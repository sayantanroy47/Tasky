import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/enhanced_theme_provider.dart';

/// Simple theme toggle button that works
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    
    return IconButton(
      icon: Icon(_getThemeIcon(themeMode)),
      tooltip: 'Toggle theme',
      onPressed: () {
        final newMode = themeMode == ThemeMode.light 
            ? ThemeMode.dark 
            : ThemeMode.light;
        ref.read(themeModeProvider.notifier).state = newMode;
      },
    );
  }

  IconData _getThemeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}