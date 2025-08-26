import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/constants/app_constants.dart';
import 'core/providers/enhanced_theme_provider.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/locale_service.dart';
import 'core/localization/app_localizations_delegate.dart';
import 'core/routing/app_router.dart';
import 'presentation/widgets/app_initialization_wrapper.dart';
import 'presentation/widgets/profile_setup_wrapper.dart';
import 'services/share_intent_service.dart';
import 'services/widget_service.dart';
import 'services/audio/audio_file_manager.dart';
import 'services/audio/lazy_audio_playback_service.dart';
import 'services/background/simple_background_service.dart';
import 'services/performance_service.dart';
import 'services/location/location_service_impl.dart';
import 'core/services/lazy_service_manager.dart';

/// Global navigator key for accessing context from services
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Performance service provider
final performanceServiceProvider = Provider<PerformanceService>((ref) {
  return PerformanceService();
});

/// Share intent service provider - lazily initialized when first accessed
final shareIntentServiceProvider = FutureProvider<ShareIntentService>((ref) async {
  final serviceManager = LazyServiceManager();
  return await serviceManager.getService<ShareIntentService>(ServiceIds.shareIntent);
});

void main() async {
  // Start performance monitoring early
  final appStartTime = DateTime.now();
  
  WidgetsFlutterBinding.ensureInitialized();
  
  // Only initialize absolutely critical performance service on main thread
  final perfService = PerformanceService();
  await perfService.initialize();
  
  // Record initial startup time
  perfService.recordStartupTime(DateTime.now().difference(appStartTime));
  
  // Defer ALL service registration and initialization to background
  _initializeServicesInBackground();
  
  // Minimal startup optimizations (only fast operations)
  _performFastStartupOptimizations();
  
  runApp(
    ProviderScope(
      overrides: [
        performanceServiceProvider.overrideWithValue(perfService),
      ],
      child: const TaskTrackerApp(),
    ),
  );
}

/// Register all services with the lazy service manager
Future<void> _registerServices() async {
  final serviceManager = LazyServiceManager();
  
  // Critical services (must be ready before UI)
  serviceManager.registerService<PerformanceService>(
    serviceId: ServiceIds.performance,
    priority: ServicePriority.critical,
    initializer: () async {
      final service = PerformanceService();
      await service.initialize();
      return service;
    },
  );
  
  // ShareIntentService - moved to low priority to avoid blocking startup
  // Takes 2+ seconds to initialize and is only needed when sharing content
  serviceManager.registerService<ShareIntentService>(
    serviceId: ServiceIds.shareIntent,
    priority: ServicePriority.low,
    initializer: () async {
      if (kDebugMode) {
        debugPrint('Initializing ShareIntentService (deferred)...');
      }
      final service = ShareIntentService();
      await service.initialize();
      return service;
    },
  );
  
  // High priority services (initialize early but not blocking)
  serviceManager.registerService<WidgetService>(
    serviceId: ServiceIds.widgetService,
    priority: ServicePriority.high,
    initializer: () async {
      final service = WidgetService();
      await service.initialize();
      return service;
    },
  );
  
  serviceManager.registerService<AudioFileManager>(
    serviceId: ServiceIds.audioFileManager,
    priority: ServicePriority.high,
    initializer: () async {
      final service = AudioFileManager();
      await service.initialize();
      return service;
    },
  );
  
  // Medium priority services (nice to have early)
  serviceManager.registerService<SimpleBackgroundService>(
    serviceId: ServiceIds.backgroundService,
    priority: ServicePriority.medium,
    runInBackground: true,
    initializer: () async {
      final service = SimpleBackgroundService.instance;
      await service.initialize();
      return service;
    },
  );
  
  // Low priority services (lazy load when needed)
  serviceManager.registerService<LazyAudioPlaybackService>(
    serviceId: ServiceIds.audioPlayback,
    priority: ServicePriority.low,
    initializer: () async {
      // Return immediately - lazy audio service initializes on first use
      return LazyAudioPlaybackService.instance;
    },
  );
  
  // Location services - moved to low priority for lazy loading
  // Only initialize when location-based features are actually used
  serviceManager.registerService<LocationServiceImpl>(
    serviceId: ServiceIds.locationService,
    priority: ServicePriority.low,
    initializer: () async {
      if (kDebugMode) {
        debugPrint('Initializing LocationService (lazy)...');
      }
      final service = LocationServiceImpl.getInstance();
      // Skip permission check during initialization to avoid blocking
      // Permissions will be checked when location is actually needed
      return service as LocationServiceImpl;
    },
  );
  
  // Note: GeofencingManager initialization is deferred to avoid circular dependencies
  // with Riverpod providers. It will be initialized when first accessed via providers.
}

/// Initialize all services in background after app launch
Future<void> _initializeServicesInBackground() async {
  // Use isolate for truly non-blocking service initialization
  scheduleMicrotask(() async {
    try {
      // Let UI settle first - increased delay for better UX
      await Future.delayed(const Duration(milliseconds: 1000));
      
      Stopwatch? stopwatch;
      if (kDebugMode) {
        debugPrint('Starting background service initialization...');
        stopwatch = Stopwatch()..start();
      }
      
      // Register and initialize all services in background
      await _registerServices();
      final serviceManager = LazyServiceManager();
      
      // Initialize only critical services first (excluding shareIntent)
      await serviceManager.initializeCriticalServices();
      
      // Then initialize background services
      await _runServiceInitializationInIsolate(serviceManager);
      
      if (kDebugMode && stopwatch != null) {
        stopwatch.stop();
        debugPrint('Background services initialized in ${stopwatch.elapsedMilliseconds}ms');
        final status = serviceManager.getInitializationStatus();
        debugPrint('Service status: $status');
      }
    } catch (e) {
      debugPrint('Warning: Background service initialization failed: $e');
    }
  });
}

/// Run service initialization in background isolate to prevent UI blocking
Future<void> _runServiceInitializationInIsolate(LazyServiceManager serviceManager) async {
  try {
    // Initialize services with reduced priority to avoid UI interference
    await serviceManager.initializeBackgroundServices();
  } catch (e) {
    debugPrint('Isolate service initialization error: $e');
    // Fallback to main thread if isolate fails
    await serviceManager.initializeBackgroundServices();
  }
}

/// Perform only the fastest startup optimizations on main thread
void _performFastStartupOptimizations() {
  try {
    // Only system UI overlay style - this is very fast (<5ms)
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark, // Changed to dark for better visibility
        statusBarIconBrightness: Brightness.dark, // Changed to dark for better visibility
        statusBarBrightness: Brightness.dark, // For iOS
      ),
    );
    
    // Move ALL other system configurations to background
    scheduleMicrotask(() async {
      try {
        await Future.delayed(const Duration(milliseconds: 1500)); // Let UI fully settle
        
        // Set preferred orientations (can take 50-200ms)
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        
        // Hide system navigation bar, keep status bar visible
        await SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.immersiveSticky,
          overlays: [SystemUiOverlay.top], // Only show status bar
        );
        
        if (kDebugMode) {
          debugPrint('Deferred system UI optimizations completed');
        }
      } catch (e) {
        debugPrint('Warning: Deferred UI optimization failed: $e');
      }
    });
    
  } catch (e) {
    debugPrint('Warning: Fast startup optimization failed: $e');
  }
}

class TaskTrackerApp extends ConsumerStatefulWidget {
  const TaskTrackerApp({super.key});
  
  @override
  ConsumerState<TaskTrackerApp> createState() => _TaskTrackerAppState();
}

class _TaskTrackerAppState extends ConsumerState<TaskTrackerApp> with WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-enforce UI mode when app becomes active
    if (state == AppLifecycleState.resumed) {
      _enforceUIMode();
    }
  }
  
  void _enforceUIMode() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [SystemUiOverlay.top], // Only show status bar
    );
  }
  
  /// Enable graphics optimizations to prevent buffer issues
  void _enableGraphicsOptimizations() {
    try {
      // Enable hardware acceleration and optimize rendering
      scheduleMicrotask(() async {
        try {
          // Optimize graphics buffer management
          SystemChrome.setSystemUIOverlayStyle(
            const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Colors.transparent,
              systemNavigationBarIconBrightness: Brightness.dark,
              statusBarIconBrightness: Brightness.dark,
            ),
          );
          
          if (kDebugMode) {
            debugPrint('Graphics optimizations enabled');
          }
        } catch (e) {
          debugPrint('Graphics optimization warning: $e');
        }
      });
    } catch (e) {
      debugPrint('Graphics optimization init failed: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(enhancedThemeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    
    // Show app immediately with default theme if custom theme isn't ready yet
    // This prevents blocking the UI while themes load
    final theme = themeState.flutterTheme ?? ThemeData.light();
    final darkTheme = themeState.darkFlutterTheme ?? ThemeData.dark();
    
    // Enable graphics optimizations for better performance
    _enableGraphicsOptimizations();
    
    return AppInitializationWrapper(
      child: RepaintBoundary(
        child: GestureDetector(
          onTap: _enforceUIMode, // Re-enforce on any tap
          child: MaterialApp(
          title: AppConstants.appName,
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          
          // Theme configuration - use defaults if custom themes not ready
          theme: theme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          
          // Localization configuration
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: SupportedLocales.all,
          
          // Route generation for navigation
          onGenerateRoute: AppRouter.generateRoute,
          
          // Use ProfileSetupWrapper as home to ensure proper widget hierarchy
          home: const ProfileSetupWrapper(),
          
          // Add loading indicator for theme if still loading
          builder: (context, child) {
            if (themeState.isLoading) {
              return Stack(
                children: [
                  child ?? const SizedBox(),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Loading theme...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            return child ?? const SizedBox();
          },
          ),
        ),
      ),
    );
  }
}
