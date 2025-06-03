import 'package:flutter/foundation.dart';
import '../models/medicine_entry.dart';
import '../repositories/medicine_repository.dart';

class MedicineProvider extends ChangeNotifier {
  final MedicineRepository _repository;
  
  List<MedicineEntry> _entries = [];
  bool _isLoading = false;
  String? _error;
  String? _currentBabyId;

  MedicineProvider({required MedicineRepository repository})
      : _repository = repository;

  // Getters
  List<MedicineEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentBabyId => _currentBabyId;

  // Get today's entries
  List<MedicineEntry> get todayEntries {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _entries.where((entry) {
      final entryDate = DateTime(
        entry.givenAt.year,
        entry.givenAt.month,
        entry.givenAt.day,
      );
      return entryDate.isAtSameMomentAs(today);
    }).toList();
  }

  // Method wrappers for dashboard compatibility
  List<MedicineEntry> getTodayMedicines() => todayEntries;
  List<MedicineEntry> getUpcomingDoses() => _entries.where((e) => e.givenAt.isAfter(DateTime.now())).toList();

  // Get active medications (not completed)
  List<MedicineEntry> get activeMedications {
    return _entries.where((entry) => !entry.isCompleted).toList();
  }

  // Get upcoming doses
  List<MedicineEntry> get upcomingDoses {
    final now = DateTime.now();
    return _entries.where((entry) {
      if (entry.isCompleted) return false;
      if (entry.nextDoseTime == null) return false;
      return entry.nextDoseTime!.isAfter(now);
    }).toList()
      ..sort((a, b) => (a.nextDoseTime ?? now).compareTo(b.nextDoseTime ?? now));
  }

  // Get overdue doses
  List<MedicineEntry> get overdueDoses {
    final now = DateTime.now();
    return _entries.where((entry) {
      if (entry.isCompleted) return false;
      if (entry.nextDoseTime == null) return false;
      return entry.nextDoseTime!.isBefore(now);
    }).toList();
  }

  // Set current baby
  void setCurrentBaby(String babyId) {
    if (_currentBabyId != babyId) {
      _currentBabyId = babyId;
      fetchEntries();
    }
  }

  // Fetch entries
  Future<void> fetchEntries() async {
    if (_currentBabyId == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _entries = await _repository.getEntriesByBabyId(_currentBabyId!);
      _entries.sort((a, b) => b.givenAt.compareTo(a.givenAt));
    } catch (e) {
      _error = 'Failed to load medicine entries. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add entry
  Future<void> addEntry(MedicineEntry entry) async {
    if (_currentBabyId == null) return;

    _error = null;
    notifyListeners();

    try {
      final newEntry = entry.copyWith(babyId: _currentBabyId);
      final savedEntry = await _repository.createEntry(newEntry);
      _entries.insert(0, savedEntry);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add medicine entry. Please try again.';
      notifyListeners();
      rethrow;
    }
  }

  // Update entry
  Future<void> updateEntry(MedicineEntry entry) async {
    _error = null;
    notifyListeners();

    try {
      final updatedEntry = await _repository.updateEntry(entry);
      final index = _entries.indexWhere((e) => e.id == entry.id);
      if (index != -1) {
        _entries[index] = updatedEntry;
        _entries.sort((a, b) => b.givenAt.compareTo(a.givenAt));
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update medicine entry. Please try again.';
      notifyListeners();
      rethrow;
    }
  }

  // Mark as given (record next dose)
  Future<void> markAsGiven(String entryId) async {
    _error = null;
    notifyListeners();

    try {
      final entry = _entries.firstWhere((e) => e.id == entryId);
      
      // Calculate next dose time if applicable
      DateTime? nextDoseTime;
      if (entry.frequency != null && !entry.isCompleted) {
        switch (entry.frequency) {
          case MedicineFrequency.asNeeded:
            nextDoseTime = null;
            break;
          case MedicineFrequency.once:
            nextDoseTime = null;
            break;
          case MedicineFrequency.twice:
            nextDoseTime = DateTime.now().add(const Duration(hours: 12));
            break;
          case MedicineFrequency.thrice:
            nextDoseTime = DateTime.now().add(const Duration(hours: 8));
            break;
          case MedicineFrequency.fourTimes:
            nextDoseTime = DateTime.now().add(const Duration(hours: 6));
            break;
          case MedicineFrequency.every4Hours:
            nextDoseTime = DateTime.now().add(const Duration(hours: 4));
            break;
          case MedicineFrequency.every6Hours:
            nextDoseTime = DateTime.now().add(const Duration(hours: 6));
            break;
          case MedicineFrequency.every8Hours:
            nextDoseTime = DateTime.now().add(const Duration(hours: 8));
            break;
          case MedicineFrequency.every12Hours:
            nextDoseTime = DateTime.now().add(const Duration(hours: 12));
            break;
          default:
            nextDoseTime = null;
        }
      }

      final updatedEntry = entry.copyWith(
        givenAt: DateTime.now(),
        nextDoseTime: nextDoseTime,
      );
      
      await updateEntry(updatedEntry);
    } catch (e) {
      _error = 'Failed to mark medicine as given. Please try again.';
      notifyListeners();
      rethrow;
    }
  }

  // Complete medication course
  Future<void> completeMedication(String entryId) async {
    _error = null;
    notifyListeners();

    try {
      final entry = _entries.firstWhere((e) => e.id == entryId);
      final updatedEntry = entry.copyWith(
        isCompleted: true,
        nextDoseTime: null,
      );
      
      await updateEntry(updatedEntry);
    } catch (e) {
      _error = 'Failed to complete medication. Please try again.';
      notifyListeners();
      rethrow;
    }
  }

  // Delete entry
  Future<void> deleteEntry(String entryId) async {
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteEntry(entryId);
      _entries.removeWhere((e) => e.id == entryId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete medicine entry. Please try again.';
      notifyListeners();
      rethrow;
    }
  }

  // Get medication history
  Map<String, List<MedicineEntry>> getMedicationHistory() {
    final history = <String, List<MedicineEntry>>{};
    
    for (final entry in _entries) {
      final name = entry.medicineName.toLowerCase();
      if (!history.containsKey(name)) {
        history[name] = [];
      }
      history[name]!.add(entry);
    }
    
    // Sort each medication's history by date
    history.forEach((key, value) {
      value.sort((a, b) => b.givenAt.compareTo(a.givenAt));
    });
    
    return history;
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    final weekEntries = _entries.where((entry) {
      return entry.givenAt.isAfter(weekAgo);
    }).toList();

    // Count by type
    final typeCount = <MedicineType, int>{};
    for (final entry in weekEntries) {
      typeCount[entry.type] = (typeCount[entry.type] ?? 0) + 1;
    }

    // Get unique medications
    final uniqueMedications = <String>{};
    for (final entry in _entries) {
      uniqueMedications.add(entry.medicineName.toLowerCase());
    }

    return {
      'totalDosesThisWeek': weekEntries.length,
      'activeMedications': activeMedications.length,
      'overdueDoses': overdueDoses.length,
      'upcomingDoses': upcomingDoses.length,
      'typeBreakdown': typeCount,
      'uniqueMedications': uniqueMedications.length,
    };
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Reset provider
  void reset() {
    _entries.clear();
    _isLoading = false;
    _error = null;
    _currentBabyId = null;
    notifyListeners();
  }
}