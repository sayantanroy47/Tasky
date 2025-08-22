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
    final themeState = ref.watch(enhancedThemeProvider);
    final currentTheme = themeState.currentTheme;
    
    // Determine theme type and variant
    final themeId = currentTheme?.metadata.id ?? '';
    final isDarkTheme = themeId.contains('dark') || themeId.contains('_dark');
    
    // Get theme-specific gradient (REQ 14: programmatic gradients)
    final Gradient gradient = _getThemeGradient(themeId, isDarkTheme);

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
          // Center-to-outward programmatic gradient background (REQ 14)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(gradient: gradient),
            ),
          ),
          // Dialog content with transparent background
          Container(
            color: Colors.transparent,
            child: child,
          ),
        ],
      ),
    );
  }

  Gradient _getThemeGradient(String themeId, bool isDarkTheme) {
    if (themeId.contains('matrix')) {
      return _getMatrixGradient(isDarkTheme);
    } else if (themeId.contains('vegeta')) {
      return _getVegetaGradient(isDarkTheme);
    } else if (themeId.contains('dracula')) {
      return _getDraculaGradient(isDarkTheme);
    } else if (themeId.contains('expressive')) {
      return _getExpressiveGradient(isDarkTheme);
    } else {
      return _getDefaultGradient(isDarkTheme);
    }
  }

  Gradient _getMatrixGradient(bool isDarkTheme) {
    if (isDarkTheme) {
      return const RadialGradient(
        center: Alignment.center,
        radius: 1.2,
        colors: [
          Color(0xFF0D1B0D), // Dark green center
          Color(0xFF1A2F1A), // Medium green
          Color(0xFF0F1E0F), // Darker green
          Color(0xFF061206), // Very dark green
        ],
        stops: [0.0, 0.4, 0.7, 1.0],
      );
    } else {
      return const RadialGradient(
        center: Alignment.center,
        radius: 1.2,
        colors: [
          Color(0xFFE8F5E8), // Light green center
          Color(0xFFD4E9D4), // Medium light green
          Color(0xFFC1DEC1), // Darker light green
          Color(0xFFAED3AE), // Green edge
        ],
        stops: [0.0, 0.4, 0.7, 1.0],
      );
    }
  }

  Gradient _getVegetaGradient(bool isDarkTheme) {
    if (isDarkTheme) {
      return const RadialGradient(
        center: Alignment.center,
        radius: 1.3,
        colors: [
          Color(0xFF0A0E3F), // Dark blue center
          Color(0xFF1E3A8A), // Medium blue
          Color(0xFF1E40AF), // Bright blue
          Color(0xFF0F172A), // Very dark blue
        ],
        stops: [0.0, 0.3, 0.6, 1.0],
      );
    } else {
      return const RadialGradient(
        center: Alignment.center,
        radius: 1.3,
        colors: [
          Color(0xFFEBF8FF), // Light blue center
          Color(0xFFDCECFB), // Medium light blue
          Color(0xFFBDE0F7), // Brighter light blue
          Color(0xFFA8D4F3), // Blue edge
        ],
        stops: [0.0, 0.3, 0.6, 1.0],
      );
    }
  }

  Gradient _getDraculaGradient(bool isDarkTheme) {
    if (isDarkTheme) {
      return const RadialGradient(
        center: Alignment.center,
        radius: 1.4,
        colors: [
          Color(0xFF2D1B69), // Dark purple center
          Color(0xFF44337A), // Medium purple
          Color(0xFF663399), // Bright purple
          Color(0xFF1A0A2E), // Very dark purple
        ],
        stops: [0.0, 0.4, 0.7, 1.0],
      );
    } else {
      return const RadialGradient(
        center: Alignment.center,
        radius: 1.4,
        colors: [
          Color(0xFFF3E8FF), // Light purple center
          Color(0xFFE6D3FA), // Medium light purple
          Color(0xFFD8B4FE), // Brighter light purple
          Color(0xFFCB9DF0), // Purple edge
        ],
        stops: [0.0, 0.4, 0.7, 1.0],
      );
    }
  }

  Gradient _getExpressiveGradient(bool isDarkTheme) {
    if (isDarkTheme) {
      return const RadialGradient(
        center: Alignment.center,
        radius: 1.5,
        colors: [
          Color(0xFF1A1A2E), // Dark center
          Color(0xFF16213E), // Medium dark
          Color(0xFF0F1419), // Darker
          Color(0xFF0A0B0F), // Very dark
        ],
        stops: [0.0, 0.4, 0.7, 1.0],
      );
    } else {
      return const RadialGradient(
        center: Alignment.center,
        radius: 1.5,
        colors: [
          Color(0xFFFAFAFA), // Light center
          Color(0xFFF1F3F4), // Medium light
          Color(0xFFE4E7EA), // Darker light
          Color(0xFFD7DCE1), // Light edge
        ],
        stops: [0.0, 0.4, 0.7, 1.0],
      );
    }
  }

  Gradient _getDefaultGradient(bool isDarkTheme) {
    if (isDarkTheme) {
      return const RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [
          Color(0xFF1A1A1A), // Dark gray center
          Color(0xFF2D2D2D), // Medium dark gray
          Color(0xFF1F1F1F), // Darker gray
          Color(0xFF0F0F0F), // Very dark gray
        ],
        stops: [0.0, 0.4, 0.7, 1.0],
      );
    } else {
      return const RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [
          Color(0xFFFFFFFF), // White center
          Color(0xFFF8F9FA), // Light gray
          Color(0xFFE9ECEF), // Medium light gray
          Color(0xFFDEE2E6), // Gray edge
        ],
        stops: [0.0, 0.4, 0.7, 1.0],
      );
    }
  }
}