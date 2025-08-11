import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:task_tracker_app/data/repositories/task_repository_impl.dart';
import 'package:task_tracker_app/data/repositories/cached_task_repository_impl.dart';
import 'package:task_tracker_app/services/database/daos/task_dao.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/models/enums.dart';
import 'package:task_tracker_app/core/errors/failures.dart';

@GenerateMocks([TaskDao])
import 'task_repository_comprehensive_test.mocks.dart';

/// COMPREHENSIVE TASK REPOSITORY TESTS - ALL DATA LAYER LOGIC
void main() {
  group('TaskRepository - Comprehensive Data Layer Tests', () {
    late MockTaskDao mockTaskDao;
    late TaskRepositoryImpl repository;
    late CachedTaskRepositoryImpl cachedRepository;

    setUp(() {
      mockTaskDao = MockTaskDao();
      repository = TaskRepositoryImpl(taskDao: mockTaskDao);
      cachedRepository = CachedTaskRepositoryImpl(
        baseRepository: repository,
        cacheExpirationMinutes: 5,
      );
    });

    group('Task Creation Tests', () {
      test('should create task successfully', () async {
        // Arrange
        final task = TaskModel.create(title: 'Test Task');
        when(mockTaskDao.insertTask(any)).thenAnswer((_) async => task.id);
        when(mockTaskDao.getTaskById(task.id)).thenAnswer((_) async => task);

        // Act
        final result = await repository.createTask(task);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should not return failure'),
          (createdTask) => expect(createdTask.title, equals('Test Task')),
        );
        verify(mockTaskDao.insertTask(task)).called(1);
      });

      test('should handle database creation failure', () async {
        // Arrange
        final task = TaskModel.create(title: 'Test Task');
        when(mockTaskDao.insertTask(any))
            .thenThrow(Exception('Database connection failed'));

        // Act
        final result = await repository.createTask(task);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<DatabaseFailure>()),
          (task) => fail('Should not return success'),
        );
      });

      test('should validate task before creation', () async {
        // Arrange
        final invalidTask = TaskModel.create(title: ''); // Invalid empty title

        // Act & Assert
        expect(
          () => repository.createTask(invalidTask),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Task Retrieval Tests', () {
      test('should get task by ID successfully', () async {
        // Arrange
        final task = TaskModel.create(title: 'Retrieved Task');
        when(mockTaskDao.getTaskById(task.id)).thenAnswer((_) async => task);

        // Act
        final result = await repository.getTaskById(task.id);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should not return failure'),
          (retrievedTask) => expect(retrievedTask.title, equals('Retrieved Task')),
        );
      });

      test('should handle task not found', () async {
        // Arrange
        const taskId = 'non-existent-id';
        when(mockTaskDao.getTaskById(taskId)).thenAnswer((_) async => null);

        // Act
        final result = await repository.getTaskById(taskId);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<NotFoundFailure>()),
          (task) => fail('Should not return task'),
        );
      });

      test('should get all tasks successfully', () async {
        // Arrange
        final tasks = [
          TaskModel.create(title: 'Task 1'),
          TaskModel.create(title: 'Task 2'),
          TaskModel.create(title: 'Task 3'),
        ];
        when(mockTaskDao.getAllTasks()).thenAnswer((_) async => tasks);

        // Act
        final result = await repository.getAllTasks();

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should not return failure'),
          (retrievedTasks) => expect(retrievedTasks.length, equals(3)),
        );
      });

      test('should get pending tasks correctly', () async {
        // Arrange
        final pendingTasks = [
          TaskModel.create(title: 'Pending 1', status: TaskStatus.pending),
          TaskModel.create(title: 'Pending 2', status: TaskStatus.inProgress),
        ];
        when(mockTaskDao.getTasksByStatus(TaskStatus.pending))
            .thenAnswer((_) async => [pendingTasks[0]]);
        when(mockTaskDao.getTasksByStatus(TaskStatus.inProgress))
            .thenAnswer((_) async => [pendingTasks[1]]);

        // Act
        final result = await repository.getPendingTasks();

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should not return failure'),
          (tasks) {
            expect(tasks.length, greaterThan(0));
            expect(tasks.every((task) => !task.isCompleted), isTrue);
          },
        );
      });

      test('should get completed tasks correctly', () async {
        // Arrange
        final completedTasks = [
          TaskModel.create(title: 'Completed 1').complete(),
          TaskModel.create(title: 'Completed 2').complete(),
        ];
        when(mockTaskDao.getTasksByStatus(TaskStatus.completed))
            .thenAnswer((_) async => completedTasks);

        // Act
        final result = await repository.getCompletedTasks();

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should not return failure'),
          (tasks) {
            expect(tasks.length, equals(2));
            expect(tasks.every((task) => task.isCompleted), isTrue);
          },
        );
      });
    });

    group('Task Update Tests', () {
      test('should update task successfully', () async {
        // Arrange
        final originalTask = TaskModel.create(title: 'Original Title');
        final updatedTask = originalTask.copyWith(title: 'Updated Title');
        when(mockTaskDao.updateTask(any)).thenAnswer((_) async => {});
        when(mockTaskDao.getTaskById(originalTask.id))
            .thenAnswer((_) async => updatedTask);

        // Act
        final result = await repository.updateTask(updatedTask);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should not return failure'),
          (task) => expect(task.title, equals('Updated Title')),
        );
        verify(mockTaskDao.updateTask(updatedTask)).called(1);
      });

      test('should handle update of non-existent task', () async {
        // Arrange
        final task = TaskModel.create(title: 'Non-existent Task');
        when(mockTaskDao.updateTask(any))
            .thenThrow(Exception('Task not found'));

        // Act
        final result = await repository.updateTask(task);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<DatabaseFailure>()),
          (task) => fail('Should not return success'),
        );
      });

      test('should update task priority correctly', () async {
        // Arrange
        final task = TaskModel.create(title: 'Task', priority: TaskPriority.low);
        final highPriorityTask = task.copyWith(priority: TaskPriority.urgent);
        
        when(mockTaskDao.updateTask(any)).thenAnswer((_) async => {});
        when(mockTaskDao.getTaskById(task.id))
            .thenAnswer((_) async => highPriorityTask);

        // Act
        final result = await repository.updateTask(highPriorityTask);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should not return failure'),
          (updatedTask) => expect(updatedTask.priority, equals(TaskPriority.urgent)),
        );
      });
    });

    group('Task Deletion Tests', () {
      test('should delete task successfully', () async {
        // Arrange
        final task = TaskModel.create(title: 'To Delete');
        when(mockTaskDao.deleteTask(task.id)).thenAnswer((_) async => {});

        // Act
        final result = await repository.deleteTask(task.id);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should not return failure'),
          (success) => expect(success, isTrue),
        );
        verify(mockTaskDao.deleteTask(task.id)).called(1);
      });

      test('should handle deletion of non-existent task', () async {
        // Arrange
        const taskId = 'non-existent-id';
        when(mockTaskDao.deleteTask(taskId))
            .thenThrow(Exception('Task not found'));

        // Act
        final result = await repository.deleteTask(taskId);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<DatabaseFailure>()),
          (success) => fail('Should not return success'),
        );
      });

      test('should delete multiple tasks in batch', () async {
        // Arrange
        final taskIds = ['id1', 'id2', 'id3'];
        when(mockTaskDao.deleteTasks(taskIds)).thenAnswer((_) async => {});

        // Act
        final result = await repository.deleteTasks(taskIds);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should not return failure'),
          (count) => expect(count, equals(3)),
        );
        verify(mockTaskDao.deleteTasks(taskIds)).called(1);
      });
    });

    group('Task Query and Filtering Tests', () {
      test('should get tasks by priority correctly', () async {
        // Arrange
        final highPriorityTasks = [
          TaskModel.create(title: 'High 1', priority: TaskPriority.high),
          TaskModel.create(title: 'High 2', priority: TaskPriority.high),
        ];
        when(mockTaskDao.getTasksByPriority(TaskPriority.high))
            .thenAnswer((_) async => highPriorityTasks);

        // Act
        final result = await repository.getTasksByPriority(TaskPriority.high);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should not return failure'),
          (tasks) {
            expect(tasks.length, equals(2));
            expect(tasks.every((task) => task.priority == TaskPriority.high), isTrue);
          },
        );
      });

      test('should get tasks by date range correctly', () async {
        // Arrange
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 1, 31);
        final tasksInRange = [
          TaskModel.create(title: 'Task 1', dueDate: DateTime(2024, 1, 15)),
          TaskModel.create(title: 'Task 2', dueDate: DateTime(2024, 1, 25)),
        ];
        
        when(mockTaskDao.getTasksByDateRange(startDate, endDate))
            .thenAnswer((_) async => tasksInRange);

        // Act
        final result = await repository.getTasksByDateRange(startDate, endDate);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should not return failure'),
          (tasks) => expect(tasks.length, equals(2)),
        );
      });

      test('should get overdue tasks correctly', () async {
        // Arrange
        final now = DateTime.now();
        final overdueTasks = [
          TaskModel.create(
            title: 'Overdue 1',
            dueDate: now.subtract(const Duration(days: 1)),
          ),
          TaskModel.create(
            title: 'Overdue 2',
            dueDate: now.subtract(const Duration(days: 5)),
          ),
        ];
        
        when(mockTaskDao.getOverdueTasks()).thenAnswer((_) async => overdueTasks);

        // Act
        final result = await repository.getOverdueTasks();

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should not return failure'),
          (tasks) {
            expect(tasks.length, equals(2));
            expect(tasks.every((task) => task.isOverdue), isTrue);
          },
        );
      });

      test('should search tasks by title and description', () async {
        // Arrange
        const searchQuery = 'important project';
        final matchingTasks = [
          TaskModel.create(title: 'Important Project Meeting'),
          TaskModel.create(
            title: 'Task',
            description: 'This is about the important project',
          ),
        ];
        
        when(mockTaskDao.searchTasks(searchQuery))
            .thenAnswer((_) async => matchingTasks);

        // Act
        final result = await repository.searchTasks(searchQuery);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should not return failure'),
          (tasks) => expect(tasks.length, equals(2)),
        );
      });
    });

    group('Caching Layer Tests', () {
      test('should cache frequently accessed tasks', () async {
        // Arrange
        final task = TaskModel.create(title: 'Cached Task');
        when(mockTaskDao.getTaskById(task.id)).thenAnswer((_) async => task);

        // Act - First call
        await cachedRepository.getTaskById(task.id);
        
        // Act - Second call (should use cache)
        final result = await cachedRepository.getTaskById(task.id);

        // Assert
        expect(result.isRight(), isTrue);
        // Should only call DAO once due to caching
        verify(mockTaskDao.getTaskById(task.id)).called(1);
      });

      test('should invalidate cache when task is updated', () async {
        // Arrange
        final originalTask = TaskModel.create(title: 'Original');
        final updatedTask = originalTask.copyWith(title: 'Updated');
        
        when(mockTaskDao.getTaskById(originalTask.id))
            .thenReturn(Future.value(originalTask))
            .thenReturn(Future.value(updatedTask));
        when(mockTaskDao.updateTask(any)).thenAnswer((_) async => {});

        // Act
        await cachedRepository.getTaskById(originalTask.id); // Cache original
        await cachedRepository.updateTask(updatedTask); // Should invalidate cache
        final result = await cachedRepository.getTaskById(originalTask.id); // Should fetch fresh

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should not return failure'),
          (task) => expect(task.title, equals('Updated')),
        );
      });

      test('should handle cache expiration correctly', () async {
        // Arrange
        final task = TaskModel.create(title: 'Expiring Task');
        when(mockTaskDao.getTaskById(task.id)).thenAnswer((_) async => task);
        
        // Create repository with very short cache expiration for testing
        final shortCachedRepo = CachedTaskRepositoryImpl(
          baseRepository: repository,
          cacheExpirationMinutes: 0, // Immediate expiration
        );

        // Act
        await shortCachedRepo.getTaskById(task.id); // Cache
        await Future.delayed(const Duration(milliseconds: 100)); // Wait for expiration
        await shortCachedRepo.getTaskById(task.id); // Should fetch fresh

        // Assert
        // Should call DAO twice due to cache expiration
        verify(mockTaskDao.getTaskById(task.id)).called(2);
      });
    });

    group('Error Handling and Edge Cases', () {
      test('should handle database connection timeout', () async {
        // Arrange
        when(mockTaskDao.getAllTasks())
            .thenThrow(TimeoutException('Database timeout', const Duration(seconds: 30)));

        // Act
        final result = await repository.getAllTasks();

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<TimeoutFailure>()),
          (tasks) => fail('Should not return success'),
        );
      });

      test('should handle concurrent task modifications', () async {
        // Arrange
        final task = TaskModel.create(title: 'Concurrent Task');
        final update1 = task.copyWith(title: 'Update 1');
        final update2 = task.copyWith(title: 'Update 2');
        
        when(mockTaskDao.updateTask(any)).thenAnswer((_) async => {});
        when(mockTaskDao.getTaskById(task.id))
            .thenAnswer((_) async => update2); // Last update wins

        // Act - Simulate concurrent updates
        final results = await Future.wait([
          repository.updateTask(update1),
          repository.updateTask(update2),
        ]);

        // Assert
        expect(results.every((result) => result.isRight()), isTrue);
        verify(mockTaskDao.updateTask(any)).called(2);
      });

      test('should handle memory pressure during large queries', () async {
        // Arrange - Create many tasks to simulate memory pressure
        final largeTasks = List.generate(
          10000,
          (index) => TaskModel.create(title: 'Task $index'),
        );
        when(mockTaskDao.getAllTasks()).thenAnswer((_) async => largeTasks);

        // Act
        final result = await repository.getAllTasks();

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should not return failure'),
          (tasks) => expect(tasks.length, equals(10000)),
        );
      });

      test('should handle malformed data from database', () async {
        // Arrange
        when(mockTaskDao.getTaskById(any))
            .thenThrow(FormatException('Invalid task data format'));

        // Act
        final result = await repository.getTaskById('malformed-id');

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ParseFailure>()),
          (task) => fail('Should not return success'),
        );
      });
    });
  });
}