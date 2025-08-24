import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/core_providers.dart';
import '../../services/analytics/project_analytics_service.dart';
import '../../services/analytics/analytics_export_service.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../widgets/charts/base_chart_widget.dart';
import 'project_providers.dart';

// Service providers
final projectAnalyticsServiceProvider = Provider<ProjectAnalyticsService>((ref) {
  final projectRepository = ref.read(projectRepositoryProvider);
  final taskRepository = ref.read(taskRepositoryProvider);
  final projectService = ref.read(projectServiceProvider);
  
  return ProjectAnalyticsService(
    projectRepository,
    taskRepository,
    projectService,
  );
});

final analyticsExportServiceProvider = Provider<AnalyticsExportService>((ref) {
  return const AnalyticsExportService();
});

// Analytics data providers
final projectAnalyticsProvider = FutureProvider.family.autoDispose<ProjectAnalytics, AnalyticsRequest>(
  (ref, request) async {
    final analyticsService = ref.read(projectAnalyticsServiceProvider);
    
    return await analyticsService.getProjectAnalytics(
      request.projectId,
      period: request.period,
      startDate: request.startDate,
      endDate: request.endDate,
    );
  },
);

// Cached analytics provider for better performance
final cachedProjectAnalyticsProvider = StateNotifierProvider.family.autoDispose<
    CachedAnalyticsNotifier, AsyncValue<ProjectAnalytics>, String>((ref, projectId) {
  return CachedAnalyticsNotifier(ref, projectId);
});

// Chart data providers
final chartDataProvider = Provider.family.autoDispose<ChartDataState, ChartDataRequest>((ref, request) {
  final analyticsAsync = ref.watch(projectAnalyticsProvider(AnalyticsRequest(
    projectId: request.projectId,
    period: request.period.toTimePeriod(),
    startDate: request.startDate,
    endDate: request.endDate,
  )));

  return analyticsAsync.when(
    data: (analytics) => ChartDataState.loaded(_buildChartData(analytics, request)),
    loading: () => const ChartDataState.loading(),
    error: (error, stack) => ChartDataState.error(error.toString()),
  );
});

// Filtered tasks provider for drill-down
final filteredTasksProvider = FutureProvider.family.autoDispose<List<TaskModel>, TaskFilterRequest>(
  (ref, request) async {
    final taskRepository = ref.read(taskRepositoryProvider);
    final allTasks = await taskRepository.getTasksByProject(request.projectId);
    
    return _applyTaskFilters(allTasks, request.filters);
  },
);

// Analytics export provider
final analyticsExportProvider = FutureProvider.family.autoDispose<ExportResult, ExportRequest>(
  (ref, request) async {
    final exportService = ref.read(analyticsExportServiceProvider);
    final projectRepository = ref.read(projectRepositoryProvider);
    final taskRepository = ref.read(taskRepositoryProvider);
    
    final project = await projectRepository.getProjectById(request.projectId);
    if (project == null) {
      throw Exception('Project not found: ${request.projectId}');
    }
    
    final tasks = await taskRepository.getTasksByProject(request.projectId);
    
    switch (request.format) {
      case ExportFormat.json:
        return await exportService.exportToJson(
          analytics: request.analytics,
          project: project,
          tasks: tasks,
          customFileName: request.customFileName,
        );
      case ExportFormat.csv:
        return await exportService.exportToCsv(
          analytics: request.analytics,
          project: project,
          tasks: tasks,
          customFileName: request.customFileName,
          options: request.csvOptions,
        );
      case ExportFormat.txt:
        return await exportService.exportToText(
          analytics: request.analytics,
          project: project,
          tasks: tasks,
          customFileName: request.customFileName,
        );
      case ExportFormat.pdf:
        throw UnimplementedError('PDF export not yet implemented');
      case ExportFormat.excel:
        throw UnimplementedError('Excel export not yet implemented');
    }
  },
);

// UI state providers
final analyticsFiltersProvider = StateNotifierProvider.family.autoDispose<
    AnalyticsFiltersNotifier, AnalyticsFiltersState, String>((ref, projectId) {
  return AnalyticsFiltersNotifier();
});

final chartConfigProvider = StateNotifierProvider.family.autoDispose<
    ChartConfigNotifier, ChartConfigState, String>((ref, projectId) {
  return ChartConfigNotifier();
});

// Performance metrics provider
final analyticsPerformanceProvider = Provider.family.autoDispose<AnalyticsPerformanceMetrics, String>(
  (ref, projectId) {
    final stopwatch = Stopwatch()..start();
    
    final analyticsAsync = ref.watch(projectAnalyticsProvider(AnalyticsRequest(
      projectId: projectId,
      period: TimePeriod.last30Days,
    )));
    
    return analyticsAsync.when(
      data: (analytics) {
        stopwatch.stop();
        return AnalyticsPerformanceMetrics(
          loadTimeMs: stopwatch.elapsedMilliseconds,
          dataPointsCount: analytics.progressData.dailyProgress.length,
          cacheHit: false, // TODO: Implement cache hit detection
          lastUpdated: DateTime.now(),
        );
      },
      loading: () => AnalyticsPerformanceMetrics(
        loadTimeMs: stopwatch.elapsedMilliseconds,
        dataPointsCount: 0,
        cacheHit: false,
        lastUpdated: DateTime.now(),
        isLoading: true,
      ),
      error: (error, stack) => AnalyticsPerformanceMetrics(
        loadTimeMs: stopwatch.elapsedMilliseconds,
        dataPointsCount: 0,
        cacheHit: false,
        lastUpdated: DateTime.now(),
        hasError: true,
        error: error.toString(),
      ),
    );
  },
);

// Notifiers
class CachedAnalyticsNotifier extends StateNotifier<AsyncValue<ProjectAnalytics>> {
  final Ref ref;
  final String projectId;
  ProjectAnalytics? _cachedData;
  DateTime? _lastFetch;
  static const Duration _cacheExpiration = Duration(minutes: 5);

  CachedAnalyticsNotifier(this.ref, this.projectId) : super(const AsyncValue.loading()) {
    _loadAnalytics();
  }

  Future<void> _loadAnalytics([bool forceRefresh = false]) async {
    if (!forceRefresh && _cachedData != null && _lastFetch != null) {
      final now = DateTime.now();
      if (now.difference(_lastFetch!) < _cacheExpiration) {
        state = AsyncValue.data(_cachedData!);
        return;
      }
    }

    try {
      state = const AsyncValue.loading();
      final analyticsService = ref.read(projectAnalyticsServiceProvider);
      
      final analytics = await analyticsService.getProjectAnalytics(
        projectId,
        period: TimePeriod.last30Days,
      );
      
      _cachedData = analytics;
      _lastFetch = DateTime.now();
      state = AsyncValue.data(analytics);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() => _loadAnalytics(true);

  void invalidateCache() {
    _cachedData = null;
    _lastFetch = null;
    _loadAnalytics(true);
  }
}

class AnalyticsFiltersNotifier extends StateNotifier<AnalyticsFiltersState> {
  AnalyticsFiltersNotifier() : super(const AnalyticsFiltersState());

  void updatePeriod(ChartTimePeriod period) {
    state = state.copyWith(selectedPeriod: period);
  }

  void updateDateRange(DateTime? startDate, DateTime? endDate) {
    state = state.copyWith(
      customStartDate: startDate,
      customEndDate: endDate,
    );
  }

  void toggleFilter(String filterKey) {
    final newFilters = Map<String, bool>.from(state.activeFilters);
    newFilters[filterKey] = !(newFilters[filterKey] ?? false);
    state = state.copyWith(activeFilters: newFilters);
  }

  void clearFilters() {
    state = state.copyWith(activeFilters: {});
  }

  void resetToDefaults() {
    state = const AnalyticsFiltersState();
  }
}

class ChartConfigNotifier extends StateNotifier<ChartConfigState> {
  ChartConfigNotifier() : super(const ChartConfigState());

  void updateChartType(ChartType type) {
    state = state.copyWith(selectedChartType: type);
  }

  void toggleShowGrid() {
    state = state.copyWith(showGrid: !state.showGrid);
  }

  void toggleShowLabels() {
    state = state.copyWith(showLabels: !state.showLabels);
  }

  void toggleAnimations() {
    state = state.copyWith(enableAnimations: !state.enableAnimations);
  }

  void updateColorScheme(ChartColorScheme scheme) {
    state = state.copyWith(colorScheme: scheme);
  }
}

// Data models
class AnalyticsRequest {
  final String projectId;
  final TimePeriod period;
  final DateTime? startDate;
  final DateTime? endDate;

  const AnalyticsRequest({
    required this.projectId,
    this.period = TimePeriod.last30Days,
    this.startDate,
    this.endDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalyticsRequest &&
          runtimeType == other.runtimeType &&
          projectId == other.projectId &&
          period == other.period &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode =>
      projectId.hashCode ^ period.hashCode ^ startDate.hashCode ^ endDate.hashCode;
}

class ChartDataRequest {
  final String projectId;
  final ChartTimePeriod period;
  final ChartType chartType;
  final String? metric;
  final DateTime? startDate;
  final DateTime? endDate;

  const ChartDataRequest({
    required this.projectId,
    this.period = ChartTimePeriod.last30Days,
    this.chartType = ChartType.line,
    this.metric,
    this.startDate,
    this.endDate,
  });
}

class TaskFilterRequest {
  final String projectId;
  final Map<String, bool> filters;
  final DateTime? startDate;
  final DateTime? endDate;

  const TaskFilterRequest({
    required this.projectId,
    this.filters = const {},
    this.startDate,
    this.endDate,
  });
}

class ExportRequest {
  final String projectId;
  final ProjectAnalytics analytics;
  final ExportFormat format;
  final String? customFileName;
  final CsvExportOptions? csvOptions;

  const ExportRequest({
    required this.projectId,
    required this.analytics,
    required this.format,
    this.customFileName,
    this.csvOptions,
  });
}

class ChartDataState {
  final bool isLoading;
  final String? error;
  final List<ChartDataPoint>? data;
  final List<TimeSeriesDataPoint>? timeSeriesData;
  final Map<String, dynamic>? metadata;

  const ChartDataState({
    this.isLoading = false,
    this.error,
    this.data,
    this.timeSeriesData,
    this.metadata,
  });

  const ChartDataState.loading() : this(isLoading: true);
  const ChartDataState.error(String error) : this(error: error);
  const ChartDataState.loaded(dynamic data) : this(data: data is List<ChartDataPoint> ? data : null, timeSeriesData: data is List<TimeSeriesDataPoint> ? data : null);
}

class AnalyticsFiltersState {
  final ChartTimePeriod selectedPeriod;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final Map<String, bool> activeFilters;

  const AnalyticsFiltersState({
    this.selectedPeriod = ChartTimePeriod.last30Days,
    this.customStartDate,
    this.customEndDate,
    this.activeFilters = const {},
  });

  AnalyticsFiltersState copyWith({
    ChartTimePeriod? selectedPeriod,
    DateTime? customStartDate,
    DateTime? customEndDate,
    Map<String, bool>? activeFilters,
  }) {
    return AnalyticsFiltersState(
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
      activeFilters: activeFilters ?? this.activeFilters,
    );
  }
}

class ChartConfigState {
  final ChartType selectedChartType;
  final bool showGrid;
  final bool showLabels;
  final bool enableAnimations;
  final ChartColorScheme colorScheme;

  const ChartConfigState({
    this.selectedChartType = ChartType.line,
    this.showGrid = true,
    this.showLabels = true,
    this.enableAnimations = true,
    this.colorScheme = ChartColorScheme.adaptive,
  });

  ChartConfigState copyWith({
    ChartType? selectedChartType,
    bool? showGrid,
    bool? showLabels,
    bool? enableAnimations,
    ChartColorScheme? colorScheme,
  }) {
    return ChartConfigState(
      selectedChartType: selectedChartType ?? this.selectedChartType,
      showGrid: showGrid ?? this.showGrid,
      showLabels: showLabels ?? this.showLabels,
      enableAnimations: enableAnimations ?? this.enableAnimations,
      colorScheme: colorScheme ?? this.colorScheme,
    );
  }
}

class AnalyticsPerformanceMetrics {
  final int loadTimeMs;
  final int dataPointsCount;
  final bool cacheHit;
  final DateTime lastUpdated;
  final bool isLoading;
  final bool hasError;
  final String? error;

  const AnalyticsPerformanceMetrics({
    required this.loadTimeMs,
    required this.dataPointsCount,
    required this.cacheHit,
    required this.lastUpdated,
    this.isLoading = false,
    this.hasError = false,
    this.error,
  });
}

// Enums
enum ChartColorScheme { adaptive, blue, green, orange, red, purple, custom }

// Helper functions
List<ChartDataPoint> _buildChartData(ProjectAnalytics analytics, ChartDataRequest request) {
  switch (request.metric) {
    case 'priority':
      return analytics.distributionData.byPriority.entries.map((entry) =>
          ChartDataPoint(label: entry.key.name, value: entry.value.toDouble())).toList();
    case 'status':
      return analytics.distributionData.byStatus.entries.map((entry) =>
          ChartDataPoint(label: entry.key.name, value: entry.value.toDouble())).toList();
    default:
      // Default to progress data
      return analytics.progressData.dailyProgress.map((point) =>
          ChartDataPoint(label: _formatDate(point.date), value: point.completionPercentage * 100)).toList();
  }
}

List<TaskModel> _applyTaskFilters(List<TaskModel> tasks, Map<String, bool> filters) {
  var filteredTasks = tasks;

  if (filters['high_priority'] == true) {
    filteredTasks = filteredTasks.where((task) =>
        task.priority == TaskPriority.high || task.priority == TaskPriority.urgent).toList();
  }

  if (filters['overdue'] == true) {
    filteredTasks = filteredTasks.where((task) => task.isOverdue).toList();
  }

  if (filters['completed'] == true) {
    filteredTasks = filteredTasks.where((task) => task.status.isCompleted).toList();
  }

  if (filters['in_progress'] == true) {
    filteredTasks = filteredTasks.where((task) => task.status.isInProgress).toList();
  }

  if (filters['with_due_date'] == true) {
    filteredTasks = filteredTasks.where((task) => task.dueDate != null).toList();
  }

  if (filters['with_estimates'] == true) {
    filteredTasks = filteredTasks.where((task) => task.estimatedDuration != null).toList();
  }

  return filteredTasks;
}

String _formatDate(DateTime date) {
  return '${date.month}/${date.day}';
}

// Extension to convert TimePeriod to ChartTimePeriod
extension TimePeriodExtension on TimePeriod {
  ChartTimePeriod toChartTimePeriod() {
    switch (this) {
      case TimePeriod.last7Days:
        return ChartTimePeriod.last7Days;
      case TimePeriod.last30Days:
        return ChartTimePeriod.last30Days;
      case TimePeriod.last3Months:
        return ChartTimePeriod.last3Months;
      case TimePeriod.allTime:
        return ChartTimePeriod.allTime;
    }
  }
}

extension ChartTimePeriodExtension on ChartTimePeriod {
  TimePeriod toTimePeriod() {
    switch (this) {
      case ChartTimePeriod.last7Days:
        return TimePeriod.last7Days;
      case ChartTimePeriod.last30Days:
        return TimePeriod.last30Days;
      case ChartTimePeriod.last3Months:
        return TimePeriod.last3Months;
      case ChartTimePeriod.allTime:
        return TimePeriod.allTime;
    }
  }
}