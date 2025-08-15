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

  // SIMPLIFIED 8-TIER TYPOGRAPHY SYSTEM - Clean, scalable, no overlaps
  static const double textXS = 12.0;    // Captions, tiny labels
  static const double textSM = 14.0;    // Body secondary, small buttons  
  static const double textBase = 16.0;  // Body primary, input text
  static const double textLG = 18.0;    // Subheadings, card titles
  static const double textXL = 20.0;    // Headings, app bar
  static const double text2XL = 24.0;   // Page titles, section headers
  static const double text3XL = 30.0;   // Display text, hero content
  static const double text4XL = 36.0;   // Large display, splash screens

  // Legacy aliases for backwards compatibility during transition
  static const double displayLarge = text4XL;      // 36.0
  static const double displayMedium = text3XL;     // 30.0
  static const double displaySmall = text2XL;      // 24.0
  static const double headlineLarge = textXL;      // 20.0
  static const double headlineMedium = textLG;     // 18.0  
  static const double headlineSmall = textBase;    // 16.0
  static const double titleLarge = textLG;         // 18.0
  static const double titleMedium = textBase;      // 16.0
  static const double titleSmall = textSM;         // 14.0
  static const double bodyLarge = textBase;        // 16.0
  static const double bodyMedium = textSM;         // 14.0
  static const double bodySmall = textXS;          // 12.0
  static const double labelLarge = textSM;         // 14.0
  static const double labelMedium = textXS;        // 12.0
  static const double labelSmall = textXS;         // 12.0

  // Specialized component aliases
  static const double appBarTitle = textXL;        // 20.0
  static const double navigationLabel = textXS;    // 12.0
  static const double buttonText = textSM;         // 14.0
  static const double inputText = textBase;        // 16.0
  static const double taskTitle = textBase;        // 16.0
  static const double taskDescription = textSM;    // 14.0  
  static const double taskMeta = textXS;           // 12.0

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

  /// Validate that a font size is allowed - SIMPLIFIED 8-TIER SYSTEM
  static bool isValidFontSize(double size) {
    const coreSizes = [
      textXS, textSM, textBase, textLG, 
      textXL, text2XL, text3XL, text4XL
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