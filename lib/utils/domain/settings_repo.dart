import 'package:part_tracker/utils/data/i_db_service.dart';

class SettingsRepo {
  final IDbService _db;
  final table = "settings";
  SettingsRepo(this._db) {
    // loadSettings();
  }
  Map<String, dynamic> _settings = {};

  loadSettings() async {
    final data = _db.getAll(table: table);
    await for (final e in data) {
      _settings.addAll(e);
    }
  }

  void _setValue(String id, dynamic val) {
    _settings[id] = val;
    _db.update(id: id, item: {id: val}, table: table);
  }

  void setInt(String id, int val) {
    _setValue(id, val);
  }

  int? getInt(String id) {
    final val = _settings[id];
    if (val != null && val is int) return val;
    return null;
  }

  void setStringList(String id, List<String> val) {
    _setValue(id, val);
  }

  List<String>? getStringList(String id) {
    final val = _settings[id];
    List<String> result = [];
    if (val is List) {
      for (final e in val) {
        result.add(e);
      }
      return result;
    }
    return null;
  }

  void setString(String id, String val) {
    _setValue(id, val);
  }

  String? getString(String id) {
    final val = _settings[id];
    if (val is String) return val;
    return null;
  }
}
