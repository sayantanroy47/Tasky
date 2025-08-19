import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/performance_service.dart';
import '../../core/monitoring/app_analytics.dart';

/// Performance service provider
final performanceServiceProvider = Provider<PerformanceService>((ref) {
  return PerformanceService();
});

/// Performance snapshot provider with auto-refresh
final performanceSnapshotProvider = StreamProvider<PerformanceSnapshot>((ref) {
  final service = ref.read(performanceServiceProvider);
  
  return Stream.periodic(const Duration(seconds: 5), (_) {
    return service.getSnapshot();
  });
});

/// Performance statistics provider
final performanceStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.read(performanceServiceProvider);
  return service.getPerformanceStats();
});

/// Analytics summary provider
final analyticsSummaryProvider = Provider<AnalyticsSummary>((ref) {
  return AppAnalytics.instance.getAnalyticsSummary();
});

/// Memory stats provider
final memoryStatsProvider = Provider<Map<String, dynamic>>((ref) {
  return MemoryManager.getMemoryStats();
});

/// Frame rate monitoring provider
final frameRateProvider = StateNotifierProvider<FrameRateNotifier, FrameRateState>((ref) {
  final service = ref.read(performanceServiceProvider);
  return FrameRateNotifier(service);
});

/// Timer provider for performance timers
final performanceTimerProvider = StateNotifierProvider<PerformanceTimerNotifier, Map<String, DateTime>>((ref) {
  final service = ref.read(performanceServiceProvider);
  return PerformanceTimerNotifier(service);
});

/// Performance metrics notifier for real-time metrics
final performanceMetricsProvider = StateNotifierProvider<PerformanceMetricsNotifier, PerformanceMetricsState>((ref) {
  final service = ref.read(performanceServiceProvider);
  return PerformanceMetricsNotifier(service);
});

/// Frame rate state
class FrameRateState {
  final double currentFps;
  final double averageFps;
  final List<double> recentFrames;
  final bool isMonitoring;

  const FrameRateState({
    this.currentFps = 60.0,
    this.averageFps = 60.0,
    this.recentFrames = const [],
    this.isMonitoring = false,
  });

  FrameRateState copyWith({
    double? currentFps,
    double? averageFps,
    List<double>? recentFrames,
    bool? isMonitoring,
  }) {
    return FrameRateState(
      currentFps: currentFps ?? this.currentFps,
      averageFps: averageFps ?? this.averageFps,
      recentFrames: recentFrames ?? this.recentFrames,
      isMonitoring: isMonitoring ?? this.isMonitoring,
    );
  }
}

/// Frame rate monitoring notifier
class FrameRateNotifier extends StateNotifier<FrameRateState> {
  final PerformanceService _service;
  
  FrameRateNotifier(this._service) : super(const FrameRateState());

  /// Start frame rate monitoring
  void startMonitoring() {
    if (state.isMonitoring) return;
    
    state = state.copyWith(isMonitoring: true);
    _service.markFrameStart();
  }

  /// Stop frame rate monitoring
  void stopMonitoring() {
    if (!state.isMonitoring) return;
    
    _service.markFrameEnd();
    state = state.copyWith(isMonitoring: false);
  }

  /// Update frame rate data
  void updateFrameRate(double fps) {
    final recentFrames = [...state.recentFrames, fps];
    if (recentFrames.length > 60) {
      recentFrames.removeAt(0);
    }
    
    final averageFps = recentFrames.isNotEmpty 
      ? recentFrames.reduce((a, b) => a + b) / recentFrames.length
      : 60.0;

    state = state.copyWith(
      currentFps: fps,
      averageFps: averageFps,
      recentFrames: recentFrames,
    );
  }
}

/// Performance timer notifier
class PerformanceTimerNotifier extends StateNotifier<Map<String, DateTime>> {
  final PerformanceService _service;
  
  PerformanceTimerNotifier(this._service) : super({});

  /// Start a timer
  void startTimer(String name) {
    _service.startTimer(name);
    state = {...state, name: DateTime.now()};
  }

  /// Stop a timer
  double? stopTimer(String name) {
    final elapsed = _service.stopTimer(name);
    final newState = Map<String, DateTime>.from(state);
    newState.remove(name);
    state = newState;
    return elapsed;
  }

  /// Get active timers
  List<String> getActiveTimers() {
    return state.keys.toList();
  }
}

/// Performance metrics state
class PerformanceMetricsState {
  final Map<String, double> currentMetrics;
  final Map<String, List<double>> metricHistory;
  final DateTime lastUpdated;

  const PerformanceMetricsState({
    this.currentMetrics = const {},
    this.metricHistory = const {},
    required this.lastUpdated,
  });

  PerformanceMetricsState copyWith({
    Map<String, double>? currentMetrics,
    Map<String, List<double>>? metricHistory,
    DateTime? lastUpdated,
  }) {
    return PerformanceMetricsState(
      currentMetrics: currentMetrics ?? this.currentMetrics,
      metricHistory: metricHistory ?? this.metricHistory,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Performance metrics notifier
class PerformanceMetricsNotifier extends StateNotifier<PerformanceMetricsState> {
  final PerformanceService _service;
  
  PerformanceMetricsNotifier(this._service) 
    : super(PerformanceMetricsState(lastUpdated: DateTime.now()));

  /// Record a metric
  void recordMetric(String name, double value, {String? unit, Map<String, dynamic>? attributes}) {
    _service.recordMetric(name, value, unit: unit, attributes: attributes);
    
    // Update state
    final newMetrics = {...state.currentMetrics, name: value};
    final newHistory = Map<String, List<double>>.from(state.metricHistory);
    newHistory.putIfAbsent(name, () => []).add(value);
    
    // Keep only recent history
    if (newHistory[name]!.length > 100) {
      newHistory[name]!.removeAt(0);
    }
    
    state = state.copyWith(
      currentMetrics: newMetrics,
      metricHistory: newHistory,
      lastUpdated: DateTime.now(),
    );
  }

  /// Get metric statistics
  Map<String, double>? getMetricStats(String name) {
    final history = state.metricHistory[name];
    if (history == null || history.isEmpty) return null;
    
    final sorted = [...history]..sort();
    final avg = history.reduce((a, b) => a + b) / history.length;
    
    return {
      'min': sorted.first,
      'max': sorted.last,
      'average': avg,
      'median': sorted[sorted.length ~/ 2],
      'latest': history.last,
      'count': history.length.toDouble(),
    };
  }

  /// Refresh metrics from service
  void refresh() {
    final stats = _service.getPerformanceStats();
    final metrics = stats['performance_metrics'] as Map<String, Map<String, double>>? ?? {};
    
    final currentMetrics = <String, double>{};
    for (final entry in metrics.entries) {
      currentMetrics[entry.key] = entry.value['average'] ?? 0.0;
    }
    
    state = state.copyWith(
      currentMetrics: currentMetrics,
      lastUpdated: DateTime.now(),
    );
  }
}

/// Database operation tracking provider
final databasePerformanceProvider = Provider<DatabasePerformanceTracker>((ref) {
  final service = ref.read(performanceServiceProvider);
  return DatabasePerformanceTracker(service);
});

/// Database performance tracker
class DatabasePerformanceTracker {
  final PerformanceService _service;
  
  DatabasePerformanceTracker(this._service);
  
  /// Track a database operation
  T trackOperation<T>(String operation, T Function() fn) {
    _service.startTimer('db_$operation');
    try {
      final result = fn();
      final elapsed = _service.stopTimer('db_$operation');
      _service.recordDatabaseOperation(operation, Duration(milliseconds: elapsed?.toInt() ?? 0));
      return result;
    } catch (e) {
      final elapsed = _service.stopTimer('db_$operation');
      _service.recordDatabaseOperation(operation, Duration(milliseconds: elapsed?.toInt() ?? 0), success: false);
      rethrow;
    }
  }

  /// Track an async database operation
  Future<T> trackAsyncOperation<T>(String operation, Future<T> Function() fn) async {
    _service.startTimer('db_$operation');
    try {
      final result = await fn();
      final elapsed = _service.stopTimer('db_$operation');
      _service.recordDatabaseOperation(operation, Duration(milliseconds: elapsed?.toInt() ?? 0));
      return result;
    } catch (e) {
      final elapsed = _service.stopTimer('db_$operation');
      _service.recordDatabaseOperation(operation, Duration(milliseconds: elapsed?.toInt() ?? 0), success: false);
      rethrow;
    }
  }
}