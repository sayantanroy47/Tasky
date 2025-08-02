import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service for managing gesture customization and haptic feedback
class GestureCustomizationService {
  static const String _gestureSettingsKey = 'gesture_settings';
  static const String _hapticSettingsKey = 'haptic_settings';

  /// Get current gesture settings
  Future<GestureSettings> getGestureSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_gestureSettingsKey);
    
    if (settingsJson != null) {
      final settingsMap = json.decode(settingsJson) as Map<String, dynamic>;
      return GestureSettings.fromJson(settingsMap);
    }
    
    return GestureSettings.defaultSettings();
  }

  /// Save gesture settings
  Future<void> saveGestureSettings(GestureSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = json.encode(settings.toJson());
    await prefs.setString(_gestureSettingsKey, settingsJson);
  }

  /// Get current haptic settings
  Future<HapticSettings> getHapticSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_hapticSettingsKey);
    
    if (settingsJson != null) {
      final settingsMap = json.decode(settingsJson) as Map<String, dynamic>;
      return HapticSettings.fromJson(settingsMap);
    }
    
    return HapticSettings.defaultSettings();
  }

  /// Save haptic settings
  Future<void> saveHapticSettings(HapticSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = json.encode(settings.toJson());
    await prefs.setString(_hapticSettingsKey, settingsJson);
  }

  /// Provide haptic feedback based on settings
  Future<void> provideHapticFeedback(
    HapticFeedbackType type,
    HapticSettings settings,
  ) async {
    if (!settings.enabled) return;

    switch (type) {
      case HapticFeedbackType.light:
        if (settings.lightFeedback) {
          await HapticFeedback.lightImpact();
        }
        break;
      case HapticFeedbackType.medium:
        if (settings.mediumFeedback) {
          await HapticFeedback.mediumImpact();
        }
        break;
      case HapticFeedbackType.heavy:
        if (settings.heavyFeedback) {
          await HapticFeedback.heavyImpact();
        }
        break;
      case HapticFeedbackType.selection:
        if (settings.selectionFeedback) {
          await HapticFeedback.selectionClick();
        }
        break;
      case HapticFeedbackType.vibrate:
        if (settings.vibrationFeedback) {
          await HapticFeedback.vibrate();
        }
        break;
    }
  }

  /// Check if gesture is enabled
  bool isGestureEnabled(GestureType gestureType, GestureSettings settings) {
    switch (gestureType) {
      case GestureType.swipeToComplete:
        return settings.swipeToComplete;
      case GestureType.swipeToDelete:
        return settings.swipeToDelete;
      case GestureType.longPressMenu:
        return settings.longPressMenu;
      case GestureType.doubleTapEdit:
        return settings.doubleTapEdit;
      case GestureType.pinchToZoom:
        return settings.pinchToZoom;
      case GestureType.pullToRefresh:
        return settings.pullToRefresh;
    }
  }

  /// Get gesture sensitivity
  double getGestureSensitivity(GestureType gestureType, GestureSettings settings) {
    switch (gestureType) {
      case GestureType.swipeToComplete:
        return settings.swipeSensitivity;
      case GestureType.swipeToDelete:
        return settings.swipeSensitivity;
      case GestureType.longPressMenu:
        return settings.longPressDuration;
      case GestureType.doubleTapEdit:
        return settings.doubleTapTimeout;
      case GestureType.pinchToZoom:
        return settings.pinchSensitivity;
      case GestureType.pullToRefresh:
        return settings.pullToRefreshThreshold;
    }
  }

  /// Reset to default settings
  Future<void> resetToDefaults() async {
    await saveGestureSettings(GestureSettings.defaultSettings());
    await saveHapticSettings(HapticSettings.defaultSettings());
  }
}

/// Gesture settings data model
class GestureSettings {
  final bool swipeToComplete;
  final bool swipeToDelete;
  final bool longPressMenu;
  final bool doubleTapEdit;
  final bool pinchToZoom;
  final bool pullToRefresh;
  final double swipeSensitivity;
  final double longPressDuration;
  final double doubleTapTimeout;
  final double pinchSensitivity;
  final double pullToRefreshThreshold;

  const GestureSettings({
    required this.swipeToComplete,
    required this.swipeToDelete,
    required this.longPressMenu,
    required this.doubleTapEdit,
    required this.pinchToZoom,
    required this.pullToRefresh,
    required this.swipeSensitivity,
    required this.longPressDuration,
    required this.doubleTapTimeout,
    required this.pinchSensitivity,
    required this.pullToRefreshThreshold,
  });

  factory GestureSettings.defaultSettings() {
    return const GestureSettings(
      swipeToComplete: true,
      swipeToDelete: true,
      longPressMenu: true,
      doubleTapEdit: true,
      pinchToZoom: true,
      pullToRefresh: true,
      swipeSensitivity: 0.5,
      longPressDuration: 500.0,
      doubleTapTimeout: 300.0,
      pinchSensitivity: 0.5,
      pullToRefreshThreshold: 80.0,
    );
  }

  factory GestureSettings.fromJson(Map<String, dynamic> json) {
    return GestureSettings(
      swipeToComplete: json['swipeToComplete'] ?? true,
      swipeToDelete: json['swipeToDelete'] ?? true,
      longPressMenu: json['longPressMenu'] ?? true,
      doubleTapEdit: json['doubleTapEdit'] ?? true,
      pinchToZoom: json['pinchToZoom'] ?? true,
      pullToRefresh: json['pullToRefresh'] ?? true,
      swipeSensitivity: (json['swipeSensitivity'] ?? 0.5).toDouble(),
      longPressDuration: (json['longPressDuration'] ?? 500.0).toDouble(),
      doubleTapTimeout: (json['doubleTapTimeout'] ?? 300.0).toDouble(),
      pinchSensitivity: (json['pinchSensitivity'] ?? 0.5).toDouble(),
      pullToRefreshThreshold: (json['pullToRefreshThreshold'] ?? 80.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'swipeToComplete': swipeToComplete,
      'swipeToDelete': swipeToDelete,
      'longPressMenu': longPressMenu,
      'doubleTapEdit': doubleTapEdit,
      'pinchToZoom': pinchToZoom,
      'pullToRefresh': pullToRefresh,
      'swipeSensitivity': swipeSensitivity,
      'longPressDuration': longPressDuration,
      'doubleTapTimeout': doubleTapTimeout,
      'pinchSensitivity': pinchSensitivity,
      'pullToRefreshThreshold': pullToRefreshThreshold,
    };
  }

  GestureSettings copyWith({
    bool? swipeToComplete,
    bool? swipeToDelete,
    bool? longPressMenu,
    bool? doubleTapEdit,
    bool? pinchToZoom,
    bool? pullToRefresh,
    double? swipeSensitivity,
    double? longPressDuration,
    double? doubleTapTimeout,
    double? pinchSensitivity,
    double? pullToRefreshThreshold,
  }) {
    return GestureSettings(
      swipeToComplete: swipeToComplete ?? this.swipeToComplete,
      swipeToDelete: swipeToDelete ?? this.swipeToDelete,
      longPressMenu: longPressMenu ?? this.longPressMenu,
      doubleTapEdit: doubleTapEdit ?? this.doubleTapEdit,
      pinchToZoom: pinchToZoom ?? this.pinchToZoom,
      pullToRefresh: pullToRefresh ?? this.pullToRefresh,
      swipeSensitivity: swipeSensitivity ?? this.swipeSensitivity,
      longPressDuration: longPressDuration ?? this.longPressDuration,
      doubleTapTimeout: doubleTapTimeout ?? this.doubleTapTimeout,
      pinchSensitivity: pinchSensitivity ?? this.pinchSensitivity,
      pullToRefreshThreshold: pullToRefreshThreshold ?? this.pullToRefreshThreshold,
    );
  }
}

/// Haptic settings data model
class HapticSettings {
  final bool enabled;
  final bool lightFeedback;
  final bool mediumFeedback;
  final bool heavyFeedback;
  final bool selectionFeedback;
  final bool vibrationFeedback;
  final double intensity;

  const HapticSettings({
    required this.enabled,
    required this.lightFeedback,
    required this.mediumFeedback,
    required this.heavyFeedback,
    required this.selectionFeedback,
    required this.vibrationFeedback,
    required this.intensity,
  });

  factory HapticSettings.defaultSettings() {
    return const HapticSettings(
      enabled: true,
      lightFeedback: true,
      mediumFeedback: true,
      heavyFeedback: true,
      selectionFeedback: true,
      vibrationFeedback: false,
      intensity: 0.7,
    );
  }

  factory HapticSettings.fromJson(Map<String, dynamic> json) {
    return HapticSettings(
      enabled: json['enabled'] ?? true,
      lightFeedback: json['lightFeedback'] ?? true,
      mediumFeedback: json['mediumFeedback'] ?? true,
      heavyFeedback: json['heavyFeedback'] ?? true,
      selectionFeedback: json['selectionFeedback'] ?? true,
      vibrationFeedback: json['vibrationFeedback'] ?? false,
      intensity: (json['intensity'] ?? 0.7).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'lightFeedback': lightFeedback,
      'mediumFeedback': mediumFeedback,
      'heavyFeedback': heavyFeedback,
      'selectionFeedback': selectionFeedback,
      'vibrationFeedback': vibrationFeedback,
      'intensity': intensity,
    };
  }

  HapticSettings copyWith({
    bool? enabled,
    bool? lightFeedback,
    bool? mediumFeedback,
    bool? heavyFeedback,
    bool? selectionFeedback,
    bool? vibrationFeedback,
    double? intensity,
  }) {
    return HapticSettings(
      enabled: enabled ?? this.enabled,
      lightFeedback: lightFeedback ?? this.lightFeedback,
      mediumFeedback: mediumFeedback ?? this.mediumFeedback,
      heavyFeedback: heavyFeedback ?? this.heavyFeedback,
      selectionFeedback: selectionFeedback ?? this.selectionFeedback,
      vibrationFeedback: vibrationFeedback ?? this.vibrationFeedback,
      intensity: intensity ?? this.intensity,
    );
  }
}

/// Gesture types enumeration
enum GestureType {
  swipeToComplete,
  swipeToDelete,
  longPressMenu,
  doubleTapEdit,
  pinchToZoom,
  pullToRefresh,
}

/// Haptic feedback types enumeration
enum HapticFeedbackType {
  light,
  medium,
  heavy,
  selection,
  vibrate,
}

/// Providers for gesture customization
final gestureCustomizationServiceProvider = Provider<GestureCustomizationService>((ref) {
  return const GestureCustomizationService();
});

final gestureSettingsProvider = StateNotifierProvider<GestureSettingsNotifier, GestureSettings>((ref) {
  return GestureSettingsNotifier(ref.read(gestureCustomizationServiceProvider));
});

final hapticSettingsProvider = StateNotifierProvider<HapticSettingsNotifier, HapticSettings>((ref) {
  return HapticSettingsNotifier(ref.read(gestureCustomizationServiceProvider));
});

/// Gesture settings notifier
class GestureSettingsNotifier extends StateNotifier<GestureSettings> {
  final GestureCustomizationService _service;

  GestureSettingsNotifier(this._service) : super(GestureSettings.defaultSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _service.getGestureSettings();
    state = settings;
  }

  Future<void> updateSettings(GestureSettings settings) async {
    await _service.saveGestureSettings(settings);
    state = settings;
  }

  Future<void> toggleGesture(GestureType gestureType, bool enabled) async {
    GestureSettings newSettings;
    
    switch (gestureType) {
      case GestureType.swipeToComplete:
        newSettings = state.copyWith(swipeToComplete: enabled);
        break;
      case GestureType.swipeToDelete:
        newSettings = state.copyWith(swipeToDelete: enabled);
        break;
      case GestureType.longPressMenu:
        newSettings = state.copyWith(longPressMenu: enabled);
        break;
      case GestureType.doubleTapEdit:
        newSettings = state.copyWith(doubleTapEdit: enabled);
        break;
      case GestureType.pinchToZoom:
        newSettings = state.copyWith(pinchToZoom: enabled);
        break;
      case GestureType.pullToRefresh:
        newSettings = state.copyWith(pullToRefresh: enabled);
        break;
    }
    
    await updateSettings(newSettings);
  }

  Future<void> updateSensitivity(GestureType gestureType, double sensitivity) async {
    GestureSettings newSettings;
    
    switch (gestureType) {
      case GestureType.swipeToComplete:
      case GestureType.swipeToDelete:
        newSettings = state.copyWith(swipeSensitivity: sensitivity);
        break;
      case GestureType.longPressMenu:
        newSettings = state.copyWith(longPressDuration: sensitivity);
        break;
      case GestureType.doubleTapEdit:
        newSettings = state.copyWith(doubleTapTimeout: sensitivity);
        break;
      case GestureType.pinchToZoom:
        newSettings = state.copyWith(pinchSensitivity: sensitivity);
        break;
      case GestureType.pullToRefresh:
        newSettings = state.copyWith(pullToRefreshThreshold: sensitivity);
        break;
    }
    
    await updateSettings(newSettings);
  }

  Future<void> resetToDefaults() async {
    await _service.resetToDefaults();
    state = GestureSettings.defaultSettings();
  }
}

/// Haptic settings notifier
class HapticSettingsNotifier extends StateNotifier<HapticSettings> {
  final GestureCustomizationService _service;

  HapticSettingsNotifier(this._service) : super(HapticSettings.defaultSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _service.getHapticSettings();
    state = settings;
  }

  Future<void> updateSettings(HapticSettings settings) async {
    await _service.saveHapticSettings(settings);
    state = settings;
  }

  Future<void> toggleHapticFeedback(bool enabled) async {
    final newSettings = state.copyWith(enabled: enabled);
    await updateSettings(newSettings);
  }

  Future<void> toggleFeedbackType(HapticFeedbackType type, bool enabled) async {
    HapticSettings newSettings;
    
    switch (type) {
      case HapticFeedbackType.light:
        newSettings = state.copyWith(lightFeedback: enabled);
        break;
      case HapticFeedbackType.medium:
        newSettings = state.copyWith(mediumFeedback: enabled);
        break;
      case HapticFeedbackType.heavy:
        newSettings = state.copyWith(heavyFeedback: enabled);
        break;
      case HapticFeedbackType.selection:
        newSettings = state.copyWith(selectionFeedback: enabled);
        break;
      case HapticFeedbackType.vibrate:
        newSettings = state.copyWith(vibrationFeedback: enabled);
        break;
    }
    
    await updateSettings(newSettings);
  }

  Future<void> updateIntensity(double intensity) async {
    final newSettings = state.copyWith(intensity: intensity);
    await updateSettings(newSettings);
  }

  Future<void> resetToDefaults() async {
    await _service.resetToDefaults();
    state = HapticSettings.defaultSettings();
  }
}