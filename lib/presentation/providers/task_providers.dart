import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../../domain/repositories/task_repository.dart';
import '../../data/repositories/cached_task_repository_impl.dart';
import '../../services/widget_service.dart';
import '../../core/cache/task_cache_manager.dart';
import '../../services/task/recurring_task_service.dart';
import '../../services/speech/transcription_service_factory.dart';
import '../../core/providers/core_providers.dart';
import '../../core/providers/error_state_manager.dart';

/// Provider for cache statistics monitoring
final cacheStatsProvider = Provider<CacheStats>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  if (repository is CachedTaskRepositoryImpl) {
    return repository.getCacheStats();
  }
  return const CacheStats(
    taskCacheSize: 0,
    listCacheSize: 0,
    totalSize: 0,
    maxSize: 0,
  );
});

/// Provider for all tasks
final tasksProvider = StreamProvider<List<TaskModel>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.watchAllTasks();
});

/// Provider for pending tasks
final pendingTasksProvider = StreamProvider<List<TaskModel>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.watchTasksByStatus(TaskStatus.pending);
});

/// Provider for completed tasks
final completedTasksProvider = StreamProvider<List<TaskModel>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.watchTasksByStatus(TaskStatus.completed);
});

/// Provider for today's tasks (reactive - updates when tasks change)
final todayTasksProvider = StreamProvider.autoDispose<List<TaskModel>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  
  // Use repository stream and filter client-side for reactivity
  // This ensures cache is used for individual queries but stream stays reactive
  return repository.watchAllTasks().map((allTasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return allTasks.where((task) {
      if (task.dueDate == null) return false;
      
      final taskDay = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
      return taskDay.isAtSameMomentAs(today);
    }).toList();
  });
});

/// Provider for tasks created today (for better user feedback)
final tasksCreatedTodayProvider = StreamProvider<List<TaskModel>>((ref) {
  final allTasksStream = ref.watch(tasksProvider.stream);
  
  return allTasksStream.asyncMap((allTasks) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return allTasks.where((task) {
      return task.createdAt.isAfter(startOfDay.subtract(const Duration(milliseconds: 1))) && 
             task.createdAt.isBefore(endOfDay);
    }).toList();
  });
});

/// Provider for overdue tasks (reactive - updates when tasks change)
final overdueTasksProvider = StreamProvider.autoDispose<List<TaskModel>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  
  // Use repository stream and filter for overdue tasks
  return repository.watchAllTasks().map((allTasks) {
    final now = DateTime.now();
    
    return allTasks.where((task) {
      if (task.dueDate == null || task.status == TaskStatus.completed) return false;
      return task.dueDate!.isBefore(now);
    }).toList();
  });
});

/// Provider for task filter state
final taskFilterProvider = StateProvider.autoDispose<TaskFilter>((ref) {
  return const TaskFilter();
});

/// Provider for filtered tasks
final filteredTasksProvider = FutureProvider.autoDispose<List<TaskModel>>((ref) async {
  final repository = ref.watch(taskRepositoryProvider);
  final filter = ref.watch(taskFilterProvider);
  
  if (!filter.hasFilters) {
    return repository.getAllTasks();
  }
  
  return repository.getTasksWithFilter(filter);
});

/// Provider for search query
final searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

/// Provider for searched tasks
final searchedTasksProvider = FutureProvider.autoDispose<List<TaskModel>>((ref) async {
  final repository = ref.watch(taskRepositoryProvider);
  final query = ref.watch(searchQueryProvider);
  
  if (query.isEmpty) {
    return repository.getAllTasks();
  }
  
  return repository.searchTasks(query);
});

// TaskOperations provider moved to task_provider.dart to avoid conflicts

/// Widget service provider
final widgetServiceProvider = Provider<WidgetService>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  final widgetService = WidgetService();
  widgetService.setTaskRepository(repository);
  return widgetService;
});

/// Pagination configuration
class PaginationConfig {
  final int page;
  final int pageSize;
  
  const PaginationConfig({
    this.page = 0,
    this.pageSize = 20,
  });
  
  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is PaginationConfig &&
    runtimeType == other.runtimeType &&
    page == other.page &&
    pageSize == other.pageSize;
  
  @override
  int get hashCode => page.hashCode ^ pageSize.hashCode;
}

/// Paginated task result
class PaginatedTaskResult {
  final List<TaskModel> tasks;
  final int totalCount;
  final bool hasMore;
  
  const PaginatedTaskResult({
    required this.tasks,
    required this.totalCount,
    required this.hasMore,
  });
}

/// Provider for pagination configuration
final paginationConfigProvider = StateProvider.autoDispose<PaginationConfig>((ref) {
  return const PaginationConfig();
});

/// Optimized provider for paginated filtered tasks
final paginatedFilteredTasksProvider = FutureProvider.autoDispose.family<PaginatedTaskResult, TaskFilter>((ref, filter) async {
  final repository = ref.watch(taskRepositoryProvider);
  final config = ref.watch(paginationConfigProvider);
  
  // Get filtered tasks (already optimized with database-level filtering)
  final allFilteredTasks = await repository.getTasksWithFilter(filter);
  
  // Calculate pagination
  final startIndex = config.page * config.pageSize;
  final endIndex = (startIndex + config.pageSize).clamp(0, allFilteredTasks.length);
  
  final paginatedTasks = startIndex < allFilteredTasks.length
    ? allFilteredTasks.sublist(startIndex, endIndex)
    : <TaskModel>[];
  
  return PaginatedTaskResult(
    tasks: paginatedTasks,
    totalCount: allFilteredTasks.length,
    hasMore: endIndex < allFilteredTasks.length,
  );
});

/// Standardized task list state using AsyncValue pattern
class TaskListState {
  final AsyncValue<List<TaskModel>> tasks;
  final bool hasMore;
  final TaskFilter? currentFilter;
  
  const TaskListState({
    required this.tasks,
    this.hasMore = true,
    this.currentFilter,
  });
  
  TaskListState copyWith({
    AsyncValue<List<TaskModel>>? tasks,
    bool? hasMore,
    TaskFilter? currentFilter,
  }) {
    return TaskListState(
      tasks: tasks ?? this.tasks,
      hasMore: hasMore ?? this.hasMore,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }

  // Convenience getters for consistent access patterns
  bool get isLoading => tasks.isLoading;
  bool get hasError => tasks.hasError;
  Object? get error => tasks.error;
  List<TaskModel> get data => tasks.valueOrNull ?? [];
}

/// Notifier for infinite scroll task loading
class TaskListNotifier extends StateNotifier<TaskListState> {
  final TaskRepository _repository;
  final Ref _ref;
  int _currentPage = 0;
  static const int _pageSize = 20;
  
  TaskListNotifier(this._repository, this._ref) : super(const TaskListState(tasks: AsyncValue.loading()));
  
  /// Load initial tasks with filter
  Future<void> loadTasks(TaskFilter filter) async {
    if (state.isLoading) return;
    
    state = state.copyWith(
      tasks: const AsyncValue.loading(),
      currentFilter: filter,
    );
    _currentPage = 0;
    
    try {
      final tasks = await _repository.getTasksWithFilter(filter);
      final paginatedTasks = tasks.take(_pageSize).toList();
      
      state = TaskListState(
        tasks: AsyncValue.data(paginatedTasks),
        hasMore: tasks.length > _pageSize,
        currentFilter: filter,
      );
    } catch (e, stackTrace) {
      state = state.copyWith(
        tasks: AsyncValue.error(e, stackTrace),
      );
      
      // Report to global error state
      _ref.reportError(
        e,
        code: 'task_list_load_failed',
        severity: ErrorSeverity.error,
        context: {'operation': 'loadTasks', 'filter': filter.toString()},
        stackTrace: stackTrace,
      );
    }
  }
  
  /// Load more tasks for infinite scroll
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore || state.currentFilter == null) return;
    
    // For loading more, we keep existing data and just indicate loading state
    _currentPage++;
    
    try {
      final allTasks = await _repository.getTasksWithFilter(state.currentFilter!);
      final startIndex = _currentPage * _pageSize;
      final endIndex = (startIndex + _pageSize).clamp(0, allTasks.length);
      
      if (startIndex < allTasks.length) {
        final newTasks = allTasks.sublist(startIndex, endIndex);
        final currentTasks = state.data;
        
        state = state.copyWith(
          tasks: AsyncValue.data([...currentTasks, ...newTasks]),
          hasMore: endIndex < allTasks.length,
        );
      } else {
        state = state.copyWith(hasMore: false);
      }
    } catch (e, stackTrace) {
      // For load more errors, we keep existing data
      _ref.reportError(
        e,
        code: 'task_list_load_more_failed',
        severity: ErrorSeverity.warning, // Less severe since we have existing data
        context: {'operation': 'loadMore'},
        stackTrace: stackTrace,
      );
    }
  }
  
  /// Refresh the current task list
  Future<void> refresh() async {
    if (state.currentFilter != null) {
      await loadTasks(state.currentFilter!);
    }
  }
}

/// Provider for infinite scroll task list
final taskListProvider = StateNotifierProvider.autoDispose<TaskListNotifier, TaskListState>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return TaskListNotifier(repository, ref);
});

/// Provider for recurring task service
final recurringTaskServiceProvider = Provider((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  final database = ref.watch(databaseProvider);
  return RecurringTaskService(repository, database);
});

/// Provider for transcription service
final transcriptionServiceProvider = FutureProvider((ref) async {
  final service = await TranscriptionServiceFactory.createService();
  return service;
});

/// Provider for transcription service info
final transcriptionServiceInfoProvider = FutureProvider((ref) async {
  return await TranscriptionServiceFactory.getServiceInfo();
});

/// State synchronization helper that ensures cache and live data consistency
class StateSynchronizationHelper {
  final TaskRepository _repository;
  final TaskCacheManager _cache;
  
  StateSynchronizationHelper(this._repository, this._cache);
  
  /// Ensures a cached list is up-to-date with latest data
  Future<List<TaskModel>> ensureListSync(String cacheKey, Future<List<TaskModel>> Function() fetcher) async {
    // Check if we have cached data
    final cached = _cache.getCachedTaskList(cacheKey);
    
    // Always return cached data if available for performance
    if (cached != null) {
      // Async verification - update cache if needed but don't block UI
      _verifyAndUpdateCache(cacheKey, fetcher);
      return cached;
    }
    
    // No cached data, fetch and cache
    final fresh = await fetcher();
    _cache.cacheTaskList(cacheKey, fresh);
    return fresh;
  }
  
  /// Verify cache in background and update if needed
  Future<void> _verifyAndUpdateCache(String cacheKey, Future<List<TaskModel>> Function() fetcher) async {
    try {
      final fresh = await fetcher();
      _cache.cacheTaskList(cacheKey, fresh);
    } catch (e) {
      // Silent failure for background updates
    }
  }
}

/// Provider for state synchronization helper
final stateSyncHelperProvider = Provider<StateSynchronizationHelper>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  final cache = ref.watch(cacheStatsProvider); // This gets us access to the cache
  
  // Note: In a real implementation, we'd need to access the cache manager directly
  // For now, this serves as a pattern for state synchronization
  throw UnimplementedError('StateSynchronizationHelper needs direct cache access');
});

// TaskOperations class moved to task_provider.dart to avoid conflicts
// The consolidated class includes both dependency management and bulk operations
