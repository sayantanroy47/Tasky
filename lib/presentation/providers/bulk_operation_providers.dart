import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/core_providers.dart';
import '../../services/bulk_operations/task_selection_manager.dart';
import '../../services/bulk_operations/bulk_operation_service.dart';
import '../../services/bulk_operations/project_migration_service.dart';
import '../../services/bulk_operations/bulk_operation_history.dart';
import '../../services/performance_service.dart';
import '../../domain/models/enums.dart';
import '../../domain/entities/task_model.dart';
import 'notification_providers.dart';

/// Provider for task selection manager (global selection state)
final taskSelectionProvider = StateNotifierProvider<TaskSelectionManager, TaskSelectionState>((ref) {
  return TaskSelectionManager();
});

/// Provider for bulk operation history
final bulkOperationHistoryProvider = Provider<BulkOperationHistory>((ref) {
  return BulkOperationHistory();
});

/// Provider for bulk operation service
final bulkOperationServiceProvider = Provider<BulkOperationService>((ref) {
  final taskRepository = ref.watch(taskRepositoryProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  final performanceService = ref.watch(performanceServiceProvider);
  final history = ref.watch(bulkOperationHistoryProvider);
  
  return BulkOperationService(
    taskRepository: taskRepository,
    notificationService: notificationService,
    performanceService: performanceService,
    history: history,
  );
});

/// Provider for project migration service
final projectMigrationServiceProvider = Provider<ProjectMigrationService>((ref) {
  final taskRepository = ref.watch(taskRepositoryProvider);
  final projectRepository = ref.watch(projectRepositoryProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  final performanceService = ref.watch(performanceServiceProvider);
  final history = ref.watch(bulkOperationHistoryProvider);
  
  return ProjectMigrationService(
    taskRepository: taskRepository,
    projectRepository: projectRepository,
    notificationService: notificationService,
    performanceService: performanceService,
    history: history,
  );
});


/// Provider for performance service
final performanceServiceProvider = Provider<PerformanceService>((ref) {
  return PerformanceService();
});

/// Provider for bulk operation progress streams
final bulkOperationProgressProvider = StreamProvider.family<BulkOperationProgress, String>((ref, operationId) {
  final bulkService = ref.watch(bulkOperationServiceProvider);
  final progressStream = bulkService.getProgressStream(operationId);
  
  if (progressStream == null) {
    return const Stream.empty();
  }
  
  return progressStream;
});

/// Provider for project migration progress streams
final migrationProgressProvider = StreamProvider.family<MigrationProgress, String>((ref, operationId) {
  final migrationService = ref.watch(projectMigrationServiceProvider);
  final progressStream = migrationService.getProgressStream(operationId);
  
  if (progressStream == null) {
    return const Stream.empty();
  }
  
  return progressStream;
});

/// Provider for bulk operation history stream
final operationHistoryProvider = StreamProvider<List<BulkOperationRecord>>((ref) {
  final history = ref.watch(bulkOperationHistoryProvider);
  return history.getOperationHistory();
});

/// Provider for undoable operations
final undoableOperationsProvider = FutureProvider<List<BulkOperationRecord>>((ref) async {
  final history = ref.watch(bulkOperationHistoryProvider);
  return await history.getUndoableOperations();
});

/// Provider for history statistics
final historyStatisticsProvider = Provider<HistoryStatistics>((ref) {
  final history = ref.watch(bulkOperationHistoryProvider);
  return history.getStatistics();
});

/// State notifier for managing bulk operations UI state
class BulkOperationUiNotifier extends StateNotifier<BulkOperationUiState> {
  BulkOperationUiNotifier() : super(const BulkOperationUiState());
  
  void showProgressDialog(String operationId, String title, String description) {
    state = state.copyWith(
      activeOperationId: operationId,
      progressDialogTitle: title,
      progressDialogDescription: description,
      showProgressDialog: true,
    );
  }
  
  void hideProgressDialog() {
    state = state.copyWith(
      showProgressDialog: false,
      activeOperationId: null,
      progressDialogTitle: null,
      progressDialogDescription: null,
    );
  }
  
  void setLastOperationResult(BulkOperationResult result) {
    state = state.copyWith(lastOperationResult: result);
  }
  
  void clearLastOperationResult() {
    state = state.copyWith(lastOperationResult: null);
  }
  
  void setShowUndoSnackbar(bool show) {
    state = state.copyWith(showUndoSnackbar: show);
  }
}

/// Provider for bulk operation UI state
final bulkOperationUiProvider = StateNotifierProvider<BulkOperationUiNotifier, BulkOperationUiState>((ref) {
  return BulkOperationUiNotifier();
});

/// UI state for bulk operations
class BulkOperationUiState {
  final bool showProgressDialog;
  final String? activeOperationId;
  final String? progressDialogTitle;
  final String? progressDialogDescription;
  final BulkOperationResult? lastOperationResult;
  final bool showUndoSnackbar;
  
  const BulkOperationUiState({
    this.showProgressDialog = false,
    this.activeOperationId,
    this.progressDialogTitle,
    this.progressDialogDescription,
    this.lastOperationResult,
    this.showUndoSnackbar = false,
  });
  
  BulkOperationUiState copyWith({
    bool? showProgressDialog,
    String? activeOperationId,
    String? progressDialogTitle,
    String? progressDialogDescription,
    BulkOperationResult? lastOperationResult,
    bool? showUndoSnackbar,
  }) {
    return BulkOperationUiState(
      showProgressDialog: showProgressDialog ?? this.showProgressDialog,
      activeOperationId: activeOperationId ?? this.activeOperationId,
      progressDialogTitle: progressDialogTitle ?? this.progressDialogTitle,
      progressDialogDescription: progressDialogDescription ?? this.progressDialogDescription,
      lastOperationResult: lastOperationResult ?? this.lastOperationResult,
      showUndoSnackbar: showUndoSnackbar ?? this.showUndoSnackbar,
    );
  }
}

/// Provider for selection statistics
final selectionStatisticsProvider = Provider<SelectionStatistics>((ref) {
  final selectionManager = ref.watch(taskSelectionProvider.notifier);
  return selectionManager.getStatistics();
});

/// Provider for suggested bulk actions based on current selection
final suggestedBulkActionsProvider = Provider<List<BulkActionSuggestion>>((ref) {
  final statistics = ref.watch(selectionStatisticsProvider);
  return statistics.suggestedActions;
});

/// Provider for checking if multi-select mode is active
final isMultiSelectModeProvider = Provider<bool>((ref) {
  final selectionState = ref.watch(taskSelectionProvider);
  return selectionState.isMultiSelectMode;
});

/// Provider for checking if tasks are selected
final hasTaskSelectionProvider = Provider<bool>((ref) {
  final selectionState = ref.watch(taskSelectionProvider);
  return selectionState.hasSelection;
});

/// Provider for selected tasks count
final selectedTasksCountProvider = Provider<int>((ref) {
  final selectionState = ref.watch(taskSelectionProvider);
  return selectionState.selectionCount;
});

/// Provider for selected tasks list
final selectedTasksProvider = Provider<List<TaskModel>>((ref) {
  final selectionState = ref.watch(taskSelectionProvider);
  return selectionState.selectedTasksList;
});

/// State notifier for managing bulk operation templates
class BulkOperationTemplatesNotifier extends StateNotifier<List<BulkOperationTemplate>> {
  BulkOperationTemplatesNotifier() : super(_defaultTemplates);
  
  void addTemplate(BulkOperationTemplate template) {
    state = [...state, template];
  }
  
  void removeTemplate(String templateId) {
    state = state.where((template) => template.id != templateId).toList();
  }
  
  void updateTemplate(BulkOperationTemplate updatedTemplate) {
    state = [
      for (final template in state)
        if (template.id == updatedTemplate.id)
          updatedTemplate
        else
          template,
    ];
  }
  
  static const List<BulkOperationTemplate> _defaultTemplates = [
    BulkOperationTemplate(
      id: 'complete_all',
      name: 'Complete All',
      description: 'Mark all selected tasks as completed',
      actions: [
        BulkTemplateAction(
          type: BulkActionType.changeStatus,
          parameters: {'status': 'completed'},
        ),
      ],
    ),
    BulkOperationTemplate(
      id: 'high_priority',
      name: 'Set High Priority',
      description: 'Set all selected tasks to high priority',
      actions: [
        BulkTemplateAction(
          type: BulkActionType.changePriority,
          parameters: {'priority': 'high'},
        ),
      ],
    ),
    BulkOperationTemplate(
      id: 'organize_urgent',
      name: 'Organize Urgent',
      description: 'Tag urgent tasks and set high priority',
      actions: [
        BulkTemplateAction(
          type: BulkActionType.addTags,
          parameters: {'tags': ['urgent', 'priority']},
        ),
        BulkTemplateAction(
          type: BulkActionType.changePriority,
          parameters: {'priority': 'urgent'},
        ),
      ],
    ),
  ];
}

/// Provider for bulk operation templates
final bulkOperationTemplatesProvider = StateNotifierProvider<BulkOperationTemplatesNotifier, List<BulkOperationTemplate>>((ref) {
  return BulkOperationTemplatesNotifier();
});

/// Template for bulk operations
class BulkOperationTemplate {
  final String id;
  final String name;
  final String description;
  final List<BulkTemplateAction> actions;
  final DateTime? createdAt;
  final Map<String, dynamic> metadata;
  
  const BulkOperationTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.actions,
    this.createdAt,
    this.metadata = const {},
  });
  
  BulkOperationTemplate copyWith({
    String? id,
    String? name,
    String? description,
    List<BulkTemplateAction>? actions,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return BulkOperationTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      actions: actions ?? this.actions,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Action within a bulk operation template
class BulkTemplateAction {
  final BulkActionType type;
  final Map<String, dynamic> parameters;
  
  const BulkTemplateAction({
    required this.type,
    required this.parameters,
  });
}

/// Provider for executing bulk operation templates
final bulkOperationTemplateExecutorProvider = Provider((ref) {
  return BulkOperationTemplateExecutor(
    bulkService: ref.watch(bulkOperationServiceProvider),
    ref: ref,
  );
});

/// Service for executing bulk operation templates
class BulkOperationTemplateExecutor {
  final BulkOperationService _bulkService;
  final Ref _ref;
  
  BulkOperationTemplateExecutor({
    required BulkOperationService bulkService,
    required Ref ref,
  }) : _bulkService = bulkService, _ref = ref;
  
  Future<List<BulkOperationResult>> executeTemplate(BulkOperationTemplate template) async {
    final selectionState = _ref.read(taskSelectionProvider);
    final selectedTasks = selectionState.selectedTasksList;
    if (selectedTasks.isEmpty) {
      throw Exception('No tasks selected');
    }
    
    final results = <BulkOperationResult>[];
    
    for (final action in template.actions) {
      BulkOperationResult result;
      
      switch (action.type) {
        case BulkActionType.changeStatus:
          final statusString = action.parameters['status'] as String;
          final status = TaskStatus.values.byName(statusString);
          result = await _bulkService.bulkUpdateStatus(selectedTasks, status);
          break;
          
        case BulkActionType.changePriority:
          final priorityString = action.parameters['priority'] as String;
          final priority = TaskPriority.values.byName(priorityString);
          result = await _bulkService.bulkUpdatePriority(selectedTasks, priority);
          break;
          
        case BulkActionType.addTags:
          final tags = List<String>.from(action.parameters['tags']);
          result = await _bulkService.bulkAddTags(selectedTasks, tags);
          break;
          
        case BulkActionType.removeTags:
          final tags = List<String>.from(action.parameters['tags']);
          result = await _bulkService.bulkRemoveTags(selectedTasks, tags);
          break;
          
        case BulkActionType.moveToProject:
          final projectId = action.parameters['projectId'] as String?;
          result = await _bulkService.bulkMoveToProject(selectedTasks, projectId);
          break;
          
        case BulkActionType.delete:
          result = await _bulkService.bulkDeleteTasks(selectedTasks);
          break;
          
        default:
          throw UnimplementedError('Action type ${action.type} not supported in templates');
      }
      
      results.add(result);
      
      // If any operation fails significantly, stop execution
      if (result.failedTasks > result.successfulTasks) {
        break;
      }
    }
    
    return results;
  }
}

/// Provider for bulk operation metrics and analytics
final bulkOperationMetricsProvider = FutureProvider<BulkOperationMetrics>((ref) async {
  final history = ref.watch(bulkOperationHistoryProvider);
  final currentHistory = await history.getCurrentHistory();
  
  return _calculateMetrics(currentHistory);
});

/// Calculate metrics from operation history
BulkOperationMetrics _calculateMetrics(List<BulkOperationRecord> history) {
  final now = DateTime.now();
  final last24Hours = now.subtract(const Duration(hours: 24));
  final lastWeek = now.subtract(const Duration(days: 7));
  final lastMonth = now.subtract(const Duration(days: 30));
  
  final recentOperations = history.where((op) => op.timestamp.isAfter(last24Hours)).toList();
  final weeklyOperations = history.where((op) => op.timestamp.isAfter(lastWeek)).toList();
  final monthlyOperations = history.where((op) => op.timestamp.isAfter(lastMonth)).toList();
  
  final totalTasksProcessed = history.fold<int>(0, (sum, op) => sum + op.taskSnapshots.length);
  final totalSuccessfulTasks = history.fold<int>(0, (sum, op) => sum + op.successfulTasks);
  final totalFailedTasks = history.fold<int>(0, (sum, op) => sum + op.failedTasks);
  
  final averageExecutionTime = history.isNotEmpty
      ? Duration(
          milliseconds: history
              .map((op) => op.executionTime.inMilliseconds)
              .reduce((a, b) => a + b) ~/
              history.length,
        )
      : Duration.zero;
  
  final operationTypeBreakdown = <BulkOperationType, int>{};
  for (final op in history) {
    operationTypeBreakdown[op.type] = (operationTypeBreakdown[op.type] ?? 0) + 1;
  }
  
  return BulkOperationMetrics(
    totalOperations: history.length,
    recentOperations: recentOperations.length,
    weeklyOperations: weeklyOperations.length,
    monthlyOperations: monthlyOperations.length,
    totalTasksProcessed: totalTasksProcessed,
    totalSuccessfulTasks: totalSuccessfulTasks,
    totalFailedTasks: totalFailedTasks,
    successRate: totalTasksProcessed > 0 ? totalSuccessfulTasks / totalTasksProcessed : 0.0,
    averageExecutionTime: averageExecutionTime,
    operationTypeBreakdown: operationTypeBreakdown,
    mostCommonOperationType: operationTypeBreakdown.entries
        .fold<MapEntry<BulkOperationType, int>?>(null, (prev, entry) =>
            prev == null || entry.value > prev.value ? entry : prev)
        ?.key,
  );
}

/// Metrics for bulk operations
class BulkOperationMetrics {
  final int totalOperations;
  final int recentOperations;
  final int weeklyOperations;
  final int monthlyOperations;
  final int totalTasksProcessed;
  final int totalSuccessfulTasks;
  final int totalFailedTasks;
  final double successRate;
  final Duration averageExecutionTime;
  final Map<BulkOperationType, int> operationTypeBreakdown;
  final BulkOperationType? mostCommonOperationType;
  
  const BulkOperationMetrics({
    required this.totalOperations,
    required this.recentOperations,
    required this.weeklyOperations,
    required this.monthlyOperations,
    required this.totalTasksProcessed,
    required this.totalSuccessfulTasks,
    required this.totalFailedTasks,
    required this.successRate,
    required this.averageExecutionTime,
    required this.operationTypeBreakdown,
    this.mostCommonOperationType,
  });
}
