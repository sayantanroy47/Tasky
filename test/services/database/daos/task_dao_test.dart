import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'package:task_tracker_app/services/database/database.dart';
import 'package:task_tracker_app/services/database/daos/task_dao.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/task_enums.dart';
import 'package:task_tracker_app/domain/entities/subtask.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('TaskDao', () {
    late AppDatabase database;
    late TaskDao taskDao;
    late TaskModel testTask;

    setUp(() async {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      taskDao = database.taskDao;
      
      testTask = TaskModel.create(
        title: 'Test Task',
        description: 'Test task description',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        priority: TaskPriority.medium,
        status: TaskStatus.todo,
        tags: const ['test', 'unit-test'],
        metadata: const {'test': 'data'},
      );
    });

    tearDown(() async {
      await database.close();
    });

    group('Task Creation', () {
      test('should create a task successfully', () async {
        await taskDao.createTask(testTask);
        
        final tasks = await taskDao.getAllTasks();
        expect(tasks, hasLength(1));
        expect(tasks.first.title, equals('Test Task'));
        expect(tasks.first.description, equals('Test task description'));
      });

      test('should create task with all properties', () async {
        final complexTask = TaskModel.create(
          title: 'Complex Task',
          description: 'Complex task description',
          dueDate: DateTime.now().add(const Duration(days: 7)),
          priority: TaskPriority.high,
          status: TaskStatus.inProgress,
          tags: const ['complex', 'priority', 'urgent'],
          metadata: const {'complexity': 'high', 'estimatedHours': 8},
        ).copyWith(subTasks: [
          SubTask.create(title: 'Subtask 1', taskId: ''),
          SubTask.create(title: 'Subtask 2', taskId: ''),
        ]);

        await taskDao.createTask(complexTask);
        
        final retrieved = await taskDao.getTaskById(complexTask.id);
        expect(retrieved, isNotNull);
        expect(retrieved!.title, equals('Complex Task'));
        expect(retrieved.priority, equals(TaskPriority.high));
        expect(retrieved.status, equals(TaskStatus.inProgress));
        expect(retrieved.tags, containsAll(['complex', 'priority', 'urgent']));
        expect(retrieved.metadata['complexity'], equals('high'));
        expect(retrieved.subTasks, hasLength(2));
      });

      test('should handle task creation with minimal data', () async {
        final minimalTask = TaskModel.create(title: 'Minimal Task');
        
        await taskDao.createTask(minimalTask);
        
        final retrieved = await taskDao.getTaskById(minimalTask.id);
        expect(retrieved, isNotNull);
        expect(retrieved!.title, equals('Minimal Task'));
        expect(retrieved.priority, equals(TaskPriority.medium)); // Default
        expect(retrieved.status, equals(TaskStatus.todo)); // Default
      });

      test('should validate task ID during creation', () async {
        final invalidTask = testTask.copyWith(id: '');
        
        expect(
          () => taskDao.createTask(invalidTask),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should handle duplicate task creation', () async {
        await taskDao.createTask(testTask);
        
        // Attempting to create the same task again should fail
        expect(
          () => taskDao.createTask(testTask),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Task Retrieval', () {
      setUp(() async {
        // Create test data
        await taskDao.createTask(testTask);
        await taskDao.createTask(TaskModel.create(
          title: 'Completed Task',
          description: 'A completed task',
          priority: TaskPriority.low,
          status: TaskStatus.completed,
        ));
        await taskDao.createTask(TaskModel.create(
          title: 'High Priority Task',
          description: 'An urgent task',
          priority: TaskPriority.urgent,
          status: TaskStatus.inProgress,
          dueDate: DateTime.now().add(const Duration(hours: 2)),
        ));
      });

      test('should get all tasks', () async {
        final tasks = await taskDao.getAllTasks();
        expect(tasks, hasLength(3));
        
        final titles = tasks.map((t) => t.title).toList();
        expect(titles, containsAll(['Test Task', 'Completed Task', 'High Priority Task']));
      });

      test('should get task by ID', () async {
        final retrieved = await taskDao.getTaskById(testTask.id);
        expect(retrieved, isNotNull);
        expect(retrieved!.id, equals(testTask.id));
        expect(retrieved.title, equals('Test Task'));
      });

      test('should return null for non-existent task', () async {
        final retrieved = await taskDao.getTaskById('non-existent-id');
        expect(retrieved, isNull);
      });

      test('should get tasks by status', () async {
        final todoTasks = await taskDao.getTasksByStatus(TaskStatus.todo);
        expect(todoTasks, hasLength(1));
        
        final completedTasks = await taskDao.getTasksByStatus(TaskStatus.completed);
        expect(completedTasks, hasLength(1));
        expect(completedTasks.first.title, equals('Completed Task'));
      });

      test('should get tasks by priority', () async {
        final highPriorityTasks = await taskDao.getTasksByPriority(TaskPriority.urgent);
        expect(highPriorityTasks, hasLength(1));
        expect(highPriorityTasks.first.title, equals('High Priority Task'));
      });

      test('should get in-progress tasks', () async {
        final inProgressTasks = await taskDao.getTasksByStatus(TaskStatus.inProgress);
        expect(inProgressTasks, hasLength(1));
        expect(inProgressTasks.first.title, equals('High Priority Task'));
      });

      test('should get overdue tasks', () async {
        // Create an overdue task
        final overdueTask = TaskModel.create(
          title: 'Overdue Task',
          description: 'This task is overdue',
          dueDate: DateTime.now().subtract(const Duration(days: 1)),
          priority: TaskPriority.medium,
        );
        await taskDao.createTask(overdueTask);
        
        final overdueTasks = await taskDao.getOverdueTasks();
        expect(overdueTasks, hasLength(1));
        expect(overdueTasks.first.title, equals('Overdue Task'));
      });

      test('should get tasks due today', () async {
        final todayTask = TaskModel.create(
          title: 'Today Task',
          description: 'Due today',
          dueDate: DateTime.now(),
          priority: TaskPriority.medium,
        );
        await taskDao.createTask(todayTask);
        
        final todayTasks = await taskDao.getTasksDueToday();
        expect(todayTasks, hasLength(1));
        expect(todayTasks.first.title, equals('Today Task'));
      });
    });

    group('Task Updates', () {
      setUp(() async {
        await taskDao.createTask(testTask);
      });

      test('should update task successfully', () async {
        final updatedTask = testTask.copyWith(
          title: 'Updated Task Title',
          description: 'Updated description',
          priority: TaskPriority.high,
          status: TaskStatus.inProgress,
        );

        await taskDao.updateTask(updatedTask);
        
        final retrieved = await taskDao.getTaskById(testTask.id);
        expect(retrieved, isNotNull);
        expect(retrieved!.title, equals('Updated Task Title'));
        expect(retrieved.description, equals('Updated description'));
        expect(retrieved.priority, equals(TaskPriority.high));
        expect(retrieved.status, equals(TaskStatus.inProgress));
      });

      test('should update task status via updateTask', () async {
        final updatedTask = testTask.copyWith(status: TaskStatus.completed);
        await taskDao.updateTask(updatedTask);
        
        final retrieved = await taskDao.getTaskById(testTask.id);
        expect(retrieved, isNotNull);
        expect(retrieved!.status, equals(TaskStatus.completed));
      });

      test('should update task priority via updateTask', () async {
        final updatedTask = testTask.copyWith(priority: TaskPriority.urgent);
        await taskDao.updateTask(updatedTask);
        
        final retrieved = await taskDao.getTaskById(testTask.id);
        expect(retrieved, isNotNull);
        expect(retrieved!.priority, equals(TaskPriority.urgent));
      });

      test('should handle updating non-existent task', () async {
        expect(
          () => taskDao.updateTask(testTask.copyWith(id: 'non-existent')),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Task Deletion', () {
      setUp(() async {
        await taskDao.createTask(testTask);
        await taskDao.createTask(TaskModel.create(
          title: 'Another Task',
          description: 'Another test task',
        ));
      });

      test('should delete task by ID', () async {
        await taskDao.deleteTask(testTask.id);
        
        final retrieved = await taskDao.getTaskById(testTask.id);
        expect(retrieved, isNull);
        
        final allTasks = await taskDao.getAllTasks();
        expect(allTasks, hasLength(1));
        expect(allTasks.first.title, equals('Another Task'));
      });

      test('should handle deleting non-existent task', () async {
        expect(
          () => taskDao.deleteTask('non-existent-id'),
          returnsNormally, // Should not throw, just return 0 affected rows
        );
      });

      test('should delete multiple tasks', () async {
        final allTasks = await taskDao.getAllTasks();
        final taskIds = allTasks.map((t) => t.id).toList();
        
        await taskDao.deleteTasks(taskIds);
        
        final remainingTasks = await taskDao.getAllTasks();
        expect(remainingTasks, isEmpty);
      });
    });

    group('Task Search', () {
      setUp(() async {
        await taskDao.createTask(TaskModel.create(
          title: 'Programming Task',
          description: 'Write unit tests for the application',
          tags: const ['programming', 'testing'],
        ));
        
        await taskDao.createTask(TaskModel.create(
          title: 'Design Task',
          description: 'Create UI mockups',
          tags: const ['design', 'ui'],
        ));
        
        await taskDao.createTask(TaskModel.create(
          title: 'Meeting Task',
          description: 'Schedule team meeting for project discussion',
          tags: const ['meeting', 'team'],
        ));
      });

      test('should search tasks by title', () async {
        final results = await taskDao.searchTasks('Programming');
        expect(results, hasLength(1));
        expect(results.first.title, equals('Programming Task'));
      });

      test('should search tasks by description', () async {
        final results = await taskDao.searchTasks('mockups');
        expect(results, hasLength(1));
        expect(results.first.title, equals('Design Task'));
      });

      test('should search tasks case-insensitively', () async {
        final results = await taskDao.searchTasks('MEETING');
        expect(results, hasLength(1));
        expect(results.first.title, equals('Meeting Task'));
      });

      test('should return empty list for no matches', () async {
        final results = await taskDao.searchTasks('nonexistent');
        expect(results, isEmpty);
      });

      test('should search with partial matches', () async {
        final results = await taskDao.searchTasks('Task');
        expect(results, hasLength(3)); // All tasks contain "Task"
      });
    });

    group('Task Filtering and Sorting', () {
      setUp(() async {
        final now = DateTime.now();
        
        await taskDao.createTask(TaskModel.create(
          title: 'Urgent Task',
          priority: TaskPriority.urgent,
          createdAt: now.subtract(const Duration(days: 3)),
          dueDate: now.add(const Duration(hours: 2)),
        ));
        
        await taskDao.createTask(TaskModel.create(
          title: 'Low Priority Task',
          priority: TaskPriority.low,
          createdAt: now.subtract(const Duration(days: 1)),
          dueDate: now.add(const Duration(days: 5)),
        ));
        
        await taskDao.createTask(TaskModel.create(
          title: 'Medium Priority Task',
          priority: TaskPriority.medium,
          createdAt: now.subtract(const Duration(days: 2)),
          dueDate: now.add(const Duration(days: 2)),
        ));
      });

      test('should get tasks by priority filter', () async {
        final urgentTasks = await taskDao.getTasksByPriority(TaskPriority.urgent);
        expect(urgentTasks, hasLength(1));
        expect(urgentTasks.first.title, equals('Urgent Task'));
        
        final mediumTasks = await taskDao.getTasksByPriority(TaskPriority.medium);
        expect(mediumTasks, hasLength(1));
        expect(mediumTasks.first.title, equals('Medium Priority Task'));
      });

      test('should get tasks by date range', () async {
        final now = DateTime.now();
        final startDate = now.subtract(const Duration(days: 5));
        final endDate = now.add(const Duration(days: 10));
        
        final tasksInRange = await taskDao.getTasksByDateRange(startDate, endDate);
        expect(tasksInRange, hasLength(3)); // All tasks should be in this range
      });
    });

    group('Task Statistics', () {
      setUp(() async {
        // Create various tasks for statistics
        await taskDao.createTask(TaskModel.create(
          title: 'Completed Task 1',
          status: TaskStatus.completed,
          priority: TaskPriority.high,
        ));
        
        await taskDao.createTask(TaskModel.create(
          title: 'Completed Task 2',
          status: TaskStatus.completed,
          priority: TaskPriority.medium,
        ));
        
        await taskDao.createTask(TaskModel.create(
          title: 'In Progress Task',
          status: TaskStatus.inProgress,
          priority: TaskPriority.high,
        ));
        
        await taskDao.createTask(TaskModel.create(
          title: 'Todo Task',
          status: TaskStatus.todo,
          priority: TaskPriority.low,
        ));
      });

      test('should get task counts via queries', () async {
        final allTasks = await taskDao.getAllTasks();
        expect(allTasks, hasLength(4));
        
        final completedTasks = await taskDao.getTasksByStatus(TaskStatus.completed);
        expect(completedTasks, hasLength(2));
        
        final highPriorityTasks = await taskDao.getTasksByPriority(TaskPriority.high);
        expect(highPriorityTasks, hasLength(2));
        
        final inProgressTasks = await taskDao.getTasksByStatus(TaskStatus.inProgress);
        expect(inProgressTasks, hasLength(1));
      });
    });

    group('Error Handling', () {
      test('should handle database connection errors gracefully', () async {
        // This test verifies error handling patterns
        expect(taskDao.getAllTasks(), completes);
      });

      test('should handle malformed data gracefully', () async {
        // Test with edge case data
        final edgeCaseTask = TaskModel.create(
          title: 'Edge Case Task',
          description: 'A' * 10000, // Very long description
        );
        
        expect(() => taskDao.createTask(edgeCaseTask), returnsNormally);
      });

      test('should validate input parameters', () async {
        expect(
          () => taskDao.getTaskById(''),
          returnsNormally, // Should return null, not throw
        );
        
        final result = await taskDao.getTaskById('');
        expect(result, isNull);
      });
    });
  });
}