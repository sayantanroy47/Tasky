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

/// Global navigator key for accessing context from services
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Performance service provider

/// Share intent service provider
final shareIntentServiceProvider = Provider<ShareIntentService>((ref) {
  return ShareIntentService();
});

void main() async {
  // Start performance monitoring early
  
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services early
  final shareIntentService = ShareIntentService();
  final widgetService = WidgetService();
  final audioFileManager = AudioFileManager();
  
  // Startup optimizations
  await _performStartupOptimizations();
  
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
  
  
  
  runApp(
    ProviderScope(
      overrides: [
        shareIntentServiceProvider.overrideWithValue(shareIntentService),
      ],
      child: const TaskTrackerApp(),
    ),
  );
}

/// Perform startup optimizations
Future<void> _performStartupOptimizations() async {
  
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

class TaskTrackerApp extends ConsumerWidget {
  const TaskTrackerApp({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(enhancedThemeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    
    return AppInitializationWrapper(
      child: MaterialApp(
        title: AppConstants.appName,
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        
        // Theme configuration
        theme: themeState.flutterTheme ?? ThemeData.light(useMaterial3: true),
        darkTheme: themeState.darkFlutterTheme ?? ThemeData.dark(useMaterial3: true),
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
    );
  }
}
