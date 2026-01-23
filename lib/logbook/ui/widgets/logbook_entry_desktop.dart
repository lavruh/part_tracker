import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:part_tracker/attachments/ui/attachments_editor_button.dart';
import 'package:part_tracker/logbook/domain/entities/log_entry.dart';
import 'package:part_tracker/logbook/domain/logbook_state.dart';
import 'package:part_tracker/utils/ui/widgets/text_input_dialog_widget.dart';

class LogbookEntryDesktop extends StatelessWidget {
  const LogbookEntryDesktop({
    super.key,
    required this.state,
    required this.entry,
  });

  final LogbookState state;
  final LogEntry entry;

  @override
  Widget build(BuildContext context) {
    final d = DateFormat('y-MM-dd HH:mm').format(entry.date);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Flex(
        direction: Axis.horizontal,
        children: [
          Flexible(
            child: TextButton(
                onPressed: () =>
                    _editDate(context, initDate: entry.date, update: (val) {
                      state.updateLogEntry(entry.copyWith(date: val));
                    }),
                child: Text(d)),
          ),
          Flexible(
            flex: 5,
            child: InkWell(
              onTap: () => _editEntry(
                  initText: entry.entry,
                  update: (text) {
                    state.updateLogEntry(entry.copyWith(entry: text));
                  }),
              child:
                  Text(entry.entry, maxLines: 2, overflow: TextOverflow.clip),
            ),
          ),
          Flexible(
              child: AttachmentsEditorButton(
            logEntryId: entry.id,
            attachments: entry.attachments,
            update: (val) {
              state.updateLogEntry(entry.copyWith(attachments: val));
            },
          )),
        ],
      ),
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
