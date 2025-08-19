import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/subtask.dart';
import 'package:task_tracker_app/domain/entities/recurrence_pattern.dart';
import 'package:task_tracker_app/domain/entities/task_enums.dart';

/// COMPREHENSIVE TASK MODEL TESTS - EVERY EDGE CASE AND SCENARIO
void main() {
  group('TaskModel - Comprehensive Domain Logic Tests', () {
    
    group('Task Creation Tests', () {
      test('should create task with valid required fields only', () {
        final task = TaskModel.create(
          title: 'Test Task',
        );
        
        expect(task.title, equals('Test Task'));
        expect(task.description, isNull);
        expect(task.isCompleted, isFalse);
        expect(task.priority, equals(TaskPriority.medium));
        expect(task.status, equals(TaskStatus.pending));
        expect(task.tags, isEmpty);
        expect(task.subTasks, isEmpty);
        expect(task.id, isNotNull);
        expect(task.createdAt, isNotNull);
      });

      test('should create task with all fields populated', () {
        final dueDate = DateTime(2024, 12, 25, 14, 30);
        final tags = ['work', 'urgent'];
        
        final task = TaskModel.create(
          title: 'Complete Project',
          description: 'Finish all remaining tasks for the project',
          priority: TaskPriority.high,
          dueDate: dueDate,
          tags: tags,
          metadata: const {'source': 'voice', 'category': 'work'},
        );
        
        expect(task.title, equals('Complete Project'));
        expect(task.description, equals('Finish all remaining tasks for the project'));
        expect(task.priority, equals(TaskPriority.high));
        expect(task.dueDate, equals(dueDate));
        expect(task.tags, equals(tags));
        expect(task.metadata['source'], equals('voice'));
        expect(task.metadata['category'], equals('work'));
      });

      test('should generate unique IDs for different tasks', () {
        final task1 = TaskModel.create(title: 'Task 1');
        final task2 = TaskModel.create(title: 'Task 2');
        
        expect(task1.id, isNot(equals(task2.id)));
      });

      test('should set creation time for new tasks', () {
        final beforeCreation = DateTime.now();
        final task = TaskModel.create(title: 'Timed Task');
        final afterCreation = DateTime.now();
        
        expect(task.createdAt.isAfter(beforeCreation) || task.createdAt.isAtSameMomentAs(beforeCreation), isTrue);
        expect(task.createdAt.isBefore(afterCreation) || task.createdAt.isAtSameMomentAs(afterCreation), isTrue);
      });
    });

    group('Task Status Management', () {
      test('should mark task as completed', () {
        final task = TaskModel.create(title: 'Test Task');
        final completedTask = task.markCompleted();
        
        expect(completedTask.status, equals(TaskStatus.completed));
        expect(completedTask.completedAt, isNotNull);
        expect(completedTask.isCompleted, isTrue);
        expect(completedTask.updatedAt, isNotNull);
      });

      test('should mark task as in progress', () {
        final task = TaskModel.create(title: 'Test Task');
        final inProgressTask = task.markInProgress();
        
        expect(inProgressTask.status, equals(TaskStatus.inProgress));
        expect(inProgressTask.updatedAt, isNotNull);
      });

      test('should mark task as cancelled', () {
        final task = TaskModel.create(title: 'Test Task');
        final cancelledTask = task.markCancelled();
        
        expect(cancelledTask.status, equals(TaskStatus.cancelled));
        expect(cancelledTask.updatedAt, isNotNull);
      });

      test('should reset task to pending', () {
        final task = TaskModel.create(title: 'Test Task')
            .markCompleted();
        final resetTask = task.resetToPending();
        
        expect(resetTask.status, equals(TaskStatus.pending));
        expect(resetTask.completedAt, isNull);
        expect(resetTask.updatedAt, isNotNull);
      });
    });

    group('Tag Management', () {
      test('should add tags to task', () {
        final task = TaskModel.create(title: 'Test Task');
        final taggedTask = task.addTag('work');
        
        expect(taggedTask.tags, contains('work'));
        expect(taggedTask.updatedAt, isNotNull);
      });

      test('should not add duplicate tags', () {
        final task = TaskModel.create(title: 'Test Task', tags: const ['work']);
        final taggedTask = task.addTag('work');
        
        expect(taggedTask.tags.length, equals(1));
        expect(taggedTask.tags, contains('work'));
      });

      test('should remove tags from task', () {
        final task = TaskModel.create(title: 'Test Task', tags: const ['work', 'urgent']);
        final untaggedTask = task.removeTag('work');
        
        expect(untaggedTask.tags, isNot(contains('work')));
        expect(untaggedTask.tags, contains('urgent'));
        expect(untaggedTask.updatedAt, isNotNull);
      });

      test('should handle removing non-existent tag', () {
        final task = TaskModel.create(title: 'Test Task', tags: const ['work']);
        final unchanged = task.removeTag('nonexistent');
        
        expect(unchanged.tags, equals(task.tags));
      });
    });

    group('SubTask Management', () {
      test('should add subtasks to task', () {
        final task = TaskModel.create(title: 'Test Task');
        final subtask = SubTask.create(
          title: 'Subtask 1',
          taskId: task.id,
        );
        final withSubtask = task.addSubTask(subtask);
        
        expect(withSubtask.subTasks.length, equals(1));
        expect(withSubtask.subTasks.first.title, equals('Subtask 1'));
        expect(withSubtask.hasSubTasks, isTrue);
        expect(withSubtask.updatedAt, isNotNull);
      });

      test('should update existing subtask', () {
        final task = TaskModel.create(title: 'Test Task');
        final subtask = SubTask.create(
          title: 'Original Title',
          taskId: task.id,
        );
        final withSubtask = task.addSubTask(subtask);
        final updatedSubtask = subtask.copyWith(title: 'Updated Title');
        final withUpdatedSubtask = withSubtask.updateSubTask(updatedSubtask);
        
        expect(withUpdatedSubtask.subTasks.first.title, equals('Updated Title'));
        expect(withUpdatedSubtask.updatedAt, isNotNull);
      });

      test('should remove subtask from task', () {
        final task = TaskModel.create(title: 'Test Task');
        final subtask = SubTask.create(
          title: 'To Remove',
          taskId: task.id,
        );
        final withSubtask = task.addSubTask(subtask);
        final withoutSubtask = withSubtask.removeSubTask(subtask.id);
        
        expect(withoutSubtask.subTasks, isEmpty);
        expect(withoutSubtask.hasSubTasks, isFalse);
        expect(withoutSubtask.updatedAt, isNotNull);
      });

      test('should calculate subtask completion percentage', () {
        final task = TaskModel.create(title: 'Test Task');
        final subtask1 = SubTask.create(title: 'Sub 1', taskId: task.id).markCompleted();
        final subtask2 = SubTask.create(title: 'Sub 2', taskId: task.id);
        
        final withSubtasks = task
            .addSubTask(subtask1)
            .addSubTask(subtask2);
        
        expect(withSubtasks.subTaskCompletionPercentage, equals(0.5));
      });

      test('should check if all subtasks are completed', () {
        final task = TaskModel.create(title: 'Test Task');
        final subtask1 = SubTask.create(title: 'Sub 1', taskId: task.id).markCompleted();
        final subtask2 = SubTask.create(title: 'Sub 2', taskId: task.id).markCompleted();
        
        final withSubtasks = task
            .addSubTask(subtask1)
            .addSubTask(subtask2);
        
        expect(withSubtasks.allSubTasksCompleted, isTrue);
      });
    });

    group('Due Date Properties', () {
      test('should identify if task is due today', () {
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day, 23, 59);
        
        final task = TaskModel.create(
          title: 'Due Today',
          dueDate: todayDate,
        );
        
        expect(task.isDueToday, isTrue);
      });

      test('should identify if task is overdue', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        
        final task = TaskModel.create(
          title: 'Overdue Task',
          dueDate: yesterday,
        );
        
        expect(task.isOverdue, isTrue);
      });

      test('should not consider completed tasks as overdue', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        
        final task = TaskModel.create(
          title: 'Completed Overdue',
          dueDate: yesterday,
        ).markCompleted();
        
        expect(task.isOverdue, isFalse);
      });

      test('should identify if task is due soon', () {
        final soon = DateTime.now().add(const Duration(hours: 12));
        
        final task = TaskModel.create(
          title: 'Due Soon',
          dueDate: soon,
        );
        
        expect(task.isDueSoon, isTrue);
      });

      test('should calculate days until due', () {
        final threeDaysFromNow = DateTime.now().add(const Duration(days: 3));
        
        final task = TaskModel.create(
          title: 'Future Task',
          dueDate: threeDaysFromNow,
        );
        
        final daysUntil = task.daysUntilDue;
        expect(daysUntil, isA<int>());
        expect(daysUntil! >= 2 && daysUntil <= 3, isTrue); // Account for time precision
      });
    });

    group('Recurrence Properties', () {
      test('should create recurring task with pattern', () {
        final recurrence = RecurrencePattern.daily(interval: 2);
        
        final task = TaskModel.create(
          title: 'Recurring Task',
          recurrence: recurrence,
        );
        
        expect(task.isRecurring, isTrue);
        expect(task.recurrence, equals(recurrence));
      });

      test('should identify task as part of recurring series', () {
        final task = TaskModel.create(
          title: 'Recurring Instance',
          metadata: const {'original_task_id': 'parent-123'},
        );
        
        expect(task.isPartOfRecurringSeries, isTrue);
        expect(task.originalRecurringTaskId, equals('parent-123'));
      });

      test('should get occurrence number', () {
        final task = TaskModel.create(
          title: 'Third Occurrence',
          metadata: const {'occurrence_number': 3},
        );
        
        expect(task.occurrenceNumber, equals(3));
      });
    });

    group('Dependencies Management', () {
      test('should add dependency to task', () {
        final task = TaskModel.create(title: 'Dependent Task');
        final withDependency = task.addDependency('prerequisite-task-id');
        
        expect(withDependency.dependencies, contains('prerequisite-task-id'));
        expect(withDependency.hasDependencies, isTrue);
        expect(withDependency.updatedAt, isNotNull);
      });

      test('should not add self as dependency', () {
        final task = TaskModel.create(title: 'Self Task');
        final unchanged = task.addDependency(task.id);
        
        expect(unchanged.dependencies, isEmpty);
      });

      test('should remove dependency from task', () {
        final task = TaskModel.create(title: 'Task')
            .addDependency('dep-1')
            .addDependency('dep-2');
        final withoutDep = task.removeDependency('dep-1');
        
        expect(withoutDep.dependencies, isNot(contains('dep-1')));
        expect(withoutDep.dependencies, contains('dep-2'));
        expect(withoutDep.updatedAt, isNotNull);
      });
    });

    group('Metadata Management', () {
      test('should update metadata', () {
        final task = TaskModel.create(
          title: 'Task',
          metadata: const {'key1': 'value1'},
        );
        final updated = task.updateMetadata({'key2': 'value2', 'key1': 'updated'});
        
        expect(updated.metadata['key1'], equals('updated'));
        expect(updated.metadata['key2'], equals('value2'));
        expect(updated.updatedAt, isNotNull);
      });

      test('should toggle pin status', () {
        final task = TaskModel.create(title: 'Task');
        final pinned = task.togglePin();
        final unpinned = pinned.togglePin();
        
        expect(pinned.isPinned, isTrue);
        expect(unpinned.isPinned, isFalse);
        expect(unpinned.updatedAt, isNotNull);
      });
    });

    group('Project and Location', () {
      test('should identify task with project', () {
        final task = TaskModel.create(
          title: 'Project Task',
          projectId: 'project-123',
        );
        
        expect(task.hasProject, isTrue);
        expect(task.projectId, equals('project-123'));
      });

      test('should identify task with location trigger', () {
        final task = TaskModel.create(
          title: 'Location Task',
          locationTrigger: 'office',
        );
        
        expect(task.hasLocationTrigger, isTrue);
        expect(task.locationTrigger, equals('office'));
      });
    });

    group('Task Validation', () {
      test('should validate correct task', () {
        final task = TaskModel.create(title: 'Valid Task');
        
        expect(task.isValid(), isTrue);
      });

      test('should invalidate task with empty title', () {
        // Create task with valid title first, then copy with empty title
        final task = TaskModel.create(title: 'Valid')
            .copyWith(title: '   ');
        
        expect(task.isValid(), isFalse);
      });

      test('should invalidate completed task without completion date', () {
        final task = TaskModel.create(title: 'Task')
            .copyWith(status: TaskStatus.completed, completedAt: null);
        
        expect(task.isValid(), isFalse);
      });

      test('should invalidate non-completed task with completion date', () {
        final task = TaskModel.create(title: 'Task')
            .copyWith(
              status: TaskStatus.pending, 
              completedAt: DateTime.now(),
            );
        
        expect(task.isValid(), isFalse);
      });
    });

    group('Task Copying', () {
      test('should copy task with updated fields', () {
        final original = TaskModel.create(
          title: 'Original',
          priority: TaskPriority.low,
        );
        
        final copied = original.copyWith(
          title: 'Updated',
          priority: TaskPriority.high,
        );
        
        expect(copied.title, equals('Updated'));
        expect(copied.priority, equals(TaskPriority.high));
        expect(copied.id, equals(original.id)); // ID should remain same
        expect(copied.createdAt, equals(original.createdAt)); // Created date unchanged
        expect(copied.updatedAt, isNotNull); // Updated date set
      });
    });

    group('Edge Cases', () {
      test('should handle task with very long title', () {
        const longTitle = 'This is a very long task title that exceeds normal length to test how the system handles lengthy task descriptions and titles';
        
        final task = TaskModel.create(title: longTitle);
        
        expect(task.title, equals(longTitle));
        expect(task.isValid(), isTrue);
      });

      test('should handle task with special characters', () {
        const specialTitle = 'Task with émojis 🚀 & symbols @#\$%^&*()';
        
        final task = TaskModel.create(title: specialTitle);
        
        expect(task.title, equals(specialTitle));
        expect(task.isValid(), isTrue);
      });

      test('should handle task with null optional fields', () {
        final task = TaskModel.create(
          title: 'Minimal Task',
          description: null,
          dueDate: null,
        );
        
        expect(task.description, isNull);
        expect(task.dueDate, isNull);
        expect(task.isValid(), isTrue);
      });
    });
  });
}