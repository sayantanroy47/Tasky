class AppConstants {
  // App Information
  static const String appName = 'Task Tracker';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String databaseName = 'task_tracker.db';
  static const int databaseVersion = 1;
  
  // Storage Keys
  static const String themeKey = 'theme_mode';
  static const String voiceEnabledKey = 'voice_enabled';
  static const String aiParsingEnabledKey = 'ai_parsing_enabled';
  static const String cloudSyncEnabledKey = 'cloud_sync_enabled';
  
  // API Configuration
  static const String openAIBaseUrl = 'https://api.openai.com/v1';
  static const String whisperApiUrl = 'https://api.openai.com/v1/audio/transcriptions';
  
  // Voice Settings
  static const Duration maxRecordingDuration = Duration(minutes: 5);
  static const Duration minRecordingDuration = Duration(seconds: 1);
  
  // Notification Settings
  static const String notificationChannelId = 'task_reminders';
  static const String notificationChannelName = 'Task Reminders';
  static const String notificationChannelDescription = 'Notifications for task reminders and updates';
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}
