import 'package:cloud_firestore/cloud_firestore.dart';

enum DiaperType {
  wet,
  dirty,
  mixed,
  dry,
}

class DiaperEntry {
  final String id;
  final String babyId;
  final DiaperType type;
  final DateTime changeTime;
  final bool hasRash;
  final String? consistency;
  final String? color;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  DiaperEntry({
    required this.id,
    required this.babyId,
    required this.type,
    required this.changeTime,
    this.hasRash = false,
    this.consistency,
    this.color,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convenience getters for compatibility
  DateTime get time => changeTime;
  DateTime get timestamp => changeTime;

  // Factory constructor for creating a new entry
  factory DiaperEntry.create({
    required String babyId,
    required DiaperType type,
    required DateTime changeTime,
    bool hasRash = false,
    String? consistency,
    String? color,
    String? notes,
  }) {
    final now = DateTime.now();
    return DiaperEntry(
      id: '', // Will be set by repository
      babyId: babyId,
      type: type,
      changeTime: changeTime,
      hasRash: hasRash,
      consistency: consistency,
      color: color,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }
  // Factory method to create from Firestore document
  factory DiaperEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DiaperEntry(
      id: doc.id,
      babyId: data['babyId'] ?? '',
      type: DiaperType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => DiaperType.wet,
      ),
      changeTime: (data['changeTime'] as Timestamp).toDate(),
      hasRash: data['hasRash'] ?? false,
      consistency: data['consistency'],
      color: data['color'],
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Factory method to create from JSON
  factory DiaperEntry.fromJson(Map<String, dynamic> json) {
    return DiaperEntry(
      id: json['id'] ?? '',
      babyId: json['babyId'] ?? '',
      type: DiaperType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => DiaperType.wet,
      ),
      changeTime: DateTime.parse(json['changeTime']),
      hasRash: json['hasRash'] ?? false,
      consistency: json['consistency'],
      color: json['color'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Factory method to create from Map
  factory DiaperEntry.fromMap(Map<String, dynamic> map) {
    return DiaperEntry(
      id: map['id'] ?? '',
      babyId: map['babyId'] ?? '',
      type: DiaperType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => DiaperType.wet,
      ),
      changeTime: map['changeTime'] is DateTime 
          ? map['changeTime'] 
          : DateTime.parse(map['changeTime']),
      hasRash: map['hasRash'] ?? false,
      consistency: map['consistency'],
      color: map['color'],
      notes: map['notes'],
      createdAt: map['createdAt'] is DateTime 
          ? map['createdAt'] 
          : DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] is DateTime 
          ? map['updatedAt'] 
          : DateTime.parse(map['updatedAt']),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'babyId': babyId,
      'type': type.toString().split('.').last,
      'changeTime': Timestamp.fromDate(changeTime),
      'hasRash': hasRash,
      'consistency': consistency,
      'color': color,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'babyId': babyId,
      'type': type.toString().split('.').last,
      'changeTime': changeTime.toIso8601String(),
      'hasRash': hasRash,
      'consistency': consistency,
      'color': color,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'babyId': babyId,
      'type': type.toString().split('.').last,
      'changeTime': changeTime,
      'hasRash': hasRash,
      'consistency': consistency,
      'color': color,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Create a copy with updated fields
  DiaperEntry copyWith({
    String? id,
    String? babyId,
    DiaperType? type,
    DateTime? changeTime,
    bool? hasRash,
    String? consistency,
    String? color,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DiaperEntry(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      type: type ?? this.type,
      changeTime: changeTime ?? this.changeTime,
      hasRash: hasRash ?? this.hasRash,
      consistency: consistency ?? this.consistency,
      color: color ?? this.color,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is DiaperEntry &&
        other.id == id &&
        other.babyId == babyId &&
        other.type == type &&
        other.changeTime == changeTime &&
        other.hasRash == hasRash &&
        other.consistency == consistency &&
        other.color == color &&
        other.notes == notes &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        babyId.hashCode ^
        type.hashCode ^
        changeTime.hashCode ^
        hasRash.hashCode ^
        consistency.hashCode ^
        color.hashCode ^
        notes.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'DiaperEntry(id: $id, babyId: $babyId, type: $type, changeTime: $changeTime, hasRash: $hasRash, consistency: $consistency, color: $color, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
