import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/routing/app_router.dart';
import 'core/providers/enhanced_theme_provider.dart';
import 'presentation/widgets/app_initialization_wrapper.dart';
import 'services/performance_service.dart';
import 'services/share_intent_service.dart';
import 'services/widget_service.dart';

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
  final performanceService = PerformanceService();
  performanceService.startTimer('app_startup_total');
  
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services early
  final shareIntentService = ShareIntentService();
  final widgetService = WidgetService();
  
  // Performance optimizations
  await _performStartupOptimizations(performanceService);
  
  // Initialize share intent service
  await shareIntentService.initialize();
  
  // Initialize widget service
  await widgetService.initialize();
  
  performanceService.stopTimer('app_startup_total');
  
  runApp(
    ProviderScope(
      overrides: [
        performanceServiceProvider.overrideWithValue(performanceService),
        shareIntentServiceProvider.overrideWithValue(shareIntentService),
      ],
      child: const TaskTrackerApp(),
    ),
  );
}

/// Perform startup optimizations
Future<void> _performStartupOptimizations(PerformanceService performanceService) async {
  performanceService.startTimer('startup_optimizations');
  
  try {
    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
    
    // Initialize performance service
    await performanceService.initialize();
    
    // Preload critical resources in debug mode
    if (kDebugMode) {
      // Warm up the rendering pipeline
      WidgetsBinding.instance.deferFirstFrame();
      WidgetsBinding.instance.allowFirstFrame();
    }
    
  } catch (e) {
    // Log startup optimization errors but don't block app startup
    performanceService.recordMetric(
      'startup_optimization_error',
      Duration.zero,
      metadata: {'error': e.toString()},
    );
  }
  
  performanceService.stopTimer('startup_optimizations');
}

class TaskTrackerApp extends ConsumerWidget {
  const TaskTrackerApp({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(enhancedThemeProvider);
    final themeMode = ref.watch(themeModeProvider);
    
    return AppInitializationWrapper(
      child: MaterialApp(
        title: AppConstants.appName,
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: themeState.flutterTheme ?? ThemeData.light(useMaterial3: true),
        darkTheme: themeState.darkFlutterTheme ?? ThemeData.dark(useMaterial3: true),
        themeMode: themeMode,
        initialRoute: AppRouter.initialRoute,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
