abstract class IDbService {
  Future<void> init({required String dbName, required String defaultTable});

  Future<void> update(
      {required String id,
      required Map<String, dynamic> item,
      required String table});

  Stream<Map<String, dynamic>> getAll({required String table});

  Future<void> delete({required String id, required String table});
}
