import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/note_entry.dart';

class NoteRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  static const String _collection = 'notes';

  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  // Get entries by baby ID
  Future<List<NoteEntry>> getEntriesByBabyId(String babyId) async {
    try {
      if (_userId == null) throw Exception('User not authenticated');
      
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('babyId', isEqualTo: babyId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => NoteEntry.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch notes: $e');
    }
  }

  // Create entry
  Future<NoteEntry> createEntry(NoteEntry entry) async {
    try {
      if (_userId == null) throw Exception('User not authenticated');
      
      final docRef = await _firestore
          .collection(_collection)
          .add(entry.toMap());
      
      return entry.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to create note: $e');
    }
  }

  // Update entry
  Future<NoteEntry> updateEntry(NoteEntry entry) async {
    try {
      if (_userId == null) throw Exception('User not authenticated');
      
      await _firestore
          .collection(_collection)
          .doc(entry.id)
          .update(entry.toMap());
      
      return entry;
    } catch (e) {
      throw Exception('Failed to update note: $e');
    }
  }

  // Delete entry
  Future<void> deleteEntry(String entryId) async {
    try {
      if (_userId == null) throw Exception('User not authenticated');
      
      await _firestore
          .collection(_collection)
          .doc(entryId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }

  // Stream entries by baby ID
  Stream<List<NoteEntry>> streamEntriesByBabyId(String babyId) {
    if (_userId == null) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection(_collection)
        .where('babyId', isEqualTo: babyId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NoteEntry.fromMap(doc.data(), doc.id))
            .toList());
  }
}