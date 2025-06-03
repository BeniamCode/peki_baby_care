import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/note_provider.dart';
import '../models/note_entry.dart';
import '../widgets/note_list_tile.dart';
import '../widgets/note_category_filter.dart';
import '../widgets/note_search_bar.dart';
import '../../dashboard/providers/selected_baby_provider.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNotes();
    });
  }

  void _initializeNotes() {
    final selectedBaby = context.read<SelectedBabyProvider>().selectedBaby;
    if (selectedBaby != null) {
      context.read<NoteProvider>().setCurrentBaby(selectedBaby.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedBaby = context.watch<SelectedBabyProvider>().selectedBaby;
    
    if (selectedBaby == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please select a baby first'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes & Diary'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Consumer<NoteProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.entries.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchEntries(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    NoteSearchBar(
                      onChanged: provider.setSearchQuery,
                      value: provider.searchQuery,
                    ),
                    const SizedBox(height: 16),
                    NoteCategoryFilter(
                      selectedCategory: provider.selectedCategory,
                      onCategorySelected: provider.setSelectedCategory,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: provider.entries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.note_alt_outlined,
                              size: 64,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              provider.searchQuery.isNotEmpty ||
                                      provider.selectedCategory != null
                                  ? 'No notes found'
                                  : 'No notes yet',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.5),
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              provider.searchQuery.isNotEmpty ||
                                      provider.selectedCategory != null
                                  ? 'Try adjusting your filters'
                                  : 'Tap + to add your first note',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.5),
                                  ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => provider.fetchEntries(),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: provider.entries.length,
                          itemBuilder: (context, index) {
                            final note = provider.entries[index];
                            return NoteListTile(
                              note: note,
                              onTap: () {
                                context.go('/notes/edit/${note.id}');
                              },
                              onDelete: () => _confirmDelete(context, note),
                              onToggleImportant: () {
                                provider.toggleImportant(note.id);
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/notes/add?babyId=${selectedBaby.id}');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, NoteEntry note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<NoteProvider>().deleteEntry(note.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Note deleted'),
                ),
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}