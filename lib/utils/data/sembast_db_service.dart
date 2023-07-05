import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:part_tracker/utils/data/i_db_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart' as p;

class SembastDbService implements IDbService {
  Database? _db;

  @override
  Future<void> init({required String dbName, String? dbPath}) async {
    try {
      if (dbPath != null && File(dbPath).existsSync()) {
        _db = await databaseFactoryIo.openDatabase(dbPath);
      } else {
        final appDataPath = await getApplicationDocumentsDirectory();
        final path = p.join(appDataPath.path, "$dbName.db");
        _db = await databaseFactoryIo.openDatabase(path);
      }
    } on PlatformException {
      throw Exception('Failed to open DB');
    }
  }

  Future<void> add({
    required Map<String, dynamic> item,
    required String table,
  }) async {
    final store = StoreRef(table);
    await _db?.transaction(
      (transaction) async => await store.add(transaction, item),
    );
  }

  @override
  Future<void> delete({
    required String id,
    required String table,
  }) async {
    final store = StoreRef(table);
    final Map<String, String> children = await getChildrenIds(id);
    await _db?.transaction(
      (transaction) async {
        await store.record(id).delete(transaction);
      },
    );
    for (final e in children.entries) {
      await deleteTable(table: e.value);
    }
  }

  Future<void> deleteTable({required String table}) async {
    final store = StoreRef(table);
    if (_db != null) {
      await store.delete(_db!);
    }
  }

  @override
  Stream<Map<String, dynamic>> getAll({
    required String table,
  }) async* {
    if (_db != null) {
      final store = StoreRef(table);
      final data = await store.find(_db!);
      for (final item in data) {
        final Map<String, dynamic> m = {};
        m.addAll(item.value as Map<String, dynamic>);
        yield m;
      }
    }
  }

  @override
  Future<void> update({
    required String id,
    required Map<String, dynamic> item,
    required String table,
  }) async {
    final store = StoreRef(table);
    await _db?.transaction(
      (transaction) async {
        await store.record(id).put(transaction, item);
      },
    );
  }

  Future<Map<String, String>> getChildrenIds(String id) async {
    final Map<String, String> ids = {};
    await for (final child in getAll(table: id)) {
      final childId = child['id'];
      if (childId != null) {
        ids.putIfAbsent(childId, () => id);
        ids.addAll(await getChildrenIds(childId));
      }
    }
    return ids;
  }

  closeAndDeleteDb() async {
    if (_db != null) {
      await _db!.close();
      await databaseFactoryIo.deleteDatabase(_db!.path);
      _db = null;
    }
  }

  Future<Map<String, dynamic>> getItemByFieldValue({
    required Map<String, String> request,
    required String table,
  }) async {
    if (_db != null) {
      final store = StoreRef(table);
      final finder = Finder(
          filter: Filter.matches(
        request.keys.first,
        request.values.first,
      ));
      final res = await store.findFirst(_db!, finder: finder);
      if (res != null) {
        return res.value as Map<String, dynamic>;
      }
    }
    return {};
  }
}
