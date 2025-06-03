import 'package:flutter/material.dart';
import '../models/sleep_entry.dart';

class SleepChartWidget extends StatelessWidget {
  final List<SleepEntry> entries;
  final int daysToShow;

  const SleepChartWidget({
    Key? key,
    required this.entries,
    this.daysToShow = 7,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chartData = _prepareChartData();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bar_chart,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Weekly Sleep Pattern',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Chart
            SizedBox(
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: chartData.map((dayData) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Bar
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (dayData.totalHours > 0)
                                  Flexible(
                                    child: _SleepBar(
                                      napHours: dayData.napHours,
                                      nightHours: dayData.nightHours,
                                      maxHours: 24,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Day label
                          Text(
                            dayData.dayLabel,
                            style: theme.textTheme.bodySmall,
                          ),
                          // Hours label
                          Text(
                            dayData.totalHours > 0 
                                ? '${dayData.totalHours.toStringAsFixed(1)}h'
                                : '-',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendItem(
                  color: theme.colorScheme.secondary,
                  label: 'Naps',
                ),
                const SizedBox(width: 24),
                _LegendItem(
                  color: theme.colorScheme.tertiary,
                  label: 'Night Sleep',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<_DayChartData> _prepareChartData() {
    final now = DateTime.now();
    final data = <_DayChartData>[];
    
    for (int i = daysToShow - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      
      // Get entries for this day
      final dayEntries = entries.where((entry) {
        return entry.startTime.isAfter(dayStart) && 
               entry.startTime.isBefore(dayEnd) &&
               entry.endTime != null;
      }).toList();
      
      // Calculate hours
      double napHours = 0;
      double nightHours = 0;
      
      for (final entry in dayEntries) {
        final hours = entry.duration!.inMinutes / 60;
        if (entry.sleepType == SleepType.nap) {
          napHours += hours;
        } else {
          nightHours += hours;
        }
      }
      
      data.add(_DayChartData(
        date: date,
        dayLabel: _getDayLabel(date),
        napHours: napHours,
        nightHours: nightHours,
      ));
    }
    
    return data;
  }

  String _getDayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    if (date.year == today.year && 
        date.month == today.month && 
        date.day == today.day) {
      return 'Today';
    } else if (date.year == yesterday.year && 
               date.month == yesterday.month && 
               date.day == yesterday.day) {
      return 'Yesterday';
    } else {
      const weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekDays[date.weekday - 1];
    }
  }
}

class _SleepBar extends StatelessWidget {
  final double napHours;
  final double nightHours;
  final double maxHours;

  const _SleepBar({
    required this.napHours,
    required this.nightHours,
    required this.maxHours,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalHours = napHours + nightHours;
    final heightFactor = totalHours / maxHours;
    
    return FractionallySizedBox(
      heightFactor: heightFactor.clamp(0.0, 1.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            stops: nightHours > 0 && napHours > 0
                ? [0, nightHours / totalHours, nightHours / totalHours, 1]
                : null,
            colors: nightHours > 0 && napHours > 0
                ? [
                    theme.colorScheme.tertiary,
                    theme.colorScheme.tertiary,
                    theme.colorScheme.secondary,
                    theme.colorScheme.secondary,
                  ]
                : nightHours > 0
                    ? [theme.colorScheme.tertiary, theme.colorScheme.tertiary]
                    : [theme.colorScheme.secondary, theme.colorScheme.secondary],
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _DayChartData {
  final DateTime date;
  final String dayLabel;
  final double napHours;
  final double nightHours;
  
  _DayChartData({
    required this.date,
    required this.dayLabel,
    required this.napHours,
    required this.nightHours,
  });
  
  double get totalHours => napHours + nightHours;
}