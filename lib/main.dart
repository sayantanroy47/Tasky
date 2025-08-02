import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/providers/theme_provider.dart';
import 'domain/models/enums.dart';
import 'core/routing/app_router.dart';
import 'presentation/widgets/app_initialization_wrapper.dart';
import 'services/performance_service.dart';

void main() async {
  // Start performance monitoring early
  final performanceService = PerformanceService();
  performanceService.startTimer('app_startup_total');
  
  WidgetsFlutterBinding.ensureInitialized();
  
  // Performance optimizations
  await _performStartupOptimizations(performanceService);
  
  performanceService.stopTimer('app_startup_total');
  
  runApp(
    ProviderScope(
      overrides: [
        performanceServiceProvider.overrideWithValue(performanceService),
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
    
    // Optimize system UI
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top],
    );
    
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
    final themeState = ref.watch(themeProvider);
    
    return AppInitializationWrapper(
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: _getTheme(themeState, false),
        darkTheme: _getTheme(themeState, true),
        themeMode: themeState.themeMode.themeMode,
        initialRoute: AppRouter.initialRoute,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }

  /// Get appropriate theme based on theme state and brightness
  ThemeData _getTheme(ThemeState themeState, bool isDark) {
    switch (themeState.themeMode) {
      case AppThemeMode.highContrastLight:
        return AppTheme.highContrastLightTheme;
      case AppThemeMode.highContrastDark:
        return AppTheme.highContrastDarkTheme;
      case AppThemeMode.system:
      case AppThemeMode.light:
      case AppThemeMode.dark:
        return isDark ? AppTheme.darkTheme : AppTheme.lightTheme;
    }
  }
}
