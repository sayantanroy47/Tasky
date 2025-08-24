import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/typography_constants.dart';
import '../../../core/design_system/design_tokens.dart';
import '../../../domain/entities/task_model.dart';
import '../../../domain/entities/timeline_settings.dart';
import '../../../domain/models/enums.dart';
import '../glassmorphism_container.dart';

/// Individual task row in the timeline showing task duration, progress, and details
/// 
/// Features:
/// - Task bar visualization with start/end dates
/// - Progress indicator with completion percentage
/// - Priority and status visual indicators
/// - Drag handles for rescheduling
/// - Resize handles for duration adjustment
/// - Tooltip with task details on hover
/// - Accessibility support for screen readers
class TaskTimelineRow extends StatefulWidget {
  /// The task to display
  final TaskModel task;
  
  /// Timeline display settings
  final TimelineSettings settings;
  
  /// Start date of the visible timeline
  final DateTime startDate;
  
  /// End date of the visible timeline
  final DateTime endDate;
  
  /// Whether this task is currently selected
  final bool isSelected;
  
  /// Whether this task is being dragged
  final bool isDragging;
  
  /// Callback when task is tapped
  final VoidCallback? onTaskTap;
  
  /// Callback when task progress is changed
  final void Function(double progress)? onProgressChanged;
  
  /// Callback when task dates are changed via resize
  final void Function(DateTime startDate, DateTime endDate)? onDatesChanged;

  const TaskTimelineRow({
    super.key,
    required this.task,
    required this.settings,
    required this.startDate,
    required this.endDate,
    this.isSelected = false,
    this.isDragging = false,
    this.onTaskTap,
    this.onProgressChanged,
    this.onDatesChanged,
  });

  @override
  State<TaskTimelineRow> createState() => _TaskTimelineRowState();
}

class _TaskTimelineRowState extends State<TaskTimelineRow>
    with SingleTickerProviderStateMixin {
  bool _isHovering = false;
  bool _isResizing = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.isSelected) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(TaskTimelineRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isTaskVisible()) {
      return const SizedBox.shrink();
    }

    return Container(
      height: widget.settings.taskRowHeight,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Task name section (fixed width)
          _buildTaskNameSection(),
          
          // Timeline section (scrollable)
          Expanded(
            child: _buildTimelineSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskNameSection() {
    return Container(
      width: 250,
      padding: const EdgeInsets.symmetric(
        horizontal: TypographyConstants.paddingMedium,
        vertical: TypographyConstants.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Priority indicator
          _buildPriorityIndicator(),
          const SizedBox(width: TypographyConstants.spacingSmall),
          
          // Task content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Task title
                Text(
                  widget.task.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: TypographyConstants.medium,
                    color: _getTaskTitleColor(),
                    decoration: widget.task.isCompleted 
                        ? TextDecoration.lineThrough 
                        : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                
                // Task metadata
                if (widget.task.description != null || 
                    widget.task.tags.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      // Status indicator
                      _buildStatusIndicator(),
                      const SizedBox(width: 4),
                      
                      // Tags
                      if (widget.task.tags.isNotEmpty) ...[
                        Expanded(
                          child: Text(
                            widget.task.tags.join(', '),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection() {
    final taskBar = _buildTaskBar();
    if (taskBar == null) return const SizedBox.shrink();

    return SizedBox(
      height: double.infinity,
      child: Stack(
        children: [
          // Task bar
          Positioned(
            left: _getTaskStartPosition(),
            top: _getTaskVerticalPosition(),
            child: taskBar,
          ),
        ],
      ),
    );
  }

  Widget? _buildTaskBar() {
    final taskStart = _getTaskStartDate();
    final taskEnd = _getTaskEndDate();
    
    if (taskStart == null || taskEnd == null) return null;
    
    final barWidth = _calculateTaskBarWidth(taskStart, taskEnd);
    if (barWidth <= 0) return null;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onTaskTap,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: widget.isSelected ? _pulseAnimation.value : 1.0,
              child: SizedBox(
                width: barWidth,
                height: _getTaskBarHeight(),
                child: Stack(
                  children: [
                    // Main task bar
                    _buildMainTaskBar(barWidth),
                    
                    // Progress indicator
                    if (widget.settings.showProgress)
                      _buildProgressIndicator(barWidth),
                    
                    // Resize handles
                    if (_isHovering && !widget.isDragging)
                      _buildResizeHandles(barWidth),
                    
                    // Task content overlay
                    _buildTaskBarContent(barWidth),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainTaskBar(double width) {
    return GlassmorphismContainer(
      level: GlassLevel.interactive,
      width: width,
      height: _getTaskBarHeight(),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
      glassTint: _getTaskBarColor().withValues(alpha: 0.2),
      borderColor: _getTaskBarColor().withValues(alpha: 0.6),
      borderWidth: widget.isSelected ? 2.0 : 1.0,
      enableAccessibilityMode: true,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _getTaskBarColor().withValues(alpha: 0.3),
              _getTaskBarColor().withValues(alpha: 0.1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(double width) {
    final progress = _getTaskProgress();
    if (progress <= 0) return const SizedBox.shrink();

    return Positioned(
      left: 0,
      top: 0,
      child: Container(
        width: width * progress,
        height: _getTaskBarHeight(),
        decoration: BoxDecoration(
          color: _getTaskBarColor().withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
          boxShadow: [
            BoxShadow(
              color: _getTaskBarColor().withValues(alpha: 0.3),
              blurRadius: 2,
              spreadRadius: 0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResizeHandles(double width) {
    return Stack(
      children: [
        // Left resize handle
        Positioned(
          left: -4,
          top: 0,
          child: _buildResizeHandle(true),
        ),
        
        // Right resize handle
        Positioned(
          right: -4,
          top: 0,
          child: _buildResizeHandle(false),
        ),
      ],
    );
  }

  Widget _buildResizeHandle(bool isLeft) {
    return GestureDetector(
      onPanStart: (_) => setState(() => _isResizing = true),
      onPanEnd: (_) => setState(() => _isResizing = false),
      onPanUpdate: (details) => _handleResize(details, isLeft),
      child: Container(
        width: 8,
        height: _getTaskBarHeight(),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          PhosphorIcons.dotsThreeVertical(),
          size: 12,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }

  Widget _buildTaskBarContent(double width) {
    if (width < 50) return const SizedBox.shrink(); // Too narrow for content

    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TypographyConstants.paddingSmall,
          vertical: 2,
        ),
        child: Row(
          children: [
            // Task icon
            if (width > 80) ...[
              Icon(
                _getTaskIcon(),
                size: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 4),
            ],
            
            // Task title (abbreviated)
            Expanded(
              child: Text(
                widget.task.title,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9),
                  fontWeight: TypographyConstants.medium,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            
            // Progress percentage
            if (widget.settings.showProgress && width > 100) ...[
              const SizedBox(width: 4),
              Text(
                '${(_getTaskProgress() * 100).toInt()}%',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator() {
    return Container(
      width: 3,
      height: 20,
      decoration: BoxDecoration(
        color: _getPriorityColor(),
        borderRadius: BorderRadius.circular(1.5),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: _getStatusColor(),
        shape: BoxShape.circle,
      ),
    );
  }

  // Calculation methods
  bool _isTaskVisible() {
    final taskStart = _getTaskStartDate();
    final taskEnd = _getTaskEndDate();
    
    if (taskStart == null || taskEnd == null) return false;
    
    // Check if task overlaps with visible timeline
    return taskStart.isBefore(widget.endDate) && taskEnd.isAfter(widget.startDate);
  }

  DateTime? _getTaskStartDate() {
    return widget.task.createdAt; // Use creation date as start for now
  }

  DateTime? _getTaskEndDate() {
    return widget.task.dueDate ?? 
           widget.task.createdAt.add(Duration(hours: widget.settings.defaultTaskDurationHours));
  }

  double _getTaskStartPosition() {
    final taskStart = _getTaskStartDate();
    if (taskStart == null) return 0;
    
    final startDiff = taskStart.difference(widget.startDate);
    final startOffset = (startDiff.inMilliseconds / widget.settings.timeUnit.inMilliseconds) *
                       widget.settings.pixelsPerTimeUnit;
    
    return math.max(0, startOffset);
  }

  double _getTaskVerticalPosition() {
    return (widget.settings.taskRowHeight - _getTaskBarHeight()) / 2;
  }

  double _calculateTaskBarWidth(DateTime start, DateTime end) {
    final duration = end.difference(start);
    return (duration.inMilliseconds / widget.settings.timeUnit.inMilliseconds) *
           widget.settings.pixelsPerTimeUnit;
  }

  double _getTaskBarHeight() {
    return widget.settings.taskRowHeight * 0.6; // 60% of row height
  }

  double _getTaskProgress() {
    if (widget.task.isCompleted) return 1.0;
    
    // Check if progress is stored in metadata
    final progress = widget.task.metadata['progress'] as double?;
    if (progress != null) return progress.clamp(0.0, 1.0);
    
    // Calculate based on subtask completion
    if (widget.task.hasSubTasks) {
      return widget.task.subTaskCompletionPercentage;
    }
    
    // Default progress based on time elapsed
    final taskStart = _getTaskStartDate();
    final taskEnd = _getTaskEndDate();
    if (taskStart == null || taskEnd == null) return 0.0;
    
    final now = DateTime.now();
    if (now.isBefore(taskStart)) return 0.0;
    if (now.isAfter(taskEnd)) return widget.task.isCompleted ? 1.0 : 0.8;
    
    final elapsed = now.difference(taskStart);
    final total = taskEnd.difference(taskStart);
    return (elapsed.inMilliseconds / total.inMilliseconds).clamp(0.0, 0.8);
  }

  Color _getTaskBarColor() {
    if (widget.task.isOverdue && !widget.task.isCompleted) {
      return Theme.of(context).colorScheme.error;
    }
    
    switch (widget.task.priority) {
      case TaskPriority.low:
        return const Color(0xFF6B7280); // Gray
      case TaskPriority.medium:
        return Theme.of(context).colorScheme.primary;
      case TaskPriority.high:
        return const Color(0xFFF59E0B); // Orange
      case TaskPriority.urgent:
        return const Color(0xFFEF4444); // Red
    }
  }

  Color _getPriorityColor() {
    switch (widget.task.priority) {
      case TaskPriority.low:
        return const Color(0xFF6B7280);
      case TaskPriority.medium:
        return const Color(0xFF3B82F6);
      case TaskPriority.high:
        return const Color(0xFFF59E0B);
      case TaskPriority.urgent:
        return const Color(0xFFEF4444);
    }
  }

  Color _getStatusColor() {
    switch (widget.task.status) {
      case TaskStatus.pending:
        return const Color(0xFF6B7280);
      case TaskStatus.inProgress:
        return const Color(0xFF3B82F6);
      case TaskStatus.completed:
        return const Color(0xFF10B981);
      case TaskStatus.cancelled:
        return const Color(0xFFEF4444);
    }
  }

  Color? _getTaskTitleColor() {
    if (widget.task.isCompleted) {
      return Theme.of(context).colorScheme.onSurfaceVariant;
    } else if (widget.task.isOverdue) {
      return Theme.of(context).colorScheme.error;
    }
    return Theme.of(context).colorScheme.onSurface;
  }

  IconData _getTaskIcon() {
    if (widget.task.isCompleted) {
      return PhosphorIcons.checkCircle();
    } else if (widget.task.status == TaskStatus.inProgress) {
      return PhosphorIcons.playCircle();
    } else if (widget.task.isOverdue) {
      return PhosphorIcons.warningCircle();
    } else if (widget.task.priority == TaskPriority.urgent) {
      return PhosphorIcons.fire();
    }
    return PhosphorIcons.circle();
  }

  void _handleResize(DragUpdateDetails details, bool isLeft) {
    final taskStart = _getTaskStartDate();
    final taskEnd = _getTaskEndDate();
    if (taskStart == null || taskEnd == null) return;

    // Convert drag delta to time delta
    final pixelDelta = details.delta.dx;
    final timeDelta = Duration(
      milliseconds: (pixelDelta / widget.settings.pixelsPerTimeUnit *
                    widget.settings.timeUnit.inMilliseconds).round(),
    );

    if (isLeft) {
      // Resize from start
      final newStart = taskStart.add(timeDelta);
      if (newStart.isBefore(taskEnd)) {
        widget.onDatesChanged?.call(newStart, taskEnd);
      }
    } else {
      // Resize from end
      final newEnd = taskEnd.add(timeDelta);
      if (newEnd.isAfter(taskStart)) {
        widget.onDatesChanged?.call(taskStart, newEnd);
      }
    }
  }
}