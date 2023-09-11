import 'package:flutter_test/flutter_test.dart';
import 'package:part_tracker/backup/data/zip_backup_service.dart';
// ignore: depend_on_referenced_packages
import 'package:file/memory.dart';
import 'package:path/path.dart' as p;

void main() {
  late ZipBackupService sut;
  late MemoryFileSystem fs;
  final backUpDir = p.join("test", 'backup');

  setUp(() {
    fs = MemoryFileSystem();
    fs.directory(backUpDir).createSync(recursive: true);
    sut = ZipBackupService.testing(
        mockFileSystem: fs, backupDirectory: backUpDir);
  });

  test('backup method should create backup file', () async {
    const description = 'Test Backup';
    final file1 = fs.file(p.join(backUpDir, 'file1.txt'));
    file1.createSync();
    final file2 = fs.file(p.join(backUpDir, 'file2.txt'));
    file2.createSync();
    final pathsToBackup = [file1.path, file2.path];
    const backupFileName = '$description.bak';

    await sut.backup(
      description: description,
      pathsToBackup: pathsToBackup,
    );

    expect(fs.file(p.join(backUpDir, backupFileName)).existsSync(), true);
  });

  test('restore method should restore backup', () async {
    const description = 'Test Restore';
    final file1 = fs.file(p.join(backUpDir, 'file1.txt'));
    final file2 = fs.file(p.join(backUpDir, 'file2.txt'));
    final pathsToBackup = [file1.path, file2.path];
    file1.writeAsStringSync('Content of file1.txt');
    file2.createSync();

    await sut.backup(
      description: description,
      pathsToBackup: pathsToBackup,
    );

    file1.deleteSync();
    file2.deleteSync();

    await sut.restoreToDescription(description: description);

    expect(file1.existsSync(), true);
    expect(file2.existsSync(), true);

    final originalContent1 = await file1.readAsString();

    expect(originalContent1, 'Content of file1.txt');
  });

  test('getAvailableBackups method should yield backup items', () async {
    final backup1 = fs.file(p.join(backUpDir, '2023-08-30_Test1.bak'));
    final backup2 = fs.file(p.join(backUpDir, '2023-08-31_Test2.bak'));
    final someFile = fs.file(p.join(backUpDir, '2023-08-31_Test2.txt'));
    backup1.createSync();
    backup2.createSync();
    someFile.createSync();

    final backups = await sut.getAvailableBackups().toList();

    expect(backups, hasLength(2));

    expect(backups[0].description, '2023-08-30_Test1');
    expect(backups[0].path, backup1.path);
    expect(backups[0].date, backup1.statSync().modified);

    expect(backups[1].description, '2023-08-31_Test2');
    expect(backups[1].path, backup2.path);
    expect(backups[1].date, backup2.statSync().modified);
  });
}
