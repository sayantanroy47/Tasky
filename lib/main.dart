import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/constants/app_constants.dart';
import 'core/routing/app_router.dart';
import 'core/providers/enhanced_theme_provider.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/locale_service.dart';
import 'core/localization/app_localizations_delegate.dart';
import 'presentation/widgets/app_initialization_wrapper.dart';
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

/// Share intent service provider
final shareIntentServiceProvider = Provider<ShareIntentService>((ref) {
  return ShareIntentService();
});

void main() async {
  // Start performance monitoring early
  final appStartTime = DateTime.now();
  
  WidgetsFlutterBinding.ensureInitialized();
  
  // Register all services with lazy service manager
  await _registerServices();
  
  // Initialize only critical services that must be ready before UI shows
  final serviceManager = LazyServiceManager();
  await serviceManager.initializeCriticalServices();
  
  // Get critical services
  final perfService = await serviceManager.getService<PerformanceService>(ServiceIds.performance);
  final shareIntentService = await serviceManager.getService<ShareIntentService>(ServiceIds.shareIntent);
  
  // Startup optimizations (lightweight only)
  await _performStartupOptimizations(appStartTime, perfService);
  
  // Start background service initialization (non-blocking)
  _initializeBackgroundServices(serviceManager);
  
  runApp(
    ProviderScope(
      overrides: [
        shareIntentServiceProvider.overrideWithValue(shareIntentService),
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
  
  serviceManager.registerService<ShareIntentService>(
    serviceId: ServiceIds.shareIntent,
    priority: ServicePriority.critical,
    initializer: () async {
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
  
  // Location services (medium priority - needed for location-based tasks)
  serviceManager.registerService<LocationServiceImpl>(
    serviceId: ServiceIds.locationService,
    priority: ServicePriority.medium,
    initializer: () async {
      final service = LocationServiceImpl.getInstance();
      // Pre-initialize location permissions if possible
      try {
        await service.checkPermission();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Location permission check failed during initialization: $e');
        }
      }
      return service as LocationServiceImpl;
    },
  );
  
  // Note: GeofencingManager initialization is deferred to avoid circular dependencies
  // with Riverpod providers. It will be initialized when first accessed via providers.
}

/// Initialize background services without blocking startup
Future<void> _initializeBackgroundServices(LazyServiceManager serviceManager) async {
  // Run in microtask to not block main thread
  scheduleMicrotask(() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100)); // Let UI settle first
      await serviceManager.initializeBackgroundServices();
      
      if (kDebugMode) {
        debugPrint('Background services initialization completed');
        final status = serviceManager.getInitializationStatus();
        debugPrint('Service status: $status');
      }
    } catch (e) {
      debugPrint('Warning: Background service initialization failed: $e');
    }
  });
}

/// Perform startup optimizations (lightweight only - heavy operations moved to background)
Future<void> _performStartupOptimizations(DateTime appStartTime, PerformanceService perfService) async {
  try {
    // Only do lightweight operations here to not block startup
    
    // Set system UI overlay style - this is fast
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark, // For iOS
      ),
    );
    
    // Record startup performance
    perfService.recordStartupTime(DateTime.now().difference(appStartTime));
    
    // Move heavy operations to background
    scheduleMicrotask(() async {
      try {
        // Set preferred orientations (can be slow)
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        
        // Hide navigation bar but keep status bar visible (can be slow)
        await SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.immersiveSticky,
          overlays: [SystemUiOverlay.top],
        );
        
        if (kDebugMode) {
          debugPrint('Background startup optimizations completed');
        }
      } catch (e) {
        debugPrint('Warning: Background startup optimization failed: $e');
      }
    });
    
  } catch (e) {
    // Log startup optimization errors but don't block app startup
    debugPrint('Warning: Startup optimization failed: $e');
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
      overlays: [SystemUiOverlay.top],
    );
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
    
    return AppInitializationWrapper(
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
          
          // Routing
          initialRoute: AppRouter.initialRoute,
          onGenerateRoute: AppRouter.generateRoute,
          
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
    );
  }
}
