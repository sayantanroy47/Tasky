import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/enhanced_theme_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Simple theme toggle button that switches between light/dark variants of the same theme
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(enhancedThemeProvider);
    final currentTheme = themeState.currentTheme;
    
    if (currentTheme == null) {
      return const SizedBox.shrink();
    }
    
    final isCurrentlyDark = currentTheme.metadata.id.contains('dark') || 
                           currentTheme.metadata.id.contains('_dark');
    
    return IconButton(
      icon: Icon(isCurrentlyDark ? PhosphorIcons.sun() : PhosphorIcons.moon()),
      tooltip: isCurrentlyDark ? 'Switch to light variant' : 'Switch to dark variant',
      onPressed: () => _toggleThemeVariant(ref, currentTheme.metadata.id),
    );
  }

  void _toggleThemeVariant(WidgetRef ref, String currentThemeId) {
    String targetThemeId;
    
    // Determine the opposite variant using a more robust approach
    if (currentThemeId.contains('_dark')) {
      // Current theme is dark, switch to light variant
      targetThemeId = currentThemeId.replaceAll('_dark', '_light');
      
      // Handle special cases where light theme doesn't have '_light' suffix
      if (targetThemeId.endsWith('_light')) {
        final baseThemeName = targetThemeId.replaceAll('_light', '');
        
        // Check if a light variant exists, otherwise use base name
        final themeNotifier = ref.read(enhancedThemeProvider.notifier);
        final lightThemeExists = themeNotifier.getTheme('${baseThemeName}_light') != null;
        final baseThemeExists = themeNotifier.getTheme(baseThemeName) != null;
        
        if (lightThemeExists) {
          targetThemeId = '${baseThemeName}_light';
        } else if (baseThemeExists) {
          targetThemeId = baseThemeName;
        } else {
          // Fallback: keep the _light suffix
          targetThemeId = '${baseThemeName}_light';
        }
      }
    } else if (currentThemeId.contains('_light')) {
      // Current theme is light, switch to dark variant
      targetThemeId = currentThemeId.replaceAll('_light', '_dark');
    } else {
      // Current theme has no suffix (assumed light), switch to dark variant
      targetThemeId = '${currentThemeId}_dark';
    }
    
    // Verify the target theme exists before applying
    final themeNotifier = ref.read(enhancedThemeProvider.notifier);
    final targetTheme = themeNotifier.getTheme(targetThemeId);
    
    if (targetTheme != null) {
      // Apply the new theme variant
      ref.read(enhancedThemeProvider.notifier).setTheme(targetThemeId);
    } else {
      // If target theme doesn't exist, log the issue but don't crash
      debugPrint('Target theme not found: $targetThemeId for current theme: $currentThemeId');
    }
  }
}

