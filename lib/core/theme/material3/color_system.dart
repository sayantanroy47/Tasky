import 'package:flutter/material.dart';
import '../models/theme_colors.dart';

/// Material 3 Expressive Color System
/// Dynamic color generation with harmonized palettes
class ExpressiveColorSystem {
  final bool isDark;
  
  // Primary colors - Dynamic purple/blue gradient
  late final Color primary;
  late final Color onPrimary;
  late final Color primaryContainer;
  late final Color onPrimaryContainer;
  
  // Secondary colors - Vibrant teal/cyan
  late final Color secondary;
  late final Color onSecondary;
  late final Color secondaryContainer;
  late final Color onSecondaryContainer;
  
  // Tertiary colors - Warm coral/pink
  late final Color tertiary;
  late final Color onTertiary;
  late final Color tertiaryContainer;
  late final Color onTertiaryContainer;
  
  // Surface colors
  late final Color surface;
  late final Color onSurface;
  late final Color surfaceVariant;
  late final Color onSurfaceVariant;
  
  // Background colors
  late final Color background;
  late final Color onBackground;
  
  // Error colors
  late final Color error;
  late final Color onError;
  late final Color errorContainer;
  late final Color onErrorContainer;
  
  // Outline colors
  late final Color outline;
  late final Color outlineVariant;
  
  // Additional colors
  late final Color shadow;
  late final Color inverseSurface;
  late final Color onInverseSurface;
  
  // Stellar Gold accent - New signature accent color
  late final Color stellarGold;
  late final Color onStellarGold;
  late final Color stellarGoldContainer;
  late final Color onStellarGoldContainer;
  
  ExpressiveColorSystem({required this.isDark}) {
    _initializeColors();
  }
  
  void _initializeColors() {
    if (isDark) {
      // Dark theme - Super bright, highly saturated colors for maximum visibility
      primary = const Color(0xFFAA88FF);          // Enhanced bright purple (more saturated)
      onPrimary = const Color(0xFF000000);        // Pure black for maximum contrast
      primaryContainer = const Color(0xFF5A4A9C);
      onPrimaryContainer = const Color(0xFFFFFFFF);  // Pure white for better contrast
      
      secondary = const Color(0xFF00FFFF);        // Pure neon cyan (maximum saturation)
      onSecondary = const Color(0xFF000000);      // Pure black for maximum contrast
      secondaryContainer = const Color(0xFF007888);
      onSecondaryContainer = const Color(0xFFFFFFFF);  // Pure white
      
      tertiary = const Color(0xFFFF77AA);         // Enhanced coral pink (brighter)
      onTertiary = const Color(0xFF000000);       // Pure black for maximum contrast
      tertiaryContainer = const Color(0xFF6D2F44);
      onTertiaryContainer = const Color(0xFFFFFFFF);  // Pure white
      
      surface = const Color(0xFF0A0A0F);          // Deeper surface for stronger contrast
      onSurface = const Color(0xFFFFFFFF);        // Pure white for maximum readability
      surfaceVariant = const Color(0xFF151520);
      onSurfaceVariant = const Color(0xFFE6E6E6);  // Near-white for excellent contrast
      
      background = const Color(0xFF050508);       // Even deeper background
      onBackground = const Color(0xFFFFFFFF);     // Pure white for maximum readability
      
      error = const Color(0xFFFF4444);            // Enhanced red (brighter)
      onError = const Color(0xFF000000);          // Pure black for maximum contrast
      errorContainer = const Color(0xFFA30000);
      onErrorContainer = const Color(0xFFFFFFFF); // Pure white
      
      outline = const Color(0xFFAA99BB);          // Brighter outline
      outlineVariant = const Color(0xFF554455);
      shadow = const Color(0xFF000000);
      inverseSurface = const Color(0xFFFFFFFF);   // Pure white
      onInverseSurface = const Color(0xFF000000); // Pure black
      
      // Stellar Gold - Maximum vibrant warm accent for dark mode
      stellarGold = const Color(0xFFFFCC00);      // Enhanced vibrant gold (brighter)
      onStellarGold = const Color(0xFF000000);    // Pure black for maximum contrast
      stellarGoldContainer = const Color(0xFF4D3D00);
      onStellarGoldContainer = const Color(0xFFFFFFFF);  // Pure white
      
    } else {
      // Light theme - Deep, substantial colors for proper contrast
      primary = const Color(0xFF4A3388);          // Deeper purple (enhanced contrast)
      onPrimary = const Color(0xFFFFFFFF);
      primaryContainer = const Color(0xFFE0D7FF);
      onPrimaryContainer = const Color(0xFF1A0044);  // Deeper container text
      
      secondary = const Color(0xFF008899);        // Deeper cyan (better contrast)
      onSecondary = const Color(0xFFFFFFFF);
      secondaryContainer = const Color(0xFFB2EBF2);
      onSecondaryContainer = const Color(0xFF001F22);  // Deeper container text
      
      tertiary = const Color(0xFFCC1744);         // Deeper pink (better contrast)
      onTertiary = const Color(0xFFFFFFFF);
      tertiaryContainer = const Color(0xFFFFD1DC);
      onTertiaryContainer = const Color(0xFF2A0011);  // Deeper container text
      
      surface = const Color(0xFFFFFFFF);          // Pure white surface
      onSurface = const Color(0xFF1A1A1A);        // Deeper text (better contrast)
      surfaceVariant = const Color(0xFFF5F5F5);
      onSurfaceVariant = const Color(0xFF333333);  // Deeper variant text
      
      background = const Color(0xFFFFFFFF);       // Pure white background
      onBackground = const Color(0xFF1A1A1A);     // Deep text for maximum readability
      
      error = const Color(0xFF990000);            // Deeper red (better contrast)
      onError = const Color(0xFFFFFFFF);
      errorContainer = const Color(0xFFFFDAD6);
      onErrorContainer = const Color(0xFF330000);  // Deeper error container text
      
      outline = const Color(0xFF666666);          // Deeper outline (better visibility)
      outlineVariant = const Color(0xFFBBBBBB);
      shadow = const Color(0xFF000000);
      inverseSurface = const Color(0xFF2A2A2A);   // Deeper inverse surface
      onInverseSurface = const Color(0xFFFFFFFF);
      
      // Stellar Gold - Deeper amber accent for light mode (enhanced contrast)
      stellarGold = const Color(0xFFDD7700);      // Deeper amber (better contrast)
      onStellarGold = const Color(0xFFFFFFFF);
      stellarGoldContainer = const Color(0xFFFFE0B3);
      onStellarGoldContainer = const Color(0xFF221100);  // Deeper container text
    }
  }
  
  /// Convert to ThemeColors for the app theme system
  ThemeColors toThemeColors() {
    return ThemeColors(
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      
      surface: surface,
      onSurface: onSurface,
      surfaceVariant: surfaceVariant,
      onSurfaceVariant: onSurfaceVariant,
      inverseSurface: inverseSurface,
      onInverseSurface: onInverseSurface,
      
      background: background,
      onBackground: onBackground,
      
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      
      // Special colors
      accent: stellarGold,                          // Stellar gold as primary accent for Expressive theme
      highlight: tertiary,
      shadow: shadow,
      outline: outline,
      outlineVariant: outlineVariant,
      
      // Stellar Gold colors
      stellarGold: stellarGold,
      onStellarGold: onStellarGold,
      stellarGoldContainer: stellarGoldContainer,
      onStellarGoldContainer: onStellarGoldContainer,
      
      // Task priority colors with gradients
      taskLowPriority: const Color(0xFF4CAF50),
      taskMediumPriority: secondary,
      taskHighPriority: stellarGold,                    // Updated to use stellar gold for high priority
      taskUrgentPriority: error,
      
      // Status colors
      success: const Color(0xFF4CAF50),
      warning: stellarGold,                             // Updated to use stellar gold for warnings
      info: secondary,

      // Calendar dot colors - Expressive theme (dynamic based on isDark)
      calendarTodayDot: primary,                      // Primary color for today
      calendarOverdueDot: error,                      // Error color for overdue
      calendarFutureDot: secondary,                   // Secondary color for future
      calendarCompletedDot: const Color(0xFF4CAF50),  // Success green for completed
      calendarHighPriorityDot: tertiary,              // Tertiary color for high priority
      
      // Status badge colors - Expressive themed (dynamic based on isDark)
      statusPendingBadge: secondary,                  // Secondary color for pending
      statusInProgressBadge: tertiary,                // Tertiary color for in progress
      statusCompletedBadge: stellarGold,              // Stellar gold for completed (achievement)
      statusCancelledBadge: onSurfaceVariant,         // Muted color for cancelled
      statusOverdueBadge: error,                      // Error color for overdue
      statusOnHoldBadge: stellarGold,                 // Stellar gold for on hold
      
      // Interactive colors
      hover: primary.withValues(alpha: 0.08),
      pressed: primary.withValues(alpha: 0.12),
      focus: primary.withValues(alpha: 0.12),
      disabled: onSurface.withValues(alpha: 0.38),
    );
  }
  
  /// Generate harmonized color from a source color
  static Color harmonize(Color sourceColor, Color targetColor) {
    final HSLColor sourceHSL = HSLColor.fromColor(sourceColor);
    final HSLColor targetHSL = HSLColor.fromColor(targetColor);
    
    // Blend hue slightly towards target
    final double blendedHue = sourceHSL.hue * 0.85 + targetHSL.hue * 0.15;
    
    return sourceHSL.withHue(blendedHue % 360).toColor();
  }
  
  /// Create a gradient from the primary and secondary colors
  LinearGradient createPrimaryGradient({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: [
        primary,
        harmonize(primary, secondary),
        secondary,
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }
  
  /// Create an animated gradient that shifts over time
  List<Color> createAnimatedGradientColors(double animationValue) {
    final hslPrimary = HSLColor.fromColor(primary);
    final hslSecondary = HSLColor.fromColor(secondary);
    
    // Shift hue based on animation value
    final shiftedPrimary = hslPrimary.withHue(
      (hslPrimary.hue + animationValue * 30) % 360
    ).toColor();
    
    final shiftedSecondary = hslSecondary.withHue(
      (hslSecondary.hue + animationValue * 30) % 360
    ).toColor();
    
    return [
      shiftedPrimary,
      harmonize(shiftedPrimary, shiftedSecondary),
      shiftedSecondary,
    ];
  }
  
  /// Get color for task priority with gradient support
  List<Color> getTaskPriorityGradient(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return [
          const Color(0xFF4CAF50),
          const Color(0xFF8BC34A),
        ];
      case 'medium':
        return [
          secondary,
          harmonize(secondary, primary),
        ];
      case 'high':
        return [
          stellarGold,
          harmonize(stellarGold, tertiary),
        ];
      case 'urgent':
        return [
          error,
          const Color(0xFFFF6B6B),
        ];
      default:
        return [surface, surfaceVariant];
    }
  }
  
  /// Create a gradient featuring stellar gold
  LinearGradient createStellarGoldGradient({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: [
        stellarGold,
        harmonize(stellarGold, primary),
        harmonize(stellarGold, tertiary),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }
  
  /// Get stellar gold color variants for different contexts
  Color getStellarGoldVariant(String context) {
    switch (context.toLowerCase()) {
      case 'achievement':
      case 'premium':
        return stellarGold;
      case 'container':
        return stellarGoldContainer;
      case 'subtle':
        return stellarGold.withValues(alpha: 0.3);
      case 'vibrant':
        return stellarGold.withValues(alpha: 0.9);
      default:
        return stellarGold;
    }
  }
}