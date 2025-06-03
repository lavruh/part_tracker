// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'package:file/local.dart';
import 'package:file/file.dart';
import 'package:archive/archive.dart';
import 'package:part_tracker/backup/data/i_backup_service.dart';
import 'package:part_tracker/backup/domain/entities/backup_item.dart';
import 'package:path/path.dart' as p;

class ZipBackupService implements IBackupService {
  final FileSystem fs;
  final String backupDirectory;

  ZipBackupService(this.backupDirectory) : fs = const LocalFileSystem();
  ZipBackupService.testing(
      {required FileSystem mockFileSystem, required this.backupDirectory})
      : fs = mockFileSystem;

  @override
  Future<void> backup(
      {required String description,
      required List<String> pathsToBackup}) async {
    final backupFileName = getFileName(description);
    final backupFilePath = p.join(backupDirectory, backupFileName);

    final archive = Archive();
    for (final path in pathsToBackup) {
      final file = fs.file(path);
      if (await file.exists()) {
        final fileName = p.basename(path);
        archive.addFile(
            ArchiveFile(fileName, file.lengthSync(), file.readAsBytesSync()));
      }
    }

    final backupFile = fs.file(backupFilePath);
    final bytes = ZipEncoder().encode(archive);
    backupFile.writeAsBytesSync(bytes);
    }

  @override
  Future<void> restore({int stepsBack = 1}) async {
    final availableBackups = await getAvailableBackups().toList();
    if (availableBackups.length < stepsBack) {
      stepsBack = availableBackups.length;
    }

    final backupItem = availableBackups[stepsBack - 1];
    await restoreToDescription(description: backupItem.description);
  }

  @override
  Future<void> restoreToDescription({required String description}) async {
    try {
      final backupFile =
          await _getFileWithDescription(description: description);
      final archiveBytes = await backupFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(archiveBytes);

      for (final file in archive) {
        final filePath = '$backupDirectory/${file.name}';
        final restoredFile = fs.file(filePath);

        if (!await restoredFile.exists()) {
          await restoredFile.create(recursive: true);
        }

        await restoredFile.writeAsBytes(file.content);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Stream<BackupItem> getAvailableBackups() async* {
    final backupDirectory = fs.directory(this.backupDirectory);
    if (await backupDirectory.exists()) {
      final backupFiles = await backupDirectory
          .list()
          .where((e) => e is File && p.extension(e.path).contains('bak'))
          .toList();
      for (final backupFile in backupFiles) {
        final fileName = p.basenameWithoutExtension(backupFile.path);
        final timestamp = backupFile.statSync().modified;
        yield BackupItem(
            description: fileName, path: backupFile.path, date: timestamp);
      }
    }
  }

  @override
  Future<void> deleteBackupWithDescription(
      {required String description}) async {
    final backupFile = await _getFileWithDescription(description: description);
    backupFile.delete(recursive: true);
  }

  Future<File> _getFileWithDescription({required String description}) async {
    final backupFileName = getFileName(description);
    final path = p.join(backupDirectory, backupFileName);
    final backupFile = fs.file(path);
    if (!await backupFile.exists()) {
      throw Exception('Backup [path: ${backupFile.path}] not found.');
    }
    return backupFile;
  }
}

String getFileName(String description) {
  if (!description.contains('.bak')) return '$description.bak';
  return description;
}
