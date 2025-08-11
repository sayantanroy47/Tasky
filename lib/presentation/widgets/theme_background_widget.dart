import 'package:flutter/material.dart';
// Removed debug import
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/enhanced_theme_provider.dart';
import '../../core/theme/painters/background_painters.dart';

/// Widget that applies theme-specific static background effects
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
    
    debugPrint('🎨 ThemeBackgroundWidget: Building with theme: ${currentTheme?.metadata.id ?? 'null'}');
    
    if (currentTheme == null) {
      debugPrint('🚫 ThemeBackgroundWidget: No current theme - returning child only');
      return child;
    }

    // ALWAYS show static background for ALL themes - user explicitly requested this
    final themeId = currentTheme.metadata.id;
    final isDarkTheme = themeId.contains('dark') || themeId.contains('_dark');
    
    debugPrint('🎨 ThemeBackgroundWidget: Theme ID: $themeId');
    debugPrint('🎨 ThemeBackgroundWidget: Is Dark Theme: $isDarkTheme');
    debugPrint('🎨 ThemeBackgroundWidget: FORCING static background for ALL themes - RELOADED!');

    // Adjust colors for light vs dark themes
    Color adjustedPrimary = isDarkTheme 
        ? currentTheme.colors.primary 
        : Colors.black87; // DARK text for light themes
    Color adjustedSecondary = isDarkTheme 
        ? currentTheme.colors.secondary 
        : Colors.black54; // DARK secondary for light themes

    // Create the appropriate static background painter based on theme - ALWAYS CREATE BACKGROUND
    CustomPainter? backgroundPainter;
    
    if (themeId.contains('matrix')) {
      if (isDarkTheme) {
        debugPrint('✅ ThemeBackgroundWidget: Creating STATIC MatrixRainPainter for DARK theme: $themeId');
        backgroundPainter = MatrixRainPainter(
          primaryColor: adjustedPrimary,
          secondaryColor: adjustedSecondary,
          config: currentTheme.effects.backgroundEffects,
          opacity: currentTheme.effects.backgroundEffects.particleOpacity,
        );
      } else {
        debugPrint('✅ ThemeBackgroundWidget: Creating STATIC LIGHT MatrixRainPainter for LIGHT Matrix theme: $themeId');
        // Light Matrix theme should use LIGHT COLORED matrix rain on white background
        backgroundPainter = MatrixRainPainter(
          primaryColor: adjustedPrimary,
          secondaryColor: adjustedSecondary,
          config: currentTheme.effects.backgroundEffects,
          opacity: 0.15, // Dark text on white needs lower opacity
        );
      }
    } else if (themeId.contains('vegeta')) {
      if (isDarkTheme) {
        debugPrint('✅ ThemeBackgroundWidget: Creating STATIC MetallicGradientMeshPainter for DARK theme: $themeId');
        backgroundPainter = MetallicGradientMeshPainter(
          primaryColor: adjustedPrimary,
          secondaryColor: adjustedSecondary,
          config: currentTheme.effects.backgroundEffects,
          opacity: 1.0,
        );
      } else {
        debugPrint('✅ ThemeBackgroundWidget: Creating STATIC LIGHT MetallicGradientMeshPainter for LIGHT Vegeta theme: $themeId');
        // Light Vegeta theme should use LIGHT COLORED metallic mesh on white background
        backgroundPainter = MetallicGradientMeshPainter(
          primaryColor: adjustedPrimary,
          secondaryColor: adjustedSecondary,
          config: currentTheme.effects.backgroundEffects,
          opacity: 0.2, // Dark patterns on white needs lower opacity
        );
      }
    } else if (themeId.contains('dracula')) {
      if (isDarkTheme) {
        debugPrint('✅ ThemeBackgroundWidget: Creating STATIC SubtleFloatingElementsPainter for DARK theme: $themeId');
        backgroundPainter = SubtleFloatingElementsPainter(
          primaryColor: adjustedPrimary,
          secondaryColor: adjustedSecondary,
          config: currentTheme.effects.backgroundEffects,
          opacity: 1.0,
        );
      } else {
        debugPrint('✅ ThemeBackgroundWidget: Creating STATIC light floating for LIGHT Dracula theme: $themeId');
        // Light Dracula theme should use very subtle floating elements
        backgroundPainter = SubtleFloatingElementsPainter(
          primaryColor: adjustedPrimary,
          secondaryColor: adjustedSecondary,
          config: currentTheme.effects.backgroundEffects,
          opacity: 0.12, // Dark patterns on white needs proper opacity
        );
      }
    } else if (themeId.contains('expressive')) {
      debugPrint('✅ ThemeBackgroundWidget: Creating STATIC ExpressiveGeometricPainter for theme: $themeId (${isDarkTheme ? 'DARK' : 'LIGHT'})');
      backgroundPainter = ExpressiveGeometricPainter(
        primaryColor: adjustedPrimary,
        secondaryColor: adjustedSecondary,
        config: currentTheme.effects.backgroundEffects,
        opacity: isDarkTheme ? 1.0 : 0.18, // Dark patterns on white for light themes
      );
    } else {
      // Default background for any unhandled themes
      debugPrint('✅ ThemeBackgroundWidget: Creating STATIC default background for theme: $themeId (${isDarkTheme ? 'DARK' : 'LIGHT'})');
      backgroundPainter = SubtleFloatingElementsPainter(
        primaryColor: adjustedPrimary,
        secondaryColor: adjustedSecondary,
        config: currentTheme.effects.backgroundEffects,
        opacity: isDarkTheme ? 0.9 : 0.15, // Dark patterns on white for light themes
      );
    }
    
    debugPrint('🎆 ThemeBackgroundWidget: Creating Stack with STATIC background painter');

    return Stack(
      children: [
        // Base background color - WHITE/LIGHT for light themes, DARK for dark themes
        Positioned.fill(
          child: Container(
            color: isDarkTheme 
                ? const Color(0xFF0D1117) // Dark background for dark themes
                : Colors.white, // PURE WHITE background for light themes
          ),
        ),
        // Static background effect layer
        Positioned.fill(
          child: CustomPaint(
            painter: backgroundPainter,
            child: Container(),
          ),
        ),
        // App content with transparent background to allow background to show through
        Container(
          color: Colors.transparent,
          child: child,
        ),
      ],
    );
  }
}