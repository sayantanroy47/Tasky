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
        primaryPreviewColor: isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF), // Pure black or white
        secondaryPreviewColor: const Color(0xFF00FF00), // Neon green (same)
        tertiaryPreviewColor: isDark ? const Color(0xFF00FF55) : const Color(0xFF008833), // Matrix Green signature accent
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
      
      // Matrix neon colors for light variant - Enhanced contrast
      const deepNeonGreen = Color(0xFF00BB00);      // Deeper primary neon for better contrast
      const deepGreen = Color(0xFF005500);          // Deeper secondary
      const deepBrightGreen = Color(0xFF228833);    // Deeper highlight for better contrast
      const deepTerminalGreen = Color(0xFF008800);  // Deeper accent
      
      // Light terminal backgrounds - Enhanced contrast
      const pureWhite = Color(0xFFFFFFFF);          // Pure white background
      const lightGray = Color(0xFFF8F8F8);          // Light surface
      const paleGreen = Color(0xFFE8F8E8);          // Light green container tint
      
      // Matrix Green Signature Accent - Deep for light mode contrast
      const deepMatrixGreenSignature = Color(0xFF008833);       // Deep signature matrix green
      const onDeepMatrixGreenSignature = Color(0xFFFFFFFF);     // White text on deep green
      const deepMatrixGreenContainer = Color(0xFFE0F8E0);       // Light green container
      const onDeepMatrixGreenContainer = Color(0xFF002211);     // Deep green container text
      
      return const ThemeColors(
        // Primary colors - Enhanced deep neon green for better contrast
        primary: deepNeonGreen,
        onPrimary: pureWhite,
        primaryContainer: paleGreen,
        onPrimaryContainer: Color(0xFF002200), // Deeper container text

        // Secondary colors - Enhanced deep green variations
        secondary: deepGreen,
        onSecondary: pureWhite,
        secondaryContainer: paleGreen,
        onSecondaryContainer: Color(0xFF002200), // Deeper container text

        // Tertiary colors - Enhanced deep bright green highlights
        tertiary: deepBrightGreen,
        onTertiary: pureWhite,
        tertiaryContainer: paleGreen,
        onTertiaryContainer: Color(0xFF002200), // Deeper container text

        // Surface colors - Enhanced contrast light backgrounds
        surface: lightGray,
        onSurface: Color(0xFF1A1A1A), // Deep text for maximum readability
        surfaceVariant: Color(0xFFF0F0F0),
        onSurfaceVariant: Color(0xFF333333), // Deeper variant text
        inverseSurface: deepGreen,
        onInverseSurface: pureWhite,

        // Background colors - Pure white for maximum contrast
        background: pureWhite,
        onBackground: Color(0xFF1A1A1A), // Deep text for maximum readability

        // Error colors - Enhanced red warnings
        error: Color(0xFFBB1111), // Deeper error red
        onError: pureWhite,
        errorContainer: Color(0xFFFEF0F0),
        onErrorContainer: Color(0xFF660000), // Deeper error container text

        // Special colors - Enhanced with signature accent
        accent: deepMatrixGreenSignature, // Use signature matrix green as primary accent
        highlight: deepBrightGreen,
        shadow: Color(0xFF000000),
        outline: Color(0xFF888888), // Deeper outline for better visibility
        outlineVariant: deepTerminalGreen,

        // Matrix Green Signature Colors
        matrixGreen: deepMatrixGreenSignature,
        onMatrixGreen: onDeepMatrixGreenSignature,
        matrixGreenContainer: deepMatrixGreenContainer,
        onMatrixGreenContainer: onDeepMatrixGreenContainer,

        // Task priority colors - Enhanced with signature accent
        taskLowPriority: Color(0xFF117744), // Deeper success green
        taskMediumPriority: deepNeonGreen,
        taskHighPriority: deepMatrixGreenSignature, // Signature matrix green - High priority
        taskUrgentPriority: Color(0xFFBB1111), // Deeper urgent red

        // Status colors - Deeper for better contrast
        success: Color(0xFF117744), // Deeper success green
        warning: Color(0xFFCC7700), // Deeper warning
        info: deepMatrixGreenSignature, // Use signature matrix green for info

        // Calendar dot colors - Enhanced
        calendarTodayDot: deepNeonGreen,
        calendarOverdueDot: Color(0xFFBB1111),
        calendarFutureDot: deepTerminalGreen,
        calendarCompletedDot: Color(0xFF117744),
        calendarHighPriorityDot: deepMatrixGreenSignature, // Signature matrix green for high priority
        
        // Status badge colors - Enhanced with signature matrix green
        statusPendingBadge: deepTerminalGreen,
        statusInProgressBadge: deepBrightGreen,
        statusCompletedBadge: deepMatrixGreenSignature, // Signature matrix green for completed (achievement)
        statusCancelledBadge: Color(0xFF888888),
        statusOverdueBadge: Color(0xFFBB1111),
        statusOnHoldBadge: Color(0xFFCC7700),

        // Interactive colors - Enhanced for better visibility
        hover: Color(0x60BB00), // Deeper green hover
        pressed: Color(0x99005500), // Deeper green pressed
        focus: deepMatrixGreenSignature, // Use signature matrix green for focus
        disabled: Color(0xFF999999), // Enhanced disabled
      );
    }
    
    // Dark variant: Super bright, maximum saturation Matrix colors
    const pureBlack = Color(0xFF000000);          // Pure void (already perfect)
    const neonGreen = Color(0xFF00FF00);          // Pure Matrix code (already perfect)
    const enhancedDarkGreen = Color(0xFF00BB00);  // Enhanced deeper green (brighter)
    const enhancedBrightGreen = Color(0xFF55FF55); // Enhanced neon highlight (brighter)
    const enhancedTerminalGreen = Color(0xFF00DD00); // Enhanced terminal accent (brighter)
    const deeperGray = Color(0xFF080808);         // Ultra-deep surface for stronger contrast
    const enhancedMatrixGreen = Color(0xFF004400); // Enhanced container green (brighter)
    const enhancedEmerald = Color(0xFF00AA55);    // Enhanced emerald for UI (brighter)
    
    // Matrix Green Signature Accent - Maximum visibility matrix green
    const matrixGreenSignature = Color(0xFF00FF55);       // Super bright signature matrix green
    const onMatrixGreenSignature = Color(0xFF000000);     // Pure black for maximum contrast
    const matrixGreenContainer = Color(0xFF003322);       // Deep matrix container
    const onMatrixGreenContainer = Color(0xFFFFFFFF);     // Pure white for container text
    
    return const ThemeColors(
      // Primary colors - Enhanced neon green Matrix code
      primary: neonGreen,
      onPrimary: Color(0xFF000000), // Pure black for maximum contrast
      primaryContainer: enhancedMatrixGreen,
      onPrimaryContainer: Color(0xFFFFFFFF), // Pure white for container text

      // Secondary colors - Enhanced dark green variations
      secondary: enhancedDarkGreen,
      onSecondary: Color(0xFF000000), // Pure black for maximum contrast
      secondaryContainer: enhancedEmerald,
      onSecondaryContainer: Color(0xFFFFFFFF), // Pure white for container text

      // Tertiary colors - Enhanced bright green highlights
      tertiary: enhancedBrightGreen,
      onTertiary: Color(0xFF000000), // Pure black for maximum contrast
      tertiaryContainer: enhancedMatrixGreen,
      onTertiaryContainer: Color(0xFFFFFFFF), // Pure white for container text

      // Surface colors - Enhanced dark with green tint
      surface: deeperGray,
      onSurface: Color(0xFFFFFFFF), // Pure white text
      surfaceVariant: enhancedEmerald,
      onSurfaceVariant: Color(0xFFDDDDDD), // Near-white for excellent contrast
      inverseSurface: neonGreen,
      onInverseSurface: pureBlack,

      // Background colors - Enhanced pure black void
      background: pureBlack,
      onBackground: Color(0xFFFFFFFF), // Pure white text

      // Error colors - Enhanced red warnings in the Matrix
      error: Color(0xFFFF4466), // Enhanced error red
      onError: Color(0xFF000000), // Pure black for maximum contrast
      errorContainer: Color(0xFF440A0A), // Enhanced red container
      onErrorContainer: Color(0xFFFFFFFF), // Pure white for container text

      // Special colors - Enhanced with signature accent
      accent: matrixGreenSignature, // Use signature matrix green as primary accent
      highlight: enhancedBrightGreen,
      shadow: pureBlack,
      outline: Color(0xFF444444), // Enhanced outline
      outlineVariant: enhancedMatrixGreen,

      // Matrix Green Signature Colors
      matrixGreen: matrixGreenSignature,
      onMatrixGreen: onMatrixGreenSignature,
      matrixGreenContainer: matrixGreenContainer,
      onMatrixGreenContainer: onMatrixGreenContainer,

      // Task priority colors - Enhanced with signature accent
      taskLowPriority: Color(0xFF55FF55), // Enhanced light green - Low priority
      taskMediumPriority: neonGreen, // Pure matrix green - Medium
      taskHighPriority: matrixGreenSignature, // Signature matrix green - High priority
      taskUrgentPriority: Color(0xFFFF4466), // Enhanced red - System alert

      // Status colors - Enhanced brightness
      success: Color(0xFF44FF88), // Enhanced success green
      warning: Color(0xFFFFFF00), // Pure yellow (already perfect)
      info: matrixGreenSignature, // Use signature matrix green for info

      // Calendar dot colors - Enhanced Matrix green theme
      calendarTodayDot: neonGreen, // Pure green for today
      calendarOverdueDot: Color(0xFFFF4466), // Enhanced red for overdue
      calendarFutureDot: enhancedTerminalGreen, // Enhanced green for future
      calendarCompletedDot: Color(0xFF44FF88), // Enhanced success green for completed
      calendarHighPriorityDot: matrixGreenSignature, // Signature matrix green for high priority
      
      // Status badge colors - Enhanced with signature matrix green
      statusPendingBadge: enhancedTerminalGreen, // Enhanced green for pending
      statusInProgressBadge: enhancedBrightGreen, // Enhanced bright green for in progress
      statusCompletedBadge: matrixGreenSignature, // Signature matrix green for completed (achievement)
      statusCancelledBadge: Color(0xFF777777), // Enhanced gray for cancelled
      statusOverdueBadge: Color(0xFFFF4466), // Enhanced red for overdue
      statusOnHoldBadge: Color(0xFFFFFF00), // Pure yellow for on hold

      // Interactive colors - Enhanced visibility
      hover: Color(0xFF00DD00), // Enhanced hover
      pressed: Color(0xFF00AA00), // Enhanced pressed
      focus: matrixGreenSignature, // Use signature matrix green for focus
      disabled: Color(0xFF444444), // Enhanced disabled
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
        fontWeight: TypographyConstants.smallTextWeight,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      cardTitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleSmall,
        fontWeight: TypographyConstants.smallTextWeight,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      cardSubtitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodySmall,
        fontWeight: TypographyConstants.smallTextWeight,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      buttonText: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.buttonText,
        fontWeight: TypographyConstants.smallTextWeight,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      inputText: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.inputText,
        fontWeight: TypographyConstants.smallTextWeight,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      appBarTitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.appBarTitle,
        fontWeight: TypographyConstants.smallTextWeight,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      navigationLabel: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.navigationLabel,
        fontWeight: TypographyConstants.smallTextWeight,
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