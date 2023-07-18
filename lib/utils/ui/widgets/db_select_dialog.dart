import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

setAppDB(BuildContext context) async {
  final cont = context;
  final pref = Get.find<SharedPreferences>();
  final f = await FilePicker.platform
      .pickFiles(dialogTitle: 'Select db', allowedExtensions: ['db']);
  if (f != null) {
    final path = f.files.first.path;
    if (path != null) {
      pref.setString('dbPath', path);
      Get.defaultDialog(
          title: '', middleText: 'To apply changes restart app');
      if (cont.mounted) {
        RestartWidget.restartApp(cont);
      }
    }
  }
}