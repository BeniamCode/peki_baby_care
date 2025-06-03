import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BabyDetailScreen extends StatelessWidget {
  final String babyId;

  const BabyDetailScreen({
    super.key,
    required this.babyId,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Get baby details from provider using babyId
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baby Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // TODO: Navigate to edit baby screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Baby Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      child: Text(
                        'B', // TODO: Get first letter of baby name
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Baby Name', // TODO: Get baby name
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '3 months old', // TODO: Calculate age
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildQuickActionsGrid(context),
            const SizedBox(height: 32),
            
            // Recent Activities
            Text(
              'Recent Activities',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildRecentActivities(context),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    final actions = [
      {'icon': Icons.baby_changing_station, 'label': 'Feeding', 'color': Colors.orange},
      {'icon': Icons.bedtime, 'label': 'Sleep', 'color': Colors.blue},
      {'icon': Icons.clean_hands, 'label': 'Diaper', 'color': Colors.green},
      {'icon': Icons.health_and_safety, 'label': 'Health', 'color': Colors.red},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              // TODO: Navigate to respective screen
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (action['color'] as Color).withOpacity(0.1),
                    (action['color'] as Color).withOpacity(0.05),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    action['icon'] as IconData,
                    size: 40,
                    color: action['color'] as Color,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    action['label'] as String,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentActivities(BuildContext context) {
    // TODO: Get recent activities from provider
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: Icon(
                Icons.baby_changing_station,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Bottle Feeding'),
              subtitle: const Text('120ml • 2 hours ago'),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                Icons.bedtime,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Nap Time'),
              subtitle: const Text('1h 30m • 4 hours ago'),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                Icons.clean_hands,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Diaper Change'),
              subtitle: const Text('Wet • 5 hours ago'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}