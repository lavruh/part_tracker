import 'package:get/get.dart';
import 'package:part_tracker/parts/domain/entities/part.dart';
import 'package:part_tracker/running_hours/domain/entities/running_hours.dart';
import 'package:part_tracker/utils/data/i_db_service.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';

class PartsManagerState extends GetxController {
  final parts = <UniqueId, Part>{}.obs;
  final IDbService _db = Get.find();
  final table = 'parts';

  updatePart(Part part) async {
    _updateState(part);
    _db.update(id: part.partNo.toString(), item: part.toMap(), table: table);
  }

  void _updateState(Part part) {
    parts[part.partNo] = part;
  }

  deletePart(UniqueId part) {
    parts.remove(part);
    _db.delete(id: part.toString(), table: table);
  }

  Future<void> getParts() async {
    await for (final map in _db.getAll(table: table)) {
      final part = Part.fromMap(map);
      _updateState(part);
    }
  }

  updatePartsRunningHours({
    required List<UniqueId> partIds,
    required RunningHours runningHours,
  }) {
    for (final id in partIds) {
      if (parts.containsKey(id)) {
        final item = parts[id];
        updatePart(item!.copyWith(runningHours: runningHours));
      } else {
        throw Exception('PartNo[$id] does not exists');
      }
    }
  }
}
