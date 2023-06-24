import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:part_tracker/di.mocks.dart';
import 'package:part_tracker/locations/domain/entities/location.dart';
import 'package:part_tracker/locations/domain/location_editor_state.dart';
import 'package:part_tracker/locations/domain/locations_manager_state.dart';
import 'package:part_tracker/locations/domain/locations_menu_state.dart';
import 'package:part_tracker/part_types/domain/entities/part_type.dart';
import 'package:part_tracker/part_types/domain/part_types_state.dart';
import 'package:part_tracker/parts/domain/part_editor_state.dart';
import 'package:part_tracker/parts/domain/parts_manager_state.dart';
import 'package:part_tracker/running_hours/domain/entities/running_hours.dart';
import 'package:part_tracker/utils/data/i_db_service.dart';
import 'package:part_tracker/utils/data/sembast_db_service.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';

import 'parts/domain/entities/part.dart';

@GenerateMocks([IDbService])
initDependencies() async {
  // initFakeDB();
  final db = Get.put<IDbService>(SembastDbService());
  await db.init(dbName: 'part_tracker', defaultTable: 'root');
  Get.put(PartTypesState());
  Get.put(PartEditorState());
  Get.put(PartsManagerState());
  Get.put(LocationEditorState());
  Get.put(LocationsMenuState());
  Get.put(LocationManagerState());
}

initFakeDB() {
  final dbMock = Get.put<IDbService>(MockIDbService());

  final partTypes = [
    PartType(id: UniqueId(id: 'CylHead'), name: 'Cylinder Head'),
    PartType(id: UniqueId(id: 'FuelPump'), name: 'FuelPump'),
    PartType(id: UniqueId(id: 'Fuel Injector'), name: 'Fuel Injector'),
  ];

  final parts = [
    Part.newPart(partNo: UniqueId(id: '1'), type: partTypes.first),
    Part.newPart(partNo: UniqueId(id: 'QotN2'), type: partTypes.first),
    Part.newPart(partNo: UniqueId(id: '3'), type: partTypes.last),
    Part(
        partNo: UniqueId(id: 'QoN23'),
        runningHours: RunningHours(123),
        remarks: 'Changed on WO123123, PO?',
        type: partTypes.last),
  ];

  final loc = Location.empty(name: 'Main engine');
  final locations = [
    loc,
    loc.copyWith(
      id: UniqueId(id: 'QueenStore'),
      name: 'Queen store',
      parts: parts.map((e) => e.partNo).toList(),
    ),
    loc.copyWith(
        id: UniqueId(id: '2'),
        name: 'Aux Engine',
        runningHours: RunningHours(12345)),
    loc.copyWith(id: UniqueId(id: 'ME_PS'), name: 'PS', parentLocation: loc.id),
    loc.copyWith(id: UniqueId(id: 'ME_SB'), name: 'SB', parentLocation: loc.id),
    loc.copyWith(
      id: UniqueId(id: 'ME_PS_A1'),
      name: 'A1',
      parentLocation: UniqueId(id: 'ME_PS'),
    ),
    loc.copyWith(
        id: UniqueId(id: 'ME_PS_B2'),
        name: 'B2',
        parentLocation: UniqueId(id: 'ME_PS')),
  ];

  when(dbMock.getAll(table: 'parts')).thenAnswer(
      (realInvocation) => Stream.fromIterable(parts.map((e) => e.toMap())));

  when(dbMock.getAll(table: 'part_types')).thenAnswer(
      (realInvocation) => Stream.fromIterable(partTypes.map((e) => e.toMap())));

  when(dbMock.getAll(table: 'locations')).thenAnswer(
      (realInvocation) => Stream.fromIterable(locations.map((e) => e.toMap())));
}
