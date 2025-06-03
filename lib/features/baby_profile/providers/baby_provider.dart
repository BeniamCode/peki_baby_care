import 'package:flutter/material.dart';
import 'package:peki_baby_care/data/models/baby_model.dart';
import 'package:peki_baby_care/data/repositories/baby_repository.dart';

class BabyProvider extends ChangeNotifier {
  final BabyRepository _repository = BabyRepository();
  
  List<BabyModel> _babies = [];
  BabyModel? _selectedBaby;
  bool _isLoading = false;
  String? _error;
  
  List<BabyModel> get babies => _babies;
  BabyModel? get selectedBaby => _selectedBaby;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasBabies => _babies.isNotEmpty;
  
  BabyProvider() {
    loadBabies();
  }
  
  // Load babies from Firestore
  void loadBabies() {
    _repository.getBabiesStream().listen(
      (babies) {
        _babies = babies;
        _isLoading = false;
        _error = null;
        
        // If no selected baby and we have babies, select the first one
        if (_selectedBaby == null && babies.isNotEmpty) {
          _selectedBaby = babies.first;
        }
        
        // If selected baby was deleted or updated, update the reference
        if (_selectedBaby != null) {
          final updatedBaby = babies.firstWhere(
            (b) => b.id == _selectedBaby!.id,
            orElse: () => babies.isNotEmpty ? babies.first : _selectedBaby!,
          );
          _selectedBaby = updatedBaby;
        }
        
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }
  
  // Select a baby
  void selectBaby(BabyModel baby) {
    _selectedBaby = baby;
    notifyListeners();
  }
  
  // Create a new baby
  Future<String> createBaby({
    required String name,
    required DateTime dateOfBirth,
    required Gender gender,
    double? birthWeight,
    double? birthHeight,
    String? bloodType,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final baby = BabyModel(
        id: '', // Will be set by Firestore
        name: name,
        dateOfBirth: dateOfBirth,
        gender: gender,
        birthWeight: birthWeight,
        birthHeight: birthHeight,
        bloodType: bloodType,
        parentIds: [], // Will be set in repository
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final babyId = await _repository.createBaby(baby);
      return babyId;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Update baby
  Future<void> updateBaby(
    String babyId,
    Map<String, dynamic> updates,
  ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _repository.updateBaby(babyId, updates);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Delete baby
  Future<void> deleteBaby(String babyId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _repository.deleteBaby(babyId);
      
      // If we deleted the selected baby, select another one
      if (_selectedBaby?.id == babyId) {
        _selectedBaby = _babies.firstWhere(
          (b) => b.id != babyId,
          orElse: () => _babies.first,
        );
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Upload baby photo
  Future<String> uploadBabyPhoto(String babyId, dynamic imageFile) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final photoUrl = await _repository.uploadBabyPhoto(babyId, imageFile);
      return photoUrl;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}