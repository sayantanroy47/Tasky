import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/task_model.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/tag.dart' as entities;
import '../../domain/models/enums.dart' hide SyncStatus, SyncConflict;
import '../../domain/repositories/task_repository.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/repositories/tag_repository.dart';
import '../../data/models/api_models.dart';
import '../../core/errors/app_exceptions.dart';
import 'sync_models.dart';

/// Custom exceptions for sync service
class AuthenticationException implements Exception {
  final String message;
  const AuthenticationException(this.message);
  @override
  String toString() => 'AuthenticationException: $message';
}

/// Implementation of cloud synchronization service using Supabase
class SyncServiceImpl {
  final TaskRepository _taskRepository;
  final ProjectRepository _projectRepository;
  final TagRepository _tagRepository;
  final SupabaseClient _supabaseClient;
  final Connectivity _connectivity;

  final StreamController<SyncStatus> _syncStatusController = StreamController<SyncStatus>.broadcast();
  final StreamController<List<SyncConflict>> _conflictsController = StreamController<List<SyncConflict>>.broadcast();

  Timer? _autoSyncTimer;
  bool _isAutoSyncEnabled = false;
  DateTime? _lastSyncTime;

  SyncServiceImpl({
    required TaskRepository taskRepository,
    required ProjectRepository projectRepository,
    required TagRepository tagRepository,
    required SupabaseClient supabaseClient,
    Connectivity? connectivity,
  }) : _taskRepository = taskRepository,
       _projectRepository = projectRepository,
       _tagRepository = tagRepository,
       _supabaseClient = supabaseClient,
       _connectivity = connectivity ?? Connectivity();

  /// Stream of sync status updates
  Stream<SyncStatus> get syncStatus => _syncStatusController.stream;

  /// Stream of sync conflicts
  Stream<List<SyncConflict>> get conflicts => _conflictsController.stream;

  /// Gets the last sync time
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Checks if auto sync is enabled
  bool get isAutoSyncEnabled => _isAutoSyncEnabled;

  /// Initializes the sync service
  Future<void> initialize() async {
    // Load last sync time from storage
    // This would typically be stored in SharedPreferences
    _lastSyncTime = DateTime.now().subtract(const Duration(days: 30));
    
    // Set up connectivity monitoring
    _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
  }

  /// Enables or disables auto sync
  Future<void> enableAutoSync(bool enabled, {Duration interval = const Duration(minutes: 15)}) async {
    _isAutoSyncEnabled = enabled;
    
    _autoSyncTimer?.cancel();
    
    if (enabled) {
      _autoSyncTimer = Timer.periodic(interval, (_) async {
        final connectivityResult = await _connectivity.checkConnectivity();
        if (!connectivityResult.contains(ConnectivityResult.none)) {
          await syncToCloud();
        }
      });
    }
  }

  /// Syncs local data to cloud
  Future<void> syncToCloud() async {
    try {
      _syncStatusController.add(SyncStatus.syncing);

      // Check connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none) && connectivityResult.length == 1) {
        throw const NetworkException('No internet connection');
      }

      // Check authentication
      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        throw const AuthenticationException('User not authenticated');
      }

      // Get local data
      final localTasks = await _taskRepository.getAllTasks();
      final localProjects = await _projectRepository.getAllProjects();
      final localTags = await _tagRepository.getAllTags();

      // Prepare sync request
      final syncRequest = SyncRequest(
        tasks: localTasks.map((t) => _taskToResponse(t)).toList(),
        projects: localProjects.map((p) => _projectToResponse(p)).toList(),
        tags: localTags.map((t) => _tagToResponse(t)).toList(),
        lastSyncTime: _lastSyncTime ?? DateTime.now().subtract(const Duration(days: 30)),
      );

      // Send to server
      final response = await _supabaseClient
          .from('sync_data')
          .upsert(syncRequest.toJson())
          .select()
          .single();

      final syncResponse = SyncResponse.fromJson(response);

      // Handle conflicts
      if (syncResponse.conflicts.isNotEmpty) {
        final conflicts = syncResponse.conflicts.map((c) => SyncConflict(
          entityId: c.entityId,
          entityType: SyncEntityType.values.firstWhere(
            (e) => e.name == c.entityType,
            orElse: () => SyncEntityType.task,
          ),
          localData: c.localData,
          serverData: c.serverData,
          conflictTime: c.conflictTime,
        )).toList();

        _conflictsController.add(conflicts);
        _syncStatusController.add(SyncStatus.conflicted);
        return;
      }

      // Update local data with server changes
      await _applyServerChanges(syncResponse);

      _lastSyncTime = syncResponse.serverTime;
      _syncStatusController.add(SyncStatus.completed);

    } catch (e) {
      _syncStatusController.add(SyncStatus.failed);
      rethrow;
    }
  }

  /// Syncs data from cloud to local
  Future<void> syncFromCloud() async {
    try {
      _syncStatusController.add(SyncStatus.syncing);

      // Check connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none) && connectivityResult.length == 1) {
        throw const NetworkException('No internet connection');
      }

      // Check authentication
      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        throw const AuthenticationException('User not authenticated');
      }

      // Get server data
      final response = await _supabaseClient
          .from('sync_data')
          .select()
          .eq('user_id', user.id)
          .single();

      final syncResponse = SyncResponse.fromJson(response);

      // Apply server changes
      await _applyServerChanges(syncResponse);

      _lastSyncTime = syncResponse.serverTime;
      _syncStatusController.add(SyncStatus.completed);

    } catch (e) {
      _syncStatusController.add(SyncStatus.failed);
      rethrow;
    }
  }

  /// Resolves sync conflicts
  Future<void> resolveConflicts(List<SyncConflictResolution> resolutions) async {
    try {
      for (final resolution in resolutions) {
        switch (resolution.entityType) {
          case SyncEntityType.task:
            await _resolveTaskConflict(resolution);
            break;
          case SyncEntityType.project:
            await _resolveProjectConflict(resolution);
            break;
          case SyncEntityType.tag:
            await _resolveTagConflict(resolution);
            break;
        }
      }

      // Clear conflicts
      _conflictsController.add([]);
      
      // Retry sync
      await syncToCloud();

    } catch (e) {
      _syncStatusController.add(SyncStatus.failed);
      rethrow;
    }
  }

  /// Handles connectivity changes
  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    if (result != ConnectivityResult.none && _isAutoSyncEnabled) {
      // Delay sync to allow connection to stabilize
      Timer(const Duration(seconds: 2), () async {
        try {
          await syncToCloud();
        } catch (e) {
          // Ignore errors from automatic sync
        }
      });
    }
  }

  /// Applies server changes to local data
  Future<void> _applyServerChanges(SyncResponse response) async {
    // Update tasks
    for (final taskResponse in response.tasks) {
      final task = _responseToTask(taskResponse);
      final existingTask = await _taskRepository.getTaskById(task.id);
      
      if (existingTask == null) {
        await _taskRepository.createTask(task);
      } else if (task.updatedAt?.isAfter(existingTask.updatedAt ?? existingTask.createdAt) ?? false) {
        await _taskRepository.updateTask(task);
      }
    }

    // Update projects
    for (final projectResponse in response.projects) {
      final project = _responseToProject(projectResponse);
      final existingProject = await _projectRepository.getProjectById(project.id);
      
      if (existingProject == null) {
        await _projectRepository.createProject(project);
      } else if (project.updatedAt?.isAfter(existingProject.updatedAt ?? existingProject.createdAt) ?? false) {
        await _projectRepository.updateProject(project);
      }
    }

    // Update tags
    for (final tagResponse in response.tags) {
      final tag = _responseToTag(tagResponse);
      final existingTag = await _tagRepository.getTagById(tag.id);
      
      if (existingTag == null) {
        await _tagRepository.createTag(tag);
      }
    }
  }

  /// Resolves a task conflict
  Future<void> _resolveTaskConflict(SyncConflictResolution resolution) async {
    final TaskModel task;
    
    switch (resolution.resolution) {
      case ConflictResolution.useLocal:
        task = TaskModel.fromJson(resolution.localData);
        break;
      case ConflictResolution.useServer:
        task = _responseToTask(TaskResponse.fromJson(resolution.serverData));
        break;
      case ConflictResolution.merge:
        task = _mergeTaskData(resolution.localData, resolution.serverData);
        break;
    }

    await _taskRepository.updateTask(task);
  }

  /// Resolves a project conflict
  Future<void> _resolveProjectConflict(SyncConflictResolution resolution) async {
    final Project project;
    
    switch (resolution.resolution) {
      case ConflictResolution.useLocal:
        project = Project.fromJson(resolution.localData);
        break;
      case ConflictResolution.useServer:
        project = _responseToProject(ProjectResponse.fromJson(resolution.serverData));
        break;
      case ConflictResolution.merge:
        project = _mergeProjectData(resolution.localData, resolution.serverData);
        break;
    }

    await _projectRepository.updateProject(project);
  }

  /// Resolves a tag conflict
  Future<void> _resolveTagConflict(SyncConflictResolution resolution) async {
    final entities.Tag tag;
    
    switch (resolution.resolution) {
      case ConflictResolution.useLocal:
        tag = entities.Tag.fromJson(resolution.localData);
        break;
      case ConflictResolution.useServer:
        tag = _responseToTag(TagResponse.fromJson(resolution.serverData));
        break;
      case ConflictResolution.merge:
        tag = _mergeTagData(resolution.localData, resolution.serverData);
        break;
    }

    await _tagRepository.updateTag(tag);
  }

  /// Merges task data for conflict resolution
  TaskModel _mergeTaskData(Map<String, dynamic> localData, Map<String, dynamic> serverData) {
    // Simple merge strategy: use server data but keep local completion status
    final serverTask = TaskModel.fromJson(serverData);
    final localTask = TaskModel.fromJson(localData);
    
    return serverTask.copyWith(
      status: localTask.status,
      completedAt: localTask.completedAt,
    );
  }

  /// Merges project data for conflict resolution
  Project _mergeProjectData(Map<String, dynamic> localData, Map<String, dynamic> serverData) {
    // Simple merge strategy: use server data but keep local archive status
    final serverProject = Project.fromJson(serverData);
    final localProject = Project.fromJson(localData);
    
    return serverProject.copyWith(
      isArchived: localProject.isArchived,
    );
  }

  /// Merges tag data for conflict resolution
  entities.Tag _mergeTagData(Map<String, dynamic> localData, Map<String, dynamic> serverData) {
    // For tags, server data takes precedence
    return entities.Tag.fromJson(serverData);
  }

  /// Converts TaskModel to TaskResponse
  TaskResponse _taskToResponse(TaskModel task) {
    return TaskResponse(
      id: task.id,
      title: task.title,
      description: task.description,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
      dueDate: task.dueDate,
      completedAt: task.completedAt,
      priority: task.priority.name,
      status: task.status.name,
      tags: task.tags,
      projectId: task.projectId,
      metadata: task.metadata,
    );
  }

  /// Converts TaskResponse to TaskModel
  TaskModel _responseToTask(TaskResponse response) {
    return TaskModel(
      id: response.id,
      title: response.title,
      description: response.description,
      createdAt: response.createdAt,
      updatedAt: response.updatedAt,
      dueDate: response.dueDate,
      completedAt: response.completedAt,
      priority: TaskPriority.values.firstWhere(
        (p) => p.name == response.priority,
        orElse: () => TaskPriority.medium,
      ),
      status: TaskStatus.values.firstWhere(
        (s) => s.name == response.status,
        orElse: () => TaskStatus.pending,
      ),
      tags: response.tags,
      projectId: response.projectId,
      metadata: response.metadata,
    );
  }

  /// Converts Project to ProjectResponse
  ProjectResponse _projectToResponse(Project project) {
    return ProjectResponse(
      id: project.id,
      name: project.name,
      description: project.description,
      color: project.color,
      createdAt: project.createdAt,
      updatedAt: project.updatedAt,
      isArchived: project.isArchived,
    );
  }

  /// Converts ProjectResponse to Project
  Project _responseToProject(ProjectResponse response) {
    return Project(
      id: response.id,
      name: response.name,
      description: response.description,
      color: response.color,
      createdAt: response.createdAt,
      updatedAt: response.updatedAt,
      isArchived: response.isArchived,
    );
  }

  /// Converts Tag to TagResponse
  TagResponse _tagToResponse(entities.Tag tag) {
    return TagResponse(
      id: tag.id,
      name: tag.name,
      color: tag.color,
      createdAt: tag.createdAt,
    );
  }

  /// Converts TagResponse to Tag
  entities.Tag _responseToTag(TagResponse response) {
    return entities.Tag(
      id: response.id,
      name: response.name,
      color: response.color,
      createdAt: response.createdAt,
    );
  }

  /// Disposes resources
  void dispose() {
    _autoSyncTimer?.cancel();
    _syncStatusController.close();
    _conflictsController.close();
  }
}