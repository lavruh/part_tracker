import 'package:intl/intl.dart';

class RunningHours {
  final int value;

  @override
  String toString() {
    return '$value @ ${DateFormat("y-MM-dd hh:mm").format(date)}';
  }

  final DateTime date;

  const RunningHours._constructor({
    required this.value,
    required this.date,
  });

  factory RunningHours(int val) =>
      RunningHours._constructor(value: val, date: DateTime.now());

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'date': date.millisecondsSinceEpoch,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RunningHours &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  factory RunningHours.fromMap(Map<String, dynamic> map) {
    return RunningHours._constructor(
      value: map['value'] as int,
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
    );
  }

  RunningHours copyWith({
    int? value,
    DateTime? date,
  }) {
    return RunningHours._constructor(
      value: value ?? this.value,
      date: date ?? this.date,
    );
  }

  RunningHours operator +(RunningHours other) {
    return RunningHours(value + other.value);
  }
}
