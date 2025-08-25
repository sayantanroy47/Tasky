import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing accessibility features
class AccessibilityService {
  static const String _highContrastKey = 'accessibility_high_contrast';
  static const String _largeTextKey = 'accessibility_large_text';
  static const String _screenReaderKey = 'accessibility_screen_reader';
  static const String _hapticFeedbackKey = 'accessibility_haptic_feedback';
  static const String _voiceOverKey = 'accessibility_voice_over';
  static const String _reducedMotionKey = 'accessibility_reduced_motion';
  static const String _colorBlindModeKey = 'accessibility_color_blind_mode';

  SharedPreferences? _prefs;
  AccessibilitySettings _settings = const AccessibilitySettings();

  /// Initialize the accessibility service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
  }

  /// Load accessibility settings
  Future<void> _loadSettings() async {
    if (_prefs == null) return;

    _settings = AccessibilitySettings(
      highContrastMode: _prefs!.getBool(_highContrastKey) ?? false,
      largeTextMode: _prefs!.getBool(_largeTextKey) ?? false,
      screenReaderEnabled: _prefs!.getBool(_screenReaderKey) ?? false,
      hapticFeedbackEnabled: _prefs!.getBool(_hapticFeedbackKey) ?? true,
      voiceOverEnabled: _prefs!.getBool(_voiceOverKey) ?? false,
      reducedMotionMode: _prefs!.getBool(_reducedMotionKey) ?? false,
      colorBlindMode: ColorBlindMode.values[_prefs!.getInt(_colorBlindModeKey) ?? 0],
    );
  }

  /// Get current accessibility settings
  AccessibilitySettings get settings => _settings;

  /// Update high contrast mode
  Future<void> setHighContrastMode(bool enabled) async {
    _settings = _settings.copyWith(highContrastMode: enabled);
    await _prefs?.setBool(_highContrastKey, enabled);
    _notifySettingsChanged();
  }

  /// Update large text mode
  Future<void> setLargeTextMode(bool enabled) async {
    _settings = _settings.copyWith(largeTextMode: enabled);
    await _prefs?.setBool(_largeTextKey, enabled);
    _notifySettingsChanged();
  }

  /// Update screen reader support
  Future<void> setScreenReaderEnabled(bool enabled) async {
    _settings = _settings.copyWith(screenReaderEnabled: enabled);
    await _prefs?.setBool(_screenReaderKey, enabled);
    _notifySettingsChanged();
  }

  /// Update haptic feedback
  Future<void> setHapticFeedbackEnabled(bool enabled) async {
    _settings = _settings.copyWith(hapticFeedbackEnabled: enabled);
    await _prefs?.setBool(_hapticFeedbackKey, enabled);
    _notifySettingsChanged();
  }

  /// Update voice over support
  Future<void> setVoiceOverEnabled(bool enabled) async {
    _settings = _settings.copyWith(voiceOverEnabled: enabled);
    await _prefs?.setBool(_voiceOverKey, enabled);
    _notifySettingsChanged();
  }

  /// Update reduced motion mode
  Future<void> setReducedMotionMode(bool enabled) async {
    _settings = _settings.copyWith(reducedMotionMode: enabled);
    await _prefs?.setBool(_reducedMotionKey, enabled);
    _notifySettingsChanged();
  }

  /// Update color blind mode
  Future<void> setColorBlindMode(ColorBlindMode mode) async {
    _settings = _settings.copyWith(colorBlindMode: mode);
    await _prefs?.setInt(_colorBlindModeKey, mode.index);
    _notifySettingsChanged();
  }

  /// Provide haptic feedback if enabled
  Future<void> provideHapticFeedback(HapticFeedbackType type) async {
    if (!_settings.hapticFeedbackEnabled) return;

    switch (type) {
      case HapticFeedbackType.light:
        await HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.medium:
        await HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        await HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selection:
        await HapticFeedback.selectionClick();
        break;
      case HapticFeedbackType.vibrate:
        await HapticFeedback.vibrate();
        break;
    }
  }

  /// Get semantic label for screen readers
  String getSemanticLabel(String text, {String? context}) {
    if (!_settings.screenReaderEnabled) return text;

    // Add context for better screen reader experience
    if (context != null) {
      return '$context: $text';
    }

    return text;
  }

  /// Get accessible color scheme
  ColorScheme getAccessibleColorScheme(ColorScheme baseScheme) {
    if (_settings.highContrastMode) {
      return _getHighContrastColorScheme(baseScheme);
    }

    if (_settings.colorBlindMode != ColorBlindMode.none) {
      return _getColorBlindFriendlyScheme(baseScheme, _settings.colorBlindMode);
    }

    return baseScheme;
  }

  /// Get high contrast color scheme
  ColorScheme _getHighContrastColorScheme(ColorScheme baseScheme) {
    return baseScheme.copyWith(
      primary: Colors.black,
      onPrimary: Colors.white,
      secondary: Colors.black,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
      error: Colors.red[900]!,
      onError: Colors.white,
    );
  }

  /// Get color blind friendly color scheme
  ColorScheme _getColorBlindFriendlyScheme(ColorScheme baseScheme, ColorBlindMode mode) {
    switch (mode) {
      case ColorBlindMode.protanopia:
        return baseScheme.copyWith(
          primary: const Color(0xFF1976D2), // Blue 700 equivalent
          secondary: const Color(0xFFF57C00), // Orange 700 equivalent  
          tertiary: const Color(0xFF388E3C), // Green 700 equivalent
          error: const Color(0xFFE65100), // Orange 900 equivalent
        );
      case ColorBlindMode.deuteranopia:
        return baseScheme.copyWith(
          primary: Colors.blue[700]!,
          secondary: Colors.purple[700]!,
          error: Colors.red[900]!,
        );
      case ColorBlindMode.tritanopia:
        return baseScheme.copyWith(
          primary: const Color(0xFFD32F2F), // Red 700 equivalent
          secondary: const Color(0xFF388E3C), // Green 700 equivalent
          tertiary: const Color(0xFF1976D2), // Blue 700 equivalent  
          error: const Color(0xFFB71C1C), // Red 900 equivalent
        );
      case ColorBlindMode.none:
        return baseScheme;
    }
  }

  /// Get accessible text theme
  TextTheme getAccessibleTextTheme(TextTheme baseTheme) {
    if (!_settings.largeTextMode) return baseTheme;

    return baseTheme.copyWith(
      displayLarge: baseTheme.displayLarge?.copyWith(fontSize: (baseTheme.displayLarge?.fontSize ?? 57) * 1.3),
      displayMedium: baseTheme.displayMedium?.copyWith(fontSize: (baseTheme.displayMedium?.fontSize ?? 45) * 1.3),
      displaySmall: baseTheme.displaySmall?.copyWith(fontSize: (baseTheme.displaySmall?.fontSize ?? 36) * 1.3),
      headlineLarge: baseTheme.headlineLarge?.copyWith(fontSize: (baseTheme.headlineLarge?.fontSize ?? 32) * 1.3),
      headlineMedium: baseTheme.headlineMedium?.copyWith(fontSize: (baseTheme.headlineMedium?.fontSize ?? 28) * 1.3),
      headlineSmall: baseTheme.headlineSmall?.copyWith(fontSize: (baseTheme.headlineSmall?.fontSize ?? 24) * 1.3),
      titleLarge: baseTheme.titleLarge?.copyWith(fontSize: (baseTheme.titleLarge?.fontSize ?? 22) * 1.3),
      titleMedium: baseTheme.titleMedium?.copyWith(fontSize: (baseTheme.titleMedium?.fontSize ?? 16) * 1.3),
      titleSmall: baseTheme.titleSmall?.copyWith(fontSize: (baseTheme.titleSmall?.fontSize ?? 14) * 1.3),
      bodyLarge: baseTheme.bodyLarge?.copyWith(fontSize: (baseTheme.bodyLarge?.fontSize ?? 16) * 1.3),
      bodyMedium: baseTheme.bodyMedium?.copyWith(fontSize: (baseTheme.bodyMedium?.fontSize ?? 14) * 1.3),
      bodySmall: baseTheme.bodySmall?.copyWith(fontSize: (baseTheme.bodySmall?.fontSize ?? 12) * 1.3),
      labelLarge: baseTheme.labelLarge?.copyWith(fontSize: (baseTheme.labelLarge?.fontSize ?? 14) * 1.3),
      labelMedium: baseTheme.labelMedium?.copyWith(fontSize: (baseTheme.labelMedium?.fontSize ?? 12) * 1.3),
      labelSmall: baseTheme.labelSmall?.copyWith(fontSize: (baseTheme.labelSmall?.fontSize ?? 11) * 1.3),
    );
  }

  /// Get animation duration based on reduced motion setting
  Duration getAnimationDuration(Duration baseDuration) {
    if (_settings.reducedMotionMode) {
      return Duration.zero;
    }
    return baseDuration;
  }

  /// Get curve based on reduced motion setting
  Curve getAnimationCurve(Curve baseCurve) {
    if (_settings.reducedMotionMode) {
      return Curves.linear;
    }
    return baseCurve;
  }

  /// Check if device has accessibility features enabled
  Future<SystemAccessibilityInfo> getSystemAccessibilityInfo() async {
    // This would check system-level accessibility settings
    // For now, we'll return mock data
    return const SystemAccessibilityInfo(
      isScreenReaderEnabled: false,
      isHighContrastEnabled: false,
      isLargeTextEnabled: false,
      isReducedMotionEnabled: false,
    );
  }

  /// Announce text for screen readers
  void announceForScreenReader(String text) {
    if (!_settings.screenReaderEnabled) return;
    
    // Use SemanticsService to announce text
    SystemSound.play(SystemSoundType.click);
    // Note: SemanticsService.announce is not available in current Flutter version
    // This would need to be implemented with platform-specific code
  }

  /// Get focus order for keyboard navigation
  List<FocusNode> getFocusOrder(List<FocusNode> nodes) {
    // Return nodes in logical order for keyboard navigation
    return nodes;
  }

  /// Validate color contrast ratio
  bool hasGoodContrast(Color foreground, Color background) {
    final luminance1 = foreground.computeLuminance();
    final luminance2 = background.computeLuminance();
    
    final lighter = luminance1 > luminance2 ? luminance1 : luminance2;
    final darker = luminance1 > luminance2 ? luminance2 : luminance1;
    
    final contrastRatio = (lighter + 0.05) / (darker + 0.05);
    
    // WCAG AA standard requires 4.5:1 for normal text
    return contrastRatio >= 4.5;
  }

  /// Settings change notification (would use a proper state management solution)
  void _notifySettingsChanged() {
    // This would notify listeners about settings changes
    // In a real app, you'd use a StateNotifier or similar
  }
}

/// Accessibility settings data class
class AccessibilitySettings {
  final bool highContrastMode;
  final bool largeTextMode;
  final bool screenReaderEnabled;
  final bool hapticFeedbackEnabled;
  final bool voiceOverEnabled;
  final bool reducedMotionMode;
  final ColorBlindMode colorBlindMode;

  const AccessibilitySettings({
    this.highContrastMode = false,
    this.largeTextMode = false,
    this.screenReaderEnabled = false,
    this.hapticFeedbackEnabled = true,
    this.voiceOverEnabled = false,
    this.reducedMotionMode = false,
    this.colorBlindMode = ColorBlindMode.none,
  });

  AccessibilitySettings copyWith({
    bool? highContrastMode,
    bool? largeTextMode,
    bool? screenReaderEnabled,
    bool? hapticFeedbackEnabled,
    bool? voiceOverEnabled,
    bool? reducedMotionMode,
    ColorBlindMode? colorBlindMode,
  }) {
    return AccessibilitySettings(
      highContrastMode: highContrastMode ?? this.highContrastMode,
      largeTextMode: largeTextMode ?? this.largeTextMode,
      screenReaderEnabled: screenReaderEnabled ?? this.screenReaderEnabled,
      hapticFeedbackEnabled: hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
      voiceOverEnabled: voiceOverEnabled ?? this.voiceOverEnabled,
      reducedMotionMode: reducedMotionMode ?? this.reducedMotionMode,
      colorBlindMode: colorBlindMode ?? this.colorBlindMode,
    );
  }
}

/// Color blind mode options
enum ColorBlindMode {
  none,
  protanopia,    // Red-blind
  deuteranopia,  // Green-blind
  tritanopia,    // Blue-blind
}

/// Haptic feedback types
enum HapticFeedbackType {
  light,
  medium,
  heavy,
  selection,
  vibrate,
}

/// System accessibility information
class SystemAccessibilityInfo {
  final bool isScreenReaderEnabled;
  final bool isHighContrastEnabled;
  final bool isLargeTextEnabled;
  final bool isReducedMotionEnabled;

  const SystemAccessibilityInfo({
    required this.isScreenReaderEnabled,
    required this.isHighContrastEnabled,
    required this.isLargeTextEnabled,
    required this.isReducedMotionEnabled,
  });
}

/// Provider for accessibility service
final accessibilityServiceProvider = Provider<AccessibilityService>((ref) {
  return AccessibilityService();
});

/// Provider for accessibility settings
final accessibilitySettingsProvider = Provider<AccessibilitySettings>((ref) {
  final service = ref.read(accessibilityServiceProvider);
  return service.settings;
});