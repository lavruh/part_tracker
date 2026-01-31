import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:part_tracker/backup/data/zip_backup_service.dart';
import 'package:part_tracker/backup/domain/backups_state.dart';
import 'package:part_tracker/locations/domain/entities/location.dart';
import 'package:part_tracker/locations/domain/location_editor_state.dart';
import 'package:part_tracker/locations/domain/locations_manager_state.dart';
import 'package:part_tracker/locations/domain/locations_menu_state.dart';
import 'package:part_tracker/logbook/domain/logbook_state.dart';
import 'package:part_tracker/maintenance/domain/maintenance_notifier.dart';
import 'package:part_tracker/part_types/domain/entities/part_type.dart';
import 'package:part_tracker/part_types/domain/part_types_state.dart';
import 'package:part_tracker/parts/domain/entities/part.dart';
import 'package:part_tracker/parts/domain/part_editor_state.dart';
import 'package:part_tracker/parts/domain/parts_manager_state.dart';
import 'package:part_tracker/running_hours/domain/entities/running_hours.dart';
import 'package:part_tracker/utils/data/i_db_service.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';
import 'package:path/path.dart' as p;
// ignore: depend_on_referenced_packages
import 'package:file/memory.dart';
import '../mocks.dart';

import 'locations_manager_test.mocks.dart';

@GenerateMocks([IDbService])
void main() {
  late ZipBackupService zip;
  late MemoryFileSystem fs;
  final backUpDir = p.join("test", 'backup');

  late LocationManagerState sut;
  late Location location;
  late IDbService dbMock;
  late PartsManagerState partsManagerState;

  setUp(() async {
    Get.put<BackupState>(MockBackupState());

    dbMock = Get.put<IDbService>(MockIDbService());
    when(dbMock.getAll(table: 'locations'))
        .thenAnswer((_) => const Stream.empty());
    when(dbMock.getAll(table: 'parts')).thenAnswer((_) => const Stream.empty());
    when(dbMock.getAll(table: 'maintenance_plans')).thenAnswer((_) => const Stream.empty());
    Get.put(LogbookState());
    Get.put(LocationEditorState());
    Get.put(LocationsMenuState());
    Get.put(PartTypesState());
    Get.put(PartEditorState());
    sut = Get.put(LocationManagerState());
    Get.put(MaintenanceNotifier());
    partsManagerState = Get.put(PartsManagerState());
    location = Location.empty(name: 'test location');
  });

  test('Create Location', () {
    sut.updateLocation(location);
    expect(sut.locations.length, 1);
    expect(sut.getParentLocation(location.id), location);
    verify(dbMock.update(
            id: location.id.toString(),
            item: location.toMap(),
            table: sut.table))
        .called(1);
  });

  tearDown(() => sut.locations.clear());

  test('get Locations', () async {
    when(dbMock.getAll(table: sut.table))
        .thenAnswer((_) => Stream.fromIterable([location.toMap()]));

    await sut.getAllLocations();

    final retrievedLocation = sut.getParentLocation(location.id);
    expect(retrievedLocation, location);
  });

  test('Update Location', () {
    sut.updateLocation(location);

    final updatedLocation = location.copyWith(name: 'Updated Location');
    sut.updateLocation(updatedLocation);

    final retrievedLocation = sut.getParentLocation(location.id);
    expect(retrievedLocation.name, 'Updated Location');
    verify(dbMock.update(
        id: location.id.toString(), item: location.toMap(), table: sut.table));
  });

  test('Delete Location', () async {
    final item = Location.empty(name: 'name');
    await sut.updateLocation(item);
    expect(sut.locations.length, 1);
    expect(sut.locations.keys, contains(item.id));

    await sut.deleteLocation(item.id);
    expect(sut.locations.length, 0);
    verify(dbMock.delete(id: item.id.toString(), table: sut.table));
  });

  test(
      '''updateLocationRunningHours should update rh of location, sub tree and parts
      Parts should be updated with location rh delta''', () async {
    final locationId = UniqueId();
    final location = Location.empty(name: 'test location')
        .copyWith(runningHours: RunningHours(0));
    final partId = UniqueId();
    final part = Part.newPart(partNo: partId, type: PartType.empty());
    final p2 = part.copyWith(
        partNo: UniqueId(id: 'p2'), runningHours: RunningHours(3));
    final p3 = part.copyWith(
        partNo: UniqueId(id: 'p3'), runningHours: RunningHours(1));
    await partsManagerState.updatePart(part);
    await partsManagerState.updatePart(p2);
    await partsManagerState.updatePart(p3);
    await sut.updateLocation(location);
    final subLocation1 = location.copyWith(
        id: UniqueId(id: 'sub1'),
        name: 'Sub Location 1',
        parentLocation: locationId);
    final subLocation2 = subLocation1.copyWith(
        id: UniqueId(id: 'sub2'), name: 'Sub Location 2', parts: [p2.partNo]);
    final subSubLocation2 = subLocation2.copyWith(
        id: UniqueId(id: 'ss2'),
        name: 'ss2',
        parentLocation: subLocation2.id,
        parts: [p3.partNo],
        runningHours: RunningHours(5));
    // Add the sub-locations to the state
    sut.updateLocation(subLocation1);
    sut.updateLocation(subLocation2);
    sut.updateLocation(subSubLocation2);

    // Update the running hours for the location, sub-locations, and parts
    sut.updateLocationRunningHours(
      locationId: locationId,
      rh: RunningHours(10),
    );

    // Check if the running hours are updated correctly for the location, sub-locations, and parts
    expect(sut.locations[locationId]?.runningHours, RunningHours(10));
    expect(
        sut.getParentLocation(subLocation1.id).runningHours, RunningHours(10));
    expect(
        sut.getParentLocation(subLocation2.id).runningHours, RunningHours(10));
    expect(sut.getParentLocation(subSubLocation2.id).runningHours,
        RunningHours(10));
    expect(partsManagerState.parts[p2.partNo]?.runningHours.value, 13);
    expect(partsManagerState.parts[p3.partNo]?.runningHours.value, 11);
  });

  test(
      'get sub locations should return locations with specified id or with null',
      () async {
    final loc = Location.empty(name: 'name');
    await sut.updateLocation(loc);
    await sut.updateLocation(loc.copyWith(id: UniqueId(id: 'root2')));
    await sut.updateLocation(
        loc.copyWith(id: UniqueId(id: 'sub1'), parentLocation: loc.id));

    final roots = sut.getSubLocations(null);
    final subs = sut.getSubLocations(loc.id);

    expect(subs.length, 1);
    expect(roots.length, 2);
    expect(roots, contains(loc));
  });

  test('toMap should return a valid map representation', () {
    final location = Location(
      id: UniqueId(),
      name: 'Test Location',
      allowedPartTypes: {
        UniqueId(id: 'type1'): null,
        UniqueId(id: 'type2'): null
      },
      parentLocation: UniqueId(),
      parts: [UniqueId(id: 'part1'), UniqueId(id: 'part2')],
      runningHours: RunningHours(123),
    );

    // Act
    final map = location.toMap();

    // Assert
    expect(map, isA<Map<String, dynamic>>());
    expect(map['id'], isA<String>());
    expect(map['name'], 'Test Location');
    expect(map['allowedPartTypes'], isA<Map<String, dynamic>>());
    expect(map['allowedPartTypes'].keys.length, 2);
    expect(map['parentLocation'], isA<String>());
    expect(map['parts'], isA<List<String>>());
    expect(map['parts'], hasLength(2));
    expect(map['runningHours'], location.runningHours?.toMap());

    final location2 = location.copyWith(clearRunningHours: true);
    final map2 = location2.toMap();
    expect(map2['runningHours'], null);
  });

  test('fromMap should create a valid Location object', () {
    // Arrange
    final map = Location(
      id: UniqueId(),
      name: 'Test Location',
      allowedPartTypes: {UniqueId(id: 'pt1'): null, UniqueId(id: 'pt2'): null},
      parentLocation: UniqueId(id: 'parentLoc'),
      parts: [UniqueId(id: 'part1'), UniqueId(id: 'part2')],
    ).toMap();

    // Act
    final location = Location.fromMap(map);

    // Assert
    expect(location.id, isA<UniqueId>());
    expect(location.name, 'Test Location');
    expect(location.allowedPartTypes, isA<Map<UniqueId, int?>>());
    expect(location.allowedPartTypes, hasLength(2));
    expect(location.parentLocation, isA<UniqueId>());
    expect(location.parts, isA<List<UniqueId>>());
    expect(location.parts, hasLength(2));
  });
}
