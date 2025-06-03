import 'package:flutter/foundation.dart';
import '../../../data/models/feeding_model.dart';
import '../../../data/repositories/feeding_repository.dart';
import '../models/feeding_summary.dart';

class FeedingProvider extends ChangeNotifier {
  final FeedingRepository _repository;
  
  List<FeedingModel> _entries = [];
  bool _isLoading = false;
  String? _error;
  String? _currentBabyId;

  FeedingProvider({required FeedingRepository repository})
      : _repository = repository;

  // Getters
  List<FeedingModel> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentBabyId => _currentBabyId;

  // Get entries for today
  List<FeedingModel> get todayEntries {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _entries.where((entry) {
      final entryDate = DateTime(
        entry.startTime.year,
        entry.startTime.month,
        entry.startTime.day,
      );
      return entryDate.isAtSameMomentAs(today);
    }).toList();
  }

  // Get last feeding
  FeedingModel? get lastFeeding {
    if (_entries.isEmpty) return null;
    return _entries.reduce((a, b) => 
      a.startTime.isAfter(b.startTime) ? a : b
    );
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
      _entries = await _repository.getFeedingsByBabyId(_currentBabyId!);
      _entries.sort((a, b) => b.startTime.compareTo(a.startTime));
    } catch (e) {
      _error = 'Failed to load feeding entries. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add entry
  Future<void> addEntry(FeedingModel entry) async {
    if (_currentBabyId == null) return;

    _error = null;
    notifyListeners();

    try {
      final newEntry = entry.copyWith(babyId: _currentBabyId);
      final savedEntry = await _repository.addFeeding(newEntry);
      _entries.insert(0, savedEntry);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add feeding entry. Please try again.';
      notifyListeners();
      rethrow;
    }
  }

  // Update entry
  Future<void> updateEntry(FeedingModel entry) async {
    _error = null;
    notifyListeners();

    try {
      final updatedEntry = await _repository.updateFeeding(entry);
      final index = _entries.indexWhere((e) => e.id == entry.id);
      if (index != -1) {
        _entries[index] = updatedEntry;
        _entries.sort((a, b) => b.startTime.compareTo(a.startTime));
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update feeding entry. Please try again.';
      notifyListeners();
      rethrow;
    }
  }

  // Delete entry
  Future<void> deleteEntry(String entryId) async {
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteFeeding(entryId);
      _entries.removeWhere((e) => e.id == entryId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete feeding entry. Please try again.';
      notifyListeners();
      rethrow;
    }
  }

  // Get feeding summary
  FeedingSummary getSummary({required DateTime date}) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final dayEntries = _entries.where((entry) {
      return entry.startTime.isAfter(dayStart) && 
             entry.startTime.isBefore(dayEnd);
    }).toList();

    return FeedingSummary.fromEntries(dayEntries, date);
  }

  // Get weekly statistics
  Map<String, dynamic> getWeeklyStats() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    final weekEntries = _entries.where((entry) {
      return entry.startTime.isAfter(weekStart);
    }).toList();

    final totalFeedings = weekEntries.length;
    final avgPerDay = totalFeedings / 7;
    
    final typeBreakdown = <FeedingType, int>{};
    for (final entry in weekEntries) {
      typeBreakdown[entry.type] = (typeBreakdown[entry.type] ?? 0) + 1;
    }

    return {
      'totalFeedings': totalFeedings,
      'averagePerDay': avgPerDay.toStringAsFixed(1),
      'typeBreakdown': typeBreakdown,
      'lastFeeding': lastFeeding,
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