import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';

/// Simple cache manager for frequently accessed tasks
/// 
/// This cache helps reduce database queries for recently accessed data.
/// It uses a simple time-based expiration strategy with LRU eviction.
class TaskCacheManager {
  static const Duration _defaultExpiration = Duration(minutes: 5);
  static const int _maxCacheSize = 100;
  
  final Map<String, _CacheEntry<TaskModel>> _taskCache = {};
  final Map<String, _CacheEntry<List<TaskModel>>> _listCache = {};
  final Map<String, DateTime> _accessTimes = {};
  
  /// Get a cached task by ID
  TaskModel? getCachedTask(String id) {
    final entry = _taskCache[id];
    if (entry != null && !entry.isExpired) {
      _accessTimes[id] = DateTime.now();
      return entry.data;
    }
    
    // Remove expired entry
    if (entry != null) {
      _taskCache.remove(id);
      _accessTimes.remove(id);
    }
    
    return null;
  }
  
  /// Cache a single task
  void cacheTask(TaskModel task) {
    _evictIfNeeded();
    _taskCache[task.id] = _CacheEntry(task);
    _accessTimes[task.id] = DateTime.now();
  }

  /// Remove a specific task from cache
  void removeCachedTask(String taskId) {
    _taskCache.remove(taskId);
    _accessTimes.remove(taskId);
  }
  
  /// Get cached task list by filter key
  List<TaskModel>? getCachedTaskList(String filterKey) {
    final entry = _listCache[filterKey];
    if (entry != null && !entry.isExpired) {
      _accessTimes[filterKey] = DateTime.now();
      return entry.data;
    }
    
    // Remove expired entry
    if (entry != null) {
      _listCache.remove(filterKey);
      _accessTimes.remove(filterKey);
    }
    
    return null;
  }
  
  /// Cache a task list with a filter key
  void cacheTaskList(String filterKey, List<TaskModel> tasks) {
    _evictIfNeeded();
    _listCache[filterKey] = _CacheEntry(tasks);
    _accessTimes[filterKey] = DateTime.now();
  }
  
  /// Generate cache key for task filters
  static String generateFilterKey(TaskFilter filter) {
    final buffer = StringBuffer();
    buffer.write('filter:');
    buffer.write('status=${filter.status?.name ?? 'null'},');
    buffer.write('priority=${filter.priority?.name ?? 'null'},');
    buffer.write('project=${filter.projectId ?? 'null'},');
    buffer.write('from=${filter.dueDateFrom?.millisecondsSinceEpoch ?? 'null'},');
    buffer.write('to=${filter.dueDateTo?.millisecondsSinceEpoch ?? 'null'},');
    buffer.write('overdue=${filter.isOverdue ?? 'null'},');
    buffer.write('pinned=${filter.isPinned ?? 'null'},');
    buffer.write('search=${filter.searchQuery ?? 'null'},');
    buffer.write('sortBy=${filter.sortBy.name},');
    buffer.write('sortAsc=${filter.sortAscending}');
    
    if (filter.tags != null && filter.tags!.isNotEmpty) {
      buffer.write(',tags=${filter.tags!.join(':')}');
    }
    
    return buffer.toString();
  }
  
  /// Invalidate cache entries that might be affected by a task update
  void invalidateTaskRelatedCache(TaskModel task) {
    // Remove the specific task from cache
    _taskCache.remove(task.id);
    _accessTimes.remove(task.id);
    
    // Remove potentially affected list caches
    final keysToRemove = <String>[];
    for (final key in _listCache.keys) {
      // Invalidate caches that might include this task based on its properties
      if (key.contains('status=${task.status.name}') ||
          key.contains('priority=${task.priority.name}') ||
          key.contains('project=${task.projectId ?? 'null'}') ||
          key.contains('pinned=${task.isPinned}') ||
          (task.dueDate != null && key.contains('from=')) ||
          key.contains('search=')) {
        keysToRemove.add(key);
      }
    }
    
    for (final key in keysToRemove) {
      _listCache.remove(key);
      _accessTimes.remove(key);
    }
  }
  
  /// Clear all cached data
  void clearAll() {
    _taskCache.clear();
    _listCache.clear();
    _accessTimes.clear();
  }

  /// Clear specific list caches by type
  void clearListCachesByType(CacheClearType type) {
    final keysToRemove = <String>[];
    
    switch (type) {
      case CacheClearType.statusRelated:
        for (final key in _listCache.keys) {
          if (key.contains('status=') || key.contains('filter:')) {
            keysToRemove.add(key);
          }
        }
        break;
      case CacheClearType.priorityRelated:
        for (final key in _listCache.keys) {
          if (key.contains('priority=') || key.contains('filter:')) {
            keysToRemove.add(key);
          }
        }
        break;
      case CacheClearType.projectRelated:
        for (final key in _listCache.keys) {
          if (key.contains('project=') || key.contains('filter:')) {
            keysToRemove.add(key);
          }
        }
        break;
      case CacheClearType.dateRelated:
        for (final key in _listCache.keys) {
          if (key.contains('from=') || key.contains('to=') || key.contains('overdue=')) {
            keysToRemove.add(key);
          }
        }
        break;
      case CacheClearType.searchRelated:
        for (final key in _listCache.keys) {
          if (key.contains('search=')) {
            keysToRemove.add(key);
          }
        }
        break;
    }
    
    for (final key in keysToRemove) {
      _listCache.remove(key);
      _accessTimes.remove(key);
    }
  }
  
  /// Evict least recently used entries if cache is full
  void _evictIfNeeded() {
    final totalEntries = _taskCache.length + _listCache.length;
    if (totalEntries >= _maxCacheSize) {
      // Find least recently used entry
      String? lruKey;
      DateTime? oldestAccess;
      
      for (final entry in _accessTimes.entries) {
        if (oldestAccess == null || entry.value.isBefore(oldestAccess)) {
          oldestAccess = entry.value;
          lruKey = entry.key;
        }
      }
      
      if (lruKey != null) {
        _taskCache.remove(lruKey);
        _listCache.remove(lruKey);
        _accessTimes.remove(lruKey);
      }
    }
  }
  
  /// Get cache statistics for monitoring
  CacheStats getStats() {
    return CacheStats(
      taskCacheSize: _taskCache.length,
      listCacheSize: _listCache.length,
      totalSize: _taskCache.length + _listCache.length,
      maxSize: _maxCacheSize,
    );
  }
}

/// Cache entry with expiration
class _CacheEntry<T> {
  final T data;
  final DateTime createdAt;
  
  _CacheEntry(this.data) : createdAt = DateTime.now();
  
  bool get isExpired => DateTime.now().difference(createdAt) > TaskCacheManager._defaultExpiration;
}

/// Cache statistics for monitoring
class CacheStats {
  final int taskCacheSize;
  final int listCacheSize;
  final int totalSize;
  final int maxSize;
  
  const CacheStats({
    required this.taskCacheSize,
    required this.listCacheSize,
    required this.totalSize,
    required this.maxSize,
  });
  
  double get hitRatio => totalSize > 0 ? totalSize / maxSize : 0.0;
  bool get isFull => totalSize >= maxSize;
}

/// Cache clear types for selective invalidation
enum CacheClearType {
  statusRelated,
  priorityRelated,
  projectRelated,
  dateRelated,
  searchRelated,
}