import 'dart:io';

import 'package:data_on_image_view/domain/overview_screen_config.dart';
import 'package:data_on_image_view/domain/view_port.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:part_tracker/dataview_on_image/ui/screens/dataview_on_image_editor.dart';
import 'package:part_tracker/dataview_on_image/ui/screens/dataview_on_image_screen.dart';
import 'package:part_tracker/dataview_on_image/ui/widgets/dataview_on_image_settings_widget.dart';
import 'package:part_tracker/utils/data/i_db_service.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';
import 'package:part_tracker/utils/ui/widgets/question_dialog_widget.dart';

class DataViewOnImageState extends GetxController {
  final _configs = <UniqueId, String>{}.obs;
  final _selectedConfig = <OverviewScreenConfig>[].obs;
  String selectedConfigPath = '';
  final data = <String, Map<String, String>>{}.obs;
  bool configChanged = false;
  final table = 'dataOnImageConfigs';
  final IDbService _db = Get.find();

  OverviewScreenConfig? get selectedConfig =>
      _selectedConfig.isNotEmpty ? _selectedConfig[0] : null;

  set selectedConfig(OverviewScreenConfig? conf) {
    if (conf != null) {
      _selectedConfig.value = [conf];
    } else {
      _selectedConfig.clear();
    }
  }

  bool get configSelected => _selectedConfig.isNotEmpty;

  setSelectedConfig(String path) async {
    final file = File(path);
    if (file.existsSync()) {
      selectedConfigPath = path;
      selectedConfig = OverviewScreenConfig.fromJson(file.readAsStringSync());
    } else {
      throw Exception('Config file [$path] does not exist');
    }
  }

  addConfig({required String configPath, required UniqueId locationId}) {
    _configs[locationId] = configPath;
  }

  getConfigs() async {
    await for (final map in _db.getAll(table: table)) {
      final id = UniqueId.fromMap(map.keys.first);
      addConfig(configPath: map[id.id], locationId: id);
    }
  }

  showDataViewOnImage({
    required UniqueId locationId,
    required Map<String, Map<String, String>> data,
  }) async {
    if (_configs.isEmpty) {
      await getConfigs();
    }
    if (!_configs.containsKey(locationId)) {
      await createOrSelectConfig(locationId);
    }
    if (_configs.containsKey(locationId)) {
      final path = _configs[locationId] ?? '';
      try {
        await setSelectedConfig(path);
        this.data.value = data;
        Get.to(() => const DataViewOnImageScreen());
      } on Exception catch (e) {
        await Get.defaultDialog(middleText: e.toString());
        selectConfigFile(locationId);
      }
    }
  }

  showConfigEditor() {
    final config = selectedConfig;
    if (config != null) {
      Get.to(() => const DataViewOnImageEditor());
    }
  }

  showDataViewOnImageSettings() {
    Get.defaultDialog(
        content: const DataViewOnImageSettingsWidget(), title: '');
  }

  updateConfig(OverviewScreenConfig conf) {
    selectedConfig = conf;
  }

  Map<String, bool> getRelatedViewPortIds() {
    Map<String, bool> res = {};
    final conf = selectedConfig;
    if (conf != null) {
      for (final e in conf.viewPorts.keys) {
        res.putIfAbsent(e, () => true);
      }
    }
    for (final e in data.keys) {
      res.putIfAbsent(e, () => false);
    }
    return res;
  }

  toggleViewPortActivation(String id) {
    final conf = selectedConfig;
    if (conf != null) {
      Map<String, ViewPort> ports = conf.viewPorts;
      if (viewPortActivated(id)) {
        ports.remove(id);
      } else {
        ports.putIfAbsent(id, () => ViewPort(id: id, title: id, x: 10, y: 10));
      }
      updateConfig(conf.copyWith(viewPorts: ports));
    }
  }

  bool viewPortActivated(String id) {
    final conf = selectedConfig;
    if (conf != null) {
      return conf.viewPorts.containsKey(id);
    }
    return false;
  }

  selectConfigFile(UniqueId locationId) async {
    final f = await FilePicker.platform.pickFiles(
      dialogTitle: 'Select config file',
      allowedExtensions: ['.json'],
    );
    if (f != null) {
      final path = f.paths.first ?? '';
      addConfig(configPath: path, locationId: locationId);
      _db.update(id: locationId.id, item: {locationId.id: path}, table: table);
    }
  }

  createOrSelectConfig(UniqueId locationId) async {
    final act = await questionDialogWidget(
        question:
            'Config file not found.\n Yes to create new,\n No select existing file.');
    if (act != null) {
      if (act) {
        await _createConfigFile(locationId);
      } else {
        await selectConfigFile(locationId);
      }
    }
  }

  Future<void> _createConfigFile(UniqueId locationId) async {
    final img =
        await FilePicker.platform.pickFiles(dialogTitle: 'Select image file');
    final imgPath = img?.files.first.path;
    if (img == null || imgPath == null) return;

    final conf = OverviewScreenConfig(path: imgPath, viewPorts: {});
    final path =
        await FilePicker.platform.saveFile(dialogTitle: 'Save new config');
    if (path != null) {
      File(path).writeAsStringSync(conf.toJson());
      addConfig(configPath: path, locationId: locationId);
      _db.update(id: locationId.id, item: {locationId.id: path}, table: table);
    }
  }

  void reloadConfigFile() async {
    await setSelectedConfig(selectedConfigPath);
  }
}
