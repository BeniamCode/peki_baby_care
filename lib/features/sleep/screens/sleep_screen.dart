import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/sleep_provider.dart';
import '../models/sleep_entry.dart';
import '../widgets/active_sleep_card.dart';
import '../widgets/sleep_list_tile.dart';
import '../widgets/sleep_summary_card.dart';
import '../../../core/extensions/datetime_extensions.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({Key? key}) : super(key: key);

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch sleep entries when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SleepProvider>().fetchEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Consumer<SleepProvider>(
        builder: (context, sleepProvider, child) {
          if (sleepProvider.isLoading && sleepProvider.entries.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (sleepProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    sleepProvider.error!,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.tonal(
                    onPressed: () => sleepProvider.fetchEntries(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final activeSleep = sleepProvider.activeSleepSession;
          final todaySummary = sleepProvider.getSummary(date: DateTime.now());
          final groupedEntries = _groupEntriesByDate(sleepProvider.entries);

          if (sleepProvider.entries.isEmpty && activeSleep == null) {
            return _buildEmptyState(theme);
          }

          return RefreshIndicator(
            onRefresh: () => sleepProvider.fetchEntries(),
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  floating: true,
                  snap: true,
                  title: Text(
                    'Sleep Tracking',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.bar_chart),
                      onPressed: () {
                        // TODO: Navigate to sleep analytics
                      },
                      tooltip: 'Sleep Analytics',
                    ),
                  ],
                ),

                // Active Sleep Session
                if (activeSleep != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: ActiveSleepCard(
                        sleepEntry: activeSleep,
                        onEndSleep: () => _showEndSleepDialog(activeSleep),
                      ),
                    ),
                  ),

                // Today's Summary
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SleepSummaryCard(summary: todaySummary),
                  ),
                ),

                // Sleep History
                if (groupedEntries.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Text(
                        'Sleep History',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final date = groupedEntries.keys.elementAt(index);
                        final entries = groupedEntries[date]!;
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date Header
                            Container(
                              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Text(
                                _formatDateHeader(date),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            // Entries for this date
                            ...entries.map((entry) => SleepListTile(
                              entry: entry,
                              onTap: () => _showSleepDetails(entry),
                              onEdit: () => _editSleepEntry(entry),
                              onDelete: () => _confirmDelete(entry),
                            )),
                          ],
                        );
                      },
                      childCount: groupedEntries.length,
                    ),
                  ),
                ],

                // Bottom padding
                const SliverPadding(
                  padding: EdgeInsets.only(bottom: 80),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Consumer<SleepProvider>(
        builder: (context, sleepProvider, child) {
          final hasActiveSleep = sleepProvider.activeSleepSession != null;
          
          return FloatingActionButton.extended(
            onPressed: hasActiveSleep 
                ? null 
                : () => context.push('/sleep/add'),
            backgroundColor: hasActiveSleep 
                ? theme.colorScheme.surfaceVariant 
                : theme.colorScheme.primary,
            foregroundColor: hasActiveSleep 
                ? theme.colorScheme.onSurfaceVariant 
                : theme.colorScheme.onPrimary,
            icon: Icon(hasActiveSleep ? Icons.bedtime : Icons.add),
            label: Text(hasActiveSleep ? 'Sleep in Progress' : 'Track Sleep'),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bedtime_outlined,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No sleep records yet',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking your baby\'s sleep patterns',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.push('/sleep/add'),
              icon: const Icon(Icons.add),
              label: const Text('Track First Sleep'),
            ),
          ],
        ),
      ),
    );
  }

  Map<DateTime, List<SleepEntry>> _groupEntriesByDate(List<SleepEntry> entries) {
    final grouped = <DateTime, List<SleepEntry>>{};
    
    for (final entry in entries) {
      final date = DateTime(
        entry.startTime.year,
        entry.startTime.month,
        entry.startTime.day,
      );
      
      if (grouped.containsKey(date)) {
        grouped[date]!.add(entry);
      } else {
        grouped[date] = [entry];
      }
    }
    
    return grouped;
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    if (date == today) {
      return 'Today';
    } else if (date == yesterday) {
      return 'Yesterday';
    } else {
      return date.formatDate();
    }
  }

  void _showEndSleepDialog(SleepEntry entry) {
    final notesController = TextEditingController(text: entry.notes);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Sleep Session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Started at ${entry.startTime.formatTime()}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'How was the sleep?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await context.read<SleepProvider>().endSleepSession(
                  entry.id,
                  notes: notesController.text.trim().isEmpty 
                      ? null 
                      : notesController.text.trim(),
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sleep session ended'),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to end sleep session: $e'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            child: const Text('End Sleep'),
          ),
        ],
      ),
    );
  }

  void _showSleepDetails(SleepEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => _buildSleepDetailsSheet(
          entry,
          scrollController,
        ),
      ),
    );
  }

  Widget _buildSleepDetailsSheet(
    SleepEntry entry,
    ScrollController scrollController,
  ) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Sleep type and duration
          Row(
            children: [
              Icon(
                entry.sleepType == SleepType.night 
                    ? Icons.nightlight 
                    : Icons.wb_sunny,
                size: 32,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.sleepTypeDisplay,
                      style: theme.textTheme.titleLarge,
                    ),
                    Text(
                      entry.durationString,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Time details
          _buildDetailRow(
            icon: Icons.access_time,
            label: 'Start Time',
            value: entry.startTime.formatDateTime(),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.access_time_filled,
            label: 'End Time',
            value: entry.endTime?.formatDateTime() ?? 'Ongoing',
          ),
          
          if (entry.notes != null && entry.notes!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Notes',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                entry.notes!,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _editSleepEntry(entry);
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _confirmDelete(entry);
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _editSleepEntry(SleepEntry entry) {
    context.push('/sleep/add', extra: entry);
  }

  void _confirmDelete(SleepEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Sleep Record?'),
        content: Text(
          'Are you sure you want to delete this ${entry.sleepTypeDisplay.toLowerCase()} record?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await context.read<SleepProvider>().deleteEntry(entry.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sleep record deleted'),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete: $e'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}