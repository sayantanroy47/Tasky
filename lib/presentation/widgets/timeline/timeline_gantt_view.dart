import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/typography_constants.dart';
import '../../../core/design_system/design_tokens.dart';
import '../../../domain/entities/task_model.dart';
import '../../../domain/entities/project.dart';
import '../../../domain/entities/timeline_milestone.dart';
import '../../../domain/entities/timeline_dependency.dart';
import '../../../domain/entities/timeline_settings.dart';
import '../../providers/timeline_providers.dart';
import '../glassmorphism_container.dart';
import 'timeline_header.dart';
import 'task_timeline_row.dart';
import 'milestone_timeline_marker.dart';
import 'dependency_connection_painter.dart';
import 'timeline_controls.dart';

/// Main Timeline/Gantt chart view with comprehensive project management features
/// 
/// Features:
/// - Multi-project timeline visualization
/// - Drag-and-drop task rescheduling
/// - Dependency visualization with connecting lines
/// - Milestone markers and management
/// - Critical path analysis
/// - Zoom levels (hours, days, weeks, months)
/// - Progress tracking and completion status
/// - Resource allocation timeline
/// - Performance optimizations with virtual scrolling
class TimelineGanttView extends ConsumerStatefulWidget {
  /// List of project IDs to display (empty for all projects)
  final List<String> projectIds;
  
  /// Initial timeline settings
  final TimelineSettings? initialSettings;
  
  /// Whether to show the timeline controls panel
  final bool showControls;
  
  /// Height of the timeline view
  final double? height;
  
  /// Callback when a task is selected
  final void Function(TaskModel task)? onTaskSelected;
  
  /// Callback when a milestone is selected
  final void Function(TimelineMilestone milestone)? onMilestoneSelected;
  
  /// Callback when a task is rescheduled via drag and drop
  final void Function(TaskModel task, DateTime newStartDate, DateTime newEndDate)? onTaskRescheduled;

  const TimelineGanttView({
    super.key,
    this.projectIds = const [],
    this.initialSettings,
    this.showControls = true,
    this.height,
    this.onTaskSelected,
    this.onMilestoneSelected,
    this.onTaskRescheduled,
  });

  @override
  ConsumerState<TimelineGanttView> createState() => _TimelineGanttViewState();
}

class _TimelineGanttViewState extends ConsumerState<TimelineGanttView>
    with TickerProviderStateMixin {
  late ScrollController _horizontalScrollController;
  late ScrollController _verticalScrollController;
  late AnimationController _zoomAnimationController;

  // Timeline viewport state
  DateTime _viewportStart = DateTime.now().subtract(const Duration(days: 30));
  DateTime _viewportEnd = DateTime.now().add(const Duration(days: 90));
  double _scrollOffset = 0.0;
  
  // Interaction state
  TaskModel? _draggedTask;
  Offset? _dragOffset;
  bool _isDragging = false;
  
  // Performance optimizations
  final Map<String, Widget> _taskRowCache = {};
  
  // Virtual scrolling
  late double _itemHeight;
  int _firstVisibleIndex = 0;
  int _lastVisibleIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeViewport();
  }

  void _initializeControllers() {
    _horizontalScrollController = ScrollController();
    _verticalScrollController = ScrollController();
    
    _zoomAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Listen to scroll changes for performance optimization
    _horizontalScrollController.addListener(_onHorizontalScroll);
    _verticalScrollController.addListener(_onVerticalScroll);
  }

  void _initializeViewport() {
    // Initialize with current settings
    final settings = widget.initialSettings ?? TimelineSettings.defaultSettings();
    _itemHeight = settings.taskRowHeight;
    
    // Set viewport based on zoom level
    _updateViewportForZoom(settings.zoomLevel);
  }

  void _updateViewportForZoom(TimelineZoom zoom) {
    switch (zoom) {
      case TimelineZoom.hours:
        _viewportStart = DateTime.now().subtract(const Duration(days: 3));
        _viewportEnd = DateTime.now().add(const Duration(days: 7));
        break;
      case TimelineZoom.days:
        _viewportStart = DateTime.now().subtract(const Duration(days: 14));
        _viewportEnd = DateTime.now().add(const Duration(days: 30));
        break;
      case TimelineZoom.weeks:
        _viewportStart = DateTime.now().subtract(const Duration(days: 60));
        _viewportEnd = DateTime.now().add(const Duration(days: 120));
        break;
      case TimelineZoom.months:
        _viewportStart = DateTime.now().subtract(const Duration(days: 180));
        _viewportEnd = DateTime.now().add(const Duration(days: 365));
        break;
    }
  }

  void _onHorizontalScroll() {
    if (_horizontalScrollController.hasClients) {
      _scrollOffset = _horizontalScrollController.offset;
      _updateVisibleTimeRange();
    }
  }

  void _onVerticalScroll() {
    if (_verticalScrollController.hasClients && mounted) {
      _updateVisibleItemRange();
    }
  }

  void _updateVisibleTimeRange() {
    final settings = ref.read(timelineSettingsProvider);
    final pixelsPerTimeUnit = settings.pixelsPerTimeUnit;
    final viewportWidth = MediaQuery.of(context).size.width;
    
    final visibleDuration = Duration(
      milliseconds: (viewportWidth / pixelsPerTimeUnit * 
                    settings.timeUnit.inMilliseconds).round(),
    );
    
    setState(() {
      _viewportStart = _viewportStart.add(
        Duration(milliseconds: (_scrollOffset / pixelsPerTimeUnit * 
                               settings.timeUnit.inMilliseconds).round()),
      );
      _viewportEnd = _viewportStart.add(visibleDuration);
    });
  }

  void _updateVisibleItemRange() {
    final viewportHeight = MediaQuery.of(context).size.height;
    final visibleCount = (viewportHeight / _itemHeight).ceil() + 2; // Buffer
    
    setState(() {
      _firstVisibleIndex = (_verticalScrollController.offset / _itemHeight).floor();
      _lastVisibleIndex = math.min(
        _firstVisibleIndex + visibleCount,
        _getTotalItemCount(),
      );
    });
  }

  int _getTotalItemCount() {
    final timelineData = ref.read(timelineDataProvider);
    return timelineData.when(
      data: (data) => data.tasks.length + data.projects.length,
      loading: () => 0,
      error: (_, __) => 0,
    );
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    _zoomAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final timelineData = ref.watch(timelineDataProvider);
        final settings = ref.watch(timelineSettingsProvider);
        
        return timelineData.when(
          data: (data) => _buildTimelineView(context, data, settings),
          loading: () => _buildLoadingView(),
          error: (error, stack) => _buildErrorView(error.toString()),
        );
      },
    );
  }

  Widget _buildTimelineView(
    BuildContext context, 
    TimelineData data, 
    TimelineSettings settings,
  ) {
    return GlassmorphismContainer(
      level: GlassLevel.background,
      height: widget.height,
      child: Column(
        children: [
          // Timeline Header with date navigation and controls
          if (widget.showControls) ...[
            TimelineControls(
              settings: settings,
              onSettingsChanged: (newSettings) => 
                ref.read(timelineSettingsProvider.notifier).updateSettings(newSettings),
              onZoomChanged: _handleZoomChange,
              onDateRangeChanged: _handleDateRangeChange,
            ),
            const SizedBox(height: TypographyConstants.spacingSmall),
          ],
          
          // Timeline Header
          TimelineHeader(
            startDate: _viewportStart,
            endDate: _viewportEnd,
            settings: settings,
            scrollController: _horizontalScrollController,
            onDateTap: _handleDateTap,
          ),
          
          // Timeline Content Area
          Expanded(
            child: _buildTimelineContent(context, data, settings),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineContent(
    BuildContext context,
    TimelineData data,
    TimelineSettings settings,
  ) {
    return Stack(
      children: [
        // Main timeline scrollable area
        Scrollbar(
          controller: _verticalScrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _verticalScrollController,
            child: SizedBox(
              height: _calculateTimelineHeight(data),
              child: Stack(
                children: [
                  // Background grid
                  _buildTimelineGrid(context, settings),
                  
                  // Today marker
                  if (settings.showTodayMarker)
                    _buildTodayMarker(context, settings),
                  
                  // Task rows (virtual scrolling)
                  _buildVirtualizedTaskRows(context, data, settings),
                  
                  // Milestone markers
                  if (settings.showMilestones)
                    _buildMilestoneMarkers(context, data, settings),
                  
                  // Dependency connections
                  if (settings.showDependencies)
                    _buildDependencyConnections(context, data, settings),
                  
                  // Drag overlay
                  if (_isDragging && _draggedTask != null)
                    _buildDragOverlay(context, settings),
                ],
              ),
            ),
          ),
        ),
        
        // Horizontal scrollbar
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Scrollbar(
            controller: _horizontalScrollController,
            thumbVisibility: true,
            notificationPredicate: (notification) => false, // Prevent double scrolling
            child: SingleChildScrollView(
              controller: _horizontalScrollController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: _calculateTimelineWidth(settings),
                height: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVirtualizedTaskRows(
    BuildContext context,
    TimelineData data,
    TimelineSettings settings,
  ) {
    // Create a list of timeline items with proper typing
    final timelineItems = <TimelineItem>[];
    
    // Add projects as timeline items
    for (final project in data.projects) {
      timelineItems.add(TimelineItem.project(project));
    }
    
    // Add tasks as timeline items
    for (final task in data.tasks) {
      timelineItems.add(TimelineItem.task(task));
    }
    
    final visibleItems = timelineItems.skip(_firstVisibleIndex)
                                     .take(_lastVisibleIndex - _firstVisibleIndex)
                                     .toList();
    
    return ListView.builder(
      controller: ScrollController(), // Separate controller for virtual scrolling
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: visibleItems.length,
      itemExtent: settings.taskRowHeight,
      itemBuilder: (context, index) {
        final actualIndex = _firstVisibleIndex + index;
        final item = visibleItems[index];
        
        // Use cache for performance
        final cacheKey = '${item.type}_${item.id}_${item.updatedAt?.millisecondsSinceEpoch}';
        if (_taskRowCache.containsKey(cacheKey)) {
          return _taskRowCache[cacheKey]!;
        }
        
        Widget widget;
        switch (item.type) {
          case TimelineItemType.project:
            widget = _buildProjectHeaderRow(context, item.project!, settings, actualIndex);
            break;
          case TimelineItemType.task:
            widget = _buildTaskRow(context, item.task!, settings, actualIndex);
            break;
        }
        
        // Cache the widget
        _taskRowCache[cacheKey] = widget;
        
        return widget;
      },
    );
  }

  Widget _buildProjectHeaderRow(
    BuildContext context,
    Project project,
    TimelineSettings settings,
    int index,
  ) {
    return Container(
      height: settings.taskRowHeight,
      decoration: BoxDecoration(
        color: Color(int.parse('0xFF${project.color.substring(1)}')).withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TypographyConstants.paddingMedium,
          vertical: TypographyConstants.paddingSmall,
        ),
        child: Row(
          children: [
            // Project color indicator
            Container(
              width: 4,
              height: settings.taskRowHeight * 0.6,
              decoration: BoxDecoration(
                color: Color(int.parse('0xFF${project.color.substring(1)}')),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: TypographyConstants.spacingSmall),
            
            // Project icon and name
            Icon(
              PhosphorIcons.folder(),
              size: TypographyConstants.bodyLarge,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: TypographyConstants.spacingSmall),
            
            Expanded(
              child: Text(
                project.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: TypographyConstants.medium,
                  color: Theme.of(context).colorScheme.primary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // Project stats
            if (project.taskCount > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: TypographyConstants.paddingSmall,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
                ),
                child: Text(
                  '${project.taskCount} tasks',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTaskRow(
    BuildContext context,
    TaskModel task,
    TimelineSettings settings,
    int index,
  ) {
    return GestureDetector(
      onTap: () => widget.onTaskSelected?.call(task),
      onPanStart: settings.enableDragAndDrop ? (details) => _startTaskDrag(task, details) : null,
      onPanUpdate: settings.enableDragAndDrop ? _updateTaskDrag : null,
      onPanEnd: settings.enableDragAndDrop ? _endTaskDrag : null,
      child: TaskTimelineRow(
        task: task,
        settings: settings,
        startDate: _viewportStart,
        endDate: _viewportEnd,
        isSelected: false, // TODO: Track selection state
        isDragging: _isDragging && _draggedTask?.id == task.id,
        onTaskTap: () => widget.onTaskSelected?.call(task),
        onProgressChanged: (progress) => _handleTaskProgressChange(task, progress),
      ),
    );
  }

  Widget _buildTimelineGrid(BuildContext context, TimelineSettings settings) {
    return CustomPaint(
      size: Size(
        _calculateTimelineWidth(settings),
        _calculateTimelineHeight(ref.read(timelineDataProvider).valueOrNull ?? TimelineData.empty()),
      ),
      painter: TimelineGridPainter(
        startDate: _viewportStart,
        endDate: _viewportEnd,
        settings: settings,
        theme: Theme.of(context),
      ),
    );
  }

  Widget _buildTodayMarker(BuildContext context, TimelineSettings settings) {
    final today = DateTime.now();
    final todayX = _dateToPixel(today, settings);
    
    return Positioned(
      left: todayX,
      top: 0,
      bottom: 0,
      child: Container(
        width: 2,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error,
              borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
            ),
            child: Text(
              'Today',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onError,
                fontWeight: TypographyConstants.medium,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMilestoneMarkers(
    BuildContext context,
    TimelineData data,
    TimelineSettings settings,
  ) {
    return Stack(
      children: data.milestones.map((milestone) {
        final milestoneX = _dateToPixel(milestone.date, settings);
        
        return Positioned(
          left: milestoneX - 12, // Center the marker
          top: 0,
          child: MilestoneTimelineMarker(
            milestone: milestone,
            height: _calculateTimelineHeight(data),
            onTap: () => widget.onMilestoneSelected?.call(milestone),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDependencyConnections(
    BuildContext context,
    TimelineData data,
    TimelineSettings settings,
  ) {
    return CustomPaint(
      size: Size(
        _calculateTimelineWidth(settings),
        _calculateTimelineHeight(data),
      ),
      painter: DependencyConnectionPainter(
        dependencies: data.dependencies,
        tasks: data.tasks,
        settings: settings,
        startDate: _viewportStart,
        theme: Theme.of(context),
        taskRowHeight: settings.taskRowHeight,
      ),
    );
  }

  Widget _buildDragOverlay(BuildContext context, TimelineSettings settings) {
    if (_draggedTask == null || _dragOffset == null) return const SizedBox.shrink();
    
    return Positioned(
      left: _dragOffset!.dx,
      top: _dragOffset!.dy,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: TypographyConstants.paddingMedium,
            vertical: TypographyConstants.paddingSmall,
          ),
          constraints: const BoxConstraints(maxWidth: 200),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _draggedTask!.title,
                style: Theme.of(context).textTheme.titleSmall,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                'Drag to reschedule',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const GlassmorphismContainer(
      level: GlassLevel.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: TypographyConstants.spacingMedium),
            Text('Loading timeline...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return GlassmorphismContainer(
      level: GlassLevel.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.warning(),
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: TypographyConstants.spacingMedium),
            Text(
              'Failed to load timeline',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: TypographyConstants.spacingSmall),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Event handlers
  void _handleZoomChange(TimelineZoom newZoom) {
    final newSettings = ref.read(timelineSettingsProvider).copyWith(
      zoomLevel: newZoom,
    );
    ref.read(timelineSettingsProvider.notifier).updateSettings(newSettings);
    _updateViewportForZoom(newZoom);
    _clearTaskRowCache();
  }

  void _handleDateRangeChange(DateTime start, DateTime end) {
    setState(() {
      _viewportStart = start;
      _viewportEnd = end;
    });
    _clearTaskRowCache();
  }

  void _handleDateTap(DateTime date) {
    // Center the timeline on the tapped date
    final settings = ref.read(timelineSettingsProvider);
    final targetX = _dateToPixel(date, settings);
    final viewportWidth = MediaQuery.of(context).size.width;
    final centerOffset = targetX - (viewportWidth / 2);
    
    _horizontalScrollController.animateTo(
      math.max(0, centerOffset),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _handleTaskProgressChange(TaskModel task, double progress) {
    // Update task progress
    final updatedTask = task.copyWith(
      metadata: {
        ...task.metadata,
        'progress': progress,
      },
    );
    
    // Notify about task update
    ref.read(timelineDataProvider.notifier).updateTask(updatedTask);
    _clearTaskRowCache();
  }

  // Drag and drop handlers
  void _startTaskDrag(TaskModel task, DragStartDetails details) {
    setState(() {
      _draggedTask = task;
      _isDragging = true;
      _dragOffset = details.localPosition;
    });
    
    HapticFeedback.lightImpact();
  }

  void _updateTaskDrag(DragUpdateDetails details) {
    setState(() {
      _dragOffset = details.localPosition;
    });
  }

  void _endTaskDrag(DragEndDetails details) {
    if (_draggedTask != null && _dragOffset != null) {
      final settings = ref.read(timelineSettingsProvider);
      
      // Calculate new start date based on drop position
      final newStartDate = _pixelToDate(_dragOffset!.dx, settings);
      final duration = _draggedTask!.dueDate?.difference(_draggedTask!.createdAt) ?? 
                      Duration(hours: settings.defaultTaskDurationHours);
      final newEndDate = newStartDate.add(duration);
      
      // Call the reschedule callback
      widget.onTaskRescheduled?.call(_draggedTask!, newStartDate, newEndDate);
      
      HapticFeedback.mediumImpact();
    }
    
    setState(() {
      _draggedTask = null;
      _isDragging = false;
      _dragOffset = null;
    });
    
    _clearTaskRowCache();
  }

  // Utility methods
  double _dateToPixel(DateTime date, TimelineSettings settings) {
    final diff = date.difference(_viewportStart);
    return (diff.inMilliseconds / settings.timeUnit.inMilliseconds) * settings.pixelsPerTimeUnit;
  }

  DateTime _pixelToDate(double pixel, TimelineSettings settings) {
    final timeUnits = pixel / settings.pixelsPerTimeUnit;
    final milliseconds = (timeUnits * settings.timeUnit.inMilliseconds).round();
    return _viewportStart.add(Duration(milliseconds: milliseconds));
  }

  double _calculateTimelineWidth(TimelineSettings settings) {
    final duration = _viewportEnd.difference(_viewportStart);
    return (duration.inMilliseconds / settings.timeUnit.inMilliseconds) * settings.pixelsPerTimeUnit;
  }

  double _calculateTimelineHeight(TimelineData data) {
    final itemCount = data.tasks.length + data.projects.length;
    final settings = ref.read(timelineSettingsProvider);
    return itemCount * settings.taskRowHeight;
  }

  void _clearTaskRowCache() {
    _taskRowCache.clear();
  }
}

/// Custom painter for timeline grid background
class TimelineGridPainter extends CustomPainter {
  final DateTime startDate;
  final DateTime endDate;
  final TimelineSettings settings;
  final ThemeData theme;

  TimelineGridPainter({
    required this.startDate,
    required this.endDate,
    required this.settings,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.dividerColor.withValues(alpha: 0.1)
      ..strokeWidth = 0.5;

    // Draw vertical grid lines
    final duration = endDate.difference(startDate);
    final timeUnits = duration.inMilliseconds / settings.timeUnit.inMilliseconds;
    
    for (int i = 0; i <= timeUnits; i++) {
      final x = i * settings.pixelsPerTimeUnit;
      if (x <= size.width) {
        canvas.drawLine(
          Offset(x, 0),
          Offset(x, size.height),
          paint,
        );
      }
    }

    // Draw horizontal grid lines
    final rowHeight = settings.taskRowHeight;
    for (double y = 0; y <= size.height; y += rowHeight) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(TimelineGridPainter oldDelegate) {
    return startDate != oldDelegate.startDate ||
           endDate != oldDelegate.endDate ||
           settings != oldDelegate.settings ||
           theme != oldDelegate.theme;
  }
}

/// Data model for timeline view
class TimelineData {
  final List<Project> projects;
  final List<TaskModel> tasks;
  final List<TimelineMilestone> milestones;
  final List<TimelineDependency> dependencies;

  const TimelineData({
    required this.projects,
    required this.tasks,
    required this.milestones,
    required this.dependencies,
  });

  factory TimelineData.empty() {
    return const TimelineData(
      projects: [],
      tasks: [],
      milestones: [],
      dependencies: [],
    );
  }
}

/// Timeline item wrapper for virtual scrolling
class TimelineItem {
  final TimelineItemType type;
  final Project? project;
  final TaskModel? task;
  
  const TimelineItem._({
    required this.type,
    this.project,
    this.task,
  });
  
  factory TimelineItem.project(Project project) {
    return TimelineItem._(
      type: TimelineItemType.project,
      project: project,
    );
  }
  
  factory TimelineItem.task(TaskModel task) {
    return TimelineItem._(
      type: TimelineItemType.task,
      task: task,
    );
  }
  
  String get id {
    switch (type) {
      case TimelineItemType.project:
        return project!.id;
      case TimelineItemType.task:
        return task!.id;
    }
  }
  
  DateTime? get updatedAt {
    switch (type) {
      case TimelineItemType.project:
        return project!.updatedAt;
      case TimelineItemType.task:
        return task!.updatedAt;
    }
  }
}

enum TimelineItemType {
  project,
  task,
}