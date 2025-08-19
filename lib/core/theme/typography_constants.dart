import 'package:flutter/material.dart';

/// Master Typography Scale Constants
/// 
/// This file defines the EXACT font sizes used throughout the entire app.
/// All themes MUST use these identical sizes, but can have different font families.
/// 
/// NEVER define font sizes anywhere else in the codebase!

class TypographyConstants {
  // Private constructor to prevent instantiation
  TypographyConstants._();

  // MOBILE-OPTIMIZED TYPOGRAPHY SCALE - UX-optimized with 2-4px reductions
  static const double labelSmall = 11.0;       // SMALLEST - Fine print, captions (baseline)
  static const double bodySmall = 11.0;        // Small body text (was 12, -1px)
  static const double labelMedium = 12.0;      // UI labels (was 13, -1px)
  static const double bodyMedium = 13.0;       // Standard body text (was 14, -1px)
  static const double labelLarge = 14.0;       // Button text, larger labels (was 15, -1px)
  static const double bodyLarge = 15.0;        // Primary body text (was 16, -1px)
  static const double titleSmall = 16.0;       // Small headings (was 17, -1px)
  static const double titleMedium = 16.0;      // Medium headings - CRITICAL: Task titles (was 18, -2px)
  static const double titleLarge = 18.0;       // Large headings - Page headers (was 20, -2px)
  static const double headlineSmall = 20.0;    // Small headlines (was 22, -2px)
  static const double headlineMedium = 22.0;   // Medium headlines (was 24, -2px)
  static const double headlineLarge = 24.0;    // Large headlines (was 26, -2px)
  static const double displaySmall = 26.0;     // Small display text (was 28, -2px)
  static const double displayMedium = 28.0;    // Medium display text (was 30, -2px)
  static const double displayLarge = 30.0;     // LARGEST - Hero text (was 32, -2px)

  // Legacy simplified aliases for backwards compatibility
  static const double textXS = bodySmall;      // 11.0 - Captions, tiny labels
  static const double textSM = bodyMedium;     // 13.0 - Body secondary, small buttons  
  static const double textBase = bodyLarge;    // 15.0 - Body primary, input text
  static const double textLG = titleLarge;     // 18.0 - Subheadings, card titles
  static const double textXL = headlineSmall;  // 20.0 - Headings, app bar
  static const double text2XL = headlineMedium; // 22.0 - Page titles, section headers
  static const double text3XL = headlineLarge; // 24.0 - Display text, hero content
  static const double text4XL = displaySmall;  // 26.0 - Large display, splash screens

  // Specialized component aliases - Mobile-optimized sizes
  static const double appBarTitle = titleLarge;       // 18.0
  static const double navigationLabel = labelMedium;  // 12.0
  static const double buttonText = labelLarge;        // 14.0
  static const double inputText = bodyLarge;          // 15.0
  static const double taskTitle = titleMedium;        // 16.0 - CRITICAL: Task titles now mobile-optimized
  static const double taskDescription = bodyMedium;   // 13.0  
  static const double taskMeta = bodySmall;           // 11.0

  // Font weight constants
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Line height constants
  static const double tightLineHeight = 1.2;
  static const double normalLineHeight = 1.4;
  static const double relaxedLineHeight = 1.6;

  // Letter spacing constants
  static const double tightLetterSpacing = -0.5;
  static const double normalLetterSpacing = 0.0;
  static const double relaxedLetterSpacing = 0.5;
  static const double wideLetterSpacing = 1.0;

  // Border radius constants - MATERIAL 3 HIERARCHY FOR VISUAL DEPTH
  static const double radiusXSmall = 4.0;      // Small components: chips, small buttons
  static const double radiusSmall = 8.0;       // Cards, standard buttons  
  static const double radiusMedium = 12.0;     // Dialogs, large components
  static const double radiusLarge = 16.0;      // Prominent surfaces, sheets
  static const double radiusXLarge = 20.0;     // Hero components
  static const double radiusXXLarge = 24.0;    // Largest components
  static const double radiusRound = 999.0;     // Fully rounded components

  // Default radius for backwards compatibility
  static const double radiusStandard = radiusSmall; // Default to 8px

  // Specialized radius for specific components - HIERARCHY-BASED
  static const double taskCardRadius = radiusSmall;        // 8px for cards
  static const double dialogRadius = radiusMedium;         // 12px for dialogs
  static const double bottomSheetRadius = radiusLarge;     // 16px for sheets
  static const double fabRadius = radiusRound;             // Fully round FAB
  static const double chipRadius = radiusXSmall;           // 4px for chips
  static const double buttonRadius = radiusSmall;          // 8px for buttons
  static const double containerRadius = radiusSmall;       // 8px for containers

  // Padding constants - STANDARDIZED
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Spacing constants
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;

  /// Validate that a font size is allowed - MATERIAL 3 SYSTEM
  static bool isValidFontSize(double size) {
    const coreSizes = [
      displayLarge, displayMedium, displaySmall,
      headlineLarge, headlineMedium, headlineSmall,
      titleLarge, titleMedium, titleSmall,
      bodyLarge, bodyMedium, bodySmall,
      labelLarge, labelMedium, labelSmall,
      // Component aliases
      appBarTitle, navigationLabel, buttonText, inputText,
      taskTitle, taskDescription, taskMeta,
    ];
    return coreSizes.contains(size);
  }

  /// Validate that a border radius is allowed - MATERIAL 3 HIERARCHY
  static bool isValidRadius(double radius) {
    const allowedRadii = [
      radiusXSmall, radiusSmall, radiusMedium, radiusLarge,
      radiusXLarge, radiusXXLarge, radiusRound,
      taskCardRadius, dialogRadius, bottomSheetRadius, fabRadius,
      chipRadius, buttonRadius, containerRadius,
    ];
    return allowedRadii.contains(radius);
  }

  /// Get a TextStyle with the specified size and weight
  static TextStyle getStyle({
    required double fontSize,
    FontWeight fontWeight = regular,
    Color? color,
    String? fontFamily,
    double? letterSpacing,
    double? height,
  }) {
    assert(isValidFontSize(fontSize), 'Font size $fontSize is not allowed! Use TypographyConstants.');
    
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFamily: fontFamily,
      letterSpacing: letterSpacing ?? normalLetterSpacing,
      height: height ?? normalLineHeight,
    );
  }

  /// Get a BorderRadius with validation
  static BorderRadius getBorderRadius({
    required double radius,
    bool onlyTop = false,
    bool onlyBottom = false,
  }) {
    assert(isValidRadius(radius), 'Border radius $radius is not allowed! Use TypographyConstants.');
    
    if (onlyTop) {
      return BorderRadius.vertical(top: Radius.circular(radius));
    } else if (onlyBottom) {
      return BorderRadius.vertical(bottom: Radius.circular(radius));
    } else {
      return BorderRadius.circular(radius);
    }
  }

  /// Get a Radius with validation
  static Radius getRadius(double radius) {
    assert(isValidRadius(radius), 'Border radius $radius is not allowed! Use TypographyConstants.');
    return Radius.circular(radius);
  }
}