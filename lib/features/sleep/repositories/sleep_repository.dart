import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sleep_entry.dart';

class SleepRepository {
  final FirebaseFirestore _firestore;
  static const String _collection = 'sleep_entries';

  SleepRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Get all entries for a baby
  Future<List<SleepEntry>> getEntriesByBabyId(String babyId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('babyId', isEqualTo: babyId)
          .orderBy('startTime', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SleepEntry.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch sleep entries: $e');
    }
  }

  // Get entries for a specific date range
  Future<List<SleepEntry>> getEntriesByDateRange(
    String babyId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('babyId', isEqualTo: babyId)
          .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('startTime', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SleepEntry.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch sleep entries by date range: $e');
    }
  }

  // Create a new entry
  Future<SleepEntry> createEntry(SleepEntry entry) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(entry.toMap());

      return entry.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to create sleep entry: $e');
    }
  }

  // Update an existing entry
  Future<SleepEntry> updateEntry(SleepEntry entry) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(entry.id)
          .update(entry.toMap());

      return entry;
    } catch (e) {
      throw Exception('Failed to update sleep entry: $e');
    }
  }

  // Delete an entry
  Future<void> deleteEntry(String entryId) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(entryId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete sleep entry: $e');
    }
  }

  // Get active sleep session for a baby
  Future<SleepEntry?> getActiveSleepSession(String babyId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('babyId', isEqualTo: babyId)
          .where('endTime', isNull: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final doc = querySnapshot.docs.first;
      return SleepEntry.fromMap(doc.data(), doc.id);
    } catch (e) {
      throw Exception('Failed to fetch active sleep session: $e');
    }
  }

  // Stream of entries for real-time updates
  Stream<List<SleepEntry>> streamEntriesByBabyId(String babyId) {
    return _firestore
        .collection(_collection)
        .where('babyId', isEqualTo: babyId)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SleepEntry.fromMap(doc.data(), doc.id))
            .toList());
  }
}