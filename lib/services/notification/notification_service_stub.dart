import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/task_model.dart';
import 'notification_service.dart';

/// Stub implementation of NotificationService when flutter_local_notifications is not available
class NotificationServiceStub implements NotificationService {
  @override
  Future<void> initialize() async {
    // No-op for stub
  }
  @override
  Future<bool> requestPermissions() async {
    return false; // Always false for stub
  }
  @override
  Future<bool> hasPermissions() async {
    return false; // Always false for stub
  }
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
  Future<void> scheduleTaskReminder(TaskModel task, DateTime reminderTime) async {
    // No-op for stub
    if (kDebugMode) {
      // print('Stub: Would schedule reminder for task: ${task.title} at $reminderTime');
    }
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
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return []; // Return empty list
  }
  void dispose() {
    // No-op for stub
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
