import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/medicine_provider.dart';
import '../widgets/medicine_list_tile.dart';
import '../widgets/medicine_summary_card.dart';
import '../widgets/upcoming_doses_card.dart';
import '../models/medicine_entry.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  @override
  void initState() {
    super.initState();
    // Load medicines when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicineProvider>().fetchEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Tracker'),
        centerTitle: true,
      ),
      body: Consumer<MedicineProvider>(
        builder: (context, medicineProvider, child) {
          if (medicineProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final todaysMedicines = medicineProvider.todayEntries;
          final upcomingDoses = medicineProvider.upcomingDoses;

          if (todaysMedicines.isEmpty && upcomingDoses.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: () => medicineProvider.fetchEntries(),
            child: CustomScrollView(
              slivers: [
                // Medicine Summary Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: MedicineSummaryCard(
                      completedCount: medicineProvider.todayEntries.where((m) => m.isCompleted).length,
                      totalCount: todaysMedicines.length,
                    ),
                  ),
                ),

                // Upcoming Doses Section
                if (upcomingDoses.isNotEmpty) ...[
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Text(
                        'Upcoming Doses',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: UpcomingDosesCard(medicines: upcomingDoses),
                    ),
                  ),
                ],

                // Today's Medicines Section
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Text(
                      'Today\'s Medicines',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Medicine List
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final medicine = todaysMedicines[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: MedicineListTile(
                            entry: medicine,
                            onToggleComplete: () {
                              if (medicine.isCompleted) {
                                // Already completed, no action needed
                              } else {
                                medicineProvider.completeMedication(medicine.id);
                              }
                            },
                            onTap: () => _showMedicineDetails(context, medicine),
                          ),
                        );
                      },
                      childCount: todaysMedicines.length,
                    ),
                  ),
                ),

                // Medicine History Section
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Text(
                      'Medicine History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // History List
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final historyEntries = medicineProvider.entries.where((e) => e.isCompleted).toList();
                        if (index >= historyEntries.length) return const SizedBox.shrink();
                        final medicine = historyEntries[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: MedicineListTile(
                            entry: medicine,
                            isHistoryItem: true,
                            onTap: () => _showMedicineDetails(context, medicine),
                          ),
                        );
                      },
                      childCount: medicineProvider.entries.where((e) => e.isCompleted).length,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-medicine'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_information_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Medicines Tracked',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking your baby\'s medicines by tapping the + button',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMedicineDetails(BuildContext context, MedicineEntry medicine) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  medicine.medicineName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Dosage', '${medicine.dosage} ${medicine.unit.toString().split('.').last}'),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Time Administered',
              '${medicine.timeAdministered.hour.toString().padLeft(2, '0')}:${medicine.timeAdministered.minute.toString().padLeft(2, '0')}',
            ),
            if (medicine.nextDoseTime != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow(
                'Next Dose',
                '${medicine.nextDoseTime!.hour.toString().padLeft(2, '0')}:${medicine.nextDoseTime!.minute.toString().padLeft(2, '0')}',
              ),
            ],
            if (medicine.notes != null && medicine.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Notes',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                medicine.notes!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                if (!medicine.isCompleted)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<MedicineProvider>().completeMedication(medicine.id);
                        Navigator.pop(context);
                      },
                      child: const Text('Mark as Given'),
                    ),
                  ),
                if (!medicine.isCompleted) const SizedBox(width: 16),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      context.read<MedicineProvider>().deleteEntry(medicine.id);
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}