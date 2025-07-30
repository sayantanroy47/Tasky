import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme mode options for the app
enum AppThemeMode {
  system,
  light,
  dark,
  highContrastLight,
  highContrastDark,
}

/// Extension to convert AppThemeMode to ThemeMode
extension AppThemeModeExtension on AppThemeMode {
  ThemeMode get themeMode {
    switch (this) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
      case AppThemeMode.highContrastLight:
        return ThemeMode.light;
      case AppThemeMode.dark:
      case AppThemeMode.highContrastDark:
        return ThemeMode.dark;
    }
  }

  String get displayName {
    switch (this) {
      case AppThemeMode.system:
        return 'System';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.highContrastLight:
        return 'High Contrast Light';
      case AppThemeMode.highContrastDark:
        return 'High Contrast Dark';
    }
  }

  bool get isHighContrast {
    return this == AppThemeMode.highContrastLight || 
           this == AppThemeMode.highContrastDark;
  }
}

/// Theme state class
class ThemeState {
  final AppThemeMode themeMode;
  final bool isDynamicColorEnabled;

  const ThemeState({
    this.themeMode = AppThemeMode.system,
    this.isDynamicColorEnabled = true,
  });

  ThemeState copyWith({
    AppThemeMode? themeMode,
    bool? isDynamicColorEnabled,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isDynamicColorEnabled: isDynamicColorEnabled ?? this.isDynamicColorEnabled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeState &&
        other.themeMode == themeMode &&
        other.isDynamicColorEnabled == isDynamicColorEnabled;
  }

  @override
  int get hashCode => Object.hash(themeMode, isDynamicColorEnabled);
}

/// Theme notifier for managing theme state
class ThemeNotifier extends StateNotifier<ThemeState> {
  static const String _themeKey = 'app_theme_mode';
  static const String _dynamicColorKey = 'dynamic_color_enabled';

  ThemeNotifier() : super(const ThemeState()) {
    _loadThemePreferences();
  }

  /// Load theme preferences from shared preferences
  Future<void> _loadThemePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final themeIndex = prefs.getInt(_themeKey) ?? 0;
      final isDynamicColorEnabled = prefs.getBool(_dynamicColorKey) ?? true;
      
      final themeMode = AppThemeMode.values[themeIndex.clamp(0, AppThemeMode.values.length - 1)];
      
      state = ThemeState(
        themeMode: themeMode,
        isDynamicColorEnabled: isDynamicColorEnabled,
      );
    } catch (e) {
      // If loading fails, keep default state
      debugPrint('Failed to load theme preferences: $e');
    }
  }

  /// Save theme preferences to shared preferences
  Future<void> _saveThemePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, state.themeMode.index);
      await prefs.setBool(_dynamicColorKey, state.isDynamicColorEnabled);
    } catch (e) {
      debugPrint('Failed to save theme preferences: $e');
    }
  }

  /// Set theme mode
  Future<void> setThemeMode(AppThemeMode themeMode) async {
    state = state.copyWith(themeMode: themeMode);
    await _saveThemePreferences();
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    final newTheme = switch (state.themeMode) {
      AppThemeMode.light => AppThemeMode.dark,
      AppThemeMode.dark => AppThemeMode.light,
      AppThemeMode.highContrastLight => AppThemeMode.highContrastDark,
      AppThemeMode.highContrastDark => AppThemeMode.highContrastLight,
      AppThemeMode.system => AppThemeMode.light,
    };
    
    await setThemeMode(newTheme);
  }

  /// Enable/disable dynamic color
  Future<void> setDynamicColorEnabled(bool enabled) async {
    state = state.copyWith(isDynamicColorEnabled: enabled);
    await _saveThemePreferences();
  }

  /// Check if current theme is dark
  bool isDarkMode(BuildContext context) {
    switch (state.themeMode) {
      case AppThemeMode.system:
        return MediaQuery.of(context).platformBrightness == Brightness.dark;
      case AppThemeMode.light:
      case AppThemeMode.highContrastLight:
        return false;
      case AppThemeMode.dark:
      case AppThemeMode.highContrastDark:
        return true;
    }
  }

  /// Get current brightness
  Brightness getBrightness(BuildContext context) {
    return isDarkMode(context) ? Brightness.dark : Brightness.light;
  }
}

/// Theme provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

/// Convenience provider for checking if dark mode is active
final isDarkModeProvider = Provider<bool>((ref) {
  final themeState = ref.watch(themeProvider);
  // This is a simplified check - in practice, you'd need BuildContext
  // to properly determine system theme
  switch (themeState.themeMode) {
    case AppThemeMode.system:
      return false; // Default to light for provider
    case AppThemeMode.light:
    case AppThemeMode.highContrastLight:
      return false;
    case AppThemeMode.dark:
    case AppThemeMode.highContrastDark:
      return true;
  }
});

/// Provider for current theme mode display name
final themeDisplayNameProvider = Provider<String>((ref) {
  final themeState = ref.watch(themeProvider);
  return themeState.themeMode.displayName;
});