import 'package:flutter/material.dart';
import '../../../data/models/diaper_model.dart';

class DiaperTypeSelector extends StatelessWidget {
  final DiaperType selectedType;
  final ValueChanged<DiaperType> onTypeSelected;

  const DiaperTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TypeButton(
            type: DiaperType.wet,
            label: 'Wet',
            icon: Icons.water_drop,
            color: Colors.blue,
            isSelected: selectedType == DiaperType.wet,
            onTap: () => onTypeSelected(DiaperType.wet),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TypeButton(
            type: DiaperType.dirty,
            label: 'Dirty',
            icon: Icons.cloud,
            color: Colors.brown,
            isSelected: selectedType == DiaperType.dirty,
            onTap: () => onTypeSelected(DiaperType.dirty),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TypeButton(
            type: DiaperType.mixed,
            label: 'Mixed',
            icon: Icons.cyclone,
            color: Colors.orange,
            isSelected: selectedType == DiaperType.mixed,
            onTap: () => onTypeSelected(DiaperType.mixed),
          ),
        ),
      ],
    );
  }
}

class _TypeButton extends StatelessWidget {
  final DiaperType type;
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
        border: Border.all(
          color: isSelected ? color : colorScheme.outline,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? color : colorScheme.onSurfaceVariant,
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}