import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../local_fonts.dart';
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
          ? 'Cinematic Matrix theme with pure black void and cascading neon green code for an authentic digital reality experience'
          : 'Matrix light variant featuring bright neon green terminals on clean white backgrounds for futuristic readability',
        author: 'Tasky Team',
        version: '1.0.0',
        tags: ['cyberpunk', 'hacker', 'digital', 'green', 'terminal', 'retro'],
        category: 'developer',
        previewIcon: PhosphorIcons.terminal(),
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


  /// Create Matrix cinematic neon color palette with accuracy
  static ThemeColors _createMatrixColors({bool isDark = true}) {
    if (!isDark) {
      // Matrix Light Variant: Cinematic Terminal
      
      // Matrix neon colors for light variant
      const darkNeonGreen = Color(0xFF00FF00);      // Primary neon
      const darkGreen = Color(0xFF008000);          // Secondary
      const darkBrightGreen = Color(0xFF39FF14);    // Highlight
      const darkTerminalGreen = Color(0xFF00CC00);  // Accent
      
      // Light terminal backgrounds
      const lightestGray = Color(0xFFFFFFFF);       // Background white
      const lightGray = Color(0xFFF3F4F6);          // Surface
      const paleGreen = Color(0xFFECFDF5);          // Container tint
      
      return const ThemeColors(
        // Primary colors - Dark neon green on light background
        primary: darkNeonGreen,
        onPrimary: Color(0xFF000000), // Black text on neon green for better contrast
        primaryContainer: paleGreen,
        onPrimaryContainer: Color(0xFF003300), // Very dark green text on light containers

        // Secondary colors - Dark green variations
        secondary: darkGreen,
        onSecondary: Color(0xFFE8FFE8), // Matrix green-tinted white for theme consistency
        secondaryContainer: paleGreen,
        onSecondaryContainer: Color(0xFF003300), // Very dark green text on light containers

        // Tertiary colors - Bright green highlights
        tertiary: darkBrightGreen,
        onTertiary: Color(0xFF000000), // Black text on bright green for better contrast
        tertiaryContainer: paleGreen,
        onTertiaryContainer: Color(0xFF003300), // Very dark green text on light containers

        // Surface colors - Light backgrounds
        surface: lightGray,
        onSurface: Color(0xFF1a1a1a), // Dark text for light surfaces
        surfaceVariant: Color(0xFFf5f5f5),
        onSurfaceVariant: Color(0xFF2a2a2a), // Dark text for light surfaces
        inverseSurface: darkGreen,
        onInverseSurface: lightestGray,

        // Background colors - Lightest gray as requested
        background: lightestGray,
        onBackground: Color(0xFF0a0a0a), // Very dark text for light backgrounds

        // Error colors - Red warnings
        error: Color(0xFFDC2626),
        onError: lightestGray,
        errorContainer: Color(0xFFffebee),
        onErrorContainer: Color(0xFFDC2626),

        // Special colors
        accent: darkTerminalGreen,
        highlight: darkBrightGreen,
        shadow: Color(0xFF000000),
        outline: darkGreen,
        outlineVariant: darkTerminalGreen,

        // Task priority colors - Green theme variants
        taskLowPriority: Color(0xFF10B981),
        taskMediumPriority: darkNeonGreen,
        taskHighPriority: darkBrightGreen,
        taskUrgentPriority: Color(0xFFDC2626),

        // Status colors
        success: Color(0xFF10B981),
        warning: Color(0xFFF59E0B),
        info: darkTerminalGreen,

        // Calendar dot colors
        calendarTodayDot: darkNeonGreen,
        calendarOverdueDot: Color(0xFFDC2626),
        calendarFutureDot: darkTerminalGreen,
        calendarCompletedDot: Color(0xFF10B981),
        calendarHighPriorityDot: darkBrightGreen,
        
        // Status badge colors
        statusPendingBadge: darkTerminalGreen,
        statusInProgressBadge: darkBrightGreen,
        statusCompletedBadge: Color(0xFF10B981),
        statusCancelledBadge: Color(0xFF9e9e9e),
        statusOverdueBadge: Color(0xFFDC2626),
        statusOnHoldBadge: Color(0xFFF59E0B),

        // Interactive colors
        hover: Color(0xFF059669),
        pressed: Color(0xFF047857),
        focus: darkBrightGreen,
        disabled: Color(0xFF9e9e9e),
      );
    }
    
    // Dark variant: Refined Matrix colors
    const pureBlack = Color(0xFF000000);          // The void
    const neonGreen = Color(0xFF00FF00);          // Primary Matrix code
    const darkGreen = Color(0xFF006400);          // Deeper authentic green
    const brightGreen = Color(0xFF39FF14);        // Neon highlight
    const terminalGreen = Color(0xFF00CC00);      // Terminal accent
    const darkGray = Color(0xFF111827);           // Subtle contrast surface
    const matrixGreen = Color(0xFF003300);        // Container depth green
    const shadowEmerald = Color(0xFF064E3B);      // Muted emerald for UI layering
    
    return const ThemeColors(
      // Primary colors - Neon green like Matrix code
      primary: neonGreen,
      onPrimary: pureBlack,
      primaryContainer: matrixGreen,
      onPrimaryContainer: neonGreen,

      // Secondary colors - Dark green variations
      secondary: darkGreen,
      onSecondary: neonGreen,
      secondaryContainer: shadowEmerald,
      onSecondaryContainer: terminalGreen,

      // Tertiary colors - Bright green highlights
      tertiary: brightGreen,
      onTertiary: pureBlack,
      tertiaryContainer: matrixGreen,
      onTertiaryContainer: brightGreen,

      // Surface colors - Dark with green tint
      surface: darkGray,
      onSurface: neonGreen,
      surfaceVariant: shadowEmerald,
      onSurfaceVariant: terminalGreen,
      inverseSurface: neonGreen,
      onInverseSurface: pureBlack,

      // Background colors - Pure black void
      background: pureBlack,
      onBackground: neonGreen,

      // Error colors - Red warnings in the Matrix
      error: Color(0xFFFF0040),
      onError: pureBlack,
      errorContainer: Color(0xFF330008),
      onErrorContainer: Color(0xFFFF6680),

      // Special colors
      accent: terminalGreen,
      highlight: brightGreen,
      shadow: pureBlack,
      outline: shadowEmerald,
      outlineVariant: matrixGreen,

      // Task priority colors - Different shades of green
      taskLowPriority: Color(0xFF40FF40),    // Light green - Low priority
      taskMediumPriority: neonGreen,         // Standard green - Medium
      taskHighPriority: brightGreen,         // Bright green - High priority
      taskUrgentPriority: Color(0xFFFF0040), // Red - System alert

      // Status colors
      success: Color(0xFF00FF80),
      warning: Color(0xFFFFFF00),
      info: terminalGreen,

      // Calendar dot colors - Matrix green theme
      calendarTodayDot: neonGreen,                    // Bright green for today
      calendarOverdueDot: Color(0xFFFF0040),          // Red for overdue
      calendarFutureDot: terminalGreen,               // Standard green for future
      calendarCompletedDot: Color(0xFF00FF80),        // Success green for completed
      calendarHighPriorityDot: brightGreen,           // Bright green for high priority
      
      // Status badge colors - Matrix themed
      statusPendingBadge: terminalGreen,              // Standard green for pending
      statusInProgressBadge: brightGreen,             // Bright green for in progress
      statusCompletedBadge: Color(0xFF00FF80),        // Success green for completed
      statusCancelledBadge: Color(0xFF666666),        // Gray for cancelled
      statusOverdueBadge: Color(0xFFFF0040),          // Red for overdue
      statusOnHoldBadge: Color(0xFFFFFF00),           // Yellow for on hold

      // Interactive colors
      hover: Color(0xFF00CC00),
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
      displayLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.displayLarge,
        fontWeight: TypographyConstants.light,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      displayMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.displayMedium,
        fontWeight: TypographyConstants.light,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      displaySmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.displaySmall,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      
      headlineLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.headlineLarge,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      headlineMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.headlineMedium,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      headlineSmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.headlineSmall,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      
      titleLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleLarge,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      titleMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleMedium,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      titleSmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleSmall,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      
      bodyLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodyLarge,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      bodyMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodyMedium,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      bodySmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodySmall,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      
      labelLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelLarge,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      labelMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelMedium,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      labelSmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelSmall,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      
      // Custom app styles with exact constants
      taskTitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.taskTitle,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      taskDescription: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.taskDescription,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      taskMeta: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.taskMeta,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      cardTitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleSmall,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      cardSubtitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodySmall,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      buttonText: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.buttonText,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      inputText: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.inputText,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      appBarTitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.appBarTitle,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      navigationLabel: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.navigationLabel,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
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
      
      backgroundEffects: theme_effects.BackgroundEffectConfig(
        enableParticles: true,
        enableGradientMesh: true, // Enable for geometric pattern
        enableScanlines: true,              // Enhanced Matrix scanline effect
        particleType: theme_effects.BackgroundParticleType.codeRain,
        particleOpacity: 0.8,               // Much more visible code rain
        effectIntensity: 1.0,
        geometricPattern: theme_effects.BackgroundGeometricPattern.mesh, // Digital grid precision
        patternAngle: 0.0, // Perfect grid alignment
        patternDensity: 1.5, // Dense digital pattern
        accentColors: [
          const Color(0xFF00FF41).withValues(alpha: 0.12), // Matrix green
          const Color(0xFF008F11).withValues(alpha: 0.08), // Dark green accent
        ],
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