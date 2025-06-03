import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/medicine_entry.dart';
import '../providers/medicine_provider.dart';
import '../../../core/extensions/datetime_extensions.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _medicineNameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _prescribedByController = TextEditingController();
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();

  MedicineType _selectedType = MedicineType.liquid;
  MedicineUnit _selectedUnit = MedicineUnit.ml;
  MedicineFrequency? _selectedFrequency;
  DateTime _selectedDateTime = DateTime.now();
  DateTime? _nextDoseTime;
  bool _scheduleNextDose = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _medicineNameController.dispose();
    _dosageController.dispose();
    _prescribedByController.dispose();
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medicine'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _handleSave,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Medicine Name
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Medicine Information',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _medicineNameController,
                        decoration: const InputDecoration(
                          labelText: 'Medicine Name',
                          hintText: 'Enter medicine name',
                          prefixIcon: Icon(Icons.medication),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter medicine name';
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),
                      // Medicine Type
                      Text(
                        'Type',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: MedicineType.values.map((type) {
                          return ChoiceChip(
                            label: Text(_getTypeLabel(type)),
                            selected: _selectedType == type,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedType = type;
                                  _updateUnitBasedOnType(type);
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Dosage
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dosage',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _dosageController,
                              decoration: InputDecoration(
                                labelText: 'Amount',
                                hintText: 'Enter dosage amount',
                                suffixText: _getUnitLabel(_selectedUnit),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter dosage';
                                }
                                final dosage = double.tryParse(value);
                                if (dosage == null || dosage <= 0) {
                                  return 'Please enter a valid dosage';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Unit selector
                          SegmentedButton<MedicineUnit>(
                            segments: _getAvailableUnits(),
                            selected: {_selectedUnit},
                            onSelectionChanged: (Set<MedicineUnit> newSelection) {
                              setState(() {
                                _selectedUnit = newSelection.first;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Date and Time
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.access_time),
                      title: const Text('Administered At'),
                      subtitle: Text(
                        '${_selectedDateTime.formatDate()} at ${_selectedDateTime.formatTime()}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _selectDateTime,
                    ),
                    const Divider(height: 1),
                    // Next Dose Schedule
                    SwitchListTile(
                      secondary: const Icon(Icons.schedule),
                      title: const Text('Schedule Next Dose'),
                      value: _scheduleNextDose,
                      onChanged: (value) {
                        setState(() {
                          _scheduleNextDose = value;
                          if (!value) {
                            _selectedFrequency = null;
                            _nextDoseTime = null;
                          }
                        });
                      },
                    ),
                    if (_scheduleNextDose) ...[
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Frequency',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: MedicineFrequency.values.map((frequency) {
                                return ChoiceChip(
                                  label: Text(_getFrequencyLabel(frequency)),
                                  selected: _selectedFrequency == frequency,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _selectedFrequency = frequency;
                                        _calculateNextDoseTime();
                                      });
                                    }
                                  },
                                );
                              }).toList(),
                            ),
                            if (_nextDoseTime != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.alarm,
                                      color: colorScheme.onPrimaryContainer,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Next dose: ${_nextDoseTime!.formatDateTime()}',
                                        style: TextStyle(
                                          color: colorScheme.onPrimaryContainer,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Additional Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Additional Information',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _prescribedByController,
                        decoration: const InputDecoration(
                          labelText: 'Prescribed By (Optional)',
                          hintText: 'Doctor name',
                          prefixIcon: Icon(Icons.person),
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _reasonController,
                        decoration: const InputDecoration(
                          labelText: 'Reason (Optional)',
                          hintText: 'e.g., Fever, Cold, Vaccination',
                          prefixIcon: Icon(Icons.medical_information),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes (Optional)',
                          hintText: 'Any additional notes...',
                          prefixIcon: Icon(Icons.note),
                        ),
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 80), // Space for FAB
            ],
          ),
        ),
      ),
    );
  }

  String _getTypeLabel(MedicineType type) {
    switch (type) {
      case MedicineType.liquid:
        return 'Liquid';
      case MedicineType.tablet:
        return 'Tablet';
      case MedicineType.drops:
        return 'Drops';
      case MedicineType.cream:
        return 'Cream';
      case MedicineType.injection:
        return 'Injection';
      case MedicineType.other:
        return 'Other';
    }
  }

  String _getUnitLabel(MedicineUnit unit) {
    switch (unit) {
      case MedicineUnit.ml:
        return 'ml';
      case MedicineUnit.mg:
        return 'mg';
      case MedicineUnit.drops:
        return 'drops';
      case MedicineUnit.applications:
        return 'applications';
    }
  }

  String _getFrequencyLabel(MedicineFrequency frequency) {
    switch (frequency) {
      case MedicineFrequency.asNeeded:
        return 'As Needed';
      case MedicineFrequency.once:
        return 'Once Daily';
      case MedicineFrequency.twice:
        return 'Twice Daily';
      case MedicineFrequency.thrice:
        return 'Three Times';
      case MedicineFrequency.fourTimes:
        return 'Four Times';
      case MedicineFrequency.every4Hours:
        return 'Every 4 Hours';
      case MedicineFrequency.every6Hours:
        return 'Every 6 Hours';
      case MedicineFrequency.every8Hours:
        return 'Every 8 Hours';
      case MedicineFrequency.every12Hours:
        return 'Every 12 Hours';
    }
  }

  void _updateUnitBasedOnType(MedicineType type) {
    setState(() {
      switch (type) {
        case MedicineType.liquid:
          _selectedUnit = MedicineUnit.ml;
          break;
        case MedicineType.tablet:
          _selectedUnit = MedicineUnit.mg;
          break;
        case MedicineType.drops:
          _selectedUnit = MedicineUnit.drops;
          break;
        case MedicineType.cream:
          _selectedUnit = MedicineUnit.applications;
          break;
        case MedicineType.injection:
          _selectedUnit = MedicineUnit.ml;
          break;
        case MedicineType.other:
          _selectedUnit = MedicineUnit.ml;
          break;
      }
    });
  }

  List<ButtonSegment<MedicineUnit>> _getAvailableUnits() {
    switch (_selectedType) {
      case MedicineType.liquid:
      case MedicineType.injection:
        return [
          const ButtonSegment(value: MedicineUnit.ml, label: Text('ml')),
          const ButtonSegment(value: MedicineUnit.mg, label: Text('mg')),
        ];
      case MedicineType.tablet:
        return [
          const ButtonSegment(value: MedicineUnit.mg, label: Text('mg')),
        ];
      case MedicineType.drops:
        return [
          const ButtonSegment(value: MedicineUnit.drops, label: Text('drops')),
          const ButtonSegment(value: MedicineUnit.ml, label: Text('ml')),
        ];
      case MedicineType.cream:
        return [
          const ButtonSegment(value: MedicineUnit.applications, label: Text('applications')),
        ];
      case MedicineType.other:
        return MedicineUnit.values.map((unit) {
          return ButtonSegment(
            value: unit,
            label: Text(_getUnitLabel(unit)),
          );
        }).toList();
    }
  }

  void _calculateNextDoseTime() {
    if (_selectedFrequency == null) {
      _nextDoseTime = null;
      return;
    }

    final baseTime = _selectedDateTime;
    switch (_selectedFrequency!) {
      case MedicineFrequency.asNeeded:
        _nextDoseTime = null;
        break;
      case MedicineFrequency.once:
        _nextDoseTime = baseTime.add(const Duration(days: 1));
        break;
      case MedicineFrequency.twice:
        _nextDoseTime = baseTime.add(const Duration(hours: 12));
        break;
      case MedicineFrequency.thrice:
        _nextDoseTime = baseTime.add(const Duration(hours: 8));
        break;
      case MedicineFrequency.fourTimes:
        _nextDoseTime = baseTime.add(const Duration(hours: 6));
        break;
      case MedicineFrequency.every4Hours:
        _nextDoseTime = baseTime.add(const Duration(hours: 4));
        break;
      case MedicineFrequency.every6Hours:
        _nextDoseTime = baseTime.add(const Duration(hours: 6));
        break;
      case MedicineFrequency.every8Hours:
        _nextDoseTime = baseTime.add(const Duration(hours: 8));
        break;
      case MedicineFrequency.every12Hours:
        _nextDoseTime = baseTime.add(const Duration(hours: 12));
        break;
    }
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );

    if (time == null || !mounted) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      if (_scheduleNextDose && _selectedFrequency != null) {
        _calculateNextDoseTime();
      }
    });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final provider = context.read<MedicineProvider>();
      
      final entry = MedicineEntry(
        id: '',
        babyId: provider.currentBabyId ?? '',
        medicineName: _medicineNameController.text.trim(),
        type: _selectedType,
        dosage: double.parse(_dosageController.text),
        unit: _selectedUnit,
        givenAt: _selectedDateTime,
        prescribedBy: _prescribedByController.text.trim().isNotEmpty
            ? _prescribedByController.text.trim()
            : null,
        reason: _reasonController.text.trim().isNotEmpty
            ? _reasonController.text.trim()
            : null,
        nextDoseTime: _scheduleNextDose ? _nextDoseTime : null,
        frequency: _scheduleNextDose ? _selectedFrequency : null,
        isCompleted: false,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        createdAt: DateTime.now(),
        createdBy: '', // Will be set by provider/repository
      );

      await provider.addEntry(entry);

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save medicine: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}