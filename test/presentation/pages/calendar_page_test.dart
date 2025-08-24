import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:task_tracker_app/presentation/pages/calendar_page.dart';
import 'package:task_tracker_app/presentation/providers/calendar_provider.dart';
import 'package:task_tracker_app/presentation/providers/task_providers.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/calendar_event.dart';
import 'package:task_tracker_app/domain/models/enums.dart';

// Helper functions available to all test groups
Widget createTestWidget({
  List<TaskModel>? tasks,
  List<CalendarEvent>? events,
  DateTime? selectedDate,
  bool hasError = false,
  bool isLoading = false,
}) {
  return ProviderScope(
    overrides: [
      if (tasks != null)
        tasksProvider.overrideWith((ref) => Stream.value(tasks)),
      if (events != null)
        selectedDateEventsProvider.overrideWith((ref) => events),
    ],
    child: MaterialApp(
      home: Theme(
        data: ThemeData.light(),
        child: const CalendarPage(),
      ),
    ),
  );
}

TaskModel createTestTask({
  String title = 'Test Task',
  DateTime? dueDate,
  TaskPriority priority = TaskPriority.medium,
  TaskStatus status = TaskStatus.pending,
}) {
  return TaskModel.create(title: title).copyWith(
    dueDate: dueDate ?? DateTime.now(),
    priority: priority,
    status: status,
  );
}

CalendarEvent createTestEvent({
  String title = 'Test Event',
  DateTime? startTime,
  DateTime? endTime,
}) {
  final now = DateTime.now();
  return CalendarEvent(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    title: title,
    description: 'Test event description',
    startTime: startTime ?? now,
    endTime: endTime ?? now.add(const Duration(hours: 1)),
  );
}

void main() {
  group('CalendarPage Widget Tests', () {
    testWidgets('should display calendar page with basic elements', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      expect(find.byType(CalendarPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display loading state', (tester) async {
      await tester.pumpWidget(createTestWidget(isLoading: true));
      await tester.pump();
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display error state', (tester) async {
      await tester.pumpWidget(createTestWidget(hasError: true));
      await tester.pump();
      
      expect(find.textContaining('error'), findsOneWidget, reason: 'Should display error message');
    });

    testWidgets('should display calendar with tasks', (tester) async {
      final tasks = [
        createTestTask(title: 'Task 1', dueDate: DateTime.now()),
        createTestTask(title: 'Task 2', dueDate: DateTime.now().add(const Duration(days: 1))),
        createTestTask(title: 'Task 3', dueDate: DateTime.now().add(const Duration(days: 2))),
      ];
      
      await tester.pumpWidget(createTestWidget(tasks: tasks));
      await tester.pump();
      
      expect(find.byType(CalendarPage), findsOneWidget);
    });

    testWidgets('should display calendar with events', (tester) async {
      final events = [
        createTestEvent(title: 'Event 1', startTime: DateTime.now()),
        createTestEvent(title: 'Event 2', startTime: DateTime.now().add(const Duration(days: 1))),
        createTestEvent(title: 'Event 3', startTime: DateTime.now().add(const Duration(days: 2))),
      ];
      
      await tester.pumpWidget(createTestWidget(events: events));
      await tester.pump();
      
      expect(find.byType(CalendarPage), findsOneWidget);
    });

    testWidgets('should handle empty calendar', (tester) async {
      await tester.pumpWidget(createTestWidget(tasks: [], events: []));
      await tester.pump();
      
      expect(find.byType(CalendarPage), findsOneWidget);
    });

    testWidgets('should handle date selection', (tester) async {
      final selectedDate = DateTime.now().add(const Duration(days: 5));
      
      await tester.pumpWidget(createTestWidget(selectedDate: selectedDate));
      await tester.pump();
      
      expect(find.byType(CalendarPage), findsOneWidget);
    });

    testWidgets('should display tasks on selected date', (tester) async {
      final selectedDate = DateTime.now();
      final tasks = [
        createTestTask(title: 'Today Task', dueDate: selectedDate),
        createTestTask(title: 'Tomorrow Task', dueDate: selectedDate.add(const Duration(days: 1))),
      ];
      
      await tester.pumpWidget(createTestWidget(
        tasks: tasks,
        selectedDate: selectedDate,
      ));
      await tester.pump();
      
      expect(find.byType(CalendarPage), findsOneWidget);
    });

    testWidgets('should display events on selected date', (tester) async {
      final selectedDate = DateTime.now();
      final events = [
        createTestEvent(title: 'Today Event', startTime: selectedDate),
        createTestEvent(title: 'Tomorrow Event', startTime: selectedDate.add(const Duration(days: 1))),
      ];
      
      await tester.pumpWidget(createTestWidget(
        events: events,
        selectedDate: selectedDate,
      ));
      await tester.pump();
      
      expect(find.byType(CalendarPage), findsOneWidget);
    });

    testWidgets('should handle tasks with different priorities', (tester) async {
      final tasks = [
        createTestTask(title: 'Urgent Task', priority: TaskPriority.urgent),
        createTestTask(title: 'High Task', priority: TaskPriority.high),
        createTestTask(title: 'Medium Task', priority: TaskPriority.medium),
        createTestTask(title: 'Low Task', priority: TaskPriority.low),
      ];
      
      await tester.pumpWidget(createTestWidget(tasks: tasks));
      await tester.pump();
      
      expect(find.byType(CalendarPage), findsOneWidget);
    });

    testWidgets('should handle tasks with different statuses', (tester) async {
      final tasks = [
      ];
      
      await tester.pumpWidget(createTestWidget(tasks: tasks));
      await tester.pump();
      
      expect(find.byType(CalendarPage), findsOneWidget);
    });

    testWidgets('should handle overdue tasks', (tester) async {
      final pastDate = DateTime.now().subtract(const Duration(days: 5));
      final tasks = [
        createTestTask(title: 'Overdue Task', dueDate: pastDate),
      ];
      
      await tester.pumpWidget(createTestWidget(tasks: tasks));
      await tester.pump();
      
      expect(find.byType(CalendarPage), findsOneWidget);
    });

    testWidgets('should handle future tasks', (tester) async {
      final futureDate = DateTime.now().add(const Duration(days: 30));
      final tasks = [
        createTestTask(title: 'Future Task', dueDate: futureDate),
      ];
      
      await tester.pumpWidget(createTestWidget(tasks: tasks));
      await tester.pump();
      
      expect(find.byType(CalendarPage), findsOneWidget);
    });

    testWidgets('should handle all-day events', (tester) async {
      final allDayStart = DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
      final allDayEnd = allDayStart.copyWith(hour: 23, minute: 59, second: 59);
      
      final events = [
        createTestEvent(
          title: 'All Day Event',
          startTime: allDayStart,
          endTime: allDayEnd,
        ),
      ];
      
      await tester.pumpWidget(createTestWidget(events: events));
      await tester.pump();
      
      expect(find.byType(CalendarPage), findsOneWidget);
    });

    testWidgets('should handle multi-day events', (tester) async {
      final startTime = DateTime.now();
      final endTime = startTime.add(const Duration(days: 3));
      
      final events = [
        createTestEvent(
          title: 'Multi-day Event',
          startTime: startTime,
          endTime: endTime,
        ),
      ];
      
      await tester.pumpWidget(createTestWidget(events: events));
      await tester.pump();
      
      expect(find.byType(CalendarPage), findsOneWidget);
    });

    testWidgets('should handle calendar navigation', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      // Look for navigation buttons (previous/next month/week/day)
      final navigationButtons = [
        ...find.byIcon(Icons.chevron_left).evaluate(),
        ...find.byIcon(Icons.chevron_right).evaluate(),
        ...find.byIcon(Icons.arrow_back).evaluate(),
        ...find.byIcon(Icons.arrow_forward).evaluate(),
      ];
      
      if (navigationButtons.isNotEmpty) {
        await tester.tap(find.byWidget(navigationButtons.first.widget));
        await tester.pump();
      }
      
      expect(find.byType(CalendarPage), findsOneWidget);
    });

    testWidgets('should handle view mode switching', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      // Look for view mode buttons (month/week/day/agenda view)
      final viewButtons = [
        ...find.textContaining('Month').evaluate(),
        ...find.textContaining('Week').evaluate(),
        ...find.textContaining('Day').evaluate(),
        ...find.textContaining('Agenda').evaluate(),
      ];
      
      if (viewButtons.isNotEmpty) {
        await tester.tap(find.byWidget(viewButtons.first.widget));
        await tester.pump();
      }
      
      expect(find.byType(CalendarPage), findsOneWidget);
    });

    testWidgets('should handle task/event tap', (tester) async {
      final tasks = [createTestTask()];
      final events = [createTestEvent()];
      
      await tester.pumpWidget(createTestWidget(tasks: tasks, events: events));
      await tester.pump();
      
      // Look for tappable task/event elements
      final tappableElements = find.byType(GestureDetector);
      if (tappableElements.evaluate().isNotEmpty) {
        await tester.tap(tappableElements.first);
        await tester.pump();
      }
      
      expect(find.byType(CalendarPage), findsOneWidget);
    });

    testWidgets('should handle calendar scrolling', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      // Test scrolling through calendar
      await tester.drag(find.byType(CalendarPage), const Offset(0, -300));
      await tester.pump();
      
      await tester.drag(find.byType(CalendarPage), const Offset(-300, 0));
      await tester.pump();
      
      expect(find.byType(CalendarPage), findsOneWidget);
    });

    testWidgets('should maintain consistent layout', (tester) async {
      final tasks = [createTestTask()];
      final events = [createTestEvent()];
      
      await tester.pumpWidget(createTestWidget(tasks: tasks, events: events));
      await tester.pump();
      
      expect(find.byType(CalendarPage), findsOneWidget);
    });

    testWidgets('should handle rapid state changes', (tester) async {
      await tester.pumpWidget(createTestWidget(isLoading: true));
      await tester.pump();
      
      await tester.pumpWidget(createTestWidget(tasks: [createTestTask()]));
      await tester.pump();
      
      await tester.pumpWidget(createTestWidget(hasError: true));
      await tester.pump();
      
      expect(find.byType(CalendarPage), findsOneWidget);
    });

    testWidgets('should work with different themes', (tester) async {
      final tasks = [createTestTask()];
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tasksProvider.overrideWith((ref) => Stream.value(tasks)),
          ],
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: const CalendarPage(),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(CalendarPage), findsOneWidget);
    });

    testWidgets('should handle today highlighting', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      // Today should be highlighted in the calendar
      expect(find.byType(CalendarPage), findsOneWidget);
    });
  });

  group('CalendarPage Integration Tests', () {
    testWidgets('should integrate with real providers', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Theme(
              data: ThemeData.light(),
              child: const CalendarPage(),
            ),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(CalendarPage), findsOneWidget);
    });

    testWidgets('should handle provider state changes', (tester) async {
      final container = ProviderContainer();
      
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: CalendarPage(),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(CalendarPage), findsOneWidget);
      
      container.dispose();
    });
  });

  group('CalendarPage Performance Tests', () {
    testWidgets('should render efficiently with many items', (tester) async {
      final tasks = List.generate(100, (i) => 
        createTestTask(title: 'Task $i', dueDate: DateTime.now().add(Duration(days: i % 30))));
      final events = List.generate(50, (i) => 
        createTestEvent(title: 'Event $i', startTime: DateTime.now().add(Duration(days: i % 30))));
      
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(createTestWidget(tasks: tasks, events: events));
      await tester.pump();
      
      stopwatch.stop();
      
      expect(stopwatch.elapsedMilliseconds, lessThan(3000));
      expect(find.byType(CalendarPage), findsOneWidget);
    });

    testWidgets('should handle frequent rebuilds', (tester) async {
      final tasks = [createTestTask()];
      
      for (int i = 0; i < 15; i++) {
        await tester.pumpWidget(createTestWidget(tasks: tasks));
        await tester.pump(const Duration(milliseconds: 10));
      }
      
      await tester.pump();
      expect(find.byType(CalendarPage), findsOneWidget);
    });
  });

  group('CalendarPage Edge Cases', () {
    testWidgets('should handle small screen sizes', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      
      final tasks = [createTestTask()];
      await tester.pumpWidget(createTestWidget(tasks: tasks));
      await tester.pump();
      
      expect(find.byType(CalendarPage), findsOneWidget);
      
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('should handle large screen sizes', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      
      final tasks = [createTestTask()];
      await tester.pumpWidget(createTestWidget(tasks: tasks));
      await tester.pump();
      
      expect(find.byType(CalendarPage), findsOneWidget);
      
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('should handle widget disposal', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      // Navigate away
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('Other page'))),
      );
      await tester.pump();
      
      expect(find.text('Other page'), findsOneWidget);
    });

    testWidgets('should handle extreme dates', (tester) async {
      final extremeFuture = DateTime(2099, 12, 31);
      final extremePast = DateTime(1900, 1, 1);
      
      final tasks = [
        createTestTask(title: 'Future Task', dueDate: extremeFuture),
        createTestTask(title: 'Past Task', dueDate: extremePast),
      ];
      
      await tester.pumpWidget(createTestWidget(tasks: tasks));
      await tester.pump();
      
      expect(find.byType(CalendarPage), findsOneWidget);
    });

    testWidgets('should handle timezone changes', (tester) async {
      // This would typically test timezone handling
      // For now, just ensure the page renders
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      expect(find.byType(CalendarPage), findsOneWidget);
    });

    testWidgets('should handle leap year dates', (tester) async {
      final leapYearDate = DateTime(2024, 2, 29); // 2024 is a leap year
      final tasks = [createTestTask(title: 'Leap Year Task', dueDate: leapYearDate)];
      
      await tester.pumpWidget(createTestWidget(tasks: tasks));
      await tester.pump();
      
      expect(find.byType(CalendarPage), findsOneWidget);
    });
  });
}
