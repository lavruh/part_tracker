import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/attachments/domain/attachments_state.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';
import 'package:popover/popover.dart';

class AttachmentsWidget extends StatelessWidget {
  const AttachmentsWidget({
    super.key,
    required this.attachments,
    required this.ownerId,
  });
  final List<String> attachments;
  final UniqueId ownerId;

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return SizedBox.shrink();
    final attachmentsState = Get.find<AttachmentsState>();

    return Badge(
      backgroundColor: Colors.grey,
      label: Text("${attachments.length}"),
      child: IconButton(
          onPressed: () {
            showPopover(
                context: context,
                bodyBuilder: (context) {
                  return Container(
                    width: 200,
                    color: Colors.white,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...attachments.map((e) => Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: ActionChip(
                                onPressed: () =>
                                    attachmentsState.openAttachment(path: e),
                                label: Text(
                                  attachmentsState.getAttachmentName(
                                    path: e,
                                    ownerId: ownerId,
                                  ),
                                ),
                              ),
                            )),
                      ],
                    ),
                  );
                });
          },
          icon: Icon(Icons.attach_file)),
    );
  }
}
