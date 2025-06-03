import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/feeding_model.dart';

class FeedingRepository {
  static final FeedingRepository _instance = FeedingRepository._internal();
  factory FeedingRepository() => _instance;
  FeedingRepository._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'feedings';

  Future<void> addFeeding(FeedingModel feeding) async {
    try {
      await _firestore.collection(_collection).add(feeding.toJson());
    } catch (e) {
      throw Exception('Failed to add feeding: $e');
    }
  }

  Stream<List<FeedingModel>> getFeedingsStream(String babyId) {
    return _firestore
        .collection(_collection)
        .where('babyId', isEqualTo: babyId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FeedingModel.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  Future<List<FeedingModel>> getFeedingsByDateRange(
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
          .map((doc) => FeedingModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to get feedings: $e');
    }
  }

  Future<FeedingModel?> getLastFeeding(String babyId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('babyId', isEqualTo: babyId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return FeedingModel.fromJson({
        ...snapshot.docs.first.data(),
        'id': snapshot.docs.first.id,
      });
    } catch (e) {
      throw Exception('Failed to get last feeding: $e');
    }
  }

  Future<void> updateFeeding(String feedingId, FeedingModel feeding) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(feedingId)
          .update(feeding.toJson());
    } catch (e) {
      throw Exception('Failed to update feeding: $e');
    }
  }

  Future<void> deleteFeeding(String feedingId) async {
    try {
      await _firestore.collection(_collection).doc(feedingId).delete();
    } catch (e) {
      throw Exception('Failed to delete feeding: $e');
    }
  }
}