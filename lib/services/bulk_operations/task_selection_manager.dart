import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../../core/constants/phosphor_icons.dart';

/// Manages task selection state across the entire application
/// 
/// This service provides centralized selection state management that works
/// across different views (home, project detail, Kanban board, etc.) with
/// proper cleanup and performance optimization.
class TaskSelectionManager extends StateNotifier<TaskSelectionState> {
  TaskSelectionManager() : super(TaskSelectionState());
  
  /// Toggle selection of a single task
  void toggleTask(TaskModel task) {
    final selectedTasks = Map<String, TaskModel>.from(state.selectedTasks);
    
    if (selectedTasks.containsKey(task.id)) {
      selectedTasks.remove(task.id);
      HapticFeedback.selectionClick(); // Deselection haptic
    } else {
      selectedTasks[task.id] = task;
      HapticFeedback.lightImpact(); // Selection haptic
    }
    
    state = state.copyWith(
      selectedTasks: selectedTasks,
      lastModified: DateTime.now(),
    );
  }
  
  /// Select all tasks from a given list
  void selectAll(List<TaskModel> tasks) {
    final selectedTasks = Map<String, TaskModel>.from(state.selectedTasks);
    
    for (final task in tasks) {
      selectedTasks[task.id] = task;
    }
    
    state = state.copyWith(
      selectedTasks: selectedTasks,
      lastModified: DateTime.now(),
    );
    
    HapticFeedback.mediumImpact(); // Bulk selection haptic
  }
  
  /// Deselect all tasks
  void deselectAll() {
    if (state.selectedTasks.isNotEmpty) {
      state = state.copyWith(
        selectedTasks: {},
        lastModified: DateTime.now(),
      );
      HapticFeedback.selectionClick();
    }
  }
  
  /// Select tasks within a range (useful for keyboard shortcuts)
  void selectRange(List<TaskModel> allTasks, TaskModel fromTask, TaskModel toTask) {
    final fromIndex = allTasks.indexWhere((t) => t.id == fromTask.id);
    final toIndex = allTasks.indexWhere((t) => t.id == toTask.id);
    
    if (fromIndex == -1 || toIndex == -1) return;
    
    final startIndex = fromIndex < toIndex ? fromIndex : toIndex;
    final endIndex = fromIndex > toIndex ? fromIndex : toIndex;
    
    final selectedTasks = Map<String, TaskModel>.from(state.selectedTasks);
    
    for (int i = startIndex; i <= endIndex; i++) {
      selectedTasks[allTasks[i].id] = allTasks[i];
    }
    
    state = state.copyWith(
      selectedTasks: selectedTasks,
      lastModified: DateTime.now(),
    );
    
    HapticFeedback.mediumImpact();
  }
  
  /// Select tasks by status
  void selectByStatus(List<TaskModel> allTasks, TaskStatus status) {
    final selectedTasks = Map<String, TaskModel>.from(state.selectedTasks);
    
    for (final task in allTasks) {
      if (task.status == status) {
        selectedTasks[task.id] = task;
      }
    }
    
    state = state.copyWith(
      selectedTasks: selectedTasks,
      lastModified: DateTime.now(),
    );
    
    HapticFeedback.lightImpact();
  }
  
  /// Select tasks by priority
  void selectByPriority(List<TaskModel> allTasks, TaskPriority priority) {
    final selectedTasks = Map<String, TaskModel>.from(state.selectedTasks);
    
    for (final task in allTasks) {
      if (task.priority == priority) {
        selectedTasks[task.id] = task;
      }
    }
    
    state = state.copyWith(
      selectedTasks: selectedTasks,
      lastModified: DateTime.now(),
    );
    
    HapticFeedback.lightImpact();
  }
  
  /// Select tasks by project
  void selectByProject(List<TaskModel> allTasks, String projectId) {
    final selectedTasks = Map<String, TaskModel>.from(state.selectedTasks);
    
    for (final task in allTasks) {
      if (task.projectId == projectId) {
        selectedTasks[task.id] = task;
      }
    }
    
    state = state.copyWith(
      selectedTasks: selectedTasks,
      lastModified: DateTime.now(),
    );
    
    HapticFeedback.lightImpact();
  }
  
  /// Invert current selection within a list of tasks
  void invertSelection(List<TaskModel> allTasks) {
    final selectedTasks = Map<String, TaskModel>.from(state.selectedTasks);
    
    for (final task in allTasks) {
      if (selectedTasks.containsKey(task.id)) {
        selectedTasks.remove(task.id);
      } else {
        selectedTasks[task.id] = task;
      }
    }
    
    state = state.copyWith(
      selectedTasks: selectedTasks,
      lastModified: DateTime.now(),
    );
    
    HapticFeedback.mediumImpact();
  }
  
  /// Remove tasks that no longer exist (cleanup)
  void cleanupDeletedTasks(List<TaskModel> existingTasks) {
    final existingIds = existingTasks.map((t) => t.id).toSet();
    final selectedTasks = Map<String, TaskModel>.from(state.selectedTasks);
    
    selectedTasks.removeWhere((id, _) => !existingIds.contains(id));
    
    if (selectedTasks.length != state.selectedTasks.length) {
      state = state.copyWith(
        selectedTasks: selectedTasks,
        lastModified: DateTime.now(),
      );
    }
  }
  
  /// Update task data if it has changed
  void updateTaskData(TaskModel updatedTask) {
    if (state.selectedTasks.containsKey(updatedTask.id)) {
      final selectedTasks = Map<String, TaskModel>.from(state.selectedTasks);
      selectedTasks[updatedTask.id] = updatedTask;
      
      state = state.copyWith(
        selectedTasks: selectedTasks,
        lastModified: DateTime.now(),
      );
    }
  }
  
  /// Set the current context (for view-specific behavior)
  void setContext(SelectionContext context, {Map<String, dynamic>? metadata}) {
    state = state.copyWith(
      currentContext: context,
      contextMetadata: metadata ?? {},
    );
  }
  
  /// Enable multi-select mode
  void enableMultiSelect() {
    if (!state.isMultiSelectMode) {
      state = state.copyWith(isMultiSelectMode: true);
      HapticFeedback.mediumImpact();
    }
  }
  
  /// Disable multi-select mode and clear selection
  void disableMultiSelect({bool clearSelection = true}) {
    if (state.isMultiSelectMode) {
      state = state.copyWith(
        isMultiSelectMode: false,
        selectedTasks: clearSelection ? {} : state.selectedTasks,
        lastModified: DateTime.now(),
      );
      HapticFeedback.selectionClick();
    }
  }
  
  /// Get selection statistics
  SelectionStatistics getStatistics() {
    final tasks = state.selectedTasks.values.toList();
    
    final statusGroups = groupBy(tasks, (TaskModel t) => t.status);
    final priorityGroups = groupBy(tasks, (TaskModel t) => t.priority);
    final projectGroups = groupBy(tasks, (TaskModel t) => t.projectId ?? 'none');
    
    final now = DateTime.now();
    final overdueCount = tasks.where((t) => 
      t.dueDate != null && 
      t.dueDate!.isBefore(now) && 
      t.status != TaskStatus.completed
    ).length;
    
    final dueTodayCount = tasks.where((t) => t.isDueToday).length;
    
    return SelectionStatistics(
      totalSelected: tasks.length,
      statusBreakdown: statusGroups.map((k, v) => MapEntry(k, v.length)),
      priorityBreakdown: priorityGroups.map((k, v) => MapEntry(k, v.length)),
      projectBreakdown: projectGroups.map((k, v) => MapEntry(k, v.length)),
      overdueCount: overdueCount,
      dueTodayCount: dueTodayCount,
      completedCount: statusGroups[TaskStatus.completed]?.length ?? 0,
      hasSubtasks: tasks.any((t) => t.hasSubTasks),
      hasDependencies: tasks.any((t) => t.hasDependencies),
      hasRecurring: tasks.any((t) => t.isRecurring),
    );
  }
}

/// State for task selection management
class TaskSelectionState {
  final Map<String, TaskModel> selectedTasks;
  final bool isMultiSelectMode;
  final SelectionContext currentContext;
  final Map<String, dynamic> contextMetadata;
  final DateTime lastModified;

  static final DateTime _defaultDateTime = DateTime.fromMillisecondsSinceEpoch(0);
  
  TaskSelectionState({
    this.selectedTasks = const {},
    this.isMultiSelectMode = false,
    this.currentContext = SelectionContext.home,
    this.contextMetadata = const {},
    DateTime? lastModified,
  }) : lastModified = lastModified ?? _defaultDateTime;
  
  TaskSelectionState copyWith({
    Map<String, TaskModel>? selectedTasks,
    bool? isMultiSelectMode,
    SelectionContext? currentContext,
    Map<String, dynamic>? contextMetadata,
    DateTime? lastModified,
  }) {
    return TaskSelectionState(
      selectedTasks: selectedTasks ?? this.selectedTasks,
      isMultiSelectMode: isMultiSelectMode ?? this.isMultiSelectMode,
      currentContext: currentContext ?? this.currentContext,
      contextMetadata: contextMetadata ?? this.contextMetadata,
      lastModified: lastModified ?? this.lastModified,
    );
  }
  
  /// Convenience getters
  bool get hasSelection => selectedTasks.isNotEmpty;
  int get selectionCount => selectedTasks.length;
  List<TaskModel> get selectedTasksList => selectedTasks.values.toList();
  List<String> get selectedTaskIds => selectedTasks.keys.toList();
  
  /// Check if a task is selected
  bool isSelected(String taskId) => selectedTasks.containsKey(taskId);
  
  /// Get selected tasks grouped by status
  Map<TaskStatus, List<TaskModel>> get tasksByStatus {
    return groupBy(selectedTasksList, (TaskModel t) => t.status);
  }
  
  /// Get selected tasks grouped by priority
  Map<TaskPriority, List<TaskModel>> get tasksByPriority {
    return groupBy(selectedTasksList, (TaskModel t) => t.priority);
  }
  
  /// Get selected tasks grouped by project
  Map<String, List<TaskModel>> get tasksByProject {
    return groupBy(selectedTasksList, (TaskModel t) => t.projectId ?? 'none');
  }
}

/// Context for where selection is happening
enum SelectionContext {
  home,
  projectDetail,
  kanbanBoard,
  timeline,
  tasksList,
  search,
  calendar,
}

/// Statistics about current selection
class SelectionStatistics {
  final int totalSelected;
  final Map<TaskStatus, int> statusBreakdown;
  final Map<TaskPriority, int> priorityBreakdown;
  final Map<String, int> projectBreakdown;
  final int overdueCount;
  final int dueTodayCount;
  final int completedCount;
  final bool hasSubtasks;
  final bool hasDependencies;
  final bool hasRecurring;
  
  const SelectionStatistics({
    required this.totalSelected,
    required this.statusBreakdown,
    required this.priorityBreakdown,
    required this.projectBreakdown,
    required this.overdueCount,
    required this.dueTodayCount,
    required this.completedCount,
    required this.hasSubtasks,
    required this.hasDependencies,
    required this.hasRecurring,
  });
  
  /// Get the most common status
  TaskStatus? get mostCommonStatus {
    if (statusBreakdown.isEmpty) return null;
    
    return statusBreakdown.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
  
  /// Get the most common priority
  TaskPriority? get mostCommonPriority {
    if (priorityBreakdown.isEmpty) return null;
    
    return priorityBreakdown.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
  
  /// Check if all selected tasks belong to the same project
  bool get allSameProject => projectBreakdown.length <= 1;
  
  /// Check if all selected tasks have the same status
  bool get allSameStatus => statusBreakdown.length <= 1;
  
  /// Check if all selected tasks have the same priority
  bool get allSamePriority => priorityBreakdown.length <= 1;
  
  /// Get suggested bulk actions based on statistics
  List<BulkActionSuggestion> get suggestedActions {
    final suggestions = <BulkActionSuggestion>[];
    
    // Status-based suggestions
    if (overdueCount > 0) {
      suggestions.add(BulkActionSuggestion(
        type: BulkActionType.reschedule,
        title: 'Reschedule Overdue Tasks',
        description: 'Set new due dates for $overdueCount overdue tasks',
        priority: BulkActionPriority.high,
        icon: PhosphorIconConstants.allIcons['calendar']!,
      ));
    }
    
    if (dueTodayCount > 0) {
      suggestions.add(BulkActionSuggestion(
        type: BulkActionType.changeStatus,
        title: 'Mark Due Today as In Progress',
        description: 'Update $dueTodayCount tasks due today',
        priority: BulkActionPriority.medium,
        icon: PhosphorIconConstants.allIcons['clock']!,
      ));
    }
    
    // Priority-based suggestions
    if (priorityBreakdown.length > 1) {
      suggestions.add(BulkActionSuggestion(
        type: BulkActionType.changePriority,
        title: 'Standardize Priority',
        description: 'Set same priority for all selected tasks',
        priority: BulkActionPriority.low,
        icon: PhosphorIconConstants.allIcons['target']!,
      ));
    }
    
    // Project-based suggestions
    if (projectBreakdown.length > 1) {
      suggestions.add(BulkActionSuggestion(
        type: BulkActionType.moveToProject,
        title: 'Move to Same Project',
        description: 'Organize tasks under one project',
        priority: BulkActionPriority.medium,
        icon: PhosphorIconConstants.allIcons['folder']!,
      ));
    }
    
    // General suggestions
    if (totalSelected > 1) {
      suggestions.add(BulkActionSuggestion(
        type: BulkActionType.addTags,
        title: 'Add Common Tags',
        description: 'Tag all selected tasks',
        priority: BulkActionPriority.low,
        icon: PhosphorIconConstants.allIcons['tag']!,
      ));
      
      suggestions.add(BulkActionSuggestion(
        type: BulkActionType.duplicate,
        title: 'Duplicate Tasks',
        description: 'Create copies of selected tasks',
        priority: BulkActionPriority.low,
        icon: PhosphorIconConstants.allIcons['copy']!,
      ));
    }
    
    return suggestions..sort((a, b) => b.priority.index.compareTo(a.priority.index));
  }
}

/// Bulk action suggestion
class BulkActionSuggestion {
  final BulkActionType type;
  final String title;
  final String description;
  final BulkActionPriority priority;
  final IconData icon;
  
  const BulkActionSuggestion({
    required this.type,
    required this.title,
    required this.description,
    required this.priority,
    required this.icon,
  });
}

/// Types of bulk actions
enum BulkActionType {
  delete,
  changeStatus,
  changePriority,
  moveToProject,
  addTags,
  removeTags,
  reschedule,
  duplicate,
  archive,
  pin,
  unpin,
}

/// Priority of bulk action suggestions
enum BulkActionPriority {
  low,
  medium,
  high,
}

