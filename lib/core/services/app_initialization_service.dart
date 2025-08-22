import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/error_recovery_service.dart';
import '../../services/privacy_service.dart';
import '../../services/database/database.dart';
import '../../services/share_intent_service.dart';
import '../../services/location/geofencing_manager.dart';
import '../../domain/repositories/task_repository.dart';

/// Service for handling app initialization with error recovery
class AppInitializationService {
  final ErrorRecoveryService _errorRecoveryService;
  final PrivacyService _privacyService;
  final AppDatabase _database;
  final ShareIntentService _shareIntentService;
  final GeofencingManager? _geofencingManager;
  final TaskRepository? _taskRepository;
  
  AppInitializationService(
    this._errorRecoveryService,
    this._privacyService,
    this._database,
    this._shareIntentService, {
    GeofencingManager? geofencingManager,
    TaskRepository? taskRepository,
  }) : _geofencingManager = geofencingManager,
       _taskRepository = taskRepository;
  
  /// Initialize the app with comprehensive error handling
  Future<void> initialize() async {
    try {
      // Initialize error recovery first
      await _errorRecoveryService.initialize();
      
      // Initialize database
      await _initializeDatabase();
      
      // Initialize share intent service
      await _shareIntentService.initialize();
      
      // Initialize privacy service
      await _privacyService.initializePrivacyDefaults();
      
      // Initialize geofencing manager if available
      await _initializeGeofencing();
      
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
      
    } catch (error, stackTrace) {
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
      await _database.getDatabaseStats();
      // Database initialized successfully
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
  
  /// Initialize geofencing manager
  Future<void> _initializeGeofencing() async {
    try {
      if (_geofencingManager != null && _taskRepository != null) {
        await _geofencingManager.initialize();
        
        // Load existing location triggers from database
        final tasks = await _taskRepository.getAllTasks();
        for (final task in tasks) {
          if (task.locationTrigger != null && task.locationTrigger!.isNotEmpty) {
            try {
              // Parse and add location trigger
              // This would parse the JSON and create LocationTrigger objects
              // For now, just log that location triggers exist
            } catch (e) {
              // Failed to parse location trigger, skip
            }
          }
        }
      }
    } catch (e) {
      // Geofencing initialization failed, but don't block app startup
      await _errorRecoveryService.recordError(
        'geofencing_initialization',
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

// Provider for app initialization is now in presentation/providers/initialization_providers.dart
// to avoid conflicts and centralize all providers