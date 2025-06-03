import 'package:cloud_firestore/cloud_firestore.dart';

enum MedicineType { liquid, tablet, drops, cream, injection, other }
enum MedicineUnit { ml, mg, drops, applications }
enum MedicineFrequency {
  asNeeded,
  once,
  twice,
  thrice,
  fourTimes,
  every4Hours,
  every6Hours,
  every8Hours,
  every12Hours,
}

class MedicineEntry {
  final String id;
  final String babyId;
  final String medicineName;
  final MedicineType type;
  final double dosage;
  final MedicineUnit unit;
  final DateTime givenAt;
  final String? prescribedBy;
  final String? reason;
  final DateTime? nextDoseTime;
  final MedicineFrequency? frequency;
  final bool isCompleted;
  final String? notes;
  final DateTime createdAt;
  final String createdBy;

  MedicineEntry({
    required this.id,
    required this.babyId,
    required this.medicineName,
    required this.type,
    required this.dosage,
    required this.unit,
    required this.givenAt,
    this.prescribedBy,
    this.reason,
    this.nextDoseTime,
    this.frequency,
    this.isCompleted = false,
    this.notes,
    required this.createdAt,
    required this.createdBy,
  });

  factory MedicineEntry.fromMap(Map<String, dynamic> map, String id) {
    return MedicineEntry(
      id: id,
      babyId: map['babyId'] ?? '',
      medicineName: map['medicineName'] ?? '',
      type: MedicineType.values.firstWhere(
        (t) => t.toString().split('.').last == map['type'],
        orElse: () => MedicineType.liquid,
      ),
      dosage: (map['dosage'] ?? 0).toDouble(),
      unit: MedicineUnit.values.firstWhere(
        (u) => u.toString().split('.').last == map['unit'],
        orElse: () => MedicineUnit.ml,
      ),
      givenAt: (map['givenAt'] as Timestamp).toDate(),
      prescribedBy: map['prescribedBy'],
      reason: map['reason'],
      nextDoseTime: map['nextDoseTime'] != null 
          ? (map['nextDoseTime'] as Timestamp).toDate() 
          : null,
      frequency: map['frequency'] != null
          ? MedicineFrequency.values.firstWhere(
              (f) => f.toString().split('.').last == map['frequency'],
              orElse: () => MedicineFrequency.asNeeded,
            )
          : null,
      isCompleted: map['isCompleted'] ?? false,
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      createdBy: map['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'babyId': babyId,
      'medicineName': medicineName,
      'type': type.toString().split('.').last,
      'dosage': dosage,
      'unit': unit.toString().split('.').last,
      'givenAt': Timestamp.fromDate(givenAt),
      'prescribedBy': prescribedBy,
      'reason': reason,
      'nextDoseTime': nextDoseTime != null 
          ? Timestamp.fromDate(nextDoseTime!) 
          : null,
      'frequency': frequency?.toString().split('.').last,
      'isCompleted': isCompleted,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }

  MedicineEntry copyWith({
    String? id,
    String? babyId,
    String? medicineName,
    MedicineType? type,
    double? dosage,
    MedicineUnit? unit,
    DateTime? givenAt,
    String? prescribedBy,
    String? reason,
    DateTime? nextDoseTime,
    MedicineFrequency? frequency,
    bool? isCompleted,
    String? notes,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return MedicineEntry(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      medicineName: medicineName ?? this.medicineName,
      type: type ?? this.type,
      dosage: dosage ?? this.dosage,
      unit: unit ?? this.unit,
      givenAt: givenAt ?? this.givenAt,
      prescribedBy: prescribedBy ?? this.prescribedBy,
      reason: reason ?? this.reason,
      nextDoseTime: nextDoseTime ?? this.nextDoseTime,
      frequency: frequency ?? this.frequency,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}