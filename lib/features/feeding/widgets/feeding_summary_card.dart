import 'package:flutter/material.dart';
import '../../../data/models/feeding_model.dart';
import '../../../core/extensions/datetime_extensions.dart';

class FeedingSummaryCard extends StatelessWidget {
  final DateTime date;
  final List<FeedingModel> entries;

  const FeedingSummaryCard({
    super.key,
    required this.date,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Calculate statistics
    final totalFeedings = entries.length;
    final breastFeedings = entries.where((e) => e.type == FeedingType.breast).length;
    final bottleFeedings = entries.where((e) => e.type == FeedingType.bottle).length;
    final solidFeedings = entries.where((e) => e.type == FeedingType.solid).length;
    
    final totalBreastTime = entries
        .where((e) => e.type == FeedingType.breast && e.duration != null)
        .fold<int>(0, (sum, e) => sum + e.duration!);
    
    final totalBottleAmount = entries
        .where((e) => e.type == FeedingType.bottle && e.amount != null)
        .fold<double>(0, (sum, e) => sum + e.amount!);

    final lastFeeding = entries.isEmpty ? null : entries.first;
    final timeSinceLastFeeding = lastFeeding != null
        ? DateTime.now().difference(lastFeeding.startTime)
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  date.isToday ? 'Today' : date.formatDate(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Last feeding info
            if (lastFeeding != null && timeSinceLastFeeding != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Last feeding',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            _formatTimeSince(timeSinceLastFeeding),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Statistics Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _buildStatCard(
                  context,
                  icon: Icons.baby_changing_station,
                  label: 'Total Feedings',
                  value: totalFeedings.toString(),
                  color: colorScheme.primary,
                ),
                if (breastFeedings > 0)
                  _buildStatCard(
                    context,
                    icon: Icons.pregnant_woman,
                    label: 'Breastfeeding',
                    value: '$breastFeedings (${totalBreastTime} min)',
                    color: colorScheme.secondary,
                  ),
                if (bottleFeedings > 0)
                  _buildStatCard(
                    context,
                    icon: Icons.baby_changing_station,
                    label: 'Bottle',
                    value: '$bottleFeedings (${totalBottleAmount.toStringAsFixed(0)} ml)',
                    color: colorScheme.tertiary,
                  ),
                if (solidFeedings > 0)
                  _buildStatCard(
                    context,
                    icon: Icons.food_bank,
                    label: 'Solids',
                    value: solidFeedings.toString(),
                    color: colorScheme.error,
                  ),
              ],
            ),

            // Empty state
            if (entries.isEmpty) ...[
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.no_meals_outlined,
                      size: 48,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No feedings recorded',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeSince(Duration duration) {
    if (duration.inMinutes < 1) {
      return 'Just now';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes} min ago';
    } else if (duration.inHours < 24) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      if (minutes == 0) {
        return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
      }
      return '${hours}h ${minutes}m ago';
    } else {
      final days = duration.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    }
  }
}