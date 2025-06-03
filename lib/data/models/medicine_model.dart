import 'package:cloud_firestore/cloud_firestore.dart';

enum MedicineType { liquid, tablet, drops, cream, injection, other }
enum MedicineUnit { ml, mg, drops, applications }

class MedicineModel {
  final String id;
  final String babyId;
  final String medicineName;
  final MedicineType type;
  final double dosage;
  final MedicineUnit unit;
  final DateTime administeredAt;
  final String? prescribedBy;
  final String? reason; // fever, cold, vaccination, etc.
  final DateTime? nextDoseTime;
  final List<String>? sideEffects;
  final String? notes;
  final DateTime createdAt;
  final String createdBy;

  MedicineModel({
    required this.id,
    required this.babyId,
    required this.medicineName,
    required this.type,
    required this.dosage,
    required this.unit,
    required this.administeredAt,
    this.prescribedBy,
    this.reason,
    this.nextDoseTime,
    this.sideEffects,
    this.notes,
    required this.createdAt,
    required this.createdBy,
  });

  factory MedicineModel.fromMap(Map<String, dynamic> map, String id) {
    return MedicineModel(
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
      administeredAt: (map['administeredAt'] as Timestamp).toDate(),
      prescribedBy: map['prescribedBy'],
      reason: map['reason'],
      nextDoseTime: map['nextDoseTime'] != null 
          ? (map['nextDoseTime'] as Timestamp).toDate() 
          : null,
      sideEffects: map['sideEffects'] != null 
          ? List<String>.from(map['sideEffects']) 
          : null,
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
      'administeredAt': Timestamp.fromDate(administeredAt),
      'prescribedBy': prescribedBy,
      'reason': reason,
      'nextDoseTime': nextDoseTime != null 
          ? Timestamp.fromDate(nextDoseTime!) 
          : null,
      'sideEffects': sideEffects,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }

  MedicineModel copyWith({
    String? id,
    String? babyId,
    String? medicineName,
    MedicineType? type,
    double? dosage,
    MedicineUnit? unit,
    DateTime? administeredAt,
    String? prescribedBy,
    String? reason,
    DateTime? nextDoseTime,
    List<String>? sideEffects,
    String? notes,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return MedicineModel(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      medicineName: medicineName ?? this.medicineName,
      type: type ?? this.type,
      dosage: dosage ?? this.dosage,
      unit: unit ?? this.unit,
      administeredAt: administeredAt ?? this.administeredAt,
      prescribedBy: prescribedBy ?? this.prescribedBy,
      reason: reason ?? this.reason,
      nextDoseTime: nextDoseTime ?? this.nextDoseTime,
      sideEffects: sideEffects ?? this.sideEffects,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}