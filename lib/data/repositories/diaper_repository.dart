import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/diaper_model.dart';

class DiaperRepository {
  static final DiaperRepository _instance = DiaperRepository._internal();
  factory DiaperRepository() => _instance;
  DiaperRepository._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'diapers';

  Future<void> addDiaper(Diaper diaper) async {
    try {
      await _firestore.collection(_collection).add(diaper.toJson());
    } catch (e) {
      throw Exception('Failed to add diaper: $e');
    }
  }

  Stream<List<Diaper>> getDiapersStream(String babyId) {
    return _firestore
        .collection(_collection)
        .where('babyId', isEqualTo: babyId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Diaper.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  Future<List<Diaper>> getDiapersByDateRange(
    String babyId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('babyId', isEqualTo: babyId)
          .where('timestamp', isGreaterThanOrEqualTo: startDate)
          .where('timestamp', isLessThanOrEqualTo: endDate)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Diaper.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to get diapers: $e');
    }
  }

  Future<Diaper?> getLastDiaper(String babyId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('babyId', isEqualTo: babyId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return Diaper.fromJson({
        ...snapshot.docs.first.data(),
        'id': snapshot.docs.first.id,
      });
    } catch (e) {
      throw Exception('Failed to get last diaper: $e');
    }
  }

  Future<Map<String, int>> getDiaperSummary(
    String babyId,
    DateTime date,
  ) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final diapers = await getDiapersByDateRange(babyId, startOfDay, endOfDay);

      int wetCount = 0;
      int dirtyCount = 0;
      int mixedCount = 0;

      for (final diaper in diapers) {
        switch (diaper.type) {
          case DiaperType.wet:
            wetCount++;
            break;
          case DiaperType.dirty:
            dirtyCount++;
            break;
          case DiaperType.mixed:
            mixedCount++;
            break;
        }
      }

      return {
        'wet': wetCount,
        'dirty': dirtyCount,
        'mixed': mixedCount,
        'total': wetCount + dirtyCount + mixedCount,
      };
    } catch (e) {
      throw Exception('Failed to get diaper summary: $e');
    }
  }

  Future<void> updateDiaper(String diaperId, Diaper diaper) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(diaperId)
          .update(diaper.toJson());
    } catch (e) {
      throw Exception('Failed to update diaper: $e');
    }
  }

  Future<void> deleteDiaper(String diaperId) async {
    try {
      await _firestore.collection(_collection).doc(diaperId).delete();
    } catch (e) {
      throw Exception('Failed to delete diaper: $e');
    }
  }
}