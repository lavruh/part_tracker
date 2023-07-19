import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

setAppDB(BuildContext context) async {
  final cont = context;
  final pref = Get.find<SharedPreferences>();
  final f = await FilePicker.platform.saveFile(
      dialogTitle: 'Select db file to load from or create new db',
      allowedExtensions: ['db']);
  if (f != null) {
    final path = f;
    pref.setString('dbPath', path);
    final file = File(path);
    if (!file.existsSync()) {
      file.createSync();
    }
    Get.defaultDialog(title: '', middleText: 'To apply changes restart app');
    if (cont.mounted) {
      RestartWidget.restartApp(cont);
    }
  }
}
