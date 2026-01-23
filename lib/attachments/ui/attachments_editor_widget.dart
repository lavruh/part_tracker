import 'package:file_provider/file_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/attachments/domain/attachments_state.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';

class AttachmentsEditorWidget extends StatefulWidget {
  const AttachmentsEditorWidget({
    super.key,
    required this.attachments,
    required this.update,
    required this.logEntryId,
  });
  final List<String> attachments;
  final Function(List<String> val) update;
  final UniqueId logEntryId;

  @override
  State<AttachmentsEditorWidget> createState() =>
      _AttachmentsEditorWidgetState();
}

class _AttachmentsEditorWidgetState extends State<AttachmentsEditorWidget> {
  List<String> items = [];
  final attachmentsState = Get.find<AttachmentsState>();

  @override
  void initState() {
    items = widget.attachments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
        constraints: BoxConstraints(minHeight: 200, minWidth: 200),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
                onPressed: () => _addAttachment(),
                child: Text('Add')),
            ...items.map((a) => Padding(
                padding: const EdgeInsets.all(3.0),
                child: Chip(
                  label: InkWell(
                      onTapUp: (_) { attachmentsState.openAttachment(path: a);
                      },
                      child: Text(attachmentsState.getAttachmentName(path: a, ownerId: widget.logEntryId))),
                  onDeleted: () => _deleteAttachment(a),
                ))),
          ],
        ));
  }

  void _addAttachment() async {
    final file = await Get.find<IFileProvider>().selectFile(
      context: Get.context!,
      title: 'Select file to attach',
    );
    if (file.existsSync()) {
      final path = await attachmentsState.addAttachment(file, widget.logEntryId);
      items.add(path);
      widget.update(items);
      setState(() {});
    }
  }

  void _deleteAttachment(String a) {
    attachmentsState.deleteAttachment(a);
    items.remove(a);
    widget.update(items);
    setState(() {});
  }
}
