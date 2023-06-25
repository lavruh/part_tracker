import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/logbook/domain/logbook_state.dart';

class LogBookWidget extends StatelessWidget {
  const LogBookWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final logbook = Get.find<LogbookState>().entries;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Related log entries',
              style: Theme.of(context).textTheme.titleLarge),
          Flexible(
            child: ListView(
              children: logbook.map((e) => Text(e.toString())).toList(),
            ),
          ),
        ],
      );
    });
  }
}
