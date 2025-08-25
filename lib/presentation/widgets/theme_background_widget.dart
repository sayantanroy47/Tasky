import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/enhanced_theme_provider.dart';
import 'standardized_colors.dart';

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

    // Determine theme type and variant
    final themeId = currentTheme.metadata.id;
    final isDarkTheme = themeId.contains('dark') || themeId.contains('_dark');
    
    // Get theme-specific gradient
    final Gradient gradient = _getThemeGradient(themeId, isDarkTheme);

    return Stack(
      children: [
        // Center-to-outward gradient background
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

  Gradient _getThemeGradient(String themeId, bool isDarkTheme) {
    if (themeId.contains('matrix')) {
      return _getMatrixGradient(isDarkTheme);
    } else if (themeId.contains('vegeta')) {
      return _getVegetaGradient(isDarkTheme);
    } else if (themeId.contains('goku')) {
      return _getGokuGradient(isDarkTheme);
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
          Color(0xFF000000), // Pure black center
          Color(0xFF000510), // Nearly black with blue hint
          Color(0xFF001020), // Very dark blue
          Color(0xFF000000), // Pure black edge
        ],
        stops: [0.0, 0.3, 0.6, 1.0],
      );
    } else {
      return const RadialGradient(
        center: Alignment.center,
        radius: 1.3,
        colors: [
          Color(0xFFE0F2FE), // Light blue center
          Color(0xFFBAE6FD), // Medium light blue
          Color(0xFF7DD3FC), // Bright light blue
          Color(0xFF0EA5E9), // Blue edge
        ],
        stops: [0.0, 0.3, 0.6, 1.0],
      );
    }
  }

  Gradient _getGokuGradient(bool isDarkTheme) {
    if (isDarkTheme) {
      return const RadialGradient(
        center: Alignment.center,
        radius: 1.4,
        colors: [
          Color(0xFF1A0D26), // Purple void center
          Color(0xFF2D1B3D), // Purple shadow
          Color(0xFF3D2A4F), // Dark purple
          Color(0xFF1A0D26), // Purple void edge
        ],
        stops: [0.0, 0.3, 0.7, 1.0],
      );
    } else {
      return const RadialGradient(
        center: Alignment.center,
        radius: 1.4,
        colors: [
          Color(0xFFFFFBFF), // Pure white center
          Color(0xFFF5F5F5), // Light silver
          Color(0xFFE6F3FF), // Soft ethereal glow
          Color(0xFFFF6600), // Vibrant orange edge
        ],
        stops: [0.0, 0.4, 0.7, 1.0],
      );
    }
  }

  Gradient _getDraculaGradient(bool isDarkTheme) {
    if (isDarkTheme) {
      return const RadialGradient(
        center: Alignment.center,
        radius: 1.1,
        colors: [
          Color(0xFF282A36), // Dark purple center
          Color(0xFF44475A), // Medium purple
          Color(0xFF6272A4), // Brighter purple
          Color(0xFF21222C), // Very dark purple
        ],
        stops: [0.0, 0.4, 0.7, 1.0],
      );
    } else {
      return const RadialGradient(
        center: Alignment.center,
        radius: 1.1,
        colors: [
          Color(0xFFF8F8F2), // Light cream center
          Color(0xFFE5E5E5), // Light gray
          Color(0xFFD6D6D6), // Medium gray
          Color(0xFFC4C4C4), // Darker gray edge
        ],
        stops: [0.0, 0.4, 0.7, 1.0],
      );
    }
  }

  Gradient _getExpressiveGradient(bool isDarkTheme) {
    if (isDarkTheme) {
      return const RadialGradient(
        center: Alignment.center,
        radius: 1.4,
        colors: [
          Color(0xFF1F2937), // Dark gray center
          Color(0xFF374151), // Medium gray
          Color(0xFF4B5563), // Lighter gray
          Color(0xFF111827), // Very dark gray
        ],
        stops: [0.0, 0.3, 0.6, 1.0],
      );
    } else {
      return const RadialGradient(
        center: Alignment.center,
        radius: 1.4,
        colors: [
          Color(0xFFFFFBEB), // Warm white center
          Color(0xFFFEF3C7), // Light yellow
          Color(0xFFFDE68A), // Medium yellow
          Color(0xFFF59E0B), // Amber edge
        ],
        stops: [0.0, 0.3, 0.6, 1.0],
      );
    }
  }

  Gradient _getDefaultGradient(bool isDarkTheme) {
    if (isDarkTheme) {
      return const RadialGradient(
        center: Alignment.center,
        radius: 1.2,
        colors: [
          Color(0xFF1E293B), // Dark slate center
          Color(0xFF334155), // Medium slate
          Color(0xFF475569), // Lighter slate
          Color(0xFF0F172A), // Very dark slate
        ],
        stops: [0.0, 0.4, 0.7, 1.0],
      );
    } else {
      return const RadialGradient(
        center: Alignment.center,
        radius: 1.2,
        colors: [
          Color(0xFFFFFFFF), // Pure white center
          Color(0xFFF8FAFC), // Very light gray
          Color(0xFFE2E8F0), // Light gray
          Color(0xFFCBD5E1), // Medium gray edge
        ],
        stops: [0.0, 0.4, 0.7, 1.0],
      );
    }
  }
}