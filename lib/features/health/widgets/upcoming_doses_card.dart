import 'package:flutter/material.dart';
import '../../../data/models/medicine_model.dart';
import '../../../core/extensions/datetime_extensions.dart';

class UpcomingDosesCard extends StatelessWidget {
  final List<MedicineModel> medicines;

  const UpcomingDosesCard({
    super.key,
    required this.medicines,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Sort medicines by next dose time
    final sortedMedicines = List<MedicineModel>.from(medicines)
      ..sort((a, b) {
        if (a.nextDoseTime == null) return 1;
        if (b.nextDoseTime == null) return -1;
        return a.nextDoseTime!.compareTo(b.nextDoseTime!);
      });

    // Take only the first 3 upcoming doses
    final upcomingDoses = sortedMedicines
        .where((m) => m.nextDoseTime != null && m.nextDoseTime!.isAfter(DateTime.now()))
        .take(3)
        .toList();

    if (upcomingDoses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.alarm,
                  size: 20,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Next Doses',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...upcomingDoses.map((medicine) => _buildDoseItem(context, medicine)),
          ],
        ),
      ),
    );
  }

  Widget _buildDoseItem(BuildContext context, MedicineModel medicine) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final timeUntilDose = medicine.nextDoseTime!.difference(now);
    final isUrgent = timeUntilDose.inMinutes < 30;

    String timeString;
    if (timeUntilDose.inMinutes < 60) {
      timeString = 'in ${timeUntilDose.inMinutes} min';
    } else if (timeUntilDose.inHours < 24) {
      final hours = timeUntilDose.inHours;
      final minutes = timeUntilDose.inMinutes % 60;
      if (minutes > 0) {
        timeString = 'in ${hours}h ${minutes}m';
      } else {
        timeString = 'in ${hours}h';
      }
    } else {
      timeString = 'on ${medicine.nextDoseTime!.formatDate()}';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isUrgent
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        medicine.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isUrgent
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        timeString,
                        style: TextStyle(
                          color: isUrgent
                              ? theme.colorScheme.onError
                              : theme.colorScheme.onPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      medicine.dosage,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• ${medicine.nextDoseTime!.formatTime()}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}