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
import 'services/background/simple_background_service.dart';
import 'services/performance_service.dart';

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
  final perfService = PerformanceService();
  await perfService.initialize();
  
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services early
  final shareIntentService = ShareIntentService();
  final widgetService = WidgetService();
  final audioFileManager = AudioFileManager();
  final backgroundService = SimpleBackgroundService.instance;
  
  // Startup optimizations
  await _performStartupOptimizations(appStartTime, perfService);
  
  // Initialize share intent service
  await shareIntentService.initialize();
  
  // Initialize widget service
  await widgetService.initialize();
  
  // Initialize audio file manager
  try {
    await audioFileManager.initialize();
  } catch (e) {
    debugPrint('Warning: Audio file manager initialization failed: $e');
    // Don't fail app startup if audio services fail
  }
  
  // Initialize background service
  try {
    await backgroundService.initialize();
    debugPrint('Background service initialized successfully');
  } catch (e) {
    debugPrint('Warning: Background service initialization failed: $e');
    // Don't fail app startup if background service fails
  }
  
  
  
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

/// Perform startup optimizations
Future<void> _performStartupOptimizations(DateTime appStartTime, PerformanceService perfService) async {
  
  try {
    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // Hide navigation bar but keep status bar visible
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [SystemUiOverlay.top],
    );
    
    // Set system UI overlay style - transparent navigation bar, visible status bar
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
    
    // Preload critical resources in debug mode
    if (kDebugMode) {
      // Warm up the rendering pipeline
      WidgetsBinding.instance.deferFirstFrame();
      WidgetsBinding.instance.allowFirstFrame();
    }
    
  } catch (e) {
    // Log startup optimization errors but don't block app startup
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
    
    // Wait for theme to finish loading before showing the app
    if (themeState.isLoading || themeState.flutterTheme == null) {
      return const MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
      );
    }
    
    return AppInitializationWrapper(
      child: GestureDetector(
        onTap: _enforceUIMode, // Re-enforce on any tap
        child: MaterialApp(
          title: AppConstants.appName,
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          
          // Theme configuration
          theme: themeState.flutterTheme!,
          darkTheme: themeState.darkFlutterTheme!,
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
        ),
      ),
    );
  }
}
