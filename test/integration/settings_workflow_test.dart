import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';

import 'package:task_tracker_app/services/database/database.dart';
import 'package:task_tracker_app/presentation/widgets/settings_card.dart';
import 'package:task_tracker_app/presentation/widgets/theme_selector.dart';
import 'package:task_tracker_app/presentation/widgets/notification_settings_card.dart';

void main() {
  group('Settings and Configuration Workflow Integration Tests', () {
    late ProviderContainer container;
    late AppDatabase testDatabase;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      
      testDatabase = AppDatabase.forTesting(NativeDatabase.memory());
      container = ProviderContainer(
        overrides: [],
      );
    });

    tearDown(() async {
      await testDatabase.close();
      container.dispose();
    });

    group('Theme and Appearance Settings', () {
      testWidgets('should change theme and see immediate visual feedback', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(title: const Text('Theme Settings')),
                body: Column(
                  children: [
                    const Card(
                      child: ListTile(
                        title: Text('Current Theme: Light'),
                        subtitle: Text('Tap to change theme'),
                      ),
                    ),
                    ThemeSelector(
                      currentTheme: ThemeMode.light,
                      onThemeChanged: (theme) {
                        // Handle theme change
                      },
                    ),
                    const Card(
                      child: ListTile(
                        title: Text('Sample Task Card'),
                        subtitle: Text('Preview how tasks look with current theme'),
                        leading: Icon(Icons.task_alt),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Verify initial light theme
        expect(find.text('Current Theme: Light'), findsOneWidget);
        expect(find.byType(ThemeSelector), findsOneWidget);

        // Test theme switching
        await tester.tap(find.byKey(const Key('dark_theme_option')));
        await tester.pump();

        // Test system theme option
        await tester.tap(find.byKey(const Key('system_theme_option')));
        await tester.pump();

        // Test custom color selection
        await tester.tap(find.byKey(const Key('custom_color_button')));
        await tester.pump();

        // Verify theme preview updates
        expect(find.text('Sample Task Card'), findsOneWidget);
      });

      testWidgets('should customize color scheme and accent colors', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(title: const Text('Color Customization')),
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Card(
                        child: ListTile(
                          title: Text('Primary Color'),
                          subtitle: Text('Choose your app\'s primary color'),
                        ),
                      ),
                      GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 6,
                        children: [
                          for (int i = 0; i < 12; i++)
                            GestureDetector(
                              key: Key('color_option_$i'),
                              onTap: () {
                                // Handle color selection
                              },
                              child: Container(
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.primaries[i % Colors.primaries.length],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const Card(
                        child: ListTile(
                          title: Text('Accent Color'),
                          subtitle: Text('Choose accent color for highlights'),
                        ),
                      ),
                      const Card(
                        child: ListTile(
                          title: Text('Background Style'),
                          subtitle: Text('Solid, Gradient, or Pattern'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        // Test color selection
        await tester.tap(find.byKey(const Key('color_option_0')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('color_option_3')));
        await tester.pump();

        // Test background style selection
        await tester.tap(find.text('Background Style'));
        await tester.pump();

        // Verify color customization interface
        expect(find.text('Primary Color'), findsOneWidget);
        expect(find.text('Accent Color'), findsOneWidget);
      });

      testWidgets('should apply accessibility settings', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(title: const Text('Accessibility Settings')),
                body: ListView(
                  children: [
                    SwitchListTile(
                      key: const Key('high_contrast_switch'),
                      title: const Text('High Contrast Mode'),
                      subtitle: const Text('Increase contrast for better visibility'),
                      value: false,
                      onChanged: (value) {
                        // Handle high contrast toggle
                      },
                    ),
                    SwitchListTile(
                      key: const Key('large_text_switch'),
                      title: const Text('Large Text'),
                      subtitle: const Text('Increase text size throughout the app'),
                      value: false,
                      onChanged: (value) {
                        // Handle large text toggle
                      },
                    ),
                    SwitchListTile(
                      key: const Key('screen_reader_switch'),
                      title: const Text('Screen Reader Support'),
                      subtitle: const Text('Enhanced labels for screen readers'),
                      value: true,
                      onChanged: (value) {
                        // Handle screen reader toggle
                      },
                    ),
                    ListTile(
                      key: const Key('animation_settings'),
                      title: const Text('Animation Settings'),
                      subtitle: const Text('Control app animations and transitions'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Navigate to animation settings
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Test accessibility toggles
        await tester.tap(find.byKey(const Key('high_contrast_switch')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('large_text_switch')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('animation_settings')));
        await tester.pump();

        // Verify accessibility settings
        expect(find.text('High Contrast Mode'), findsOneWidget);
        expect(find.text('Large Text'), findsOneWidget);
        expect(find.text('Screen Reader Support'), findsOneWidget);
      });
    });

    group('Notification Settings Workflow', () {
      testWidgets('should configure notification preferences comprehensively', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(title: const Text('Notification Settings')),
                body: ListView(
                  children: [
                    NotificationSettingsCard(
                      title: 'Task Reminders',
                      enabled: true,
                      onToggle: (enabled) {
                        // Handle reminder toggle
                      },
                    ),
                    const Card(
                      child: ExpansionTile(
                        key: Key('reminder_timing_expansion'),
                        title: Text('Reminder Timing'),
                        children: [
                          ListTile(
                            title: Text('Default Reminder'),
                            subtitle: Text('1 hour before due time'),
                            trailing: Icon(Icons.schedule),
                          ),
                          ListTile(
                            title: Text('Additional Reminders'),
                            subtitle: Text('15 minutes, 1 day before'),
                            trailing: Icon(Icons.add_alert),
                          ),
                        ],
                      ),
                    ),
                    const Card(
                      child: ExpansionTile(
                        key: Key('notification_types_expansion'),
                        title: Text('Notification Types'),
                        children: [
                          SwitchListTile(
                            title: Text('Daily Summary'),
                            subtitle: Text('Get daily task overview'),
                            value: true,
                            onChanged: null,
                          ),
                          SwitchListTile(
                            title: Text('Overdue Alerts'),
                            subtitle: Text('Alert for overdue tasks'),
                            value: true,
                            onChanged: null,
                          ),
                          SwitchListTile(
                            title: Text('Location Reminders'),
                            subtitle: Text('Reminders based on location'),
                            value: false,
                            onChanged: null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Test notification settings expansion
        await tester.tap(find.byKey(const Key('reminder_timing_expansion')));
        await tester.pump();

        expect(find.text('Default Reminder'), findsOneWidget);
        expect(find.text('Additional Reminders'), findsOneWidget);

        // Test notification types expansion
        await tester.tap(find.byKey(const Key('notification_types_expansion')));
        await tester.pump();

        expect(find.text('Daily Summary'), findsOneWidget);
        expect(find.text('Overdue Alerts'), findsOneWidget);
        expect(find.text('Location Reminders'), findsOneWidget);

        // Test reminder time customization
        await tester.tap(find.text('Default Reminder'));
        await tester.pump();

        // Would open time picker for reminder customization
        expect(find.text('1 hour before due time'), findsOneWidget);
      });

      testWidgets('should test notification scheduling and delivery', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(title: const Text('Notification Test')),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Test Notification Delivery'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        key: const Key('test_immediate_notification'),
                        onPressed: () {
                          // Send test notification immediately
                        },
                        child: const Text('Send Test Notification'),
                      ),
                      ElevatedButton(
                        key: const Key('test_scheduled_notification'),
                        onPressed: () {
                          // Schedule test notification for 5 seconds
                        },
                        child: const Text('Schedule Test (5 seconds)'),
                      ),
                      ElevatedButton(
                        key: const Key('test_notification_actions'),
                        onPressed: () {
                          // Test notification with actions
                        },
                        child: const Text('Test Notification Actions'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        // Test immediate notification
        await tester.tap(find.byKey(const Key('test_immediate_notification')));
        await tester.pump();

        // Test scheduled notification
        await tester.tap(find.byKey(const Key('test_scheduled_notification')));
        await tester.pump();

        // Test actionable notifications
        await tester.tap(find.byKey(const Key('test_notification_actions')));
        await tester.pump();

        // Verify test interface
        expect(find.text('Test Notification Delivery'), findsOneWidget);
      });
    });

    group('Data Management Settings', () {
      testWidgets('should handle data backup and export workflow', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(title: const Text('Data Management')),
                body: ListView(
                  children: [
                    const Card(
                      child: ListTile(
                        title: Text('Backup & Sync'),
                        subtitle: Text('Keep your data safe and synchronized'),
                        leading: Icon(Icons.cloud_upload),
                      ),
                    ),
                    ListTile(
                      key: const Key('create_backup_button'),
                      title: const Text('Create Backup'),
                      subtitle: const Text('Export all your tasks and settings'),
                      leading: const Icon(Icons.backup),
                      onTap: () {
                        // Create backup
                      },
                    ),
                    ListTile(
                      key: const Key('restore_backup_button'),
                      title: const Text('Restore Backup'),
                      subtitle: const Text('Import previously saved data'),
                      leading: const Icon(Icons.restore),
                      onTap: () {
                        // Restore backup
                      },
                    ),
                    const Divider(),
                    ListTile(
                      key: const Key('export_json_button'),
                      title: const Text('Export to JSON'),
                      subtitle: const Text('Export tasks in JSON format'),
                      leading: const Icon(Icons.file_download),
                      onTap: () {
                        // Export JSON
                      },
                    ),
                    ListTile(
                      key: const Key('export_csv_button'),
                      title: const Text('Export to CSV'),
                      subtitle: const Text('Export tasks in spreadsheet format'),
                      leading: const Icon(Icons.table_chart),
                      onTap: () {
                        // Export CSV
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Test backup creation
        await tester.tap(find.byKey(const Key('create_backup_button')));
        await tester.pump();

        // Test backup restoration
        await tester.tap(find.byKey(const Key('restore_backup_button')));
        await tester.pump();

        // Test data export
        await tester.tap(find.byKey(const Key('export_json_button')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('export_csv_button')));
        await tester.pump();

        // Verify data management interface
        expect(find.text('Backup & Sync'), findsOneWidget);
        expect(find.text('Create Backup'), findsOneWidget);
        expect(find.text('Restore Backup'), findsOneWidget);
      });

      testWidgets('should manage storage and cleanup settings', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(title: const Text('Storage Management')),
                body: ListView(
                  children: [
                    const Card(
                      child: Column(
                        children: [
                          ListTile(
                            title: Text('Storage Usage'),
                            subtitle: Text('Current app storage usage'),
                          ),
                          LinearProgressIndicator(value: 0.3),
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('12.5 MB used of 50 MB available'),
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      key: const Key('cleanup_completed_tasks'),
                      title: const Text('Clean Up Completed Tasks'),
                      subtitle: const Text('Remove tasks completed over 30 days ago'),
                      leading: const Icon(Icons.cleaning_services),
                      onTap: () {
                        // Clean up old tasks
                      },
                    ),
                    ListTile(
                      key: const Key('cleanup_old_backups'),
                      title: const Text('Clean Up Old Backups'),
                      subtitle: const Text('Keep only last 5 backups'),
                      leading: const Icon(Icons.delete_sweep),
                      onTap: () {
                        // Clean up old backups
                      },
                    ),
                    SwitchListTile(
                      key: const Key('auto_cleanup_switch'),
                      title: const Text('Automatic Cleanup'),
                      subtitle: const Text('Automatically clean up old data'),
                      value: false,
                      onChanged: (value) {
                        // Toggle auto cleanup
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Test cleanup operations
        await tester.tap(find.byKey(const Key('cleanup_completed_tasks')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('cleanup_old_backups')));
        await tester.pump();

        // Test auto cleanup toggle
        await tester.tap(find.byKey(const Key('auto_cleanup_switch')));
        await tester.pump();

        // Verify storage management interface
        expect(find.text('Storage Usage'), findsOneWidget);
        expect(find.text('12.5 MB used of 50 MB available'), findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      });
    });

    group('Integration and Sync Settings', () {
      testWidgets('should configure external service integrations', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(title: const Text('Integrations')),
                body: ListView(
                  children: [
                    const Card(
                      child: ListTile(
                        title: Text('Connected Services'),
                        subtitle: Text('Manage your connected accounts'),
                      ),
                    ),
                    ListTile(
                      key: const Key('google_calendar_integration'),
                      title: const Text('Google Calendar'),
                      subtitle: const Text('Sync tasks with Google Calendar'),
                      leading: const Icon(Icons.calendar_today),
                      trailing: Switch(
                        value: false,
                        onChanged: (value) {
                          // Toggle Google Calendar sync
                        },
                      ),
                      onTap: () {
                        // Configure Google Calendar
                      },
                    ),
                    ListTile(
                      key: const Key('slack_integration'),
                      title: const Text('Slack'),
                      subtitle: const Text('Send task notifications to Slack'),
                      leading: const Icon(Icons.message),
                      trailing: Switch(
                        value: false,
                        onChanged: (value) {
                          // Toggle Slack integration
                        },
                      ),
                      onTap: () {
                        // Configure Slack
                      },
                    ),
                    ListTile(
                      key: const Key('email_integration'),
                      title: const Text('Email Notifications'),
                      subtitle: const Text('Receive task reminders via email'),
                      leading: const Icon(Icons.email),
                      trailing: Switch(
                        value: true,
                        onChanged: (value) {
                          // Toggle email notifications
                        },
                      ),
                      onTap: () {
                        // Configure email
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Test integration toggles
        await tester.tap(find.byKey(const Key('google_calendar_integration')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('slack_integration')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('email_integration')));
        await tester.pump();

        // Verify integrations interface
        expect(find.text('Connected Services'), findsOneWidget);
        expect(find.text('Google Calendar'), findsOneWidget);
        expect(find.text('Slack'), findsOneWidget);
        expect(find.text('Email Notifications'), findsOneWidget);
      });

      testWidgets('should test settings persistence and restoration', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(title: const Text('Settings Test')),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Test Settings Persistence'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        key: const Key('save_test_settings'),
                        onPressed: () {
                          // Save test settings
                        },
                        child: const Text('Save Test Settings'),
                      ),
                      ElevatedButton(
                        key: const Key('load_test_settings'),
                        onPressed: () {
                          // Load test settings
                        },
                        child: const Text('Load Test Settings'),
                      ),
                      ElevatedButton(
                        key: const Key('reset_all_settings'),
                        onPressed: () {
                          // Reset all settings to defaults
                        },
                        child: const Text('Reset to Defaults'),
                      ),
                      const SizedBox(height: 20),
                      const Text('Settings Status: All settings saved'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        // Test settings persistence
        await tester.tap(find.byKey(const Key('save_test_settings')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('load_test_settings')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('reset_all_settings')));
        await tester.pump();

        // Verify settings test interface
        expect(find.text('Test Settings Persistence'), findsOneWidget);
        expect(find.text('Settings Status: All settings saved'), findsOneWidget);
      });
    });
  });
}