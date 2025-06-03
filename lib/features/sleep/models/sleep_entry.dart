import 'package:cloud_firestore/cloud_firestore.dart';

enum SleepType { nap, night }

class SleepEntry {
  final String id;
  final String babyId;
  final DateTime startTime;
  final DateTime? endTime;
  final SleepType sleepType;
  final String? notes;
  final DateTime createdAt;

  SleepEntry({
    required this.id,
    required this.babyId,
    required this.startTime,
    this.endTime,
    SleepType? sleepType,
    this.notes,
    DateTime? createdAt,
  })  : sleepType = sleepType ?? _determineSleepType(startTime),
        createdAt = createdAt ?? DateTime.now();

  // Determine sleep type based on time of day
  static SleepType _determineSleepType(DateTime startTime) {
    final hour = startTime.hour;
    // Night sleep typically starts after 6 PM or before 6 AM
    return (hour >= 18 || hour < 6) ? SleepType.night : SleepType.nap;
  }

  // Calculate duration
  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  // Check if sleep is active
  bool get isActive => endTime == null;

  // Get formatted duration string
  String get durationString {
    if (duration == null) return 'Ongoing';
    final hours = duration!.inHours;
    final minutes = duration!.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  // Get sleep type display string
  String get sleepTypeDisplay => sleepType == SleepType.night ? 'Night Sleep' : 'Nap';

  // Create from Firestore document
  factory SleepEntry.fromMap(Map<String, dynamic> map, String id) {
    return SleepEntry(
      id: id,
      babyId: map['babyId'] ?? '',
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: map['endTime'] != null ? (map['endTime'] as Timestamp).toDate() : null,
      sleepType: map['sleepType'] != null
          ? SleepType.values.firstWhere(
              (type) => type.toString().split('.').last == map['sleepType'],
              orElse: () => _determineSleepType((map['startTime'] as Timestamp).toDate()),
            )
          : null,
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'babyId': babyId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'sleepType': sleepType.toString().split('.').last,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Copy with method
  SleepEntry copyWith({
    String? id,
    String? babyId,
    DateTime? startTime,
    DateTime? endTime,
    SleepType? sleepType,
    String? notes,
    DateTime? createdAt,
  }) {
    return SleepEntry(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      sleepType: sleepType ?? this.sleepType,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'SleepEntry(id: $id, startTime: $startTime, endTime: $endTime, type: $sleepType)';
  }
}