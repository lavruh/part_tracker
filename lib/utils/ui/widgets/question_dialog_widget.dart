import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<bool?> questionDialogWidget({
  required String question,
  Function? onConfirm,
}) async {
  return await Get.defaultDialog<bool>(
      title: '',
      middleText: question,
      actions: [
        TextButton(
            onPressed: () {
              if (onConfirm != null) onConfirm();
              Get.back(result: true);
            },
            child: const Text('Yes')),
        TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel')),
        TextButton(
            onPressed: () => Get.back(result: null), child: const Text('No')),
      ]);
}
