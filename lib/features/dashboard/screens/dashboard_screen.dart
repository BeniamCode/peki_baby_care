import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../baby_profile/providers/baby_provider.dart';
import '../../feeding/providers/feeding_provider.dart';
import '../../sleep/providers/sleep_provider.dart';
import '../../diaper/providers/diaper_provider.dart';
import '../../health/providers/medicine_provider.dart';
import '../../../data/models/feeding_model.dart';
import '../../diaper/models/diaper_entry.dart' as diaper_models; // For DiaperType enum
import '../widgets/baby_info_card.dart';
import '../widgets/activity_summary_card.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/today_summary_widget.dart';

class DashboardScreen extends StatefulWidget {
  final String babyId;

  const DashboardScreen({
    super.key,
    required this.babyId,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Set selected baby in provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final babyProvider = context.read<BabyProvider>();
      final baby = babyProvider.babies.firstWhere((b) => b.id == widget.babyId);
      babyProvider.selectBaby(baby);
    });
  }

  // Add refresh handler
  Future<void> _handleRefresh() async {
    // Refresh all providers
    final babyProvider = context.read<BabyProvider>();
    final feedingProvider = context.read<FeedingProvider>();
    final sleepProvider = context.read<SleepProvider>();
    final diaperProvider = context.read<DiaperProvider>();
    final medicineProvider = context.read<MedicineProvider>();
    
    // Load babies and fetch entries for each provider (these are void methods that trigger stream subscriptions)
    babyProvider.loadBabies();
    feedingProvider.fetchEntries();
    sleepProvider.fetchEntries();
    diaperProvider.fetchEntries();
    medicineProvider.fetchEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Baby Care Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: Consumer<BabyProvider>(
        builder: (context, babyProvider, _) {
          final baby = babyProvider.selectedBaby;
          
          if (baby == null || baby.id != widget.babyId) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Baby Info Card
                  BabyInfoCard(baby: baby),
                  const SizedBox(height: 24),

                  // Today's Summary
                  TodaySummaryWidget(babyId: widget.babyId),
                  const SizedBox(height: 24),

                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  QuickActionsGrid(babyId: widget.babyId),
                  const SizedBox(height: 24),

                  // Recent Activities
                  Text(
                    'Recent Activities',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Feeding Summary
                  Consumer<FeedingProvider>(
                    builder: (context, feedingProvider, _) {
                      final recentFeedings = feedingProvider.getTodayFeedings();
                      final lastFeeding = feedingProvider.getLastFeeding();
                      
                      return ActivitySummaryCard(
                        title: 'Feeding',
                        icon: Icons.restaurant,
                        color: Colors.orange,
                        itemCount: recentFeedings.length,
                        lastActivity: lastFeeding != null
                            ? 'Last: ${_formatTime(lastFeeding.startTime)}'
                            : 'No feedings today',
                        onTap: () => context.go('/feeding'),
                        details: _buildFeedingDetails(recentFeedings),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Sleep Summary
                  Consumer<SleepProvider>(
                    builder: (context, sleepProvider, _) {
                      final todaySleep = sleepProvider.getTodaySleepEntries();
                      final lastSleep = sleepProvider.getLastSleepEntry();
                      final totalSleep = sleepProvider.getTotalSleepDuration();
                      
                      return ActivitySummaryCard(
                        title: 'Sleep',
                        icon: Icons.bedtime,
                        color: Colors.indigo,
                        itemCount: todaySleep.length,
                        lastActivity: lastSleep != null
                            ? 'Last: ${_formatTime(lastSleep.startTime)}'
                            : 'No sleep tracked today',
                        onTap: () => context.go('/sleep'),
                        details: 'Total: ${_formatDuration(totalSleep)}',
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Diaper Summary
                  Consumer<DiaperProvider>(
                    builder: (context, diaperProvider, _) {
                      final todayDiapers = diaperProvider.getTodayDiapers();
                      final lastDiaper = diaperProvider.getLastDiaper();
                      
                      return ActivitySummaryCard(
                        title: 'Diaper',
                        icon: Icons.baby_changing_station,
                        color: Colors.green,
                        itemCount: todayDiapers.length,
                        lastActivity: lastDiaper != null
                            ? 'Last: ${_formatTime(lastDiaper.time)}'
                            : 'No changes today',
                        onTap: () => context.go('/diaper'),
                        details: _buildDiaperDetails(todayDiapers),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Medicine Summary
                  Consumer<MedicineProvider>(
                    builder: (context, medicineProvider, _) {
                      final todayMedicines = medicineProvider.getTodayMedicines();
                      final upcomingDoses = medicineProvider.getUpcomingDoses();
                      
                      return ActivitySummaryCard(
                        title: 'Medicine',
                        icon: Icons.medication,
                        color: Colors.red,
                        itemCount: todayMedicines.length,
                        lastActivity: upcomingDoses.isNotEmpty
                            ? 'Next: ${_formatTime(upcomingDoses.first.time)}'
                            : 'No medicines scheduled',
                        onTap: () => context.go('/health'),
                        details: '${upcomingDoses.length} upcoming doses',
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    } else {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  String _buildFeedingDetails(List<FeedingModel> feedings) {
    int breast = 0;
    int bottle = 0;
    int solid = 0;

    for (final feeding in feedings) {
      switch (feeding.type) {
        case FeedingType.breast:
          breast++;
          break;
        case FeedingType.bottle:
          bottle++;
          break;
        case FeedingType.solid:
          solid++;
          break;
      }
    }

    final parts = <String>[];
    if (breast > 0) parts.add('Breast: $breast');
    if (bottle > 0) parts.add('Bottle: $bottle');
    if (solid > 0) parts.add('Solid: $solid');

    return parts.isEmpty ? 'No feedings today' : parts.join(', ');
  }

  String _buildDiaperDetails(List<diaper_models.DiaperEntry> diapers) {
    int wet = 0;
    int soiled = 0;
    int mixed = 0;

    for (final diaper in diapers) {
      switch (diaper.type) {
        case diaper_models.DiaperType.wet:
          wet++;
          break;
        case diaper_models.DiaperType.dirty:
          soiled++;
          break;
        case diaper_models.DiaperType.mixed:
          mixed++;
          break;
        case diaper_models.DiaperType.dry:
          // Dry diapers don't count in summary
          break;
      }
    }

    final parts = <String>[];
    if (wet > 0) parts.add('Wet: $wet');
    if (soiled > 0) parts.add('Soiled: $soiled');
    if (mixed > 0) parts.add('Mixed: $mixed');

    return parts.isEmpty ? 'No changes today' : parts.join(', ');
  }
}