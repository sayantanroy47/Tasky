import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/error_recovery_service.dart';
import '../../services/performance_service.dart';
import '../../services/privacy_service.dart';

/// Service for handling app initialization with error recovery
class AppInitializationService {
  final ErrorRecoveryService _errorRecoveryService;
  final PerformanceService _performanceService;
  final PrivacyService _privacyService;
  
  AppInitializationService(
    this._errorRecoveryService,
    this._performanceService,
    this._privacyService,
  );
  
  /// Initialize the app with comprehensive error handling
  Future<void> initialize() async {
    _performanceService.startTimer('app_initialization_service');
    
    try {
      // Initialize error recovery first
      await _errorRecoveryService.initialize();
      
      // Initialize performance monitoring
      await _performanceService.initialize();
      
      // Initialize privacy service
      await _privacyService.initializePrivacyDefaults();
      
      // Attempt to restore app state if recovering from crash
      await _attemptStateRecovery();
      
      // Perform health check
      final healthStatus = await _errorRecoveryService.performHealthCheck();
      if (healthStatus.level == HealthLevel.critical) {
        // Consider clearing corrupted data or entering safe mode
        await _handleCriticalHealth();
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

/// Provider for app initialization
final appInitializationProvider = FutureProvider<void>((ref) async {
  final errorRecoveryService = ref.read(errorRecoveryServiceProvider);
  final performanceService = ref.read(performanceServiceProvider);
  final privacyService = ref.read(privacyServiceProvider);
  
  final initService = AppInitializationService(
    errorRecoveryService,
    performanceService,
    privacyService,
  );
  
  await initService.initialize();
});