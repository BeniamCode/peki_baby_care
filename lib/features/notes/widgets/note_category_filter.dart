import 'package:flutter/material.dart';
import '../models/note_entry.dart';

class NoteCategoryFilter extends StatelessWidget {
  final NoteCategory? selectedCategory;
  final ValueChanged<NoteCategory?> onCategorySelected;

  const NoteCategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            label: const Text('All'),
            selected: selectedCategory == null,
            onSelected: (selected) {
              if (selected) {
                onCategorySelected(null);
              }
            },
          ),
          const SizedBox(width: 8),
          ...NoteCategory.values.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
                label: Text(_getCategoryLabel(category)),
                selected: selectedCategory == category,
                onSelected: (selected) {
                  if (selected) {
                    onCategorySelected(category);
                  } else {
                    onCategorySelected(null);
                  }
                },
                avatar: Icon(
                  _getCategoryIcon(category),
                  size: 18,
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  String _getCategoryLabel(NoteCategory category) {
    switch (category) {
      case NoteCategory.medical:
        return 'Medical';
      case NoteCategory.milestone:
        return 'Milestone';
      case NoteCategory.general:
        return 'General';
    }
  }

  IconData _getCategoryIcon(NoteCategory category) {
    switch (category) {
      case NoteCategory.medical:
        return Icons.medical_services_outlined;
      case NoteCategory.milestone:
        return Icons.star_outline;
      case NoteCategory.general:
        return Icons.note_outlined;
    }
  }
}