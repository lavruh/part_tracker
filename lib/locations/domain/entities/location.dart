import 'package:part_tracker/running_hours/domain/entities/running_hours.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';

class Location {
  final UniqueId id;
  final String name;
  final Map<UniqueId, int?> allowedPartTypes;
  final UniqueId? parentLocation;
  final List<UniqueId> parts;
  final RunningHours? runningHours;

  const Location({
    required this.id,
    required this.name,
    required this.allowedPartTypes,
    this.parentLocation,
    required this.parts,
    this.runningHours,
  });

  @override
  String toString() {
    return 'Location{name: $name, parts: $parts}';
  }

  Location.empty({required this.name})
      : id = UniqueId(),
        allowedPartTypes = {},
        parentLocation = null,
        runningHours = null,
        parts = [];

  Location copyWith({
    UniqueId? id,
    String? name,
    Map<UniqueId, int?>? allowedPartTypes,
    UniqueId? parentLocation,
    List<UniqueId>? parts,
    RunningHours? runningHours,
    bool clearRunningHours = false,
    bool clearParentLocation = false,
  }) {
    return Location(
      id: id ?? this.id,
      name: name ?? this.name,
      allowedPartTypes: allowedPartTypes ?? {...this.allowedPartTypes},
      parentLocation:
          clearParentLocation ? null : parentLocation ?? this.parentLocation,
      runningHours:
          clearRunningHours ? null : runningHours ?? this.runningHours,
      parts: parts ?? [...this.parts],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id.toMap(),
      'name': name,
      'allowedPartTypes':
          allowedPartTypes.map((k, v) => MapEntry(k.toMap(), v)),
      'parentLocation': parentLocation?.toMap(),
      'parts': parts.map((e) => e.toMap()).toList(),
      'runningHours': runningHours?.toMap(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Location && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  factory Location.fromMap(Map<String, dynamic> map) {
    Map<UniqueId, int?> allowedPT = {};
    final Map<String, dynamic> mapAllowedPT = map['allowedPartTypes'];
    for (final key in mapAllowedPT .keys) {
      final i = mapAllowedPT[key];
      allowedPT.putIfAbsent(UniqueId.fromMap(key), () => i);
    }
    // print(map['allowedPartTypes']);

    return Location(
      id: UniqueId(id: map['id']),
      name: map['name'] as String,
      allowedPartTypes: allowedPT,
      parentLocation: map['parentLocation'] != null
          ? UniqueId(id: map['parentLocation'])
          : null,
      parts: (map['parts'] as List).map((e) => UniqueId.fromMap(e)).toList(),
      runningHours: map['runningHours'] != null
          ? RunningHours.fromMap(map['runningHours'])
          : null,
    );
  }
}
