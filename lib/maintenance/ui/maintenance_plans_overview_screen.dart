import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/maintenance/domain/entities/maintenance_plan.dart';
import 'package:part_tracker/maintenance/domain/maintenance_notifier.dart';
import 'package:part_tracker/maintenance/ui/maintenance_plan_editor.dart';
import 'package:part_tracker/maintenance/ui/maintenance_plan_widget.dart';
import 'package:popover/popover.dart';

class MaintenancePlansOverviewScreen extends StatelessWidget {
  const MaintenancePlansOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [AddMaintenancePlanButton()],
      ),
      body: GetX<MaintenanceNotifier>(builder: (state) {
        final children = state.maintenancePlans.values
            .map((e) => MaintenancePlanWidget(plan: e, onTap: () {

          Get.defaultDialog(
              title: "Update ${e.id}",
              content: MaintenancePlanEditorWidget(plan: e));
        }));

        return ListView(children: [...children]);
      }),
    );
  }
}

class AddMaintenancePlanButton extends StatelessWidget {
  const AddMaintenancePlanButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          showPopover(
              context: context,
              direction: PopoverDirection.left,
              bodyBuilder: (context) => _showAddMenu(context));
        },
        icon: Icon(Icons.add));
  }

  Widget _showAddMenu(BuildContext context) {
    final types = DefaultMeterTypes.values;
    return Flexible(
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Add",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...types.map((e) => TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Get.defaultDialog(
                      title: "Edit ${e.value.title}",
                      content: MaintenancePlanEditorWidget(plan: e.creator));
                },
                child: Text(e.value.title)))
          ],
        ),
      ),
    );
  }
}
