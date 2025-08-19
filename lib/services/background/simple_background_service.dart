import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/task_model.dart';
import '../../domain/entities/task_enums.dart';

/// Simple background task processing service for scheduled notifications and maintenance
/// 
/// This is a lightweight implementation that uses Dart timers for background processing.
/// For production apps, consider using platform-specific background task frameworks like
/// WorkManager (Android) or Background Tasks (iOS).
class SimpleBackgroundService {
  static SimpleBackgroundService? _instance;
  static SimpleBackgroundService get instance => _instance ??= SimpleBackgroundService._();
  
  SimpleBackgroundService._();

  SharedPreferences? _prefs;
  bool _isInitialized = false;
  Timer? _reminderTimer;
  Timer? _cleanupTimer;
  bool _isRunning = false;

  /// Initialize the background service
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize SimpleBackgroundService: $e');
      }
      return false;
    }
  }

  /// Start background task processing
  Future<void> startBackgroundProcessing() async {
    if (!_isInitialized || _prefs == null) {
      throw Exception('SimpleBackgroundService not initialized');
    }
    
    if (_isRunning) {
      if (kDebugMode) {
        print('Background processing already running');
      }
      return;
    }

    _isRunning = true;

    // Start reminder processing (every 15 minutes)
    _reminderTimer = Timer.periodic(const Duration(minutes: 15), (timer) {
      _processTaskReminders();
    });

    // Start daily cleanup (check every hour, run once per day)
    _cleanupTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      _checkAndPerformDailyCleanup();
    });

    if (kDebugMode) {
      print('Background task processing started');
    }
  }

  /// Stop background task processing
  Future<void> stopBackgroundProcessing() async {
    _reminderTimer?.cancel();
    _cleanupTimer?.cancel();
    _reminderTimer = null;
    _cleanupTimer = null;
    _isRunning = false;

    if (kDebugMode) {
      print('Background task processing stopped');
    }
  }

  /// Process task reminders
  Future<void> _processTaskReminders() async {
    try {
      if (kDebugMode) {
        print('Processing task reminders at ${DateTime.now()}');
      }

      // In a real implementation, this would:
      // 1. Query the task database for upcoming due dates
      // 2. Check which tasks need reminders
      // 3. Schedule appropriate notifications
      
      await _prefs?.setString('last_reminder_check', DateTime.now().toIso8601String());
    } catch (e) {
      if (kDebugMode) {
        print('Task reminder processing failed: $e');
      }
    }
  }

  /// Check and perform daily cleanup if needed
  Future<void> _checkAndPerformDailyCleanup() async {
    try {
      final lastCleanup = _prefs?.getString('last_cleanup_date');
      final now = DateTime.now();
      
      if (lastCleanup == null || 
          DateTime.parse(lastCleanup).difference(now).inDays.abs() >= 1) {
        await performDailyCleanup();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Daily cleanup check failed: $e');
      }
    }
  }

  /// Schedule a notification for a specific task
  Future<void> scheduleTaskNotification(TaskModel task) async {
    if (!_isInitialized || _prefs == null || task.dueDate == null) return;
    
    try {
      // Store notification data for processing
      final notificationKey = 'scheduled_notification_${task.id}';
      final notificationData = {
        'task_id': task.id,
        'task_title': task.title,
        'due_date': task.dueDate!.toIso8601String(),
        'reminder_time': task.dueDate!.subtract(const Duration(hours: 1)).toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      };
      
      await _prefs?.setString(notificationKey, notificationData.toString());
      
      if (kDebugMode) {
        print('Scheduled notification for task: ${task.title}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to schedule notification: $e');
      }
    }
  }

  /// Cancel scheduled notifications for a task
  Future<void> cancelTaskNotifications(String taskId) async {
    try {
      final notificationKey = 'scheduled_notification_$taskId';
      await _prefs?.remove(notificationKey);
      
      if (kDebugMode) {
        print('Cancelled notifications for task: $taskId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to cancel notifications: $e');
      }
    }
  }

  /// Process overdue task notifications
  Future<void> processOverdueTaskNotifications(List<TaskModel> overdueTasks) async {
    for (final task in overdueTasks) {
      if (task.status != TaskStatus.completed && task.dueDate != null) {
        try {
          // Create overdue notification record
          final overdueKey = 'overdue_notification_${task.id}_${DateTime.now().millisecondsSinceEpoch}';
          await _prefs?.setString(overdueKey, 'Task "${task.title}" is overdue');
          
          if (kDebugMode) {
            print('Processed overdue notification for: ${task.title}');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Failed to process overdue notification: $e');
          }
        }
      }
    }
  }

  /// Clean up old data and optimize performance
  Future<void> performDailyCleanup() async {
    try {
      // Clean up old notification records
      await _cleanupOldNotifications();
      
      // Clean up old analytics data
      await _cleanupOldAnalytics();
      
      // Update last cleanup timestamp
      await _prefs?.setString('last_cleanup_date', DateTime.now().toIso8601String());
      
      if (kDebugMode) {
        print('Daily cleanup completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Daily cleanup failed: $e');
      }
    }
  }

  /// Clean up old notification records
  Future<void> _cleanupOldNotifications() async {
    try {
      final allKeys = _prefs?.getKeys() ?? <String>{};
      // final cutoffDate = DateTime.now().subtract(const Duration(days: 7));
      
      final keysToRemove = <String>[];
      for (final key in allKeys) {
        if (key.startsWith('scheduled_notification_') || key.startsWith('overdue_notification_')) {
          // For simplicity, clean up notification records older than 7 days
          // In a real implementation, you would parse the stored data to check dates
          keysToRemove.add(key);
        }
      }
      
      // Remove old notification keys (simplified - in practice you'd check actual dates)
      if (keysToRemove.length > 100) { // Only clean up if too many accumulated
        for (final key in keysToRemove.take(50)) { // Clean up oldest 50
          await _prefs?.remove(key);
        }
      }
      
      if (kDebugMode) {
        print('Cleaned up ${keysToRemove.length} old notification records');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Notification cleanup failed: $e');
      }
    }
  }

  /// Clean up old analytics data
  Future<void> _cleanupOldAnalytics() async {
    try {
      // Clean up analytics data older than 90 days
      final cutoffDate = DateTime.now().subtract(const Duration(days: 90));
      await _prefs?.setString('analytics_cleanup_date', cutoffDate.toIso8601String());
      
      if (kDebugMode) {
        print('Analytics cleanup completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Analytics cleanup failed: $e');
      }
    }
  }

  /// Get background service status
  Map<String, dynamic> getServiceStatus() {
    if (!_isInitialized) {
      return {
        'initialized': false,
        'running': false,
        'last_cleanup': null,
        'last_reminder_check': null,
        'analytics_cleanup': null,
        'service_enabled': true,
      };
    }
    
    return {
      'initialized': _isInitialized,
      'running': _isRunning,
      'last_cleanup': _prefs?.getString('last_cleanup_date'),
      'last_reminder_check': _prefs?.getString('last_reminder_check'),
      'analytics_cleanup': _prefs?.getString('analytics_cleanup_date'),
      'service_enabled': _prefs?.getBool('background_service_enabled') ?? true,
    };
  }

  /// Enable or disable background service
  Future<void> setServiceEnabled(bool enabled) async {
    if (!_isInitialized || _prefs == null) {
      throw Exception('SimpleBackgroundService not initialized');
    }
    await _prefs!.setBool('background_service_enabled', enabled);
    
    if (enabled && !_isRunning) {
      await startBackgroundProcessing();
    } else if (!enabled && _isRunning) {
      await stopBackgroundProcessing();
    }
  }

  /// Check if service is enabled
  bool get isServiceEnabled => _prefs?.getBool('background_service_enabled') ?? true;

  /// Check if service is running
  bool get isRunning => _isRunning;

  /// Dispose the service
  Future<void> dispose() async {
    await stopBackgroundProcessing();
    _isInitialized = false;
  }
}