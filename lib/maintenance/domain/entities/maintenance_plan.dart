import 'package:part_tracker/maintenance/domain/entities/counter_maintenance_plan.dart';
import 'package:part_tracker/maintenance/domain/entities/maintenance_info.dart';
import 'package:part_tracker/maintenance/domain/entities/time_based_maintenance_plan.dart';
import 'package:part_tracker/parts/domain/entities/part.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';

class MaintenancePlan {
  final UniqueId id;
  final String title;
  final String description;

  MaintenancePlan({
    required this.id,
    required this.title,
    required this.description,
  });

  const MaintenancePlan.empty()
      : id = const UniqueId.empty(),
        title = "",
        description = "";

  MaintenanceInfo? checkPart({required Part part}) => null;

  MaintenancePlan copyWith({
    UniqueId? id,
    String? title,
    String? description,
  }) {
    return MaintenancePlan(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    throw UnimplementedError();
  }

  factory MaintenancePlan.fromMap(Map<String, dynamic> map) {
    return MaintenancePlan(
      id: UniqueId.fromMap(map['id']),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
    );
  }
}

enum DefaultMeterTypes {
  rh(MaintenanceType("rh", "Running hours"), CounterMaintenancePlan.empty()),
  tank(MaintenanceType("time", "Time based"), TimeBasedMaintenancePlan.empty());

  final MaintenanceType value;
  final MaintenancePlan creator;
  const DefaultMeterTypes(this.value, this.creator);
}

class MaintenanceType {
  final String id;
  final String title;
  const MaintenanceType(this.id, this.title);
}
