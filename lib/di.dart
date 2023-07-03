import 'package:get/get.dart';
import 'package:part_tracker/dataview_on_image/domain/dataview_on_image_state.dart';
import 'package:part_tracker/locations/domain/location_editor_state.dart';
import 'package:part_tracker/locations/domain/locations_manager_state.dart';
import 'package:part_tracker/locations/domain/locations_menu_state.dart';
import 'package:part_tracker/logbook/domain/logbook_state.dart';
import 'package:part_tracker/part_types/domain/part_types_state.dart';
import 'package:part_tracker/parts/domain/part_editor_state.dart';
import 'package:part_tracker/parts/domain/parts_manager_state.dart';
import 'package:part_tracker/utils/data/i_db_service.dart';
import 'package:part_tracker/utils/data/sembast_db_service.dart';

initDependencies() async {
  final db = Get.put<IDbService>(SembastDbService());
  await db.init(dbName: 'part_tracker', defaultTable: 'root');
  final log = Get.put(LogbookState());
  log.getAll();
  Get.lazyPut(()=>DataViewOnImageState());
  Get.put(PartTypesState());
  Get.put(PartEditorState());
  Get.put(PartsManagerState());
  Get.put(LocationEditorState());
  Get.put(LocationsMenuState());
  Get.put(LocationManagerState());
}

