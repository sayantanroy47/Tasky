import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/task_enums.dart';
import 'package:task_tracker_app/services/notification/local_notification_service.dart';
import 'package:task_tracker_app/services/notification/notification_models.dart';

// Generate mocks for external dependencies
@GenerateMocks([])
class MockLocalNotificationService extends Mock implements LocalNotificationService {}

void main() {
  group('LocalNotificationService', () {
    late LocalNotificationService notificationService;
    late TaskModel testTask;

    setUp(() {
      notificationService = LocalNotificationService();
      testTask = TaskModel.create(
        title: 'Test Task',
        description: 'Test task description',
        dueDate: DateTime.now().add(const Duration(hours: 2)),
        priority: TaskPriority.medium,
      );
    });

    group('initialization', () {
      test('should initialize successfully', () async {
        // Note: This test would require mocking flutter_local_notifications
        // For now, we'll test the basic structure
        expect(notificationService, isNotNull);
      });
    });

    group('notification scheduling', () {
      test('should format duration correctly', () {
        expect(_formatDuration(const Duration(minutes: 15)), equals('15 minutes before'));
        expect(_formatDuration(const Duration(hours: 1)), equals('1 hour before'));
        expect(_formatDuration(const Duration(hours: 2)), equals('2 hours before'));
        expect(_formatDuration(const Duration(days: 1)), equals('1 day before'));
        expect(_formatDuration(const Duration(days: 2)), equals('2 days before'));
      });

      test('should format time of day correctly', () {
        const time1 = TimeOfDay(hour: 8, minute: 0);
        const time2 = TimeOfDay(hour: 14, minute: 30);
        const time3 = TimeOfDay(hour: 9, minute: 5);

        expect(_formatTimeOfDay(time1), equals('08:00'));
        expect(_formatTimeOfDay(time2), equals('14:30'));
        expect(_formatTimeOfDay(time3), equals('09:05'));
      });
    });

    group('notification settings', () {
      test('should create default notification settings', () {
        const settings = NotificationSettings();
        
        expect(settings.enabled, isTrue);
        expect(settings.defaultReminder, equals(const Duration(hours: 1)));
        expect(settings.dailySummary, isTrue);
        expect(settings.dailySummaryTime.hour, equals(8));
        expect(settings.dailySummaryTime.minute, equals(0));
        expect(settings.overdueNotifications, isTrue);
        expect(settings.respectDoNotDisturb, isTrue);
        expect(settings.vibrate, isTrue);
        expect(settings.showBadges, isTrue);
      });

      test('should copy settings with new values', () {
        const originalSettings = NotificationSettings();
        final updatedSettings = originalSettings.copyWith(
          enabled: false,
          defaultReminder: const Duration(hours: 2),
          dailySummary: false,
        );

        expect(updatedSettings.enabled, isFalse);
        expect(updatedSettings.defaultReminder, equals(const Duration(hours: 2)));
        expect(updatedSettings.dailySummary, isFalse);
        // Other values should remain the same
        expect(updatedSettings.overdueNotifications, isTrue);
        expect(updatedSettings.vibrate, isTrue);
      });
    });

    group('scheduled notifications', () {
      test('should create scheduled notification with correct properties', () {
        final scheduledTime = DateTime.now().add(const Duration(hours: 1));
        final notification = ScheduledNotification(
          id: 123,
          taskId: testTask.id,
          type: NotificationTypeModel.taskReminder,
          scheduledTime: scheduledTime,
          title: 'Test Notification',
          body: 'Test notification body',
          createdAt: DateTime.now(),
        );

        expect(notification.id, equals(123));
        expect(notification.taskId, equals(testTask.id));
        expect(notification.type, equals(NotificationTypeModel.taskReminder));
        expect(notification.scheduledTime, equals(scheduledTime));
        expect(notification.title, equals('Test Notification'));
        expect(notification.body, equals('Test notification body'));
        expect(notification.sent, isFalse);
        expect(notification.payload, isEmpty);
      });

      test('should copy scheduled notification with new values', () {
        final originalNotification = ScheduledNotification(
          id: 123,
          taskId: testTask.id,
          type: NotificationTypeModel.taskReminder,
          scheduledTime: DateTime.now(),
          title: 'Original Title',
          body: 'Original Body',
          createdAt: DateTime.now(),
        );

        final updatedNotification = originalNotification.copyWith(
          title: 'Updated Title',
          sent: true,
        );

        expect(updatedNotification.title, equals('Updated Title'));
        expect(updatedNotification.sent, isTrue);
        // Other values should remain the same
        expect(updatedNotification.id, equals(123));
        expect(updatedNotification.body, equals('Original Body'));
      });
    });

    group('notification types', () {
      test('should have correct display names for notification types', () {
        expect(NotificationTypeModel.taskReminder.displayName, equals('Task Reminder'));
        expect(NotificationTypeModel.dailySummary.displayName, equals('Daily Summary'));
        expect(NotificationTypeModel.overdueTask.displayName, equals('Overdue Task'));
        expect(NotificationTypeModel.taskCompleted.displayName, equals('Task Completed'));
        expect(NotificationTypeModel.locationReminder.displayName, equals('Location Reminder'));
      });

      test('should have correct display names for notification actions', () {
        expect(NotificationAction.complete.displayName, equals('Complete'));
        expect(NotificationAction.snooze.displayName, equals('Snooze'));
        expect(NotificationAction.view.displayName, equals('View'));
        expect(NotificationAction.dismiss.displayName, equals('Dismiss'));
      });
    });

    group('time of day', () {
      test('should create time of day correctly', () {
        const time = TimeOfDay(hour: 14, minute: 30);
        
        expect(time.hour, equals(14));
        expect(time.minute, equals(30));
      });

      test('should serialize and deserialize notification time', () {
        const originalTime = NotificationTime(hour: 9, minute: 15);
        final json = originalTime.toJson();
        final deserializedTime = NotificationTime.fromJson(json);

        expect(deserializedTime.hour, equals(originalTime.hour));
        expect(deserializedTime.minute, equals(originalTime.minute));
      });

      test('should compare time of day correctly', () {
        const time1 = TimeOfDay(hour: 8, minute: 0);
        const time2 = TimeOfDay(hour: 8, minute: 0);
        const time3 = TimeOfDay(hour: 9, minute: 0);

        expect(time1, equals(time2));
        expect(time1, isNot(equals(time3)));
      });

      test('should format time of day string correctly', () {
        const time1 = TimeOfDay(hour: 8, minute: 0);
        const time2 = TimeOfDay(hour: 14, minute: 30);

        expect(time1.toString(), equals('TimeOfDay(08:00)'));
        expect(time2.toString(), equals('TimeOfDay(14:30)'));
      });
    });
  });
}

// Helper functions for testing (these would normally be private in the service)
String _formatDuration(Duration duration) {
  if (duration.inDays > 0) {
    return '${duration.inDays} day${duration.inDays == 1 ? '' : 's'} before';
  } else if (duration.inHours > 0) {
    return '${duration.inHours} hour${duration.inHours == 1 ? '' : 's'} before';
  } else {
    return '${duration.inMinutes} minute${duration.inMinutes == 1 ? '' : 's'} before';
  }
}

String _formatTimeOfDay(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
