import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/typography_constants.dart';
import '../../core/accessibility/accessibility_constants.dart';
import '../../core/design_system/design_tokens.dart';

// Using GlassLevel from design_tokens.dart to avoid conflicts

class GlassmorphismContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final double? blur;         // Custom blur (overrides level)
  final double? opacity;      // Custom opacity (overrides level)
  final GlassLevel level;     // Hierarchy level for automatic blur/opacity
  final Color? glassTint;
  final Color? borderColor;
  final double borderWidth;
  final bool enableAccessibilityMode; // Enable accessibility optimizations
  final bool enablePerformanceMode; // Enable performance optimizations
  
  const GlassmorphismContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blur,           // Custom blur (overrides level defaults)
    this.opacity,        // Custom opacity (overrides level defaults)
    this.level = GlassLevel.content, // Default to content level
    this.glassTint,
    this.borderColor,
    this.borderWidth = 0.2, // Ultra-thin borders by default
    this.enableAccessibilityMode = true, // Enable accessibility by default
    this.enablePerformanceMode = true, // Enable performance optimizations by default
  });

  /// Get blur value based on level hierarchy and accessibility settings
  double _getEffectiveBlur(BuildContext context) {
    if (blur != null) return blur!; // Custom blur overrides level
    
    // Use default properties for level
    final adaptiveProperties = _getDefaultPropertiesForLevel(level);
    
    // Check accessibility settings
    final accessibleSettings = enableAccessibilityMode 
        ? _getAccessibleGlassSettings(context)
        : null;
    
    if (accessibleSettings?.blurRadius != null) {
      return accessibleSettings!.blurRadius!;
    }
    
    return adaptiveProperties.blurRadius;
  }

  /// Get opacity value based on level hierarchy and accessibility settings
  double _getEffectiveOpacity(BuildContext context) {
    if (opacity != null) return opacity!; // Custom opacity overrides level
    
    // Use default properties for level
    final adaptiveProperties = _getDefaultPropertiesForLevel(level);
    
    // Check accessibility settings
    final accessibleSettings = enableAccessibilityMode 
        ? _getAccessibleGlassSettings(context)
        : null;
    
    if (accessibleSettings?.opacity != null) {
      return accessibleSettings!.opacity!;
    }
    
    // In high contrast mode, use higher opacity for better visibility
    if (enableAccessibilityMode && MediaQuery.of(context).highContrast) {
      return (adaptiveProperties.opacity * 2.0).clamp(0.0, 1.0);
    }
    
    return adaptiveProperties.opacity;
  }

  /// Get accessible glass settings for accessibility mode
  _AccessibleGlassSettings? _getAccessibleGlassSettings(BuildContext context) {
    if (!enableAccessibilityMode) return null;
    
    final isHighContrast = MediaQuery.of(context).highContrast;
    
    if (isHighContrast) {
      return const _AccessibleGlassSettings(
        blurRadius: 5.0, // Reduced blur for better visibility
        opacity: 0.9, // High opacity for better contrast
        useHighContrastColors: true,
      );
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    
    // Cache expensive calculations
    final cacheKey = _buildCacheKey(context);
    final cachedProps = enablePerformanceMode ? _getCachedProperties(cacheKey, context) : null;
    
    // Use cached properties if available, otherwise calculate
    final _CachedGlassProperties effectiveProps;
    if (cachedProps != null) {
      effectiveProps = cachedProps;
    } else {
      effectiveProps = _calculateGlassProperties(context, mediaQuery, isDarkTheme);
      if (enablePerformanceMode) {
        _cacheProperties(cacheKey, effectiveProps);
      }
    }
    
    final effectiveBlurValue = effectiveProps.blurValue;
    final effectiveOpacityValue = effectiveProps.opacityValue;
    final effectiveHighContrast = effectiveProps.highContrast;
    final defaultGlassTint = effectiveProps.glassTint;
    final defaultBorderColor = effectiveProps.borderColor;
    final effectiveBorderWidth = effectiveProps.borderWidth;
    
    // Use the final computed values, with custom overrides
    final finalGlassTint = glassTint ?? defaultGlassTint;
    final finalBorderColor = borderColor ?? defaultBorderColor;
    
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(TypographyConstants.radiusStandard),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: effectiveBlurValue, 
            sigmaY: effectiveBlurValue
          ),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              // ENHANCED glassmorphism - white for dark themes, darker for light themes
              color: finalGlassTint,
              borderRadius: borderRadius ?? BorderRadius.circular(TypographyConstants.radiusStandard),
              border: Border.all(
                color: finalBorderColor,
                width: effectiveBorderWidth,
              ),
              // Use pre-computed gradient for performance
              gradient: enablePerformanceMode && !effectiveHighContrast
                  ? effectiveProps.gradient
                  : (effectiveHighContrast
                      ? null // Disable gradient in high contrast mode for better accessibility
                      : _buildGradient(isDarkTheme, effectiveOpacityValue)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
  
  /// Get default properties object for a given glass level (static helper)
  static _GlassProperties _getDefaultPropertiesForLevel(GlassLevel level) {
    return _GlassProperties(
      blurRadius: _getDefaultBlurForLevel(level),
      opacity: _getDefaultOpacityForLevel(level),
      borderWidth: _getDefaultBorderWidthForLevel(level),
    );
  }
  
  /// Get default blur value for a given glass level (static helper)
  static double _getDefaultBlurForLevel(GlassLevel level) {
    switch (level) {
      case GlassLevel.background:
        return 5.0;
      case GlassLevel.content:
        return 8.0;
      case GlassLevel.interactive:
        return 12.0;
      case GlassLevel.floating:
        return 16.0;
      default:
        return 10.0;
    }
  }

  /// Get default opacity for a given glass level (static helper)
  static double _getDefaultOpacityForLevel(GlassLevel level) {
    switch (level) {
      case GlassLevel.background:
        return 0.1;
      case GlassLevel.content:
        return 0.15;
      case GlassLevel.interactive:
        return 0.2;
      case GlassLevel.floating:
        return 0.25;
      default:
        return 0.2;
    }
  }

  /// Get default border width for a given glass level (static helper)
  static double _getDefaultBorderWidthForLevel(GlassLevel level) {
    switch (level) {
      case GlassLevel.background:
        return 0.5;
      case GlassLevel.content:
        return 0.8;
      case GlassLevel.interactive:
        return 1.0;
      case GlassLevel.floating:
        return 1.2;
      default:
        return 1.0;
    }
  }

  /// Performance optimization: Cache expensive calculations
  static final Map<String, _CachedGlassProperties> _propertiesCache = {};
  
  /// Build cache key for property caching
  String _buildCacheKey(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    return '${level.name}_${theme.brightness.name}_${mediaQuery.highContrast}_$blur$opacity';
  }
  
  /// Get cached properties if available
  _CachedGlassProperties? _getCachedProperties(String key, BuildContext context) {
    return _propertiesCache[key];
  }
  
  /// Cache computed properties
  void _cacheProperties(String key, _CachedGlassProperties properties) {
    // Limit cache size to prevent memory leaks
    if (_propertiesCache.length > 50) {
      _propertiesCache.clear();
    }
    _propertiesCache[key] = properties;
  }
  
  /// Calculate all glass properties at once for better performance
  _CachedGlassProperties _calculateGlassProperties(
    BuildContext context,
    MediaQueryData mediaQuery,
    bool isDarkTheme,
  ) {
    final effectiveBlurValue = _getEffectiveBlur(context);
    final effectiveOpacityValue = _getEffectiveOpacity(context);
    
    // Check for high contrast mode
    final accessibleSettings = enableAccessibilityMode 
        ? _getAccessibleGlassSettings(context)
        : null;
    final useHighContrast = accessibleSettings?.useHighContrastColors ?? false;
    
    // Use high contrast colors if accessibility mode is enabled
    final systemHighContrast = mediaQuery.highContrast;
    final effectiveHighContrast = useHighContrast || systemHighContrast;
    
    final defaultGlassTint = effectiveHighContrast 
        ? (isDarkTheme 
            ? AccessibilityConstants.highContrastSurface
            : AccessibilityConstants.highContrastBackground.withOpacity(0.95))
        : (isDarkTheme 
            ? Colors.white.withOpacity(effectiveOpacityValue)
            : Colors.black.withOpacity(effectiveOpacityValue * 1.0));
    
    final defaultBorderColor = effectiveHighContrast 
        ? (isDarkTheme 
            ? AccessibilityConstants.highContrastText.withOpacity(0.8)
            : AccessibilityConstants.highContrastText.withOpacity(0.6))
        : (isDarkTheme 
            ? Colors.white.withOpacity(0.45)
            : Colors.black.withOpacity(0.35));
    
    // Increase border width for high contrast mode
    final effectiveBorderWidth = effectiveHighContrast ? (borderWidth * 2.0).clamp(1.0, 3.0) : borderWidth;
    
    // Pre-compute gradient for performance
    final gradient = effectiveHighContrast ? null : _buildGradient(isDarkTheme, effectiveOpacityValue);
    
    return _CachedGlassProperties(
      blurValue: effectiveBlurValue,
      opacityValue: effectiveOpacityValue,
      highContrast: effectiveHighContrast,
      glassTint: defaultGlassTint,
      borderColor: defaultBorderColor,
      borderWidth: effectiveBorderWidth,
      gradient: gradient,
    );
  }
  
  /// Build gradient efficiently
  LinearGradient? _buildGradient(bool isDarkTheme, double effectiveOpacityValue) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDarkTheme 
        ? [
            Colors.white.withOpacity(effectiveOpacityValue * 1.4),
            Colors.white.withOpacity(effectiveOpacityValue * 0.6),
            Colors.white.withOpacity(effectiveOpacityValue * 0.3),
            Colors.white.withOpacity(effectiveOpacityValue * 1.1),
          ]
        : [
            Colors.black.withOpacity(effectiveOpacityValue * 0.7),
            Colors.black.withOpacity(effectiveOpacityValue * 0.5),
            Colors.grey.withOpacity(effectiveOpacityValue * 0.8),
            Colors.black.withOpacity(effectiveOpacityValue * 0.6),
          ],
      stops: const [0.0, 0.4, 0.8, 1.0],
    );
  }
}

/// A glassmorphism card specifically for task-related components
class GlassTaskCard extends StatelessWidget {
  final Widget child;
  final double elevation;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  
  const GlassTaskCard({
    super.key,
    required this.child,
    this.elevation = 2.0,
    this.onTap,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    // Get adaptive properties from design tokens
    final adaptiveProperties = GlassmorphismContainer._getDefaultPropertiesForLevel(GlassLevel.content);
    
    final cardWidget = GlassmorphismContainer(
      level: GlassLevel.content, // Use content level for task cards
      padding: padding ?? const EdgeInsets.all(SpacingTokens.md),
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      borderWidth: adaptiveProperties.borderWidth,
      child: child,
    );
    
    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
          child: cardWidget,
        ),
      );
    }
    
    return cardWidget;
  }
}

/// A glassmorphism container for project cards
class GlassProjectCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? accentColor;
  
  const GlassProjectCard({
    super.key,
    required this.child,
    this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    // Get adaptive properties from design tokens
    final adaptiveProperties = GlassmorphismContainer._getDefaultPropertiesForLevel(GlassLevel.content);
    
    final cardWidget = GlassmorphismContainer(
      level: GlassLevel.content, // Use content level for project cards
      padding: const EdgeInsets.all(SpacingTokens.md),
      margin: const EdgeInsets.all(SpacingTokens.sm),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      borderWidth: adaptiveProperties.borderWidth,
      glassTint: accentColor?.withOpacity(0.1), // Keep accent color tinting
      child: child,
    );
    
    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
          child: cardWidget,
        ),
      );
    }
    
    return cardWidget;
  }
}

/// Glassmorphism container for floating action buttons and controls
class GlassControlContainer extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double size;
  
  const GlassControlContainer({
    super.key,
    required this.child,
    this.onTap,
    this.size = 56.0,
  });

  @override
  Widget build(BuildContext context) {
    // Get adaptive properties from design tokens
    final adaptiveProperties = GlassmorphismContainer._getDefaultPropertiesForLevel(GlassLevel.floating);
    
    return GlassmorphismContainer(
      level: GlassLevel.floating, // Use floating level for controls
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(size / 2),
      borderWidth: adaptiveProperties.borderWidth,
      child: onTap != null
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(size / 2),
                child: Center(child: child),
              ),
            )
          : Center(child: child),
    );
  }
}

/// Glassmorphism button with consistent styling
class GlassButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool enabled;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  
  const GlassButton({
    super.key,
    required this.child,
    this.onPressed,
    this.type = ButtonType.primary,
    this.enabled = true,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    // Get adaptive properties from design tokens
    final level = type == ButtonType.floating ? GlassLevel.floating : GlassLevel.interactive;
    final adaptiveProperties = GlassmorphismContainer._getDefaultPropertiesForLevel(level);
    
    return GlassmorphismContainer(
      level: level,
      padding: padding ?? const EdgeInsets.all(SpacingTokens.sm),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      borderWidth: adaptiveProperties.borderWidth,
      glassTint: color?.withOpacity(0.1),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
          child: Center(child: child),
        ),
      ),
    );
  }
}

/// Simple properties class for glass effects
class _GlassProperties {
  final double blurRadius;
  final double opacity;
  final double borderWidth;
  
  const _GlassProperties({
    required this.blurRadius,
    required this.opacity,
    required this.borderWidth,
  });
}

/// Accessible glass settings for high contrast mode
class _AccessibleGlassSettings {
  final double? blurRadius;
  final double? opacity;
  final bool useHighContrastColors;
  
  const _AccessibleGlassSettings({
    this.blurRadius,
    this.opacity,
    this.useHighContrastColors = false,
  });
}

/// Cached glass properties for performance optimization
class _CachedGlassProperties {
  final double blurValue;
  final double opacityValue;
  final bool highContrast;
  final Color glassTint;
  final Color borderColor;
  final double borderWidth;
  final LinearGradient? gradient;
  
  const _CachedGlassProperties({
    required this.blurValue,
    required this.opacityValue,
    required this.highContrast,
    required this.glassTint,
    required this.borderColor,
    required this.borderWidth,
    this.gradient,
  });
}

/// Button types for different glassmorphism levels
enum ButtonType {
  primary,
  secondary,
  floating,
}