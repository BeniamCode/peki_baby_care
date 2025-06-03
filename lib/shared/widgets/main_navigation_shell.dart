import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainNavigationShell extends StatefulWidget {
  final Widget child;

  const MainNavigationShell({
    super.key,
    required this.child,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.baby_changing_station_outlined),
      selectedIcon: Icon(Icons.baby_changing_station),
      label: 'Feeding',
    ),
    NavigationDestination(
      icon: Icon(Icons.bedtime_outlined),
      selectedIcon: Icon(Icons.bedtime),
      label: 'Sleep',
    ),
    NavigationDestination(
      icon: Icon(Icons.clean_hands_outlined),
      selectedIcon: Icon(Icons.clean_hands),
      label: 'Diaper',
    ),
    NavigationDestination(
      icon: Icon(Icons.health_and_safety_outlined),
      selectedIcon: Icon(Icons.health_and_safety),
      label: 'Health',
    ),
    NavigationDestination(
      icon: Icon(Icons.note_alt_outlined),
      selectedIcon: Icon(Icons.note_alt),
      label: 'Notes',
    ),
  ];

  final List<String> _routes = [
    '/home',
    '/feeding',
    '/sleep',
    '/diaper',
    '/health',
    '/notes',
  ];

  void _onDestinationSelected(int index) {
    setState(() => _currentIndex = index);
    context.go(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: _destinations,
      ),
    );
  }
}