import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/notes/models/note_entry.dart';

class NoteRepository {
  static final NoteRepository _instance = NoteRepository._internal();
  factory NoteRepository() => _instance;
  NoteRepository._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'notes';

  Future<void> addNote(NoteEntry note) async {
    try {
      await _firestore.collection(_collection).add(note.toJson());
    } catch (e) {
      throw Exception('Failed to add note: $e');
    }
  }

  Stream<List<NoteEntry>> getNotesStream(String babyId) {
    return _firestore
        .collection(_collection)
        .where('babyId', isEqualTo: babyId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NoteEntry.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  Future<List<NoteEntry>> getNotesByDateRange(
    String babyId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('babyId', isEqualTo: babyId)
          .where('createdAt', isGreaterThanOrEqualTo: startDate)
          .where('createdAt', isLessThanOrEqualTo: endDate)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => NoteEntry.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to get notes: $e');
    }
  }

  Future<List<NoteEntry>> searchNotes(String babyId, String searchTerm) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('babyId', isEqualTo: babyId)
          .orderBy('createdAt', descending: true)
          .get();

      final searchLower = searchTerm.toLowerCase();
      
      return snapshot.docs
          .map((doc) => NoteEntry.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .where((note) =>
              note.content.toLowerCase().contains(searchLower) ||
              note.tags.any((tag) => tag.toLowerCase().contains(searchLower)))
          .toList();
    } catch (e) {
      throw Exception('Failed to search notes: $e');
    }
  }

  Future<void> updateNote(String noteId, NoteEntry note) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(noteId)
          .update(note.toJson());
    } catch (e) {
      throw Exception('Failed to update note: $e');
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await _firestore.collection(_collection).doc(noteId).delete();
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }
}