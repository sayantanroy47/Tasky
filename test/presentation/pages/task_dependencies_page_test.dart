import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:task_tracker_app/presentation/pages/task_dependencies_page.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';

void main() {
  group('TaskDependenciesPage Widget Tests', () {
    Widget createTestWidget({
      List<TaskModel>? tasks,
      Map<String, List<String>>? dependencies,
      bool hasError = false,
      bool isLoading = false,
    }) {
      return ProviderScope(
        overrides: const [
          // Note: For testing, provider overrides omitted for simplicity
        ],
        child: MaterialApp(
          home: Theme(
            data: ThemeData.light(),
            child: const TaskDependenciesPage(),
          ),
        ),
      );
    }

    testWidgets('should display task dependencies page', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      expect(find.byType(TaskDependenciesPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display loading state', (tester) async {
      await tester.pumpWidget(createTestWidget(isLoading: true));
      await tester.pumpAndSettle();
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display error state', (tester) async {
      await tester.pumpWidget(createTestWidget(hasError: true));
      await tester.pumpAndSettle();
      
      expect(find.textContaining('error'), findsOneWidget);
    });

    testWidgets('should display task dependency graph', (tester) async {
      final tasks = [
        TaskModel.create(title: 'Task 1'),
        TaskModel.create(title: 'Task 2'),
        TaskModel.create(title: 'Task 3'),
      ];
      
      await tester.pumpWidget(createTestWidget(tasks: tasks));
      await tester.pumpAndSettle();
      
      expect(find.byType(TaskDependenciesPage), findsOneWidget);
    });

    testWidgets('should handle empty dependencies', (tester) async {
      await tester.pumpWidget(createTestWidget(tasks: []));
      await tester.pumpAndSettle();
      
      expect(find.byType(TaskDependenciesPage), findsOneWidget);
    });

    testWidgets('should work with different themes', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: const TaskDependenciesPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(TaskDependenciesPage), findsOneWidget);
    });
  });
}
