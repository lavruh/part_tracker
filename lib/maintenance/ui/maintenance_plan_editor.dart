import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/maintenance/domain/entities/maintenance_plan.dart';
import 'package:part_tracker/maintenance/domain/entities/counter_maintenance_plan.dart';
import 'package:part_tracker/maintenance/domain/entities/time_based_maintenance_plan.dart';
import 'package:part_tracker/maintenance/domain/maintenance_notifier.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';

class MaintenancePlanEditorWidget extends StatefulWidget {
  const MaintenancePlanEditorWidget({super.key, required this.plan});
  final MaintenancePlan plan;

  @override
  State<MaintenancePlanEditorWidget> createState() =>
      _MaintenancePlanEditorWidgetState();
}

class _MaintenancePlanEditorWidgetState
    extends State<MaintenancePlanEditorWidget> {
  late MaintenancePlan item;

  @override
  void initState() {
    item = widget.plan;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.5;

    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              enabled: widget.plan.id.id.isEmpty,
              controller: TextEditingController(text: item.id.toString()),
              onChanged: (text) {
                if (text.isNotEmpty) {
                  item = item.copyWith(id: UniqueId(id: text));
                } else {
                  item = item.copyWith(id: UniqueId());
                }
              },
              decoration: const InputDecoration(
                labelText: 'Id',
              ),
            ),
            TextField(
              controller: TextEditingController(text: item.title),
              onChanged: (text) {
                item = item.copyWith(title: text);
              },
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            TextField(
              controller: TextEditingController(text: item.description),
              maxLines: 10,
              onChanged: (text) {
                item = item.copyWith(description: text);
              },
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
            ),
            if (item is CounterMaintenancePlan) ...[
              TextField(
                controller: TextEditingController(text: (item as CounterMaintenancePlan).counterLimit.toString()),
                onChanged: (text) {
                  final counterLimit = int.tryParse(text) ?? 0;
                  item = (item as CounterMaintenancePlan).copyWith(counterLimit: counterLimit);
                },
                decoration: const InputDecoration(
                  labelText: 'Counter Limit',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
            if (item is TimeBasedMaintenancePlan) ...[
              TextField(
                controller: TextEditingController(text: (item as TimeBasedMaintenancePlan).timeLimit.toString()),
                onChanged: (text) {
                  final timeLimit = int.tryParse(text) ?? 0;
                  item = (item as TimeBasedMaintenancePlan).copyWith(timeLimit: timeLimit);
                },
                decoration: const InputDecoration(
                  labelText: 'Time Limit',
                ),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<TimeUnit>(
                initialValue: (item as TimeBasedMaintenancePlan).timeUnit,
                onChanged: (TimeUnit? newValue) {
                  if (newValue != null) {
                    item = (item as TimeBasedMaintenancePlan).copyWith(timeUnit: newValue);
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Time Unit',
                ),
                items: TimeUnit.values.map((TimeUnit unit) {
                  return DropdownMenuItem<TimeUnit>(
                    value: unit,
                    child: Text(unit.name.toUpperCase()),
                  );
                }).toList(),
              ),
            ],
            IconButton(onPressed: _save, icon: Icon(Icons.check)),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (item.id.id.isEmpty) {
      item = item.copyWith(id: UniqueId());
    }
    Get.find<MaintenanceNotifier>().updateMaintenancePlan(item);
    Get.back();
  }
}
