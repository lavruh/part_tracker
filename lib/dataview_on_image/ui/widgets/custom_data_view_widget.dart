import 'package:data_on_image_view/domain/view_port.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/locations/domain/locations_manager_state.dart';
import 'package:part_tracker/maintenance/domain/maintenance_notifier.dart';
import 'package:part_tracker/maintenance/ui/maintenance_info_widget.dart';
import 'package:part_tracker/parts/domain/parts_manager_state.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';

class CustomDataViewWidget extends StatelessWidget {
  const CustomDataViewWidget({super.key, required this.port});
  final ViewPort port;

  @override
  Widget build(BuildContext context) {
    final locationId = UniqueId(id: port.id);
    final location = Get.find<LocationManagerState>().locations[locationId];
    if (location == null) return Container();
    final parts = Get.find<PartsManagerState>().getPartWithIds(location.parts);
    final maintenanceNotifier = Get.find<MaintenanceNotifier>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...parts.map((e) {
          final textColor = port.textColor;
          final timeToMaintenanceInfos =
              maintenanceNotifier.checkPartTimeToMaintenance(part: e);
          final defTextStyle =
              TextStyle(color: textColor, fontSize: port.textSize);

          return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(text: "", style: defTextStyle, children: [
                    TextSpan(
                      text: "${e.type.name}\t",
                      style: defTextStyle.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: "${e.partNo}\t"),
                    TextSpan(
                        text: "${e.runningHoursAtLocation.value}rh",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                        ))
                  ]),
                ),
                ...timeToMaintenanceInfos.map((e) {
                  return MaintenanceInfoWidget(
                      info: e, defTextStyle: defTextStyle);
                }),
              ]);
        }),
      ],
    );
  }
}
