import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/feeding_model.dart';
import '../providers/feeding_provider.dart';
import '../widgets/feeding_timer_widget.dart';
import '../../../core/extensions/datetime_extensions.dart';

class AddFeedingScreen extends StatefulWidget {
  const AddFeedingScreen({super.key});

  @override
  State<AddFeedingScreen> createState() => _AddFeedingScreenState();
}

class _AddFeedingScreenState extends State<AddFeedingScreen> {
  late FeedingType _selectedType;
  late DateTime _selectedDateTime;
  
  // Breastfeeding fields
  BreastSide? _selectedSide;
  int? _duration; // in minutes
  bool _isTimerRunning = false;
  DateTime? _timerStartTime;
  
  // Bottle fields
  final _amountController = TextEditingController();
  String _milkType = 'breast_milk'; // breast_milk or formula
  
  // Solids fields
  final _foodNameController = TextEditingController();
  final _solidAmountController = TextEditingController();
  final _notesController = TextEditingController();
  
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedType = FeedingType.breast;
    _selectedDateTime = DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _foodNameController.dispose();
    _solidAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Feeding'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Feeding Type Selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Feeding Type',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<FeedingType>(
                      segments: const [
                        ButtonSegment(
                          value: FeedingType.breast,
                          icon: Icon(Icons.pregnant_woman),
                          label: Text('Breast'),
                        ),
                        ButtonSegment(
                          value: FeedingType.bottle,
                          icon: Icon(Icons.baby_changing_station),
                          label: Text('Bottle'),
                        ),
                        ButtonSegment(
                          value: FeedingType.solid,
                          icon: Icon(Icons.food_bank),
                          label: Text('Solids'),
                        ),
                      ],
                      selected: {_selectedType},
                      onSelectionChanged: (Set<FeedingType> newSelection) {
                        setState(() {
                          _selectedType = newSelection.first;
                          // Reset fields when type changes
                          _selectedSide = null;
                          _duration = null;
                          _isTimerRunning = false;
                          _timerStartTime = null;
                          _amountController.clear();
                          _foodNameController.clear();
                          _solidAmountController.clear();
                          _notesController.clear();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Type-specific fields
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildTypeSpecificFields(),
            ),

            const SizedBox(height: 16),

            // Date and Time
            Card(
              child: ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Date & Time'),
                subtitle: Text(
                  '${_selectedDateTime.formatDate()} at ${_selectedDateTime.formatTime()}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _selectDateTime,
              ),
            ),

            const SizedBox(height: 16),

            // Notes (for all types)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes (Optional)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Add any notes about this feeding...',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSpecificFields() {
    switch (_selectedType) {
      case FeedingType.breast:
        return _buildBreastfeedingFields();
      case FeedingType.bottle:
        return _buildBottleFields();
      case FeedingType.solid:
        return _buildSolidsFields();
    }
  }

  Widget _buildBreastfeedingFields() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      key: const ValueKey('breast'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Side selector
            Text(
              'Side',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<BreastSide>(
              segments: const [
                ButtonSegment(
                  value: BreastSide.left,
                  label: Text('Left'),
                ),
                ButtonSegment(
                  value: BreastSide.right,
                  label: Text('Right'),
                ),
                ButtonSegment(
                  value: BreastSide.both,
                  label: Text('Both'),
                ),
              ],
              selected: _selectedSide != null ? {_selectedSide!} : {},
              onSelectionChanged: (Set<BreastSide> newSelection) {
                setState(() {
                  _selectedSide = newSelection.firstOrNull;
                });
              },
            ),
            const SizedBox(height: 24),

            // Timer
            Text(
              'Duration',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            FeedingTimerWidget(
              isRunning: _isTimerRunning,
              startTime: _timerStartTime,
              initialDuration: _duration,
              onStart: () {
                setState(() {
                  _isTimerRunning = true;
                  _timerStartTime = DateTime.now();
                });
              },
              onStop: (duration) {
                setState(() {
                  _isTimerRunning = false;
                  _duration = duration.inMinutes;
                });
              },
              onDurationChanged: (duration) {
                setState(() {
                  _duration = duration?.inMinutes;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottleFields() {
    final theme = Theme.of(context);

    return Card(
      key: const ValueKey('bottle'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount
            Text(
              'Amount (ml)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: const InputDecoration(
                hintText: 'Enter amount in ml',
                suffixText: 'ml',
              ),
            ),
            const SizedBox(height: 24),

            // Milk type
            Text(
              'Milk Type',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'breast_milk',
                  label: Text('Breast Milk'),
                ),
                ButtonSegment(
                  value: 'formula',
                  label: Text('Formula'),
                ),
              ],
              selected: {_milkType},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _milkType = newSelection.first;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSolidsFields() {
    final theme = Theme.of(context);

    return Card(
      key: const ValueKey('solid'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food name
            Text(
              'Food',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _foodNameController,
              decoration: const InputDecoration(
                hintText: 'What did baby eat?',
              ),
            ),
            const SizedBox(height: 24),

            // Amount
            Text(
              'Amount (Optional)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _solidAmountController,
              decoration: const InputDecoration(
                hintText: 'e.g., 2 tablespoons, 1/2 jar',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final theme = Theme.of(context);
    
    // Show date picker
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (date == null || !mounted) return;

    // Show time picker
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
    });
  }

  Future<void> _handleSave() async {
    // Validate fields
    String? error;
    
    switch (_selectedType) {
      case FeedingType.breast:
        if (_selectedSide == null) {
          error = 'Please select a side';
        } else if (_duration == null || _duration == 0) {
          error = 'Please enter the duration';
        }
        break;
      case FeedingType.bottle:
        if (_amountController.text.isEmpty) {
          error = 'Please enter the amount';
        } else {
          final amount = double.tryParse(_amountController.text);
          if (amount == null || amount <= 0) {
            error = 'Please enter a valid amount';
          }
        }
        break;
      case FeedingType.solid:
        if (_foodNameController.text.isEmpty) {
          error = 'Please enter the food name';
        }
        break;
    }

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final provider = context.read<FeedingProvider>();
      
      // Create feeding entry
      final feeding = FeedingModel(
        id: '', // Will be set by repository
        babyId: provider.currentBabyId ?? '',
        type: _selectedType,
        startTime: _selectedDateTime,
        endTime: _selectedType == FeedingType.breast && _duration != null
            ? _selectedDateTime.add(Duration(minutes: _duration!))
            : null,
        duration: _duration,
        amount: _selectedType == FeedingType.bottle
            ? double.tryParse(_amountController.text)
            : _selectedType == FeedingType.solid && _solidAmountController.text.isNotEmpty
                ? 0.0 // Placeholder for solid amount as text
                : null,
        breastSide: _selectedSide,
        foodType: _selectedType == FeedingType.solid
            ? _foodNameController.text
            : _selectedType == FeedingType.bottle
                ? _milkType
                : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        createdAt: DateTime.now(),
        createdBy: '', // Will be set by provider/repository
      );

      await provider.addEntry(feeding);

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save feeding: ${e.toString()}'),
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