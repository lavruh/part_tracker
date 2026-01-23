import 'package:flutter/material.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';
import 'package:popover/popover.dart';

import 'attachments_editor_widget.dart';

class AttachmentsEditorButton extends StatelessWidget {
  const AttachmentsEditorButton(
      {super.key,
      required this.attachments,
      required this.update,
      required this.logEntryId});

  final List<String> attachments;
  final Function(List<String> val) update;
  final UniqueId logEntryId;

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) {
      return IconButton(
          onPressed: () => _open(context), icon: Icon(Icons.attach_file));
    }

    return Badge(
        backgroundColor: Colors.grey,
        label: Text("${attachments.length}"),
        child: IconButton(
            onPressed: () => _open(context), icon: Icon(Icons.attach_file)));
  }

  void _open(BuildContext context) {
    showPopover(
        context: context,
        bodyBuilder: (context) {
          return AttachmentsEditorWidget(
            attachments: attachments,
            update: update,
            logEntryId: logEntryId,
          );
        });
  }
}
