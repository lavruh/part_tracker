import 'package:flutter/material.dart';
import 'package:part_tracker/parts/domain/entities/part.dart';

class PartWidget extends StatelessWidget {
  const PartWidget(
      {Key? key,
      required this.item,
      required this.onTap,
      required this.partSelected,
      required this.widgetMaxHeight})
      : super(key: key);
  final Part item;
  final Function onTap;
  final bool partSelected;
  final double widgetMaxHeight;

  @override
  Widget build(BuildContext context) {
    return Draggable(
      data: item,
      feedback: Card(
          child: _Child(
        item: item,
        selected: partSelected,
        widgetMaxHeight: widgetMaxHeight,
      )),
      child: InkWell(
        onTapUp: (_) => onTap(),
        child: _Child(
          item: item,
          selected: partSelected,
          widgetMaxHeight: widgetMaxHeight,
        ),
      ),
    );
  }
}

class _Child extends StatelessWidget {
  const _Child(
      {Key? key,
      required this.item,
      required this.selected,
      required this.widgetMaxHeight})
      : super(key: key);
  final Part item;
  final bool selected;
  static const bold = TextStyle(fontWeight: FontWeight.bold);
  final double widgetMaxHeight;

  @override
  Widget build(BuildContext context) {
    final style = selected ? bold : null;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.45,
        maxHeight: widgetMaxHeight,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 125),
                child: Text(item.type.name, style: style)),
            ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 125),
                child: Text(item.partNo.id, style: style)),
            ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 75),
                child: Text('${item.runningHours.value}', style: style)),
            ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 75),
                child:
                    Text('${item.runningHoursAtLocation.value}', style: style)),
            Flexible(
              child:
                  Text(item.remarks, style: style, overflow: TextOverflow.fade),
            ),
          ],
        ),
      ),
    );
  }
}
