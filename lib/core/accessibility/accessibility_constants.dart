import 'package:flutter/material.dart';

/// Accessibility constants and utilities for WCAG AA compliance
import 'package:flutter/semantics.dart';
import 'color_contrast_validator.dart';

/// Accessibility constants following WCAG AA guidelines
class AccessibilityConstants {
  // Touch target sizes (minimum 44dp for WCAG AA)
  static const double minTouchTarget = 44.0;
  static const double recommendedTouchTarget = 48.0;
  static const double largeTouchTarget = 56.0;
  
  // Focus indicators
  static const double focusIndicatorWidth = 2.0;
  static const Color focusIndicatorColor = Colors.blue;
  static const BorderRadius focusIndicatorRadius = BorderRadius.all(Radius.circular(4));
  
  // Animation durations for accessibility
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration reducedAnimationDuration = Duration(milliseconds: 150);
  static const Duration noAnimationDuration = Duration.zero;
  
  // Contrast ratios (WCAG AA requires 4.5:1 for normal text, 3:1 for large text)
  static const double minContrastRatio = 4.5;
  static const double largeTextContrastRatio = 3.0;
  
  // Glassmorphism accessibility adjustments
  static const double highContrastGlassOpacity = 0.9; // More opaque for better readability
  static const double reducedBlurRadius = 2.0; // Minimal blur for high contrast mode
  
  // Semantic labels
  static const String taskCardSemanticLabel = 'Task card';
  static const String completedTaskSemanticHint = 'Double tap to mark as incomplete';
  static const String incompleteTaskSemanticHint = 'Double tap to mark as complete';
  static const String deleteTaskSemanticHint = 'Swipe left or use context menu to delete';
  static const String editTaskSemanticHint = 'Double tap to edit task details';
  static const String navigationSemanticLabel = 'Bottom navigation';
  static const String fabSemanticLabel = 'Create new task';
  static const String fabSemanticHint = 'Opens task creation options';
  
  // Screen reader announcements
  static const String taskCompletedAnnouncement = 'Task completed';
  static const String taskUncompletedAnnouncement = 'Task marked as incomplete';
  static const String taskCreatedAnnouncement = 'New task created';
  static const String taskDeletedAnnouncement = 'Task deleted';
  static const String taskEditedAnnouncement = 'Task updated';
  
  // High contrast mode colors
  static const Color highContrastBackground = Color(0xFF000000);
  static const Color highContrastSurface = Color(0xFF1A1A1A);
  static const Color highContrastText = Color(0xFFFFFFFF);
  static const Color highContrastPrimary = Color(0xFF66BBFF);
  static const Color highContrastError = Color(0xFFFF6B6B);
  static const Color highContrastSuccess = Color(0xFF51CF66);
  static const Color highContrastWarning = Color(0xFFFFD93D);
}

/// Extension methods for accessibility features
extension AccessibilityExtensions on Widget {
  /// Wraps widget with minimum touch target size
  Widget withMinTouchTarget({
    double size = AccessibilityConstants.minTouchTarget,
    VoidCallback? onTap,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          child: this,
        ),
      ),
    );
  }
  
  /// Wraps widget with focus indicator
  Widget withFocusIndicator({
    bool autoFocus = false,
    FocusNode? focusNode,
  }) {
    return Focus(
      autofocus: autoFocus,
      focusNode: focusNode,
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          return Container(
            decoration: hasFocus
                ? BoxDecoration(
                    border: Border.all(
                      color: AccessibilityConstants.focusIndicatorColor,
                      width: AccessibilityConstants.focusIndicatorWidth,
                    ),
                    borderRadius: AccessibilityConstants.focusIndicatorRadius,
                  )
                : null,
            child: this,
          );
        },
      ),
    );
  }
  
  /// Wraps widget with comprehensive semantics
  Widget withSemantics({
    required String label,
    String? hint,
    String? value,
    bool? button,
    bool? focused,
    bool? selected,
    bool? enabled,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    void Function(bool)? onMoveCursorForwardByCharacter,
    void Function(bool)? onMoveCursorBackwardByCharacter,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: button ?? false,
      focused: focused ?? false,
      selected: selected ?? false,
      enabled: enabled ?? true,
      onTap: onTap,
      onLongPress: onLongPress,
      onMoveCursorForwardByCharacter: onMoveCursorForwardByCharacter,
      onMoveCursorBackwardByCharacter: onMoveCursorBackwardByCharacter,
      child: this,
    );
  }
}

/// Utility class for checking accessibility preferences
class AccessibilityUtils {
  /// Check if reduce motion is enabled
  static bool shouldReduceMotion(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }
  
  /// Check if high contrast mode should be used
  static bool shouldUseHighContrast(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }
  
  /// Check if large text is enabled
  static bool isLargeTextEnabled(BuildContext context) {
    final textScaler = MediaQuery.of(context).textScaler;
    return textScaler.scale(1.0) > 1.3;
  }
  
  /// Get appropriate animation duration based on accessibility settings
  static Duration getAnimationDuration(BuildContext context, Duration defaultDuration) {
    if (shouldReduceMotion(context)) {
      return AccessibilityConstants.noAnimationDuration;
    }
    return defaultDuration;
  }
  
  /// Get glassmorphism settings for accessibility
  static AccessibleGlassSettings getAccessibleGlassSettings(BuildContext context) {
    final highContrast = shouldUseHighContrast(context);
    return AccessibleGlassSettings(
      opacity: highContrast ? AccessibilityConstants.highContrastGlassOpacity : null,
      blurRadius: highContrast ? AccessibilityConstants.reducedBlurRadius : null,
      useHighContrastColors: highContrast,
    );
  }

  /// Validate and adjust colors for accessibility
  static Color getAccessibleColor(Color foreground, Color background, {bool isLargeText = false}) {
    if (ColorContrastValidator.meetsWCAGAA(foreground, background, isLargeText: isLargeText)) {
      return foreground;
    }
    return ColorContrastValidator.adjustForContrast(foreground, background);
  }

  /// Get accessible text color for any background
  static Color getAccessibleTextColor(Color backgroundColor) {
    return ColorContrastValidator.getAccessibleTextColor(backgroundColor);
  }

  /// Validate if color combination is accessible
  static bool isAccessibleColorCombination(Color foreground, Color background, {bool isLargeText = false}) {
    return ColorContrastValidator.meetsWCAGAA(foreground, background, isLargeText: isLargeText);
  }
  
  /// Announce text to screen reader
  static void announceToScreenReader(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }
  
  /// Calculate contrast ratio between two colors
  static double calculateContrastRatio(Color foreground, Color background) {
    final foregroundLuminance = _calculateLuminance(foreground);
    final backgroundLuminance = _calculateLuminance(background);
    
    final lighter = foregroundLuminance > backgroundLuminance 
        ? foregroundLuminance 
        : backgroundLuminance;
    final darker = foregroundLuminance > backgroundLuminance 
        ? backgroundLuminance 
        : foregroundLuminance;
        
    return (lighter + 0.05) / (darker + 0.05);
  }
  
  /// Calculate relative luminance of a color
  static double _calculateLuminance(Color color) {
    final r = _calculateChannelLuminance(color.r / 255.0);
    final g = _calculateChannelLuminance(color.g / 255.0);
    final b = _calculateChannelLuminance(color.b / 255.0);
    
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }
  
  static double _calculateChannelLuminance(double channel) {
    if (channel <= 0.03928) {
      return channel / 12.92;
    } else {
      return ((channel + 0.055) / 1.055).pow(2.4);
    }
  }
}

/// Settings for accessible glassmorphism
class AccessibleGlassSettings {
  final double? opacity;
  final double? blurRadius;
  final bool useHighContrastColors;
  
  const AccessibleGlassSettings({
    this.opacity,
    this.blurRadius,
    this.useHighContrastColors = false,
  });
}

/// Extension for num.pow() since it's not available in the current context
extension NumExtension on num {
  double pow(num exponent) {
    if (exponent == 0) return 1.0;
    if (exponent == 1) return toDouble();
    
    double result = 1.0;
    double base = toDouble();
    int exp = exponent.abs().toInt();
    
    while (exp > 0) {
      if (exp % 2 == 1) {
        result *= base;
      }
      base *= base;
      exp ~/= 2;
    }
    
    return exponent < 0 ? 1.0 / result : result;
  }
}