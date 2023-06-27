import 'package:part_tracker/utils/domain/unique_id.dart';

class LogEntry {
  final UniqueId id;
  final DateTime date;
  final String entry;
  final List<UniqueId> relatedParts;
  final List<UniqueId> relatedLocations;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LogEntry && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  LogEntry._internal({
    required this.id,
    required this.date,
    required this.entry,
    required this.relatedParts,
    required this.relatedLocations,
  });

  LogEntry({
    required this.entry,
    this.relatedParts = const [],
    this.relatedLocations = const [],
  })  : id = UniqueId(),
        date = DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id.toString(),
      'date': date.millisecondsSinceEpoch,
      'message': entry,
      'relatedParts': relatedParts.map((e) => e.toMap()).toList(),
      'relatedLocations': relatedLocations.map((e) => e.toMap()).toList(),
    };
  }

  factory LogEntry.fromMap(Map<String, dynamic> map) {
    return LogEntry._internal(
      id: UniqueId(id: map['id']),
      date: DateTime.fromMillisecondsSinceEpoch(
          map['date'] ?? DateTime.now().millisecondsSinceEpoch),
      entry: map['message'].toString(),
      relatedParts: (map['relatedParts'] as List)
          .map((e) => UniqueId.fromMap(e))
          .toList(),
      relatedLocations: (map['relatedLocations'] as List)
          .map((e) => UniqueId.fromMap(e))
          .toList(),
    );
  }

  @override
  String toString() {
    return 'LogEntry{date: $date, message: $entry}';
  }

  LogEntry copyWith({
    UniqueId? id,
    DateTime? date,
    String? entry,
    List<UniqueId>? relatedParts,
    List<UniqueId>? relatedLocations,
  }) {
    return LogEntry._internal(
      id: id ?? this.id,
      date: date ?? this.date,
      entry: entry ?? this.entry,
      relatedParts: relatedParts ?? this.relatedParts,
      relatedLocations: relatedLocations ?? this.relatedLocations,
    );
  }
}
