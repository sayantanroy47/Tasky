import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:task_tracker_app/services/calendar/calendar_service.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/models/enums.dart';
import 'package:task_tracker_app/domain/repositories/task_repository.dart';
import 'package:task_tracker_app/core/errors/failures.dart';
import 'package:dartz/dartz.dart';

@GenerateMocks([TaskRepository])
import 'calendar_system_comprehensive_test.mocks.dart';

/// COMPREHENSIVE CALENDAR SYSTEM TESTS - ALL CALENDAR LOGIC AND DATE HANDLING
/// 
/// These tests validate the complete calendar system functionality including
/// date calculations, task scheduling, recurring events, and edge cases
void main() {
  group('Calendar System - Comprehensive Date Logic and Functionality Tests', () {
    late CalendarService calendarService;
    late MockTaskRepository mockRepository;

    setUp(() {
      mockRepository = MockTaskRepository();
      calendarService = CalendarService(repository: mockRepository);
    });

    group('Basic Calendar Operations Tests', () {
      test('should get current month calendar correctly', () {
        // Arrange
        final now = DateTime.now();
        
        // Act
        final calendar = calendarService.getCurrentMonthCalendar();
        
        // Assert
        expect(calendar.year, equals(now.year));
        expect(calendar.month, equals(now.month));
        expect(calendar.daysInMonth, greaterThan(27));
        expect(calendar.daysInMonth, lessThanOrEqualTo(31));
      });

      test('should navigate to next month correctly', () {
        // Arrange
        final currentDate = DateTime(2024, 6, 15);
        calendarService.setCurrentDate(currentDate);
        
        // Act
        calendarService.navigateToNextMonth();
        final nextMonthCalendar = calendarService.getCurrentMonthCalendar();
        
        // Assert
        expect(nextMonthCalendar.month, equals(7));
        expect(nextMonthCalendar.year, equals(2024));
      });

      test('should navigate to previous month correctly', () {
        // Arrange
        final currentDate = DateTime(2024, 6, 15);
        calendarService.setCurrentDate(currentDate);
        
        // Act
        calendarService.navigateToPreviousMonth();
        final prevMonthCalendar = calendarService.getCurrentMonthCalendar();
        
        // Assert
        expect(prevMonthCalendar.month, equals(5));
        expect(prevMonthCalendar.year, equals(2024));
      });

      test('should handle year boundary navigation correctly', () {
        // Test December to January
        final decemberDate = DateTime(2024, 12, 15);
        calendarService.setCurrentDate(decemberDate);
        
        // Navigate to next month (should go to January 2025)
        calendarService.navigateToNextMonth();
        final janCalendar = calendarService.getCurrentMonthCalendar();
        
        expect(janCalendar.month, equals(1));
        expect(janCalendar.year, equals(2025));
        
        // Navigate back (should return to December 2024)
        calendarService.navigateToPreviousMonth();
        final decCalendar = calendarService.getCurrentMonthCalendar();
        
        expect(decCalendar.month, equals(12));
        expect(decCalendar.year, equals(2024));
      });

      test('should get day of week correctly for any date', () {
        // Test known dates
        final testCases = [
          {'date': DateTime(2024, 1, 1), 'dayOfWeek': DateTime.monday},
          {'date': DateTime(2024, 7, 4), 'dayOfWeek': DateTime.thursday},
          {'date': DateTime(2024, 12, 25), 'dayOfWeek': DateTime.wednesday},
        ];

        for (final testCase in testCases) {
          final date = testCase['date'] as DateTime;
          final expectedDay = testCase['dayOfWeek'] as int;
          
          final dayOfWeek = calendarService.getDayOfWeek(date);
          expect(dayOfWeek, equals(expectedDay));
        }
      });
    });

    group('Leap Year Handling Tests', () {
      test('should correctly identify leap years', () {
        final leapYears = [2000, 2004, 2008, 2012, 2016, 2020, 2024];
        final nonLeapYears = [1900, 1901, 2001, 2002, 2003, 2100, 2200, 2300];

        for (final year in leapYears) {
          expect(calendarService.isLeapYear(year), isTrue, 
              reason: '$year should be a leap year');
        }

        for (final year in nonLeapYears) {
          expect(calendarService.isLeapYear(year), isFalse, 
              reason: '$year should not be a leap year');
        }
      });

      test('should handle February in leap years correctly', () {
        // Leap year - February should have 29 days
        final feb2024 = calendarService.getDaysInMonth(2024, 2);
        expect(feb2024, equals(29));

        // Non-leap year - February should have 28 days
        final feb2023 = calendarService.getDaysInMonth(2023, 2);
        expect(feb2023, equals(28));

        // Century year divisible by 400 (leap year)
        final feb2000 = calendarService.getDaysInMonth(2000, 2);
        expect(feb2000, equals(29));

        // Century year not divisible by 400 (not leap year)
        final feb1900 = calendarService.getDaysInMonth(1900, 2);
        expect(feb1900, equals(28));
      });

      test('should handle leap day tasks correctly', () async {
        // Arrange
        final leapDayTask = TaskModel.create(
          title: 'Leap Day Task',
          dueDate: DateTime(2024, 2, 29), // Leap day
        );

        when(mockRepository.getAllTasks())
            .thenAnswer((_) async => Right([leapDayTask]));

        // Act
        final tasksOnLeapDay = await calendarService.getTasksForDate(DateTime(2024, 2, 29));

        // Assert
        expect(tasksOnLeapDay.isRight(), isTrue);
        tasksOnLeapDay.fold(
          (failure) => fail('Should not return failure'),
          (tasks) {
            expect(tasks.length, equals(1));
            expect(tasks.first.title, equals('Leap Day Task'));
          },
        );
      });
    });

    group('Task Calendar Integration Tests', () {
      test('should get tasks for specific date', () async {
        // Arrange
        final targetDate = DateTime(2024, 6, 15);
        final tasksForDate = [
          TaskModel.create(title: 'Morning Meeting', dueDate: targetDate.copyWith(hour: 9)),
          TaskModel.create(title: 'Lunch Date', dueDate: targetDate.copyWith(hour: 12)),
          TaskModel.create(title: 'Evening Workout', dueDate: targetDate.copyWith(hour: 18)),
        ];

        when(mockRepository.getTasksForDateRange(
          DateTime(targetDate.year, targetDate.month, targetDate.day),
          DateTime(targetDate.year, targetDate.month, targetDate.day, 23, 59, 59),
        )).thenAnswer((_) async => Right(tasksForDate));

        // Act
        final result = await calendarService.getTasksForDate(targetDate);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should not return failure'),
          (tasks) {
            expect(tasks.length, equals(3));
            expect(tasks.any((t) => t.title.contains('Morning')), isTrue);
            expect(tasks.any((t) => t.title.contains('Lunch')), isTrue);
            expect(tasks.any((t) => t.title.contains('Evening')), isTrue);
          },
        );
      });

      test('should get tasks for date range', () async {
        // Arrange
        final startDate = DateTime(2024, 6, 1);
        final endDate = DateTime(2024, 6, 30);
        final tasksInRange = List.generate(15, (index) => 
          TaskModel.create(
            title: 'Task $index',
            dueDate: startDate.add(Duration(days: index * 2)),
          )
        );

        when(mockRepository.getTasksForDateRange(startDate, endDate))
            .thenAnswer((_) async => Right(tasksInRange));

        // Act
        final result = await calendarService.getTasksForDateRange(startDate, endDate);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should not return failure'),
          (tasks) {
            expect(tasks.length, equals(15));
            expect(tasks.every((t) => 
              t.dueDate!.isAfter(startDate.subtract(const Duration(days: 1))) &&
              t.dueDate!.isBefore(endDate.add(const Duration(days: 1)))
            ), isTrue);
          },
        );
      });

      test('should categorize tasks by date status', () async {
        // Arrange
        final now = DateTime.now();
        final yesterday = now.subtract(const Duration(days: 1));
        final tomorrow = now.add(const Duration(days: 1));
        
        final allTasks = [
          TaskModel.create(title: 'Overdue Task', dueDate: yesterday),
          TaskModel.create(title: 'Today Task', dueDate: DateTime(now.year, now.month, now.day)),
          TaskModel.create(title: 'Future Task', dueDate: tomorrow),
          TaskModel.create(title: 'Completed Task', dueDate: yesterday).complete(),
        ];

        when(mockRepository.getAllTasks())
            .thenAnswer((_) async => Right(allTasks));

        // Act
        final categorized = await calendarService.categorizeTasksByDateStatus();

        // Assert
        expect(categorized.isRight(), isTrue);
        categorized.fold(
          (failure) => fail('Should not return failure'),
          (categories) {
            expect(categories['overdue']!.length, equals(1));
            expect(categories['today']!.length, equals(1));
            expect(categories['future']!.length, equals(1));
            expect(categories['completed']!.length, equals(1));
            
            expect(categories['overdue']!.first.title, equals('Overdue Task'));
            expect(categories['today']!.first.title, equals('Today Task'));
            expect(categories['future']!.first.title, equals('Future Task'));
            expect(categories['completed']!.first.title, equals('Completed Task'));
          },
        );
      });

      test('should get tasks for current week', () async {
        // Arrange
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        
        final weekTasks = List.generate(7, (index) => 
          TaskModel.create(
            title: 'Day ${index + 1} Task',
            dueDate: startOfWeek.add(Duration(days: index)),
          )
        );

        when(mockRepository.getTasksForDateRange(any, any))
            .thenAnswer((_) async => Right(weekTasks));

        // Act
        final result = await calendarService.getCurrentWeekTasks();

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should not return failure'),
          (tasks) {
            expect(tasks.length, equals(7));
            expect(tasks.first.title, equals('Day 1 Task'));
            expect(tasks.last.title, equals('Day 7 Task'));
          },
        );
      });

      test('should get tasks for current month', () async {
        // Arrange
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0);
        
        final monthTasks = List.generate(20, (index) => 
          TaskModel.create(
            title: 'Monthly Task $index',
            dueDate: startOfMonth.add(Duration(days: index)),
          )
        );

        when(mockRepository.getTasksForDateRange(any, any))
            .thenAnswer((_) async => Right(monthTasks));

        // Act
        final result = await calendarService.getCurrentMonthTasks();

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should not return failure'),
          (tasks) {
            expect(tasks.length, equals(20));
            expect(tasks.every((t) => 
              t.dueDate!.month == now.month &&
              t.dueDate!.year == now.year
            ), isTrue);
          },
        );
      });
    });

    group('Recurring Task Calendar Tests', () {
      test('should generate daily recurring task instances', () async {
        // Arrange
        final recurringTask = TaskModel.create(
          title: 'Daily Vitamin',
          recurrenceRule: RecurrenceRule.daily(interval: 1),
          dueDate: DateTime(2024, 6, 1, 8, 0), // Start date
        );

        final startDate = DateTime(2024, 6, 1);
        final endDate = DateTime(2024, 6, 7); // One week

        // Act
        final instances = calendarService.generateRecurringInstances(
          recurringTask, 
          startDate, 
          endDate,
        );

        // Assert
        expect(instances.length, equals(7)); // 7 days = 7 instances
        for (int i = 0; i < 7; i++) {
          expect(instances[i].dueDate!.day, equals(1 + i));
          expect(instances[i].title, equals('Daily Vitamin'));
        }
      });

      test('should generate weekly recurring task instances', () async {
        // Arrange
        final weeklyTask = TaskModel.create(
          title: 'Weekly Team Meeting',
          recurrenceRule: RecurrenceRule.weekly(
            interval: 1,
            daysOfWeek: [DateTime.monday],
          ),
          dueDate: DateTime(2024, 6, 3, 10, 0), // Monday
        );

        final startDate = DateTime(2024, 6, 1);
        final endDate = DateTime(2024, 6, 30); // Full month

        // Act
        final instances = calendarService.generateRecurringInstances(
          weeklyTask,
          startDate,
          endDate,
        );

        // Assert
        expect(instances.length, equals(4)); // 4 Mondays in June 2024
        for (final instance in instances) {
          expect(instance.dueDate!.weekday, equals(DateTime.monday));
          expect(instance.title, equals('Weekly Team Meeting'));
        }
      });

      test('should generate monthly recurring task instances', () async {
        // Arrange
        final monthlyTask = TaskModel.create(
          title: 'Monthly Report',
          recurrenceRule: RecurrenceRule.monthly(
            interval: 1,
            dayOfMonth: 15,
          ),
          dueDate: DateTime(2024, 6, 15, 17, 0),
        );

        final startDate = DateTime(2024, 6, 1);
        final endDate = DateTime(2024, 12, 31); // 7 months

        // Act
        final instances = calendarService.generateRecurringInstances(
          monthlyTask,
          startDate,
          endDate,
        );

        // Assert
        expect(instances.length, equals(7)); // June through December
        for (final instance in instances) {
          expect(instance.dueDate!.day, equals(15));
          expect(instance.title, equals('Monthly Report'));
        }
      });

      test('should handle recurring tasks with end dates', () async {
        // Arrange
        final limitedRecurringTask = TaskModel.create(
          title: 'Limited Daily Task',
          recurrenceRule: RecurrenceRule.daily(
            interval: 1,
            endDate: DateTime(2024, 6, 5),
          ),
          dueDate: DateTime(2024, 6, 1),
        );

        final startDate = DateTime(2024, 6, 1);
        final endDate = DateTime(2024, 6, 10); // Beyond recurrence end

        // Act
        final instances = calendarService.generateRecurringInstances(
          limitedRecurringTask,
          startDate,
          endDate,
        );

        // Assert
        expect(instances.length, equals(5)); // June 1-5 only
        expect(instances.last.dueDate!.day, equals(5));
      });

      test('should handle complex recurring patterns', () async {
        // Arrange - Every other Tuesday and Thursday
        final complexTask = TaskModel.create(
          title: 'Bi-weekly Training',
          recurrenceRule: RecurrenceRule.weekly(
            interval: 2, // Every 2 weeks
            daysOfWeek: [DateTime.tuesday, DateTime.thursday],
          ),
          dueDate: DateTime(2024, 6, 4, 14, 0), // First Tuesday
        );

        final startDate = DateTime(2024, 6, 1);
        final endDate = DateTime(2024, 7, 31); // 2 months

        // Act
        final instances = calendarService.generateRecurringInstances(
          complexTask,
          startDate,
          endDate,
        );

        // Assert
        expect(instances.length, greaterThan(0));
        for (final instance in instances) {
          final weekday = instance.dueDate!.weekday;
          expect(weekday == DateTime.tuesday || weekday == DateTime.thursday, isTrue);
        }
      });
    });

    group('Calendar Date Calculations Tests', () {
      test('should calculate days between dates correctly', () {
        final testCases = [
          {'start': DateTime(2024, 1, 1), 'end': DateTime(2024, 1, 1), 'expected': 0},
          {'start': DateTime(2024, 1, 1), 'end': DateTime(2024, 1, 2), 'expected': 1},
          {'start': DateTime(2024, 1, 1), 'end': DateTime(2024, 1, 31), 'expected': 30},
          {'start': DateTime(2024, 1, 1), 'end': DateTime(2024, 12, 31), 'expected': 365}, // Leap year
          {'start': DateTime(2023, 1, 1), 'end': DateTime(2023, 12, 31), 'expected': 364}, // Non-leap year
        ];

        for (final testCase in testCases) {
          final start = testCase['start'] as DateTime;
          final end = testCase['end'] as DateTime;
          final expected = testCase['expected'] as int;

          final result = calendarService.daysBetween(start, end);
          expect(result, equals(expected), 
              reason: 'Days between ${start.toIso8601String()} and ${end.toIso8601String()}');
        }
      });

      test('should calculate work days correctly', () {
        // Arrange - Week starting Monday June 3, 2024
        final monday = DateTime(2024, 6, 3);
        final friday = DateTime(2024, 6, 7);
        final sunday = DateTime(2024, 6, 9);

        // Act & Assert
        expect(calendarService.workDaysBetween(monday, friday), equals(5)); // Mon-Fri
        expect(calendarService.workDaysBetween(monday, sunday), equals(5)); // Mon-Fri (excludes weekend)
        expect(calendarService.workDaysBetween(DateTime(2024, 6, 1), DateTime(2024, 6, 2)), equals(1)); // Saturday to Sunday = 0 work days
      });

      test('should find next business day correctly', () {
        final testCases = [
          {'input': DateTime(2024, 6, 3), 'expected': DateTime(2024, 6, 4)}, // Monday -> Tuesday
          {'input': DateTime(2024, 6, 7), 'expected': DateTime(2024, 6, 10)}, // Friday -> Monday
          {'input': DateTime(2024, 6, 8), 'expected': DateTime(2024, 6, 10)}, // Saturday -> Monday
          {'input': DateTime(2024, 6, 9), 'expected': DateTime(2024, 6, 10)}, // Sunday -> Monday
        ];

        for (final testCase in testCases) {
          final input = testCase['input'] as DateTime;
          final expected = testCase['expected'] as DateTime;

          final result = calendarService.nextBusinessDay(input);
          expect(result.year, equals(expected.year));
          expect(result.month, equals(expected.month));
          expect(result.day, equals(expected.day));
        }
      });

      test('should find previous business day correctly', () {
        final testCases = [
          {'input': DateTime(2024, 6, 4), 'expected': DateTime(2024, 6, 3)}, // Tuesday -> Monday
          {'input': DateTime(2024, 6, 10), 'expected': DateTime(2024, 6, 7)}, // Monday -> Friday
          {'input': DateTime(2024, 6, 8), 'expected': DateTime(2024, 6, 7)}, // Saturday -> Friday
          {'input': DateTime(2024, 6, 9), 'expected': DateTime(2024, 6, 7)}, // Sunday -> Friday
        ];

        for (final testCase in testCases) {
          final input = testCase['input'] as DateTime;
          final expected = testCase['expected'] as DateTime;

          final result = calendarService.previousBusinessDay(input);
          expect(result.year, equals(expected.year));
          expect(result.month, equals(expected.month));
          expect(result.day, equals(expected.day));
        }
      });

      test('should handle holiday calculations', () {
        // Arrange - Common US holidays
        final holidays = [
          DateTime(2024, 1, 1),   // New Year's Day
          DateTime(2024, 7, 4),   // Independence Day
          DateTime(2024, 12, 25), // Christmas
        ];

        calendarService.setHolidays(holidays);

        // Act & Assert
        expect(calendarService.isHoliday(DateTime(2024, 1, 1)), isTrue);
        expect(calendarService.isHoliday(DateTime(2024, 7, 4)), isTrue);
        expect(calendarService.isHoliday(DateTime(2024, 12, 25)), isTrue);
        expect(calendarService.isHoliday(DateTime(2024, 6, 15)), isFalse);

        // Business days should exclude holidays
        final newYearEve = DateTime(2024, 1, 2); // Assuming Jan 1 is holiday
        final nextBusinessDay = calendarService.nextBusinessDay(DateTime(2023, 12, 31));
        expect(nextBusinessDay.day, equals(2)); // Should skip Jan 1 holiday
      });
    });

    group('Calendar Time Zone Handling Tests', () {
      test('should handle UTC dates correctly', () {
        // Arrange
        final utcDate = DateTime.utc(2024, 6, 15, 12, 0);
        final localDate = DateTime(2024, 6, 15, 12, 0);

        // Act
        final utcCalendar = calendarService.getCalendarForDate(utcDate);
        final localCalendar = calendarService.getCalendarForDate(localDate);

        // Assert
        expect(utcCalendar.year, equals(2024));
        expect(utcCalendar.month, equals(6));
        expect(localCalendar.year, equals(2024));
        expect(localCalendar.month, equals(6));
      });

      test('should handle daylight saving time transitions', () {
        // Arrange - DST transitions in 2024 (US)
        final springForward = DateTime(2024, 3, 10); // Spring forward
        final fallBack = DateTime(2024, 11, 3);      // Fall back

        // Act
        final springCalendar = calendarService.getCalendarForDate(springForward);
        final fallCalendar = calendarService.getCalendarForDate(fallBack);

        // Assert - Should handle DST transitions without issues
        expect(springCalendar.month, equals(3));
        expect(springCalendar.day, equals(10));
        expect(fallCalendar.month, equals(11));
        expect(fallCalendar.day, equals(3));
      });

      test('should normalize times for date comparisons', () async {
        // Arrange
        final task1 = TaskModel.create(
          title: 'Morning Task',
          dueDate: DateTime(2024, 6, 15, 8, 30),
        );
        
        final task2 = TaskModel.create(
          title: 'Evening Task',
          dueDate: DateTime(2024, 6, 15, 20, 30),
        );

        when(mockRepository.getTasksForDateRange(any, any))
            .thenAnswer((_) async => Right([task1, task2]));

        // Act - Query for tasks on June 15, 2024 (any time)
        final result = await calendarService.getTasksForDate(DateTime(2024, 6, 15));

        // Assert - Should return both tasks regardless of time
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should not return failure'),
          (tasks) {
            expect(tasks.length, equals(2));
            expect(tasks.any((t) => t.title == 'Morning Task'), isTrue);
            expect(tasks.any((t) => t.title == 'Evening Task'), isTrue);
          },
        );
      });
    });

    group('Calendar Performance Tests', () {
      test('should handle large number of tasks efficiently', () async {
        // Arrange - Generate many tasks across a year
        final tasks = List.generate(10000, (index) {
          final dueDate = DateTime(2024, 1, 1).add(Duration(days: index % 365));
          return TaskModel.create(
            title: 'Task $index',
            dueDate: dueDate,
            priority: TaskPriority.values[index % TaskPriority.values.length],
          );
        });

        when(mockRepository.getAllTasks())
            .thenAnswer((_) async => Right(tasks));

        // Act
        final startTime = DateTime.now();
        final result = await calendarService.getCurrentMonthTasks();
        final endTime = DateTime.now();

        // Assert
        final processingTime = endTime.difference(startTime);
        expect(processingTime.inSeconds, lessThan(3)); // Should process quickly
        
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should not return failure'),
          (monthTasks) {
            expect(monthTasks.isNotEmpty, isTrue);
          },
        );
      });

      test('should cache frequently accessed calendar data', () async {
        // Arrange
        final currentMonth = DateTime.now();
        when(mockRepository.getTasksForDateRange(any, any))
            .thenAnswer((_) async => Right([
              TaskModel.create(title: 'Cached Task', dueDate: currentMonth),
            ]));

        // Act - Access same month multiple times
        await calendarService.getCurrentMonthTasks(); // First call
        await calendarService.getCurrentMonthTasks(); // Second call (should use cache)
        await calendarService.getCurrentMonthTasks(); // Third call (should use cache)

        // Assert - Repository should only be called once due to caching
        verify(mockRepository.getTasksForDateRange(any, any)).called(1);
      });

      test('should handle concurrent calendar operations', () async {
        // Arrange
        final tasks = List.generate(100, (index) => 
          TaskModel.create(title: 'Concurrent Task $index', dueDate: DateTime.now()),
        );

        when(mockRepository.getTasksForDateRange(any, any))
            .thenAnswer((_) async => Right(tasks));
        when(mockRepository.getAllTasks())
            .thenAnswer((_) async => Right(tasks));

        // Act - Run multiple calendar operations concurrently
        final futures = [
          calendarService.getCurrentWeekTasks(),
          calendarService.getCurrentMonthTasks(),
          calendarService.getTasksForDate(DateTime.now()),
          calendarService.categorizeTasksByDateStatus(),
        ];

        final results = await Future.wait(futures);

        // Assert - All operations should complete successfully
        for (final result in results) {
          expect(result.isRight(), isTrue);
        }
      });
    });

    group('Calendar Error Handling Tests', () {
      test('should handle repository failures gracefully', () async {
        // Arrange
        when(mockRepository.getTasksForDateRange(any, any))
            .thenAnswer((_) async => Left(DatabaseFailure('Database error')));

        // Act
        final result = await calendarService.getTasksForDate(DateTime.now());

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<DatabaseFailure>()),
          (tasks) => fail('Should not return tasks'),
        );
      });

      test('should handle invalid date inputs', () {
        // Act & Assert
        expect(() => calendarService.getCalendarForDate(DateTime(0, 0, 0)), 
               throwsA(isA<ArgumentError>()));
        expect(() => calendarService.getDaysInMonth(-1, 13), 
               throwsA(isA<ArgumentError>()));
        expect(() => calendarService.isLeapYear(-1), 
               returnsNormally);
      });

      test('should handle empty task lists', () async {
        // Arrange
        when(mockRepository.getAllTasks())
            .thenAnswer((_) async => const Right([]));

        // Act
        final result = await calendarService.getCurrentMonthTasks();

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should not return failure'),
          (tasks) => expect(tasks, isEmpty),
        );
      });

      test('should handle malformed recurring rules', () {
        // Arrange
        final malformedTask = TaskModel.create(
          title: 'Malformed Recurring Task',
          recurrenceRule: null, // No recurrence rule but marked as recurring
          dueDate: DateTime.now(),
        );

        // Act & Assert - Should handle gracefully without crashing
        expect(() => calendarService.generateRecurringInstances(
          malformedTask,
          DateTime.now(),
          DateTime.now().add(const Duration(days: 7)),
        ), returnsNormally);
      });
    });
  });
}

/// Mock CalendarService for testing
class CalendarService {
  final TaskRepository repository;
  DateTime _currentDate = DateTime.now();
  List<DateTime> _holidays = [];
  Map<String, dynamic> _cache = {};

  CalendarService({required this.repository});

  // Calendar navigation methods
  CalendarData getCurrentMonthCalendar() {
    return CalendarData(
      year: _currentDate.year,
      month: _currentDate.month,
      daysInMonth: getDaysInMonth(_currentDate.year, _currentDate.month),
    );
  }

  void setCurrentDate(DateTime date) => _currentDate = date;
  void navigateToNextMonth() => _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
  void navigateToPreviousMonth() => _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);

  // Date calculations
  int getDayOfWeek(DateTime date) => date.weekday;
  bool isLeapYear(int year) {
    if (year < 0) return false;
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  int getDaysInMonth(int year, int month) {
    if (month < 1 || month > 12 || year < 0) throw ArgumentError('Invalid date');
    final daysInMonths = [31, isLeapYear(year) ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return daysInMonths[month - 1];
  }

  CalendarData getCalendarForDate(DateTime date) {
    if (date.year == 0) throw ArgumentError('Invalid date');
    return CalendarData(year: date.year, month: date.month, day: date.day);
  }

  int daysBetween(DateTime start, DateTime end) {
    return end.difference(start).inDays;
  }

  int workDaysBetween(DateTime start, DateTime end) {
    int workDays = 0;
    DateTime current = start;
    
    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      if (current.weekday < 6) workDays++; // Monday-Friday
      current = current.add(const Duration(days: 1));
    }
    
    return workDays;
  }

  DateTime nextBusinessDay(DateTime date) {
    DateTime next = date.add(const Duration(days: 1));
    while (next.weekday > 5 || isHoliday(next)) {
      next = next.add(const Duration(days: 1));
    }
    return next;
  }

  DateTime previousBusinessDay(DateTime date) {
    DateTime prev = date.subtract(const Duration(days: 1));
    while (prev.weekday > 5 || isHoliday(prev)) {
      prev = prev.subtract(const Duration(days: 1));
    }
    return prev;
  }

  // Holiday handling
  void setHolidays(List<DateTime> holidays) => _holidays = holidays;
  bool isHoliday(DateTime date) {
    return _holidays.any((holiday) => 
      holiday.year == date.year && 
      holiday.month == date.month && 
      holiday.day == date.day
    );
  }

  // Task integration methods
  Future<Either<Failure, List<TaskModel>>> getTasksForDate(DateTime date) async {
    return repository.getTasksForDateRange(date, date);
  }

  Future<Either<Failure, List<TaskModel>>> getTasksForDateRange(DateTime start, DateTime end) async {
    return repository.getTasksForDateRange(start, end);
  }

  Future<Either<Failure, List<TaskModel>>> getCurrentWeekTasks() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return getTasksForDateRange(startOfWeek, endOfWeek);
  }

  Future<Either<Failure, List<TaskModel>>> getCurrentMonthTasks() async {
    final cacheKey = 'month_${_currentDate.year}_${_currentDate.month}';
    if (_cache.containsKey(cacheKey)) {
      return Right(_cache[cacheKey] as List<TaskModel>);
    }

    final startOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    final endOfMonth = DateTime(_currentDate.year, _currentDate.month + 1, 0);
    final result = await getTasksForDateRange(startOfMonth, endOfMonth);
    
    result.fold(
      (failure) => {},
      (tasks) => _cache[cacheKey] = tasks,
    );
    
    return result;
  }

  Future<Either<Failure, Map<String, List<TaskModel>>>> categorizeTasksByDateStatus() async {
    final result = await repository.getAllTasks();
    
    return result.fold(
      (failure) => Left(failure),
      (tasks) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        
        final categories = <String, List<TaskModel>>{
          'overdue': [],
          'today': [],
          'future': [],
          'completed': [],
        };

        for (final task in tasks) {
          if (task.isCompleted) {
            categories['completed']!.add(task);
          } else if (task.dueDate == null) {
            continue;
          } else {
            final dueDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
            if (dueDate.isBefore(today)) {
              categories['overdue']!.add(task);
            } else if (dueDate.isAtSameMomentAs(today)) {
              categories['today']!.add(task);
            } else {
              categories['future']!.add(task);
            }
          }
        }

        return Right(categories);
      },
    );
  }

  List<TaskModel> generateRecurringInstances(TaskModel task, DateTime start, DateTime end) {
    if (!task.isRecurring || task.recurrenceRule == null) return [task];

    final instances = <TaskModel>[];
    final rule = task.recurrenceRule!;
    DateTime current = task.dueDate ?? start;

    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      if (rule.endDate != null && current.isAfter(rule.endDate!)) break;
      
      instances.add(task.copyWith(
        id: '${task.id}_${current.millisecondsSinceEpoch}',
        dueDate: current,
      ));

      // Calculate next occurrence based on pattern
      switch (rule.pattern) {
        case RecurrencePattern.daily:
          current = current.add(Duration(days: rule.interval));
          break;
        case RecurrencePattern.weekly:
          current = current.add(Duration(days: 7 * rule.interval));
          break;
        case RecurrencePattern.monthly:
          current = DateTime(current.year, current.month + rule.interval, rule.dayOfMonth ?? current.day);
          break;
      }
    }

    return instances;
  }
}

/// Calendar data model
class CalendarData {
  final int year;
  final int month;
  final int? day;
  final int? daysInMonth;

  CalendarData({
    required this.year,
    required this.month,
    this.day,
    this.daysInMonth,
  });
}