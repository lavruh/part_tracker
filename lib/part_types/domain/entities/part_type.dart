import 'package:part_tracker/utils/domain/mappers.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';

class PartType {
  final UniqueId id;
  final String name;
  final List<UniqueId> maintenancePlans;

  PartType(
      {required this.id, required this.name, required this.maintenancePlans});

  @override
  String toString() {
    return 'id: $id, name: $name';
  }

  PartType.empty()
      : id = UniqueId(),
        name = '',
        maintenancePlans = [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PartType && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  PartType copyWith({
    UniqueId? id,
    String? name,
    List<UniqueId>? maintenancePlans,
  }) {
    return PartType(
      id: id ?? this.id,
      name: name ?? this.name,
      maintenancePlans: maintenancePlans ?? this.maintenancePlans,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id.id,
      'name': name,
      'maintenancePlans': maintenancePlans.map((e) => e.toMap()).toList(),
    };
  }

  factory PartType.fromMap(Map<String, dynamic> map) {
    return PartType(
        id: UniqueId(id: map['id']),
        name: map['name'] as String,
        maintenancePlans: mapUniqueIdList(map['maintenancePlans']));
  }
}
