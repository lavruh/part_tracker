import 'dart:io';

import 'package:part_tracker/utils/domain/unique_id.dart';

abstract class IAttachmentsService {
  Future<File> getAttachment({required String path});
  Future<void> openAttachment({required String path});
  Future<String> saveAttachment({required File file, required UniqueId ownerId});
  Future<void> deleteAttachment({required String path});
}
