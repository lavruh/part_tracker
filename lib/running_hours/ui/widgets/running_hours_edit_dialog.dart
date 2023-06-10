import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/running_hours/domain/entities/running_hours.dart';
import 'package:part_tracker/running_hours/domain/running_hours_edit_controller.dart';

class RunningHoursEditDialog extends StatelessWidget {
  const RunningHoursEditDialog({Key? key, required this.item})
      : super(key: key);

  final RunningHours item;

  @override
  Widget build(BuildContext context) {
    final state = RunningHoursEditController(item);
    return Form(
      key: state.formKey,
      child: AlertDialog(
        title: const Text('Update running hours'),
        content: TextFormField(
          controller: state.textController,
          onChanged: state.updateItem,
          validator: state.validator,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
              onPressed: () => state.confirm(), child: const Text('Confirm')),
        ],
      ),
    );
  }
}
