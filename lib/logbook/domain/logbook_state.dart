import 'package:get/get.dart';
import 'package:part_tracker/locations/domain/entities/location.dart';
import 'package:part_tracker/logbook/domain/entities/log_entry.dart';
import 'package:part_tracker/parts/domain/entities/part.dart';
import 'package:part_tracker/utils/data/i_db_service.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';

class LogbookState extends GetxController {
  final entries = <LogEntry>[].obs;
  final filteredEntries = <LogEntry>[].obs;
  final filteredByTextEntries = <LogEntry>[].obs;
  final IDbService db = Get.find();
  final _tableName = 'logbook';

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
      {required Part part, Location? source, required Location target}) {
    String s = "${part.type.name} [No. ${part.partNo}] moved";
    if (source != null) {
      s += ' from ${source.name}';
    }
    s += " to  ${target.name}. ${part.remarks}";
    addLogEntry(
      s,
      relatedParts: [part.partNo],
      relatedLocations: [target.id, if (source != null) source.id],
    );
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
  }

  updateLogEntry(LogEntry entry) {
    entries.removeWhere((e) => e.id == entry.id);
    entries.add(entry);
    _sortEntries();
    db.update(id: entry.id.toString(), item: entry.toMap(), table: _tableName);
  }

  getAll() async {
    await for (final map in db.getAll(table: _tableName)) {
      final entry = LogEntry.fromMap(map);
      entries.add(entry);
    }
    _sortEntries();
    filteredByTextEntries.value = entries;
  }

  _sortEntries(){
    entries.sort((a,b) => b.date.compareTo(a.date));
  }
}
