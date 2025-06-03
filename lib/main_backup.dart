import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:peki_baby_care/core/themes/app_theme.dart';
import 'package:peki_baby_care/config/routes/app_router.dart';
import 'package:peki_baby_care/core/constants/app_constants.dart';
import 'package:peki_baby_care/features/dashboard/providers/selected_baby_provider.dart';
import 'package:peki_baby_care/features/feeding/providers/feeding_provider.dart';
import 'package:peki_baby_care/features/sleep/providers/sleep_provider.dart';
import 'package:peki_baby_care/features/diaper/providers/diaper_provider.dart';
import 'package:peki_baby_care/features/health/providers/medicine_provider.dart';
import 'package:peki_baby_care/features/notes/providers/note_provider.dart';
import 'package:peki_baby_care/data/repositories/feeding_repository.dart';
import 'package:peki_baby_care/data/repositories/sleep_repository.dart';
import 'package:peki_baby_care/data/repositories/diaper_repository.dart';
import 'package:peki_baby_care/data/repositories/medicine_repository.dart';
import 'package:peki_baby_care/data/repositories/note_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const PegkiApp());
}

class PegkiApp extends StatelessWidget {
  const PegkiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SelectedBabyProvider()),
        ChangeNotifierProvider(create: (_) => FeedingProvider(repository: FeedingRepository())),
        ChangeNotifierProvider(create: (_) => SleepProvider(repository: SleepRepository())),
        ChangeNotifierProvider(create: (_) => DiaperProvider(repository: DiaperRepository())),
        ChangeNotifierProvider(create: (_) => MedicineProvider(repository: MedicineRepository())),
        ChangeNotifierProvider(create: (_) => NoteProvider(repository: NoteRepository())),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            
            // Theme
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system, // TODO: Get from ThemeProvider
            
            // Routing
            routerConfig: AppRouter.router,
            
            // Localization
            // TODO: Add localization support
            // localizationsDelegates: const [
            //   GlobalMaterialLocalizations.delegate,
            //   GlobalWidgetsLocalizations.delegate,
            //   GlobalCupertinoLocalizations.delegate,
            // ],
            // supportedLocales: const [
            //   Locale('en', 'US'),
            //   Locale('es', 'ES'),
            // ],
          );
        },
      ),
    );
  }
}