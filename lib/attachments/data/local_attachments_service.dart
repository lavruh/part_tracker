import 'dart:io';

import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:part_tracker/attachments/data/i_attachments_service.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';
import 'package:path/path.dart' as p;

class LocalAttachmentsService implements IAttachmentsService {
  late final String attachmentsDir;
  LocalAttachmentsService() {
    final appDir = Get.find<String>(tag: 'dirName');
    attachmentsDir = p.join(appDir, 'attachments');
    if (!Directory(attachmentsDir).existsSync()) {
      Directory(attachmentsDir).createSync(recursive: true);
    }
  }

  @override
  Future<void> deleteAttachment({required String path}) async {
    final file = File(path);
    if (!file.existsSync()) {
      throw AttachmentsServiceException('File[${file.path}] does not exist');
    }
    try {
      await file.delete();
    } catch (e) {
      throw AttachmentsServiceException('Failed to delete file: $e');
    }
  }

  @override
  Future<File> getAttachment({required String path}) async {
    final file = File(path);
    if (!file.existsSync()) {
      throw AttachmentsServiceException("File ${file.path} does not exist");
    }
    return file;
  }

  @override
  Future<void> openAttachment({required String path}) async {
    if (File(path).existsSync()) {
      OpenFile.open(path);
    }
  }

  @override
  Future<String> saveAttachment(
      {required File file, required UniqueId ownerId}) async {
    if (!file.existsSync()) {
      throw AttachmentsServiceException('File[${file.path}] does not exist');
    }
    final name = "${ownerId.id}_${p.basename(file.path)}";
    final path = p.join(attachmentsDir, name);
    try {
      await file.copy(path);
      return path;
    } catch (e) {
      throw AttachmentsServiceException('Failed to copy file: $e');
    }
  }
}

class AttachmentsServiceException implements Exception {
  final String message;
  AttachmentsServiceException(this.message);
}
