import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/enhanced_theme_provider.dart';

/// Helper widget that provides theme-specific background for dialogs
class ThemeAwareDialogBackground extends ConsumerWidget {
  final Widget child;
  final double? width;
  final double? height;

  const ThemeAwareDialogBackground({
    super.key,
    required this.child,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeState = ref.watch(enhancedThemeProvider);
    final currentTheme = themeState.currentTheme;
    
    // Determine theme type and variant
    final themeId = currentTheme?.metadata.id ?? '';
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
    }

    final screenSize = MediaQuery.of(context).size;
    
    return Container(
      width: width ?? screenSize.width,
      height: height ?? screenSize.height,
      decoration: const BoxDecoration(
        // No border radius for full-page dialogs
        // No border for full-page dialogs
        // No shadow for full-page dialogs
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Base background color (fallback)
          Positioned.fill(
            child: Container(
              color: isDarkTheme 
                  ? const Color(0xFF0D1117) // Dark background for dark themes
                  : const Color(0xFFF8F8F8), // Light background for light themes
            ),
          ),
          // Background image if available
          if (backgroundImagePath != null)
            Positioned.fill(
              child: Image.asset(
                backgroundImagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to theme background color if image fails to load
                  return Container(
                    color: theme.colorScheme.surface,
                  );
                },
              ),
            ),
          // Dialog content
          child,
        ],
      ),
    );
  }
}