import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/theme_provider.dart';

/// Widget for selecting app theme mode
class ThemeSelector extends ConsumerWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Theme Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Theme mode selection
            Text(
              'Theme Mode',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            
            ...AppThemeMode.values.map((mode) {
              return RadioListTile<AppThemeMode>(
                title: Text(mode.displayName),
                subtitle: _getThemeDescription(mode),
                value: mode,
                groupValue: themeState.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    themeNotifier.setThemeMode(value);
                  }
                },
                contentPadding: EdgeInsets.zero,
              );
            }),
            
            const SizedBox(height: 16),
            
            // Dynamic color toggle
            SwitchListTile(
              title: const Text('Dynamic Color'),
              subtitle: const Text('Use system color scheme when available'),
              value: themeState.isDynamicColorEnabled,
              onChanged: (value) {
                themeNotifier.setDynamicColorEnabled(value);
              },
              contentPadding: EdgeInsets.zero,
            ),
            
            const SizedBox(height: 16),
            
            // Quick theme toggle button
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => themeNotifier.toggleTheme(),
                    icon: Icon(
                      themeNotifier.isDarkMode(context) 
                        ? Icons.light_mode 
                        : Icons.dark_mode,
                    ),
                    label: Text(
                      themeNotifier.isDarkMode(context) 
                        ? 'Switch to Light' 
                        : 'Switch to Dark',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget? _getThemeDescription(AppThemeMode mode) {
    final description = switch (mode) {
      AppThemeMode.system => 'Follow system settings',
      AppThemeMode.light => 'Always use light theme',
      AppThemeMode.dark => 'Always use dark theme',
      AppThemeMode.highContrastLight => 'High contrast light theme for accessibility',
      AppThemeMode.highContrastDark => 'High contrast dark theme for accessibility',
    };
    
    return Text(
      description,
      style: const TextStyle(fontSize: 12),
    );
  }
}

/// Simple theme toggle button for quick access
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.read(themeProvider.notifier);
    
    return IconButton(
      onPressed: () => themeNotifier.toggleTheme(),
      icon: Icon(
        themeNotifier.isDarkMode(context) 
          ? Icons.light_mode 
          : Icons.dark_mode,
      ),
      tooltip: themeNotifier.isDarkMode(context) 
        ? 'Switch to Light Theme' 
        : 'Switch to Dark Theme',
    );
  }
}