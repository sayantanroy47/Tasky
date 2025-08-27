import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/enhanced_theme_provider.dart';

/// Optimized theme background widget that uses pre-generated PNG assets
/// instead of computing gradients at runtime for better performance
class OptimizedThemeBackgroundWidget extends ConsumerWidget {
  final Widget child;
  final bool useRadialGradient;
  
  const OptimizedThemeBackgroundWidget({
    super.key,
    required this.child,
    this.useRadialGradient = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(enhancedThemeProvider);
    final currentTheme = themeState.currentTheme;
    
    if (currentTheme == null) {
      return child;
    }

    // Get theme ID and determine if it's dark mode
    final themeId = currentTheme.metadata.id;
    final isDark = themeId.contains('_dark');
    
    // Extract theme name from ID
    String themeName = themeId
        .replaceAll('_dark', '')
        .replaceAll('_light', '');
    
    // Map theme IDs to asset names
    final assetName = _getBackgroundAssetName(themeName, isDark);
    
    return Stack(
      children: [
        // Theme base background color as fallback
        Positioned.fill(
          child: Container(
            color: currentTheme.colors.background,
          ),
        ),
        // Pre-generated PNG background
        if (assetName != null)
          Positioned.fill(
            child: Image.asset(
              assetName,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to solid color if PNG fails to load
                return Container(
                  color: currentTheme.colors.background,
                );
              },
            ),
          ),
        // App content with transparent background
        Container(
          color: Colors.transparent,
          child: child,
        ),
      ],
    );
  }

  /// Get the appropriate background asset name for the theme
  String? _getBackgroundAssetName(String themeName, bool isDark) {
    // Map of theme names to their unique background assets
    final uniqueThemes = {
      'matrix',
      'cyberpunk_2077', 
      'dracula_ide',
      'artist_palette',
      'vegeta_blue',
      'autumn_forest',
      'unicorn_dream',
      'demon_slayer_flame',
      'hollow_knight_shadow',
      'starfield_cosmic',
      'executive_platinum',
    };

    final variant = isDark ? 'dark' : 'light';
    
    // Use EPIC backgrounds for supported themes
    if (uniqueThemes.contains(themeName)) {
      return 'assets/backgrounds/${themeName}_${variant}_EPIC.png';
    }
    
    // Fallback to gradient backgrounds for other themes
    final gradientType = useRadialGradient ? 'radial' : 'linear';
    return 'assets/backgrounds/${themeName}_${variant}_$gradientType.png';
  }
}

/// Extension to easily replace the existing ThemeBackgroundWidget
extension OptimizedThemeBackground on Widget {
  /// Wrap this widget with an optimized theme background
  Widget withOptimizedThemeBackground({bool useRadialGradient = true}) {
    return OptimizedThemeBackgroundWidget(
      useRadialGradient: useRadialGradient,
      child: this,
    );
  }
}