import 'package:flutter/material.dart';
import 'package:part_tracker/part_types/domain/entities/part_type.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';

class QtyEditDialog extends StatefulWidget {
  const QtyEditDialog(
      {Key? key,
      required this.item,
      required this.updateCallback,
      required this.isSelected,
      this.qty})
      : super(key: key);

  final PartType item;
  final bool isSelected;
  final int? qty;
  final Function(MapEntry<UniqueId, int?>?) updateCallback;

  @override
  State<QtyEditDialog> createState() => _QtyEditDialogState();
}

class _QtyEditDialogState extends State<QtyEditDialog> {
  bool fl = false;
  final controller = TextEditingController(text: '');

  @override
  void initState() {
    if (widget.isSelected) {
      fl = true;
      controller.text = '${widget.qty ?? 0}';
    } else {
      fl = false;
      controller.text = '';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Checkbox(
                  value: fl,
                  onChanged: (v) {
                    fl = v ?? false;
                    setState(() {});
                  }),
            ),
            Flexible(
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Qty'),
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            if (fl == true) {
              widget.updateCallback(
                  MapEntry(widget.item.id, int.tryParse(controller.text) ?? 0));
            } else {
              widget.updateCallback(null);
            }
          },
          child: const Text('Confirm'),
        )
      ],
    );
  }
}
