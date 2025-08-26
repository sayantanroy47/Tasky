import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';

/// Performance optimizer for Kanban board operations
/// 
/// Provides:
/// - Task virtualization for large lists
/// - Lazy loading with pagination
/// - Efficient filtering and sorting
/// - Memory management
/// - Background processing for heavy operations
class KanbanPerformanceOptimizer {
  static const int _itemsPerPage = 20;
  static const int _maxCachedItems = 200;
  static const Duration _cacheExpiration = Duration(minutes: 5);

  final Map<String, _CachedTaskList> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  /// Optimized task filtering with caching
  List<TaskModel> filterTasks(
    List<TaskModel> tasks, {
    String searchQuery = '',
    TaskPriority? priority,
    List<String> tags = const [],
    TaskStatus? status,
    DateTime? dueDateFrom,
    DateTime? dueDateTo,
  }) {
    final cacheKey = _generateFilterCacheKey(
      searchQuery, priority, tags, status, dueDateFrom, dueDateTo
    );

    // Check cache
    final cached = _getCachedResult(cacheKey);
    if (cached != null) {
      return cached.tasks;
    }

    // Apply filters efficiently
    final filteredTasks = _applyFilters(
      tasks,
      searchQuery: searchQuery,
      priority: priority,
      tags: tags,
      status: status,
      dueDateFrom: dueDateFrom,
      dueDateTo: dueDateTo,
    );

    // Cache result
    _cacheResult(cacheKey, filteredTasks);

    return filteredTasks;
  }

  /// Virtualized task list for large datasets
  Widget buildVirtualizedTaskList({
    required List<TaskModel> tasks,
    required Widget Function(TaskModel task, int index) itemBuilder,
    required ScrollController scrollController,
    int itemsPerPage = _itemsPerPage,
    VoidCallback? onLoadMore,
  }) {
    return _VirtualizedTaskList(
      tasks: tasks,
      itemBuilder: itemBuilder,
      scrollController: scrollController,
      itemsPerPage: itemsPerPage,
      onLoadMore: onLoadMore,
    );
  }

  /// Background task processing
  Future<List<TaskModel>> processTasksInBackground(
    List<TaskModel> tasks,
    Future<TaskModel> Function(TaskModel) processor,
  ) async {
    return compute(_processTasksBatch, _TaskProcessingParams(tasks, processor));
  }

  /// Memory cleanup
  void cleanup() {
    final now = DateTime.now();
    final keysToRemove = <String>[];

    for (final entry in _cacheTimestamps.entries) {
      if (now.difference(entry.value) > _cacheExpiration) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
    }

    // Limit cache size
    if (_cache.length > _maxCachedItems) {
      final sortedEntries = _cacheTimestamps.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));

      final itemsToRemove = sortedEntries.length - _maxCachedItems;
      for (int i = 0; i < itemsToRemove; i++) {
        final key = sortedEntries[i].key;
        _cache.remove(key);
        _cacheTimestamps.remove(key);
      }
    }
  }

  // Private methods

  List<TaskModel> _applyFilters(
    List<TaskModel> tasks, {
    String searchQuery = '',
    TaskPriority? priority,
    List<String> tags = const [],
    TaskStatus? status,
    DateTime? dueDateFrom,
    DateTime? dueDateTo,
  }) {
    return tasks.where((task) {
      // Search filter (most expensive, apply last)
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchesTitle = task.title.toLowerCase().contains(query);
        final matchesDescription = task.description?.toLowerCase().contains(query) ?? false;
        if (!matchesTitle && !matchesDescription) return false;
      }

      // Status filter (cheapest, apply first)
      if (status != null && task.status != status) return false;

      // Priority filter
      if (priority != null && task.priority != priority) return false;

      // Tags filter
      if (tags.isNotEmpty && !tags.any((tag) => task.tags.contains(tag))) {
        return false;
      }

      // Date filters
      if (dueDateFrom != null && task.dueDate != null) {
        if (task.dueDate!.isBefore(dueDateFrom)) return false;
      }

      if (dueDateTo != null && task.dueDate != null) {
        if (task.dueDate!.isAfter(dueDateTo)) return false;
      }

      return true;
    }).toList();
  }

  String _generateFilterCacheKey(
    String searchQuery,
    TaskPriority? priority,
    List<String> tags,
    TaskStatus? status,
    DateTime? dueDateFrom,
    DateTime? dueDateTo,
  ) {
    return [
      searchQuery,
      priority?.name ?? '',
      tags.join(','),
      status?.name ?? '',
      dueDateFrom?.millisecondsSinceEpoch.toString() ?? '',
      dueDateTo?.millisecondsSinceEpoch.toString() ?? '',
    ].join('|');
  }

  _CachedTaskList? _getCachedResult(String key) {
    final cached = _cache[key];
    final timestamp = _cacheTimestamps[key];

    if (cached != null && timestamp != null) {
      if (DateTime.now().difference(timestamp) < _cacheExpiration) {
        return cached;
      } else {
        _cache.remove(key);
        _cacheTimestamps.remove(key);
      }
    }

    return null;
  }

  void _cacheResult(String key, List<TaskModel> tasks) {
    _cache[key] = _CachedTaskList(tasks);
    _cacheTimestamps[key] = DateTime.now();
  }
}

/// Virtualized task list widget for performance
class _VirtualizedTaskList extends StatefulWidget {
  final List<TaskModel> tasks;
  final Widget Function(TaskModel task, int index) itemBuilder;
  final ScrollController scrollController;
  final int itemsPerPage;
  final VoidCallback? onLoadMore;

  const _VirtualizedTaskList({
    required this.tasks,
    required this.itemBuilder,
    required this.scrollController,
    required this.itemsPerPage,
    this.onLoadMore,
  });

  @override
  State<_VirtualizedTaskList> createState() => _VirtualizedTaskListState();
}

class _VirtualizedTaskListState extends State<_VirtualizedTaskList> {
  int _loadedItems = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadedItems = widget.itemsPerPage.clamp(0, widget.tasks.length);
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (widget.scrollController.position.pixels >=
        widget.scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _loadMore() {
    if (_isLoading || _loadedItems >= widget.tasks.length) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate async loading
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _loadedItems = (_loadedItems + widget.itemsPerPage)
              .clamp(0, widget.tasks.length);
          _isLoading = false;
        });

        widget.onLoadMore?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleTasks = widget.tasks.take(_loadedItems).toList();

    return ListView.builder(
      controller: widget.scrollController,
      itemCount: visibleTasks.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= visibleTasks.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        return widget.itemBuilder(visibleTasks[index], index);
      },
    );
  }
}

/// Optimized drag and drop system
class OptimizedDragAndDrop {
  static const Duration _animationDuration = Duration(milliseconds: 200);
  static const double _dragThreshold = 10.0;

  /// Creates an optimized draggable widget
  static Widget createDraggable<T extends Object>({
    required T data,
    required Widget child,
    required Widget Function(T data) feedbackBuilder,
    VoidCallback? onDragStarted,
    VoidCallback? onDragEnd,
  }) {
    return _OptimizedDraggable<T>(
      data: data,
      feedbackBuilder: feedbackBuilder,
      onDragStarted: onDragStarted,
      onDragEnd: onDragEnd,
      child: child,
    );
  }

  /// Creates an optimized drag target
  static Widget createDragTarget<T extends Object>({
    required Widget child,
    required bool Function(T? data) onWillAccept,
    required void Function(T data) onAccept,
    VoidCallback? onLeave,
  }) {
    return _OptimizedDragTarget<T>(
      onWillAccept: onWillAccept,
      onAccept: onAccept,
      onLeave: onLeave,
      child: child,
    );
  }
}

class _OptimizedDraggable<T extends Object> extends StatefulWidget {
  final T data;
  final Widget child;
  final Widget Function(T data) feedbackBuilder;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnd;

  const _OptimizedDraggable({
    required this.data,
    required this.child,
    required this.feedbackBuilder,
    this.onDragStarted,
    this.onDragEnd,
  });

  @override
  State<_OptimizedDraggable<T>> createState() => _OptimizedDraggableState<T>();
}

class _OptimizedDraggableState<T extends Object> extends State<_OptimizedDraggable<T>> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<T>(
      data: widget.data,
      feedback: widget.feedbackBuilder(widget.data),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: widget.child,
      ),
      onDragStarted: () {
        setState(() {
          _isDragging = true;
        });
        widget.onDragStarted?.call();
      },
      onDragEnd: (_) {
        setState(() {
          _isDragging = false;
        });
        widget.onDragEnd?.call();
      },
      child: AnimatedContainer(
        duration: OptimizedDragAndDrop._animationDuration,
        curve: Curves.easeInOut,
        transform: Matrix4.identity().scaled(_isDragging ? 1.05 : 1.0),
        child: widget.child,
      ),
    );
  }
}

class _OptimizedDragTarget<T extends Object> extends StatefulWidget {
  final Widget child;
  final bool Function(T? data) onWillAccept;
  final void Function(T data) onAccept;
  final VoidCallback? onLeave;

  const _OptimizedDragTarget({
    required this.child,
    required this.onWillAccept,
    required this.onAccept,
    this.onLeave,
  });

  @override
  State<_OptimizedDragTarget<T>> createState() => _OptimizedDragTargetState<T>();
}

class _OptimizedDragTargetState<T extends Object> extends State<_OptimizedDragTarget<T>> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return DragTarget<T>(
      onWillAcceptWithDetails: (details) => widget.onWillAccept(details.data),
      onAcceptWithDetails: (details) => widget.onAccept(details.data),
      onMove: (_) {
        if (!_isHovering) {
          setState(() {
            _isHovering = true;
          });
        }
      },
      onLeave: (_) {
        setState(() {
          _isHovering = false;
        });
        widget.onLeave?.call();
      },
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: OptimizedDragAndDrop._animationDuration,
          curve: Curves.easeInOut,
          transform: Matrix4.identity().scaled(_isHovering ? 1.02 : 1.0),
          child: widget.child,
        );
      },
    );
  }
}

/// Memory-efficient task list management
class TaskListManager {
  final Map<String, List<TaskModel>> _taskLists = {};
  final Map<String, DateTime> _lastAccessed = {};
  static const int _maxListsInMemory = 10;
  static const Duration _accessTimeout = Duration(minutes: 10);

  /// Get or create a task list with automatic cleanup
  List<TaskModel> getTaskList(String key, List<TaskModel> Function() creator) {
    _lastAccessed[key] = DateTime.now();
    
    if (_taskLists.containsKey(key)) {
      return _taskLists[key]!;
    }

    final taskList = creator();
    _taskLists[key] = taskList;
    
    _cleanup();
    return taskList;
  }

  /// Update a task list
  void updateTaskList(String key, List<TaskModel> tasks) {
    _taskLists[key] = tasks;
    _lastAccessed[key] = DateTime.now();
  }

  /// Remove a task list
  void removeTaskList(String key) {
    _taskLists.remove(key);
    _lastAccessed.remove(key);
  }

  /// Manual cleanup
  void cleanup() {
    _cleanup();
  }

  void _cleanup() {
    final now = DateTime.now();
    final keysToRemove = <String>[];

    // Remove expired lists
    for (final entry in _lastAccessed.entries) {
      if (now.difference(entry.value) > _accessTimeout) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      _taskLists.remove(key);
      _lastAccessed.remove(key);
    }

    // Limit memory usage
    if (_taskLists.length > _maxListsInMemory) {
      final sortedEntries = _lastAccessed.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));

      final itemsToRemove = _taskLists.length - _maxListsInMemory;
      for (int i = 0; i < itemsToRemove; i++) {
        final key = sortedEntries[i].key;
        _taskLists.remove(key);
        _lastAccessed.remove(key);
      }
    }
  }
}

/// Performance monitoring for Kanban operations
class KanbanPerformanceMonitor {
  final Map<String, List<int>> _operationTimes = {};
  static const int _maxSamples = 100;

  /// Record an operation time
  void recordOperation(String operationName, int durationMs) {
    _operationTimes.putIfAbsent(operationName, () => <int>[]);
    
    final times = _operationTimes[operationName]!;
    times.add(durationMs);
    
    // Keep only recent samples
    if (times.length > _maxSamples) {
      times.removeAt(0);
    }
  }

  /// Get performance statistics
  PerformanceStats getStats(String operationName) {
    final times = _operationTimes[operationName] ?? [];
    
    if (times.isEmpty) {
      return const PerformanceStats();
    }

    final sortedTimes = List<int>.from(times)..sort();
    
    return PerformanceStats(
      samples: times.length,
      averageMs: times.reduce((a, b) => a + b) / times.length,
      medianMs: sortedTimes[sortedTimes.length ~/ 2].toDouble(),
      p95Ms: sortedTimes[(sortedTimes.length * 0.95).floor().clamp(0, sortedTimes.length - 1)].toDouble(),
      minMs: sortedTimes.first.toDouble(),
      maxMs: sortedTimes.last.toDouble(),
    );
  }

  /// Get all performance statistics
  Map<String, PerformanceStats> getAllStats() {
    return Map.fromEntries(
      _operationTimes.keys.map((key) => MapEntry(key, getStats(key)))
    );
  }
}

/// Performance statistics
class PerformanceStats {
  final int samples;
  final double averageMs;
  final double medianMs;
  final double p95Ms;
  final double minMs;
  final double maxMs;

  const PerformanceStats({
    this.samples = 0,
    this.averageMs = 0.0,
    this.medianMs = 0.0,
    this.p95Ms = 0.0,
    this.minMs = 0.0,
    this.maxMs = 0.0,
  });

  @override
  String toString() {
    return 'PerformanceStats(samples: $samples, avg: ${averageMs.toStringAsFixed(1)}ms, '
           'median: ${medianMs.toStringAsFixed(1)}ms, p95: ${p95Ms.toStringAsFixed(1)}ms)';
  }
}

// Helper classes

class _CachedTaskList {
  final List<TaskModel> tasks;
  final DateTime timestamp;

  _CachedTaskList(this.tasks) : timestamp = DateTime.now();
}

class _TaskProcessingParams {
  final List<TaskModel> tasks;
  final Future<TaskModel> Function(TaskModel) processor;

  _TaskProcessingParams(this.tasks, this.processor);
}

// Background processing function
Future<List<TaskModel>> _processTasksBatch(_TaskProcessingParams params) async {
  final processedTasks = <TaskModel>[];
  
  for (final task in params.tasks) {
    try {
      final processed = await params.processor(task);
      processedTasks.add(processed);
    } catch (e) {
      // Skip failed tasks or add original task
      processedTasks.add(task);
    }
  }
  
  return processedTasks;
}

/// Global performance optimizer provider
final kanbanPerformanceOptimizerProvider = Provider<KanbanPerformanceOptimizer>((ref) {
  return KanbanPerformanceOptimizer();
});

/// Global task list manager provider
final taskListManagerProvider = Provider<TaskListManager>((ref) {
  return TaskListManager();
});

/// Global performance monitor provider
final kanbanPerformanceMonitorProvider = Provider<KanbanPerformanceMonitor>((ref) {
  return KanbanPerformanceMonitor();
});