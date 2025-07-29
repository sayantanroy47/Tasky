import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracker_app/domain/entities/task_enums.dart';

void main() {
  group('TaskStatus', () {
    test('should have correct JSON values', () {
      expect(TaskStatus.pending.name, 'pending');
      expect(TaskStatus.inProgress.name, 'inProgress');
      expect(TaskStatus.completed.name, 'completed');
      expect(TaskStatus.cancelled.name, 'cancelled');
    });

    test('should correctly identify active status', () {
      expect(TaskStatus.pending.isActive, isTrue);
      expect(TaskStatus.inProgress.isActive, isTrue);
      expect(TaskStatus.completed.isActive, isFalse);
      expect(TaskStatus.cancelled.isActive, isFalse);
    });

    test('should correctly identify completed status', () {
      expect(TaskStatus.pending.isCompleted, isFalse);
      expect(TaskStatus.inProgress.isCompleted, isFalse);
      expect(TaskStatus.completed.isCompleted, isTrue);
      expect(TaskStatus.cancelled.isCompleted, isFalse);
    });

    test('should correctly identify cancelled status', () {
      expect(TaskStatus.pending.isCancelled, isFalse);
      expect(TaskStatus.inProgress.isCancelled, isFalse);
      expect(TaskStatus.completed.isCancelled, isFalse);
      expect(TaskStatus.cancelled.isCancelled, isTrue);
    });

    test('should return correct display names', () {
      expect(TaskStatus.pending.displayName, 'Pending');
      expect(TaskStatus.inProgress.displayName, 'In Progress');
      expect(TaskStatus.completed.displayName, 'Completed');
      expect(TaskStatus.cancelled.displayName, 'Cancelled');
    });
  });

  group('TaskPriority', () {
    test('should have correct JSON values', () {
      expect(TaskPriority.low.name, 'low');
      expect(TaskPriority.medium.name, 'medium');
      expect(TaskPriority.high.name, 'high');
      expect(TaskPriority.urgent.name, 'urgent');
    });

    test('should return correct sort values', () {
      expect(TaskPriority.low.sortValue, 1);
      expect(TaskPriority.medium.sortValue, 2);
      expect(TaskPriority.high.sortValue, 3);
      expect(TaskPriority.urgent.sortValue, 4);
    });

    test('should return correct display names', () {
      expect(TaskPriority.low.displayName, 'Low');
      expect(TaskPriority.medium.displayName, 'Medium');
      expect(TaskPriority.high.displayName, 'High');
      expect(TaskPriority.urgent.displayName, 'Urgent');
    });

    test('should correctly identify high priority', () {
      expect(TaskPriority.low.isHighPriority, isFalse);
      expect(TaskPriority.medium.isHighPriority, isFalse);
      expect(TaskPriority.high.isHighPriority, isTrue);
      expect(TaskPriority.urgent.isHighPriority, isTrue);
    });
  });

  group('RecurrenceType', () {
    test('should have correct JSON values', () {
      expect(RecurrenceType.none.name, 'none');
      expect(RecurrenceType.daily.name, 'daily');
      expect(RecurrenceType.weekly.name, 'weekly');
      expect(RecurrenceType.monthly.name, 'monthly');
      expect(RecurrenceType.yearly.name, 'yearly');
      expect(RecurrenceType.custom.name, 'custom');
    });

    test('should return correct display names', () {
      expect(RecurrenceType.none.displayName, 'No Recurrence');
      expect(RecurrenceType.daily.displayName, 'Daily');
      expect(RecurrenceType.weekly.displayName, 'Weekly');
      expect(RecurrenceType.monthly.displayName, 'Monthly');
      expect(RecurrenceType.yearly.displayName, 'Yearly');
      expect(RecurrenceType.custom.displayName, 'Custom');
    });
  });
}