import 'dart:io';

import 'package:file_provider/file_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

setAppDB(BuildContext context) async {
  final cont = context;
  final pref = Get.find<SharedPreferences>();
  final provider = Get.find<IFileProvider>();
  try {
    final f = await provider.selectFile(
      context: context,
      title: 'Select db file to load from or create new db',
      allowedExtensions: ['db'],
    );
    final path = f.path;

    if (path.isNotEmpty) {
      pref.setString('dbPath', path);
      final file = File(path);
      if (!file.existsSync()) {
        file.createSync();
      }
      if (cont.mounted) {
        RestartWidget.restartApp(cont);
      }
    }
  } catch (e) {
    Get.defaultDialog(middleText: "$e");
    return;
  }
}
