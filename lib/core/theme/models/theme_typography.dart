import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography system for themes
class ThemeTypography {
  final String fontFamily;
  final String? displayFontFamily;
  final String? monospaceFontFamily;
  final double baseSize;
  final double scaleRatio;
  final FontWeight baseFontWeight;
  final double baseLetterSpacing;
  final double baseLineHeight;

  // Text Styles
  final TextStyle displayLarge;
  final TextStyle displayMedium;
  final TextStyle displaySmall;
  final TextStyle headlineLarge;
  final TextStyle headlineMedium;
  final TextStyle headlineSmall;
  final TextStyle titleLarge;
  final TextStyle titleMedium;
  final TextStyle titleSmall;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;
  final TextStyle labelLarge;
  final TextStyle labelMedium;
  final TextStyle labelSmall;

  // Custom App Styles
  final TextStyle taskTitle;
  final TextStyle taskDescription;
  final TextStyle taskMeta;
  final TextStyle cardTitle;
  final TextStyle cardSubtitle;
  final TextStyle buttonText;
  final TextStyle inputText;
  final TextStyle appBarTitle;
  final TextStyle navigationLabel;

  const ThemeTypography({
    required this.fontFamily,
    this.displayFontFamily,
    this.monospaceFontFamily,
    this.baseSize = 16.0,
    this.scaleRatio = 1.2,
    this.baseFontWeight = FontWeight.normal,
    this.baseLetterSpacing = 0.0,
    this.baseLineHeight = 1.4,
    required this.displayLarge,
    required this.displayMedium,
    required this.displaySmall,
    required this.headlineLarge,
    required this.headlineMedium,
    required this.headlineSmall,
    required this.titleLarge,
    required this.titleMedium,
    required this.titleSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
    required this.labelMedium,
    required this.labelSmall,
    required this.taskTitle,
    required this.taskDescription,
    required this.taskMeta,
    required this.cardTitle,
    required this.cardSubtitle,
    required this.buttonText,
    required this.inputText,
    required this.appBarTitle,
    required this.navigationLabel,
  });

  /// Create typography from font family and base properties
  factory ThemeTypography.fromFontFamily({
    required String fontFamily,
    String? displayFontFamily,
    String? monospaceFontFamily,
    double baseSize = 16.0,
    double scaleRatio = 1.2,
    FontWeight baseFontWeight = FontWeight.normal,
    double baseLetterSpacing = 0.0,
    double baseLineHeight = 1.4,
    required Color textColor,
  }) {
    // final baseStyle = GoogleFonts.getFont(
    //   fontFamily,
    //   fontSize: baseSize,
    //   fontWeight: baseFontWeight,
    //   letterSpacing: baseLetterSpacing,
    //   height: baseLineHeight,
    //   color: textColor,
    // );

    final displayFont = displayFontFamily ?? fontFamily;
    final monoFont = monospaceFontFamily ?? fontFamily;

    // Calculate scaled sizes
    final sizes = _calculateScaledSizes(baseSize, scaleRatio);

    return ThemeTypography(
      fontFamily: fontFamily,
      displayFontFamily: displayFontFamily,
      monospaceFontFamily: monospaceFontFamily,
      baseSize: baseSize,
      scaleRatio: scaleRatio,
      baseFontWeight: baseFontWeight,
      baseLetterSpacing: baseLetterSpacing,
      baseLineHeight: baseLineHeight,

      // Display styles
      displayLarge: GoogleFonts.getFont(
        displayFont,
        fontSize: sizes['displayLarge']!,
        fontWeight: FontWeight.w300,
        letterSpacing: -1.5,
        color: textColor,
      ),
      displayMedium: GoogleFonts.getFont(
        displayFont,
        fontSize: sizes['displayMedium']!,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.5,
        color: textColor,
      ),
      displaySmall: GoogleFonts.getFont(
        displayFont,
        fontSize: sizes['displaySmall']!,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.0,
        color: textColor,
      ),

      // Headline styles
      headlineLarge: GoogleFonts.getFont(
        fontFamily,
        fontSize: sizes['headlineLarge']!,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.0,
        color: textColor,
      ),
      headlineMedium: GoogleFonts.getFont(
        fontFamily,
        fontSize: sizes['headlineMedium']!,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: textColor,
      ),
      headlineSmall: GoogleFonts.getFont(
        fontFamily,
        fontSize: sizes['headlineSmall']!,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.0,
        color: textColor,
      ),

      // Title styles
      titleLarge: GoogleFonts.getFont(
        fontFamily,
        fontSize: sizes['titleLarge']!,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.0,
        color: textColor,
      ),
      titleMedium: GoogleFonts.getFont(
        fontFamily,
        fontSize: sizes['titleMedium']!,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        color: textColor,
      ),
      titleSmall: GoogleFonts.getFont(
        fontFamily,
        fontSize: sizes['titleSmall']!,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: textColor,
      ),

      // Body styles
      bodyLarge: GoogleFonts.getFont(
        fontFamily,
        fontSize: sizes['bodyLarge']!,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: textColor,
      ),
      bodyMedium: GoogleFonts.getFont(
        fontFamily,
        fontSize: sizes['bodyMedium']!,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: textColor,
      ),
      bodySmall: GoogleFonts.getFont(
        fontFamily,
        fontSize: sizes['bodySmall']!,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: textColor,
      ),

      // Label styles
      labelLarge: GoogleFonts.getFont(
        fontFamily,
        fontSize: sizes['labelLarge']!,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.25,
        color: textColor,
      ),
      labelMedium: GoogleFonts.getFont(
        fontFamily,
        fontSize: sizes['labelMedium']!,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.5,
        color: textColor,
      ),
      labelSmall: GoogleFonts.getFont(
        fontFamily,
        fontSize: sizes['labelSmall']!,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.5,
        color: textColor,
      ),

      // Custom app styles
      taskTitle: GoogleFonts.getFont(
        fontFamily,
        fontSize: sizes['titleMedium']!,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: textColor,
      ),
      taskDescription: GoogleFonts.getFont(
        fontFamily,
        fontSize: sizes['bodySmall']!,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: textColor.withValues(alpha: 0.8),
      ),
      taskMeta: GoogleFonts.getFont(
        monoFont,
        fontSize: sizes['labelSmall']!,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: textColor.withValues(alpha: 0.6),
      ),
      cardTitle: GoogleFonts.getFont(
        fontFamily,
        fontSize: sizes['titleSmall']!,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: textColor,
      ),
      cardSubtitle: GoogleFonts.getFont(
        fontFamily,
        fontSize: sizes['bodySmall']!,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: textColor.withValues(alpha: 0.8),
      ),
      buttonText: GoogleFonts.getFont(
        fontFamily,
        fontSize: sizes['labelLarge']!,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.0,
        color: textColor,
      ),
      inputText: GoogleFonts.getFont(
        fontFamily,
        fontSize: sizes['bodyLarge']!,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: textColor,
      ),
      appBarTitle: GoogleFonts.getFont(
        fontFamily,
        fontSize: sizes['titleLarge']!,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        color: textColor,
      ),
      navigationLabel: GoogleFonts.getFont(
        fontFamily,
        fontSize: sizes['labelMedium']!,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.0,
        color: textColor,
      ),
    );
  }

  /// Calculate scaled text sizes based on base size and ratio
  static Map<String, double> _calculateScaledSizes(double baseSize, double ratio) {
    return {
      'displayLarge': baseSize * ratio * ratio * ratio * ratio, // 57
      'displayMedium': baseSize * ratio * ratio * ratio, // 45
      'displaySmall': baseSize * ratio * ratio, // 36
      'headlineLarge': baseSize * ratio * ratio, // 32
      'headlineMedium': baseSize * ratio * 1.75, // 28
      'headlineSmall': baseSize * ratio * 1.5, // 24
      'titleLarge': baseSize * ratio * 1.375, // 22
      'titleMedium': baseSize * ratio, // 16 * 1.2 = 19.2
      'titleSmall': baseSize * 0.875, // 14
      'bodyLarge': baseSize, // 16
      'bodyMedium': baseSize * 0.875, // 14
      'bodySmall': baseSize * 0.75, // 12
      'labelLarge': baseSize * 0.875, // 14
      'labelMedium': baseSize * 0.75, // 12
      'labelSmall': baseSize * 0.6875, // 11
    };
  }

  /// Convert to Flutter TextTheme
  TextTheme toTextTheme() {
    return TextTheme(
      displayLarge: displayLarge,
      displayMedium: displayMedium,
      displaySmall: displaySmall,
      headlineLarge: headlineLarge,
      headlineMedium: headlineMedium,
      headlineSmall: headlineSmall,
      titleLarge: titleLarge,
      titleMedium: titleMedium,
      titleSmall: titleSmall,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelMedium: labelMedium,
      labelSmall: labelSmall,
    );
  }
}