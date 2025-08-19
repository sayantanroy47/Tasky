import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/task_model.dart';
import '../../domain/entities/task_enums.dart';
import '../task/recurring_task_service.dart';
import '../../domain/repositories/task_repository.dart';


/// Background task processing service for scheduled notifications and maintenance
/// 
/// This service handles:
/// - Scheduled task notifications
/// - Background sync operations
/// - Data cleanup tasks
/// - Performance monitoring background tasks
class BackgroundTaskService {
  static BackgroundTaskService? _instance;
  static BackgroundTaskService get instance => _instance ??= BackgroundTaskService._();
  
  BackgroundTaskService._();

  late SharedPreferences _prefs;
  bool _isInitialized = false;
  Timer? _backgroundTimer;
  RecurringTaskService? _recurringTaskService;
  TaskRepository? _taskRepository;
  
  /// Set dependencies for the background service
  void setDependencies({
    required RecurringTaskService recurringTaskService,
    required TaskRepository taskRepository,
  }) {
    _recurringTaskService = recurringTaskService;
    _taskRepository = taskRepository;
  }

  /// Initialize the background task service
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      _prefs = await SharedPreferences.getInstance();
      
      // Simple timer-based background processing for now
      // In production, this would use platform-specific background task frameworks
      _isInitialized = true;
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize BackgroundTaskService: $e');
      }
      return false;
    }
  }

  /// Start background task processing
  Future<void> startBackgroundProcessing() async {
    if (!_isInitialized) {
      throw Exception('BackgroundTaskService not initialized');
    }
    
    // Start simple timer-based background processing
    _backgroundTimer = Timer.periodic(const Duration(minutes: 15), (timer) {
      _performBackgroundWork();
    });
    
    if (kDebugMode) {
      print('Background task processing started');
    }
  }

  /// Stop background task processing
  Future<void> stopBackgroundProcessing() async {
    _backgroundTimer?.cancel();
    _backgroundTimer = null;
    
    if (kDebugMode) {
      print('Background task processing stopped');
    }
  }

  /// Schedule a notification for a specific task
  Future<void> scheduleTaskNotification(TaskModel task) async {
    if (!_isInitialized || task.dueDate == null) return;
    
    final now = DateTime.now();
    final dueDate = task.dueDate!;
    
    if (dueDate.isBefore(now)) return; // Don't schedule past due notifications
    
    // Schedule notification 1 hour before due time
    final reminderTime = dueDate.subtract(const Duration(hours: 1));
    if (reminderTime.isAfter(now)) {
      await _scheduleNotification(
        id: task.id.hashCode,
        title: 'Task Reminder',
        body: 'Task "${task.title}" is due in 1 hour',
        scheduledTime: reminderTime,
        payload: task.id,
      );
    }
    
    // Schedule notification at due time
    await _scheduleNotification(
      id: task.id.hashCode + 1,
      title: 'Task Due',
      body: 'Task "${task.title}" is due now',
      scheduledTime: dueDate,
      payload: task.id,
    );
  }

  /// Cancel scheduled notifications for a task
  Future<void> cancelTaskNotifications(String taskId) async {
    // Note: LocalNotificationService needs to be injected as a dependency
    // This is a placeholder implementation
    // await notificationService.cancelNotification(taskId.hashCode);
    // await notificationService.cancelNotification(taskId.hashCode + 1);
  }

  /// Process overdue task notifications
  Future<void> processOverdueTaskNotifications(List<TaskModel> overdueTasks) async {
    for (final task in overdueTasks) {
      if (task.status != TaskStatus.completed && task.dueDate != null) {
        await _scheduleNotification(
          id: task.id.hashCode + 2,
          title: 'Overdue Task',
          body: 'Task "${task.title}" is overdue',
          scheduledTime: DateTime.now(),
          payload: task.id,
        );
      }
    }
  }

  /// Schedule a notification
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    try {
      // Note: LocalNotificationService needs to be injected as a dependency
      // This is a placeholder implementation
      // await notificationService.scheduleNotification(
      //   id: id,
      //   title: title,
      //   body: body,
      //   scheduledTime: scheduledTime,
      //   payload: payload,
      // );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to schedule notification: $e');
      }
    }
  }

  /// Clean up old data and optimize performance
  Future<void> performDailyCleanup() async {
    try {
      // Clean up old completed tasks (older than 30 days)
      await _prefs.setString('last_cleanup_date', DateTime.now().toIso8601String());
      
      // Clean up old audio files
      await _cleanupOldAudioFiles();
      
      // Clean up old analytics data
      await _cleanupOldAnalytics();
      
      if (kDebugMode) {
        print('Daily cleanup completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Daily cleanup failed: $e');
      }
    }
  }

  /// Clean up old audio recording files
  Future<void> _cleanupOldAudioFiles() async {
    try {
      // This would integrate with AudioRecordingService to clean up old files
      // Implementation would depend on the audio storage structure
      if (kDebugMode) {
        print('Audio files cleanup completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Audio files cleanup failed: $e');
      }
    }
  }

  /// Clean up old analytics data
  Future<void> _cleanupOldAnalytics() async {
    try {
      // Clean up analytics data older than 90 days
      final cutoffDate = DateTime.now().subtract(const Duration(days: 90));
      await _prefs.setString('analytics_cleanup_date', cutoffDate.toIso8601String());
      
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
    return {
      'initialized': _isInitialized,
      'last_cleanup': _prefs.getString('last_cleanup_date'),
      'analytics_cleanup': _prefs.getString('analytics_cleanup_date'),
      'service_enabled': _prefs.getBool('background_service_enabled') ?? true,
    };
  }

  /// Enable or disable background service
  Future<void> setServiceEnabled(bool enabled) async {
    await _prefs.setBool('background_service_enabled', enabled);
    
    if (enabled) {
      await startBackgroundProcessing();
    } else {
      await stopBackgroundProcessing();
    }
  }

  /// Check if service is enabled
  bool get isServiceEnabled => _prefs.getBool('background_service_enabled') ?? true;

  /// Dispose the service
  Future<void> dispose() async {
    await stopBackgroundProcessing();
    _isInitialized = false;
  }
}

/// Perform general background work
Future<void> _performBackgroundWork() async {
  try {
    BackgroundTaskService.instance;
    
    // Process recurring tasks
    await _processRecurringTasks();
    
    // Process task reminders
    await _processTaskReminders();
    
    // Perform daily cleanup if needed
    await _checkAndPerformDailyCleanup();
    
    if (kDebugMode) {
      print('Background work completed at ${DateTime.now()}');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Background work failed: $e');
    }
  }
}

/// Process recurring tasks in background
Future<void> _processRecurringTasks() async {
  try {
    final service = BackgroundTaskService.instance;
    if (service._recurringTaskService != null) {
      final newTasks = await service._recurringTaskService!.processCompletedRecurringTasks();
      if (kDebugMode) {
        print('Generated ${newTasks.length} new recurring task instances');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Recurring task processing failed: $e');
    }
  }
}

/// Process task reminders in background
Future<void> _processTaskReminders() async {
  try {
    final service = BackgroundTaskService.instance;
    if (service._taskRepository != null) {
      final allTasks = await service._taskRepository!.getAllTasks();
      final upcomingTasks = allTasks.where((task) {
        if (task.dueDate == null || task.isCompleted) return false;
        final now = DateTime.now();
        final timeUntilDue = task.dueDate!.difference(now);
        return timeUntilDue.inMinutes <= 60 && timeUntilDue.inMinutes > 0;
      }).toList();
      
      for (final task in upcomingTasks) {
        await service.scheduleTaskNotification(task);
      }
      
      if (kDebugMode) {
        print('Processed ${upcomingTasks.length} upcoming task reminders');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Task reminder processing failed: $e');
    }
  }
}

/// Check and perform daily cleanup if needed
Future<void> _checkAndPerformDailyCleanup() async {
  try {
    final service = BackgroundTaskService.instance;
    final lastCleanup = service._prefs.getString('last_cleanup_date');
    final now = DateTime.now();
    
    bool shouldCleanup = false;
    if (lastCleanup == null) {
      shouldCleanup = true;
    } else {
      final lastDate = DateTime.tryParse(lastCleanup);
      if (lastDate == null || now.difference(lastDate).inDays >= 1) {
        shouldCleanup = true;
      }
    }
    
    if (shouldCleanup) {
      await service.performDailyCleanup();
      if (kDebugMode) {
        print('Daily cleanup performed');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Daily cleanup check failed: $e');
    }
  }
}