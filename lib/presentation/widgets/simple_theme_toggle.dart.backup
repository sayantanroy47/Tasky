import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/enhanced_theme_provider.dart';

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
      icon: Icon(isCurrentlyDark ? Icons.light_mode : Icons.dark_mode),
      tooltip: isCurrentlyDark ? 'Switch to light variant' : 'Switch to dark variant',
      onPressed: () => _toggleThemeVariant(ref, currentTheme.metadata.id),
    );
  }

  void _toggleThemeVariant(WidgetRef ref, String currentThemeId) {
    String targetThemeId;
    
    // Determine the opposite variant
    if (currentThemeId.contains('_dark')) {
      // Remove '_dark' suffix to get light variant
      if (currentThemeId == 'expressive_dark') {
        targetThemeId = 'expressive_light';
      } else {
        targetThemeId = currentThemeId.replaceAll('_dark', '');
      }
    } else if (currentThemeId.endsWith('dark')) {
      // Remove 'dark' suffix and add light (for themes like 'matrix_dark')
      targetThemeId = currentThemeId.replaceAll('dark', '');
      if (targetThemeId.endsWith('_')) {
        targetThemeId = targetThemeId.substring(0, targetThemeId.length - 1);
      }
    } else {
      // Current theme is light, switch to dark variant
      if (currentThemeId == 'matrix' || currentThemeId == 'vegeta_blue' || currentThemeId == 'dracula_ide') {
        targetThemeId = '${currentThemeId}_dark';
      } else if (currentThemeId == 'expressive_light') {
        targetThemeId = 'expressive_dark';
      } else {
        // For themes that don't follow the pattern, try adding '_dark'
        targetThemeId = '${currentThemeId}_dark';
      }
    }
    
    // Apply the new theme variant
    ref.read(enhancedThemeProvider.notifier).setTheme(targetThemeId);
  }
}