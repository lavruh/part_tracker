import 'dart:io';

import 'package:data_on_image_view/domain/overview_screen_config.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:part_tracker/dataview_on_image/ui/screens/dataview_on_image_screen.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';

class DataViewOnImageState extends GetxController {
  final _configs = <UniqueId, String>{}.obs;
  final _selectedConfig = <OverviewScreenConfig>[].obs;
  final data = <String, Map<String, String>>{}.obs;

  OverviewScreenConfig? get selectedConfig =>
      _selectedConfig.isNotEmpty ? _selectedConfig[0] : null;

  set selectedConfig(OverviewScreenConfig? conf) {
    if (conf != null) {
      _selectedConfig.value = [conf];
    } else {
      _selectedConfig.clear();
    }
  }

  addConfig({required String configPath, required UniqueId locationId}) {
    _configs.putIfAbsent(locationId, () => configPath);
  }

  showDataViewOnImage({
    required UniqueId locationId,
    required Map<String, Map<String, String>> data,
  }) async {
    if (!_configs.containsKey(locationId)) {
      final f = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select config file',
        allowedExtensions: ['.json'],
      );
      if (f != null) {
        final path = f.paths.first ?? '';
        addConfig(configPath: path, locationId: locationId);
      }
    }
    if (_configs.containsKey(locationId)) {
      final path = _configs[locationId] ?? '';
      selectedConfig =
          OverviewScreenConfig.fromJson(File(path).readAsStringSync());
      this.data.value = data;
      Get.to(() => const DataViewOnImageScreen());
    }
  }
}
