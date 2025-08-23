import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracker_app/domain/entities/subtask.dart';

void main() {
  group('SubTask', () {
    late DateTime testDate;
    late SubTask testSubTask;

    setUp(() {
      testDate = DateTime(2024, 1, 15, 10, 30);
      testSubTask = SubTask(
        id: 'subtask-1',
        taskId: 'task-1',
        title: 'Test Subtask',
        isCompleted: false,
        sortOrder: 0,
        createdAt: testDate,
      );
    });

    group('constructor', () {
      test('should create SubTask with required fields', () {
        expect(testSubTask.id, 'subtask-1');
        expect(testSubTask.taskId, 'task-1');
        expect(testSubTask.title, 'Test Subtask');
        expect(testSubTask.isCompleted, false);
        expect(testSubTask.completedAt, isNull);
        expect(testSubTask.sortOrder, 0);
        expect(testSubTask.createdAt, testDate);
      });

      test('should create SubTask with default values', () {
        final subTask = SubTask(
          id: 'id',
          taskId: 'taskId',
          title: 'title',
          createdAt: testDate,
        );

        expect(subTask.isCompleted, false);
        expect(subTask.completedAt, isNull);
        expect(subTask.sortOrder, 0);
      });
    });

    group('factory create', () {
      test('should create SubTask with generated ID and current timestamp', () {
        final subTask = SubTask.create(
          taskId: 'task-1',
          title: 'New Subtask',
          sortOrder: 1,
        );

        expect(subTask.id, isNotEmpty);
        expect(subTask.taskId, 'task-1');
        expect(subTask.title, 'New Subtask');
        expect(subTask.sortOrder, 1);
        expect(subTask.isCompleted, false);
        expect(subTask.completedAt, isNull);
        expect(subTask.createdAt, isA<DateTime>());
      });

      test('should create SubTask with default sort order', () {
        final subTask = SubTask.create(
          taskId: 'task-1',
          title: 'New Subtask',
        );

        expect(subTask.sortOrder, 0);
      });
    });

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        final json = testSubTask.toJson();

        expect(json['id'], 'subtask-1');
        expect(json['taskId'], 'task-1');
        expect(json['title'], 'Test Subtask');
        expect(json['isCompleted'], false);
        expect(json['completedAt'], isNull);
        expect(json['sortOrder'], 0);
        expect(json['createdAt'], testDate.toIso8601String());
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'id': 'subtask-1',
          'taskId': 'task-1',
          'title': 'Test Subtask',
          'isCompleted': false,
          'completedAt': null,
          'sortOrder': 0,
          'createdAt': testDate.toIso8601String(),
        };

        final subTask = SubTask.fromJson(json);

        expect(subTask.id, 'subtask-1');
        expect(subTask.taskId, 'task-1');
        expect(subTask.title, 'Test Subtask');
        expect(subTask.isCompleted, false);
        expect(subTask.completedAt, isNull);
        expect(subTask.sortOrder, 0);
        expect(subTask.createdAt, testDate);
      });

      test('should handle completed subtask JSON serialization', () {
        final completedDate = DateTime(2024, 1, 16, 14, 30);
        final completedSubTask = testSubTask.copyWith(
          isCompleted: true,
          completedAt: completedDate,
        );

        final json = completedSubTask.toJson();
        expect(json['isCompleted'], true);
        expect(json['completedAt'], completedDate.toIso8601String());

        final deserialized = SubTask.fromJson(json);
        expect(deserialized.isCompleted, true);
        expect(deserialized.completedAt, completedDate);
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final updatedSubTask = testSubTask.copyWith(
          title: 'Updated Title',
          isCompleted: true,
          sortOrder: 5,
        );

        expect(updatedSubTask.id, testSubTask.id);
        expect(updatedSubTask.taskId, testSubTask.taskId);
        expect(updatedSubTask.title, 'Updated Title');
        expect(updatedSubTask.isCompleted, true);
        expect(updatedSubTask.sortOrder, 5);
        expect(updatedSubTask.createdAt, testSubTask.createdAt);
      });

      test('should preserve original values when no updates provided', () {
        final copiedSubTask = testSubTask.copyWith();

        expect(copiedSubTask, equals(testSubTask));
      });
    });

    group('markCompleted', () {
      test('should mark subtask as completed with timestamp', () {
        final completedSubTask = testSubTask.markCompleted();

        expect(completedSubTask.isCompleted, true);
        expect(completedSubTask.completedAt, isA<DateTime>());
        expect(completedSubTask.completedAt!.isAfter(testDate), true);
      });
    });

    group('markIncomplete', () {
      test('should mark subtask as incomplete and clear completion date', () {
        final completedSubTask = testSubTask.markCompleted();
        final incompleteSubTask = completedSubTask.markIncomplete();

        expect(incompleteSubTask.isCompleted, false);
        expect(incompleteSubTask.completedAt, isNull);
      });
    });

    group('isValid', () {
      test('should return true for valid subtask', () {
        expect(testSubTask.isValid(), true);
      });

      test('should return false for empty id', () {
        final invalidSubTask = testSubTask.copyWith(id: '');
        expect(invalidSubTask.isValid(), false);
      });

      test('should return false for empty taskId', () {
        final invalidSubTask = testSubTask.copyWith(taskId: '');
        expect(invalidSubTask.isValid(), false);
      });

      test('should return false for empty title', () {
        final invalidSubTask = testSubTask.copyWith(title: '');
        expect(invalidSubTask.isValid(), false);
      });

      test('should return false for whitespace-only title', () {
        final invalidSubTask = testSubTask.copyWith(title: '   ');
        expect(invalidSubTask.isValid(), false);
      });

      test('should return false for completed task without completion date', () {
        final invalidSubTask = testSubTask.copyWith(
          isCompleted: true,
          completedAt: null,
        );
        expect(invalidSubTask.isValid(), false);
      });

      test('should return false for incomplete task with completion date', () {
        final invalidSubTask = testSubTask.copyWith(
          isCompleted: false,
          completedAt: DateTime.now(),
        );
        expect(invalidSubTask.isValid(), false);
      });

      test('should return false for negative sort order', () {
        final invalidSubTask = testSubTask.copyWith(sortOrder: -1);
        expect(invalidSubTask.isValid(), false);
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        final subTask1 = SubTask(
          id: 'id',
          taskId: 'taskId',
          title: 'title',
          isCompleted: false,
          sortOrder: 0,
          createdAt: testDate,
        );

        final subTask2 = SubTask(
          id: 'id',
          taskId: 'taskId',
          title: 'title',
          isCompleted: false,
          sortOrder: 0,
          createdAt: testDate,
        );

        expect(subTask1, equals(subTask2));
        expect(subTask1.hashCode, equals(subTask2.hashCode));
      });

      test('should not be equal when properties differ', () {
        final subTask1 = testSubTask;
        final subTask2 = testSubTask.copyWith(title: 'Different Title');

        expect(subTask1, isNot(equals(subTask2)));
      });
    });

    group('toString', () {
      test('should return formatted string representation', () {
        final string = testSubTask.toString();

        expect(string, contains('SubTask'));
        expect(string, contains('subtask-1'));
        expect(string, contains('task-1'));
        expect(string, contains('Test Subtask'));
        expect(string, contains('false'));
        expect(string, contains('0'));
      });
    });
  });
}
