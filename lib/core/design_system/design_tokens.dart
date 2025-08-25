import 'package:flutter/material.dart';
import '../theme/typography_constants.dart';

/// Comprehensive design tokens for consistent glassmorphism design
class DesignTokens {
  DesignTokens._();

  /// Sophisticated glass hierarchy with refined blur values for premium aesthetics
  static const Map<GlassLevel, GlassProperties> glassHierarchy = {
    GlassLevel.whisper: GlassProperties(
      blurRadius: 3.0,        // Ultra-subtle for sophisticated backgrounds
      opacity: 0.02,          // Whisper-light transparency
      borderOpacity: 0.05,    // Barely visible borders
      shadowElevation: 0,
      borderWidth: 0.5,
    ),
    GlassLevel.background: GlassProperties(
      blurRadius: 6.0,        // Reduced from 10.0 for elegance
      opacity: 0.04,          // Refined transparency
      borderOpacity: 0.08,    // Subtle definition
      shadowElevation: 0,
      borderWidth: 0.5,
    ),
    GlassLevel.content: GlassProperties(
      blurRadius: 8.0,        // Reduced from 15.0 for clarity
      opacity: 0.06,          // Refined for readability
      borderOpacity: 0.12,    // Clear content boundaries
      shadowElevation: 1,
      borderWidth: 0.5,       // Ultra-thin for sophistication
    ),
    GlassLevel.interactive: GlassProperties(
      blurRadius: 10.0,       // Reduced from 20.0 for responsiveness
      opacity: 0.08,          // Subtle interaction feedback
      borderOpacity: 0.15,    // Clear interactive boundaries
      shadowElevation: 2,
      borderWidth: 0.5,       // Consistent thin borders
    ),
    GlassLevel.floating: GlassProperties(
      blurRadius: 12.0,       // Reduced from 25.0 for sophisticated overlays
      opacity: 0.1,           // Refined floating elements
      borderOpacity: 0.2,     // Clear floating definition
      shadowElevation: 4,
      borderWidth: 0.5,       // Elegant thin borders
    ),
  };

  /// Accessibility glass properties for high contrast and reduced motion
  static const Map<GlassLevel, GlassProperties> accessibilityGlassHierarchy = {
    GlassLevel.whisper: GlassProperties(
      blurRadius: 2.0,        // Minimal blur for accessibility
      opacity: 0.85,          // High contrast
      borderOpacity: 0.9,     // Clear boundaries
      shadowElevation: 0,
      borderWidth: 1.0,
    ),
    GlassLevel.background: GlassProperties(
      blurRadius: 3.0,        // Reduced for clarity
      opacity: 0.8,
      borderOpacity: 0.9,
      shadowElevation: 0,
      borderWidth: 1.0,
    ),
    GlassLevel.content: GlassProperties(
      blurRadius: 4.0,        // Reduced for readability
      opacity: 0.85,
      borderOpacity: 0.95,
      shadowElevation: 1,
      borderWidth: 1.5,
    ),
    GlassLevel.interactive: GlassProperties(
      blurRadius: 5.0,        // Reduced for clarity
      opacity: 0.9,
      borderOpacity: 1.0,
      shadowElevation: 2,
      borderWidth: 2.0,
    ),
    GlassLevel.floating: GlassProperties(
      blurRadius: 6.0,        // Reduced for accessibility
      opacity: 0.95,
      borderOpacity: 1.0,
      shadowElevation: 4,
      borderWidth: 2.5,
    ),
  };

  /// Spacing scale following 8px grid system
  static const spacing = SpacingTokens._();

  /// Typography scale with consistent line heights and letter spacing
  static const typography = TypographyTokens._();

  /// Color semantics for consistent theming
  static const colors = ColorTokens._();

  /// Animation and motion tokens
  static const motion = MotionTokens._();

  /// Border radius scale
  static const BorderRadiusTokens borderRadius = BorderRadiusTokens._();

  /// Shadow depths and elevations
  static const shadows = ShadowTokens._();

  /// Icon sizes and weights
  static const icons = IconTokens._();

  /// Component-specific tokens
  static const components = ComponentTokens._();
}

/// Sophisticated glass level enumeration with refined hierarchy
enum GlassLevel {
  whisper,      // NEW: Ultra-subtle for premium backgrounds
  background,
  content,
  interactive,
  floating,
}

/// Glass properties for each hierarchy level
class GlassProperties {
  final double blurRadius;
  final double opacity;
  final double borderOpacity;
  final double shadowElevation;
  final double borderWidth;

  const GlassProperties({
    required this.blurRadius,
    required this.opacity,
    required this.borderOpacity,
    required this.shadowElevation,
    required this.borderWidth,
  });

  /// Create accessible version with high contrast
  GlassProperties get accessible => GlassProperties(
    blurRadius: blurRadius * 0.5,
    opacity: opacity > 0.5 ? opacity : 0.8,
    borderOpacity: borderOpacity > 0.8 ? borderOpacity : 1.0,
    shadowElevation: shadowElevation + 1,
    borderWidth: borderWidth * 1.5,
  );

  /// Create reduced motion version
  GlassProperties get reducedMotion => GlassProperties(
    blurRadius: blurRadius * 0.3,
    opacity: opacity,
    borderOpacity: borderOpacity,
    shadowElevation: shadowElevation,
    borderWidth: borderWidth,
  );
}

/// Enhanced spacing tokens with golden ratio progression for sophisticated interfaces
class SpacingTokens {
  const SpacingTokens._();

  // Base spacing unit (8px)
  static const double unit = 8.0;
  
  // Golden ratio constant for mathematical harmony
  static const double phi = 1.618;

  // Standard spacing scale (maintained for compatibility)
  static const double xs = unit * 0.5;    // 4px
  static const double sm = unit;          // 8px
  static const double md = unit * 2;      // 16px
  static const double lg = unit * 3;      // 24px
  static const double xl = unit * 4;      // 32px
  static const double xxl = unit * 6;     // 48px
  static const double xxxl = unit * 8;    // 64px

  // Enhanced golden ratio spacing for sophisticated interfaces
  static const double phi1 = unit * phi;              // 13px - Natural rhythm
  static const double phi2 = unit * phi * phi * 0.65; // 17px - Comfortable reading
  static const double phi3 = unit * phi * phi;        // 21px - Spacious layout
  static const double phi4 = unit * phi * phi * phi * 0.6; // 25px - Generous spacing
  static const double phi5 = unit * phi * phi * phi;  // 34px - Luxurious breathing room
  static const double phi6 = unit * phi * phi * phi * phi * 0.65; // 36px - Expansive sections
  static const double phi7 = unit * phi * phi * phi * phi; // 55px - Hero isolation

  // Semantic spacing (enhanced with golden ratio)
  static const double elementPadding = phi3;     // 21px - Perfect card breathing room
  static const double sectionPadding = phi5;     // 34px - Elegant section separation  
  static const double pagePadding = xl;          // 32px - Page margins
  static const double componentMargin = sm;      // 8px - Component spacing
  static const double sectionMargin = phi5;      // 34px - Section separation
  
  // Task-specific sophisticated spacing
  static const double taskCardHeight = 88.0;     // Golden ratio optimized height
  static const double taskCardPadding = phi3;    // 21px internal padding
  static const double taskCardMargin = sm;       // 8px between cards
  static const double taskCardRadius = 12.0;     // Sophisticated corner radius
  static const double welcomeSpacing = phi5;     // 34px for welcome section elegance
  static const double tabSpacing = phi1;         // 13px for natural tab rhythm
}

/// Typography tokens with consistent scales
class TypographyTokens {
  const TypographyTokens._();

  // Line height multipliers
  static const double tightLineHeight = 1.2;
  static const double normalLineHeight = 1.4;
  static const double relaxedLineHeight = 1.6;

  // Letter spacing
  static const double tightLetterSpacing = -0.5;
  static const double normalLetterSpacing = 0.0;
  static const double wideLetterSpacing = 0.5;

  // Font weights (referencing typography_constants.dart)
  static FontWeight get light => TypographyConstants.light;
  static FontWeight get regular => TypographyConstants.regular;
  static FontWeight get medium => TypographyConstants.medium;
  // semiBold and bold removed per REQ 20 - maximum weight is medium (w500)

  // Font sizes (referencing typography_constants.dart)
  static double get xs => TypographyConstants.textXS;
  static double get sm => TypographyConstants.textSM;
  static double get base => TypographyConstants.textBase;
  static double get lg => TypographyConstants.textLG;
  static double get xl => TypographyConstants.textXL;
  static double get xxl => TypographyConstants.text2XL;
  static double get xxxl => TypographyConstants.text3XL;
}

/// Color semantic tokens
class ColorTokens {
  const ColorTokens._();

  // Glass tint opacities for different themes
  static const Map<String, double> glassThemeTints = {
    'matrix': 0.15,
    'vegeta': 0.12,
    'dracula': 0.18,
    'light': 0.08,
    'dark': 0.2,
  };

  // State colors with consistent opacity
  static const double successOpacity = 0.1;
  static const double warningOpacity = 0.1;
  static const double errorOpacity = 0.1;
  static const double infoOpacity = 0.1;

  // Interactive states
  static const double hoverOpacity = 0.04;
  static const double pressedOpacity = 0.08;
  static const double focusOpacity = 0.12;
  static const double dragOpacity = 0.16;

  // Accessibility contrast ratios (WCAG AA)
  static const double minContrastRatio = 4.5;
  static const double preferredContrastRatio = 7.0;
}

/// Motion and animation tokens
class MotionTokens {
  const MotionTokens._();

  // Duration scale
  static const Duration instant = Duration(milliseconds: 0);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration slower = Duration(milliseconds: 800);

  // Easing curves
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;

  // Glassmorphism-specific animations
  static const Duration glassBlur = Duration(milliseconds: 200);
  static const Duration glassOpacity = Duration(milliseconds: 150);
  static const Duration glassBorder = Duration(milliseconds: 100);
  static const Duration glassShadow = Duration(milliseconds: 250);

  // Interaction feedback
  static const Duration tapFeedback = Duration(milliseconds: 100);
  static const Duration hoverFeedback = Duration(milliseconds: 200);
  static const Duration longPressFeedback = Duration(milliseconds: 500);

  // Reduced motion alternatives
  static Duration getAccessibleDuration(Duration original) {
    return Duration(milliseconds: (original.inMilliseconds * 0.3).round());
  }
}

/// Border radius tokens
class BorderRadiusTokens {
  const BorderRadiusTokens._();

  static const double none = 0.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double full = 1000.0; // For circular shapes

  // Semantic radius values
  static double get button => md;
  static double get card => lg;
  static double get dialog => xl;
  static double get sheet => xl;
  static double get fab => full;
}

/// Shadow and elevation tokens
class ShadowTokens {
  const ShadowTokens._();

  // Shadow elevations
  static const double level0 = 0.0;
  static const double level1 = 2.0;
  static const double level2 = 4.0;
  static const double level3 = 8.0;
  static const double level4 = 16.0;
  static const double level5 = 24.0;

  // Glass shadow properties
  static List<BoxShadow> glassLevelShadows(BuildContext context, GlassLevel level) {
    final theme = Theme.of(context);
    final properties = DesignTokens.glassHierarchy[level]!;
    
    if (properties.shadowElevation <= 0) return [];
    
    return [
      BoxShadow(
        color: theme.colorScheme.shadow.withValues(alpha: 0.1),
        blurRadius: properties.shadowElevation * 2,
        spreadRadius: properties.shadowElevation * 0.5,
        offset: Offset(0, properties.shadowElevation * 0.5),
      ),
      BoxShadow(
        color: theme.colorScheme.shadow.withValues(alpha: 0.05),
        blurRadius: properties.shadowElevation * 4,
        spreadRadius: properties.shadowElevation,
        offset: Offset(0, properties.shadowElevation),
      ),
    ];
  }
}

/// Icon sizing and weight tokens
class IconTokens {
  const IconTokens._();

  // Size scale
  static const double xs = 12.0;
  static const double sm = 16.0;
  static const double md = 20.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 40.0;
  static const double xxxl = 48.0;

  // Semantic sizes
  static double get button => md;
  static double get listItem => lg;
  static double get fab => lg;
  static double get appBar => lg;
  static double get feature => xxxl;
}

/// Component-specific design tokens
class ComponentTokens {
  const ComponentTokens._();

  // Button tokens
  static const button = ButtonTokens._();
  
  // Card tokens
  static const card = CardTokens._();
  
  // Input tokens
  static const input = InputTokens._();
  
  // Navigation tokens
  static const navigation = NavigationTokens._();
}

class ButtonTokens {
  const ButtonTokens._();

  static const double height = 48.0;
  static const double minWidth = 64.0;
  static const EdgeInsets padding = EdgeInsets.symmetric(horizontal: 24, vertical: 12);
  static const double borderRadius = BorderRadiusTokens.md;
  static const double disabledOpacity = 0.38;
  static const Duration animationDuration = MotionTokens.fast;
}

class CardTokens {
  const CardTokens._();

  static const EdgeInsets padding = EdgeInsets.all(SpacingTokens.md);
  static const EdgeInsets margin = EdgeInsets.all(SpacingTokens.sm);
  static const double borderRadius = BorderRadiusTokens.lg;
  static const GlassLevel glassLevel = GlassLevel.content;
}

class InputTokens {
  const InputTokens._();

  static const double height = 56.0;
  static const EdgeInsets padding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  static const double borderRadius = BorderRadiusTokens.md;
  static const double borderWidth = 1.0;
  static const double focusedBorderWidth = 2.0;
  static const GlassLevel glassLevel = GlassLevel.interactive;
}

class NavigationTokens {
  const NavigationTokens._();

  static const double bottomNavHeight = 80.0;
  static const double appBarHeight = kToolbarHeight;
  static const double drawerWidth = 280.0;
  static const double tabBarHeight = 48.0;
  static const GlassLevel glassLevel = GlassLevel.interactive;
  static const double borderRadius = BorderRadiusTokens.xl;
}

/// Design system utilities for consistent implementation
class DesignSystem {
  DesignSystem._();

  /// Get glass properties for a specific level with accessibility considerations
  static GlassProperties getGlassProperties(
    BuildContext context,
    GlassLevel level, {
    bool forceAccessible = false,
  }) {
    final isHighContrast = MediaQuery.of(context).highContrast || forceAccessible;
    final shouldReduceMotion = MediaQuery.of(context).disableAnimations;
    
    GlassProperties properties;
    
    if (isHighContrast) {
      properties = DesignTokens.accessibilityGlassHierarchy[level]!;
    } else {
      properties = DesignTokens.glassHierarchy[level]!;
    }
    
    if (shouldReduceMotion) {
      properties = properties.reducedMotion;
    }
    
    return properties;
  }

  /// Get appropriate color with semantic meaning
  static Color getSemanticColor(
    BuildContext context,
    SemanticColorType type, {
    double? opacity,
  }) {
    final theme = Theme.of(context);
    final actualOpacity = opacity ?? 1.0;
    
    switch (type) {
      case SemanticColorType.success:
        return theme.colorScheme.tertiary.withValues(alpha: actualOpacity); // Success uses tertiary
      case SemanticColorType.warning:
        return theme.colorScheme.onTertiaryContainer.withValues(alpha: actualOpacity); // Warning uses tertiary variant
      case SemanticColorType.error:
        return theme.colorScheme.error.withValues(alpha: actualOpacity);
      case SemanticColorType.info:
        return Colors.blue.withValues(alpha: actualOpacity);
      case SemanticColorType.primary:
        return theme.colorScheme.primary.withValues(alpha: actualOpacity);
      case SemanticColorType.secondary:
        return theme.colorScheme.secondary.withValues(alpha: actualOpacity);
    }
  }

  /// Get responsive spacing based on screen size
  static double getResponsiveSpacing(
    BuildContext context,
    double baseSpacing, {
    double tabletMultiplier = 1.2,
    double desktopMultiplier = 1.5,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth >= 1200) {
      return baseSpacing * desktopMultiplier;
    } else if (screenWidth >= 768) {
      return baseSpacing * tabletMultiplier;
    } else {
      return baseSpacing;
    }
  }

  /// Get appropriate animation duration with accessibility considerations
  static Duration getAnimationDuration(
    BuildContext context,
    Duration baseDuration, {
    double accessibilityMultiplier = 0.3,
  }) {
    final shouldReduceMotion = MediaQuery.of(context).disableAnimations;
    
    if (shouldReduceMotion) {
      return Duration(
        milliseconds: (baseDuration.inMilliseconds * accessibilityMultiplier).round(),
      );
    }
    
    return baseDuration;
  }

  /// Validate design token usage and provide feedback
  static String? validateDesignUsage({
    required GlassLevel? glassLevel,
    required double? spacing,
    required double? fontSize,
    required Color? color,
  }) {
    final issues = <String>[];
    
    // Validate spacing follows 8px grid
    if (spacing != null && spacing % SpacingTokens.unit != 0) {
      issues.add('Spacing should follow 8px grid system');
    }
    
    // Validate glass level consistency
    if (glassLevel == null) {
      issues.add('Glass level should be specified for consistent hierarchy');
    }
    
    // Validate font size is from scale
    if (fontSize != null) {
      final validSizes = [
        TypographyTokens.xs,
        TypographyTokens.sm,
        TypographyTokens.base,
        TypographyTokens.lg,
        TypographyTokens.xl,
        TypographyTokens.xxl,
        TypographyTokens.xxxl,
      ];
      
      if (!validSizes.contains(fontSize)) {
        issues.add('Font size should use typography scale');
      }
    }
    
    return issues.isEmpty ? null : issues.join(', ');
  }
}

/// Semantic color types for consistent theming
enum SemanticColorType {
  success,
  warning,
  error,
  info,
  primary,
  secondary,
}