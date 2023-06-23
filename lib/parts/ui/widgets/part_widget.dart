import 'package:flutter/material.dart';
import 'package:part_tracker/parts/domain/entities/part.dart';

class PartWidget extends StatelessWidget {
  const PartWidget(
      {Key? key,
      required this.item,
      required this.onTap,
      required this.partSelected})
      : super(key: key);
  final Part item;
  final Function onTap;
  final bool partSelected;

  @override
  Widget build(BuildContext context) {
    return Draggable(
      data: item,
      feedback: _Child(item: item, selected: partSelected),
      child: InkWell(
        onTapUp: (_) => onTap(),
        child: _Child(item: item, selected: partSelected),
      ),
    );
  }
}

class _Child extends StatelessWidget {
  const _Child({Key? key, required this.item, required this.selected})
      : super(key: key);
  final Part item;
  final bool selected;
  static const bold = TextStyle(fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    final style = selected ? bold : null;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 125),
              child: Text(item.type.name, style: style)),
          ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 125),
              child: Text('PartNo. ${item.partNo.id}', style: style)),
          ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 75),
              child: Text('RH: ${item.runningHours.value}', style: style)),
          Text('Remarks: ${item.remarks}', style: style),
        ],
      ),
    );
  }
}
