import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for handling app reliability and error recovery
class ErrorRecoveryService {
  static const String _crashReportsKey = 'crash_reports';
  static const String _appStateKey = 'app_state_backup';
  static const String _errorCountKey = 'error_count';

  
  final List<CrashReport> _crashReports = [];
  final StreamController<AppHealthStatus> _healthController = StreamController.broadcast();
  Timer? _healthCheckTimer;
  int _errorCount = 0;
  
  /// Stream of app health status updates
  Stream<AppHealthStatus> get healthStream => _healthController.stream;
  
  /// Initialize error recovery service
  Future<void> initialize() async {
    await _loadCrashReports();
    await _loadErrorCount();
    _startHealthMonitoring();
    
    // Set up global error handlers
    _setupErrorHandlers();
  }
  
  /// Record a crash report
  Future<void> recordCrash(CrashReport report) async {
    _crashReports.add(report);
    await _persistCrashReports();
    
    // Update health status
    _updateHealthStatus();
    
    developer.log(
      'Crash recorded: ${report.error}',
      name: 'ErrorRecoveryService',
      error: report.error,
      stackTrace: report.stackTrace,
    );
  }
  
  /// Record a non-fatal error
  Future<void> recordError(String operation, dynamic error, StackTrace? stackTrace) async {
    _errorCount++;
    await _persistErrorCount();
    
    ErrorReport(
      operation: operation,
      error: error,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
      isFatal: false,
    );
    
    // Log error
    developer.log(
      'Error in $operation: $error',
      name: 'ErrorRecoveryService',
      error: error,
      stackTrace: stackTrace,
    );
    
    // Update health status
    _updateHealthStatus();
  }
  
  /// Backup current app state
  Future<void> backupAppState(Map<String, dynamic> state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stateJson = json.encode({
        'timestamp': DateTime.now().toIso8601String(),
        'state': state,
      });
      await prefs.setString(_appStateKey, stateJson);
    } catch (e) {
      developer.log('Failed to backup app state: $e', name: 'ErrorRecoveryService');
    }
  }
  
  /// Restore app state from backup
  Future<Map<String, dynamic>?> restoreAppState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stateJson = prefs.getString(_appStateKey);
      
      if (stateJson != null) {
        final stateData = json.decode(stateJson) as Map<String, dynamic>;
        final timestamp = DateTime.parse(stateData['timestamp']);
        
        // Only restore if backup is less than 24 hours old
        if (DateTime.now().difference(timestamp).inHours < 24) {
          return stateData['state'] as Map<String, dynamic>;
        }
      }
    } catch (e) {
      developer.log('Failed to restore app state: $e', name: 'ErrorRecoveryService');
    }
    
    return null;
  }
  
  /// Perform health check
  Future<AppHealthStatus> performHealthCheck() async {
    final now = DateTime.now();
    final recentCrashes = _crashReports.where((crash) => 
      now.difference(crash.timestamp).inHours < 24
    ).length;
    
    final recentErrors = _errorCount; // This would be filtered by time in a real implementation
    
    HealthLevel level;
    String message;
    
    if (recentCrashes > 3) {
      level = HealthLevel.critical;
      message = 'Multiple crashes detected in the last 24 hours';
    } else if (recentCrashes > 1) {
      level = HealthLevel.warning;
      message = 'Recent crashes detected';
    } else if (recentErrors > 10) {
      level = HealthLevel.warning;
      message = 'High error rate detected';
    } else {
      level = HealthLevel.healthy;
      message = 'App is running normally';
    }
    
    return AppHealthStatus(
      level: level,
      message: message,
      crashCount: recentCrashes,
      errorCount: recentErrors,
      lastChecked: now,
    );
  }
  
  /// Retry a failed operation with exponential backoff
  Future<T> retryOperation<T>(
    Future<T> Function() operation,
    String operationName, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
    double backoffMultiplier = 2.0,
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;
    
    while (attempt < maxRetries) {
      try {
        return await operation();
      } catch (error, stackTrace) {
        attempt++;
        
        if (attempt >= maxRetries) {
          await recordError(operationName, error, stackTrace);
          rethrow;
        }
        
        developer.log(
          'Retry attempt $attempt for $operationName failed: $error',
          name: 'ErrorRecoveryService',
        );
        
        await Future.delayed(delay);
        delay = Duration(milliseconds: (delay.inMilliseconds * backoffMultiplier).round());
      }
    }
    
    throw StateError('This should never be reached');
  }
  
  /// Clear old crash reports and errors
  Future<void> clearOldReports() async {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    _crashReports.removeWhere((report) => report.timestamp.isBefore(cutoff));
    await _persistCrashReports();
    
    // Reset error count periodically
    _errorCount = 0;
    await _persistErrorCount();
  }
  
  /// Get crash reports for analysis
  List<CrashReport> getCrashReports() => List.unmodifiable(_crashReports);
  
  /// Get current error count
  int get errorCount => _errorCount;
  
  /// Setup global error handlers
  void _setupErrorHandlers() {
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      final crashReport = CrashReport(
        error: details.exception,
        stackTrace: details.stack,
        timestamp: DateTime.now(),
        context: details.context?.toString(),
        library: details.library,
        isFatal: true,
      );
      
      recordCrash(crashReport);
      
      // Call the default error handler in debug mode
      if (kDebugMode) {
        FlutterError.presentError(details);
      }
    };
    
    // Handle async errors
    PlatformDispatcher.instance.onError = (error, stack) {
      final crashReport = CrashReport(
        error: error,
        stackTrace: stack,
        timestamp: DateTime.now(),
        isFatal: true,
      );
      
      recordCrash(crashReport);
      return true;
    };
  }
  
  /// Start periodic health monitoring
  void _startHealthMonitoring() {
    _healthCheckTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      final status = await performHealthCheck();
      _healthController.add(status);
    });
  }
  
  /// Update health status
  void _updateHealthStatus() async {
    final status = await performHealthCheck();
    _healthController.add(status);
  }
  
  /// Load crash reports from storage
  Future<void> _loadCrashReports() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reportsJson = prefs.getString(_crashReportsKey);
      
      if (reportsJson != null) {
        final reportsList = json.decode(reportsJson) as List<dynamic>;
        _crashReports.clear();
        _crashReports.addAll(
          reportsList.map((report) => CrashReport.fromJson(report as Map<String, dynamic>))
        );
      }
    } catch (e) {
      developer.log('Failed to load crash reports: $e', name: 'ErrorRecoveryService');
    }
  }
  
  /// Persist crash reports to storage
  Future<void> _persistCrashReports() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reportsJson = json.encode(
        _crashReports.map((report) => report.toJson()).toList(),
      );
      await prefs.setString(_crashReportsKey, reportsJson);
    } catch (e) {
      developer.log('Failed to persist crash reports: $e', name: 'ErrorRecoveryService');
    }
  }
  
  /// Load error count from storage
  Future<void> _loadErrorCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _errorCount = prefs.getInt(_errorCountKey) ?? 0;
    } catch (e) {
      developer.log('Failed to load error count: $e', name: 'ErrorRecoveryService');
    }
  }
  
  /// Persist error count to storage
  Future<void> _persistErrorCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_errorCountKey, _errorCount);
    } catch (e) {
      developer.log('Failed to persist error count: $e', name: 'ErrorRecoveryService');
    }
  }
  
  /// Dispose resources
  void dispose() {
    _healthCheckTimer?.cancel();
    _healthController.close();
  }
}

/// Crash report data model
class CrashReport {
  final dynamic error;
  final StackTrace? stackTrace;
  final DateTime timestamp;
  final String? context;
  final String? library;
  final bool isFatal;
  
  const CrashReport({
    required this.error,
    this.stackTrace,
    required this.timestamp,
    this.context,
    this.library,
    required this.isFatal,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'error': error.toString(),
      'stackTrace': stackTrace?.toString(),
      'timestamp': timestamp.toIso8601String(),
      'context': context,
      'library': library,
      'isFatal': isFatal,
    };
  }
  
  factory CrashReport.fromJson(Map<String, dynamic> json) {
    return CrashReport(
      error: json['error'],
      stackTrace: json['stackTrace'] != null ? StackTrace.fromString(json['stackTrace']) : null,
      timestamp: DateTime.parse(json['timestamp']),
      context: json['context'],
      library: json['library'],
      isFatal: json['isFatal'] ?? false,
    );
  }
}

/// Error report data model
class ErrorReport {
  final String operation;
  final dynamic error;
  final StackTrace? stackTrace;
  final DateTime timestamp;
  final bool isFatal;
  
  const ErrorReport({
    required this.operation,
    required this.error,
    this.stackTrace,
    required this.timestamp,
    required this.isFatal,
  });
}

/// App health status
class AppHealthStatus {
  final HealthLevel level;
  final String message;
  final int crashCount;
  final int errorCount;
  final DateTime lastChecked;
  
  const AppHealthStatus({
    required this.level,
    required this.message,
    required this.crashCount,
    required this.errorCount,
    required this.lastChecked,
  });
}

/// Health level enumeration
enum HealthLevel { healthy, warning, critical }

/// Error recovery widget wrapper
class ErrorRecoveryWrapper extends ConsumerStatefulWidget {
  final Widget child;
  final String operationName;
  final Widget Function(BuildContext context, dynamic error, VoidCallback retry)? errorBuilder;
  
  const ErrorRecoveryWrapper({
    super.key,
    required this.child,
    required this.operationName,
    this.errorBuilder,
  });
  @override
  ConsumerState<ErrorRecoveryWrapper> createState() => _ErrorRecoveryWrapperState();
}

class _ErrorRecoveryWrapperState extends ConsumerState<ErrorRecoveryWrapper> {
  dynamic _error;
  bool _hasError = false;
  @override
  Widget build(BuildContext context) {
    if (_hasError && _error != null) {
      return widget.errorBuilder?.call(context, _error, _retry) ?? 
        _buildDefaultErrorWidget(context);
    }
    
    return ErrorBoundary(
      onError: (error, stackTrace) {
        setState(() {
          _error = error;
          _hasError = true;
        });
        
        // Record the error
        ref.read(errorRecoveryServiceProvider).recordError(
          widget.operationName,
          error,
          stackTrace,
        );
      },
      child: widget.child,
    );
  }
  
  void _retry() {
    setState(() {
      _error = null;
      _hasError = false;
    });
  }
  
  Widget _buildDefaultErrorWidget(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'An error occurred in ${widget.operationName}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error boundary widget
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final void Function(dynamic error, StackTrace stackTrace)? onError;
  
  const ErrorBoundary({
    super.key,
    required this.child,
    this.onError,
  });
  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // This is a simplified error boundary - in a real implementation,
    // you'd need to use a more sophisticated approach to catch widget errors
  }
}

/// Providers
final errorRecoveryServiceProvider = Provider<ErrorRecoveryService>((ref) {
  final service = const ErrorRecoveryService();
  ref.onDispose(() => service.dispose());
  return service;
});

final appHealthStatusProvider = StreamProvider<AppHealthStatus>((ref) {
  final service = ref.read(errorRecoveryServiceProvider);
  return service.healthStream;
});