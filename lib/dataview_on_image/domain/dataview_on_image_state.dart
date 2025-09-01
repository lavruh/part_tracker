import 'dart:convert';
import 'dart:io';

import 'package:data_on_image_view/domain/overview_screen_config.dart';
import 'package:data_on_image_view/domain/view_port.dart';
import 'package:file_provider/file_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/dataview_on_image/ui/screens/dataview_on_image_editor.dart';
import 'package:part_tracker/dataview_on_image/ui/screens/dataview_on_image_screen.dart';
import 'package:part_tracker/dataview_on_image/ui/widgets/dataview_on_image_settings_widget.dart';
import 'package:part_tracker/utils/domain/settings_repo.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';
import 'package:part_tracker/utils/ui/widgets/question_dialog_widget.dart';

class DataViewOnImageState extends GetxController {
  final _configs = <UniqueId, String>{}.obs;
  final _selectedConfig = <OverviewScreenConfig>[].obs;
  UniqueId? selectedConfigLocationId;
  String selectedConfigPath = '';
  final data = <String, Map<String, String>>{}.obs;
  bool configChanged = false;
  final table = 'dataOnImageConfigs';
  final _settings = Get.find<SettingsRepo>();
  final _fileProvider = Get.find<IFileProvider>();

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

  @override
  onInit() {
    getConfigs();
    super.onInit();
  }

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
    final jsonString = _encodeConfigs();
    _settings.setString(table, jsonString);
  }

  getConfigs() async {
    final configsString = _settings.getString(table);
    if (configsString == null) return;

    final data = jsonDecode(configsString);
    _configs.addAll(data.map<UniqueId, String>(
        (key, value) => MapEntry(UniqueId(id: key), "$value")));
  }

  bool isConfigExist(UniqueId locationId) {
    return _configs.containsKey(locationId);
  }

  showDataViewOnImage(
    BuildContext context, {
    required UniqueId locationId,
    required Map<String, Map<String, String>> data,
  }) async {
    final c = context;
    selectedConfigLocationId = locationId;
    if (_configs.isEmpty) await getConfigs();

    if (!isConfigExist(locationId) && c.mounted) {
      await createOrSelectConfig(locationId, context);
    }
    if (isConfigExist(locationId)) {
      final path = _configs[locationId] ?? '';
      try {
        await setSelectedConfig(path);
        this.data.value = data;
        final config = selectedConfig;
        if (config != null) {
          if (config.path.isEmpty) {
            showConfigEditor();
          } else {
            Get.to(() => const DataViewOnImageScreen());
          }
        }
      } on Exception catch (e) {
        await Get.defaultDialog(middleText: e.toString());
        if (c.mounted) createOrSelectConfig(locationId, context);
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

  selectConfigFile(BuildContext context) async {
    final locationId = selectedConfigLocationId;
    try {
      if (locationId == null) throw Exception('Location is not selected');
      final f = await _fileProvider.selectFile(
          context: context,
          title: 'Select config file',
          allowedExtensions: ['json']);

      final path = f.path;
      addConfig(configPath: path, locationId: locationId);
    } catch (e) {
      Get.defaultDialog(middleText: "$e");
    }
  }

  createOrSelectConfig(UniqueId locationId, BuildContext context) async {
    final c = context;
    final act = await questionDialogWidget(
        question:
            'Config file not found.\n Yes to create new,\n No select existing file.');
    if (act != null && c.mounted) {
      if (act) {
        await _createConfigFile(context);
      } else {
        await selectConfigFile(context);
      }
    }
  }

  Future<void> _createConfigFile(BuildContext context) async {
    final c = context;
    final locationId = selectedConfigLocationId;
    try {
      if (locationId == null) throw Exception('Location is not selected');
      final conf = OverviewScreenConfig(path: "", viewPorts: {});
      if (!c.mounted) return;
      final file = await _fileProvider.selectFile(
        context: c,
        title: 'Save new config',
        allowedExtensions: ['json'],
      );
      final path = file.path;
      File(path).writeAsStringSync(conf.toJson());
      addConfig(configPath: path, locationId: locationId);
      showConfigEditor();
    } on Exception catch (e) {
      Get.defaultDialog(middleText: "$e");
      return;
    }
  }

  void reloadConfigFile() async {
    await setSelectedConfig(selectedConfigPath);
  }

  saveConfig(OverviewScreenConfig conf) async {
    updateConfig(conf);
    if (selectedConfigPath.isNotEmpty) {
      File(selectedConfigPath).writeAsString(conf.toJson());
    }
  }

  Future<File> selectFile(BuildContext context, String title) async {
    return _fileProvider.selectFile(context: context, title: title);
  }

  String _encodeConfigs() {
    final data = _configs.map<String, String>((k, v) => MapEntry(k.id, v));
    return jsonEncode(data);
  }
}
