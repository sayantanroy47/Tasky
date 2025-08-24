import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/typography_constants.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/entities/project.dart';
import '../../domain/models/enums.dart';
import '../../services/ui/mobile_gesture_service.dart';
import '../../services/ui/slidable_feedback_service.dart';
import '../providers/task_providers.dart';
import '../providers/project_providers.dart';
import 'enhanced_ux_widgets.dart';
import 'glassmorphism_container.dart';

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
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _refreshAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
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
    final tasksAsync = ref.watch(projectTasksProvider(widget.projectId));

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
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Kanban board header
              _buildKanbanHeader(theme),
              
              const SizedBox(height: 16),
              
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
                      const SizedBox(width: 12),
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
                      const SizedBox(width: 12),
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
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      child: Row(
        children: [
          Icon(
            PhosphorIcons.kanban(),
            color: theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Project Board',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Drag tasks between columns or swipe for quick actions',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
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
          
          const SizedBox(height: 8),
          
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
                duration: const Duration(milliseconds: 200),
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
                      ? accentColor.withValues(alpha: 0.1)
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      glassTint: accentColor.withValues(alpha: 0.1),
      borderColor: accentColor.withValues(alpha: 0.3),
      child: Row(
        children: [
          Icon(
            icon,
            color: accentColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: accentColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              taskCount.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: accentColor,
                fontWeight: FontWeight.w500,
              ),
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
              color: accentColor.withValues(alpha: 0.5),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'No tasks in $title',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Drag tasks here',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                // Using theme bodySmall size
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
      padding: const EdgeInsets.all(8),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
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
        duration: const Duration(milliseconds: 200),
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
        borderColor: _getTaskStatusColor(task.status).withValues(alpha: 0.3),
        glassTint: _getTaskStatusColor(task.status).withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.all(12),
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
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
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
                const SizedBox(height: 8),
                Text(
                  task.description!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
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
                    const SizedBox(width: 4),
                    Text(
                      _formatDueDate(task.dueDate!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: task.isOverdue
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurfaceVariant,
                        // Using theme labelSmall size
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  
                  // Subtasks count
                  if (task.subtaskCount > 0) ...[
                    Icon(
                      PhosphorIcons.listChecks(),
                      size: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${task.completedSubtaskCount}/${task.subtaskCount}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        // Using theme labelSmall size
                      ),
                    ),
                  ],
                  
                  const Spacer(),
                  
                  // Drag handle
                  if (widget.enableDragDrop)
                    Icon(
                      PhosphorIcons.dotsSixVertical(),
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
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
          const SizedBox(height: 16),
          Text(
            'Error loading Kanban board',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          EnhancedButton(
            onPressed: () => ref.invalidate(projectTasksProvider(widget.projectId)),
            child: const Text('Retry'),
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
      await ref.read(taskNotifierProvider.notifier).refreshTasks();
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
    final task = await ref.read(taskByIdProvider(taskId).future);
    if (task == null) return;

    if (task.status != newStatus) {
      await ref.read(taskNotifierProvider.notifier).updateTaskStatus(taskId, newStatus);
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
    await ref.read(taskNotifierProvider.notifier).archiveTask(task.id);
    await SlidableFeedbackService.provideFeedback(SlidableActionType.archive);
  }

  void _deleteTask(TaskModel task) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
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
      await ref.read(taskNotifierProvider.notifier).deleteTask(task.id);
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