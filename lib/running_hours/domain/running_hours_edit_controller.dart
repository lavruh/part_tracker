import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/running_hours/domain/entities/running_hours.dart';

class RunningHoursEditController {
  final RunningHours item;
  final formKey = GlobalKey<FormState>();
  late final TextEditingController textController;
  RunningHours? newValue;

  RunningHoursEditController(this.item) {
    textController = TextEditingController(text: item.value.toString());
  }

  updateItem(String val) {
    final rh = int.tryParse(val);
    if (rh != null) {
      newValue = RunningHours(rh);
    }
  }

  String? validator(String? val) {
    if (val != null) {
      final rh = int.tryParse(val);
      if (rh == null) return 'Should be integer';
      if (rh < item.value) return 'New reading should be bigger then old';
      updateItem(val);
      return null;
    }
    return 'Incorrect value';
  }

  confirm() {
    if (formKey.currentState!.validate() && newValue != null) {
      Get.back(result: newValue);
    }
  }
}
