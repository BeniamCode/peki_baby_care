import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/diaper_model.dart';
import '../providers/diaper_provider.dart';
import '../widgets/diaper_type_selector.dart';
import '../../../core/utils/date_time_extensions.dart';

class AddDiaperScreen extends StatefulWidget {
  final Diaper? diaper;

  const AddDiaperScreen({super.key, this.diaper});

  @override
  State<AddDiaperScreen> createState() => _AddDiaperScreenState();
}

class _AddDiaperScreenState extends State<AddDiaperScreen> {
  late DiaperType _selectedType;
  late DateTime _selectedDateTime;
  final _notesController = TextEditingController();
  String? _consistency;
  String? _color;
  bool _hasRash = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.diaper != null) {
      _selectedType = widget.diaper!.type;
      _selectedDateTime = widget.diaper!.timestamp;
      _notesController.text = widget.diaper!.notes ?? '';
      _consistency = widget.diaper!.consistency;
      _color = widget.diaper!.color;
      _hasRash = widget.diaper!.hasRash;
    } else {
      _selectedType = DiaperType.wet;
      _selectedDateTime = DateTime.now();
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.diaper != null ? 'Edit Diaper' : 'Log Diaper Change'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Type selector
            Text(
              'Type',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            DiaperTypeSelector(
              selectedType: _selectedType,
              onTypeSelected: (type) {
                setState(() {
                  _selectedType = type;
                });
              },
            ),
            const SizedBox(height: 24),

            // Date and time
            Text(
              'Date & Time',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _selectDateTime,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.outline),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: colorScheme.primary),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedDateTime.formatDate(),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedDateTime.formatTime(),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.edit, color: colorScheme.primary),
                  ],
                ),
              ),
            ),

            // Additional details for dirty/mixed diapers
            if (_selectedType != DiaperType.wet) ...[
              const SizedBox(height: 24),
              Text(
                'Additional Details',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),

              // Consistency
              DropdownButtonFormField<String>(
                value: _consistency,
                decoration: InputDecoration(
                  labelText: 'Consistency',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.texture),
                ),
                items: const [
                  DropdownMenuItem(value: 'Liquid', child: Text('Liquid')),
                  DropdownMenuItem(value: 'Soft', child: Text('Soft')),
                  DropdownMenuItem(value: 'Formed', child: Text('Formed')),
                  DropdownMenuItem(value: 'Hard', child: Text('Hard')),
                ],
                onChanged: (value) {
                  setState(() {
                    _consistency = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Color
              DropdownButtonFormField<String>(
                value: _color,
                decoration: InputDecoration(
                  labelText: 'Color',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.palette),
                ),
                items: const [
                  DropdownMenuItem(value: 'Yellow', child: Text('Yellow')),
                  DropdownMenuItem(value: 'Brown', child: Text('Brown')),
                  DropdownMenuItem(value: 'Green', child: Text('Green')),
                  DropdownMenuItem(value: 'Black', child: Text('Black')),
                  DropdownMenuItem(value: 'Red-tinged', child: Text('Red-tinged')),
                  DropdownMenuItem(value: 'White', child: Text('White')),
                ],
                onChanged: (value) {
                  setState(() {
                    _color = value;
                  });
                },
              ),
            ],

            // Rash indicator
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Diaper Rash'),
              subtitle: const Text('Check if rash is present'),
              value: _hasRash,
              onChanged: (value) {
                setState(() {
                  _hasRash = value;
                });
              },
              secondary: Icon(
                Icons.warning,
                color: _hasRash ? colorScheme.error : colorScheme.outline,
              ),
            ),

            // Notes
            const SizedBox(height: 24),
            Text(
              'Notes (Optional)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Any additional notes...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.note),
              ),
            ),

            const SizedBox(height: 32),

            // Save button
            FilledButton(
              onPressed: _isLoading ? null : _saveDiaper,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.diaper != null ? 'Update' : 'Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (time != null && mounted) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _saveDiaper() async {
    setState(() => _isLoading = true);

    try {
      final provider = context.read<DiaperProvider>();
      final diaper = Diaper(
        id: widget.diaper?.id,
        babyId: widget.diaper?.babyId ?? provider.currentBabyId ?? '',
        type: _selectedType,
        timestamp: _selectedDateTime,
        consistency: _consistency,
        color: _color,
        hasRash: _hasRash,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      if (widget.diaper != null) {
        await provider.updateDiaper(diaper);
      } else {
        await provider.addDiaper(diaper);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}