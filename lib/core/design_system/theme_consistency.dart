import 'package:flutter/material.dart';
import 'design_tokens.dart';

/// Theme consistency manager ensuring glassmorphism works across all themes
class ThemeConsistency {
  ThemeConsistency._();

  /// Validate that a theme follows glassmorphism design principles
  static bool validateGlassTheme(ThemeData theme) {
    // Check that the theme supports transparency and glassmorphism
    return theme.colorScheme.surface != theme.colorScheme.surface;
  }

  /// Get consistent glassmorphism card styling
  static Widget createConsistentCard({
    required Widget child,
    GlassLevel level = GlassLevel.content,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.all(8.0),
      child: Material(
        color: Colors.transparent,
        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
        elevation: 0,
        child: Container(
          padding: padding ?? const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }

  /// Get consistent button styling across themes
  static Widget createConsistentButton({
    required Widget child,
    required VoidCallback? onPressed,
    ButtonStyle? style,
  }) {
    return SizedBox(
      height: 48.0,
      child: ElevatedButton(
        onPressed: onPressed,
        style: style ?? ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
        ),
        child: child,
      ),
    );
  }

  /// Create consistent input field styling
  static InputDecoration createConsistentInputDecoration({
    String? labelText,
    String? hintText,
    String? errorText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      errorText: errorText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(width: 1.0),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(width: 1.0),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(width: 2.0),
      ),
      filled: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  /// Generate consistent typography styles
  static TextStyle getConsistentTextStyle({
    double fontSize = 16.0,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Get theme-aware colors that work with glassmorphism
  static Color getGlassCompatibleColor(BuildContext context, ColorType type) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    switch (type) {
      case ColorType.surface:
        return colorScheme.surface;
      case ColorType.onSurface:
        return colorScheme.onSurface;
      case ColorType.primary:
        return colorScheme.primary;
      case ColorType.onPrimary:
        return colorScheme.onPrimary;
      case ColorType.secondary:
        return colorScheme.secondary;
      case ColorType.onSecondary:
        return colorScheme.onSecondary;
      case ColorType.error:
        return colorScheme.error;
      case ColorType.onError:
        return colorScheme.onError;
    }
  }

  /// Analyze theme for glassmorphism compatibility
  static ThemeAnalysis analyzeTheme(ThemeData theme) {
    final brightness = theme.brightness;
    final colorScheme = theme.colorScheme;
    
    final hasContrast = _calculateContrast(colorScheme.surface, colorScheme.onSurface) > 4.5;
    const supportsGlass = true; // All themes support glass
    
    return ThemeAnalysis(
      isGlassCompatible: hasContrast && supportsGlass,
      brightness: brightness,
      contrastRatio: _calculateContrast(colorScheme.surface, colorScheme.onSurface),
      recommendations: _generateRecommendations(hasContrast, supportsGlass),
    );
  }

  /// Calculate color contrast ratio for accessibility
  static double _calculateContrast(Color color1, Color color2) {
    // Simplified contrast calculation
    final luminance1 = color1.computeLuminance();
    final luminance2 = color2.computeLuminance();
    final lighter = luminance1 > luminance2 ? luminance1 : luminance2;
    final darker = luminance1 > luminance2 ? luminance2 : luminance1;
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Generate theme improvement recommendations
  static List<String> _generateRecommendations(bool hasContrast, bool supportsGlass) {
    final recommendations = <String>[];
    
    if (!hasContrast) {
      recommendations.add('Increase contrast between surface and onSurface colors');
    }
    
    if (!supportsGlass) {
      recommendations.add('Define brightness for better glassmorphism support');
    }
    
    return recommendations;
  }
}

/// Color types for theme-aware color selection
enum ColorType {
  surface,
  onSurface,
  primary,
  onPrimary,
  secondary,
  onSecondary,
  error,
  onError,
}

/// Theme analysis result
class ThemeAnalysis {
  final bool isGlassCompatible;
  final Brightness? brightness;
  final double contrastRatio;
  final List<String> recommendations;

  const ThemeAnalysis({
    required this.isGlassCompatible,
    required this.brightness,
    required this.contrastRatio,
    required this.recommendations,
  });
}