/// Application constants
class AppConstants {
  static const String appName = 'Task Tracker';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  
  // Database
  static const String databaseName = 'task_tracker.db';
  static const int databaseVersion = 1;
  
  // Shared Preferences Keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyFirstLaunch = 'first_launch';
  static const String keyOnboardingCompleted = 'onboarding_completed';
  
  // Performance
  static const int maxCachedItems = 100;
  static const Duration defaultTimeout = Duration(seconds: 30);
  
  // UI
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 8.0;
  static const double defaultElevation = 2.0;
  
  // Animation
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
}