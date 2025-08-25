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

/// 🦇 Vampire Gothic Theme - "Eternal Aristocracy"
/// An elegant gothic theme inspired by classical vampire aristocracy and Victorian grandeur
/// Dark Mode: "Midnight Manor" - Deep midnight black with blood crimson accents and antique gold details
/// Light Mode: "Victorian Court" - Ivory whites with gothic accents and aristocratic elegance
class VampireGothicTheme {
  static app_theme_data.AppThemeData create({bool isDark = true}) {
    final now = DateTime.now();
    
    return app_theme_data.AppThemeData(
      metadata: ThemeMetadata(
        id: isDark ? 'vampire_gothic_dark' : 'vampire_gothic_light',
        name: isDark ? 'Vampire Gothic Dark' : 'Vampire Gothic Light',
        description: isDark 
          ? 'Midnight Manor theme featuring deep midnight black backgrounds, blood crimson accents, ivory white highlights, antique gold details, and aristocratic gothic particle effects'
          : 'Victorian Court theme with ivory white backgrounds, gothic crimson accents, elegant shadows, and refined aristocratic aesthetics for daylight nobility',
        author: 'Tasky Team',
        version: '1.0.0',
        tags: ['gothic', 'vampire', 'aristocratic', 'elegant', 'victorian', 'dark', 'blood', 'classical'],
        category: 'dark',
        previewIcon: PhosphorIcons.crown(),
        primaryPreviewColor: const Color(0xFF8B0000), // Blood crimson
        secondaryPreviewColor: const Color(0xFF000000), // Midnight black
        createdAt: now,
        isPremium: false,
        popularityScore: 9.1, // Classic gothic appeal
      ),
      
      colors: _createGothicColors(isDark: isDark),
      typography: _createGothicTypography(isDark: isDark),
      animations: _createGothicAnimations(),
      effects: _createGothicEffects(),
      spacing: _createGothicSpacing(),
      components: _createGothicComponents(),
    );
  }

  /// Create light variant - Victorian Court
  static app_theme_data.AppThemeData createLight() => create(isDark: false);
  
  /// Create dark variant - Midnight Manor
  static app_theme_data.AppThemeData createDark() => create(isDark: true);

  /// Create elegant gothic color palette
  static ThemeColors _createGothicColors({bool isDark = true}) {
    if (isDark) {
      // 🌑 Dark Mode - "Midnight Manor": Aristocratic darkness with blood accents
      const midnightBlack = Color(0xFF000000);        // Pure midnight black
      const bloodCrimson = Color(0xFF8B0000);         // Deep blood crimson
      const ivoryWhite = Color(0xFFFFFFF0);           // Elegant ivory white
      const antiqueGold = Color(0xFFCFB53B);          // Rich antique gold
      const deepCharcoal = Color(0xFF1C1C1C);         // Deep charcoal for depth
      const velvetRed = Color(0xFF800020);            // Rich velvet red
      const parchmentCream = Color(0xFFF5F5DC);       // Aged parchment cream
      const gothicPurple = Color(0xFF4B0082);         // Deep gothic purple
      const silverMist = Color(0xFFC0C0C0);           // Elegant silver mist
      const darkWine = Color(0xFF722F37);             // Dark wine burgundy
      
      return const ThemeColors(
        // Primary colors - Blood Crimson nobility
        primary: bloodCrimson,
        onPrimary: ivoryWhite,
        primaryContainer: darkWine,
        onPrimaryContainer: parchmentCream,

        // Secondary colors - Antique Gold elegance
        secondary: antiqueGold,
        onSecondary: midnightBlack,
        secondaryContainer: Color(0xFF8B7500),
        onSecondaryContainer: Color(0xFFFFF8DC),

        // Tertiary colors - Gothic Purple mystery
        tertiary: gothicPurple,
        onTertiary: ivoryWhite,
        tertiaryContainer: Color(0xFF301934),
        onTertiaryContainer: Color(0xFFDDA0DD),

        // Surface colors - Gothic manor materials
        surface: deepCharcoal,
        onSurface: ivoryWhite,
        surfaceVariant: Color(0xFF2A2A2A),
        onSurfaceVariant: silverMist,
        inverseSurface: ivoryWhite,
        onInverseSurface: midnightBlack,

        // Background colors - Midnight manor depths
        background: midnightBlack,
        onBackground: ivoryWhite,

        // Error colors - Dangerous blood magic
        error: Color(0xFFDC143C),
        onError: ivoryWhite,
        errorContainer: Color(0xFF330A0A),
        onErrorContainer: Color(0xFFFF6B6B),

        // Special colors - Gothic essence
        accent: bloodCrimson,
        highlight: antiqueGold,
        shadow: midnightBlack,
        outline: Color(0xFF444444),
        outlineVariant: deepCharcoal,

        // Task priority colors - Aristocratic hierarchy
        taskLowPriority: Color(0xFF9ACD32),      // Noble green
        taskMediumPriority: antiqueGold,         // Gold nobility
        taskHighPriority: bloodCrimson,          // Blood importance
        taskUrgentPriority: Color(0xFFDC143C),   // Crimson danger

        // Status colors - Gothic manor states
        success: Color(0xFF228B22),
        warning: antiqueGold,
        info: silverMist,

        // Calendar dot colors - Gothic calendar
        calendarTodayDot: bloodCrimson,
        calendarOverdueDot: Color(0xFFDC143C),
        calendarFutureDot: antiqueGold,
        calendarCompletedDot: Color(0xFF228B22),
        calendarHighPriorityDot: velvetRed,
        
        // Status badge colors - Manor activity states
        statusPendingBadge: silverMist,
        statusInProgressBadge: bloodCrimson,
        statusCompletedBadge: Color(0xFF228B22),
        statusCancelledBadge: Color(0xFF444444),
        statusOverdueBadge: Color(0xFFDC143C),
        statusOnHoldBadge: gothicPurple,

        // Interactive colors - Gothic manor responses
        hover: Color(0x808B0000),    // bloodCrimson with 0.5 alpha
        pressed: Color(0xB3CFB53B),  // antiqueGold with 0.7 alpha
        focus: antiqueGold,
        disabled: Color(0xFF2A2A2A),
      );
    }
    
    // ☀️ Light Mode - "Victorian Court": Elegant ivory with gothic accents
    const ivoryWhite = Color(0xFFFFFFF0);           // Pure ivory background
    const parchmentCream = Color(0xFFF5F5DC);       // Parchment cream surface
    const warmBeige = Color(0xFFE6E6E6);            // Warm beige
    const darkCrimson = Color(0xFF8B0000);          // Dark crimson (consistent)
    const richGold = Color(0xFFB8860B);             // Rich dark gold
    const deepPurple = Color(0xFF4B0082);           // Deep purple (consistent)
    const charcoalText = Color(0xFF2F2F2F);         // Charcoal text
    const elegantSilver = Color(0xFF999999);        // Elegant silver
    const vintageBrown = Color(0xFF8B4513);         // Vintage brown
    const regalBlue = Color(0xFF191970);            // Regal midnight blue
    
    return const ThemeColors(
      // Primary colors - Dark Crimson elegance
      primary: darkCrimson,
      onPrimary: ivoryWhite,
      primaryContainer: parchmentCream,
      onPrimaryContainer: Color(0xFF660000),
      
      // Secondary colors - Rich Gold nobility  
      secondary: richGold,
      onSecondary: ivoryWhite,
      secondaryContainer: Color(0xFFFFF8DC),
      onSecondaryContainer: Color(0xFF664400),
      
      // Tertiary colors - Deep Purple mystery
      tertiary: deepPurple,
      onTertiary: ivoryWhite,
      tertiaryContainer: Color(0xFFE6E6FA),
      onTertiaryContainer: Color(0xFF2D1B42),
      
      // Surface colors - Victorian court materials
      surface: parchmentCream,
      onSurface: charcoalText,
      surfaceVariant: warmBeige,
      onSurfaceVariant: Color(0xFF5A5A5A),
      inverseSurface: charcoalText,
      onInverseSurface: ivoryWhite,
      
      // Background colors - Ivory elegance
      background: ivoryWhite,
      onBackground: charcoalText,
      
      // Error colors - Victorian danger
      error: Color(0xFFDC2626),
      onError: ivoryWhite,
      errorContainer: Color(0xFFFEF2F2),
      onErrorContainer: Color(0xFF991B1B),
      
      // Special colors - Light gothic essence
      accent: darkCrimson,
      highlight: richGold,
      shadow: Color(0xFF000000),
      outline: elegantSilver,
      outlineVariant: warmBeige,
      
      // Task priority colors - Light aristocratic hierarchy
      taskLowPriority: Color(0xFF22C55E),
      taskMediumPriority: richGold,
      taskHighPriority: darkCrimson,
      taskUrgentPriority: Color(0xFFDC2626),
      
      // Status colors - Light gothic states
      success: Color(0xFF22C55E),
      warning: Color(0xFFF59E0B),
      info: regalBlue,
      
      // Calendar dot colors - Light gothic calendar
      calendarTodayDot: darkCrimson,
      calendarOverdueDot: Color(0xFFDC2626),
      calendarFutureDot: richGold,
      calendarCompletedDot: Color(0xFF22C55E),
      calendarHighPriorityDot: deepPurple,
      
      // Status badge colors - Light court activity
      statusPendingBadge: elegantSilver,
      statusInProgressBadge: darkCrimson,
      statusCompletedBadge: Color(0xFF22C55E),
      statusCancelledBadge: warmBeige,
      statusOverdueBadge: Color(0xFFDC2626),
      statusOnHoldBadge: deepPurple,
      
      // Interactive colors - Light gothic responses
      hover: Color(0x408B0000),    // darkCrimson with 0.25 alpha
      pressed: Color(0x80B8860B),  // richGold with 0.5 alpha
      focus: richGold,
      disabled: warmBeige,
    );
  }

  /// Create aristocratic gothic typography using Cinzel font
  static ThemeTypography _createGothicTypography({bool isDark = true}) {
    final colors = _GothicColorsHelper(isDark: isDark);
    const fontFamily = 'Cinzel';
    
    return ThemeTypography(
      fontFamily: fontFamily,
      displayFontFamily: fontFamily,
      monospaceFontFamily: fontFamily,
      baseSize: TypographyConstants.bodyLarge,
      scaleRatio: 1.0,
      baseFontWeight: FontWeight.w400, // Elegant regular weight
      baseLetterSpacing: TypographyConstants.wideLetterSpacing * 0.9, // Slightly wider for elegance
      baseLineHeight: TypographyConstants.relaxedLineHeight, // More space for aristocratic feel
      
      // Display styles - Aristocratic titles
      displayLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.displayLarge,
        fontWeight: FontWeight.w600, // SemiBold for aristocratic presence
        letterSpacing: TypographyConstants.wideLetterSpacing * 0.7,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      displayMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.displayMedium,
        fontWeight: FontWeight.w600,
        letterSpacing: TypographyConstants.wideLetterSpacing * 0.7,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      displaySmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.displaySmall,
        fontWeight: FontWeight.w500,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      
      // Headline styles - Gothic grandeur
      headlineLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.headlineLarge,
        fontWeight: FontWeight.w500,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      headlineMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.headlineMedium,
        fontWeight: FontWeight.w500,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      headlineSmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.headlineSmall,
        fontWeight: FontWeight.w500,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      
      // Title styles - Noble refinement
      titleLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleLarge,
        fontWeight: FontWeight.w500,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      titleMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleMedium,
        fontWeight: FontWeight.w500,
        letterSpacing: TypographyConstants.normalLetterSpacing * 1.1,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      titleSmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleSmall,
        fontWeight: FontWeight.w500,
        letterSpacing: TypographyConstants.normalLetterSpacing * 1.1,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      
      // Body styles - Elegant prose
      bodyLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodyLarge,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      bodyMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodyMedium,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      bodySmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodySmall,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      
      // Label styles - Aristocratic labels
      labelLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelLarge,
        fontWeight: FontWeight.w600, // SemiBold for noble labels
        letterSpacing: TypographyConstants.wideLetterSpacing * 1.2,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      labelMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelMedium,
        fontWeight: FontWeight.w600,
        letterSpacing: TypographyConstants.wideLetterSpacing * 1.2,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      labelSmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelSmall,
        fontWeight: FontWeight.w500,
        letterSpacing: TypographyConstants.wideLetterSpacing * 1.2,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      
      // Custom app styles - Gothic manor precision
      taskTitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.taskTitle,
        fontWeight: FontWeight.w500,
        letterSpacing: TypographyConstants.normalLetterSpacing * 1.1,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      taskDescription: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.taskDescription,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      taskMeta: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.taskMeta,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      cardTitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleSmall,
        fontWeight: FontWeight.w500,
        letterSpacing: TypographyConstants.normalLetterSpacing * 1.1,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      cardSubtitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodySmall,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      buttonText: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.buttonText,
        fontWeight: FontWeight.w600,
        letterSpacing: TypographyConstants.wideLetterSpacing * 1.2,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      inputText: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.inputText,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      appBarTitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.appBarTitle,
        fontWeight: FontWeight.w500,
        letterSpacing: TypographyConstants.normalLetterSpacing * 1.1,
        height: TypographyConstants.relaxedLineHeight,
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

  /// Create elegant gothic animations with aristocratic particle effects
  static ThemeAnimations _createGothicAnimations() {
    return ThemeAnimations.fromThemeStyle(ThemeAnimationStyle.smooth).copyWith(
      // Stately, aristocratic timing
      fast: const Duration(milliseconds: 250),
      medium: const Duration(milliseconds: 500),
      slow: const Duration(milliseconds: 750),
      verySlow: const Duration(milliseconds: 1200),
      
      // Elegant, noble curves
      primaryCurve: Curves.easeInOutCubic,      // Smooth aristocratic curves
      secondaryCurve: Curves.easeOutQuart,      // Elegant deceleration
      entranceCurve: Curves.easeOutCubic,       // Noble entrance
      exitCurve: Curves.easeInCubic,            // Graceful exit
      
      // Gothic mist particle system
      enableParticles: true,
      particleConfig: const ParticleConfig(
        density: ParticleDensity.low,            // Sparse aristocratic mist
        speed: ParticleSpeed.verySlow,           // Slowly drifting elegance
        style: ParticleStyle.organic,            // Organic gothic shapes
        enableGlow: true,                        // Mystical gothic glow
        opacity: 0.3,                            // Subtle aristocratic presence
        size: 1.1,                               // Larger aristocratic particles
      ),
    );
  }

  /// Create aristocratic gothic visual effects
  static theme_effects.ThemeEffects _createGothicEffects() {
    return theme_effects.ThemeEffects.fromEffectStyle(theme_effects.ThemeEffectStyle.elegant).copyWith(
      shadowStyle: theme_effects.ShadowStyle.dramatic,    // Dramatic gothic shadows
      gradientStyle: theme_effects.GradientStyle.metallic, // Rich metallic gradients
      borderStyle: theme_effects.BorderStyle.rounded,     // Elegant rounded edges
      
      blurConfig: const theme_effects.BlurConfig(
        enabled: true,
        intensity: 1.5,                          // Soft aristocratic blur
        style: theme_effects.BlurStyle.normal,
      ),
      
      glowConfig: const theme_effects.GlowConfig(
        enabled: true,
        intensity: 0.4,                          // Subtle noble glow
        spread: 10.0,                            // Wide aristocratic glow
        style: theme_effects.GlowStyle.outer,
      ),
      
      backgroundEffects: const theme_effects.BackgroundEffectConfig(
        enableParticles: true,                   // Gothic mist particles
        enableGradientMesh: true,                // Rich gothic gradients
        enableScanlines: false,                  // No modern elements
        particleType: theme_effects.BackgroundParticleType.floating, // Floating mist
        particleOpacity: 0.2,                    // Subtle gothic atmosphere
        effectIntensity: 0.5,                    // Moderate aristocratic effects
      ),
    );
  }

  /// Create aristocratic spacing with noble proportions
  static app_theme_data.ThemeSpacing _createGothicSpacing() {
    const gothicRatio = 1.414; // √2 ratio for classical proportions
    const baseUnit = 10.0; // Larger base unit for aristocratic feel
    
    return app_theme_data.ThemeSpacing.fromBaseUnit(baseUnit).copyWith(
      cardPadding: baseUnit * gothicRatio * 1.6,     // ~22.6 → Noble card padding
      screenPadding: baseUnit * gothicRatio * 2.0,   // ~28.3 → Aristocratic margins
      buttonPadding: baseUnit * gothicRatio * 1.3,   // ~18.4 → Elegant button padding
      inputPadding: baseUnit * gothicRatio * 1.1,    // ~15.6 → Refined input padding
    );
  }

  /// Create aristocratic gothic components
  static app_theme_data.ThemeComponents _createGothicComponents() {
    return const app_theme_data.ThemeComponents(
      appBar: app_theme_data.AppBarConfig(
        elevation: 4.0,                          // Noble elevation
        centerTitle: true,                       // Centered aristocratic balance
        toolbarHeight: kToolbarHeight,
      ),
      
      card: app_theme_data.CardConfig(
        elevation: 3.0,                          // Aristocratic card elevation
        borderRadius: 18.0,                      // Noble rounded corners
        margin: EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
        padding: EdgeInsets.all(24.0),          // Generous aristocratic padding
      ),
      
      button: app_theme_data.ButtonConfig(
        borderRadius: 16.0,                      // Elegant button curves
        padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 18.0),
        elevation: 3.0,                          // Noble button elevation
        height: 56.0,                            // Aristocratic button height
        style: app_theme_data.ButtonStyle.filled,
      ),
      
      input: app_theme_data.InputConfig(
        borderRadius: 14.0,                      // Refined input curves
        contentPadding: EdgeInsets.symmetric(horizontal: 22.0, vertical: 18.0),
        borderStyle: app_theme_data.InputBorderStyle.outline,
        filled: true,
      ),
      
      fab: app_theme_data.FABConfig(
        shape: app_theme_data.FABShape.circular, // Perfect aristocratic orb
        elevation: 6.0,                          // High noble elevation
        width: null,
        height: null,
      ),
      
      navigation: app_theme_data.NavigationConfig(
        type: app_theme_data.NavigationType.bottomNav,
        elevation: 8.0,                          // Noble navigation elevation
        showLabels: true,
      ),
      
      taskCard: app_theme_data.TaskCardConfig(
        borderRadius: 16.0,                      // Aristocratic task curves
        margin: EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
        padding: EdgeInsets.all(22.0),          // Noble task padding
        elevation: 2.0,                          // Gentle aristocratic float
        showPriorityStripe: true,                // Noble priority indicators
        enableSwipeActions: true,                // Elegant gothic interactions
      ),
    );
  }
}

/// Helper class for accessing gothic colors in static context
class _GothicColorsHelper {
  final bool isDark;
  const _GothicColorsHelper({this.isDark = true});
  
  Color get onBackground => isDark 
    ? const Color(0xFFFFFFF0)   // Ivory white
    : const Color(0xFF2F2F2F);  // Charcoal text
    
  Color get primary => isDark 
    ? const Color(0xFF8B0000)   // Blood crimson
    : const Color(0xFF8B0000);  // Blood crimson (consistent)
    
  Color get antiqueGold => isDark 
    ? const Color(0xFFCFB53B)   // Rich antique gold
    : const Color(0xFFB8860B);  // Darker rich gold
}