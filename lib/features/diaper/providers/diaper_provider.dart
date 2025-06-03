import 'package:flutter/foundation.dart';
import '../models/diaper_entry.dart';
import '../repositories/diaper_repository.dart';
import '../models/diaper_summary.dart';

class DiaperProvider extends ChangeNotifier {
  final DiaperRepository _repository;
  
  List<DiaperEntry> _entries = [];
  bool _isLoading = false;
  String? _error;
  String? _currentBabyId;

  DiaperProvider({required DiaperRepository repository})
      : _repository = repository;

  // Getters
  List<DiaperEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentBabyId => _currentBabyId;

  // Get today's entries
  List<DiaperEntry> get todayEntries {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _entries.where((entry) {
      final entryDate = DateTime(
        entry.changeTime.year,
        entry.changeTime.month,
        entry.changeTime.day,
      );
      return entryDate.isAtSameMomentAs(today);
    }).toList();
  }

  // Get last diaper change
  DiaperEntry? get lastDiaperChange {
    if (_entries.isEmpty) return null;
    return _entries.reduce((a, b) => 
      a.changeTime.isAfter(b.changeTime) ? a : b
    );
  }

  // Check if diaper change is needed (more than 3 hours since last change)
  bool get isDiaperChangeNeeded {
    final last = lastDiaperChange;
    if (last == null) return true;
    
    final hoursSinceLastChange = DateTime.now()
        .difference(last.changeTime)
        .inHours;
    return hoursSinceLastChange >= 3;
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
      _entries.sort((a, b) => b.changeTime.compareTo(a.changeTime));
    } catch (e) {
      _error = 'Failed to load diaper entries. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add entry
  Future<void> addEntry(DiaperEntry entry) async {
    if (_currentBabyId == null) return;

    _error = null;
    notifyListeners();

    try {
      final newEntry = entry.copyWith(babyId: _currentBabyId);
      final savedEntry = await _repository.createEntry(newEntry);
      _entries.insert(0, savedEntry);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add diaper entry. Please try again.';
      notifyListeners();
      rethrow;
    }
  }

  // Update entry
  Future<void> updateEntry(DiaperEntry entry) async {
    _error = null;
    notifyListeners();

    try {
      final updatedEntry = await _repository.updateEntry(entry);
      final index = _entries.indexWhere((e) => e.id == entry.id);
      if (index != -1) {
        _entries[index] = updatedEntry;
        _entries.sort((a, b) => b.changeTime.compareTo(a.changeTime));
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update diaper entry. Please try again.';
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
      _error = 'Failed to delete diaper entry. Please try again.';
      notifyListeners();
      rethrow;
    }
  }

  // Get diaper summary
  DiaperSummary getSummary({required DateTime date}) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final dayEntries = _entries.where((entry) {
      return entry.changeTime.isAfter(dayStart) && 
             entry.changeTime.isBefore(dayEnd);
    }).toList();

    return DiaperSummary.fromEntries(dayEntries, date);
  }

  // Get weekly statistics
  Map<String, dynamic> getWeeklyStats() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    final weekEntries = _entries.where((entry) {
      return entry.changeTime.isAfter(weekStart);
    }).toList();

    final totalChanges = weekEntries.length;
    final avgPerDay = totalChanges / 7;
    
    // Count by type
    int wetCount = 0;
    int dirtyCount = 0;
    int bothCount = 0;
    int rashCount = 0;

    for (final entry in weekEntries) {
      if (entry.hasRash) rashCount++;
      
      if (entry.type == DiaperType.wet) {
        wetCount++;
      } else if (entry.type == DiaperType.dirty) {
        dirtyCount++;
      } else if (entry.type == DiaperType.both) {
        bothCount++;
      }
    }

    // Calculate average time between changes
    Duration totalTimeBetween = Duration.zero;
    int intervals = 0;
    
    for (int i = 0; i < weekEntries.length - 1; i++) {
      final current = weekEntries[i];
      final next = weekEntries[i + 1];
      totalTimeBetween += current.changeTime.difference(next.changeTime);
      intervals++;
    }
    
    final avgTimeBetween = intervals > 0 
        ? totalTimeBetween ~/ intervals 
        : const Duration(hours: 3);

    return {
      'totalChanges': totalChanges,
      'averagePerDay': avgPerDay.toStringAsFixed(1),
      'wetCount': wetCount,
      'dirtyCount': dirtyCount,
      'bothCount': bothCount,
      'rashCount': rashCount,
      'averageTimeBetween': avgTimeBetween,
      'lastChange': lastDiaperChange,
      'changeNeeded': isDiaperChangeNeeded,
    };
  }

  // Get rash trend
  List<bool> getRashTrend({int days = 7}) {
    final now = DateTime.now();
    final trend = <bool>[];
    
    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      
      final dayEntries = _entries.where((entry) {
        return entry.changeTime.isAfter(dayStart) && 
               entry.changeTime.isBefore(dayEnd);
      }).toList();
      
      trend.add(dayEntries.any((entry) => entry.hasRash));
    }
    
    return trend;
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