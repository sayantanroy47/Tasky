import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/task_model.dart';
import 'notification_service.dart';
import 'notification_models.dart';

/// Stub implementation of NotificationService when flutter_local_notifications is not available
class NotificationServiceStub implements NotificationService {
  final StreamController<NotificationEvent> _eventController = StreamController<NotificationEvent>.broadcast();

  @override
  Future<bool> initialize() async {
    return false; // Always false for stub
  }
  
  @override
  Future<bool> requestPermissions() async {
    return false; // Always false for stub
  }
  
  @override
  Future<bool> get hasPermissions async => false; // Always false for stub
  Future<void> showTaskNotification(TaskModel task) async {
    // No-op for stub
    if (kDebugMode) {
      // print('Stub: Would show notification for task: ${task.title}');
    }
  }
  Future<void> showTaskReminderNotification(TaskModel task) async {
    // No-op for stub
    if (kDebugMode) {
      // print('Stub: Would show reminder notification for task: ${task.title}');
    }
  }
  Future<void> showTaskOverdueNotification(TaskModel task) async {
    // No-op for stub
    if (kDebugMode) {
      // print('Stub: Would show overdue notification for task: ${task.title}');
    }
  }
  Future<void> showProgressNotification(String title, String body, int progress) async {
    // No-op for stub
    if (kDebugMode) {
      // print('Stub: Would show progress notification: $title - $progress%');
    }
  }
  Future<void> showSyncNotification(String message) async {
    // No-op for stub
    if (kDebugMode) {
      // print('Stub: Would show sync notification: $message');
    }
  }
  @override
  Future<int?> scheduleTaskReminder({
    required TaskModel task,
    required DateTime scheduledTime,
    Duration? customReminder,
  }) async {
    // No-op for stub
    if (kDebugMode) {
      // print('Stub: Would schedule reminder for task: ${task.title} at $scheduledTime');
    }
    return null;
  }
  Future<void> cancelTaskNotification(String taskId) async {
    // No-op for stub
    if (kDebugMode) {
      // print('Stub: Would cancel notification for task: $taskId');
    }
  }
  @override
  Future<void> cancelAllNotifications() async {
    // No-op for stub
    if (kDebugMode) {
      // print('Stub: Would cancel all notifications');
    }
  }

  @override
  Future<void> cancelNotification(int id) async {
    // No-op for stub
  }

  @override
  Future<void> cancelTaskNotifications(String taskId) async {
    // No-op for stub
  }

  @override
  Future<DateTime?> getNextNotificationTime(String taskId) async {
    return null;
  }

  @override
  Future<List<ScheduledNotification>> getScheduledNotifications() async {
    return [];
  }

  @override
  Future<void> rescheduleAllNotifications() async {
    // No-op for stub
  }

  @override
  Future<int?> scheduleNotification({
    required TaskModel task,
    required DateTime scheduledTime,
    Duration? customReminder,
  }) async {
    // No-op for stub
    return null;
  }

  @override
  Future<void> showNotification({
    required String title,
    required String body,
    String? taskId,
    NotificationTypeModel type = NotificationTypeModel.taskReminder,
    Map<String, dynamic>? payload,
  }) async {
    // No-op for stub
  }

  Future<void> scheduleRecurringNotification({
    required int id,
    required String title,
    required String body,
    required DateTime firstScheduledTime,
    required Duration interval,
    String? payload,
  }) async {
    // No-op for stub
  }

  Future<bool> shouldShowNotification() async {
    return false;
  }

  @override
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? taskId,
    NotificationTypeModel type = NotificationTypeModel.taskReminder,
    Map<String, dynamic>? payload,
  }) async {
    // No-op for stub
  }

  @override
  Future<List<int>> scheduleMultipleReminders({
    required TaskModel task,
    required List<Duration> reminderIntervals,
  }) async {
    return [];
  }

  @override
  Future<int?> scheduleDailySummary({
    required DateTime scheduledTime,
    required List<TaskModel> tasks,
  }) async {
    return null;
  }

  @override
  Future<int?> scheduleOverdueNotification({
    required TaskModel task,
  }) async {
    return null;
  }

  @override
  Future<List<ScheduledNotification>> getTaskNotifications(String taskId) async {
    return [];
  }

  @override
  Future<void> handleNotificationAction({
    required String taskId,
    required NotificationAction action,
    Map<String, dynamic>? payload,
  }) async {
    // No-op for stub
  }

  @override
  Future<void> updateSettings(NotificationSettings settings) async {
    // No-op for stub
  }

  @override
  Future<NotificationSettings> getSettings() async {
    return const NotificationSettings();
  }

  @override
  Future<bool> shouldSendNotification(DateTime scheduledTime) async {
    return false;
  }

  @override
  Stream<NotificationEvent> get notificationEvents => _eventController.stream;

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return []; // Return empty list
  }
  
  void dispose() {
    _eventController.close();
  }
}

/// Stub class for PendingNotificationRequest
class PendingNotificationRequest {
  final int id;
  final String? title;
  final String? body;
  final String? payload;

  PendingNotificationRequest({
    required this.id,
    this.title,
    this.body,
    this.payload,
  });
}


