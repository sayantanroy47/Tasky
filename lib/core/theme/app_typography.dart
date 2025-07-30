import 'package:flutter/material.dart';

/// Typography system for the Task Tracker App
/// Provides Material 3 typography with consistent text styles
class AppTypography {
  // Private constructor to prevent instantiation
  AppTypography._();

  /// Base font family
  static const String fontFamily = 'Roboto';

  /// Create complete text theme for the app
  static TextTheme textTheme(ColorScheme colorScheme) {
    return TextTheme(
      // Display styles
      displayLarge: displayLarge(colorScheme),
      displayMedium: displayMedium(colorScheme),
      displaySmall: displaySmall(colorScheme),
      
      // Headline styles
      headlineLarge: headlineLarge(colorScheme),
      headlineMedium: headlineMedium(colorScheme),
      headlineSmall: headlineSmall(colorScheme),
      
      // Title styles
      titleLarge: titleLarge(colorScheme),
      titleMedium: titleMedium(colorScheme),
      titleSmall: titleSmall(colorScheme),
      
      // Body styles
      bodyLarge: bodyLarge(colorScheme),
      bodyMedium: bodyMedium(colorScheme),
      bodySmall: bodySmall(colorScheme),
      
      // Label styles
      labelLarge: labelLarge(colorScheme),
      labelMedium: labelMedium(colorScheme),
      labelSmall: labelSmall(colorScheme),
    );
  }

  // Display styles
  static TextStyle displayLarge(ColorScheme colorScheme) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      height: 1.12,
      color: colorScheme.onSurface,
    );
  }

  static TextStyle displayMedium(ColorScheme colorScheme) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 45,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.16,
      color: colorScheme.onSurface,
    );
  }

  static TextStyle displaySmall(ColorScheme colorScheme) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 36,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.22,
      color: colorScheme.onSurface,
    );
  }

  // Headline styles
  static TextStyle headlineLarge(ColorScheme colorScheme) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 32,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.25,
      color: colorScheme.onSurface,
    );
  }

  static TextStyle headlineMedium(ColorScheme colorScheme) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 28,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.29,
      color: colorScheme.onSurface,
    );
  }

  static TextStyle headlineSmall(ColorScheme colorScheme) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 24,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.33,
      color: colorScheme.onSurface,
    );
  }

  // Title styles
  static TextStyle titleLarge(ColorScheme colorScheme) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 22,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.27,
      color: colorScheme.onSurface,
    );
  }

  static TextStyle titleMedium(ColorScheme colorScheme) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      height: 1.50,
      color: colorScheme.onSurface,
    );
  }

  static TextStyle titleSmall(ColorScheme colorScheme) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.43,
      color: colorScheme.onSurface,
    );
  }

  // Body styles
  static TextStyle bodyLarge(ColorScheme colorScheme) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      height: 1.50,
      color: colorScheme.onSurface,
    );
  }

  static TextStyle bodyMedium(ColorScheme colorScheme) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.43,
      color: colorScheme.onSurface,
    );
  }

  static TextStyle bodySmall(ColorScheme colorScheme) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      height: 1.33,
      color: colorScheme.onSurfaceVariant,
    );
  }

  // Label styles
  static TextStyle labelLarge(ColorScheme colorScheme) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.43,
      color: colorScheme.onSurface,
    );
  }

  static TextStyle labelMedium(ColorScheme colorScheme) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.33,
      color: colorScheme.onSurface,
    );
  }

  static TextStyle labelSmall(ColorScheme colorScheme) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.45,
      color: colorScheme.onSurface,
    );
  }

  // Custom styles for specific use cases
  static TextStyle taskTitle(ColorScheme colorScheme) {
    return titleMedium(colorScheme).copyWith(
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle taskDescription(ColorScheme colorScheme) {
    return bodyMedium(colorScheme).copyWith(
      color: colorScheme.onSurfaceVariant,
    );
  }

  static TextStyle taskDueDate(ColorScheme colorScheme) {
    return labelMedium(colorScheme).copyWith(
      color: colorScheme.onSurfaceVariant,
    );
  }

  static TextStyle taskPriority(ColorScheme colorScheme) {
    return labelSmall(colorScheme).copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.8,
    );
  }

  static TextStyle tagLabel(ColorScheme colorScheme) {
    return labelSmall(colorScheme).copyWith(
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle voiceTranscription(ColorScheme colorScheme) {
    return bodyLarge(colorScheme).copyWith(
      fontStyle: FontStyle.italic,
      color: colorScheme.onSurfaceVariant,
    );
  }

  static TextStyle errorText(ColorScheme colorScheme) {
    return bodySmall(colorScheme).copyWith(
      color: colorScheme.error,
    );
  }

  static TextStyle successText(ColorScheme colorScheme) {
    return bodySmall(colorScheme).copyWith(
      color: colorScheme.primary,
    );
  }
}