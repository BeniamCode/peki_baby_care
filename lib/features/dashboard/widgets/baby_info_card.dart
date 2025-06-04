import 'package:flutter/material.dart';
import '../../../data/models/baby_model.dart';

class BabyInfoCard extends StatelessWidget {
  final BabyModel baby;

  const BabyInfoCard({
    super.key,
    required this.baby,
  });

  @override
  Widget build(BuildContext context) {
    final age = baby.ageString;
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: Row(
          children: [
            // Baby Photo
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withOpacity(0.2),
                border: Border.all(
                  color: theme.colorScheme.primary,
                  width: 3,
                ),
              ),
              child: baby.photoUrl != null && baby.photoUrl!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        baby.photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultAvatar(theme);
                        },
                      ),
                    )
                  : _buildDefaultAvatar(theme),
            ),
            const SizedBox(width: 16),
            
            // Baby Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    baby.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    age,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildInfoChip(
                        context,
                        Icons.cake,
                        '${baby.birthDate.day}/${baby.birthDate.month}/${baby.birthDate.year}',
                      ),
                      const SizedBox(width: 8),
                      if (baby.gender != null)
                        _buildInfoChip(
                          context,
                          baby.gender == Gender.male ? Icons.male : Icons.female,
                          baby.gender.toString().split('.').last,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Edit Button
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // Navigate to edit baby profile
              },
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(ThemeData theme) {
    return Icon(
      Icons.child_care,
      size: 40,
      color: theme.colorScheme.primary,
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}