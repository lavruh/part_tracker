import 'package:flutter/material.dart';
import 'package:part_tracker/parts/domain/entities/part.dart';

class PartWidget extends StatelessWidget {
  const PartWidget({Key? key, required this.item}) : super(key: key);
  final Part item;

  @override
  Widget build(BuildContext context) {
    return Draggable(
      data: item,
      feedback: _Child(item: item),
      child: _Child(item: item),
    );
  }
}

class _Child extends StatelessWidget {
  const _Child({Key? key, required this.item}) : super(key: key);
  final Part item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 125),
                child: Text(item.type.name)),
            ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 125),
                child: Text('PartNo. ${item.partNo.id}')),
            ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 75),
                child: Text('RH: ${item.runningHours.value}')),
            Text('Remarks: ${item.remarks}'),
          ],
        ),
      ),
    );
  }
}
