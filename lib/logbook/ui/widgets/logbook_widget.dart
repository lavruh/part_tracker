import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:part_tracker/logbook/domain/logbook_state.dart';

class LogBookWidget extends StatelessWidget {
  const LogBookWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final logbook = Get.find<LogbookState>().filteredEntries;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (logbook.isNotEmpty)
            Text('Related log entries',
                style: Theme.of(context).textTheme.titleLarge),
          Flexible(
            child: ListView(
              children: logbook.map((e) {
                final d = DateFormat('y-MM-dd HH:mm').format(e.date);
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "$d  ${e.entry}",
                    maxLines: 3,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      );
    });
  }
}
