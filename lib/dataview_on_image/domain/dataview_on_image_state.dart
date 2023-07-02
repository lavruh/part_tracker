import 'dart:io';

import 'package:data_on_image_view/domain/overview_screen_config.dart';
import 'package:data_on_image_view/domain/view_port.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:part_tracker/dataview_on_image/ui/screens/dataview_on_image_screen.dart';
import 'package:part_tracker/dataview_on_image/ui/widgets/dataview_on_image_settings_widget.dart';
import 'package:part_tracker/utils/data/i_db_service.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';

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

  setSelectedConfig(String path) {
    selectedConfigPath = path;
    selectedConfig =
        OverviewScreenConfig.fromJson(File(path).readAsStringSync());
  }

  addConfig({required String configPath, required UniqueId locationId}) {
    _configs.putIfAbsent(locationId, () => configPath);
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
      await selectConfigFile(locationId);
    }
    if (_configs.containsKey(locationId)) {
      final path = _configs[locationId] ?? '';
      setSelectedConfig(path);
      this.data.value = data;
      Get.to(() => const DataViewOnImageScreen());
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
}
