import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../core/monitoring/app_analytics.dart';

/// Comprehensive performance monitoring service
class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  final Map<String, DateTime> _timers = {};
  final Map<String, List<double>> _frameTimings = {};
  DateTime? _appStartTime;
  bool _initialized = false;

  /// Initialize the performance service
  Future<void> initialize() async {
    if (_initialized) return;
    
    _appStartTime = DateTime.now();
    await AppAnalytics.instance.initialize();
    _initialized = true;
    
    // Track app initialization
    AppAnalytics.instance.trackEvent('performance_service_initialized');
  }

  /// Record app startup time
  void recordStartupTime(Duration duration) {
    AppAnalytics.instance.trackPerformance(
      'app_start_time',
      duration.inMilliseconds.toDouble(),
      unit: 'milliseconds',
      attributes: {
        'platform': Platform.operatingSystem,
        'is_debug': kDebugMode,
      },
    );
  }

  /// Record a general performance metric
  void recordMetric(String name, double value, {String? unit, Map<String, dynamic>? attributes}) {
    AppAnalytics.instance.trackPerformance(
      name,
      value,
      unit: unit,
      attributes: attributes,
    );
  }

  /// Mark the start of a frame for frame rate monitoring
  void markFrameStart() {
    startTimer('frame_render');
  }

  /// Mark the end of a frame for frame rate monitoring
  void markFrameEnd() {
    final renderTime = stopTimer('frame_render');
    if (renderTime != null) {
      _frameTimings.putIfAbsent('frame_render', () => []).add(renderTime);
      
      // Keep only recent timings to avoid memory issues
      final timings = _frameTimings['frame_render']!;
      if (timings.length > 100) {
        timings.removeAt(0);
      }
      
      // Calculate average frame rate from recent frames
      if (timings.length >= 10) {
        final avgRenderTime = timings.reduce((a, b) => a + b) / timings.length;
        final fps = avgRenderTime > 0 ? 1000 / avgRenderTime : 60.0;
        
        recordMetric('frame_rate', fps, unit: 'fps');
      }
    }
  }

  /// Start a named timer
  void startTimer(String name) {
    _timers[name] = DateTime.now();
  }

  /// Stop a named timer and return elapsed milliseconds
  double? stopTimer(String name) {
    final startTime = _timers.remove(name);
    if (startTime != null) {
      final elapsed = DateTime.now().difference(startTime).inMilliseconds.toDouble();
      recordMetric('timer_$name', elapsed, unit: 'milliseconds');
      return elapsed;
    }
    return null;
  }

  /// Record memory usage
  void recordMemoryUsage() {
    // In a real app, you'd use dart:developer or platform channels
    // For now, we'll simulate memory tracking
    recordMetric('memory_usage', 0, unit: 'bytes', attributes: {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Record database operation performance
  void recordDatabaseOperation(String operation, Duration duration, {bool success = true}) {
    recordMetric(
      'database_$operation',
      duration.inMilliseconds.toDouble(),
      unit: 'milliseconds',
      attributes: {
        'operation': operation,
        'success': success,
      },
    );
  }

  /// Record UI operation performance
  void recordUIOperation(String operation, Duration duration) {
    recordMetric(
      'ui_$operation',
      duration.inMilliseconds.toDouble(),
      unit: 'milliseconds',
      attributes: {
        'operation': operation,
      },
    );
  }

  /// Get current performance statistics
  Map<String, dynamic> getPerformanceStats() {
    final summary = AppAnalytics.instance.getAnalyticsSummary();
    final perfStats = summary.performanceStats;
    
    return {
      'app_uptime': _appStartTime != null 
        ? DateTime.now().difference(_appStartTime!).inMilliseconds 
        : 0,
      'total_events': summary.totalEvents,
      'session_id': summary.sessionId,
      'performance_metrics': perfStats.map((key, stats) => MapEntry(key, {
        'average': stats.average,
        'min': stats.min,
        'max': stats.max,
        'median': stats.median,
        'sample_count': stats.sampleCount,
      })),
      'frame_timings': _frameTimings,
    };
  }

  /// Get specific metrics by name
  Map<String, dynamic> getMetrics() {
    final summary = AppAnalytics.instance.getAnalyticsSummary();
    return {
      'events_by_type': summary.eventsByType,
      'user_properties': summary.userProperties,
      'performance_metrics': summary.performanceMetrics,
    };
  }

  /// Get real-time performance data
  PerformanceSnapshot getSnapshot() {
    final stats = getPerformanceStats();
    return PerformanceSnapshot(
      timestamp: DateTime.now(),
      appUptime: Duration(milliseconds: stats['app_uptime'] as int),
      eventCount: stats['total_events'] as int,
      sessionId: stats['session_id'] as String,
      performanceMetrics: Map<String, Map<String, double>>.from(
        stats['performance_metrics'] as Map? ?? {},
      ),
    );
  }

  /// Dispose the service
  Future<void> dispose() async {
    await AppAnalytics.instance.dispose();
    _timers.clear();
    _frameTimings.clear();
    _initialized = false;
  }
}

/// Performance snapshot data class
class PerformanceSnapshot {
  final DateTime timestamp;
  final Duration appUptime;
  final int eventCount;
  final String sessionId;
  final Map<String, Map<String, double>> performanceMetrics;

  const PerformanceSnapshot({
    required this.timestamp,
    required this.appUptime,
    required this.eventCount,
    required this.sessionId,
    required this.performanceMetrics,
  });

  /// Get metric value by name and statistic type
  double? getMetric(String metricName, String statType) {
    return performanceMetrics[metricName]?[statType];
  }

  /// Get all metrics for a specific metric name
  Map<String, double>? getMetricStats(String metricName) {
    return performanceMetrics[metricName];
  }

  /// Check if a metric exists
  bool hasMetric(String metricName) {
    return performanceMetrics.containsKey(metricName);
  }
}

/// Enhanced memory manager with performance tracking
class MemoryManager {
  static final PerformanceService _perfService = PerformanceService();

  /// Optimize memory and track performance
  static void optimizeMemory() {
    _perfService.startTimer('memory_optimization');
    
    // In a real implementation, you'd:
    // 1. Clear image caches
    // 2. Dispose unused resources
    // 3. Trigger garbage collection if needed
    
    _perfService.stopTimer('memory_optimization');
    _perfService.recordMemoryUsage();
  }

  /// Force garbage collection with tracking
  static void collectGarbage() {
    _perfService.startTimer('garbage_collection');
    
    // In a real implementation, you'd trigger GC
    // This is platform-specific and might use dart:developer
    
    _perfService.stopTimer('garbage_collection');
  }

  /// Get current memory stats
  static Map<String, dynamic> getMemoryStats() {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'platform': Platform.operatingSystem,
      // In a real app, you'd get actual memory usage
      'estimated_usage': 'N/A - Would require platform channels',
    };
  }
}