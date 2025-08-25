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

/// 🎨 Artist Palette Theme - "Creative Canvas"
/// A vibrant artistic theme inspired by paint palettes and creative expression
/// Dark Mode: "Night Studio" - Deep artistic colors with vivid accents and paint splatter effects
/// Light Mode: "Bright Canvas" - Clean whites with vermillion, cerulean, and cadmium colors
class ArtistPaletteTheme {
  static app_theme_data.AppThemeData create({bool isDark = true}) {
    final now = DateTime.now();
    
    return app_theme_data.AppThemeData(
      metadata: ThemeMetadata(
        id: isDark ? 'artist_palette_dark' : 'artist_palette_light',
        name: isDark ? 'Artist Palette Dark' : 'Artist Palette Light',
        description: isDark 
          ? 'Night Studio theme featuring deep artistic colors, paint splatter effects, vermillion accents, cerulean blues, and creative expression'
          : 'Bright Canvas theme with clean whites, vibrant vermillion highlights, cerulean blue accents, and artistic paint palette aesthetics',
        author: 'Tasky Team',
        version: '1.0.0',
        tags: ['artistic', 'creative', 'colorful', 'paint', 'vibrant', 'expressive', 'canvas', 'studio'],
        category: 'creative',
        previewIcon: PhosphorIcons.palette(),
        primaryPreviewColor: const Color(0xFFFF5722), // Vermillion red
        secondaryPreviewColor: const Color(0xFF2196F3), // Cerulean blue
        createdAt: now,
        isPremium: false,
        popularityScore: 8.8, // High creative appeal
      ),
      
      colors: _createArtistColors(isDark: isDark),
      typography: _createArtistTypography(isDark: isDark),
      animations: _createArtistAnimations(),
      effects: _createArtistEffects(),
      spacing: _createArtistSpacing(),
      components: _createArtistComponents(),
    );
  }

  /// Create light variant - Bright Canvas
  static app_theme_data.AppThemeData createLight() => create(isDark: false);
  
  /// Create dark variant - Night Studio
  static app_theme_data.AppThemeData createDark() => create(isDark: true);

  static ThemeColors _createArtistColors({required bool isDark}) {
    if (isDark) {
      return const ThemeColors(
        // Night Studio - Deep artistic colors
        primary: Color(0xFFD84315), // Dark vermillion
        onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFFBF360C),
        onPrimaryContainer: Color(0xFFFFE5DD),
        
        secondary: Color(0xFF1976D2), // Deep cerulean
        onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: Color(0xFF0D47A1),
        onSecondaryContainer: Color(0xFFE1F5FE),
        
        tertiary: Color(0xFFF57F17), // Dark cadmium
        onTertiary: Color(0xFF000000),
        tertiaryContainer: Color(0xFFE65100),
        onTertiaryContainer: Color(0xFFFFFDE7),
        
        error: Color(0xFFC2185B), // Dark magenta
        onError: Color(0xFFFFFFFF),
        errorContainer: Color(0xFF880E4F),
        onErrorContainer: Color(0xFFFFECF1),
        
        surface: Color(0xFF16130F), // Dark canvas
        onSurface: Color(0xFFF0E6DE),
        surfaceVariant: Color(0xFF1F1B16), // Dark aged paper
        onSurfaceVariant: Color(0xFFD3C4B4),
        
        background: Color(0xFF16130F), // Night studio
        onBackground: Color(0xFFF0E6DE),
        
        outline: Color(0xFF9A8F80),
        outlineVariant: Color(0xFF4F4539),
        shadow: Color(0xFF000000),
        inverseSurface: Color(0xFFF0E6DE),
        onInverseSurface: Color(0xFF34302A),
        
        // Missing required arguments
        highlight: Color(0xFFFFCC02), // Golden highlight
        hover: Color(0xFFBF360C), // Darker vermillion for hover
        pressed: Color(0xFF8D2E0C), // Even darker for press
        info: Color(0xFF03DAC6), // Cyan info
        success: Color(0xFF4CAF50), // Green success
        warning: Color(0xFFFF9800), // Orange warning
        
        // Status badge colors
        statusPendingBadge: Color(0xFFFF9800), // Orange
        statusInProgressBadge: Color(0xFF2196F3), // Blue
        statusCompletedBadge: Color(0xFF4CAF50), // Green
        statusCancelledBadge: Color(0xFF9E9E9E), // Grey
        statusOverdueBadge: Color(0xFFC2185B), // Dark magenta
        statusOnHoldBadge: Color(0xFF795548), // Brown
        
        // Task priority colors
        taskLowPriority: Color(0xFF4CAF50), // Green
        taskMediumPriority: Color(0xFF2196F3), // Blue
        taskHighPriority: Color(0xFFFF9800), // Orange
        taskUrgentPriority: Color(0xFFC2185B), // Dark magenta
        
        // Additional required colors
        accent: Color(0xFFFFEB3B), // Cadmium yellow accent
        disabled: Color(0xFF4F4539),
        focus: Color(0xFFD84315), // Primary color for focus
        
        // Calendar dot colors - artistic theme
        calendarTodayDot: Color(0xFFD84315), // Primary vermillion
        calendarCompletedDot: Color(0xFF4CAF50), // Viridian green
        calendarOverdueDot: Color(0xFFC2185B), // Dark magenta
        calendarHighPriorityDot: Color(0xFFFF9800), // Orange
        calendarFutureDot: Color(0xFF1976D2), // Deep cerulean
      );
    } else {
      return const ThemeColors(
        // Creative Canvas - Bright artistic colors
        primary: Color(0xFFFF5722), // Vermillion red
        onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFFFFE5DD),
        onPrimaryContainer: Color(0xFF410E00),
        
        secondary: Color(0xFF2196F3), // Cerulean blue  
        onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: Color(0xFFE1F5FE),
        onSecondaryContainer: Color(0xFF001D36),
        
        tertiary: Color(0xFFFFEB3B), // Cadmium yellow
        onTertiary: Color(0xFF000000),
        tertiaryContainer: Color(0xFFFFFDE7),
        onTertiaryContainer: Color(0xFF1C1B00),
        
        error: Color(0xFFE91E63), // Magenta error
        onError: Color(0xFFFFFFFF),
        errorContainer: Color(0xFFFFECF1),
        onErrorContainer: Color(0xFF3E001D),
        
        surface: Color(0xFFFFFDF7), // Canvas white
        onSurface: Color(0xFF1F1B16),
        surfaceVariant: Color(0xFFF7F2EA), // Aged paper
        onSurfaceVariant: Color(0xFF4F4539),
        
        background: Color(0xFFFFFDF7), // Artist studio
        onBackground: Color(0xFF1F1B16),
        
        outline: Color(0xFF807567),
        outlineVariant: Color(0xFFD3C4B4),
        shadow: Color(0xFF000000),
        inverseSurface: Color(0xFF34302A),
        onInverseSurface: Color(0xFFF7F0E8),
        
        // Missing required arguments
        highlight: Color(0xFFFFEB3B), // Cadmium yellow highlight
        hover: Color(0xFFE64A19), // Darker vermillion for hover
        pressed: Color(0xFFD84315), // Even darker for press
        info: Color(0xFF00BCD4), // Light cyan info
        success: Color(0xFF4CAF50), // Green success
        warning: Color(0xFFFF9800), // Orange warning
        
        // Status badge colors
        statusPendingBadge: Color(0xFFFF9800), // Orange
        statusInProgressBadge: Color(0xFF2196F3), // Blue
        statusCompletedBadge: Color(0xFF4CAF50), // Green
        statusCancelledBadge: Color(0xFF9E9E9E), // Grey
        statusOverdueBadge: Color(0xFFE91E63), // Magenta
        statusOnHoldBadge: Color(0xFF795548), // Brown
        
        // Task priority colors
        taskLowPriority: Color(0xFF4CAF50), // Green
        taskMediumPriority: Color(0xFF2196F3), // Blue
        taskHighPriority: Color(0xFFFF9800), // Orange
        taskUrgentPriority: Color(0xFFE91E63), // Magenta
        
        // Additional required colors
        accent: Color(0xFFFFEB3B), // Cadmium yellow accent
        disabled: Color(0xFFD3C4B4),
        focus: Color(0xFFFF5722), // Primary color for focus
        
        // Calendar dot colors - artistic theme
        calendarTodayDot: Color(0xFFFF5722), // Primary vermillion
        calendarCompletedDot: Color(0xFF4CAF50), // Viridian green
        calendarOverdueDot: Color(0xFFE91E63), // Magenta
        calendarHighPriorityDot: Color(0xFFFF9800), // Orange
        calendarFutureDot: Color(0xFF2196F3), // Cerulean blue
      );
    }
  }

  static ThemeTypography _createArtistTypography({required bool isDark}) {
    const fontFamily = 'Quicksand'; // Artistic, rounded font
    final colors = _ArtistColorsHelper(isDark: isDark);
    
    return ThemeTypography(
      fontFamily: fontFamily,
      displayFontFamily: fontFamily,
      monospaceFontFamily: fontFamily,
      baseSize: TypographyConstants.bodyLarge,
      scaleRatio: 1.0,
      baseFontWeight: TypographyConstants.regular,
      baseLetterSpacing: TypographyConstants.normalLetterSpacing,
      baseLineHeight: TypographyConstants.normalLineHeight,
      
      // Display styles - Bold artistic statements
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
      
      // Headline styles - Creative headers
      headlineLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.headlineLarge,
        fontWeight: TypographyConstants.regular,
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
      
      // Title styles - Artistic emphasis
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
      
      // Body styles - Readable content
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
      
      // Label styles - UI elements
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
      
      // Task-specific styles
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
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurfaceVariant,
      ),
      cardTitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleSmall,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurface,
      ),
      cardSubtitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodySmall,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurfaceVariant,
      ),
      buttonText: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.buttonText,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurface,
      ),
      inputText: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.inputText,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurface,
      ),
      appBarTitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.appBarTitle,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurface,
      ),
      navigationLabel: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.navigationLabel,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurface,
      ),
    );
  }

  static ThemeAnimations _createArtistAnimations() {
    return ThemeAnimations.fromThemeStyle(ThemeAnimationStyle.smooth).copyWith(
      // Smooth paint brush strokes
      fast: const Duration(milliseconds: 200),
      medium: const Duration(milliseconds: 400),
      slow: const Duration(milliseconds: 600),
      verySlow: const Duration(milliseconds: 1000),
      
      // Smooth artistic curves
      primaryCurve: Curves.easeOutQuart, // Paint brush movement
      secondaryCurve: Curves.elasticInOut, // Color mixing
      entranceCurve: Curves.easeOutCubic,
      exitCurve: Curves.easeInCubic,
      
      enableParticles: true,
      particleConfig: const ParticleConfig(
        density: ParticleDensity.medium,
        speed: ParticleSpeed.medium,
        style: ParticleStyle.organic,
        enableGlow: true,
        opacity: 0.6,
        size: 1.2,
      ),
    );
  }

  static theme_effects.ThemeEffects _createArtistEffects() {
    return theme_effects.ThemeEffects.fromEffectStyle(theme_effects.ThemeEffectStyle.elegant).copyWith(
      // Refined artistic effects
      shadowStyle: theme_effects.ShadowStyle.soft,
      gradientStyle: theme_effects.GradientStyle.subtle,
      borderStyle: theme_effects.BorderStyle.rounded,
      
      blurConfig: const theme_effects.BlurConfig(
        enabled: true,
        intensity: 2.0,
        style: theme_effects.BlurStyle.outer,
      ),
      
      glowConfig: const theme_effects.GlowConfig(
        enabled: true,
        intensity: 0.6,
        spread: 8.0,
        style: theme_effects.GlowStyle.outer,
      ),
      
      backgroundEffects: const theme_effects.BackgroundEffectConfig(
        enableParticles: true,
        enableGradientMesh: true,
        enableScanlines: false,
        particleType: theme_effects.BackgroundParticleType.floating,
        particleOpacity: 0.15,
        effectIntensity: 0.6,
      ),
    );
  }

  static app_theme_data.ThemeSpacing _createArtistSpacing() {
    return const app_theme_data.ThemeSpacing(
      extraSmall: 4.0,
      small: 8.0,
      medium: 16.0,
      large: 24.0,
      extraLarge: 32.0,
      cardPadding: 20.0,
      screenPadding: 24.0,
      buttonPadding: 20.0,
      inputPadding: 16.0,
    );
  }

  static app_theme_data.ThemeComponents _createArtistComponents() {
    return const app_theme_data.ThemeComponents(
      appBar: app_theme_data.AppBarConfig(
        elevation: 4.0,
        centerTitle: false,
        toolbarHeight: 64.0,
      ),
      
      card: app_theme_data.CardConfig(
        elevation: 6.0,
        borderRadius: 16.0,
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: EdgeInsets.all(20.0),
      ),
      
      button: app_theme_data.ButtonConfig(
        borderRadius: 12.0,
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
        elevation: 2.0,
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
        elevation: 6.0,
        width: null,
        height: 56.0,
      ),
      
      navigation: app_theme_data.NavigationConfig(
        type: app_theme_data.NavigationType.bottomNav,
        elevation: 8.0,
        showLabels: true,
      ),
      
      taskCard: app_theme_data.TaskCardConfig(
        borderRadius: 16.0,
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        padding: EdgeInsets.all(20.0),
        elevation: 4.0,
        showPriorityStripe: true,
        enableSwipeActions: true,
      ),
    );
  }
}

/// Helper class for accessing artist palette colors in static context
class _ArtistColorsHelper {
  final bool isDark;
  
  const _ArtistColorsHelper({required this.isDark});
  
  Color get primary => isDark ? const Color(0xFFD84315) : const Color(0xFFFF5722);
  Color get onSurface => isDark ? const Color(0xFFF0E6DE) : const Color(0xFF1F1B16);
  Color get onSurfaceVariant => isDark ? const Color(0xFFD3C4B4) : const Color(0xFF4F4539);
}