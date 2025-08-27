import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/enhanced_theme_provider.dart';
import '../../core/theme/models/theme_effects.dart';
import '../../core/theme/models/theme_colors.dart';
import 'standardized_colors.dart';
import 'dart:math' as math;

/// Widget that applies theme-specific programmatic gradients
class ThemeBackgroundWidget extends ConsumerWidget {
  final Widget child;
  
  const ThemeBackgroundWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(enhancedThemeProvider);
    final currentTheme = themeState.currentTheme;
    
    if (currentTheme == null) {
      return child;
    }

    // Generate unique background based on theme's color palette
    final backgroundEffects = currentTheme.effects.backgroundEffects;
    final themeColors = currentTheme.colors;
    final Gradient gradient;
    
    if (backgroundEffects.enableGradientMesh) {
      // Use geometric patterns with theme colors
      gradient = _createGeometricGradient(backgroundEffects, themeColors);
    } else {
      // Create theme-specific background from color palette
      gradient = _createThemeSignatureBackground(themeColors);
    }

    return Stack(
      children: [
        // Theme base background color
        Positioned.fill(
          child: Container(
            color: themeColors.background,
          ),
        ),
        // Theme signature gradient overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(gradient: gradient),
          ),
        ),
        // App content with transparent background
        Container(
          color: context.colors.backgroundTransparent,
          child: child,
        ),
      ],
    );
  }

  /// Create gradient based on geometric pattern configuration
  Gradient _createGeometricGradient(BackgroundEffectConfig config, ThemeColors themeColors) {
    // Use theme accent colors or generate from theme palette
    final colors = config.accentColors.isNotEmpty 
        ? config.accentColors 
        : _getThemeAccentColors(themeColors);
    
    // Make patterns MUCH more prominent and visible
    final adjustedColors = colors.map((color) {
      double baseAlpha = color.a;
      // Boost alpha significantly for visibility
      double alpha = (baseAlpha * config.effectIntensity * 3.0).clamp(0.4, 0.9); // 3x multiplier, 40-90% alpha
      return color.withValues(alpha: alpha);
    }).toList();
    
    // Create gradient based on geometric pattern
    switch (config.geometricPattern) {
      case BackgroundGeometricPattern.linear:
        return _createLinearGradient(adjustedColors, config.patternAngle, config.patternDensity);
      case BackgroundGeometricPattern.radial:
        return _createRadialGradient(adjustedColors, config.patternDensity);
      case BackgroundGeometricPattern.diamond:
        return _createDiamondGradient(adjustedColors, config.patternAngle, config.patternDensity);
      case BackgroundGeometricPattern.mesh:
        return _createMeshGradient(adjustedColors, config.patternAngle, config.patternDensity);
    }
  }

  /// Create linear gradient with angle and density
  Gradient _createLinearGradient(List<Color> colors, double angle, double density) {
    // Convert angle to alignment
    final radians = angle * (math.pi / 180);
    final alignment = Alignment(math.cos(radians), math.sin(radians));
    
    return LinearGradient(
      begin: -alignment,
      end: alignment,
      colors: colors,
      stops: _createStops(colors.length, density),
    );
  }

  /// Create radial gradient with density
  Gradient _createRadialGradient(List<Color> colors, double density) {
    return RadialGradient(
      center: Alignment.center,
      radius: 0.8 + (density * 0.4), // Density affects radius
      colors: colors,
      stops: _createStops(colors.length, density),
    );
  }

  /// Create diamond-like sweep gradient
  Gradient _createDiamondGradient(List<Color> colors, double angle, double density) {
    return SweepGradient(
      center: Alignment.center,
      startAngle: angle * (math.pi / 180),
      endAngle: (angle + 360) * (math.pi / 180),
      colors: [...colors, colors.first], // Complete the sweep
      stops: _createStops(colors.length + 1, density),
      transform: GradientRotation(angle * (math.pi / 180)),
    );
  }

  /// Create mesh-like gradient (using linear with offset)
  Gradient _createMeshGradient(List<Color> colors, double angle, double density) {
    final radians = angle * (math.pi / 180);
    final alignment = Alignment(math.cos(radians), math.sin(radians));
    
    // Create a more complex mesh pattern by layering
    return LinearGradient(
      begin: Alignment.topLeft.add(alignment * 0.3),
      end: Alignment.bottomRight.add(alignment * -0.3),
      colors: colors,
      stops: _createStops(colors.length, density),
      tileMode: TileMode.mirror, // Creates mesh-like repetition
    );
  }

  /// Create gradient stops based on color count and density
  List<double> _createStops(int colorCount, double density) {
    if (colorCount <= 1) return [0.0];
    
    final stops = <double>[];
    final densityFactor = (1.0 / density).clamp(0.5, 2.0); // Density affects spread
    
    for (int i = 0; i < colorCount; i++) {
      final stop = (i / (colorCount - 1)) * densityFactor;
      stops.add(stop.clamp(0.0, 1.0));
    }
    
    return stops;
  }

  /// Generate theme-specific accent colors from theme palette
  List<Color> _getThemeAccentColors(ThemeColors themeColors) {
    return [
      themeColors.primary.withValues(alpha: 0.6),    // Much higher base alpha
      themeColors.secondary.withValues(alpha: 0.5),  // Much higher base alpha  
      themeColors.tertiary.withValues(alpha: 0.4),   // Much higher base alpha
    ];
  }
  
  /// Create theme signature background from color palette
  Gradient _createThemeSignatureBackground(ThemeColors themeColors) {
    final isLight = themeColors.background.computeLuminance() > 0.5;
    
    // Create unique gradient using theme's primary colors
    if (isLight) {
      return RadialGradient(
        center: Alignment.center,
        radius: 1.2,
        colors: [
          themeColors.background,
          themeColors.primaryContainer.withValues(alpha: 0.3),
          themeColors.secondaryContainer.withValues(alpha: 0.2),
          themeColors.background,
        ],
        stops: const [0.0, 0.4, 0.7, 1.0],
      );
    } else {
      return RadialGradient(
        center: Alignment.center,
        radius: 1.2,
        colors: [
          themeColors.background,
          themeColors.primary.withValues(alpha: 0.15),
          themeColors.secondary.withValues(alpha: 0.1),
          themeColors.background,
        ],
        stops: const [0.0, 0.4, 0.7, 1.0],
      );
    }
  }

}