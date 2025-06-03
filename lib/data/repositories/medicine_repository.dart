import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medicine_model.dart';

class MedicineRepository {
  static final MedicineRepository _instance = MedicineRepository._internal();
  factory MedicineRepository() => _instance;
  MedicineRepository._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'medicines';

  Future<void> addMedicine(Medicine medicine) async {
    try {
      await _firestore.collection(_collection).add(medicine.toJson());
    } catch (e) {
      throw Exception('Failed to add medicine: $e');
    }
  }

  Stream<List<Medicine>> getMedicinesStream(String babyId) {
    return _firestore
        .collection(_collection)
        .where('babyId', isEqualTo: babyId)
        .orderBy('administeredAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Medicine.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  Future<List<Medicine>> getMedicinesByDateRange(
    String babyId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('babyId', isEqualTo: babyId)
          .where('administeredAt', isGreaterThanOrEqualTo: startDate)
          .where('administeredAt', isLessThanOrEqualTo: endDate)
          .orderBy('administeredAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Medicine.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to get medicines: $e');
    }
  }

  Future<Medicine?> getLastMedicine(String babyId, {String? medicineName}) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('babyId', isEqualTo: babyId);

      if (medicineName != null) {
        query = query.where('name', isEqualTo: medicineName);
      }

      final snapshot = await query
          .orderBy('administeredAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return Medicine.fromJson({
        ...snapshot.docs.first.data() as Map<String, dynamic>,
        'id': snapshot.docs.first.id,
      });
    } catch (e) {
      throw Exception('Failed to get last medicine: $e');
    }
  }

  Future<List<Medicine>> getUpcomingMedicines(String babyId) async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection(_collection)
          .where('babyId', isEqualTo: babyId)
          .where('nextDoseTime', isGreaterThan: now)
          .orderBy('nextDoseTime')
          .limit(5)
          .get();

      return snapshot.docs
          .map((doc) => Medicine.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to get upcoming medicines: $e');
    }
  }

  Future<void> updateMedicine(String medicineId, Medicine medicine) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(medicineId)
          .update(medicine.toJson());
    } catch (e) {
      throw Exception('Failed to update medicine: $e');
    }
  }

  Future<void> deleteMedicine(String medicineId) async {
    try {
      await _firestore.collection(_collection).doc(medicineId).delete();
    } catch (e) {
      throw Exception('Failed to delete medicine: $e');
    }
  }
}