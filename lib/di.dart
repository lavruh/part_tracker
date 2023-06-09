import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:part_tracker/di.mocks.dart';
import 'package:part_tracker/locations/domain/entities/location.dart';
import 'package:part_tracker/locations/domain/locations_manager_state.dart';
import 'package:part_tracker/utils/data/i_db_service.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';

@GenerateMocks([IDbService])
initDependencies() {
  initFakeDB();
  final locationsManager = Get.put(LocationManagerState());
  locationsManager.getAllLocations();
}

initFakeDB() {
  final dbMock = Get.put<IDbService>(MockIDbService());
  final loc = Location.empty(name: 'Main engine');
  final locations = [
    loc,
    loc.copyWith(
        id: UniqueId(id: '2'), name: 'Aux Engine', runningHours: 12345),
    loc.copyWith(id: UniqueId(id: 'ME_PS'), name: 'PS', parentLocation: loc.id),
    loc.copyWith(id: UniqueId(id: 'ME_SB'), name: 'SB', parentLocation: loc.id),
    loc.copyWith(
        id: UniqueId(id: 'ME_PS_A1'),
        name: 'A1',
        parentLocation: UniqueId(id: 'ME_PS')),
    loc.copyWith(
        id: UniqueId(id: 'ME_PS_B2'),
        name: 'B2',
        parentLocation: UniqueId(id: 'ME_PS')),
  ];
  when(dbMock.getAll(table: 'locations')).thenAnswer(
      (realInvocation) => Stream.fromIterable(locations.map((e) => e.toMap())));
}
