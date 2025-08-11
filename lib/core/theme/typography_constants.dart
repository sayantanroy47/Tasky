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

  // Master font size scale - FIXED OVERLAPS - DISTINCT SIZES ONLY
  static const double displayLarge = 32.0;      // Major headings
  static const double displayMedium = 28.0;     // Page titles  
  static const double displaySmall = 26.0;      // Section headers (FIXED: was 24.0)

  static const double headlineLarge = 22.0;     // Card titles (FIXED: was 24.0 - overlapped with displaySmall)
  static const double headlineMedium = 20.0;    // Subsection headers
  static const double headlineSmall = 19.0;     // Important text (FIXED: was 18.0)

  static const double titleLarge = 17.0;        // Widget titles (FIXED: was 18.0 - overlapped with headlineSmall)
  static const double titleMedium = 16.0;       // Standard titles
  static const double titleSmall = 14.0;        // Small titles

  static const double bodyLarge = 16.2;         // Main body text (FIXED: was 16.0 - overlapped with titleMedium & inputText)
  static const double bodyMedium = 14.2;        // Secondary body text (FIXED: was 14.0 - overlapped with titleSmall & buttonText)
  static const double bodySmall = 12.3;         // Small body text (FIXED: was 12.0 - overlapped with navigationLabel)

  static const double labelLarge = 14.5;        // Button labels (FIXED: was 14.0 - overlapped with titleSmall & buttonText)
  static const double labelMedium = 11.0;       // Form labels (FIXED: was 12.0 - overlapped with navigationLabel)
  static const double labelSmall = 9.0;         // Tiny labels/captions (FIXED: was 10.0 - overlapped with taskMeta)

  // Specialized sizes for specific components - NO OVERLAPS
  static const double appBarTitle = 21.0;        // FIXED: was 20.0 - overlapped with headlineMedium
  static const double navigationLabel = 12.0;
  static const double buttonText = 14.0;
  static const double inputText = 16.0;
  static const double taskTitle = 15.0;          // FIXED: was 16.0 - overlapped with titleMedium & inputText
  static const double taskDescription = 13.0;    // FIXED: was 14.0 - overlapped with titleSmall & buttonText  
  static const double taskMeta = 10.0;

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

  // Border radius constants - STANDARDIZED TO 5px AS REQUESTED
  static const double radiusStandard = 5.0;    // UNIVERSAL STANDARD - 5px everywhere
  
  // Legacy constants - ALL SET TO 5px FOR CONSISTENCY
  static const double radiusXSmall = 5.0;      // Now 5px
  static const double radiusSmall = 5.0;       // Now 5px  
  static const double radiusMedium = 5.0;      // Now 5px
  static const double radiusLarge = 5.0;       // Now 5px
  static const double radiusXLarge = 5.0;      // Now 5px
  static const double radiusXXLarge = 5.0;     // Now 5px
  static const double radiusRound = 5.0;       // Now 5px (no more fully rounded)

  // Specialized radius for specific components - ALL 5px
  static const double taskCardRadius = 5.0;
  static const double dialogRadius = 5.0;
  static const double bottomSheetRadius = 5.0;
  static const double fabRadius = 5.0;          // No more round FAB
  static const double chipRadius = 5.0;
  static const double buttonRadius = 5.0;
  static const double containerRadius = 5.0;

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

  /// Validate that a font size is allowed
  static bool isValidFontSize(double size) {
    const allowedSizes = [
      displayLarge, displayMedium, displaySmall,
      headlineLarge, headlineMedium, headlineSmall,
      titleLarge, titleMedium, titleSmall,
      bodyLarge, bodyMedium, bodySmall,
      labelLarge, labelMedium, labelSmall,
      appBarTitle, navigationLabel, buttonText, inputText,
      taskTitle, taskDescription, taskMeta,
    ];
    return allowedSizes.contains(size);
  }

  /// Validate that a border radius is allowed - ONLY 5.0 is valid now
  static bool isValidRadius(double radius) {
    return radius == 5.0; // Only 5px is allowed as per requirement
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