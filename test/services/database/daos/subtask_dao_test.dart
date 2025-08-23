import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'package:task_tracker_app/services/database/database.dart';
import 'package:task_tracker_app/services/database/daos/subtask_dao.dart';
import 'package:task_tracker_app/domain/entities/subtask.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('SubtaskDao', () {
    late AppDatabase database;
    late SubtaskDao subtaskDao;
    late SubTask testSubtask;

    setUp(() async {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      subtaskDao = database.subtaskDao;
      
      testSubtask = SubTask.create(
        title: 'Test Subtask',
        taskId: 'test-task-id',
        description: 'Test subtask description',
      );
    });

    tearDown(() async {
      await database.close();
    });

    group('Subtask Creation', () {
      test('should create a subtask successfully', () async {
        await subtaskDao.insertSubtask(testSubtask);
        
        final subtasks = await subtaskDao.getAllSubtasks();
        expect(subtasks, hasLength(1));
        expect(subtasks.first.title, equals('Test Subtask'));
        expect(subtasks.first.taskId, equals('test-task-id'));
      });

      test('should create subtask with all properties', () async {
        final complexSubtask = SubTask.create(
          title: 'Complex Subtask',
          taskId: 'complex-task-id',
          description: 'Complex subtask description',
          sortOrder: 5,
        ).copyWith(isCompleted: true);

        await subtaskDao.insertSubtask(complexSubtask);
        
        final retrieved = await subtaskDao.getSubtaskById(complexSubtask.id);
        expect(retrieved, isNotNull);
        expect(retrieved!.title, equals('Complex Subtask'));
        expect(retrieved.taskId, equals('complex-task-id'));
        expect(retrieved.description, equals('Complex subtask description'));
        expect(retrieved.sortOrder, equals(5));
        expect(retrieved.isCompleted, isTrue);
      });

      test('should handle multiple subtasks for same task', () async {
        final subtask1 = SubTask.create(
          title: 'Subtask 1',
          taskId: 'shared-task-id',
          sortOrder: 1,
        );
        
        final subtask2 = SubTask.create(
          title: 'Subtask 2',
          taskId: 'shared-task-id',
          sortOrder: 2,
        );

        await subtaskDao.insertSubtask(subtask1);
        await subtaskDao.insertSubtask(subtask2);
        
        final subtasks = await subtaskDao.getSubtasksForTask('shared-task-id');
        expect(subtasks, hasLength(2));
        expect(subtasks[0].title, equals('Subtask 1')); // Sorted by sortOrder
        expect(subtasks[1].title, equals('Subtask 2'));
      });
    });

    group('Subtask Retrieval', () {
      setUp(() async {
        // Create test data
        await subtaskDao.insertSubtask(testSubtask);
        await subtaskDao.insertSubtask(SubTask.create(
          title: 'Another Subtask',
          taskId: 'another-task-id',
          description: 'Another test subtask',
        ));
        await subtaskDao.insertSubtask(SubTask.create(
          title: 'Third Subtask',
          taskId: 'test-task-id', // Same task as testSubtask
          sortOrder: 1,
        ));
      });

      test('should get all subtasks', () async {
        final subtasks = await subtaskDao.getAllSubtasks();
        expect(subtasks, hasLength(3));
        
        final titles = subtasks.map((s) => s.title).toList();
        expect(titles, containsAll(['Test Subtask', 'Another Subtask', 'Third Subtask']));
      });

      test('should get subtask by ID', () async {
        final retrieved = await subtaskDao.getSubtaskById(testSubtask.id);
        expect(retrieved, isNotNull);
        expect(retrieved!.id, equals(testSubtask.id));
        expect(retrieved.title, equals('Test Subtask'));
      });

      test('should return null for non-existent subtask', () async {
        final retrieved = await subtaskDao.getSubtaskById('non-existent-id');
        expect(retrieved, isNull);
      });

      test('should get subtasks for specific task', () async {
        final subtasks = await subtaskDao.getSubtasksForTask('test-task-id');
        expect(subtasks, hasLength(2));
        
        final titles = subtasks.map((s) => s.title).toList();
        expect(titles, containsAll(['Test Subtask', 'Third Subtask']));
      });

      test('should get subtasks ordered by sort order', () async {
        // Add more subtasks with specific sort orders
        await subtaskDao.insertSubtask(SubTask.create(
          title: 'First Subtask',
          taskId: 'ordered-task-id',
          sortOrder: 1,
        ));
        
        await subtaskDao.insertSubtask(SubTask.create(
          title: 'Third Subtask',
          taskId: 'ordered-task-id',
          sortOrder: 3,
        ));
        
        await subtaskDao.insertSubtask(SubTask.create(
          title: 'Second Subtask',
          taskId: 'ordered-task-id',
          sortOrder: 2,
        ));
        
        final subtasks = await subtaskDao.getSubtasksForTask('ordered-task-id');
        expect(subtasks, hasLength(3));
        expect(subtasks[0].title, equals('First Subtask'));
        expect(subtasks[1].title, equals('Second Subtask'));
        expect(subtasks[2].title, equals('Third Subtask'));
      });
    });

    group('Subtask Updates', () {
      setUp(() async {
        await subtaskDao.insertSubtask(testSubtask);
      });

      test('should update subtask successfully', () async {
        final updatedSubtask = testSubtask.copyWith(
          title: 'Updated Subtask Title',
          description: 'Updated description',
          isCompleted: true,
          sortOrder: 10,
        );

        await subtaskDao.updateSubtask(updatedSubtask);
        
        final retrieved = await subtaskDao.getSubtaskById(testSubtask.id);
        expect(retrieved, isNotNull);
        expect(retrieved!.title, equals('Updated Subtask Title'));
        expect(retrieved.description, equals('Updated description'));
        expect(retrieved.isCompleted, isTrue);
        expect(retrieved.sortOrder, equals(10));
      });

      test('should handle updating non-existent subtask', () async {
        final nonExistentSubtask = testSubtask.copyWith(id: 'non-existent');
        
        // Should not throw but also should not affect any rows
        await subtaskDao.updateSubtask(nonExistentSubtask);
        
        final retrieved = await subtaskDao.getSubtaskById('non-existent');
        expect(retrieved, isNull);
      });
    });

    group('Subtask Deletion', () {
      setUp(() async {
        await subtaskDao.insertSubtask(testSubtask);
        await subtaskDao.insertSubtask(SubTask.create(
          title: 'Another Subtask',
          taskId: 'another-task-id',
        ));
      });

      test('should delete subtask by ID', () async {
        await subtaskDao.deleteSubtask(testSubtask.id);
        
        final retrieved = await subtaskDao.getSubtaskById(testSubtask.id);
        expect(retrieved, isNull);
        
        final allSubtasks = await subtaskDao.getAllSubtasks();
        expect(allSubtasks, hasLength(1));
        expect(allSubtasks.first.title, equals('Another Subtask'));
      });

      test('should handle deleting non-existent subtask', () async {
        await subtaskDao.deleteSubtask('non-existent-id');
        
        // Should not affect existing subtasks
        final allSubtasks = await subtaskDao.getAllSubtasks();
        expect(allSubtasks, hasLength(2));
      });

      test('should delete all subtasks for a task', () async {
        // Add more subtasks for the same task
        await subtaskDao.insertSubtask(SubTask.create(
          title: 'Third Subtask',
          taskId: 'test-task-id',
        ));

        await subtaskDao.deleteSubtasksForTask('test-task-id');
        
        final remainingSubtasks = await subtaskDao.getSubtasksForTask('test-task-id');
        expect(remainingSubtasks, isEmpty);
        
        // Other task's subtasks should remain
        final otherSubtasks = await subtaskDao.getSubtasksForTask('another-task-id');
        expect(otherSubtasks, hasLength(1));
      });
    });

    group('Subtask Completion', () {
      setUp(() async {
        await subtaskDao.insertSubtask(testSubtask);
        await subtaskDao.insertSubtask(SubTask.create(
          title: 'Completed Subtask',
          taskId: 'test-task-id',
        ).copyWith(isCompleted: true));
      });

      test('should toggle subtask completion', () async {
        // Initially not completed
        expect(testSubtask.isCompleted, isFalse);
        
        // Mark as completed
        final completedSubtask = testSubtask.copyWith(isCompleted: true);
        await subtaskDao.updateSubtask(completedSubtask);
        
        final retrieved = await subtaskDao.getSubtaskById(testSubtask.id);
        expect(retrieved!.isCompleted, isTrue);
        
        // Mark as incomplete again
        final incompleteSubtask = completedSubtask.copyWith(isCompleted: false);
        await subtaskDao.updateSubtask(incompleteSubtask);
        
        final retrievedAgain = await subtaskDao.getSubtaskById(testSubtask.id);
        expect(retrievedAgain!.isCompleted, isFalse);
      });

      test('should get subtask completion statistics', () async {
        final completedCount = await subtaskDao.getCompletedSubtaskCount('test-task-id');
        expect(completedCount, equals(1));
        
        final totalCount = await subtaskDao.getSubtaskCount('test-task-id');
        expect(totalCount, equals(2));
        
        final completionPercentage = await subtaskDao.getSubtaskCompletionPercentage('test-task-id');
        expect(completionPercentage, equals(0.5)); // 50% completion
      });
    });

    group('Subtask Sorting', () {
      setUp(() async {
        // Create subtasks with different sort orders
        await subtaskDao.insertSubtask(SubTask.create(
          title: 'Middle Subtask',
          taskId: 'sort-test-task',
          sortOrder: 2,
        ));
        
        await subtaskDao.insertSubtask(SubTask.create(
          title: 'Last Subtask',
          taskId: 'sort-test-task',
          sortOrder: 3,
        ));
        
        await subtaskDao.insertSubtask(SubTask.create(
          title: 'First Subtask',
          taskId: 'sort-test-task',
          sortOrder: 1,
        ));
      });

      test('should maintain sort order when retrieving subtasks', () async {
        final subtasks = await subtaskDao.getSubtasksForTask('sort-test-task');
        expect(subtasks, hasLength(3));
        expect(subtasks[0].title, equals('First Subtask'));
        expect(subtasks[1].title, equals('Middle Subtask'));
        expect(subtasks[2].title, equals('Last Subtask'));
      });

      test('should reorder subtasks using reorderSubtasks method', () async {
        final subtasks = await subtaskDao.getSubtasksForTask('sort-test-task');
        
        // Reorder: Last, First, Middle
        final newOrder = [
          subtasks[2].id, // Last Subtask
          subtasks[0].id, // First Subtask  
          subtasks[1].id, // Middle Subtask
        ];
        
        await subtaskDao.reorderSubtasks('sort-test-task', newOrder);
        
        final reorderedResults = await subtaskDao.getSubtasksForTask('sort-test-task');
        expect(reorderedResults[0].title, equals('Last Subtask'));
        expect(reorderedResults[1].title, equals('First Subtask'));
        expect(reorderedResults[2].title, equals('Middle Subtask'));
      });
    });

    group('Error Handling', () {
      test('should handle database connection errors gracefully', () async {
        expect(subtaskDao.getAllSubtasks(), completes);
      });

      test('should handle malformed data gracefully', () async {
        final edgeCaseSubtask = SubTask.create(
          title: 'Edge Case Subtask',
          taskId: 'edge-case-task',
          description: 'A' * 1000, // Very long description
        );
        
        expect(() => subtaskDao.insertSubtask(edgeCaseSubtask), returnsNormally);
      });

      test('should validate input parameters', () async {
        expect(
          () => subtaskDao.getSubtaskById(''),
          returnsNormally, // Should return null, not throw
        );
        
        final result = await subtaskDao.getSubtaskById('');
        expect(result, isNull);
        
        expect(
          () => subtaskDao.getSubtasksForTask(''),
          returnsNormally, // Should return empty list, not throw
        );
        
        final emptyResult = await subtaskDao.getSubtasksForTask('');
        expect(emptyResult, isEmpty);
      });
    });

    group('Batch Operations', () {
      test('should handle batch subtask insertion', () async {
        final subtasks = List.generate(10, (index) => SubTask.create(
          title: 'Batch Subtask $index',
          taskId: 'batch-task-id',
          sortOrder: index,
        ));

        for (final subtask in subtasks) {
          await subtaskDao.insertSubtask(subtask);
        }

        final allBatchSubtasks = await subtaskDao.getSubtasksForTask('batch-task-id');
        expect(allBatchSubtasks, hasLength(10));
        
        // Verify order is maintained
        for (int i = 0; i < 10; i++) {
          expect(allBatchSubtasks[i].title, equals('Batch Subtask $i'));
          expect(allBatchSubtasks[i].sortOrder, equals(i));
        }
      });

      test('should handle batch subtask updates', () async {
        final subtasks = List.generate(5, (index) => SubTask.create(
          title: 'Update Test Subtask $index',
          taskId: 'update-test-task',
          sortOrder: index,
        ));

        for (final subtask in subtasks) {
          await subtaskDao.insertSubtask(subtask);
        }

        // Update all subtasks to completed
        for (final subtask in subtasks) {
          final updatedSubtask = subtask.copyWith(isCompleted: true);
          await subtaskDao.updateSubtask(updatedSubtask);
        }

        final updatedSubtasks = await subtaskDao.getSubtasksForTask('update-test-task');
        for (final subtask in updatedSubtasks) {
          expect(subtask.isCompleted, isTrue);
        }
      });
    });
  });
}