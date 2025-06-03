import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../feeding/providers/feeding_provider.dart';
import '../../sleep/providers/sleep_provider.dart';
import '../../diaper/providers/diaper_provider.dart';
import '../../health/providers/medicine_provider.dart';

class TodaySummaryWidget extends StatelessWidget {
  final String babyId;

  const TodaySummaryWidget({
    super.key,
    required this.babyId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Today's Summary",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatDate(DateTime.now()),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Summary Stats Grid
            Row(
              children: [
                // Feeding Stats
                Expanded(
                  child: Consumer<FeedingProvider>(
                    builder: (context, provider, _) {
                      final todayFeedings = provider.getTodayFeedings();
                      final totalVolume = todayFeedings.fold<double>(
                        0,
                        (sum, feeding) => sum + (feeding.amount ?? 0),
                      );
                      
                      return _SummaryStatItem(
                        icon: Icons.restaurant,
                        color: Colors.orange,
                        value: todayFeedings.length.toString(),
                        label: 'Feedings',
                        detail: totalVolume > 0 ? '${totalVolume.toInt()} ml' : null,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                
                // Sleep Stats
                Expanded(
                  child: Consumer<SleepProvider>(
                    builder: (context, provider, _) {
                      final totalSleep = provider.getTotalSleepDuration();
                      final sessions = provider.getTodaySleepEntries().length;
                      
                      return _SummaryStatItem(
                        icon: Icons.bedtime,
                        color: Colors.indigo,
                        value: _formatDuration(totalSleep),
                        label: 'Sleep',
                        detail: '$sessions sessions',
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Diaper Stats
                Expanded(
                  child: Consumer<DiaperProvider>(
                    builder: (context, provider, _) {
                      final todayDiapers = provider.getTodayDiapers();
                      
                      return _SummaryStatItem(
                        icon: Icons.baby_changing_station,
                        color: Colors.green,
                        value: todayDiapers.length.toString(),
                        label: 'Diapers',
                        detail: 'Changed',
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                
                // Medicine Stats
                Expanded(
                  child: Consumer<MedicineProvider>(
                    builder: (context, provider, _) {
                      final todayMedicines = provider.getTodayMedicines();
                      final upcomingDoses = provider.getUpcomingDoses();
                      
                      return _SummaryStatItem(
                        icon: Icons.medication,
                        color: Colors.red,
                        value: todayMedicines.length.toString(),
                        label: 'Medicines',
                        detail: '${upcomingDoses.length} pending',
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}

class _SummaryStatItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final String? detail;

  const _SummaryStatItem({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    this.detail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (detail != null) ...[
            const SizedBox(height: 2),
            Text(
              detail!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}