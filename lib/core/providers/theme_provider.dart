import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../../domain/models/enums.dart';

/// Theme state
class ThemeState {
  final AppThemeMode themeMode;
  final bool isLoading;
  final bool isDynamicColorEnabled;

  const ThemeState({
    this.themeMode = AppThemeMode.system,
    this.isLoading = false,
    this.isDynamicColorEnabled = false,
  });

  ThemeState copyWith({
    AppThemeMode? themeMode,
    bool? isLoading,
    bool? isDynamicColorEnabled,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isLoading: isLoading ?? this.isLoading,
      isDynamicColorEnabled: isDynamicColorEnabled ?? this.isDynamicColorEnabled,
    );
  }
}

/// Theme notifier
class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(const ThemeState()) {
    _loadTheme();
  }

  /// Load theme from preferences
  Future<void> _loadTheme() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeName = prefs.getString(AppConstants.keyThemeMode);
      
      if (themeName != null) {
        final themeMode = AppThemeMode.values.firstWhere(
          (mode) => mode.name == themeName,
          orElse: () => AppThemeMode.system,
        );
        state = state.copyWith(themeMode: themeMode, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Set theme mode
  Future<void> setThemeMode(AppThemeMode themeMode) async {
    state = state.copyWith(themeMode: themeMode);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyThemeMode, themeMode.name);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    final newMode = state.themeMode == AppThemeMode.dark 
        ? AppThemeMode.light 
        : AppThemeMode.dark;
    await setThemeMode(newMode);
  }

  /// Check if current theme is dark mode
  bool isDarkMode(context) {
    return state.themeMode == AppThemeMode.dark ||
           (state.themeMode == AppThemeMode.system && 
            MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  /// Set dynamic color enabled (placeholder for future implementation)
  Future<void> setDynamicColorEnabled(bool enabled) async {
    // This would be implemented when dynamic color support is added
    // For now, this is a placeholder
  }
}

/// Theme provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});