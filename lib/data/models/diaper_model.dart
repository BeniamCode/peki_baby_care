import 'package:cloud_firestore/cloud_firestore.dart';

enum DiaperType { wet, dirty, both, dry }
enum DiaperCondition { normal, diarrhea, constipation }

class DiaperModel {
  final String id;
  final String babyId;
  final DateTime changeTime;
  final DiaperType type;
  final DiaperCondition? condition;
  final String? color; // for tracking stool color
  final bool hasRash;
  final String? rashNotes;
  final String? notes;
  final DateTime createdAt;
  final String createdBy;

  DiaperModel({
    required this.id,
    required this.babyId,
    required this.changeTime,
    required this.type,
    this.condition,
    this.color,
    required this.hasRash,
    this.rashNotes,
    this.notes,
    required this.createdAt,
    required this.createdBy,
  });

  factory DiaperModel.fromMap(Map<String, dynamic> map, String id) {
    return DiaperModel(
      id: id,
      babyId: map['babyId'] ?? '',
      changeTime: (map['changeTime'] as Timestamp).toDate(),
      type: DiaperType.values.firstWhere(
        (t) => t.toString().split('.').last == map['type'],
        orElse: () => DiaperType.wet,
      ),
      condition: map['condition'] != null
          ? DiaperCondition.values.firstWhere(
              (c) => c.toString().split('.').last == map['condition'],
              orElse: () => DiaperCondition.normal,
            )
          : null,
      color: map['color'],
      hasRash: map['hasRash'] ?? false,
      rashNotes: map['rashNotes'],
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      createdBy: map['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'babyId': babyId,
      'changeTime': Timestamp.fromDate(changeTime),
      'type': type.toString().split('.').last,
      'condition': condition?.toString().split('.').last,
      'color': color,
      'hasRash': hasRash,
      'rashNotes': rashNotes,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }

  DiaperModel copyWith({
    String? id,
    String? babyId,
    DateTime? changeTime,
    DiaperType? type,
    DiaperCondition? condition,
    String? color,
    bool? hasRash,
    String? rashNotes,
    String? notes,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return DiaperModel(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      changeTime: changeTime ?? this.changeTime,
      type: type ?? this.type,
      condition: condition ?? this.condition,
      color: color ?? this.color,
      hasRash: hasRash ?? this.hasRash,
      rashNotes: rashNotes ?? this.rashNotes,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}