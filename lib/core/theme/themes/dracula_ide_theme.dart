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

/// Dracula IDE Theme - "Developer's Dream"
/// A sophisticated dark theme inspired by the popular Dracula color scheme
/// Features dark purple backgrounds, pink accents, and developer-friendly design
class DraculaIDETheme {
  static app_theme_data.AppThemeData create({bool isDark = true}) {
    final now = DateTime.now();
    
    return app_theme_data.AppThemeData(
      metadata: ThemeMetadata(
        id: isDark ? 'dracula_ide_dark' : 'dracula_ide',
        name: isDark ? 'Dracula IDE Dark' : 'Dracula IDE Light',
        description: isDark 
          ? 'Refined Dracula IDE theme with moody purple backgrounds and bright neon-like highlights for modern readability'
          : 'Dracula IDE light variant maintaining playful vibrancy with refined tones for excellent UI usability',
        author: 'Tasky Team',
        version: '1.0.0',
        tags: ['developer', 'ide', 'dark', 'purple', 'pink', 'elegant', 'syntax'],
        category: 'developer',
        previewIcon: PhosphorIcons.code(),
        primaryPreviewColor: isDark ? const Color(0xFF1A1C26) : const Color(0xFFFFFFFF), // Enhanced dark purple or pure white
        secondaryPreviewColor: isDark ? const Color(0xFFFF88DD) : const Color(0xFFDD4499), // Enhanced pink (mode-specific)
        tertiaryPreviewColor: isDark ? const Color(0xFFE6C1FF) : const Color(0xFF6633AA), // Dracula Purple signature accent
        createdAt: now,
        isPremium: false,
        popularityScore: 9.7,
      ),
      
      colors: _createDraculaColors(isDark: isDark),
      typography: _createDraculaTypography(isDark: isDark),
      animations: _createDraculaAnimations(),
      effects: _createDraculaEffects(),
      spacing: _createDraculaSpacing(),
      components: _createDraculaComponents(),
    );
  }

  /// Create light variant
  static app_theme_data.AppThemeData createLight() => create(isDark: false);
  
  /// Create dark variant (standard Dracula)
  static app_theme_data.AppThemeData createDark() => create(isDark: true);


  /// Create Dracula IDE-inspired color palette with refined usability
  static ThemeColors _createDraculaColors({bool isDark = true}) {
    if (!isDark) {
      // Dracula Light Variant: Refined & Usable
      
      // Dracula colors - Deeper variants for better contrast on light backgrounds
      const deepDraculaPink = Color(0xFFDD4499);          // Deeper pink primary
      const deepDraculaPurple = Color(0xFF8855CC);        // Deeper purple secondary  
      const deepDraculaCyan = Color(0xFF4499BB);          // Deeper cyan
      const deepDraculaGreen = Color(0xFF338855);         // Deeper green
      const deepDraculaOrange = Color(0xFFDD7744);        // Deeper orange
      const deepDraculaRed = Color(0xFFCC2222);           // Deeper red
      const deepDraculaYellow = Color(0xFFBBBB44);        // Deeper yellow
      const deepDraculaComment = Color(0xFF556677);       // Deeper comment color for readability
      
      // Light backgrounds and containers - Enhanced contrast
      const pureWhite = Color(0xFFFFFFFF);                // Pure white background
      const lightSurface = Color(0xFFF8F8F8);             // Light gray surface
      const paleContainer = Color(0xFFE8E0FF);            // Light purple tint container
      const deepTextInk = Color(0xFF1A1A1A);              // Deep text for maximum readability
      
      // Dracula Purple Signature Accent - Deeper for light mode contrast
      const deepDraculaPurpleSignature = Color(0xFF6633AA);    // Deep signature purple
      const onDeepDraculaPurpleSignature = Color(0xFFFFFFFF);  // White text on deep purple
      const deepDraculaPurpleContainer = Color(0xFFE8E0FF);    // Light purple container
      const onDeepDraculaPurpleContainer = Color(0xFF2A1155);  // Deep purple container text
      
      
      return const ThemeColors(
        // Primary colors - Deep Dracula pink for better contrast
        primary: deepDraculaPink,
        onPrimary: pureWhite,
        primaryContainer: paleContainer,
        onPrimaryContainer: deepDraculaPink,

        // Secondary colors - Deep Dracula purple for better contrast
        secondary: deepDraculaPurple,
        onSecondary: pureWhite,
        secondaryContainer: paleContainer,
        onSecondaryContainer: deepDraculaPurple,

        // Tertiary colors - Deep Dracula cyan for better contrast
        tertiary: deepDraculaCyan,
        onTertiary: pureWhite,
        tertiaryContainer: paleContainer,
        onTertiaryContainer: deepDraculaCyan,

        // Surface colors - Enhanced contrast
        surface: lightSurface,
        onSurface: deepTextInk,                // Deep text for maximum readability
        surfaceVariant: lightSurface,
        onSurfaceVariant: deepTextInk,         // Deep text for variants too
        inverseSurface: deepDraculaPink,
        onInverseSurface: pureWhite,

        // Background colors - Enhanced contrast
        background: pureWhite,
        onBackground: deepTextInk,             // Deep text for maximum readability

        // Error colors - Deep Dracula red for better contrast
        error: deepDraculaRed,
        onError: pureWhite,
        errorContainer: paleContainer,
        onErrorContainer: deepDraculaRed,

        // Special colors - Enhanced with signature accent
        accent: deepDraculaPurpleSignature,    // Use signature purple as primary accent
        highlight: deepDraculaYellow,
        shadow: Color(0xFF000000),
        outline: deepDraculaComment,           // Deeper outline for better visibility
        outlineVariant: Color(0xFF889999),    // Enhanced outline variant

        // Dracula Purple Signature Colors
        draculaPurple: deepDraculaPurpleSignature,
        onDraculaPurple: onDeepDraculaPurpleSignature,
        draculaPurpleContainer: deepDraculaPurpleContainer,
        onDraculaPurpleContainer: onDeepDraculaPurpleContainer,

        // Task priority colors - Enhanced with signature accent
        taskLowPriority: deepDraculaGreen,          // Deep green - Low priority
        taskMediumPriority: deepDraculaCyan,        // Deep cyan - Medium priority
        taskHighPriority: deepDraculaPurpleSignature, // Signature purple - High priority
        taskUrgentPriority: deepDraculaRed,         // Deep red - Urgent priority

        // Status colors - Deeper for better contrast
        success: deepDraculaGreen,
        warning: deepDraculaOrange,
        info: deepDraculaCyan,

        // Calendar dot colors - Dracula IDE theme (light) - Enhanced
        calendarTodayDot: deepDraculaPink,                  // Deep pink for today
        calendarOverdueDot: deepDraculaRed,                 // Deep red for overdue
        calendarFutureDot: deepDraculaCyan,                 // Deep cyan for future
        calendarCompletedDot: deepDraculaGreen,             // Deep green for completed
        calendarHighPriorityDot: deepDraculaPurpleSignature, // Signature purple for high priority
        
        // Status badge colors - Enhanced with signature purple
        statusPendingBadge: deepDraculaCyan,                // Deep cyan for pending
        statusInProgressBadge: deepDraculaOrange,           // Deep orange for in progress
        statusCompletedBadge: deepDraculaPurpleSignature,   // Signature purple for completed (achievement)
        statusCancelledBadge: deepDraculaComment,           // Deep comment color for cancelled
        statusOverdueBadge: deepDraculaRed,                 // Deep red for overdue
        statusOnHoldBadge: deepDraculaYellow,               // Deep yellow for on hold

        // Interactive colors - Enhanced for better visibility
        hover: Color(0xFFCC5588),              // Deeper hover state
        pressed: Color(0xFFAA3366),            // Deeper pressed state
        focus: deepDraculaYellow,
        disabled: deepDraculaComment,
      );
    }
    
    // Dracula Dark Variant: Super bright, highly saturated colors for maximum visibility
    const draculaBackground = Color(0xFF1A1C26);    // Deeper dark purple background
    const draculaCurrentLine = Color(0xFF2A2D3A);   // Deeper current line for stronger contrast
    const draculaForeground = Color(0xFFFFFFFF);    // Pure white foreground for maximum readability
    const draculaComment = Color(0xFF7788BB);       // Enhanced blue-gray comments (brighter)
    const draculaCyan = Color(0xFF00FFFF);          // Pure neon cyan (maximum saturation)
    const draculaGreen = Color(0xFF55FF88);         // Enhanced vibrant green (brighter)
    const draculaOrange = Color(0xFFFFCC77);        // Enhanced warm orange (brighter)
    const draculaPink = Color(0xFFFF88DD);          // Enhanced pink primary (brighter)
    const draculaPurple = Color(0xFFCC99FF);        // Enhanced purple secondary (brighter)
    const draculaRed = Color(0xFFFF6666);           // Enhanced red (brighter)
    const draculaYellow = Color(0xFFFFFF99);        // Enhanced yellow highlight (brighter)
    
    // Dracula Purple Signature Accent - Enhanced for dark mode visibility
    const draculaPurpleSignature = Color(0xFFE6C1FF);     // Super bright signature purple
    const onDraculaPurpleSignature = Color(0xFF000000);   // Pure black for maximum contrast
    const draculaPurpleContainer = Color(0xFF5A3A7A);     // Enhanced purple container
    const onDraculaPurpleContainer = Color(0xFFFFFFFF);   // Pure white for container text
    
    return const ThemeColors(
      // Primary colors - Enhanced Dracula pink
      primary: draculaPink,
      onPrimary: Color(0xFF000000),           // Pure black for maximum contrast
      primaryContainer: Color(0xFF5A2A46),    // Enhanced pink container
      onPrimaryContainer: Color(0xFFFFFFFF),  // Pure white for container text

      // Secondary colors - Enhanced Dracula purple
      secondary: draculaPurple,
      onSecondary: Color(0xFF000000),         // Pure black for maximum contrast
      secondaryContainer: Color(0xFF4D3A6F),  // Enhanced purple container
      onSecondaryContainer: Color(0xFFFFFFFF), // Pure white for container text

      // Tertiary colors - Enhanced Dracula cyan
      tertiary: draculaCyan,
      onTertiary: Color(0xFF000000),          // Pure black for maximum contrast
      tertiaryContainer: Color(0xFF2A4A5F),   // Enhanced cyan container
      onTertiaryContainer: Color(0xFFFFFFFF), // Pure white for container text

      // Surface colors - Enhanced contrast
      surface: draculaCurrentLine,
      onSurface: draculaForeground,           // Pure white text
      surfaceVariant: Color(0xFF2A2D3A),     // Enhanced surface variant
      onSurfaceVariant: Color(0xFFE6E6E6),   // Near-white for excellent contrast
      inverseSurface: draculaForeground,
      onInverseSurface: draculaBackground,

      // Background colors - Enhanced contrast
      background: draculaBackground,
      onBackground: draculaForeground,        // Pure white text

      // Error colors - Enhanced Dracula red
      error: draculaRed,
      onError: Color(0xFF000000),             // Pure black for maximum contrast
      errorContainer: Color(0xFF5A2A2A),     // Enhanced red container
      onErrorContainer: Color(0xFFFFFFFF),   // Pure white for container text

      // Special colors - Enhanced with signature accent
      accent: draculaPurpleSignature,         // Use signature purple as primary accent
      highlight: draculaYellow,
      shadow: Color(0xFF000000),
      outline: draculaComment,
      outlineVariant: Color(0xFF5A5D6A),     // Enhanced outline variant

      // Dracula Purple Signature Colors
      draculaPurple: draculaPurpleSignature,
      onDraculaPurple: onDraculaPurpleSignature,
      draculaPurpleContainer: draculaPurpleContainer,
      onDraculaPurpleContainer: onDraculaPurpleContainer,

      // Task priority colors - Enhanced with signature accent
      taskLowPriority: draculaGreen,          // Enhanced green - Low priority
      taskMediumPriority: draculaCyan,        // Enhanced cyan - Medium priority
      taskHighPriority: draculaPurpleSignature, // Signature purple - High priority
      taskUrgentPriority: draculaRed,         // Enhanced red - Urgent priority

      // Status colors - Enhanced brightness
      success: draculaGreen,
      warning: draculaOrange,
      info: draculaCyan,

      // Calendar dot colors - Dracula IDE theme (dark)
      calendarTodayDot: draculaPink,                  // Enhanced pink for today
      calendarOverdueDot: draculaRed,                 // Enhanced red for overdue
      calendarFutureDot: draculaCyan,                 // Enhanced cyan for future
      calendarCompletedDot: draculaGreen,             // Enhanced green for completed
      calendarHighPriorityDot: draculaPurpleSignature, // Signature purple for high priority
      
      // Status badge colors - Enhanced with signature purple
      statusPendingBadge: draculaCyan,                // Enhanced cyan for pending
      statusInProgressBadge: draculaOrange,           // Enhanced orange for in progress
      statusCompletedBadge: draculaPurpleSignature,   // Signature purple for completed (achievement)
      statusCancelledBadge: draculaComment,           // Enhanced comment color for cancelled
      statusOverdueBadge: draculaRed,                 // Enhanced red for overdue
      statusOnHoldBadge: draculaYellow,               // Enhanced yellow for on hold

      // Interactive colors - Enhanced visibility
      hover: Color(0xFFFF99EE),               // Brighter hover state
      pressed: Color(0xFFFF77DD),             // Enhanced pressed state
      focus: draculaYellow,
      disabled: draculaComment,
    );
  }

  /// Create Dracula-inspired typography using JetBrains Mono
  static ThemeTypography _createDraculaTypography({bool isDark = true}) {
    final colors = _DraculaColorsHelper(isDark: isDark);
    const fontFamily = 'JetBrains Mono';
    
    return ThemeTypography(
      fontFamily: fontFamily,
      displayFontFamily: fontFamily,
      monospaceFontFamily: fontFamily,
      baseSize: TypographyConstants.bodyLarge,
      scaleRatio: 1.0, // No scaling - use exact constants
      baseFontWeight: TypographyConstants.regular,
      baseLetterSpacing: TypographyConstants.normalLetterSpacing, // Consistent spacing
      baseLineHeight: TypographyConstants.normalLineHeight, // Consistent line height
      
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

  /// Create smooth, professional animations
  static ThemeAnimations _createDraculaAnimations() {
    return ThemeAnimations.fromThemeStyle(ThemeAnimationStyle.smooth).copyWith(
      // Silky smooth, luxurious animations
      fast: const Duration(milliseconds: 150),
      medium: const Duration(milliseconds: 300),
      slow: const Duration(milliseconds: 500),
      verySlow: const Duration(milliseconds: 800),
      
      // Elegant, sophisticated curves
      primaryCurve: Curves.easeInOutCubic,
      secondaryCurve: Curves.decelerate,
      entranceCurve: Curves.easeOutBack,
      exitCurve: Curves.easeInQuart,
      
      // Sophisticated floating particles
      enableParticles: true,
      particleConfig: const ParticleConfig(
        density: ParticleDensity.medium,
        speed: ParticleSpeed.medium,
        style: ParticleStyle.organic,
        enableGlow: true,
        opacity: 0.4,
        size: 1.0,
      ),
    );
  }

  /// Create elegant visual effects
  static theme_effects.ThemeEffects _createDraculaEffects() {
    return theme_effects.ThemeEffects.fromEffectStyle(theme_effects.ThemeEffectStyle.elegant).copyWith(
      shadowStyle: theme_effects.ShadowStyle.soft,
      gradientStyle: theme_effects.GradientStyle.subtle,
      borderStyle: theme_effects.BorderStyle.rounded,
      
      blurConfig: const theme_effects.BlurConfig(
        enabled: true,
        intensity: 2.0,
        style: theme_effects.BlurStyle.normal,
      ),
      
      glowConfig: const theme_effects.GlowConfig(
        enabled: true,
        intensity: 0.6,
        spread: 10.0,
        style: theme_effects.GlowStyle.outer,
      ),
      
      backgroundEffects: theme_effects.BackgroundEffectConfig(
        enableParticles: true,
        enableGradientMesh: true,
        enableScanlines: false,
        particleType: theme_effects.BackgroundParticleType.floating,
        particleOpacity: 0.12,
        effectIntensity: 0.5,
        geometricPattern: theme_effects.BackgroundGeometricPattern.mesh, // Elegant sophistication 
        patternAngle: 45.0, // Diagonal elegance
        patternDensity: 1.2, // Refined density
        accentColors: [
          const Color(0xFFE6C1FF).withValues(alpha: 0.12), // Enhanced Dracula Purple signature accent (dark mode)
          const Color(0xFFFF88DD).withValues(alpha: 0.08), // Enhanced pink accent (dark mode)
          const Color(0xFF00FFFF).withValues(alpha: 0.06), // Enhanced cyan accent (dark mode)
        ],
      ),
    );
  }

  /// Create comfortable, developer-friendly spacing
  static app_theme_data.ThemeSpacing _createDraculaSpacing() {
    return app_theme_data.ThemeSpacing.fromBaseUnit(8.0).copyWith(
      cardPadding: 16.0,     // Comfortable padding
      screenPadding: 16.0,   // Standard screen padding
      buttonPadding: 20.0,   // Comfortable button padding
      inputPadding: 14.0,    // Good input padding
    );
  }

  /// Create modern, rounded components
  static app_theme_data.ThemeComponents _createDraculaComponents() {
    return const app_theme_data.ThemeComponents(
      appBar: app_theme_data.AppBarConfig(
        elevation: 0.0,        // Modern flat design
        centerTitle: true,
        toolbarHeight: kToolbarHeight,
      ),
      
      card: app_theme_data.CardConfig(
        elevation: 2.0,        // Subtle elevation
        borderRadius: 5.0,    // Modern rounded corners
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: EdgeInsets.all(16.0),
      ),
      
      button: app_theme_data.ButtonConfig(
        borderRadius: 5.0,     // Rounded corners
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
        elevation: 2.0,        // Subtle elevation
        height: 48.0,          // Comfortable height
        style: app_theme_data.ButtonStyle.filled,
      ),
      
      input: app_theme_data.InputConfig(
        borderRadius: 5.0,     // Rounded corners
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        borderStyle: app_theme_data.InputBorderStyle.outline,
        filled: true,          // Filled input style
      ),
      
      fab: app_theme_data.FABConfig(
        shape: app_theme_data.FABShape.circular, // Classic circular FAB
        elevation: 6.0,           // Standard elevation
        width: null,              // Default size
        height: null,
      ),
      
      navigation: app_theme_data.NavigationConfig(
        type: app_theme_data.NavigationType.bottomNav,
        elevation: 8.0,        // Standard elevation
        showLabels: true,
      ),
      
      taskCard: app_theme_data.TaskCardConfig(
        borderRadius: 5.0,    // Rounded corners
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        padding: EdgeInsets.all(16.0),
        elevation: 1.0,        // Subtle elevation
        showPriorityStripe: true,
        enableSwipeActions: true,
      ),
    );
  }
}

/// Helper class for accessing colors in static context
class _DraculaColorsHelper {
  final bool isDark;
  const _DraculaColorsHelper({this.isDark = true});
  
  Color get onBackground => isDark ? const Color(0xFFf8f8f2) : const Color(0xFF2d2d2d);
  Color get primary => const Color(0xFFff79c6);  // Pink in both variants
  Color get secondary => isDark ? const Color(0xFFbd93f9) : const Color(0xFF9d6fd9);
}


