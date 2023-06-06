import 'package:get/get.dart';
import 'package:part_tracker/part_types/domain/entities/part_type.dart';
import 'package:part_tracker/utils/data/i_db_service.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';

class PartTypesState extends GetxController {
  final types = <UniqueId, PartType>{}.obs;
  final IDbService db = Get.find();
  final _tableName = 'part_types';

  PartTypesState() {
    getAll();
  }

  createPartType() {}

  updatePartType(PartType type) {
    types[type.id] = type;
    db.update(id: type.id.toString(), item: type.toMap(), table: _tableName);
  }

  getAll() async {
    await for (final map in db.getAll(table: _tableName)) {
      final type = PartType.fromMap(map);
      types.addEntries([MapEntry(type.id, type)]);
    }
  }

  removePartType(UniqueId id) {
    types.remove(id);
    db.delete(id: id.toString(), table: _tableName);
  }
}
