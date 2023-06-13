import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/locations/domain/entities/location.dart';
import 'package:part_tracker/locations/domain/locations_manager_state.dart';

class LocationEditorState extends GetxController {
  final item = <Location>[].obs;
  final _isChanged = false.obs;

  bool isSet() => item.isNotEmpty;

  bool get isChanged => _isChanged.value;

  Location get getLocation => item.first;

  clearLocation() {
    item.clear();
    update();
  }

  setLocation(Location l) async {
    bool actFl = true;
    if (item.isNotEmpty && _isChanged.value) {
      await Get.defaultDialog(
        title: '',
        content: const Text('Save changes?'),
        actions: [
          TextButton(
              onPressed: () {
                save();
                Get.back();
              },
              child: const Text('Yes')),
          TextButton(
              onPressed: () {
                actFl = false;
                Get.back();
              },
              child: const Text('Cancel')),
          TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('No')),
        ],
      );
    }
    if (actFl) {
      item.value = [l];
      _isChanged.value = false;
      update();
    }
  }

  updateLocation(Location l) {
    item.value = [l];
    _isChanged.value = true;
    update();
  }

  save() {
    Get.find<LocationManagerState>().updateLocation(item.first);
    _isChanged.value = false;
    update();
  }
}
