import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/locations/domain/locations_manager_state.dart';
import 'package:part_tracker/logbook/domain/logbook_state.dart';
import 'package:part_tracker/maintenance/domain/entities/maintenance_info.dart';
import 'package:part_tracker/maintenance/domain/maintenance_notifier.dart';
import 'package:part_tracker/parts/domain/entities/part.dart';
import 'package:part_tracker/parts/domain/parts_manager_state.dart';

class MaintenanceInfoOverview extends StatefulWidget {
  const MaintenanceInfoOverview({super.key, required this.part});
  final Part part;

  @override
  State<MaintenanceInfoOverview> createState() =>
      _MaintenanceInfoOverviewState();
}

class _MaintenanceInfoOverviewState extends State<MaintenanceInfoOverview> {
  List<MaintenanceInfo> selectedPlans = [];

  @override
  Widget build(BuildContext context) {
    final maintenanceNotifier = Get.find<MaintenanceNotifier>();
    final data =
        maintenanceNotifier.necessaryMaintenanceInfos(widget.part.partNo);
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 100, minHeight: 100),
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...data.map(
              (e) {
                return CheckboxListTile(
                  title: Text.rich(
                    TextSpan(
                        text: "${e.plan.title}:  ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                              text: e.info,
                              style: TextStyle(fontWeight: FontWeight.normal)),
                        ]),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(left: 18.0),
                    child: Text(e.plan.description,
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontStyle: FontStyle.italic)),
                  ),
                  value: _isSelected(info: e),
                  onChanged: (val) {
                    if (val == true) {
                      selectedPlans.add(e);
                    }
                    if (val == false) {
                      selectedPlans.remove(e);
                    }
                    setState(() {});
                  },
                );
              },
            ),
            AnimatedCrossFade(
                firstChild: Container(),
                secondChild: TextButton(
                    onPressed: performMaintenance,
                    child: Text('Do maintenance')),
                crossFadeState: selectedPlans.isEmpty
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: Duration(milliseconds: 300)),
          ],
        ),
      ),
    );
  }

  void performMaintenance() {
    final part = widget.part;
    final partId = part.partNo;
    final location = Get.find<LocationManagerState>()
        .getLocationContainingPart(partId: partId);
    final locationRunningHours = location.runningHours;
    if (locationRunningHours == null) return;
    final logWhatDone = Get.find<PartsManagerState>().performMaintenance(
        partId: partId,
        maintenanceToPerform: selectedPlans,
        runningHours: locationRunningHours);
    if (logWhatDone != null) {
      Get.find<LogbookState>().addMaintenanceLogEntry(
        location: location,
        part: part,
        remarks: logWhatDone,
      );
    }
    setState(() {});
  }

  bool? _isSelected({required MaintenanceInfo info}) {
    return selectedPlans.contains(info);
  }
}
