import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note_model.dart';

class NoteRepository {
  static final NoteRepository _instance = NoteRepository._internal();
  factory NoteRepository() => _instance;
  NoteRepository._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'notes';

  Future<void> addNote(Note note) async {
    try {
      await _firestore.collection(_collection).add(note.toJson());
    } catch (e) {
      throw Exception('Failed to add note: $e');
    }
  }

  Stream<List<Note>> getNotesStream(String babyId) {
    return _firestore
        .collection(_collection)
        .where('babyId', isEqualTo: babyId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Note.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  Future<List<Note>> getNotesByDateRange(
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
          .map((doc) => Note.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to get notes: $e');
    }
  }

  Future<List<Note>> searchNotes(String babyId, String searchTerm) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('babyId', isEqualTo: babyId)
          .orderBy('timestamp', descending: true)
          .get();

      final searchLower = searchTerm.toLowerCase();
      
      return snapshot.docs
          .map((doc) => Note.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .where((note) =>
              note.content.toLowerCase().contains(searchLower) ||
              (note.tags?.any((tag) => tag.toLowerCase().contains(searchLower)) ?? false))
          .toList();
    } catch (e) {
      throw Exception('Failed to search notes: $e');
    }
  }

  Future<void> updateNote(String noteId, Note note) async {
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