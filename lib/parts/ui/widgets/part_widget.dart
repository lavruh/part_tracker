import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/locations/domain/locations_manager_state.dart';
import 'package:part_tracker/maintenance/domain/maintenance_notifier.dart';
import 'package:part_tracker/maintenance/ui/maintenance_info_overview.dart';
import 'package:part_tracker/parts/domain/entities/part.dart';

const bold = TextStyle(fontWeight: FontWeight.bold);

class PartWidget extends StatelessWidget {
  const PartWidget(
      {super.key,
      required this.item,
      required this.onTap,
      required this.partSelected,
      required this.widgetMaxHeight})
      : style = partSelected ? bold : null;
  final Part item;
  final Function onTap;
  final bool partSelected;
  final double widgetMaxHeight;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    Widget child = _ChildDesktop(
        item: item,
        style: style,
        widgetMaxHeight: widgetMaxHeight,
        runningHoursAtLocationProvider: _runningHoursAtLocationProvider);
    Widget result = Draggable(
        data: item,
        feedback: Card(child: child),
        child: InkWell(onTapUp: (_) => onTap(), child: child));
    if (Platform.isAndroid) {
      child = _ChildMobile(
        item: item,
        style: style,
        widgetMaxHeight: widgetMaxHeight,
        runningHoursAtLocationProvider: _runningHoursAtLocationProvider,
      );
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

  Widget _runningHoursAtLocationProvider(BuildContext context) {
    final maintenanceNotifier = Get.find<MaintenanceNotifier>();
    final isPartDueToMaintenance =
        maintenanceNotifier.isPartDueToMaintenance(item.partNo);
    return InkWell(
      onTap: () {
        if (isPartDueToMaintenance) {
          Get.defaultDialog(
              title: "Necessary Maintenance:",
              content: MaintenanceInfoOverview(part: item));
        }
      },
      child: Text('${item.runningHoursAtLocation.value}',
          style: isPartDueToMaintenance
              ? bold.copyWith(color: Colors.red)
              : style),
    );
  }
}

class _ChildDesktop extends StatelessWidget {
  const _ChildDesktop(
      {required this.item,
      required this.style,
      required this.widgetMaxHeight,
      required this.runningHoursAtLocationProvider});
  final Part item;
  final TextStyle? style;
  final double widgetMaxHeight;
  final Widget Function(BuildContext) runningHoursAtLocationProvider;

  @override
  Widget build(BuildContext context) {
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
                child: runningHoursAtLocationProvider(context)),
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
      {required this.item,
      required this.style,
      required this.widgetMaxHeight,
      required this.runningHoursAtLocationProvider});
  final Part item;
  final TextStyle? style;
  final double widgetMaxHeight;
  final Widget Function(BuildContext) runningHoursAtLocationProvider;

  @override
  Widget build(BuildContext context) {
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
                    child: runningHoursAtLocationProvider(context),
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
