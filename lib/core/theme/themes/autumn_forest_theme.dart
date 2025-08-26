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

/// 🍂 Autumn Forest Theme - "Golden Autumn"
/// A warm, natural theme inspired by autumn forests and falling leaves
/// Dark Mode: "Midnight Forest" - Deep browns and golds with warm amber accents
/// Light Mode: "Golden Day" - Warm maple reds, sunset oranges, and rich bark browns
class AutumnForestTheme {
  static app_theme_data.AppThemeData create({bool isDark = true}) {
    final now = DateTime.now();
    
    return app_theme_data.AppThemeData(
      metadata: ThemeMetadata(
        id: isDark ? 'autumn_forest_dark' : 'autumn_forest_light',
        name: isDark ? 'Autumn Forest Dark' : 'Autumn Forest Light',
        description: isDark 
          ? 'Midnight Forest theme featuring deep browns, warm amber accents, golden highlights, and natural forest atmosphere'
          : 'Golden Day theme with warm maple reds, sunset oranges, rich bark browns, and autumn forest aesthetics',
        author: 'Tasky Team',
        version: '1.0.0',
        tags: ['nature', 'autumn', 'warm', 'forest', 'golden', 'maple', 'cozy', 'natural'],
        category: 'nature',
        previewIcon: PhosphorIcons.tree(),
        primaryPreviewColor: const Color(0xFFD84315), // Maple leaf red
        secondaryPreviewColor: const Color(0xFFFF8F00), // Sunset orange
        createdAt: now,
        isPremium: false,
        popularityScore: 8.5, // High natural appeal
      ),
      
      colors: _createAutumnColors(isDark: isDark),
      typography: _createAutumnTypography(isDark: isDark),
      animations: _createAutumnAnimations(),
      effects: _createAutumnEffects(isDark: isDark),
      spacing: _createAutumnSpacing(),
      components: _createAutumnComponents(),
    );
  }

  /// Create light variant - Golden Day
  static app_theme_data.AppThemeData createLight() => create(isDark: false);
  
  /// Create dark variant - Midnight Forest
  static app_theme_data.AppThemeData createDark() => create(isDark: true);

  static ThemeColors _createAutumnColors({required bool isDark}) {
    if (isDark) {
      return const ThemeColors(
        // Midnight Forest - Deep natural colors
        primary: Color(0xFFBF360C), // Dark maple
        onPrimary: Color(0xFFFFF8E8), // Warm autumn-tinted white
        primaryContainer: Color(0xFF8B2500),
        onPrimaryContainer: Color(0xFFFFE5DD),
        
        secondary: Color(0xFFE65100), // Deep sunset
        onSecondary: Color(0xFFFFF5E6), // Sunset-tinted white
        secondaryContainer: Color(0xFFBF3600),
        onSecondaryContainer: Color(0xFFFFF3E0),
        
        tertiary: Color(0xFF5D4037), // Deep bark
        onTertiary: Color(0xFFFFFFFF),
        tertiaryContainer: Color(0xFF3E2723),
        onTertiaryContainer: Color(0xFFF5DEB3),
        
        error: Color(0xFF6D1B00), // Dark autumn red
        onError: Color(0xFFFFFFFF),
        errorContainer: Color(0xFF4F1400),
        onErrorContainer: Color(0xFFFFEBEE),
        
        surface: Color(0xFF1A1611), // Dark forest floor
        onSurface: Color(0xFFF7F0E8),
        surfaceVariant: Color(0xFF1F1B16), // Dark leaves
        onSurfaceVariant: Color(0xFFD3C4B4),
        inverseSurface: Color(0xFFF7F0E8),
        onInverseSurface: Color(0xFF34302A),
        
        background: Color(0xFF1A1611), // Night forest
        onBackground: Color(0xFFF7F0E8),
        
        outline: Color(0xFF9A8F80),
        outlineVariant: Color(0xFF4F4539),
        shadow: Color(0xFF000000),
        
        // Additional required colors
        accent: Color(0xFFFFAB00), // Golden amber accent
        highlight: Color(0xFFFFCC02), // Bright golden highlight
        
        // Task priority colors - autumn theme
        taskLowPriority: Color(0xFF66BB6A), // Forest green
        taskMediumPriority: Color(0xFFE65100), // Deep orange
        taskHighPriority: Color(0xFFBF360C), // Primary maple
        taskUrgentPriority: Color(0xFF6D1B00), // Dark red
        
        // Status colors
        success: Color(0xFF66BB6A), // Forest green
        warning: Color(0xFFFFAB00), // Golden amber
        info: Color(0xFFE65100), // Deep orange
        
        // Calendar dot colors - autumn theme
        calendarTodayDot: Color(0xFFBF360C), // Primary maple
        calendarCompletedDot: Color(0xFF66BB6A), // Forest green
        calendarOverdueDot: Color(0xFF6D1B00), // Dark red
        calendarHighPriorityDot: Color(0xFFE65100), // Deep orange
        calendarFutureDot: Color(0xFF5D4037), // Deep bark
        
        // Status badge colors - autumn theme
        statusPendingBadge: Color(0xFFE65100), // Deep orange
        statusInProgressBadge: Color(0xFFFFAB00), // Golden amber
        statusCompletedBadge: Color(0xFF66BB6A), // Forest green
        statusCancelledBadge: Color(0xFF9E9E9E), // Gray
        statusOverdueBadge: Color(0xFF6D1B00), // Dark red
        statusOnHoldBadge: Color(0xFF5D4037), // Deep bark
        
        // Interactive colors
        hover: Color(0xFF8B2500), // Darker maple
        pressed: Color(0xFF6A1B00), // Even darker maple
        focus: Color(0xFFBF360C), // Primary color for focus
        disabled: Color(0xFF4F4539)
      );
    } else {
      return const ThemeColors(
        // Golden Autumn Day - Warm forest colors
        primary: Color(0xFFD84315), // Maple leaf red
        onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFFFFE5DD),
        onPrimaryContainer: Color(0xFF2E0E00),
        
        secondary: Color(0xFFFF8F00), // Sunset orange  
        onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: Color(0xFFFFF3E0),
        onSecondaryContainer: Color(0xFF3E2000),
        
        tertiary: Color(0xFF6A4C39), // Rich bark brown
        onTertiary: Color(0xFFFFFFFF),
        tertiaryContainer: Color(0xFFF5DEB3),
        onTertiaryContainer: Color(0xFF2A1A0F),
        
        error: Color(0xFF8B0000), // Deep autumn red
        onError: Color(0xFFFFFFFF),
        errorContainer: Color(0xFFFFEBEE),
        onErrorContainer: Color(0xFF2F0000),
        
        surface: Color(0xFFFFFBF5), // Morning mist
        onSurface: Color(0xFF1F1B16),
        surfaceVariant: Color(0xFFF7F2EA), // Dried leaves
        onSurfaceVariant: Color(0xFF4F4539),
        inverseSurface: Color(0xFF34302A),
        onInverseSurface: Color(0xFFF7F0E8),
        
        background: Color(0xFFFFFBF5), // Autumn clearing
        onBackground: Color(0xFF1F1B16),
        
        outline: Color(0xFF807567),
        outlineVariant: Color(0xFFD3C4B4),
        shadow: Color(0xFF000000),
        
        // Additional required colors
        accent: Color(0xFFFFAB00), // Golden amber accent
        highlight: Color(0xFFFFD54F), // Bright golden highlight
        
        // Task priority colors - autumn theme
        taskLowPriority: Color(0xFF66BB6A), // Forest green
        taskMediumPriority: Color(0xFFFF8F00), // Sunset orange
        taskHighPriority: Color(0xFFD84315), // Primary maple
        taskUrgentPriority: Color(0xFF8B0000), // Deep red
        
        // Status colors
        success: Color(0xFF66BB6A), // Forest green
        warning: Color(0xFFFFAB00), // Golden amber
        info: Color(0xFFFF8F00), // Sunset orange
        
        // Calendar dot colors - autumn theme
        calendarTodayDot: Color(0xFFD84315), // Primary maple
        calendarCompletedDot: Color(0xFF66BB6A), // Forest green
        calendarOverdueDot: Color(0xFF8B0000), // Deep red
        calendarHighPriorityDot: Color(0xFFFF8F00), // Sunset orange
        calendarFutureDot: Color(0xFF6A4C39), // Rich bark
        
        // Status badge colors - autumn theme
        statusPendingBadge: Color(0xFFFF8F00), // Sunset orange
        statusInProgressBadge: Color(0xFFFFAB00), // Golden amber
        statusCompletedBadge: Color(0xFF66BB6A), // Forest green
        statusCancelledBadge: Color(0xFF9E9E9E), // Gray
        statusOverdueBadge: Color(0xFF8B0000), // Deep red
        statusOnHoldBadge: Color(0xFF6A4C39), // Rich bark
        
        // Interactive colors
        hover: Color(0xFFE64A19), // Darker maple
        pressed: Color(0xFFD84315), // Even darker maple
        focus: Color(0xFFD84315), // Primary color for focus
        disabled: Color(0xFFD3C4B4)
      );
    }
  }

  static ThemeTypography _createAutumnTypography({required bool isDark}) {
    const fontFamily = 'Merriweather'; // Natural, serif font for warmth
    final colors = _AutumnColorsHelper(isDark: isDark);
    
    return ThemeTypography(
      fontFamily: fontFamily,
      displayFontFamily: fontFamily,
      monospaceFontFamily: fontFamily,
      baseSize: TypographyConstants.bodyLarge,
      scaleRatio: 1.0,
      baseFontWeight: TypographyConstants.regular,
      baseLetterSpacing: TypographyConstants.normalLetterSpacing,
      baseLineHeight: TypographyConstants.normalLineHeight,
      
      // Display styles - Natural warmth
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
      
      // Headline styles - Forest headers
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
      
      // Title styles - Natural emphasis
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
      
      // Body styles - Comfortable reading
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
      
      // Label styles - Natural UI elements
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

  static ThemeAnimations _createAutumnAnimations() {
    return const ThemeAnimations(
      // Gentle falling leaves
      fast: Duration(milliseconds: 200),
      medium: Duration(milliseconds: 400),
      slow: Duration(milliseconds: 600),
      verySlow: Duration(milliseconds: 1000),
      
      // Natural autumn curves
      primaryCurve: Curves.easeInQuart, // Falling leaf movement
      secondaryCurve: Curves.easeInOutSine, // Natural wind sway
      entranceCurve: Curves.easeOutCubic,
      exitCurve: Curves.easeInCubic,
      
      enableParticles: true,
      particleConfig: ParticleConfig(
        density: ParticleDensity.low,
        speed: ParticleSpeed.slow,
        style: ParticleStyle.organic,
        enableGlow: false,
        opacity: 0.4,
        size: 1.5,
      ),
    );
  }

  static theme_effects.ThemeEffects _createAutumnEffects({required bool isDark}) {
    return theme_effects.ThemeEffects(
      // Natural elegance
      shadowStyle: theme_effects.ShadowStyle.soft,
      gradientStyle: theme_effects.GradientStyle.subtle,
      borderStyle: theme_effects.BorderStyle.rounded,
      
      blurConfig: const theme_effects.BlurConfig(
        enabled: true,
        intensity: 1.5,
        style: theme_effects.BlurStyle.outer,
      ),
      
      glowConfig: theme_effects.GlowConfig(
        enabled: true,
        intensity: isDark ? 0.6 : 0.2, // Warmer amber glow in midnight forest
        spread: isDark ? 8.0 : 4.0, // Wider atmospheric glow in dark forest
        style: theme_effects.GlowStyle.outer,
      ),
      
      backgroundEffects: theme_effects.BackgroundEffectConfig(
        enableParticles: true,
        enableGradientMesh: true,
        enableScanlines: false,
        particleType: theme_effects.BackgroundParticleType.floating,
        particleOpacity: isDark ? 0.18 : 0.05, // More falling leaves in midnight forest
        effectIntensity: isDark ? 0.7 : 0.2, // Stronger forest atmosphere in dark mode
        geometricPattern: theme_effects.BackgroundGeometricPattern.radial, // Natural harmony
        patternAngle: 0.0, // Centered radial
        patternDensity: 0.9, // Organic density
        accentColors: [
          (isDark ? const Color(0xFFD84315) : const Color(0xFFFF8F00)).withValues(alpha: 0.08), // Autumn orange
          (isDark ? const Color(0xFF8D6E63) : const Color(0xFFA1887F)).withValues(alpha: 0.06), // Warm brown
        ],
      ),
    );
  }

  static app_theme_data.ThemeSpacing _createAutumnSpacing() {
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

  static app_theme_data.ThemeComponents _createAutumnComponents() {
    return const app_theme_data.ThemeComponents(
      appBar: app_theme_data.AppBarConfig(
        elevation: 4.0,
        centerTitle: false,
        toolbarHeight: 64.0,
      ),
      
      card: app_theme_data.CardConfig(
        elevation: 6.0,
        borderRadius: 12.0,
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
        borderRadius: 12.0,
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        padding: EdgeInsets.all(20.0),
        elevation: 4.0,
        showPriorityStripe: true,
        enableSwipeActions: true,
      ),
    );
  }
}

/// Helper class for accessing autumn colors in static context
class _AutumnColorsHelper {
  final bool isDark;
  
  const _AutumnColorsHelper({required this.isDark});
  
  Color get primary => isDark ? const Color(0xFFBF360C) : const Color(0xFFD84315);
  Color get onSurface => isDark ? const Color(0xFFF7F0E8) : const Color(0xFF1F1B16);
  Color get onSurfaceVariant => isDark ? const Color(0xFFD3C4B4) : const Color(0xFF4F4539);
}