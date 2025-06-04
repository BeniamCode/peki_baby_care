import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/diaper_entry.dart';
import '../providers/diaper_provider.dart';
import '../widgets/diaper_list_tile.dart';
import '../widgets/diaper_summary_card.dart';
import '../widgets/quick_log_buttons.dart';
import 'add_diaper_screen.dart';
import '../../../core/extensions/datetime_extensions.dart';

class DiaperScreen extends StatefulWidget {
  const DiaperScreen({super.key});

  @override
  State<DiaperScreen> createState() => _DiaperScreenState();
}

class _DiaperScreenState extends State<DiaperScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiaperProvider>().fetchEntries();
    });
  }

  Future<void> _quickLog(DiaperType type) async {
    final provider = context.read<DiaperProvider>();
    final diaper = DiaperEntry.create(
      babyId: provider.currentBabyId ?? '',
      type: type,
      changeTime: DateTime.now(),
      hasRash: false,
    );

    try {
      await provider.addEntry(diaper);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${type.name.toUpperCase()} diaper logged'),
            duration: const Duration(seconds: 2),
          ),
        );
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diaper Tracker'),
        centerTitle: true,
      ),
      body: Consumer<DiaperProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.entries.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchEntries(),
            child: CustomScrollView(
              slivers: [
                // Quick log buttons
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: QuickLogButtons(
                      onWet: () => _quickLog(DiaperType.wet),
                      onDirty: () => _quickLog(DiaperType.dirty),
                      onMixed: () => _quickLog(DiaperType.mixed),
                    ),
                  ),
                ),

                // Summary card
                if (provider.entries.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: DiaperSummaryCard(
                        summary: provider.getSummary(date: DateTime.now()),
                        lastEntry: provider.lastDiaperChange,
                      ),
                    ),
                  ),

                // Diaper history
                if (provider.entries.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.baby_changing_station,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No diaper changes recorded',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap + to log a diaper change',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == 0 || 
                              !provider.entries[index].changeTime.isSameDay(
                                provider.entries[index - 1].changeTime)) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (index != 0) const SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    provider.entries[index].changeTime.formatDate(),
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DiaperListTile(
                                  entry: provider.entries[index],
                                  onTap: () => _showDiaperDetails(provider.entries[index]),
                                  onDelete: () => _deleteDiaper(provider.entries[index]),
                                ),
                              ],
                            );
                          }
                          return DiaperListTile(
                            entry: provider.entries[index],
                            onTap: () => _showDiaperDetails(provider.entries[index]),
                            onDelete: () => _deleteDiaper(provider.entries[index]),
                          );
                        },
                        childCount: provider.entries.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddDiaperScreen(),
            ),
          );
          if (result == true && mounted) {
            context.read<DiaperProvider>().fetchEntries();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDiaperDetails(DiaperEntry diaper) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getDiaperIcon(diaper.type),
                  size: 32,
                  color: _getDiaperColor(diaper.type),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${diaper.type.name.toUpperCase()} Diaper',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        diaper.changeTime.formatDateTime(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (diaper.consistency != null || diaper.color != null || diaper.hasRash) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              if (diaper.consistency != null) ...[
                Text(
                  'Consistency',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 4),
                Text(diaper.consistency!),
                const SizedBox(height: 12),
              ],
              if (diaper.color != null) ...[
                Text(
                  'Color',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 4),
                Text(diaper.color!),
                const SizedBox(height: 12),
              ],
              if (diaper.hasRash) ...[
                Chip(
                  label: const Text('Has Rash'),
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ],
            if (diaper.notes != null && diaper.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Notes',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 4),
              Text(diaper.notes!),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _deleteDiaper(DiaperEntry diaper) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Diaper Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await context.read<DiaperProvider>().deleteEntry(diaper.id);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting entry: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  IconData _getDiaperIcon(DiaperType type) {
    switch (type) {
      case DiaperType.wet:
        return Icons.water_drop;
      case DiaperType.dirty:
        return Icons.cloud;
      case DiaperType.mixed:
        return Icons.cyclone;
      case DiaperType.dry:
        return Icons.check_circle;
    }
  }

  Color _getDiaperColor(DiaperType type) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (type) {
      case DiaperType.wet:
        return Colors.blue;
      case DiaperType.dirty:
        return Colors.brown;
      case DiaperType.mixed:
        return colorScheme.tertiary;
      case DiaperType.dry:
        return Colors.grey;
    }
  }
}