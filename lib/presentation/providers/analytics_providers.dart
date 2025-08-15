import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/analytics/analytics_service.dart';
import '../../services/analytics/analytics_models.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../core/providers/core_providers.dart';

/// Providers for analytics functionality

/// Analytics service provider
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final database = ref.watch(databaseProvider);
  final taskRepository = TaskRepositoryImpl(database);
  return AnalyticsServiceImpl(taskRepository);
});

/// Current analytics time period provider
final analyticsTimePeriodProvider = StateProvider<AnalyticsTimePeriod>((ref) {
  return AnalyticsTimePeriod.thisWeek;
});

/// Custom date range provider (used when period is custom)
final customDateRangeProvider = StateProvider<DateRange?>((ref) {
  return null;
});

/// Analytics summary provider
final analyticsSummaryProvider = FutureProvider<AnalyticsSummary>((ref) async {
  final analyticsService = ref.watch(analyticsServiceProvider);
  final period = ref.watch(analyticsTimePeriodProvider);
  final customRange = ref.watch(customDateRangeProvider);
  
  return await analyticsService.getAnalyticsSummary(
    period,
    customRange: customRange,
  );
});

/// Productivity metrics provider
final productivityMetricsProvider = FutureProvider<ProductivityMetrics>((ref) async {
  final analyticsService = ref.watch(analyticsServiceProvider);
  return await analyticsService.getProductivityMetrics();
});

/// Streak information provider
final streakInfoProvider = FutureProvider<StreakInfo>((ref) async {
  final analyticsService = ref.watch(analyticsServiceProvider);
  return await analyticsService.getStreakInfo();
});

/// Category analytics provider
final categoryAnalyticsProvider = FutureProvider<List<CategoryAnalytics>>((ref) async {
  final analyticsService = ref.watch(analyticsServiceProvider);
  final period = ref.watch(analyticsTimePeriodProvider);
  final customRange = ref.watch(customDateRangeProvider);
  
  return await analyticsService.getCategoryAnalytics(
    period,
    customRange: customRange,
  );
});

/// Daily statistics provider
final dailyStatsProvider = FutureProvider<List<DailyStats>>((ref) async {
  final analyticsService = ref.watch(analyticsServiceProvider);
  final period = ref.watch(analyticsTimePeriodProvider);
  final customRange = ref.watch(customDateRangeProvider);
  
  final dateRange = customRange ?? period.dateRange;
  return await analyticsService.getDailyStats(dateRange);
});

/// Hourly productivity provider
final hourlyProductivityProvider = FutureProvider<Map<int, int>>((ref) async {
  final analyticsService = ref.watch(analyticsServiceProvider);
  final period = ref.watch(analyticsTimePeriodProvider);
  final customRange = ref.watch(customDateRangeProvider);
  
  final dateRange = customRange ?? period.dateRange;
  return await analyticsService.getHourlyProductivity(dateRange);
});

/// Weekday productivity provider
final weekdayProductivityProvider = FutureProvider<Map<int, int>>((ref) async {
  final analyticsService = ref.watch(analyticsServiceProvider);
  final period = ref.watch(analyticsTimePeriodProvider);
  final customRange = ref.watch(customDateRangeProvider);
  
  final dateRange = customRange ?? period.dateRange;
  return await analyticsService.getWeekdayProductivity(dateRange);
});

/// Completion rate trend provider
final completionRateTrendProvider = FutureProvider.family<List<double>, int>((ref, intervalDays) async {
  final analyticsService = ref.watch(analyticsServiceProvider);
  final period = ref.watch(analyticsTimePeriodProvider);
  final customRange = ref.watch(customDateRangeProvider);
  
  final dateRange = customRange ?? period.dateRange;
  return await analyticsService.getCompletionRateTrend(dateRange, intervalDays);
});

/// Advanced analytics providers

/// Productivity patterns provider
final productivityPatternsProvider = FutureProvider<ProductivityPatterns>((ref) async {
  final analyticsService = ref.watch(analyticsServiceProvider);
  final period = ref.watch(analyticsTimePeriodProvider);
  final customRange = ref.watch(customDateRangeProvider);
  
  final dateRange = customRange ?? period.dateRange;
  return await analyticsService.getProductivityPatterns(dateRange);
});

/// Peak hours analysis provider
final peakHoursAnalysisProvider = FutureProvider<PeakHoursAnalysis>((ref) async {
  final analyticsService = ref.watch(analyticsServiceProvider);
  final period = ref.watch(analyticsTimePeriodProvider);
  final customRange = ref.watch(customDateRangeProvider);
  
  final dateRange = customRange ?? period.dateRange;
  return await analyticsService.getPeakHoursAnalysis(dateRange);
});

/// Advanced category analytics provider
final advancedCategoryAnalyticsProvider = FutureProvider<AdvancedCategoryAnalytics>((ref) async {
  final analyticsService = ref.watch(analyticsServiceProvider);
  final period = ref.watch(analyticsTimePeriodProvider);
  final customRange = ref.watch(customDateRangeProvider);
  
  return await analyticsService.getAdvancedCategoryAnalytics(
    period,
    customRange: customRange,
  );
});

/// Productivity insights provider
final productivityInsightsProvider = FutureProvider<ProductivityInsights>((ref) async {
  final analyticsService = ref.watch(analyticsServiceProvider);
  final period = ref.watch(analyticsTimePeriodProvider);
  final customRange = ref.watch(customDateRangeProvider);
  
  final dateRange = customRange ?? period.dateRange;
  return await analyticsService.getProductivityInsights(dateRange);
});

/// Analytics export provider
final analyticsExportProvider = FutureProvider.family<String, AnalyticsExportFormat>((ref, format) async {
  final analyticsService = ref.watch(analyticsServiceProvider);
  final period = ref.watch(analyticsTimePeriodProvider);
  final customRange = ref.watch(customDateRangeProvider);
  
  return await analyticsService.exportAnalytics(
    format,
    period,
    customRange: customRange,
  );
});

/// Provider for refreshing analytics data
final refreshAnalyticsProvider = Provider<void Function()>((ref) {
  return () {
    ref.invalidate(analyticsSummaryProvider);
    ref.invalidate(productivityMetricsProvider);
    ref.invalidate(streakInfoProvider);
    ref.invalidate(categoryAnalyticsProvider);
    ref.invalidate(dailyStatsProvider);
    ref.invalidate(hourlyProductivityProvider);
    ref.invalidate(weekdayProductivityProvider);
    ref.invalidate(completionRateTrendProvider);
    ref.invalidate(productivityPatternsProvider);
    ref.invalidate(peakHoursAnalysisProvider);
    ref.invalidate(advancedCategoryAnalyticsProvider);
    ref.invalidate(productivityInsightsProvider);
    ref.invalidate(analyticsExportProvider);
  };
});

/// Analytics state notifier for managing analytics UI state
class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  final AnalyticsService _analyticsService;

  AnalyticsNotifier(this._analyticsService) : super(const AnalyticsState());

  void setTimePeriod(AnalyticsTimePeriod period) {
    state = state.copyWith(
      timePeriod: period,
      clearCustomDateRange: period != AnalyticsTimePeriod.custom,
    );
  }

  void setCustomDateRange(DateRange? dateRange) {
    state = state.copyWith(
      customDateRange: dateRange,
      timePeriod: dateRange != null ? AnalyticsTimePeriod.custom : state.timePeriod,
    );
  }

  void setSelectedMetric(String metric) {
    state = state.copyWith(selectedMetric: metric);
  }

  void toggleShowTrends() {
    state = state.copyWith(showTrends: !state.showTrends);
  }

  Future<void> refreshAnalytics() async {
    state = state.copyWith(isRefreshing: true);
    try {
      await _analyticsService.recalculateAnalytics();
      state = state.copyWith(isRefreshing: false);
    } catch (e) {
      state = state.copyWith(isRefreshing: false, error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Analytics state for UI management
class AnalyticsState {
  final AnalyticsTimePeriod timePeriod;
  final DateRange? customDateRange;
  final String selectedMetric;
  final bool showTrends;
  final bool isRefreshing;
  final String? error;

  const AnalyticsState({
    this.timePeriod = AnalyticsTimePeriod.thisWeek,
    this.customDateRange,
    this.selectedMetric = 'completion',
    this.showTrends = false,
    this.isRefreshing = false,
    this.error,
  });

  AnalyticsState copyWith({
    AnalyticsTimePeriod? timePeriod,
    DateRange? customDateRange,
    bool clearCustomDateRange = false,
    String? selectedMetric,
    bool? showTrends,
    bool? isRefreshing,
    String? error,
    bool clearError = false,
  }) {
    return AnalyticsState(
      timePeriod: timePeriod ?? this.timePeriod,
      customDateRange: clearCustomDateRange ? null : (customDateRange ?? this.customDateRange),
      selectedMetric: selectedMetric ?? this.selectedMetric,
      showTrends: showTrends ?? this.showTrends,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Analytics state notifier provider
final analyticsNotifierProvider = StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  final analyticsService = ref.watch(analyticsServiceProvider);
  return AnalyticsNotifier(analyticsService);
});

/// Import database provider from task providers
/// (Database provider is defined in task_providers.dart)
