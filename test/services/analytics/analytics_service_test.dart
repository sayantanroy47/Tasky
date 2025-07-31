import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:task_tracker_app/services/analytics/analytics_service.dart';
import 'package:task_tracker_app/services/analytics/analytics_models.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/task_enums.dart';
import 'package:task_tracker_app/domain/repositories/task_repository.dart';

import 'analytics_service_test.mocks.dart';

@GenerateMocks([TaskRepository])
void main() {
  group('AnalyticsService', () {
    late AnalyticsService analyticsService;
    late MockTaskRepository mockTaskRepository;

    setUp(() {
      mockTaskRepository = MockTaskRepository();
      analyticsService = AnalyticsServiceImpl(mockTaskRepository);
    });

    group('getAnalyticsSummary', () {
      test('should return correct analytics summary for empty task list', () async {
        // Arrange
        when(mockTaskRepository.getAllTasks()).thenAnswer((_) async => []);

        // Act
        final result = await analyticsService.getAnalyticsSummary(
          AnalyticsTimePeriod.thisWeek,
        );

        // Assert
        expect(result.totalTasks, equals(0));
        expect(result.completedTasks, equals(0));
        expect(result.pendingTasks, equals(0));
        expect(result.completionRate, equals(0.0));
        expect(result.currentStreak, equals(0));
        expect(result.longestStreak, equals(0));
      });

      test('should return correct analytics summary with tasks', () async {
        // Arrange
        final now = DateTime.now();
        final tasks = [
          TaskModel.create(
            title: 'Task 1',
            priority: TaskPriority.high,
            tags: ['work'],
          ).copyWith(
            status: TaskStatus.completed,
            completedAt: now,
            actualDuration: 60,
          ),
          TaskModel.create(
            title: 'Task 2',
            priority: TaskPriority.medium,
            tags: ['personal'],
          ).copyWith(
            status: TaskStatus.pending,
          ),
          TaskModel.create(
            title: 'Task 3',
            priority: TaskPriority.low,
            tags: ['work'],
          ).copyWith(
            status: TaskStatus.cancelled,
          ),
        ];

        when(mockTaskRepository.getAllTasks()).thenAnswer((_) async => tasks);

        // Act
        final result = await analyticsService.getAnalyticsSummary(
          AnalyticsTimePeriod.thisWeek,
        );

        // Assert
        expect(result.totalTasks, equals(3));
        expect(result.completedTasks, equals(1));
        expect(result.pendingTasks, equals(1));
        expect(result.cancelledTasks, equals(1));
        expect(result.completionRate, closeTo(0.33, 0.01));
        expect(result.averageTaskDuration, equals(60.0));
        expect(result.tasksByPriority['High'], equals(1));
        expect(result.tasksByPriority['Medium'], equals(1));
        expect(result.tasksByPriority['Low'], equals(1));
        expect(result.tasksByTag['work'], equals(2));
        expect(result.tasksByTag['personal'], equals(1));
      });
    });

    group('getProductivityMetrics', () {
      test('should calculate productivity metrics correctly', () async {
        // Arrange
        final now = DateTime.now();
        final tasks = List.generate(10, (index) {
          return TaskModel.create(
            title: 'Task $index',
          ).copyWith(
            status: index < 7 ? TaskStatus.completed : TaskStatus.pending,
            completedAt: index < 7 ? now.subtract(Duration(days: index)) : null,
            actualDuration: index < 7 ? 30 + (index * 10) : null,
          );
        });

        when(mockTaskRepository.getAllTasks()).thenAnswer((_) async => tasks);

        // Act
        final result = await analyticsService.getProductivityMetrics();

        // Assert
        expect(result.tasksCompletedThisWeek, greaterThan(0));
        expect(result.tasksCompletedThisMonth, greaterThan(0));
        expect(result.weeklyCompletionRate, greaterThan(0));
        expect(result.monthlyCompletionRate, greaterThan(0));
        expect(result.averageTasksPerDay, greaterThan(0));
        expect(result.averageCompletionTime, greaterThan(0));
        expect(result.weeklyTrend, hasLength(7));
        expect(result.monthlyTrend, hasLength(30));
      });
    });

    group('getStreakInfo', () {
      test('should return zero streak for no completed tasks', () async {
        // Arrange
        when(mockTaskRepository.getAllTasks()).thenAnswer((_) async => []);

        // Act
        final result = await analyticsService.getStreakInfo();

        // Assert
        expect(result.currentStreak, equals(0));
        expect(result.longestStreak, equals(0));
        expect(result.completionDates, isEmpty);
        expect(result.isStreakActive, isFalse);
      });

      test('should calculate streak correctly for consecutive days', () async {
        // Arrange
        final now = DateTime.now();
        final tasks = List.generate(5, (index) {
          return TaskModel.create(
            title: 'Task $index',
          ).copyWith(
            status: TaskStatus.completed,
            completedAt: now.subtract(Duration(days: index)),
          );
        });

        when(mockTaskRepository.getAllTasks()).thenAnswer((_) async => tasks);

        // Act
        final result = await analyticsService.getStreakInfo();

        // Assert
        expect(result.currentStreak, greaterThan(0));
        expect(result.longestStreak, greaterThan(0));
        expect(result.completionDates, hasLength(5));
        expect(result.isStreakActive, isTrue);
      });

      test('should handle broken streak correctly', () async {
        // Arrange
        final now = DateTime.now();
        final tasks = [
          // Recent streak (3 days)
          TaskModel.create(title: 'Task 1').copyWith(
            status: TaskStatus.completed,
            completedAt: now,
          ),
          TaskModel.create(title: 'Task 2').copyWith(
            status: TaskStatus.completed,
            completedAt: now.subtract(const Duration(days: 1)),
          ),
          TaskModel.create(title: 'Task 3').copyWith(
            status: TaskStatus.completed,
            completedAt: now.subtract(const Duration(days: 2)),
          ),
          // Gap of 2 days
          // Older streak (2 days)
          TaskModel.create(title: 'Task 4').copyWith(
            status: TaskStatus.completed,
            completedAt: now.subtract(const Duration(days: 5)),
          ),
          TaskModel.create(title: 'Task 5').copyWith(
            status: TaskStatus.completed,
            completedAt: now.subtract(const Duration(days: 6)),
          ),
        ];

        when(mockTaskRepository.getAllTasks()).thenAnswer((_) async => tasks);

        // Act
        final result = await analyticsService.getStreakInfo();

        // Assert
        expect(result.currentStreak, equals(3));
        expect(result.longestStreak, equals(3));
        expect(result.isStreakActive, isTrue);
      });
    });

    group('getCategoryAnalytics', () {
      test('should return category analytics correctly', () async {
        // Arrange
        final tasks = [
          TaskModel.create(title: 'Work Task 1', tags: ['work']).copyWith(
            status: TaskStatus.completed,
            actualDuration: 60,
          ),
          TaskModel.create(title: 'Work Task 2', tags: ['work']).copyWith(
            status: TaskStatus.pending,
          ),
          TaskModel.create(title: 'Personal Task', tags: ['personal']).copyWith(
            status: TaskStatus.completed,
            actualDuration: 30,
          ),
          TaskModel.create(title: 'Uncategorized Task').copyWith(
            status: TaskStatus.pending,
          ),
        ];

        when(mockTaskRepository.getAllTasks()).thenAnswer((_) async => tasks);

        // Act
        final result = await analyticsService.getCategoryAnalytics(
          AnalyticsTimePeriod.thisWeek,
        );

        // Assert
        expect(result, hasLength(3)); // work, personal, uncategorized
        
        final workCategory = result.firstWhere((c) => c.categoryName == 'work');
        expect(workCategory.totalTasks, equals(2));
        expect(workCategory.completedTasks, equals(1));
        expect(workCategory.completionRate, equals(0.5));
        expect(workCategory.averageDuration, equals(60.0));

        final personalCategory = result.firstWhere((c) => c.categoryName == 'personal');
        expect(personalCategory.totalTasks, equals(1));
        expect(personalCategory.completedTasks, equals(1));
        expect(personalCategory.completionRate, equals(1.0));

        final uncategorizedCategory = result.firstWhere((c) => c.categoryName == 'Uncategorized');
        expect(uncategorizedCategory.totalTasks, equals(1));
        expect(uncategorizedCategory.completedTasks, equals(0));
        expect(uncategorizedCategory.completionRate, equals(0.0));
      });
    });

    group('getDailyStats', () {
      test('should return daily statistics correctly', () async {
        // Arrange
        final now = DateTime.now();
        final startDate = DateTime(now.year, now.month, now.day - 6);
        final endDate = DateTime(now.year, now.month, now.day + 1);
        final dateRange = DateRange(start: startDate, end: endDate);

        final tasks = [
          TaskModel.create(title: 'Task 1').copyWith(
            createdAt: startDate,
            status: TaskStatus.completed,
            completedAt: startDate.add(const Duration(hours: 2)),
            actualDuration: 60,
          ),
          TaskModel.create(title: 'Task 2').copyWith(
            createdAt: startDate.add(const Duration(days: 1)),
            status: TaskStatus.completed,
            completedAt: startDate.add(const Duration(days: 1, hours: 3)),
            actualDuration: 90,
          ),
        ];

        when(mockTaskRepository.getAllTasks()).thenAnswer((_) async => tasks);

        // Act
        final result = await analyticsService.getDailyStats(dateRange);

        // Assert
        expect(result, hasLength(7)); // 7 days in range
        expect(result.first.date, equals(startDate));
        expect(result.first.createdTasks, equals(1));
        expect(result.first.completedTasks, equals(1));
        expect(result.first.totalDuration, equals(60.0));
      });
    });

    group('getHourlyProductivity', () {
      test('should return hourly productivity data', () async {
        // Arrange
        final now = DateTime.now();
        final dateRange = DateRange(
          start: now.subtract(const Duration(days: 7)),
          end: now.add(const Duration(days: 1)),
        );

        final tasks = [
          TaskModel.create(title: 'Morning Task').copyWith(
            createdAt: now.subtract(const Duration(days: 1)),
            status: TaskStatus.completed,
            completedAt: DateTime(now.year, now.month, now.day, 9, 0),
          ),
          TaskModel.create(title: 'Afternoon Task').copyWith(
            createdAt: now.subtract(const Duration(days: 1)),
            status: TaskStatus.completed,
            completedAt: DateTime(now.year, now.month, now.day, 14, 0),
          ),
          TaskModel.create(title: 'Another Morning Task').copyWith(
            createdAt: now.subtract(const Duration(days: 1)),
            status: TaskStatus.completed,
            completedAt: DateTime(now.year, now.month, now.day, 9, 30),
          ),
        ];

        when(mockTaskRepository.getAllTasks()).thenAnswer((_) async => tasks);

        // Act
        final result = await analyticsService.getHourlyProductivity(dateRange);

        // Assert
        expect(result, hasLength(24)); // 24 hours
        expect(result[9], equals(2)); // 2 tasks completed at 9 AM
        expect(result[14], equals(1)); // 1 task completed at 2 PM
        expect(result[0], equals(0)); // No tasks at midnight
      });
    });

    group('getWeekdayProductivity', () {
      test('should return weekday productivity data', () async {
        // Arrange
        final now = DateTime.now();
        final dateRange = DateRange(
          start: now.subtract(const Duration(days: 7)),
          end: now,
        );

        // Create tasks for different weekdays
        final monday = now.subtract(Duration(days: now.weekday - 1));
        final tuesday = monday.add(const Duration(days: 1));
        
        final tasks = [
          TaskModel.create(title: 'Monday Task').copyWith(
            status: TaskStatus.completed,
            completedAt: monday,
          ),
          TaskModel.create(title: 'Tuesday Task 1').copyWith(
            status: TaskStatus.completed,
            completedAt: tuesday,
          ),
          TaskModel.create(title: 'Tuesday Task 2').copyWith(
            status: TaskStatus.completed,
            completedAt: tuesday.add(const Duration(hours: 2)),
          ),
        ];

        when(mockTaskRepository.getAllTasks()).thenAnswer((_) async => tasks);

        // Act
        final result = await analyticsService.getWeekdayProductivity(dateRange);

        // Assert
        expect(result, hasLength(7)); // 7 weekdays
        expect(result[1], equals(1)); // Monday (1 task)
        expect(result[2], equals(2)); // Tuesday (2 tasks)
        expect(result[3], equals(0)); // Wednesday (0 tasks)
      });
    });

    group('getCompletionRateTrend', () {
      test('should return completion rate trend', () async {
        // Arrange
        final now = DateTime.now();
        final dateRange = DateRange(
          start: now.subtract(const Duration(days: 10)),
          end: now,
        );

        final tasks = List.generate(20, (index) {
          final date = now.subtract(Duration(days: index));
          return TaskModel.create(title: 'Task $index').copyWith(
            createdAt: date,
            status: index < 15 ? TaskStatus.completed : TaskStatus.pending,
            completedAt: index < 15 ? date.add(const Duration(hours: 1)) : null,
          );
        });

        when(mockTaskRepository.getAllTasks()).thenAnswer((_) async => tasks);

        // Act
        final result = await analyticsService.getCompletionRateTrend(dateRange, 2);

        // Assert
        expect(result, isNotEmpty);
        expect(result.every((rate) => rate >= 0.0 && rate <= 1.0), isTrue);
      });
    });
  });

  group('AnalyticsTimePeriod', () {
    test('should return correct date ranges', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Test today
      final todayRange = AnalyticsTimePeriod.today.dateRange;
      expect(todayRange.start, equals(today));
      expect(todayRange.end, equals(today.add(const Duration(days: 1))));

      // Test this week
      final weekRange = AnalyticsTimePeriod.thisWeek.dateRange;
      final weekday = now.weekday;
      final expectedWeekStart = today.subtract(Duration(days: weekday - 1));
      expect(weekRange.start, equals(expectedWeekStart));
      expect(weekRange.end, equals(expectedWeekStart.add(const Duration(days: 7))));

      // Test this month
      final monthRange = AnalyticsTimePeriod.thisMonth.dateRange;
      final expectedMonthStart = DateTime(now.year, now.month, 1);
      final expectedMonthEnd = DateTime(now.year, now.month + 1, 1);
      expect(monthRange.start, equals(expectedMonthStart));
      expect(monthRange.end, equals(expectedMonthEnd));
    });

    test('should return correct display names', () {
      expect(AnalyticsTimePeriod.today.displayName, equals('Today'));
      expect(AnalyticsTimePeriod.thisWeek.displayName, equals('This Week'));
      expect(AnalyticsTimePeriod.thisMonth.displayName, equals('This Month'));
      expect(AnalyticsTimePeriod.thisYear.displayName, equals('This Year'));
      expect(AnalyticsTimePeriod.last7Days.displayName, equals('Last 7 Days'));
      expect(AnalyticsTimePeriod.last30Days.displayName, equals('Last 30 Days'));
      expect(AnalyticsTimePeriod.last90Days.displayName, equals('Last 90 Days'));
      expect(AnalyticsTimePeriod.custom.displayName, equals('Custom Range'));
    });
  });

  group('DateRange', () {
    test('should calculate duration correctly', () {
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 1, 8);
      final range = DateRange(start: start, end: end);

      expect(range.durationInDays, equals(7));
    });

    test('should check if date is contained', () {
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 1, 8);
      final range = DateRange(start: start, end: end);

      expect(range.contains(DateTime(2024, 1, 5)), isTrue);
      expect(range.contains(DateTime(2024, 1, 1)), isFalse); // Start is exclusive
      expect(range.contains(DateTime(2024, 1, 8)), isFalse); // End is exclusive
      expect(range.contains(DateTime(2023, 12, 31)), isFalse);
      expect(range.contains(DateTime(2024, 1, 9)), isFalse);
    });
  });

  group('StreakInfo', () {
    test('should determine if streak is active correctly', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final twoDaysAgo = today.subtract(const Duration(days: 2));

      // Active streak - completed today
      final activeStreakToday = StreakInfo(
        currentStreak: 3,
        longestStreak: 5,
        lastCompletionDate: today,
        completionDates: [today, yesterday, twoDaysAgo],
      );
      expect(activeStreakToday.isStreakActive, isTrue);

      // Active streak - completed yesterday
      final activeStreakYesterday = StreakInfo(
        currentStreak: 2,
        longestStreak: 5,
        lastCompletionDate: yesterday,
        completionDates: [yesterday, twoDaysAgo],
      );
      expect(activeStreakYesterday.isStreakActive, isTrue);

      // Inactive streak - completed two days ago
      final inactiveStreak = StreakInfo(
        currentStreak: 0,
        longestStreak: 5,
        lastCompletionDate: twoDaysAgo,
        completionDates: [twoDaysAgo],
      );
      expect(inactiveStreak.isStreakActive, isFalse);

      // No completion date
      const noCompletionStreak = StreakInfo(
        currentStreak: 0,
        longestStreak: 0,
        completionDates: [],
      );
      expect(noCompletionStreak.isStreakActive, isFalse);
    });
  });
}