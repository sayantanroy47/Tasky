import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart' show shareIntentServiceProvider;
import '../../core/providers/core_providers.dart';
import '../providers/initialization_providers.dart';
import '../providers/background_service_providers.dart';
import '../../core/theme/typography_constants.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Wrapper widget that handles app initialization with performance monitoring
class AppInitializationWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const AppInitializationWrapper({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<AppInitializationWrapper> createState() => _AppInitializationWrapperState();
}

class _AppInitializationWrapperState extends ConsumerState<AppInitializationWrapper> {
  @override
  void initState() {
    super.initState();
    
    // Set context for ShareIntentService and initialize background services
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shareIntentService = ref.read(shareIntentServiceProvider);
      final taskRepository = ref.read(taskRepositoryProvider);
      
      shareIntentService.whenData((service) {
        service.setContext(context);
        service.setTaskRepository(taskRepository);
      });
      
      // Initialize background service processing
      ref.read(backgroundProcessingProvider);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initializationAsync = ref.watch(appInitializationProvider);

    return initializationAsync.when(
      data: (_) {
        // After app initialization, return the child (MaterialApp) with ProfileSetupWrapper as home
        return widget.child;
      },
      loading: () => MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Initializing Task Tracker...',
                  style: TextStyle(
                    fontSize: TypographyConstants.bodyLarge,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Setting up your workspace...',
                  style: TextStyle(
                    fontSize: TypographyConstants.bodyMedium,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      error: (error, stackTrace) {
        
        return MaterialApp(
          home: Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      PhosphorIcons.warningCircle(),
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Failed to initialize app',
                      style: TextStyle(
                        fontSize: TypographyConstants.headlineMedium,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'The app encountered an error during startup. This might be due to corrupted data or insufficient device resources.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: TypographyConstants.bodyLarge,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (error.toString().isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                        ),
                        child: Text(
                          error.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: TypographyConstants.bodySmall,
                            color: Colors.grey[600],
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            // Retry initialization
                            ref.invalidate(appInitializationProvider);
                          },
                          icon: Icon(PhosphorIcons.arrowClockwise()),
                          label: const Text('Retry'),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton.icon(
                          onPressed: () {
                            // Clear app data and retry
                            _clearAppDataAndRetry();
                          },
                          icon: Icon(PhosphorIcons.trash()),
                          label: const Text('Reset & Retry'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  /// Clear app data and retry initialization
  void _clearAppDataAndRetry() async {
    try {
      // This would clear app data - implementation depends on data layer
      // For now, just retry
      ref.invalidate(appInitializationProvider);
    } catch (e) {
      // Handle error
    }
  }
}

/// Memory manager for periodic cleanup
class MemoryManager {
  static Timer? _cleanupTimer;
  
  static void startPeriodicCleanup() {
    // Start periodic cleanup every 5 minutes
    _cleanupTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      // Force garbage collection
      // Running periodic memory cleanup
      // Clear image cache when memory pressure is high
      PaintingBinding.instance.imageCache.clear();
      // Clear any cached network responses
      // This would typically be done by specific cache managers
    });
  }
  
  static void stopPeriodicCleanup() {
    // Stop periodic cleanup timer
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
  }
}



