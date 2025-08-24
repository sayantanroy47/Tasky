import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/task_model.dart';
import '../../domain/entities/timeline_milestone.dart';
import '../../domain/entities/timeline_dependency.dart';
import '../../domain/entities/timeline_settings.dart';
import '../../presentation/widgets/timeline/timeline_gantt_view.dart';
import '../../services/timeline_service.dart';
import '../../core/providers/core_providers.dart';

// Timeline service provider
final timelineServiceProvider = Provider<TimelineService>((ref) {
  final taskRepository = ref.read(taskRepositoryProvider);
  final projectRepository = ref.read(projectRepositoryProvider);
  return TimelineService(
    taskRepository: taskRepository,
    projectRepository: projectRepository,
  );
});

// Timeline settings provider
final timelineSettingsProvider = StateNotifierProvider<TimelineSettingsNotifier, TimelineSettings>(
  (ref) => TimelineSettingsNotifier(),
);

class TimelineSettingsNotifier extends StateNotifier<TimelineSettings> {
  TimelineSettingsNotifier() : super(TimelineSettings.defaultSettings());

  void updateSettings(TimelineSettings newSettings) {
    state = newSettings;
  }

  void updateZoomLevel(TimelineZoom zoomLevel) {
    state = state.copyWith(zoomLevel: zoomLevel);
  }

  void toggleShowWeekends() {
    state = state.copyWith(showWeekends: !state.showWeekends);
  }

  void toggleShowDependencies() {
    state = state.copyWith(showDependencies: !state.showDependencies);
  }

  void toggleShowMilestones() {
    state = state.copyWith(showMilestones: !state.showMilestones);
  }

  void toggleShowCriticalPath() {
    state = state.copyWith(showCriticalPath: !state.showCriticalPath);
  }

  void toggleShowProgress() {
    state = state.copyWith(showProgress: !state.showProgress);
  }

  void updateDateRange(DateTime? startDate, DateTime? endDate) {
    state = state.copyWith(startDate: startDate, endDate: endDate);
  }

  void updateIncludedProjects(List<String> projectIds) {
    state = state.copyWith(includedProjectIds: projectIds);
  }

  void updateVisibleTaskStatuses(List<String> statuses) {
    state = state.copyWith(visibleTaskStatuses: statuses);
  }

  void updateColorTheme(TimelineColorTheme theme) {
    state = state.copyWith(colorTheme: theme);
  }

  void updateWorkingHours(int startHour, int endHour) {
    state = state.copyWith(
      workingHoursStart: startHour,
      workingHoursEnd: endHour,
    );
  }

  void updateWorkingDays(List<int> workingDays) {
    state = state.copyWith(workingDays: workingDays);
  }

  void resetToDefaults() {
    state = TimelineSettings.defaultSettings();
  }
}

// Timeline data provider - combines all timeline-related data
final timelineDataProvider = StateNotifierProvider<TimelineDataNotifier, AsyncValue<TimelineData>>(
  (ref) => TimelineDataNotifier(ref.read(timelineServiceProvider), ref),
);

class TimelineDataNotifier extends StateNotifier<AsyncValue<TimelineData>> {
  final TimelineService _timelineService;
  final Ref _ref;

  TimelineDataNotifier(this._timelineService, this._ref) : super(const AsyncValue.loading()) {
    loadTimelineData();
  }

  Future<void> loadTimelineData() async {
    state = const AsyncValue.loading();
    
    try {
      final settings = _ref.read(timelineSettingsProvider);
      
      // Load timeline data based on current settings
      final timelineData = await _timelineService.getTimelineData(
        projectIds: settings.includedProjectIds,
        startDate: settings.startDate,
        endDate: settings.endDate,
        visibleStatuses: settings.visibleTaskStatuses,
      );
      
      state = AsyncValue.data(timelineData);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshData() async {
    await loadTimelineData();
  }

  Future<void> updateTask(TaskModel updatedTask) async {
    try {
      await _timelineService.updateTask(updatedTask);
      await loadTimelineData(); // Refresh data after update
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> rescheduleTask(
    TaskModel task,
    DateTime newStartDate,
    DateTime newEndDate,
  ) async {
    try {
      await _timelineService.rescheduleTask(task, newStartDate, newEndDate);
      await loadTimelineData(); // Refresh data after reschedule
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> createDependency(TimelineDependency dependency) async {
    try {
      await _timelineService.createDependency(dependency);
      await loadTimelineData(); // Refresh data after creating dependency
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> removeDependency(String dependencyId) async {
    try {
      await _timelineService.removeDependency(dependencyId);
      await loadTimelineData(); // Refresh data after removing dependency
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> createMilestone(TimelineMilestone milestone) async {
    try {
      await _timelineService.createMilestone(milestone);
      await loadTimelineData(); // Refresh data after creating milestone
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateMilestone(TimelineMilestone milestone) async {
    try {
      await _timelineService.updateMilestone(milestone);
      await loadTimelineData(); // Refresh data after updating milestone
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteMilestone(String milestoneId) async {
    try {
      await _timelineService.deleteMilestone(milestoneId);
      await loadTimelineData(); // Refresh data after deleting milestone
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Selected task provider for timeline interactions
final selectedTimelineTaskProvider = StateProvider<TaskModel?>((ref) => null);

// Selected milestone provider for timeline interactions
final selectedTimelineMilestoneProvider = StateProvider<TimelineMilestone?>((ref) => null);

// Timeline filter providers
final timelineProjectFilterProvider = StateProvider<List<String>>((ref) => []);

final timelineStatusFilterProvider = StateProvider<List<String>>((ref) => [
  'pending',
  'in_progress',
]);

final timelineDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

// Critical path analysis provider
final criticalPathProvider = FutureProvider<List<String>>((ref) async {
  final timelineData = ref.watch(timelineDataProvider).valueOrNull;
  if (timelineData == null) return [];
  
  final timelineService = ref.read(timelineServiceProvider);
  return await timelineService.calculateCriticalPath(
    tasks: timelineData.tasks,
    dependencies: timelineData.dependencies,
  );
});

// Resource allocation provider
final resourceAllocationProvider = FutureProvider<Map<String, List<TaskModel>>>((ref) async {
  final timelineData = ref.watch(timelineDataProvider).valueOrNull;
  if (timelineData == null) return {};
  
  final timelineService = ref.read(timelineServiceProvider);
  return await timelineService.getResourceAllocation(timelineData.tasks);
});

// Timeline statistics provider
final timelineStatsProvider = FutureProvider<TimelineStats>((ref) async {
  final timelineData = ref.watch(timelineDataProvider).valueOrNull;
  if (timelineData == null) return TimelineStats.empty();
  
  final timelineService = ref.read(timelineServiceProvider);
  return await timelineService.calculateTimelineStats(
    tasks: timelineData.tasks,
    projects: timelineData.projects,
    milestones: timelineData.milestones,
    dependencies: timelineData.dependencies,
  );
});

// Timeline drag state provider (for drag and drop operations)
final timelineDragStateProvider = StateNotifierProvider<TimelineDragStateNotifier, TimelineDragState>(
  (ref) => TimelineDragStateNotifier(),
);

class TimelineDragState {
  final TaskModel? draggedTask;
  final bool isDragging;
  final Offset? dragPosition;
  final DateTime? proposedStartDate;
  final DateTime? proposedEndDate;

  const TimelineDragState({
    this.draggedTask,
    this.isDragging = false,
    this.dragPosition,
    this.proposedStartDate,
    this.proposedEndDate,
  });

  TimelineDragState copyWith({
    TaskModel? draggedTask,
    bool? isDragging,
    Offset? dragPosition,
    DateTime? proposedStartDate,
    DateTime? proposedEndDate,
  }) {
    return TimelineDragState(
      draggedTask: draggedTask ?? this.draggedTask,
      isDragging: isDragging ?? this.isDragging,
      dragPosition: dragPosition ?? this.dragPosition,
      proposedStartDate: proposedStartDate ?? this.proposedStartDate,
      proposedEndDate: proposedEndDate ?? this.proposedEndDate,
    );
  }

  static const empty = TimelineDragState();
}

class TimelineDragStateNotifier extends StateNotifier<TimelineDragState> {
  TimelineDragStateNotifier() : super(TimelineDragState.empty);

  void startDrag(TaskModel task, Offset position) {
    state = state.copyWith(
      draggedTask: task,
      isDragging: true,
      dragPosition: position,
    );
  }

  void updateDragPosition(
    Offset position,
    DateTime? proposedStart,
    DateTime? proposedEnd,
  ) {
    state = state.copyWith(
      dragPosition: position,
      proposedStartDate: proposedStart,
      proposedEndDate: proposedEnd,
    );
  }

  void endDrag() {
    state = TimelineDragState.empty;
  }

  void cancelDrag() {
    state = TimelineDragState.empty;
  }
}

// Timeline export provider
final timelineExportProvider = FutureProvider.family<String, TimelineExportRequest>((ref, request) async {
  final timelineData = ref.read(timelineDataProvider).valueOrNull;
  if (timelineData == null) throw Exception('No timeline data available');
  
  final timelineService = ref.read(timelineServiceProvider);
  return await timelineService.exportTimeline(timelineData, request);
});

// Data classes for providers
class TimelineStats {
  final int totalTasks;
  final int completedTasks;
  final int overdueTasks;
  final int upcomingTasks;
  final int totalProjects;
  final int activeProjects;
  final int totalMilestones;
  final int completedMilestones;
  final int overdueMilestones;
  final Duration averageTaskDuration;
  final Duration totalProjectDuration;
  final double overallProgress;
  final List<TaskModel> criticalTasks;

  const TimelineStats({
    required this.totalTasks,
    required this.completedTasks,
    required this.overdueTasks,
    required this.upcomingTasks,
    required this.totalProjects,
    required this.activeProjects,
    required this.totalMilestones,
    required this.completedMilestones,
    required this.overdueMilestones,
    required this.averageTaskDuration,
    required this.totalProjectDuration,
    required this.overallProgress,
    required this.criticalTasks,
  });

  static TimelineStats empty() {
    return const TimelineStats(
      totalTasks: 0,
      completedTasks: 0,
      overdueTasks: 0,
      upcomingTasks: 0,
      totalProjects: 0,
      activeProjects: 0,
      totalMilestones: 0,
      completedMilestones: 0,
      overdueMilestones: 0,
      averageTaskDuration: Duration.zero,
      totalProjectDuration: Duration.zero,
      overallProgress: 0.0,
      criticalTasks: [],
    );
  }
}

enum TimelineExportFormat {
  png,
  pdf,
  csv,
  xlsx,
}

class TimelineExportRequest {
  final TimelineExportFormat format;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> includeProjectIds;
  final bool includeDetails;
  final bool includeDependencies;
  final bool includeMilestones;

  const TimelineExportRequest({
    required this.format,
    this.startDate,
    this.endDate,
    this.includeProjectIds = const [],
    this.includeDetails = true,
    this.includeDependencies = true,
    this.includeMilestones = true,
  });
}

// Timeline view state provider (for UI state management)
final timelineViewStateProvider = StateNotifierProvider<TimelineViewStateNotifier, TimelineViewState>(
  (ref) => TimelineViewStateNotifier(),
);

class TimelineViewState {
  final double scrollOffsetX;
  final double scrollOffsetY;
  final DateTime viewportStart;
  final DateTime viewportEnd;
  final bool isLoading;
  final String? error;
  final TaskModel? hoveredTask;
  final TimelineMilestone? hoveredMilestone;
  final TimelineDependency? hoveredDependency;

  const TimelineViewState({
    this.scrollOffsetX = 0.0,
    this.scrollOffsetY = 0.0,
    required this.viewportStart,
    required this.viewportEnd,
    this.isLoading = false,
    this.error,
    this.hoveredTask,
    this.hoveredMilestone,
    this.hoveredDependency,
  });

  TimelineViewState copyWith({
    double? scrollOffsetX,
    double? scrollOffsetY,
    DateTime? viewportStart,
    DateTime? viewportEnd,
    bool? isLoading,
    String? error,
    TaskModel? hoveredTask,
    TimelineMilestone? hoveredMilestone,
    TimelineDependency? hoveredDependency,
  }) {
    return TimelineViewState(
      scrollOffsetX: scrollOffsetX ?? this.scrollOffsetX,
      scrollOffsetY: scrollOffsetY ?? this.scrollOffsetY,
      viewportStart: viewportStart ?? this.viewportStart,
      viewportEnd: viewportEnd ?? this.viewportEnd,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hoveredTask: hoveredTask ?? this.hoveredTask,
      hoveredMilestone: hoveredMilestone ?? this.hoveredMilestone,
      hoveredDependency: hoveredDependency ?? this.hoveredDependency,
    );
  }
}

class TimelineViewStateNotifier extends StateNotifier<TimelineViewState> {
  TimelineViewStateNotifier() : super(TimelineViewState(
    viewportStart: DateTime.now().subtract(const Duration(days: 30)),
    viewportEnd: DateTime.now().add(const Duration(days: 90)),
  ));

  void updateScrollOffset(double x, double y) {
    state = state.copyWith(scrollOffsetX: x, scrollOffsetY: y);
  }

  void updateViewport(DateTime start, DateTime end) {
    state = state.copyWith(viewportStart: start, viewportEnd: end);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void setHoveredTask(TaskModel? task) {
    state = state.copyWith(hoveredTask: task);
  }

  void setHoveredMilestone(TimelineMilestone? milestone) {
    state = state.copyWith(hoveredMilestone: milestone);
  }

  void setHoveredDependency(TimelineDependency? dependency) {
    state = state.copyWith(hoveredDependency: dependency);
  }

  void clearHoverStates() {
    state = state.copyWith(
      hoveredTask: null,
      hoveredMilestone: null,
      hoveredDependency: null,
    );
  }
}