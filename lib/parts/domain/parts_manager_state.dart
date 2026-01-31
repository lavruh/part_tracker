import 'package:get/get.dart';
import 'package:part_tracker/locations/domain/locations_manager_state.dart';
import 'package:part_tracker/logbook/domain/logbook_state.dart';
import 'package:part_tracker/maintenance/domain/maintenance_notifier.dart';
import 'package:part_tracker/part_types/domain/part_types_state.dart';
import 'package:part_tracker/parts/domain/entities/part.dart';
import 'package:part_tracker/parts/domain/part_editor_state.dart';
import 'package:part_tracker/parts/ui/widgets/part_update_widget.dart';
import 'package:part_tracker/parts/ui/widgets/parts_search_dialog.dart';
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
  final _partTypeManager = Get.find<PartTypesState>();
  final _maintenanceNotifier = Get.find<MaintenanceNotifier>();
  final _log = Get.find<LogbookState>();
  final foundPartsIds = <Part>[].obs;

  PartsManagerState() {
    getParts();
  }

  bool get partSelected => _selectedPart.isNotEmpty;
  Part? get selectedPart {
    if (_selectedPart.isNotEmpty) {
      return _selectedPart.first;
    }
    return null;
  }

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
    _maintenanceNotifier.checkPartForNecessaryMaintenance(part: part);
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
      try {
        final updatedType = _partTypeManager.getTypeById(part.type.id);
        _updateState(part.copyWith(type: updatedType));
      } catch (e) {
        Get.defaultDialog(
            title: '',
            middleText:
                'Can not load part[${part.partNo.id}]. Part type with id[${part.type.id}] does not exist.');
      }
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
      } on Exception catch (_) {
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

  void updateSelectedPart() async {
    if (partSelected) {
      final part = _selectedPart.first;
      final updatedPart = await Get.defaultDialog(
          title: 'Update part', content: PartUpdateWidget(part: part));
      if (updatedPart != null) {
        updatePart(updatedPart);
        selectPart(updatedPart);
      }
    }
  }

  updateRemarks(Part part) async {
    final remark =
        await textInputDialogWidget(title: 'Remarks', initName: part.remarks);
    if (remark != null) {
      updatePart(part.copyWith(remarks: remark));
    }
  }

  RunningHours clearPartCurrentRunningHours(
    UniqueId partId, {
    RunningHours? installationRunningHours,
  }) {
    final part = getPart(id: partId);
    final rhSpendOnLocation = part.runningHoursAtLocation;
    updatePart(part.copyWith(
        runningHoursAtLocation: RunningHours(0),
        installationRh: installationRunningHours ??
            RunningHours.atTime(value: 0, date: DateTime.now())));
    return rhSpendOnLocation;
  }

  Part getPart({required UniqueId id}) {
    final part = parts[id];
    if (part == null) throw Exception('PartNo[$id] does not exists');
    return part;
  }

  showSearchDialog() async {
    Get.defaultDialog(title: "Part Search", content: const PartsSearchDialog());
  }

  searchPart(String partNoStr) {
    foundPartsIds.value = parts.values
        .where((part) => part.partNo.id.contains(partNoStr))
        .toList();
  }

  selectFoundPart(Part p) {
    Get.find<LocationManagerState>()
        .selectLocationContainingPart(partId: p.partNo);
    selectPart(p);
  }

  reloadState() async {
    parts.clear();
    getParts();
  }
}
