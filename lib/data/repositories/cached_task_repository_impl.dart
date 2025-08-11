import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../../domain/repositories/task_repository.dart';
import '../../services/database/database.dart';
import '../../core/cache/task_cache_manager.dart';
import 'task_repository_impl.dart';

/// Cached implementation of TaskRepository for improved performance
/// 
/// This repository wraps the standard implementation with a caching layer
/// to reduce database queries for frequently accessed data.
class CachedTaskRepositoryImpl implements TaskRepository {
  final TaskRepositoryImpl _baseRepository;
  final TaskCacheManager _cache;

  CachedTaskRepositoryImpl(AppDatabase database)
      : _baseRepository = TaskRepositoryImpl(database),
        _cache = TaskCacheManager();

  @override
  Future<List<TaskModel>> getAllTasks() async {
    return await _baseRepository.getAllTasks();
  }

  @override
  Future<TaskModel?> getTaskById(String id) async {
    // Check cache first
    final cachedTask = _cache.getCachedTask(id);
    if (cachedTask != null) {
      return cachedTask;
    }

    // Fetch from database and cache
    final task = await _baseRepository.getTaskById(id);
    if (task != null) {
      _cache.cacheTask(task);
    }
    return task;
  }

  @override
  Future<void> createTask(TaskModel task) async {
    await _baseRepository.createTask(task);
    _cache.cacheTask(task);
    // Clear list caches as they might be outdated
    _cache.invalidateTaskRelatedCache(task);
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    await _baseRepository.updateTask(task);
    _cache.cacheTask(task);
    _cache.invalidateTaskRelatedCache(task);
  }

  @override
  Future<void> deleteTask(String id) async {
    // Get task before deletion for cache invalidation
    final task = await getTaskById(id);
    await _baseRepository.deleteTask(id);
    
    if (task != null) {
      _cache.invalidateTaskRelatedCache(task);
    }
  }

  @override
  Future<List<TaskModel>> getTasksByStatus(TaskStatus status) async {
    final filter = TaskFilter(status: status);
    final cacheKey = TaskCacheManager.generateFilterKey(filter);
    
    // Check cache first
    final cachedTasks = _cache.getCachedTaskList(cacheKey);
    if (cachedTasks != null) {
      return cachedTasks;
    }

    // Fetch from database and cache
    final tasks = await _baseRepository.getTasksByStatus(status);
    _cache.cacheTaskList(cacheKey, tasks);
    return tasks;
  }

  @override
  Future<List<TaskModel>> getTasksByPriority(TaskPriority priority) async {
    final filter = TaskFilter(priority: priority);
    final cacheKey = TaskCacheManager.generateFilterKey(filter);
    
    // Check cache first
    final cachedTasks = _cache.getCachedTaskList(cacheKey);
    if (cachedTasks != null) {
      return cachedTasks;
    }

    // Fetch from database and cache
    final tasks = await _baseRepository.getTasksByPriority(priority);
    _cache.cacheTaskList(cacheKey, tasks);
    return tasks;
  }

  @override
  Future<List<TaskModel>> getTasksDueToday() async {
    final today = DateTime.now();
    final filter = TaskFilter(
      dueDateFrom: DateTime(today.year, today.month, today.day),
      dueDateTo: DateTime(today.year, today.month, today.day, 23, 59, 59),
    );
    final cacheKey = TaskCacheManager.generateFilterKey(filter);
    
    // Check cache first
    final cachedTasks = _cache.getCachedTaskList(cacheKey);
    if (cachedTasks != null) {
      return cachedTasks;
    }

    // Fetch from database and cache
    final tasks = await _baseRepository.getTasksDueToday();
    _cache.cacheTaskList(cacheKey, tasks);
    return tasks;
  }

  @override
  Future<List<TaskModel>> getOverdueTasks() async {
    final filter = TaskFilter(isOverdue: true);
    final cacheKey = TaskCacheManager.generateFilterKey(filter);
    
    // Check cache first
    final cachedTasks = _cache.getCachedTaskList(cacheKey);
    if (cachedTasks != null) {
      return cachedTasks;
    }

    // Fetch from database and cache
    final tasks = await _baseRepository.getOverdueTasks();
    _cache.cacheTaskList(cacheKey, tasks);
    return tasks;
  }

  @override
  Future<List<TaskModel>> getTasksByDateRange(DateTime startDate, DateTime endDate) async {
    final filter = TaskFilter(
      dueDateFrom: startDate,
      dueDateTo: endDate,
    );
    final cacheKey = TaskCacheManager.generateFilterKey(filter);
    
    // Check cache first
    final cachedTasks = _cache.getCachedTaskList(cacheKey);
    if (cachedTasks != null) {
      return cachedTasks;
    }

    // Fetch from database and cache
    final tasks = await _baseRepository.getTasksByDateRange(startDate, endDate);
    _cache.cacheTaskList(cacheKey, tasks);
    return tasks;
  }

  @override
  Future<List<TaskModel>> getTasksByProject(String projectId) async {
    final filter = TaskFilter(projectId: projectId);
    final cacheKey = TaskCacheManager.generateFilterKey(filter);
    
    // Check cache first
    final cachedTasks = _cache.getCachedTaskList(cacheKey);
    if (cachedTasks != null) {
      return cachedTasks;
    }

    // Fetch from database and cache
    final tasks = await _baseRepository.getTasksByProject(projectId);
    _cache.cacheTaskList(cacheKey, tasks);
    return tasks;
  }

  @override
  Future<List<TaskModel>> searchTasks(String query) async {
    final filter = TaskFilter(searchQuery: query);
    final cacheKey = TaskCacheManager.generateFilterKey(filter);
    
    // Check cache first
    final cachedTasks = _cache.getCachedTaskList(cacheKey);
    if (cachedTasks != null) {
      return cachedTasks;
    }

    // Fetch from database and cache
    final tasks = await _baseRepository.searchTasks(query);
    _cache.cacheTaskList(cacheKey, tasks);
    return tasks;
  }

  @override
  Future<List<TaskModel>> getTasksWithFilter(TaskFilter filter) async {
    final cacheKey = TaskCacheManager.generateFilterKey(filter);
    
    // Check cache first
    final cachedTasks = _cache.getCachedTaskList(cacheKey);
    if (cachedTasks != null) {
      return cachedTasks;
    }

    // Fetch from database and cache
    final tasks = await _baseRepository.getTasksWithFilter(filter);
    _cache.cacheTaskList(cacheKey, tasks);
    return tasks;
  }

  @override
  Stream<List<TaskModel>> watchAllTasks() {
    return _baseRepository.watchAllTasks();
  }

  @override
  Stream<List<TaskModel>> watchTasksByStatus(TaskStatus status) {
    return _baseRepository.watchTasksByStatus(status);
  }

  @override
  Stream<List<TaskModel>> watchTasksByProject(String projectId) {
    return _baseRepository.watchTasksByProject(projectId);
  }

  @override
  Future<List<TaskModel>> getTasksByIds(List<String> ids) async {
    // Check cache for individual tasks first
    final cachedTasks = <TaskModel>[];
    final missedIds = <String>[];
    
    for (final id in ids) {
      final cachedTask = _cache.getCachedTask(id);
      if (cachedTask != null) {
        cachedTasks.add(cachedTask);
      } else {
        missedIds.add(id);
      }
    }
    
    // Fetch missed tasks from database
    if (missedIds.isNotEmpty) {
      final fetchedTasks = await _baseRepository.getTasksByIds(missedIds);
      
      // Cache the fetched tasks
      for (final task in fetchedTasks) {
        _cache.cacheTask(task);
      }
      
      cachedTasks.addAll(fetchedTasks);
    }
    
    return cachedTasks;
  }

  @override
  Future<List<TaskModel>> getTasksWithDependency(String dependencyId) async {
    return await _baseRepository.getTasksWithDependency(dependencyId);
  }

  // Bulk Operations
  @override
  Future<void> deleteTasks(List<String> taskIds) async {
    // Get tasks before deletion for cache invalidation
    final tasks = await getTasksByIds(taskIds);
    await _baseRepository.deleteTasks(taskIds);
    
    // Invalidate cache for each deleted task
    for (final task in tasks) {
      _cache.invalidateTaskRelatedCache(task);
    }
  }

  @override
  Future<void> updateTasksStatus(List<String> taskIds, TaskStatus status) async {
    await _baseRepository.updateTasksStatus(taskIds, status);
    
    // Clear potentially affected caches
    _cache.clearAll(); // Bulk operations affect too many caches, safer to clear all
  }

  @override
  Future<void> updateTasksPriority(List<String> taskIds, TaskPriority priority) async {
    await _baseRepository.updateTasksPriority(taskIds, priority);
    _cache.clearAll(); // Bulk operations affect too many caches
  }

  @override
  Future<void> assignTasksToProject(List<String> taskIds, String? projectId) async {
    await _baseRepository.assignTasksToProject(taskIds, projectId);
    _cache.clearAll(); // Bulk operations affect too many caches
  }

  /// Get cache statistics for monitoring
  CacheStats getCacheStats() {
    return _cache.getStats();
  }

  /// Clear all cached data
  void clearCache() {
    _cache.clearAll();
  }
}