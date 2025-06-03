import 'package:flutter/foundation.dart';
import '../models/sleep_entry.dart';
import '../repositories/sleep_repository.dart';
import '../models/sleep_summary.dart';

class SleepProvider extends ChangeNotifier {
  final SleepRepository _repository;
  
  List<SleepEntry> _entries = [];
  bool _isLoading = false;
  String? _error;
  String? _currentBabyId;

  SleepProvider({required SleepRepository repository})
      : _repository = repository;

  // Getters
  List<SleepEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentBabyId => _currentBabyId;

  // Get active sleep session
  SleepEntry? get activeSleepSession {
    try {
      return _entries.firstWhere((entry) => entry.endTime == null);
    } catch (_) {
      return null;
    }
  }

  // Get today's entries
  List<SleepEntry> get todayEntries {
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

  // Get last completed sleep
  SleepEntry? get lastCompletedSleep {
    final completed = _entries.where((e) => e.endTime != null).toList();
    if (completed.isEmpty) return null;
    return completed.reduce((a, b) => 
      a.startTime.isAfter(b.startTime) ? a : b
    );
  }

  // Method wrappers for dashboard compatibility
  List<SleepEntry> getTodaySleepEntries() => todayEntries;
  SleepEntry? getLastSleepEntry() => lastCompletedSleep;
  Duration getTotalSleepDuration() {
    final today = DateTime.now();
    final todaySleeps = todayEntries.where((e) => e.endTime != null);
    return todaySleeps.fold(Duration.zero, (total, sleep) => 
      total + sleep.endTime!.difference(sleep.startTime));
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
      _entries.sort((a, b) => b.startTime.compareTo(a.startTime));
    } catch (e) {
      _error = 'Failed to load sleep entries. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Start sleep session
  Future<void> startSleepSession({String? notes}) async {
    if (_currentBabyId == null) return;

    // Check if there's already an active session
    if (activeSleepSession != null) {
      _error = 'There is already an active sleep session.';
      notifyListeners();
      return;
    }

    _error = null;
    notifyListeners();

    try {
      final entry = SleepEntry(
        id: '',
        babyId: _currentBabyId!,
        startTime: DateTime.now(),
        notes: notes,
      );
      
      final savedEntry = await _repository.createEntry(entry);
      _entries.insert(0, savedEntry);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to start sleep session. Please try again.';
      notifyListeners();
      rethrow;
    }
  }

  // End sleep session
  Future<void> endSleepSession(String entryId, {String? notes}) async {
    _error = null;
    notifyListeners();

    try {
      final entry = _entries.firstWhere((e) => e.id == entryId);
      if (entry.endTime != null) {
        _error = 'This sleep session has already ended.';
        notifyListeners();
        return;
      }

      final updatedEntry = entry.copyWith(
        endTime: DateTime.now(),
        notes: notes ?? entry.notes,
      );
      
      final savedEntry = await _repository.updateEntry(updatedEntry);
      final index = _entries.indexWhere((e) => e.id == entryId);
      if (index != -1) {
        _entries[index] = savedEntry;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to end sleep session. Please try again.';
      notifyListeners();
      rethrow;
    }
  }

  // Add completed entry
  Future<void> addEntry(SleepEntry entry) async {
    if (_currentBabyId == null) return;

    _error = null;
    notifyListeners();

    try {
      final newEntry = entry.copyWith(babyId: _currentBabyId);
      final savedEntry = await _repository.createEntry(newEntry);
      _entries.insert(0, savedEntry);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add sleep entry. Please try again.';
      notifyListeners();
      rethrow;
    }
  }

  // Update entry
  Future<void> updateEntry(SleepEntry entry) async {
    _error = null;
    notifyListeners();

    try {
      final updatedEntry = await _repository.updateEntry(entry);
      final index = _entries.indexWhere((e) => e.id == entry.id);
      if (index != -1) {
        _entries[index] = updatedEntry;
        _entries.sort((a, b) => b.startTime.compareTo(a.startTime));
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update sleep entry. Please try again.';
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
      _error = 'Failed to delete sleep entry. Please try again.';
      notifyListeners();
      rethrow;
    }
  }

  // Get sleep summary
  SleepSummary getSummary({required DateTime date}) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final dayEntries = _entries.where((entry) {
      return entry.startTime.isAfter(dayStart) && 
             entry.startTime.isBefore(dayEnd);
    }).toList();

    return SleepSummary.fromEntries(dayEntries, date);
  }

  // Get weekly statistics
  Map<String, dynamic> getWeeklyStats() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    final weekEntries = _entries.where((entry) {
      return entry.startTime.isAfter(weekStart) && entry.endTime != null;
    }).toList();

    Duration totalSleep = Duration.zero;
    for (final entry in weekEntries) {
      if (entry.endTime != null) {
        totalSleep += entry.duration!;
      }
    }

    final avgSleepHours = totalSleep.inMinutes / 60 / 7;
    final totalNaps = weekEntries.length;
    final avgNapsPerDay = totalNaps / 7;

    // Calculate longest and shortest sleep
    Duration? longestSleep;
    Duration? shortestSleep;
    
    for (final entry in weekEntries) {
      final duration = entry.duration;
      if (duration != null) {
        if (longestSleep == null || duration > longestSleep) {
          longestSleep = duration;
        }
        if (shortestSleep == null || duration < shortestSleep) {
          shortestSleep = duration;
        }
      }
    }

    return {
      'totalSleepHours': totalSleep.inHours,
      'averageSleepPerDay': avgSleepHours.toStringAsFixed(1),
      'totalNaps': totalNaps,
      'averageNapsPerDay': avgNapsPerDay.toStringAsFixed(1),
      'longestSleep': longestSleep,
      'shortestSleep': shortestSleep,
      'activeSleepSession': activeSleepSession,
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