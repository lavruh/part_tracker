import 'dart:io';

import 'package:get/get.dart';
import 'package:part_tracker/backup/data/i_backup_service.dart';
import 'package:part_tracker/backup/domain/entities/backup_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackupState extends GetxController {
  final availableBackups = <BackupItem>[].obs;
  final filesToBackupPaths = <String>[].obs;
  final IBackupService _service;
  final _amountOfStepsToKeep = 0.obs;
  final table = 'backups';
  final _settings = Get.find<SharedPreferences>();

  BackupState(this._service) {
    amountOfSteps = _settings.getInt('amountOfSteps') ?? 0;
    getAvailableBackups();
    getFilesToBackup();
  }

  int get amountOfSteps => _amountOfStepsToKeep.value;

  addFileToBackup(String filePath) {
    final appDir = Get.find<String>(tag: 'dirName');
    if (!File(filePath).existsSync()) {
      Get.defaultDialog(middleText: 'File does not exist.');
      return;
    }
    if (!filePath.contains(appDir)) {
      Get.defaultDialog(
          middleText:
              'File \n[$filePath]\nis not in app directory. \nSelect file from $appDir');
      return;
    }
    filesToBackupPaths.add(filePath);
    _settings.setStringList(table, filesToBackupPaths);
  }

  removeFileFromBackup(String filePath) {
    if (!filesToBackupPaths.contains(filePath)) {
      Get.defaultDialog(middleText: 'Wrong file path');
      return;
    }
    filesToBackupPaths.remove(filePath);
    _settings.setStringList(table, filesToBackupPaths);
  }

  set amountOfSteps(int val) {
    _amountOfStepsToKeep.value = val;
    _settings.setInt('amountOfSteps', val);
  }

  getAvailableBackups() async {
    availableBackups.clear();
    await for (final backup in _service.getAvailableBackups()) {
      availableBackups.add(backup);
    }
    availableBackups.sort((a, b) =>
        b.date.millisecondsSinceEpoch.compareTo(a.date.millisecondsSinceEpoch));
  }

  createBackup({String description = ""}) async {
    if (_amountOfStepsToKeep.value != 0 &&
        availableBackups.length >= _amountOfStepsToKeep.value) {
      deleteOldBackups();
    }

    try {
      await _service.backup(
        description: description,
        pathsToBackup: filesToBackupPaths,
      );
      getAvailableBackups();
    } catch (e) {
      Get.defaultDialog(middleText: e.toString());
    }
  }

  restoreToDescription({required String description}) async {
    await _service.restoreToDescription(description: description);
  }

  getFilesToBackup() async {
    filesToBackupPaths.value = _settings.getStringList(table) ?? [];
  }

  void deleteOldBackups() {
    final start = _amountOfStepsToKeep.value - 1;
    final end = availableBackups.length - 1;
    final itemsToDelete = availableBackups.sublist(start);
    availableBackups.removeRange(start, end);
    for (final i in itemsToDelete) {
      _service.deleteBackupWithDescription(description: i.description);
    }
  }
}
