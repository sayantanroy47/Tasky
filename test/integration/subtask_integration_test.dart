import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/subtask.dart';
import 'package:task_tracker_app/domain/entities/task_enums.dart';

void main() {
  group('Subtask Integration Tests', () {
    late TaskModel testTask;

    setUp(() {
      testTask = TaskModel.create(
        title: 'Test Task with Subtasks',
        description: 'A task to test subtask functionality',
        priority: TaskPriority.high,
      );
    });

    test('should create task with subtasks', () {
      final subTask1 = SubTask.create(
        taskId: testTask.id,
        title: 'First subtask',
        sortOrder: 0,
      );

      final subTask2 = SubTask.create(
        taskId: testTask.id,
        title: 'Second subtask',
        sortOrder: 1,
      );

      final taskWithSubTasks = testTask.copyWith(
        subTasks: [subTask1, subTask2],
      );

      expect(taskWithSubTasks.hasSubTasks, isTrue);
      expect(taskWithSubTasks.subTasks.length, equals(2));
      expect(taskWithSubTasks.subTaskCompletionPercentage, equals(0.0));
      expect(taskWithSubTasks.allSubTasksCompleted, isFalse);
    });

    test('should add subtask to existing task', () {
      final newSubTask = SubTask.create(
        taskId: testTask.id,
        title: 'New subtask',
        sortOrder: 0,
      );

      final updatedTask = testTask.addSubTask(newSubTask);

      expect(updatedTask.hasSubTasks, isTrue);
      expect(updatedTask.subTasks.length, equals(1));
      expect(updatedTask.subTasks.first.title, equals('New subtask'));
      expect(updatedTask.subTasks.first.taskId, equals(testTask.id));
    });

    test('should update subtask completion status', () {
      final subTask = SubTask.create(
        taskId: testTask.id,
        title: 'Test subtask',
        sortOrder: 0,
      );

      final taskWithSubTask = testTask.addSubTask(subTask);
      expect(taskWithSubTask.subTaskCompletionPercentage, equals(0.0));

      // Complete the subtask
      final completedSubTask = subTask.markCompleted();
      final updatedTask = taskWithSubTask.updateSubTask(completedSubTask);

      expect(updatedTask.subTaskCompletionPercentage, equals(1.0));
      expect(updatedTask.allSubTasksCompleted, isTrue);
      expect(updatedTask.subTasks.first.isCompleted, isTrue);
      expect(updatedTask.subTasks.first.completedAt, isNotNull);
    });

    test('should remove subtask from task', () {
      final subTask1 = SubTask.create(
        taskId: testTask.id,
        title: 'First subtask',
        sortOrder: 0,
      );

      final subTask2 = SubTask.create(
        taskId: testTask.id,
        title: 'Second subtask',
        sortOrder: 1,
      );

      final taskWithSubTasks = testTask.copyWith(
        subTasks: [subTask1, subTask2],
      );

      final updatedTask = taskWithSubTasks.removeSubTask(subTask1.id);

      expect(updatedTask.subTasks.length, equals(1));
      expect(updatedTask.subTasks.first.title, equals('Second subtask'));
    });

    test('should calculate correct completion percentage with mixed subtask states', () {
      final subTask1 = SubTask.create(
        taskId: testTask.id,
        title: 'Completed subtask',
        sortOrder: 0,
      ).markCompleted();

      final subTask2 = SubTask.create(
        taskId: testTask.id,
        title: 'Pending subtask 1',
        sortOrder: 1,
      );

      final subTask3 = SubTask.create(
        taskId: testTask.id,
        title: 'Pending subtask 2',
        sortOrder: 2,
      );

      final subTask4 = SubTask.create(
        taskId: testTask.id,
        title: 'Another completed subtask',
        sortOrder: 3,
      ).markCompleted();

      final taskWithSubTasks = testTask.copyWith(
        subTasks: [subTask1, subTask2, subTask3, subTask4],
      );

      // 2 out of 4 subtasks completed = 50%
      expect(taskWithSubTasks.subTaskCompletionPercentage, equals(0.5));
      expect(taskWithSubTasks.allSubTasksCompleted, isFalse);
    });

    test('should handle subtask reordering', () {
      final subTask1 = SubTask.create(
        taskId: testTask.id,
        title: 'First subtask',
        sortOrder: 0,
      );

      final subTask2 = SubTask.create(
        taskId: testTask.id,
        title: 'Second subtask',
        sortOrder: 1,
      );

      final subTask3 = SubTask.create(
        taskId: testTask.id,
        title: 'Third subtask',
        sortOrder: 2,
      );

      // Reorder: move first subtask to the end
      final reorderedSubTasks = [
        subTask2.copyWith(sortOrder: 0),
        subTask3.copyWith(sortOrder: 1),
        subTask1.copyWith(sortOrder: 2),
      ];

      final taskWithReorderedSubTasks = testTask.copyWith(
        subTasks: reorderedSubTasks,
      );

      expect(taskWithReorderedSubTasks.subTasks[0].title, equals('Second subtask'));
      expect(taskWithReorderedSubTasks.subTasks[1].title, equals('Third subtask'));
      expect(taskWithReorderedSubTasks.subTasks[2].title, equals('First subtask'));

      expect(taskWithReorderedSubTasks.subTasks[0].sortOrder, equals(0));
      expect(taskWithReorderedSubTasks.subTasks[1].sortOrder, equals(1));
      expect(taskWithReorderedSubTasks.subTasks[2].sortOrder, equals(2));
    });

    test('should validate subtask data integrity', () {
      final validSubTask = SubTask.create(
        taskId: testTask.id,
        title: 'Valid subtask',
        sortOrder: 0,
      );

      expect(validSubTask.isValid(), isTrue);

      // Test invalid subtask (empty title)
      final invalidSubTask = validSubTask.copyWith(title: '');
      expect(invalidSubTask.isValid(), isFalse);

      // Test invalid subtask (empty task ID)
      final invalidSubTask2 = validSubTask.copyWith(taskId: '');
      expect(invalidSubTask2.isValid(), isFalse);

      // Test invalid subtask (negative sort order)
      final invalidSubTask3 = validSubTask.copyWith(sortOrder: -1);
      expect(invalidSubTask3.isValid(), isFalse);
    });

    test('should handle subtask completion state transitions', () {
      final subTask = SubTask.create(
        taskId: testTask.id,
        title: 'Test subtask',
        sortOrder: 0,
      );

      // Initially not completed
      expect(subTask.isCompleted, isFalse);
      expect(subTask.completedAt, isNull);

      // Mark as completed
      final completedSubTask = subTask.markCompleted();
      expect(completedSubTask.isCompleted, isTrue);
      expect(completedSubTask.completedAt, isNotNull);

      // Mark as incomplete again
      final incompleteSubTask = completedSubTask.markIncomplete();
      expect(incompleteSubTask.isCompleted, isFalse);
      expect(incompleteSubTask.completedAt, isNull);
    });

    test('should maintain task validation with subtasks', () {
      final validSubTask = SubTask.create(
        taskId: testTask.id,
        title: 'Valid subtask',
        sortOrder: 0,
      );

      final invalidSubTask = SubTask.create(
        taskId: 'different-task-id', // Wrong task ID
        title: 'Invalid subtask',
        sortOrder: 1,
      );

      final taskWithValidSubTask = testTask.copyWith(subTasks: [validSubTask]);
      expect(taskWithValidSubTask.isValid(), isTrue);

      final taskWithInvalidSubTask = testTask.copyWith(subTasks: [invalidSubTask]);
      expect(taskWithInvalidSubTask.isValid(), isFalse);
    });
  });
}