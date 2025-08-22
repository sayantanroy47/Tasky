import 'package:flutter/material.dart';


/// Local font helper to replace Google Fonts usage
/// Uses local font assets instead of downloading fonts from the internet
class LocalFonts {
  
  /// Font family mappings for themes
  static const Map<String, String> _fontFamilyMap = {
    'Fira Code': 'FiraCode',
    'JetBrains Mono': 'JetBrainsMono', // Now using actual JetBrains Mono font
    'Orbitron': 'Orbitron',
    'Montserrat': 'Montserrat',
    'Roboto': 'Roboto',
  };

  /// Default fallback font family
  static const String _fallbackFont = 'Montserrat';

  /// Creates a TextStyle using local fonts instead of GoogleFonts.getFont()
  /// 
  /// Parameters match GoogleFonts.getFont() for easy replacement:
  /// - [fontFamily]: The desired font family name (will be mapped to local font)
  /// - [fontSize]: Size of the font in logical pixels
  /// - [fontWeight]: Weight of the font
  /// - [letterSpacing]: Spacing between letters
  /// - [height]: Line height as a multiplier of font size
  /// - [color]: Color of the text
  static TextStyle getFont(
    String fontFamily, {
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
    Color? color,
    TextDecoration? decoration,
    Paint? background,
    Paint? foreground,
    List<Shadow>? shadows,
  }) {
    // Map the requested font family to local font
    final localFontFamily = _fontFamilyMap[fontFamily] ?? _fallbackFont;
    
    return TextStyle(
      fontFamily: localFontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
      color: color,
      decoration: decoration,
      background: background,
      foreground: foreground,
      shadows: shadows,
      // Add font fallbacks
      fontFamilyFallback: const [_fallbackFont],
    );
  }

  /// Available local font families
  static const List<String> availableFonts = [
    'FiraCode',
    'JetBrainsMono',
    'Orbitron', 
    'Roboto',
    'Montserrat',
  ];

  /// Get the local font family name for a given font
  static String getLocalFontFamily(String requestedFont) {
    return _fontFamilyMap[requestedFont] ?? _fallbackFont;
  }

  /// Theme-specific font getters for convenience
  static String get matrixFont => 'FiraCode';
  static String get draculaFont => 'JetBrainsMono'; // Now using actual JetBrains Mono
  static String get vegetaFont => 'Orbitron';
  static String get fallbackFont => _fallbackFont;
}