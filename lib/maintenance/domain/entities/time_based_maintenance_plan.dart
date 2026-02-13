import 'package:part_tracker/maintenance/domain/entities/maintenance_info.dart';
import 'package:part_tracker/maintenance/domain/entities/maintenance_plan.dart';
import 'package:part_tracker/parts/domain/entities/part.dart';
import 'package:part_tracker/running_hours/domain/entities/running_hours.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';

class TimeBasedMaintenancePlan extends MaintenancePlan {
  final int timeLimit;
  final TimeUnit timeUnit;

  TimeBasedMaintenancePlan(
      {required super.id,
      required super.title,
      required super.description,
      required this.timeLimit,
      required this.timeUnit});

  const TimeBasedMaintenancePlan.empty()
      : timeLimit = 0,
        timeUnit = TimeUnit.day,
        super.empty();

  @override
  TimeBasedMaintenancePlan copyWith({
    UniqueId? id,
    String? title,
    String? description,
    int? timeLimit,
    TimeUnit? timeUnit,
  }) {
    return TimeBasedMaintenancePlan(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timeLimit: timeLimit ?? this.timeLimit,
      timeUnit: timeUnit ?? this.timeUnit,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id.toMap(),
      'title': title,
      'description': description,
      'timeLimit': timeLimit,
      'timeUnit': timeUnit.name,
      'planType': 'time_based',
    };
  }

  @override
  factory TimeBasedMaintenancePlan.fromMap(Map<String, dynamic> map) {
    return TimeBasedMaintenancePlan(
      id: UniqueId.fromMap(map['id']),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      timeLimit: map['timeLimit'] ?? 0,
      timeUnit: TimeUnit.values.firstWhere(
        (unit) => unit.name == map['timeUnit'],
        orElse: () => TimeUnit.day,
      ),
    );
  }

  @override
  MaintenanceInfo? checkPart({
    required Part part,
    required RunningHours locationRunningHours,
  }) {
    final counterLimitInDays = getTimeLimitInDays();
    final daysDifference = _getDifference(part, locationRunningHours);
    if (daysDifference < counterLimitInDays) return null;
    final info = "Overdue $daysDifference days";
    return MaintenanceInfo(
        plan: this,
        info: info,
        isOverdue: true,
        difference: daysDifference,
        percentage: _getPercentage(daysDifference));
  }

  int getTimeLimitInDays() => timeLimit * _getDuration(timeUnit).inDays;

  int _getDifference(Part part, RunningHours locationRunningHours) {
    final lastMaintenance = part.doneMaintenance
        .where((dm) => dm.planId == id)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final startDate = lastMaintenance.isNotEmpty
        ? lastMaintenance.first.date
        : part.installationRh.date;

    final now = DateTime.now();
    final daysDifference = now.difference(startDate).inDays;
    return daysDifference;
  }

  @override
  MaintenanceInfo? timeToMaintenance({
    required Part part,
    required RunningHours locationRunningHours,
  }) {
    final counterLimitInDays = getTimeLimitInDays();
    final daysDifference = _getDifference(part, locationRunningHours);
    final isOverdue = daysDifference >= counterLimitInDays;

    String info = "$daysDifference days overdue";
    if (!isOverdue) info = "$daysDifference days until";
    return MaintenanceInfo(
        plan: this,
        info: info,
        isOverdue: isOverdue,
        difference: daysDifference,
        percentage: _getPercentage(daysDifference));
  }

  double _getPercentage(int difference) =>
      (difference / getTimeLimitInDays()).abs();
}

Duration _getDuration(TimeUnit unit) {
  switch (unit) {
    case TimeUnit.day:
      return Duration(days: 1);
    case TimeUnit.week:
      return Duration(days: 7);
    case TimeUnit.month:
      return Duration(days: 30);
  }
}

enum TimeUnit {
  day,
  week,
  month,
}
