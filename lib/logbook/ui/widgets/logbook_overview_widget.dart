import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:part_tracker/logbook/domain/logbook_state.dart';
import 'package:part_tracker/utils/ui/widgets/text_input_dialog_widget.dart';

class LogBookOverviewWidget extends StatelessWidget {
  const LogBookOverviewWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = Get.find<LogbookState>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(() {
          final logbook = state.filteredByTextEntries;
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            width: MediaQuery.of(context).size.width * 0.7,
            child: ListView(
              children: logbook.map((e) {
                final d = DateFormat('y-MM-dd HH:mm').format(e.date);
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Flex(
                    direction: Axis.horizontal,
                    children: [
                      Flexible(
                        child: TextButton(
                            onPressed: () => _editDate(context,
                                    initDate: e.date, update: (val) {
                                  state.updateLogEntry(e.copyWith(date: val));
                                }),
                            child: Text(d)),
                      ),
                      Flexible(
                        flex: 5,
                        child: InkWell(
                          onTap: () => _editEntry(
                              initText: e.entry,
                              update: (text) {
                                state.updateLogEntry(e.copyWith(entry: text));
                              }),
                          child: Text(e.entry,
                              maxLines: 2, overflow: TextOverflow.clip),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        }),
        Flexible(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: TextEditingController(text: state.textFilter.value),
            onChanged: (val) {
              state.textFilter.value = val;
            },
            decoration: const InputDecoration(labelText: 'Search'),
          ),
        )),
      ],
    );
  }

  _editDate(BuildContext context,
      {required DateTime initDate,
      required Function(DateTime e) update}) async {
    final d = await showDatePicker(
        context: context,
        initialDate: initDate,
        locale: const Locale('en', 'GB'),
        firstDate: DateTime(initDate.year - 2),
        lastDate: DateTime(initDate.year + 1));
    if (d != null && context.mounted) {
      final t = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initDate),
      );
      if (t != null) {
        update(DateTime(d.year, d.month, d.day, t.hour, t.minute));
      }
    }
  }

  _editEntry(
      {required String initText, required Function(String text) update}) async {
    final text = await textInputDialogWidget(initName: initText);
    if (text != null) {
      update(text);
    }
  }
}
