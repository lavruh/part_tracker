import 'package:get/get.dart';
import 'package:part_tracker/logbook/domain/entities/log_entry.dart';
import 'package:part_tracker/utils/data/i_db_service.dart';

class LogbookState extends GetxController {
  final entries = <LogEntry>[].obs;
  final IDbService db = Get.find();
  final _tableName = 'part_types';

  addLogEntry(String entry) {
    final logEntry = LogEntry(entry: entry);
    entries.add(logEntry);
    db.update(
        id: logEntry.id.toString(), item: logEntry.toMap(), table: _tableName);
  }

  updateLogEntry(LogEntry entry) {
    entries.removeWhere((e) => e.id == entry.id);
    entries.add(entry);
    db.update(
        id: entry.id.toString(), item: entry.toMap(), table: _tableName);
  }

  getAll() async {
    await for (final map in db.getAll(table: _tableName)) {
      final entry = LogEntry.fromMap(map);
      entries.add(entry);
    }
  }
}
