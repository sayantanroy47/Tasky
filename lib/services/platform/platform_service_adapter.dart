import 'dart:io';
import 'package:flutter/foundation.dart';

import '../speech/speech_service.dart';
import '../speech/speech_service_impl.dart';
import '../speech/speech_service_stub.dart';
import '../audio/audio_recording_service.dart';
import '../notification/local_notification_service.dart';
import '../background/simple_background_service.dart';

/// Platform-specific service adapter to ensure cross-platform compatibility
/// 
/// This adapter provides platform-appropriate implementations for services
/// that may have different behaviors or capabilities across iOS, Android, and other platforms
class PlatformServiceAdapter {
  static PlatformServiceAdapter? _instance;
  static PlatformServiceAdapter get instance => _instance ??= PlatformServiceAdapter._();
  
  PlatformServiceAdapter._();

  /// Get platform-appropriate speech service implementation
  SpeechService createSpeechService() {
    if (Platform.isAndroid || Platform.isIOS) {
      return SpeechServiceImpl();
    } else {
      // Use stub implementation for unsupported platforms
      return SpeechServiceStub();
    }
  }

  /// Get platform-appropriate audio recording service
  AudioRecordingService createAudioRecordingService() {
    // AudioRecordingService works on all mobile platforms
    return AudioRecordingService();
  }

  /// Get platform-appropriate notification service
  LocalNotificationService createNotificationService() {
    // Note: LocalNotificationService requires initialization parameter
    // This is a placeholder - actual usage should provide the required parameter
    throw UnimplementedError('LocalNotificationService requires initialization parameter');
  }

  /// Get platform-appropriate background task service
  SimpleBackgroundService createBackgroundTaskService() {
    return SimpleBackgroundService.instance;
  }

  /// Check if speech recognition is supported on current platform
  bool get isSpeechRecognitionSupported {
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Check if audio recording is supported on current platform
  bool get isAudioRecordingSupported {
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Check if background processing is supported on current platform
  bool get isBackgroundProcessingSupported {
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Check if push notifications are supported on current platform
  bool get areNotificationsSupported {
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Get platform-specific service limitations
  PlatformServiceCapabilities get serviceCapabilities {
    return PlatformServiceCapabilities(
      speechRecognition: _getSpeechRecognitionCapabilities(),
      audioRecording: _getAudioRecordingCapabilities(),
      backgroundProcessing: _getBackgroundProcessingCapabilities(),
      notifications: _getNotificationCapabilities(),
    );
  }

  /// Get speech recognition capabilities for current platform
  SpeechRecognitionCapabilities _getSpeechRecognitionCapabilities() {
    if (Platform.isAndroid) {
      return const SpeechRecognitionCapabilities(
        isSupported: true,
        maxListenDuration: Duration(minutes: 10),
        supportsContinuousListening: true,
        supportsPartialResults: true,
        supportsMultipleLanguages: true,
        supportsOfflineRecognition: false, // Depends on device/settings
        supportsConfidenceScoring: true,
      );
    } else if (Platform.isIOS) {
      return const SpeechRecognitionCapabilities(
        isSupported: true,
        maxListenDuration: Duration(minutes: 1),
        supportsContinuousListening: false,
        supportsPartialResults: true,
        supportsMultipleLanguages: true,
        supportsOfflineRecognition: true,
        supportsConfidenceScoring: true,
      );
    } else {
      return const SpeechRecognitionCapabilities(
        isSupported: false,
        maxListenDuration: Duration.zero,
        supportsContinuousListening: false,
        supportsPartialResults: false,
        supportsMultipleLanguages: false,
        supportsOfflineRecognition: false,
        supportsConfidenceScoring: false,
      );
    }
  }

  /// Get audio recording capabilities for current platform
  AudioRecordingCapabilities _getAudioRecordingCapabilities() {
    if (Platform.isAndroid || Platform.isIOS) {
      return const AudioRecordingCapabilities(
        isSupported: true,
        maxRecordingDuration: Duration(minutes: 10),
        supportedFormats: ['aac', 'mp3', 'wav'],
        supportsBackgroundRecording: true,
        requiresMicrophonePermission: true,
        supportsAudioLevelMonitoring: true,
      );
    } else {
      return const AudioRecordingCapabilities(
        isSupported: false,
        maxRecordingDuration: Duration.zero,
        supportedFormats: [],
        supportsBackgroundRecording: false,
        requiresMicrophonePermission: false,
        supportsAudioLevelMonitoring: false,
      );
    }
  }

  /// Get background processing capabilities for current platform
  BackgroundProcessingCapabilities _getBackgroundProcessingCapabilities() {
    if (Platform.isAndroid) {
      return const BackgroundProcessingCapabilities(
        isSupported: true,
        supportsPeriodicTasks: true,
        supportsLongRunningTasks: true,
        maxBackgroundDuration: Duration(minutes: 10),
        requiresBatteryOptimizationWhitelist: true,
        supportsExactAlarms: true,
      );
    } else if (Platform.isIOS) {
      return const BackgroundProcessingCapabilities(
        isSupported: true,
        supportsPeriodicTasks: false, // iOS has strict background limitations
        supportsLongRunningTasks: false,
        maxBackgroundDuration: Duration(seconds: 30),
        requiresBatteryOptimizationWhitelist: false,
        supportsExactAlarms: false, // iOS handles this differently
      );
    } else {
      return const BackgroundProcessingCapabilities(
        isSupported: false,
        supportsPeriodicTasks: false,
        supportsLongRunningTasks: false,
        maxBackgroundDuration: Duration.zero,
        requiresBatteryOptimizationWhitelist: false,
        supportsExactAlarms: false,
      );
    }
  }

  /// Get notification capabilities for current platform
  NotificationCapabilities _getNotificationCapabilities() {
    if (Platform.isAndroid || Platform.isIOS) {
      return NotificationCapabilities(
        isSupported: true,
        supportsScheduledNotifications: true,
        supportsActionButtons: Platform.isAndroid,
        supportsCustomSounds: true,
        supportsImages: Platform.isAndroid,
        supportsBadgeCount: Platform.isIOS,
        requiresPermission: Platform.isAndroid,
        maxScheduledNotifications: Platform.isIOS ? 64 : null,
      );
    } else {
      return const NotificationCapabilities(
        isSupported: false,
        supportsScheduledNotifications: false,
        supportsActionButtons: false,
        supportsCustomSounds: false,
        supportsImages: false,
        supportsBadgeCount: false,
        requiresPermission: false,
        maxScheduledNotifications: null,
      );
    }
  }

  /// Get platform-specific configuration recommendations
  Map<String, dynamic> getPlatformConfiguration() {
    final config = <String, dynamic>{
      'platform': Platform.operatingSystem,
      'version': Platform.operatingSystemVersion,
      'isSupported': Platform.isAndroid || Platform.isIOS,
    };

    if (Platform.isAndroid) {
      config.addAll({
        'speechListenDuration': const Duration(minutes: 5),
        'audioRecordingFormat': 'aac',
        'backgroundTasksEnabled': true,
        'notificationChannels': true,
        'permissionHandling': 'runtime',
      });
    } else if (Platform.isIOS) {
      config.addAll({
        'speechListenDuration': const Duration(seconds: 60),
        'audioRecordingFormat': 'aac',
        'backgroundTasksEnabled': false, // Limited background processing
        'notificationChannels': false,
        'permissionHandling': 'info_plist',
      });
    }

    return config;
  }

  /// Initialize platform-specific services with appropriate configurations
  Future<Map<String, bool>> initializePlatformServices() async {
    final results = <String, bool>{};
    
    try {
      // Initialize speech service
      if (isSpeechRecognitionSupported) {
        final speechService = createSpeechService();
        results['speechService'] = await speechService.initialize();
      } else {
        results['speechService'] = false;
      }

      // Initialize audio recording service
      if (isAudioRecordingSupported) {
        final audioService = createAudioRecordingService();
        results['audioRecordingService'] = await audioService.initialize();
      } else {
        results['audioRecordingService'] = false;
      }

      // Initialize background task service
      if (isBackgroundProcessingSupported) {
        final backgroundService = createBackgroundTaskService();
        results['backgroundTaskService'] = await backgroundService.initialize();
      } else {
        results['backgroundTaskService'] = false;
      }

      // Initialize notification service
      if (areNotificationsSupported) {
        final notificationService = createNotificationService();
        results['notificationService'] = await notificationService.initialize();
      } else {
        results['notificationService'] = false;
      }

      if (kDebugMode) {
        print('Platform services initialization results: $results');
      }

      return results;
    } catch (e) {
      if (kDebugMode) {
        print('Platform services initialization failed: $e');
      }
      return results;
    }
  }
}

/// Capabilities of speech recognition service on current platform
class SpeechRecognitionCapabilities {
  final bool isSupported;
  final Duration maxListenDuration;
  final bool supportsContinuousListening;
  final bool supportsPartialResults;
  final bool supportsMultipleLanguages;
  final bool supportsOfflineRecognition;
  final bool supportsConfidenceScoring;

  const SpeechRecognitionCapabilities({
    required this.isSupported,
    required this.maxListenDuration,
    required this.supportsContinuousListening,
    required this.supportsPartialResults,
    required this.supportsMultipleLanguages,
    required this.supportsOfflineRecognition,
    required this.supportsConfidenceScoring,
  });
}

/// Capabilities of audio recording service on current platform
class AudioRecordingCapabilities {
  final bool isSupported;
  final Duration maxRecordingDuration;
  final List<String> supportedFormats;
  final bool supportsBackgroundRecording;
  final bool requiresMicrophonePermission;
  final bool supportsAudioLevelMonitoring;

  const AudioRecordingCapabilities({
    required this.isSupported,
    required this.maxRecordingDuration,
    required this.supportedFormats,
    required this.supportsBackgroundRecording,
    required this.requiresMicrophonePermission,
    required this.supportsAudioLevelMonitoring,
  });
}

/// Capabilities of background processing service on current platform
class BackgroundProcessingCapabilities {
  final bool isSupported;
  final bool supportsPeriodicTasks;
  final bool supportsLongRunningTasks;
  final Duration maxBackgroundDuration;
  final bool requiresBatteryOptimizationWhitelist;
  final bool supportsExactAlarms;

  const BackgroundProcessingCapabilities({
    required this.isSupported,
    required this.supportsPeriodicTasks,
    required this.supportsLongRunningTasks,
    required this.maxBackgroundDuration,
    required this.requiresBatteryOptimizationWhitelist,
    required this.supportsExactAlarms,
  });
}

/// Capabilities of notification service on current platform
class NotificationCapabilities {
  final bool isSupported;
  final bool supportsScheduledNotifications;
  final bool supportsActionButtons;
  final bool supportsCustomSounds;
  final bool supportsImages;
  final bool supportsBadgeCount;
  final bool requiresPermission;
  final int? maxScheduledNotifications;

  const NotificationCapabilities({
    required this.isSupported,
    required this.supportsScheduledNotifications,
    required this.supportsActionButtons,
    required this.supportsCustomSounds,
    required this.supportsImages,
    required this.supportsBadgeCount,
    required this.requiresPermission,
    this.maxScheduledNotifications,
  });
}

/// Combined platform service capabilities
class PlatformServiceCapabilities {
  final SpeechRecognitionCapabilities speechRecognition;
  final AudioRecordingCapabilities audioRecording;
  final BackgroundProcessingCapabilities backgroundProcessing;
  final NotificationCapabilities notifications;

  const PlatformServiceCapabilities({
    required this.speechRecognition,
    required this.audioRecording,
    required this.backgroundProcessing,
    required this.notifications,
  });

  /// Get a summary of what's supported on this platform
  Map<String, bool> get supportSummary {
    return {
      'speechRecognition': speechRecognition.isSupported,
      'audioRecording': audioRecording.isSupported,
      'backgroundProcessing': backgroundProcessing.isSupported,
      'notifications': notifications.isSupported,
      'continuousSpeech': speechRecognition.supportsContinuousListening,
      'backgroundAudio': audioRecording.supportsBackgroundRecording,
      'periodicTasks': backgroundProcessing.supportsPeriodicTasks,
      'scheduledNotifications': notifications.supportsScheduledNotifications,
    };
  }
}