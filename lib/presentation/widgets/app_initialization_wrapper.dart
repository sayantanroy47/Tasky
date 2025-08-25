import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart' show shareIntentServiceProvider;
import '../../core/providers/core_providers.dart';
import '../providers/initialization_providers.dart';
import '../providers/background_service_providers.dart';
import '../../core/theme/typography_constants.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'standardized_text.dart';
import 'standardized_colors.dart';
import 'standardized_spacing.dart';
import 'standardized_error_states.dart';

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
                SizedBox(
                  width: 48,
                  height: 48,
                  child: StandardizedErrorStates.loading(),
                ),
                StandardizedGaps.lg,
                const StandardizedText(
                  'Initializing Task Tracker...',
                  style: StandardizedTextStyle.headlineSmall,
                ),
                StandardizedGaps.vertical(SpacingSize.sm),
                Builder(
                  builder: (context) => StandardizedText(
                    'Setting up your workspace...',
                    style: StandardizedTextStyle.bodyMedium,
                    color: context.colors.withSemanticOpacity(
                      Theme.of(context).colorScheme.onSurface,
                      SemanticOpacity.strong,
                    ),
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
                padding: StandardizedSpacing.padding(SpacingSize.lg),
                child: Builder(
                  builder: (context) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Icon(
                      PhosphorIcons.warningCircle(),
                      size: 64,
                      color: context.colors.error,
                    ),
                    StandardizedGaps.lg,
                    const StandardizedText(
                      'Failed to initialize app',
                      style: StandardizedTextStyle.headlineMedium,
                    ),
                    StandardizedGaps.vertical(SpacingSize.sm),
                    StandardizedText(
                      'The app encountered an error during startup. This might be due to corrupted data or insufficient device resources.',
                      textAlign: TextAlign.center,
                      style: StandardizedTextStyle.bodyLarge,
                      color: context.colors.withSemanticOpacity(
                        Theme.of(context).colorScheme.onSurface,
                        SemanticOpacity.strong,
                      ),
                    ),
                    StandardizedGaps.vertical(SpacingSize.xs),
                    if (error.toString().isNotEmpty)
                      Container(
                        padding: StandardizedSpacing.padding(SpacingSize.sm),
                        margin: StandardizedSpacing.marginSymmetric(vertical: SpacingSize.xs),
                        decoration: BoxDecoration(
                          color: context.colors.withSemanticOpacity(
                            Theme.of(context).colorScheme.surfaceContainerHighest,
                            SemanticOpacity.subtle,
                          ),
                          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                        ),
                        child: StandardizedText(
                          error.toString(),
                          textAlign: TextAlign.center,
                          style: StandardizedTextStyle.bodySmall,
                          color: context.colors.withSemanticOpacity(
                            Theme.of(context).colorScheme.onSurface,
                            SemanticOpacity.strong,
                          ),
                        ),
                      ),
                    StandardizedGaps.lg,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            // Retry initialization
                            ref.invalidate(appInitializationProvider);
                          },
                          icon: Icon(PhosphorIcons.arrowClockwise()),
                          label: const StandardizedText(
                            'Retry',
                            style: StandardizedTextStyle.buttonText,
                          ),
                        ),
                        StandardizedGaps.horizontal(SpacingSize.md),
                        OutlinedButton.icon(
                          onPressed: () {
                            // Clear app data and retry
                            _clearAppDataAndRetry();
                          },
                          icon: Icon(PhosphorIcons.trash()),
                          label: const StandardizedText(
                            'Reset & Retry',
                            style: StandardizedTextStyle.buttonText,
                          ),
                        ),
                      ],
                    ),
                    ],
                  ),
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



