import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/theme_registry.dart';
import '../theme/app_theme_data.dart';
import '../theme/theme_factory.dart';
import '../theme/themes/vegeta_blue_theme.dart';
import '../theme/themes/matrix_theme.dart';
import '../theme/themes/dracula_ide_theme.dart';
import '../theme/material3/expressive_theme.dart';

/// Enhanced theme state with more detailed information
class EnhancedThemeState {
  final AppThemeData? currentTheme;
  final ThemeData? flutterTheme;
  final ThemeData? darkFlutterTheme;
  final bool isLoading;
  final String? error;
  final bool isTransitioning;
  final double transitionProgress;

  const EnhancedThemeState({
    this.currentTheme,
    this.flutterTheme,
    this.darkFlutterTheme,
    this.isLoading = false,
    this.error,
    this.isTransitioning = false,
    this.transitionProgress = 0.0,
  });

  EnhancedThemeState copyWith({
    AppThemeData? currentTheme,
    ThemeData? flutterTheme,
    ThemeData? darkFlutterTheme,
    bool? isLoading,
    String? error,
    bool? isTransitioning,
    double? transitionProgress,
  }) {
    return EnhancedThemeState(
      currentTheme: currentTheme ?? this.currentTheme,
      flutterTheme: flutterTheme ?? this.flutterTheme,
      darkFlutterTheme: darkFlutterTheme ?? this.darkFlutterTheme,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isTransitioning: isTransitioning ?? this.isTransitioning,
      transitionProgress: transitionProgress ?? this.transitionProgress,
    );
  }

  bool get hasTheme => currentTheme != null;
  bool get hasError => error != null;
  String get currentThemeId => currentTheme?.metadata.id ?? 'default';
  String get currentThemeName => currentTheme?.metadata.name ?? 'Default';
}

/// Enhanced theme notifier with smooth transitions and theme registry integration
class EnhancedThemeNotifier extends StateNotifier<EnhancedThemeState> {
  static const String _keyCurrentThemeId = 'current_theme_id';
  static const String _keyThemeHistory = 'theme_history';
  static const int _maxHistorySize = 10;

  final ThemeRegistry _themeRegistry = ThemeRegistry();
  final List<String> _themeHistory = [];

  EnhancedThemeNotifier() : super(const EnhancedThemeState()) {
    _initializeThemes();
    _loadSavedTheme();
  }

  /// Initialize built-in themes
  void _initializeThemes() {
    debugPrint('🎨 Initializing built-in themes...');
    
    final themes = [
      // Material 3 Expressive themes - DEFAULT
      ExpressiveTheme.createLight(),
      ExpressiveTheme.createDark(),
      
      // Light variants
      VegetaBlueTheme.createLight(),
      MatrixTheme.createLight(),
      DraculaIDETheme.createLight(),
      
      // Dark variants
      VegetaBlueTheme.createDark(),
      MatrixTheme.createDark(),
      DraculaIDETheme.createDark(),
    ];
    
    debugPrint('🎨 Registering ${themes.length} themes');
    for (final theme in themes) {
      debugPrint('🎨 Registering: ${theme.metadata.id} (${theme.metadata.name})');
    }
    
    _themeRegistry.registerAll(themes);
    
    debugPrint('🎨 Theme registry now contains ${_themeRegistry.count} themes');
    debugPrint('🎨 Available themes: ${_themeRegistry.themes.map((t) => t.metadata.id).join(', ')}');
  }

  /// Load previously saved theme
  Future<void> _loadSavedTheme() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedThemeId = prefs.getString(_keyCurrentThemeId);
      final historyJson = prefs.getStringList(_keyThemeHistory) ?? [];
      
      _themeHistory.clear();
      _themeHistory.addAll(historyJson);
      
      if (savedThemeId != null && _themeRegistry.isRegistered(savedThemeId)) {
        debugPrint('🎨 Loading saved theme: $savedThemeId');
        await setTheme(savedThemeId, saveToPrefs: false);
      } else {
        // Set default theme to Matrix Dark for demo
        debugPrint('🎨 No saved theme found, setting default to: matrix_dark');
        await setTheme('matrix_dark', saveToPrefs: false);
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load saved theme: $e',
        isLoading: false,
      );
      // Fallback to matrix theme even in error case
      debugPrint('🎨 Error occurred, falling back to matrix_dark');
      await setTheme('matrix_dark', saveToPrefs: false);
    }
  }

  /// Set theme by ID with smooth transition
  Future<void> setTheme(String themeId, {bool saveToPrefs = true}) async {
    debugPrint('🎨 EnhancedThemeNotifier.setTheme() called with: $themeId');
    
    final theme = _themeRegistry.getTheme(themeId);
    if (theme == null) {
      debugPrint('🚫 Theme not found: $themeId');
      state = state.copyWith(
        error: 'Theme not found: $themeId',
        isLoading: false,
      );
      return;
    }
    
    debugPrint('✅ Theme found: ${theme.metadata.name} (${theme.metadata.id})');
    debugPrint('🎨 Background effects enabled: ${theme.effects.backgroundEffects.enableParticles}');
    debugPrint('🎨 Particle type: ${theme.effects.backgroundEffects.particleType}');
    debugPrint('🎨 Effect intensity: ${theme.effects.backgroundEffects.effectIntensity}');
    debugPrint('🎨 Particle opacity: ${theme.effects.backgroundEffects.particleOpacity}');

    // Start transition
    state = state.copyWith(
      isTransitioning: true,
      transitionProgress: 0.0,
      error: null,
    );

    try {
      // Simulate smooth transition
      await _animateTransition();
      
      // Get corresponding light/dark variants
      final lightThemeId = theme.metadata.id.replaceAll('_dark', '');
      final darkThemeId = theme.metadata.id.contains('_dark') 
          ? theme.metadata.id 
          : '${theme.metadata.id}_dark';
      
      final lightTheme = _themeRegistry.getTheme(lightThemeId) ?? theme;
      final darkTheme = _themeRegistry.getTheme(darkThemeId) ?? theme;
      
      // Create Flutter themes from appropriate variants
      final flutterTheme = ThemeFactory.createFlutterTheme(lightTheme);
      final darkFlutterTheme = ThemeFactory.createFlutterTheme(darkTheme);

      // Update state
      state = state.copyWith(
        currentTheme: theme,
        flutterTheme: flutterTheme,
        darkFlutterTheme: darkFlutterTheme,
        isLoading: false,
        isTransitioning: false,
        transitionProgress: 1.0,
      );

      // Save to preferences and update history
      if (saveToPrefs) {
        await _saveThemePreferences(themeId);
        _updateThemeHistory(themeId);
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to apply theme: $e',
        isLoading: false,
        isTransitioning: false,
      );
    }
  }

  /// Animate transition progress
  Future<void> _animateTransition() async {
    const steps = 10;
    const stepDuration = Duration(milliseconds: 30);
    
    for (int i = 0; i <= steps; i++) {
      state = state.copyWith(
        transitionProgress: i / steps,
      );
      await Future.delayed(stepDuration);
    }
  }

  /// Save theme preferences
  Future<void> _saveThemePreferences(String themeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyCurrentThemeId, themeId);
      await prefs.setStringList(_keyThemeHistory, _themeHistory);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Update theme history
  void _updateThemeHistory(String themeId) {
    _themeHistory.remove(themeId); // Remove if already exists
    _themeHistory.insert(0, themeId); // Add to beginning
    
    // Limit history size
    if (_themeHistory.length > _maxHistorySize) {
      _themeHistory.removeRange(_maxHistorySize, _themeHistory.length);
    }
  }

  /// Get all available themes
  List<AppThemeData> getAllThemes() {
    final themes = _themeRegistry.themes.toList();
    debugPrint('🎨 getAllThemes() called - returning ${themes.length} themes');
    if (themes.isEmpty) {
      debugPrint('🚫 No themes found in registry! Registry count: ${_themeRegistry.count}');
    }
    return themes;
  }

  /// Get themes by category
  List<AppThemeData> getThemesByCategory(String category) {
    return _themeRegistry.getThemesByCategory(category);
  }

  /// Search themes
  List<AppThemeData> searchThemes(String query) {
    return _themeRegistry.searchThemes(query);
  }

  /// Get theme history
  List<AppThemeData> getThemeHistory() {
    return _themeHistory
        .map((id) => _themeRegistry.getTheme(id))
        .where((theme) => theme != null)
        .cast<AppThemeData>()
        .toList();
  }

  /// Get theme categories
  Set<String> getCategories() {
    return _themeRegistry.categories;
  }

  /// Get theme by ID
  AppThemeData? getTheme(String id) {
    return _themeRegistry.getTheme(id);
  }

  /// Register a new theme
  void registerTheme(AppThemeData theme) {
    _themeRegistry.register(theme);
  }

  /// Unregister a theme
  bool unregisterTheme(String id) {
    return _themeRegistry.unregister(id);
  }

  /// Get theme statistics
  Map<String, dynamic> getThemeStatistics() {
    return _themeRegistry.getStatistics();
  }

  /// Cycle to next theme in current category
  Future<void> cycleToNextTheme() async {
    if (state.currentTheme == null) return;
    
    final currentCategory = state.currentTheme!.metadata.category;
    final categoryThemes = getThemesByCategory(currentCategory);
    
    if (categoryThemes.length <= 1) return;
    
    final currentIndex = categoryThemes.indexWhere(
      (theme) => theme.metadata.id == state.currentTheme!.metadata.id,
    );
    
    final nextIndex = (currentIndex + 1) % categoryThemes.length;
    await setTheme(categoryThemes[nextIndex].metadata.id);
  }

  /// Apply random theme
  Future<void> applyRandomTheme() async {
    final themes = getAllThemes();
    if (themes.isEmpty) return;
    
    themes.shuffle();
    final randomTheme = themes.first;
    await setTheme(randomTheme.metadata.id);
  }

  /// Reset to default theme
  Future<void> resetToDefault() async {
    await setTheme('dracula_ide_dark');
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Enhanced theme provider
final enhancedThemeProvider = StateNotifierProvider<EnhancedThemeNotifier, EnhancedThemeState>(
  (ref) => EnhancedThemeNotifier(),
);

/// Provider for current Flutter theme
final currentFlutterThemeProvider = Provider<ThemeData?>((ref) {
  final themeState = ref.watch(enhancedThemeProvider);
  return themeState.flutterTheme;
});

/// Provider for current Flutter dark theme
final currentFlutterDarkThemeProvider = Provider<ThemeData?>((ref) {
  final themeState = ref.watch(enhancedThemeProvider);
  return themeState.darkFlutterTheme;
});

/// Provider for theme mode (dynamically changes based on selected theme)
final themeModeProvider = Provider<ThemeMode>((ref) {
  final themeState = ref.watch(enhancedThemeProvider);
  
  if (themeState.currentTheme == null) {
    return ThemeMode.system;
  }
  
  // Determine if the current theme is light or dark based on theme ID
  final themeId = themeState.currentTheme!.metadata.id;
  final isLightTheme = !themeId.contains('_dark');
  
  return isLightTheme ? ThemeMode.light : ThemeMode.dark;
});

/// Provider for all available themes
final availableThemesProvider = Provider<List<AppThemeData>>((ref) {
  final themeNotifier = ref.watch(enhancedThemeProvider.notifier);
  ref.watch(enhancedThemeProvider); // Watch state changes to trigger updates
  return themeNotifier.getAllThemes();
});

/// Provider for theme categories
final themeCategoriesProvider = Provider<Set<String>>((ref) {
  final themeNotifier = ref.watch(enhancedThemeProvider.notifier);
  return themeNotifier.getCategories();
});

/// Provider for theme history
final themeHistoryProvider = Provider<List<AppThemeData>>((ref) {
  final themeNotifier = ref.watch(enhancedThemeProvider.notifier);
  ref.watch(enhancedThemeProvider); // Watch state changes
  return themeNotifier.getThemeHistory();
});

/// Provider for theme statistics
final themeStatisticsProvider = Provider<Map<String, dynamic>>((ref) {
  final themeNotifier = ref.watch(enhancedThemeProvider.notifier);
  ref.watch(enhancedThemeProvider); // Watch state changes
  return themeNotifier.getThemeStatistics();
});

/// Helper extensions for theme state
extension EnhancedThemeStateX on EnhancedThemeState {
  bool get canTransition => !isLoading && !isTransitioning;
  
  bool get isDarkTheme {
    return (currentTheme?.colors.background.computeLuminance() ?? 0.5) < 0.5;
  }
  
  Color get primaryColor => currentTheme?.colors.primary ?? Colors.blue;
  Color get backgroundColor => currentTheme?.colors.background ?? Colors.white;
  
  String get themeDescription => currentTheme?.metadata.description ?? 'Default theme';
  List<String> get themeTags => currentTheme?.metadata.tags ?? [];
}