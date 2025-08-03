import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/theme_provider.dart';
import '../../domain/models/enums.dart';

/// A widget for selecting app theme
class ThemeSelector extends ConsumerWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theme',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Theme mode selector
            Column(
              children: AppThemeMode.values.map((mode) {
                return RadioListTile<AppThemeMode>(
                  title: Text(mode.displayName),
                  subtitle: _getThemeDescription(mode),
                  value: mode,
                  groupValue: themeState.themeMode,
                  onChanged: themeState.isLoading 
                    ? null 
                    : (value) {
                        if (value != null) {
                          ref.read(themeProvider.notifier).setThemeMode(value);
                        }
                      },
                  contentPadding: EdgeInsets.zero,
                );
              }).toList(),
            ),
            
            if (themeState.isLoading) ...[
              const SizedBox(height: 16),
              const Center(
                child: CircularProgressIndicator(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget? _getThemeDescription(AppThemeMode mode) {
    String description;
    switch (mode) {
      case AppThemeMode.system:
        description = 'Follow system theme';
        break;
      case AppThemeMode.light:
        description = 'Always use light theme';
        break;
      case AppThemeMode.dark:
        description = 'Always use dark theme';
        break;
      case AppThemeMode.highContrastLight:
        description = 'High contrast light theme';
        break;
      case AppThemeMode.highContrastDark:
        description = 'High contrast dark theme';
        break;
    }
    
    return Text(
      description,
      style: const TextStyle(fontSize: 12),
    );
  }
}

/// A simple toggle button for switching between light and dark themes
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    
    return IconButton(
      icon: Icon(
        _getThemeIcon(themeState.themeMode, context),
      ),
      onPressed: themeState.isLoading 
        ? null 
        : () => themeNotifier.toggleTheme(),
      tooltip: 'Toggle theme',
    );
  }

  IconData _getThemeIcon(AppThemeMode mode, BuildContext context) {
    switch (mode) {
      case AppThemeMode.light:
      case AppThemeMode.highContrastLight:
        return Icons.light_mode;
      case AppThemeMode.dark:
      case AppThemeMode.highContrastDark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        // Check system brightness
        final brightness = MediaQuery.of(context).platformBrightness;
        return brightness == Brightness.dark 
          ? Icons.dark_mode 
          : Icons.light_mode;
    }
  }
}

/// A compact theme selector for use in app bars or toolbars
class CompactThemeSelector extends ConsumerWidget {
  const CompactThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    
    return PopupMenuButton<AppThemeMode>(
      icon: Icon(_getThemeIcon(themeState.themeMode, context)),
      tooltip: 'Select theme',
      onSelected: (mode) {
        ref.read(themeProvider.notifier).setThemeMode(mode);
      },
      itemBuilder: (context) => AppThemeMode.values.map((mode) {
        return PopupMenuItem<AppThemeMode>(
          value: mode,
          child: Row(
            children: [
              Icon(
                _getThemeIcon(mode, context),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(mode.displayName),
              if (themeState.themeMode == mode) ...[
                const Spacer(),
                Icon(
                  Icons.check,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  IconData _getThemeIcon(AppThemeMode mode, BuildContext context) {
    switch (mode) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.highContrastLight:
        return Icons.contrast;
      case AppThemeMode.highContrastDark:
        return Icons.contrast;
      case AppThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}

/// A theme preview widget that shows how the theme looks
class ThemePreview extends StatelessWidget {
  final AppThemeMode themeMode;
  final bool isSelected;
  final VoidCallback? onTap;

  const ThemePreview({
    super.key,
    required this.themeMode,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected 
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            // Header
            Container(
              height: 20,
              decoration: BoxDecoration(
                color: _getPreviewColor(themeMode, true),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(7),
                  topRight: Radius.circular(7),
                ),
              ),
            ),
            // Body
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: _getPreviewColor(themeMode, false),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(7),
                    bottomRight: Radius.circular(7),
                  ),
                ),
                child: Center(
                  child: Text(
                    themeMode.displayName,
                    style: TextStyle(
                      fontSize: 10,
                      color: _getPreviewTextColor(themeMode),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPreviewColor(AppThemeMode mode, bool isHeader) {
    switch (mode) {
      case AppThemeMode.light:
        return isHeader ? Colors.blue : Colors.white;
      case AppThemeMode.dark:
        return isHeader ? Colors.blue.shade800 : Colors.grey.shade900;
      case AppThemeMode.highContrastLight:
        return isHeader ? Colors.black : Colors.white;
      case AppThemeMode.highContrastDark:
        return isHeader ? Colors.white : Colors.black;
      case AppThemeMode.system:
        return isHeader ? Colors.purple : Colors.grey.shade100;
    }
  }

  Color _getPreviewTextColor(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
      case AppThemeMode.system:
        return Colors.black87;
      case AppThemeMode.dark:
        return Colors.white;
      case AppThemeMode.highContrastLight:
        return Colors.black;
      case AppThemeMode.highContrastDark:
        return Colors.white;
    }
  }
}

/// A horizontal theme selector with previews
class HorizontalThemeSelector extends ConsumerWidget {
  const HorizontalThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Theme',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: AppThemeMode.values.map((mode) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ThemePreview(
                  themeMode: mode,
                  isSelected: themeState.themeMode == mode,
                  onTap: themeState.isLoading 
                    ? null 
                    : () {
                        ref.read(themeProvider.notifier).setThemeMode(mode);
                      },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}