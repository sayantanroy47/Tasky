import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:task_tracker_app/services/task/recurring_task_service.dart';
import 'package:task_tracker_app/data/repositories/task_repository_impl.dart';
import 'package:task_tracker_app/services/database/database.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/task_enums.dart';
import 'package:task_tracker_app/domain/entities/recurrence_pattern.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Recurring Task Flow Integration Tests', () {
    late AppDatabase database;
    late TaskRepositoryImpl repository;
    late RecurringTaskService recurringService;
    
    setUp(() async {
      database = AppDatabase.forTesting(testExecutor);
      repository = TaskRepositoryImpl(database);
      recurringService = RecurringTaskService(repository, database);
    });

    tearDown(() async {
      await database.clearAllData();
      await database.close();
    });

    test('daily recurring task creation and instances', () async {
      // Create a daily recurring task
      final dailyTask = TaskModel.create(
        title: 'Daily Standup Meeting',
        description: 'Daily team standup at 9 AM',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        recurrence: const RecurrencePattern(
          type: RecurrenceType.daily,
          interval: 1,
        ),
      );

      await repository.createTask(dailyTask);

      // Generate future instances
      final futureInstances = await recurringService.generateFutureInstances(dailyTask, 5);
      
      expect(futureInstances.length, equals(5));
      
      // Verify each instance has correct due date
      for (int i = 0; i < futureInstances.length; i++) {
        final instance = futureInstances[i];
        final expectedDueDate = dailyTask.dueDate!.add(Duration(days: i + 1));
        
        expect(instance.title, equals(dailyTask.title));
        expect(instance.dueDate?.day, equals(expectedDueDate.day));
        expect(instance.metadata['original_task_id'], equals(dailyTask.id));
      }

      // Create the instances in database
      final createdInstances = await recurringService.createFutureInstances(dailyTask, 3);
      expect(createdInstances.length, equals(3));
      
      // Verify they exist in database
      final allTasks = await repository.getAllTasks();
      expect(allTasks.length, equals(4)); // Original + 3 instances
    });

    test('weekly recurring task with specific days', () async {
      // Create weekly task for Monday, Wednesday, Friday
      final weeklyTask = TaskModel.create(
        title: 'Gym Workout',
        dueDate: _getNextWeekday(DateTime.monday), // Next Monday
        recurrence: const RecurrencePattern(
          type: RecurrenceType.weekly,
          interval: 1,
          daysOfWeek: [1, 3, 5], // Monday, Wednesday, Friday
        ),
      );

      await repository.createTask(weeklyTask);

      // Generate instances for next 2 weeks
      final instances = await recurringService.generateFutureInstances(weeklyTask, 6);
      
      expect(instances.length, equals(6)); // 3 days × 2 weeks
      
      // Verify correct days of week
      for (final instance in instances) {
        final weekday = instance.dueDate!.weekday;
        expect([1, 3, 5], contains(weekday)); // Mon, Wed, Fri
      }
    });

    test('monthly recurring task', () async {
      final now = DateTime.now();
      final monthlyTask = TaskModel.create(
        title: 'Monthly Report',
        dueDate: DateTime(now.year, now.month, 15), // 15th of current month
        recurrence: const RecurrencePattern(
          type: RecurrenceType.monthly,
          interval: 1,
        ),
      );

      await repository.createTask(monthlyTask);

      // Generate next 6 months
      final instances = await recurringService.generateFutureInstances(monthlyTask, 6);
      
      expect(instances.length, equals(6));
      
      // Verify each instance is on the 15th of successive months
      for (int i = 0; i < instances.length; i++) {
        final instance = instances[i];
        expect(instance.dueDate!.day, equals(15));
        
        // Verify month progression
        final expectedMonth = (now.month + i + 1) % 12;
        final actualMonth = instance.dueDate!.month;
        expect(actualMonth == expectedMonth || (expectedMonth == 0 && actualMonth == 12), isTrue);
      }
    });

    test('yearly recurring task', () async {
      final birthday = DateTime(DateTime.now().year, 6, 15); // June 15th
      final yearlyTask = TaskModel.create(
        title: 'Birthday Reminder',
        dueDate: birthday,
        recurrence: const RecurrencePattern(
          type: RecurrenceType.yearly,
          interval: 1,
        ),
      );

      await repository.createTask(yearlyTask);

      // Generate next 3 years
      final instances = await recurringService.generateFutureInstances(yearlyTask, 3);
      
      expect(instances.length, equals(3));
      
      // Verify each instance is same day/month, different year
      for (int i = 0; i < instances.length; i++) {
        final instance = instances[i];
        expect(instance.dueDate!.month, equals(6));
        expect(instance.dueDate!.day, equals(15));
        expect(instance.dueDate!.year, equals(birthday.year + i + 1));
      }
    });

    test('recurring task completion flow', () async {
      final dailyTask = TaskModel.create(
        title: 'Take Medication',
        dueDate: DateTime.now(),
        recurrence: const RecurrencePattern(
          type: RecurrenceType.daily,
          interval: 1,
        ),
      );

      await repository.createTask(dailyTask);

      // Mark task as completed
      final completedTask = dailyTask.markCompleted();
      await repository.updateTask(completedTask);

      // Process completed recurring tasks
      final newTasks = await recurringService.processCompletedRecurringTasks();
      
      expect(newTasks.length, equals(1));
      expect(newTasks[0].title, equals(dailyTask.title));
      expect(newTasks[0].status, equals(TaskStatus.pending));
      expect(newTasks[0].metadata['original_task_id'], equals(dailyTask.id));
      
      // Verify the new task exists in database
      final allTasks = await repository.getAllTasks();
      final pendingTasks = allTasks.where((t) => t.status == TaskStatus.pending).toList();
      expect(pendingTasks.length, equals(1));
    });

    test('recurring task with end date limit', () async {
      final endDate = DateTime.now().add(const Duration(days: 10));
      final limitedTask = TaskModel.create(
        title: 'Short-term Daily Task',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        recurrence: RecurrencePattern(
          type: RecurrenceType.daily,
          interval: 1,
          endDate: endDate,
        ),
      );

      await repository.createTask(limitedTask);

      // Try to generate 20 instances (should be limited by end date)
      final instances = await recurringService.generateFutureInstances(limitedTask, 20);
      
      // Should only generate instances up to the end date
      expect(instances.length, lessThanOrEqualTo(10));
      
      for (final instance in instances) {
        expect(instance.dueDate!.isBefore(endDate) || instance.dueDate!.isAtSameMomentAs(endDate), isTrue);
      }
    });

    test('recurring task with max occurrences limit', () async {
      final limitedTask = TaskModel.create(
        title: 'Limited Occurrence Task',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        recurrence: const RecurrencePattern(
          type: RecurrenceType.daily,
          interval: 1,
          maxOccurrences: 5,
        ),
      );

      await repository.createTask(limitedTask);

      // Generate instances and count total occurrences
      await recurringService.createFutureInstances(limitedTask, 3);
      
      // Complete the original task multiple times to test limit
      var currentTask = limitedTask.markCompleted();
      await repository.updateTask(currentTask);
      await recurringService.processCompletedRecurringTasks();

      // Check that we haven't exceeded the limit
      final allTasks = await repository.getAllTasks();
      final recurringInstances = allTasks.where((task) => 
        task.title == limitedTask.title || 
        task.metadata['original_task_id'] == limitedTask.id
      ).toList();
      
      expect(recurringInstances.length, lessThanOrEqualTo(5));
    });

    test('updating recurring task pattern', () async {
      final originalTask = TaskModel.create(
        title: 'Task with Changing Pattern',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        recurrence: const RecurrencePattern(
          type: RecurrenceType.daily,
          interval: 1,
        ),
      );

      await repository.createTask(originalTask);
      
      // Create some future instances
      await recurringService.createFutureInstances(originalTask, 3);

      // Update the recurrence pattern to weekly
      const newPattern = RecurrencePattern(
        type: RecurrenceType.weekly,
        interval: 1,
        daysOfWeek: [1, 5], // Monday and Friday
      );

      await recurringService.updateRecurringTaskPattern(
        originalTask,
        newPattern,
        updateFutureInstances: true,
      );

      // Verify the original task was updated
      final updatedOriginal = await repository.getTaskById(originalTask.id);
      expect(updatedOriginal?.recurrence?.type, equals(RecurrenceType.weekly));
      
      // Verify future instances were updated
      final futureInstances = await recurringService.getFutureRecurringInstances(originalTask);
      for (final instance in futureInstances) {
        expect(instance.recurrence?.type, equals(RecurrenceType.weekly));
      }
    });

    test('stopping recurring task series', () async {
      final recurringTask = TaskModel.create(
        title: 'Task to be Stopped',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        recurrence: const RecurrencePattern(
          type: RecurrenceType.daily,
          interval: 1,
        ),
      );

      await repository.createTask(recurringTask);
      await recurringService.createFutureInstances(recurringTask, 5);

      // Stop the recurring series
      await recurringService.stopRecurringTaskSeries(recurringTask);

      // Verify original task no longer has recurrence
      final updatedTask = await repository.getTaskById(recurringTask.id);
      expect(updatedTask?.recurrence?.type, equals(RecurrenceType.none));

      // Future instances should still exist but not generate new ones
      final futureInstances = await recurringService.getFutureRecurringInstances(recurringTask);
      expect(futureInstances.isNotEmpty, isTrue);
    });

    test('deleting future recurring instances', () async {
      final recurringTask = TaskModel.create(
        title: 'Task with Future Deletion',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        recurrence: const RecurrencePattern(
          type: RecurrenceType.daily,
          interval: 1,
        ),
      );

      await repository.createTask(recurringTask);
      await recurringService.createFutureInstances(recurringTask, 5);

      // Verify instances were created
      var futureInstances = await recurringService.getFutureRecurringInstances(recurringTask);
      expect(futureInstances.length, equals(5));

      // Delete future instances
      await recurringService.deleteFutureRecurringInstances(recurringTask);

      // Verify instances were deleted
      futureInstances = await recurringService.getFutureRecurringInstances(recurringTask);
      expect(futureInstances.length, equals(0));

      // Original task should still exist
      final originalTask = await repository.getTaskById(recurringTask.id);
      expect(originalTask, isNotNull);
    });

    test('complex recurring pattern integration', () async {
      // Create a complex weekly task that occurs on specific days with custom intervals
      final complexTask = TaskModel.create(
        title: 'Bi-weekly Team Meeting',
        dueDate: _getNextWeekday(DateTime.tuesday),
        recurrence: const RecurrencePattern(
          type: RecurrenceType.weekly,
          interval: 2, // Every 2 weeks
          daysOfWeek: [2], // Tuesday only
        ),
      );

      await repository.createTask(complexTask);

      // Generate instances for next 2 months
      final instances = await recurringService.generateFutureInstances(complexTask, 4);
      
      expect(instances.length, equals(4));
      
      // Verify instances are exactly 2 weeks apart and on Tuesday
      DateTime? lastDate;
      for (final instance in instances) {
        expect(instance.dueDate!.weekday, equals(DateTime.tuesday));
        
        if (lastDate != null) {
          final daysDifference = instance.dueDate!.difference(lastDate).inDays;
          expect(daysDifference, equals(14)); // Exactly 2 weeks
        }
        
        lastDate = instance.dueDate;
      }
    });

    test('performance with large numbers of recurring tasks', () async {
      final stopwatch = Stopwatch()..start();
      
      // Create 20 different recurring tasks
      final recurringTasks = <TaskModel>[];
      for (int i = 0; i < 20; i++) {
        final task = TaskModel.create(
          title: 'Performance Test Task $i',
          dueDate: DateTime.now().add(Duration(days: i % 7)),
          recurrence: RecurrencePattern(
            type: [RecurrenceType.daily, RecurrenceType.weekly, RecurrenceType.monthly][i % 3],
            interval: 1,
          ),
        );
        
        recurringTasks.add(task);
        await repository.createTask(task);
      }
      
      // Generate instances for each
      for (final task in recurringTasks) {
        await recurringService.createFutureInstances(task, 3);
      }
      
      stopwatch.stop();
      
      print('Performance test completed in ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // Should complete in < 5 seconds
      
      // Verify all tasks and instances were created
      final allTasks = await repository.getAllTasks();
      expect(allTasks.length, equals(80)); // 20 original + (20 × 3 instances)
    });
  });

  group('Recurring Task Edge Cases', () {
    late AppDatabase database;
    late TaskRepositoryImpl repository;
    late RecurringTaskService recurringService;
    
    setUp(() async {
      database = AppDatabase.forTesting(testExecutor);
      repository = TaskRepositoryImpl(database);
      recurringService = RecurringTaskService(repository, database);
    });

    tearDown(() async {
      await database.clearAllData();
      await database.close();
    });

    test('leap year handling for yearly recurring tasks', () async {
      // Create task for Feb 29 on a leap year
      final leapYearTask = TaskModel.create(
        title: 'Leap Year Task',
        dueDate: DateTime(2024, 2, 29), // Feb 29, 2024 (leap year)
        recurrence: const RecurrencePattern(
          type: RecurrenceType.yearly,
          interval: 1,
        ),
      );

      await repository.createTask(leapYearTask);

      // Generate next few years
      final instances = await recurringService.generateFutureInstances(leapYearTask, 5);
      
      expect(instances.length, equals(5));
      
      // Check how non-leap years are handled (should probably use Feb 28)
      for (final instance in instances) {
        expect(instance.dueDate!.month, equals(2));
        expect(instance.dueDate!.day, anyOf([28, 29])); // Either Feb 28 or 29
      }
    });

    test('timezone handling for recurring tasks', () async {
      // This test would be more relevant if timezone support was implemented
      final task = TaskModel.create(
        title: 'Timezone Test Task',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        recurrence: const RecurrencePattern(
          type: RecurrenceType.daily,
          interval: 1,
        ),
      );

      await repository.createTask(task);
      
      final instances = await recurringService.generateFutureInstances(task, 3);
      
      // Verify instances maintain consistent timing
      for (int i = 0; i < instances.length - 1; i++) {
        final timeDifference = instances[i + 1].dueDate!.difference(instances[i].dueDate!);
        expect(timeDifference.inDays, equals(1));
        expect(timeDifference.inHours % 24, equals(0)); // Should be exactly 24-hour intervals
      }
    });

    test('month boundary edge cases', () async {
      // Test monthly recurrence at month boundaries
      final monthEndTask = TaskModel.create(
        title: 'Month End Task',
        dueDate: DateTime(2024, 1, 31), // Jan 31
        recurrence: const RecurrencePattern(
          type: RecurrenceType.monthly,
          interval: 1,
        ),
      );

      await repository.createTask(monthEndTask);

      final instances = await recurringService.generateFutureInstances(monthEndTask, 12);
      
      // Check how months with fewer days are handled
      for (final instance in instances) {
        // February instance should handle the fact that Feb doesn't have 31 days
        if (instance.dueDate!.month == 2) {
          expect(instance.dueDate!.day, anyOf([28, 29])); // Last day of February
        }
        
        // April, June, September, November don't have 31 days
        if ([4, 6, 9, 11].contains(instance.dueDate!.month)) {
          expect(instance.dueDate!.day, equals(30)); // Should be adjusted to 30
        }
      }
    });
  });
}

/// Helper function to get next occurrence of a specific weekday
DateTime _getNextWeekday(int weekday) {
  final now = DateTime.now();
  final daysUntilWeekday = (weekday - now.weekday + 7) % 7;
  return now.add(Duration(days: daysUntilWeekday == 0 ? 7 : daysUntilWeekday));
}

// Mock test executor for testing
final testExecutor = null; // Placeholder - would be actual test database executor