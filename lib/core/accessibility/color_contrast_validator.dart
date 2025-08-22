import 'package:flutter/material.dart';
import 'dart:math' as math;

/// WCAG color contrast validation and enforcement
class ColorContrastValidator {
  /// Calculate contrast ratio between two colors
  static double calculateContrastRatio(Color foreground, Color background) {
    final foregroundLuminance = _calculateLuminance(foreground);
    final backgroundLuminance = _calculateLuminance(background);
    
    final lighter = math.max(foregroundLuminance, backgroundLuminance);
    final darker = math.min(foregroundLuminance, backgroundLuminance);
    
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Calculate relative luminance of a color
  static double _calculateLuminance(Color color) {
    final r = _calculateChannelLuminance(color.r / 255.0);
    final g = _calculateChannelLuminance(color.g / 255.0);
    final b = _calculateChannelLuminance(color.b / 255.0);
    
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Calculate channel luminance
  static double _calculateChannelLuminance(double channel) {
    if (channel <= 0.03928) {
      return channel / 12.92;
    } else {
      return math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
    }
  }

  /// Check if contrast ratio meets WCAG AA standard
  static bool meetsWCAGAA(Color foreground, Color background, {bool isLargeText = false}) {
    final ratio = calculateContrastRatio(foreground, background);
    return isLargeText ? ratio >= 3.0 : ratio >= 4.5;
  }

  /// Check if contrast ratio meets WCAG AAA standard
  static bool meetsWCAGAAA(Color foreground, Color background, {bool isLargeText = false}) {
    final ratio = calculateContrastRatio(foreground, background);
    return isLargeText ? ratio >= 4.5 : ratio >= 7.0;
  }

  /// Get WCAG compliance level
  static WCAGComplianceLevel getComplianceLevel(Color foreground, Color background, {bool isLargeText = false}) {
    final ratio = calculateContrastRatio(foreground, background);
    
    if (isLargeText) {
      if (ratio >= 7.0) return WCAGComplianceLevel.aaa;
      if (ratio >= 4.5) return WCAGComplianceLevel.aa;
      if (ratio >= 3.0) return WCAGComplianceLevel.aa;
      return WCAGComplianceLevel.fail;
    } else {
      if (ratio >= 7.0) return WCAGComplianceLevel.aaa;
      if (ratio >= 4.5) return WCAGComplianceLevel.aa;
      return WCAGComplianceLevel.fail;
    }
  }

  /// Adjust color to meet minimum contrast ratio
  static Color adjustForContrast(
    Color originalColor,
    Color backgroundColor,
    {double minRatio = 4.5, bool preferLighter = true}
  ) {
    final currentRatio = calculateContrastRatio(originalColor, backgroundColor);
    
    if (currentRatio >= minRatio) {
      return originalColor; // Already meets requirements
    }

    // Try to adjust the original color to meet contrast requirements
    final backgroundLuminance = _calculateLuminance(backgroundColor);
    final hsl = HSLColor.fromColor(originalColor);
    
    // Determine if we should go lighter or darker
    final shouldGoLighter = preferLighter ^ (backgroundLuminance > 0.5);
    
    double lightness = hsl.lightness;
    const step = 0.05;
    const maxSteps = 20; // Prevent infinite loops
    int steps = 0;
    
    while (steps < maxSteps) {
      final testColor = hsl.withLightness(lightness).toColor();
      final testRatio = calculateContrastRatio(testColor, backgroundColor);
      
      if (testRatio >= minRatio) {
        return testColor;
      }
      
      if (shouldGoLighter) {
        lightness += step;
        if (lightness > 1.0) break;
      } else {
        lightness -= step;
        if (lightness < 0.0) break;
      }
      
      steps++;
    }
    
    // If we couldn't adjust the original color, return black or white
    final whiteRatio = calculateContrastRatio(Colors.white, backgroundColor);
    final blackRatio = calculateContrastRatio(Colors.black, backgroundColor);
    
    return whiteRatio > blackRatio ? Colors.white : Colors.black;
  }

  /// Get accessible text color for a given background
  static Color getAccessibleTextColor(Color backgroundColor, {bool preferDark = true}) {
    final whiteRatio = calculateContrastRatio(Colors.white, backgroundColor);
    final blackRatio = calculateContrastRatio(Colors.black, backgroundColor);
    
    // If both meet AA standards, use preference
    if (whiteRatio >= 4.5 && blackRatio >= 4.5) {
      return preferDark ? Colors.black : Colors.white;
    }
    
    // Use the one with better contrast
    return whiteRatio > blackRatio ? Colors.white : Colors.black;
  }

  /// Validate theme colors for accessibility
  static List<ColorAccessibilityIssue> validateThemeColors(ColorScheme colorScheme) {
    final issues = <ColorAccessibilityIssue>[];

    // Check primary color combinations
    if (!meetsWCAGAA(colorScheme.onPrimary, colorScheme.primary)) {
      issues.add(ColorAccessibilityIssue(
        foreground: colorScheme.onPrimary,
        background: colorScheme.primary,
        context: 'Primary/OnPrimary',
        severity: AccessibilitySeverity.high,
        message: 'Primary color combination does not meet WCAG AA standards',
      ));
    }

    // Check secondary color combinations
    if (!meetsWCAGAA(colorScheme.onSecondary, colorScheme.secondary)) {
      issues.add(ColorAccessibilityIssue(
        foreground: colorScheme.onSecondary,
        background: colorScheme.secondary,
        context: 'Secondary/OnSecondary',
        severity: AccessibilitySeverity.high,
        message: 'Secondary color combination does not meet WCAG AA standards',
      ));
    }

    // Check surface color combinations
    if (!meetsWCAGAA(colorScheme.onSurface, colorScheme.surface)) {
      issues.add(ColorAccessibilityIssue(
        foreground: colorScheme.onSurface,
        background: colorScheme.surface,
        context: 'Surface/OnSurface',
        severity: AccessibilitySeverity.critical,
        message: 'Surface color combination does not meet WCAG AA standards',
      ));
    }

    // Check error color combinations
    if (!meetsWCAGAA(colorScheme.onError, colorScheme.error)) {
      issues.add(ColorAccessibilityIssue(
        foreground: colorScheme.onError,
        background: colorScheme.error,
        context: 'Error/OnError',
        severity: AccessibilitySeverity.high,
        message: 'Error color combination does not meet WCAG AA standards',
      ));
    }

    // Check surface combinations (background is deprecated)
    if (!meetsWCAGAA(colorScheme.onSurface, colorScheme.surface)) {
      issues.add(ColorAccessibilityIssue(
        foreground: colorScheme.onSurface,
        background: colorScheme.surface,
        context: 'Surface/OnSurface (background)',
        severity: AccessibilitySeverity.critical,
        message: 'Surface color combination does not meet WCAG AA standards',
      ));
    }

    return issues;
  }

  /// Create accessible ColorScheme from base colors
  static ColorScheme createAccessibleColorScheme({
    required Color primary,
    required Color background,
    Brightness brightness = Brightness.light,
  }) {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
    );

    return ColorScheme(
      brightness: brightness,
      primary: adjustForContrast(
        baseScheme.primary,
        background,
        minRatio: 4.5,
      ),
      onPrimary: getAccessibleTextColor(baseScheme.primary),
      secondary: adjustForContrast(
        baseScheme.secondary,
        background,
        minRatio: 4.5,
      ),
      onSecondary: getAccessibleTextColor(baseScheme.secondary),
      error: adjustForContrast(
        baseScheme.error,
        background,
        minRatio: 4.5,
      ),
      onError: getAccessibleTextColor(baseScheme.error),
      surface: baseScheme.surface,
      onSurface: getAccessibleTextColor(baseScheme.surface),
      surfaceContainerHighest: baseScheme.surfaceContainerHighest,
      onSurfaceVariant: getAccessibleTextColor(baseScheme.surfaceContainerHighest),
      outline: adjustForContrast(
        baseScheme.outline,
        baseScheme.surface,
        minRatio: 3.0, // Lower requirement for outline elements
      ),
      outlineVariant: baseScheme.outlineVariant,
      shadow: baseScheme.shadow,
      scrim: baseScheme.scrim,
      inverseSurface: baseScheme.inverseSurface,
      onInverseSurface: getAccessibleTextColor(baseScheme.inverseSurface),
      inversePrimary: adjustForContrast(
        baseScheme.inversePrimary,
        baseScheme.inverseSurface,
        minRatio: 4.5,
      ),
      // Material 3 container colors
      primaryContainer: baseScheme.primaryContainer,
      onPrimaryContainer: getAccessibleTextColor(baseScheme.primaryContainer),
      secondaryContainer: baseScheme.secondaryContainer,
      onSecondaryContainer: getAccessibleTextColor(baseScheme.secondaryContainer),
      tertiary: adjustForContrast(
        baseScheme.tertiary,
        background,
        minRatio: 4.5,
      ),
      onTertiary: getAccessibleTextColor(baseScheme.tertiary),
      tertiaryContainer: baseScheme.tertiaryContainer,
      onTertiaryContainer: getAccessibleTextColor(baseScheme.tertiaryContainer),
      errorContainer: baseScheme.errorContainer,
      onErrorContainer: getAccessibleTextColor(baseScheme.errorContainer),
      surfaceTint: baseScheme.surfaceTint,
    );
  }

  /// Generate color accessibility report
  static ColorAccessibilityReport generateReport(ColorScheme colorScheme) {
    final issues = validateThemeColors(colorScheme);
    
    final criticalIssues = issues.where((i) => i.severity == AccessibilitySeverity.critical).length;
    final highIssues = issues.where((i) => i.severity == AccessibilitySeverity.high).length;
    final mediumIssues = issues.where((i) => i.severity == AccessibilitySeverity.medium).length;
    
    AccessibilityGrade grade;
    if (criticalIssues > 0) {
      grade = AccessibilityGrade.f;
    } else if (highIssues > 2) {
      grade = AccessibilityGrade.d;
    } else if (highIssues > 0) {
      grade = AccessibilityGrade.c;
    } else if (mediumIssues > 2) {
      grade = AccessibilityGrade.b;
    } else {
      grade = AccessibilityGrade.a;
    }

    return ColorAccessibilityReport(
      issues: issues,
      overallGrade: grade,
      totalIssues: issues.length,
      criticalIssues: criticalIssues,
      highIssues: highIssues,
      mediumIssues: mediumIssues,
    );
  }
}

/// WCAG compliance levels
enum WCAGComplianceLevel {
  fail,
  aa,
  aaa,
}

/// Accessibility severity levels
enum AccessibilitySeverity {
  low,
  medium,
  high,
  critical,
}

/// Accessibility grade
enum AccessibilityGrade {
  a, // Excellent
  b, // Good
  c, // Fair
  d, // Poor
  f, // Fail
}

/// Color accessibility issue
class ColorAccessibilityIssue {
  final Color foreground;
  final Color background;
  final String context;
  final AccessibilitySeverity severity;
  final String message;
  final double? contrastRatio;
  final Color? suggestedForeground;

  ColorAccessibilityIssue({
    required this.foreground,
    required this.background,
    required this.context,
    required this.severity,
    required this.message,
    this.contrastRatio,
    this.suggestedForeground,
  });

  /// Get contrast ratio if not already calculated
  double getContrastRatio() {
    return contrastRatio ?? ColorContrastValidator.calculateContrastRatio(foreground, background);
  }

  /// Get suggested foreground color
  Color getSuggestedForeground() {
    return suggestedForeground ?? ColorContrastValidator.adjustForContrast(
      foreground,
      background,
      minRatio: 4.5,
    );
  }

  @override
  String toString() {
    return 'ColorAccessibilityIssue(context: $context, severity: $severity, ratio: ${getContrastRatio().toStringAsFixed(2)}, message: $message)';
  }
}

/// Color accessibility report
class ColorAccessibilityReport {
  final List<ColorAccessibilityIssue> issues;
  final AccessibilityGrade overallGrade;
  final int totalIssues;
  final int criticalIssues;
  final int highIssues;
  final int mediumIssues;

  const ColorAccessibilityReport({
    required this.issues,
    required this.overallGrade,
    required this.totalIssues,
    required this.criticalIssues,
    required this.highIssues,
    required this.mediumIssues,
  });

  /// Check if the color scheme is accessible
  bool get isAccessible => criticalIssues == 0 && highIssues == 0;

  /// Get grade letter
  String get gradeLetter => overallGrade.name.toUpperCase();

  /// Get grade description
  String get gradeDescription {
    switch (overallGrade) {
      case AccessibilityGrade.a:
        return 'Excellent accessibility';
      case AccessibilityGrade.b:
        return 'Good accessibility with minor issues';
      case AccessibilityGrade.c:
        return 'Fair accessibility with some issues';
      case AccessibilityGrade.d:
        return 'Poor accessibility with major issues';
      case AccessibilityGrade.f:
        return 'Fails accessibility standards';
    }
  }

  @override
  String toString() {
    return 'ColorAccessibilityReport(grade: $gradeLetter, total: $totalIssues, critical: $criticalIssues, high: $highIssues, medium: $mediumIssues)';
  }
}

/// Widget for testing color contrast in development
class ColorContrastTester extends StatelessWidget {
  final Color foreground;
  final Color background;
  final String text;
  final bool isLargeText;

  const ColorContrastTester({
    super.key,
    required this.foreground,
    required this.background,
    this.text = 'Sample Text',
    this.isLargeText = false,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = ColorContrastValidator.calculateContrastRatio(foreground, background);
    final meetsAA = ColorContrastValidator.meetsWCAGAA(foreground, background, isLargeText: isLargeText);
    final meetsAAA = ColorContrastValidator.meetsWCAGAAA(foreground, background, isLargeText: isLargeText);

    return Container(
      color: background,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              color: foreground,
              fontSize: isLargeText ? 18 : 14,
              fontWeight: isLargeText ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Contrast Ratio: ${ratio.toStringAsFixed(2)}:1',
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            'WCAG AA: ${meetsAA ? "✓" : "✗"} | AAA: ${meetsAAA ? "✓" : "✗"}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}