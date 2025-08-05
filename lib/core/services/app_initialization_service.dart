import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/error_recovery_service.dart';
import '../../services/performance_service.dart';
import '../../services/privacy_service.dart';
import '../../services/database/database.dart';
import '../../services/share_intent_service.dart';
import '../../presentation/providers/task_providers.dart';
import '../../main.dart' show navigatorKey;

/// Service for handling app initialization with error recovery
class AppInitializationService {
  final ErrorRecoveryService _errorRecoveryService;
  final PerformanceService _performanceService;
  final PrivacyService _privacyService;
  final AppDatabase _database;
  final ShareIntentService _shareIntentService;
  
  AppInitializationService(
    this._errorRecoveryService,
    this._performanceService,
    this._privacyService,
    this._database,
    this._shareIntentService,
  );
  
  /// Initialize the app with comprehensive error handling
  Future<void> initialize() async {
    _performanceService.startTimer('app_initialization_service');
    
    try {
      // Initialize error recovery first
      await _errorRecoveryService.initialize();
      
      // Initialize performance monitoring
      await _performanceService.initialize();
      
      // Initialize database
      await _initializeDatabase();
      
      // Initialize share intent service
      await _shareIntentService.initialize();
      
      // Initialize privacy service
      await _privacyService.initializePrivacyDefaults();
      
      // Attempt to restore app state if recovering from crash
      await _attemptStateRecovery();
      
      // Perform health check
      try {
        final healthStatus = await _errorRecoveryService.performHealthCheck();
        if (healthStatus.toString().contains('critical')) {
          // Consider clearing corrupted data or entering safe mode
          await _handleCriticalHealth();
        }
      } catch (e) {
        // Health check failed, continue with initialization
        await _errorRecoveryService.recordError(
          'health_check_failed',
          e,
          StackTrace.current,
        );
      }
      
      _performanceService.stopTimer('app_initialization_service');
      
    } catch (error, stackTrace) {
      _performanceService.stopTimer('app_initialization_service');
      
      // Record initialization failure
      await _errorRecoveryService.recordError(
        'app_initialization',
        error,
        stackTrace,
      );
      
      rethrow;
    }
  }

  /// Initialize the database
  Future<void> _initializeDatabase() async {
    try {
      // The database is already initialized when created, but we can
      // perform additional setup here if needed
      final stats = await _database.getDatabaseStats();
      _performanceService.recordMetric(
        'database_initialization',
        Duration.zero,
        metadata: stats,
      );
    } catch (e) {
      await _errorRecoveryService.recordError(
        'database_initialization',
        e,
        StackTrace.current,
      );
      rethrow;
    }
  }
  
  /// Attempt to recover app state from previous session
  Future<void> _attemptStateRecovery() async {
    try {
      final restoredState = await _errorRecoveryService.restoreAppState();
      if (restoredState != null) {
        // Apply restored state to relevant services
        // This would be implemented based on actual app state structure
      }
    } catch (e) {
      // State recovery failed, continue with fresh state
      await _errorRecoveryService.recordError(
        'state_recovery',
        e,
        StackTrace.current,
      );
    }
  }
  
  /// Handle critical health status
  Future<void> _handleCriticalHealth() async {
    try {
      // Clear potentially corrupted data
      await _errorRecoveryService.clearOldReports();
      
      // Reset to safe defaults
      await _privacyService.initializePrivacyDefaults();
      
    } catch (e) {
      // Even recovery failed - this is a serious issue
      await _errorRecoveryService.recordError(
        'critical_health_recovery',
        e,
        StackTrace.current,
      );
    }
  }
}

/// Provider for error recovery service
final errorRecoveryServiceProvider = Provider<ErrorRecoveryService>((ref) {
  return ErrorRecoveryService();
});

/// Provider for privacy service
final privacyServiceProvider = Provider<PrivacyService>((ref) {
  return PrivacyService();
});

/// Provider for app initialization
final appInitializationProvider = FutureProvider<void>((ref) async {
  final errorRecoveryService = ref.read(errorRecoveryServiceProvider);
  final performanceService = ref.read(performanceServiceProvider);
  final privacyService = ref.read(privacyServiceProvider);
  final database = ref.read(databaseProvider);
  final taskRepository = ref.read(taskRepositoryProvider);
  final shareIntentService = ShareIntentService();
  
  // Connect repository to share intent service
  shareIntentService.setTaskRepository(taskRepository);
  
  // Set context for dialog display (will be available after app builds)
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      shareIntentService.setContext(context);
    }
  });
  
  final initService = AppInitializationService(
    errorRecoveryService,
    performanceService,
    privacyService,
    database,
    shareIntentService,
  );
  
  await initService.initialize();
});