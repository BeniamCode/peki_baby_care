import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/sleep/models/sleep_entry.dart';

class SleepRepository {
  static final SleepRepository _instance = SleepRepository._internal();
  factory SleepRepository() => _instance;
  SleepRepository._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'sleeps';

  Future<void> addSleep(SleepEntry sleep) async {
    try {
      await _firestore.collection(_collection).add(sleep.toJson());
    } catch (e) {
      throw Exception('Failed to add sleep: $e');
    }
  }

  Stream<List<SleepEntry>> getSleepsStream(String babyId) {
    return _firestore
        .collection(_collection)
        .where('babyId', isEqualTo: babyId)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SleepEntry.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  Future<List<SleepEntry>> getSleepsByDateRange(
    String babyId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('babyId', isEqualTo: babyId)
          .where('startTime', isGreaterThanOrEqualTo: startDate)
          .where('startTime', isLessThanOrEqualTo: endDate)
          .orderBy('startTime', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => SleepEntry.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to get sleeps: $e');
    }
  }

  Future<SleepEntry?> getLastSleep(String babyId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('babyId', isEqualTo: babyId)
          .orderBy('startTime', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return SleepEntry.fromJson({
        ...snapshot.docs.first.data(),
        'id': snapshot.docs.first.id,
      });
    } catch (e) {
      throw Exception('Failed to get last sleep: $e');
    }
  }

  Future<Map<String, dynamic>> getSleepSummary(
    String babyId,
    DateTime date,
  ) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final sleeps = await getSleepsByDateRange(babyId, startOfDay, endOfDay);

      int totalMinutes = 0;
      int napCount = 0;
      int nightSleepMinutes = 0;

      for (final sleep in sleeps) {
        if (sleep.endTime != null) {
          final duration = sleep.endTime!.difference(sleep.startTime).inMinutes;
          totalMinutes += duration;

          if (sleep.type == SleepType.nap) {
            napCount++;
          } else {
            nightSleepMinutes += duration;
          }
        }
      }

      return {
        'totalHours': totalMinutes / 60,
        'napCount': napCount,
        'nightHours': nightSleepMinutes / 60,
        'dayHours': (totalMinutes - nightSleepMinutes) / 60,
      };
    } catch (e) {
      throw Exception('Failed to get sleep summary: $e');
    }
  }

  Future<void> updateSleep(String sleepId, SleepEntry sleep) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(sleepId)
          .update(sleep.toJson());
    } catch (e) {
      throw Exception('Failed to update sleep: $e');
    }
  }

  Future<void> deleteSleep(String sleepId) async {
    try {
      await _firestore.collection(_collection).doc(sleepId).delete();
    } catch (e) {
      throw Exception('Failed to delete sleep: $e');
    }
  }
}