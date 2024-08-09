import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/logbook/domain/logbook_state.dart';
import 'package:part_tracker/logbook/ui/widgets/logbook_entry_desktop.dart';

class LogBookOverviewWidget extends StatelessWidget {
  const LogBookOverviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Get.find<LogbookState>();
    return Flex(
      direction: Axis.vertical,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          flex: 5,
          child: Obx(() {
            final logbook = state.filteredByTextEntries;
            return SizedBox(
              child: ListView(
                children: logbook
                    .map((e) => LogbookEntryDesktop(
                          state: state,
                          entry: e,
                        ))
                    .toList(),
              ),
            );
          }),
        ),
        Flexible(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: TextEditingController(text: state.textFilter.value),
                onChanged: (val) => state.textFilter.value = val,
                decoration: const InputDecoration(labelText: 'Search'),
              ),
            )),
      ],
    );
  }
}
