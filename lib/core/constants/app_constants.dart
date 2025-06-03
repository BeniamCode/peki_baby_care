class AppConstants {
  // App Info
  static const String appName = 'Pegki Baby Care';
  static const String appVersion = '1.0.0';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String babiesCollection = 'babies';
  static const String feedingCollection = 'feeding_records';
  static const String sleepCollection = 'sleep_records';
  static const String diaperCollection = 'diaper_records';
  static const String healthCollection = 'health_records';
  static const String growthCollection = 'growth_records';
  static const String activitiesCollection = 'activities';
  
  // Storage Buckets
  static const String profileImagesBucket = 'profile_images';
  static const String healthDocumentsBucket = 'health_documents';
  
  // Shared Preferences Keys
  static const String themeKey = 'theme_mode';
  static const String onboardingCompleteKey = 'onboarding_complete';
  static const String selectedBabyIdKey = 'selected_baby_id';
  static const String notificationEnabledKey = 'notifications_enabled';
  static const String localeKey = 'app_locale';
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxNameLength = 50;
  static const int maxNotesLength = 500;
  
  // Time Formats
  static const String dateFormat = 'MMM d, yyyy';
  static const String timeFormat = 'h:mm a';
  static const String dateTimeFormat = 'MMM d, yyyy • h:mm a';
  
  // Default Values
  static const Duration feedingReminderInterval = Duration(hours: 3);
  static const Duration sleepReminderInterval = Duration(hours: 2);
  static const Duration diaperCheckInterval = Duration(hours: 2);
  
  // Feature Flags
  static const bool enablePremiumFeatures = false;
  static const bool enableAnalytics = true;
  static const bool enableCrashlytics = true;
}