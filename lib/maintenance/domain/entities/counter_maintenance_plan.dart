import 'package:part_tracker/maintenance/domain/entities/maintenance_info.dart';
import 'package:part_tracker/maintenance/domain/entities/maintenance_plan.dart';
import 'package:part_tracker/parts/domain/entities/part.dart';
import 'package:part_tracker/running_hours/domain/entities/running_hours.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';

class CounterMaintenancePlan extends MaintenancePlan {
  final int counterLimit;
  CounterMaintenancePlan(
      {required super.id,
      required super.title,
      required super.description,
      required this.counterLimit});

  const CounterMaintenancePlan.empty()
      : counterLimit = 0,
        super.empty();

  @override
  CounterMaintenancePlan copyWith({
    UniqueId? id,
    String? title,
    String? description,
    int? counterLimit,
  }) {
    return CounterMaintenancePlan(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      counterLimit: counterLimit ?? this.counterLimit,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id.toMap(),
      'title': title,
      'description': description,
      'counterLimit': counterLimit,
      'planType': 'counter_based',
    };
  }

  @override
  factory CounterMaintenancePlan.fromMap(Map<String, dynamic> map) {
    return CounterMaintenancePlan(
      id: UniqueId.fromMap(map['id']),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      counterLimit: map['counterLimit'] ?? 0,
    );
  }

  @override
  MaintenanceInfo? checkPart({
    required Part part,
    required RunningHours locationRunningHours,
  }) {
    int currentRh = part.runningHoursAtLocation.value;

    final lastMaintenance = part.doneMaintenance
        .where((dm) => dm.planId == id)
        .toList()
      ..sort((a, b) => b.runningHours.value.compareTo(a.runningHours.value));

    if (lastMaintenance.isNotEmpty) {
      final lastMaintenanceRh = lastMaintenance.first.runningHours.value;
      currentRh = locationRunningHours.value - lastMaintenanceRh;
    }

    if (currentRh < counterLimit) return null;
    final info = "Overdue ${currentRh - counterLimit}rhs";
    return MaintenanceInfo(plan: this, info: info);
  }
}
