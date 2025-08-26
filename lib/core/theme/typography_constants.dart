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

  // MOBILE-OPTIMIZED TYPOGRAPHY SCALE - Enhanced readability with modest increases + weight adjustments
  static const double labelSmall = 11.5;       // SMALLEST - Fine print, captions (slight increase + weight boost)
  static const double bodySmall = 11.5;        // Small body text (slight increase + weight boost)
  static const double labelMedium = 12.5;      // UI labels (slight increase)
  static const double bodyMedium = 13.5;       // Standard body text (slight increase)
  static const double labelLarge = 14.5;       // Button text, larger labels (slight increase)
  static const double bodyLarge = 15.0;        // Primary body text (unchanged)
  static const double titleSmall = 16.0;       // Small headings (unchanged)
  static const double titleMedium = 16.5;      // Medium headings - CRITICAL: Task titles (modest increase)
  static const double titleLarge = 18.5;       // Large headings - Page headers (modest increase)
  static const double headlineSmall = 20.0;    // Small headlines (was 22, -2px)
  static const double headlineMedium = 22.0;   // Medium headlines (was 24, -2px)
  static const double headlineLarge = 24.0;    // Large headlines (was 26, -2px)
  static const double displaySmall = 26.0;     // Small display text (was 28, -2px)
  static const double displayMedium = 28.0;    // Medium display text (was 30, -2px)
  static const double displayLarge = 30.0;     // LARGEST - Hero text (was 32, -2px)

  // Legacy simplified aliases for backwards compatibility
  static const double textXS = bodySmall;      // 11.5 - Captions, tiny labels
  static const double textSM = bodyMedium;     // 13.5 - Body secondary, small buttons  
  static const double textBase = bodyLarge;    // 15.0 - Body primary, input text
  static const double textLG = titleLarge;     // 18.5 - Subheadings, card titles
  static const double textXL = headlineSmall;  // 20.0 - Headings, app bar
  static const double text2XL = headlineMedium; // 22.0 - Page titles, section headers
  static const double text3XL = headlineLarge; // 24.0 - Display text, hero content
  static const double text4XL = displaySmall;  // 26.0 - Large display, splash screens

  // Specialized component aliases - Mobile-optimized sizes
  static const double appBarTitle = titleLarge;       // 18.5
  static const double navigationLabel = labelMedium;  // 12.5
  static const double buttonText = labelLarge;        // 14.5
  static const double inputText = bodyLarge;          // 15.0
  static const double taskTitle = titleMedium;        // 16.5 - CRITICAL: Task titles optimized for readability
  static const double taskDescription = bodyMedium;   // 13.5  
  static const double taskMeta = bodySmall;           // 11.5

  // Font weight constants - Enhanced hierarchy for small text readability
  static const FontWeight light = FontWeight.w400;    // Light weight for large text
  static const FontWeight regular = FontWeight.w500;  // Standard weight  
  static const FontWeight medium = FontWeight.w600;   // Medium weight
  static const FontWeight semiBold = FontWeight.w600; // Alias for medium to maintain compatibility
  static const FontWeight smallTextWeight = FontWeight.w600; // Enhanced weight for small text readability

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
  static const double radiusStandard = radiusMedium; // Standard 12px button radius

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