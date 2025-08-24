import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

import 'package:task_tracker_app/presentation/widgets/project_form_dialog.dart';
import 'package:task_tracker_app/domain/entities/project.dart';

// Mock classes
class MockProjectsNotifier extends Mock {}

void main() {
  group('ProjectFormDialog Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          // Override providers as needed for testing
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('should render without layout exceptions', (WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => const ProjectFormDialog(),
                      );
                    },
                    child: const Text('Show Dialog'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Tap the button to show the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify that the dialog is displayed
      expect(find.text('Create Project'), findsOneWidget);
      expect(find.text('Project Name *'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Project Color'), findsOneWidget);
      expect(find.text('Deadline'), findsOneWidget);

      // Verify color selection grid is displayed without layout errors
      expect(find.byType(GridView), findsOneWidget);

      // Verify action buttons are present
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Create'), findsOneWidget);

      // No layout exceptions should be thrown during the test
    });

    testWidgets('should display correct header for editing mode', (WidgetTester tester) async {
      final testProject = Project(
        id: '1',
        name: 'Test Project',
        description: 'Test Description',
        color: '#FF0000',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => ProjectFormDialog(project: testProject),
                      );
                    },
                    child: const Text('Show Edit Dialog'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Tap the button to show the edit dialog
      await tester.tap(find.text('Show Edit Dialog'));
      await tester.pumpAndSettle();

      // Verify that the edit dialog is displayed
      expect(find.text('Edit Project'), findsOneWidget);
      expect(find.text('Update'), findsOneWidget);

      // Verify form fields are pre-populated
      expect(find.text('Test Project'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
    });

    testWidgets('should constrain dialog width properly on different screen sizes', (WidgetTester tester) async {
      // Test with different screen sizes to ensure proper constraints
      await tester.binding.setSurfaceSize(const Size(400, 800)); // Mobile
      
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => const ProjectFormDialog(),
                      );
                    },
                    child: const Text('Show Dialog'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog renders without overflow
      expect(tester.takeException(), isNull);

      // Test with tablet size
      await tester.binding.setSurfaceSize(const Size(800, 1200)); // Tablet
      await tester.pumpAndSettle();
      
      // Verify dialog still renders properly
      expect(tester.takeException(), isNull);
    });

    testWidgets('should validate required project name field', (WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => const ProjectFormDialog(),
                      );
                    },
                    child: const Text('Show Dialog'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Try to create project with empty name
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Project name is required'), findsOneWidget);
    });
  });
}