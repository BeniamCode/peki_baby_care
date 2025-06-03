import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/baby_model.dart';
import 'dashboard_screen.dart';

class DashboardWrapperScreen extends StatefulWidget {
  const DashboardWrapperScreen({super.key});

  @override
  State<DashboardWrapperScreen> createState() => _DashboardWrapperScreenState();
}

class _DashboardWrapperScreenState extends State<DashboardWrapperScreen> {
  String? _selectedBabyId;
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final userId = _auth.currentUser?.uid;
    
    if (userId == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please login to continue'),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('babies')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        final babies = snapshot.data?.docs ?? [];

        if (babies.isEmpty) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.child_care,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No babies added yet',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/home/add-baby'),
                    child: const Text('Add Baby'),
                  ),
                ],
              ),
            ),
          );
        }

        // If only one baby, show dashboard directly
        if (babies.length == 1) {
          final baby = BabyModel.fromJson({
            'id': babies.first.id,
            ...babies.first.data(),
          });
          return DashboardScreen(babyId: baby.id);
        }

        // If multiple babies and none selected, show selection screen
        if (_selectedBabyId == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Select Baby'),
            ),
            body: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: babies.length,
              itemBuilder: (context, index) {
                final baby = BabyModel.fromJson({
                  'id': babies[index].id,
                  ...babies[index].data(),
                });
                
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: baby.photoUrl != null && baby.photoUrl!.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                baby.photoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.child_care, color: Colors.white);
                                },
                              ),
                            )
                          : const Icon(Icons.child_care, color: Colors.white),
                    ),
                    title: Text(baby.name),
                    subtitle: Text('Age: ${_calculateAge(baby.birthDate)}'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      setState(() {
                        _selectedBabyId = baby.id;
                      });
                    },
                  ),
                );
              },
            ),
          );
        }

        // Show dashboard for selected baby
        return DashboardScreen(babyId: _selectedBabyId!);
      },
    );
  }

  String _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    final age = now.difference(birthDate);
    
    if (age.inDays < 30) {
      return '${age.inDays} days';
    } else if (age.inDays < 365) {
      final months = (age.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'}';
    } else {
      final years = (age.inDays / 365).floor();
      final months = ((age.inDays % 365) / 30).floor();
      return '$years ${years == 1 ? 'year' : 'years'}${months > 0 ? ' $months ${months == 1 ? 'month' : 'months'}' : ''}';
    }
  }
}