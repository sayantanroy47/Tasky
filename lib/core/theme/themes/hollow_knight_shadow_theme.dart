import 'package:flutter/material.dart';
import '../local_fonts.dart';
import '../app_theme_data.dart' as app_theme_data;
import '../models/theme_metadata.dart';
import '../models/theme_colors.dart';
import '../models/theme_typography.dart';
import '../models/theme_animations.dart';
import '../models/theme_effects.dart' as theme_effects;
import '../typography_constants.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Hollow Knight Shadow Theme - "Ethereal Void"
/// A mysterious void-inspired theme with spectral effects and soul particles
/// Features deep shadow backgrounds, ethereal accents, and ghostly animations
class HollowKnightShadowTheme {
  static app_theme_data.AppThemeData create({bool isDark = true}) {
    final now = DateTime.now();
    
    return app_theme_data.AppThemeData(
      metadata: ThemeMetadata(
        id: isDark ? 'hollow_knight_shadow_dark' : 'hollow_knight_shadow',
        name: isDark ? 'Hollow Knight Shadow Dark' : 'Hollow Knight Shadow Light',
        description: isDark 
          ? 'Ethereal void theme with spectral shadows and soul-like effects for deep focus'
          : 'Bright ethereal theme with ghostly mist and radiant soul energy',
        author: 'Tasky Team',
        version: '1.0.0',
        tags: ['void', 'shadow', 'ethereal', 'gaming', 'mysterious', 'soul', 'spectral'],
        category: 'Gaming',
        previewIcon: PhosphorIcons.ghost(),
        primaryPreviewColor: isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF8F8FF),
        secondaryPreviewColor: const Color(0xFF4A90E2),
        createdAt: now,
        isPremium: true,
        popularityScore: 9.2,
      ),
      
      colors: _createShadowColors(isDark: isDark),
      typography: _createShadowTypography(isDark: isDark),
      animations: _createShadowAnimations(),
      effects: _createShadowEffects(isDark: isDark),
      spacing: _createShadowSpacing(),
      components: _createShadowComponents(),
    );
  }

  /// Create light variant
  static app_theme_data.AppThemeData createLight() => create(isDark: false);
  
  /// Create dark variant
  static app_theme_data.AppThemeData createDark() => create(isDark: true);

  /// Create shadow-inspired color palette
  static ThemeColors _createShadowColors({bool isDark = true}) {
    if (!isDark) {
      // Shadow Light - Ethereal mist
      const soulBlue = Color(0xFF4A90E2);         // Soul essence
      const voidPurple = Color(0xFF8A2BE2);       // Void magic
      const spectraiWhite = Color(0xFFE6E6FA);    // Spectral white
      const shadowGray = Color(0xFF2F2F2F);       // Dark text
      const mistGray = Color(0xFF708090);         // Mist gray
      const etherealWhite = Color(0xFFF8F8FF);    // Background
      const lightVoid = Color(0xFFF0F8FF);        // Light surface
      const ghostGlow = Color(0xFFB0C4DE);        // Accent
      
      return ThemeColors(
        // Primary
        primary: soulBlue,
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFFE3F2FD),
        onPrimaryContainer: const Color(0xFF001B3E),
        
        // Secondary
        secondary: voidPurple,
        onSecondary: Colors.white,
        secondaryContainer: const Color(0xFFF3E5F5),
        onSecondaryContainer: const Color(0xFF31003D),
        
        // Tertiary
        tertiary: spectraiWhite,
        onTertiary: shadowGray,
        tertiaryContainer: const Color(0xFFF5F5FF),
        onTertiaryContainer: const Color(0xFF1A1A1F),
        
        // Surface
        surface: etherealWhite,
        onSurface: shadowGray,
        surfaceVariant: lightVoid,
        onSurfaceVariant: mistGray,
        inverseSurface: shadowGray,
        onInverseSurface: etherealWhite,
        
        // Background
        background: etherealWhite,
        onBackground: shadowGray,
        
        // Error
        error: const Color(0xFFB71C1C),
        onError: Colors.white,
        errorContainer: const Color(0xFFFFEBEE),
        onErrorContainer: const Color(0xFF2D0001),
        
        // Special
        accent: ghostGlow,
        highlight: spectraiWhite,
        shadow: Colors.black26,
        outline: mistGray,
        outlineVariant: const Color(0xFFCFCFD4),
        
        // Task Priority
        taskLowPriority: ghostGlow,
        taskMediumPriority: soulBlue,
        taskHighPriority: voidPurple,
        taskUrgentPriority: const Color(0xFF4527A0),
        
        // Status
        success: const Color(0xFF2E7D32),
        warning: const Color(0xFFF57C00),
        info: soulBlue,
        
        // Calendar Dots
        calendarTodayDot: soulBlue,
        calendarOverdueDot: voidPurple,
        calendarFutureDot: ghostGlow,
        calendarCompletedDot: const Color(0xFF2E7D32),
        calendarHighPriorityDot: const Color(0xFF4527A0),
        
        // Status Badges
        statusPendingBadge: ghostGlow,
        statusInProgressBadge: soulBlue,
        statusCompletedBadge: const Color(0xFF2E7D32),
        statusCancelledBadge: mistGray,
        statusOverdueBadge: voidPurple,
        statusOnHoldBadge: spectraiWhite,
        
        // Interactive
        hover: soulBlue.withValues(alpha: 0.8),
        pressed: soulBlue.withValues(alpha: 0.9),
        focus: soulBlue.withValues(alpha: 0.12),
        disabled: mistGray.withValues(alpha: 0.5),
      );
    } else {
      // Shadow Dark - Void depths
      const deepVoid = Color(0xFF0A0A0F);         // Void black
      const soulBlue = Color(0xFF4A90E2);         // Soul essence
      const voidPurple = Color(0xFF8A2BE2);       // Void magic
      const spectralWhite = Color(0xFFE6E6FA);    // Spectral energy
      const shadowGray = Color(0xFF1A1A1F);       // Surface
      const mistGray = Color(0xFF2A2A2F);         // Variant surface
      const ghostWhite = Color(0xFFCCCCCC);       // On surface
      
      return ThemeColors(
        // Primary
        primary: soulBlue,
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFF1A237E),
        onPrimaryContainer: const Color(0xFFE3F2FD),
        
        // Secondary
        secondary: voidPurple,
        onSecondary: Colors.white,
        secondaryContainer: const Color(0xFF4A148C),
        onSecondaryContainer: const Color(0xFFF3E5F5),
        
        // Tertiary
        tertiary: spectralWhite,
        onTertiary: Colors.black,
        tertiaryContainer: const Color(0xFF3A3A4F),
        onTertiaryContainer: const Color(0xFFF5F5FF),
        
        // Surface
        surface: shadowGray,
        onSurface: ghostWhite,
        surfaceVariant: mistGray,
        onSurfaceVariant: const Color(0xFFAAAAAA),
        inverseSurface: ghostWhite,
        onInverseSurface: deepVoid,
        
        // Background
        background: deepVoid,
        onBackground: ghostWhite,
        
        // Error
        error: const Color(0xFFFF5252),
        onError: Colors.white,
        errorContainer: const Color(0xFF930006),
        onErrorContainer: const Color(0xFFFFEBEE),
        
        // Special
        accent: voidPurple,
        highlight: spectralWhite,
        shadow: Colors.black87,
        outline: const Color(0xFF5A5A5F),
        outlineVariant: const Color(0xFF3A3A3F),
        
        // Task Priority
        taskLowPriority: const Color(0xFF7986CB),
        taskMediumPriority: soulBlue,
        taskHighPriority: voidPurple,
        taskUrgentPriority: const Color(0xFF4527A0),
        
        // Status
        success: const Color(0xFF4CAF50),
        warning: const Color(0xFFFF9800),
        info: soulBlue,
        
        // Calendar Dots
        calendarTodayDot: soulBlue,
        calendarOverdueDot: const Color(0xFF4527A0),
        calendarFutureDot: voidPurple,
        calendarCompletedDot: const Color(0xFF4CAF50),
        calendarHighPriorityDot: const Color(0xFF4527A0),
        
        // Status Badges
        statusPendingBadge: voidPurple,
        statusInProgressBadge: soulBlue,
        statusCompletedBadge: const Color(0xFF4CAF50),
        statusCancelledBadge: const Color(0xFF5A5A5F),
        statusOverdueBadge: const Color(0xFF4527A0),
        statusOnHoldBadge: spectralWhite,
        
        // Interactive
        hover: soulBlue.withValues(alpha: 0.8),
        pressed: soulBlue.withValues(alpha: 0.9),
        focus: soulBlue.withValues(alpha: 0.12),
        disabled: const Color(0xFF5A5A5F).withValues(alpha: 0.5),
      );
    }
  }

  /// Create shadow-inspired typography with Exo 2 font
  static ThemeTypography _createShadowTypography({bool isDark = true}) {
    const fontFamily = 'Exo 2';
    final colors = _ShadowColorsHelper(isDark: isDark);
    
    return ThemeTypography(
      fontFamily: fontFamily,
      displayFontFamily: fontFamily,
      monospaceFontFamily: fontFamily,
      baseSize: TypographyConstants.bodyLarge,
      scaleRatio: 1.0,
      baseFontWeight: TypographyConstants.regular,
      baseLetterSpacing: TypographyConstants.normalLetterSpacing,
      baseLineHeight: TypographyConstants.normalLineHeight,
      
      // Display styles - Light and ethereal
      displayLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.displayLarge,
        fontWeight: TypographyConstants.light,
        letterSpacing: TypographyConstants.tightLetterSpacing,
        height: TypographyConstants.tightLineHeight,
        color: colors.primary,
      ),
      displayMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.displayMedium,
        fontWeight: TypographyConstants.light,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.primary,
      ),
      displaySmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.displaySmall,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurface,
      ),
      
      // Headline styles - Ghostly presence
      headlineLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.headlineLarge,
        fontWeight: TypographyConstants.light,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.primary,
      ),
      headlineMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.headlineMedium,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurface,
      ),
      headlineSmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.headlineSmall,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurface,
      ),
      
      // Title styles - Subtle presence
      titleLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleLarge,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurface,
      ),
      titleMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleMedium,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurface,
      ),
      titleSmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleSmall,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurfaceVariant,
      ),
      
      // Body styles - Ethereal readability
      bodyLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodyLarge,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onSurface,
      ),
      bodyMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodyMedium,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurface,
      ),
      bodySmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodySmall,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.relaxedLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurfaceVariant,
      ),
      
      // Label styles - Spectral guidance
      labelLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelLarge,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.primary,
      ),
      labelMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelMedium,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.relaxedLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurface,
      ),
      labelSmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelSmall,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.relaxedLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurfaceVariant,
      ),
      
      // Task-specific styles - Shadow realm
      taskTitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.taskTitle,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurface,
      ),
      taskDescription: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.taskDescription,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onSurfaceVariant,
      ),
      taskMeta: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.taskMeta,
        fontWeight: TypographyConstants.smallTextWeight,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurfaceVariant,
      ),
      cardTitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleSmall,
        fontWeight: TypographyConstants.smallTextWeight,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurface,
      ),
      cardSubtitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodySmall,
        fontWeight: TypographyConstants.smallTextWeight,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurfaceVariant,
      ),
      buttonText: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.buttonText,
        fontWeight: TypographyConstants.smallTextWeight,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurface,
      ),
      inputText: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.inputText,
        fontWeight: TypographyConstants.smallTextWeight,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurface,
      ),
      appBarTitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.appBarTitle,
        fontWeight: TypographyConstants.smallTextWeight,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurface,
      ),
      navigationLabel: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.navigationLabel,
        fontWeight: TypographyConstants.smallTextWeight,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurface,
      ),
    );
  }

  /// Create shadow-inspired animations
  static ThemeAnimations _createShadowAnimations() {
    return const ThemeAnimations(
      fast: Duration(milliseconds: 150),    // Spectral fade
      medium: Duration(milliseconds: 400),  // Soul drift
      slow: Duration(milliseconds: 600),    // Void emergence
      verySlow: Duration(milliseconds: 800), // Deep shadow
      
      primaryCurve: Curves.easeInOutSine,         // Ethereal flow
      secondaryCurve: Curves.easeInOutQuart,      // Void transition
      entranceCurve: Curves.easeOutCubic,
      exitCurve: Curves.easeInCubic,
      
      enableParticles: true,
      particleConfig: ParticleConfig(
        density: ParticleDensity.medium,
        speed: ParticleSpeed.slow,
        style: ParticleStyle.organic,
        enableGlow: true,
        opacity: 0.4,
        size: 1.0,
      ),
    );
  }

  /// Create shadow-inspired effects
  static theme_effects.ThemeEffects _createShadowEffects({required bool isDark}) {
    return theme_effects.ThemeEffects(
      shadowStyle: theme_effects.ShadowStyle.soft,
      gradientStyle: theme_effects.GradientStyle.subtle,
      borderStyle: theme_effects.BorderStyle.rounded,
      
      blurConfig: const theme_effects.BlurConfig(
        enabled: true,
        intensity: 2.0,
        style: theme_effects.BlurStyle.outer,
      ),
      
      glowConfig: theme_effects.GlowConfig(
        enabled: true,
        intensity: isDark ? 0.6 : 0.2, // Stronger soul glow in the void
        spread: isDark ? 16.0 : 8.0, // Wider ethereal spread in darkness
        style: theme_effects.GlowStyle.outer,
      ),
      
      backgroundEffects: theme_effects.BackgroundEffectConfig(
        enableParticles: true,
        enableGradientMesh: true,
        enableScanlines: false,
        particleType: theme_effects.BackgroundParticleType.floating,
        particleOpacity: isDark ? 0.3 : 0.1, // More soul particles in the void
        effectIntensity: isDark ? 0.6 : 0.2, // Stronger ethereal effects in darkness
        geometricPattern: theme_effects.BackgroundGeometricPattern.radial, // Ethereal void symmetry
        patternAngle: 0.0, // Centered ethereal energy
        patternDensity: 0.7, // Sparse ethereal pattern
        accentColors: [
          (isDark ? const Color(0xFF4A90E2) : const Color(0xFF64B5F6)).withValues(alpha: 0.1), // Soul blue
          (isDark ? const Color(0xFF8A2BE2) : const Color(0xFFBA68C8)).withValues(alpha: 0.06), // Void purple
        ],
      ),
    );
  }

  /// Create shadow-inspired spacing
  static app_theme_data.ThemeSpacing _createShadowSpacing() {
    return const app_theme_data.ThemeSpacing(
      extraSmall: 4.0,
      small: 8.0,
      medium: 16.0,
      large: 24.0,
      extraLarge: 32.0,
      cardPadding: 20.0,     // More space for ethereal feel
      screenPadding: 20.0,
      buttonPadding: 16.0,
      inputPadding: 16.0,
    );
  }

  /// Create shadow-inspired components
  static app_theme_data.ThemeComponents _createShadowComponents() {
    return const app_theme_data.ThemeComponents(
      appBar: app_theme_data.AppBarConfig(
        elevation: 0.0,
        centerTitle: true,
        toolbarHeight: kToolbarHeight,
      ),
      
      card: app_theme_data.CardConfig(
        elevation: 2.0,        // Ethereal lift
        borderRadius: 16.0,    // Soft ghostly curves
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: EdgeInsets.all(20.0),
      ),
      
      button: app_theme_data.ButtonConfig(
        borderRadius: 12.0,    // Ethereal curves
        padding: EdgeInsets.symmetric(horizontal: 28.0, vertical: 14.0),
        elevation: 1.0,        // Minimal shadow
        height: 48.0,
        style: app_theme_data.ButtonStyle.filled,
      ),
      
      input: app_theme_data.InputConfig(
        borderRadius: 12.0,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        borderStyle: app_theme_data.InputBorderStyle.outline,
        filled: true,
      ),
      
      fab: app_theme_data.FABConfig(
        shape: app_theme_data.FABShape.circular,
        elevation: 4.0,
        width: null,
        height: null,
      ),
      
      navigation: app_theme_data.NavigationConfig(
        type: app_theme_data.NavigationType.bottomNav,
        elevation: 6.0,
        showLabels: true,
      ),
      
      taskCard: app_theme_data.TaskCardConfig(
        borderRadius: 16.0,    // Consistent ethereal curves
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: EdgeInsets.all(20.0),
        elevation: 2.0,        // Subtle ethereal presence
        showPriorityStripe: true,
        enableSwipeActions: true,
      ),
    );
  }
}

/// Helper class for accessing shadow colors in static context
class _ShadowColorsHelper {
  final bool isDark;
  
  const _ShadowColorsHelper({required this.isDark});
  
  Color get primary => isDark ? const Color(0xFF4A90E2) : const Color(0xFF1A237E);
  Color get onSurface => isDark ? const Color(0xFFCCCCCC) : const Color(0xFF2F2F2F);
  Color get onSurfaceVariant => isDark ? const Color(0xFFAAAAAA) : const Color(0xFF708090);
}