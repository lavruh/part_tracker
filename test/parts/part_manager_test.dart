import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:part_tracker/part_types/domain/entities/part_type.dart';
import 'package:part_tracker/parts/domain/entities/part.dart';
import 'package:part_tracker/parts/domain/parts_manager_state.dart';
import 'package:part_tracker/running_hours/domain/entities/running_hours.dart';
import 'package:part_tracker/utils/data/i_db_service.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';

import 'part_manager_test.mocks.dart';

@GenerateMocks([IDbService])
void main() {
  late PartsManagerState sut;
  late IDbService dbMock;
  final type = PartType.empty();

  group('PartsManagerState', () {
    setUp(() {
      dbMock = Get.put<IDbService>(MockIDbService());
      when(dbMock.getAll(table: 'parts'))
          .thenAnswer((_) => const Stream.empty());
      sut = PartsManagerState();
      verify(dbMock.getAll(table: sut.table)).called(1);
    });

    tearDown(() => sut.parts.clear());

    test('updatePart should update the part correctly', () async {
      final initialPart = Part.newPart(partNo: UniqueId(), type: type);
      await sut.updatePart(initialPart);
      verify(dbMock.update(
              id: initialPart.partNo.toString(),
              item: initialPart.toMap(),
              table: sut.table))
          .called(1);
      final updatedPart = initialPart.copyWith(
          runningHours: RunningHours(20), remarks: 'wo1232');

      await sut.updatePart(updatedPart);

      final partAfterUpdate = sut.parts[initialPart.partNo];
      expect(partAfterUpdate, isNotNull);
      expect(partAfterUpdate!.remarks, updatedPart.remarks);
      expect(partAfterUpdate.runningHours, RunningHours(20));
      verify(dbMock.update(
              id: initialPart.partNo.toString(),
              item: updatedPart.toMap(),
              table: sut.table))
          .called(1);
    });

    test('deletePart should remove the part from the parts map', () async {
      // Arrange
      final part = Part.newPart(partNo: UniqueId(), type: type);
      await sut.updatePart(part);

      // Act
      await sut.deletePart(part.partNo);

      // Assert
      expect(sut.parts.containsKey(part.partNo), isFalse);
      verify(dbMock.delete(id: part.partNo.toString(), table: sut.table))
          .called(1);
    });

    test('getParts should load data from the database', () async {
      // Arrange
      final part1 = Part.newPart(partNo: UniqueId(), type: type);
      final part2 = Part.newPart(partNo: UniqueId(id: 'part2'), type: type);
      final partsData = [part1.toMap(), part2.toMap()];

      when(dbMock.getAll(table: sut.table))
          .thenAnswer((_) => Stream.fromIterable(partsData));

      // Act
      await sut.getParts();

      // Assert
      expect(sut.parts.length, 2);
      expect(sut.parts.containsKey(part1.partNo), isTrue);
      expect(sut.parts.containsKey(part2.partNo), isTrue);
      verify(dbMock.getAll(table: sut.table)).called(1);
    });

    test(
        'updatePartsRunningHours should update the running hours for specified parts',
        () async {
      // Arrange
      final part1 = Part(
          partNo: UniqueId(id: 'p1'),
          type: type,
          runningHours: RunningHours(10),
          remarks: '',
          runningHoursAtLocation: RunningHours(0));
      final part2 = Part(
          partNo: UniqueId(id: 'p2'),
          type: type,
          runningHours: RunningHours(15),
          remarks: '',
          runningHoursAtLocation: RunningHours(0));
      final partIds = [part1.partNo, part2.partNo];
      final updatedRunningHours = RunningHours(20);
      await sut.updatePart(part1);
      await sut.updatePart(part2);

      // Act
      await sut.updatePartsRunningHours(
        partIds: partIds,
        runningHours: updatedRunningHours,
      );
      final newRH1 = updatedRunningHours + part1.runningHours;

      pumpEventQueue();
      // Assert
      expect(sut.parts.values.first.runningHours, newRH1);
      expect(sut.parts.values.last.runningHours,
          updatedRunningHours + part2.runningHours);
    });
  });
}
