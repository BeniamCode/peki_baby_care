import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:peki_baby_care/data/datasources/firebase_service.dart';
import 'package:peki_baby_care/data/models/baby_model.dart';

class BabyRepository {
  final FirebaseService _firebaseService = FirebaseService();
  static const String _collection = 'babies';

  // Create a new baby
  Future<String> createBaby(BabyModel baby) async {
    try {
      final userId = _firebaseService.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      // Create a new baby with the current user as parent
      final babyData = baby.toMap();
      babyData['parentIds'] = [userId];
      
      final docRef = await _firebaseService.addDocument(
        _collection,
        babyData,
      );
      
      // Update user's babyIds
      await _firebaseService.updateDocument(
        'users',
        userId,
        {
          'babyIds': FieldValue.arrayUnion([docRef.id]),
          'lastLogin': FieldValue.serverTimestamp(),
        },
      );
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create baby: $e');
    }
  }

  // Get all babies for current user
  Stream<List<BabyModel>> getBabiesStream() {
    final userId = _firebaseService.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firebaseService.getCollectionStream(
      _collection,
      queryBuilder: (query) => query
          .where('parentIds', arrayContains: userId)
          .orderBy('createdAt', descending: true),
    ).map((snapshot) {
      return snapshot.docs.map((doc) {
        return BabyModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Get a single baby
  Future<BabyModel?> getBaby(String babyId) async {
    try {
      final doc = await _firebaseService.getDocument(_collection, babyId);
      if (doc.exists && doc.data() != null) {
        return BabyModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get baby: $e');
    }
  }

  // Update baby
  Future<void> updateBaby(String babyId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _firebaseService.updateDocument(_collection, babyId, updates);
    } catch (e) {
      throw Exception('Failed to update baby: $e');
    }
  }

  // Delete baby
  Future<void> deleteBaby(String babyId) async {
    try {
      // First, remove babyId from user's babyIds
      final userId = _firebaseService.currentUser?.uid;
      if (userId != null) {
        await _firebaseService.updateDocument(
          'users',
          userId,
          {
            'babyIds': FieldValue.arrayRemove([babyId]),
            'updatedAt': FieldValue.serverTimestamp(),
          },
        );
      }
      
      // Delete all related data (feedings, sleep, diapers, etc.)
      await _deleteRelatedData(babyId);
      
      // Finally, delete the baby document
      await _firebaseService.deleteDocument(_collection, babyId);
    } catch (e) {
      throw Exception('Failed to delete baby: $e');
    }
  }

  // Delete all related data for a baby
  Future<void> _deleteRelatedData(String babyId) async {
    final batch = _firebaseService.firestore.batch();
    
    // Delete feedings
    final feedings = await _firebaseService.firestore
        .collection('feedings')
        .where('babyId', isEqualTo: babyId)
        .get();
    for (final doc in feedings.docs) {
      batch.delete(doc.reference);
    }
    
    // Delete sleep records
    final sleeps = await _firebaseService.firestore
        .collection('sleeps')
        .where('babyId', isEqualTo: babyId)
        .get();
    for (final doc in sleeps.docs) {
      batch.delete(doc.reference);
    }
    
    // Delete diaper records
    final diapers = await _firebaseService.firestore
        .collection('diapers')
        .where('babyId', isEqualTo: babyId)
        .get();
    for (final doc in diapers.docs) {
      batch.delete(doc.reference);
    }
    
    // Delete medicine records
    final medicines = await _firebaseService.firestore
        .collection('medicines')
        .where('babyId', isEqualTo: babyId)
        .get();
    for (final doc in medicines.docs) {
      batch.delete(doc.reference);
    }
    
    // Delete notes
    final notes = await _firebaseService.firestore
        .collection('notes')
        .where('babyId', isEqualTo: babyId)
        .get();
    for (final doc in notes.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
  }

  // Upload baby photo
  Future<String> uploadBabyPhoto(String babyId, dynamic imageFile) async {
    try {
      final path = 'babies/$babyId/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final downloadUrl = await _firebaseService.uploadFile(path, imageFile);
      
      // Update baby's photoUrl
      await updateBaby(babyId, {'photoUrl': downloadUrl});
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload photo: $e');
    }
  }
}