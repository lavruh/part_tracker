import 'package:part_tracker/utils/domain/unique_id.dart';

class PartType {
  final UniqueId id;
  final String name;

  PartType({required this.id, required this.name});

  @override
  String toString() {
    return 'id: $id, name: $name';
  }

  PartType.empty()
      : id = UniqueId(),
        name = '';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PartType && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  PartType copyWith({
    UniqueId? id,
    String? name,
  }) {
    return PartType(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id.id,
      'name': name,
    };
  }

  factory PartType.fromMap(Map<String, dynamic> map) {
    return PartType(
      id: UniqueId(id: map['id']),
      name: map['name'] as String,
    );
  }
}
