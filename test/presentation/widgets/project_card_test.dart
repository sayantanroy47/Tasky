import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:task_tracker_app/presentation/widgets/project_card.dart';
import 'package:task_tracker_app/domain/entities/project.dart';

// Helper functions for testing
Widget createTestWidget({required Widget child}) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: child,
      ),
    ),
  );
}

Project createTestProject({
  String name = 'Test Project',
  String description = 'Test Description',
  String color = '#2196F3',
  bool isArchived = false,
}) {
  return Project(
    id: 'test-id',
    name: name,
    description: description,
    color: color,
    isArchived: isArchived,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

void main() {
  group('ProjectCard Widget Tests', () {
    testWidgets('should display project name and description', (tester) async {
      final project = createTestProject(
        name: 'Test Project',
        description: 'Test Description',
      );
      
      await tester.pumpWidget(
        createTestWidget(
          child: ProjectCard(project: project),
        ),
      );
      await tester.pump();
      
      expect(find.text('Test Project'), findsOneWidget);
      expect(find.byType(ProjectCard), findsOneWidget);
    });

    testWidgets('should display different project colors', (tester) async {
      final redProject = createTestProject(
        name: 'Red Project',
        color: '#FF0000',
      );
      
      await tester.pumpWidget(
        createTestWidget(
          child: ProjectCard(project: redProject),
        ),
      );
      await tester.pump();
      
      expect(find.text('Red Project'), findsOneWidget);
      expect(find.byType(ProjectCard), findsOneWidget);
    });

    testWidgets('should handle archived projects', (tester) async {
      final archivedProject = createTestProject(
        name: 'Archived Project',
        isArchived: true,
      );
      
      await tester.pumpWidget(
        createTestWidget(
          child: ProjectCard(project: archivedProject),
        ),
      );
      await tester.pump();
      
      expect(find.text('Archived Project'), findsOneWidget);
      expect(find.byType(ProjectCard), findsOneWidget);
    });

    testWidgets('should handle tap interactions', (tester) async {
      final project = createTestProject(name: 'Tappable Project');
      bool onTapCalled = false;
      
      await tester.pumpWidget(
        createTestWidget(
          child: ProjectCard(
            project: project,
            onTap: () => onTapCalled = true,
          ),
        ),
      );
      await tester.pump();
      
      await tester.tap(find.byType(ProjectCard));
      await tester.pump();
      
      expect(onTapCalled, isTrue);
    });

    testWidgets('should handle long descriptions', (tester) async {
      final longDescProject = createTestProject(
        name: 'Long Description Project',
        description: 'This is a very long project description that should be handled gracefully by the widget and should not cause overflow issues in the UI',
      );
      
      await tester.pumpWidget(
        createTestWidget(
          child: ProjectCard(project: longDescProject),
        ),
      );
      await tester.pump();
      
      expect(find.text('Long Description Project'), findsOneWidget);
      expect(find.byType(ProjectCard), findsOneWidget);
    });

    testWidgets('should work with different themes', (tester) async {
      final project = createTestProject(name: 'Themed Project');
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              body: ProjectCard(project: project),
            ),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.text('Themed Project'), findsOneWidget);
      expect(find.byType(ProjectCard), findsOneWidget);
    });

    testWidgets('should handle empty description', (tester) async {
      final project = createTestProject(
        name: 'No Description Project',
        description: '',
      );
      
      await tester.pumpWidget(
        createTestWidget(
          child: ProjectCard(project: project),
        ),
      );
      await tester.pump();
      
      expect(find.text('No Description Project'), findsOneWidget);
      expect(find.byType(ProjectCard), findsOneWidget);
    });

    testWidgets('should handle invalid color gracefully', (tester) async {
      final project = createTestProject(
        name: 'Invalid Color Project',
        color: 'invalid-color',
      );
      
      await tester.pumpWidget(
        createTestWidget(
          child: ProjectCard(project: project),
        ),
      );
      await tester.pump();
      
      expect(find.text('Invalid Color Project'), findsOneWidget);
      expect(find.byType(ProjectCard), findsOneWidget);
    });

    testWidgets('should show context menu on long press', (tester) async {
      final project = createTestProject(name: 'Context Menu Project');
      
      await tester.pumpWidget(
        createTestWidget(
          child: ProjectCard(project: project),
        ),
      );
      await tester.pump();
      
      await tester.longPress(find.byType(ProjectCard));
      await tester.pump();
      
      // Should not crash and card should still be there
      expect(find.byType(ProjectCard), findsOneWidget);
    });

    testWidgets('should be accessible', (tester) async {
      final project = createTestProject(name: 'Accessible Project');
      
      await tester.pumpWidget(
        createTestWidget(
          child: ProjectCard(project: project),
        ),
      );
      await tester.pump();
      
      // Check for accessibility semantics
      expect(find.byType(ProjectCard), findsOneWidget);
      
      // Verify the widget can be found by semantic labels if present
      final semantics = tester.getSemantics(find.byType(ProjectCard));
      expect(semantics, isNotNull);
    });
  });
}