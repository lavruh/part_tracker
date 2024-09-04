import 'package:get/get.dart';
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
import 'package:part_tracker/utils/data/i_db_service.dart';
import 'package:part_tracker/utils/data/i_file_provider.dart';
import 'package:part_tracker/utils/data/sembast_db_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

Future<bool> initDependencies() async {
  try {
    final pref =
        Get.put<SharedPreferences>(await SharedPreferences.getInstance());
    Get.put<IFileProvider>(FileProvider.getInstance());
    final path = pref.getString('dbPath');
    if (path == null) {
      throw Exception('No db selected');
    }
    final dirName = Get.put<String>(p.dirname(path), tag: 'dirName');
    final db = Get.put<IDbService>(SembastDbService());
    await db.init(dbName: 'part_tracker', dbPath: path);
    Get.put(BackupState(ZipBackupService(dirName)));
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
    return true;
  } catch (e) {
    rethrow;
  }
}
