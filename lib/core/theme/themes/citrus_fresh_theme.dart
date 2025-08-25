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

/// 🍋 Citrus Fresh Theme - "Vitamin Energy Burst"
/// A vibrant, energizing theme inspired by fresh citrus fruits and vitamin vitality
/// Dark Mode: "Citrus Night" - Deep green backgrounds with bright lime, lemon, and orange accents
/// Light Mode: "Sunny Citrus" - Fresh white backgrounds with zesty citrus colors and energy bursts
class CitrusFreshTheme {
  static app_theme_data.AppThemeData create({bool isDark = false}) {
    final now = DateTime.now();
    
    return app_theme_data.AppThemeData(
      metadata: ThemeMetadata(
        id: isDark ? 'citrus_fresh_dark' : 'citrus_fresh_light',
        name: isDark ? 'Citrus Fresh Dark' : 'Citrus Fresh Light',
        description: isDark 
          ? 'Citrus Night theme featuring deep forest green backgrounds, electric lime highlights, bright lemon accents, vibrant orange details, and energizing vitamin particle effects'
          : 'Sunny Citrus theme with fresh white backgrounds, zesty lime greens, bright lemon yellows, vibrant orange accents, and refreshing energy bursts',
        author: 'Tasky Team',
        version: '1.0.0',
        tags: ['citrus', 'fresh', 'energizing', 'vitamin', 'zesty', 'bright', 'vibrant', 'healthy'],
        category: 'colorful',
        previewIcon: PhosphorIcons.orange(),
        primaryPreviewColor: const Color(0xFF32CD32), // Lime green
        secondaryPreviewColor: const Color(0xFFFFFF00), // Lemon yellow
        createdAt: now,
        isPremium: false,
        popularityScore: 8.8, // High energy appeal
      ),
      
      colors: _createCitrusColors(isDark: isDark),
      typography: _createCitrusTypography(isDark: isDark),
      animations: _createCitrusAnimations(),
      effects: _createCitrusEffects(),
      spacing: _createCitrusSpacing(),
      components: _createCitrusComponents(),
    );
  }

  /// Create light variant - Sunny Citrus
  static app_theme_data.AppThemeData createLight() => create(isDark: false);
  
  /// Create dark variant - Citrus Night
  static app_theme_data.AppThemeData createDark() => create(isDark: true);

  /// Create zesty citrus color palette
  static ThemeColors _createCitrusColors({bool isDark = false}) {
    if (isDark) {
      // 🌃 Dark Mode - "Citrus Night": Deep greens with electric citrus accents
      const forestGreen = Color(0xFF0D3B0D);           // Deep forest green background
      const limeGreen = Color(0xFF32CD32);             // Electric lime green
      const lemonYellow = Color(0xFFFFFF00);           // Bright lemon yellow
      const orangeZest = Color(0xFFFF8C00);            // Vibrant orange zest
      const mintWhite = Color(0xFFF5FFFA);             // Fresh mint white
      const darkLeaf = Color(0xFF1B4D1B);              // Dark leaf green
      const citrusGreen = Color(0xFF9AFF9A);           // Light citrus green
      const tangerineOrange = Color(0xFFFF7F50);       // Tangerine orange
      const vitaminC = Color(0xFFFFA500);              // Vitamin C orange
      const leafGreen = Color(0xFF228B22);             // Natural leaf green
      
      return const ThemeColors(
        // Primary colors - Lime Green energy
        primary: limeGreen,
        onPrimary: forestGreen,
        primaryContainer: Color(0xFF2E7D2E),
        onPrimaryContainer: citrusGreen,

        // Secondary colors - Lemon Yellow zest
        secondary: lemonYellow,
        onSecondary: forestGreen,
        secondaryContainer: Color(0xFF808000),
        onSecondaryContainer: Color(0xFFFFFFC0),

        // Tertiary colors - Orange Zest vitality
        tertiary: orangeZest,
        onTertiary: mintWhite,
        tertiaryContainer: Color(0xFF8B4513),
        onTertiaryContainer: Color(0xFFFFDAAA),

        // Surface colors - Fresh leaf materials
        surface: darkLeaf,
        onSurface: mintWhite,
        surfaceVariant: Color(0xFF2D5A2D),
        onSurfaceVariant: citrusGreen,
        inverseSurface: mintWhite,
        onInverseSurface: forestGreen,

        // Background colors - Deep forest freshness
        background: forestGreen,
        onBackground: mintWhite,

        // Error colors - Citrus alert
        error: Color(0xFFFF6B47),
        onError: mintWhite,
        errorContainer: Color(0xFF4D1B1B),
        onErrorContainer: Color(0xFFFFB3A6),

        // Special colors - Citrus essence
        accent: lemonYellow,
        highlight: orangeZest,
        shadow: Color(0xFF000000),
        outline: leafGreen,
        outlineVariant: darkLeaf,

        // Task priority colors - Vitamin energy levels
        taskLowPriority: citrusGreen,            // Low energy - Light citrus
        taskMediumPriority: limeGreen,           // Medium energy - Lime green
        taskHighPriority: lemonYellow,           // High energy - Lemon yellow
        taskUrgentPriority: orangeZest,          // Critical energy - Orange zest

        // Status colors - Fresh vitamin states
        success: limeGreen,
        warning: vitaminC,
        info: Color(0xFF00BFFF),

        // Calendar dot colors - Citrus calendar
        calendarTodayDot: lemonYellow,
        calendarOverdueDot: Color(0xFFFF6B47),
        calendarFutureDot: citrusGreen,
        calendarCompletedDot: limeGreen,
        calendarHighPriorityDot: orangeZest,
        
        // Status badge colors - Vitamin activity states
        statusPendingBadge: citrusGreen,
        statusInProgressBadge: lemonYellow,
        statusCompletedBadge: limeGreen,
        statusCancelledBadge: leafGreen,
        statusOverdueBadge: Color(0xFFFF6B47),
        statusOnHoldBadge: tangerineOrange,

        // Interactive colors - Citrus burst responses
        hover: Color(0x8032CD32),    // limeGreen with 0.5 alpha
        pressed: Color(0xB3FFFF00),  // lemonYellow with 0.7 alpha
        focus: orangeZest,
        disabled: Color(0xFF2A4A2A),
      );
    }
    
    // ☀️ Light Mode - "Sunny Citrus": Fresh whites with vibrant citrus energy
    const citrusWhite = Color(0xFFFFFFF8);           // Fresh citrus white
    const mintCream = Color(0xFFF5FFFA);             // Mint cream surface
    const lightLime = Color(0xFFE6FFE6);             // Light lime background
    const vibrantLime = Color(0xFF32CD32);           // Vibrant lime green
    const sunnyYellow = Color(0xFFFFD700);           // Sunny lemon yellow
    const freshOrange = Color(0xFFFF8C00);           // Fresh orange
    const deepForest = Color(0xFF0D5F0D);            // Deep forest text
    const naturalGreen = Color(0xFF228B22);          // Natural green
    const citrusGray = Color(0xFF90EE90);            // Light citrus gray
    const energyOrange = Color(0xFFFF7F50);          // Energy orange
    
    return const ThemeColors(
      // Primary colors - Vibrant Lime on fresh backgrounds
      primary: vibrantLime,
      onPrimary: citrusWhite,
      primaryContainer: lightLime,
      onPrimaryContainer: deepForest,
      
      // Secondary colors - Sunny Yellow energy
      secondary: sunnyYellow,
      onSecondary: deepForest,
      secondaryContainer: Color(0xFFFFFFC0),
      onSecondaryContainer: Color(0xFF666600),
      
      // Tertiary colors - Fresh Orange vitality
      tertiary: freshOrange,
      onTertiary: citrusWhite,
      tertiaryContainer: Color(0xFFFFE4B5),
      onTertiaryContainer: Color(0xFF8B4513),
      
      // Surface colors - Fresh citrus materials
      surface: mintCream,
      onSurface: deepForest,
      surfaceVariant: lightLime,
      onSurfaceVariant: naturalGreen,
      inverseSurface: deepForest,
      onInverseSurface: citrusWhite,
      
      // Background colors - Fresh sunny brightness
      background: citrusWhite,
      onBackground: deepForest,
      
      // Error colors - Fresh citrus danger
      error: Color(0xFFDC2626),
      onError: citrusWhite,
      errorContainer: Color(0xFFFEF2F2),
      onErrorContainer: Color(0xFF991B1B),
      
      // Special colors - Light citrus essence
      accent: vibrantLime,
      highlight: energyOrange,
      shadow: Color(0xFF000000),
      outline: citrusGray,
      outlineVariant: lightLime,
      
      // Task priority colors - Light vitamin energy
      taskLowPriority: naturalGreen,
      taskMediumPriority: vibrantLime,
      taskHighPriority: sunnyYellow,
      taskUrgentPriority: freshOrange,
      
      // Status colors - Light fresh states
      success: vibrantLime,
      warning: Color(0xFFF59E0B),
      info: Color(0xFF3B82F6),
      
      // Calendar dot colors - Light citrus calendar
      calendarTodayDot: sunnyYellow,
      calendarOverdueDot: Color(0xFFDC2626),
      calendarFutureDot: naturalGreen,
      calendarCompletedDot: vibrantLime,
      calendarHighPriorityDot: freshOrange,
      
      // Status badge colors - Light vitamin activity
      statusPendingBadge: naturalGreen,
      statusInProgressBadge: sunnyYellow,
      statusCompletedBadge: vibrantLime,
      statusCancelledBadge: citrusGray,
      statusOverdueBadge: Color(0xFFDC2626),
      statusOnHoldBadge: energyOrange,
      
      // Interactive colors - Light citrus responses
      hover: Color(0x4032CD32),    // vibrantLime with 0.25 alpha
      pressed: Color(0x80FFD700),  // sunnyYellow with 0.5 alpha
      focus: freshOrange,
      disabled: citrusGray,
    );
  }

  /// Create energizing citrus typography using Quicksand font
  static ThemeTypography _createCitrusTypography({bool isDark = false}) {
    final colors = _CitrusColorsHelper(isDark: isDark);
    const fontFamily = 'Quicksand';
    
    return ThemeTypography(
      fontFamily: fontFamily,
      displayFontFamily: fontFamily,
      monospaceFontFamily: fontFamily,
      baseSize: TypographyConstants.bodyLarge,
      scaleRatio: 1.0,
      baseFontWeight: FontWeight.w500, // Medium weight for energetic feel
      baseLetterSpacing: TypographyConstants.normalLetterSpacing * 0.9, // Slightly tighter for energy
      baseLineHeight: TypographyConstants.normalLineHeight, // Standard for readability
      
      // Display styles - Energizing citrus titles
      displayLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.displayLarge,
        fontWeight: FontWeight.w600, // SemiBold for energy
        letterSpacing: TypographyConstants.normalLetterSpacing * 0.8,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      displayMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.displayMedium,
        fontWeight: FontWeight.w600,
        letterSpacing: TypographyConstants.normalLetterSpacing * 0.8,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      displaySmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.displaySmall,
        fontWeight: FontWeight.w500,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      
      // Headline styles - Zesty headers
      headlineLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.headlineLarge,
        fontWeight: FontWeight.w500,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      headlineMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.headlineMedium,
        fontWeight: FontWeight.w500,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      headlineSmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.headlineSmall,
        fontWeight: FontWeight.w500,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      
      // Title styles - Fresh vitality
      titleLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleLarge,
        fontWeight: FontWeight.w500,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      titleMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleMedium,
        fontWeight: FontWeight.w500,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      titleSmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleSmall,
        fontWeight: FontWeight.w500,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      
      // Body styles - Vitamin energy
      bodyLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodyLarge,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      bodyMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodyMedium,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      bodySmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodySmall,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      
      // Label styles - Citrus labels
      labelLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelLarge,
        fontWeight: FontWeight.w600, // SemiBold for energy
        letterSpacing: TypographyConstants.wideLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      labelMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelMedium,
        fontWeight: FontWeight.w600,
        letterSpacing: TypographyConstants.wideLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      labelSmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelSmall,
        fontWeight: FontWeight.w500,
        letterSpacing: TypographyConstants.wideLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      
      // Custom app styles - Citrus fresh precision
      taskTitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.taskTitle,
        fontWeight: FontWeight.w500,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      taskDescription: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.taskDescription,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      taskMeta: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.taskMeta,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      cardTitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleSmall,
        fontWeight: FontWeight.w500,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      cardSubtitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodySmall,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      buttonText: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.buttonText,
        fontWeight: FontWeight.w600,
        letterSpacing: TypographyConstants.wideLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      inputText: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.inputText,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      appBarTitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.appBarTitle,
        fontWeight: FontWeight.w500,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      navigationLabel: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.navigationLabel,
        fontWeight: FontWeight.w500,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
    );
  }

  /// Create energizing citrus animations with juice burst effects
  static ThemeAnimations _createCitrusAnimations() {
    return ThemeAnimations.fromThemeStyle(ThemeAnimationStyle.sharp).copyWith(
      // Fast, energetic citrus timing
      fast: const Duration(milliseconds: 150),
      medium: const Duration(milliseconds: 300),
      slow: const Duration(milliseconds: 450),
      verySlow: const Duration(milliseconds: 700),
      
      // Bouncy, energetic curves like citrus bubbles
      primaryCurve: Curves.bounceOut,           // Energetic citrus bounce
      secondaryCurve: Curves.elasticOut,        // Zesty elasticity
      entranceCurve: Curves.easeOutBack,        // Citrus burst entrance
      exitCurve: Curves.easeInQuart,            // Quick citrus exit
      
      // Vitamin bubble particle system
      enableParticles: true,
      particleConfig: const ParticleConfig(
        density: ParticleDensity.high,           // Dense vitamin bubbles
        speed: ParticleSpeed.fast,               // Fast-moving energy
        style: ParticleStyle.organic,            // Organic citrus shapes
        enableGlow: true,                        // Vitamin energy glow
        opacity: 0.9,                            // Bright citrus visibility
        size: 1.1,                               // Larger energy bubbles
      ),
    );
  }

  /// Create energizing citrus visual effects
  static theme_effects.ThemeEffects _createCitrusEffects() {
    return theme_effects.ThemeEffects.fromEffectStyle(theme_effects.ThemeEffectStyle.dramatic).copyWith(
      shadowStyle: theme_effects.ShadowStyle.soft,         // Soft citrus shadows
      gradientStyle: theme_effects.GradientStyle.subtle,   // Subtle citrus gradients
      borderStyle: theme_effects.BorderStyle.rounded,      // Organic citrus shapes
      
      blurConfig: const theme_effects.BlurConfig(
        enabled: true,
        intensity: 1.2,                          // Light citrus energy blur
        style: theme_effects.BlurStyle.normal,
      ),
      
      glowConfig: const theme_effects.GlowConfig(
        enabled: true,
        intensity: 0.8,                          // Strong vitamin glow
        spread: 6.0,                             // Moderate citrus glow radius
        style: theme_effects.GlowStyle.outer,
      ),
      
      backgroundEffects: const theme_effects.BackgroundEffectConfig(
        enableParticles: true,                   // Floating vitamin particles
        enableGradientMesh: true,                // Citrus gradient mesh
        enableScanlines: false,                  // No digital elements
        particleType: theme_effects.BackgroundParticleType.energy, // Energy bubbles
        particleOpacity: 0.7,                    // Bright vitamin visibility
        effectIntensity: 0.9,                    // High energy citrus effects
      ),
    );
  }

  /// Create energizing citrus spacing with vitamin proportions
  static app_theme_data.ThemeSpacing _createCitrusSpacing() {
    const citrusRatio = 1.25; // 5:4 ratio for energetic proportions
    const baseUnit = 8.0;
    
    return app_theme_data.ThemeSpacing.fromBaseUnit(baseUnit).copyWith(
      cardPadding: baseUnit * citrusRatio * 1.8,     // ~18.0 → Energetic card padding
      screenPadding: baseUnit * citrusRatio * 2.0,   // ~20.0 → Fresh screen margins
      buttonPadding: baseUnit * citrusRatio * 1.5,   // ~15.0 → Zesty button padding
      inputPadding: baseUnit * citrusRatio * 1.2,    // ~12.0 → Vitamin input padding
    );
  }

  /// Create energizing citrus components with fresh aesthetics
  static app_theme_data.ThemeComponents _createCitrusComponents() {
    return const app_theme_data.ThemeComponents(
      appBar: app_theme_data.AppBarConfig(
        elevation: 2.0,                          // Fresh elevation
        centerTitle: true,                       // Centered fresh balance
        toolbarHeight: kToolbarHeight,
      ),
      
      card: app_theme_data.CardConfig(
        elevation: 2.5,                          // Energetic card elevation
        borderRadius: 14.0,                      // Fresh citrus curves
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: EdgeInsets.all(18.0),          // Fresh vitamin padding
      ),
      
      button: app_theme_data.ButtonConfig(
        borderRadius: 12.0,                      // Energetic citrus curves
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        elevation: 2.5,                          // Fresh button elevation
        height: 50.0,                            // Standard energetic height
        style: app_theme_data.ButtonStyle.filled,
      ),
      
      input: app_theme_data.InputConfig(
        borderRadius: 10.0,                      // Fresh citrus input
        contentPadding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
        borderStyle: app_theme_data.InputBorderStyle.outline,
        filled: true,
      ),
      
      fab: app_theme_data.FABConfig(
        shape: app_theme_data.FABShape.circular, // Perfect citrus orb
        elevation: 4.0,                          // Energetic floating
        width: null,
        height: null,
      ),
      
      navigation: app_theme_data.NavigationConfig(
        type: app_theme_data.NavigationType.bottomNav,
        elevation: 6.0,                          // Fresh navigation elevation
        showLabels: true,
      ),
      
      taskCard: app_theme_data.TaskCardConfig(
        borderRadius: 12.0,                      // Fresh citrus task curves
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        padding: EdgeInsets.all(16.0),          // Energetic citrus space
        elevation: 1.5,                          // Light citrus float
        showPriorityStripe: true,                // Vitamin energy indicators
        enableSwipeActions: true,                // Fast citrus interactions
      ),
    );
  }
}

/// Helper class for accessing citrus colors in static context
class _CitrusColorsHelper {
  final bool isDark;
  const _CitrusColorsHelper({this.isDark = false});
  
  Color get onBackground => isDark 
    ? const Color(0xFFF5FFFA)   // Mint white
    : const Color(0xFF0D5F0D);  // Deep forest
    
  Color get primary => isDark 
    ? const Color(0xFF32CD32)   // Lime green
    : const Color(0xFF32CD32);  // Lime green (consistent)
    
  Color get citrusYellow => const Color(0xFFFFFF00); // Lemon yellow in both modes
}