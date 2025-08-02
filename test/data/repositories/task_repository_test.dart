import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:task_tracker_app/services/database/database.dart';
import 'package:task_tracker_app/data/repositories/task_repository_impl.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/task_enums.dart';
import 'package:task_tracker_app/domain/entities/subtask.dart' as domain;
import 'package:task_tracker_app/domain/entities/project.dart' as domain;
import 'package:task_tracker_app/domain/repositories/task_repository.dart';
import 'package:task_tracker_app/services/database/daos/tag_dao.dart' as dao;

void main() {
  group('TaskRepositoryImpl', () {
    late AppDatabase database;
    late TaskRepository repository;

    setUp(() async {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      repository = TaskRepositoryImpl(database);
    });

    tearDown(() async {
      await database.close();
    });

    group('Basic CRUD Operations', () {
      test('should create and retrieve a task', () async {
        final task = TaskModel.create(
          title: 'Test Task',
          description: 'A test task',
          priority: TaskPriority.high,
        );

        await repository.createTask(task);
        final retrievedTask = await repository.getTaskById(task.id);

        expect(retrievedTask, isNotNull);
        expect(retrievedTask!.id, task.id);
        expect(retrievedTask.title, task.title);
        expect(retrievedTask.description, task.description);
        expect(retrievedTask.priority, task.priority);
      });

      test('should update a task', () async {
        final task = TaskModel.create(title: 'Original Title');
        await repository.createTask(task);

        final updatedTask = task.copyWith(
          title: 'Updated Title',
          status: TaskStatus.completed,
        );
        await repository.updateTask(updatedTask);

        final retrievedTask = await repository.getTaskById(task.id);
        expect(retrievedTask!.title, 'Updated Title');
        expect(retrievedTask.status, TaskStatus.completed);
      });

      test('should delete a task', () async {
        final task = TaskModel.create(title: 'Task to Delete');
        await repository.createTask(task);

        await repository.deleteTask(task.id);
        final retrievedTask = await repository.getTaskById(task.id);

        expect(retrievedTask, isNull);
      });

      test('should get all tasks', () async {
        final task1 = TaskModel.create(title: 'Task 1');
        final task2 = TaskModel.create(title: 'Task 2');

        await repository.createTask(task1);
        await repository.createTask(task2);

        final allTasks = await repository.getAllTasks();

        expect(allTasks.length, 2);
        expect(allTasks.any((t) => t.title == 'Task 1'), true);
        expect(allTasks.any((t) => t.title == 'Task 2'), true);
      });
    });

    group('Filtering Operations', () {
      late TaskModel pendingTask;
      late TaskModel completedTask;
      late TaskModel highPriorityTask;
      late TaskModel lowPriorityTask;

      setUp(() async {
        pendingTask = TaskModel.create(title: 'Pending Task');
        completedTask = TaskModel.create(title: 'Completed Task').markCompleted();
        highPriorityTask = TaskModel.create(title: 'High Priority', priority: TaskPriority.high);
        lowPriorityTask = TaskModel.create(title: 'Low Priority', priority: TaskPriority.low);

        await repository.createTask(pendingTask);
        await repository.createTask(completedTask);
        await repository.createTask(highPriorityTask);
        await repository.createTask(lowPriorityTask);
      });

      test('should get tasks by status', () async {
        final pendingTasks = await repository.getTasksByStatus(TaskStatus.pending);
        final completedTasks = await repository.getTasksByStatus(TaskStatus.completed);

        expect(pendingTasks.length, 3); // pendingTask, highPriorityTask, lowPriorityTask
        expect(completedTasks.length, 1); // completedTask
        expect(completedTasks.first.title, 'Completed Task');
      });

      test('should get tasks by priority', () async {
        final highPriorityTasks = await repository.getTasksByPriority(TaskPriority.high);
        final lowPriorityTasks = await repository.getTasksByPriority(TaskPriority.low);

        expect(highPriorityTasks.length, 1);
        expect(highPriorityTasks.first.title, 'High Priority');
        expect(lowPriorityTasks.length, 1);
        expect(lowPriorityTasks.first.title, 'Low Priority');
      });

      test('should get tasks due today', () async {
        final todayTask = TaskModel.create(
          title: 'Due Today',
          dueDate: DateTime.now(),
        );
        await repository.createTask(todayTask);

        final tasksDueToday = await repository.getTasksDueToday();

        expect(tasksDueToday.length, 1);
        expect(tasksDueToday.first.title, 'Due Today');
      });

      test('should get overdue tasks', () async {
        final overdueTask = TaskModel.create(
          title: 'Overdue Task',
          dueDate: DateTime.now().subtract(const Duration(days: 1)),
        );
        await repository.createTask(overdueTask);

        final overdueTasks = await repository.getOverdueTasks();

        expect(overdueTasks.length, 1);
        expect(overdueTasks.first.title, 'Overdue Task');
      });

      test('should get tasks by project', () async {
        // First create a project
        const projectId = 'project-1';
        final project = domain.Project(
          id: projectId,
          name: 'Test Project',
          color: '#FF0000',
          createdAt: DateTime.now(),
          taskIds: const [],
        );
        await database.projectDao.createProject(project);

        final projectTask = TaskModel.create(
          title: 'Project Task',
          projectId: projectId,
        );
        await repository.createTask(projectTask);

        final projectTasks = await repository.getTasksByProject(projectId);

        expect(projectTasks.length, 1);
        expect(projectTasks.first.title, 'Project Task');
      });

      test('should search tasks', () async {
        final searchResults = await repository.searchTasks('Priority');

        expect(searchResults.length, 2); // High Priority and Low Priority
        expect(searchResults.any((t) => t.title == 'High Priority'), true);
        expect(searchResults.any((t) => t.title == 'Low Priority'), true);
      });
    });

    group('Advanced Filtering', () {
      test('should filter tasks with TaskFilter', () async {
        final task1 = TaskModel.create(
          title: 'Important Task',
          priority: TaskPriority.high,
          isPinned: true,
        );
        final task2 = TaskModel.create(
          title: 'Regular Task',
          priority: TaskPriority.medium,
        ).markCompleted();

        await repository.createTask(task1);
        await repository.createTask(task2);

        // Filter by status
        const filter1 = TaskFilter(status: TaskStatus.pending);
        final pendingTasks = await repository.getTasksWithFilter(filter1);
        expect(pendingTasks.length, 1);
        expect(pendingTasks.first.title, 'Important Task');

        // Filter by priority
        const filter2 = TaskFilter(priority: TaskPriority.high);
        final highPriorityTasks = await repository.getTasksWithFilter(filter2);
        expect(highPriorityTasks.length, 1);
        expect(highPriorityTasks.first.title, 'Important Task');

        // Filter by pinned status
        const filter3 = TaskFilter(isPinned: true);
        final pinnedTasks = await repository.getTasksWithFilter(filter3);
        expect(pinnedTasks.length, 1);
        expect(pinnedTasks.first.title, 'Important Task');

        // Search filter
        const filter4 = TaskFilter(searchQuery: 'Important');
        final searchResults = await repository.getTasksWithFilter(filter4);
        expect(searchResults.length, 1);
        expect(searchResults.first.title, 'Important Task');
      });

      test('should sort tasks with TaskFilter', () async {
        final task1 = TaskModel.create(title: 'B Task', priority: TaskPriority.low);
        final task2 = TaskModel.create(title: 'A Task', priority: TaskPriority.high);

        await repository.createTask(task1);
        await repository.createTask(task2);

        // Sort by title ascending
        const filter1 = TaskFilter(
          sortBy: TaskSortBy.title,
          sortAscending: true,
        );
        final sortedByTitle = await repository.getTasksWithFilter(filter1);
        expect(sortedByTitle.first.title, 'A Task');
        expect(sortedByTitle.last.title, 'B Task');

        // Sort by priority descending
        const filter2 = TaskFilter(
          sortBy: TaskSortBy.priority,
          sortAscending: false,
        );
        final sortedByPriority = await repository.getTasksWithFilter(filter2);
        expect(sortedByPriority.first.priority, TaskPriority.high);
        expect(sortedByPriority.last.priority, TaskPriority.low);
      });

      test('should filter by date range', () async {
        final now = DateTime.now();
        final yesterday = now.subtract(const Duration(days: 1));
        final tomorrow = now.add(const Duration(days: 1));

        final task1 = TaskModel.create(title: 'Yesterday Task', dueDate: yesterday);
        final task2 = TaskModel.create(title: 'Tomorrow Task', dueDate: tomorrow);

        await repository.createTask(task1);
        await repository.createTask(task2);

        // Filter tasks due from today onwards
        final filter = TaskFilter(dueDateFrom: now);
        final futureTasks = await repository.getTasksWithFilter(filter);

        expect(futureTasks.length, 1);
        expect(futureTasks.first.title, 'Tomorrow Task');
      });
    });

    group('Complex Task Operations', () {
      test('should handle tasks with subtasks', () async {
        final subTask1 = domain.SubTask.create(taskId: 'task-1', title: 'Subtask 1');
        final subTask2 = domain.SubTask.create(taskId: 'task-1', title: 'Subtask 2');
        
        final task = TaskModel(
          id: 'task-1',
          title: 'Task with Subtasks',
          createdAt: DateTime.now(),
          subTasks: [subTask1, subTask2],
        );

        await repository.createTask(task);
        final retrievedTask = await repository.getTaskById(task.id);

        expect(retrievedTask, isNotNull);
        expect(retrievedTask!.subTasks.length, 2);
        expect(retrievedTask.subTasks[0].title, 'Subtask 1');
        expect(retrievedTask.subTasks[1].title, 'Subtask 2');
      });

      test('should handle tasks with tags', () async {
        // First create the tags
        final tag1 = dao.Tag(id: 'tag-1', name: 'work', createdAt: DateTime.now());
        final tag2 = dao.Tag(id: 'tag-2', name: 'urgent', createdAt: DateTime.now());
        await database.tagDao.createTag(tag1);
        await database.tagDao.createTag(tag2);

        final task = TaskModel.create(
          title: 'Tagged Task',
          tags: const ['tag-1', 'tag-2'],
        );

        await repository.createTask(task);
        final retrievedTask = await repository.getTaskById(task.id);

        expect(retrievedTask, isNotNull);
        expect(retrievedTask!.tags.length, 2);
        expect(retrievedTask.tags, containsAll(['tag-1', 'tag-2']));
      });

      test('should handle tasks with dependencies', () async {
        final task1 = TaskModel.create(title: 'Task 1');
        final task2 = TaskModel.create(
          title: 'Task 2',
          dependencies: [task1.id],
        );

        await repository.createTask(task1);
        await repository.createTask(task2);

        final retrievedTask2 = await repository.getTaskById(task2.id);
        expect(retrievedTask2!.dependencies, contains(task1.id));
      });
    });

    group('Stream Operations', () {
      test('should watch all tasks', () async {
        final task = TaskModel.create(title: 'Watched Task');
        
        // Start watching
        final stream = repository.watchAllTasks();
        final future = stream.first;

        // Create task
        await repository.createTask(task);

        // Verify stream emits the task
        final tasks = await future;
        expect(tasks.any((t) => t.title == 'Watched Task'), true);
      });

      test('should watch tasks by status', () async {
        final pendingTask = TaskModel.create(title: 'Pending Task');
        
        // Start watching pending tasks
        final stream = repository.watchTasksByStatus(TaskStatus.pending);
        final future = stream.first;

        // Create task
        await repository.createTask(pendingTask);

        // Verify stream emits the task
        final tasks = await future;
        expect(tasks.any((t) => t.title == 'Pending Task'), true);
      });

      test('should watch tasks by project', () async {
        // First create a project
        const projectId = 'project-1';
        final project = domain.Project(
          id: projectId,
          name: 'Test Project',
          color: '#FF0000',
          createdAt: DateTime.now(),
          taskIds: const [],
        );
        await database.projectDao.createProject(project);

        final projectTask = TaskModel.create(
          title: 'Project Task',
          projectId: projectId,
        );
        
        // Start watching project tasks
        final stream = repository.watchTasksByProject(projectId);
        final future = stream.first;

        // Create task
        await repository.createTask(projectTask);

        // Verify stream emits the task
        final tasks = await future;
        expect(tasks.any((t) => t.title == 'Project Task'), true);
      });
    });
  });
}