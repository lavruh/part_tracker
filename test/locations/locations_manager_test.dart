import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:part_tracker/locations/domain/entities/location.dart';
import 'package:part_tracker/locations/domain/locations_manager_state.dart';
import 'package:part_tracker/utils/data/i_db_service.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';

import 'locations_manager_test.mocks.dart';

@GenerateMocks([IDbService])
void main() {
  group('LocationManagerState', () {
    late LocationManagerState sut;
    late Location location;
    late IDbService dbMock;

    setUp(() {
      dbMock = Get.put<IDbService>(MockIDbService());
      sut = LocationManagerState();
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
          id: location.id.toString(),
          item: location.toMap(),
          table: sut.table));
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
        '''updateLocationRunningHours should update rh of location, sub tree and parts''',
        () async {
      final locationId = UniqueId();
      final location = Location.empty(name: 'test location');
      sut.updateLocation(location);
      final subLocation1 = location.copyWith(
          id: UniqueId(id: 'sub1'),
          name: 'Sub Location 1',
          parentLocation: locationId,
          parts: [UniqueId()]);
      final subLocation2 = subLocation1.copyWith(
          id: UniqueId(id: 'sub2'), name: 'Sub Location 2');
      final subSubLocation2 = subLocation2.copyWith(
          id: UniqueId(id: 'ss2'),
          name: 'ss2',
          parentLocation: subLocation2.id,
          parts: [UniqueId()]);
      // Add the sub-locations to the state
      sut.updateLocation(subLocation1);
      sut.updateLocation(subLocation2);
      sut.updateLocation(subSubLocation2);

      // Update the running hours for the location, sub-locations, and parts
      sut.updateLocationRunningHours(
        locationId: locationId,
        rh: 10,
      );

      // Check if the running hours are updated correctly for the location, sub-locations, and parts
      expect(sut.locations[locationId]?.runningHours, 10);
      expect(sut.getParentLocation(subLocation1.id).runningHours, 10);
      expect(sut.getParentLocation(subLocation2.id).runningHours, 10);
      expect(sut.getParentLocation(subSubLocation2.id).runningHours, 10);
    });
  });

  test('toMap should return a valid map representation', () {
    final location = Location(
      id: UniqueId(),
      name: 'Test Location',
      allowedPartTypes: [UniqueId(), UniqueId()],
      parentLocation: UniqueId(),
      parts: [UniqueId(id: 'part1'), UniqueId(id: 'part2')],
      runningHours: 123,
    );

    // Act
    final map = location.toMap();

    // Assert
    expect(map, isA<Map<String, dynamic>>());
    expect(map['id'], isA<String>());
    expect(map['name'], 'Test Location');
    expect(map['allowedPartTypes'], isA<List<dynamic>>());
    expect(map['allowedPartTypes'], hasLength(2));
    expect(map['parentLocation'], isA<String>());
    expect(map['parts'], isA<List<String>>());
    expect(map['parts'], hasLength(2));
    expect(map['runningHours'], location.runningHours);

    final location2 = location.copyWith(clearRunningHours: true);
    final map2 = location2.toMap();
    expect(map2['runningHours'], null);
  });

  test('fromMap should create a valid Location object', () {
    // Arrange
    final map = Location(
      id: UniqueId(),
      name: 'Test Location',
      allowedPartTypes: [UniqueId(), UniqueId()],
      parentLocation: UniqueId(),
      parts: [UniqueId(id: 'part1'), UniqueId(id: 'part2')],
    ).toMap();

    // Act
    final location = Location.fromMap(map);

    // Assert
    expect(location.id, isA<UniqueId>());
    expect(location.name, 'Test Location');
    expect(location.allowedPartTypes, isA<List<UniqueId>>());
    expect(location.allowedPartTypes, hasLength(2));
    expect(location.parentLocation, isA<UniqueId>());
    expect(location.parts, isA<List<UniqueId>>());
    expect(location.parts, hasLength(2));
  });
}
