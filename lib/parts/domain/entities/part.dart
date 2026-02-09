import 'package:part_tracker/maintenance/domain/entities/done_maintenance.dart';
import 'package:part_tracker/part_types/domain/entities/part_type.dart';
import 'package:part_tracker/running_hours/domain/entities/running_hours.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';

class Part {
  final UniqueId partNo;
  final RunningHours runningHours;
  final RunningHours runningHoursAtLocation;
  final String remarks;
  final PartType type;
  final RunningHours installationRh;
  final List<DoneMaintenance> doneMaintenance;

  const Part({
    required this.partNo,
    required this.runningHours,
    required this.runningHoursAtLocation,
    required this.remarks,
    required this.type,
    required this.installationRh,
    required this.doneMaintenance,
  });

  Part.newPart({required this.partNo, required this.type, String? remarks})
      : runningHours = RunningHours(0),
        runningHoursAtLocation = RunningHours(0),
        installationRh = RunningHours(0),
        remarks = remarks ?? '',
        doneMaintenance = [];

  Map<String, dynamic> toMap() {
    return {
      'partNo': partNo.toString(),
      'runningHours': runningHours.toMap(),
      'runningHoursAtLocation': runningHoursAtLocation.toMap(),
      'remarks': remarks,
      'type': type.toMap(),
      'installationDate': installationRh.toMap(),
      'doneMaintenance': doneMaintenance.map((e) => e.toMap()).toList(),
    };
  }

  factory Part.fromMap(Map<String, dynamic> map) {
    final maintenanceMap = map['doneMaintenance'] ?? [];
    List<DoneMaintenance> doneMaintenance = [];
    for (Map<String, dynamic> element in maintenanceMap) {
      doneMaintenance.add(DoneMaintenance.fromMap(element));
    }

    return Part(
      partNo: UniqueId(id: map['partNo']),
      runningHours: RunningHours.fromMap(map['runningHours']),
      runningHoursAtLocation:
          RunningHours.fromMap(map['runningHoursAtLocation']),
      remarks: map['remarks'] as String,
      type: PartType.fromMap(map['type']),
      installationRh: RunningHours.fromMap(map['installationDate']),
      doneMaintenance: doneMaintenance,
    );
  }

  Part copyWith({
    UniqueId? partNo,
    RunningHours? runningHours,
    RunningHours? runningHoursAtLocation,
    String? remarks,
    PartType? type,
    RunningHours? installationRh,
    List<DoneMaintenance>? doneMaintenance,
  }) {
    return Part(
      partNo: partNo ?? this.partNo,
      runningHours: runningHours ?? this.runningHours,
      runningHoursAtLocation:
          runningHoursAtLocation ?? this.runningHoursAtLocation,
      remarks: remarks ?? this.remarks,
      type: type ?? this.type,
      installationRh: installationRh ?? this.installationRh,
      doneMaintenance: doneMaintenance ?? this.doneMaintenance,
    );
  }
}
