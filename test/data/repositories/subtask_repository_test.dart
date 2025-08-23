import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:task_tracker_app/services/database/database.dart';
import 'package:task_tracker_app/services/database/daos/subtask_dao.dart';
import 'package:task_tracker_app/data/repositories/subtask_repository_impl.dart';
import 'package:task_tracker_app/domain/entities/subtask.dart';

import 'subtask_repository_test.mocks.dart';

@GenerateMocks([AppDatabase, SubtaskDao])
void main() {
  group('SubtaskRepositoryImpl', () {
    late SubtaskRepositoryImpl repository;
    late MockAppDatabase mockDatabase;
    late MockSubtaskDao mockSubtaskDao;

    setUp(() {
      mockDatabase = MockAppDatabase();
      mockSubtaskDao = MockSubtaskDao();
      when(mockDatabase.subtaskDao).thenReturn(mockSubtaskDao);
      repository = SubtaskRepositoryImpl(mockDatabase);
    });

    group('Basic CRUD Operations', () {
      test('should create subtask', () async {
        // Arrange
        final subtask = SubTask.create(
          title: 'Test Subtask',
          taskId: 'parent-task-id',
        );
        when(mockSubtaskDao.createSubtask(subtask)).thenAnswer((_) async => {});

        // Act
        await repository.createSubtask(subtask);

        // Assert
        verify(mockSubtaskDao.createSubtask(subtask)).called(1);
      });

      test('should get subtask by id', () async {
        // Arrange
        const subtaskId = 'test-subtask-id';
        final expectedSubtask = SubTask.create(
          title: 'Test Subtask',
          taskId: 'parent-task-id',
        );
        when(mockSubtaskDao.getSubtaskById(subtaskId)).thenAnswer((_) async => expectedSubtask);

        // Act
        final result = await repository.getSubtaskById(subtaskId);

        // Assert
        expect(result, equals(expectedSubtask));
        verify(mockSubtaskDao.getSubtaskById(subtaskId)).called(1);
      });

      test('should return null for non-existent subtask', () async {
        // Arrange
        const nonExistentId = 'non-existent-id';
        when(mockSubtaskDao.getSubtaskById(nonExistentId)).thenAnswer((_) async => null);

        // Act
        final result = await repository.getSubtaskById(nonExistentId);

        // Assert
        expect(result, isNull);
        verify(mockSubtaskDao.getSubtaskById(nonExistentId)).called(1);
      });

      test('should update subtask', () async {
        // Arrange
        final subtask = SubTask.create(
          title: 'Updated Subtask',
          taskId: 'parent-task-id',
        );
        when(mockSubtaskDao.updateSubtask(subtask)).thenAnswer((_) async => {});

        // Act
        await repository.updateSubtask(subtask);

        // Assert
        verify(mockSubtaskDao.updateSubtask(subtask)).called(1);
      });

      test('should delete subtask', () async {
        // Arrange
        const subtaskId = 'subtask-to-delete';
        when(mockSubtaskDao.deleteSubtask(subtaskId)).thenAnswer((_) async => {});

        // Act
        await repository.deleteSubtask(subtaskId);

        // Assert
        verify(mockSubtaskDao.deleteSubtask(subtaskId)).called(1);
      });
    });

    group('Task-Related Operations', () {
      test('should get subtasks for task', () async {
        // Arrange
        const taskId = 'parent-task-id';
        final expectedSubtasks = [
          SubTask.create(title: 'Subtask 1', taskId: taskId),
          SubTask.create(title: 'Subtask 2', taskId: taskId),
        ];
        when(mockSubtaskDao.getSubtasksForTask(taskId)).thenAnswer((_) async => expectedSubtasks);

        // Act
        final result = await repository.getSubtasksForTask(taskId);

        // Assert
        expect(result, equals(expectedSubtasks));
        verify(mockSubtaskDao.getSubtasksForTask(taskId)).called(1);
      });

      test('should get subtasks sorted by order', () async {
        // Arrange
        const taskId = 'parent-task-id';
        final expectedSubtasks = [
          SubTask.create(title: 'First Subtask', taskId: taskId),
          SubTask.create(title: 'Second Subtask', taskId: taskId),
          SubTask.create(title: 'Third Subtask', taskId: taskId),
        ];
        when(mockSubtaskDao.getSubtasksSorted(taskId)).thenAnswer((_) async => expectedSubtasks);

        // Act
        final result = await repository.getSubtasksSorted(taskId);

        // Assert
        expect(result, equals(expectedSubtasks));
        expect(result.length, equals(3));
        verify(mockSubtaskDao.getSubtasksSorted(taskId)).called(1);
      });

      test('should watch subtasks for task', () async {
        // Arrange
        const taskId = 'watch-task-id';
        final expectedSubtasks = [
          SubTask.create(title: 'Watched Subtask', taskId: taskId),
        ];
        when(mockSubtaskDao.watchSubtasksForTask(taskId)).thenAnswer((_) => Stream.value(expectedSubtasks));

        // Act
        final stream = repository.watchSubtasksForTask(taskId);

        // Assert
        expect(await stream.first, equals(expectedSubtasks));
        verify(mockSubtaskDao.watchSubtasksForTask(taskId)).called(1);
      });
    });

    group('Completion and Statistics', () {
      test('should toggle subtask completion', () async {
        // Arrange
        const subtaskId = 'toggle-subtask-id';
        when(mockSubtaskDao.toggleSubtaskCompletion(subtaskId)).thenAnswer((_) async => {});

        // Act
        await repository.toggleSubtaskCompletion(subtaskId);

        // Assert
        verify(mockSubtaskDao.toggleSubtaskCompletion(subtaskId)).called(1);
      });

      test('should get subtask completion percentage', () async {
        // Arrange
        const taskId = 'stats-task-id';
        const expectedPercentage = 75.0;
        when(mockSubtaskDao.getSubtaskCompletionPercentage(taskId)).thenAnswer((_) async => expectedPercentage);

        // Act
        final result = await repository.getSubtaskCompletionPercentage(taskId);

        // Assert
        expect(result, equals(expectedPercentage));
        verify(mockSubtaskDao.getSubtaskCompletionPercentage(taskId)).called(1);
      });

      test('should get completed subtask count', () async {
        // Arrange
        const taskId = 'count-task-id';
        const expectedCount = 5;
        when(mockSubtaskDao.getCompletedSubtaskCount(taskId)).thenAnswer((_) async => expectedCount);

        // Act
        final result = await repository.getCompletedSubtaskCount(taskId);

        // Assert
        expect(result, equals(expectedCount));
        verify(mockSubtaskDao.getCompletedSubtaskCount(taskId)).called(1);
      });

      test('should get total subtask count', () async {
        // Arrange
        const taskId = 'total-count-task-id';
        const expectedCount = 8;
        when(mockSubtaskDao.getTotalSubtaskCount(taskId)).thenAnswer((_) async => expectedCount);

        // Act
        final result = await repository.getTotalSubtaskCount(taskId);

        // Assert
        expect(result, equals(expectedCount));
        verify(mockSubtaskDao.getTotalSubtaskCount(taskId)).called(1);
      });
    });

    group('Ordering Operations', () {
      test('should reorder subtasks', () async {
        // Arrange
        const taskId = 'reorder-task-id';
        final newOrder = ['subtask-3', 'subtask-1', 'subtask-2'];
        when(mockSubtaskDao.reorderSubtasks(taskId, newOrder)).thenAnswer((_) async => {});

        // Act
        await repository.reorderSubtasks(taskId, newOrder);

        // Assert
        verify(mockSubtaskDao.reorderSubtasks(taskId, newOrder)).called(1);
      });

      test('should move subtask up', () async {
        // Arrange
        const subtaskId = 'move-up-subtask';
        when(mockSubtaskDao.moveSubtaskUp(subtaskId)).thenAnswer((_) async => {});

        // Act
        await repository.moveSubtaskUp(subtaskId);

        // Assert
        verify(mockSubtaskDao.moveSubtaskUp(subtaskId)).called(1);
      });

      test('should move subtask down', () async {
        // Arrange
        const subtaskId = 'move-down-subtask';
        when(mockSubtaskDao.moveSubtaskDown(subtaskId)).thenAnswer((_) async => {});

        // Act
        await repository.moveSubtaskDown(subtaskId);

        // Assert
        verify(mockSubtaskDao.moveSubtaskDown(subtaskId)).called(1);
      });
    });

    group('Bulk Operations', () {
      test('should bulk delete subtasks for task', () async {
        // Arrange
        const taskId = 'bulk-delete-task';
        when(mockSubtaskDao.deleteSubtasksForTask(taskId)).thenAnswer((_) async => {});

        // Act
        await repository.deleteSubtasksForTask(taskId);

        // Assert
        verify(mockSubtaskDao.deleteSubtasksForTask(taskId)).called(1);
      });

      test('should bulk complete subtasks', () async {
        // Arrange
        final subtaskIds = ['sub1', 'sub2', 'sub3'];
        when(mockSubtaskDao.bulkCompleteSubtasks(subtaskIds)).thenAnswer((_) async => {});

        // Act
        await repository.bulkCompleteSubtasks(subtaskIds);

        // Assert
        verify(mockSubtaskDao.bulkCompleteSubtasks(subtaskIds)).called(1);
      });

      test('should bulk uncomplete subtasks', () async {
        // Arrange
        final subtaskIds = ['sub1', 'sub2', 'sub3'];
        when(mockSubtaskDao.bulkUncompleteSubtasks(subtaskIds)).thenAnswer((_) async => {});

        // Act
        await repository.bulkUncompleteSubtasks(subtaskIds);

        // Assert
        verify(mockSubtaskDao.bulkUncompleteSubtasks(subtaskIds)).called(1);
      });
    });

    group('Error Handling', () {
      test('should handle database exceptions during createSubtask', () async {
        // Arrange
        final subtask = SubTask.create(title: 'Error Subtask', taskId: 'task-id');
        when(mockSubtaskDao.createSubtask(subtask)).thenThrow(Exception('Create error'));

        // Act & Assert
        expect(
          () async => await repository.createSubtask(subtask),
          throwsException,
        );
      });

      test('should handle database exceptions during getSubtasksForTask', () async {
        // Arrange
        const taskId = 'error-task-id';
        when(mockSubtaskDao.getSubtasksForTask(taskId)).thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () async => await repository.getSubtasksForTask(taskId),
          throwsException,
        );
      });

      test('should handle database exceptions during toggleSubtaskCompletion', () async {
        // Arrange
        const subtaskId = 'error-subtask-id';
        when(mockSubtaskDao.toggleSubtaskCompletion(subtaskId)).thenThrow(Exception('Toggle error'));

        // Act & Assert
        expect(
          () async => await repository.toggleSubtaskCompletion(subtaskId),
          throwsException,
        );
      });
    });

    group('Edge Cases', () {
      test('should handle empty subtask list for task', () async {
        // Arrange
        const taskId = 'empty-task-id';
        when(mockSubtaskDao.getSubtasksForTask(taskId)).thenAnswer((_) async => []);

        // Act
        final result = await repository.getSubtasksForTask(taskId);

        // Assert
        expect(result, isEmpty);
        verify(mockSubtaskDao.getSubtasksForTask(taskId)).called(1);
      });

      test('should handle zero completion percentage', () async {
        // Arrange
        const taskId = 'zero-completion-task';
        when(mockSubtaskDao.getSubtaskCompletionPercentage(taskId)).thenAnswer((_) async => 0.0);

        // Act
        final result = await repository.getSubtaskCompletionPercentage(taskId);

        // Assert
        expect(result, equals(0.0));
        verify(mockSubtaskDao.getSubtaskCompletionPercentage(taskId)).called(1);
      });

      test('should handle 100% completion percentage', () async {
        // Arrange
        const taskId = 'full-completion-task';
        when(mockSubtaskDao.getSubtaskCompletionPercentage(taskId)).thenAnswer((_) async => 100.0);

        // Act
        final result = await repository.getSubtaskCompletionPercentage(taskId);

        // Assert
        expect(result, equals(100.0));
        verify(mockSubtaskDao.getSubtaskCompletionPercentage(taskId)).called(1);
      });

      test('should handle empty reorder list', () async {
        // Arrange
        const taskId = 'empty-reorder-task';
        final emptyOrder = <String>[];
        when(mockSubtaskDao.reorderSubtasks(taskId, emptyOrder)).thenAnswer((_) async => {});

        // Act
        await repository.reorderSubtasks(taskId, emptyOrder);

        // Assert
        verify(mockSubtaskDao.reorderSubtasks(taskId, emptyOrder)).called(1);
      });
    });
  });

  group('SubtaskRepositoryImpl Integration Tests', () {
    late SubtaskRepositoryImpl repository;
    late AppDatabase database;

    setUp(() async {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      repository = SubtaskRepositoryImpl(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('should perform end-to-end subtask operations', () async {
      const taskId = 'integration-test-task';

      // Create subtasks
      final subtask1 = SubTask.create(
        title: 'First Subtask',
        taskId: taskId,
        description: 'First subtask description',
      );
      final subtask2 = SubTask.create(
        title: 'Second Subtask',
        taskId: taskId,
      );
      final subtask3 = SubTask.create(
        title: 'Third Subtask',
        taskId: taskId,
      );

      await repository.createSubtask(subtask1);
      await repository.createSubtask(subtask2);
      await repository.createSubtask(subtask3);

      // Get all subtasks for task
      final allSubtasks = await repository.getSubtasksForTask(taskId);
      expect(allSubtasks.length, equals(3));

      // Get by ID
      final retrievedSubtask = await repository.getSubtaskById(subtask1.id);
      expect(retrievedSubtask, isNotNull);
      expect(retrievedSubtask!.title, equals('First Subtask'));

      // Toggle completion
      await repository.toggleSubtaskCompletion(subtask1.id);
      await repository.toggleSubtaskCompletion(subtask2.id);

      // Check completion statistics
      final completedCount = await repository.getCompletedSubtaskCount(taskId);
      expect(completedCount, equals(2));

      final totalCount = await repository.getTotalSubtaskCount(taskId);
      expect(totalCount, equals(3));

      final completionPercentage = await repository.getSubtaskCompletionPercentage(taskId);
      expect(completionPercentage, closeTo(66.67, 0.1));

      // Update subtask
      final updatedSubtask = subtask3.copyWith(description: 'Updated description');
      await repository.updateSubtask(updatedSubtask);
      final retrieved = await repository.getSubtaskById(subtask3.id);
      expect(retrieved!.description, equals('Updated description'));

      // Test reordering
      final newOrder = [subtask3.id, subtask1.id, subtask2.id];
      await repository.reorderSubtasks(taskId, newOrder);
      final reorderedSubtasks = await repository.getSubtasksSorted(taskId);
      expect(reorderedSubtasks.first.id, equals(subtask3.id));

      // Delete subtask
      await repository.deleteSubtask(subtask2.id);
      final remainingSubtasks = await repository.getSubtasksForTask(taskId);
      expect(remainingSubtasks.length, equals(2));

      // Clean up - delete all subtasks for task
      await repository.deleteSubtasksForTask(taskId);
      final finalSubtasks = await repository.getSubtasksForTask(taskId);
      expect(finalSubtasks, isEmpty);
    });

    test('should handle streaming operations', () async {
      const taskId = 'stream-test-task';

      // Create initial subtask
      final subtask = SubTask.create(title: 'Stream Test Subtask', taskId: taskId);
      await repository.createSubtask(subtask);

      // Watch subtasks for task
      final stream = repository.watchSubtasksForTask(taskId);
      final initialSubtasks = await stream.first;
      expect(initialSubtasks.length, equals(1));
      expect(initialSubtasks.first.title, equals('Stream Test Subtask'));

      // The stream should continue to emit as subtasks change
      // This would require more complex setup for real streaming tests
    });
  });
}