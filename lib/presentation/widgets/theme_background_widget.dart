import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/enhanced_theme_provider.dart';

/// Widget that applies theme-specific static background images
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

    // Determine theme type and variant
    final themeId = currentTheme.metadata.id;
    final isDarkTheme = themeId.contains('dark') || themeId.contains('_dark');
    
    // Get the appropriate background image asset path
    String? backgroundImagePath;
    
    if (themeId.contains('matrix')) {
      backgroundImagePath = isDarkTheme 
        ? 'assets/backgrounds/matrix/matrix_dark.png'
        : 'assets/backgrounds/matrix/matrix_light.png';
    } else if (themeId.contains('vegeta')) {
      backgroundImagePath = isDarkTheme 
        ? 'assets/backgrounds/vegeta/vegeta_dark.png'
        : 'assets/backgrounds/vegeta/vegeta_light.png';
    } else if (themeId.contains('dracula')) {
      backgroundImagePath = isDarkTheme 
        ? 'assets/backgrounds/dracula/dracula_dark.png'
        : 'assets/backgrounds/dracula/dracula_light.png';
    } else if (themeId.contains('expressive')) {
      backgroundImagePath = isDarkTheme 
        ? 'assets/backgrounds/expressive/expressive_dark.png'
        : 'assets/backgrounds/expressive/expressive_light.png';
    }

    return Stack(
      children: [
        // Base background color (fallback)
        Positioned.fill(
          child: Container(
            color: isDarkTheme 
                ? const Color(0xFF0D1117) // Dark background for dark themes
                : const Color(0xFFF8F8F8), // Lightest gray background for light themes
          ),
        ),
        // Static background image
        if (backgroundImagePath != null)
          Positioned.fill(
            child: Image.asset(
              backgroundImagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to solid color if image fails to load
                return Container(
                  color: isDarkTheme 
                      ? const Color(0xFF0D1117)
                      : const Color(0xFFF8F8F8),
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
}