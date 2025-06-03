import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuickActionsGrid extends StatelessWidget {
  final String babyId;

  const QuickActionsGrid({
    super.key,
    required this.babyId,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      QuickAction(
        icon: Icons.restaurant,
        label: 'Log Feeding',
        color: Colors.orange,
        onTap: () => context.push('/feeding/add?babyId=$babyId'),
      ),
      QuickAction(
        icon: Icons.bedtime,
        label: 'Track Sleep',
        color: Colors.indigo,
        onTap: () => context.push('/sleep/add?babyId=$babyId'),
      ),
      QuickAction(
        icon: Icons.baby_changing_station,
        label: 'Change Diaper',
        color: Colors.green,
        onTap: () => context.push('/diaper/add?babyId=$babyId'),
      ),
      QuickAction(
        icon: Icons.medication,
        label: 'Give Medicine',
        color: Colors.red,
        onTap: () => context.push('/health/medicine/add?babyId=$babyId'),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        return _QuickActionTile(action: actions[index]);
      },
    );
  }
}

class QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _QuickActionTile extends StatelessWidget {
  final QuickAction action;

  const _QuickActionTile({
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                action.color.withOpacity(0.1),
                action.color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                action.icon,
                size: 32,
                color: action.color,
              ),
              const SizedBox(height: 8),
              Text(
                action.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}