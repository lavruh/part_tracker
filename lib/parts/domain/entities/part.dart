import 'package:part_tracker/part_types/domain/entities/part_type.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';

class Part {
  final UniqueId partNo;
  final int runningHours;
  final String remarks;
  final PartType type;

  const Part({
    required this.partNo,
    required this.runningHours,
    required this.remarks,
    required this.type,
  });

  Part.newPart({required this.partNo, required this.type, String? remarks})
      : runningHours = 0,
        remarks = remarks ?? '';

  Map<String, dynamic> toMap() {
    return {
      'partNo': partNo.toString(),
      'runningHours': runningHours,
      'remarks': remarks,
      'type': type.toMap(),
    };
  }

  factory Part.fromMap(Map<String, dynamic> map) {
    return Part(
      partNo: UniqueId(id: map['partNo']),
      runningHours: int.tryParse(map['runningHours']) ?? 0,
      remarks: map['remarks'] as String,
      type: PartType.fromMap(map['type']),
    );
  }

  Part copyWith({
    UniqueId? partNo,
    int? runningHours,
    String? remarks,
    PartType? type,
  }) {
    return Part(
      partNo: partNo ?? this.partNo,
      runningHours: runningHours ?? this.runningHours,
      remarks: remarks ?? this.remarks,
      type: type ?? this.type,
    );
  }
}
