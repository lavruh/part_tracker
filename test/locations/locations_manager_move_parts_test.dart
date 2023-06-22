import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:part_tracker/locations/domain/entities/location.dart';
import 'package:part_tracker/locations/domain/location_editor_state.dart';
import 'package:part_tracker/locations/domain/locations_manager_state.dart';
import 'package:part_tracker/locations/domain/locations_menu_state.dart';
import 'package:part_tracker/part_types/domain/entities/part_type.dart';
import 'package:part_tracker/parts/domain/entities/part.dart';
import 'package:part_tracker/parts/domain/parts_manager_state.dart';
import 'package:part_tracker/running_hours/domain/entities/running_hours.dart';
import 'package:part_tracker/utils/data/i_db_service.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';

import 'locations_manager_test.mocks.dart';

main() {
  late LocationManagerState sut;
  late IDbService dbMock;
  late PartsManagerState partsManagerState;
  final partType = PartType.empty();
  final partId = UniqueId();
  final sourceLocationId = UniqueId(id: 'source');
  final targetLocationId = UniqueId(id: 'target');
  final part = Part.newPart(partNo: partId, type: partType);
  final sourceLocation = Location(
    id: sourceLocationId,
    name: 'Source Location',
    parts: [partId],
    allowedPartTypes: {},
  );

  setUp(() async {
    dbMock = Get.put<IDbService>(MockIDbService());
    when(dbMock.getAll(table: 'locations'))
        .thenAnswer((_) => const Stream.empty());
    when(dbMock.getAll(table: 'parts')).thenAnswer((_) => const Stream.empty());
    Get.put(LocationEditorState());
    Get.put(LocationsMenuState());
    partsManagerState = Get.put(PartsManagerState());
    sut = Get.put(LocationManagerState());
  });

  tearDown(() {
    partsManagerState.parts.clear();
    sut.locations.clear();
  });

  test('Move Part Between Locations', () async {
    final targetLocation = Location(
      id: targetLocationId,
      name: 'Target Location',
      parts: [],
      allowedPartTypes: {partType.id: 0},
    );

    // Add locations to the state
    await partsManagerState.updatePart(part);
    await sut.updateLocation(sourceLocation);
    await sut.updateLocation(targetLocation);

    // Call the method
    await sut.movePartBetweenLocations(
      partId: partId,
      sourceLocation: sourceLocationId,
      targetLocation: targetLocationId,
    );

    // Verify that the part was moved to the target location
    expect(sut.locations[targetLocationId]?.parts, contains(partId));
    expect(sut.locations[sourceLocationId]?.parts, isEmpty);
  });

  test(
      'movePartBetweenLocations should throw exception if Part not found in part manager',
      () async {
    final targetLocation = Location(
      id: targetLocationId,
      name: 'Target Location',
      parts: [],
      allowedPartTypes: {partType.id: 0},
    );

    // Add locations to the state
    await sut.updateLocation(sourceLocation);
    await sut.updateLocation(targetLocation);

    // Call the method
    expect(
        () async => await sut.movePartBetweenLocations(
              partId: partId,
              sourceLocation: sourceLocationId,
              targetLocation: targetLocationId,
            ),
        throwsA(
          predicate(
              (e) => e is LocationManagerException && e.m == 'Part not found'),
        ));
  });

  test("""movePartBetweenLocations should throw exception 
      if running hours of part updated more then 1 day ago""", () async {
    final targetLocation = Location(
      id: targetLocationId,
      name: 'Target Location',
      parts: [],
      allowedPartTypes: {partType.id: 0},
    );

    // Add locations to the state
    final now = DateTime.now();
    final rh = RunningHours.fromMap({
      'value': 0,
      'date': now.copyWith(day: now.day - 1).millisecondsSinceEpoch,
    });
    await partsManagerState.updatePart(part.copyWith(runningHours: rh));
    await sut.updateLocation(sourceLocation);
    await sut.updateLocation(targetLocation);

    // Call the method
    expect(
        () async => await sut.movePartBetweenLocations(
              partId: partId,
              sourceLocation: sourceLocationId,
              targetLocation: targetLocationId,
            ),
        throwsA(
          predicate((e) =>
              e is LocationManagerException &&
              e.m == 'Running hours are not up to date'),
        ));
  });

  test("""movePartBetweenLocations should throw exception 
      if part is not in the list of allowed parts for target location""",
      () async {
    final targetLocation = Location(
      id: targetLocationId,
      name: 'Target Location',
      parts: [],
      allowedPartTypes: {},
    );

    await partsManagerState.updatePart(part);
    await sut.updateLocation(sourceLocation);
    await sut.updateLocation(targetLocation);

    expect(
        () async => await sut.movePartBetweenLocations(
              partId: partId,
              sourceLocation: sourceLocationId,
              targetLocation: targetLocationId,
            ),
        throwsA(
          predicate((e) =>
              e is LocationManagerException &&
              e.m == 'Part is not suitable for target location'),
        ));
  });

  test("""movePartBetweenLocations should throw exception 
      if target location is full of parts with same type""", () async {
    final targetLocation = Location(
      id: targetLocationId,
      name: 'Target Location',
      parts: [partId],
      allowedPartTypes: {partType.id: 1},
    );

    await partsManagerState.updatePart(part);
    await sut.updateLocation(sourceLocation);
    await sut.updateLocation(targetLocation);

    expect(
        () async => await sut.movePartBetweenLocations(
              partId: partId,
              sourceLocation: sourceLocationId,
              targetLocation: targetLocationId,
            ),
        throwsA(
          predicate((e) =>
              e is LocationManagerException &&
              e.m == 'Location already has a part of same type'),
        ));
  });
}
