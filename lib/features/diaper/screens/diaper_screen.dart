import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/diaper_model.dart';
import '../providers/diaper_provider.dart';
import '../widgets/diaper_list_tile.dart';
import '../widgets/diaper_summary_card.dart';
import '../widgets/quick_log_buttons.dart';
import 'add_diaper_screen.dart';
import '../../../core/utils/date_time_extensions.dart';

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
      context.read<DiaperProvider>().loadDiapers();
    });
  }

  Future<void> _quickLog(DiaperType type) async {
    final provider = context.read<DiaperProvider>();
    final diaper = Diaper(
      babyId: provider.currentBabyId ?? '',
      type: type,
      timestamp: DateTime.now(),
    );

    try {
      await provider.addDiaper(diaper);
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
          if (provider.isLoading && provider.diapers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadDiapers(),
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
                if (provider.diapers.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: DiaperSummaryCard(
                        summary: provider.todaySummary,
                        lastDiaper: provider.lastDiaper,
                      ),
                    ),
                  ),

                // Diaper history
                if (provider.diapers.isEmpty)
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
                              !provider.diapers[index].timestamp.isSameDay(
                                provider.diapers[index - 1].timestamp)) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (index != 0) const SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    provider.diapers[index].timestamp.formatDate(),
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DiaperListTile(
                                  diaper: provider.diapers[index],
                                  onTap: () => _showDiaperDetails(provider.diapers[index]),
                                  onDelete: () => _deleteDiaper(provider.diapers[index]),
                                ),
                              ],
                            );
                          }
                          return DiaperListTile(
                            diaper: provider.diapers[index],
                            onTap: () => _showDiaperDetails(provider.diapers[index]),
                            onDelete: () => _deleteDiaper(provider.diapers[index]),
                          );
                        },
                        childCount: provider.diapers.length,
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
            context.read<DiaperProvider>().loadDiapers();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDiaperDetails(Diaper diaper) {
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
                        diaper.timestamp.formatDateTime(),
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

  Future<void> _deleteDiaper(Diaper diaper) async {
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
        await context.read<DiaperProvider>().deleteDiaper(diaper.id!);
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
    }
  }
}