import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<String?> textInputDialogWidget({
  String title = '',
  required String initName,
}) async {
  final controller = TextEditingController(text: initName);
  return Get.defaultDialog<String?>(
      title: title,
      content: TextFormField(
        controller: controller,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back(result: controller.text);
          },
          child: const Text('Confirm'),
        )
      ]);
}
