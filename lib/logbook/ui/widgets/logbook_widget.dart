import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:part_tracker/attachments/ui/attachments_widget.dart';
import 'package:part_tracker/logbook/domain/logbook_state.dart';

class LogBookWidget extends StatelessWidget {
  const LogBookWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = Get.find<LogbookState>();
      final logbook = state.filteredEntries;
      List<Widget> header = [];
      if (logbook.isNotEmpty) {
        header = [
          Text('Related log entries',
              style: Theme.of(context).textTheme.titleLarge),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => state.addLogEntryToLocation(),
                icon: const Icon(Icons.add),
                tooltip: "Add log entry",
              )
            ],
          ),
        ];
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...header,
          Flexible(
            child: ListView(
              children: logbook.map((e) {
                final d = DateFormat('y-MM-dd HH:mm').format(e.date);
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: SelectableText("$d  ${e.entry}"),
                      ),
                      AttachmentsWidget(
                        attachments: e.attachments,
                        ownerId: e.id,
                      ),
                    ],
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
