import 'sleep_entry.dart';

class SleepSummary {
  final DateTime date;
  final List<SleepEntry> entries;
  final Duration totalSleepDuration;
  final int napCount;
  final int nightSleepCount;
  final Duration averageSleepDuration;
  final Duration? longestSleep;
  final Duration? shortestSleep;

  SleepSummary({
    required this.date,
    required this.entries,
    required this.totalSleepDuration,
    required this.napCount,
    required this.nightSleepCount,
    required this.averageSleepDuration,
    this.longestSleep,
    this.shortestSleep,
  });

  factory SleepSummary.fromEntries(List<SleepEntry> entries, DateTime date) {
    // Filter completed entries only
    final completedEntries = entries.where((e) => e.endTime != null).toList();
    
    // Calculate totals
    Duration totalDuration = Duration.zero;
    Duration? longest;
    Duration? shortest;
    int naps = 0;
    int nightSleeps = 0;

    for (final entry in completedEntries) {
      final duration = entry.duration!;
      totalDuration += duration;

      if (entry.sleepType == SleepType.nap) {
        naps++;
      } else {
        nightSleeps++;
      }

      if (longest == null || duration > longest) {
        longest = duration;
      }
      if (shortest == null || duration < shortest) {
        shortest = duration;
      }
    }

    final avgDuration = completedEntries.isNotEmpty
        ? Duration(milliseconds: totalDuration.inMilliseconds ~/ completedEntries.length)
        : Duration.zero;

    return SleepSummary(
      date: date,
      entries: entries,
      totalSleepDuration: totalDuration,
      napCount: naps,
      nightSleepCount: nightSleeps,
      averageSleepDuration: avgDuration,
      longestSleep: longest,
      shortestSleep: shortest,
    );
  }

  // Get formatted total sleep time
  String get totalSleepString {
    final hours = totalSleepDuration.inHours;
    final minutes = totalSleepDuration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  // Get formatted average sleep time
  String get averageSleepString {
    final hours = averageSleepDuration.inHours;
    final minutes = averageSleepDuration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  // Check if there's any active sleep
  bool get hasActiveSleep => entries.any((e) => e.isActive);

  // Get active sleep entry
  SleepEntry? get activeSleep {
    try {
      return entries.firstWhere((e) => e.isActive);
    } catch (_) {
      return null;
    }
  }
}