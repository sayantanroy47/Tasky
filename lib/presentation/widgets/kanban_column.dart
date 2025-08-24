import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../../core/theme/typography_constants.dart';
import '../../core/design_system/design_tokens.dart';
import '../../core/theme/material3/motion_system.dart';
import 'glassmorphism_container.dart';
import 'advanced_task_card.dart';
import 'kanban_board_view.dart';

/// Individual Kanban column widget with drag-and-drop functionality
/// 
/// Features:
/// - Glassmorphism design with proper theming
/// - Drag-and-drop task reordering and status changes
/// - Task filtering and searching within column
/// - Collapsible column header
/// - Performance optimized lazy loading
/// - Smooth animations and transitions
/// - Accessibility support
class KanbanColumn extends ConsumerStatefulWidget {
  /// Column configuration
  final KanbanColumnConfig config;
  
  /// List of tasks in this column
  final List<TaskModel> tasks;
  
  /// Whether to show task count in header
  final bool showTaskCount;
  
  /// Whether drag-and-drop is enabled
  final bool enableDragAndDrop;
  
  /// Set of selected task IDs for batch operations
  final Set<String> selectedTaskIds;
  
  /// Current search query for filtering
  final String searchQuery;
  
  /// Priority filter
  final TaskPriority? priorityFilter;
  
  /// Tag filter
  final List<String> tagFilter;
  
  /// Callback when a task is tapped
  final Function(TaskModel)? onTaskTapped;
  
  /// Callback when a task is moved to this column
  final Function(TaskModel, TaskStatus)? onTaskMoved;
  
  /// Callback when a task selection changes
  final Function(TaskModel, bool)? onTaskSelected;
  
  /// Callback when create task is tapped in this column
  final VoidCallback? onCreateTask;

  const KanbanColumn({
    super.key,
    required this.config,
    required this.tasks,
    this.showTaskCount = true,
    this.enableDragAndDrop = true,
    this.selectedTaskIds = const {},
    this.searchQuery = '',
    this.priorityFilter,
    this.tagFilter = const [],
    this.onTaskTapped,
    this.onTaskMoved,
    this.onTaskSelected,
    this.onCreateTask,
  });

  @override
  ConsumerState<KanbanColumn> createState() => _KanbanColumnState();
}

class _KanbanColumnState extends ConsumerState<KanbanColumn>
    with TickerProviderStateMixin {
  
  late ScrollController _scrollController;
  late AnimationController _collapseController;
  late AnimationController _dropZoneController;
  late AnimationController _loadingController;
  
  late Animation<double> _collapseAnimation;
  late Animation<double> _dropZoneAnimation;
  late Animation<double> _loadingAnimation;
  
  bool _isCollapsed = false;
  bool _isDragOver = false;
  bool _isLoading = false;
  
  // Performance optimization
  static const int _itemsPerPage = 20;
  int _loadedItems = _itemsPerPage;
  List<TaskModel> _filteredTasks = [];

  @override
  void initState() {
    super.initState();
    
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    
    // Initialize animations
    _collapseController = AnimationController(
      duration: ExpressiveMotionSystem.durationMedium2,
      vsync: this,
    );
    
    _dropZoneController = AnimationController(
      duration: ExpressiveMotionSystem.durationShort2,
      vsync: this,
    );
    
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _collapseAnimation = CurvedAnimation(
      parent: _collapseController,
      curve: ExpressiveMotionSystem.emphasizedDecelerate,
    );
    
    _dropZoneAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _dropZoneController,
      curve: ExpressiveMotionSystem.emphasizedAccelerate,
    ));
    
    _loadingAnimation = CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    );
    
    _updateFilteredTasks();
  }

  @override
  void didUpdateWidget(KanbanColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.tasks != widget.tasks ||
        oldWidget.searchQuery != widget.searchQuery ||
        oldWidget.priorityFilter != widget.priorityFilter ||
        oldWidget.tagFilter != widget.tagFilter) {
      _updateFilteredTasks();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _collapseController.dispose();
    _dropZoneController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  void _updateFilteredTasks() {
    setState(() {
      _filteredTasks = widget.tasks.where((task) {
        // Search filter
        if (widget.searchQuery.isNotEmpty) {
          final query = widget.searchQuery.toLowerCase();
          if (!task.title.toLowerCase().contains(query) &&
              !(task.description?.toLowerCase().contains(query) ?? false)) {
            return false;
          }
        }
        
        // Priority filter
        if (widget.priorityFilter != null && task.priority != widget.priorityFilter) {
          return false;
        }
        
        // Tag filter
        if (widget.tagFilter.isNotEmpty) {
          if (!widget.tagFilter.any((tag) => task.tags.contains(tag))) {
            return false;
          }
        }
        
        return true;
      }).toList();
      
      // Reset loaded items when filters change
      _loadedItems = _itemsPerPage;
    });
  }

  void _onScroll() {
    // Infinite scroll implementation
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreItems();
    }
  }

  void _loadMoreItems() {
    if (_loadedItems >= _filteredTasks.length || _isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    
    _loadingController.forward();
    
    // Simulate loading delay for performance
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _loadedItems = (_loadedItems + _itemsPerPage).clamp(0, _filteredTasks.length);
          _isLoading = false;
        });
        
        _loadingController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleTasks = _filteredTasks.take(_loadedItems).toList();
    
    return AnimatedBuilder(
      animation: _dropZoneAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _dropZoneAnimation.value,
          child: DragTarget<TaskModel>(
            onAcceptWithDetails: _handleTaskDrop,
            onWillAcceptWithDetails: (details) {
              final task = details.data;
              return task.status != widget.config.status;
            },
            onLeave: (_) => _setDragOver(false),
            builder: (context, candidateData, rejectedData) {
              return GlassmorphismContainer(
                level: _isDragOver ? GlassLevel.floating : GlassLevel.content,
                borderColor: _isDragOver ? widget.config.color.withValues(alpha: 0.8) : null,
                borderWidth: _isDragOver ? 2.0 : 1.0,
                margin: const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Column header
                    _buildColumnHeader(theme),
                    
                    // Task list (collapsible)
                    AnimatedBuilder(
                      animation: _collapseAnimation,
                      builder: (context, child) {
                        if (_isCollapsed && _collapseAnimation.value == 0) {
                          return const SizedBox.shrink();
                        }
                        
                        return SizeTransition(
                          sizeFactor: _collapseAnimation,
                          child: _buildTaskList(theme, visibleTasks),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildColumnHeader(ThemeData theme) {
    final taskCount = _filteredTasks.length;
    final hasFilters = widget.searchQuery.isNotEmpty ||
                      widget.priorityFilter != null ||
                      widget.tagFilter.isNotEmpty;
    
    return GlassmorphismContainer(
      level: GlassLevel.interactive,
      glassTint: widget.config.color.withValues(alpha: 0.1),
      borderColor: widget.config.color.withValues(alpha: 0.3),
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: InkWell(
        onTap: widget.config.isCollapsible ? _toggleCollapse : null,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        child: Row(
          children: [
            // Column icon and status indicator
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: widget.config.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
              ),
              child: Icon(
                widget.config.icon,
                size: 18,
                color: widget.config.color,
              ),
            ),
            
            const SizedBox(width: SpacingTokens.sm),
            
            // Column title and count
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.config.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: TypographyConstants.medium,
                      color: widget.config.color,
                    ),
                  ),
                  if (widget.showTaskCount) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          '$taskCount task${taskCount != 1 ? 's' : ''}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (hasFilters) ...[
                          const SizedBox(width: SpacingTokens.xs),
                          Icon(
                            PhosphorIcons.funnel(),
                            size: 12,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            // Action buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Add task button
                if (widget.onCreateTask != null)
                  IconButton(
                    onPressed: widget.onCreateTask,
                    icon: Icon(PhosphorIcons.plus()),
                    iconSize: 16,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    tooltip: 'Add task',
                  ),
                
                // Collapse button
                if (widget.config.isCollapsible)
                  AnimatedRotation(
                    turns: _isCollapsed ? 0.5 : 0.0,
                    duration: ExpressiveMotionSystem.durationMedium2,
                    child: IconButton(
                      onPressed: _toggleCollapse,
                      icon: Icon(PhosphorIcons.caretDown()),
                      iconSize: 16,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                      tooltip: _isCollapsed ? 'Expand column' : 'Collapse column',
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(ThemeData theme, List<TaskModel> visibleTasks) {
    return Flexible(
      child: Container(
        constraints: const BoxConstraints(minHeight: 100),
        child: Column(
          children: [
            // Task list
            Flexible(
              child: visibleTasks.isEmpty
                  ? _buildEmptyState(theme)
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(SpacingTokens.sm),
                      itemCount: visibleTasks.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= visibleTasks.length) {
                          return _buildLoadingIndicator(theme);
                        }
                        
                        final task = visibleTasks[index];
                        return _buildTaskCard(task, theme);
                      },
                    ),
            ),
            
            // Drop zone indicator
            if (_isDragOver) _buildDropZoneIndicator(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(TaskModel task, ThemeData theme) {
    final isSelected = widget.selectedTaskIds.contains(task.id);
    
    Widget taskCard = AdvancedTaskCard(
      task: task,
      style: TaskCardStyle.glass,
      margin: const EdgeInsets.only(bottom: SpacingTokens.sm),
      accentColor: isSelected ? theme.colorScheme.primary : null,
      showDragHandle: widget.enableDragAndDrop,
      onTap: () => widget.onTaskTapped?.call(task),
      onEdit: () => _editTask(task),
      onDelete: () => _deleteTask(task),
      onToggleComplete: () => _toggleTaskComplete(task),
      onStatusChanged: (status) => widget.onTaskMoved?.call(task, status),
      onPriorityChanged: (priority) => _updateTaskPriority(task, priority),
    );
    
    // Add selection overlay
    if (widget.selectedTaskIds.isNotEmpty) {
      taskCard = GestureDetector(
        onTap: () => _toggleTaskSelection(task),
        child: Stack(
          children: [
            taskCard,
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.onPrimary,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    PhosphorIcons.check(),
                    size: 14,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
          ],
        ),
      );
    }
    
    // Add drag functionality
    if (widget.enableDragAndDrop) {
      taskCard = Draggable<TaskModel>(
        data: task,
        feedback: Material(
          color: Colors.transparent,
          child: Transform.rotate(
            angle: 0.05,
            child: Opacity(
              opacity: 0.8,
              child: SizedBox(
                width: 300,
                child: AdvancedTaskCard(
                  task: task,
                  style: TaskCardStyle.glass,
                  elevation: 8,
                ),
              ),
            ),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.5,
          child: taskCard,
        ),
        onDragStarted: () => _startDrag(),
        onDragEnd: (_) => _endDrag(),
        child: taskCard,
      );
    }
    
    return taskCard;
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.stack(),
              size: 48,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            
            const SizedBox(height: SpacingTokens.md),
            
            Text(
              'No tasks',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            
            const SizedBox(height: SpacingTokens.sm),
            
            Text(
              widget.searchQuery.isNotEmpty || 
              widget.priorityFilter != null || 
              widget.tagFilter.isNotEmpty
                  ? 'No tasks match your filters'
                  : 'Drag tasks here or tap + to add',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(ThemeData theme) {
    return AnimatedBuilder(
      animation: _loadingAnimation,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.all(SpacingTokens.md),
          child: Center(
            child: Opacity(
              opacity: _loadingAnimation.value,
              child: Column(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.config.color,
                      ),
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  Text(
                    'Loading more tasks...',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropZoneIndicator(ThemeData theme) {
    return Container(
      height: 60,
      margin: const EdgeInsets.all(SpacingTokens.sm),
      decoration: BoxDecoration(
        color: widget.config.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        border: Border.all(
          color: widget.config.color.withValues(alpha: 0.5),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.arrowDown(),
              color: widget.config.color,
            ),
            const SizedBox(width: SpacingTokens.sm),
            Text(
              'Drop task here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: widget.config.color,
                fontWeight: TypographyConstants.medium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Event handlers

  void _handleTaskDrop(DragTargetDetails<TaskModel> details) {
    final task = details.data;
    _setDragOver(false);
    
    if (task.status != widget.config.status) {
      widget.onTaskMoved?.call(task, widget.config.status);
    }
  }

  void _setDragOver(bool isDragOver) {
    if (_isDragOver == isDragOver) return;
    
    setState(() {
      _isDragOver = isDragOver;
    });
    
    if (_isDragOver) {
      _dropZoneController.forward();
    } else {
      _dropZoneController.reverse();
    }
  }

  void _startDrag() {
    // Visual feedback for drag start
    setState(() {});
  }

  void _endDrag() {
    // Clean up after drag end
    setState(() {});
  }

  void _toggleCollapse() {
    setState(() {
      _isCollapsed = !_isCollapsed;
    });
    
    if (_isCollapsed) {
      _collapseController.reverse();
    } else {
      _collapseController.forward();
    }
  }

  void _toggleTaskSelection(TaskModel task) {
    final isSelected = widget.selectedTaskIds.contains(task.id);
    widget.onTaskSelected?.call(task, !isSelected);
  }

  void _editTask(TaskModel task) {
    // TODO: Implement task editing
    widget.onTaskTapped?.call(task);
  }

  void _deleteTask(TaskModel task) {
    // TODO: Implement task deletion with confirmation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Delete task through provider
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleTaskComplete(TaskModel task) {
    final newStatus = task.isCompleted ? TaskStatus.pending : TaskStatus.completed;
    widget.onTaskMoved?.call(task, newStatus);
  }

  void _updateTaskPriority(TaskModel task, TaskPriority priority) {
    // TODO: Update task priority through provider
    // This would typically update the task and trigger a rebuild
  }
}