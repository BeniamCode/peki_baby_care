import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/feeding/models/feeding_entry.dart';
import '../datasources/firebase_service.dart';

class FeedingRepository {
  final FirebaseService _firebaseService = FirebaseService();
  static const String _collection = 'feedings';

  // Create a new feeding entry
  Future<String> addFeeding(FeedingModel feeding) async {
    try {
      final userId = _firebaseService.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final feedingData = feeding.toMap();
      feedingData['createdBy'] = userId;
      
      final docRef = await _firebaseService.addDocument(
        _collection,
        feedingData,
      );
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add feeding: $e');
    }
  }

  Stream<List<FeedingModel>> getFeedingsStream(String babyId) {
    return _firebaseService.getCollectionStream(
      _collection,
      queryBuilder: (query) => query
          .where('babyId', isEqualTo: babyId)
          .orderBy('startTime', descending: true),
    ).map((snapshot) {
      return snapshot.docs.map((doc) {
        return FeedingModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<List<FeedingModel>> getFeedingsByDateRange(
    String babyId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _firebaseService.firestore
          .collection(_collection)
          .where('babyId', isEqualTo: babyId)
          .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('startTime', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FeedingModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get feedings: $e');
    }
  }

  Future<FeedingModel?> getLastFeeding(String babyId) async {
    try {
      final snapshot = await _firebaseService.firestore
          .collection(_collection)
          .where('babyId', isEqualTo: babyId)
          .orderBy('startTime', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return FeedingModel.fromMap(
        snapshot.docs.first.data(),
        snapshot.docs.first.id,
      );
    } catch (e) {
      throw Exception('Failed to get last feeding: $e');
    }
  }

  Future<void> updateFeeding(String feedingId, Map<String, dynamic> updates) async {
    try {
      await _firebaseService.updateDocument(_collection, feedingId, updates);
    } catch (e) {
      throw Exception('Failed to update feeding: $e');
    }
  }

  Future<void> deleteFeeding(String feedingId) async {
    try {
      await _firebaseService.deleteDocument(_collection, feedingId);
    } catch (e) {
      throw Exception('Failed to delete feeding: $e');
    }
  }
}