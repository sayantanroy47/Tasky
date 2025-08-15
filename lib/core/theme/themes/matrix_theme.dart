import 'package:flutter/material.dart';
import '../app_theme_data.dart' as app_theme_data;
import '../models/theme_metadata.dart';
import '../models/theme_colors.dart';
import '../models/theme_typography.dart';
import '../models/theme_animations.dart';
import '../models/theme_effects.dart' as theme_effects;
import '../typography_constants.dart';

/// Matrix Theme - "Digital Reality"
/// A cyberpunk theme inspired by The Matrix movie
/// Features pure black backgrounds, neon green accents, and digital effects
class MatrixTheme {
  static app_theme_data.AppThemeData create({bool isDark = true}) {
    final now = DateTime.now();
    
    return app_theme_data.AppThemeData(
      metadata: ThemeMetadata(
        id: isDark ? 'matrix_dark' : 'matrix',
        name: isDark ? 'Matrix Dark' : 'Matrix Light',
        description: isDark 
          ? 'Enter the digital reality with this cyberpunk theme featuring neon green code on pure black backgrounds'
          : 'Light variant of the Matrix theme with green code on white terminal backgrounds',
        author: 'Tasky Team',
        version: '1.0.0',
        tags: ['cyberpunk', 'hacker', 'digital', 'green', 'terminal', 'retro'],
        category: 'developer',
        previewIcon: Icons.terminal,
        primaryPreviewColor: isDark ? const Color(0xFF000000) : const Color(0xFFf8f8f8), // Pure black or light gray
        secondaryPreviewColor: const Color(0xFF00ff00), // Neon green (same)
        createdAt: now,
        isPremium: false,
        popularityScore: 9.2,
      ),
      
      colors: _createMatrixColors(isDark: isDark),
      typography: _createMatrixTypography(isDark: isDark),
      animations: _createMatrixAnimations(),
      effects: _createMatrixEffects(),
      spacing: _createMatrixSpacing(),
      components: _createMatrixComponents(),
    );
  }

  /// Create light variant (unusual for Matrix, but available)
  static app_theme_data.AppThemeData createLight() => create(isDark: false);
  
  /// Create dark variant (standard Matrix)
  static app_theme_data.AppThemeData createDark() => create(isDark: true);

  /// Helper method to reduce color brightness by 25%
  static Color _reduceBrightness(Color color, double factor) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness * factor).clamp(0.0, 1.0)).toColor();
  }

  /// Create Matrix-inspired color palette
  static ThemeColors _createMatrixColors({bool isDark = true}) {
    if (!isDark) {
      // Light variant: Use dark theme colors reduced by 25% brightness + light backgrounds
      
      // Get dark theme colors first
      const darkNeonGreen = Color(0xFF00ff00);      // Dark theme primary
      const darkGreen = Color(0xFF008000);          // Dark theme secondary  
      const darkBrightGreen = Color(0xFF39ff14);    // Dark theme highlight
      const darkTerminalGreen = Color(0xFF00cc00);  // Dark theme accent
      
      // Reduce brightness by 25% (factor of 0.75)
      final lightPrimary = _reduceBrightness(darkNeonGreen, 0.75);
      final lightSecondary = _reduceBrightness(darkGreen, 0.75);
      final lightHighlight = _reduceBrightness(darkBrightGreen, 0.75);
      final lightAccent = _reduceBrightness(darkTerminalGreen, 0.75);
      
      // Light backgrounds
      const lightestGray = Color(0xFFfafafa);       // Background - Brighter white
      const lightGray = Color(0xFFf5f5f5);          // Surface - Light gray  
      const paleGreen = Color(0xFFe8f5e8);          // Container - More visible green tint
      
      return ThemeColors(
        // Primary colors - Reduced brightness from dark theme
        primary: lightPrimary,
        onPrimary: const Color(0xFFffffff), // White text on colored primary buttons
        primaryContainer: paleGreen,
        onPrimaryContainer: const Color(0xFF003300), // Very dark green text on light containers

        // Secondary colors - Reduced brightness from dark theme
        secondary: lightSecondary,
        onSecondary: const Color(0xFFffffff), // White text on colored secondary buttons
        secondaryContainer: paleGreen,
        onSecondaryContainer: const Color(0xFF003300), // Very dark green text on light containers

        // Tertiary colors - Reduced brightness from dark theme
        tertiary: lightHighlight,
        onTertiary: const Color(0xFFffffff), // White text on colored tertiary buttons
        tertiaryContainer: paleGreen,
        onTertiaryContainer: const Color(0xFF003300), // Very dark green text on light containers

        // Surface colors - Light backgrounds
        surface: lightGray,
        onSurface: const Color(0xFF1a1a1a), // Dark text for light surfaces
        surfaceVariant: const Color(0xFFf5f5f5),
        onSurfaceVariant: const Color(0xFF2a2a2a), // Dark text for light surfaces
        inverseSurface: lightSecondary,
        onInverseSurface: lightestGray,

        // Background colors - Lightest gray as requested
        background: lightestGray,
        onBackground: const Color(0xFF0a0a0a), // Very dark text for light backgrounds

        // Error colors - Reduced brightness
        error: _reduceBrightness(const Color(0xFFff0040), 0.75),
        onError: lightestGray,
        errorContainer: const Color(0xFFffebee),
        onErrorContainer: _reduceBrightness(const Color(0xFFff0040), 0.75),

        // Special colors - Reduced brightness
        accent: lightAccent,
        highlight: lightHighlight,
        shadow: const Color(0xFF000000),
        outline: lightSecondary,
        outlineVariant: lightAccent,

        // Task priority colors - Reduced brightness from dark theme
        taskLowPriority: _reduceBrightness(const Color(0xFF40ff40), 0.75),
        taskMediumPriority: lightPrimary,
        taskHighPriority: lightHighlight,
        taskUrgentPriority: _reduceBrightness(const Color(0xFFff0040), 0.75),

        // Status colors - Reduced brightness
        success: _reduceBrightness(const Color(0xFF00ff80), 0.75),
        warning: _reduceBrightness(const Color(0xFFffff00), 0.75),
        info: lightAccent,

        // Calendar dot colors - Reduced brightness
        calendarTodayDot: lightPrimary,
        calendarOverdueDot: _reduceBrightness(const Color(0xFFff0040), 0.75),
        calendarFutureDot: lightAccent,
        calendarCompletedDot: _reduceBrightness(const Color(0xFF00ff80), 0.75),
        calendarHighPriorityDot: lightHighlight,
        
        // Status badge colors - Reduced brightness
        statusPendingBadge: lightAccent,
        statusInProgressBadge: lightHighlight,
        statusCompletedBadge: _reduceBrightness(const Color(0xFF00ff80), 0.75),
        statusCancelledBadge: const Color(0xFF9e9e9e),
        statusOverdueBadge: _reduceBrightness(const Color(0xFFff0040), 0.75),
        statusOnHoldBadge: _reduceBrightness(const Color(0xFFffff00), 0.75),

        // Interactive colors - Reduced brightness
        hover: _reduceBrightness(const Color(0xFF00cc00), 0.75),
        pressed: _reduceBrightness(const Color(0xFF008000), 0.75),
        focus: lightHighlight,
        disabled: const Color(0xFF9e9e9e),
      );
    }
    
    // Dark variant: Original Matrix colors
    const pureBlack = Color(0xFF000000);          // Background - The void
    const neonGreen = Color(0xFF00ff00);          // Primary - Matrix code
    const darkGreen = Color(0xFF008000);          // Secondary - Deeper code
    const brightGreen = Color(0xFF39ff14);        // Highlight - Active code
    const terminalGreen = Color(0xFF00cc00);      // Accent - Terminal text
    const darkGray = Color(0xFF0d1b0d);           // Surface - Subtle variation
    const matrixGreen = Color(0xFF003300);        // Container - Deep matrix
    
    return const ThemeColors(
      // Primary colors - Neon green like Matrix code
      primary: neonGreen,
      onPrimary: pureBlack,
      primaryContainer: matrixGreen,
      onPrimaryContainer: neonGreen,

      // Secondary colors - Dark green variations
      secondary: darkGreen,
      onSecondary: neonGreen,
      secondaryContainer: Color(0xFF004d00),
      onSecondaryContainer: terminalGreen,

      // Tertiary colors - Bright green highlights
      tertiary: brightGreen,
      onTertiary: pureBlack,
      tertiaryContainer: Color(0xFF001a00),
      onTertiaryContainer: brightGreen,

      // Surface colors - Dark with green tint
      surface: darkGray,
      onSurface: neonGreen,
      surfaceVariant: Color(0xFF1a1a1a),
      onSurfaceVariant: terminalGreen,
      inverseSurface: neonGreen,
      onInverseSurface: pureBlack,

      // Background colors - Pure black void
      background: pureBlack,
      onBackground: neonGreen,

      // Error colors - Red warnings in the Matrix
      error: Color(0xFFff0040),
      onError: pureBlack,
      errorContainer: Color(0xFF330008),
      onErrorContainer: Color(0xFFff6680),

      // Special colors
      accent: terminalGreen,
      highlight: brightGreen,
      shadow: pureBlack,
      outline: Color(0xFF004d00),
      outlineVariant: Color(0xFF002600),

      // Task priority colors - Different shades of green
      taskLowPriority: Color(0xFF40ff40),    // Light green - Low priority
      taskMediumPriority: neonGreen,         // Standard green - Medium
      taskHighPriority: brightGreen,         // Bright green - High priority
      taskUrgentPriority: Color(0xFFff0040), // Red - System alert

      // Status colors
      success: Color(0xFF00ff80),
      warning: Color(0xFFffff00),
      info: terminalGreen,

      // Calendar dot colors - Matrix green theme
      calendarTodayDot: neonGreen,                    // Bright green for today
      calendarOverdueDot: Color(0xFFff0040),          // Red for overdue
      calendarFutureDot: terminalGreen,               // Standard green for future
      calendarCompletedDot: Color(0xFF00ff80),        // Success green for completed
      calendarHighPriorityDot: brightGreen,           // Bright green for high priority
      
      // Status badge colors - Matrix themed
      statusPendingBadge: terminalGreen,              // Standard green for pending
      statusInProgressBadge: brightGreen,             // Bright green for in progress
      statusCompletedBadge: Color(0xFF00ff80),        // Success green for completed
      statusCancelledBadge: Color(0xFF666666),        // Gray for cancelled
      statusOverdueBadge: Color(0xFFff0040),          // Red for overdue
      statusOnHoldBadge: Color(0xFFffff00),           // Yellow for on hold

      // Interactive colors
      hover: Color(0xFF00cc00),
      pressed: Color(0xFF008000),
      focus: brightGreen,
      disabled: Color(0xFF333333),
    );
  }

  /// Create Matrix-inspired typography using Fira Code (monospace terminal font)
  static ThemeTypography _createMatrixTypography({bool isDark = true}) {
    final colors = _MatrixColorsHelper(isDark: isDark);
    const fontFamily = 'Fira Code';
    
    return ThemeTypography(
      fontFamily: fontFamily,
      displayFontFamily: fontFamily,
      monospaceFontFamily: fontFamily,
      baseSize: TypographyConstants.bodyLarge,
      scaleRatio: 1.0, // No scaling - use exact constants
      baseFontWeight: TypographyConstants.regular,
      baseLetterSpacing: TypographyConstants.normalLetterSpacing,
      baseLineHeight: TypographyConstants.normalLineHeight,
      
      // Use EXACT typography constants for all sizes
      displayLarge: TypographyConstants.getStyle(
        fontSize: TypographyConstants.displayLarge,
        fontWeight: TypographyConstants.light,
        fontFamily: fontFamily,
        color: colors.onBackground,
      ),
      displayMedium: TypographyConstants.getStyle(
        fontSize: TypographyConstants.displayMedium,
        fontWeight: TypographyConstants.light,
        fontFamily: fontFamily,
        color: colors.onBackground,
      ),
      displaySmall: TypographyConstants.getStyle(
        fontSize: TypographyConstants.displaySmall,
        fontWeight: TypographyConstants.regular,
        fontFamily: fontFamily,
        color: colors.onBackground,
      ),
      
      headlineLarge: TypographyConstants.getStyle(
        fontSize: TypographyConstants.headlineLarge,
        fontWeight: TypographyConstants.regular,
        fontFamily: fontFamily,
        color: colors.onBackground,
      ),
      headlineMedium: TypographyConstants.getStyle(
        fontSize: TypographyConstants.headlineMedium,
        fontWeight: TypographyConstants.regular,
        fontFamily: fontFamily,
        color: colors.onBackground,
      ),
      headlineSmall: TypographyConstants.getStyle(
        fontSize: TypographyConstants.headlineSmall,
        fontWeight: TypographyConstants.regular,
        fontFamily: fontFamily,
        color: colors.onBackground,
      ),
      
      titleLarge: TypographyConstants.getStyle(
        fontSize: TypographyConstants.titleLarge,
        fontWeight: TypographyConstants.medium,
        fontFamily: fontFamily,
        color: colors.onBackground,
      ),
      titleMedium: TypographyConstants.getStyle(
        fontSize: TypographyConstants.titleMedium,
        fontWeight: TypographyConstants.medium,
        fontFamily: fontFamily,
        color: colors.onBackground,
      ),
      titleSmall: TypographyConstants.getStyle(
        fontSize: TypographyConstants.titleSmall,
        fontWeight: TypographyConstants.medium,
        fontFamily: fontFamily,
        color: colors.onBackground,
      ),
      
      bodyLarge: TypographyConstants.getStyle(
        fontSize: TypographyConstants.bodyLarge,
        fontWeight: TypographyConstants.regular,
        fontFamily: fontFamily,
        color: colors.onBackground,
      ),
      bodyMedium: TypographyConstants.getStyle(
        fontSize: TypographyConstants.bodyMedium,
        fontWeight: TypographyConstants.regular,
        fontFamily: fontFamily,
        color: colors.onBackground,
      ),
      bodySmall: TypographyConstants.getStyle(
        fontSize: TypographyConstants.bodySmall,
        fontWeight: TypographyConstants.regular,
        fontFamily: fontFamily,
        color: colors.onBackground,
      ),
      
      labelLarge: TypographyConstants.getStyle(
        fontSize: TypographyConstants.labelLarge,
        fontWeight: TypographyConstants.medium,
        fontFamily: fontFamily,
        color: colors.onBackground,
      ),
      labelMedium: TypographyConstants.getStyle(
        fontSize: TypographyConstants.labelMedium,
        fontWeight: TypographyConstants.medium,
        fontFamily: fontFamily,
        color: colors.onBackground,
      ),
      labelSmall: TypographyConstants.getStyle(
        fontSize: TypographyConstants.labelSmall,
        fontWeight: TypographyConstants.medium,
        fontFamily: fontFamily,
        color: colors.onBackground,
      ),
      
      // Custom app styles with exact constants
      taskTitle: TypographyConstants.getStyle(
        fontSize: TypographyConstants.taskTitle,
        fontWeight: TypographyConstants.semiBold,
        fontFamily: fontFamily,
        color: colors.onBackground,
      ),
      taskDescription: TypographyConstants.getStyle(
        fontSize: TypographyConstants.taskDescription,
        fontWeight: TypographyConstants.regular,
        fontFamily: fontFamily,
        color: colors.onBackground,
      ),
      taskMeta: TypographyConstants.getStyle(
        fontSize: TypographyConstants.taskMeta,
        fontWeight: TypographyConstants.regular,
        fontFamily: fontFamily,
        color: colors.onBackground,
      ),
      cardTitle: TypographyConstants.getStyle(
        fontSize: TypographyConstants.titleSmall,
        fontWeight: TypographyConstants.medium,
        fontFamily: fontFamily,
        color: colors.onBackground,
      ),
      cardSubtitle: TypographyConstants.getStyle(
        fontSize: TypographyConstants.bodySmall,
        fontWeight: TypographyConstants.regular,
        fontFamily: fontFamily,
        color: colors.onBackground,
      ),
      buttonText: TypographyConstants.getStyle(
        fontSize: TypographyConstants.buttonText,
        fontWeight: TypographyConstants.medium,
        fontFamily: fontFamily,
        color: colors.onBackground,
      ),
      inputText: TypographyConstants.getStyle(
        fontSize: TypographyConstants.inputText,
        fontWeight: TypographyConstants.regular,
        fontFamily: fontFamily,
        color: colors.onBackground,
      ),
      appBarTitle: TypographyConstants.getStyle(
        fontSize: TypographyConstants.appBarTitle,
        fontWeight: TypographyConstants.medium,
        fontFamily: fontFamily,
        color: colors.onBackground,
      ),
      navigationLabel: TypographyConstants.getStyle(
        fontSize: TypographyConstants.navigationLabel,
        fontWeight: TypographyConstants.medium,
        fontFamily: fontFamily,
        color: colors.onBackground,
      ),
    );
  }

  /// Create digital, linear animations
  static ThemeAnimations _createMatrixAnimations() {
    return ThemeAnimations.fromThemeStyle(ThemeAnimationStyle.digital).copyWith(
      // Ultra-fast, digital precision animations
      fast: const Duration(milliseconds: 50),
      medium: const Duration(milliseconds: 100),
      slow: const Duration(milliseconds: 200),
      verySlow: const Duration(milliseconds: 350),
      
      // Sharp, digital precision curves
      primaryCurve: Curves.linear,
      secondaryCurve: Curves.easeInOutQuart,
      entranceCurve: Curves.easeOutCubic,
      exitCurve: Curves.easeInCubic,
      
      // Enable ultra-dense digital particles
      enableParticles: true,
      particleConfig: const ParticleConfig(
        density: ParticleDensity.ultra,
        speed: ParticleSpeed.veryFast,
        style: ParticleStyle.digital,
        enableGlow: true,
        opacity: 1.0,
        size: 0.9,
      ),
    );
  }

  /// Create digital visual effects
  static theme_effects.ThemeEffects _createMatrixEffects() {
    return theme_effects.ThemeEffects.fromEffectStyle(theme_effects.ThemeEffectStyle.digital).copyWith(
      shadowStyle: theme_effects.ShadowStyle.none,        // No shadows in digital space
      gradientStyle: theme_effects.GradientStyle.none,    // Pure, flat colors
      borderStyle: theme_effects.BorderStyle.sharp,       // Perfect rectangles
      
      blurConfig: const theme_effects.BlurConfig(
        enabled: false,                     // Sharp, pixelated look
      ),
      
      glowConfig: const theme_effects.GlowConfig(
        enabled: true,
        intensity: 0.3,                     // Reduced intensity for subtle effect
        spread: 12.0,                       // Increased spread for softer glow
        style: theme_effects.GlowStyle.outer,
      ),
      
      backgroundEffects: const theme_effects.BackgroundEffectConfig(
        enableParticles: true,
        enableGradientMesh: false,
        enableScanlines: true,              // Enhanced Matrix scanline effect
        particleType: theme_effects.BackgroundParticleType.codeRain,
        particleOpacity: 0.8,               // Much more visible code rain
        effectIntensity: 1.0,
      ),
    );
  }

  /// Create terminal-like spacing - compact and efficient
  static app_theme_data.ThemeSpacing _createMatrixSpacing() {
    return app_theme_data.ThemeSpacing.fromBaseUnit(6.0).copyWith(
      cardPadding: 12.0,     // Compact terminal padding
      screenPadding: 12.0,   // Minimal screen padding
      buttonPadding: 16.0,   // Terminal button padding
      inputPadding: 10.0,    // Compact input padding
    );
  }

  /// Create sharp, digital components
  static app_theme_data.ThemeComponents _createMatrixComponents() {
    return const app_theme_data.ThemeComponents(
      appBar: app_theme_data.AppBarConfig(
        elevation: 0.0,        // Flat, no elevation in digital space
        centerTitle: false,    // Terminal-style left alignment
        toolbarHeight: kToolbarHeight,
      ),
      
      card: app_theme_data.CardConfig(
        elevation: 0.0,        // Flat cards
        borderRadius: 5.0,     // Perfect rectangles
        margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        padding: EdgeInsets.all(12.0),
      ),
      
      button: app_theme_data.ButtonConfig(
        borderRadius: 5.0,     // Sharp rectangular buttons
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        elevation: 0.0,        // Flat buttons
        height: 40.0,          // Compact terminal buttons
        style: app_theme_data.ButtonStyle.outlined,
      ),
      
      input: app_theme_data.InputConfig(
        borderRadius: 5.0,     // Rectangular input fields
        contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        borderStyle: app_theme_data.InputBorderStyle.outline,
        filled: false,
      ),
      
      fab: app_theme_data.FABConfig(
        shape: app_theme_data.FABShape.square,  // Square FAB
        elevation: 0.0,          // Flat
        width: 48.0,
        height: 48.0,
      ),
      
      navigation: app_theme_data.NavigationConfig(
        type: app_theme_data.NavigationType.bottomNav,
        elevation: 0.0,        // Flat navigation
        showLabels: false,     // Icon-only for minimal look
      ),
      
      taskCard: app_theme_data.TaskCardConfig(
        borderRadius: 5.0,     // Perfect rectangles
        margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
        padding: EdgeInsets.all(12.0),
        elevation: 0.0,        // Flat cards
        showPriorityStripe: true,
        enableSwipeActions: true,
      ),
    );
  }
}

/// Helper class for accessing colors in static context
class _MatrixColorsHelper {
  final bool isDark;
  const _MatrixColorsHelper({this.isDark = true});
  
  Color get onBackground => isDark ? const Color(0xFF00ff00) : const Color(0xFF004d00);
  Color get primary => const Color(0xFF00ff00);  // Neon green in both variants
  Color get secondary => isDark ? const Color(0xFF008000) : const Color(0xFF006600);
}