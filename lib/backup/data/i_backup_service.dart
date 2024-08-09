import 'package:part_tracker/backup/domain/entities/backup_item.dart';

abstract class IBackupService {

  Future<void> backup({required String description, required List<String> pathsToBackup});
  Future<void> restore({int stepsBack = 1});
  Future<void> restoreToDescription({required String description});
  Future<void> deleteBackupWithDescription({required String description});
  Stream<BackupItem> getAvailableBackups();
}
