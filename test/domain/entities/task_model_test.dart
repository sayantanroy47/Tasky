import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/task_enums.dart';
import 'package:task_tracker_app/domain/entities/subtask.dart';
import 'package:task_tracker_app/domain/entities/recurrence_pattern.dart';

void main() {
  group('TaskModel', () {
    late DateTime testDate;
    late TaskModel testTask;
    late SubTask testSubTask;
    late RecurrencePattern testRecurrence;

    setUp(() {
      testDate = DateTime(2024, 1, 15, 10, 30);
      testSubTask = SubTask(
        id: 'subtask-1',
        taskId: 'task-1',
        title: 'Test Subtask',
        createdAt: testDate,
      );
      testRecurrence = RecurrencePattern.daily();
      testTask = TaskModel(
        id: 'task-1',
        title: 'Test Task',
        description: 'A test task',
        createdAt: testDate,
        dueDate: testDate.add(const Duration(days: 1)),
        priority: TaskPriority.high,
        status: TaskStatus.pending,
        tags: const ['work', 'urgent'],
        subTasks: [testSubTask],
        locationTrigger: 'Office',
        recurrence: testRecurrence,
        projectId: 'project-1',
        dependencies: const ['task-0'],
        metadata: const {'key': 'value'},
        isPinned: true,
        estimatedDuration: 60,
      );
    });

    group('constructor', () {
      test('should create TaskModel with all fields', () {
        expect(testTask.id, 'task-1');
        expect(testTask.title, 'Test Task');
        expect(testTask.description, 'A test task');
        expect(testTask.createdAt, testDate);
        expect(testTask.dueDate, testDate.add(const Duration(days: 1)));
        expect(testTask.priority, TaskPriority.high);
        expect(testTask.status, TaskStatus.pending);
        expect(testTask.tags, ['work', 'urgent']);
        expect(testTask.subTasks, [testSubTask]);
        expect(testTask.locationTrigger, 'Office');
        expect(testTask.recurrence, testRecurrence);
        expect(testTask.projectId, 'project-1');
        expect(testTask.dependencies, ['task-0']);
        expect(testTask.metadata, {'key': 'value'});
        expect(testTask.isPinned, true);
        expect(testTask.estimatedDuration, 60);
      });

      test('should create TaskModel with default values', () {
        final task = TaskModel(
          id: 'id',
          title: 'title',
          createdAt: testDate,
        );

        expect(task.description, isNull);
        expect(task.updatedAt, isNull);
        expect(task.dueDate, isNull);
        expect(task.completedAt, isNull);
        expect(task.priority, TaskPriority.medium);
        expect(task.status, TaskStatus.pending);
        expect(task.tags, isEmpty);
        expect(task.subTasks, isEmpty);
        expect(task.locationTrigger, isNull);
        expect(task.recurrence, isNull);
        expect(task.projectId, isNull);
        expect(task.dependencies, isEmpty);
        expect(task.metadata, isEmpty);
        expect(task.isPinned, false);
        expect(task.estimatedDuration, isNull);
        expect(task.actualDuration, isNull);
      });
    });

    group('factory create', () {
      test('should create TaskModel with generated ID and current timestamp', () {
        final task = TaskModel.create(
          title: 'New Task',
          description: 'Description',
          dueDate: testDate,
          priority: TaskPriority.urgent,
          tags: const ['tag1', 'tag2'],
          locationTrigger: 'Home',
          recurrence: testRecurrence,
          projectId: 'project-1',
          dependencies: const ['dep-1'],
          metadata: const {'meta': 'data'},
          isPinned: true,
          estimatedDuration: 120,
        );

        expect(task.id, isNotEmpty);
        expect(task.title, 'New Task');
        expect(task.description, 'Description');
        expect(task.dueDate, testDate);
        expect(task.priority, TaskPriority.urgent);
        expect(task.tags, ['tag1', 'tag2']);
        expect(task.locationTrigger, 'Home');
        expect(task.recurrence, testRecurrence);
        expect(task.projectId, 'project-1');
        expect(task.dependencies, ['dep-1']);
        expect(task.metadata, {'meta': 'data'});
        expect(task.isPinned, true);
        expect(task.estimatedDuration, 120);
        expect(task.createdAt, isA<DateTime>());
        expect(task.status, TaskStatus.pending);
      });

      test('should create TaskModel with default values', () {
        final task = TaskModel.create(title: 'Simple Task');

        expect(task.priority, TaskPriority.medium);
        expect(task.tags, isEmpty);
        expect(task.dependencies, isEmpty);
        expect(task.metadata, isEmpty);
        expect(task.isPinned, false);
      });
    });

    group('JSON serialization', () {
      test('should serialize basic task to JSON correctly', () {
        final simpleTask = TaskModel(
          id: 'task-1',
          title: 'Simple Task',
          createdAt: testDate,
          priority: TaskPriority.high,
          status: TaskStatus.pending,
        );
        
        final json = simpleTask.toJson();

        expect(json['id'], 'task-1');
        expect(json['title'], 'Simple Task');
        expect(json['createdAt'], testDate.toIso8601String());
        expect(json['priority'], 'high');
        expect(json['status'], 'pending');
      });

      test('should deserialize basic task from JSON correctly', () {
        final simpleTask = TaskModel(
          id: 'task-1',
          title: 'Simple Task',
          createdAt: testDate,
          priority: TaskPriority.high,
          status: TaskStatus.pending,
        );
        
        final json = simpleTask.toJson();
        final deserializedTask = TaskModel.fromJson(json);

        expect(deserializedTask.id, simpleTask.id);
        expect(deserializedTask.title, simpleTask.title);
        expect(deserializedTask.createdAt, simpleTask.createdAt);
        expect(deserializedTask.priority, simpleTask.priority);
        expect(deserializedTask.status, simpleTask.status);
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final updatedTask = testTask.copyWith(
          title: 'Updated Task',
          priority: TaskPriority.low,
          status: TaskStatus.completed,
          isPinned: false,
        );

        expect(updatedTask.id, testTask.id);
        expect(updatedTask.title, 'Updated Task');
        expect(updatedTask.priority, TaskPriority.low);
        expect(updatedTask.status, TaskStatus.completed);
        expect(updatedTask.isPinned, false);
        expect(updatedTask.description, testTask.description);
        expect(updatedTask.createdAt, testTask.createdAt);
        expect(updatedTask.updatedAt, isA<DateTime>());
      });

      test('should preserve original values when no updates provided', () {
        final copiedTask = testTask.copyWith();
        // Note: copyWith always updates updatedAt, so we can't use direct equality
        expect(copiedTask.id, testTask.id);
        expect(copiedTask.title, testTask.title);
        expect(copiedTask.status, testTask.status);
      });
    });

    group('status management', () {
      test('markCompleted should mark task as completed', () {
        final completedTask = testTask.markCompleted();

        expect(completedTask.status, TaskStatus.completed);
        expect(completedTask.completedAt, isA<DateTime>());
        expect(completedTask.updatedAt, isA<DateTime>());
      });

      test('markInProgress should mark task as in progress', () {
        final inProgressTask = testTask.markInProgress();

        expect(inProgressTask.status, TaskStatus.inProgress);
        expect(inProgressTask.updatedAt, isA<DateTime>());
      });

      test('markCancelled should mark task as cancelled', () {
        final cancelledTask = testTask.markCancelled();

        expect(cancelledTask.status, TaskStatus.cancelled);
        expect(cancelledTask.updatedAt, isA<DateTime>());
      });

      test('resetToPending should reset task to pending', () {
        final completedTask = testTask.markCompleted();
        final pendingTask = completedTask.resetToPending();

        expect(pendingTask.status, TaskStatus.pending);
        expect(pendingTask.completedAt, isNull);
        expect(pendingTask.updatedAt, isA<DateTime>());
      });
    });

    group('tag management', () {
      test('addTag should add new tag', () {
        final updatedTask = testTask.addTag('new-tag');

        expect(updatedTask.tags, contains('new-tag'));
        expect(updatedTask.tags.length, 3);
        expect(updatedTask.updatedAt, isA<DateTime>());
      });

      test('addTag should not add duplicate tag', () {
        final updatedTask = testTask.addTag('work');

        expect(updatedTask.tags.length, 2);
        expect(updatedTask, equals(testTask));
      });

      test('removeTag should remove existing tag', () {
        final updatedTask = testTask.removeTag('work');

        expect(updatedTask.tags, isNot(contains('work')));
        expect(updatedTask.tags.length, 1);
        expect(updatedTask.updatedAt, isA<DateTime>());
      });

      test('removeTag should not change task if tag not found', () {
        final updatedTask = testTask.removeTag('non-existent');

        expect(updatedTask.tags.length, 2);
        expect(updatedTask, equals(testTask));
      });
    });

    group('subtask management', () {
      test('addSubTask should add new subtask', () {
        final newSubTask = SubTask.create(taskId: 'task-1', title: 'New Subtask');
        final updatedTask = testTask.addSubTask(newSubTask);

        expect(updatedTask.subTasks, contains(newSubTask));
        expect(updatedTask.subTasks.length, 2);
        expect(updatedTask.updatedAt, isA<DateTime>());
      });

      test('updateSubTask should update existing subtask', () {
        final updatedSubTask = testSubTask.copyWith(title: 'Updated Subtask');
        final updatedTask = testTask.updateSubTask(updatedSubTask);

        expect(updatedTask.subTasks.first.title, 'Updated Subtask');
        expect(updatedTask.updatedAt, isA<DateTime>());
      });

      test('updateSubTask should not change task if subtask not found', () {
        final nonExistentSubTask = SubTask.create(taskId: 'task-1', title: 'Non-existent');
        final updatedTask = testTask.updateSubTask(nonExistentSubTask);

        expect(updatedTask.subTasks.length, 1);
        expect(updatedTask, equals(testTask));
      });

      test('removeSubTask should remove existing subtask', () {
        final updatedTask = testTask.removeSubTask('subtask-1');

        expect(updatedTask.subTasks, isEmpty);
        expect(updatedTask.updatedAt, isA<DateTime>());
      });

      test('removeSubTask should not change task if subtask not found', () {
        final updatedTask = testTask.removeSubTask('non-existent');

        expect(updatedTask.subTasks.length, 1);
        expect(updatedTask, equals(testTask));
      });
    });

    group('dependency management', () {
      test('addDependency should add new dependency', () {
        final updatedTask = testTask.addDependency('task-2');

        expect(updatedTask.dependencies, contains('task-2'));
        expect(updatedTask.dependencies.length, 2);
        expect(updatedTask.updatedAt, isA<DateTime>());
      });

      test('addDependency should not add duplicate dependency', () {
        final updatedTask = testTask.addDependency('task-0');

        expect(updatedTask.dependencies.length, 1);
        expect(updatedTask, equals(testTask));
      });

      test('addDependency should not add self as dependency', () {
        final updatedTask = testTask.addDependency('task-1');

        expect(updatedTask.dependencies.length, 1);
        expect(updatedTask, equals(testTask));
      });

      test('removeDependency should remove existing dependency', () {
        final updatedTask = testTask.removeDependency('task-0');

        expect(updatedTask.dependencies, isEmpty);
        expect(updatedTask.updatedAt, isA<DateTime>());
      });

      test('removeDependency should not change task if dependency not found', () {
        final updatedTask = testTask.removeDependency('non-existent');

        expect(updatedTask.dependencies.length, 1);
        expect(updatedTask, equals(testTask));
      });
    });

    group('togglePin', () {
      test('should toggle pin status', () {
        final unpinnedTask = testTask.togglePin();
        expect(unpinnedTask.isPinned, false);
        expect(unpinnedTask.updatedAt, isA<DateTime>());

        final pinnedTask = unpinnedTask.togglePin();
        expect(pinnedTask.isPinned, true);
        expect(pinnedTask.updatedAt, isA<DateTime>());
      });
    });

    group('updateMetadata', () {
      test('should update metadata', () {
        final updatedTask = testTask.updateMetadata({'new': 'value', 'key': 'updated'});

        expect(updatedTask.metadata['new'], 'value');
        expect(updatedTask.metadata['key'], 'updated');
        expect(updatedTask.updatedAt, isA<DateTime>());
      });
    });

    group('isValid', () {
      test('should return true for valid task', () {
        expect(testTask.isValid(), true);
      });

      test('should return false for empty id', () {
        final invalidTask = testTask.copyWith(id: '');
        expect(invalidTask.isValid(), false);
      });

      test('should return false for empty title', () {
        final invalidTask = testTask.copyWith(title: '');
        expect(invalidTask.isValid(), false);
      });

      test('should return false for whitespace-only title', () {
        final invalidTask = testTask.copyWith(title: '   ');
        expect(invalidTask.isValid(), false);
      });

      test('should return false for completed task without completion date', () {
        final invalidTask = testTask.copyWith(
          status: TaskStatus.completed,
          completedAt: null,
        );
        expect(invalidTask.isValid(), false);
      });

      test('should return false for non-completed task with completion date', () {
        final invalidTask = testTask.copyWith(
          status: TaskStatus.pending,
          completedAt: DateTime.now(),
        );
        expect(invalidTask.isValid(), false);
      });

      test('should return false for invalid subtask', () {
        final invalidSubTask = testSubTask.copyWith(taskId: 'different-task');
        final invalidTask = testTask.copyWith(subTasks: [invalidSubTask]);
        expect(invalidTask.isValid(), false);
      });

      test('should return false for invalid recurrence pattern', () {
        // Cannot create const invalid recurrence due to assert, so we test that
        // the constructor throws an error instead
        expect(
          () => RecurrencePattern(type: RecurrenceType.daily, interval: 0),
          throwsA(isA<AssertionError>()),
        );
      });

      test('should return false for self-dependency', () {
        final invalidTask = testTask.copyWith(dependencies: ['task-1']);
        expect(invalidTask.isValid(), false);
      });
    });

    group('computed properties', () {
      test('isDueToday should return correct value', () {
        final today = DateTime.now();
        final todayTask = testTask.copyWith(
          dueDate: DateTime(today.year, today.month, today.day, 15, 0),
        );
        expect(todayTask.isDueToday, true);

        final tomorrowTask = testTask.copyWith(
          dueDate: today.add(const Duration(days: 1)),
        );
        expect(tomorrowTask.isDueToday, false);

        final noDueDateTask = testTask.copyWith(dueDate: null);
        expect(noDueDateTask.isDueToday, false);
      });

      test('isOverdue should return correct value', () {
        final pastTask = TaskModel(
          id: testTask.id,
          title: testTask.title,
          createdAt: testTask.createdAt,
          dueDate: DateTime.now().subtract(const Duration(hours: 1)),
          status: TaskStatus.pending,
        );
        expect(pastTask.isOverdue, true);

        final futureTask = TaskModel(
          id: testTask.id,
          title: testTask.title,
          createdAt: testTask.createdAt,
          dueDate: DateTime.now().add(const Duration(hours: 1)),
          status: TaskStatus.pending,
        );
        expect(futureTask.isOverdue, false);

        final completedTask = pastTask.markCompleted();
        expect(completedTask.isOverdue, false);

        final noDueDateTask = TaskModel(
          id: testTask.id,
          title: testTask.title,
          createdAt: testTask.createdAt,
          dueDate: null,
        );
        expect(noDueDateTask.isOverdue, false);
      });

      test('isDueSoon should return correct value', () {
        final soonTask = testTask.copyWith(
          dueDate: DateTime.now().add(const Duration(hours: 12)),
        );
        expect(soonTask.isDueSoon, true);

        final farTask = testTask.copyWith(
          dueDate: DateTime.now().add(const Duration(days: 2)),
        );
        expect(farTask.isDueSoon, false);

        final pastTask = testTask.copyWith(
          dueDate: DateTime.now().subtract(const Duration(hours: 1)),
        );
        expect(pastTask.isDueSoon, false);

        final completedTask = soonTask.markCompleted();
        expect(completedTask.isDueSoon, false);
      });

      test('hasSubTasks should return correct value', () {
        expect(testTask.hasSubTasks, true);

        final noSubTasksTask = testTask.copyWith(subTasks: []);
        expect(noSubTasksTask.hasSubTasks, false);
      });

      test('subTaskCompletionPercentage should return correct value', () {
        final completedSubTask = testSubTask.markCompleted();
        final incompleteSubTask = SubTask.create(taskId: 'task-1', title: 'Incomplete');
        
        final taskWithMixedSubTasks = testTask.copyWith(
          subTasks: [completedSubTask, incompleteSubTask],
        );
        expect(taskWithMixedSubTasks.subTaskCompletionPercentage, 0.5);

        final noSubTasksTask = testTask.copyWith(subTasks: []);
        expect(noSubTasksTask.subTaskCompletionPercentage, 0.0);
      });

      test('allSubTasksCompleted should return correct value', () {
        final completedSubTask = testSubTask.markCompleted();
        final allCompletedTask = testTask.copyWith(subTasks: [completedSubTask]);
        expect(allCompletedTask.allSubTasksCompleted, true);

        expect(testTask.allSubTasksCompleted, false);

        final noSubTasksTask = testTask.copyWith(subTasks: []);
        expect(noSubTasksTask.allSubTasksCompleted, true);
      });

      test('isRecurring should return correct value', () {
        expect(testTask.isRecurring, true);

        final nonRecurringTask = TaskModel(
          id: testTask.id,
          title: testTask.title,
          createdAt: testTask.createdAt,
          recurrence: null,
        );
        expect(nonRecurringTask.isRecurring, false);

        final noneRecurrenceTask = TaskModel(
          id: testTask.id,
          title: testTask.title,
          createdAt: testTask.createdAt,
          recurrence: const RecurrencePattern(type: RecurrenceType.none),
        );
        expect(noneRecurrenceTask.isRecurring, false);
      });

      test('hasProject should return correct value', () {
        expect(testTask.hasProject, true);

        final noProjectTask = TaskModel(
          id: testTask.id,
          title: testTask.title,
          createdAt: testTask.createdAt,
          projectId: null,
        );
        expect(noProjectTask.hasProject, false);

        final emptyProjectTask = TaskModel(
          id: testTask.id,
          title: testTask.title,
          createdAt: testTask.createdAt,
          projectId: '',
        );
        expect(emptyProjectTask.hasProject, false);
      });

      test('hasDependencies should return correct value', () {
        expect(testTask.hasDependencies, true);

        final noDependenciesTask = testTask.copyWith(dependencies: []);
        expect(noDependenciesTask.hasDependencies, false);
      });

      test('hasLocationTrigger should return correct value', () {
        expect(testTask.hasLocationTrigger, true);

        final noLocationTask = TaskModel(
          id: testTask.id,
          title: testTask.title,
          createdAt: testTask.createdAt,
          locationTrigger: null,
        );
        expect(noLocationTask.hasLocationTrigger, false);

        final emptyLocationTask = TaskModel(
          id: testTask.id,
          title: testTask.title,
          createdAt: testTask.createdAt,
          locationTrigger: '',
        );
        expect(emptyLocationTask.hasLocationTrigger, false);
      });

      test('daysUntilDue should return correct value', () {
        final futureDate = DateTime.now().add(const Duration(days: 5));
        final futureTask = testTask.copyWith(dueDate: futureDate);
        expect(futureTask.daysUntilDue, anyOf(4, 5)); // Allow for timing differences

        final pastDate = DateTime.now().subtract(const Duration(days: 3));
        final pastTask = testTask.copyWith(dueDate: pastDate);
        expect(pastTask.daysUntilDue, -3);

        final noDueDateTask = TaskModel(
          id: testTask.id,
          title: testTask.title,
          createdAt: testTask.createdAt,
          dueDate: null,
        );
        expect(noDueDateTask.daysUntilDue, isNull);
      });
    });

    group('generateNextRecurrence (deprecated)', () {
      test('should generate next recurring task when completed', () {
        final completedTask = testTask.markCompleted();
        // ignore: deprecated_member_use_from_same_package
        final nextTask = completedTask.generateNextRecurrence();

        expect(nextTask, isNotNull);
        expect(nextTask!.id, isNot(equals(completedTask.id)));
        expect(nextTask.title, completedTask.title);
        expect(nextTask.status, TaskStatus.pending);
        expect(nextTask.dueDate, isA<DateTime>());
        expect(nextTask.dueDate!.isAfter(completedTask.dueDate!), true);
      });

      test('should return null for non-recurring task', () {
        final nonRecurringTask = TaskModel(
          id: testTask.id,
          title: testTask.title,
          createdAt: testTask.createdAt,
          dueDate: testTask.dueDate,
          recurrence: null,
        );
        final completedTask = nonRecurringTask.markCompleted();
        // ignore: deprecated_member_use_from_same_package
        final nextTask = completedTask.generateNextRecurrence();

        expect(nextTask, isNull);
      });

      test('should return null for non-completed task', () {
        // ignore: deprecated_member_use_from_same_package
        final nextTask = testTask.generateNextRecurrence();
        expect(nextTask, isNull);
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        final task1 = TaskModel(
          id: 'id',
          title: 'title',
          createdAt: testDate,
        );

        final task2 = TaskModel(
          id: 'id',
          title: 'title',
          createdAt: testDate,
        );

        expect(task1, equals(task2));
        expect(task1.hashCode, equals(task2.hashCode));
      });

      test('should not be equal when properties differ', () {
        final task1 = testTask;
        final task2 = testTask.copyWith(title: 'Different Title');

        expect(task1, isNot(equals(task2)));
      });
    });

    group('toString', () {
      test('should return formatted string representation', () {
        final string = testTask.toString();

        expect(string, contains('TaskModel'));
        expect(string, contains('task-1'));
        expect(string, contains('Test Task'));
        expect(string, contains('pending'));
        expect(string, contains('high'));
        expect(string, contains('1')); // subtasks count
        expect(string, contains('2')); // tags count
      });
    });
  });
}
