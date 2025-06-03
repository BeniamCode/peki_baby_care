import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:peki_baby_care/data/models/baby_model.dart';
import 'package:peki_baby_care/features/baby_profile/providers/baby_provider.dart';
import 'package:peki_baby_care/features/auth/providers/auth_provider.dart';

class BabyListScreen extends StatelessWidget {
  const BabyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final babyProvider = context.watch<BabyProvider>();
    
    if (!authProvider.isAuthenticated) {
      return const Scaffold(
        body: Center(
          child: Text('Please login to continue'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Babies'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) {
                context.go('/auth/login');
              }
            },
          ),
        ],
      ),
      body: babyProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : babyProvider.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${babyProvider.error}'),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => babyProvider.loadBabies(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : babyProvider.babies.isEmpty
                  ? _buildEmptyState(context)
                  : _buildBabyList(context, babyProvider.babies),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/home/add-baby'),
        icon: const Icon(Icons.add),
        label: const Text('Add Baby'),
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
              Icons.child_care,
              size: 120,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No babies added yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first baby to start tracking their journey',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.push('/home/add-baby'),
              icon: const Icon(Icons.add),
              label: const Text('Add Your Baby'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBabyList(BuildContext context, List<BabyModel> babies) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: babies.length,
      itemBuilder: (context, index) {
        final baby = babies[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () {
              // Set selected baby in provider
              context.read<BabyProvider>().selectBaby(baby);
              // Navigate to dashboard
              context.push('/home/dashboard/${baby.id}');
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: baby.photoUrl != null
                        ? NetworkImage(baby.photoUrl!)
                        : null,
                    child: baby.photoUrl == null
                        ? Text(
                            baby.name[0].toUpperCase(),
                            style: Theme.of(context).textTheme.headlineSmall,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  
                  // Baby Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          baby.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          baby.ageString,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Arrow
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}