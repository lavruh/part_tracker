import 'package:get/get.dart';
import 'package:part_tracker/locations/domain/locations_manager_state.dart';
import 'package:part_tracker/logbook/domain/logbook_state.dart';
import 'package:part_tracker/parts/domain/entities/part.dart';
import 'package:part_tracker/parts/domain/part_editor_state.dart';
import 'package:part_tracker/running_hours/domain/entities/running_hours.dart';
import 'package:part_tracker/utils/data/i_db_service.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';
import 'package:part_tracker/utils/ui/widgets/question_dialog_widget.dart';
import 'package:part_tracker/utils/ui/widgets/text_input_dialog_widget.dart';

class PartsManagerState extends GetxController {
  final parts = <UniqueId, Part>{}.obs;
  final IDbService _db = Get.find();
  final table = 'parts';
  final _selectedPart = <Part>[].obs;
  final _editor = Get.find<PartEditorState>();
  final _log = Get.find<LogbookState>();

  PartsManagerState() {
    getParts();
  }

  bool get partSelected => _selectedPart.isNotEmpty;

  selectPart(Part p) {
    _selectedPart.value = [p];
    _log.filterLogByPart(p.partNo);
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

  deleteSelectedPart() async {
    if (partSelected) {
      final fl = await questionDialogWidget(question: 'Delete part?');
      if (fl == true) {
        deletePart(_selectedPart.first.partNo);
      }
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
      try {
        final item = getPart(id: id);
        final partRh = item.runningHours;
        final partRhSinceInstall = item.runningHoursAtLocation;
        updatePart(item.copyWith(
          runningHours: partRh + runningHours,
          runningHoursAtLocation: partRhSinceInstall + runningHours,
        ));
      } on Exception catch (e) {
        print(e);
        rethrow;
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

  RunningHours clearPartCurrentRunningHours(UniqueId partId) {
    final part = getPart(id: partId);
    final rhSpendOnLocation = part.runningHoursAtLocation;
    updatePart(part.copyWith(runningHoursAtLocation: RunningHours(0)));
    return rhSpendOnLocation;
  }

  Part getPart({required UniqueId id}) {
    final part = parts[id];
    if (part == null) throw Exception('PartNo[$id] does not exists');
    return part;
  }
}
