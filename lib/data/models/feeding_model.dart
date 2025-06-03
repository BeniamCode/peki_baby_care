import 'package:cloud_firestore/cloud_firestore.dart';

enum FeedingType { breast, bottle, solid }
enum BreastSide { left, right, both }

class FeedingModel {
  final String id;
  final String babyId;
  final FeedingType type;
  final DateTime startTime;
  final DateTime? endTime;
  final int? duration; // in minutes
  final double? amount; // in ml for bottle, grams for solid
  final BreastSide? breastSide; // for breastfeeding
  final String? foodType; // for solid food
  final String? notes;
  final DateTime createdAt;
  final String createdBy;

  FeedingModel({
    required this.id,
    required this.babyId,
    required this.type,
    required this.startTime,
    this.endTime,
    this.duration,
    this.amount,
    this.breastSide,
    this.foodType,
    this.notes,
    required this.createdAt,
    required this.createdBy,
  });

  factory FeedingModel.fromMap(Map<String, dynamic> map, String id) {
    return FeedingModel(
      id: id,
      babyId: map['babyId'] ?? '',
      type: FeedingType.values.firstWhere(
        (t) => t.toString().split('.').last == map['type'],
        orElse: () => FeedingType.bottle,
      ),
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: map['endTime'] != null ? (map['endTime'] as Timestamp).toDate() : null,
      duration: map['duration'],
      amount: map['amount']?.toDouble(),
      breastSide: map['breastSide'] != null
          ? BreastSide.values.firstWhere(
              (s) => s.toString().split('.').last == map['breastSide'],
              orElse: () => BreastSide.both,
            )
          : null,
      foodType: map['foodType'],
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      createdBy: map['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'babyId': babyId,
      'type': type.toString().split('.').last,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'duration': duration,
      'amount': amount,
      'breastSide': breastSide?.toString().split('.').last,
      'foodType': foodType,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }

  FeedingModel copyWith({
    String? id,
    String? babyId,
    FeedingType? type,
    DateTime? startTime,
    DateTime? endTime,
    int? duration,
    double? amount,
    BreastSide? breastSide,
    String? foodType,
    String? notes,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return FeedingModel(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      type: type ?? this.type,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      amount: amount ?? this.amount,
      breastSide: breastSide ?? this.breastSide,
      foodType: foodType ?? this.foodType,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}