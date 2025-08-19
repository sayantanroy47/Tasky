import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

/// Service for managing onboarding state and user preferences
class OnboardingService {
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _appLaunchCountKey = 'app_launch_count';
  static const String _firstLaunchDateKey = 'first_launch_date';
  // static const String _userPreferencesKey = 'user_preferences';
  static const String _onboardingVersionKey = 'onboarding_version';
  
  // Current onboarding version - increment this when onboarding changes
  static const int currentOnboardingVersion = 1;

  /// Check if onboarding has been completed
  Future<bool> isOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completed = prefs.getBool(_onboardingCompletedKey) ?? false;
      final version = prefs.getInt(_onboardingVersionKey) ?? 0;
      
      // If onboarding version is outdated, show onboarding again
      if (completed && version < currentOnboardingVersion) {
        return false;
      }
      
      return completed;
    } catch (e) {
      developer.log('Error checking onboarding status: $e', name: 'OnboardingService');
      return false;
    }
  }

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setBool(_onboardingCompletedKey, true),
        prefs.setInt(_onboardingVersionKey, currentOnboardingVersion),
      ]);
      
      developer.log('Onboarding completed successfully', name: 'OnboardingService');
    } catch (e) {
      developer.log('Error completing onboarding: $e', name: 'OnboardingService');
      throw OnboardingException('Failed to complete onboarding: $e');
    }
  }

  /// Reset onboarding state (for testing or user request)
  Future<void> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove(_onboardingCompletedKey),
        prefs.remove(_onboardingVersionKey),
      ]);
      
      developer.log('Onboarding state reset', name: 'OnboardingService');
    } catch (e) {
      developer.log('Error resetting onboarding: $e', name: 'OnboardingService');
      throw OnboardingException('Failed to reset onboarding: $e');
    }
  }

  /// Track app launch for analytics and onboarding decisions
  Future<AppLaunchInfo> trackAppLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get current launch count
      final currentCount = prefs.getInt(_appLaunchCountKey) ?? 0;
      final newCount = currentCount + 1;
      
      // Get or set first launch date
      final String? firstLaunchDateString = prefs.getString(_firstLaunchDateKey);
      final DateTime firstLaunchDate;
      
      if (firstLaunchDateString == null) {
        firstLaunchDate = DateTime.now();
        await prefs.setString(_firstLaunchDateKey, firstLaunchDate.toIso8601String());
      } else {
        firstLaunchDate = DateTime.parse(firstLaunchDateString);
      }
      
      // Update launch count
      await prefs.setInt(_appLaunchCountKey, newCount);
      
      final daysSinceFirstLaunch = DateTime.now().difference(firstLaunchDate).inDays;
      
      developer.log(
        'App launched: count=$newCount, days since first launch=$daysSinceFirstLaunch',
        name: 'OnboardingService',
      );
      
      return AppLaunchInfo(
        launchCount: newCount,
        firstLaunchDate: firstLaunchDate,
        daysSinceFirstLaunch: daysSinceFirstLaunch,
        isFirstLaunch: newCount == 1,
      );
    } catch (e) {
      developer.log('Error tracking app launch: $e', name: 'OnboardingService');
      // Return safe defaults
      return AppLaunchInfo(
        launchCount: 1,
        firstLaunchDate: DateTime.now(),
        daysSinceFirstLaunch: 0,
        isFirstLaunch: true,
      );
    }
  }

  /// Save user preferences from onboarding
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final preferencesMap = preferences.toMap();
      
      for (final entry in preferencesMap.entries) {
        if (entry.value is bool) {
          await prefs.setBool('pref_${entry.key}', entry.value);
        } else if (entry.value is String) {
          await prefs.setString('pref_${entry.key}', entry.value);
        } else if (entry.value is int) {
          await prefs.setInt('pref_${entry.key}', entry.value);
        } else if (entry.value is double) {
          await prefs.setDouble('pref_${entry.key}', entry.value);
        }
      }
      
      developer.log('User preferences saved', name: 'OnboardingService');
    } catch (e) {
      developer.log('Error saving user preferences: $e', name: 'OnboardingService');
      throw OnboardingException('Failed to save user preferences: $e');
    }
  }

  /// Load user preferences
  Future<UserPreferences> loadUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      return UserPreferences(
        enableNotifications: prefs.getBool('pref_enableNotifications') ?? true,
        preferredTheme: prefs.getString('pref_preferredTheme') ?? 'system',
        enableVoiceCommands: prefs.getBool('pref_enableVoiceCommands') ?? true,
        enableHapticFeedback: prefs.getBool('pref_enableHapticFeedback') ?? true,
        defaultTaskPriority: prefs.getString('pref_defaultTaskPriority') ?? 'medium',
        enableSmartScheduling: prefs.getBool('pref_enableSmartScheduling') ?? true,
        workingHoursStart: prefs.getInt('pref_workingHoursStart') ?? 9,
        workingHoursEnd: prefs.getInt('pref_workingHoursEnd') ?? 17,
        enableLocationServices: prefs.getBool('pref_enableLocationServices') ?? false,
        syncFrequency: prefs.getInt('pref_syncFrequency') ?? 30, // minutes
      );
    } catch (e) {
      developer.log('Error loading user preferences: $e', name: 'OnboardingService');
      return UserPreferences.defaults();
    }
  }

  /// Check if user should see onboarding based on various factors
  Future<OnboardingRecommendation> getOnboardingRecommendation() async {
    try {
      final isCompleted = await isOnboardingCompleted();
      final launchInfo = await trackAppLaunch();
      
      if (!isCompleted) {
        return const OnboardingRecommendation(
          shouldShowOnboarding: true,
          reason: OnboardingReason.firstTime,
          priority: OnboardingPriority.high,
        );
      }
      
      // Check for version updates that might warrant re-onboarding
      final prefs = await SharedPreferences.getInstance();
      final lastSeenVersion = prefs.getInt(_onboardingVersionKey) ?? 0;
      
      if (lastSeenVersion < currentOnboardingVersion) {
        return const OnboardingRecommendation(
          shouldShowOnboarding: true,
          reason: OnboardingReason.versionUpdate,
          priority: OnboardingPriority.medium,
        );
      }
      
      // Check if user might benefit from re-onboarding (e.g., low engagement)
      if (launchInfo.daysSinceFirstLaunch > 30 && launchInfo.launchCount < 10) {
        return const OnboardingRecommendation(
          shouldShowOnboarding: false, // Don't force, but suggest
          reason: OnboardingReason.lowEngagement,
          priority: OnboardingPriority.low,
        );
      }
      
      return const OnboardingRecommendation(
        shouldShowOnboarding: false,
        reason: OnboardingReason.completed,
        priority: OnboardingPriority.none,
      );
    } catch (e) {
      developer.log('Error getting onboarding recommendation: $e', name: 'OnboardingService');
      return const OnboardingRecommendation(
        shouldShowOnboarding: true,
        reason: OnboardingReason.error,
        priority: OnboardingPriority.high,
      );
    }
  }

  /// Skip onboarding (mark as completed without going through it)
  Future<void> skipOnboarding() async {
    try {
      await completeOnboarding();
      developer.log('Onboarding skipped', name: 'OnboardingService');
    } catch (e) {
      developer.log('Error skipping onboarding: $e', name: 'OnboardingService');
      throw OnboardingException('Failed to skip onboarding: $e');
    }
  }

  /// Get onboarding analytics data
  Future<OnboardingAnalytics> getOnboardingAnalytics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final launchInfo = await trackAppLaunch();
      final isCompleted = await isOnboardingCompleted();
      
      return OnboardingAnalytics(
        onboardingCompleted: isCompleted,
        onboardingVersion: prefs.getInt(_onboardingVersionKey) ?? 0,
        totalAppLaunches: launchInfo.launchCount,
        daysSinceFirstLaunch: launchInfo.daysSinceFirstLaunch,
        firstLaunchDate: launchInfo.firstLaunchDate,
      );
    } catch (e) {
      developer.log('Error getting onboarding analytics: $e', name: 'OnboardingService');
      return OnboardingAnalytics.empty();
    }
  }
}

/// App launch tracking information
class AppLaunchInfo {
  final int launchCount;
  final DateTime firstLaunchDate;
  final int daysSinceFirstLaunch;
  final bool isFirstLaunch;

  const AppLaunchInfo({
    required this.launchCount,
    required this.firstLaunchDate,
    required this.daysSinceFirstLaunch,
    required this.isFirstLaunch,
  });
}

/// User preferences collected during onboarding
class UserPreferences {
  final bool enableNotifications;
  final String preferredTheme;
  final bool enableVoiceCommands;
  final bool enableHapticFeedback;
  final String defaultTaskPriority;
  final bool enableSmartScheduling;
  final int workingHoursStart;
  final int workingHoursEnd;
  final bool enableLocationServices;
  final int syncFrequency;

  const UserPreferences({
    required this.enableNotifications,
    required this.preferredTheme,
    required this.enableVoiceCommands,
    required this.enableHapticFeedback,
    required this.defaultTaskPriority,
    required this.enableSmartScheduling,
    required this.workingHoursStart,
    required this.workingHoursEnd,
    required this.enableLocationServices,
    required this.syncFrequency,
  });

  factory UserPreferences.defaults() {
    return const UserPreferences(
      enableNotifications: true,
      preferredTheme: 'system',
      enableVoiceCommands: true,
      enableHapticFeedback: true,
      defaultTaskPriority: 'medium',
      enableSmartScheduling: true,
      workingHoursStart: 9,
      workingHoursEnd: 17,
      enableLocationServices: false,
      syncFrequency: 30,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enableNotifications': enableNotifications,
      'preferredTheme': preferredTheme,
      'enableVoiceCommands': enableVoiceCommands,
      'enableHapticFeedback': enableHapticFeedback,
      'defaultTaskPriority': defaultTaskPriority,
      'enableSmartScheduling': enableSmartScheduling,
      'workingHoursStart': workingHoursStart,
      'workingHoursEnd': workingHoursEnd,
      'enableLocationServices': enableLocationServices,
      'syncFrequency': syncFrequency,
    };
  }
}

/// Onboarding recommendation result
class OnboardingRecommendation {
  final bool shouldShowOnboarding;
  final OnboardingReason reason;
  final OnboardingPriority priority;

  const OnboardingRecommendation({
    required this.shouldShowOnboarding,
    required this.reason,
    required this.priority,
  });
}

/// Reasons for showing onboarding
enum OnboardingReason {
  firstTime,
  versionUpdate,
  lowEngagement,
  userRequest,
  completed,
  error,
}

/// Priority levels for onboarding
enum OnboardingPriority {
  none,
  low,
  medium,
  high,
}

/// Onboarding analytics data
class OnboardingAnalytics {
  final bool onboardingCompleted;
  final int onboardingVersion;
  final int totalAppLaunches;
  final int daysSinceFirstLaunch;
  final DateTime firstLaunchDate;

  const OnboardingAnalytics({
    required this.onboardingCompleted,
    required this.onboardingVersion,
    required this.totalAppLaunches,
    required this.daysSinceFirstLaunch,
    required this.firstLaunchDate,
  });

  factory OnboardingAnalytics.empty() {
    return OnboardingAnalytics(
      onboardingCompleted: false,
      onboardingVersion: 0,
      totalAppLaunches: 0,
      daysSinceFirstLaunch: 0,
      firstLaunchDate: DateTime.now(),
    );
  }
}

/// Custom exception for onboarding errors
class OnboardingException implements Exception {
  final String message;
  
  const OnboardingException(this.message);
  
  @override
  String toString() => 'OnboardingException: $message';
}

/// Onboarding state notifier
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final OnboardingService _service;

  OnboardingNotifier(this._service) : super(const OnboardingState.loading()) {
    _initializeOnboardingState();
  }

  Future<void> _initializeOnboardingState() async {
    try {
      final recommendation = await _service.getOnboardingRecommendation();
      final analytics = await _service.getOnboardingAnalytics();
      
      if (recommendation.shouldShowOnboarding) {
        state = OnboardingState.required(recommendation, analytics);
      } else {
        state = OnboardingState.completed(analytics);
      }
    } catch (e) {
      state = OnboardingState.error(e.toString());
    }
  }

  Future<void> completeOnboarding() async {
    try {
      await _service.completeOnboarding();
      final analytics = await _service.getOnboardingAnalytics();
      state = OnboardingState.completed(analytics);
    } catch (e) {
      state = OnboardingState.error(e.toString());
    }
  }

  Future<void> skipOnboarding() async {
    try {
      await _service.skipOnboarding();
      final analytics = await _service.getOnboardingAnalytics();
      state = OnboardingState.completed(analytics);
    } catch (e) {
      state = OnboardingState.error(e.toString());
    }
  }

  Future<void> resetOnboarding() async {
    try {
      await _service.resetOnboarding();
      await _initializeOnboardingState();
    } catch (e) {
      state = OnboardingState.error(e.toString());
    }
  }
}

/// Onboarding state
abstract class OnboardingState {
  const OnboardingState();

  const factory OnboardingState.loading() = OnboardingLoading;
  const factory OnboardingState.required(
    OnboardingRecommendation recommendation,
    OnboardingAnalytics analytics,
  ) = OnboardingRequired;
  const factory OnboardingState.completed(OnboardingAnalytics analytics) = OnboardingCompleted;
  const factory OnboardingState.error(String message) = OnboardingError;
}

class OnboardingLoading extends OnboardingState {
  const OnboardingLoading();
}

class OnboardingRequired extends OnboardingState {
  final OnboardingRecommendation recommendation;
  final OnboardingAnalytics analytics;

  const OnboardingRequired(this.recommendation, this.analytics);
}

class OnboardingCompleted extends OnboardingState {
  final OnboardingAnalytics analytics;

  const OnboardingCompleted(this.analytics);
}

class OnboardingError extends OnboardingState {
  final String message;

  const OnboardingError(this.message);
}

/// Providers
final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  return OnboardingService();
});

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  final service = ref.read(onboardingServiceProvider);
  return OnboardingNotifier(service);
});

/// Helper provider to check if onboarding is needed
final shouldShowOnboardingProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(onboardingServiceProvider);
  final recommendation = await service.getOnboardingRecommendation();
  return recommendation.shouldShowOnboarding;
});