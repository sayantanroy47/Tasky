import '../../domain/entities/task_model.dart';
import '../../domain/entities/subtask.dart';

/// Service for handling data synchronization conflicts
/// 
/// This service manages conflicts that occur when:
/// - Same task is modified on different devices
/// - Task is deleted on one device but modified on another
/// - Data integrity issues during sync
class ConflictResolutionService {
  
  /// Resolves conflicts between local and remote tasks
  Future<ConflictResolution> resolveTaskConflict(
    TaskModel localTask,
    TaskModel remoteTask,
    ConflictResolutionStrategy strategy,
  ) async {
    // Detect the type of conflict
    final conflictType = _detectConflictType(localTask, remoteTask);
    
    switch (strategy) {
      case ConflictResolutionStrategy.localWins:
        return _resolveLocalWins(localTask, remoteTask, conflictType);
        
      case ConflictResolutionStrategy.remoteWins:
        return _resolveRemoteWins(localTask, remoteTask, conflictType);
        
      case ConflictResolutionStrategy.lastModifiedWins:
        return _resolveLastModifiedWins(localTask, remoteTask, conflictType);
        
      case ConflictResolutionStrategy.merge:
        return _resolveMerge(localTask, remoteTask, conflictType);
        
      case ConflictResolutionStrategy.manual:
        return _createManualResolution(localTask, remoteTask, conflictType);
    }
  }
  
  /// Detects the type of conflict between two tasks
  ConflictType _detectConflictType(TaskModel localTask, TaskModel remoteTask) {
    final conflicts = <ConflictField>[];
    
    // Compare basic fields
    if (localTask.title != remoteTask.title) {
      conflicts.add(ConflictField.title);
    }
    if (localTask.description != remoteTask.description) {
      conflicts.add(ConflictField.description);
    }
    if (localTask.status != remoteTask.status) {
      conflicts.add(ConflictField.status);
    }
    if (localTask.priority != remoteTask.priority) {
      conflicts.add(ConflictField.priority);
    }
    if (localTask.dueDate != remoteTask.dueDate) {
      conflicts.add(ConflictField.dueDate);
    }
    if (localTask.completedAt != remoteTask.completedAt) {
      conflicts.add(ConflictField.completedAt);
    }
    
    // Compare collections
    if (!_listsEqual(localTask.tags, remoteTask.tags)) {
      conflicts.add(ConflictField.tags);
    }
    if (!_listsEqual(localTask.dependencies, remoteTask.dependencies)) {
      conflicts.add(ConflictField.dependencies);
    }
    if (localTask.subTasks.length != remoteTask.subTasks.length ||
        !localTask.subTasks.every((local) => 
          remoteTask.subTasks.any((remote) => 
            local.id == remote.id && local.title == remote.title && 
            local.isCompleted == remote.isCompleted))) {
      conflicts.add(ConflictField.subTasks);
    }
    
    // Compare metadata
    if (!_mapsEqual(localTask.metadata, remoteTask.metadata)) {
      conflicts.add(ConflictField.metadata);
    }
    
    if (conflicts.isEmpty) {
      return ConflictType.none;
    } else if (conflicts.length == 1) {
      return ConflictType.minor;
    } else if (conflicts.length <= 3) {
      return ConflictType.moderate;
    } else {
      return ConflictType.major;
    }
  }
  
  /// Resolves conflict with local version winning
  ConflictResolution _resolveLocalWins(
    TaskModel localTask, 
    TaskModel remoteTask, 
    ConflictType conflictType,
  ) {
    return ConflictResolution(
      resolvedTask: localTask,
      strategy: ConflictResolutionStrategy.localWins,
      conflictType: conflictType,
      wasAutoResolved: true,
      resolution: 'Local version kept, remote changes discarded',
    );
  }
  
  /// Resolves conflict with remote version winning
  ConflictResolution _resolveRemoteWins(
    TaskModel localTask, 
    TaskModel remoteTask, 
    ConflictType conflictType,
  ) {
    return ConflictResolution(
      resolvedTask: remoteTask,
      strategy: ConflictResolutionStrategy.remoteWins,
      conflictType: conflictType,
      wasAutoResolved: true,
      resolution: 'Remote version kept, local changes discarded',
    );
  }
  
  /// Resolves conflict based on last modified timestamp
  ConflictResolution _resolveLastModifiedWins(
    TaskModel localTask, 
    TaskModel remoteTask, 
    ConflictType conflictType,
  ) {
    final localModified = localTask.updatedAt ?? localTask.createdAt;
    final remoteModified = remoteTask.updatedAt ?? remoteTask.createdAt;
    
    if (localModified.isAfter(remoteModified)) {
      return ConflictResolution(
        resolvedTask: localTask,
        strategy: ConflictResolutionStrategy.lastModifiedWins,
        conflictType: conflictType,
        wasAutoResolved: true,
        resolution: 'Local version newer ($localModified), kept local changes',
      );
    } else {
      return ConflictResolution(
        resolvedTask: remoteTask,
        strategy: ConflictResolutionStrategy.lastModifiedWins,
        conflictType: conflictType,
        wasAutoResolved: true,
        resolution: 'Remote version newer ($remoteModified), kept remote changes',
      );
    }
  }
  
  /// Attempts to merge changes from both versions
  ConflictResolution _resolveMerge(
    TaskModel localTask, 
    TaskModel remoteTask, 
    ConflictType conflictType,
  ) {
    try {
      // Create merged task with intelligent field selection
      final mergedTask = _createMergedTask(localTask, remoteTask);
      
      return ConflictResolution(
        resolvedTask: mergedTask,
        strategy: ConflictResolutionStrategy.merge,
        conflictType: conflictType,
        wasAutoResolved: true,
        resolution: 'Successfully merged changes from both versions',
      );
    } catch (e) {
      // Fall back to last modified wins if merge fails
      return _resolveLastModifiedWins(localTask, remoteTask, conflictType);
    }
  }
  
  /// Creates a merged task combining changes from both versions
  TaskModel _createMergedTask(TaskModel localTask, TaskModel remoteTask) {
    // Use more recent timestamp for each field
    final localModified = localTask.updatedAt ?? localTask.createdAt;
    final remoteModified = remoteTask.updatedAt ?? remoteTask.createdAt;
    
    return TaskModel(
      id: localTask.id,
      
      // Use more recent basic fields
      title: localModified.isAfter(remoteModified) ? localTask.title : remoteTask.title,
      description: _mergeOptionalString(localTask.description, remoteTask.description, localModified, remoteModified),
      
      // Keep earliest creation date
      createdAt: localTask.createdAt.isBefore(remoteTask.createdAt) 
        ? localTask.createdAt 
        : remoteTask.createdAt,
        
      // Use latest update date
      updatedAt: localModified.isAfter(remoteModified) ? localModified : remoteModified,
      
      // Smart due date merging
      dueDate: _mergeDueDate(localTask.dueDate, remoteTask.dueDate, localModified, remoteModified),
      
      // Use completion from more recent version
      completedAt: localModified.isAfter(remoteModified) ? localTask.completedAt : remoteTask.completedAt,
      
      // Status and priority from more recent version
      status: localModified.isAfter(remoteModified) ? localTask.status : remoteTask.status,
      priority: localModified.isAfter(remoteModified) ? localTask.priority : remoteTask.priority,
      
      // Merge collections
      tags: _mergeLists(localTask.tags, remoteTask.tags),
      dependencies: _mergeLists(localTask.dependencies, remoteTask.dependencies),
      subTasks: _mergeSubTasks(localTask.subTasks, remoteTask.subTasks),
      
      // Other fields from more recent version
      locationTrigger: localModified.isAfter(remoteModified) ? localTask.locationTrigger : remoteTask.locationTrigger,
      recurrence: localModified.isAfter(remoteModified) ? localTask.recurrence : remoteTask.recurrence,
      projectId: localModified.isAfter(remoteModified) ? localTask.projectId : remoteTask.projectId,
      
      // Merge metadata
      metadata: _mergeMaps(localTask.metadata, remoteTask.metadata),
      
      // Other properties
      isPinned: localModified.isAfter(remoteModified) ? localTask.isPinned : remoteTask.isPinned,
      estimatedDuration: localModified.isAfter(remoteModified) ? localTask.estimatedDuration : remoteTask.estimatedDuration,
      actualDuration: localModified.isAfter(remoteModified) ? localTask.actualDuration : remoteTask.actualDuration,
    );
  }
  
  /// Creates a manual resolution that requires user input
  ConflictResolution _createManualResolution(
    TaskModel localTask, 
    TaskModel remoteTask, 
    ConflictType conflictType,
  ) {
    return ConflictResolution(
      resolvedTask: localTask, // Temporary - will be replaced by user choice
      strategy: ConflictResolutionStrategy.manual,
      conflictType: conflictType,
      wasAutoResolved: false,
      resolution: 'Manual resolution required - user must choose',
      localTask: localTask,
      remoteTask: remoteTask,
    );
  }
  
  // Helper methods for merging
  
  String? _mergeOptionalString(String? local, String? remote, DateTime localTime, DateTime remoteTime) {
    if (local == null && remote == null) return null;
    if (local == null) return remote;
    if (remote == null) return local;
    return localTime.isAfter(remoteTime) ? local : remote;
  }
  
  DateTime? _mergeDueDate(DateTime? local, DateTime? remote, DateTime localTime, DateTime remoteTime) {
    if (local == null && remote == null) return null;
    if (local == null) return remote;
    if (remote == null) return local;
    
    // Prefer earlier due date if both exist, unless one is much more recent
    final timeDiff = localTime.difference(remoteTime).abs();
    if (timeDiff.inHours < 1) {
      return local.isBefore(remote) ? local : remote;
    } else {
      return localTime.isAfter(remoteTime) ? local : remote;
    }
  }
  
  List<T> _mergeLists<T>(List<T> local, List<T> remote) {
    final merged = <T>[...local];
    for (final item in remote) {
      if (!merged.contains(item)) {
        merged.add(item);
      }
    }
    return merged;
  }
  
  List<SubTask> _mergeSubTasks(List<SubTask> local, List<SubTask> remote) {
    final merged = <SubTask>[];
    final processedIds = <String>{};
    
    // Add all local subtasks
    for (final localSub in local) {
      merged.add(localSub);
      processedIds.add(localSub.id);
    }
    
    // Add remote subtasks that don't exist locally
    for (final remoteSub in remote) {
      if (!processedIds.contains(remoteSub.id)) {
        merged.add(remoteSub);
      } else {
        // Merge existing subtask (prefer completed status)
        final index = merged.indexWhere((s) => s.id == remoteSub.id);
        if (index >= 0) {
          final localSub = merged[index];
          if (remoteSub.isCompleted && !localSub.isCompleted) {
            merged[index] = remoteSub; // Prefer completed version
          }
        }
      }
    }
    
    return merged;
  }
  
  Map<String, dynamic> _mergeMaps(Map<String, dynamic> local, Map<String, dynamic> remote) {
    final merged = <String, dynamic>{...local};
    for (final entry in remote.entries) {
      merged[entry.key] = entry.value;
    }
    return merged;
  }
  
  bool _listsEqual<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
  
  bool _mapsEqual(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
  
  /// Gets user preference for conflict resolution strategy
  Future<ConflictResolutionStrategy> getUserPreferredStrategy() async {
    // In production, this would check user settings
    // For now, return a sensible default
    return ConflictResolutionStrategy.lastModifiedWins;
  }
  
  /// Analyzes multiple conflicts and provides batch resolution
  Future<List<ConflictResolution>> resolveBatchConflicts(
    List<TaskConflictPair> conflicts,
    ConflictResolutionStrategy strategy,
  ) async {
    final resolutions = <ConflictResolution>[];
    
    for (final conflict in conflicts) {
      final resolution = await resolveTaskConflict(
        conflict.localTask,
        conflict.remoteTask,
        strategy,
      );
      resolutions.add(resolution);
    }
    
    return resolutions;
  }
}

/// Represents a conflict between local and remote versions of a task
class TaskConflictPair {
  final TaskModel localTask;
  final TaskModel remoteTask;
  
  const TaskConflictPair({
    required this.localTask,
    required this.remoteTask,
  });
}

/// Result of conflict resolution
class ConflictResolution {
  final TaskModel resolvedTask;
  final ConflictResolutionStrategy strategy;
  final ConflictType conflictType;
  final bool wasAutoResolved;
  final String resolution;
  final TaskModel? localTask;
  final TaskModel? remoteTask;
  
  const ConflictResolution({
    required this.resolvedTask,
    required this.strategy,
    required this.conflictType,
    required this.wasAutoResolved,
    required this.resolution,
    this.localTask,
    this.remoteTask,
  });
}

/// Types of conflicts
enum ConflictType {
  none,
  minor,      // 1 field different
  moderate,   // 2-3 fields different
  major,      // 4+ fields different
}

/// Fields that can have conflicts
enum ConflictField {
  title,
  description,
  status,
  priority,
  dueDate,
  completedAt,
  tags,
  subTasks,
  dependencies,
  metadata,
}

/// Strategies for resolving conflicts
enum ConflictResolutionStrategy {
  localWins,          // Always keep local version
  remoteWins,         // Always keep remote version
  lastModifiedWins,   // Keep version with latest timestamp
  merge,              // Attempt to merge changes intelligently
  manual,             // Require user to manually resolve
}