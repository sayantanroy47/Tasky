import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Comprehensive analytics and monitoring system
class AppAnalytics {
  static AppAnalytics? _instance;
  static AppAnalytics get instance => _instance ??= AppAnalytics._internal();
  AppAnalytics._internal();

  final _events = <AnalyticsEvent>[];
  final _userProperties = <String, dynamic>{};
  final _performanceMetrics = <PerformanceMetric>[];
  Timer? _flushTimer;
  bool _initialized = false;

  /// Initialize analytics system
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await _loadUserProperties();
      _startPeriodicFlush();
      _initialized = true;
      
      // Track app launch
      trackEvent('app_launch', {
        'platform': Platform.operatingSystem,
        'version': '1.0.0', // This would come from package info
        'timestamp': DateTime.now().toIso8601String(),
      });

      debugPrint('AppAnalytics: Initialized successfully');
    } catch (e) {
      debugPrint('AppAnalytics: Failed to initialize: $e');
    }
  }

  /// Track an event with optional properties
  void trackEvent(String eventName, [Map<String, dynamic>? properties]) {
    if (!_initialized) {
      debugPrint('AppAnalytics: Not initialized, skipping event: $eventName');
      return;
    }

    final event = AnalyticsEvent(
      name: eventName,
      properties: {
        ...?properties,
        'timestamp': DateTime.now().toIso8601String(),
        'session_id': _getSessionId(),
      },
    );

    _events.add(event);
    
    // Immediate flush for critical events
    if (_isCriticalEvent(eventName)) {
      _flushEvents();
    }

    debugPrint('AppAnalytics: Tracked event: $eventName');
  }

  /// Set user property
  void setUserProperty(String key, dynamic value) {
    _userProperties[key] = value;
    _saveUserProperties();
  }

  /// Track screen view
  void trackScreenView(String screenName, {String? screenClass}) {
    trackEvent('screen_view', {
      'screen_name': screenName,
      'screen_class': screenClass ?? screenName,
    });
  }

  /// Track user action
  void trackUserAction(String action, {Map<String, dynamic>? context}) {
    trackEvent('user_action', {
      'action': action,
      ...?context,
    });
  }

  /// Track error
  void trackError(String error, {
    String? stackTrace,
    String? context,
    String? severity,
  }) {
    trackEvent('error', {
      'error_message': error,
      'stack_trace': stackTrace,
      'context': context,
      'severity': severity ?? 'error',
    });
  }

  /// Track performance metric
  void trackPerformance(String metric, double value, {
    String? unit,
    Map<String, dynamic>? attributes,
  }) {
    final performanceMetric = PerformanceMetric(
      name: metric,
      value: value,
      unit: unit,
      timestamp: DateTime.now(),
      attributes: attributes,
    );

    _performanceMetrics.add(performanceMetric);
    
    // Keep only recent metrics to avoid memory issues
    if (_performanceMetrics.length > 1000) {
      _performanceMetrics.removeAt(0);
    }

    // Also track as event for critical performance metrics
    if (_isCriticalPerformanceMetric(metric)) {
      trackEvent('performance_metric', {
        'metric_name': metric,
        'metric_value': value,
        'metric_unit': unit,
        ...?attributes,
      });
    }
  }

  /// Track app lifecycle events
  void trackAppLifecycle(String event) {
    trackEvent('app_lifecycle', {
      'lifecycle_event': event,
    });
  }

  /// Track feature usage
  void trackFeatureUsage(String feature, {Map<String, dynamic>? details}) {
    trackEvent('feature_usage', {
      'feature': feature,
      ...?details,
    });
  }

  /// Get analytics summary
  AnalyticsSummary getAnalyticsSummary() {
    final eventsByType = <String, int>{};
    for (final event in _events) {
      eventsByType[event.name] = (eventsByType[event.name] ?? 0) + 1;
    }

    final performanceByMetric = <String, List<double>>{};
    for (final metric in _performanceMetrics) {
      performanceByMetric.putIfAbsent(metric.name, () => []).add(metric.value);
    }

    return AnalyticsSummary(
      totalEvents: _events.length,
      eventsByType: eventsByType,
      userProperties: Map.from(_userProperties),
      performanceMetrics: performanceByMetric,
      sessionId: _getSessionId(),
    );
  }

  /// Start periodic flush timer
  void _startPeriodicFlush() {
    _flushTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _flushEvents();
    });
  }

  /// Flush events to storage/server
  Future<void> _flushEvents() async {
    if (_events.isEmpty) return;

    try {
      final eventsToFlush = List<AnalyticsEvent>.from(_events);
      _events.clear();

      // In a real app, you'd send to analytics service
      await _saveEventsLocally(eventsToFlush);
      
      debugPrint('AppAnalytics: Flushed ${eventsToFlush.length} events');
    } catch (e) {
      debugPrint('AppAnalytics: Failed to flush events: $e');
    }
  }

  /// Save events locally for offline analytics
  Future<void> _saveEventsLocally(List<AnalyticsEvent> events) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingEvents = prefs.getStringList('analytics_events') ?? [];
      
      final eventStrings = events.map((e) => jsonEncode({
        'name': e.name,
        'properties': e.properties,
        'timestamp': e.timestamp.toIso8601String(),
      })).toList();
      
      existingEvents.addAll(eventStrings);
      
      // Keep only recent events (last 1000)
      if (existingEvents.length > 1000) {
        existingEvents.removeRange(0, existingEvents.length - 1000);
      }
      
      await prefs.setStringList('analytics_events', existingEvents);
    } catch (e) {
      debugPrint('AppAnalytics: Failed to save events locally: $e');
    }
  }

  /// Load user properties from storage
  Future<void> _loadUserProperties() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userPropsString = prefs.getString('user_properties');
      
      if (userPropsString != null) {
        final props = jsonDecode(userPropsString) as Map<String, dynamic>;
        _userProperties.addAll(props);
      }
    } catch (e) {
      debugPrint('AppAnalytics: Failed to load user properties: $e');
    }
  }

  /// Save user properties to storage
  Future<void> _saveUserProperties() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_properties', jsonEncode(_userProperties));
    } catch (e) {
      debugPrint('AppAnalytics: Failed to save user properties: $e');
    }
  }

  /// Get current session ID
  String _getSessionId() {
    // In a real app, this would be more sophisticated
    return 'session_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Check if event is critical and needs immediate flush
  bool _isCriticalEvent(String eventName) {
    const criticalEvents = {
      'error',
      'crash',
      'app_launch',
      'user_signup',
      'purchase',
    };
    return criticalEvents.contains(eventName);
  }

  /// Check if performance metric is critical
  bool _isCriticalPerformanceMetric(String metric) {
    const criticalMetrics = {
      'app_start_time',
      'crash_rate',
      'memory_usage',
      'network_error_rate',
    };
    return criticalMetrics.contains(metric);
  }

  /// Dispose analytics system
  Future<void> dispose() async {
    _flushTimer?.cancel();
    await _flushEvents();
    _initialized = false;
  }
}

/// Analytics event data class
class AnalyticsEvent {
  final String name;
  final Map<String, dynamic> properties;
  final DateTime timestamp;

  AnalyticsEvent({
    required this.name,
    required this.properties,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Performance metric data class
class PerformanceMetric {
  final String name;
  final double value;
  final String? unit;
  final DateTime timestamp;
  final Map<String, dynamic>? attributes;

  PerformanceMetric({
    required this.name,
    required this.value,
    this.unit,
    DateTime? timestamp,
    this.attributes,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Analytics summary data class
class AnalyticsSummary {
  final int totalEvents;
  final Map<String, int> eventsByType;
  final Map<String, dynamic> userProperties;
  final Map<String, List<double>> performanceMetrics;
  final String sessionId;

  const AnalyticsSummary({
    required this.totalEvents,
    required this.eventsByType,
    required this.userProperties,
    required this.performanceMetrics,
    required this.sessionId,
  });

  /// Get top events by count
  List<MapEntry<String, int>> get topEvents {
    final entries = eventsByType.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.take(10).toList();
  }

  /// Get performance metrics with statistics
  Map<String, PerformanceStats> get performanceStats {
    final stats = <String, PerformanceStats>{};
    
    for (final entry in performanceMetrics.entries) {
      final values = entry.value;
      if (values.isNotEmpty) {
        final sorted = List<double>.from(values)..sort();
        final avg = values.reduce((a, b) => a + b) / values.length;
        final min = sorted.first;
        final max = sorted.last;
        final median = sorted[sorted.length ~/ 2];
        
        stats[entry.key] = PerformanceStats(
          average: avg,
          min: min,
          max: max,
          median: median,
          sampleCount: values.length,
        );
      }
    }
    
    return stats;
  }
}

/// Performance statistics data class
class PerformanceStats {
  final double average;
  final double min;
  final double max;
  final double median;
  final int sampleCount;

  const PerformanceStats({
    required this.average,
    required this.min,
    required this.max,
    required this.median,
    required this.sampleCount,
  });
}

/// Analytics mixin for easy integration
mixin AnalyticsTracker {
  void trackEvent(String eventName, [Map<String, dynamic>? properties]) {
    AppAnalytics.instance.trackEvent(eventName, properties);
  }

  void trackScreenView(String screenName) {
    AppAnalytics.instance.trackScreenView(screenName);
  }

  void trackUserAction(String action, {Map<String, dynamic>? context}) {
    AppAnalytics.instance.trackUserAction(action, context: context);
  }

  void trackFeatureUsage(String feature, {Map<String, dynamic>? details}) {
    AppAnalytics.instance.trackFeatureUsage(feature, details: details);
  }
}