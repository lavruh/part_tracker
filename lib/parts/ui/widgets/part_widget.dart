import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/locations/domain/locations_manager_state.dart';
import 'package:part_tracker/parts/domain/entities/part.dart';

class PartWidget extends StatelessWidget {
  const PartWidget(
      {super.key,
      required this.item,
      required this.onTap,
      required this.partSelected,
      required this.widgetMaxHeight});
  final Part item;
  final Function onTap;
  final bool partSelected;
  final double widgetMaxHeight;

  @override
  Widget build(BuildContext context) {
    Widget child = _ChildDesktop(
        item: item, selected: partSelected, widgetMaxHeight: widgetMaxHeight);
    Widget result = Draggable(
        data: item,
        feedback: Card(child: child),
        child: InkWell(onTapUp: (_) => onTap(), child: child));
    if (Platform.isAndroid) {
      child = _ChildMobile(
          item: item, selected: partSelected, widgetMaxHeight: widgetMaxHeight);
      result = LongPressDraggable(
        data: item,
        feedback: Card(child: child),
        child: InkWell(onTapUp: (_) => onTap(), child: child),
        onDragStarted: () {
          Get.find<LocationManagerState>().showLocations();
        },
      );
    }
    return result;
  }
}

class _ChildDesktop extends StatelessWidget {
  const _ChildDesktop(
      {super.key,
      required this.item,
      required this.selected,
      required this.widgetMaxHeight});
  final Part item;
  final bool selected;
  static const bold = TextStyle(fontWeight: FontWeight.bold);
  final double widgetMaxHeight;

  @override
  Widget build(BuildContext context) {
    final style = selected ? bold : null;
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.45,
      height: widgetMaxHeight,
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

class _ChildMobile extends StatelessWidget {
  const _ChildMobile(
      {super.key,
      required this.item,
      required this.selected,
      required this.widgetMaxHeight});
  final Part item;
  final bool selected;
  static const bold = TextStyle(fontWeight: FontWeight.bold);
  final double widgetMaxHeight;

  @override
  Widget build(BuildContext context) {
    final style = selected ? bold : null;
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.45,
      // height: widgetMaxHeight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flex(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              direction: Axis.horizontal,
              children: [
                Flexible(
                    flex: 3,
                    child: Text("${item.type.name} no.[${item.partNo.id}]",
                        style: style)),
                Flexible(child: Container()),
                Flexible(
                    flex: 2,
                    child: Text('${item.runningHours.value}', style: style)),
                Flexible(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text('${item.runningHoursAtLocation.value}',
                        style: style),
                  ),
                ),
              ],
            ),
            Text(item.remarks, style: style, overflow: TextOverflow.fade),
          ],
        ),
      ),
    );
  }
}
