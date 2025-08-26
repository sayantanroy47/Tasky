import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/typography_constants.dart';
import '../../core/utils/text_utils.dart';
import '../../core/design_system/design_tokens.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../../services/ui/mobile_gesture_service.dart';
import '../../services/ui/slidable_feedback_service.dart';
import '../../services/ui/slidable_action_service.dart';
import '../providers/task_providers.dart';
import '../providers/task_provider.dart';
import 'enhanced_ux_widgets.dart';
import 'glassmorphism_container.dart';
import 'standardized_text.dart';
import 'standardized_colors.dart';
import 'standardized_border_radius.dart';
import 'standardized_spacing.dart';
import 'standardized_animations.dart';

/// Mobile-optimized Kanban board with touch-friendly interactions
class MobileKanbanBoard extends ConsumerStatefulWidget {
  final String projectId;
  final double cardWidth;
  final double cardHeight;
  final bool enableDragDrop;
  final bool enableSwipeActions;
  final VoidCallback? onRefresh;

  const MobileKanbanBoard({
    super.key,
    required this.projectId,
    this.cardWidth = 300.0,
    this.cardHeight = 150.0,
    this.enableDragDrop = true,
    this.enableSwipeActions = true,
    this.onRefresh,
  });

  @override
  ConsumerState<MobileKanbanBoard> createState() => _MobileKanbanBoardState();
}

class _MobileKanbanBoardState extends ConsumerState<MobileKanbanBoard>
    with TickerProviderStateMixin {
  late AnimationController _dragAnimationController;
  late AnimationController _refreshAnimationController;
  
  String? _draggingTaskId;
  final TaskStatus _targetColumn = TaskStatus.pending;
  bool _isRefreshing = false;
  
  final GlobalKey _kanbanKey = GlobalKey();
  final ScrollController _horizontalScrollController = ScrollController();
  final Map<TaskStatus, ScrollController> _columnScrollControllers = {
    TaskStatus.pending: ScrollController(),
    TaskStatus.inProgress: ScrollController(),
    TaskStatus.completed: ScrollController(),
  };

  @override
  void initState() {
    super.initState();
    _dragAnimationController = AnimationController(
      duration: StandardizedAnimations.fast,
      vsync: this,
    );
    _refreshAnimationController = AnimationController(
      duration: StandardizedAnimations.normal,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _dragAnimationController.dispose();
    _refreshAnimationController.dispose();
    _horizontalScrollController.dispose();
    for (final controller in _columnScrollControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mobileGestureService = ref.read(mobileGestureServiceProvider);
    final tasksAsync = ref.watch(tasksForProjectProvider(widget.projectId));

    return tasksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error.toString()),
      data: (tasks) => _buildKanbanBoard(context, theme, mobileGestureService, tasks),
    );
  }

  Widget _buildKanbanBoard(
    BuildContext context,
    ThemeData theme,
    MobileGestureService gestureService,
    List<TaskModel> tasks,
  ) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: gestureService.createPullToRefreshGestureDetector(
        onRefresh: _handleRefresh,
        semanticLabel: 'Pull to refresh Kanban board',
        child: Container(
          key: _kanbanKey,
          padding: StandardizedSpacing.padding(SpacingSize.sm),
          child: Column(
            children: [
              // Kanban board header
              _buildKanbanHeader(theme),
              
              StandardizedGaps.md,
              
              // Kanban columns
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _horizontalScrollController,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildKanbanColumn(
                        context,
                        theme,
                        gestureService,
                        TaskStatus.pending,
                        'To Do',
                        PhosphorIcons.clock(),
                        theme.colorScheme.tertiary,
                        tasks.where((t) => t.status.isPending).toList(),
                      ),
                      StandardizedGaps.horizontal(SpacingSize.sm),
                      _buildKanbanColumn(
                        context,
                        theme,
                        gestureService,
                        TaskStatus.inProgress,
                        'In Progress',
                        PhosphorIcons.playCircle(),
                        theme.colorScheme.secondary,
                        tasks.where((t) => t.status.isInProgress).toList(),
                      ),
                      StandardizedGaps.horizontal(SpacingSize.sm),
                      _buildKanbanColumn(
                        context,
                        theme,
                        gestureService,
                        TaskStatus.completed,
                        'Completed',
                        PhosphorIcons.checkCircle(),
                        theme.colorScheme.primary,
                        tasks.where((t) => t.status.isCompleted).toList(),
                      ),
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

  Widget _buildKanbanHeader(ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: StandardizedSpacing.padding(SpacingSize.md),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      child: Row(
        children: [
          Icon(
            PhosphorIcons.kanban(),
            color: theme.colorScheme.primary,
            size: 24,
          ),
          StandardizedGaps.horizontal(SpacingSize.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const StandardizedText(
                  'Project Board',
                  style: StandardizedTextStyle.titleMedium,
                ),
                StandardizedText(
                  'Drag tasks between columns or swipe for quick actions',
                  style: StandardizedTextStyle.bodySmall,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
          if (_isRefreshing)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKanbanColumn(
    BuildContext context,
    ThemeData theme,
    MobileGestureService gestureService,
    TaskStatus status,
    String title,
    IconData icon,
    Color accentColor,
    List<TaskModel> tasks,
  ) {
    final isDragTarget = _draggingTaskId != null && _targetColumn == status;
    
    return SizedBox(
      width: widget.cardWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column header
          _buildColumnHeader(theme, title, icon, accentColor, tasks.length),
          
          StandardizedGaps.sm,
          
          // Column content
          Expanded(
            child: gestureService.createDragDropGestureDetector(
              itemId: status.name,
              itemType: 'kanban_column',
              canDrag: false,
              canAccept: widget.enableDragDrop,
              onAccept: (details) => _handleTaskDrop(details.data as String, status),
              semanticLabel: '$title column, ${tasks.length} tasks',
              child: AnimatedContainer(
                duration: StandardizedAnimations.fast,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                  border: isDragTarget
                      ? Border.all(color: accentColor, width: 2)
                      : null,
                ),
                child: GlassmorphismContainer(
                  level: GlassLevel.content,
                  borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                  glassTint: isDragTarget
                      ? context.colors.withSemanticOpacity(
                          accentColor,
                          SemanticOpacity.subtle,
                        )
                      : null,
                  child: tasks.isEmpty
                      ? _buildEmptyColumn(theme, title, icon, accentColor)
                      : _buildTaskList(context, theme, gestureService, status, tasks),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumnHeader(
    ThemeData theme,
    String title,
    IconData icon,
    Color accentColor,
    int taskCount,
  ) {
    return GlassmorphismContainer(
      level: GlassLevel.interactive,
      padding: StandardizedSpacing.paddingSymmetric(
        horizontal: SpacingSize.sm,
        vertical: SpacingSize.sm,
      ),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      glassTint: context.colors.withSemanticOpacity(
        accentColor,
        SemanticOpacity.subtle,
      ),
      borderColor: context.colors.withSemanticOpacity(
        accentColor,
        SemanticOpacity.light,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: accentColor,
            size: 18,
          ),
          StandardizedGaps.horizontal(SpacingSize.sm),
          Expanded(
            child: StandardizedText(
              title,
              style: StandardizedTextStyle.titleSmall,
              color: accentColor,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: StandardizedSpacing.paddingSymmetric(
              horizontal: SpacingSize.sm,
              vertical: SpacingSize.xs,
            ),
            decoration: BoxDecoration(
              color: context.colors.withSemanticOpacity(
                accentColor,
                SemanticOpacity.light,
              ),
              borderRadius: StandardizedBorderRadius.md,
            ),
            child: StandardizedText(
              taskCount.toString(),
              style: StandardizedTextStyle.bodySmall,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyColumn(
    ThemeData theme,
    String title,
    IconData icon,
    Color accentColor,
  ) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: context.colors.withSemanticOpacity(
                accentColor,
                SemanticOpacity.medium,
              ),
              size: 32,
            ),
            StandardizedGaps.sm,
            StandardizedText(
              'No tasks in $title',
              style: StandardizedTextStyle.bodySmall,
              color: theme.colorScheme.onSurfaceVariant,
              textAlign: TextAlign.center,
            ),
            StandardizedGaps.xs,
            StandardizedText(
              'Drag tasks here',
              style: StandardizedTextStyle.bodySmall,
              color: context.colors.withSemanticOpacity(
                theme.colorScheme.onSurfaceVariant,
                SemanticOpacity.strong,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(
    BuildContext context,
    ThemeData theme,
    MobileGestureService gestureService,
    TaskStatus status,
    List<TaskModel> tasks,
  ) {
    return ListView.builder(
      controller: _columnScrollControllers[status],
      padding: StandardizedSpacing.padding(SpacingSize.sm),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Padding(
          padding: StandardizedSpacing.paddingOnly(bottom: SpacingSize.sm),
          child: _buildMobileTaskCard(
            context,
            theme,
            gestureService,
            task,
            status,
          ),
        );
      },
    );
  }

  Widget _buildMobileTaskCard(
    BuildContext context,
    ThemeData theme,
    MobileGestureService gestureService,
    TaskModel task,
    TaskStatus currentStatus,
  ) {
    final isDragging = _draggingTaskId == task.id;
    
    return gestureService.createDragDropGestureDetector(
      itemId: task.id,
      itemType: 'task',
      canDrag: widget.enableDragDrop,
      onDragStart: () => _handleTaskDragStart(task.id),
      onDragEnd: (taskId) => _handleTaskDragEnd(taskId),
      semanticLabel: 'Task: ${task.title}',
      child: AnimatedOpacity(
        opacity: isDragging ? 0.7 : 1.0,
        duration: StandardizedAnimations.fast,
        child: _buildTaskCardContent(context, theme, gestureService, task, currentStatus),
      ),
    );
  }

  Widget _buildTaskCardContent(
    BuildContext context,
    ThemeData theme,
    MobileGestureService gestureService,
    TaskModel task,
    TaskStatus currentStatus,
  ) {
    return gestureService.createProjectCardGestureDetector(
      projectId: widget.projectId,
      onTap: () => _viewTask(task),
      onEdit: () => _editTask(task),
      onArchive: widget.enableSwipeActions ? () => _archiveTask(task) : null,
      onDelete: widget.enableSwipeActions ? () => _deleteTask(task) : null,
      onViewTasks: () => _viewTask(task),
      semanticLabel: 'Task card: ${task.title}, ${task.status.displayName}',
      child: GlassmorphismContainer(
        level: GlassLevel.interactive,
        height: widget.cardHeight,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        borderColor: context.colors.withSemanticOpacity(
          _getTaskStatusColor(task.status),
          SemanticOpacity.light,
        ),
        glassTint: context.colors.withSemanticOpacity(
          _getTaskStatusColor(task.status),
          SemanticOpacity.subtle,
        ),
        child: Padding(
          padding: StandardizedSpacing.padding(SpacingSize.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task header
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 16,
                    decoration: BoxDecoration(
                      color: _getTaskPriorityColor(task.priority),
                      borderRadius: StandardizedBorderRadius.xs,
                    ),
                  ),
                  StandardizedGaps.horizontal(SpacingSize.sm),
                  Expanded(
                    child: StandardizedText(
                      task.title,
                      style: StandardizedTextStyle.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (task.priority.isHigh)
                    Icon(
                      PhosphorIcons.warning(),
                      color: _getTaskPriorityColor(task.priority),
                      size: 16,
                    ),
                ],
              ),
              
              if (task.description?.isNotEmpty ?? false) ...[
                StandardizedGaps.sm,
                StandardizedText(
                  task.description!,
                  style: StandardizedTextStyle.bodySmall,
                  color: theme.colorScheme.onSurfaceVariant,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              const Spacer(),
              
              // Task footer
              Row(
                children: [
                  // Due date
                  if (task.hasDueDate) ...[
                    Icon(
                      PhosphorIcons.clock(),
                      size: 12,
                      color: task.isOverdue
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    StandardizedGaps.horizontal(SpacingSize.xs),
                    StandardizedText(
                      _formatDueDate(task.dueDate!),
                      style: StandardizedTextStyle.bodySmall,
                      color: task.isOverdue
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    StandardizedGaps.horizontal(SpacingSize.sm),
                  ],
                  
                  // Subtasks count
                  if (task.subtaskCount > 0) ...[
                    Icon(
                      PhosphorIcons.listChecks(),
                      size: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    StandardizedGaps.horizontal(SpacingSize.xs),
                    StandardizedText(
                      '${task.completedSubtaskCount}/${task.subtaskCount}',
                      style: StandardizedTextStyle.bodySmall,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                  
                  const Spacer(),
                  
                  // Drag handle
                  if (widget.enableDragDrop)
                    Icon(
                      PhosphorIcons.dotsSixVertical(),
                      size: 16,
                      color: context.colors.withSemanticOpacity(
                        theme.colorScheme.onSurfaceVariant,
                        SemanticOpacity.medium,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.warningCircle(),
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          StandardizedGaps.md,
          const StandardizedText(
            'Error loading Kanban board',
            style: StandardizedTextStyle.headlineSmall,
          ),
          StandardizedGaps.sm,
          StandardizedText(
            error,
            style: StandardizedTextStyle.bodyMedium,
            textAlign: TextAlign.center,
          ),
          StandardizedGaps.vertical(SpacingSize.lg),
          EnhancedButton(
            onPressed: () => ref.invalidate(tasksForProjectProvider(widget.projectId)),
            child: const StandardizedText(
              'Retry',
              style: StandardizedTextStyle.buttonText,
            ),
          ),
        ],
      ),
    );
  }

  // Event handlers
  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    
    await _refreshAnimationController.forward();
    
    try {
      // Refresh tasks by invalidating the provider
      ref.invalidate(tasksForProjectProvider(widget.projectId));
      await SlidableFeedbackService.provideFeedback(SlidableActionType.neutral);
    } finally {
      await _refreshAnimationController.reverse();
      setState(() => _isRefreshing = false);
      widget.onRefresh?.call();
    }
  }

  void _handleTaskDragStart(String taskId) {
    setState(() => _draggingTaskId = taskId);
    HapticFeedback.mediumImpact();
  }

  void _handleTaskDragEnd(String taskId) {
    setState(() => _draggingTaskId = null);
    HapticFeedback.lightImpact();
  }

  void _handleTaskDrop(String taskId, TaskStatus newStatus) async {
    final task = await ref.read(singleTaskProvider(taskId).future);
    if (task == null) return;

    if (task.status != newStatus) {
      final taskModel = task.copyWith(status: newStatus);
      await ref.read(taskOperationsProvider).updateTask(taskModel);
      await SlidableFeedbackService.provideFeedback(SlidableActionType.complete);
    }
    
    setState(() => _draggingTaskId = null);
  }

  void _viewTask(TaskModel task) {
    Navigator.pushNamed(context, '/task-detail', arguments: task.id);
  }

  void _editTask(TaskModel task) {
    // Navigate to task edit page or show edit dialog
    Navigator.pushNamed(context, '/task-edit', arguments: task.id);
  }

  void _archiveTask(TaskModel task) async {
    // Archive by updating status to cancelled (or delete if no archive status exists)
    final archivedTask = task.copyWith(status: TaskStatus.cancelled);
    await ref.read(taskOperationsProvider).updateTask(archivedTask);
    await SlidableFeedbackService.provideFeedback(SlidableActionType.archive);
  }

  void _deleteTask(TaskModel task) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${TextUtils.autoCapitalize(task.title)}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(taskOperationsProvider).deleteTask(task);
      await SlidableFeedbackService.provideFeedback(SlidableActionType.destructive);
    }
  }

  Color _getTaskStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Theme.of(context).colorScheme.tertiary;
      case TaskStatus.inProgress:
        return Theme.of(context).colorScheme.secondary;
      case TaskStatus.completed:
        return Theme.of(context).colorScheme.primary;
      case TaskStatus.cancelled:
        return Theme.of(context).colorScheme.error;
    }
  }

  Color _getTaskPriorityColor(TaskPriority priority) {
    final colors = StandardizedColors(Theme.of(context));
    switch (priority) {
      case TaskPriority.low:
        return colors.priorityLow;
      case TaskPriority.medium:
        return colors.priorityMedium;
      case TaskPriority.high:
        return colors.priorityHigh;
      case TaskPriority.urgent:
        return colors.priorityCritical;
    }
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;

    if (difference < 0) {
      return 'Overdue';
    } else if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference <= 7) {
      return '${difference}d';
    } else {
      return '${dueDate.day}/${dueDate.month}';
    }
  }
}