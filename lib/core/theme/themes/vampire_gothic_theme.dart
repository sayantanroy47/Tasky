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
        primaryPreviewColor: isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF), // Pure midnight black or white
        secondaryPreviewColor: isDark ? const Color(0xFFBB1144) : const Color(0xFF770000), // Enhanced blood crimson (mode-specific)
        tertiaryPreviewColor: isDark ? const Color(0xFFFF4466) : const Color(0xFF990022), // Vampire Blood signature accent
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
      // 🌑 Dark Mode - "Midnight Manor": Super bright, maximum saturation gothic elegance
      const midnightBlack = Color(0xFF000000);        // Pure midnight black (already perfect)
      const bloodCrimson = Color(0xFFBB1144);         // Enhanced blood crimson (brighter)
      const ivoryWhite = Color(0xFFFFFFFF);           // Pure white for maximum readability
      const antiqueGold = Color(0xFFFFDD55);          // Enhanced antique gold (brighter)
      const deepCharcoal = Color(0xFF0A0A0A);         // Ultra-deep charcoal for stronger contrast
      // const velvetRed = Color(0xFFAA3355);            // Enhanced velvet red (reserved for future use)
      // const parchmentCream = Color(0xFFFFF8DC);       // Enhanced parchment cream (reserved for future use)
      const gothicPurple = Color(0xFF7744BB);         // Enhanced gothic purple (brighter)
      const silverMist = Color(0xFFDDDDDD);           // Enhanced silver mist (brighter)
      const darkWine = Color(0xFF993366);             // Enhanced dark wine (brighter)
      
      // Vampire Blood Signature Accent - Maximum visibility blood red
      const vampireBloodSignature = Color(0xFFFF4466);       // Super bright signature blood red
      const onVampireBloodSignature = Color(0xFF000000);     // Pure black for maximum contrast
      const vampireBloodContainer = Color(0xFF551122);       // Deep blood container
      const onVampireBloodContainer = Color(0xFFFFFFFF);     // Pure white for container text
      
      return const ThemeColors(
        // Primary colors - Enhanced Blood Crimson nobility
        primary: bloodCrimson,
        onPrimary: Color(0xFF000000),           // Pure black for maximum contrast
        primaryContainer: darkWine,
        onPrimaryContainer: Color(0xFFFFFFFF),  // Pure white for container text

        // Secondary colors - Enhanced Antique Gold elegance
        secondary: antiqueGold,
        onSecondary: Color(0xFF000000),         // Pure black for maximum contrast
        secondaryContainer: Color(0xFFBB8800),  // Enhanced gold container
        onSecondaryContainer: Color(0xFFFFFFFF), // Pure white for container text

        // Tertiary colors - Enhanced Gothic Purple mystery
        tertiary: gothicPurple,
        onTertiary: Color(0xFF000000),          // Pure black for maximum contrast
        tertiaryContainer: Color(0xFF442255),   // Enhanced purple container
        onTertiaryContainer: Color(0xFFFFFFFF), // Pure white for container text

        // Surface colors - Enhanced gothic manor materials
        surface: deepCharcoal,
        onSurface: ivoryWhite,                  // Pure white text
        surfaceVariant: Color(0xFF1A1A1A),     // Enhanced surface variant
        onSurfaceVariant: silverMist,          // Enhanced silver text
        inverseSurface: ivoryWhite,
        onInverseSurface: midnightBlack,

        // Background colors - Enhanced midnight manor depths
        background: midnightBlack,
        onBackground: ivoryWhite,               // Pure white text

        // Error colors - Enhanced dangerous blood magic
        error: Color(0xFFFF5555),              // Enhanced error red
        onError: Color(0xFF000000),            // Pure black for maximum contrast
        errorContainer: Color(0xFF440A0A),     // Enhanced red container
        onErrorContainer: Color(0xFFFFFFFF),   // Pure white for container text

        // Special colors - Enhanced with signature accent
        accent: vampireBloodSignature,          // Use signature blood red as primary accent
        highlight: antiqueGold,
        shadow: midnightBlack,
        outline: Color(0xFF555555),             // Enhanced outline
        outlineVariant: deepCharcoal,

        // Vampire Blood Signature Colors
        vampireBlood: vampireBloodSignature,
        onVampireBlood: onVampireBloodSignature,
        vampireBloodContainer: vampireBloodContainer,
        onVampireBloodContainer: onVampireBloodContainer,

        // Task priority colors - Enhanced aristocratic hierarchy with signature
        taskLowPriority: Color(0xAABBDD55),            // Enhanced noble green
        taskMediumPriority: antiqueGold,               // Enhanced gold nobility
        taskHighPriority: vampireBloodSignature,       // Signature blood red - High priority
        taskUrgentPriority: Color(0xFFFF5555),         // Enhanced crimson danger

        // Status colors - Enhanced gothic manor states
        success: Color(0xFF44BB44),             // Enhanced success green
        warning: antiqueGold,
        info: silverMist,

        // Calendar dot colors - Enhanced gothic calendar
        calendarTodayDot: bloodCrimson,
        calendarOverdueDot: Color(0xFFFF5555),
        calendarFutureDot: antiqueGold,
        calendarCompletedDot: Color(0xFF44BB44),
        calendarHighPriorityDot: vampireBloodSignature, // Signature blood red for high priority
        
        // Status badge colors - Enhanced with signature blood red
        statusPendingBadge: silverMist,
        statusInProgressBadge: bloodCrimson,
        statusCompletedBadge: vampireBloodSignature,    // Signature blood red for completed (achievement)
        statusCancelledBadge: Color(0xFF555555),
        statusOverdueBadge: Color(0xFFFF5555),
        statusOnHoldBadge: gothicPurple,

        // Interactive colors - Enhanced gothic manor responses
        hover: Color(0x99BB1144),               // Enhanced blood crimson hover
        pressed: Color(0xCCFFDD55),             // Enhanced antique gold pressed
        focus: vampireBloodSignature,           // Use signature blood red for focus
        disabled: Color(0xFF333333),            // Enhanced disabled
      );
    }
    
    // ☀️ Light Mode - "Victorian Court": Deep contrasting colors for maximum readability
    const ivoryWhite = Color(0xFFFFFFFF);           // Pure white background
    const parchmentCream = Color(0xFFF8F8F8);       // Light cream surface
    const warmBeige = Color(0xFFE0E0E0);            // Deeper warm beige
    const deepCrimson = Color(0xFF770000);          // Deeper dark crimson for better contrast
    const deepGold = Color(0xFF996600);             // Deeper rich gold
    const deepPurple = Color(0xFF330055);           // Deeper purple for better contrast
    const deepCharcoalText = Color(0xFF1A1A1A);     // Deep charcoal text for maximum readability
    const deepSilver = Color(0xFF666666);           // Deeper elegant silver
    const deepBrown = Color(0xFF663311);            // Deeper vintage brown
    const deepRegalBlue = Color(0xFF001144);        // Deeper regal midnight blue
    
    // Vampire Blood Signature Accent - Deep for light mode contrast
    const deepVampireBloodSignature = Color(0xFF990022);       // Deep signature blood red
    const onDeepVampireBloodSignature = Color(0xFFFFFFFF);     // White text on deep blood red
    const deepVampireBloodContainer = Color(0xFFFFE5E5);       // Light blood container
    const onDeepVampireBloodContainer = Color(0xFF440011);     // Deep blood container text
    
    return const ThemeColors(
      // Primary colors - Enhanced Deep Crimson elegance
      primary: deepCrimson,
      onPrimary: ivoryWhite,
      primaryContainer: parchmentCream,
      onPrimaryContainer: Color(0xFF440000),  // Deeper container text
      
      // Secondary colors - Enhanced Deep Gold nobility  
      secondary: deepGold,
      onSecondary: ivoryWhite,
      secondaryContainer: Color(0xFFFFF0CD),
      onSecondaryContainer: deepBrown,        // Enhanced brown
      
      // Tertiary colors - Enhanced Deep Purple mystery
      tertiary: deepPurple,
      onTertiary: ivoryWhite,
      tertiaryContainer: Color(0xFFE0E0FA),
      onTertiaryContainer: Color(0xFF220033),  // Deeper container text
      
      // Surface colors - Enhanced contrast Victorian court materials
      surface: parchmentCream,
      onSurface: deepCharcoalText,            // Deep text for maximum readability
      surfaceVariant: warmBeige,
      onSurfaceVariant: Color(0xFF444444),    // Deeper variant text
      inverseSurface: deepCharcoalText,
      onInverseSurface: ivoryWhite,
      
      // Background colors - Enhanced contrast ivory elegance
      background: ivoryWhite,
      onBackground: deepCharcoalText,         // Deep text for maximum readability
      
      // Error colors - Enhanced Victorian danger
      error: Color(0xFFBB1111),              // Deeper error red
      onError: ivoryWhite,
      errorContainer: Color(0xFFFEF0F0),
      onErrorContainer: Color(0xFF660000),   // Deeper error container text
      
      // Special colors - Enhanced with signature accent
      accent: deepVampireBloodSignature,      // Use signature blood red as primary accent
      highlight: deepGold,
      shadow: Color(0xFF000000),
      outline: deepSilver,                    // Deeper outline for better visibility
      outlineVariant: warmBeige,
      
      // Vampire Blood Signature Colors
      vampireBlood: deepVampireBloodSignature,
      onVampireBlood: onDeepVampireBloodSignature,
      vampireBloodContainer: deepVampireBloodContainer,
      onVampireBloodContainer: onDeepVampireBloodContainer,
      
      // Task priority colors - Enhanced with signature accent
      taskLowPriority: Color(0xFF118844),            // Deeper success green
      taskMediumPriority: deepGold,                  // Deep gold nobility
      taskHighPriority: deepVampireBloodSignature,   // Signature blood red - High priority
      taskUrgentPriority: Color(0xFFBB1111),         // Deeper urgent red
      
      // Status colors - Enhanced deeper gothic states
      success: Color(0xFF118844),             // Deeper success green
      warning: Color(0xFFCC7700),             // Deeper warning
      info: deepRegalBlue,                    // Deep regal blue
      
      // Calendar dot colors - Enhanced light gothic calendar
      calendarTodayDot: deepCrimson,
      calendarOverdueDot: Color(0xFFBB1111),
      calendarFutureDot: deepGold,
      calendarCompletedDot: Color(0xFF118844),
      calendarHighPriorityDot: deepVampireBloodSignature, // Signature blood red for high priority
      
      // Status badge colors - Enhanced with signature blood red
      statusPendingBadge: deepSilver,
      statusInProgressBadge: deepCrimson,
      statusCompletedBadge: deepVampireBloodSignature,    // Signature blood red for completed (achievement)
      statusCancelledBadge: warmBeige,
      statusOverdueBadge: Color(0xFFBB1111),
      statusOnHoldBadge: deepPurple,
      
      // Interactive colors - Enhanced light gothic responses
      hover: Color(0x60770000),               // Deeper crimson hover
      pressed: Color(0x99996600),             // Deeper gold pressed
      focus: deepVampireBloodSignature,       // Use signature blood red for focus
      disabled: Color(0xFFBBBBBB),            // Enhanced disabled
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
        fontWeight: TypographyConstants.smallTextWeight,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      cardTitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleSmall,
        fontWeight: TypographyConstants.smallTextWeight,
        letterSpacing: TypographyConstants.normalLetterSpacing * 1.1,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      cardSubtitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodySmall,
        fontWeight: TypographyConstants.smallTextWeight,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      buttonText: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.buttonText,
        fontWeight: TypographyConstants.smallTextWeight,
        letterSpacing: TypographyConstants.wideLetterSpacing * 1.2,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      inputText: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.inputText,
        fontWeight: TypographyConstants.smallTextWeight,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      appBarTitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.appBarTitle,
        fontWeight: TypographyConstants.smallTextWeight,
        letterSpacing: TypographyConstants.normalLetterSpacing * 1.1,
        height: TypographyConstants.relaxedLineHeight,
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
        geometricPattern: theme_effects.BackgroundGeometricPattern.mesh,
        patternAngle: 30.0,
        patternDensity: 0.9,
        accentColors: [
          Color(0x198B0000), // Blood crimson at 0.1 alpha
          Color(0x1FCFB53B), // Antique gold at 0.12 alpha
        ],
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