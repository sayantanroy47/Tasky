import 'dart:async';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/task_model.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/models/enums.dart';
import '../notification/notification_service.dart';
import '../performance_service.dart';
import 'bulk_operation_history.dart';
import 'bulk_operation_service.dart';

/// Service for project migration operations with full history preservation
/// 
/// This service handles:
/// - Moving tasks between projects with history preservation
/// - Merging projects with conflict resolution
/// - Splitting projects into multiple projects
/// - Project archiving with relationship preservation
/// - Bulk import/export operations
/// - Migration validation and rollback
class ProjectMigrationService {
  final TaskRepository _taskRepository;
  final ProjectRepository _projectRepository;
  final NotificationService _notificationService;
  final PerformanceService _performanceService;
  final BulkOperationHistory _history;
  
  final Map<String, StreamController<MigrationProgress>> _progressControllers = {};
  final Map<String, CancelToken> _cancelTokens = {};
  
  ProjectMigrationService({
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
  
  /// Move tasks between projects with full history preservation
  Future<MigrationResult> moveTasksBetweenProjects({
    required List<TaskModel> tasks,
    required String? sourceProjectId,
    required String? targetProjectId,
    MigrationStrategy strategy = MigrationStrategy.preserve,
    bool showNotification = true,
    bool enableUndo = true,
  }) async {
    final operationId = const Uuid().v4();
    final startTime = DateTime.now();
    
    return _performanceService.trackOperation(
      'move_tasks_between_projects',
      () => _executeMigrationOperation(
        operationId: operationId,
        operationType: MigrationType.moveToProject,
        tasks: tasks,
        sourceProjectId: sourceProjectId,
        targetProjectId: targetProjectId,
        strategy: strategy,
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
                'sourceProjectId': sourceProjectId,
                'targetProjectId': targetProjectId,
                'strategy': strategy.name,
                'count': batch.length,
              },
            ));
          }
          
          // Validate migration
          final validationResult = await _validateMigration(
            batch, sourceProjectId, targetProjectId, strategy,
          );
          
          if (validationResult.hasErrors) {
            throw MigrationException(
              'Migration validation failed: ${validationResult.errors.join(', ')}',
              code: 'validation_failed',
              metadata: validationResult.toMap(),
            );
          }
          
          // Apply conflict resolution if needed
          final resolvedTasks = await _resolveConflicts(
            batch, targetProjectId, validationResult.conflicts,
          );
          
          // Update project references in tasks
          final taskIds = resolvedTasks.map((t) => t.id).toList();
          await _taskRepository.assignTasksToProject(taskIds, targetProjectId);
          
          // Update project task counts
          await _updateProjectTaskCounts(sourceProjectId, targetProjectId, batch.length);
          
          HapticFeedback.lightImpact();
          
          return MigrationOperationResult(
            migratedTasks: resolvedTasks,
            conflicts: validationResult.conflicts,
            warnings: validationResult.warnings,
          );
        },
      ),
    );
  }
  
  /// Merge two projects into one
  Future<MigrationResult> mergeProjects({
    required String sourceProjectId,
    required String targetProjectId,
    MergeStrategy mergeStrategy = MergeStrategy.combineAll,
    ConflictResolution conflictResolution = ConflictResolution.targetWins,
    bool showNotification = true,
    bool enableUndo = true,
  }) async {
    final operationId = const Uuid().v4();
    final startTime = DateTime.now();
    
    return _performanceService.trackOperation(
      'merge_projects',
      () => _executeMigrationOperation(
        operationId: operationId,
        operationType: MigrationType.mergeProjects,
        tasks: [],
        sourceProjectId: sourceProjectId,
        targetProjectId: targetProjectId,
        strategy: MigrationStrategy.merge,
        showNotification: showNotification,
        enableUndo: enableUndo,
        operation: (batch, progress) async {
          // Get all tasks from source project
          final sourceTasks = await _taskRepository.getTasksByProject(sourceProjectId);
          final targetTasks = await _taskRepository.getTasksByProject(targetProjectId);
          
          // Get project details
          final sourceProject = await _projectRepository.getProjectById(sourceProjectId);
          final targetProject = await _projectRepository.getProjectById(targetProjectId);
          
          if (sourceProject == null || targetProject == null) {
            throw const MigrationException(
              'Source or target project not found',
              code: 'project_not_found',
            );
          }
          
          // Create backup for undo
          if (enableUndo) {
            await _history.recordOperation(BulkOperationRecord(
              id: operationId,
              type: BulkOperationType.moveToProject,
              taskSnapshots: [...sourceTasks, ...targetTasks],
              timestamp: startTime,
              metadata: {
                'operation': 'mergeProjects',
                'sourceProjectId': sourceProjectId,
                'targetProjectId': targetProjectId,
                'mergeStrategy': mergeStrategy.name,
                'conflictResolution': conflictResolution.name,
                'sourceProject': sourceProject.toJson(),
                'targetProject': targetProject.toJson(),
              },
            ));
          }
          
          // Detect conflicts
          final conflicts = _detectMergeConflicts(sourceTasks, targetTasks);
          
          // Resolve conflicts based on strategy
          final resolvedTasks = await _resolveMergeConflicts(
            sourceTasks, targetTasks, conflicts, conflictResolution,
          );
          
          // Move source tasks to target project
          if (sourceTasks.isNotEmpty) {
            final sourceTaskIds = sourceTasks.map((t) => t.id).toList();
            await _taskRepository.assignTasksToProject(sourceTaskIds, targetProjectId);
          }
          
          // Merge project metadata based on strategy
          final mergedProject = await _mergeProjectMetadata(
            sourceProject, targetProject, mergeStrategy, conflictResolution,
          );
          
          await _projectRepository.updateProject(mergedProject);
          
          // Archive source project
          final archivedSourceProject = sourceProject.archive();
          await _projectRepository.updateProject(archivedSourceProject);
          
          HapticFeedback.mediumImpact();
          
          return MigrationOperationResult(
            migratedTasks: resolvedTasks,
            conflicts: conflicts,
            warnings: [],
            mergedProject: mergedProject,
            archivedProject: archivedSourceProject,
          );
        },
      ),
    );
  }
  
  /// Split a project into multiple projects
  Future<MigrationResult> splitProject({
    required String sourceProjectId,
    required List<ProjectSplit> splits,
    bool showNotification = true,
    bool enableUndo = true,
  }) async {
    final operationId = const Uuid().v4();
    final startTime = DateTime.now();
    
    return _performanceService.trackOperation(
      'split_project',
      () => _executeMigrationOperation(
        operationId: operationId,
        operationType: MigrationType.splitProject,
        tasks: [],
        sourceProjectId: sourceProjectId,
        targetProjectId: null,
        strategy: MigrationStrategy.split,
        showNotification: showNotification,
        enableUndo: enableUndo,
        operation: (batch, progress) async {
          // Get all tasks from source project
          final sourceTasks = await _taskRepository.getTasksByProject(sourceProjectId);
          final sourceProject = await _projectRepository.getProjectById(sourceProjectId);
          
          if (sourceProject == null) {
            throw const MigrationException(
              'Source project not found',
              code: 'project_not_found',
            );
          }
          
          // Create backup for undo
          if (enableUndo) {
            await _history.recordOperation(BulkOperationRecord(
              id: operationId,
              type: BulkOperationType.moveToProject,
              taskSnapshots: sourceTasks,
              timestamp: startTime,
              metadata: {
                'operation': 'splitProject',
                'sourceProjectId': sourceProjectId,
                'sourceProject': sourceProject.toJson(),
                'splits': splits.map((s) => s.toJson()).toList(),
              },
            ));
          }
          
          // Validate splits
          final validationResult = _validateProjectSplits(sourceTasks, splits);
          if (validationResult.hasErrors) {
            throw MigrationException(
              'Split validation failed: ${validationResult.errors.join(', ')}',
              code: 'split_validation_failed',
            );
          }
          
          final createdProjects = <Project>[];
          final migratedTasks = <TaskModel>[];
          
          // Create new projects and move tasks
          for (final split in splits) {
            // Create new project
            final newProject = Project.create(
              name: split.projectName,
              description: split.projectDescription,
              color: split.projectColor ?? sourceProject.color,
              categoryId: split.categoryId ?? sourceProject.categoryId,
            );
            
            await _projectRepository.createProject(newProject);
            createdProjects.add(newProject);
            
            // Move tasks to new project
            if (split.taskIds.isNotEmpty) {
              await _taskRepository.assignTasksToProject(split.taskIds, newProject.id);
              
              final movedTasks = sourceTasks
                  .where((t) => split.taskIds.contains(t.id))
                  .toList();
              migratedTasks.addAll(movedTasks);
            }
          }
          
          HapticFeedback.mediumImpact();
          
          return MigrationOperationResult(
            migratedTasks: migratedTasks,
            conflicts: [],
            warnings: validationResult.warnings,
            createdProjects: createdProjects,
          );
        },
      ),
    );
  }
  
  /// Archive a project with task relationship preservation
  Future<MigrationResult> archiveProjectWithTasks({
    required String projectId,
    ArchiveStrategy strategy = ArchiveStrategy.preserveRelationships,
    bool showNotification = true,
    bool enableUndo = true,
  }) async {
    final operationId = const Uuid().v4();
    final startTime = DateTime.now();
    
    return _performanceService.trackOperation(
      'archive_project_with_tasks',
      () => _executeMigrationOperation(
        operationId: operationId,
        operationType: MigrationType.archiveProject,
        tasks: [],
        sourceProjectId: projectId,
        targetProjectId: null,
        strategy: MigrationStrategy.archive,
        showNotification: showNotification,
        enableUndo: enableUndo,
        operation: (batch, progress) async {
          // Get project and its tasks
          final project = await _projectRepository.getProjectById(projectId);
          final projectTasks = await _taskRepository.getTasksByProject(projectId);
          
          if (project == null) {
            throw const MigrationException(
              'Project not found',
              code: 'project_not_found',
            );
          }
          
          // Create backup for undo
          if (enableUndo) {
            await _history.recordOperation(BulkOperationRecord(
              id: operationId,
              type: BulkOperationType.moveToProject,
              taskSnapshots: projectTasks,
              timestamp: startTime,
              metadata: {
                'operation': 'archiveProject',
                'projectId': projectId,
                'project': project.toJson(),
                'strategy': strategy.name,
                'taskCount': projectTasks.length,
              },
            ));
          }
          
          // Archive project
          final archivedProject = project.archive();
          await _projectRepository.updateProject(archivedProject);
          
          // Handle tasks based on strategy
          List<TaskModel> processedTasks = [];
          
          switch (strategy) {
            case ArchiveStrategy.preserveRelationships:
              // Keep tasks in archived project, but update metadata
              for (final task in projectTasks) {
                final updatedTask = task.updateMetadata({
                  'archived_with_project': projectId,
                  'archived_at': DateTime.now().toIso8601String(),
                });
                await _taskRepository.updateTask(updatedTask);
                processedTasks.add(updatedTask);
              }
              break;
              
            case ArchiveStrategy.moveToDefault:
              // Move tasks to no project (null)
              if (projectTasks.isNotEmpty) {
                final taskIds = projectTasks.map((t) => t.id).toList();
                await _taskRepository.assignTasksToProject(taskIds, null);
                processedTasks = projectTasks;
              }
              break;
              
            case ArchiveStrategy.completeOrDelete:
              // Complete pending tasks, keep completed ones
              for (final task in projectTasks) {
                if (task.status != TaskStatus.completed) {
                  final completedTask = task.markCompleted();
                  await _taskRepository.updateTask(completedTask);
                  processedTasks.add(completedTask);
                } else {
                  processedTasks.add(task);
                }
              }
              break;
          }
          
          HapticFeedback.mediumImpact();
          
          return MigrationOperationResult(
            migratedTasks: processedTasks,
            conflicts: [],
            warnings: [],
            archivedProject: archivedProject,
          );
        },
      ),
    );
  }
  
  /// Bulk import tasks and projects from export data
  Future<MigrationResult> bulkImport({
    required Map<String, dynamic> importData,
    ImportOptions options = const ImportOptions(),
    bool showNotification = true,
  }) async {
    final operationId = const Uuid().v4();
    
    return _performanceService.trackOperation(
      'bulk_import',
      () => _executeMigrationOperation(
        operationId: operationId,
        operationType: MigrationType.import,
        tasks: [],
        sourceProjectId: null,
        targetProjectId: null,
        strategy: MigrationStrategy.import,
        showNotification: showNotification,
        enableUndo: false, // Import creates new data, no undo needed
        operation: (batch, progress) async {
          final importedProjects = <Project>[];
          final importedTasks = <TaskModel>[];
          final warnings = <String>[];
          final conflicts = <MigrationConflict>[];
          
          // Import projects first
          final projectsData = importData['projects'] as List<dynamic>? ?? [];
          for (final projectJson in projectsData) {
            try {
              final project = Project.fromJson(projectJson as Map<String, dynamic>);
              
              // Check for name conflicts
              final existingProjects = await _projectRepository.getAllProjects();
              final nameConflict = existingProjects.any((p) => p.name == project.name);
              
              if (nameConflict && options.conflictResolution == ConflictResolution.skip) {
                warnings.add('Skipped project "${project.name}" due to name conflict');
                continue;
              }
              
              final finalProject = nameConflict && options.conflictResolution == ConflictResolution.rename
                  ? project.copyWith(name: '${project.name} (Imported)')
                  : project;
              
              await _projectRepository.createProject(finalProject);
              importedProjects.add(finalProject);
              
            } catch (e) {
              warnings.add('Failed to import project: $e');
            }
          }
          
          // Import tasks
          final tasksData = importData['tasks'] as List<dynamic>? ?? [];
          for (final taskJson in tasksData) {
            try {
              final task = TaskModel.fromJson(taskJson as Map<String, dynamic>);
              
              // Validate project reference
              String? finalProjectId = task.projectId;
              if (task.projectId != null) {
                final projectExists = importedProjects.any((p) => p.id == task.projectId) ||
                                   await _projectRepository.getProjectById(task.projectId!) != null;
                
                if (!projectExists) {
                  finalProjectId = null;
                  warnings.add('Task "${task.title}" project reference removed (project not found)');
                }
              }
              
              final finalTask = task.copyWith(
                projectId: finalProjectId,
                metadata: {
                  ...task.metadata,
                  'imported_at': DateTime.now().toIso8601String(),
                  'import_operation_id': operationId,
                },
              );
              
              await _taskRepository.createTask(finalTask);
              importedTasks.add(finalTask);
              
            } catch (e) {
              warnings.add('Failed to import task: $e');
            }
          }
          
          HapticFeedback.mediumImpact();
          
          return MigrationOperationResult(
            migratedTasks: importedTasks,
            conflicts: conflicts,
            warnings: warnings,
            createdProjects: importedProjects,
          );
        },
      ),
    );
  }
  
  /// Bulk export tasks and projects
  Future<Map<String, dynamic>> bulkExport({
    List<String>? projectIds,
    List<String>? taskIds,
    ExportOptions options = const ExportOptions(),
  }) async {
    return _performanceService.trackOperation(
      'bulk_export',
      () async {
        final exportData = <String, dynamic>{
          'version': '1.0',
          'exportedAt': DateTime.now().toIso8601String(),
          'options': options.toJson(),
        };
        
        // Export projects
        List<Project> projectsToExport = [];
        if (projectIds != null) {
          for (final projectId in projectIds) {
            final project = await _projectRepository.getProjectById(projectId);
            if (project != null) {
              projectsToExport.add(project);
            }
          }
        } else if (options.includeAllProjects) {
          projectsToExport = await _projectRepository.getAllProjects();
        }
        
        exportData['projects'] = projectsToExport.map((p) => p.toJson()).toList();
        
        // Export tasks
        List<TaskModel> tasksToExport = [];
        if (taskIds != null) {
          tasksToExport = await _taskRepository.getTasksByIds(taskIds);
        } else if (projectIds != null) {
          for (final projectId in projectIds) {
            final projectTasks = await _taskRepository.getTasksByProject(projectId);
            tasksToExport.addAll(projectTasks);
          }
        } else if (options.includeAllTasks) {
          tasksToExport = await _taskRepository.getAllTasks();
        }
        
        // Filter tasks based on options
        if (!options.includeCompletedTasks) {
          tasksToExport = tasksToExport.where((t) => !t.isCompleted).toList();
        }
        
        if (!options.includeArchivedProjects) {
          final activeProjectIds = projectsToExport
              .where((p) => !p.isArchived)
              .map((p) => p.id)
              .toSet();
          
          tasksToExport = tasksToExport.where((t) => 
            t.projectId == null || activeProjectIds.contains(t.projectId)
          ).toList();
        }
        
        exportData['tasks'] = tasksToExport.map((t) => t.toJson()).toList();
        
        // Add statistics
        exportData['statistics'] = {
          'projectCount': projectsToExport.length,
          'taskCount': tasksToExport.length,
          'completedTaskCount': tasksToExport.where((t) => t.isCompleted).length,
          'archivedProjectCount': projectsToExport.where((p) => p.isArchived).length,
        };
        
        return exportData;
      },
    );
  }
  
  /// Execute a migration operation with progress tracking
  Future<MigrationResult<T>> _executeMigrationOperation<T>({
    required String operationId,
    required MigrationType operationType,
    required List<TaskModel> tasks,
    required String? sourceProjectId,
    required String? targetProjectId,
    required MigrationStrategy strategy,
    required bool showNotification,
    required bool enableUndo,
    required Future<T> Function(List<TaskModel> batch, MigrationProgress progress) operation,
  }) async {
    final progressController = StreamController<MigrationProgress>.broadcast();
    final cancelToken = CancelToken();
    
    _progressControllers[operationId] = progressController;
    _cancelTokens[operationId] = cancelToken;
    
    try {
      var progress = MigrationProgress(
        operationId: operationId,
        operationType: operationType,
        totalTasks: tasks.length,
        processedTasks: 0,
        isCompleted: false,
        isCancelled: false,
        startTime: DateTime.now(),
        strategy: strategy,
        sourceProjectId: sourceProjectId,
        targetProjectId: targetProjectId,
      );
      
      progressController.add(progress);
      
      // Execute operation
      final result = await operation(tasks, progress);
      
      // Mark as completed
      progress = progress.copyWith(
        isCompleted: true,
        processedTasks: tasks.length,
        endTime: DateTime.now(),
      );
      
      progressController.add(progress);
      
      // Show completion notification
      if (showNotification) {
        await _showMigrationNotification(operationType, tasks.length);
      }
      
      return MigrationResult<T>(
        operationId: operationId,
        operationType: operationType,
        result: result,
        duration: progress.duration,
        canUndo: enableUndo,
      );
      
    } catch (e) {
      final progress = MigrationProgress(
        operationId: operationId,
        operationType: operationType,
        totalTasks: tasks.length,
        processedTasks: 0,
        isCompleted: true,
        isCancelled: false,
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        error: e.toString(),
        strategy: strategy,
        sourceProjectId: sourceProjectId,
        targetProjectId: targetProjectId,
      );
      
      progressController.add(progress);
      
      rethrow;
      
    } finally {
      progressController.close();
      _progressControllers.remove(operationId);
      _cancelTokens.remove(operationId);
    }
  }
  
  /// Validate migration before execution
  Future<MigrationValidation> _validateMigration(
    List<TaskModel> tasks,
    String? sourceProjectId,
    String? targetProjectId,
    MigrationStrategy strategy,
  ) async {
    final errors = <String>[];
    final warnings = <String>[];
    final conflicts = <MigrationConflict>[];
    
    // Validate target project exists
    if (targetProjectId != null) {
      final targetProject = await _projectRepository.getProjectById(targetProjectId);
      if (targetProject == null) {
        errors.add('Target project not found');
      } else if (targetProject.isArchived) {
        warnings.add('Target project is archived');
      }
    }
    
    // Check for dependency conflicts
    for (final task in tasks) {
      if (task.hasDependencies) {
        // Check if dependencies will be in different projects
        final dependencies = await _taskRepository.getTasksByIds(task.dependencies);
        for (final dep in dependencies) {
          if (dep.projectId != targetProjectId) {
            conflicts.add(MigrationConflict(
              type: ConflictType.crossProjectDependency,
              taskId: task.id,
              description: 'Task has dependencies in other projects',
              suggestedResolution: 'Move dependencies or remove dependency',
            ));
          }
        }
      }
    }
    
    return MigrationValidation(
      errors: errors,
      warnings: warnings,
      conflicts: conflicts,
    );
  }
  
  /// Resolve conflicts in migration
  Future<List<TaskModel>> _resolveConflicts(
    List<TaskModel> tasks,
    String? targetProjectId,
    List<MigrationConflict> conflicts,
  ) async {
    final resolvedTasks = List<TaskModel>.from(tasks);
    
    // Auto-resolve conflicts based on type
    for (final conflict in conflicts) {
      final taskIndex = resolvedTasks.indexWhere((t) => t.id == conflict.taskId);
      if (taskIndex == -1) continue;
      
      final task = resolvedTasks[taskIndex];
      
      switch (conflict.type) {
        case ConflictType.crossProjectDependency:
          // Remove cross-project dependencies
          final filteredDependencies = <String>[];
          for (final depId in task.dependencies) {
            final dep = await _taskRepository.getTaskById(depId);
            if (dep?.projectId == targetProjectId) {
              filteredDependencies.add(depId);
            }
          }
          
          resolvedTasks[taskIndex] = task.copyWith(
            dependencies: filteredDependencies,
          );
          break;
          
        case ConflictType.duplicateTask:
          // Add suffix to distinguish duplicate
          resolvedTasks[taskIndex] = task.copyWith(
            title: '${task.title} (Migrated)',
          );
          break;
          
        case ConflictType.invalidData:
          // Skip invalid tasks or fix data
          break;
      }
    }
    
    return resolvedTasks;
  }
  
  /// Detect conflicts when merging projects
  List<MigrationConflict> _detectMergeConflicts(
    List<TaskModel> sourceTasks,
    List<TaskModel> targetTasks,
  ) {
    final conflicts = <MigrationConflict>[];
    
    // Check for duplicate task titles
    final targetTitles = targetTasks.map((t) => t.title.toLowerCase()).toSet();
    
    for (final task in sourceTasks) {
      if (targetTitles.contains(task.title.toLowerCase())) {
        conflicts.add(MigrationConflict(
          type: ConflictType.duplicateTask,
          taskId: task.id,
          description: 'Task title already exists in target project',
          suggestedResolution: 'Rename task or merge with existing',
        ));
      }
    }
    
    return conflicts;
  }
  
  /// Resolve merge conflicts
  Future<List<TaskModel>> _resolveMergeConflicts(
    List<TaskModel> sourceTasks,
    List<TaskModel> targetTasks,
    List<MigrationConflict> conflicts,
    ConflictResolution resolution,
  ) async {
    final resolvedTasks = List<TaskModel>.from(sourceTasks);
    
    for (final conflict in conflicts) {
      final taskIndex = resolvedTasks.indexWhere((t) => t.id == conflict.taskId);
      if (taskIndex == -1) continue;
      
      final task = resolvedTasks[taskIndex];
      
      switch (resolution) {
        case ConflictResolution.sourceWins:
          // Keep source task as-is
          break;
          
        case ConflictResolution.targetWins:
          // Remove conflicting source task
          resolvedTasks.removeAt(taskIndex);
          break;
          
        case ConflictResolution.rename:
          // Rename source task
          resolvedTasks[taskIndex] = task.copyWith(
            title: '${task.title} (From ${await _getProjectName(task.projectId)})',
          );
          break;
          
        case ConflictResolution.skip:
          // Remove conflicting task
          resolvedTasks.removeAt(taskIndex);
          break;
      }
    }
    
    return resolvedTasks;
  }
  
  /// Merge project metadata
  Future<Project> _mergeProjectMetadata(
    Project sourceProject,
    Project targetProject,
    MergeStrategy strategy,
    ConflictResolution resolution,
  ) async {
    switch (strategy) {
      case MergeStrategy.combineAll:
        // Keep target project info, update task count
        return targetProject.copyWith(
          description: resolution == ConflictResolution.sourceWins 
              ? sourceProject.description 
              : targetProject.description,
        );
        
      case MergeStrategy.sourceMetadata:
        return targetProject.copyWith(
          name: sourceProject.name,
          description: sourceProject.description,
          color: sourceProject.color,
          categoryId: sourceProject.categoryId,
        );
        
      case MergeStrategy.targetMetadata:
        return targetProject; // Keep as-is
    }
  }
  
  /// Validate project splits
  MigrationValidation _validateProjectSplits(
    List<TaskModel> sourceTasks,
    List<ProjectSplit> splits,
  ) {
    final errors = <String>[];
    final warnings = <String>[];
    
    final allTaskIds = sourceTasks.map((t) => t.id).toSet();
    final splitTaskIds = <String>{};
    
    // Validate each split
    for (final split in splits) {
      if (split.projectName.trim().isEmpty) {
        errors.add('Project name cannot be empty for split');
      }
      
      // Check for duplicate task assignments
      for (final taskId in split.taskIds) {
        if (!allTaskIds.contains(taskId)) {
          warnings.add('Task $taskId not found in source project');
        }
        
        if (splitTaskIds.contains(taskId)) {
          errors.add('Task $taskId assigned to multiple splits');
        }
        
        splitTaskIds.add(taskId);
      }
    }
    
    // Check if all tasks are assigned
    final unassignedTasks = allTaskIds.difference(splitTaskIds);
    if (unassignedTasks.isNotEmpty) {
      warnings.add('${unassignedTasks.length} tasks not assigned to any split');
    }
    
    return MigrationValidation(
      errors: errors,
      warnings: warnings,
      conflicts: [],
    );
  }
  
  /// Update project task counts
  Future<void> _updateProjectTaskCounts(
    String? sourceProjectId,
    String? targetProjectId,
    int taskCount,
  ) async {
    // Implementation would update project metadata with task counts
    // This is a placeholder for the actual implementation
  }
  
  /// Get project name by ID
  Future<String> _getProjectName(String? projectId) async {
    if (projectId == null) return 'No Project';
    
    final project = await _projectRepository.getProjectById(projectId);
    return project?.name ?? 'Unknown Project';
  }
  
  /// Show migration completion notification
  Future<void> _showMigrationNotification(MigrationType type, int taskCount) async {
    String title;
    String body;
    
    switch (type) {
      case MigrationType.moveToProject:
        title = 'Tasks Moved';
        body = '$taskCount tasks moved between projects';
        break;
      case MigrationType.mergeProjects:
        title = 'Projects Merged';
        body = 'Projects merged successfully';
        break;
      case MigrationType.splitProject:
        title = 'Project Split';
        body = 'Project split into multiple projects';
        break;
      case MigrationType.archiveProject:
        title = 'Project Archived';
        body = 'Project archived with $taskCount tasks';
        break;
      case MigrationType.import:
        title = 'Import Complete';
        body = 'Data imported successfully';
        break;
      case MigrationType.export:
        title = 'Export Complete';
        body = 'Data exported successfully';
        break;
    }
    
    await _notificationService.showNotification(
      title: title,
      body: body,
    );
  }
  
  /// Cancel a migration operation
  void cancelOperation(String operationId) {
    final cancelToken = _cancelTokens[operationId];
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel();
      HapticFeedback.mediumImpact();
    }
  }
  
  /// Get progress stream for an operation
  Stream<MigrationProgress>? getProgressStream(String operationId) {
    return _progressControllers[operationId]?.stream;
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

/// Progress information for migration operations
class MigrationProgress {
  final String operationId;
  final MigrationType operationType;
  final int totalTasks;
  final int processedTasks;
  final bool isCompleted;
  final bool isCancelled;
  final DateTime startTime;
  final DateTime? endTime;
  final String? error;
  final MigrationStrategy strategy;
  final String? sourceProjectId;
  final String? targetProjectId;
  
  const MigrationProgress({
    required this.operationId,
    required this.operationType,
    required this.totalTasks,
    required this.processedTasks,
    required this.isCompleted,
    required this.isCancelled,
    required this.startTime,
    this.endTime,
    this.error,
    required this.strategy,
    this.sourceProjectId,
    this.targetProjectId,
  });
  
  MigrationProgress copyWith({
    String? operationId,
    MigrationType? operationType,
    int? totalTasks,
    int? processedTasks,
    bool? isCompleted,
    bool? isCancelled,
    DateTime? startTime,
    DateTime? endTime,
    String? error,
    MigrationStrategy? strategy,
    String? sourceProjectId,
    String? targetProjectId,
  }) {
    return MigrationProgress(
      operationId: operationId ?? this.operationId,
      operationType: operationType ?? this.operationType,
      totalTasks: totalTasks ?? this.totalTasks,
      processedTasks: processedTasks ?? this.processedTasks,
      isCompleted: isCompleted ?? this.isCompleted,
      isCancelled: isCancelled ?? this.isCancelled,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      error: error ?? this.error,
      strategy: strategy ?? this.strategy,
      sourceProjectId: sourceProjectId ?? this.sourceProjectId,
      targetProjectId: targetProjectId ?? this.targetProjectId,
    );
  }
  
  /// Get duration of operation
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }
  
  /// Get progress percentage
  double get progressPercentage {
    if (totalTasks == 0) return 0.0;
    return processedTasks / totalTasks;
  }
}

/// Result of a migration operation
class MigrationResult<T> {
  final String operationId;
  final MigrationType operationType;
  final T? result;
  final Duration duration;
  final bool canUndo;
  
  const MigrationResult({
    required this.operationId,
    required this.operationType,
    this.result,
    required this.duration,
    required this.canUndo,
  });
}

/// Result of a specific migration operation
class MigrationOperationResult {
  final List<TaskModel> migratedTasks;
  final List<MigrationConflict> conflicts;
  final List<String> warnings;
  final Project? mergedProject;
  final Project? archivedProject;
  final List<Project>? createdProjects;
  
  const MigrationOperationResult({
    required this.migratedTasks,
    required this.conflicts,
    required this.warnings,
    this.mergedProject,
    this.archivedProject,
    this.createdProjects,
  });
}

/// Validation result for migrations
class MigrationValidation {
  final List<String> errors;
  final List<String> warnings;
  final List<MigrationConflict> conflicts;
  
  const MigrationValidation({
    required this.errors,
    required this.warnings,
    required this.conflicts,
  });
  
  bool get hasErrors => errors.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasConflicts => conflicts.isNotEmpty;
  
  Map<String, dynamic> toMap() {
    return {
      'errors': errors,
      'warnings': warnings,
      'conflicts': conflicts.map((c) => c.toMap()).toList(),
    };
  }
}

/// Migration conflict representation
class MigrationConflict {
  final ConflictType type;
  final String taskId;
  final String description;
  final String suggestedResolution;
  
  const MigrationConflict({
    required this.type,
    required this.taskId,
    required this.description,
    required this.suggestedResolution,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'taskId': taskId,
      'description': description,
      'suggestedResolution': suggestedResolution,
    };
  }
}

/// Project split configuration
class ProjectSplit {
  final String projectName;
  final String? projectDescription;
  final String? projectColor;
  final String? categoryId;
  final List<String> taskIds;
  
  const ProjectSplit({
    required this.projectName,
    this.projectDescription,
    this.projectColor,
    this.categoryId,
    required this.taskIds,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'projectName': projectName,
      'projectDescription': projectDescription,
      'projectColor': projectColor,
      'categoryId': categoryId,
      'taskIds': taskIds,
    };
  }
}

/// Import options
class ImportOptions {
  final ConflictResolution conflictResolution;
  final bool preserveIds;
  final bool validateData;
  
  const ImportOptions({
    this.conflictResolution = ConflictResolution.rename,
    this.preserveIds = false,
    this.validateData = true,
  });
}

/// Export options
class ExportOptions {
  final bool includeAllProjects;
  final bool includeAllTasks;
  final bool includeCompletedTasks;
  final bool includeArchivedProjects;
  final bool includeMetadata;
  
  const ExportOptions({
    this.includeAllProjects = false,
    this.includeAllTasks = false,
    this.includeCompletedTasks = true,
    this.includeArchivedProjects = false,
    this.includeMetadata = true,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'includeAllProjects': includeAllProjects,
      'includeAllTasks': includeAllTasks,
      'includeCompletedTasks': includeCompletedTasks,
      'includeArchivedProjects': includeArchivedProjects,
      'includeMetadata': includeMetadata,
    };
  }
}

/// Enums
enum MigrationType {
  moveToProject,
  mergeProjects,
  splitProject,
  archiveProject,
  import,
  export,
}

enum MigrationStrategy {
  preserve,
  merge,
  split,
  archive,
  import,
}

enum ConflictType {
  crossProjectDependency,
  duplicateTask,
  invalidData,
}

enum ConflictResolution {
  sourceWins,
  targetWins,
  rename,
  skip,
}

enum MergeStrategy {
  combineAll,
  sourceMetadata,
  targetMetadata,
}

enum ArchiveStrategy {
  preserveRelationships,
  moveToDefault,
  completeOrDelete,
}

/// Exception for migration operations
class MigrationException implements Exception {
  final String message;
  final String? code;
  final Map<String, dynamic>? metadata;
  
  const MigrationException(
    this.message, {
    this.code,
    this.metadata,
  });
  
  @override
  String toString() => 'MigrationException: $message';
}


/// Cancel token (duplicate from bulk_operation_service.dart)
class CancelToken {
  bool _isCancelled = false;
  
  bool get isCancelled => _isCancelled;
  
  void cancel() {
    _isCancelled = true;
  }
}