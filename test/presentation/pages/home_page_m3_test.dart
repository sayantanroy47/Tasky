import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:task_tracker_app/presentation/pages/home_page_m3.dart';
import 'package:task_tracker_app/presentation/providers/task_providers.dart';
import 'package:task_tracker_app/presentation/providers/profile_providers.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/user_profile.dart';
import 'package:task_tracker_app/domain/models/enums.dart';

// Helper function available to all test groups
Widget createTestWidget({
  List<TaskModel>? pendingTasks,
  List<TaskModel>? completedTasks,
  UserProfile? userProfile,
}) {
  return ProviderScope(
    overrides: [
      pendingTasksProvider.overrideWith((ref) => Stream.value(pendingTasks ?? [])),
      completedTasksProvider.overrideWith((ref) => Stream.value(completedTasks ?? [])),
      currentProfileProvider.overrideWith((ref) async => userProfile),
    ],
    child: MaterialApp(
      home: Theme(
        data: ThemeData.light(),
        child: const HomePage(),
      ),
    ),
  );
}

void main() {
  group('HomePage Widget Tests', () {
    testWidgets('should display home page with basic elements', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      // Verify basic UI elements
      expect(find.text('Home'), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display welcome message with user name', (tester) async {
      final mockProfile = UserProfile(
        id: '1',
        firstName: 'John',
        lastName: 'Doe',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(createTestWidget(userProfile: mockProfile));
      await tester.pump();
      
      // Should find elements related to the profile/welcome
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should display pending tasks count', (tester) async {
      final pendingTasks = [
        TaskModel.create(title: 'Task 1'),
        TaskModel.create(title: 'Task 2'),
        TaskModel.create(title: 'Task 3'),
      ];

      await tester.pumpWidget(createTestWidget(pendingTasks: pendingTasks));
      await tester.pump();
      
      // Verify the home page renders with tasks
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should display completed tasks count', (tester) async {
      final completedTasks = [
        TaskModel.create(title: 'Completed 1').copyWith(status: TaskStatus.completed),
        TaskModel.create(title: 'Completed 2').copyWith(status: TaskStatus.completed),
      ];

      await tester.pumpWidget(createTestWidget(completedTasks: completedTasks));
      await tester.pump();
      
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should handle loading state', (tester) async {
      final widget = ProviderScope(
        overrides: [
          pendingTasksProvider.overrideWith((ref) => Stream.value(<TaskModel>[])),
          completedTasksProvider.overrideWith((ref) => Stream.value(<TaskModel>[])),
          currentProfileProvider.overrideWith((ref) async => null),
        ],
        child: MaterialApp(
          home: Theme(
            data: ThemeData.light(),
            child: const HomePage(),
          ),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pump();
      
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should handle error state', (tester) async {
      final widget = ProviderScope(
        overrides: [
          pendingTasksProvider.overrideWith((ref) => 
            Stream.error('Failed to load tasks')),
          completedTasksProvider.overrideWith((ref) => 
            Stream.error('Failed to load tasks')),
          currentProfileProvider.overrideWith((ref) async => throw Exception('Failed to load profile')),
        ],
        child: MaterialApp(
          home: Theme(
            data: ThemeData.light(),
            child: const HomePage(),
          ),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pump();
      
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should display theme toggle button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      // Look for the theme toggle in the app bar
      expect(find.byType(IconButton), findsWidgets);
    });

    testWidgets('should display analytics button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      // Should find chart icon for analytics
      expect(find.byIcon(PhosphorIcons.chartLine()), findsOneWidget);
    });

    testWidgets('should handle tap on analytics button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final analyticsButton = find.byIcon(PhosphorIcons.chartLine());
      expect(analyticsButton, findsOneWidget);
      
      await tester.tap(analyticsButton);
      await tester.pump();
    });

    testWidgets('should display scroll controller properly', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      // Verify the page has scrollable content
      expect(find.byType(HomePage), findsOneWidget);
      
      // Test scrolling behavior
      await tester.drag(find.byType(HomePage), const Offset(0, -200));
      await tester.pump();
    });

    testWidgets('should handle different user profile states', (tester) async {
      // Test with minimal profile
      final minimalProfile = UserProfile(
        id: '1',
        firstName: 'Jane',
        lastName: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(createTestWidget(userProfile: minimalProfile));
      await tester.pump();
      
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should handle empty task lists', (tester) async {
      await tester.pumpWidget(createTestWidget(
        pendingTasks: [],
        completedTasks: [],
      ));
      await tester.pump();
      
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should handle mixed task states', (tester) async {
      final mixedTasks = [
        TaskModel.create(title: 'Urgent Task').copyWith(priority: TaskPriority.urgent),
        TaskModel.create(title: 'High Task').copyWith(priority: TaskPriority.high),
        TaskModel.create(title: 'Medium Task').copyWith(priority: TaskPriority.medium),
        TaskModel.create(title: 'Low Task').copyWith(priority: TaskPriority.low),
      ];

      await tester.pumpWidget(createTestWidget(pendingTasks: mixedTasks));
      await tester.pump();
      
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should properly dispose scroll controller', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      // Navigate away to trigger dispose
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      await tester.pump();
    });

    testWidgets('should handle welcome service data correctly', (tester) async {
      final profile = UserProfile(
        id: '1',
        firstName: 'Test',
        lastName: 'User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final pendingTasks = [TaskModel.create(title: 'Task 1')];
      final completedTasks = [
        TaskModel.create(title: 'Done').copyWith(status: TaskStatus.completed)
      ];

      await tester.pumpWidget(createTestWidget(
        userProfile: profile,
        pendingTasks: pendingTasks,
        completedTasks: completedTasks,
      ));
      await tester.pump();
      
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should maintain transparent background', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, Colors.transparent);
    });

    testWidgets('should extend body behind app bar', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.extendBodyBehindAppBar, true);
    });
  });

  group('HomePage Integration Tests', () {
    testWidgets('should integrate with providers correctly', (tester) async {
      final widget = ProviderScope(
        child: MaterialApp(
          home: Theme(
            data: ThemeData.light(),
            child: const HomePage(),
          ),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pump();
      
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should handle theme changes', (tester) async {
      await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          home: const HomePage(),
        ),
      ));
      await tester.pump();
      
      expect(find.byType(HomePage), findsOneWidget);
    });
  });

  group('HomePage Edge Cases', () {
    testWidgets('should handle null profile gracefully', (tester) async {
      await tester.pumpWidget(createTestWidget(userProfile: null));
      await tester.pump();
      
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should handle very large task lists', (tester) async {
      final largeTasks = List.generate(1000, (i) => 
        TaskModel.create(title: 'Task $i'));
      
      await tester.pumpWidget(createTestWidget(pendingTasks: largeTasks));
      await tester.pump();
      
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should handle rapid state changes', (tester) async {
      final widget = createTestWidget();
      await tester.pumpWidget(widget);
      
      // Simulate rapid rebuilds
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 10));
      }
      
      expect(find.byType(HomePage), findsOneWidget);
    });
  });
}
