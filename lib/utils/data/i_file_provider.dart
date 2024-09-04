import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';

abstract class IFileProvider {
  Future<File> selectFile({
    required BuildContext context,
    required String title,
    List<String>? allowedExtensions,
  });
}

class FileProvider {
  static IFileProvider getInstance() {
    if (Platform.isAndroid) {
      return _FilesystemPickerFileProvider();
    }
    return _FilepeakerFileProvider();
  }
}

class _FilepeakerFileProvider implements IFileProvider {
  @override
  Future<File> selectFile(
      {required BuildContext context,
      required String title,
      List<String>? allowedExtensions}) async {
    try {
      final f = await FilePicker.platform.pickFiles(
        dialogTitle: title,
        allowedExtensions:
            allowedExtensions?.map((e) => e.replaceAll(".", "")).toList(),
        type: allowedExtensions == null ? FileType.any : FileType.custom,
      );
      if (f == null) throw Exception('No file selected');
      final filePath = f.files.first.path;
      if (filePath == null) throw Exception("Wrong file path");
      return File(filePath);
    } catch (e) {
      rethrow;
    }
  }
}

class _FilesystemPickerFileProvider implements IFileProvider {
  @override
  Future<File> selectFile({
    required BuildContext context,
    required String title,
    List<String>? allowedExtensions,
  }) async {
    if (allowedExtensions != null &&
        allowedExtensions.any((e) => e.contains("."))) {
      throw Exception("Allowed extensions should not contain dots");
    }
    final f = await FilesystemPicker.open(
      title: title,
      context: context,
      rootDirectory: Directory("storage/emulated/0"),
      allowedExtensions: allowedExtensions?.map((e) => ".$e").toList(),
    );
    if (f == null) throw Exception('No file selected');
    return File(f);
  }
}
