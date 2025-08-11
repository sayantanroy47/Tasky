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
final todayTasksProvider = StreamProvider<List<TaskModel>>((ref) {
  final allTasksStream = ref.watch(tasksProvider.stream);
  
  return allTasksStream.asyncMap((allTasks) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    
    return allTasks.where((task) {
      if (task.dueDate == null) return false;
      
      // Only include tasks due today (not past or future days)
      final taskDate = task.dueDate!;
      final taskDay = DateTime(taskDate.year, taskDate.month, taskDate.day);
      final today = DateTime(now.year, now.month, now.day);
      
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

/// Provider for overdue tasks
final overdueTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getOverdueTasks();
});

/// Provider for task filter state
final taskFilterProvider = StateProvider<TaskFilter>((ref) {
  return const TaskFilter();
});

/// Provider for filtered tasks
final filteredTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final repository = ref.watch(taskRepositoryProvider);
  final filter = ref.watch(taskFilterProvider);
  
  if (!filter.hasFilters) {
    return repository.getAllTasks();
  }
  
  return repository.getTasksWithFilter(filter);
});

/// Provider for search query
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for searched tasks
final searchedTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
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
final paginationConfigProvider = StateProvider<PaginationConfig>((ref) {
  return const PaginationConfig();
});

/// Optimized provider for paginated filtered tasks
final paginatedFilteredTasksProvider = FutureProvider.family<PaginatedTaskResult, TaskFilter>((ref, filter) async {
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

/// Lazy loading provider for infinite scroll
class TaskListState {
  final List<TaskModel> tasks;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  
  const TaskListState({
    required this.tasks,
    this.isLoading = false,
    this.hasMore = true,
    this.error,
  });
  
  TaskListState copyWith({
    List<TaskModel>? tasks,
    bool? isLoading,
    bool? hasMore,
    String? error,
  }) {
    return TaskListState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
    );
  }
}

/// Notifier for infinite scroll task loading
class TaskListNotifier extends StateNotifier<TaskListState> {
  final TaskRepository _repository;
  TaskFilter? _currentFilter;
  int _currentPage = 0;
  static const int _pageSize = 20;
  
  TaskListNotifier(this._repository) : super(const TaskListState(tasks: []));
  
  /// Load initial tasks with filter
  Future<void> loadTasks(TaskFilter filter) async {
    if (state.isLoading) return;
    
    state = state.copyWith(isLoading: true, error: null);
    _currentFilter = filter;
    _currentPage = 0;
    
    try {
      final tasks = await _repository.getTasksWithFilter(filter);
      final paginatedTasks = tasks.take(_pageSize).toList();
      
      state = TaskListState(
        tasks: paginatedTasks,
        isLoading: false,
        hasMore: tasks.length > _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load tasks: ${e.toString()}',
      );
    }
  }
  
  /// Load more tasks for infinite scroll
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore || _currentFilter == null) return;
    
    state = state.copyWith(isLoading: true);
    _currentPage++;
    
    try {
      final allTasks = await _repository.getTasksWithFilter(_currentFilter!);
      final startIndex = _currentPage * _pageSize;
      final endIndex = (startIndex + _pageSize).clamp(0, allTasks.length);
      
      if (startIndex < allTasks.length) {
        final newTasks = allTasks.sublist(startIndex, endIndex);
        state = state.copyWith(
          tasks: [...state.tasks, ...newTasks],
          isLoading: false,
          hasMore: endIndex < allTasks.length,
        );
      } else {
        state = state.copyWith(isLoading: false, hasMore: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load more tasks: ${e.toString()}',
      );
    }
  }
  
  /// Refresh the current task list
  Future<void> refresh() async {
    if (_currentFilter != null) {
      await loadTasks(_currentFilter!);
    }
  }
}

/// Provider for infinite scroll task list
final taskListProvider = StateNotifierProvider<TaskListNotifier, TaskListState>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return TaskListNotifier(repository);
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

// TaskOperations class moved to task_provider.dart to avoid conflicts
// The consolidated class includes both dependency management and bulk operations
