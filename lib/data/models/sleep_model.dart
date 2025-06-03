import 'package:cloud_firestore/cloud_firestore.dart';

enum SleepQuality { excellent, good, fair, poor }

class SleepModel {
  final String id;
  final String babyId;
  final DateTime startTime;
  final DateTime? endTime;
  final int? duration; // in minutes
  final SleepQuality? quality;
  final bool isNap;
  final String? location; // crib, bassinet, stroller, etc.
  final String? notes;
  final DateTime createdAt;
  final String createdBy;

  SleepModel({
    required this.id,
    required this.babyId,
    required this.startTime,
    this.endTime,
    this.duration,
    this.quality,
    required this.isNap,
    this.location,
    this.notes,
    required this.createdAt,
    required this.createdBy,
  });

  factory SleepModel.fromMap(Map<String, dynamic> map, String id) {
    return SleepModel(
      id: id,
      babyId: map['babyId'] ?? '',
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: map['endTime'] != null ? (map['endTime'] as Timestamp).toDate() : null,
      duration: map['duration'],
      quality: map['quality'] != null
          ? SleepQuality.values.firstWhere(
              (q) => q.toString().split('.').last == map['quality'],
              orElse: () => SleepQuality.good,
            )
          : null,
      isNap: map['isNap'] ?? false,
      location: map['location'],
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      createdBy: map['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'babyId': babyId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'duration': duration,
      'quality': quality?.toString().split('.').last,
      'isNap': isNap,
      'location': location,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }

  SleepModel copyWith({
    String? id,
    String? babyId,
    DateTime? startTime,
    DateTime? endTime,
    int? duration,
    SleepQuality? quality,
    bool? isNap,
    String? location,
    String? notes,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return SleepModel(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      quality: quality ?? this.quality,
      isNap: isNap ?? this.isNap,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}