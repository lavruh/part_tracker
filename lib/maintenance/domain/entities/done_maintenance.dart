import 'package:part_tracker/running_hours/domain/entities/running_hours.dart';
import 'package:part_tracker/utils/domain/date_extensions.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';

class DoneMaintenance {
  final DateTime date;
  final RunningHours runningHours;
  final UniqueId planId;
  final String remarks;

  const DoneMaintenance({
    required this.date,
    required this.runningHours,
    required this.planId,
    required this.remarks,
  });

  DoneMaintenance.now(
      {required this.runningHours, required this.planId, this.remarks = ""})
      : date = DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'runningHours': runningHours.toMap(),
      'planId': planId.toMap(),
      'remarks': remarks,
    };
  }

  factory DoneMaintenance.fromMap(Map<String, dynamic> map) {
    final dateMap = map['date'];
    return DoneMaintenance(
      date: fromDynamic(dateMap),
      runningHours: RunningHours.fromMap(map['runningHours']),
      planId: UniqueId.fromMap(map['planId']),
      remarks: map['remarks'] ?? '',
    );
  }
}
