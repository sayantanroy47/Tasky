import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart' show performanceServiceProvider, shareIntentServiceProvider;
import '../../core/providers/core_providers.dart';
import '../providers/initialization_providers.dart';
import '../providers/task_providers.dart';
import '../../core/theme/typography_constants.dart';

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
    
    // Start performance monitoring
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final performanceService = ref.read(performanceServiceProvider);
      performanceService.startTimer('app_initialization');
      
      // Set context for ShareIntentService
      final shareIntentService = ref.read(shareIntentServiceProvider);
      final taskRepository = ref.read(taskRepositoryProvider);
      shareIntentService.setContext(context);
      shareIntentService.setTaskRepository(taskRepository);
      
      // Start memory management
      MemoryManager.startPeriodicCleanup();
    });
  }

  @override
  void dispose() {
    // Stop memory management
    MemoryManager.stopPeriodicCleanup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initializationAsync = ref.watch(appInitializationProvider);
    final performanceService = ref.watch(performanceServiceProvider);

    return initializationAsync.when(
      data: (_) {
        // Stop initialization timer when complete
        WidgetsBinding.instance.addPostFrameCallback((_) {
          performanceService.stopTimer('app_initialization');
        });
        
        return PerformanceMonitor(
          operationName: 'main_app_render',
          child: widget.child,
        );
      },
      loading: () => MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 48,
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
                  'Optimizing performance...',
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
        // Record initialization error
        performanceService.recordMetric(
          'app_initialization_error',
          Duration.zero,
          metadata: {
            'error': error.toString(),
            'stack_trace': stackTrace.toString(),
          },
        );
        
        return MaterialApp(
          home: Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Failed to initialize app',
                      style: TextStyle(
                        fontSize: TypographyConstants.headlineMedium,
                        fontWeight: FontWeight.bold,
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
                            performanceService.startTimer('app_initialization_retry');
                            ref.invalidate(appInitializationProvider);
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton.icon(
                          onPressed: () {
                            // Clear app data and retry
                            _clearAppDataAndRetry();
                          },
                          icon: const Icon(Icons.delete_sweep),
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
  static void startPeriodicCleanup() {
    // TODO: Implement periodic cleanup
  }
  
  static void stopPeriodicCleanup() {
    // TODO: Implement cleanup stop
  }
}

/// Performance monitor widget for tracking render performance
class PerformanceMonitor extends StatelessWidget {
  final String operationName;
  final Widget child;
  
  const PerformanceMonitor({
    super.key,
    required this.operationName,
    required this.child,
  });
  
  @override
  Widget build(BuildContext context) {
    // TODO: Implement performance monitoring
    return child;
  }
}