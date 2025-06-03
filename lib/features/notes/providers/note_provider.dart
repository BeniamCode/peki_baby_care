import 'package:flutter/foundation.dart';
import '../models/note_entry.dart';
import '../repositories/note_repository.dart';

class NoteProvider extends ChangeNotifier {
  final NoteRepository _repository;
  
  List<NoteEntry> _entries = [];
  bool _isLoading = false;
  String? _error;
  String? _currentBabyId;
  String _searchQuery = '';
  NoteCategory? _selectedCategory;

  NoteProvider({required NoteRepository repository})
      : _repository = repository;

  // Getters
  List<NoteEntry> get entries => _filteredEntries;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentBabyId => _currentBabyId;
  String get searchQuery => _searchQuery;
  NoteCategory? get selectedCategory => _selectedCategory;

  // Get filtered entries based on search and category
  List<NoteEntry> get _filteredEntries {
    var filtered = _entries;

    // Filter by category
    if (_selectedCategory != null) {
      filtered = filtered.where((entry) => 
        entry.category == _selectedCategory
      ).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((entry) =>
        entry.title.toLowerCase().contains(query) ||
        entry.content.toLowerCase().contains(query) ||
        entry.tags.any((tag) => tag.toLowerCase().contains(query))
      ).toList();
    }

    return filtered;
  }

  // Get today's entries
  List<NoteEntry> get todayEntries {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _filteredEntries.where((entry) {
      final entryDate = DateTime(
        entry.createdAt.year,
        entry.createdAt.month,
        entry.createdAt.day,
      );
      return entryDate.isAtSameMomentAs(today);
    }).toList();
  }

  // Get important notes
  List<NoteEntry> get importantNotes {
    return _entries.where((entry) => entry.isImportant).toList();
  }

  // Get notes by category
  Map<NoteCategory, List<NoteEntry>> get notesByCategory {
    final categorized = <NoteCategory, List<NoteEntry>>{};
    
    for (final category in NoteCategory.values) {
      final categoryNotes = _entries.where((entry) => 
        entry.category == category
      ).toList();
      
      if (categoryNotes.isNotEmpty) {
        categorized[category] = categoryNotes;
      }
    }
    
    return categorized;
  }

  // Get all unique tags
  Set<String> get allTags {
    final tags = <String>{};
    for (final entry in _entries) {
      tags.addAll(entry.tags);
    }
    return tags;
  }

  // Set current baby
  void setCurrentBaby(String babyId) {
    if (_currentBabyId != babyId) {
      _currentBabyId = babyId;
      fetchEntries();
    }
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Set selected category
  void setSelectedCategory(NoteCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    notifyListeners();
  }

  // Fetch entries
  Future<void> fetchEntries() async {
    if (_currentBabyId == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _entries = await _repository.getEntriesByBabyId(_currentBabyId!);
      _entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _error = 'Failed to load notes. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add entry
  Future<void> addEntry(NoteEntry entry) async {
    if (_currentBabyId == null) return;

    _error = null;
    notifyListeners();

    try {
      final newEntry = entry.copyWith(
        babyId: _currentBabyId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final savedEntry = await _repository.createEntry(newEntry);
      _entries.insert(0, savedEntry);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add note. Please try again.';
      notifyListeners();
      rethrow;
    }
  }

  // Update entry
  Future<void> updateEntry(NoteEntry entry) async {
    _error = null;
    notifyListeners();

    try {
      final updatedEntry = entry.copyWith(
        updatedAt: DateTime.now(),
      );
      final savedEntry = await _repository.updateEntry(updatedEntry);
      final index = _entries.indexWhere((e) => e.id == entry.id);
      if (index != -1) {
        _entries[index] = savedEntry;
        _entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update note. Please try again.';
      notifyListeners();
      rethrow;
    }
  }

  // Toggle important status
  Future<void> toggleImportant(String entryId) async {
    try {
      final entry = _entries.firstWhere((e) => e.id == entryId);
      final updatedEntry = entry.copyWith(
        isImportant: !entry.isImportant,
      );
      await updateEntry(updatedEntry);
    } catch (e) {
      _error = 'Failed to update note status. Please try again.';
      notifyListeners();
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
      _error = 'Failed to delete note. Please try again.';
      notifyListeners();
      rethrow;
    }
  }

  // Get notes with attachments
  List<NoteEntry> getNotesWithAttachments() {
    return _entries.where((entry) => 
      entry.attachments != null && entry.attachments!.isNotEmpty
    ).toList();
  }

  // Get notes by tag
  List<NoteEntry> getNotesByTag(String tag) {
    return _entries.where((entry) => 
      entry.tags.contains(tag)
    ).toList();
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));
    
    final monthEntries = _entries.where((entry) {
      return entry.createdAt.isAfter(monthAgo);
    }).toList();

    // Count by category
    final categoryCount = <NoteCategory, int>{};
    for (final entry in _entries) {
      categoryCount[entry.category] = 
          (categoryCount[entry.category] ?? 0) + 1;
    }

    // Get recent activity
    final weekAgo = now.subtract(const Duration(days: 7));
    final weekEntries = _entries.where((entry) {
      return entry.createdAt.isAfter(weekAgo);
    }).toList();

    return {
      'totalNotes': _entries.length,
      'notesThisMonth': monthEntries.length,
      'notesThisWeek': weekEntries.length,
      'importantNotes': importantNotes.length,
      'notesWithAttachments': getNotesWithAttachments().length,
      'categoryBreakdown': categoryCount,
      'totalTags': allTags.length,
      'recentNotes': _entries.take(5).toList(),
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
    _searchQuery = '';
    _selectedCategory = null;
    notifyListeners();
  }
}