import 'package:flutter/material.dart';
import '../../../data/models/diaper_model.dart';
import '../../../core/utils/date_time_extensions.dart';

class DiaperSummaryCard extends StatelessWidget {
  final Map<String, int> summary;
  final Diaper? lastDiaper;

  const DiaperSummaryCard({
    super.key,
    required this.summary,
    this.lastDiaper,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final timeSinceLastChange = lastDiaper != null
        ? DateTime.now().difference(lastDiaper!.timestamp)
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (timeSinceLastChange != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getTimeColor(timeSinceLastChange).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _formatTimeSince(timeSinceLastChange),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getTimeColor(timeSinceLastChange),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  context,
                  'Wet',
                  summary['wet']?.toString() ?? '0',
                  Icons.water_drop,
                  Colors.blue,
                ),
                _buildStatColumn(
                  context,
                  'Dirty',
                  summary['dirty']?.toString() ?? '0',
                  Icons.cloud,
                  Colors.brown,
                ),
                _buildStatColumn(
                  context,
                  'Mixed',
                  summary['mixed']?.toString() ?? '0',
                  Icons.cyclone,
                  Colors.orange,
                ),
                _buildStatColumn(
                  context,
                  'Total',
                  summary['total']?.toString() ?? '0',
                  Icons.baby_changing_station,
                  colorScheme.primary,
                ),
              ],
            ),
            if (lastDiaper != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Last change: ${lastDiaper!.timestamp.formatTime()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (lastDiaper!.hasRash) ...[
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'RASH',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _formatTimeSince(Duration duration) {
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m ago';
    } else if (duration.inHours < 24) {
      return '${duration.inHours}h ago';
    } else {
      return '${duration.inDays}d ago';
    }
  }

  Color _getTimeColor(Duration duration) {
    if (duration.inHours < 2) {
      return Colors.green;
    } else if (duration.inHours < 4) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}