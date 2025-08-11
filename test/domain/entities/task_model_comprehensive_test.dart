import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/models/enums.dart';

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
        expect(task.subtasks, isEmpty);
        expect(task.id, isNotNull);
        expect(task.createdAt, isNotNull);
        expect(task.updatedAt, isNotNull);
      });

      test('should create task with all fields populated', () {
        final dueDate = DateTime(2024, 12, 25, 14, 30);
        final reminder = DateTime(2024, 12, 24, 9, 0);
        final tags = ['work', 'urgent'];
        
        final task = TaskModel.create(
          title: 'Complete Project',
          description: 'Finish all remaining tasks for the project',
          priority: TaskPriority.high,
          dueDate: dueDate,
          reminderDate: reminder,
          tags: tags,
          metadata: {'source': 'voice', 'category': 'work'},
        );
        
        expect(task.title, equals('Complete Project'));
        expect(task.description, equals('Finish all remaining tasks for the project'));
        expect(task.priority, equals(TaskPriority.high));
        expect(task.dueDate, equals(dueDate));
        expect(task.reminderDate, equals(reminder));
        expect(task.tags, equals(tags));
        expect(task.metadata['source'], equals('voice'));
        expect(task.metadata['category'], equals('work'));
      });

      test('should throw ArgumentError for empty title', () {
        expect(
          () => TaskModel.create(title: ''),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw ArgumentError for whitespace-only title', () {
        expect(
          () => TaskModel.create(title: '   '),
          throwsA(isA<ArgumentError>()),
        );
      });
      
      test('should trim title and description whitespace', () {
        final task = TaskModel.create(
          title: '  Task Title  ',
          description: '  Task Description  ',
        );
        
        expect(task.title, equals('Task Title'));
        expect(task.description, equals('Task Description'));
      });
    });

    group('Task Priority Logic Tests', () {
      test('should handle all priority levels correctly', () {
        for (final priority in TaskPriority.values) {
          final task = TaskModel.create(
            title: 'Test $priority',
            priority: priority,
          );
          
          expect(task.priority, equals(priority));
        }
      });

      test('should validate priority ordering logic', () {
        final priorities = [
          TaskPriority.low,
          TaskPriority.medium,
          TaskPriority.high,
          TaskPriority.urgent,
        ];
        
        for (int i = 0; i < priorities.length - 1; i++) {
          final current = priorities[i];
          final next = priorities[i + 1];
          
          expect(current.index < next.index, isTrue,
              reason: '$current should have lower index than $next');
        }
      });
    });

    group('Task Status Transitions Tests', () {
      test('should transition from pending to in_progress', () {
        var task = TaskModel.create(title: 'Test Task');
        expect(task.status, equals(TaskStatus.pending));
        
        task = task.copyWith(status: TaskStatus.inProgress);
        expect(task.status, equals(TaskStatus.inProgress));
      });

      test('should complete task and update completedAt timestamp', () {
        var task = TaskModel.create(title: 'Test Task');
        expect(task.isCompleted, isFalse);
        expect(task.completedAt, isNull);
        
        final completedTask = task.complete();
        expect(completedTask.isCompleted, isTrue);
        expect(completedTask.completedAt, isNotNull);
        expect(completedTask.status, equals(TaskStatus.completed));
      });

      test('should reopen completed task', () {
        var task = TaskModel.create(title: 'Test Task').complete();
        expect(task.isCompleted, isTrue);
        
        task = task.reopen();
        expect(task.isCompleted, isFalse);
        expect(task.completedAt, isNull);
        expect(task.status, equals(TaskStatus.pending));
      });
    });

    group('Date Logic Tests - CRITICAL EDGE CASES', () {
      test('should handle due date in the past', () {
        final pastDate = DateTime.now().subtract(const Duration(days: 5));
        final task = TaskModel.create(
          title: 'Overdue Task',
          dueDate: pastDate,
        );
        
        expect(task.dueDate, equals(pastDate));
        expect(task.isOverdue, isTrue);
      });

      test('should handle due date today', () {
        final today = DateTime.now();
        final todayMidnight = DateTime(today.year, today.month, today.day);
        
        final task = TaskModel.create(
          title: 'Due Today',
          dueDate: todayMidnight,
        );
        
        expect(task.isDueToday, isTrue);
        expect(task.isOverdue, isFalse);
      });

      test('should handle due date in the future', () {
        final futureDate = DateTime.now().add(const Duration(days: 5));
        final task = TaskModel.create(
          title: 'Future Task',
          dueDate: futureDate,
        );
        
        expect(task.isOverdue, isFalse);
        expect(task.isDueToday, isFalse);
      });

      test('should validate reminder date logic', () {
        final dueDate = DateTime(2024, 12, 25, 14, 0);
        final validReminder = DateTime(2024, 12, 24, 9, 0);
        final invalidReminder = DateTime(2024, 12, 26, 9, 0); // After due date
        
        // Valid reminder
        final validTask = TaskModel.create(
          title: 'Task with Valid Reminder',
          dueDate: dueDate,
          reminderDate: validReminder,
        );
        expect(validTask.reminderDate, equals(validReminder));
        
        // Invalid reminder should throw or be ignored
        expect(
          () => TaskModel.create(
            title: 'Task with Invalid Reminder',
            dueDate: dueDate,
            reminderDate: invalidReminder,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should handle leap year dates correctly', () {
        final leapYearDate = DateTime(2024, 2, 29); // 2024 is a leap year
        final task = TaskModel.create(
          title: 'Leap Year Task',
          dueDate: leapYearDate,
        );
        
        expect(task.dueDate, equals(leapYearDate));
      });

      test('should handle timezone edge cases', () {
        final utcDate = DateTime.utc(2024, 12, 25, 12, 0);
        final localDate = DateTime(2024, 12, 25, 12, 0);
        
        final utcTask = TaskModel.create(
          title: 'UTC Task',
          dueDate: utcDate,
        );
        
        final localTask = TaskModel.create(
          title: 'Local Task',
          dueDate: localDate,
        );
        
        expect(utcTask.dueDate, equals(utcDate));
        expect(localTask.dueDate, equals(localDate));
      });
    });

    group('Task Tags and Metadata Tests', () {
      test('should handle empty tags list', () {
        final task = TaskModel.create(
          title: 'No Tags Task',
          tags: [],
        );
        
        expect(task.tags, isEmpty);
      });

      test('should normalize and validate tags', () {
        final task = TaskModel.create(
          title: 'Tagged Task',
          tags: ['WORK', 'personal', '  urgent  ', 'work'], // Duplicates and whitespace
        );
        
        // Should normalize to lowercase and remove duplicates/whitespace
        expect(task.tags, containsAll(['work', 'personal', 'urgent']));
        expect(task.tags.length, equals(3)); // No duplicates
      });

      test('should handle large metadata objects', () {
        final largeMetadata = <String, dynamic>{
          'source': 'voice_recognition',
          'confidence_score': 0.95,
          'processing_time_ms': 1250,
          'user_corrections': ['title', 'due_date'],
          'ai_suggestions': {
            'priority': 'high',
            'category': 'work',
            'estimated_duration': '2h',
          },
          'location_data': {
            'latitude': 37.7749,
            'longitude': -122.4194,
            'address': '123 Main St, San Francisco, CA',
          }
        };
        
        final task = TaskModel.create(
          title: 'Complex Task',
          metadata: largeMetadata,
        );
        
        expect(task.metadata['source'], equals('voice_recognition'));
        expect(task.metadata['ai_suggestions']['priority'], equals('high'));
        expect(task.metadata['location_data']['latitude'], equals(37.7749));
      });
    });

    group('Subtask Logic Tests', () {
      test('should handle empty subtasks list', () {
        final task = TaskModel.create(
          title: 'Task with No Subtasks',
        );
        
        expect(task.subtasks, isEmpty);
        expect(task.completedSubtasks, equals(0));
        expect(task.totalSubtasks, equals(0));
        expect(task.subtaskProgress, equals(0.0));
      });

      test('should calculate subtask progress correctly', () {
        final subtasks = [
          'Subtask 1',
          'Subtask 2',
          'Subtask 3',
          'Subtask 4',
        ];
        
        final task = TaskModel.create(
          title: 'Task with Subtasks',
          subtasks: subtasks,
        );
        
        expect(task.totalSubtasks, equals(4));
        expect(task.completedSubtasks, equals(0));
        expect(task.subtaskProgress, equals(0.0));
        
        // Complete some subtasks
        final partiallyCompleted = task.copyWith(
          completedSubtasks: 2,
        );
        
        expect(partiallyCompleted.subtaskProgress, equals(0.5)); // 2/4 = 0.5
        
        // Complete all subtasks
        final fullyCompleted = task.copyWith(
          completedSubtasks: 4,
        );
        
        expect(fullyCompleted.subtaskProgress, equals(1.0)); // 4/4 = 1.0
      });
    });

    group('Task Validation and Edge Cases', () {
      test('should handle very long title (boundary testing)', () {
        final longTitle = 'A' * 1000; // 1000 characters
        
        final task = TaskModel.create(title: longTitle);
        expect(task.title, equals(longTitle));
      });

      test('should handle special characters in title', () {
        const specialTitle = 'Task with émojis 🚀 and spëcial chärs #@%';
        
        final task = TaskModel.create(title: specialTitle);
        expect(task.title, equals(specialTitle));
      });

      test('should handle null description correctly', () {
        final task = TaskModel.create(
          title: 'Task',
          description: null,
        );
        
        expect(task.description, isNull);
      });

      test('should handle empty description', () {
        final task = TaskModel.create(
          title: 'Task',
          description: '',
        );
        
        // Empty description should be converted to null
        expect(task.description, isNull);
      });
    });

    group('Task Equality and Comparison Tests', () {
      test('should compare tasks by ID correctly', () {
        final task1 = TaskModel.create(title: 'Task 1');
        final task2 = TaskModel.create(title: 'Task 2');
        final task1Copy = task1.copyWith(title: 'Modified Task 1');
        
        expect(task1 == task2, isFalse);
        expect(task1 == task1Copy, isTrue); // Same ID
        expect(task1.hashCode == task1Copy.hashCode, isTrue);
      });

      test('should handle copyWith edge cases', () {
        final original = TaskModel.create(
          title: 'Original Task',
          description: 'Original Description',
          priority: TaskPriority.low,
        );
        
        // Copy with null values
        final copied = original.copyWith(
          description: null,
          priority: TaskPriority.urgent,
        );
        
        expect(copied.title, equals('Original Task'));
        expect(copied.description, isNull);
        expect(copied.priority, equals(TaskPriority.urgent));
        expect(copied.id, equals(original.id)); // ID should remain the same
      });
    });

    group('Recurring Task Logic Tests', () {
      test('should handle daily recurring tasks', () {
        final task = TaskModel.create(
          title: 'Daily Task',
          recurrenceRule: RecurrenceRule.daily(interval: 1),
        );
        
        expect(task.isRecurring, isTrue);
        expect(task.recurrenceRule?.pattern, equals(RecurrencePattern.daily));
        expect(task.recurrenceRule?.interval, equals(1));
      });

      test('should handle weekly recurring tasks with specific days', () {
        final task = TaskModel.create(
          title: 'Weekly Meeting',
          recurrenceRule: RecurrenceRule.weekly(
            interval: 1,
            daysOfWeek: [DateTime.monday, DateTime.friday],
          ),
        );
        
        expect(task.isRecurring, isTrue);
        expect(task.recurrenceRule?.pattern, equals(RecurrencePattern.weekly));
        expect(task.recurrenceRule?.daysOfWeek, contains(DateTime.monday));
        expect(task.recurrenceRule?.daysOfWeek, contains(DateTime.friday));
      });

      test('should handle monthly recurring tasks', () {
        final task = TaskModel.create(
          title: 'Monthly Report',
          recurrenceRule: RecurrenceRule.monthly(
            interval: 1,
            dayOfMonth: 15,
          ),
        );
        
        expect(task.isRecurring, isTrue);
        expect(task.recurrenceRule?.pattern, equals(RecurrencePattern.monthly));
        expect(task.recurrenceRule?.dayOfMonth, equals(15));
      });
    });
  });
}