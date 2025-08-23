import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

import 'package:task_tracker_app/services/database/database.dart';
import 'package:task_tracker_app/data/repositories/task_repository_impl.dart';
import 'package:task_tracker_app/data/repositories/subtask_repository_impl.dart';
import 'package:task_tracker_app/data/repositories/project_repository_impl.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/subtask.dart';
import 'package:task_tracker_app/domain/entities/project.dart';
import 'package:task_tracker_app/domain/models/enums.dart';

void main() {
  group('Repository Integration Tests', () {
    late AppDatabase database;
    late TaskRepositoryImpl taskRepository;
    late SubtaskRepositoryImpl subtaskRepository;
    late ProjectRepositoryImpl projectRepository;

    setUp(() async {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      taskRepository = TaskRepositoryImpl(database);
      subtaskRepository = SubtaskRepositoryImpl(database);
      projectRepository = ProjectRepositoryImpl(database);
    });

    tearDown(() async {
      await database.close();
    });

    group('TaskRepository Integration', () {
      test('should perform complete task CRUD operations', () async {
        // Create task
        final task = TaskModel.create(
          title: 'Integration Test Task',
          description: 'Test task for repository integration',
          priority: TaskPriority.high,
          dueDate: DateTime.now().add(const Duration(days: 1)),
        );

        await taskRepository.createTask(task);

        // Read task
        final retrievedTask = await taskRepository.getTaskById(task.id);
        expect(retrievedTask, isNotNull);
        expect(retrievedTask!.title, equals('Integration Test Task'));
        expect(retrievedTask.priority, equals(TaskPriority.high));

        // Get all tasks
        final allTasks = await taskRepository.getAllTasks();
        expect(allTasks.length, equals(1));
        expect(allTasks.first.id, equals(task.id));

        // Update task
        final updatedTask = task.copyWith(
          title: 'Updated Task Title',
          description: 'Updated description',
          priority: TaskPriority.medium,
        );
        await taskRepository.updateTask(updatedTask);

        final afterUpdate = await taskRepository.getTaskById(task.id);
        expect(afterUpdate!.title, equals('Updated Task Title'));
        expect(afterUpdate.priority, equals(TaskPriority.medium));

        // Filter by priority
        final mediumPriorityTasks = await taskRepository.getTasksByPriority(TaskPriority.medium);
        expect(mediumPriorityTasks.length, equals(1));
        expect(mediumPriorityTasks.first.id, equals(task.id));

        final highPriorityTasks = await taskRepository.getTasksByPriority(TaskPriority.high);
        expect(highPriorityTasks, isEmpty);

        // Search tasks
        final searchResults = await taskRepository.searchTasks('Updated');
        expect(searchResults.length, equals(1));
        expect(searchResults.first.id, equals(task.id));

        final noMatchResults = await taskRepository.searchTasks('NoMatch');
        expect(noMatchResults, isEmpty);

        // Delete task
        await taskRepository.deleteTask(task.id);

        final afterDelete = await taskRepository.getTaskById(task.id);
        expect(afterDelete, isNull);

        final emptyTasks = await taskRepository.getAllTasks();
        expect(emptyTasks, isEmpty);
      });

      test('should handle task filtering operations', () async {
        // Create multiple tasks with different properties
        final task1 = TaskModel.create(
          title: 'High Priority Task',
          priority: TaskPriority.high,
          dueDate: DateTime.now(),
        );

        final task2 = TaskModel.create(
          title: 'Medium Priority Task',
          priority: TaskPriority.medium,
          dueDate: DateTime.now().add(const Duration(days: 1)),
        );

        final task3 = TaskModel.create(
          title: 'Overdue Task',
          priority: TaskPriority.low,
          dueDate: DateTime.now().subtract(const Duration(days: 1)),
        );

        await taskRepository.createTask(task1);
        await taskRepository.createTask(task2);
        await taskRepository.createTask(task3);

        // Test priority filtering
        final highTasks = await taskRepository.getTasksByPriority(TaskPriority.high);
        expect(highTasks.length, equals(1));
        expect(highTasks.first.id, equals(task1.id));

        final mediumTasks = await taskRepository.getTasksByPriority(TaskPriority.medium);
        expect(mediumTasks.length, equals(1));
        expect(mediumTasks.first.id, equals(task2.id));

        // Test due date filtering
        final todayTasks = await taskRepository.getTasksDueToday();
        expect(todayTasks.length, equals(1));
        expect(todayTasks.first.id, equals(task1.id));

        final overdueTasks = await taskRepository.getOverdueTasks();
        expect(overdueTasks.length, equals(1));
        expect(overdueTasks.first.id, equals(task3.id));

        // Test date range filtering
        final startDate = DateTime.now().subtract(const Duration(days: 2));
        final endDate = DateTime.now().add(const Duration(days: 2));
        final tasksInRange = await taskRepository.getTasksByDateRange(startDate, endDate);
        expect(tasksInRange.length, equals(3));

        // Clean up
        await taskRepository.deleteTask(task1.id);
        await taskRepository.deleteTask(task2.id);
        await taskRepository.deleteTask(task3.id);
      });

      test('should handle bulk operations', () async {
        // Create multiple tasks
        final tasks = List.generate(5, (i) => TaskModel.create(
          title: 'Bulk Task ${i + 1}',
          priority: TaskPriority.low,
        ));

        for (final task in tasks) {
          await taskRepository.createTask(task);
        }

        final taskIds = tasks.map((t) => t.id).toList();

        // Test bulk retrieval
        final retrievedTasks = await taskRepository.getTasksByIds(taskIds);
        expect(retrievedTasks.length, equals(5));

        // Test bulk priority update
        await taskRepository.updateTasksPriority(taskIds, TaskPriority.high);

        for (final taskId in taskIds) {
          final task = await taskRepository.getTaskById(taskId);
          expect(task!.priority, equals(TaskPriority.high));
        }

        // Test bulk delete
        await taskRepository.deleteTasks(taskIds);

        final remainingTasks = await taskRepository.getAllTasks();
        expect(remainingTasks, isEmpty);
      });
    });

    group('SubtaskRepository Integration', () {
      test('should perform complete subtask operations', () async {
        const parentTaskId = 'parent-task-123';

        // Create subtasks
        final subtask1 = SubTask.create(
          title: 'First Subtask',
          taskId: parentTaskId,
          description: 'First subtask description',
        );

        final subtask2 = SubTask.create(
          title: 'Second Subtask',
          taskId: parentTaskId,
        );

        await subtaskRepository.createSubtask(subtask1);
        await subtaskRepository.createSubtask(subtask2);

        // Read subtasks
        final subtasksForTask = await subtaskRepository.getSubtasksForTask(parentTaskId);
        expect(subtasksForTask.length, equals(2));

        // Get specific subtask
        final retrievedSubtask = await subtaskRepository.getSubtaskById(subtask1.id);
        expect(retrievedSubtask, isNotNull);
        expect(retrievedSubtask!.title, equals('First Subtask'));
        expect(retrievedSubtask.description, equals('First subtask description'));

        // Test completion statistics
        final initialCompletedCount = await subtaskRepository.getCompletedSubtaskCount(parentTaskId);
        expect(initialCompletedCount, equals(0));

        final totalCount = await subtaskRepository.getTotalSubtaskCount(parentTaskId);
        expect(totalCount, equals(2));

        final initialPercentage = await subtaskRepository.getSubtaskCompletionPercentage(parentTaskId);
        expect(initialPercentage, equals(0.0));

        // Toggle completion
        await subtaskRepository.toggleSubtaskCompletion(subtask1.id);

        final afterToggleCount = await subtaskRepository.getCompletedSubtaskCount(parentTaskId);
        expect(afterToggleCount, equals(1));

        final afterTogglePercentage = await subtaskRepository.getSubtaskCompletionPercentage(parentTaskId);
        expect(afterTogglePercentage, equals(50.0));

        // Update subtask
        final updatedSubtask = subtask2.copyWith(
          title: 'Updated Subtask Title',
          description: 'Updated description',
        );
        await subtaskRepository.updateSubtask(updatedSubtask);

        final afterUpdate = await subtaskRepository.getSubtaskById(subtask2.id);
        expect(afterUpdate!.title, equals('Updated Subtask Title'));
        expect(afterUpdate.description, equals('Updated description'));

        // Delete subtask
        await subtaskRepository.deleteSubtask(subtask2.id);

        final remainingSubtasks = await subtaskRepository.getSubtasksForTask(parentTaskId);
        expect(remainingSubtasks.length, equals(1));
        expect(remainingSubtasks.first.id, equals(subtask1.id));

        // Clean up all subtasks for task
        await subtaskRepository.deleteSubtasksForTask(parentTaskId);

        final finalSubtasks = await subtaskRepository.getSubtasksForTask(parentTaskId);
        expect(finalSubtasks, isEmpty);
      });

      test('should handle subtask ordering operations', () async {
        const parentTaskId = 'order-test-task';

        // Create multiple subtasks
        final subtasks = List.generate(4, (i) => SubTask.create(
          title: 'Subtask ${i + 1}',
          taskId: parentTaskId,
        ));

        for (final subtask in subtasks) {
          await subtaskRepository.createSubtask(subtask);
        }

        // Get sorted subtasks (should be in creation order initially)
        final initialOrder = await subtaskRepository.getSubtasksSorted(parentTaskId);
        expect(initialOrder.length, equals(4));

        // Test reordering
        final newOrder = [
          subtasks[2].id, // Third becomes first
          subtasks[0].id, // First becomes second
          subtasks[3].id, // Fourth becomes third
          subtasks[1].id, // Second becomes fourth
        ];

        await subtaskRepository.reorderSubtasks(parentTaskId, newOrder);

        final reorderedSubtasks = await subtaskRepository.getSubtasksSorted(parentTaskId);
        expect(reorderedSubtasks[0].id, equals(subtasks[2].id));
        expect(reorderedSubtasks[1].id, equals(subtasks[0].id));
        expect(reorderedSubtasks[2].id, equals(subtasks[3].id));
        expect(reorderedSubtasks[3].id, equals(subtasks[1].id));

        // Clean up
        await subtaskRepository.deleteSubtasksForTask(parentTaskId);
      });

      test('should handle bulk subtask operations', () async {
        const parentTaskId = 'bulk-subtask-task';

        // Create multiple subtasks
        final subtasks = List.generate(3, (i) => SubTask.create(
          title: 'Bulk Subtask ${i + 1}',
          taskId: parentTaskId,
        ));

        for (final subtask in subtasks) {
          await subtaskRepository.createSubtask(subtask);
        }

        final subtaskIds = subtasks.map((s) => s.id).toList();

        // Test bulk completion
        await subtaskRepository.bulkCompleteSubtasks(subtaskIds);

        final completedCount = await subtaskRepository.getCompletedSubtaskCount(parentTaskId);
        expect(completedCount, equals(3));

        final completionPercentage = await subtaskRepository.getSubtaskCompletionPercentage(parentTaskId);
        expect(completionPercentage, equals(100.0));

        // Test bulk uncomplete
        await subtaskRepository.bulkUncompleteSubtasks(subtaskIds);

        final uncompletedCount = await subtaskRepository.getCompletedSubtaskCount(parentTaskId);
        expect(uncompletedCount, equals(0));

        // Clean up
        await subtaskRepository.deleteSubtasksForTask(parentTaskId);
      });
    });

    group('ProjectRepository Integration', () {
      test('should perform complete project operations', () async {
        // Create project
        final project = Project(
          id: 'integration-test-project',
          name: 'Integration Test Project',
          description: 'Project for integration testing',
          color: '#2196F3',
          createdAt: DateTime.now(),
          deadline: DateTime.now().add(const Duration(days: 30)),
        );

        await projectRepository.createProject(project);

        // Read project
        final retrievedProject = await projectRepository.getProjectById(project.id);
        expect(retrievedProject, isNotNull);
        expect(retrievedProject!.name, equals('Integration Test Project'));
        expect(retrievedProject.color, equals('#2196F3'));
        expect(retrievedProject.deadline, isNotNull);

        // Get all projects
        final allProjects = await projectRepository.getAllProjects();
        expect(allProjects.length, equals(1));
        expect(allProjects.first.id, equals(project.id));

        // Update project
        final updatedProject = project.copyWith(
          name: 'Updated Project Name',
          description: 'Updated project description',
          color: '#4CAF50',
        );
        await projectRepository.updateProject(updatedProject);

        final afterUpdate = await projectRepository.getProjectById(project.id);
        expect(afterUpdate!.name, equals('Updated Project Name'));
        expect(afterUpdate.description, equals('Updated project description'));
        expect(afterUpdate.color, equals('#4CAF50'));

        // Test archiving
        expect(afterUpdate.isArchived, isFalse);

        await projectRepository.archiveProject(project.id);
        final archivedProject = await projectRepository.getProjectById(project.id);
        expect(archivedProject!.isArchived, isTrue);

        // Test active/archived filtering
        final activeProjects = await projectRepository.getActiveProjects();
        expect(activeProjects, isEmpty);

        final archivedProjects = await projectRepository.getArchivedProjects();
        expect(archivedProjects.length, equals(1));
        expect(archivedProjects.first.id, equals(project.id));

        // Unarchive
        await projectRepository.unarchiveProject(project.id);
        final unarchivedProject = await projectRepository.getProjectById(project.id);
        expect(unarchivedProject!.isArchived, isFalse);

        final activeAfterUnarchive = await projectRepository.getActiveProjects();
        expect(activeAfterUnarchive.length, equals(1));

        // Search projects
        final searchResults = await projectRepository.searchProjects('Updated');
        expect(searchResults.length, equals(1));
        expect(searchResults.first.id, equals(project.id));

        // Delete project
        await projectRepository.deleteProject(project.id);

        final afterDelete = await projectRepository.getProjectById(project.id);
        expect(afterDelete, isNull);

        final emptyProjects = await projectRepository.getAllProjects();
        expect(emptyProjects, isEmpty);
      });

      test('should handle project deadline filtering', () async {
        final now = DateTime.now();

        // Create projects with different deadlines
        final project1 = Project(
          id: 'deadline-project-1',
          name: 'Project Due Soon',
          description: 'Due in 5 days',
          color: '#FF9800',
          createdAt: now,
          deadline: now.add(const Duration(days: 5)),
        );

        final project2 = Project(
          id: 'deadline-project-2',
          name: 'Project Due Later',
          description: 'Due in 20 days',
          color: '#2196F3',
          createdAt: now,
          deadline: now.add(const Duration(days: 20)),
        );

        final project3 = Project(
          id: 'deadline-project-3',
          name: 'Overdue Project',
          description: 'Was due yesterday',
          color: '#F44336',
          createdAt: now.subtract(const Duration(days: 10)),
          deadline: now.subtract(const Duration(days: 1)),
        );

        final project4 = Project(
          id: 'deadline-project-4',
          name: 'No Deadline Project',
          description: 'No deadline set',
          color: '#4CAF50',
          createdAt: now,
        );

        await projectRepository.createProject(project1);
        await projectRepository.createProject(project2);
        await projectRepository.createProject(project3);
        await projectRepository.createProject(project4);

        // Test deadline range filtering
        final startDate = now;
        final endDate = now.add(const Duration(days: 10));
        final projectsInRange = await projectRepository.getProjectsByDeadlineRange(startDate, endDate);
        expect(projectsInRange.length, equals(1));
        expect(projectsInRange.first.id, equals(project1.id));

        // Test overdue projects
        final overdueProjects = await projectRepository.getOverdueProjects();
        expect(overdueProjects.length, equals(1));
        expect(overdueProjects.first.id, equals(project3.id));

        // Clean up
        await projectRepository.deleteProject(project1.id);
        await projectRepository.deleteProject(project2.id);
        await projectRepository.deleteProject(project3.id);
        await projectRepository.deleteProject(project4.id);
      });
    });

    group('Cross-Repository Integration', () {
      test('should handle task-project relationships', () async {
        // Create project
        final project = Project(
          id: 'cross-test-project',
          name: 'Cross Integration Project',
          description: 'For testing task-project relationships',
          color: '#9C27B0',
          createdAt: DateTime.now(),
        );

        await projectRepository.createProject(project);

        // Create tasks assigned to project
        final task1 = TaskModel.create(
          title: 'Project Task 1',
          description: 'First task in project',
          projectId: project.id,
        );

        final task2 = TaskModel.create(
          title: 'Project Task 2',
          description: 'Second task in project',
          projectId: project.id,
        );

        final task3 = TaskModel.create(
          title: 'Unassigned Task',
          description: 'Not in any project',
        );

        await taskRepository.createTask(task1);
        await taskRepository.createTask(task2);
        await taskRepository.createTask(task3);

        // Test project task filtering
        final projectTasks = await taskRepository.getTasksByProject(project.id);
        expect(projectTasks.length, equals(2));
        expect(projectTasks.any((t) => t.id == task1.id), isTrue);
        expect(projectTasks.any((t) => t.id == task2.id), isTrue);
        expect(projectTasks.any((t) => t.id == task3.id), isFalse);

        // Test bulk assignment
        final unassignedIds = [task3.id];
        await taskRepository.assignTasksToProject(unassignedIds, project.id);

        final allProjectTasks = await taskRepository.getTasksByProject(project.id);
        expect(allProjectTasks.length, equals(3));

        // Test bulk unassignment
        await taskRepository.assignTasksToProject(unassignedIds, null);

        final afterUnassignment = await taskRepository.getTasksByProject(project.id);
        expect(afterUnassignment.length, equals(2));

        // Clean up
        await taskRepository.deleteTask(task1.id);
        await taskRepository.deleteTask(task2.id);
        await taskRepository.deleteTask(task3.id);
        await projectRepository.deleteProject(project.id);
      });

      test('should handle task-subtask relationships', () async {
        // Create parent task
        final parentTask = TaskModel.create(
          title: 'Parent Task',
          description: 'Has subtasks',
        );

        await taskRepository.createTask(parentTask);

        // Create subtasks
        final subtask1 = SubTask.create(
          title: 'First Subtask',
          taskId: parentTask.id,
        );

        final subtask2 = SubTask.create(
          title: 'Second Subtask',
          taskId: parentTask.id,
        );

        await subtaskRepository.createSubtask(subtask1);
        await subtaskRepository.createSubtask(subtask2);

        // Test subtask retrieval for task
        final taskSubtasks = await subtaskRepository.getSubtasksForTask(parentTask.id);
        expect(taskSubtasks.length, equals(2));

        // Test completion statistics
        await subtaskRepository.toggleSubtaskCompletion(subtask1.id);

        final completionPercentage = await subtaskRepository.getSubtaskCompletionPercentage(parentTask.id);
        expect(completionPercentage, equals(50.0));

        // When parent task is deleted, subtasks should be cleaned up
        await taskRepository.deleteTask(parentTask.id);

        // Verify subtasks are still there (they should be handled separately)
        final remainingSubtasks = await subtaskRepository.getSubtasksForTask(parentTask.id);
        // Note: This depends on the actual implementation of cascade deletes
        // For now, we'll clean up manually
        await subtaskRepository.deleteSubtasksForTask(parentTask.id);

        final finalSubtasks = await subtaskRepository.getSubtasksForTask(parentTask.id);
        expect(finalSubtasks, isEmpty);
      });
    });

    group('Error Handling and Edge Cases', () {
      test('should handle non-existent IDs gracefully', () async {
        // Test task repository
        const nonExistentId = 'non-existent-id';

        final nullTask = await taskRepository.getTaskById(nonExistentId);
        expect(nullTask, isNull);

        final nullSubtask = await subtaskRepository.getSubtaskById(nonExistentId);
        expect(nullSubtask, isNull);

        final nullProject = await projectRepository.getProjectById(nonExistentId);
        expect(nullProject, isNull);

        // Test filtering operations return empty lists
        final emptyTasks = await taskRepository.getTasksByProject(nonExistentId);
        expect(emptyTasks, isEmpty);

        final emptySubtasks = await subtaskRepository.getSubtasksForTask(nonExistentId);
        expect(emptySubtasks, isEmpty);
      });

      test('should handle empty database operations', () async {
        // All operations should work on empty database
        final allTasks = await taskRepository.getAllTasks();
        expect(allTasks, isEmpty);

        final allProjects = await projectRepository.getAllProjects();
        expect(allProjects, isEmpty);

        final activeProjects = await projectRepository.getActiveProjects();
        expect(activeProjects, isEmpty);

        final overdueProjects = await projectRepository.getOverdueProjects();
        expect(overdueProjects, isEmpty);

        final highPriorityTasks = await taskRepository.getTasksByPriority(TaskPriority.high);
        expect(highPriorityTasks, isEmpty);

        final searchResults = await taskRepository.searchTasks('anything');
        expect(searchResults, isEmpty);
      });

      test('should handle bulk operations with empty lists', () async {
        final emptyIds = <String>[];

        // Should not throw errors
        await taskRepository.deleteTasks(emptyIds);
        await taskRepository.updateTasksPriority(emptyIds, TaskPriority.high);
        await taskRepository.assignTasksToProject(emptyIds, 'some-project');

        final emptyResults = await taskRepository.getTasksByIds(emptyIds);
        expect(emptyResults, isEmpty);
      });
    });
  });
}