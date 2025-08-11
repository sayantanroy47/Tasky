import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/app_initialization_service.dart';
import '../../services/error_recovery_service.dart';
import '../../services/performance_service.dart';
import '../../services/privacy_service.dart';
import '../../services/database/database.dart';
import '../../services/share_intent_service.dart';
import '../../core/providers/core_providers.dart';
import 'task_providers.dart';

/// Provider for app initialization
final appInitializationProvider = FutureProvider<void>((ref) async {
  final database = ref.watch(databaseProvider);
  final errorRecoveryService = ErrorRecoveryService();
  final performanceService = ref.watch(performanceServiceProvider);
  final privacyService = PrivacyService();
  final shareIntentService = ShareIntentService();
  final taskRepository = ref.watch(taskRepositoryProvider);
  
  // Set up ShareIntentService with repository
  shareIntentService.setTaskRepository(taskRepository);
  
  final initService = AppInitializationService(
    errorRecoveryService,
    performanceService,
    privacyService,
    database,
    shareIntentService,
  );
  
  await initService.initialize();
});

/// Memory manager for performance optimization
class MemoryManager {
  static bool _isRunning = false;
  static Duration _cleanupInterval = const Duration(minutes: 5);
  
  /// Start periodic memory cleanup
  static void startPeriodicCleanup() {
    if (_isRunning) return;
    _isRunning = true;
    
    Future.doWhile(() async {
      if (!_isRunning) return false;
      
      await Future.delayed(_cleanupInterval);
      
      if (_isRunning) {
        // Trigger garbage collection hint
        // This is a hint to the system, not a guarantee
        imageCache.clear();
        imageCache.clearLiveImages();
        
        // Clear any cached data that's not currently needed
        PaintingBinding.instance.imageCache.clear();
        PaintingBinding.instance.imageCache.clearLiveImages();
      }
      
      return _isRunning;
    });
  }
  
  /// Stop periodic memory cleanup
  static void stopPeriodicCleanup() {
    _isRunning = false;
  }
  
  /// Manually trigger memory cleanup
  static void triggerCleanup() {
    imageCache.clear();
    imageCache.clearLiveImages();
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }
  
  /// Configure cleanup interval
  static void setCleanupInterval(Duration interval) {
    _cleanupInterval = interval;
  }
}

/// Performance monitor widget for tracking render performance
class PerformanceMonitor extends ConsumerStatefulWidget {
  final String operationName;
  final Widget child;
  
  const PerformanceMonitor({
    super.key,
    required this.operationName,
    required this.child,
  });
  
  @override
  ConsumerState<PerformanceMonitor> createState() => _PerformanceMonitorState();
}

class _PerformanceMonitorState extends ConsumerState<PerformanceMonitor> {
  late DateTime _startTime;
  
  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    
    // Start monitoring
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final performanceService = ref.read(performanceServiceProvider);
      performanceService.startTimer(widget.operationName);
    });
  }
  
  @override
  void dispose() {
    // Stop monitoring and record metrics
    final performanceService = ref.read(performanceServiceProvider);
    performanceService.stopTimer(widget.operationName);
    
    final duration = DateTime.now().difference(_startTime);
    performanceService.recordMetric(
      '${widget.operationName}_render',
      duration,
      metadata: {
        'widget_type': widget.child.runtimeType.toString(),
        'render_time_ms': duration.inMilliseconds,
      },
    );
    
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}