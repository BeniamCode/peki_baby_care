import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/themes/app_theme.dart';
import 'config/routes/app_router.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/baby_profile/providers/baby_provider.dart';
import 'features/feeding/providers/feeding_provider.dart';
import 'features/sleep/providers/sleep_provider.dart';
import 'features/sleep/repositories/sleep_repository.dart';
import 'features/diaper/providers/diaper_provider.dart';
import 'features/diaper/repositories/diaper_repository.dart';
import 'features/health/providers/medicine_provider.dart';
import 'features/health/repositories/medicine_repository.dart';
import 'features/notes/providers/note_provider.dart';
import 'features/notes/repositories/note_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Enable Firestore offline persistence
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, BabyProvider>(
          create: (_) => BabyProvider(),
          update: (_, authProvider, babyProvider) {
            // Reload babies when auth state changes
            if (authProvider.isAuthenticated && babyProvider != null) {
              babyProvider.loadBabies();
            }
            return babyProvider ?? BabyProvider();
          },
        ),
        ChangeNotifierProxyProvider<BabyProvider, FeedingProvider>(
          create: (_) => FeedingProvider(),
          update: (_, babyProvider, feedingProvider) {
            // Update feeding provider when selected baby changes
            if (babyProvider.selectedBaby != null && feedingProvider != null) {
              feedingProvider.setCurrentBaby(babyProvider.selectedBaby!.id);
            }
            return feedingProvider ?? FeedingProvider();
          },
        ),
        ChangeNotifierProxyProvider<BabyProvider, SleepProvider>(
          create: (_) => SleepProvider(repository: SleepRepository()),
          update: (_, babyProvider, sleepProvider) {
            if (babyProvider.selectedBaby != null && sleepProvider != null) {
              sleepProvider.setCurrentBaby(babyProvider.selectedBaby!.id);
            }
            return sleepProvider ?? SleepProvider(repository: SleepRepository());
          },
        ),
        ChangeNotifierProxyProvider<BabyProvider, DiaperProvider>(
          create: (_) => DiaperProvider(repository: DiaperRepository()),
          update: (_, babyProvider, diaperProvider) {
            if (babyProvider.selectedBaby != null && diaperProvider != null) {
              diaperProvider.setCurrentBaby(babyProvider.selectedBaby!.id);
            }
            return diaperProvider ?? DiaperProvider(repository: DiaperRepository());
          },
        ),
        ChangeNotifierProxyProvider<BabyProvider, MedicineProvider>(
          create: (_) => MedicineProvider(repository: MedicineRepository()),
          update: (_, babyProvider, medicineProvider) {
            if (babyProvider.selectedBaby != null && medicineProvider != null) {
              medicineProvider.setCurrentBaby(babyProvider.selectedBaby!.id);
            }
            return medicineProvider ?? MedicineProvider(repository: MedicineRepository());
          },
        ),
        ChangeNotifierProxyProvider<BabyProvider, NoteProvider>(
          create: (_) => NoteProvider(repository: NoteRepository()),
          update: (_, babyProvider, noteProvider) {
            if (babyProvider.selectedBaby != null && noteProvider != null) {
              noteProvider.setCurrentBaby(babyProvider.selectedBaby!.id);
            }
            return noteProvider ?? NoteProvider(repository: NoteRepository());
          },
        ),
      ],
      child: const PegkiApp(),
    ),
  );
}

class PegkiApp extends StatefulWidget {
  const PegkiApp({super.key});

  @override
  State<PegkiApp> createState() => _PegkiAppState();
}

class _PegkiAppState extends State<PegkiApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updateSystemUI();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    _updateSystemUI();
  }

  void _updateSystemUI() {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final isDark = brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light, // iOS
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pegki Baby Care',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.textScalerOf(context),
          ),
          child: child!,
        );
      },
    );
  }
}
