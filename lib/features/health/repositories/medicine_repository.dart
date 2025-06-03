import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medicine_entry.dart';

class MedicineRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'medicines';

  MedicineRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Create
  Future<MedicineEntry> createEntry(MedicineEntry entry) async {
    try {
      final docRef = await _firestore.collection(_collection).add(entry.toMap());
      return entry.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to create medicine entry: $e');
    }
  }

  // Read
  Future<List<MedicineEntry>> getEntriesByBabyId(String babyId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('babyId', isEqualTo: babyId)
          .orderBy('givenAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return MedicineEntry.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch medicine entries: $e');
    }
  }

  // Update
  Future<MedicineEntry> updateEntry(MedicineEntry entry) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(entry.id)
          .update(entry.toMap());
      return entry;
    } catch (e) {
      throw Exception('Failed to update medicine entry: $e');
    }
  }

  // Delete
  Future<void> deleteEntry(String entryId) async {
    try {
      await _firestore.collection(_collection).doc(entryId).delete();
    } catch (e) {
      throw Exception('Failed to delete medicine entry: $e');
    }
  }

  // Stream of entries
  Stream<List<MedicineEntry>> streamEntriesByBabyId(String babyId) {
    return _firestore
        .collection(_collection)
        .where('babyId', isEqualTo: babyId)
        .orderBy('givenAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MedicineEntry.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}