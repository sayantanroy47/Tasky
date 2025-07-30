import 'package:flutter_test/flutter_test.dart';

import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/task_enums.dart';
import 'package:task_tracker_app/services/notification/notification_models.dart';

void main() {
  group('NotificationManager', () {
    late TaskModel testTask;

    setUp(() {
      testTask = TaskModel.create(
        title: 'Test Task',
        description: 'Test task description',
        dueDate: DateTime.now().add(const Duration(hours: 2)),
        priority: TaskPriority.medium,
      );
    });

    group('notification models', () {
      test('should create notification settings with default values', () {
        const settings = NotificationSettings();
        
        expect(settings.enabled, isTrue);
        expect(settings.defaultReminder, equals(const Duration(hours: 1)));
        expect(settings.dailySummary, isTrue);
        expect(settings.overdueNotifications, isTrue);
        expect(settings.vibrate, isTrue);
      });

      test('should copy notification settings with new values', () {
        const originalSettings = NotificationSettings();
        final updatedSettings = originalSettings.copyWith(
          enabled: false,
          defaultReminder: const Duration(hours: 2),
        );

        expect(updatedSettings.enabled, isFalse);
        expect(updatedSettings.defaultReminder, equals(const Duration(hours: 2)));
        expect(updatedSettings.dailySummary, isTrue); // Should remain unchanged
      });

      test('should create scheduled notification correctly', () {
        final scheduledTime = DateTime.now().add(const Duration(hours: 1));
        final notification = ScheduledNotification(
          id: 123,
          taskId: testTask.id,
          type: NotificationType.taskReminder,
          scheduledTime: scheduledTime,
          title: 'Test Notification',
          body: 'Test body',
          createdAt: DateTime.now(),
        );

        expect(notification.id, equals(123));
        expect(notification.taskId, equals(testTask.id));
        expect(notification.type, equals(NotificationType.taskReminder));
        expect(notification.sent, isFalse);
      });
    });

    group('notification types', () {
      test('should have correct display names', () {
        expect(NotificationType.taskReminder.displayName, equals('Task Reminder'));
        expect(NotificationType.dailySummary.displayName, equals('Daily Summary'));
        expect(NotificationType.overdueTask.displayName, equals('Overdue Task'));
      });

      test('should have correct action display names', () {
        expect(NotificationAction.complete.displayName, equals('Complete'));
        expect(NotificationAction.snooze.displayName, equals('Snooze'));
        expect(NotificationAction.view.displayName, equals('View'));
      });
    });

    group('time of day', () {
      test('should create and format time correctly', () {
        const time = TimeOfDay(hour: 14, minute: 30);
        
        expect(time.hour, equals(14));
        expect(time.minute, equals(30));
        expect(time.toString(), equals('TimeOfDay(14:30)'));
      });

      test('should serialize and deserialize correctly', () {
        const originalTime = TimeOfDay(hour: 9, minute: 15);
        final json = originalTime.toJson();
        final deserializedTime = TimeOfDay.fromJson(json);

        expect(deserializedTime.hour, equals(originalTime.hour));
        expect(deserializedTime.minute, equals(originalTime.minute));
      });

      test('should compare times correctly', () {
        const time1 = TimeOfDay(hour: 8, minute: 0);
        const time2 = TimeOfDay(hour: 8, minute: 0);
        const time3 = TimeOfDay(hour: 9, minute: 0);

        expect(time1, equals(time2));
        expect(time1, isNot(equals(time3)));
      });
    });
  });
}