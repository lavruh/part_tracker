import 'dart:io';

import 'package:file_provider/file_provider.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:part_tracker/backup/data/zip_backup_service.dart';
import 'package:part_tracker/backup/domain/backups_state.dart';
import 'package:part_tracker/dataview_on_image/domain/dataview_on_image_state.dart';
import 'package:part_tracker/locations/domain/location_editor_state.dart';
import 'package:part_tracker/locations/domain/locations_manager_state.dart';
import 'package:part_tracker/locations/domain/locations_menu_state.dart';
import 'package:part_tracker/logbook/domain/logbook_state.dart';
import 'package:part_tracker/part_types/domain/part_types_state.dart';
import 'package:part_tracker/parts/domain/part_editor_state.dart';
import 'package:part_tracker/parts/domain/parts_manager_state.dart';
import 'package:part_tracker/utils/data/db_lock_manager.dart';
import 'package:part_tracker/utils/data/i_db_service.dart';
import 'package:part_tracker/utils/data/sembast_db_service.dart';
import 'package:part_tracker/utils/domain/settings_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

Future<bool> initDependencies() async {
  try {
    final pref = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(pref);
    final lockManager = Get.put(DBLockManager());

    Get.put<IFileProvider>(FileProvider.getInstance());
    final path = pref.getString('dbPath');
    if (path == null) {
      throw Exception('No db selected');
    }
    if (lockManager.isLocked(path)) {
      throw Exception('DB [$path] is in use by another user and locked.');
    }

    final dirName = Get.put<String>(p.dirname(path), tag: 'dirName');
    final db = Get.put<IDbService>(SembastDbService());
    await db.init(dbName: 'part_tracker', dbPath: path);

    final settingsPath = p.join(dirName, "settings.db");
    final settingsFile = File(settingsPath);
    if (!settingsFile.existsSync()) settingsFile.createSync(recursive: true);

    final settingsDb = SembastDbService();
    await settingsDb.init(dbName: 'settings', dbPath: settingsPath);
    final settings = Get.put<SettingsRepo>(SettingsRepo(settingsDb));
    await settings.loadSettings();

    final backupState = BackupState(ZipBackupService(dirName));
    Get.put<BackupState>(backupState);

    final now = DateTime.now();
    backupState.createBackup(
        description: DateFormat("yyyy-MM-dd_HH-mm-ss").format(now));

    final log = Get.put(LogbookState());
    log.getAll();
    Get.lazyPut(() => DataViewOnImageState());
    Get.put(PartTypesState());
    Get.put(PartEditorState());
    Get.put(PartsManagerState());
    Get.put(LocationEditorState());
    Get.put(LocationsMenuState());
    Get.put(LocationManagerState());
    final packageInfo = await PackageInfo.fromPlatform();
    Get.put<String>(packageInfo.version, tag: 'version');
    Get.put<String>(path, tag: 'dbPath');

    await lockManager.setLock(path);

    return true;
  } catch (e) {
    rethrow;
  }
}
