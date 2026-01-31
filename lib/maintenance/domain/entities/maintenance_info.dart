import 'package:part_tracker/maintenance/domain/entities/maintenance_plan.dart';

class MaintenanceInfo {
  final MaintenancePlan plan;
  final String info;


  MaintenanceInfo({required this.plan, required this.info});

  MaintenanceInfo copyWith({MaintenancePlan? plan, String? info}) {
    return MaintenanceInfo(
      plan: plan ?? this.plan,
      info: info ?? this.info,
    );
  }
}