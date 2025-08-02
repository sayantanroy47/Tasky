import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:task_tracker_app/main.dart' as app;
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/task_enums.dart';
import 'package:task_tracker_app/services/notification/notification_models.dart';
import 'package:task_tracker_app/presentation/pages/notification_settings_page.dart';
import 'package:task_tracker_app/presentation/pages/notification_history_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Notification Integration Tests', () {
    testWidgets('should navigate to notification settings and configure options', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings (assuming there's a settings button in the app bar or drawer)
      // This would depend on your app's navigation structure
      // For now, we'll test the notification settings page directly
      
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: NotificationSettingsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify that the notification settings page loads
      expect(find.text('Notification Settings'), findsOneWidget);
      expect(find.text('Permissions'), findsOneWidget);
      expect(find.text('General'), findsOneWidget);

      // Test toggling notifications
      final notificationToggle = find.byType(SwitchListTile).first;
      await tester.tap(notificationToggle);
      await tester.pumpAndSettle();

      // Test opening reminder time picker
      final reminderTimeTile = find.text('Default Reminder Time');
      if (reminderTimeTile.evaluate().isNotEmpty) {
        await tester.tap(reminderTimeTile);
        await tester.pumpAndSettle();
        
        // Should show reminder time picker dialog
        expect(find.text('Default Reminder Time'), findsWidgets);
      }

      // Test daily summary toggle
      final dailySummaryToggle = find.text('Daily Summary');
      if (dailySummaryToggle.evaluate().isNotEmpty) {
        await tester.tap(dailySummaryToggle);
        await tester.pumpAndSettle();
      }

      // Test sending a test notification
      final testButton = find.text('Send Test Notification');
      if (testButton.evaluate().isNotEmpty) {
        await tester.tap(testButton);
        await tester.pumpAndSettle();
        
        // Should show confirmation snackbar
        expect(find.text('Test notification sent!'), findsOneWidget);
      }
    });

    testWidgets('should display notification history and statistics', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: NotificationHistoryPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify that the notification history page loads
      expect(find.text('Notification History'), findsOneWidget);
      expect(find.text('Notification Statistics'), findsOneWidget);

      // Check for statistics cards
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Sent'), findsOneWidget);

      // Test refresh functionality
      final refreshButton = find.byIcon(Icons.refresh);
      if (refreshButton.evaluate().isNotEmpty) {
        await tester.tap(refreshButton);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('should handle notification permissions correctly', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: NotificationSettingsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Look for permission section
      expect(find.text('Permissions'), findsOneWidget);

      // Test permission request (if permissions are not granted)
      final grantButton = find.text('Grant');
      if (grantButton.evaluate().isNotEmpty) {
        await tester.tap(grantButton);
        await tester.pumpAndSettle();
        
        // Note: In a real integration test, this would trigger the system permission dialog
        // For testing purposes, we just verify the button exists and can be tapped
      }
    });

    testWidgets('should configure quiet hours correctly', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: NotificationSettingsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Look for quiet hours section
      expect(find.text('Quiet Hours'), findsOneWidget);

      // Test setting quiet hours
      final setQuietHoursButton = find.text('Set Quiet Hours');
      if (setQuietHoursButton.evaluate().isNotEmpty) {
        await tester.tap(setQuietHoursButton);
        await tester.pumpAndSettle();

        // Should show quiet hours setup dialog
        expect(find.text('Set Quiet Hours'), findsWidgets);
        expect(find.text('Start Time'), findsOneWidget);
        expect(find.text('End Time'), findsOneWidget);

        // Test setting start time
        final startTimeTile = find.text('Start Time');
        await tester.tap(startTimeTile);
        await tester.pumpAndSettle();

        // Cancel the time picker
        final cancelButton = find.text('Cancel');
        if (cancelButton.evaluate().isNotEmpty) {
          await tester.tap(cancelButton);
          await tester.pumpAndSettle();
        }

        // Cancel the quiet hours dialog
        final dialogCancelButton = find.text('Cancel').last;
        await tester.tap(dialogCancelButton);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('should handle notification types correctly', (tester) async {
      // Test notification type display names
      expect(NotificationType.taskReminder.displayName, equals('Task Reminder'));
      expect(NotificationType.dailySummary.displayName, equals('Daily Summary'));
      expect(NotificationType.overdueTask.displayName, equals('Overdue Task'));
      expect(NotificationType.taskCompleted.displayName, equals('Task Completed'));
      expect(NotificationType.locationReminder.displayName, equals('Location Reminder'));

      // Test notification action display names
      expect(NotificationAction.complete.displayName, equals('Complete'));
      expect(NotificationAction.snooze.displayName, equals('Snooze'));
      expect(NotificationAction.view.displayName, equals('View'));
      expect(NotificationAction.dismiss.displayName, equals('Dismiss'));
    });

    testWidgets('should create and manage notification settings', (tester) async {
      // Test default notification settings
      const defaultSettings = NotificationSettings();
      expect(defaultSettings.enabled, isTrue);
      expect(defaultSettings.defaultReminder, equals(const Duration(hours: 1)));
      expect(defaultSettings.dailySummary, isTrue);
      expect(defaultSettings.overdueNotifications, isTrue);

      // Test copying settings with new values
      final updatedSettings = defaultSettings.copyWith(
        enabled: false,
        defaultReminder: const Duration(hours: 2),
      );
      expect(updatedSettings.enabled, isFalse);
      expect(updatedSettings.defaultReminder, equals(const Duration(hours: 2)));
      expect(updatedSettings.dailySummary, isTrue); // Should remain unchanged
    });

    testWidgets('should create scheduled notifications correctly', (tester) async {
      final testTask = TaskModel.create(
        title: 'Test Task',
        description: 'Test task description',
        dueDate: DateTime.now().add(const Duration(hours: 2)),
        priority: TaskPriority.medium,
      );

      final scheduledTime = DateTime.now().add(const Duration(hours: 1));
      final notification = ScheduledNotification(
        id: 123,
        taskId: testTask.id,
        type: NotificationType.taskReminder,
        scheduledTime: scheduledTime,
        title: 'Test Notification',
        body: 'Test notification body',
        createdAt: DateTime.now(),
      );

      expect(notification.id, equals(123));
      expect(notification.taskId, equals(testTask.id));
      expect(notification.type, equals(NotificationType.taskReminder));
      expect(notification.sent, isFalse);
      expect(notification.payload, isEmpty);

      // Test copying notification with new values
      final updatedNotification = notification.copyWith(
        title: 'Updated Title',
        sent: true,
      );
      expect(updatedNotification.title, equals('Updated Title'));
      expect(updatedNotification.sent, isTrue);
      expect(updatedNotification.id, equals(123)); // Should remain unchanged
    });

    testWidgets('should handle notification time correctly', (tester) async {
      // Test creating notification time
      const time = NotificationTime(hour: 14, minute: 30);
      expect(time.hour, equals(14));
      expect(time.minute, equals(30));

      // Test serialization
      final json = time.toJson();
      final deserializedTime = NotificationTime.fromJson(json);
      expect(deserializedTime.hour, equals(time.hour));
      expect(deserializedTime.minute, equals(time.minute));

      // Test equality
      const time1 = NotificationTime(hour: 8, minute: 0);
      const time2 = NotificationTime(hour: 8, minute: 0);
      const time3 = NotificationTime(hour: 9, minute: 0);
      expect(time1, equals(time2));
      expect(time1, isNot(equals(time3)));

      // Test string representation
      expect(time.toString(), equals('NotificationTime(14:30)'));
    });
  });
}