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
  
  ExpressiveColorSystem({required this.isDark}) {
    _initializeColors();
  }
  
  void _initializeColors() {
    if (isDark) {
      // Dark theme - Deep, rich colors with neon accents
      primary = const Color(0xFF9575FF);          // Bright purple
      onPrimary = const Color(0xFF1A0033);
      primaryContainer = const Color(0xFF4A3A8C);
      onPrimaryContainer = const Color(0xFFE0D7FF);
      
      secondary = const Color(0xFF00E5FF);        // Neon cyan
      onSecondary = const Color(0xFF003844);
      secondaryContainer = const Color(0xFF00687B);
      onSecondaryContainer = const Color(0xFFB2F2FF);
      
      tertiary = const Color(0xFFFF6E90);         // Coral pink
      onTertiary = const Color(0xFF3E0017);
      tertiaryContainer = const Color(0xFF5D1F33);
      onTertiaryContainer = const Color(0xFFFFD9E1);
      
      surface = const Color(0xFF121318);          // Very dark surface
      onSurface = const Color(0xFFE6E1E9);
      surfaceVariant = const Color(0xFF1E1F25);
      onSurfaceVariant = const Color(0xFFC9C4D0);
      
      background = const Color(0xFF0A0B0F);       // Near black
      onBackground = const Color(0xFFE6E1E9);
      
      error = const Color(0xFFFF5252);
      onError = const Color(0xFF3D0909);
      errorContainer = const Color(0xFF93000A);
      onErrorContainer = const Color(0xFFFFDAD6);
      
      outline = const Color(0xFF938F99);
      outlineVariant = const Color(0xFF49454E);
      shadow = const Color(0xFF000000);
      inverseSurface = const Color(0xFFE6E1E9);
      onInverseSurface = const Color(0xFF1C1B20);
      
    } else {
      // Light theme - Bright, vibrant colors
      primary = const Color(0xFF6750A4);          // Material purple
      onPrimary = const Color(0xFFFFFFFF);
      primaryContainer = const Color(0xFFE9DDFF);
      onPrimaryContainer = const Color(0xFF22005D);
      
      secondary = const Color(0xFF00ACC1);        // Bright cyan
      onSecondary = const Color(0xFFFFFFFF);
      secondaryContainer = const Color(0xFFB2EBF2);
      onSecondaryContainer = const Color(0xFF002F34);
      
      tertiary = const Color(0xFFE91E63);         // Pink
      onTertiary = const Color(0xFFFFFFFF);
      tertiaryContainer = const Color(0xFFFFD1DC);
      onTertiaryContainer = const Color(0xFF3E001E);
      
      surface = const Color(0xFFFEFBFF);          // Slightly tinted white
      onSurface = const Color(0xFF1C1B20);
      surfaceVariant = const Color(0xFFE7E0EC);
      onSurfaceVariant = const Color(0xFF49454E);
      
      background = const Color(0xFFFEFBFF);
      onBackground = const Color(0xFF1C1B20);
      
      error = const Color(0xFFBA1A1A);
      onError = const Color(0xFFFFFFFF);
      errorContainer = const Color(0xFFFFDAD6);
      onErrorContainer = const Color(0xFF410002);
      
      outline = const Color(0xFF7A757F);
      outlineVariant = const Color(0xFFCAC4CF);
      shadow = const Color(0xFF000000);
      inverseSurface = const Color(0xFF313034);
      onInverseSurface = const Color(0xFFF4EFF4);
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
      accent: secondary,
      highlight: tertiary,
      shadow: shadow,
      outline: outline,
      outlineVariant: outlineVariant,
      
      // Task priority colors with gradients
      taskLowPriority: const Color(0xFF4CAF50),
      taskMediumPriority: secondary,
      taskHighPriority: const Color(0xFFFF9800),
      taskUrgentPriority: error,
      
      // Status colors
      success: const Color(0xFF4CAF50),
      warning: const Color(0xFFFF9800),
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
      statusCompletedBadge: const Color(0xFF4CAF50),  // Success green for completed
      statusCancelledBadge: onSurfaceVariant,         // Muted color for cancelled
      statusOverdueBadge: error,                      // Error color for overdue
      statusOnHoldBadge: const Color(0xFFFF9800),     // Warning color for on hold
      
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
          const Color(0xFFFF9800),
          const Color(0xFFFFC107),
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
}