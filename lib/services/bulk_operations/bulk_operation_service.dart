import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/task_model.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/models/enums.dart';
import '../notification/notification_service.dart';
import '../performance_service.dart';
import 'bulk_operation_history.dart';

/// Service for coordinating bulk operations on tasks with performance optimization,
/// progress tracking, and undo/redo functionality.
/// 
/// This service handles:
/// - Bulk task operations with smart batching
/// - Background processing for large datasets
/// - Progress tracking with real-time updates
/// - Conflict resolution and validation
/// - Undo/redo functionality
/// - Performance monitoring
class BulkOperationService {
  final TaskRepository _taskRepository;
  final ProjectRepository _projectRepository;
  final NotificationService _notificationService;
  final PerformanceService _performanceService;
  final BulkOperationHistory _history;
  
  static const int _batchSize = 50; // Process 50 tasks at a time
  static const Duration _batchDelay = Duration(milliseconds: 10); // Small delay between batches
  
  final Map<String, StreamController<BulkOperationProgress>> _progressControllers = {};
  final Map<String, CancelToken> _cancelTokens = {};
  
  BulkOperationService({
    required TaskRepository taskRepository,
    required ProjectRepository projectRepository,
    required NotificationService notificationService,
    required PerformanceService performanceService,
    BulkOperationHistory? history,
  })  : _taskRepository = taskRepository,
        _projectRepository = projectRepository,
        _notificationService = notificationService,
        _performanceService = performanceService,
        _history = history ?? BulkOperationHistory();
  
  /// Delete multiple tasks with progress tracking and undo functionality
  Future<BulkOperationResult> bulkDeleteTasks(
    List<TaskModel> tasks, {
    bool showNotification = true,
    bool enableUndo = true,
  }) async {
    final operationId = const Uuid().v4();
    final startTime = DateTime.now();
    
    return _performanceService.trackOperation(
      'bulk_delete_tasks',
      () => _executeBulkOperation<void>(
        operationId: operationId,
        operationType: BulkOperationType.delete,
        tasks: tasks,
        showNotification: showNotification,
        enableUndo: enableUndo,
        operation: (batch, progress) async {
          // Create backup for undo
          if (enableUndo) {
            await _history.recordOperation(BulkOperationRecord(
              id: operationId,
              type: BulkOperationType.delete,
              taskSnapshots: batch,
              timestamp: startTime,
              metadata: {'operation': 'delete', 'count': batch.length},
            ));
          }
          
          // Delete tasks in batch
          final taskIds = batch.map((t) => t.id).toList();
          await _taskRepository.deleteTasks(taskIds);
          
          // Provide haptic feedback
          HapticFeedback.mediumImpact();
          
          return; // Delete doesn't return data
        },
      ),
    );
  }
  
  /// Update status for multiple tasks
  Future<BulkOperationResult> bulkUpdateStatus(
    List<TaskModel> tasks,
    TaskStatus newStatus, {
    bool showNotification = true,
    bool enableUndo = true,
  }) async {
    final operationId = const Uuid().v4();
    final startTime = DateTime.now();
    
    return _performanceService.trackOperation(
      'bulk_update_status',
      () => _executeBulkOperation<void>(
        operationId: operationId,
        operationType: BulkOperationType.updateStatus,
        tasks: tasks,
        showNotification: showNotification,
        enableUndo: enableUndo,
        operation: (batch, progress) async {
          // Create backup for undo
          if (enableUndo) {
            await _history.recordOperation(BulkOperationRecord(
              id: operationId,
              type: BulkOperationType.updateStatus,
              taskSnapshots: batch,
              timestamp: startTime,
              metadata: {
                'operation': 'updateStatus',
                'oldStatus': batch.first.status,
                'newStatus': newStatus,
                'count': batch.length,
              },
            ));
          }
          
          // Update status in batch
          final taskIds = batch.map((t) => t.id).toList();
          await _taskRepository.updateTasksStatus(taskIds, newStatus);
          
          // Provide haptic feedback
          HapticFeedback.lightImpact();
          
          return;
        },
      ),
    );
  }
  
  /// Update priority for multiple tasks
  Future<BulkOperationResult> bulkUpdatePriority(
    List<TaskModel> tasks,
    TaskPriority newPriority, {
    bool showNotification = true,
    bool enableUndo = true,
  }) async {
    final operationId = const Uuid().v4();
    final startTime = DateTime.now();
    
    return _performanceService.trackOperation(
      'bulk_update_priority',
      () => _executeBulkOperation<void>(
        operationId: operationId,
        operationType: BulkOperationType.updatePriority,
        tasks: tasks,
        showNotification: showNotification,
        enableUndo: enableUndo,
        operation: (batch, progress) async {
          // Create backup for undo
          if (enableUndo) {
            await _history.recordOperation(BulkOperationRecord(
              id: operationId,
              type: BulkOperationType.updatePriority,
              taskSnapshots: batch,
              timestamp: startTime,
              metadata: {
                'operation': 'updatePriority',
                'oldPriority': batch.first.priority,
                'newPriority': newPriority,
                'count': batch.length,
              },
            ));
          }
          
          // Update priority in batch
          final taskIds = batch.map((t) => t.id).toList();
          await _taskRepository.updateTasksPriority(taskIds, newPriority);
          
          HapticFeedback.lightImpact();
          return;
        },
      ),
    );
  }
  
  /// Move multiple tasks to a project
  Future<BulkOperationResult> bulkMoveToProject(
    List<TaskModel> tasks,
    String? projectId, {
    bool showNotification = true,
    bool enableUndo = true,
  }) async {
    final operationId = const Uuid().v4();
    final startTime = DateTime.now();
    
    return _performanceService.trackOperation(
      'bulk_move_to_project',
      () => _executeBulkOperation<void>(
        operationId: operationId,
        operationType: BulkOperationType.moveToProject,
        tasks: tasks,
        showNotification: showNotification,
        enableUndo: enableUndo,
        operation: (batch, progress) async {
          // Create backup for undo
          if (enableUndo) {
            await _history.recordOperation(BulkOperationRecord(
              id: operationId,
              type: BulkOperationType.moveToProject,
              taskSnapshots: batch,
              timestamp: startTime,
              metadata: {
                'operation': 'moveToProject',
                'oldProjectIds': batch.map((t) => t.projectId).toList(),
                'newProjectId': projectId,
                'count': batch.length,
              },
            ));
          }
          
          // Move to project in batch
          final taskIds = batch.map((t) => t.id).toList();
          await _taskRepository.assignTasksToProject(taskIds, projectId);
          
          HapticFeedback.lightImpact();
          return;
        },
      ),
    );
  }
  
  /// Add tags to multiple tasks
  Future<BulkOperationResult> bulkAddTags(
    List<TaskModel> tasks,
    List<String> tagsToAdd, {
    bool showNotification = true,
    bool enableUndo = true,
  }) async {
    final operationId = const Uuid().v4();
    final startTime = DateTime.now();
    
    return _performanceService.trackOperation(
      'bulk_add_tags',
      () => _executeBulkOperation<void>(
        operationId: operationId,
        operationType: BulkOperationType.addTags,
        tasks: tasks,
        showNotification: showNotification,
        enableUndo: enableUndo,
        operation: (batch, progress) async {
          // Create backup for undo
          if (enableUndo) {
            await _history.recordOperation(BulkOperationRecord(
              id: operationId,
              type: BulkOperationType.addTags,
              taskSnapshots: batch,
              timestamp: startTime,
              metadata: {
                'operation': 'addTags',
                'tagsToAdd': tagsToAdd,
                'count': batch.length,
              },
            ));
          }
          
          // Process each task individually for tag updates
          final updatedTasks = <TaskModel>[];
          
          for (final task in batch) {
            final currentTags = Set<String>.from(task.tags);
            final newTags = Set<String>.from(tagsToAdd);
            currentTags.addAll(newTags);
            
            if (currentTags.length != task.tags.length) {
              final updatedTask = task.copyWith(tags: currentTags.toList());
              await _taskRepository.updateTask(updatedTask);
              updatedTasks.add(updatedTask);
            }
          }
          
          HapticFeedback.lightImpact();
          return;
        },
      ),
    );
  }
  
  /// Remove tags from multiple tasks
  Future<BulkOperationResult> bulkRemoveTags(
    List<TaskModel> tasks,
    List<String> tagsToRemove, {
    bool showNotification = true,
    bool enableUndo = true,
  }) async {
    final operationId = const Uuid().v4();
    final startTime = DateTime.now();
    
    return _performanceService.trackOperation(
      'bulk_remove_tags',
      () => _executeBulkOperation<void>(
        operationId: operationId,
        operationType: BulkOperationType.removeTags,
        tasks: tasks,
        showNotification: showNotification,
        enableUndo: enableUndo,
        operation: (batch, progress) async {
          // Create backup for undo
          if (enableUndo) {
            await _history.recordOperation(BulkOperationRecord(
              id: operationId,
              type: BulkOperationType.removeTags,
              taskSnapshots: batch,
              timestamp: startTime,
              metadata: {
                'operation': 'removeTags',
                'tagsToRemove': tagsToRemove,
                'count': batch.length,
              },
            ));
          }
          
          // Process each task individually for tag updates
          final updatedTasks = <TaskModel>[];
          
          for (final task in batch) {
            final currentTags = Set<String>.from(task.tags);
            final originalTagsLength = currentTags.length;
            currentTags.removeAll(tagsToRemove);
            
            if (currentTags.length != originalTagsLength) {
              final updatedTask = task.copyWith(tags: currentTags.toList());
              await _taskRepository.updateTask(updatedTask);
              updatedTasks.add(updatedTask);
            }
          }
          
          HapticFeedback.lightImpact();
          return;
        },
      ),
    );
  }
  
  /// Reschedule multiple tasks to new due dates
  Future<BulkOperationResult> bulkReschedule(
    List<TaskModel> tasks,
    DateTime newDueDate, {
    RescheduleStrategy strategy = RescheduleStrategy.absolute,
    Duration? relativeDuration,
    bool showNotification = true,
    bool enableUndo = true,
  }) async {
    final operationId = const Uuid().v4();
    final startTime = DateTime.now();
    
    return _performanceService.trackOperation(
      'bulk_reschedule',
      () => _executeBulkOperation<void>(
        operationId: operationId,
        operationType: BulkOperationType.reschedule,
        tasks: tasks,
        showNotification: showNotification,
        enableUndo: enableUndo,
        operation: (batch, progress) async {
          // Create backup for undo
          if (enableUndo) {
            await _history.recordOperation(BulkOperationRecord(
              id: operationId,
              type: BulkOperationType.reschedule,
              taskSnapshots: batch,
              timestamp: startTime,
              metadata: {
                'operation': 'reschedule',
                'strategy': strategy.name,
                'newDueDate': newDueDate.toIso8601String(),
                'relativeDuration': relativeDuration?.inMilliseconds,
                'count': batch.length,
              },
            ));
          }
          
          // Process each task individually for rescheduling
          for (final task in batch) {
            DateTime? taskNewDueDate;
            
            switch (strategy) {
              case RescheduleStrategy.absolute:
                taskNewDueDate = newDueDate;
                break;
              case RescheduleStrategy.relative:
                if (relativeDuration != null) {
                  taskNewDueDate = (task.dueDate ?? DateTime.now()).add(relativeDuration);
                }
                break;
              case RescheduleStrategy.preserveTime:
                if (task.dueDate != null) {
                  taskNewDueDate = DateTime(
                    newDueDate.year,
                    newDueDate.month,
                    newDueDate.day,
                    task.dueDate!.hour,
                    task.dueDate!.minute,
                    task.dueDate!.second,
                  );
                } else {
                  taskNewDueDate = newDueDate;
                }
                break;
            }
            
            if (taskNewDueDate != null) {
              final updatedTask = task.copyWith(dueDate: taskNewDueDate);
              await _taskRepository.updateTask(updatedTask);
            }
          }
          
          HapticFeedback.lightImpact();
          return;
        },
      ),
    );
  }
  
  /// Duplicate multiple tasks with smart naming
  Future<BulkOperationResult<List<TaskModel>>> bulkDuplicate(
    List<TaskModel> tasks, {
    DuplicationStrategy strategy = DuplicationStrategy.smartNaming,
    String? nameSuffix,
    bool includeSubtasks = true,
    bool showNotification = true,
  }) async {
    final operationId = const Uuid().v4();
    final startTime = DateTime.now();
    
    return _performanceService.trackOperation(
      'bulk_duplicate',
      () => _executeBulkOperation<List<TaskModel>>(
        operationId: operationId,
        operationType: BulkOperationType.duplicate,
        tasks: tasks,
        showNotification: showNotification,
        enableUndo: false, // Duplication creates new tasks, no undo needed
        operation: (batch, progress) async {
          final duplicatedTasks = <TaskModel>[];
          
          for (final task in batch) {
            String newTitle;
            
            switch (strategy) {
              case DuplicationStrategy.smartNaming:
                newTitle = _generateSmartDuplicateName(task.title);
                break;
              case DuplicationStrategy.suffix:
                newTitle = '${task.title} ${nameSuffix ?? '(Copy)'}';
                break;
              case DuplicationStrategy.prefix:
                newTitle = '${nameSuffix ?? 'Copy of'} ${task.title}';
                break;
              case DuplicationStrategy.keepOriginal:
                newTitle = task.title;
                break;
            }
            
            final duplicatedTask = TaskModel.create(
              title: newTitle,
              description: task.description,
              priority: task.priority,
              tags: List<String>.from(task.tags),
              locationTrigger: task.locationTrigger,
              projectId: task.projectId,
              estimatedDuration: task.estimatedDuration,
              metadata: {
                ...task.metadata,
                'duplicated_from': task.id,
                'duplicate_strategy': strategy.name,
              },
            );
            
            await _taskRepository.createTask(duplicatedTask);
            duplicatedTasks.add(duplicatedTask);
          }
          
          HapticFeedback.lightImpact();
          return duplicatedTasks;
        },
      ),
    );
  }
  
  /// Execute a bulk operation with progress tracking and error handling
  Future<BulkOperationResult<T>> _executeBulkOperation<T>({
    required String operationId,
    required BulkOperationType operationType,
    required List<TaskModel> tasks,
    required bool showNotification,
    required bool enableUndo,
    required Future<T> Function(List<TaskModel> batch, BulkOperationProgress progress) operation,
  }) async {
    final progressController = StreamController<BulkOperationProgress>.broadcast();
    final cancelToken = CancelToken();
    
    _progressControllers[operationId] = progressController;
    _cancelTokens[operationId] = cancelToken;
    
    try {
      final totalTasks = tasks.length;
      var processedTasks = 0;
      var successfulTasks = 0;
      var failedTasks = 0;
      final errors = <String, String>{};
      T? result;
      
      // Emit initial progress
      var progress = BulkOperationProgress(
        operationId: operationId,
        operationType: operationType,
        totalTasks: totalTasks,
        processedTasks: processedTasks,
        successfulTasks: successfulTasks,
        failedTasks: failedTasks,
        errors: errors,
        isCompleted: false,
        isCancelled: false,
        startTime: DateTime.now(),
      );
      
      progressController.add(progress);
      
      // Process tasks in batches
      final batches = tasks.slices(_batchSize).toList();
      
      for (int i = 0; i < batches.length; i++) {
        if (cancelToken.isCancelled) {
          progress = progress.copyWith(
            isCancelled: true,
            endTime: DateTime.now(),
          );
          progressController.add(progress);
          break;
        }
        
        final batch = batches[i];
        
        try {
          final batchResult = await operation(batch, progress);
          if (result == null && batchResult != null) {
            result = batchResult;
          } else if (result is List && batchResult is List) {
            (result as List).addAll(batchResult);
          }
          
          successfulTasks += batch.length;
        } catch (e, stackTrace) {
          failedTasks += batch.length;
          final errorKey = 'batch_${i}_error';
          errors[errorKey] = e.toString();
          
          // Log error for debugging
          debugPrint('Bulk operation error in batch $i: $e');
          debugPrint('Stack trace: $stackTrace');
        }
        
        processedTasks += batch.length;
        
        // Update progress
        progress = progress.copyWith(
          processedTasks: processedTasks,
          successfulTasks: successfulTasks,
          failedTasks: failedTasks,
          errors: errors,
        );
        
        progressController.add(progress);
        
        // Small delay between batches to prevent overwhelming the system
        if (i < batches.length - 1) {
          await Future.delayed(_batchDelay);
        }
      }
      
      // Mark as completed
      progress = progress.copyWith(
        isCompleted: true,
        endTime: DateTime.now(),
      );
      
      progressController.add(progress);
      
      // Show completion notification
      if (showNotification && successfulTasks > 0) {
        await _showCompletionNotification(operationType, successfulTasks, failedTasks);
      }
      
      return BulkOperationResult<T>(
        operationId: operationId,
        operationType: operationType,
        totalTasks: totalTasks,
        successfulTasks: successfulTasks,
        failedTasks: failedTasks,
        errors: errors,
        result: result,
        duration: progress.duration,
        canUndo: enableUndo && successfulTasks > 0,
      );
      
    } catch (e) {
      // Handle unexpected errors
      final progress = BulkOperationProgress(
        operationId: operationId,
        operationType: operationType,
        totalTasks: tasks.length,
        processedTasks: 0,
        successfulTasks: 0,
        failedTasks: tasks.length,
        errors: {'unexpected_error': e.toString()},
        isCompleted: true,
        isCancelled: false,
        startTime: DateTime.now(),
        endTime: DateTime.now(),
      );
      
      progressController.add(progress);
      
      return BulkOperationResult<T>(
        operationId: operationId,
        operationType: operationType,
        totalTasks: tasks.length,
        successfulTasks: 0,
        failedTasks: tasks.length,
        errors: {'unexpected_error': e.toString()},
        result: null,
        duration: const Duration(),
        canUndo: false,
      );
      
    } finally {
      // Cleanup
      progressController.close();
      _progressControllers.remove(operationId);
      _cancelTokens.remove(operationId);
    }
  }
  
  /// Cancel a bulk operation
  void cancelOperation(String operationId) {
    final cancelToken = _cancelTokens[operationId];
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel();
      HapticFeedback.mediumImpact();
    }
  }
  
  /// Get progress stream for an operation
  Stream<BulkOperationProgress>? getProgressStream(String operationId) {
    return _progressControllers[operationId]?.stream;
  }
  
  /// Undo a bulk operation
  Future<BulkOperationResult> undoOperation(String operationId) async {
    final record = await _history.getOperation(operationId);
    if (record == null) {
      throw const BulkOperationException('Operation not found in history');
    }
    
    return _performanceService.trackOperation(
      'bulk_undo',
      () async {
        switch (record.type) {
          case BulkOperationType.delete:
            return _undoDelete(record);
          case BulkOperationType.updateStatus:
            return _undoStatusUpdate(record);
          case BulkOperationType.updatePriority:
            return _undoPriorityUpdate(record);
          case BulkOperationType.moveToProject:
            return _undoProjectMove(record);
          case BulkOperationType.addTags:
            return _undoAddTags(record);
          case BulkOperationType.removeTags:
            return _undoRemoveTags(record);
          case BulkOperationType.reschedule:
            return _undoReschedule(record);
          default:
            throw BulkOperationException('Cannot undo operation of type ${record.type}');
        }
      },
    );
  }
  
  /// Generate smart duplicate name
  String _generateSmartDuplicateName(String originalTitle) {
    // Check if title already has a copy suffix
    final copyPattern = RegExp(r'(.*?)\s*\((\d+)\)$');
    final match = copyPattern.firstMatch(originalTitle);
    
    if (match != null) {
      final baseName = match.group(1)!;
      final copyNumber = int.parse(match.group(2)!) + 1;
      return '$baseName ($copyNumber)';
    } else {
      return '$originalTitle (1)';
    }
  }
  
  /// Show completion notification
  Future<void> _showCompletionNotification(
    BulkOperationType operationType,
    int successfulTasks,
    int failedTasks,
  ) async {
    String title;
    String body;
    
    switch (operationType) {
      case BulkOperationType.delete:
        title = 'Tasks Deleted';
        body = '$successfulTasks tasks deleted successfully';
        break;
      case BulkOperationType.updateStatus:
        title = 'Status Updated';
        body = '$successfulTasks tasks updated successfully';
        break;
      case BulkOperationType.updatePriority:
        title = 'Priority Updated';
        body = '$successfulTasks tasks updated successfully';
        break;
      case BulkOperationType.moveToProject:
        title = 'Tasks Moved';
        body = '$successfulTasks tasks moved to project';
        break;
      case BulkOperationType.addTags:
        title = 'Tags Added';
        body = '$successfulTasks tasks tagged successfully';
        break;
      case BulkOperationType.removeTags:
        title = 'Tags Removed';
        body = '$successfulTasks tasks updated successfully';
        break;
      case BulkOperationType.reschedule:
        title = 'Tasks Rescheduled';
        body = '$successfulTasks tasks rescheduled successfully';
        break;
      case BulkOperationType.duplicate:
        title = 'Tasks Duplicated';
        body = '$successfulTasks tasks duplicated successfully';
        break;
      case BulkOperationType.restore:
        title = 'Tasks Restored';
        body = '$successfulTasks tasks restored successfully';
        break;
    }
    
    if (failedTasks > 0) {
      body += ', $failedTasks failed';
    }
    
    await _notificationService.showImmediateNotification(
      title: title,
      body: body,
    );
  }
  
  // Undo implementations
  Future<BulkOperationResult> _undoDelete(BulkOperationRecord record) async {
    final tasks = record.taskSnapshots;
    for (final task in tasks) {
      await _taskRepository.createTask(task);
    }
    
    await _history.markOperationUndone(record.id);
    
    return BulkOperationResult(
      operationId: const Uuid().v4(),
      operationType: BulkOperationType.restore,
      totalTasks: tasks.length,
      successfulTasks: tasks.length,
      failedTasks: 0,
      errors: {},
      result: null,
      duration: const Duration(),
      canUndo: false,
    );
  }
  
  Future<BulkOperationResult> _undoStatusUpdate(BulkOperationRecord record) async {
    final tasks = record.taskSnapshots;
    for (final task in tasks) {
      await _taskRepository.updateTask(task);
    }
    
    await _history.markOperationUndone(record.id);
    
    return BulkOperationResult(
      operationId: const Uuid().v4(),
      operationType: BulkOperationType.restore,
      totalTasks: tasks.length,
      successfulTasks: tasks.length,
      failedTasks: 0,
      errors: {},
      result: null,
      duration: const Duration(),
      canUndo: false,
    );
  }
  
  Future<BulkOperationResult> _undoPriorityUpdate(BulkOperationRecord record) async {
    final tasks = record.taskSnapshots;
    for (final task in tasks) {
      await _taskRepository.updateTask(task);
    }
    
    await _history.markOperationUndone(record.id);
    
    return BulkOperationResult(
      operationId: const Uuid().v4(),
      operationType: BulkOperationType.restore,
      totalTasks: tasks.length,
      successfulTasks: tasks.length,
      failedTasks: 0,
      errors: {},
      result: null,
      duration: const Duration(),
      canUndo: false,
    );
  }
  
  Future<BulkOperationResult> _undoProjectMove(BulkOperationRecord record) async {
    final tasks = record.taskSnapshots;
    for (final task in tasks) {
      await _taskRepository.updateTask(task);
    }
    
    await _history.markOperationUndone(record.id);
    
    return BulkOperationResult(
      operationId: const Uuid().v4(),
      operationType: BulkOperationType.restore,
      totalTasks: tasks.length,
      successfulTasks: tasks.length,
      failedTasks: 0,
      errors: {},
      result: null,
      duration: const Duration(),
      canUndo: false,
    );
  }
  
  Future<BulkOperationResult> _undoAddTags(BulkOperationRecord record) async {
    final tasks = record.taskSnapshots;
    for (final task in tasks) {
      await _taskRepository.updateTask(task);
    }
    
    await _history.markOperationUndone(record.id);
    
    return BulkOperationResult(
      operationId: const Uuid().v4(),
      operationType: BulkOperationType.restore,
      totalTasks: tasks.length,
      successfulTasks: tasks.length,
      failedTasks: 0,
      errors: {},
      result: null,
      duration: const Duration(),
      canUndo: false,
    );
  }
  
  Future<BulkOperationResult> _undoRemoveTags(BulkOperationRecord record) async {
    final tasks = record.taskSnapshots;
    for (final task in tasks) {
      await _taskRepository.updateTask(task);
    }
    
    await _history.markOperationUndone(record.id);
    
    return BulkOperationResult(
      operationId: const Uuid().v4(),
      operationType: BulkOperationType.restore,
      totalTasks: tasks.length,
      successfulTasks: tasks.length,
      failedTasks: 0,
      errors: {},
      result: null,
      duration: const Duration(),
      canUndo: false,
    );
  }
  
  Future<BulkOperationResult> _undoReschedule(BulkOperationRecord record) async {
    final tasks = record.taskSnapshots;
    for (final task in tasks) {
      await _taskRepository.updateTask(task);
    }
    
    await _history.markOperationUndone(record.id);
    
    return BulkOperationResult(
      operationId: const Uuid().v4(),
      operationType: BulkOperationType.restore,
      totalTasks: tasks.length,
      successfulTasks: tasks.length,
      failedTasks: 0,
      errors: {},
      result: null,
      duration: const Duration(),
      canUndo: false,
    );
  }
  
  /// Get operation history
  Stream<List<BulkOperationRecord>> getOperationHistory() {
    return _history.getOperationHistory();
  }
  
  /// Clear operation history
  Future<void> clearHistory() async {
    await _history.clearHistory();
  }
  
  /// Dispose resources
  void dispose() {
    for (final controller in _progressControllers.values) {
      controller.close();
    }
    _progressControllers.clear();
    _cancelTokens.clear();
  }
}

/// Progress information for bulk operations
class BulkOperationProgress {
  final String operationId;
  final BulkOperationType operationType;
  final int totalTasks;
  final int processedTasks;
  final int successfulTasks;
  final int failedTasks;
  final Map<String, String> errors;
  final bool isCompleted;
  final bool isCancelled;
  final DateTime startTime;
  final DateTime? endTime;
  
  const BulkOperationProgress({
    required this.operationId,
    required this.operationType,
    required this.totalTasks,
    required this.processedTasks,
    required this.successfulTasks,
    required this.failedTasks,
    required this.errors,
    required this.isCompleted,
    required this.isCancelled,
    required this.startTime,
    this.endTime,
  });
  
  BulkOperationProgress copyWith({
    String? operationId,
    BulkOperationType? operationType,
    int? totalTasks,
    int? processedTasks,
    int? successfulTasks,
    int? failedTasks,
    Map<String, String>? errors,
    bool? isCompleted,
    bool? isCancelled,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return BulkOperationProgress(
      operationId: operationId ?? this.operationId,
      operationType: operationType ?? this.operationType,
      totalTasks: totalTasks ?? this.totalTasks,
      processedTasks: processedTasks ?? this.processedTasks,
      successfulTasks: successfulTasks ?? this.successfulTasks,
      failedTasks: failedTasks ?? this.failedTasks,
      errors: errors ?? this.errors,
      isCompleted: isCompleted ?? this.isCompleted,
      isCancelled: isCancelled ?? this.isCancelled,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
  
  /// Get completion percentage (0.0 to 1.0)
  double get progressPercentage {
    if (totalTasks == 0) return 0.0;
    return processedTasks / totalTasks;
  }
  
  /// Get success rate (0.0 to 1.0)
  double get successRate {
    if (processedTasks == 0) return 0.0;
    return successfulTasks / processedTasks;
  }
  
  /// Get duration of operation
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }
  
  /// Check if operation has errors
  bool get hasErrors => errors.isNotEmpty;
  
  /// Get estimated time remaining
  Duration? get estimatedTimeRemaining {
    if (isCompleted || isCancelled || processedTasks == 0) return null;
    
    final elapsed = duration;
    final remainingTasks = totalTasks - processedTasks;
    final averageTimePerTask = elapsed.inMilliseconds / processedTasks;
    
    return Duration(milliseconds: (remainingTasks * averageTimePerTask).round());
  }
}

/// Result of a bulk operation
class BulkOperationResult<T> {
  final String operationId;
  final BulkOperationType operationType;
  final int totalTasks;
  final int successfulTasks;
  final int failedTasks;
  final Map<String, String> errors;
  final T? result;
  final Duration duration;
  final bool canUndo;
  
  const BulkOperationResult({
    required this.operationId,
    required this.operationType,
    required this.totalTasks,
    required this.successfulTasks,
    required this.failedTasks,
    required this.errors,
    this.result,
    required this.duration,
    required this.canUndo,
  });
  
  /// Check if operation was successful
  bool get isSuccess => failedTasks == 0;
  
  /// Check if operation was partially successful
  bool get isPartialSuccess => successfulTasks > 0 && failedTasks > 0;
  
  /// Check if operation failed completely
  bool get isFailure => successfulTasks == 0 && totalTasks > 0;
  
  /// Get success rate (0.0 to 1.0)
  double get successRate {
    if (totalTasks == 0) return 0.0;
    return successfulTasks / totalTasks;
  }
}

/// Types of bulk operations
enum BulkOperationType {
  delete,
  updateStatus,
  updatePriority,
  moveToProject,
  addTags,
  removeTags,
  reschedule,
  duplicate,
  restore, // For undo operations
}

/// Strategies for rescheduling tasks
enum RescheduleStrategy {
  absolute, // Set all tasks to the same date
  relative, // Add/subtract duration from current due date
  preserveTime, // Change date but preserve time of day
}

/// Strategies for duplicating tasks
enum DuplicationStrategy {
  smartNaming, // Add (1), (2), etc.
  suffix, // Add custom suffix
  prefix, // Add custom prefix
  keepOriginal, // Keep original name
}

/// Exception for bulk operations
class BulkOperationException implements Exception {
  final String message;
  final String? code;
  final Map<String, dynamic>? metadata;
  
  const BulkOperationException(
    this.message, {
    this.code,
    this.metadata,
  });
  
  @override
  String toString() => 'BulkOperationException: $message';
}

/// Cancel token for operations
class CancelToken {
  bool _isCancelled = false;
  
  bool get isCancelled => _isCancelled;
  
  void cancel() {
    _isCancelled = true;
  }
}

