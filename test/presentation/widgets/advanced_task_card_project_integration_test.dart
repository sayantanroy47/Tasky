import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/project.dart';
import 'package:task_tracker_app/domain/models/enums.dart';
import 'package:task_tracker_app/presentation/widgets/advanced_task_card.dart';
import 'package:task_tracker_app/presentation/providers/project_providers.dart';
import 'package:task_tracker_app/services/project_service.dart';

import 'advanced_task_card_project_integration_test.mocks.dart';

@GenerateMocks([ProjectService])
void main() {
  group('AdvancedTaskCard Project Integration Tests', () {
    late MockProjectService mockProjectService;

    setUp(() {
      mockProjectService = MockProjectService();
    });

    // Helper method to create a sample task with project
    TaskModel createTaskWithProject(String projectId) {
      return TaskModel.create(
        title: 'Test Task',
        description: 'Test Description',
        priority: TaskPriority.medium,
        projectId: projectId,
      );
    }

    // Helper method to create a sample project
    Project createProject(String id, String name, String color) {
      return Project(
        id: id,
        name: name,
        color: color,
        createdAt: DateTime.now(),
      );
    }

    testWidgets('displays project badge when task has valid project', (tester) async {
      // Arrange
      const projectId = 'project-1';
      const projectName = 'Work Project';
      const projectColor = '#2196F3';
      
      final task = createTaskWithProject(projectId);
      final project = createProject(projectId, projectName, projectColor);

      when(mockProjectService.getProjectById(projectId))
          .thenAnswer((_) async => project);

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            projectServiceProvider.overrideWithValue(mockProjectService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: AdvancedTaskCard(
                task: task,
                showProjectInfo: true,
              ),
            ),
          ),
        ),
      );

      // Wait for async operations
      await tester.pumpAndSettle();

      // Assert
      expect(find.text(projectName), findsOneWidget);
      expect(find.byIcon(Icons.folder), findsOneWidget);
    });

    testWidgets('displays loading state while fetching project', (tester) async {
      // Arrange
      const projectId = 'project-1';
      final task = createTaskWithProject(projectId);

      // Mock service to return a delayed response
      when(mockProjectService.getProjectById(projectId))
          .thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return createProject(projectId, 'Test Project', '#2196F3');
      });

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            projectServiceProvider.overrideWithValue(mockProjectService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: AdvancedTaskCard(
                task: task,
                showProjectInfo: true,
              ),
            ),
          ),
        ),
      );

      // Assert loading state
      expect(find.text('Loading...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for completion
      await tester.pumpAndSettle();

      // Assert final state
      expect(find.text('Test Project'), findsOneWidget);
      expect(find.text('Loading...'), findsNothing);
    });

    testWidgets('displays error state when project fetch fails', (tester) async {
      // Arrange
      const projectId = 'project-1';
      final task = createTaskWithProject(projectId);

      when(mockProjectService.getProjectById(projectId))
          .thenThrow(Exception('Network error'));

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            projectServiceProvider.overrideWithValue(mockProjectService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: AdvancedTaskCard(
                task: task,
                showProjectInfo: true,
              ),
            ),
          ),
        ),
      );

      // Wait for async operations
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Project Error'), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('hides project info when task has no project', (tester) async {
      // Arrange
      final task = TaskModel.create(
        title: 'Test Task',
        description: 'Test Description',
        priority: TaskPriority.medium,
        // No projectId
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            projectServiceProvider.overrideWithValue(mockProjectService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: AdvancedTaskCard(
                task: task,
                showProjectInfo: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - no project-related widgets should be present
      expect(find.text('Loading...'), findsNothing);
      expect(find.text('Project Error'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('hides project info when showProjectInfo is false', (tester) async {
      // Arrange
      const projectId = 'project-1';
      final task = createTaskWithProject(projectId);
      final project = createProject(projectId, 'Work Project', '#2196F3');

      when(mockProjectService.getProjectById(projectId))
          .thenAnswer((_) async => project);

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            projectServiceProvider.overrideWithValue(mockProjectService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: AdvancedTaskCard(
                task: task,
                showProjectInfo: false, // Explicitly disabled
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - project name should not be displayed
      expect(find.text('Work Project'), findsNothing);
    });

    testWidgets('handles deleted project gracefully', (tester) async {
      // Arrange
      const projectId = 'deleted-project';
      final task = createTaskWithProject(projectId);

      // Mock service returns null (project was deleted)
      when(mockProjectService.getProjectById(projectId))
          .thenAnswer((_) async => null);

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            projectServiceProvider.overrideWithValue(mockProjectService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: AdvancedTaskCard(
                task: task,
                showProjectInfo: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - no project widgets should be displayed
      expect(find.text('Loading...'), findsNothing);
      expect(find.text('Project Error'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}