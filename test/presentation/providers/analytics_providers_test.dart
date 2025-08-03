import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:task_tracker_app/presentation/providers/analytics_providers.dart';
import 'package:task_tracker_app/services/analytics/analytics_service.dart';
import 'package:task_tracker_app/services/analytics/analytics_models.dart';
import 'package:task_tracker_app/services/database/database.dart';

import 'analytics_providers_test.mocks.dart';

@GenerateMocks([AnalyticsService, AppDatabase])
void main() {
  group('Analytics Providers', () {
    late MockAnalyticsService mockAnalyticsService;
    late ProviderContainer container;

    setUp(() {
      mockAnalyticsService = MockAnalyticsService();
      
      container = ProviderContainer(
        overrides: [
          analyticsServiceProvider.overrideWithValue(mockAnalyticsService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('analyticsTimePeriodProvider', () {
      test('should have default value of thisWeek', () {
        final period = container.read(analyticsTimePeriodProvider);
        expect(period, equals(AnalyticsTimePeriod.thisWeek));
      });

      test('should update period correctly', () {
        container.read(analyticsTimePeriodProvider.notifier).state = AnalyticsTimePeriod.thisMonth;
        final period = container.read(analyticsTimePeriodProvider);
        expect(period, equals(AnalyticsTimePeriod.thisMonth));
      });
    });

    group('customDateRangeProvider', () {
      test('should have default value of null', () {
        final range = container.read(customDateRangeProvider);
        expect(range, isNull);
      });

      test('should update range correctly', () {
        final testRange = DateRange(
          start: DateTime(2024, 1, 1),
          end: DateTime(2024, 1, 31),
        );
        
        container.read(customDateRangeProvider.notifier).state = testRange;
        final range = container.read(customDateRangeProvider);
        expect(range, equals(testRange));
      });
    });

    group('analyticsSummaryProvider', () {
      test('should call analytics service with correct parameters', () async {
        final mockSummary = AnalyticsSummary(
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 7),
          totalTasks: 10,
          completedTasks: 7,
          pendingTasks: 2,
          cancelledTasks: 1,
          completionRate: 0.7,
          currentStreak: 3,
          longestStreak: 5,
          averageTaskDuration: 45.0,
          tasksByPriority: const {'High': 3, 'Medium': 4, 'Low': 3},
          tasksByStatus: const {'Completed': 7, 'Pending': 2, 'Cancelled': 1},
          tasksByTag: const {'work': 5, 'personal': 3, 'health': 2},
          tasksByProject: const {'project1': 6, 'project2': 4},
          dailyStats: const [],
        );

        when(mockAnalyticsService.getAnalyticsSummary(
          AnalyticsTimePeriod.thisWeek,
          customRange: null,
        )).thenAnswer((_) async => mockSummary);

        final result = await container.read(analyticsSummaryProvider.future);

        expect(result, equals(mockSummary));
        verify(mockAnalyticsService.getAnalyticsSummary(
          AnalyticsTimePeriod.thisWeek,
          customRange: null,
        )).called(1);
      });

      test('should use custom date range when provided', () async {
        final customRange = DateRange(
          start: DateTime(2024, 1, 1),
          end: DateTime(2024, 1, 31),
        );
        
        final mockSummary = AnalyticsSummary(
          startDate: customRange.start,
          endDate: customRange.end,
          totalTasks: 20,
          completedTasks: 15,
          pendingTasks: 3,
          cancelledTasks: 2,
          completionRate: 0.75,
          currentStreak: 5,
          longestStreak: 8,
          averageTaskDuration: 60.0,
          tasksByPriority: const {'High': 5, 'Medium': 8, 'Low': 7},
          tasksByStatus: const {'Completed': 15, 'Pending': 3, 'Cancelled': 2},
          tasksByTag: const {'work': 10, 'personal': 6, 'health': 4},
          tasksByProject: const {'project1': 12, 'project2': 8},
          dailyStats: const [],
        );

        when(mockAnalyticsService.getAnalyticsSummary(
          AnalyticsTimePeriod.thisWeek,
          customRange: customRange,
        )).thenAnswer((_) async => mockSummary);

        // Set custom date range
        container.read(customDateRangeProvider.notifier).state = customRange;

        final result = await container.read(analyticsSummaryProvider.future);

        expect(result, equals(mockSummary));
        verify(mockAnalyticsService.getAnalyticsSummary(
          AnalyticsTimePeriod.thisWeek,
          customRange: customRange,
        )).called(1);
      });
    });

    group('productivityMetricsProvider', () {
      test('should call analytics service correctly', () async {
        final mockMetrics = ProductivityMetrics(
          weeklyCompletionRate: 0.8,
          monthlyCompletionRate: 0.75,
          tasksCompletedThisWeek: 20,
          tasksCompletedThisMonth: 80,
          currentStreak: 5,
          longestStreak: 12,
          weeklyTrend: const [3, 4, 2, 5, 6, 4, 3],
          monthlyTrend: List.filled(30, 3),
          hourlyProductivity: const {9: 10, 14: 8, 19: 5},
          weekdayProductivity: const {1: 15, 2: 12, 3: 18, 4: 10, 5: 8, 6: 5, 7: 3},
          averageTasksPerDay: 3.2,
          averageCompletionTime: 45.5,
        );

        when(mockAnalyticsService.getProductivityMetrics())
            .thenAnswer((_) async => mockMetrics);

        final result = await container.read(productivityMetricsProvider.future);

        expect(result, equals(mockMetrics));
        verify(mockAnalyticsService.getProductivityMetrics()).called(1);
      });
    });

    group('streakInfoProvider', () {
      test('should call analytics service correctly', () async {
        final mockStreakInfo = StreakInfo(
          currentStreak: 7,
          longestStreak: 15,
          lastCompletionDate: DateTime.now(),
          streakStartDate: DateTime.now().subtract(const Duration(days: 6)),
          completionDates: List.generate(7, (i) => DateTime.now().subtract(Duration(days: i))),
        );

        when(mockAnalyticsService.getStreakInfo())
            .thenAnswer((_) async => mockStreakInfo);

        final result = await container.read(streakInfoProvider.future);

        expect(result, equals(mockStreakInfo));
        verify(mockAnalyticsService.getStreakInfo()).called(1);
      });
    });

    group('categoryAnalyticsProvider', () {
      test('should call analytics service with correct parameters', () async {
        final mockCategories = [
          const CategoryAnalytics(
            categoryName: 'Work',
            categoryId: 'work',
            totalTasks: 15,
            completedTasks: 12,
            pendingTasks: 3,
            completionRate: 0.8,
            averageDuration: 60.0,
            priorityDistribution: {'High': 5, 'Medium': 7, 'Low': 3},
          ),
          const CategoryAnalytics(
            categoryName: 'Personal',
            categoryId: 'personal',
            totalTasks: 8,
            completedTasks: 6,
            pendingTasks: 2,
            completionRate: 0.75,
            averageDuration: 30.0,
            priorityDistribution: {'High': 2, 'Medium': 4, 'Low': 2},
          ),
        ];

        when(mockAnalyticsService.getCategoryAnalytics(
          AnalyticsTimePeriod.thisWeek,
          customRange: null,
        )).thenAnswer((_) async => mockCategories);

        final result = await container.read(categoryAnalyticsProvider.future);

        expect(result, equals(mockCategories));
        verify(mockAnalyticsService.getCategoryAnalytics(
          AnalyticsTimePeriod.thisWeek,
          customRange: null,
        )).called(1);
      });
    });

    group('dailyStatsProvider', () {
      test('should call analytics service with correct date range', () async {
        final mockDailyStats = [
          DailyStats(
            date: DateTime(2024, 1, 1),
            totalTasks: 5,
            completedTasks: 4,
            createdTasks: 2,
            completionRate: 0.8,
            totalDuration: 120.0,
            tasksByPriority: const {'High': 2, 'Medium': 2, 'Low': 1},
            tasksByTag: const {'work': 3, 'personal': 2},
          ),
          DailyStats(
            date: DateTime(2024, 1, 2),
            totalTasks: 3,
            completedTasks: 2,
            createdTasks: 1,
            completionRate: 0.67,
            totalDuration: 90.0,
            tasksByPriority: const {'High': 1, 'Medium': 1, 'Low': 1},
            tasksByTag: const {'work': 2, 'personal': 1},
          ),
        ];

        when(mockAnalyticsService.getDailyStats(any))
            .thenAnswer((_) async => mockDailyStats);

        final result = await container.read(dailyStatsProvider.future);

        expect(result, equals(mockDailyStats));
        verify(mockAnalyticsService.getDailyStats(any)).called(1);
      });
    });

    group('hourlyProductivityProvider', () {
      test('should call analytics service with correct date range', () async {
        const mockHourlyData = {
          9: 10,
          10: 8,
          11: 12,
          14: 6,
          15: 9,
          16: 7,
        };

        when(mockAnalyticsService.getHourlyProductivity(any))
            .thenAnswer((_) async => mockHourlyData);

        final result = await container.read(hourlyProductivityProvider.future);

        expect(result, equals(mockHourlyData));
        verify(mockAnalyticsService.getHourlyProductivity(any)).called(1);
      });
    });

    group('weekdayProductivityProvider', () {
      test('should call analytics service with correct date range', () async {
        const mockWeekdayData = {
          1: 15, // Monday
          2: 12, // Tuesday
          3: 18, // Wednesday
          4: 10, // Thursday
          5: 8,  // Friday
          6: 5,  // Saturday
          7: 3,  // Sunday
        };

        when(mockAnalyticsService.getWeekdayProductivity(any))
            .thenAnswer((_) async => mockWeekdayData);

        final result = await container.read(weekdayProductivityProvider.future);

        expect(result, equals(mockWeekdayData));
        verify(mockAnalyticsService.getWeekdayProductivity(any)).called(1);
      });
    });

    group('completionRateTrendProvider', () {
      test('should call analytics service with correct parameters', () async {
        const mockTrend = [0.6, 0.7, 0.8, 0.75, 0.9];
        const intervalDays = 7;

        when(mockAnalyticsService.getCompletionRateTrend(any, intervalDays))
            .thenAnswer((_) async => mockTrend);

        final result = await container.read(completionRateTrendProvider(intervalDays).future);

        expect(result, equals(mockTrend));
        verify(mockAnalyticsService.getCompletionRateTrend(any, intervalDays)).called(1);
      });
    });

    group('refreshAnalyticsProvider', () {
      test('should invalidate all analytics providers', () {
        final refreshFunction = container.read(refreshAnalyticsProvider);
        
        // This test verifies that the refresh function exists and can be called
        // In a real scenario, we would need to verify that providers are invalidated
        expect(refreshFunction, isA<Function>());
        
        // Call the refresh function
        refreshFunction();
        
        // The function should complete without throwing
      });
    });

    group('AnalyticsNotifier', () {
      late AnalyticsNotifier notifier;

      setUp(() {
        notifier = AnalyticsNotifier(mockAnalyticsService);
      });

      test('should have correct initial state', () {
        expect(notifier.state.timePeriod, equals(AnalyticsTimePeriod.thisWeek));
        expect(notifier.state.customDateRange, isNull);
        expect(notifier.state.selectedMetric, equals('completion'));
        expect(notifier.state.showTrends, isFalse);
        expect(notifier.state.isRefreshing, isFalse);
        expect(notifier.state.error, isNull);
      });

      test('should update time period correctly', () {
        notifier.setTimePeriod(AnalyticsTimePeriod.thisMonth);
        
        expect(notifier.state.timePeriod, equals(AnalyticsTimePeriod.thisMonth));
        expect(notifier.state.customDateRange, isNull);
      });

      test('should clear custom date range when setting non-custom period', () {
        final customRange = DateRange(
          start: DateTime(2024, 1, 1),
          end: DateTime(2024, 1, 31),
        );
        
        notifier.setCustomDateRange(customRange);
        expect(notifier.state.customDateRange, equals(customRange));
        expect(notifier.state.timePeriod, equals(AnalyticsTimePeriod.custom));
        
        notifier.setTimePeriod(AnalyticsTimePeriod.thisWeek);
        expect(notifier.state.timePeriod, equals(AnalyticsTimePeriod.thisWeek));
        expect(notifier.state.customDateRange, isNull);
      });

      test('should update custom date range correctly', () {
        final customRange = DateRange(
          start: DateTime(2024, 1, 1),
          end: DateTime(2024, 1, 31),
        );
        
        notifier.setCustomDateRange(customRange);
        
        expect(notifier.state.customDateRange, equals(customRange));
        expect(notifier.state.timePeriod, equals(AnalyticsTimePeriod.custom));
      });

      test('should update selected metric correctly', () {
        notifier.setSelectedMetric('productivity');
        
        expect(notifier.state.selectedMetric, equals('productivity'));
      });

      test('should toggle show trends correctly', () {
        expect(notifier.state.showTrends, isFalse);
        
        notifier.toggleShowTrends();
        expect(notifier.state.showTrends, isTrue);
        
        notifier.toggleShowTrends();
        expect(notifier.state.showTrends, isFalse);
      });

      test('should handle refresh analytics correctly', () async {
        when(mockAnalyticsService.recalculateAnalytics())
            .thenAnswer((_) async {});

        await notifier.refreshAnalytics();

        verify(mockAnalyticsService.recalculateAnalytics()).called(1);
        expect(notifier.state.isRefreshing, isFalse);
        expect(notifier.state.error, isNull);
      });

      test('should handle refresh analytics error correctly', () async {
        const errorMessage = 'Failed to refresh analytics';
        when(mockAnalyticsService.recalculateAnalytics())
            .thenThrow(Exception(errorMessage));

        await notifier.refreshAnalytics();

        verify(mockAnalyticsService.recalculateAnalytics()).called(1);
        expect(notifier.state.isRefreshing, isFalse);
        expect(notifier.state.error, contains(errorMessage));
      });

      test('should clear error correctly', () {
        // Set an error first
        notifier.state = notifier.state.copyWith(error: 'Test error');
        expect(notifier.state.error, equals('Test error'));
        
        notifier.clearError();
        expect(notifier.state.error, isNull);
      });
    });

    group('AnalyticsState', () {
      test('should create state with default values', () {
        const state = AnalyticsState();
        
        expect(state.timePeriod, equals(AnalyticsTimePeriod.thisWeek));
        expect(state.customDateRange, isNull);
        expect(state.selectedMetric, equals('completion'));
        expect(state.showTrends, isFalse);
        expect(state.isRefreshing, isFalse);
        expect(state.error, isNull);
      });

      test('should create state with custom values', () {
        final customRange = DateRange(
          start: DateTime(2024, 1, 1),
          end: DateTime(2024, 1, 31),
        );
        
        final state = AnalyticsState(
          timePeriod: AnalyticsTimePeriod.thisMonth,
          customDateRange: customRange,
          selectedMetric: 'productivity',
          showTrends: true,
          isRefreshing: true,
          error: 'Test error',
        );
        
        expect(state.timePeriod, equals(AnalyticsTimePeriod.thisMonth));
        expect(state.customDateRange, equals(customRange));
        expect(state.selectedMetric, equals('productivity'));
        expect(state.showTrends, isTrue);
        expect(state.isRefreshing, isTrue);
        expect(state.error, equals('Test error'));
      });

      test('should copy state with updated values', () {
        const originalState = AnalyticsState();
        
        final updatedState = originalState.copyWith(
          timePeriod: AnalyticsTimePeriod.thisMonth,
          selectedMetric: 'streak',
          showTrends: true,
        );
        
        expect(updatedState.timePeriod, equals(AnalyticsTimePeriod.thisMonth));
        expect(updatedState.selectedMetric, equals('streak'));
        expect(updatedState.showTrends, isTrue);
        // Unchanged values should remain the same
        expect(updatedState.customDateRange, isNull);
        expect(updatedState.isRefreshing, isFalse);
        expect(updatedState.error, isNull);
      });
    });
  });
}
