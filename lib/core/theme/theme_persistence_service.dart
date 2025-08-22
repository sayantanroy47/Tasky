import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme_data.dart';
import 'theme_registry.dart';

/// Comprehensive theme persistence service with advanced features
class ThemePersistenceService {
  static const String _keyCurrentThemeId = 'current_theme_id';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyThemeHistory = 'theme_history';
  static const String _keyCustomThemes = 'custom_themes';
  static const String _keyThemeSettings = 'theme_settings';
  static const String _keyThemePreferences = 'theme_preferences';
  static const String _keyThemeUsageStats = 'theme_usage_stats';
  static const String _keyFavoriteThemes = 'favorite_themes';
  static const String _keyThemeAnalytics = 'theme_analytics';
  static const String _keyThemeVersion = 'theme_version';
  
  static const int _currentVersion = 2;
  static const int _maxHistorySize = 20;
  static const int _maxCustomThemes = 50;

  final ThemeRegistry _themeRegistry;
  final StreamController<ThemePersistenceEvent> _eventController;

  ThemePersistenceService(this._themeRegistry) 
      : _eventController = StreamController<ThemePersistenceEvent>.broadcast();

  /// Stream of persistence events
  Stream<ThemePersistenceEvent> get events => _eventController.stream;

  /// Initialize persistence service and migrate data if needed
  Future<void> initialize() async {
    try {
      await _migrateDataIfNeeded();
      await _cleanupOldData();
      debugPrint('ThemePersistenceService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing ThemePersistenceService: $e');
    }
  }

  /// Save current theme with comprehensive data
  Future<bool> saveCurrentTheme({
    required String themeId,
    ThemeMode? themeMode,
    Map<String, dynamic>? customizations,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save theme ID
      await prefs.setString(_keyCurrentThemeId, themeId);
      
      // Save theme mode if provided
      if (themeMode != null) {
        await prefs.setString(_keyThemeMode, themeMode.name);
      }
      
      // Save customizations if provided
      if (customizations != null && customizations.isNotEmpty) {
        await prefs.setString('${_keyThemeSettings}_$themeId', 
            jsonEncode(customizations));
      }
      
      // Update usage statistics
      await _updateThemeUsageStats(themeId);
      
      // Update history
      await _updateThemeHistory(themeId);
      
      // Track analytics
      await _trackThemeChange(themeId);
      
      _eventController.add(ThemePersistenceEvent(
        type: ThemePersistenceEventType.themeSaved,
        themeId: themeId,
        data: {'themeMode': themeMode?.name, 'hasCustomizations': customizations != null},
      ));
      
      return true;
    } catch (e) {
      debugPrint('Error saving theme: $e');
      _eventController.add(ThemePersistenceEvent(
        type: ThemePersistenceEventType.error,
        error: e.toString(),
      ));
      return false;
    }
  }

  /// Load saved theme configuration
  Future<SavedThemeConfig?> loadSavedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final themeId = prefs.getString(_keyCurrentThemeId);
      if (themeId == null) return null;
      
      final themeModeString = prefs.getString(_keyThemeMode);
      final themeMode = themeModeString != null 
          ? ThemeMode.values.firstWhere(
              (mode) => mode.name == themeModeString,
              orElse: () => ThemeMode.system,
            )
          : ThemeMode.system;
      
      // Load customizations for this theme
      final customizationsString = prefs.getString('${_keyThemeSettings}_$themeId');
      final customizations = customizationsString != null 
          ? Map<String, dynamic>.from(jsonDecode(customizationsString))
          : <String, dynamic>{};
      
      // Load theme preferences
      final preferencesString = prefs.getString(_keyThemePreferences);
      final preferences = preferencesString != null 
          ? Map<String, dynamic>.from(jsonDecode(preferencesString))
          : <String, dynamic>{};
      
      return SavedThemeConfig(
        themeId: themeId,
        themeMode: themeMode,
        customizations: customizations,
        preferences: preferences,
      );
    } catch (e) {
      debugPrint('Error loading saved theme: $e');
      return null;
    }
  }

  /// Save custom theme created by user
  Future<bool> saveCustomTheme(AppThemeData theme) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customThemesString = prefs.getString(_keyCustomThemes) ?? '{}';
      final customThemes = Map<String, dynamic>.from(jsonDecode(customThemesString));
      
      // Check if we're at the limit
      if (customThemes.length >= _maxCustomThemes && !customThemes.containsKey(theme.metadata.id)) {
        throw Exception('Maximum number of custom themes reached ($_maxCustomThemes)');
      }
      
      // Serialize theme data
      final themeData = _serializeTheme(theme);
      customThemes[theme.metadata.id] = themeData;
      
      await prefs.setString(_keyCustomThemes, jsonEncode(customThemes));
      
      // Register theme in registry
      _themeRegistry.register(theme);
      
      _eventController.add(ThemePersistenceEvent(
        type: ThemePersistenceEventType.customThemeSaved,
        themeId: theme.metadata.id,
        data: {'themeName': theme.metadata.name},
      ));
      
      return true;
    } catch (e) {
      debugPrint('Error saving custom theme: $e');
      _eventController.add(ThemePersistenceEvent(
        type: ThemePersistenceEventType.error,
        error: e.toString(),
      ));
      return false;
    }
  }

  /// Load all custom themes
  Future<List<AppThemeData>> loadCustomThemes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customThemesString = prefs.getString(_keyCustomThemes) ?? '{}';
      final customThemes = Map<String, dynamic>.from(jsonDecode(customThemesString));
      
      final themes = <AppThemeData>[];
      for (final themeData in customThemes.values) {
        try {
          final theme = _deserializeTheme(Map<String, dynamic>.from(themeData));
          if (theme != null) {
            themes.add(theme);
          }
        } catch (e) {
          debugPrint('Error deserializing custom theme: $e');
        }
      }
      
      return themes;
    } catch (e) {
      debugPrint('Error loading custom themes: $e');
      return [];
    }
  }

  /// Delete custom theme
  Future<bool> deleteCustomTheme(String themeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customThemesString = prefs.getString(_keyCustomThemes) ?? '{}';
      final customThemes = Map<String, dynamic>.from(jsonDecode(customThemesString));
      
      if (customThemes.remove(themeId) != null) {
        await prefs.setString(_keyCustomThemes, jsonEncode(customThemes));
        
        // Unregister from registry
        _themeRegistry.unregister(themeId);
        
        _eventController.add(ThemePersistenceEvent(
          type: ThemePersistenceEventType.customThemeDeleted,
          themeId: themeId,
        ));
        
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error deleting custom theme: $e');
      return false;
    }
  }

  /// Save theme preferences (auto-switching, schedules, etc.)
  Future<bool> saveThemePreferences(ThemePreferences preferences) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyThemePreferences, jsonEncode(preferences.toJson()));
      
      _eventController.add(ThemePersistenceEvent(
        type: ThemePersistenceEventType.preferencesSaved,
        data: preferences.toJson(),
      ));
      
      return true;
    } catch (e) {
      debugPrint('Error saving theme preferences: $e');
      return false;
    }
  }

  /// Load theme preferences
  Future<ThemePreferences> loadThemePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final preferencesString = prefs.getString(_keyThemePreferences);
      
      if (preferencesString != null) {
        final data = Map<String, dynamic>.from(jsonDecode(preferencesString));
        return ThemePreferences.fromJson(data);
      }
      
      return ThemePreferences.defaultPreferences();
    } catch (e) {
      debugPrint('Error loading theme preferences: $e');
      return ThemePreferences.defaultPreferences();
    }
  }

  /// Get theme usage statistics
  Future<Map<String, ThemeUsageStats>> getThemeUsageStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsString = prefs.getString(_keyThemeUsageStats) ?? '{}';
      final statsData = Map<String, dynamic>.from(jsonDecode(statsString));
      
      final stats = <String, ThemeUsageStats>{};
      for (final entry in statsData.entries) {
        try {
          stats[entry.key] = ThemeUsageStats.fromJson(
            Map<String, dynamic>.from(entry.value)
          );
        } catch (e) {
          debugPrint('Error parsing usage stats for ${entry.key}: $e');
        }
      }
      
      return stats;
    } catch (e) {
      debugPrint('Error loading theme usage stats: $e');
      return {};
    }
  }

  /// Get theme history
  Future<List<String>> getThemeHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_keyThemeHistory) ?? [];
    } catch (e) {
      debugPrint('Error loading theme history: $e');
      return [];
    }
  }

  /// Save favorite themes
  Future<bool> saveFavoriteThemes(List<String> favoriteThemeIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_keyFavoriteThemes, favoriteThemeIds);
      
      _eventController.add(ThemePersistenceEvent(
        type: ThemePersistenceEventType.favoritesSaved,
        data: {'count': favoriteThemeIds.length},
      ));
      
      return true;
    } catch (e) {
      debugPrint('Error saving favorite themes: $e');
      return false;
    }
  }

  /// Load favorite themes
  Future<List<String>> loadFavoriteThemes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_keyFavoriteThemes) ?? [];
    } catch (e) {
      debugPrint('Error loading favorite themes: $e');
      return [];
    }
  }

  /// Export all theme data for backup
  Future<Map<String, dynamic>> exportThemeData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      return {
        'version': _currentVersion,
        'currentTheme': prefs.getString(_keyCurrentThemeId),
        'themeMode': prefs.getString(_keyThemeMode),
        'history': prefs.getStringList(_keyThemeHistory) ?? [],
        'customThemes': prefs.getString(_keyCustomThemes) ?? '{}',
        'preferences': prefs.getString(_keyThemePreferences) ?? '{}',
        'usageStats': prefs.getString(_keyThemeUsageStats) ?? '{}',
        'favorites': prefs.getStringList(_keyFavoriteThemes) ?? [],
        'analytics': prefs.getString(_keyThemeAnalytics) ?? '{}',
        'exportedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('Error exporting theme data: $e');
      return {};
    }
  }

  /// Import theme data from backup
  Future<bool> importThemeData(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Validate data version
      final version = data['version'] as int? ?? 1;
      if (version > _currentVersion) {
        throw Exception('Backup data is from a newer version');
      }
      
      // Import data with validation
      if (data['currentTheme'] != null) {
        await prefs.setString(_keyCurrentThemeId, data['currentTheme']);
      }
      
      if (data['themeMode'] != null) {
        await prefs.setString(_keyThemeMode, data['themeMode']);
      }
      
      if (data['history'] != null) {
        await prefs.setStringList(_keyThemeHistory, 
            List<String>.from(data['history']));
      }
      
      if (data['customThemes'] != null) {
        await prefs.setString(_keyCustomThemes, data['customThemes']);
      }
      
      if (data['preferences'] != null) {
        await prefs.setString(_keyThemePreferences, data['preferences']);
      }
      
      if (data['usageStats'] != null) {
        await prefs.setString(_keyThemeUsageStats, data['usageStats']);
      }
      
      if (data['favorites'] != null) {
        await prefs.setStringList(_keyFavoriteThemes, 
            List<String>.from(data['favorites']));
      }
      
      _eventController.add(ThemePersistenceEvent(
        type: ThemePersistenceEventType.dataImported,
        data: {'itemsImported': data.keys.length},
      ));
      
      return true;
    } catch (e) {
      debugPrint('Error importing theme data: $e');
      _eventController.add(ThemePersistenceEvent(
        type: ThemePersistenceEventType.error,
        error: e.toString(),
      ));
      return false;
    }
  }

  /// Clear all theme data
  Future<bool> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await Future.wait([
        prefs.remove(_keyCurrentThemeId),
        prefs.remove(_keyThemeMode),
        prefs.remove(_keyThemeHistory),
        prefs.remove(_keyCustomThemes),
        prefs.remove(_keyThemeSettings),
        prefs.remove(_keyThemePreferences),
        prefs.remove(_keyThemeUsageStats),
        prefs.remove(_keyFavoriteThemes),
        prefs.remove(_keyThemeAnalytics),
      ]);
      
      _eventController.add(ThemePersistenceEvent(
        type: ThemePersistenceEventType.dataCleared,
      ));
      
      return true;
    } catch (e) {
      debugPrint('Error clearing theme data: $e');
      return false;
    }
  }

  // Private helper methods

  /// Update theme usage statistics
  Future<void> _updateThemeUsageStats(String themeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsString = prefs.getString(_keyThemeUsageStats) ?? '{}';
      final statsData = Map<String, dynamic>.from(jsonDecode(statsString));
      
      final now = DateTime.now();
      final currentStats = statsData[themeId] != null 
          ? ThemeUsageStats.fromJson(Map<String, dynamic>.from(statsData[themeId]))
          : ThemeUsageStats(
              themeId: themeId,
              usageCount: 0,
              totalTimeUsed: Duration.zero,
              lastUsed: now,
              firstUsed: now,
            );
      
      final updatedStats = currentStats.copyWith(
        usageCount: currentStats.usageCount + 1,
        lastUsed: now,
      );
      
      statsData[themeId] = updatedStats.toJson();
      await prefs.setString(_keyThemeUsageStats, jsonEncode(statsData));
    } catch (e) {
      debugPrint('Error updating theme usage stats: $e');
    }
  }

  /// Update theme history
  Future<void> _updateThemeHistory(String themeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_keyThemeHistory) ?? [];
      
      // Remove if already exists and add to beginning
      history.remove(themeId);
      history.insert(0, themeId);
      
      // Limit history size
      if (history.length > _maxHistorySize) {
        history.removeRange(_maxHistorySize, history.length);
      }
      
      await prefs.setStringList(_keyThemeHistory, history);
    } catch (e) {
      debugPrint('Error updating theme history: $e');
    }
  }

  /// Track theme change for analytics
  Future<void> _trackThemeChange(String themeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final analyticsString = prefs.getString(_keyThemeAnalytics) ?? '{}';
      final analytics = Map<String, dynamic>.from(jsonDecode(analyticsString));
      
      final changes = List<Map<String, dynamic>>.from(analytics['changes'] ?? []);
      changes.add({
        'themeId': themeId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      // Keep only recent changes (last 100)
      if (changes.length > 100) {
        changes.removeRange(0, changes.length - 100);
      }
      
      analytics['changes'] = changes;
      analytics['totalChanges'] = (analytics['totalChanges'] ?? 0) + 1;
      
      await prefs.setString(_keyThemeAnalytics, jsonEncode(analytics));
    } catch (e) {
      debugPrint('Error tracking theme change: $e');
    }
  }

  /// Migrate data if version has changed
  Future<void> _migrateDataIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedVersion = prefs.getInt(_keyThemeVersion) ?? 1;
      
      if (savedVersion < _currentVersion) {
        debugPrint('Migrating theme data from version $savedVersion to $_currentVersion');
        
        // Perform migrations based on version differences
        if (savedVersion < 2) {
          await _migrateToV2();
        }
        
        await prefs.setInt(_keyThemeVersion, _currentVersion);
        
        _eventController.add(ThemePersistenceEvent(
          type: ThemePersistenceEventType.dataMigrated,
          data: {'fromVersion': savedVersion, 'toVersion': _currentVersion},
        ));
      }
    } catch (e) {
      debugPrint('Error migrating theme data: $e');
    }
  }

  /// Migrate to version 2
  Future<void> _migrateToV2() async {
    // Add any V2 migration logic here
    // For example, converting old data formats, adding new fields, etc.
    debugPrint('Migrating theme data to version 2');
  }

  /// Clean up old or corrupt data
  Future<void> _cleanupOldData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Clean up custom themes that might be corrupted
      final customThemesString = prefs.getString(_keyCustomThemes);
      if (customThemesString != null) {
        try {
          final customThemes = Map<String, dynamic>.from(jsonDecode(customThemesString));
          final validThemes = <String, dynamic>{};
          
          for (final entry in customThemes.entries) {
            try {
              final theme = _deserializeTheme(Map<String, dynamic>.from(entry.value));
              if (theme != null) {
                validThemes[entry.key] = entry.value;
              }
            } catch (e) {
              debugPrint('Removing corrupted custom theme: ${entry.key}');
            }
          }
          
          if (validThemes.length != customThemes.length) {
            await prefs.setString(_keyCustomThemes, jsonEncode(validThemes));
          }
        } catch (e) {
          debugPrint('Error cleaning up custom themes, resetting: $e');
          await prefs.remove(_keyCustomThemes);
        }
      }
    } catch (e) {
      debugPrint('Error during cleanup: $e');
    }
  }

  /// Serialize theme data for storage
  Map<String, dynamic> _serializeTheme(AppThemeData theme) {
    // This is a simplified serialization - in a real app you'd need
    // comprehensive serialization for all theme properties
    return {
      'metadata': {
        'id': theme.metadata.id,
        'name': theme.metadata.name,
        'description': theme.metadata.description,
        'category': theme.metadata.category,
        'tags': theme.metadata.tags,
        'isPremium': theme.metadata.isPremium,
        'createdAt': theme.metadata.createdAt.toIso8601String(),
      },
      'colors': {
        'primary': theme.colors.primary.toARGB32(),
        'secondary': theme.colors.secondary.toARGB32(),
        'background': theme.colors.background.toARGB32(),
        'surface': theme.colors.surface.toARGB32(),
      },
      // Add more theme properties as needed
    };
  }

  /// Deserialize theme data from storage
  AppThemeData? _deserializeTheme(Map<String, dynamic> data) {
    try {
      // This is a simplified deserialization - in a real app you'd need
      // comprehensive deserialization for all theme properties
      // For now, return null to indicate this needs full implementation
      return null;
    } catch (e) {
      debugPrint('Error deserializing theme: $e');
      return null;
    }
  }

  /// Dispose resources
  void dispose() {
    _eventController.close();
  }
}

/// Saved theme configuration
class SavedThemeConfig {
  final String themeId;
  final ThemeMode themeMode;
  final Map<String, dynamic> customizations;
  final Map<String, dynamic> preferences;

  const SavedThemeConfig({
    required this.themeId,
    required this.themeMode,
    required this.customizations,
    required this.preferences,
  });
}

/// Theme preferences for advanced features
class ThemePreferences {
  final bool autoSwitchEnabled;
  final TimeOfDay? lightThemeTime;
  final TimeOfDay? darkThemeTime;
  final String? lightThemeId;
  final String? darkThemeId;
  final bool followSystemTheme;
  final List<ScheduledThemeChange> scheduledChanges;
  final bool animationsEnabled;
  final Duration animationDuration;

  const ThemePreferences({
    required this.autoSwitchEnabled,
    this.lightThemeTime,
    this.darkThemeTime,
    this.lightThemeId,
    this.darkThemeId,
    required this.followSystemTheme,
    required this.scheduledChanges,
    required this.animationsEnabled,
    required this.animationDuration,
  });

  factory ThemePreferences.defaultPreferences() {
    return const ThemePreferences(
      autoSwitchEnabled: false,
      followSystemTheme: true,
      scheduledChanges: [],
      animationsEnabled: true,
      animationDuration: Duration(milliseconds: 300),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'autoSwitchEnabled': autoSwitchEnabled,
      'lightThemeTime': lightThemeTime != null 
          ? '${lightThemeTime!.hour}:${lightThemeTime!.minute}' 
          : null,
      'darkThemeTime': darkThemeTime != null 
          ? '${darkThemeTime!.hour}:${darkThemeTime!.minute}' 
          : null,
      'lightThemeId': lightThemeId,
      'darkThemeId': darkThemeId,
      'followSystemTheme': followSystemTheme,
      'scheduledChanges': scheduledChanges.map((c) => c.toJson()).toList(),
      'animationsEnabled': animationsEnabled,
      'animationDuration': animationDuration.inMilliseconds,
    };
  }

  factory ThemePreferences.fromJson(Map<String, dynamic> json) {
    TimeOfDay? parseTime(String? timeStr) {
      if (timeStr == null) return null;
      final parts = timeStr.split(':');
      if (parts.length == 2) {
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
      return null;
    }

    return ThemePreferences(
      autoSwitchEnabled: json['autoSwitchEnabled'] ?? false,
      lightThemeTime: parseTime(json['lightThemeTime']),
      darkThemeTime: parseTime(json['darkThemeTime']),
      lightThemeId: json['lightThemeId'],
      darkThemeId: json['darkThemeId'],
      followSystemTheme: json['followSystemTheme'] ?? true,
      scheduledChanges: (json['scheduledChanges'] as List?)
          ?.map((c) => ScheduledThemeChange.fromJson(c))
          .toList() ?? [],
      animationsEnabled: json['animationsEnabled'] ?? true,
      animationDuration: Duration(
        milliseconds: json['animationDuration'] ?? 300,
      ),
    );
  }

  ThemePreferences copyWith({
    bool? autoSwitchEnabled,
    TimeOfDay? lightThemeTime,
    TimeOfDay? darkThemeTime,
    String? lightThemeId,
    String? darkThemeId,
    bool? followSystemTheme,
    List<ScheduledThemeChange>? scheduledChanges,
    bool? animationsEnabled,
    Duration? animationDuration,
  }) {
    return ThemePreferences(
      autoSwitchEnabled: autoSwitchEnabled ?? this.autoSwitchEnabled,
      lightThemeTime: lightThemeTime ?? this.lightThemeTime,
      darkThemeTime: darkThemeTime ?? this.darkThemeTime,
      lightThemeId: lightThemeId ?? this.lightThemeId,
      darkThemeId: darkThemeId ?? this.darkThemeId,
      followSystemTheme: followSystemTheme ?? this.followSystemTheme,
      scheduledChanges: scheduledChanges ?? this.scheduledChanges,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
      animationDuration: animationDuration ?? this.animationDuration,
    );
  }
}

/// Scheduled theme change
class ScheduledThemeChange {
  final String id;
  final String name;
  final TimeOfDay time;
  final String themeId;
  final List<int> daysOfWeek; // 1-7, Monday-Sunday
  final bool enabled;

  const ScheduledThemeChange({
    required this.id,
    required this.name,
    required this.time,
    required this.themeId,
    required this.daysOfWeek,
    required this.enabled,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'time': '${time.hour}:${time.minute}',
      'themeId': themeId,
      'daysOfWeek': daysOfWeek,
      'enabled': enabled,
    };
  }

  factory ScheduledThemeChange.fromJson(Map<String, dynamic> json) {
    final timeParts = (json['time'] as String).split(':');
    return ScheduledThemeChange(
      id: json['id'],
      name: json['name'],
      time: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      themeId: json['themeId'],
      daysOfWeek: List<int>.from(json['daysOfWeek']),
      enabled: json['enabled'],
    );
  }
}

/// Theme usage statistics
class ThemeUsageStats {
  final String themeId;
  final int usageCount;
  final Duration totalTimeUsed;
  final DateTime lastUsed;
  final DateTime firstUsed;

  const ThemeUsageStats({
    required this.themeId,
    required this.usageCount,
    required this.totalTimeUsed,
    required this.lastUsed,
    required this.firstUsed,
  });

  Map<String, dynamic> toJson() {
    return {
      'themeId': themeId,
      'usageCount': usageCount,
      'totalTimeUsed': totalTimeUsed.inMilliseconds,
      'lastUsed': lastUsed.toIso8601String(),
      'firstUsed': firstUsed.toIso8601String(),
    };
  }

  factory ThemeUsageStats.fromJson(Map<String, dynamic> json) {
    return ThemeUsageStats(
      themeId: json['themeId'],
      usageCount: json['usageCount'],
      totalTimeUsed: Duration(milliseconds: json['totalTimeUsed']),
      lastUsed: DateTime.parse(json['lastUsed']),
      firstUsed: DateTime.parse(json['firstUsed']),
    );
  }

  ThemeUsageStats copyWith({
    String? themeId,
    int? usageCount,
    Duration? totalTimeUsed,
    DateTime? lastUsed,
    DateTime? firstUsed,
  }) {
    return ThemeUsageStats(
      themeId: themeId ?? this.themeId,
      usageCount: usageCount ?? this.usageCount,
      totalTimeUsed: totalTimeUsed ?? this.totalTimeUsed,
      lastUsed: lastUsed ?? this.lastUsed,
      firstUsed: firstUsed ?? this.firstUsed,
    );
  }
}

/// Theme persistence events
class ThemePersistenceEvent {
  final ThemePersistenceEventType type;
  final String? themeId;
  final Map<String, dynamic>? data;
  final String? error;
  final DateTime timestamp;

  ThemePersistenceEvent({
    required this.type,
    this.themeId,
    this.data,
    this.error,
  }) : timestamp = DateTime.now();
}

/// Theme persistence event types
enum ThemePersistenceEventType {
  themeSaved,
  customThemeSaved,
  customThemeDeleted,
  preferencesSaved,
  favoritesSaved,
  dataImported,
  dataExported,
  dataCleared,
  dataMigrated,
  error,
}