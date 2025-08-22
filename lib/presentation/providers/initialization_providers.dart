import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/app_initialization_service.dart';
import '../../services/error_recovery_service.dart';
import '../../services/privacy_service.dart';
import '../../services/share_intent_service.dart';
import '../../core/providers/core_providers.dart';
import 'location_providers.dart';

/// Provider for app initialization
final appInitializationProvider = FutureProvider<void>((ref) async {
  final database = ref.watch(databaseProvider);
  final errorRecoveryService = ErrorRecoveryService();
  final privacyService = PrivacyService();
  final shareIntentService = ShareIntentService();
  final taskRepository = ref.watch(taskRepositoryProvider);
  final geofencingManager = ref.watch(geofencingManagerProvider);
  
  // Set up ShareIntentService with repository
  shareIntentService.setTaskRepository(taskRepository);
  
  final initService = AppInitializationService(
    errorRecoveryService,
    privacyService,
    database,
    shareIntentService,
    geofencingManager: geofencingManager,
    taskRepository: taskRepository,
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

