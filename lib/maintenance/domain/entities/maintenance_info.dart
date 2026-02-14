import 'package:part_tracker/maintenance/domain/entities/maintenance_plan.dart';

class MaintenanceInfo {
  final MaintenancePlan plan;
  final String info;
  final int difference;
  final double percentage;
  final bool isOverdue;

  MaintenanceInfo({
    required this.plan,
    required this.info,
    required this.difference,
    required this.percentage,
    required this.isOverdue,
  });

  MaintenanceInfo copyWith({
    MaintenancePlan? plan,
    String? info,
    int? difference,
    double? percentage,
    bool? isOverdue,
  }) {
    return MaintenanceInfo(
      plan: plan ?? this.plan,
      info: info ?? this.info,
      difference: difference ?? this.difference,
      percentage: percentage ?? this.percentage,
      isOverdue: isOverdue ?? this.isOverdue,
    );
  }
}
