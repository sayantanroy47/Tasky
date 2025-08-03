import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service for managing app performance optimization and monitoring
class PerformanceService {
  static const String _performanceMetricsKey = 'performance_metrics';
  static const String _performanceSettingsKey = 'performance_settings';
  
  final Map<String, Stopwatch> _timers = {};
  final List<PerformanceMetric> _metrics = [];
  final StreamController<PerformanceMetric> _metricsController = StreamController.broadcast();
  
  Timer? _memoryMonitorTimer;
  Timer? _metricsCleanupTimer;
  
  /// Stream of performance metrics
  Stream<PerformanceMetric> get metricsStream => _metricsController.stream;
  
  /// Initialize performance monitoring
  Future<void> initialize() async {
    await _loadPerformanceSettings();
    _startMemoryMonitoring();
    _startMetricsCleanup();
    
    // Optimize app startup
    await _optimizeStartup();
  }
  
  /// Start timing a performance operation
  void startTimer(String operation) {
    _timers[operation] = Stopwatch()..start();
  }
  
  /// Stop timing and record performance metric
  void stopTimer(String operation, {Map<String, dynamic>? metadata}) {
    final timer = _timers.remove(operation);
    if (timer != null) {
      timer.stop();
      final metric = PerformanceMetric(
        operation: operation,
        duration: timer.elapsed,
        timestamp: DateTime.now(),
        metadata: metadata ?? {},
      );
      
      _recordMetric(metric);
    }
  }
  
  /// Record a performance metric
  void recordMetric(String operation, Duration duration, {Map<String, dynamic>? metadata}) {
    final metric = PerformanceMetric(
      operation: operation,
      duration: duration,
      timestamp: DateTime.now(),
      metadata: metadata ?? {},
    );
    
    _recordMetric(metric);
  }
  
  /// Record memory usage metric
  void recordMemoryUsage() {
    if (kDebugMode) {
      final info = Isolate.current.debugName ?? 'main';
      // In production, we'd use platform-specific memory monitoring
      final metric = PerformanceMetric(
        operation: 'memory_usage',
        duration: Duration.zero,
        timestamp: DateTime.now(),
        metadata: {
          'isolate_id': info,
          'platform': Platform.operatingSystem,
        },
      );
      
      _recordMetric(metric);
    }
  }
  
  /// Get performance statistics
  Future<PerformanceStats> getPerformanceStats() async {
    final now = DateTime.now();
    final last24Hours = now.subtract(const Duration(hours: 24));
    
    final recentMetrics = _metrics.where((m) => m.timestamp.isAfter(last24Hours)).toList();
    
    final operationGroups = <String, List<PerformanceMetric>>{};
    for (final metric in recentMetrics) {
      operationGroups.putIfAbsent(metric.operation, () => []).add(metric);
    }
    
    final operationStats = <String, OperationStats>{};
    for (final entry in operationGroups.entries) {
      final durations = entry.value.map((m) => m.duration.inMilliseconds).toList();
      durations.sort();
      
      operationStats[entry.key] = OperationStats(
        operation: entry.key,
        count: durations.length,
        averageDuration: Duration(milliseconds: durations.isEmpty ? 0 : durations.reduce((a, b) => a + b) ~/ durations.length),
        minDuration: Duration(milliseconds: durations.isEmpty ? 0 : durations.first),
        maxDuration: Duration(milliseconds: durations.isEmpty ? 0 : durations.last),
        p95Duration: Duration(milliseconds: durations.isEmpty ? 0 : durations[(durations.length * 0.95).floor()]),
      );
    }
    
    return PerformanceStats(
      totalMetrics: recentMetrics.length,
      operationStats: operationStats,
      generatedAt: now,
    );
  }
  
  /// Optimize app startup performance
  Future<void> _optimizeStartup() async {
    startTimer('app_startup');
    
    // Preload critical resources
    await _preloadCriticalResources();
    
    // Initialize essential services only
    await _initializeEssentialServices();
    
    stopTimer('app_startup');
  }
  
  /// Preload critical resources for faster startup
  Future<void> _preloadCriticalResources() async {
    startTimer('preload_resources');
    
    try {
      // Preload SharedPreferences
      await SharedPreferences.getInstance();
      
      // Preload system fonts and assets
      await _preloadAssets();
      
      // Warm up platform channels
      await _warmupPlatformChannels();
      
    } catch (e) {
      developer.log('Error preloading resources: $e', name: 'PerformanceService');
    }
    
    stopTimer('preload_resources');
  }
  
  /// Initialize only essential services during startup
  Future<void> _initializeEssentialServices() async {
    startTimer('init_essential_services');
    
    try {
      // Initialize only critical services here
      // Non-critical services should be lazy-loaded
      
    } catch (e) {
      developer.log('Error initializing essential services: $e', name: 'PerformanceService');
    }
    
    stopTimer('init_essential_services');
  }
  
  /// Preload critical assets
  Future<void> _preloadAssets() async {
    // Preload commonly used images and icons
    // This would be implemented based on actual assets
  }
  
  /// Warm up platform channels
  Future<void> _warmupPlatformChannels() async {
    try {
      // Warm up commonly used platform channels
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } catch (e) {
      // Ignore warmup errors
    }
  }
  
  /// Start monitoring memory usage
  void _startMemoryMonitoring() {
    _memoryMonitorTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      recordMemoryUsage();
    });
  }
  
  /// Start periodic cleanup of old metrics
  void _startMetricsCleanup() {
    _metricsCleanupTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      _cleanupOldMetrics();
    });
  }
  
  /// Clean up old performance metrics
  void _cleanupOldMetrics() {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    _metrics.removeWhere((metric) => metric.timestamp.isBefore(cutoff));
  }
  
  /// Record a performance metric
  void _recordMetric(PerformanceMetric metric) {
    _metrics.add(metric);
    _metricsController.add(metric);
    
    // Log slow operations in debug mode
    if (kDebugMode && metric.duration.inMilliseconds > 100) {
      developer.log(
        'Slow operation: ${metric.operation} took ${metric.duration.inMilliseconds}ms',
        name: 'PerformanceService',
      );
    }
    
    // Persist metrics periodically
    if (_metrics.length % 50 == 0) {
      _persistMetrics();
    }
  }
  
  /// Load performance settings
  Future<void> _loadPerformanceSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_performanceSettingsKey);
      
      if (settingsJson != null) {
        // Load and apply performance settings
        // Apply settings...
      }
    } catch (e) {
      developer.log('Error loading performance settings: $e', name: 'PerformanceService');
    }
  }
  
  /// Persist performance metrics
  Future<void> _persistMetrics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentMetrics = _metrics.where((m) => 
        m.timestamp.isAfter(DateTime.now().subtract(const Duration(hours: 24)))
      ).toList();
      
      final metricsJson = json.encode(
        recentMetrics.map((m) => m.toJson()).toList(),
      );
      
      await prefs.setString(_performanceMetricsKey, metricsJson);
    } catch (e) {
      developer.log('Error persisting metrics: $e', name: 'PerformanceService');
    }
  }
  
  /// Dispose resources
  void dispose() {
    _memoryMonitorTimer?.cancel();
    _metricsCleanupTimer?.cancel();
    _metricsController.close();
  }
}

/// Performance metric data model
class PerformanceMetric {
  final String operation;
  final Duration duration;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  
  const PerformanceMetric({
    required this.operation,
    required this.duration,
    required this.timestamp,
    required this.metadata,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'operation': operation,
      'duration_ms': duration.inMilliseconds,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
  
  factory PerformanceMetric.fromJson(Map<String, dynamic> json) {
    return PerformanceMetric(
      operation: json['operation'] ?? '',
      duration: Duration(milliseconds: json['duration_ms'] ?? 0),
      timestamp: DateTime.parse(json['timestamp']),
      metadata: json['metadata'] ?? {},
    );
  }
}

/// Performance statistics
class PerformanceStats {
  final int totalMetrics;
  final Map<String, OperationStats> operationStats;
  final DateTime generatedAt;
  
  const PerformanceStats({
    required this.totalMetrics,
    required this.operationStats,
    required this.generatedAt,
  });
}

/// Operation-specific statistics
class OperationStats {
  final String operation;
  final int count;
  final Duration averageDuration;
  final Duration minDuration;
  final Duration maxDuration;
  final Duration p95Duration;
  
  const OperationStats({
    required this.operation,
    required this.count,
    required this.averageDuration,
    required this.minDuration,
    required this.maxDuration,
    required this.p95Duration,
  });
}

/// Efficient list rendering widget for large datasets
class PerformantListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final double? itemExtent;
  final ScrollController? controller;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final int? cacheExtent;
  
  const PerformantListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.itemExtent,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.cacheExtent,
  });
  @override
  State<PerformantListView<T>> createState() => _PerformantListViewState<T>();
}

class _PerformantListViewState<T> extends State<PerformantListView<T>> {
  late ScrollController _controller;
  final Map<int, Widget> _cachedWidgets = {};
  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ScrollController();
  }
  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _controller,
      itemCount: widget.items.length,
      itemExtent: widget.itemExtent,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      cacheExtent: widget.cacheExtent?.toDouble(),
      itemBuilder: (context, index) {
        // Cache widgets for better performance
        if (!_cachedWidgets.containsKey(index)) {
          _cachedWidgets[index] = widget.itemBuilder(context, widget.items[index], index);
          
          // Limit cache size to prevent memory issues
          if (_cachedWidgets.length > 100) {
            final oldestKey = _cachedWidgets.keys.first;
            _cachedWidgets.remove(oldestKey);
          }
        }
        
        return _cachedWidgets[index]!;
      },
    );
  }
}

/// Memory management utilities
class MemoryManager {
  static Timer? _cleanupTimer;
  
  /// Start periodic memory cleanup
  static void startPeriodicCleanup() {
    _cleanupTimer = Timer.periodic(const Duration(minutes: 10), (timer) {
      performCleanup();
    });
  }
  
  /// Perform memory cleanup
  static void performCleanup() {
    // Force garbage collection in debug mode
    if (kDebugMode) {
      developer.log('Performing memory cleanup', name: 'MemoryManager');
    }
    
    // Clear image cache if it's getting large
    PaintingBinding.instance.imageCache.clear();
    
    // Clear any other caches as needed
  }
  
  /// Stop periodic cleanup
  static void stopPeriodicCleanup() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
  }
}

/// Performance monitoring widget
class PerformanceMonitor extends StatefulWidget {
  final Widget child;
  final String? operationName;
  
  const PerformanceMonitor({
    super.key,
    required this.child,
    this.operationName,
  });
  @override
  State<PerformanceMonitor> createState() => _PerformanceMonitorState();
}

class _PerformanceMonitorState extends State<PerformanceMonitor> {
  late final PerformanceService _performanceService;
  late final String _operationName;
  @override
  void initState() {
    super.initState();
    _performanceService = PerformanceService();
    _operationName = widget.operationName ?? 'widget_build_${widget.runtimeType}';
    _performanceService.startTimer(_operationName);
  }
  @override
  void dispose() {
    _performanceService.stopTimer(_operationName);
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Providers
final performanceServiceProvider = Provider<PerformanceService>((ref) {
  final service = PerformanceService();
  ref.onDispose(() => service.dispose());
  return service;
});

final performanceStatsProvider = FutureProvider<PerformanceStats>((ref) async {
  final service = ref.read(performanceServiceProvider);
  return await service.getPerformanceStats();
});