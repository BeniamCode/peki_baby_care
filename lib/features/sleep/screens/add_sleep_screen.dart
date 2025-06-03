import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/sleep_provider.dart';
import '../models/sleep_entry.dart';
import '../../../core/extensions/datetime_extensions.dart';

class AddSleepScreen extends StatefulWidget {
  final SleepEntry? editEntry;

  const AddSleepScreen({
    Key? key,
    this.editEntry,
  }) : super(key: key);

  @override
  State<AddSleepScreen> createState() => _AddSleepScreenState();
}

class _AddSleepScreenState extends State<AddSleepScreen> {
  late bool _isStartNow;
  late DateTime _startTime;
  DateTime? _endTime;
  late SleepType _sleepType;
  final _notesController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    
    if (widget.editEntry != null) {
      // Editing existing entry
      _isStartNow = false;
      _startTime = widget.editEntry!.startTime;
      _endTime = widget.editEntry!.endTime;
      _sleepType = widget.editEntry!.sleepType;
      _notesController.text = widget.editEntry!.notes ?? '';
    } else {
      // New entry
      _isStartNow = true;
      _startTime = DateTime.now();
      _endTime = null;
      _sleepType = SleepEntry.determineSleepTypeFromTime(_startTime);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.editEntry != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Sleep' : 'Track Sleep'),
        actions: [
          if (!_isStartNow)
            TextButton(
              onPressed: _isSaving ? null : _handleSave,
              child: const Text('Save'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mode selector (only for new entries)
            if (!isEditing) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How would you like to track?',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(
                            value: true,
                            label: Text('Start Now'),
                            icon: Icon(Icons.play_arrow),
                          ),
                          ButtonSegment(
                            value: false,
                            label: Text('Log Past Sleep'),
                            icon: Icon(Icons.history),
                          ),
                        ],
                        selected: {_isStartNow},
                        onSelectionChanged: (value) {
                          setState(() {
                            _isStartNow = value.first;
                            if (_isStartNow) {
                              _startTime = DateTime.now();
                              _endTime = null;
                              _sleepType = SleepEntry.determineSleepTypeFromTime(_startTime);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Sleep type selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sleep Type',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _SleepTypeChip(
                            label: 'Nap',
                            icon: Icons.wb_sunny,
                            isSelected: _sleepType == SleepType.nap,
                            onSelected: () {
                              setState(() => _sleepType = SleepType.nap);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SleepTypeChip(
                            label: 'Night Sleep',
                            icon: Icons.nightlight,
                            isSelected: _sleepType == SleepType.night,
                            onSelected: () {
                              setState(() => _sleepType = SleepType.night);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Time selection
            if (_isStartNow) ...[
              // Start Now mode
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.bedtime,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Sleep will start when you save',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Current time: ${DateTime.now().formatTime()}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Manual time entry
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sleep Duration',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      
                      // Start time
                      _TimeSelector(
                        label: 'Start Time',
                        time: _startTime,
                        onTimeSelected: (time) {
                          setState(() {
                            _startTime = time;
                            // Auto-determine sleep type based on new time
                            if (!isEditing) {
                              _sleepType = SleepEntry.determineSleepTypeFromTime(time);
                            }
                          });
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // End time
                      _TimeSelector(
                        label: 'End Time',
                        time: _endTime ?? DateTime.now(),
                        onTimeSelected: (time) {
                          setState(() => _endTime = time);
                        },
                      ),
                      
                      if (_endTime != null && _endTime!.isBefore(_startTime)) ...[
                        const SizedBox(height: 8),
                        Text(
                          'End time must be after start time',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ],
                      
                      // Duration display
                      if (_endTime != null && _endTime!.isAfter(_startTime)) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.timer,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Duration: ${_formatDuration(_endTime!.difference(_startTime))}',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Notes
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes (Optional)',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        hintText: 'How was the sleep? Any observations?',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Save button
            if (_isStartNow)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _handleSave,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Sleep Now'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  void _handleSave() async {
    // Validate
    if (!_isStartNow) {
      if (_endTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an end time'),
          ),
        );
        return;
      }
      
      if (_endTime!.isBefore(_startTime)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End time must be after start time'),
          ),
        );
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      final provider = context.read<SleepProvider>();
      final notes = _notesController.text.trim().isEmpty 
          ? null 
          : _notesController.text.trim();

      if (widget.editEntry != null) {
        // Update existing entry
        final updatedEntry = widget.editEntry!.copyWith(
          startTime: _startTime,
          endTime: _endTime,
          sleepType: _sleepType,
          notes: notes,
        );
        await provider.updateEntry(updatedEntry);
      } else if (_isStartNow) {
        // Start new sleep session
        await provider.startSleepSession(notes: notes);
      } else {
        // Add completed sleep entry
        final entry = SleepEntry(
          id: '',
          babyId: provider.currentBabyId!,
          startTime: _startTime,
          endTime: _endTime,
          sleepType: _sleepType,
          notes: notes,
        );
        await provider.addEntry(entry);
      }

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.editEntry != null 
                  ? 'Sleep record updated'
                  : _isStartNow 
                      ? 'Sleep tracking started'
                      : 'Sleep record added',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _SleepTypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onSelected;

  const _SleepTypeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primaryContainer 
              : theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeSelector extends StatelessWidget {
  final String label;
  final DateTime time;
  final ValueChanged<DateTime> onTimeSelected;

  const _TimeSelector({
    required this.label,
    required this.time,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDateTime(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Text(
                  time.formatDateTime(),
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    // First select date
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: time,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null && context.mounted) {
      // Then select time
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(time),
      );

      if (selectedTime != null) {
        final newDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
        onTimeSelected(newDateTime);
      }
    }
  }
}

extension on SleepEntry {
  static SleepType determineSleepTypeFromTime(DateTime time) {
    final hour = time.hour;
    // Night sleep typically starts after 6 PM or before 6 AM
    return (hour >= 18 || hour < 6) ? SleepType.night : SleepType.nap;
  }
}