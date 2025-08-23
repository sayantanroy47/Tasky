import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_registry.dart';
import '../theme/app_theme_data.dart';
import '../theme/theme_factory.dart';
import '../theme/theme_persistence_service.dart';
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
  final ThemePreferences preferences;
  final List<String> favoriteThemes;
  final Map<String, ThemeUsageStats> usageStats;

  const EnhancedThemeState({
    this.currentTheme,
    this.flutterTheme,
    this.darkFlutterTheme,
    this.isLoading = false,
    this.error,
    this.isTransitioning = false,
    this.transitionProgress = 0.0,
    this.preferences = const ThemePreferences(
      autoSwitchEnabled: false,
      followSystemTheme: true,
      scheduledChanges: [],
      animationsEnabled: true,
      animationDuration: Duration(milliseconds: 300),
    ),
    this.favoriteThemes = const [],
    this.usageStats = const {},
  });

  EnhancedThemeState copyWith({
    AppThemeData? currentTheme,
    ThemeData? flutterTheme,
    ThemeData? darkFlutterTheme,
    bool? isLoading,
    String? error,
    bool? isTransitioning,
    double? transitionProgress,
    ThemePreferences? preferences,
    List<String>? favoriteThemes,
    Map<String, ThemeUsageStats>? usageStats,
  }) {
    return EnhancedThemeState(
      currentTheme: currentTheme ?? this.currentTheme,
      flutterTheme: flutterTheme ?? this.flutterTheme,
      darkFlutterTheme: darkFlutterTheme ?? this.darkFlutterTheme,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isTransitioning: isTransitioning ?? this.isTransitioning,
      transitionProgress: transitionProgress ?? this.transitionProgress,
      preferences: preferences ?? this.preferences,
      favoriteThemes: favoriteThemes ?? this.favoriteThemes,
      usageStats: usageStats ?? this.usageStats,
    );
  }

  bool get hasTheme => currentTheme != null;
  bool get hasError => error != null;
  String get currentThemeId => currentTheme?.metadata.id ?? 'default';
  String get currentThemeName => currentTheme?.metadata.name ?? 'Default';
}

/// Enhanced theme notifier with smooth transitions and theme registry integration
class EnhancedThemeNotifier extends StateNotifier<EnhancedThemeState> {
  final ThemeRegistry _themeRegistry = ThemeRegistry();
  late final ThemePersistenceService _persistenceService;
  final List<String> _themeHistory = [];

  EnhancedThemeNotifier() : super(_createInitialState()) {
    _persistenceService = ThemePersistenceService(_themeRegistry);
    _initializeThemes();
    _loadSavedTheme();
  }

  /// Create initial state with default theme to prevent flash
  static EnhancedThemeState _createInitialState() {
    // Create a basic default theme to prevent flash
    final defaultTheme = ExpressiveTheme.createDark();
    final flutterTheme = ThemeFactory.createFlutterTheme(defaultTheme);
    
    return EnhancedThemeState(
      currentTheme: defaultTheme,
      flutterTheme: flutterTheme,
      darkFlutterTheme: flutterTheme,
      isLoading: true, // Mark as loading since we'll replace it
    );
  }

  /// Initialize built-in themes
  void _initializeThemes() {
    
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
    
    
    _themeRegistry.registerAll(themes);
    
  }

  /// Load previously saved theme with enhanced persistence
  Future<void> _loadSavedTheme() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Initialize persistence service
      await _persistenceService.initialize();
      
      // Load saved configuration
      final savedConfig = await _persistenceService.loadSavedTheme();
      final preferences = await _persistenceService.loadThemePreferences();
      final favoriteThemes = await _persistenceService.loadFavoriteThemes();
      final usageStats = await _persistenceService.getThemeUsageStats();
      final history = await _persistenceService.getThemeHistory();
      
      // Update state with loaded data
      state = state.copyWith(
        preferences: preferences,
        favoriteThemes: favoriteThemes,
        usageStats: usageStats,
      );
      
      _themeHistory.clear();
      _themeHistory.addAll(history);
      
      // Load custom themes
      final customThemes = await _persistenceService.loadCustomThemes();
      for (final theme in customThemes) {
        _themeRegistry.register(theme);
      }
      
      if (savedConfig != null && _themeRegistry.isRegistered(savedConfig.themeId)) {
        await setTheme(savedConfig.themeId, saveToPrefs: false);
      } else {
        // Set default theme to Matrix Dark for demo
        await setTheme('matrix_dark', saveToPrefs: false);
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load saved theme: $e',
        isLoading: false,
      );
      // Fallback to matrix theme even in error case
      await setTheme('matrix_dark', saveToPrefs: false);
    }
  }

  /// Set theme by ID with smooth transition
  Future<void> setTheme(String themeId, {bool saveToPrefs = true}) async {
    
    final theme = _themeRegistry.getTheme(themeId);
    if (theme == null) {
      debugPrint('Theme not found: $themeId');
      state = state.copyWith(
        error: 'Theme not found: $themeId',
        isLoading: false,
      );
      return;
    }
    
    debugPrint('Theme found: ${theme.metadata.name} (${theme.metadata.id})');

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

      // Save to preferences using persistence service
      if (saveToPrefs) {
        await _persistenceService.saveCurrentTheme(themeId: themeId);
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

  /// Save custom theme
  Future<bool> saveCustomTheme(AppThemeData theme) async {
    return await _persistenceService.saveCustomTheme(theme);
  }

  /// Delete custom theme
  Future<bool> deleteCustomTheme(String themeId) async {
    final success = await _persistenceService.deleteCustomTheme(themeId);
    if (success) {
      // If we deleted the current theme, switch to default
      if (state.currentTheme?.metadata.id == themeId) {
        await resetToDefault();
      }
    }
    return success;
  }

  /// Save theme preferences
  Future<bool> saveThemePreferences(ThemePreferences preferences) async {
    final success = await _persistenceService.saveThemePreferences(preferences);
    if (success) {
      state = state.copyWith(preferences: preferences);
    }
    return success;
  }

  /// Toggle theme as favorite
  Future<void> toggleFavoriteTheme(String themeId) async {
    final currentFavorites = List<String>.from(state.favoriteThemes);
    
    if (currentFavorites.contains(themeId)) {
      currentFavorites.remove(themeId);
    } else {
      currentFavorites.add(themeId);
    }
    
    final success = await _persistenceService.saveFavoriteThemes(currentFavorites);
    if (success) {
      state = state.copyWith(favoriteThemes: currentFavorites);
    }
  }

  /// Export theme data for backup
  Future<Map<String, dynamic>?> exportThemeData() async {
    try {
      return await _persistenceService.exportThemeData();
    } catch (e) {
      debugPrint('Error exporting theme data: $e');
      return null;
    }
  }

  /// Import theme data from backup
  Future<bool> importThemeData(Map<String, dynamic> data) async {
    try {
      final success = await _persistenceService.importThemeData(data);
      if (success) {
        // Reload everything after import
        await _loadSavedTheme();
      }
      return success;
    } catch (e) {
      debugPrint('Error importing theme data: $e');
      return false;
    }
  }

  /// Get all available themes
  List<AppThemeData> getAllThemes() {
    final themes = _themeRegistry.themes.toList();
    if (themes.isEmpty) {
      debugPrint('No themes found in registry! Registry count: ${_themeRegistry.count}');
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

  /// Get usage statistics for a theme
  ThemeUsageStats? getThemeUsageStats(String themeId) {
    return state.usageStats[themeId];
  }

  /// Check if theme is favorite
  bool isThemeFavorite(String themeId) {
    return state.favoriteThemes.contains(themeId);
  }

  /// Get favorite themes
  List<AppThemeData> getFavoriteThemes() {
    return state.favoriteThemes
        .map((id) => _themeRegistry.getTheme(id))
        .where((theme) => theme != null)
        .cast<AppThemeData>()
        .toList();
  }

  /// Get most used themes
  List<AppThemeData> getMostUsedThemes({int limit = 5}) {
    final sortedUsage = state.usageStats.entries.toList()
      ..sort((a, b) => b.value.usageCount.compareTo(a.value.usageCount));
    
    return sortedUsage
        .take(limit)
        .map((entry) => _themeRegistry.getTheme(entry.key))
        .where((theme) => theme != null)
        .cast<AppThemeData>()
        .toList();
  }

  /// Clear all theme data (for reset)
  Future<bool> clearAllThemeData() async {
    final success = await _persistenceService.clearAllData();
    if (success) {
      // Reset to default state
      state = const EnhancedThemeState();
      await _loadSavedTheme();
    }
    return success;
  }

  /// Dispose resources
  @override
  void dispose() {
    _persistenceService.dispose();
    super.dispose();
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

/// Provider for favorite themes
final favoriteThemesProvider = Provider<List<AppThemeData>>((ref) {
  final themeNotifier = ref.watch(enhancedThemeProvider.notifier);
  ref.watch(enhancedThemeProvider); // Watch state changes
  return themeNotifier.getFavoriteThemes();
});

/// Provider for most used themes
final mostUsedThemesProvider = Provider<List<AppThemeData>>((ref) {
  final themeNotifier = ref.watch(enhancedThemeProvider.notifier);
  ref.watch(enhancedThemeProvider); // Watch state changes
  return themeNotifier.getMostUsedThemes();
});

/// Provider for theme preferences
final themePreferencesProvider = Provider<ThemePreferences>((ref) {
  final themeState = ref.watch(enhancedThemeProvider);
  return themeState.preferences;
});

/// Provider for theme usage statistics
final themeUsageStatsProvider = Provider<Map<String, ThemeUsageStats>>((ref) {
  final themeState = ref.watch(enhancedThemeProvider);
  return themeState.usageStats;
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