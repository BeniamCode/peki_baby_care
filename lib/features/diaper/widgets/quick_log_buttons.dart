import 'package:flutter/material.dart';

class QuickLogButtons extends StatelessWidget {
  final VoidCallback onWet;
  final VoidCallback onDirty;
  final VoidCallback onMixed;

  const QuickLogButtons({
    super.key,
    required this.onWet,
    required this.onDirty,
    required this.onMixed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Log',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickLogButton(
                label: 'Wet',
                icon: Icons.water_drop,
                color: Colors.blue,
                onTap: onWet,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickLogButton(
                label: 'Dirty',
                icon: Icons.cloud,
                color: Colors.brown,
                onTap: onDirty,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickLogButton(
                label: 'Mixed',
                icon: Icons.cyclone,
                color: Colors.orange,
                onTap: onMixed,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickLogButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickLogButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}