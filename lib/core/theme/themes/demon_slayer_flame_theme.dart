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

/// Demon Slayer Flame Theme - "Burning Spirit"
/// An intense flame-inspired theme with fire effects and ember particles
/// Features deep red-orange backgrounds, ember accents, and flame-like animations
class DemonSlayerFlameTheme {
  static app_theme_data.AppThemeData create({bool isDark = true}) {
    final now = DateTime.now();
    
    return app_theme_data.AppThemeData(
      metadata: ThemeMetadata(
        id: isDark ? 'demon_slayer_flame_dark' : 'demon_slayer_flame',
        name: isDark ? 'Demon Slayer Flame Dark' : 'Demon Slayer Flame Light',
        description: isDark 
          ? 'Intense flame theme with burning embers and fire effects for powerful focus'
          : 'Bright flame theme with warm sunrise colors and energizing fire effects',
        author: 'Tasky Team',
        version: '1.0.0',
        tags: ['flame', 'fire', 'anime', 'intense', 'gaming', 'energy', 'ember'],
        category: 'Gaming',
        previewIcon: PhosphorIcons.fire(),
        primaryPreviewColor: isDark ? const Color(0xFF8B0000) : const Color(0xFFFFF8F0),
        secondaryPreviewColor: const Color(0xFFFF4500),
        createdAt: now,
        isPremium: true,
        popularityScore: 9.5,
      ),
      
      colors: _createFlameColors(isDark: isDark),
      typography: _createFlameTypography(isDark: isDark),
      animations: _createFlameAnimations(),
      effects: _createFlameEffects(),
      spacing: _createFlameSpacing(),
      components: _createFlameComponents(),
    );
  }

  /// Create light variant
  static app_theme_data.AppThemeData createLight() => create(isDark: false);
  
  /// Create dark variant
  static app_theme_data.AppThemeData createDark() => create(isDark: true);

  /// Create flame-inspired color palette
  static ThemeColors _createFlameColors({bool isDark = true}) {
    if (!isDark) {
      // Flame Light - Sunrise energy
      const blazeOrange = Color(0xFFFF4500);      // Primary flame
      const emberRed = Color(0xFFDC143C);         // Ember red
      const sunriseYellow = Color(0xFFFFD700);    // Golden flame
      const charcoalGray = Color(0xFF2F2F2F);     // Dark text
      const smokeGray = Color(0xFF696969);        // Secondary text
      const ashWhite = Color(0xFFFFF8F0);         // Background
      const lightEmber = Color(0xFFFFE4E1);       // Light surface
      const warmGlow = Color(0xFFFFA07A);         // Accent
      
      return ThemeColors(
        // Primary
        primary: blazeOrange,
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFFFFE4E1),
        onPrimaryContainer: const Color(0xFF2E0E00),
        
        // Secondary
        secondary: emberRed,
        onSecondary: Colors.white,
        secondaryContainer: const Color(0xFFFFEBEE),
        onSecondaryContainer: const Color(0xFF330003),
        
        // Tertiary
        tertiary: sunriseYellow,
        onTertiary: charcoalGray,
        tertiaryContainer: const Color(0xFFFFFDE7),
        onTertiaryContainer: const Color(0xFF1C1B00),
        
        // Surface
        surface: ashWhite,
        onSurface: const Color(0xFF2d2d2d),
        surfaceVariant: lightEmber,
        onSurfaceVariant: const Color(0xFF2d2d2d),
        inverseSurface: const Color(0xFF2d2d2d),
        onInverseSurface: ashWhite,
        
        // Background
        background: ashWhite,
        onBackground: const Color(0xFF2d2d2d),
        
        // Error
        error: emberRed,
        onError: Colors.white,
        errorContainer: const Color(0xFFFFEBEE),
        onErrorContainer: const Color(0xFF330003),
        
        // Special
        accent: warmGlow,
        highlight: sunriseYellow,
        shadow: Colors.black54,
        outline: smokeGray,
        outlineVariant: const Color(0xFFD3C4B4),
        
        // Task Priority
        taskLowPriority: const Color(0xFFFFA07A),
        taskMediumPriority: blazeOrange,
        taskHighPriority: emberRed,
        taskUrgentPriority: const Color(0xFF8B0000),
        
        // Status
        success: const Color(0xFF32CD32),
        warning: sunriseYellow,
        info: const Color(0xFF4682B4),
        
        // Calendar Dots
        calendarTodayDot: blazeOrange,
        calendarOverdueDot: emberRed,
        calendarFutureDot: warmGlow,
        calendarCompletedDot: const Color(0xFF32CD32),
        calendarHighPriorityDot: const Color(0xFF8B0000),
        
        // Status Badges
        statusPendingBadge: warmGlow,
        statusInProgressBadge: blazeOrange,
        statusCompletedBadge: const Color(0xFF32CD32),
        statusCancelledBadge: smokeGray,
        statusOverdueBadge: emberRed,
        statusOnHoldBadge: sunriseYellow,
        
        // Interactive
        hover: blazeOrange.withValues(alpha: 0.8),
        pressed: blazeOrange.withValues(alpha: 0.9),
        focus: blazeOrange.withValues(alpha: 0.12),
        disabled: smokeGray.withValues(alpha: 0.5),
      );
    } else {
      // Flame Dark - Inferno night
      const deepRed = Color(0xFF8B0000);          // Dark crimson
      const blazeOrange = Color(0xFFFF4500);      // Bright flame
      const emberGlow = Color(0xFFFF6347);        // Ember glow
      const flameYellow = Color(0xFFFFD700);      // Golden flame
      const charcoalBlack = Color(0xFF1C1C1C);    // Background
      const smokeGray = Color(0xFF2F2F2F);        // Surface
      const ashGray = Color(0xFFDDDDDD);          // On surface
      
      return ThemeColors(
        // Primary
        primary: blazeOrange,
        onPrimary: Colors.white,
        primaryContainer: deepRed,
        onPrimaryContainer: const Color(0xFFFFE4E1),
        
        // Secondary
        secondary: emberGlow,
        onSecondary: Colors.white,
        secondaryContainer: const Color(0xFF5D0000),
        onSecondaryContainer: const Color(0xFFFFEBEE),
        
        // Tertiary
        tertiary: flameYellow,
        onTertiary: Colors.black,
        tertiaryContainer: const Color(0xFF4A3C00),
        onTertiaryContainer: const Color(0xFFFFFDE7),
        
        // Surface
        surface: charcoalBlack,
        onSurface: ashGray,                          // Use ashGray for better contrast
        surfaceVariant: smokeGray,
        onSurfaceVariant: ashGray,                   // Use ashGray consistently
        inverseSurface: const Color(0xFFf8f8f2),
        onInverseSurface: charcoalBlack,
        
        // Background
        background: charcoalBlack,
        onBackground: ashGray,                       // Use ashGray consistently
        
        // Error
        error: const Color(0xFFFF5555),
        onError: Colors.white,
        errorContainer: deepRed,
        onErrorContainer: const Color(0xFFFFEBEE),
        
        // Special
        accent: emberGlow,
        highlight: flameYellow,
        shadow: Colors.black87,
        outline: const Color(0xFF6B6B6B),
        outlineVariant: const Color(0xFF4A4A4A),
        
        // Task Priority
        taskLowPriority: const Color(0xFFFF8C69),
        taskMediumPriority: blazeOrange,
        taskHighPriority: emberGlow,
        taskUrgentPriority: deepRed,
        
        // Status
        success: const Color(0xFF4CAF50),
        warning: flameYellow,
        info: const Color(0xFF2196F3),
        
        // Calendar Dots
        calendarTodayDot: blazeOrange,
        calendarOverdueDot: deepRed,
        calendarFutureDot: emberGlow,
        calendarCompletedDot: const Color(0xFF4CAF50),
        calendarHighPriorityDot: deepRed,
        
        // Status Badges
        statusPendingBadge: emberGlow,
        statusInProgressBadge: blazeOrange,
        statusCompletedBadge: const Color(0xFF4CAF50),
        statusCancelledBadge: const Color(0xFF6B6B6B),
        statusOverdueBadge: deepRed,
        statusOnHoldBadge: flameYellow,
        
        // Interactive
        hover: blazeOrange.withValues(alpha: 0.8),
        pressed: blazeOrange.withValues(alpha: 0.9),
        focus: blazeOrange.withValues(alpha: 0.12),
        disabled: const Color(0xFF6B6B6B).withValues(alpha: 0.5),
      );
    }
  }

  /// Create flame-inspired typography with Exo 2 font
  static ThemeTypography _createFlameTypography({bool isDark = true}) {
    final colors = _FlameColorsHelper(isDark: isDark);
    const fontFamily = 'Exo 2';
    
    return ThemeTypography(
      fontFamily: fontFamily,
      displayFontFamily: fontFamily,
      monospaceFontFamily: fontFamily,
      baseSize: TypographyConstants.bodyLarge,
      scaleRatio: 1.0,
      baseFontWeight: TypographyConstants.medium, // Gaming strength
      baseLetterSpacing: TypographyConstants.normalLetterSpacing,
      baseLineHeight: TypographyConstants.normalLineHeight,
      
      // Display styles - Bold and commanding like flame
      displayLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.displayLarge,
        fontWeight: TypographyConstants.light,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
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
      
      // Headlines - Strong and energetic
      headlineLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.headlineLarge,
        fontWeight: TypographyConstants.regular, // Match Dracula IDE
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
        color: colors.primary,
      ),
      headlineSmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.headlineSmall,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurface,
      ),
      
      // Titles - Confident and clear
      titleLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleLarge,
        fontWeight: TypographyConstants.medium, // Gaming emphasis
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
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurface,
      ),
      
      // Body styles - Readable and balanced
      bodyLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodyLarge,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
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
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurfaceVariant,
      ),
      
      // Labels - Clear and functional
      labelLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelLarge,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurface,
      ),
      labelMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelMedium,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurface,
      ),
      labelSmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelSmall,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurfaceVariant,
      ),
      
      // Custom app styles
      taskTitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.taskTitle,
        fontWeight: TypographyConstants.medium, // Gaming strength
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurface,
      ),
      taskDescription: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.taskDescription,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
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
        color: colors.onPrimary,
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

  /// Create flame-inspired animations
  static ThemeAnimations _createFlameAnimations() {
    return ThemeAnimations.fromThemeStyle(ThemeAnimationStyle.sharp).copyWith(
      // Quick ember sparks and flame flicker
      fast: const Duration(milliseconds: 100),
      medium: const Duration(milliseconds: 250),
      slow: const Duration(milliseconds: 400),
      verySlow: const Duration(milliseconds: 600),
      
      // Flame-like curves
      primaryCurve: Curves.easeOutQuart,         // Sharp flame movement
      secondaryCurve: Curves.bounceInOut,        // Ember bounce
      entranceCurve: Curves.easeOutBack,         // Fire burst
      exitCurve: Curves.easeInQuart,             // Flame fade
      
      // Fire particle effects
      enableParticles: true,
    );
  }

  /// Create flame-inspired effects
  static theme_effects.ThemeEffects _createFlameEffects() {
    return theme_effects.ThemeEffects.fromEffectStyle(theme_effects.ThemeEffectStyle.dramatic).copyWith(
      shadowStyle: theme_effects.ShadowStyle.soft,
      gradientStyle: theme_effects.GradientStyle.metallic,
      borderStyle: theme_effects.BorderStyle.rounded,
      
      blurConfig: const theme_effects.BlurConfig(
        enabled: true,
        intensity: 3.0, // Strong flame glow
        style: theme_effects.BlurStyle.normal,
      ),
      
      glowConfig: const theme_effects.GlowConfig(
        enabled: true,
        intensity: 0.8, // Strong fire glow
        spread: 12.0,
        style: theme_effects.GlowStyle.outer,
      ),
      
      backgroundEffects: const theme_effects.BackgroundEffectConfig(
        enableParticles: true,
        enableGradientMesh: true,
        enableScanlines: false,
        particleType: theme_effects.BackgroundParticleType.energy,
        particleOpacity: 0.7,
        effectIntensity: 0.8,
        geometricPattern: theme_effects.BackgroundGeometricPattern.linear,
        patternAngle: 90.0,
        patternDensity: 1.1,
        accentColors: [
          Color(0x1AFF4500), // Blaze orange at 0.1 alpha
          Color(0x1FDC143C), // Ember red at 0.12 alpha
        ],
      ),
    );
  }

  /// Create flame-inspired spacing
  static app_theme_data.ThemeSpacing _createFlameSpacing() {
    return app_theme_data.ThemeSpacing.fromBaseUnit(8.0).copyWith(
      cardPadding: 16.0,
      screenPadding: 16.0,
      buttonPadding: 18.0,    // Slightly tighter for gaming feel
      inputPadding: 14.0,
    );
  }

  /// Create flame-inspired components
  static app_theme_data.ThemeComponents _createFlameComponents() {
    return const app_theme_data.ThemeComponents(
      appBar: app_theme_data.AppBarConfig(
        elevation: 0.0,
        centerTitle: true,
        toolbarHeight: kToolbarHeight,
      ),
      
      card: app_theme_data.CardConfig(
        elevation: 4.0,        // More prominent for gaming
        borderRadius: 12.0,    // Rounded but strong
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        padding: EdgeInsets.all(16.0),
      ),
      
      button: app_theme_data.ButtonConfig(
        borderRadius: 8.0,     // Gaming-style corners
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        elevation: 2.0,
        height: 48.0,
        style: app_theme_data.ButtonStyle.filled,
      ),
      
      input: app_theme_data.InputConfig(
        borderRadius: 8.0,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        borderStyle: app_theme_data.InputBorderStyle.outline,
        filled: true,
      ),
      
      fab: app_theme_data.FABConfig(
        shape: app_theme_data.FABShape.circular,
        elevation: 6.0,
        width: null,
        height: null,
      ),
      
      navigation: app_theme_data.NavigationConfig(
        type: app_theme_data.NavigationType.bottomNav,
        elevation: 8.0,
        showLabels: true,
      ),
      
      taskCard: app_theme_data.TaskCardConfig(
        borderRadius: 12.0,    // Consistent with card
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        padding: EdgeInsets.all(16.0),
        elevation: 3.0,        // Slightly more prominent
        showPriorityStripe: true,
        enableSwipeActions: true,
      ),
    );
  }
}

/// Helper class for accessing colors in static context
class _FlameColorsHelper {
  final bool isDark;
  
  _FlameColorsHelper({required this.isDark});
  
  Color get primary => isDark ? const Color(0xFFFF4500) : const Color(0xFFFF4500);
  Color get onPrimary => Colors.white;
  Color get onSurface => isDark ? const Color(0xFFf8f8f2) : const Color(0xFF2d2d2d);
  Color get onSurfaceVariant => isDark ? const Color(0xFFf8f8f2) : const Color(0xFF2d2d2d);
}