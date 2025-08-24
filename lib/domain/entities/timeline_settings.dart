import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'timeline_settings.g.dart';

/// Settings and configuration for timeline/Gantt chart views
/// 
/// Contains user preferences for timeline visualization including
/// zoom levels, display options, and view configurations.
@JsonSerializable()
class TimelineSettings extends Equatable {
  /// Current zoom level for the timeline
  final TimelineZoom zoomLevel;
  
  /// Whether to show weekends in the timeline
  final bool showWeekends;
  
  /// Whether to show task dependencies
  final bool showDependencies;
  
  /// Whether to show milestone markers
  final bool showMilestones;
  
  /// Whether to show critical path highlighting
  final bool showCriticalPath;
  
  /// Whether to show task progress bars
  final bool showProgress;
  
  /// Whether to show resource allocation
  final bool showResourceAllocation;
  
  /// Whether to show overdue tasks with special highlighting
  final bool highlightOverdue;
  
  /// Whether to show today marker
  final bool showTodayMarker;
  
  /// Timeline start date (null for automatic)
  final DateTime? startDate;
  
  /// Timeline end date (null for automatic)
  final DateTime? endDate;
  
  /// List of project IDs to include in timeline (empty for all)
  final List<String> includedProjectIds;
  
  /// List of task status filters to show
  final List<String> visibleTaskStatuses;
  
  /// Timeline color theme
  final TimelineColorTheme colorTheme;
  
  /// Working hours start (24-hour format)
  final int workingHoursStart;
  
  /// Working hours end (24-hour format)  
  final int workingHoursEnd;
  
  /// Working days (1 = Monday, 7 = Sunday)
  final List<int> workingDays;
  
  /// Default task duration in hours for new tasks
  final int defaultTaskDurationHours;
  
  /// Whether to auto-schedule tasks based on dependencies
  final bool autoSchedule;
  
  /// Whether to enable drag and drop rescheduling
  final bool enableDragAndDrop;
  
  /// Whether to show task details on hover
  final bool showTaskDetailsOnHover;
  
  /// Timeline header height in pixels
  final double headerHeight;
  
  /// Task row height in pixels
  final double taskRowHeight;
  
  /// When these settings were last updated
  final DateTime updatedAt;

  const TimelineSettings({
    this.zoomLevel = TimelineZoom.weeks,
    this.showWeekends = true,
    this.showDependencies = true,
    this.showMilestones = true,
    this.showCriticalPath = false,
    this.showProgress = true,
    this.showResourceAllocation = false,
    this.highlightOverdue = true,
    this.showTodayMarker = true,
    this.startDate,
    this.endDate,
    this.includedProjectIds = const [],
    this.visibleTaskStatuses = const ['pending', 'in_progress'],
    this.colorTheme = TimelineColorTheme.material,
    this.workingHoursStart = 9,
    this.workingHoursEnd = 17,
    this.workingDays = const [1, 2, 3, 4, 5], // Monday to Friday
    this.defaultTaskDurationHours = 8,
    this.autoSchedule = false,
    this.enableDragAndDrop = true,
    this.showTaskDetailsOnHover = true,
    this.headerHeight = 80.0,
    this.taskRowHeight = 48.0,
    required this.updatedAt,
  });

  /// Creates default timeline settings
  factory TimelineSettings.defaultSettings() {
    return TimelineSettings(
      updatedAt: DateTime.now(),
    );
  }

  /// Creates a TimelineSettings from JSON
  factory TimelineSettings.fromJson(Map<String, dynamic> json) =>
      _$TimelineSettingsFromJson(json);

  /// Converts this TimelineSettings to JSON
  Map<String, dynamic> toJson() => _$TimelineSettingsToJson(this);

  /// Creates a copy with updated fields
  TimelineSettings copyWith({
    TimelineZoom? zoomLevel,
    bool? showWeekends,
    bool? showDependencies,
    bool? showMilestones,
    bool? showCriticalPath,
    bool? showProgress,
    bool? showResourceAllocation,
    bool? highlightOverdue,
    bool? showTodayMarker,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? includedProjectIds,
    List<String>? visibleTaskStatuses,
    TimelineColorTheme? colorTheme,
    int? workingHoursStart,
    int? workingHoursEnd,
    List<int>? workingDays,
    int? defaultTaskDurationHours,
    bool? autoSchedule,
    bool? enableDragAndDrop,
    bool? showTaskDetailsOnHover,
    double? headerHeight,
    double? taskRowHeight,
    DateTime? updatedAt,
  }) {
    return TimelineSettings(
      zoomLevel: zoomLevel ?? this.zoomLevel,
      showWeekends: showWeekends ?? this.showWeekends,
      showDependencies: showDependencies ?? this.showDependencies,
      showMilestones: showMilestones ?? this.showMilestones,
      showCriticalPath: showCriticalPath ?? this.showCriticalPath,
      showProgress: showProgress ?? this.showProgress,
      showResourceAllocation: showResourceAllocation ?? this.showResourceAllocation,
      highlightOverdue: highlightOverdue ?? this.highlightOverdue,
      showTodayMarker: showTodayMarker ?? this.showTodayMarker,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      includedProjectIds: includedProjectIds ?? this.includedProjectIds,
      visibleTaskStatuses: visibleTaskStatuses ?? this.visibleTaskStatuses,
      colorTheme: colorTheme ?? this.colorTheme,
      workingHoursStart: workingHoursStart ?? this.workingHoursStart,
      workingHoursEnd: workingHoursEnd ?? this.workingHoursEnd,
      workingDays: workingDays ?? this.workingDays,
      defaultTaskDurationHours: defaultTaskDurationHours ?? this.defaultTaskDurationHours,
      autoSchedule: autoSchedule ?? this.autoSchedule,
      enableDragAndDrop: enableDragAndDrop ?? this.enableDragAndDrop,
      showTaskDetailsOnHover: showTaskDetailsOnHover ?? this.showTaskDetailsOnHover,
      headerHeight: headerHeight ?? this.headerHeight,
      taskRowHeight: taskRowHeight ?? this.taskRowHeight,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Returns working hours as duration
  Duration get workingHoursDuration {
    return Duration(hours: workingHoursEnd - workingHoursStart);
  }

  /// Returns true if the given day of week is a working day
  bool isWorkingDay(int dayOfWeek) {
    return workingDays.contains(dayOfWeek);
  }

  /// Returns true if weekends should be shown
  bool get shouldShowWeekends => showWeekends;

  /// Returns the time unit for the current zoom level
  Duration get timeUnit {
    switch (zoomLevel) {
      case TimelineZoom.hours:
        return const Duration(hours: 1);
      case TimelineZoom.days:
        return const Duration(days: 1);
      case TimelineZoom.weeks:
        return const Duration(days: 7);
      case TimelineZoom.months:
        return const Duration(days: 30);
    }
  }

  /// Returns the number of pixels per time unit for current zoom
  double get pixelsPerTimeUnit {
    switch (zoomLevel) {
      case TimelineZoom.hours:
        return 24.0; // 24px per hour
      case TimelineZoom.days:
        return 80.0; // 80px per day
      case TimelineZoom.weeks:
        return 120.0; // 120px per week
      case TimelineZoom.months:
        return 100.0; // 100px per month
    }
  }

  @override
  List<Object?> get props => [
        zoomLevel,
        showWeekends,
        showDependencies,
        showMilestones,
        showCriticalPath,
        showProgress,
        showResourceAllocation,
        highlightOverdue,
        showTodayMarker,
        startDate,
        endDate,
        includedProjectIds,
        visibleTaskStatuses,
        colorTheme,
        workingHoursStart,
        workingHoursEnd,
        workingDays,
        defaultTaskDurationHours,
        autoSchedule,
        enableDragAndDrop,
        showTaskDetailsOnHover,
        headerHeight,
        taskRowHeight,
        updatedAt,
      ];

  @override
  String toString() {
    return 'TimelineSettings(zoomLevel: $zoomLevel, showWeekends: $showWeekends, '
           'showDependencies: $showDependencies, colorTheme: $colorTheme)';
  }
}

/// Timeline zoom levels
enum TimelineZoom {
  hours,
  days,
  weeks,
  months;

  /// Returns display name for the zoom level
  String get displayName {
    switch (this) {
      case TimelineZoom.hours:
        return 'Hours';
      case TimelineZoom.days:
        return 'Days';
      case TimelineZoom.weeks:
        return 'Weeks';
      case TimelineZoom.months:
        return 'Months';
    }
  }

  /// Returns icon name for the zoom level
  String get iconName {
    switch (this) {
      case TimelineZoom.hours:
        return 'clock';
      case TimelineZoom.days:
        return 'calendar';
      case TimelineZoom.weeks:
        return 'calendar-blank';
      case TimelineZoom.months:
        return 'calendar-check';
    }
  }
}

/// Timeline color themes
enum TimelineColorTheme {
  material,
  pastel,
  vibrant,
  monochrome;

  /// Returns display name for the color theme
  String get displayName {
    switch (this) {
      case TimelineColorTheme.material:
        return 'Material';
      case TimelineColorTheme.pastel:
        return 'Pastel';
      case TimelineColorTheme.vibrant:
        return 'Vibrant';
      case TimelineColorTheme.monochrome:
        return 'Monochrome';
    }
  }
}