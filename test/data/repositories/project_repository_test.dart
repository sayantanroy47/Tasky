import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:task_tracker_app/services/database/database.dart';
import 'package:task_tracker_app/services/database/daos/project_dao.dart';
import 'package:task_tracker_app/data/repositories/project_repository_impl.dart';
import 'package:task_tracker_app/domain/entities/project.dart';

import 'project_repository_test.mocks.dart';

@GenerateMocks([AppDatabase, ProjectDao])
void main() {
  group('ProjectRepositoryImpl', () {
    late ProjectRepositoryImpl repository;
    late MockAppDatabase mockDatabase;
    late MockProjectDao mockProjectDao;

    setUp(() {
      mockDatabase = MockAppDatabase();
      mockProjectDao = MockProjectDao();
      when(mockDatabase.projectDao).thenReturn(mockProjectDao);
      repository = ProjectRepositoryImpl(mockDatabase);
    });

    group('Basic CRUD Operations', () {
      test('should create project', () async {
        // Arrange
        final project = Project(
          id: 'test-project-id',
          name: 'Test Project',
          description: 'Test project description',
          color: '#2196F3',
          createdAt: DateTime.now(),
        );
        when(mockProjectDao.createProject(project)).thenAnswer((_) async => {});

        // Act
        await repository.createProject(project);

        // Assert
        verify(mockProjectDao.createProject(project)).called(1);
      });

      test('should get project by id', () async {
        // Arrange
        const projectId = 'test-project-id';
        final expectedProject = Project(
          id: projectId,
          name: 'Test Project',
          description: 'Test description',
          color: '#2196F3',
          createdAt: DateTime.now(),
        );
        when(mockProjectDao.getProjectById(projectId)).thenAnswer((_) async => expectedProject);

        // Act
        final result = await repository.getProjectById(projectId);

        // Assert
        expect(result, equals(expectedProject));
        verify(mockProjectDao.getProjectById(projectId)).called(1);
      });

      test('should return null for non-existent project', () async {
        // Arrange
        const nonExistentId = 'non-existent-id';
        when(mockProjectDao.getProjectById(nonExistentId)).thenAnswer((_) async => null);

        // Act
        final result = await repository.getProjectById(nonExistentId);

        // Assert
        expect(result, isNull);
        verify(mockProjectDao.getProjectById(nonExistentId)).called(1);
      });

      test('should get all projects', () async {
        // Arrange
        final expectedProjects = [
          Project(
            id: '1',
            name: 'Project 1',
            description: 'First project',
            color: '#2196F3',
            createdAt: DateTime.now(),
          ),
          Project(
            id: '2',
            name: 'Project 2',
            description: 'Second project',
            color: '#4CAF50',
            createdAt: DateTime.now(),
          ),
        ];
        when(mockProjectDao.getAllProjects()).thenAnswer((_) async => expectedProjects);

        // Act
        final result = await repository.getAllProjects();

        // Assert
        expect(result, equals(expectedProjects));
        expect(result.length, equals(2));
        verify(mockProjectDao.getAllProjects()).called(1);
      });

      test('should update project', () async {
        // Arrange
        final project = Project(
          id: 'update-project-id',
          name: 'Updated Project',
          description: 'Updated description',
          color: '#FF5722',
          createdAt: DateTime.now(),
        );
        when(mockProjectDao.updateProject(project)).thenAnswer((_) async => {});

        // Act
        await repository.updateProject(project);

        // Assert
        verify(mockProjectDao.updateProject(project)).called(1);
      });

      test('should delete project', () async {
        // Arrange
        const projectId = 'project-to-delete';
        when(mockProjectDao.deleteProject(projectId)).thenAnswer((_) async => {});

        // Act
        await repository.deleteProject(projectId);

        // Assert
        verify(mockProjectDao.deleteProject(projectId)).called(1);
      });
    });

    group('Status and Archive Operations', () {
      test('should archive project', () async {
        // Arrange
        const projectId = 'archive-project-id';
        when(mockProjectDao.archiveProject(projectId)).thenAnswer((_) async => {});

        // Act
        await repository.archiveProject(projectId);

        // Assert
        verify(mockProjectDao.archiveProject(projectId)).called(1);
      });

      test('should unarchive project', () async {
        // Arrange
        const projectId = 'unarchive-project-id';
        when(mockProjectDao.unarchiveProject(projectId)).thenAnswer((_) async => {});

        // Act
        await repository.unarchiveProject(projectId);

        // Assert
        verify(mockProjectDao.unarchiveProject(projectId)).called(1);
      });

      test('should get active projects', () async {
        // Arrange
        final expectedProjects = [
          Project(
            id: '1',
            name: 'Active Project 1',
            description: 'Active project',
            color: '#2196F3',
            createdAt: DateTime.now(),
            isArchived: false,
          ),
          Project(
            id: '2',
            name: 'Active Project 2',
            description: 'Another active project',
            color: '#4CAF50',
            createdAt: DateTime.now(),
            isArchived: false,
          ),
        ];
        when(mockProjectDao.getActiveProjects()).thenAnswer((_) async => expectedProjects);

        // Act
        final result = await repository.getActiveProjects();

        // Assert
        expect(result, equals(expectedProjects));
        expect(result.every((p) => !p.isArchived), isTrue);
        verify(mockProjectDao.getActiveProjects()).called(1);
      });

      test('should get archived projects', () async {
        // Arrange
        final expectedProjects = [
          Project(
            id: '1',
            name: 'Archived Project',
            description: 'Archived project',
            color: '#9E9E9E',
            createdAt: DateTime.now(),
            isArchived: true,
          ),
        ];
        when(mockProjectDao.getArchivedProjects()).thenAnswer((_) async => expectedProjects);

        // Act
        final result = await repository.getArchivedProjects();

        // Assert
        expect(result, equals(expectedProjects));
        expect(result.every((p) => p.isArchived), isTrue);
        verify(mockProjectDao.getArchivedProjects()).called(1);
      });
    });

    group('Statistics and Analytics', () {
      test('should get project task counts', () async {
        // Arrange
        const projectId = 'stats-project-id';
        const expectedStats = ProjectTaskCounts(
          totalTasks: 10,
          completedTasks: 7,
          pendingTasks: 2,
          inProgressTasks: 1,
        );
        when(mockProjectDao.getProjectTaskCounts(projectId)).thenAnswer((_) async => expectedStats);

        // Act
        final result = await repository.getProjectTaskCounts(projectId);

        // Assert
        expect(result, equals(expectedStats));
        expect(result.totalTasks, equals(10));
        expect(result.completedTasks, equals(7));
        verify(mockProjectDao.getProjectTaskCounts(projectId)).called(1);
      });

      test('should get project completion percentage', () async {
        // Arrange
        const projectId = 'completion-project-id';
        const expectedPercentage = 70.5;
        when(mockProjectDao.getProjectCompletionPercentage(projectId)).thenAnswer((_) async => expectedPercentage);

        // Act
        final result = await repository.getProjectCompletionPercentage(projectId);

        // Assert
        expect(result, equals(expectedPercentage));
        verify(mockProjectDao.getProjectCompletionPercentage(projectId)).called(1);
      });

      test('should get projects with task counts', () async {
        // Arrange
        final expectedData = [
          ProjectWithTaskCount(
            project: Project(
              id: '1',
              name: 'Project with Tasks',
              description: 'Has tasks',
              color: '#2196F3',
              createdAt: DateTime.now(),
            ),
            taskCount: 5,
            completedTaskCount: 3,
          ),
        ];
        when(mockProjectDao.getProjectsWithTaskCounts()).thenAnswer((_) async => expectedData);

        // Act
        final result = await repository.getProjectsWithTaskCounts();

        // Assert
        expect(result, equals(expectedData));
        expect(result.first.taskCount, equals(5));
        expect(result.first.completedTaskCount, equals(3));
        verify(mockProjectDao.getProjectsWithTaskCounts()).called(1);
      });
    });

    group('Deadline and Filtering Operations', () {
      test('should get projects by deadline range', () async {
        // Arrange
        final startDate = DateTime.now();
        final endDate = DateTime.now().add(const Duration(days: 30));
        final expectedProjects = [
          Project(
            id: '1',
            name: 'Project with Deadline',
            description: 'Has deadline in range',
            color: '#FF9800',
            createdAt: DateTime.now(),
            deadline: DateTime.now().add(const Duration(days: 15)),
          ),
        ];
        when(mockProjectDao.getProjectsByDeadlineRange(startDate, endDate)).thenAnswer((_) async => expectedProjects);

        // Act
        final result = await repository.getProjectsByDeadlineRange(startDate, endDate);

        // Assert
        expect(result, equals(expectedProjects));
        expect(result.first.deadline, isNotNull);
        verify(mockProjectDao.getProjectsByDeadlineRange(startDate, endDate)).called(1);
      });

      test('should get overdue projects', () async {
        // Arrange
        final expectedProjects = [
          Project(
            id: '1',
            name: 'Overdue Project',
            description: 'Past deadline',
            color: '#F44336',
            createdAt: DateTime.now().subtract(const Duration(days: 60)),
            deadline: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ];
        when(mockProjectDao.getOverdueProjects()).thenAnswer((_) async => expectedProjects);

        // Act
        final result = await repository.getOverdueProjects();

        // Assert
        expect(result, equals(expectedProjects));
        verify(mockProjectDao.getOverdueProjects()).called(1);
      });

      test('should search projects', () async {
        // Arrange
        const query = 'search term';
        final expectedProjects = [
          Project(
            id: '1',
            name: 'Project containing search term',
            description: 'Found by search',
            color: '#2196F3',
            createdAt: DateTime.now(),
          ),
        ];
        when(mockProjectDao.searchProjects(query)).thenAnswer((_) async => expectedProjects);

        // Act
        final result = await repository.searchProjects(query);

        // Assert
        expect(result, equals(expectedProjects));
        verify(mockProjectDao.searchProjects(query)).called(1);
      });
    });

    group('Streaming Operations', () {
      test('should watch all projects', () async {
        // Arrange
        final expectedProjects = [
          Project(
            id: '1',
            name: 'Watched Project',
            description: 'Being watched',
            color: '#2196F3',
            createdAt: DateTime.now(),
          ),
        ];
        when(mockProjectDao.watchAllProjects()).thenAnswer((_) => Stream.value(expectedProjects));

        // Act
        final stream = repository.watchAllProjects();

        // Assert
        expect(await stream.first, equals(expectedProjects));
        verify(mockProjectDao.watchAllProjects()).called(1);
      });

      test('should watch active projects', () async {
        // Arrange
        final expectedProjects = [
          Project(
            id: '1',
            name: 'Active Watched Project',
            description: 'Active and watched',
            color: '#4CAF50',
            createdAt: DateTime.now(),
            isArchived: false,
          ),
        ];
        when(mockProjectDao.watchActiveProjects()).thenAnswer((_) => Stream.value(expectedProjects));

        // Act
        final stream = repository.watchActiveProjects();

        // Assert
        expect(await stream.first, equals(expectedProjects));
        verify(mockProjectDao.watchActiveProjects()).called(1);
      });

      test('should watch project with task counts', () async {
        // Arrange
        const projectId = 'watch-project-id';
        final expectedData = ProjectWithTaskCount(
          project: Project(
            id: projectId,
            name: 'Watched Project with Tasks',
            description: 'Being watched with task counts',
            color: '#9C27B0',
            createdAt: DateTime.now(),
          ),
          taskCount: 8,
          completedTaskCount: 5,
        );
        when(mockProjectDao.watchProjectWithTaskCounts(projectId)).thenAnswer((_) => Stream.value(expectedData));

        // Act
        final stream = repository.watchProjectWithTaskCounts(projectId);

        // Assert
        expect(await stream.first, equals(expectedData));
        verify(mockProjectDao.watchProjectWithTaskCounts(projectId)).called(1);
      });
    });

    group('Error Handling', () {
      test('should handle database exceptions during createProject', () async {
        // Arrange
        final project = Project(
          id: 'error-project-id',
          name: 'Error Project',
          description: 'Will cause error',
          color: '#F44336',
          createdAt: DateTime.now(),
        );
        when(mockProjectDao.createProject(project)).thenThrow(Exception('Create error'));

        // Act & Assert
        expect(
          () async => await repository.createProject(project),
          throwsException,
        );
      });

      test('should handle database exceptions during getAllProjects', () async {
        // Arrange
        when(mockProjectDao.getAllProjects()).thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () async => await repository.getAllProjects(),
          throwsException,
        );
      });

      test('should handle database exceptions during updateProject', () async {
        // Arrange
        final project = Project(
          id: 'error-update-project',
          name: 'Error Update',
          description: 'Will cause update error',
          color: '#F44336',
          createdAt: DateTime.now(),
        );
        when(mockProjectDao.updateProject(project)).thenThrow(Exception('Update error'));

        // Act & Assert
        expect(
          () async => await repository.updateProject(project),
          throwsException,
        );
      });

      test('should handle database exceptions during deleteProject', () async {
        // Arrange
        const projectId = 'error-delete-project';
        when(mockProjectDao.deleteProject(projectId)).thenThrow(Exception('Delete error'));

        // Act & Assert
        expect(
          () async => await repository.deleteProject(projectId),
          throwsException,
        );
      });
    });

    group('Edge Cases', () {
      test('should handle empty project list', () async {
        // Arrange
        when(mockProjectDao.getAllProjects()).thenAnswer((_) async => []);

        // Act
        final result = await repository.getAllProjects();

        // Assert
        expect(result, isEmpty);
        verify(mockProjectDao.getAllProjects()).called(1);
      });

      test('should handle empty search results', () async {
        // Arrange
        const query = 'no-match-query';
        when(mockProjectDao.searchProjects(query)).thenAnswer((_) async => []);

        // Act
        final result = await repository.searchProjects(query);

        // Assert
        expect(result, isEmpty);
        verify(mockProjectDao.searchProjects(query)).called(1);
      });

      test('should handle zero completion percentage', () async {
        // Arrange
        const projectId = 'zero-completion-project';
        when(mockProjectDao.getProjectCompletionPercentage(projectId)).thenAnswer((_) async => 0.0);

        // Act
        final result = await repository.getProjectCompletionPercentage(projectId);

        // Assert
        expect(result, equals(0.0));
        verify(mockProjectDao.getProjectCompletionPercentage(projectId)).called(1);
      });

      test('should handle 100% completion percentage', () async {
        // Arrange
        const projectId = 'full-completion-project';
        when(mockProjectDao.getProjectCompletionPercentage(projectId)).thenAnswer((_) async => 100.0);

        // Act
        final result = await repository.getProjectCompletionPercentage(projectId);

        // Assert
        expect(result, equals(100.0));
        verify(mockProjectDao.getProjectCompletionPercentage(projectId)).called(1);
      });
    });
  });

  group('ProjectRepositoryImpl Integration Tests', () {
    late ProjectRepositoryImpl repository;
    late AppDatabase database;

    setUp(() async {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      repository = ProjectRepositoryImpl(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('should perform end-to-end project operations', () async {
      // Create projects
      final project1 = Project(
        id: 'integration-project-1',
        name: 'Integration Test Project 1',
        description: 'First integration test project',
        color: '#2196F3',
        createdAt: DateTime.now(),
        deadline: DateTime.now().add(const Duration(days: 30)),
      );

      final project2 = Project(
        id: 'integration-project-2',
        name: 'Integration Test Project 2',
        description: 'Second integration test project',
        color: '#4CAF50',
        createdAt: DateTime.now(),
      );

      await repository.createProject(project1);
      await repository.createProject(project2);

      // Get all projects
      final allProjects = await repository.getAllProjects();
      expect(allProjects.length, equals(2));

      // Get by ID
      final retrievedProject = await repository.getProjectById(project1.id);
      expect(retrievedProject, isNotNull);
      expect(retrievedProject!.name, equals('Integration Test Project 1'));
      expect(retrievedProject.deadline, isNotNull);

      // Update project
      final updatedProject = project1.copyWith(
        name: 'Updated Project Name',
        description: 'Updated project description',
      );
      await repository.updateProject(updatedProject);
      final retrieved = await repository.getProjectById(project1.id);
      expect(retrieved!.name, equals('Updated Project Name'));
      expect(retrieved.description, equals('Updated project description'));

      // Archive project
      await repository.archiveProject(project2.id);
      final activeProjects = await repository.getActiveProjects();
      expect(activeProjects.length, equals(1));
      expect(activeProjects.first.id, equals(project1.id));

      final archivedProjects = await repository.getArchivedProjects();
      expect(archivedProjects.length, equals(1));
      expect(archivedProjects.first.id, equals(project2.id));

      // Unarchive project
      await repository.unarchiveProject(project2.id);
      final allActiveProjects = await repository.getActiveProjects();
      expect(allActiveProjects.length, equals(2));

      // Search projects
      final searchResults = await repository.searchProjects('Integration');
      expect(searchResults.length, equals(2));

      // Test deadline filtering
      final startDate = DateTime.now();
      final endDate = DateTime.now().add(const Duration(days: 60));
      final projectsWithDeadlines = await repository.getProjectsByDeadlineRange(startDate, endDate);
      expect(projectsWithDeadlines.length, equals(1));
      expect(projectsWithDeadlines.first.id, equals(project1.id));

      // Delete project
      await repository.deleteProject(project2.id);
      final remainingProjects = await repository.getAllProjects();
      expect(remainingProjects.length, equals(1));
      expect(remainingProjects.first.id, equals(project1.id));
    });

    test('should handle streaming operations', () async {
      // Create initial project
      final project = Project(
        id: 'stream-test-project',
        name: 'Stream Test Project',
        description: 'For testing streams',
        color: '#FF5722',
        createdAt: DateTime.now(),
      );
      await repository.createProject(project);

      // Watch all projects
      final stream = repository.watchAllProjects();
      final initialProjects = await stream.first;
      expect(initialProjects.length, equals(1));
      expect(initialProjects.first.name, equals('Stream Test Project'));

      // The stream should continue to emit as projects change
      // This would require more complex setup for real streaming tests
    });
  });
}

// Mock data classes for testing
class ProjectTaskCounts {
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final int inProgressTasks;

  const ProjectTaskCounts({
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.inProgressTasks,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectTaskCounts &&
          runtimeType == other.runtimeType &&
          totalTasks == other.totalTasks &&
          completedTasks == other.completedTasks &&
          pendingTasks == other.pendingTasks &&
          inProgressTasks == other.inProgressTasks;

  @override
  int get hashCode =>
      totalTasks.hashCode ^
      completedTasks.hashCode ^
      pendingTasks.hashCode ^
      inProgressTasks.hashCode;
}

class ProjectWithTaskCount {
  final Project project;
  final int taskCount;
  final int completedTaskCount;

  const ProjectWithTaskCount({
    required this.project,
    required this.taskCount,
    required this.completedTaskCount,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectWithTaskCount &&
          runtimeType == other.runtimeType &&
          project == other.project &&
          taskCount == other.taskCount &&
          completedTaskCount == other.completedTaskCount;

  @override
  int get hashCode =>
      project.hashCode ^ taskCount.hashCode ^ completedTaskCount.hashCode;
}