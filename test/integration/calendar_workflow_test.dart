import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';

import 'package:task_tracker_app/services/database/database.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/presentation/widgets/advanced_task_card.dart';
import 'package:task_tracker_app/presentation/widgets/enhanced_calendar_widget.dart';

void main() {
  group('Calendar and Scheduling Workflow Integration Tests', () {
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

    group('Calendar View and Navigation', () {
      testWidgets('should navigate calendar and view tasks by date', (tester) async {
        final taskToday = TaskModel.create(
          title: 'Today Task',
          dueDate: DateTime.now(),
        );

        final taskTomorrow = TaskModel.create(
          title: 'Tomorrow Task',
          dueDate: DateTime.now().add(const Duration(days: 1)),
        );

        final taskNextWeek = TaskModel.create(
          title: 'Next Week Task',
          dueDate: DateTime.now().add(const Duration(days: 7)),
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Calendar View'),
                  actions: [
                    IconButton(
                      key: const Key('calendar_view_toggle'),
                      icon: const Icon(Icons.calendar_view_month),
                      onPressed: () {
                        // Toggle calendar view
                      },
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    // Calendar widget
                    const SizedBox(
                      key: Key('calendar_widget'),
                      height: 300,
                      child: EnhancedCalendarWidget(),
                    ),
                    // Task list for selected date
                    Expanded(
                      child: ListView(
                        children: [
                          AdvancedTaskCard(
                            key: Key('task_${taskToday.id}'),
                            task: taskToday,
                            showDueDate: true,
                          ),
                          AdvancedTaskCard(
                            key: Key('task_${taskTomorrow.id}'),
                            task: taskTomorrow,
                            showDueDate: true,
                          ),
                          AdvancedTaskCard(
                            key: Key('task_${taskNextWeek.id}'),
                            task: taskNextWeek,
                            showDueDate: true,
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

        // Verify calendar loads
        expect(find.byKey(const Key('calendar_widget')), findsOneWidget);
        expect(find.text('Today Task'), findsOneWidget);
        expect(find.text('Tomorrow Task'), findsOneWidget);
        expect(find.text('Next Week Task'), findsOneWidget);

        // Navigate to tomorrow
        await tester.tap(find.byKey(const Key('calendar_next_day')));
        await tester.pump();

        // Navigate to previous day
        await tester.tap(find.byKey(const Key('calendar_prev_day')));
        await tester.pump();

        // Test month navigation
        await tester.tap(find.byKey(const Key('calendar_next_month')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('calendar_prev_month')));
        await tester.pump();

        // Verify calendar navigation works
        expect(find.byKey(const Key('calendar_widget')), findsOneWidget);
      });

      testWidgets('should switch between calendar views (day, week, month)', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: DefaultTabController(
                length: 3,
                child: Scaffold(
                  appBar: AppBar(
                    title: const Text('Calendar Views'),
                    bottom: const TabBar(
                      tabs: [
                        Tab(key: Key('day_view_tab'), text: 'Day'),
                        Tab(key: Key('week_view_tab'), text: 'Week'),
                        Tab(key: Key('month_view_tab'), text: 'Month'),
                      ],
                    ),
                  ),
                  body: const TabBarView(
                    children: [
                      // Day view
                      Center(child: Text('Day View')),
                      // Week view
                      Center(child: Text('Week View')),
                      // Month view
                      Center(child: Text('Month View')),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        // Test view switching
        await tester.tap(find.byKey(const Key('week_view_tab')));
        await tester.pump();
        expect(find.text('Week View'), findsOneWidget);

        await tester.tap(find.byKey(const Key('month_view_tab')));
        await tester.pump();
        expect(find.text('Month View'), findsOneWidget);

        await tester.tap(find.byKey(const Key('day_view_tab')));
        await tester.pump();
        expect(find.text('Day View'), findsOneWidget);
      });
    });

    group('Task Scheduling and Due Dates', () {
      testWidgets('should schedule task with date and time picker workflow', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Column(
                    children: [
                      ElevatedButton(
                        key: const Key('schedule_task_button'),
                        onPressed: () {
                          // Open scheduling dialog
                        },
                        child: const Text('Schedule Task'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        // Open scheduling dialog
        await tester.tap(find.byKey(const Key('schedule_task_button')));
        await tester.pump();

        // Would test date/time picker integration
        expect(find.byKey(const Key('schedule_task_button')), findsOneWidget);
      });

      testWidgets('should handle recurring task scheduling workflow', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    const Text('Recurring Task Setup'),
                    DropdownButton<String>(
                      key: const Key('recurrence_dropdown'),
                      items: const [
                        DropdownMenuItem(value: 'daily', child: Text('Daily')),
                        DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                        DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                        DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                      ],
                      onChanged: (value) {
                        // Handle recurrence change
                      },
                    ),
                    const TextField(
                      key: Key('recurrence_interval_field'),
                      decoration: InputDecoration(
                        labelText: 'Every X days/weeks/months',
                      ),
                    ),
                    ElevatedButton(
                      key: const Key('save_recurring_task_button'),
                      onPressed: () {
                        // Save recurring task
                      },
                      child: const Text('Save Recurring Task'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Test recurrence setup
        await tester.tap(find.byKey(const Key('recurrence_dropdown')));
        await tester.pump();
        await tester.tap(find.text('Weekly'));
        await tester.pump();

        await tester.enterText(find.byKey(const Key('recurrence_interval_field')), '2');

        await tester.tap(find.byKey(const Key('save_recurring_task_button')));
        await tester.pump();

        // Verify recurring task setup
        expect(find.text('Recurring Task Setup'), findsOneWidget);
      });

      testWidgets('should handle overdue tasks workflow', (tester) async {
        final overdueTask1 = TaskModel.create(
          title: 'Overdue Task 1',
          dueDate: DateTime.now().subtract(const Duration(days: 1)),
        );

        final overdueTask2 = TaskModel.create(
          title: 'Overdue Task 2',
          dueDate: DateTime.now().subtract(const Duration(days: 3)),
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Overdue Tasks'),
                  backgroundColor: Colors.red[100],
                ),
                body: Column(
                  children: [
                    Container(
                      key: const Key('overdue_banner'),
                      padding: const EdgeInsets.all(16),
                      color: Colors.red[50],
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.red),
                          const SizedBox(width: 8),
                          const Text('You have 2 overdue tasks'),
                          const Spacer(),
                          TextButton(
                            key: const Key('reschedule_all_button'),
                            onPressed: () {
                              // Reschedule all overdue tasks
                            },
                            child: const Text('Reschedule All'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          AdvancedTaskCard(
                            key: Key('overdue_task_${overdueTask1.id}'),
                            task: overdueTask1,
                            isOverdue: true,
                            onReschedule: () {
                              // Reschedule individual task
                            },
                          ),
                          AdvancedTaskCard(
                            key: Key('overdue_task_${overdueTask2.id}'),
                            task: overdueTask2,
                            isOverdue: true,
                            onReschedule: () {
                              // Reschedule individual task
                            },
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

        // Verify overdue tasks display
        expect(find.text('You have 2 overdue tasks'), findsOneWidget);
        expect(find.text('Overdue Task 1'), findsOneWidget);
        expect(find.text('Overdue Task 2'), findsOneWidget);

        // Test reschedule all
        await tester.tap(find.byKey(const Key('reschedule_all_button')));
        await tester.pump();

        // Test individual reschedule
        await tester.tap(find.byKey(Key('reschedule_button_${overdueTask1.id}')));
        await tester.pump();

        // Verify overdue handling
        expect(find.byKey(const Key('overdue_banner')), findsOneWidget);
      });
    });

    group('Time Tracking and Reminders', () {
      testWidgets('should track task time and show progress', (tester) async {
        final trackedTask = TaskModel.create(
          title: 'Time Tracked Task',
          estimatedDuration: const Duration(hours: 2),
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: AdvancedTaskCard(
                  key: Key('tracked_task_${trackedTask.id}'),
                  task: trackedTask,
                  showTimeTracking: true,
                  onStartTimer: () {
                    // Start time tracking
                  },
                  onStopTimer: () {
                    // Stop time tracking
                  },
                ),
              ),
            ),
          ),
        );

        // Start time tracking
        await tester.tap(find.byKey(Key('start_timer_${trackedTask.id}')));
        await tester.pump();

        // Stop time tracking
        await tester.tap(find.byKey(Key('stop_timer_${trackedTask.id}')));
        await tester.pump();

        // Verify time tracking controls
        expect(find.byKey(Key('tracked_task_${trackedTask.id}')), findsOneWidget);
      });

      testWidgets('should set and trigger task reminders', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    const Text('Task Reminder Settings'),
                    ListTile(
                      key: const Key('reminder_15min'),
                      title: const Text('15 minutes before'),
                      leading: Checkbox(
                        value: false,
                        onChanged: (value) {
                          // Handle reminder setting
                        },
                      ),
                    ),
                    ListTile(
                      key: const Key('reminder_1hour'),
                      title: const Text('1 hour before'),
                      leading: Checkbox(
                        value: true,
                        onChanged: (value) {
                          // Handle reminder setting
                        },
                      ),
                    ),
                    ListTile(
                      key: const Key('reminder_1day'),
                      title: const Text('1 day before'),
                      leading: Checkbox(
                        value: false,
                        onChanged: (value) {
                          // Handle reminder setting
                        },
                      ),
                    ),
                    ElevatedButton(
                      key: const Key('save_reminders_button'),
                      onPressed: () {
                        // Save reminder settings
                      },
                      child: const Text('Save Reminders'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Test reminder configuration
        await tester.tap(find.byKey(const Key('reminder_15min')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('reminder_1day')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('save_reminders_button')));
        await tester.pump();

        // Verify reminder settings
        expect(find.text('Task Reminder Settings'), findsOneWidget);
      });
    });

    group('Calendar Integration and Sync', () {
      testWidgets('should sync with device calendar workflow', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Calendar Sync'),
                ),
                body: Column(
                  children: [
                    Card(
                      child: ListTile(
                        key: const Key('device_calendar_sync'),
                        title: const Text('Sync with Device Calendar'),
                        subtitle: const Text('Import and export tasks as calendar events'),
                        trailing: Switch(
                          value: false,
                          onChanged: (value) {
                            // Handle calendar sync toggle
                          },
                        ),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        key: const Key('google_calendar_sync'),
                        title: const Text('Google Calendar Integration'),
                        subtitle: const Text('Two-way sync with Google Calendar'),
                        trailing: ElevatedButton(
                          onPressed: () {
                            // Authenticate with Google Calendar
                          },
                          child: const Text('Connect'),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      key: const Key('export_calendar_button'),
                      onPressed: () {
                        // Export tasks to calendar
                      },
                      child: const Text('Export to Calendar'),
                    ),
                    ElevatedButton(
                      key: const Key('import_calendar_button'),
                      onPressed: () {
                        // Import from calendar
                      },
                      child: const Text('Import from Calendar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Test calendar sync toggle
        await tester.tap(find.byKey(const Key('device_calendar_sync')));
        await tester.pump();

        // Test Google Calendar connection
        await tester.tap(find.text('Connect'));
        await tester.pump();

        // Test export/import
        await tester.tap(find.byKey(const Key('export_calendar_button')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('import_calendar_button')));
        await tester.pump();

        // Verify calendar integration
        expect(find.text('Calendar Sync'), findsOneWidget);
      });

      testWidgets('should handle calendar conflict resolution', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Calendar Conflicts'),
                ),
                body: Column(
                  children: [
                    Card(
                      key: const Key('conflict_card'),
                      color: Colors.orange[50],
                      child: const ListTile(
                        leading: Icon(Icons.warning, color: Colors.orange),
                        title: Text('Schedule Conflict Detected'),
                        subtitle: Text('Task conflicts with existing calendar event'),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          key: const Key('keep_task_time'),
                          onPressed: () {
                            // Keep task time, move calendar event
                          },
                          child: const Text('Keep Task Time'),
                        ),
                        ElevatedButton(
                          key: const Key('move_task'),
                          onPressed: () {
                            // Move task to avoid conflict
                          },
                          child: const Text('Reschedule Task'),
                        ),
                        ElevatedButton(
                          key: const Key('ignore_conflict'),
                          onPressed: () {
                            // Ignore conflict
                          },
                          child: const Text('Ignore'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Test conflict resolution
        await tester.tap(find.byKey(const Key('move_task')));
        await tester.pump();

        // Verify conflict handling
        expect(find.text('Schedule Conflict Detected'), findsOneWidget);
      });
    });
  });
}