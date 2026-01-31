import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/maintenance/domain/maintenance_notifier.dart';
import 'package:part_tracker/parts/domain/entities/part.dart';

class MaintenanceInfoOverview extends StatelessWidget {
  const MaintenanceInfoOverview({super.key, required this.part});
  final Part part;

  @override
  Widget build(BuildContext context) {
    final maintenanceNotifier = Get.find<MaintenanceNotifier>();
    final data = maintenanceNotifier.necessaryMaintenanceInfos(part.partNo);
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 100, minHeight: 100),
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...data.map(
              (e) {
                return ListTile(
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
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
