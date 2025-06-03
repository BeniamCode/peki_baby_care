import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FeedingTimerWidget extends StatefulWidget {
  final bool isRunning;
  final DateTime? startTime;
  final int? initialDuration; // in minutes
  final VoidCallback onStart;
  final Function(Duration) onStop;
  final Function(Duration?) onDurationChanged;

  const FeedingTimerWidget({
    super.key,
    required this.isRunning,
    this.startTime,
    this.initialDuration,
    required this.onStart,
    required this.onStop,
    required this.onDurationChanged,
  });

  @override
  State<FeedingTimerWidget> createState() => _FeedingTimerWidgetState();
}

class _FeedingTimerWidgetState extends State<FeedingTimerWidget> {
  Timer? _timer;
  Duration _currentDuration = Duration.zero;
  final _manualMinutesController = TextEditingController();
  bool _isManualMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialDuration != null) {
      _currentDuration = Duration(minutes: widget.initialDuration!);
      _manualMinutesController.text = widget.initialDuration.toString();
      _isManualMode = true;
    }
    
    if (widget.isRunning && widget.startTime != null) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(FeedingTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isRunning && !oldWidget.isRunning) {
      _startTimer();
    } else if (!widget.isRunning && oldWidget.isRunning) {
      _stopTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _manualMinutesController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _isManualMode = false;
    _manualMinutesController.clear();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && widget.startTime != null) {
        setState(() {
          _currentDuration = DateTime.now().difference(widget.startTime!);
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    widget.onStop(_currentDuration);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Timer Display
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
          decoration: BoxDecoration(
            color: widget.isRunning
                ? colorScheme.primaryContainer.withOpacity(0.3)
                : colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isRunning
                  ? colorScheme.primary.withOpacity(0.3)
                  : colorScheme.outline.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(
                _formatDuration(_currentDuration),
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: widget.isRunning
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                ),
              ),
              if (widget.isRunning) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colorScheme.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Recording',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Controls
        Row(
          children: [
            // Timer Button
            Expanded(
              child: FilledButton.icon(
                onPressed: widget.isRunning ? () => _stopTimer() : widget.onStart,
                icon: Icon(widget.isRunning ? Icons.stop : Icons.play_arrow),
                label: Text(widget.isRunning ? 'Stop' : 'Start Timer'),
                style: FilledButton.styleFrom(
                  backgroundColor: widget.isRunning
                      ? colorScheme.error
                      : colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Manual Entry Button
            IconButton.outlined(
              onPressed: () {
                setState(() {
                  _isManualMode = !_isManualMode;
                  if (!_isManualMode) {
                    _manualMinutesController.clear();
                    widget.onDurationChanged(null);
                  }
                });
              },
              icon: Icon(_isManualMode ? Icons.timer_off : Icons.edit),
              tooltip: _isManualMode ? 'Use timer' : 'Manual entry',
            ),
          ],
        ),
        
        // Manual Entry
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: _isManualMode
              ? Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _manualMinutesController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Duration (minutes)',
                            hintText: 'Enter duration',
                            suffixText: 'min',
                          ),
                          onChanged: (value) {
                            final minutes = int.tryParse(value);
                            if (minutes != null && minutes > 0) {
                              final duration = Duration(minutes: minutes);
                              setState(() {
                                _currentDuration = duration;
                              });
                              widget.onDurationChanged(duration);
                            } else {
                              widget.onDurationChanged(null);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
        
        // Quick duration buttons
        if (!widget.isRunning && _isManualMode) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [5, 10, 15, 20, 30].map((minutes) {
              return ActionChip(
                label: Text('$minutes min'),
                onPressed: () {
                  _manualMinutesController.text = minutes.toString();
                  final duration = Duration(minutes: minutes);
                  setState(() {
                    _currentDuration = duration;
                  });
                  widget.onDurationChanged(duration);
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}