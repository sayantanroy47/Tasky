import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/providers/theme_provider.dart';
import 'core/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(
    const ProviderScope(
      child: TaskTrackerApp(),
    ),
  );
}

class TaskTrackerApp extends ConsumerWidget {
  const TaskTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: _getTheme(themeState, false),
      darkTheme: _getTheme(themeState, true),
      themeMode: themeState.themeMode.themeMode,
      initialRoute: AppRouter.initialRoute,
      onGenerateRoute: AppRouter.generateRoute,
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
