import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class DBLockManager {
  String _deviceInfoString = "";
  File? _lockFile;

  DBLockManager() {
    getDeviceInfo();
  }

  getDeviceInfo() async {
    final deviceInfo = await DeviceInfoPlugin().deviceInfo;
    _deviceInfoString = deviceInfo.data.toString();
  }

  setLock(String path) async {
    debugPrint("dbPath: $path");
    final lockFilePath = _getLockfilePath(path);
    if (_deviceInfoString.isEmpty) throw Exception("Can not get device info");
    _lockFile = File(lockFilePath);
    await _lockFile?.create(recursive: true);
    await _lockFile?.writeAsString(_deviceInfoString);
  }

  removeLock() {
    final lockFile = _lockFile;
    if (lockFile == null) return;
    debugPrint("LOCK FILE >>> ${lockFile.path}");
    if (lockFile.existsSync()) {
      lockFile.deleteSync();
      debugPrint("DELETE LOCK");
    }
  }

  bool isLocked(String path) {
    final lockFile = File(_getLockfilePath(path));
    if (lockFile.existsSync()) {
      return true;
    }
    return false;
  }

  String _getLockfilePath(String path) {
    final dirName = p.dirname(path);
    final fileWithoutExtension = p.basenameWithoutExtension(path);
    return p.join(dirName, "$fileWithoutExtension.lock");
  }
}
