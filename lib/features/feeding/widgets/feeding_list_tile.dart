import 'package:flutter/material.dart';
import '../../../data/models/feeding_model.dart';
import '../../../core/extensions/datetime_extensions.dart';

class FeedingListTile extends StatelessWidget {
  final FeedingModel feeding;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const FeedingListTile({
    super.key,
    required this.feeding,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getIconColor(colorScheme).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIcon(),
                  color: _getIconColor(colorScheme),
                ),
              ),
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _getTitle(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          feeding.startTime.formatTime(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getSubtitle(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (feeding.notes != null && feeding.notes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.note_outlined,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              feeding.notes!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              // Actions
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                  tooltip: 'Delete feeding',
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (feeding.type) {
      case FeedingType.breast:
        return Icons.pregnant_woman;
      case FeedingType.bottle:
        return Icons.baby_changing_station;
      case FeedingType.solid:
        return Icons.food_bank;
    }
  }

  Color _getIconColor(ColorScheme colorScheme) {
    switch (feeding.type) {
      case FeedingType.breast:
        return colorScheme.primary;
      case FeedingType.bottle:
        return colorScheme.secondary;
      case FeedingType.solid:
        return colorScheme.tertiary;
    }
  }

  String _getTitle() {
    switch (feeding.type) {
      case FeedingType.breast:
        return 'Breastfeeding';
      case FeedingType.bottle:
        return 'Bottle';
      case FeedingType.solid:
        return 'Solids';
    }
  }

  String _getSubtitle() {
    switch (feeding.type) {
      case FeedingType.breast:
        final side = feeding.breastSide?.name ?? 'both';
        final duration = feeding.duration ?? 0;
        return '${side.capitalize()} side • ${duration} min';
      case FeedingType.bottle:
        final amount = feeding.amount ?? 0;
        final type = feeding.foodType == 'formula' ? 'Formula' : 'Breast milk';
        return '$type • ${amount.toStringAsFixed(0)} ml';
      case FeedingType.solid:
        final food = feeding.foodType ?? 'Food';
        final amount = feeding.amount != null && feeding.amount! > 0
            ? ' • Amount recorded'
            : '';
        return food + amount;
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}