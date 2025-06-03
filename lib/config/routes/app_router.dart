import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:peki_baby_care/features/auth/providers/auth_provider.dart';
import 'package:peki_baby_care/features/auth/presentation/screens/login_screen.dart';
import 'package:peki_baby_care/features/auth/presentation/screens/register_screen.dart';
import 'package:peki_baby_care/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:peki_baby_care/features/baby_profile/presentation/screens/baby_list_screen.dart';
import 'package:peki_baby_care/features/baby_profile/presentation/screens/add_baby_screen.dart';
import 'package:peki_baby_care/features/baby_profile/presentation/screens/baby_detail_screen.dart';
import 'package:peki_baby_care/features/dashboard/screens/dashboard_screen.dart';
import 'package:peki_baby_care/features/dashboard/screens/dashboard_wrapper_screen.dart';
import 'package:peki_baby_care/features/feeding/screens/feeding_screen.dart';
import 'package:peki_baby_care/features/feeding/screens/add_feeding_screen.dart';
import 'package:peki_baby_care/features/sleep/screens/sleep_screen.dart';
import 'package:peki_baby_care/features/sleep/screens/add_sleep_screen.dart';
import 'package:peki_baby_care/features/diaper/screens/diaper_screen.dart';
import 'package:peki_baby_care/features/diaper/screens/add_diaper_screen.dart';
import 'package:peki_baby_care/features/health/screens/health_screen.dart';
import 'package:peki_baby_care/features/health/screens/add_medicine_screen.dart';
import 'package:peki_baby_care/features/notes/screens/notes_screen.dart';
import 'package:peki_baby_care/features/notes/screens/add_note_screen.dart';
import 'package:peki_baby_care/shared/widgets/main_navigation_shell.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/auth/login',
    routes: [
      // Auth Routes
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      
      // Main App Shell
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainNavigationShell(child: child),
        routes: [
          // Home/Dashboard
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) {
              // Show dashboard wrapper if babies exist, otherwise baby list
              return const DashboardWrapperScreen();
            },
            routes: [
              // Baby Profile Routes
              GoRoute(
                path: 'add-baby',
                name: 'addBaby',
                builder: (context, state) => const AddBabyScreen(),
              ),
              GoRoute(
                path: 'baby/:babyId',
                name: 'babyDetail',
                builder: (context, state) {
                  final babyId = state.pathParameters['babyId']!;
                  return BabyDetailScreen(babyId: babyId);
                },
              ),
              GoRoute(
                path: 'dashboard/:babyId',
                name: 'dashboard',
                builder: (context, state) {
                  final babyId = state.pathParameters['babyId']!;
                  return DashboardScreen(babyId: babyId);
                },
              ),
            ],
          ),
          
          // Feeding Routes
          GoRoute(
            path: '/feeding',
            name: 'feeding',
            builder: (context, state) => const FeedingScreen(),
            routes: [
              GoRoute(
                path: 'add',
                name: 'addFeeding',
                builder: (context, state) => const AddFeedingScreen(),
              ),
            ],
          ),
          
          // Sleep Routes
          GoRoute(
            path: '/sleep',
            name: 'sleep',
            builder: (context, state) => const SleepScreen(),
            routes: [
              GoRoute(
                path: 'add',
                name: 'addSleep',
                builder: (context, state) => const AddSleepScreen(),
              ),
            ],
          ),
          
          // Diaper Routes
          GoRoute(
            path: '/diaper',
            name: 'diaper',
            builder: (context, state) => const DiaperScreen(),
            routes: [
              GoRoute(
                path: 'add',
                name: 'addDiaper',
                builder: (context, state) => const AddDiaperScreen(),
              ),
            ],
          ),
          
          // Health Routes
          GoRoute(
            path: '/health',
            name: 'health',
            builder: (context, state) => const HealthScreen(),
            routes: [
              GoRoute(
                path: 'medicine/add',
                name: 'addMedicine',
                builder: (context, state) => const AddMedicineScreen(),
              ),
            ],
          ),
          
          // Notes Routes
          GoRoute(
            path: '/notes',
            name: 'notes',
            builder: (context, state) => const NotesScreen(),
            routes: [
              GoRoute(
                path: 'add',
                name: 'addNote',
                builder: (context, state) {
                  final babyId = state.uri.queryParameters['babyId'];
                  return AddNoteScreen(babyId: babyId);
                },
              ),
              GoRoute(
                path: 'edit/:noteId',
                name: 'editNote',
                builder: (context, state) {
                  final noteId = state.pathParameters['noteId']!;
                  return AddNoteScreen(noteId: noteId);
                },
              ),
            ],
          ),
        ],
      ),
    ],
    
    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
    
    // Redirect logic
    redirect: (context, state) {
      final authProvider = context.read<AuthProvider>();
      final isAuthenticated = authProvider.isAuthenticated;
      final isAuthRoute = state.uri.toString().startsWith('/auth');
      final isLoading = authProvider.isLoading;
      
      // Don't redirect while loading
      if (isLoading) return null;
      
      // Redirect to login if not authenticated and not on auth route
      if (!isAuthenticated && !isAuthRoute) {
        return '/auth/login';
      }
      
      // Redirect to home if authenticated and on auth route
      if (isAuthenticated && isAuthRoute) {
        return '/home';
      }
      
      return null;
    },
  );
}