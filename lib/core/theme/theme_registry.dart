import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'app_theme_data.dart';

/// Central registry for all app themes
class ThemeRegistry {
  static final ThemeRegistry _instance = ThemeRegistry._internal();
  factory ThemeRegistry() => _instance;
  ThemeRegistry._internal();

  final Map<String, AppThemeData> _themes = {};
  final List<VoidCallback> _listeners = [];

  /// Get all registered themes
  UnmodifiableListView<AppThemeData> get themes =>
      UnmodifiableListView(_themes.values);

  /// Get theme by ID
  AppThemeData? getTheme(String id) => _themes[id];

  /// Get themes by category
  List<AppThemeData> getThemesByCategory(String category) {
    return _themes.values
        .where((theme) => theme.metadata.category == category)
        .toList();
  }

  /// Get themes by tags
  List<AppThemeData> getThemesByTags(List<String> tags) {
    return _themes.values
        .where((theme) => tags.any((tag) => theme.metadata.tags.contains(tag)))
        .toList();
  }

  /// Search themes by name or description
  List<AppThemeData> searchThemes(String query) {
    if (query.isEmpty) return themes.toList();
    
    final lowercaseQuery = query.toLowerCase();
    return _themes.values
        .where((theme) =>
            theme.metadata.name.toLowerCase().contains(lowercaseQuery) ||
            theme.metadata.description.toLowerCase().contains(lowercaseQuery) ||
            theme.metadata.tags.any(
                (tag) => tag.toLowerCase().contains(lowercaseQuery)))
        .toList();
  }

  /// Get all available categories
  Set<String> get categories {
    return _themes.values.map((theme) => theme.metadata.category).toSet();
  }

  /// Get all available tags
  Set<String> get tags {
    final allTags = <String>{};
    for (final theme in _themes.values) {
      allTags.addAll(theme.metadata.tags);
    }
    return allTags;
  }

  /// Register a new theme
  void register(AppThemeData theme) {
    if (_themes.containsKey(theme.metadata.id)) {
      // Theme update - silently replacing existing theme
    }
    
    _themes[theme.metadata.id] = theme;
    _notifyListeners();
  }

  /// Register multiple themes
  void registerAll(List<AppThemeData> themes) {
    for (final theme in themes) {
      _themes[theme.metadata.id] = theme;
    }
    _notifyListeners();
  }

  /// Unregister a theme
  bool unregister(String id) {
    final removed = _themes.remove(id);
    if (removed != null) {
      _notifyListeners();
      return true;
    }
    return false;
  }

  /// Check if theme is registered
  bool isRegistered(String id) => _themes.containsKey(id);

  /// Get theme count
  int get count => _themes.length;

  /// Check if registry is empty
  bool get isEmpty => _themes.isEmpty;

  /// Check if registry is not empty
  bool get isNotEmpty => _themes.isNotEmpty;

  /// Clear all themes
  void clear() {
    _themes.clear();
    _notifyListeners();
  }

  /// Add listener for theme registry changes
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  /// Remove listener
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  /// Notify all listeners of changes
  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  /// Get themes sorted by popularity
  List<AppThemeData> getThemesByPopularity() {
    final themes = _themes.values.toList();
    themes.sort((a, b) => b.metadata.popularityScore.compareTo(a.metadata.popularityScore));
    return themes;
  }

  /// Get recently added themes
  List<AppThemeData> getRecentThemes({int limit = 5}) {
    final themes = _themes.values.toList();
    themes.sort((a, b) => b.metadata.createdAt.compareTo(a.metadata.createdAt));
    return themes.take(limit).toList();
  }

  /// Get premium themes
  List<AppThemeData> getPremiumThemes() {
    return _themes.values
        .where((theme) => theme.metadata.isPremium)
        .toList();
  }

  /// Get free themes
  List<AppThemeData> getFreeThemes() {
    return _themes.values
        .where((theme) => !theme.metadata.isPremium)
        .toList();
  }

  /// Export theme registry data (for debugging)
  Map<String, dynamic> exportData() {
    return {
      'totalThemes': count,
      'categories': categories.toList(),
      'tags': tags.toList(),
      'themes': _themes.values.map((theme) => {
        'id': theme.metadata.id,
        'name': theme.metadata.name,
        'category': theme.metadata.category,
        'tags': theme.metadata.tags,
        'isPremium': theme.metadata.isPremium,
        'popularityScore': theme.metadata.popularityScore,
      }).toList(),
    };
  }

  /// Validate theme data
  bool validateTheme(AppThemeData theme) {
    // Check required fields
    if (theme.metadata.id.isEmpty) return false;
    if (theme.metadata.name.isEmpty) return false;
    
    // Check for duplicate IDs
    if (_themes.containsKey(theme.metadata.id)) {
      // Duplicate theme ID detected during validation
    }

    return true;
  }

  /// Get theme statistics
  Map<String, dynamic> getStatistics() {
    final stats = <String, dynamic>{};
    
    // Count by category
    final categoryCount = <String, int>{};
    for (final theme in _themes.values) {
      categoryCount[theme.metadata.category] = 
          (categoryCount[theme.metadata.category] ?? 0) + 1;
    }
    stats['categoryCounts'] = categoryCount;
    
    // Premium vs Free
    final premiumCount = _themes.values.where((t) => t.metadata.isPremium).length;
    stats['premiumThemes'] = premiumCount;
    stats['freeThemes'] = count - premiumCount;
    
    // Average popularity
    if (isNotEmpty) {
      final avgPopularity = _themes.values
          .map((t) => t.metadata.popularityScore)
          .reduce((a, b) => a + b) / count;
      stats['averagePopularity'] = avgPopularity;
    }
    
    return stats;
  }

  @override
  String toString() {
    return 'ThemeRegistry(themes: $count, categories: ${categories.length})';
  }
}