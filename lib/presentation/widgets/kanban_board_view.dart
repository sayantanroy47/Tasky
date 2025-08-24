import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../../core/theme/typography_constants.dart';
import '../../core/design_system/design_tokens.dart';
import '../../core/theme/material3/motion_system.dart';
import '../../core/providers/core_providers.dart';
import '../../presentation/providers/task_providers.dart';
import 'glassmorphism_container.dart';
import 'kanban_column.dart';
import 'kanban_dialogs.dart';

/// Comprehensive Kanban board view for project management
/// 
/// Features:
/// - Drag-and-drop task management between columns
/// - Customizable column configurations
/// - Real-time task status updates
/// - Advanced filtering and search capabilities
/// - Responsive design with smooth animations
/// - Performance optimized for large task sets
/// - Accessibility compliant with screen readers
class KanbanBoardView extends ConsumerStatefulWidget {
  /// Optional project ID to filter tasks by project
  final String? projectId;
  
  /// Initial column configuration
  final List<KanbanColumnConfig> initialColumns;
  
  /// Whether to show task counts in column headers
  final bool showTaskCounts;
  
  /// Whether to enable drag-and-drop functionality
  final bool enableDragAndDrop;
  
  /// Whether to show search and filter controls
  final bool showControls;
  
  /// Custom task filter applied to all columns
  final TaskFilter? globalFilter;
  
  /// Callback when a task is moved between columns
  final Function(TaskModel task, TaskStatus newStatus)? onTaskMoved;
  
  /// Callback when a task is tapped
  final Function(TaskModel task)? onTaskTapped;
  
  /// Callback when a new task should be created in a specific column
  final Function(TaskStatus status)? onCreateTask;

  KanbanBoardView({
    super.key,
    this.projectId,
    List<KanbanColumnConfig>? initialColumns,
    this.showTaskCounts = true,
    this.enableDragAndDrop = true,
    this.showControls = true,
    this.globalFilter,
    this.onTaskMoved,
    this.onTaskTapped,
    this.onCreateTask,
  }) : initialColumns = initialColumns ?? defaultKanbanColumns;

  @override
  ConsumerState<KanbanBoardView> createState() => _KanbanBoardViewState();
}

class _KanbanBoardViewState extends ConsumerState<KanbanBoardView>
    with TickerProviderStateMixin {
  
  late ScrollController _horizontalScrollController;
  late AnimationController _searchAnimationController;
  late Animation<double> _searchAnimation;
  
  // State management
  String _searchQuery = '';
  bool _showSearch = false;
  TaskPriority? _priorityFilter;
  List<String> _tagFilter = [];
  final Set<String> _selectedTaskIds = {};
  bool _showBatchActions = false;
  
  // Column management
  late List<KanbanColumnConfig> _columns;
  final Map<String, GlobalKey> _columnKeys = {};
  
  // Performance optimization
  final Map<TaskStatus, List<TaskModel>> _cachedTasks = {};
  DateTime? _lastCacheUpdate;
  static const _cacheValidityDuration = Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    
    _columns = List.from(widget.initialColumns);
    _horizontalScrollController = ScrollController();
    
    // Initialize column keys for drag-and-drop
    for (final column in _columns) {
      _columnKeys[column.id] = GlobalKey();
    }
    
    // Initialize search animation
    _searchAnimationController = AnimationController(
      duration: ExpressiveMotionSystem.durationMedium1,
      vsync: this,
    );
    
    _searchAnimation = CurvedAnimation(
      parent: _searchAnimationController,
      curve: ExpressiveMotionSystem.emphasizedDecelerate,
    );
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _searchAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GlassmorphismContainer(
      level: GlassLevel.background,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Header with controls
          if (widget.showControls) _buildControlsHeader(theme),
          
          // Kanban board content
          Expanded(
            child: _buildKanbanBoard(theme),
          ),
          
          // Batch actions bar
          if (_showBatchActions) _buildBatchActionsBar(theme),
        ],
      ),
    );
  }

  Widget _buildControlsHeader(ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.interactive,
      margin: const EdgeInsets.all(SpacingTokens.sm),
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        children: [
          // Search and filter row
          Row(
            children: [
              // Search button
              IconButton(
                onPressed: _toggleSearch,
                icon: Icon(
                  PhosphorIcons.magnifyingGlass(),
                  color: _showSearch ? theme.colorScheme.primary : null,
                ),
                tooltip: 'Search tasks',
              ),
              
              // Filter buttons
              IconButton(
                onPressed: _showFilterDialog,
                icon: Icon(
                  PhosphorIcons.funnel(),
                  color: _hasActiveFilters ? theme.colorScheme.primary : null,
                ),
                tooltip: 'Filter tasks',
              ),
              
              // View options
              IconButton(
                onPressed: _showViewOptions,
                icon: Icon(PhosphorIcons.gear()),
                tooltip: 'View options',
              ),
              
              const Spacer(),
              
              // Batch selection toggle
              IconButton(
                onPressed: _toggleBatchSelection,
                icon: Icon(
                  _showBatchActions 
                    ? PhosphorIcons.selectionAll() 
                    : PhosphorIcons.selection(),
                ),
                tooltip: 'Batch select',
              ),
              
              // Add task button
              FilledButton.icon(
                onPressed: () => _showCreateTaskDialog(),
                icon: Icon(PhosphorIcons.plus()),
                label: const Text('Add Task'),
              ),
            ],
          ),
          
          // Search field (animated)
          AnimatedBuilder(
            animation: _searchAnimation,
            builder: (context, child) {
              if (!_showSearch) return const SizedBox.shrink();
              
              return Padding(
                padding: EdgeInsets.only(
                  top: SpacingTokens.sm * _searchAnimation.value,
                ),
                child: Opacity(
                  opacity: _searchAnimation.value,
                  child: Transform.scale(
                    scale: 0.8 + (0.2 * _searchAnimation.value),
                    child: _buildSearchField(theme),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search tasks...',
        prefixIcon: Icon(PhosphorIcons.magnifyingGlass()),
        suffixIcon: _searchQuery.isNotEmpty
          ? IconButton(
              onPressed: _clearSearch,
              icon: Icon(PhosphorIcons.x()),
            )
          : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
        _invalidateCache();
      },
      onSubmitted: (_) => _toggleSearch(),
    );
  }

  Widget _buildKanbanBoard(ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrowScreen = constraints.maxWidth < 800;
        final columnWidth = _calculateColumnWidth(constraints.maxWidth, isNarrowScreen);
        
        return SingleChildScrollView(
          controller: _horizontalScrollController,
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: _columns.length * columnWidth,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _columns.map((column) {
                return SizedBox(
                  width: columnWidth,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xs),
                    child: KanbanColumn(
                      key: _columnKeys[column.id],
                      config: column,
                      tasks: _getTasksForColumn(column.status),
                      showTaskCount: widget.showTaskCounts,
                      enableDragAndDrop: widget.enableDragAndDrop,
                      selectedTaskIds: _selectedTaskIds,
                      searchQuery: _searchQuery,
                      priorityFilter: _priorityFilter,
                      tagFilter: _tagFilter,
                      onTaskTapped: widget.onTaskTapped,
                      onTaskMoved: _handleTaskMoved,
                      onTaskSelected: _handleTaskSelection,
                      onCreateTask: () => widget.onCreateTask?.call(column.status),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBatchActionsBar(ThemeData theme) {
    final selectedCount = _selectedTaskIds.length;
    
    return GlassmorphismContainer(
      level: GlassLevel.floating,
      margin: const EdgeInsets.all(SpacingTokens.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.sm,
      ),
      child: Row(
        children: [
          Text(
            '$selectedCount task${selectedCount != 1 ? 's' : ''} selected',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: TypographyConstants.medium,
            ),
          ),
          
          const Spacer(),
          
          // Batch action buttons
          IconButton(
            onPressed: selectedCount > 0 ? _batchComplete : null,
            icon: Icon(PhosphorIcons.checkCircle()),
            tooltip: 'Mark as complete',
          ),
          
          IconButton(
            onPressed: selectedCount > 0 ? _batchSetPriority : null,
            icon: Icon(PhosphorIcons.star()),
            tooltip: 'Set priority',
          ),
          
          IconButton(
            onPressed: selectedCount > 0 ? _batchAddTags : null,
            icon: Icon(PhosphorIcons.tag()),
            tooltip: 'Add tags',
          ),
          
          IconButton(
            onPressed: selectedCount > 0 ? _batchDelete : null,
            icon: Icon(PhosphorIcons.trash(), color: theme.colorScheme.error),
            tooltip: 'Delete tasks',
          ),
          
          const SizedBox(width: SpacingTokens.sm),
          
          // Clear selection
          TextButton(
            onPressed: _clearSelection,
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  // Helper methods

  double _calculateColumnWidth(double totalWidth, bool isNarrowScreen) {
    if (isNarrowScreen) {
      // On narrow screens, make columns wider and scrollable
      return (totalWidth * 0.85).clamp(280.0, 400.0);
    } else {
      // On wide screens, fit all columns
      final availableWidth = totalWidth - (SpacingTokens.xs * 2 * _columns.length);
      return (availableWidth / _columns.length).clamp(250.0, 350.0);
    }
  }

  List<TaskModel> _getTasksForColumn(TaskStatus status) {
    // Check cache validity
    final now = DateTime.now();
    if (_lastCacheUpdate != null &&
        now.difference(_lastCacheUpdate!) < _cacheValidityDuration &&
        _cachedTasks.containsKey(status)) {
      return _cachedTasks[status]!;
    }

    // Get tasks from provider and apply filters
    final allTasks = ref.watch(tasksProvider);
    
    final List<TaskModel> tasks = allTasks.when(
      data: (taskList) {
        final filteredTasks = taskList.where((task) {
          // Status filter
          if (task.status != status) return false;
          
          // Project filter
          if (widget.projectId != null && task.projectId != widget.projectId) {
            return false;
          }
          
          // Global filter
          if (widget.globalFilter != null) {
            final filter = widget.globalFilter!;
            
            if (filter.priority != null && task.priority != filter.priority) {
              return false;
            }
            
            if (filter.tags != null && filter.tags!.isNotEmpty) {
              if (!filter.tags!.any((tag) => task.tags.contains(tag))) {
                return false;
              }
            }
            
            if (filter.isOverdue != null && task.isOverdue != filter.isOverdue) {
              return false;
            }
            
            if (filter.isPinned != null && task.isPinned != filter.isPinned) {
              return false;
            }
            
            if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
              final query = filter.searchQuery!.toLowerCase();
              if (!task.title.toLowerCase().contains(query) &&
                  !(task.description?.toLowerCase().contains(query) ?? false)) {
                return false;
              }
            }
          }
          
          // Local filters
          if (_searchQuery.isNotEmpty) {
            final query = _searchQuery.toLowerCase();
            if (!task.title.toLowerCase().contains(query) &&
                !(task.description?.toLowerCase().contains(query) ?? false)) {
              return false;
            }
          }
          
          if (_priorityFilter != null && task.priority != _priorityFilter) {
            return false;
          }
          
          if (_tagFilter.isNotEmpty) {
            if (!_tagFilter.any((tag) => task.tags.contains(tag))) {
              return false;
            }
          }
          
          return true;
        }).toList();
        
        // Sort by priority and due date
        filteredTasks.sort((a, b) {
          // Pinned tasks first
          if (a.isPinned != b.isPinned) {
            return a.isPinned ? -1 : 1;
          }
          
          // Then by priority
          final priorityComparison = b.priority.value.compareTo(a.priority.value);
          if (priorityComparison != 0) return priorityComparison;
          
          // Then by due date (null dates last)
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          
          return a.dueDate!.compareTo(b.dueDate!);
        });
        
        return filteredTasks;
      },
      loading: () => <TaskModel>[],
      error: (_, __) => <TaskModel>[],
    );

    // Cache the result
    _cachedTasks[status] = tasks;
    _lastCacheUpdate = now;
    
    return tasks;
  }

  void _handleTaskMoved(TaskModel task, TaskStatus newStatus) {
    if (task.status == newStatus) return;
    
    // Update task status
    final repository = ref.read(taskRepositoryProvider);
    repository.updateTask(
      task.copyWith(status: newStatus)
    );
    
    // Invalidate cache
    _invalidateCache();
    
    // Notify callback
    widget.onTaskMoved?.call(task, newStatus);
  }

  void _handleTaskSelection(TaskModel task, bool selected) {
    setState(() {
      if (selected) {
        _selectedTaskIds.add(task.id);
      } else {
        _selectedTaskIds.remove(task.id);
      }
      
      _showBatchActions = _selectedTaskIds.isNotEmpty;
    });
  }

  void _invalidateCache() {
    _cachedTasks.clear();
    _lastCacheUpdate = null;
  }

  bool get _hasActiveFilters {
    return _searchQuery.isNotEmpty ||
           _priorityFilter != null ||
           _tagFilter.isNotEmpty ||
           (widget.globalFilter?.hasFilters ?? false);
  }

  // UI Action handlers

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
    });
    
    if (_showSearch) {
      _searchAnimationController.forward();
    } else {
      _searchAnimationController.reverse();
      _searchQuery = '';
      _invalidateCache();
    }
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
    });
    _invalidateCache();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => KanbanFilterDialog(
        currentPriority: _priorityFilter,
        currentTags: _tagFilter,
        onFiltersChanged: (priority, tags) {
          setState(() {
            _priorityFilter = priority;
            _tagFilter = tags;
          });
          _invalidateCache();
        },
      ),
    );
  }

  void _showViewOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => KanbanViewOptionsSheet(
        columns: _columns,
        onColumnsChanged: (newColumns) {
          setState(() {
            _columns = newColumns;
          });
        },
      ),
    );
  }

  void _toggleBatchSelection() {
    setState(() {
      _showBatchActions = !_showBatchActions;
      if (!_showBatchActions) {
        _selectedTaskIds.clear();
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedTaskIds.clear();
      _showBatchActions = false;
    });
  }

  void _showCreateTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => TaskCreationDialog(
        initialStatus: TaskStatus.pending,
        projectId: widget.projectId,
      ),
    );
  }

  // Batch operations

  Future<void> _batchComplete() async {
    final tasksToUpdate = ref.read(tasksProvider).value
        ?.where((task) => _selectedTaskIds.contains(task.id))
        .toList() ?? [];
    
    for (final task in tasksToUpdate) {
      final repository = ref.read(taskRepositoryProvider);
      repository.updateTask(
        task.markCompleted()
      );
    }
    
    _clearSelection();
    _invalidateCache();
  }

  void _batchSetPriority() {
    showDialog(
      context: context,
      builder: (context) => PrioritySelectionDialog(
        onPrioritySelected: (priority) async {
          final tasksToUpdate = ref.read(tasksProvider).value
              ?.where((task) => _selectedTaskIds.contains(task.id))
              .toList() ?? [];
          
          for (final task in tasksToUpdate) {
            final repository = ref.read(taskRepositoryProvider);
      repository.updateTask(
              task.copyWith(priority: priority)
            );
          }
          
          _clearSelection();
          _invalidateCache();
        },
      ),
    );
  }

  void _batchAddTags() {
    showDialog(
      context: context,
      builder: (context) => TagSelectionDialog(
        onTagsSelected: (tags) async {
          final tasksToUpdate = ref.read(tasksProvider).value
              ?.where((task) => _selectedTaskIds.contains(task.id))
              .toList() ?? [];
          
          for (final task in tasksToUpdate) {
            final newTags = [...task.tags];
            for (final tag in tags) {
              if (!newTags.contains(tag)) {
                newTags.add(tag);
              }
            }
            final repository = ref.read(taskRepositoryProvider);
      repository.updateTask(
              task.copyWith(tags: newTags)
            );
          }
          
          _clearSelection();
          _invalidateCache();
        },
      ),
    );
  }

  Future<void> _batchDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tasks'),
        content: Text(
          'Are you sure you want to delete ${_selectedTaskIds.length} task${_selectedTaskIds.length != 1 ? 's' : ''}?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
    
    if (confirmed) {
      final repository = ref.read(taskRepositoryProvider);
      for (final taskId in _selectedTaskIds) {
        repository.deleteTask(taskId);
      }
      
      _clearSelection();
      _invalidateCache();
    }
  }
}

/// Configuration for a Kanban column
class KanbanColumnConfig {
  final String id;
  final String title;
  final TaskStatus status;
  final IconData icon;
  final Color color;
  final bool isCollapsible;
  final bool isVisible;
  final int maxTasks;

  KanbanColumnConfig({
    required this.id,
    required this.title,
    required this.status,
    required this.icon,
    required this.color,
    this.isCollapsible = true,
    this.isVisible = true,
    this.maxTasks = 100,
  });

  KanbanColumnConfig copyWith({
    String? id,
    String? title,
    TaskStatus? status,
    IconData? icon,
    Color? color,
    bool? isCollapsible,
    bool? isVisible,
    int? maxTasks,
  }) {
    return KanbanColumnConfig(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isCollapsible: isCollapsible ?? this.isCollapsible,
      isVisible: isVisible ?? this.isVisible,
      maxTasks: maxTasks ?? this.maxTasks,
    );
  }
}

/// Default Kanban column configurations
final List<KanbanColumnConfig> defaultKanbanColumns = [
  KanbanColumnConfig(
    id: 'backlog',
    title: 'Backlog',
    status: TaskStatus.pending,
    icon: PhosphorIcons.clock(),
    color: Colors.grey,
  ),
  KanbanColumnConfig(
    id: 'in-progress',
    title: 'In Progress',
    status: TaskStatus.inProgress,
    icon: PhosphorIcons.playCircle(),
    color: Colors.blue,
  ),
  KanbanColumnConfig(
    id: 'completed',
    title: 'Completed',
    status: TaskStatus.completed,
    icon: PhosphorIcons.checkCircle(),
    color: Colors.green,
  ),
];

