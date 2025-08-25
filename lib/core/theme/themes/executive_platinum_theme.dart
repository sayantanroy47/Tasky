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

/// 💼 Executive Platinum Theme - "Corporate Excellence"
/// A sophisticated business theme with premium platinum aesthetics
/// Dark Mode: "Executive Night" - Deep charcoal with platinum highlights and gold accents
/// Light Mode: "Corporate Platinum" - Clean whites with platinum grays and executive elegance
class ExecutivePlatinumTheme {
  static app_theme_data.AppThemeData create({bool isDark = true}) {
    final now = DateTime.now();
    
    return app_theme_data.AppThemeData(
      metadata: ThemeMetadata(
        id: isDark ? 'executive_platinum_dark' : 'executive_platinum_light',
        name: isDark ? 'Executive Platinum Dark' : 'Executive Platinum Light',
        description: isDark 
          ? 'Executive Night theme featuring deep charcoal backgrounds, platinum highlights, gold accents, and sophisticated business aesthetics'
          : 'Corporate Platinum theme with clean whites, platinum grays, gold details, and premium executive elegance',
        author: 'Tasky Team',
        version: '1.0.0',
        tags: ['business', 'executive', 'platinum', 'professional', 'premium', 'corporate', 'elegant', 'sophisticated'],
        category: 'business',
        previewIcon: PhosphorIcons.briefcase(),
        primaryPreviewColor: const Color(0xFF424242), // Platinum gray
        secondaryPreviewColor: const Color(0xFFFFB300), // Executive gold
        createdAt: now,
        isPremium: false,
        popularityScore: 9.2, // High business appeal
      ),
      
      colors: _createExecutiveColors(isDark: isDark),
      typography: _createExecutiveTypography(isDark: isDark),
      animations: _createExecutiveAnimations(),
      effects: _createExecutiveEffects(),
      spacing: _createExecutiveSpacing(),
      components: _createExecutiveComponents(),
    );
  }

  /// Create light variant - Corporate Platinum
  static app_theme_data.AppThemeData createLight() => create(isDark: false);
  
  /// Create dark variant - Executive Night
  static app_theme_data.AppThemeData createDark() => create(isDark: true);

  static ThemeColors _createExecutiveColors({required bool isDark}) {
    if (isDark) {
      return const ThemeColors(
        // Executive Night - Deep sophisticated colors
        primary: Color(0xFF616161), // Platinum gray
        onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFF424242),
        onPrimaryContainer: Color(0xFFE0E0E0),
        
        secondary: Color(0xFFFFB300), // Executive gold
        onSecondary: Color(0xFF000000),
        secondaryContainer: Color(0xFFFF8F00),
        onSecondaryContainer: Color(0xFFFFF3C4),
        
        tertiary: Color(0xFF37474F), // Executive steel
        onTertiary: Color(0xFFFFFFFF),
        tertiaryContainer: Color(0xFF263238),
        onTertiaryContainer: Color(0xFFCFD8DC),
        
        error: Color(0xFFE57373), // Executive red
        onError: Color(0xFF000000),
        errorContainer: Color(0xFFD32F2F),
        onErrorContainer: Color(0xFFFFEBEE),
        
        surface: Color(0xFF121212), // Executive black
        onSurface: Color(0xFFf8f8f2),
        surfaceVariant: Color(0xFF1E1E1E), // Dark platinum
        onSurfaceVariant: Color(0xFFf8f8f2),
        
        background: Color(0xFF121212), // Executive office
        onBackground: Color(0xFFf8f8f2),
        
        outline: Color(0xFF757575),
        outlineVariant: Color(0xFF424242),
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),
        inverseSurface: Color(0xFFE0E0E0),
        onInverseSurface: Color(0xFF212121),
        inversePrimary: Color(0xFF424242),
        
        // Additional required colors
        accent: Color(0xFFFFB300), // Executive gold accent
        disabled: Color(0xFF424242),
        focus: Color(0xFF616161), // Primary color for focus
        
        // Calendar dot colors - executive theme
        calendarTodayDot: Color(0xFF616161), // Platinum
        calendarCompletedDot: Color(0xFF66BB6A), // Success green
        calendarOverdueDot: Color(0xFFE57373), // Executive red
        calendarHighPriorityDot: Color(0xFFFFB300), // Gold
        calendarFutureDot: Color(0xFF37474F), // Steel
      );
    } else {
      return const ThemeColors(
        // Corporate Platinum - Clean professional colors
        primary: Color(0xFF424242), // Platinum gray
        onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFFE0E0E0),
        onPrimaryContainer: Color(0xFF1C1C1C),
        
        secondary: Color(0xFFFFB300), // Executive gold
        onSecondary: Color(0xFF000000),
        secondaryContainer: Color(0xFFFFF3C4),
        onSecondaryContainer: Color(0xFF3E2000),
        
        tertiary: Color(0xFF607D8B), // Executive steel blue
        onTertiary: Color(0xFFFFFFFF),
        tertiaryContainer: Color(0xFFCFD8DC),
        onTertiaryContainer: Color(0xFF102027),
        
        error: Color(0xFFD32F2F), // Executive red
        onError: Color(0xFFFFFFFF),
        errorContainer: Color(0xFFFFEBEE),
        onErrorContainer: Color(0xFF2C0009),
        
        surface: Color(0xFFFAFAFA), // Executive white
        onSurface: Color(0xFF2d2d2d),
        surfaceVariant: Color(0xFFF5F5F5), // Light platinum
        onSurfaceVariant: Color(0xFF2d2d2d),
        
        background: Color(0xFFFAFAFA), // Executive office
        onBackground: Color(0xFF2d2d2d),
        
        outline: Color(0xFF757575),
        outlineVariant: Color(0xFFBDBDBD),
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),
        inverseSurface: Color(0xFF212121),
        onInverseSurface: Color(0xFFF5F5F5),
        inversePrimary: Color(0xFF9E9E9E),
        
        // Additional required colors
        accent: Color(0xFFFFB300), // Executive gold accent
        disabled: Color(0xFFBDBDBD),
        focus: Color(0xFF424242), // Primary color for focus
        
        // Calendar dot colors - executive theme
        calendarTodayDot: Color(0xFF424242), // Platinum
        calendarCompletedDot: Color(0xFF66BB6A), // Success green
        calendarOverdueDot: Color(0xFFD32F2F), // Executive red
        calendarHighPriorityDot: Color(0xFFFFB300), // Gold
        calendarFutureDot: Color(0xFF607D8B), // Steel blue
      );
    }
  }

  static ThemeTypography _createExecutiveTypography({required bool isDark}) {
    const fontFamily = 'Roboto'; // Clean, professional font
    final colors = _ExecutiveColorsHelper(isDark: isDark);
    
    return ThemeTypography(
      fontFamily: fontFamily,
      
      // Display styles - Executive presence
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
      
      // Headline styles - Executive headers
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
      
      // Title styles - Professional emphasis
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
      
      // Body styles - Business communication
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
      
      // Label styles - Professional UI elements
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
    );
  }

  static ThemeAnimations _createExecutiveAnimations() {
    return ThemeAnimations.fromThemeStyle(
      theme_effects.ThemeAnimationStyle.sharp, // Crisp, professional transitions
      customCurves: {
        'businessDecision': Curves.easeInOutCubic, // Confident decisions
        'professionalSlide': Curves.easeOutQuart, // Smooth presentations
        'executiveReveal': Curves.easeInOutExpo, // Impressive reveals
      },
    );
  }

  static theme_effects.ThemeEffects _createExecutiveEffects() {
    return theme_effects.ThemeEffects.fromEffectStyle(
      theme_effects.ThemeEffectStyle.elegant, // Refined professional effects
      backgroundEffect: theme_effects.BackgroundEffectConfig(
        enableParticles: true,
        enableGradientMesh: true,
        particleType: theme_effects.ParticleType.geometric,
        particleCount: 8, // Subtle professional particles
        particleColors: [
          const Color(0xFF424242), // Platinum
          const Color(0xFFFFB300), // Executive gold
          const Color(0xFF607D8B), // Steel blue
          const Color(0xFF9E9E9E), // Light platinum
        ],
        animationDuration: const Duration(seconds: 6), // Measured, professional
        meshColors: [
          const Color(0xFF424242).withOpacity(0.05), // Subtle platinum
          const Color(0xFFFFB300).withOpacity(0.05), // Hint of gold
          const Color(0xFF607D8B).withOpacity(0.05), // Steel undertone
        ],
        intensity: 0.3, // Refined intensity
        speed: 0.4, // Professional pace
      ),
    );
  }

  static app_theme_data.ThemeSpacing _createExecutiveSpacing() {
    return const app_theme_data.ThemeSpacing(
      xs: TypographyConstants.spacingSmall / 2, // 4px
      sm: TypographyConstants.spacingSmall, // 8px
      md: TypographyConstants.spacingMedium, // 16px
      lg: TypographyConstants.spacingLarge, // 24px
      xl: TypographyConstants.spacingXLarge, // 32px
    );
  }

  static app_theme_data.ThemeComponents _createExecutiveComponents() {
    return const app_theme_data.ThemeComponents(
      cardElevation: 4.0, // Professional depth
      borderRadius: TypographyConstants.radiusSmall, // Clean, professional edges
      buttonHeight: 48.0, // Standard professional interaction
      inputHeight: 52.0, // Executive input size
      iconSize: 24.0, // Professional icons
      avatarSize: 40.0, // Executive profile size
      chipHeight: 36.0, // Business chips
      tabHeight: 48.0, // Professional navigation
      listItemHeight: 64.0, // Executive list spacing
      dividerThickness: 1.0, // Clean dividers
    );
  }
}

/// Helper class for accessing executive colors in static context
class _ExecutiveColorsHelper {
  final bool isDark;
  
  const _ExecutiveColorsHelper({required this.isDark});
  
  Color get primary => isDark ? const Color(0xFF616161) : const Color(0xFF424242);
  Color get onSurface => isDark ? const Color(0xFFf8f8f2) : const Color(0xFF2d2d2d);
  Color get onSurfaceVariant => isDark ? const Color(0xFFf8f8f2) : const Color(0xFF2d2d2d);
}