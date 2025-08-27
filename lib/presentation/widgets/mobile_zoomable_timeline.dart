import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/typography_constants.dart';
import '../../core/design_system/design_tokens.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../../services/ui/mobile_gesture_service.dart';
import '../providers/task_providers.dart';
import 'enhanced_ux_widgets.dart';
import 'glassmorphism_container.dart';

/// Mobile-optimized zoomable timeline/Gantt chart with pinch-to-zoom
class MobileZoomableTimeline extends ConsumerStatefulWidget {
  final String projectId;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool enablePinchZoom;
  final bool enablePanNavigation;
  final double initialScale;

  const MobileZoomableTimeline({
    super.key,
    required this.projectId,
    this.startDate,
    this.endDate,
    this.enablePinchZoom = true,
    this.enablePanNavigation = true,
    this.initialScale = 1.0,
  });

  @override
  ConsumerState<MobileZoomableTimeline> createState() => _MobileZoomableTimelineState();
}

class _MobileZoomableTimelineState extends ConsumerState<MobileZoomableTimeline>
    with TickerProviderStateMixin {
  late AnimationController _zoomAnimationController;
  late AnimationController _panAnimationController;
  late AnimationController _loadingAnimationController;
  
  double _currentScale = 1.0;
  DateTime _viewportStart = DateTime.now().subtract(const Duration(days: 30));
  DateTime _viewportEnd = DateTime.now().add(const Duration(days: 30));
  
  final GlobalKey _timelineKey = GlobalKey();
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  
  // Timeline configuration
  static const double _dayWidth = 40.0;
  static const double _taskHeight = 50.0;
  static const double _headerHeight = 60.0;
  static const double _taskLaneHeight = 60.0;
  static const double _minScale = 0.3;
  static const double _maxScale = 3.0;
  static const int _maxVisibleDays = 365;

  @override
  void initState() {
    super.initState();
    _currentScale = widget.initialScale.clamp(_minScale, _maxScale);
    
    if (widget.startDate != null && widget.endDate != null) {
      _viewportStart = widget.startDate!;
      _viewportEnd = widget.endDate!;
    }
    
    _zoomAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _panAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _loadingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _zoomAnimationController.dispose();
    _panAnimationController.dispose();
    _loadingAnimationController.dispose();
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mobileGestureService = ref.read(mobileGestureServiceProvider);
    final tasksAsync = ref.watch(tasksForProjectProvider(widget.projectId));

    return tasksAsync.when(
      loading: () => _buildLoadingState(theme),
      error: (error, stack) => _buildErrorState(theme, error.toString()),
      data: (tasks) => _buildTimeline(context, theme, mobileGestureService, tasks),
    );
  }

  Widget _buildTimeline(
    BuildContext context,
    ThemeData theme,
    MobileGestureService gestureService,
    List<TaskModel> tasks,
  ) {
    return Column(
      children: [
        // Timeline controls
        _buildTimelineControls(theme, gestureService),
        
        // Timeline content
        Expanded(
          child: gestureService.createZoomableGestureDetector(
            minScale: _minScale,
            maxScale: _maxScale,
            onScaleStart: _handleZoomStart,
            onScaleChanged: _handleZoomUpdate,
            onScaleEnd: _handleZoomEnd,
            semanticLabel: 'Zoomable project timeline',
            child: _buildTimelineContent(theme, tasks),
          ),
        ),
        
        // Timeline footer
        _buildTimelineFooter(theme),
      ],
    );
  }

  Widget _buildTimelineControls(ThemeData theme, MobileGestureService gestureService) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Timeline header
            Row(
              children: [
                Icon(
                  PhosphorIcons.calendarBlank(),
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Project Timeline',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDateRange(_viewportStart, _viewportEnd),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Zoom and navigation controls
            Row(
              children: [
                // Zoom controls
                _buildControlButton(
                  theme,
                  PhosphorIcons.magnifyingGlassMinus(),
                  'Zoom out',
                  _canZoomOut,
                  _zoomOut,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 30,
                    child: Slider(
                      value: _currentScale,
                      min: _minScale,
                      max: _maxScale,
                      divisions: 20,
                      onChanged: _handleSliderZoom,
                      activeColor: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildControlButton(
                  theme,
                  PhosphorIcons.magnifyingGlassPlus(),
                  'Zoom in',
                  _canZoomIn,
                  _zoomIn,
                ),
                
                const SizedBox(width: 16),
                
                // Navigation controls
                _buildControlButton(
                  theme,
                  PhosphorIcons.arrowLeft(),
                  'Previous period',
                  true,
                  _navigatePrevious,
                ),
                const SizedBox(width: 8),
                _buildControlButton(
                  theme,
                  PhosphorIcons.house(),
                  'Today',
                  true,
                  _navigateToToday,
                ),
                const SizedBox(width: 8),
                _buildControlButton(
                  theme,
                  PhosphorIcons.arrowRight(),
                  'Next period',
                  true,
                  _navigateNext,
                ),
              ],
            ),
            
            // Gesture instructions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Pinch to zoom • Pan to navigate • Tap task for details',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  // Using theme labelSmall size
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineContent(ThemeData theme, List<TaskModel> tasks) {
    final timelineTasks = tasks.where((task) => 
      task.hasDueDate && 
      task.dueDate!.isAfter(_viewportStart) && 
      task.dueDate!.isBefore(_viewportEnd)
    ).toList();

    return Container(
      key: _timelineKey,
      child: SingleChildScrollView(
        controller: _horizontalScrollController,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: _calculateTimelineWidth(),
          child: Column(
            children: [
              // Timeline header with dates
              _buildTimelineHeader(theme),
              
              // Timeline tasks
              Expanded(
                child: SingleChildScrollView(
                  controller: _verticalScrollController,
                  child: Column(
                    children: [
                      ...timelineTasks.asMap().entries.map((entry) {
                        final index = entry.key;
                        final task = entry.value;
                        return _buildTimelineTask(theme, task, index);
                      }),
                      if (timelineTasks.isEmpty) _buildEmptyTimeline(theme),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineHeader(ThemeData theme) {
    final visibleDays = _getVisibleDays();
    
    return SizedBox(
      height: _headerHeight * _currentScale,
      child: Row(
        children: visibleDays.map((date) {
          return _buildDateColumn(theme, date);
        }).toList(),
      ),
    );
  }

  Widget _buildDateColumn(ThemeData theme, DateTime date) {
    final isToday = _isSameDay(date, DateTime.now());
    final isWeekend = date.weekday > 5;
    
    return Container(
      width: _dayWidth * _currentScale,
      decoration: BoxDecoration(
        color: isToday
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : isWeekend
                ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                : Colors.transparent,
        border: Border(
          right: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
            width: 0.5,
          ),
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            Text(
              '${date.day}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                color: isToday
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                fontSize: (theme.textTheme.titleSmall?.fontSize ?? 14) * _currentScale.clamp(0.7, 1.2),
              ),
            ),
            Text(
              _formatWeekday(date),
              style: theme.textTheme.bodySmall?.copyWith(
                color: isToday
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontSize: (theme.textTheme.bodySmall?.fontSize ?? 12) * _currentScale.clamp(0.6, 1.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineTask(ThemeData theme, TaskModel task, int index) {
    final taskStart = _calculateTaskStartPosition(task);
    final taskWidth = _calculateTaskWidth(task);
    
    return SizedBox(
      height: _taskLaneHeight * _currentScale,
      child: Stack(
        children: [
          // Task lane background
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
            ),
          ),
          
          // Task bar
          Positioned(
            left: taskStart,
            top: 8,
            child: GestureDetector(
              onTap: () => _viewTask(task),
              onLongPress: () => _editTask(task),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: taskWidth,
                height: _taskHeight * _currentScale,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getTaskStatusColor(task.status),
                      _getTaskStatusColor(task.status).withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(6 * _currentScale),
                  boxShadow: [
                    BoxShadow(
                      color: _getTaskStatusColor(task.status).withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(4 * _currentScale),
                  child: Row(
                    children: [
                      // Priority indicator
                      if (task.priority.isHigh)
                        Container(
                          width: 3 * _currentScale,
                          decoration: BoxDecoration(
                            color: _getTaskPriorityColor(task.priority),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      
                      if (task.priority.isHigh)
                        SizedBox(width: 4 * _currentScale),
                      
                      // Task title
                      Expanded(
                        child: Text(
                          task.title,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: (theme.textTheme.bodySmall?.fontSize ?? 12) * 
                                _currentScale.clamp(0.6, 1.0),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      // Task status indicator
                      if (_currentScale > 0.7)
                        Icon(
                          _getTaskStatusIcon(task.status),
                          color: Colors.white,
                          size: 12 * _currentScale,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTimeline(ThemeData theme) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.calendarX(),
              size: 48,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks in selected period',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tasks with due dates will appear here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineFooter(ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Scale indicator
            Text(
              'Scale: ${(_currentScale * 100).round()}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Legend
            Expanded(
              child: Row(
                children: [
                  _buildLegendItem(theme, 'To Do', _getTaskStatusColor(TaskStatus.pending)),
                  const SizedBox(width: 12),
                  _buildLegendItem(theme, 'In Progress', _getTaskStatusColor(TaskStatus.inProgress)),
                  const SizedBox(width: 12),
                  _buildLegendItem(theme, 'Completed', _getTaskStatusColor(TaskStatus.completed)),
                ],
              ),
            ),
            
            // Export button
            GestureDetector(
              onTap: _exportTimeline,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PhosphorIcons.export(),
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Export',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(ThemeData theme, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            // Using theme labelSmall size
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton(
    ThemeData theme,
    IconData icon,
    String tooltip,
    bool enabled,
    VoidCallback? onPressed,
  ) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled
                ? theme.colorScheme.primary.withValues(alpha: 0.3)
                : theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: AnimatedBuilder(
        animation: _loadingAnimationController,
        builder: (context, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.scale(
                scale: 1.0 + (_loadingAnimationController.value * 0.1),
                child: Icon(
                  PhosphorIcons.calendarBlank(),
                  size: 64,
                  color: theme.colorScheme.primary.withValues(
                    alpha: 0.5 + (_loadingAnimationController.value * 0.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading Timeline...',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.warningCircle(),
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading timeline',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          EnhancedButton(
            onPressed: () => ref.invalidate(tasksForProjectProvider(widget.projectId)),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Event handlers
  void _handleZoomStart() {
    HapticFeedback.selectionClick();
  }

  void _handleZoomUpdate(double scale) {
    if (scale != _currentScale) {
      setState(() {
        _currentScale = scale.clamp(_minScale, _maxScale);
      });
      
      // Provide haptic feedback for significant zoom changes
      if ((scale - _currentScale).abs() > 0.1) {
        HapticFeedback.lightImpact();
      }
    }
  }

  void _handleZoomEnd() {
    HapticFeedback.lightImpact();
  }

  void _handleSliderZoom(double scale) {
    setState(() {
      _currentScale = scale;
    });
    HapticFeedback.selectionClick();
  }

  void _zoomIn() {
    if (_canZoomIn) {
      setState(() {
        _currentScale = (_currentScale + 0.2).clamp(_minScale, _maxScale);
      });
      HapticFeedback.lightImpact();
    }
  }

  void _zoomOut() {
    if (_canZoomOut) {
      setState(() {
        _currentScale = (_currentScale - 0.2).clamp(_minScale, _maxScale);
      });
      HapticFeedback.lightImpact();
    }
  }

  void _navigatePrevious() {
    final daysDiff = _viewportEnd.difference(_viewportStart).inDays;
    setState(() {
      _viewportStart = _viewportStart.subtract(Duration(days: daysDiff));
      _viewportEnd = _viewportEnd.subtract(Duration(days: daysDiff));
    });
    HapticFeedback.selectionClick();
  }

  void _navigateNext() {
    final daysDiff = _viewportEnd.difference(_viewportStart).inDays;
    setState(() {
      _viewportStart = _viewportStart.add(Duration(days: daysDiff));
      _viewportEnd = _viewportEnd.add(Duration(days: daysDiff));
    });
    HapticFeedback.selectionClick();
  }

  void _navigateToToday() {
    final today = DateTime.now();
    final daysDiff = _viewportEnd.difference(_viewportStart).inDays;
    setState(() {
      _viewportStart = today.subtract(Duration(days: daysDiff ~/ 2));
      _viewportEnd = today.add(Duration(days: daysDiff ~/ 2));
    });
    HapticFeedback.mediumImpact();
  }

  void _viewTask(TaskModel task) {
    Navigator.pushNamed(context, '/task-detail', arguments: task.id);
  }

  void _editTask(TaskModel task) {
    Navigator.pushNamed(context, '/task-edit', arguments: task.id);
  }

  void _exportTimeline() {
    HapticFeedback.selectionClick();
    // Implement timeline export
  }

  // Helper methods
  bool get _canZoomIn => _currentScale < _maxScale;
  bool get _canZoomOut => _currentScale > _minScale;

  double _calculateTimelineWidth() {
    final days = _viewportEnd.difference(_viewportStart).inDays;
    return days * _dayWidth * _currentScale;
  }

  List<DateTime> _getVisibleDays() {
    final days = <DateTime>[];
    final totalDays = _viewportEnd.difference(_viewportStart).inDays;
    
    for (int i = 0; i < totalDays && i < _maxVisibleDays; i++) {
      days.add(_viewportStart.add(Duration(days: i)));
    }
    
    return days;
  }

  double _calculateTaskStartPosition(TaskModel task) {
    if (!task.hasDueDate) return 0;
    
    final daysDiff = task.dueDate!.difference(_viewportStart).inDays;
    return daysDiff * _dayWidth * _currentScale;
  }

  double _calculateTaskWidth(TaskModel task) {
    // For now, use a fixed width. In the future, this could be based on task duration
    return _dayWidth * _currentScale * 0.8;
  }

  Color _getTaskStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Colors.orange;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.cancelled:
        return Colors.red;
    }
  }

  Color _getTaskPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.urgent:
        return Colors.deepPurple;
    }
  }

  IconData _getTaskStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return PhosphorIcons.clock();
      case TaskStatus.inProgress:
        return PhosphorIcons.playCircle();
      case TaskStatus.completed:
        return PhosphorIcons.checkCircle();
      case TaskStatus.cancelled:
        return PhosphorIcons.xCircle();
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  String _formatWeekday(DateTime date) {
    const weekdays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return weekdays[date.weekday - 1];
  }

  String _formatDateRange(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month) {
      return '${start.day}-${end.day} ${_formatMonth(start.month)} ${start.year}';
    } else if (start.year == end.year) {
      return '${_formatMonth(start.month)} - ${_formatMonth(end.month)} ${start.year}';
    } else {
      return '${_formatMonth(start.month)} ${start.year} - ${_formatMonth(end.month)} ${end.year}';
    }
  }

  String _formatMonth(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}