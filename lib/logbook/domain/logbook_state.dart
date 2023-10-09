import 'package:get/get.dart';
import 'package:part_tracker/backup/domain/backups_state.dart';
import 'package:part_tracker/locations/domain/entities/location.dart';
import 'package:part_tracker/locations/domain/locations_menu_state.dart';
import 'package:part_tracker/logbook/domain/entities/log_entry.dart';
import 'package:part_tracker/parts/domain/entities/part.dart';
import 'package:part_tracker/parts/domain/parts_manager_state.dart';
import 'package:part_tracker/running_hours/domain/entities/running_hours.dart';
import 'package:part_tracker/utils/data/i_db_service.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';
import 'package:part_tracker/utils/ui/widgets/text_input_dialog_widget.dart';

class LogbookState extends GetxController {
  final entries = <LogEntry>[].obs;
  final filteredEntries = <LogEntry>[].obs;
  final filteredByTextEntries = <LogEntry>[].obs;
  final IDbService db = Get.find();
  final _tableName = 'logbook';
  final textFilter = ''.obs;
  final _backupState = Get.find<BackupState>();

  showAllLog() {
    filteredEntries.value = entries;
  }

  filterLogByText(String text) {
    if (text.isNotEmpty) {
      filteredByTextEntries.value =
          entries.where((e) => e.entry.contains(text)).toList();
    } else {
      filteredByTextEntries.value = entries;
    }
  }

  @override
  onInit() {
    super.onInit();
    ever(entries, (val) => filterLogByText(textFilter.value));
    ever(textFilter, (val) => filterLogByText(val));
  }

  filterLogByLocation(UniqueId location) {
    filteredEntries.value =
        entries.where((e) => e.relatedLocations.contains(location)).toList();
  }

  filterLogByPart(UniqueId partId) {
    filteredEntries.value =
        entries.where((e) => e.relatedParts.contains(partId)).toList();
  }

  removeLogFilter() {
    filteredEntries.value = [];
  }

  movePartLogEntry(
      {required Part part,
      Location? source,
      required Location target,
      RunningHours? runningHoursSpentOnLocation}) async {
    final remark = (await textInputDialogWidget(
            title: 'Transaction remarks', initName: part.remarks)) ??
        '';

    String s = "${part.type.name} [No. ${part.partNo}] moved";
    if (source != null) {
      s += ' from ${source.id.id}';
    }
    s += " to  ${target.id.id}.";
    if (runningHoursSpentOnLocation != null) {
      s += " after ${runningHoursSpentOnLocation.value} hours.";
    }
    s += " $remark";
    addLogEntry(
      s,
      relatedParts: [part.partNo],
      relatedLocations: [target.id, if (source != null) source.id],
    );
  }

  addLogEntryToLocation() async {
    final location = Get.find<LocationsMenuState>().selectedLocation;
    if (location != null) {
      final part = Get.find<PartsManagerState>().selectedPart;
      String logText = location.name;
      if (location.runningHours != null) {
        logText += '@${location.runningHours?.value}Hrs.';
      }
      if (part != null) {
        logText += '${part.type.name}[${part.partNo}]';
      }
      final entry = await textInputDialogWidget(initName: logText);
      if (entry != null) {
        addLogEntry(entry,
            relatedParts: [if (part != null) part.partNo],
            relatedLocations: [location.id]);
      }
    }
  }

  addLogEntry(
    String entry, {
    required List<UniqueId> relatedParts,
    required List<UniqueId> relatedLocations,
  }) {
    final logEntry = LogEntry(
      entry: entry,
      relatedParts: relatedParts,
      relatedLocations: relatedLocations,
    );
    entries.add(logEntry);
    db.update(
        id: logEntry.id.toString(), item: logEntry.toMap(), table: _tableName);
    _backupState.createBackup(description: logEntry.date.toString());
  }

  updateLogEntry(LogEntry entry) {
    entries.removeWhere((e) => e.id == entry.id);
    entries.add(entry);
    _sortEntries();
    db.update(id: entry.id.toString(), item: entry.toMap(), table: _tableName);
  }

  getAll() async {
    entries.clear();
    await for (final map in db.getAll(table: _tableName)) {
      final entry = LogEntry.fromMap(map);
      entries.add(entry);
    }
    _sortEntries();
    filteredByTextEntries.value = entries;
  }

  _sortEntries() {
    entries.sort((a, b) => b.date.compareTo(a.date));
  }
}
