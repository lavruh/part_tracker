import 'package:get/get.dart';
import 'package:part_tracker/locations/domain/locations_manager_state.dart';
import 'package:part_tracker/parts/domain/entities/part.dart';
import 'package:part_tracker/parts/domain/part_editor_state.dart';
import 'package:part_tracker/running_hours/domain/entities/running_hours.dart';
import 'package:part_tracker/utils/data/i_db_service.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';
import 'package:part_tracker/utils/ui/widgets/text_input_dialog_widget.dart';

class PartsManagerState extends GetxController {
  final parts = <UniqueId, Part>{}.obs;
  final IDbService _db = Get.find();
  final table = 'parts';
  final _selectedPart = <Part>[].obs;
  final _editor = Get.find<PartEditorState>();

  PartsManagerState() {
    getParts();
  }

  bool get partSelected => _selectedPart.isNotEmpty;

  selectPart(Part p) {
    _selectedPart.value = [p];
  }

  deselectPart() {
    _selectedPart.clear();
  }

  createPart() {
    _editor.openEditor();
  }

  updatePart(Part part) async {
    _updateState(part);
    _db.update(id: part.partNo.toString(), item: part.toMap(), table: table);
  }

  void _updateState(Part part) {
    parts[part.partNo] = part;
  }

  deleteSelectedPart() {
    if (partSelected) {
      deletePart(_selectedPart.first.partNo);
    }
  }

  deletePart(UniqueId part) {
    parts.remove(part);
    Get.find<LocationManagerState>().deletePartSelectedLocation(part);
    _db.delete(id: part.toString(), table: table);
  }

  Future<void> getParts() async {
    await for (final map in _db.getAll(table: table)) {
      final part = Part.fromMap(map);
      _updateState(part);
    }
  }

  List<Part> getPartWithIds(List<UniqueId> ids) {
    List<Part> res = [];
    for (final key in ids) {
      if (parts.containsKey(key)) {
        res.add(parts[key]!);
      }
    }
    return res;
  }

  updatePartsRunningHours({
    required List<UniqueId> partIds,
    required RunningHours runningHours,
  }) {
    for (final id in partIds) {
      final item = parts[id];
      if (item != null) {
        final partRh = item.runningHours;
        updatePart(item.copyWith(runningHours: partRh + runningHours));
      } else {
        throw Exception('PartNo[$id] does not exists');
      }
    }
  }

  bool currentPartSelected(UniqueId partNo) {
    if (partSelected && _selectedPart[0].partNo == partNo) {
      return true;
    }
    return false;
  }

  updateRemarksSelectedPart() async {
    if (partSelected) {
      final part = _selectedPart[0];
      updateRemarks(part);
    }
  }

  updateRemarks(Part part) async {
    final remark =
        await textInputDialogWidget(title: 'Remarks', initName: part.remarks);
    if (remark != null) {
      updatePart(part.copyWith(remarks: remark));
    }
  }
}
