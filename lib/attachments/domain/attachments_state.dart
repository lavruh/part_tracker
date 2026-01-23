import 'dart:io';

import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:part_tracker/attachments/data/i_attachments_service.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';
import 'package:path/path.dart' as p;

class AttachmentsState extends GetxController {
  final IAttachmentsService _service;

  AttachmentsState(this._service);

  Future<String> addAttachment(File file, UniqueId ownerId) =>
      _service.saveAttachment(file: file, ownerId: ownerId);

  Future<void> deleteAttachment(String a) async {
    await _service.deleteAttachment(path: a);
  }
  
  String getAttachmentName({required String path, required UniqueId ownerId}) {
    return p.basename(path).replaceAll("${ownerId}_", "");
  }

  void openAttachment({required String path}) {
    _service.openAttachment(path: path);
  }
}
