import 'diaper_entry.dart';

class DiaperSummary {
  final DateTime date;
  final int totalChanges;
  final int wetChanges;
  final int dirtyChanges;
  final int mixedChanges;
  final int dryChanges;
  final Duration? timeSinceLastChange;
  final DiaperEntry? lastChange;
  final List<DiaperEntry> entries;

  DiaperSummary({
    required this.date,
    required this.totalChanges,
    required this.wetChanges,
    required this.dirtyChanges,
    required this.mixedChanges,
    required this.dryChanges,
    this.timeSinceLastChange,
    this.lastChange,
    required this.entries,
  });

  // Factory constructor from list of entries
  factory DiaperSummary.fromEntries(List<DiaperEntry> entries, DateTime date) {
    final dayEntries = entries.where((entry) {
      final entryDate = entry.timestamp;
      return entryDate.year == date.year &&
          entryDate.month == date.month &&
          entryDate.day == date.day;
    }).toList();

    // Sort entries by timestamp (most recent first)
    dayEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final totalChanges = dayEntries.length;
    final wetChanges = dayEntries.where((e) => e.type == DiaperType.wet).length;
    final dirtyChanges = dayEntries.where((e) => e.type == DiaperType.dirty).length;
    final mixedChanges = dayEntries.where((e) => e.type == DiaperType.mixed).length;
    final dryChanges = dayEntries.where((e) => e.type == DiaperType.dry).length;

    DiaperEntry? lastChange;
    Duration? timeSinceLastChange;

    if (dayEntries.isNotEmpty) {
      lastChange = dayEntries.first; // Most recent entry
      timeSinceLastChange = DateTime.now().difference(lastChange.timestamp);
    }

    return DiaperSummary(
      date: date,
      totalChanges: totalChanges,
      wetChanges: wetChanges,
      dirtyChanges: dirtyChanges,
      mixedChanges: mixedChanges,
      dryChanges: dryChanges,
      timeSinceLastChange: timeSinceLastChange,
      lastChange: lastChange,
      entries: dayEntries,
    );
  }

  // Empty summary
  factory DiaperSummary.empty(DateTime date) {
    return DiaperSummary(
      date: date,
      totalChanges: 0,
      wetChanges: 0,
      dirtyChanges: 0,
      mixedChanges: 0,
      dryChanges: 0,
      entries: [],
    );
  }

  // Helper getters
  bool get hasChanges => totalChanges > 0;
  
  String get formattedTimeSinceLastChange {
    if (timeSinceLastChange == null) return 'No changes yet';
    
    final duration = timeSinceLastChange!;
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m ago';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Get percentage of each type
  double get wetPercentage => totalChanges > 0 ? (wetChanges / totalChanges) * 100 : 0;
  double get dirtyPercentage => totalChanges > 0 ? (dirtyChanges / totalChanges) * 100 : 0;
  double get mixedPercentage => totalChanges > 0 ? (mixedChanges / totalChanges) * 100 : 0;
  double get dryPercentage => totalChanges > 0 ? (dryChanges / totalChanges) * 100 : 0;

  // Get entries by type
  List<DiaperEntry> get wetEntries => entries.where((e) => e.type == DiaperType.wet).toList();
  List<DiaperEntry> get dirtyEntries => entries.where((e) => e.type == DiaperType.dirty).toList();
  List<DiaperEntry> get mixedEntries => entries.where((e) => e.type == DiaperType.mixed).toList();
  List<DiaperEntry> get dryEntries => entries.where((e) => e.type == DiaperType.dry).toList();

  // Average time between changes
  Duration? get averageTimeBetweenChanges {
    if (entries.length < 2) return null;

    final sortedEntries = List<DiaperEntry>.from(entries)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    var totalDuration = Duration.zero;
    for (int i = 1; i < sortedEntries.length; i++) {
      totalDuration += sortedEntries[i].timestamp.difference(sortedEntries[i - 1].timestamp);
    }

    return Duration(
      milliseconds: totalDuration.inMilliseconds ~/ (sortedEntries.length - 1),
    );
  }

  String get formattedAverageTimeBetweenChanges {
    final avgTime = averageTimeBetweenChanges;
    if (avgTime == null) return 'N/A';

    if (avgTime.inHours > 0) {
      return '${avgTime.inHours}h ${avgTime.inMinutes % 60}m';
    } else {
      return '${avgTime.inMinutes}m';
    }
  }

  @override
  String toString() {
    return 'DiaperSummary(date: $date, totalChanges: $totalChanges, wet: $wetChanges, dirty: $dirtyChanges, mixed: $mixedChanges, dry: $dryChanges)';
  }
}
