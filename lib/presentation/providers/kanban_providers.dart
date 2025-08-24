import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../../domain/repositories/task_repository.dart';
import '../../core/providers/core_providers.dart';
import '../../presentation/widgets/kanban_board_view.dart';

/// Provider for Kanban board configuration
final kanbanConfigProvider = StateNotifierProvider<KanbanConfigNotifier, KanbanBoardConfig>(
  (ref) => KanbanConfigNotifier(),
);

/// Provider for tasks grouped by status for Kanban board
final kanbanTasksProvider = StreamProvider.family<Map<TaskStatus, List<TaskModel>>, KanbanBoardFilter>(
  (ref, filter) {
    final repository = ref.watch(taskRepositoryProvider);
    
    return repository.watchAllTasks().map((tasks) {
      // Apply filters
      final filteredTasks = tasks.where((task) {
        // Project filter
        if (filter.projectId != null && task.projectId != filter.projectId) {
          return false;
        }
        
        // Search query
        if (filter.searchQuery.isNotEmpty) {
          final query = filter.searchQuery.toLowerCase();
          if (!task.title.toLowerCase().contains(query) &&
              !(task.description?.toLowerCase().contains(query) ?? false)) {
            return false;
          }
        }
        
        // Priority filter
        if (filter.priority != null && task.priority != filter.priority) {
          return false;
        }
        
        // Tags filter
        if (filter.tags.isNotEmpty) {
          if (!filter.tags.any((tag) => task.tags.contains(tag))) {
            return false;
          }
        }
        
        return true;
      }).toList();
      
      // Group by status
      final groupedTasks = <TaskStatus, List<TaskModel>>{
        TaskStatus.pending: [],
        TaskStatus.inProgress: [],
        TaskStatus.completed: [],
        TaskStatus.cancelled: [],
      };
      
      for (final task in filteredTasks) {
        if (groupedTasks.containsKey(task.status)) {
          groupedTasks[task.status]!.add(task);
        }
      }
      
      // Sort tasks within each status
      for (final entry in groupedTasks.entries) {
        entry.value.sort((a, b) {
          // Pinned tasks first
          if (a.isPinned != b.isPinned) {
            return a.isPinned ? -1 : 1;
          }
          
          // Then by priority
          final priorityComparison = b.priority.value.compareTo(a.priority.value);
          if (priorityComparison != 0) return priorityComparison;
          
          // Then by due date (null dates last)
          if (a.dueDate == null && b.dueDate == null) {
            return a.createdAt.compareTo(b.createdAt);
          }
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          
          return a.dueDate!.compareTo(b.dueDate!);
        });
      }
      
      return groupedTasks;
    });
  },
);

/// Provider for Kanban board filter state
final kanbanFilterProvider = StateProvider<KanbanBoardFilter>(
  (ref) => const KanbanBoardFilter(),
);

/// Provider for Kanban board operations
final kanbanOperationsProvider = Provider<KanbanOperations>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return KanbanOperations(repository);
});

/// Provider for column statistics
final kanbanStatsProvider = Provider.family<AsyncValue<KanbanColumnStats>, TaskStatus>(
  (ref, status) {
    final filter = ref.watch(kanbanFilterProvider);
    final tasksAsync = ref.watch(kanbanTasksProvider(filter));
    
    return tasksAsync.when(
      data: (groupedTasks) {
        final tasks = groupedTasks[status] ?? [];
        
        final stats = KanbanColumnStats(
          totalTasks: tasks.length,
          highPriorityTasks: tasks.where((t) => t.priority.isHighPriority).length,
          overdueTasks: tasks.where((t) => t.isOverdue).length,
          completedToday: status == TaskStatus.completed
              ? tasks.where((t) => t.completedAt?.isAfter(
                    DateTime.now().subtract(const Duration(days: 1))) ?? false).length
              : 0,
        );
        
        return AsyncValue.data(stats);
      },
      loading: () => const AsyncValue.loading(),
      error: (error, stack) => AsyncValue.error(error, stack),
    );
  },
);

/// Provider for drag and drop state
final dragDropStateProvider = StateNotifierProvider<DragDropStateNotifier, DragDropState>(
  (ref) => DragDropStateNotifier(),
);

/// Configuration for Kanban board
class KanbanBoardConfig {
  final List<KanbanColumnConfig> columns;
  final bool showTaskCounts;
  final bool enableDragAndDrop;
  final bool enableBatchOperations;
  final bool enableSwimLanes;
  final KanbanViewMode viewMode;
  final Map<String, dynamic> customSettings;

  KanbanBoardConfig({
    List<KanbanColumnConfig>? columns,
    this.showTaskCounts = true,
    this.enableDragAndDrop = true,
    this.enableBatchOperations = true,
    this.enableSwimLanes = false,
    this.viewMode = KanbanViewMode.standard,
    this.customSettings = const {},
  }) : columns = columns ?? defaultKanbanColumns;

  KanbanBoardConfig copyWith({
    List<KanbanColumnConfig>? columns,
    bool? showTaskCounts,
    bool? enableDragAndDrop,
    bool? enableBatchOperations,
    bool? enableSwimLanes,
    KanbanViewMode? viewMode,
    Map<String, dynamic>? customSettings,
  }) {
    return KanbanBoardConfig(
      columns: columns ?? this.columns,
      showTaskCounts: showTaskCounts ?? this.showTaskCounts,
      enableDragAndDrop: enableDragAndDrop ?? this.enableDragAndDrop,
      enableBatchOperations: enableBatchOperations ?? this.enableBatchOperations,
      enableSwimLanes: enableSwimLanes ?? this.enableSwimLanes,
      viewMode: viewMode ?? this.viewMode,
      customSettings: customSettings ?? this.customSettings,
    );
  }
}

/// Kanban board filter configuration
class KanbanBoardFilter {
  final String? projectId;
  final String searchQuery;
  final TaskPriority? priority;
  final List<String> tags;
  final DateTime? dueDateFrom;
  final DateTime? dueDateTo;
  final bool includeCompleted;

  const KanbanBoardFilter({
    this.projectId,
    this.searchQuery = '',
    this.priority,
    this.tags = const [],
    this.dueDateFrom,
    this.dueDateTo,
    this.includeCompleted = true,
  });

  KanbanBoardFilter copyWith({
    String? projectId,
    String? searchQuery,
    TaskPriority? priority,
    List<String>? tags,
    DateTime? dueDateFrom,
    DateTime? dueDateTo,
    bool? includeCompleted,
  }) {
    return KanbanBoardFilter(
      projectId: projectId ?? this.projectId,
      searchQuery: searchQuery ?? this.searchQuery,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      dueDateFrom: dueDateFrom ?? this.dueDateFrom,
      dueDateTo: dueDateTo ?? this.dueDateTo,
      includeCompleted: includeCompleted ?? this.includeCompleted,
    );
  }

  bool get hasFilters {
    return projectId != null ||
           searchQuery.isNotEmpty ||
           priority != null ||
           tags.isNotEmpty ||
           dueDateFrom != null ||
           dueDateTo != null ||
           !includeCompleted;
  }
}

/// Kanban column statistics
class KanbanColumnStats {
  final int totalTasks;
  final int highPriorityTasks;
  final int overdueTasks;
  final int completedToday;

  const KanbanColumnStats({
    this.totalTasks = 0,
    this.highPriorityTasks = 0,
    this.overdueTasks = 0,
    this.completedToday = 0,
  });

  @override
  String toString() {
    return 'KanbanColumnStats(total: $totalTasks, highPriority: $highPriorityTasks, overdue: $overdueTasks, completedToday: $completedToday)';
  }
}

/// Kanban view modes
enum KanbanViewMode {
  standard,
  compact,
  swimLanes,
  priority,
}

/// Drag and drop state
class DragDropState {
  final bool isDragging;
  final TaskModel? draggedTask;
  final TaskStatus? targetColumn;
  final String? hoveredColumnId;

  const DragDropState({
    this.isDragging = false,
    this.draggedTask,
    this.targetColumn,
    this.hoveredColumnId,
  });

  DragDropState copyWith({
    bool? isDragging,
    TaskModel? draggedTask,
    TaskStatus? targetColumn,
    String? hoveredColumnId,
  }) {
    return DragDropState(
      isDragging: isDragging ?? this.isDragging,
      draggedTask: draggedTask ?? this.draggedTask,
      targetColumn: targetColumn ?? this.targetColumn,
      hoveredColumnId: hoveredColumnId ?? this.hoveredColumnId,
    );
  }
}

/// State notifier for Kanban configuration
class KanbanConfigNotifier extends StateNotifier<KanbanBoardConfig> {
  KanbanConfigNotifier() : super(KanbanBoardConfig());

  void updateColumns(List<KanbanColumnConfig> columns) {
    state = state.copyWith(columns: columns);
  }

  void toggleTaskCounts() {
    state = state.copyWith(showTaskCounts: !state.showTaskCounts);
  }

  void toggleDragAndDrop() {
    state = state.copyWith(enableDragAndDrop: !state.enableDragAndDrop);
  }

  void toggleBatchOperations() {
    state = state.copyWith(enableBatchOperations: !state.enableBatchOperations);
  }

  void toggleSwimLanes() {
    state = state.copyWith(enableSwimLanes: !state.enableSwimLanes);
  }

  void setViewMode(KanbanViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  void updateCustomSetting(String key, dynamic value) {
    final updatedSettings = Map<String, dynamic>.from(state.customSettings);
    updatedSettings[key] = value;
    state = state.copyWith(customSettings: updatedSettings);
  }

  void resetToDefaults() {
    state = KanbanBoardConfig();
  }

  void addColumn(KanbanColumnConfig column) {
    final updatedColumns = [...state.columns, column];
    state = state.copyWith(columns: updatedColumns);
  }

  void removeColumn(String columnId) {
    final updatedColumns = state.columns.where((c) => c.id != columnId).toList();
    state = state.copyWith(columns: updatedColumns);
  }

  void reorderColumns(int oldIndex, int newIndex) {
    final columns = List<KanbanColumnConfig>.from(state.columns);
    final column = columns.removeAt(oldIndex);
    columns.insert(newIndex, column);
    state = state.copyWith(columns: columns);
  }

  void updateColumn(String columnId, KanbanColumnConfig updatedColumn) {
    final columns = state.columns.map((c) => c.id == columnId ? updatedColumn : c).toList();
    state = state.copyWith(columns: columns);
  }
}

/// State notifier for drag and drop operations
class DragDropStateNotifier extends StateNotifier<DragDropState> {
  DragDropStateNotifier() : super(const DragDropState());

  void startDragging(TaskModel task) {
    state = state.copyWith(
      isDragging: true,
      draggedTask: task,
    );
  }

  void setTargetColumn(TaskStatus? status, String? columnId) {
    state = state.copyWith(
      targetColumn: status,
      hoveredColumnId: columnId,
    );
  }

  void endDragging() {
    state = const DragDropState();
  }

  void cancelDragging() {
    state = const DragDropState();
  }
}

/// Operations for Kanban board
class KanbanOperations {
  final TaskRepository _repository;

  KanbanOperations(this._repository);

  /// Move a task to a different status/column
  Future<void> moveTask(TaskModel task, TaskStatus newStatus) async {
    if (task.status == newStatus) return;

    final updatedTask = task.copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
    );

    await _repository.updateTask(updatedTask);
  }

  /// Batch move multiple tasks to a new status
  Future<void> batchMoveTasksToStatus(List<TaskModel> tasks, TaskStatus status) async {
    for (final task in tasks) {
      if (task.status != status) {
        final updatedTask = task.copyWith(
          status: status,
          updatedAt: DateTime.now(),
        );
        await _repository.updateTask(updatedTask);
      }
    }
  }

  /// Batch update priority for multiple tasks
  Future<void> batchUpdatePriority(List<TaskModel> tasks, TaskPriority priority) async {
    for (final task in tasks) {
      if (task.priority != priority) {
        final updatedTask = task.copyWith(
          priority: priority,
          updatedAt: DateTime.now(),
        );
        await _repository.updateTask(updatedTask);
      }
    }
  }

  /// Batch add tags to multiple tasks
  Future<void> batchAddTags(List<TaskModel> tasks, List<String> tagsToAdd) async {
    for (final task in tasks) {
      final newTags = [...task.tags];
      var updated = false;
      
      for (final tag in tagsToAdd) {
        if (!newTags.contains(tag)) {
          newTags.add(tag);
          updated = true;
        }
      }
      
      if (updated) {
        final updatedTask = task.copyWith(
          tags: newTags,
          updatedAt: DateTime.now(),
        );
        await _repository.updateTask(updatedTask);
      }
    }
  }

  /// Batch remove tags from multiple tasks
  Future<void> batchRemoveTags(List<TaskModel> tasks, List<String> tagsToRemove) async {
    for (final task in tasks) {
      final newTags = task.tags.where((tag) => !tagsToRemove.contains(tag)).toList();
      
      if (newTags.length != task.tags.length) {
        final updatedTask = task.copyWith(
          tags: newTags,
          updatedAt: DateTime.now(),
        );
        await _repository.updateTask(updatedTask);
      }
    }
  }

  /// Batch delete multiple tasks
  Future<void> batchDeleteTasks(List<TaskModel> tasks) async {
    for (final task in tasks) {
      await _repository.deleteTask(task.id);
    }
  }

  /// Create a new task in a specific column
  Future<TaskModel> createTaskInColumn(
    String title,
    TaskStatus status, {
    String? description,
    DateTime? dueDate,
    TaskPriority priority = TaskPriority.medium,
    List<String> tags = const [],
    String? projectId,
  }) async {
    final task = TaskModel.create(
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      tags: tags,
      projectId: projectId,
    );

    final taskWithStatus = task.copyWith(status: status);
    await _repository.createTask(taskWithStatus);
    
    return taskWithStatus;
  }

  /// Get task count for a specific status
  Future<int> getTaskCountForStatus(TaskStatus status, {String? projectId}) async {
    final tasks = await _repository.getTasksByStatus(status);
    
    if (projectId != null) {
      return tasks.where((task) => task.projectId == projectId).length;
    }
    
    return tasks.length;
  }

  /// Get tasks statistics for Kanban board
  Future<KanbanBoardStatistics> getBoardStatistics({String? projectId}) async {
    final allTasks = projectId != null
        ? await _repository.getTasksByProject(projectId)
        : await _repository.getAllTasks();

    final pendingCount = allTasks.where((t) => t.status == TaskStatus.pending).length;
    final inProgressCount = allTasks.where((t) => t.status == TaskStatus.inProgress).length;
    final completedCount = allTasks.where((t) => t.status == TaskStatus.completed).length;
    final cancelledCount = allTasks.where((t) => t.status == TaskStatus.cancelled).length;

    final overdueCount = allTasks.where((t) => t.isOverdue && !t.isCompleted).length;
    final highPriorityCount = allTasks.where((t) => t.priority.isHighPriority && !t.isCompleted).length;

    return KanbanBoardStatistics(
      totalTasks: allTasks.length,
      pendingTasks: pendingCount,
      inProgressTasks: inProgressCount,
      completedTasks: completedCount,
      cancelledTasks: cancelledCount,
      overdueTasks: overdueCount,
      highPriorityTasks: highPriorityCount,
    );
  }
}

/// Kanban board statistics
class KanbanBoardStatistics {
  final int totalTasks;
  final int pendingTasks;
  final int inProgressTasks;
  final int completedTasks;
  final int cancelledTasks;
  final int overdueTasks;
  final int highPriorityTasks;

  const KanbanBoardStatistics({
    required this.totalTasks,
    required this.pendingTasks,
    required this.inProgressTasks,
    required this.completedTasks,
    required this.cancelledTasks,
    required this.overdueTasks,
    required this.highPriorityTasks,
  });

  double get completionRate {
    if (totalTasks == 0) return 0.0;
    return completedTasks / totalTasks;
  }

  int get activeTasks => pendingTasks + inProgressTasks;

  @override
  String toString() {
    return 'KanbanBoardStatistics('
           'total: $totalTasks, '
           'pending: $pendingTasks, '
           'inProgress: $inProgressTasks, '
           'completed: $completedTasks, '
           'cancelled: $cancelledTasks, '
           'overdue: $overdueTasks, '
           'highPriority: $highPriorityTasks)';
  }
}

/// Predefined column configurations for different workflows
class KanbanColumnPresets {
  static final List<KanbanColumnConfig> agileWorkflow = [
    KanbanColumnConfig(
      id: 'backlog',
      title: 'Backlog',
      status: TaskStatus.pending,
      icon: PhosphorIcons.stack(),
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
      id: 'review',
      title: 'Review',
      status: TaskStatus.inProgress, // Could be extended with custom statuses
      icon: PhosphorIcons.magnifyingGlass(),
      color: Colors.orange,
    ),
    KanbanColumnConfig(
      id: 'done',
      title: 'Done',
      status: TaskStatus.completed,
      icon: PhosphorIcons.checkCircle(),
      color: Colors.green,
    ),
  ];

  static final List<KanbanColumnConfig> simpleWorkflow = [
    KanbanColumnConfig(
      id: 'todo',
      title: 'To Do',
      status: TaskStatus.pending,
      icon: PhosphorIcons.circle(),
      color: Colors.grey,
    ),
    KanbanColumnConfig(
      id: 'doing',
      title: 'Doing',
      status: TaskStatus.inProgress,
      icon: PhosphorIcons.arrowRight(),
      color: Colors.blue,
    ),
    KanbanColumnConfig(
      id: 'done',
      title: 'Done',
      status: TaskStatus.completed,
      icon: PhosphorIcons.checkCircle(),
      color: Colors.green,
    ),
  ];

  static final List<KanbanColumnConfig> personalWorkflow = [
    KanbanColumnConfig(
      id: 'ideas',
      title: 'Ideas',
      status: TaskStatus.pending,
      icon: PhosphorIcons.lightbulb(),
      color: Colors.yellow,
    ),
    KanbanColumnConfig(
      id: 'planned',
      title: 'Planned',
      status: TaskStatus.pending,
      icon: PhosphorIcons.calendar(),
      color: Colors.blue,
    ),
    KanbanColumnConfig(
      id: 'active',
      title: 'Active',
      status: TaskStatus.inProgress,
      icon: PhosphorIcons.rocket(),
      color: Colors.orange,
    ),
    KanbanColumnConfig(
      id: 'completed',
      title: 'Completed',
      status: TaskStatus.completed,
      icon: PhosphorIcons.star(),
      color: Colors.green,
    ),
  ];
}

/// Provider for available column presets
final columnPresetsProvider = Provider<Map<String, List<KanbanColumnConfig>>>((ref) {
  return {
    'agile': KanbanColumnPresets.agileWorkflow,
    'simple': KanbanColumnPresets.simpleWorkflow,
    'personal': KanbanColumnPresets.personalWorkflow,
  };
});

/// Provider for board statistics
final kanbanBoardStatsProvider = FutureProvider.family<KanbanBoardStatistics, String?>(
  (ref, projectId) async {
    final operations = ref.watch(kanbanOperationsProvider);
    return operations.getBoardStatistics(projectId: projectId);
  },
);

/// Provider for task count per status
final taskCountByStatusProvider = FutureProvider.family<Map<TaskStatus, int>, String?>(
  (ref, projectId) async {
    final operations = ref.watch(kanbanOperationsProvider);
    
    final counts = <TaskStatus, int>{};
    for (final status in TaskStatus.values) {
      counts[status] = await operations.getTaskCountForStatus(status, projectId: projectId);
    }
    
    return counts;
  },
);