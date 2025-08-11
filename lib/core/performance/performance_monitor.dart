/// Performance monitoring service for tracking query performance
/// and cache effectiveness
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final Map<String, List<Duration>> _queryTimes = {};
  final Map<String, int> _cacheHits = {};
  final Map<String, int> _cacheMisses = {};
  final List<QueryMetric> _recentQueries = [];
  static const int _maxRecentQueries = 100;

  /// Record a database query execution time
  void recordQuery(String queryType, Duration duration) {
    _queryTimes.putIfAbsent(queryType, () => []).add(duration);
    
    _recentQueries.add(QueryMetric(
      queryType: queryType,
      duration: duration,
      timestamp: DateTime.now(),
    ));
    
    // Keep only recent queries
    if (_recentQueries.length > _maxRecentQueries) {
      _recentQueries.removeAt(0);
    }
  }

  /// Record a cache hit
  void recordCacheHit(String cacheType) {
    _cacheHits[cacheType] = (_cacheHits[cacheType] ?? 0) + 1;
  }

  /// Record a cache miss
  void recordCacheMiss(String cacheType) {
    _cacheMisses[cacheType] = (_cacheMisses[cacheType] ?? 0) + 1;
  }

  /// Get average query time for a specific query type
  Duration? getAverageQueryTime(String queryType) {
    final times = _queryTimes[queryType];
    if (times == null || times.isEmpty) return null;

    final totalMs = times.fold<int>(0, (sum, duration) => sum + duration.inMilliseconds);
    return Duration(milliseconds: (totalMs / times.length).round());
  }

  /// Get cache hit ratio for a specific cache type
  double getCacheHitRatio(String cacheType) {
    final hits = _cacheHits[cacheType] ?? 0;
    final misses = _cacheMisses[cacheType] ?? 0;
    final total = hits + misses;
    return total > 0 ? hits / total : 0.0;
  }

  /// Get comprehensive performance statistics
  PerformanceStats getStats() {
    final Map<String, Duration> avgQueryTimes = {};
    final Map<String, double> cacheHitRatios = {};
    
    for (final queryType in _queryTimes.keys) {
      final avgTime = getAverageQueryTime(queryType);
      if (avgTime != null) {
        avgQueryTimes[queryType] = avgTime;
      }
    }
    
    // Calculate cache hit ratios for all cache types
    final allCacheTypes = {..._cacheHits.keys, ..._cacheMisses.keys};
    for (final cacheType in allCacheTypes) {
      cacheHitRatios[cacheType] = getCacheHitRatio(cacheType);
    }
    
    return PerformanceStats(
      averageQueryTimes: avgQueryTimes,
      cacheHitRatios: cacheHitRatios,
      totalQueries: _recentQueries.length,
      recentQueries: List.from(_recentQueries.reversed.take(10)),
    );
  }

  /// Get slow queries (queries taking longer than threshold)
  List<QueryMetric> getSlowQueries({Duration threshold = const Duration(milliseconds: 100)}) {
    return _recentQueries
        .where((query) => query.duration > threshold)
        .toList();
  }

  /// Clear all performance data
  void clear() {
    _queryTimes.clear();
    _cacheHits.clear();
    _cacheMisses.clear();
    _recentQueries.clear();
  }

  /// Export performance data for analysis
  Map<String, dynamic> export() {
    return {
      'query_times': _queryTimes.map((key, value) => MapEntry(
        key, 
        value.map((d) => d.inMilliseconds).toList()
      )),
      'cache_hits': _cacheHits,
      'cache_misses': _cacheMisses,
      'recent_queries': _recentQueries.map((q) => q.toJson()).toList(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

/// Single query metric
class QueryMetric {
  final String queryType;
  final Duration duration;
  final DateTime timestamp;

  QueryMetric({
    required this.queryType,
    required this.duration,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'query_type': queryType,
      'duration_ms': duration.inMilliseconds,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  bool get isSlow => duration > const Duration(milliseconds: 100);
}

/// Overall performance statistics
class PerformanceStats {
  final Map<String, Duration> averageQueryTimes;
  final Map<String, double> cacheHitRatios;
  final int totalQueries;
  final List<QueryMetric> recentQueries;

  const PerformanceStats({
    required this.averageQueryTimes,
    required this.cacheHitRatios,
    required this.totalQueries,
    required this.recentQueries,
  });

  /// Get overall cache hit ratio
  double get overallCacheHitRatio {
    if (cacheHitRatios.isEmpty) return 0.0;
    return cacheHitRatios.values.reduce((a, b) => a + b) / cacheHitRatios.length;
  }

  /// Get slowest query type
  String? get slowestQueryType {
    if (averageQueryTimes.isEmpty) return null;
    
    String? slowest;
    Duration? slowestTime;
    
    for (final entry in averageQueryTimes.entries) {
      if (slowestTime == null || entry.value > slowestTime) {
        slowest = entry.key;
        slowestTime = entry.value;
      }
    }
    
    return slowest;
  }

  /// Check if performance is healthy
  bool get isHealthy {
    // Consider performance healthy if:
    // 1. Average query time is under 50ms
    // 2. Cache hit ratio is above 70%
    // 3. No queries taking longer than 200ms in recent queries
    
    final avgQueryTimeOk = averageQueryTimes.values
        .every((time) => time.inMilliseconds < 50);
    
    final cacheHitRatioOk = overallCacheHitRatio > 0.7;
    
    final noSlowQueries = recentQueries
        .every((query) => query.duration.inMilliseconds < 200);
    
    return avgQueryTimeOk && cacheHitRatioOk && noSlowQueries;
  }
}

/// Extension to make timing queries easier
extension TimedQuery<T> on Future<T> Function() {
  /// Execute the function and record the execution time
  Future<T> timed(String queryType) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await this();
      stopwatch.stop();
      PerformanceMonitor().recordQuery(queryType, stopwatch.elapsed);
      return result;
    } catch (e) {
      stopwatch.stop();
      PerformanceMonitor().recordQuery('${queryType}_error', stopwatch.elapsed);
      rethrow;
    }
  }
}