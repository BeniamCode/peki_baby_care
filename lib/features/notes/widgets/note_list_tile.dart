import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note_entry.dart';

class NoteListTile extends StatelessWidget {
  final NoteEntry note;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onToggleImportant;

  const NoteListTile({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
    required this.onToggleImportant,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (note.isImportant)
                    const Icon(
                      Icons.star,
                      size: 20,
                      color: Colors.amber,
                    ),
                  if (note.isImportant) const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      note.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildCategoryChip(context),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                note.content,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM dd, yyyy').format(note.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                  ),
                  const Spacer(),
                  if (note.tags.isNotEmpty) ...[
                    Icon(
                      Icons.label_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${note.tags.length}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'important',
                        child: Row(
                          children: [
                            Icon(
                              note.isImportant ? Icons.star_border : Icons.star,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(note.isImportant ? 'Remove star' : 'Add star'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 20),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'important') {
                        onToggleImportant();
                      } else if (value == 'delete') {
                        onDelete();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context) {
    final color = _getCategoryColor(note.category);
    final label = _getCategoryLabel(note.category);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Color _getCategoryColor(NoteCategory category) {
    switch (category) {
      case NoteCategory.medical:
        return Colors.red;
      case NoteCategory.milestone:
        return Colors.green;
      case NoteCategory.general:
        return Colors.blue;
    }
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
}