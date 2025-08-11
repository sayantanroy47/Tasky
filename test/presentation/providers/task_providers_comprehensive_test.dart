import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:task_tracker_app/presentation/providers/task_providers.dart';
import 'package:task_tracker_app/presentation/providers/task_provider.dart';
import 'package:task_tracker_app/domain/repositories/task_repository.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/models/enums.dart';
import 'package:task_tracker_app/core/errors/failures.dart';
import 'package:dartz/dartz.dart';

@GenerateMocks([TaskRepository])
import 'task_providers_comprehensive_test.mocks.dart';

/// COMPREHENSIVE TASK PROVIDERS TESTS - ALL STATE MANAGEMENT LOGIC
void main() {
  group('TaskProviders - Comprehensive State Management Tests', () {
    late MockTaskRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      mockRepository = MockTaskRepository();
      container = ProviderContainer(
        overrides: [
          taskRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Task Operations Provider Tests', () {
      test('should create task successfully and update state', () async {
        // Arrange
        final task = TaskModel.create(title: 'New Task');
        when(mockRepository.createTask(any))
            .thenAnswer((_) async => Right(task));
        when(mockRepository.getAllTasks())
            .thenAnswer((_) async => Right([task]));

        // Act
        final operations = container.read(taskOperationsProvider);
        await operations.createTask(task);

        // Assert
        final allTasks = await container.read(allTasksProvider.future);
        expect(allTasks, contains(task));
        verify(mockRepository.createTask(task)).called(1);
      });

      test('should handle task creation failure', () async {
        // Arrange
        final task = TaskModel.create(title: 'Failed Task');
        when(mockRepository.createTask(any))
            .thenAnswer((_) async => Left(DatabaseFailure('Creation failed')));

        // Act & Assert
        final operations = container.read(taskOperationsProvider);
        expect(
          () => operations.createTask(task),
          throwsA(isA<Exception>()),
        );
      });

      test('should update task and refresh state', () async {
        // Arrange
        final originalTask = TaskModel.create(title: 'Original');
        final updatedTask = originalTask.copyWith(title: 'Updated');
        
        when(mockRepository.updateTask(any))
            .thenAnswer((_) async => Right(updatedTask));
        when(mockRepository.getAllTasks())
            .thenAnswer((_) async => Right([updatedTask]));

        // Act
        final operations = container.read(taskOperationsProvider);
        await operations.updateTask(updatedTask);

        // Assert
        final allTasks = await container.read(allTasksProvider.future);
        expect(allTasks.any((t) => t.title == 'Updated'), isTrue);
        verify(mockRepository.updateTask(updatedTask)).called(1);
      });

      test('should delete task and update state', () async {
        // Arrange
        final task = TaskModel.create(title: 'To Delete');
        when(mockRepository.deleteTask(task.id))
            .thenAnswer((_) async => const Right(true));
        when(mockRepository.getAllTasks())
            .thenAnswer((_) async => const Right([]));

        // Act
        final operations = container.read(taskOperationsProvider);
        await operations.deleteTask(task.id);

        // Assert
        final allTasks = await container.read(allTasksProvider.future);
        expect(allTasks, isEmpty);
        verify(mockRepository.deleteTask(task.id)).called(1);
      });

      test('should complete task and update completion status', () async {
        // Arrange
        final task = TaskModel.create(title: 'To Complete');
        final completedTask = task.complete();
        
        when(mockRepository.updateTask(any))
            .thenAnswer((_) async => Right(completedTask));
        when(mockRepository.getCompletedTasks())
            .thenAnswer((_) async => Right([completedTask]));

        // Act
        final operations = container.read(taskOperationsProvider);
        await operations.completeTask(task.id);

        // Assert
        final completedTasks = await container.read(completedTasksProvider.future);
        expect(completedTasks, contains(completedTask));
        expect(completedTask.isCompleted, isTrue);
        expect(completedTask.completedAt, isNotNull);
      });

      test('should reopen completed task', () async {
        // Arrange
        final completedTask = TaskModel.create(title: 'Completed').complete();
        final reopenedTask = completedTask.reopen();
        
        when(mockRepository.updateTask(any))
            .thenAnswer((_) async => Right(reopenedTask));
        when(mockRepository.getPendingTasks())
            .thenAnswer((_) async => Right([reopenedTask]));

        // Act
        final operations = container.read(taskOperationsProvider);
        await operations.reopenTask(completedTask.id);

        // Assert
        final pendingTasks = await container.read(pendingTasksProvider.future);
        expect(pendingTasks, contains(reopenedTask));
        expect(reopenedTask.isCompleted, isFalse);
        expect(reopenedTask.completedAt, isNull);
      });
    });

    group('Task Filtering Providers Tests', () {
      test('should filter pending tasks correctly', () async {
        // Arrange
        final tasks = [
          TaskModel.create(title: 'Pending 1', status: TaskStatus.pending),
          TaskModel.create(title: 'Completed 1').complete(),
          TaskModel.create(title: 'Pending 2', status: TaskStatus.inProgress),
        ];
        final pendingTasks = tasks.where((t) => !t.isCompleted).toList();
        
        when(mockRepository.getPendingTasks())
            .thenAnswer((_) async => Right(pendingTasks));

        // Act
        final result = await container.read(pendingTasksProvider.future);

        // Assert
        expect(result.length, equals(2));
        expect(result.every((task) => !task.isCompleted), isTrue);
        verify(mockRepository.getPendingTasks()).called(1);
      });

      test('should filter completed tasks correctly', () async {
        // Arrange
        final tasks = [
          TaskModel.create(title: 'Pending 1'),
          TaskModel.create(title: 'Completed 1').complete(),
          TaskModel.create(title: 'Completed 2').complete(),
        ];
        final completedTasks = tasks.where((t) => t.isCompleted).toList();
        
        when(mockRepository.getCompletedTasks())
            .thenAnswer((_) async => Right(completedTasks));

        // Act
        final result = await container.read(completedTasksProvider.future);

        // Assert
        expect(result.length, equals(2));
        expect(result.every((task) => task.isCompleted), isTrue);
        verify(mockRepository.getCompletedTasks()).called(1);
      });

      test('should filter today tasks correctly', () async {
        // Arrange
        final today = DateTime.now();
        final todayTasks = [
          TaskModel.create(
            title: 'Due Today',
            dueDate: DateTime(today.year, today.month, today.day),
          ),
          TaskModel.create(
            title: 'Created Today',
            createdAt: today,
          ),
        ];
        
        when(mockRepository.getTodayTasks())
            .thenAnswer((_) async => Right(todayTasks));

        // Act
        final result = await container.read(todayTasksProvider.future);

        // Assert
        expect(result.length, equals(2));
        verify(mockRepository.getTodayTasks()).called(1);
      });

      test('should filter overdue tasks correctly', () async {
        // Arrange
        final now = DateTime.now();
        final overdueTasks = [
          TaskModel.create(
            title: 'Overdue 1',
            dueDate: now.subtract(const Duration(days: 1)),
          ),
          TaskModel.create(
            title: 'Overdue 2',
            dueDate: now.subtract(const Duration(hours: 2)),
          ),
        ];
        
        when(mockRepository.getOverdueTasks())
            .thenAnswer((_) async => Right(overdueTasks));

        // Act
        final result = await container.read(overdueTasksProvider.future);

        // Assert
        expect(result.length, equals(2));
        expect(result.every((task) => task.isOverdue), isTrue);
        verify(mockRepository.getOverdueTasks()).called(1);
      });

      test('should filter future tasks correctly', () async {
        // Arrange
        final futureDate = DateTime.now().add(const Duration(days: 7));
        final futureTasks = [
          TaskModel.create(
            title: 'Future 1',
            dueDate: futureDate,
          ),
          TaskModel.create(
            title: 'Future 2',
            dueDate: futureDate.add(const Duration(hours: 5)),
          ),
        ];
        
        when(mockRepository.getFutureTasks())
            .thenAnswer((_) async => Right(futureTasks));

        // Act
        final result = await container.read(futureTasksProvider.future);

        // Assert
        expect(result.length, equals(2));
        verify(mockRepository.getFutureTasks()).called(1);
      });
    });

    group('Task Priority Providers Tests', () {
      test('should filter high priority tasks correctly', () async {
        // Arrange
        final tasks = [
          TaskModel.create(title: 'Low', priority: TaskPriority.low),
          TaskModel.create(title: 'High', priority: TaskPriority.high),
          TaskModel.create(title: 'Urgent', priority: TaskPriority.urgent),
        ];
        final highPriorityTasks = tasks.where((t) => 
            t.priority == TaskPriority.high || t.priority == TaskPriority.urgent).toList();
        
        when(mockRepository.getTasksByPriority(TaskPriority.high))
            .thenAnswer((_) async => Right([tasks[1]]));
        when(mockRepository.getTasksByPriority(TaskPriority.urgent))
            .thenAnswer((_) async => Right([tasks[2]]));

        // Act
        final result = await container.read(highPriorityTasksProvider.future);

        // Assert
        expect(result.any((t) => t.priority == TaskPriority.high), isTrue);
        expect(result.any((t) => t.priority == TaskPriority.urgent), isTrue);
        expect(result.any((t) => t.priority == TaskPriority.low), isFalse);
      });
    });

    group('Task Search Provider Tests', () {
      test('should search tasks by query correctly', () async {
        // Arrange
        const searchQuery = 'important meeting';
        final matchingTasks = [
          TaskModel.create(title: 'Important Meeting Tomorrow'),
          TaskModel.create(
            title: 'Task',
            description: 'Prepare for the important meeting',
          ),
        ];
        
        when(mockRepository.searchTasks(searchQuery))
            .thenAnswer((_) async => Right(matchingTasks));

        // Act
        final searchNotifier = container.read(taskSearchProvider.notifier);
        await searchNotifier.searchTasks(searchQuery);
        final result = container.read(taskSearchProvider);

        // Assert
        expect(result.when(
          data: (tasks) => tasks.length,
          loading: () => 0,
          error: (_, __) => 0,
        ), equals(2));
        verify(mockRepository.searchTasks(searchQuery)).called(1);
      });

      test('should clear search results', () async {
        // Arrange
        const searchQuery = 'test';
        final matchingTasks = [TaskModel.create(title: 'Test Task')];
        
        when(mockRepository.searchTasks(searchQuery))
            .thenAnswer((_) async => Right(matchingTasks));

        // Act
        final searchNotifier = container.read(taskSearchProvider.notifier);
        await searchNotifier.searchTasks(searchQuery);
        searchNotifier.clearSearch();
        final result = container.read(taskSearchProvider);

        // Assert
        expect(result.when(
          data: (tasks) => tasks.isEmpty,
          loading: () => false,
          error: (_, __) => false,
        ), isTrue);
      });

      test('should handle search with empty query', () async {
        // Act
        final searchNotifier = container.read(taskSearchProvider.notifier);
        await searchNotifier.searchTasks('');
        final result = container.read(taskSearchProvider);

        // Assert
        expect(result.when(
          data: (tasks) => tasks.isEmpty,
          loading: () => false,
          error: (_, __) => false,
        ), isTrue);
        verifyNever(mockRepository.searchTasks(any));
      });
    });

    group('Task Statistics Provider Tests', () {
      test('should calculate task statistics correctly', () async {
        // Arrange
        final allTasks = [
          TaskModel.create(title: 'Pending 1', priority: TaskPriority.high),
          TaskModel.create(title: 'Pending 2', priority: TaskPriority.low),
          TaskModel.create(title: 'Completed 1', priority: TaskPriority.medium).complete(),
          TaskModel.create(title: 'Completed 2', priority: TaskPriority.urgent).complete(),
        ];
        
        when(mockRepository.getAllTasks())
            .thenAnswer((_) async => Right(allTasks));
        when(mockRepository.getCompletedTasks())
            .thenAnswer((_) async => Right(allTasks.where((t) => t.isCompleted).toList()));
        when(mockRepository.getPendingTasks())
            .thenAnswer((_) async => Right(allTasks.where((t) => !t.isCompleted).toList()));

        // Act
        final stats = await container.read(taskStatisticsProvider.future);

        // Assert
        expect(stats.totalTasks, equals(4));
        expect(stats.completedTasks, equals(2));
        expect(stats.pendingTasks, equals(2));
        expect(stats.completionRate, equals(0.5)); // 2/4 = 0.5
      });

      test('should handle empty task list for statistics', () async {
        // Arrange
        when(mockRepository.getAllTasks())
            .thenAnswer((_) async => const Right([]));
        when(mockRepository.getCompletedTasks())
            .thenAnswer((_) async => const Right([]));
        when(mockRepository.getPendingTasks())
            .thenAnswer((_) async => const Right([]));

        // Act
        final stats = await container.read(taskStatisticsProvider.future);

        // Assert
        expect(stats.totalTasks, equals(0));
        expect(stats.completedTasks, equals(0));
        expect(stats.pendingTasks, equals(0));
        expect(stats.completionRate, equals(0.0));
      });
    });

    group('Provider State Management Edge Cases', () {
      test('should handle provider disposal correctly', () {
        // Act
        container.dispose();

        // Assert - Should not throw any exceptions
        expect(() => container.dispose(), returnsNormally);
      });

      test('should handle concurrent provider reads', () async {
        // Arrange
        when(mockRepository.getAllTasks())
            .thenAnswer((_) async => Right([TaskModel.create(title: 'Task')]));

        // Act - Multiple concurrent reads
        final futures = List.generate(10, (_) => 
            container.read(allTasksProvider.future));
        final results = await Future.wait(futures);

        // Assert
        expect(results.every((tasks) => tasks.length == 1), isTrue);
        // Repository should only be called once due to provider caching
        verify(mockRepository.getAllTasks()).called(1);
      });

      test('should handle provider refresh correctly', () async {
        // Arrange
        when(mockRepository.getAllTasks())
            .thenAnswer((_) async => Right([TaskModel.create(title: 'Task')]));

        // Act
        await container.read(allTasksProvider.future); // Initial load
        container.refresh(allTasksProvider); // Force refresh
        await container.read(allTasksProvider.future); // Second load

        // Assert
        // Should call repository twice due to refresh
        verify(mockRepository.getAllTasks()).called(2);
      });

      test('should handle provider auto-dispose correctly', () async {
        // Arrange
        when(mockRepository.getAllTasks())
            .thenAnswer((_) async => Right([TaskModel.create(title: 'Task')]));

        // Act
        final listener = container.listen<AsyncValue<List<TaskModel>>>(
          allTasksProvider,
          (previous, next) {},
        );
        
        await container.read(allTasksProvider.future);
        listener.close(); // Remove listener
        
        // Provider should auto-dispose after some time
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert - Should not throw
        expect(() => container.read(allTasksProvider), returnsNormally);
      });

      test('should handle provider error states correctly', () async {
        // Arrange
        when(mockRepository.getAllTasks())
            .thenAnswer((_) async => Left(NetworkFailure('Connection failed')));

        // Act
        final asyncValue = container.read(allTasksProvider);

        // Assert
        expect(asyncValue.when(
          data: (_) => false,
          loading: () => false,
          error: (_, __) => true,
        ), isTrue);
      });
    });

    group('Provider Memory Management Tests', () {
      test('should not leak memory with frequent provider updates', () async {
        // Arrange
        final tasks = List.generate(
          1000,
          (i) => TaskModel.create(title: 'Task $i'),
        );
        when(mockRepository.getAllTasks())
            .thenAnswer((_) async => Right(tasks));

        // Act - Simulate frequent updates
        for (int i = 0; i < 100; i++) {
          container.refresh(allTasksProvider);
          await container.read(allTasksProvider.future);
        }

        // Assert - Should complete without memory issues
        final finalTasks = await container.read(allTasksProvider.future);
        expect(finalTasks.length, equals(1000));
      });

      test('should handle large provider state efficiently', () async {
        // Arrange
        final largeTasks = List.generate(
          10000,
          (i) => TaskModel.create(
            title: 'Large Task $i',
            description: 'This is a task with a long description ' * 10,
            tags: ['tag1', 'tag2', 'tag3', 'tag4', 'tag5'],
          ),
        );
        when(mockRepository.getAllTasks())
            .thenAnswer((_) async => Right(largeTasks));

        // Act
        final startTime = DateTime.now();
        final result = await container.read(allTasksProvider.future);
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);

        // Assert - Should handle large state efficiently (under 1 second)
        expect(result.length, equals(10000));
        expect(duration.inMilliseconds, lessThan(1000));
      });
    });
  });
}