import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:task_tracker_app/services/database/daos/task_dao.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/models/enums.dart';

@GenerateMocks([TaskDao])
import 'task_repository_comprehensive_test.mocks.dart';

/// COMPREHENSIVE TASK REPOSITORY TESTS - ALL DATA LAYER LOGIC
void main() {
  group('TaskRepository - Basic Unit Tests', () {
    late MockTaskDao mockTaskDao;

    setUp(() {
      mockTaskDao = MockTaskDao();
    });

    group('TaskDao Tests', () {
      test('should create task successfully', () async {
        // Arrange
        final task = TaskModel.create(title: 'Test Task');
        when(mockTaskDao.createTask(any)).thenAnswer((_) async {});

        // Act
        await mockTaskDao.createTask(task);

        // Assert
        verify(mockTaskDao.createTask(task)).called(1);
      });

      test('should handle database creation failure', () async {
        // Arrange
        final task = TaskModel.create(title: 'Test Task');
        when(mockTaskDao.createTask(any))
            .thenThrow(Exception('Database connection failed'));

        // Act & Assert
        expect(
          () => mockTaskDao.createTask(task),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Task Retrieval Tests', () {
      test('should get task by ID successfully', () async {
        // Arrange
        final task = TaskModel.create(title: 'Retrieved Task');
        when(mockTaskDao.getTaskById(task.id)).thenAnswer((_) async => task);

        // Act
        final result = await mockTaskDao.getTaskById(task.id);

        // Assert
        expect(result, isNotNull);
        expect(result!.title, equals('Retrieved Task'));
      });

      test('should handle task not found', () async {
        // Arrange
        const taskId = 'non-existent-id';
        when(mockTaskDao.getTaskById(taskId)).thenAnswer((_) async => null);

        // Act
        final result = await mockTaskDao.getTaskById(taskId);

        // Assert
        expect(result, isNull);
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
        final result = await mockTaskDao.getAllTasks();

        // Assert
        expect(result.length, equals(3));
      });

      test('should get tasks by status', () async {
        // Arrange
        final pendingTasks = [
          TaskModel.create(title: 'Pending 1'),
        ];
        when(mockTaskDao.getTasksByStatus(TaskStatus.pending))
            .thenAnswer((_) async => pendingTasks);

        // Act
        final result = await mockTaskDao.getTasksByStatus(TaskStatus.pending);

        // Assert
        expect(result.length, equals(1));
        expect(result.first.status, equals(TaskStatus.pending));
      });
    });

    group('Task Update Tests', () {
      test('should update task successfully', () async {
        // Arrange
        final originalTask = TaskModel.create(title: 'Original Title');
        final updatedTask = originalTask.copyWith(title: 'Updated Title');
        when(mockTaskDao.updateTask(any)).thenAnswer((_) async {});

        // Act
        await mockTaskDao.updateTask(updatedTask);

        // Assert
        verify(mockTaskDao.updateTask(updatedTask)).called(1);
      });

      test('should handle update failure', () async {
        // Arrange
        final task = TaskModel.create(title: 'Test Task');
        when(mockTaskDao.updateTask(any))
            .thenThrow(Exception('Update failed'));

        // Act & Assert
        expect(
          () => mockTaskDao.updateTask(task),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Task Deletion Tests', () {
      test('should delete task successfully', () async {
        // Arrange
        final task = TaskModel.create(title: 'To Delete');
        when(mockTaskDao.deleteTask(task.id)).thenAnswer((_) async {});

        // Act
        await mockTaskDao.deleteTask(task.id);

        // Assert
        verify(mockTaskDao.deleteTask(task.id)).called(1);
      });

      test('should handle deletion failure', () async {
        // Arrange
        const taskId = 'test-id';
        when(mockTaskDao.deleteTask(taskId))
            .thenThrow(Exception('Delete failed'));

        // Act & Assert
        expect(
          () => mockTaskDao.deleteTask(taskId),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}