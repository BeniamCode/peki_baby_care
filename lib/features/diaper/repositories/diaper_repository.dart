import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/diaper_entry.dart';

class DiaperRepository {
  final FirebaseFirestore _firestore;
  static const String _collection = 'diaper_entries';

  DiaperRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Add new diaper entry
  Future<String> addEntry(DiaperEntry entry) async {
    try {
      final docRef = await _firestore.collection(_collection).add(entry.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add diaper entry: $e');
    }
  }

  // Update existing diaper entry
  Future<void> updateEntry(DiaperEntry entry) async {
    try {
      final updatedEntry = entry.copyWith(updatedAt: DateTime.now());
      await _firestore
          .collection(_collection)
          .doc(entry.id)
          .update(updatedEntry.toFirestore());
    } catch (e) {
      throw Exception('Failed to update diaper entry: $e');
    }
  }

  // Delete diaper entry
  Future<void> deleteEntry(String entryId) async {
    try {
      await _firestore.collection(_collection).doc(entryId).delete();
    } catch (e) {
      throw Exception('Failed to delete diaper entry: $e');
    }
  }

  // Get all entries for a baby
  Future<List<DiaperEntry>> getEntriesForBaby(String babyId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('babyId', isEqualTo: babyId)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => DiaperEntry.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get diaper entries: $e');
    }
  }

  // Get entries for a baby within a date range
  Future<List<DiaperEntry>> getEntriesForBabyInRange(
    String babyId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('babyId', isEqualTo: babyId)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => DiaperEntry.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get diaper entries for date range: $e');
    }
  }

  // Get entries for today
  Future<List<DiaperEntry>> getTodayEntriesForBaby(String babyId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return getEntriesForBabyInRange(babyId, startOfDay, endOfDay);
  }

  // Get the last entry for a baby
  Future<DiaperEntry?> getLastEntryForBaby(String babyId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('babyId', isEqualTo: babyId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return DiaperEntry.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      throw Exception('Failed to get last diaper entry: $e');
    }
  }

  // Stream entries for a baby (real-time updates)
  Stream<List<DiaperEntry>> streamEntriesForBaby(String babyId) {
    return _firestore
        .collection(_collection)
        .where('babyId', isEqualTo: babyId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DiaperEntry.fromFirestore(doc))
            .toList());
  }

  // Stream today's entries for a baby
  Stream<List<DiaperEntry>> streamTodayEntriesForBaby(String babyId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return _firestore
        .collection(_collection)
        .where('babyId', isEqualTo: babyId)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DiaperEntry.fromFirestore(doc))
            .toList());
  }

  // Get statistics for a baby within a date range
  Future<Map<String, dynamic>> getStatistics(
    String babyId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final entries = await getEntriesForBabyInRange(babyId, startDate, endDate);

    final totalChanges = entries.length;
    final wetChanges = entries.where((e) => e.type == DiaperType.wet).length;
    final dirtyChanges = entries.where((e) => e.type == DiaperType.dirty).length;
    final mixedChanges = entries.where((e) => e.type == DiaperType.mixed).length;
    final dryChanges = entries.where((e) => e.type == DiaperType.dry).length;

    // Calculate average daily changes
    final daysDifference = endDate.difference(startDate).inDays + 1;
    final averageDailyChanges = totalChanges / daysDifference;

    // Calculate most common type
    final typeCounts = {
      'wet': wetChanges,
      'dirty': dirtyChanges,
      'mixed': mixedChanges,
      'dry': dryChanges,
    };
    final mostCommonType = typeCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    return {
      'totalChanges': totalChanges,
      'wetChanges': wetChanges,
      'dirtyChanges': dirtyChanges,
      'mixedChanges': mixedChanges,
      'dryChanges': dryChanges,
      'averageDailyChanges': averageDailyChanges,
      'mostCommonType': mostCommonType,
      'dateRange': {
        'start': startDate.toIso8601String(),
        'end': endDate.toIso8601String(),
      },
    };
  }
}
