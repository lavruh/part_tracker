import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:part_tracker/part_types/domain/entities/part_type.dart';
import 'package:part_tracker/part_types/domain/part_types_state.dart';
import 'package:part_tracker/utils/data/i_db_service.dart';

import 'part_type_test.mocks.dart';

const tableName = 'part_types';

@GenerateMocks([IDbService])
main() {
  test('add new part type and update it', () async {
    final dbMock = Get.put<IDbService>(MockIDbService());
    when(dbMock.getAll(table: tableName))
        .thenAnswer((_) => const Stream.empty());
    final sut = PartTypesState();
    final type = PartType.empty().copyWith(name: 'head');

    sut.updatePartType(type);

    expect(sut.types.keys, contains(type.id));
    expect(sut.types.values.first.name, type.name);
    verify(dbMock.update(
            id: type.id.toString(), item: type.toMap(), table: tableName))
        .called(1);

    final updatedType = type.copyWith(name: 'update');

    sut.updatePartType(updatedType);
    expect(sut.types.keys, contains(type.id));
    expect(sut.types.values.length, 1);
    expect(sut.types.values.first.name, updatedType.name);
    verify(dbMock.update(
            id: type.id.toString(),
            item: updatedType.toMap(),
            table: tableName))
        .called(1);
  });

  test('get all part types from db', () async {
    final dbMock = Get.put<IDbService>(MockIDbService());
    final type = PartType.empty().copyWith(name: 'head');
    when(dbMock.getAll(table: tableName))
        .thenAnswer((_) => Stream.fromIterable([type.toMap()]));
    final sut = PartTypesState();

    await sut.getAll();
    await pumpEventQueue(times: 10);

    expect(sut.types.keys, contains(type.id));
    expect(sut.types.values, contains(type));
  });

  test('delete part type', () async {
    final dbMock = Get.put<IDbService>(MockIDbService());
    final type = PartType.empty().copyWith(name: 'head');
    when(dbMock.getAll(table: tableName))
        .thenAnswer((_) => Stream.fromIterable([type.toMap()]));
    final sut = PartTypesState();

    await sut.getAll();
    await pumpEventQueue(times: 10);

    sut.removePartType(type.id);

    expect(sut.types.keys.contains(type.id), false);
    verify(dbMock.delete(id: type.id.toString(), table: tableName)).called(1);
  });
}
