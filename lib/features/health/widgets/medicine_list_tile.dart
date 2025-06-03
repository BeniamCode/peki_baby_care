import 'package:flutter/material.dart';
import '../../../data/models/medicine_model.dart';
import '../../../core/extensions/datetime_extensions.dart';

class MedicineListTile extends StatelessWidget {
  final MedicineModel medicine;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onTap;
  final bool isHistoryItem;

  const MedicineListTile({
    super.key,
    required this.medicine,
    this.onToggleComplete,
    this.onTap,
    this.isHistoryItem = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = medicine.isCompleted;
    final isPastDue = !isCompleted && 
        medicine.timeAdministered.isBefore(DateTime.now());

    return Card(
      elevation: isCompleted ? 0 : 2,
      color: isCompleted 
          ? theme.colorScheme.surfaceVariant.withOpacity(0.5)
          : isPastDue 
              ? theme.colorScheme.errorContainer
              : theme.cardColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Completion Checkbox or Status Icon
              if (!isHistoryItem)
                Checkbox(
                  value: isCompleted,
                  onChanged: onToggleComplete != null 
                      ? (_) => onToggleComplete!() 
                      : null,
                  fillColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.selected)) {
                      return theme.colorScheme.primary;
                    }
                    return isPastDue 
                        ? theme.colorScheme.error 
                        : theme.colorScheme.outline;
                  }),
                )
              else
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? theme.colorScheme.primary.withOpacity(0.2)
                        : theme.colorScheme.error.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCompleted ? Icons.check : Icons.close,
                    color: isCompleted
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error,
                    size: 20,
                  ),
                ),
              const SizedBox(width: 12),

              // Medicine Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            medicine.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              decoration: isCompleted 
                                  ? TextDecoration.lineThrough 
                                  : null,
                              fontWeight: FontWeight.w600,
                              color: isCompleted
                                  ? theme.colorScheme.onSurface.withOpacity(0.6)
                                  : isPastDue
                                      ? theme.colorScheme.onErrorContainer
                                      : null,
                            ),
                          ),
                        ),
                        if (isPastDue && !isHistoryItem)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Past Due',
                              style: TextStyle(
                                color: theme.colorScheme.onError,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.local_pharmacy,
                          size: 16,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          medicine.dosage,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          medicine.timeAdministered.formatTime(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    if (medicine.notes != null && medicine.notes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.note,
                            size: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              medicine.notes!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
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

              // Arrow icon for details
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}