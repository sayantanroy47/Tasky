import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/providers/enhanced_theme_provider.dart';
import '../../../core/theme/app_theme_data.dart';
import '../../../core/theme/typography_constants.dart';

/// Compact theme selector for app bars and settings
class CompactThemeSelector extends ConsumerWidget {
  final bool showLabel;
  final bool showCurrentTheme;

  const CompactThemeSelector({
    super.key,
    this.showLabel = true,
    this.showCurrentTheme = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(enhancedThemeProvider);
    final themes = ref.watch(availableThemesProvider);

    if (themeState.isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return PopupMenuButton<String>(
      icon: Icon(
        themeState.currentTheme?.metadata.previewIcon ?? PhosphorIcons.palette(),
        size: 20,
      ),
      tooltip: 'Select Theme',
      offset: const Offset(0, 40),
      itemBuilder: (context) => [
        if (showCurrentTheme && themeState.currentTheme != null) ...[
          PopupMenuItem<String>(
            enabled: false,
            child: _buildCurrentThemeHeader(themeState.currentTheme!),
          ),
          const PopupMenuDivider(),
        ],
        ...themes.map((theme) => _buildThemeMenuItem(
              theme,
              theme.metadata.id == themeState.currentTheme?.metadata.id,
            )),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: '__random__',
          child: Row(
            children: [
              Icon(PhosphorIcons.shuffle(), size: 16),
              const SizedBox(width: 12),
              const Text('Random Theme'),
              const Spacer(),
              Icon(
                PhosphorIcons.shuffle(),
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == '__random__') {
          ref.read(enhancedThemeProvider.notifier).applyRandomTheme();
        } else {
          ref.read(enhancedThemeProvider.notifier).setTheme(value);
        }
      },
    );
  }

  Widget _buildCurrentThemeHeader(AppThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Current Theme',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              theme.metadata.previewIcon,
              size: 16,
              color: theme.colors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                theme.metadata.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            _buildColorSwatch(theme.colors.primary, 12),
            const SizedBox(width: 4),
            _buildColorSwatch(theme.colors.secondary, 12),
          ],
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildThemeMenuItem(AppThemeData theme, bool isSelected) {
    return PopupMenuItem<String>(
      value: theme.metadata.id,
      child: Row(
        children: [
          Icon(
            theme.metadata.previewIcon,
            size: 16,
            color: theme.colors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  theme.metadata.name,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
                Text(
                  _formatCategory(theme.metadata.category),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildColorSwatch(theme.colors.primary, 10),
              const SizedBox(width: 2),
              _buildColorSwatch(theme.colors.secondary, 10),
              const SizedBox(width: 2),
              _buildColorSwatch(theme.colors.accent, 10),
            ],
          ),
          if (isSelected) ...[
            const SizedBox(width: 8),
            Icon(
              PhosphorIcons.checkCircle(),
              size: 16,
              color: theme.colors.primary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildColorSwatch(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
    );
  }

  String _formatCategory(String category) {
    return category.split('_').map((word) => word.substring(0, 1).toUpperCase() + word.substring(1)).join(' ');
  }
}

/// Quick theme cycle button
class QuickThemeCycleButton extends ConsumerWidget {
  final IconData? icon;
  final String? tooltip;

  const QuickThemeCycleButton({
    super.key,
    this.icon,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(enhancedThemeProvider);

    return IconButton(
      icon: Icon(icon ?? PhosphorIcons.palette()),
      tooltip: tooltip ?? 'Cycle Theme',
      onPressed: themeState.canTransition
          ? () {
              ref.read(enhancedThemeProvider.notifier).cycleToNextTheme();
            }
          : null,
    );
  }
}

/// Theme history dropdown
class ThemeHistorySelector extends ConsumerWidget {
  const ThemeHistorySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(themeHistoryProvider);
    final currentTheme = ref.watch(enhancedThemeProvider).currentTheme;

    if (history.isEmpty) {
      return const SizedBox();
    }

    return PopupMenuButton<String>(
      icon: Icon(PhosphorIcons.clockCounterClockwise()),
      tooltip: 'Theme History',
      itemBuilder: (context) => [
        const PopupMenuItem<String>(
          enabled: false,
          child: Text(
            'Recent Themes',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
        const PopupMenuDivider(),
        ...history.map((theme) => PopupMenuItem<String>(
              value: theme.metadata.id,
              child: Row(
                children: [
                  Icon(
                    theme.metadata.previewIcon,
                    size: 16,
                    color: theme.colors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(theme.metadata.name)),
                  if (currentTheme?.metadata.id == theme.metadata.id)
                    Icon(
                      PhosphorIcons.check(),
                      size: 16,
                      color: theme.colors.primary,
                    ),
                ],
              ),
            )),
      ],
      onSelected: (themeId) {
        ref.read(enhancedThemeProvider.notifier).setTheme(themeId);
      },
    );
  }
}

/// Theme category quick selector
class ThemeCategoryQuickSelector extends ConsumerWidget {
  const ThemeCategoryQuickSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(themeCategoriesProvider);
    // final currentTheme = ref.watch(enhancedThemeProvider).currentTheme;

    return PopupMenuButton<String>(
      icon: Icon(PhosphorIcons.square()),
      tooltip: 'Browse by Category',
      itemBuilder: (context) => [
        const PopupMenuItem<String>(
          enabled: false,
          child: Text(
            'Theme Categories',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
        const PopupMenuDivider(),
        ...categories.map((category) {
          final categoryThemes = ref.read(enhancedThemeProvider.notifier).getThemesByCategory(category);

          return PopupMenuItem<String>(
            value: category,
            child: Row(
              children: [
                _getCategoryIcon(category),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_formatCategoryName(category)),
                      Text(
                        '${categoryThemes.length} themes',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Show category color swatches
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: categoryThemes
                      .take(3)
                      .map(
                        (theme) => Padding(
                          padding: const EdgeInsets.only(left: 2),
                          child: _buildColorSwatch(theme.colors.primary, 8),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          );
        }),
      ],
      onSelected: (category) {
        // Navigate to category or show category themes
        _showCategoryThemes(context, ref, category);
      },
    );
  }

  Widget _getCategoryIcon(String category) {
    IconData iconData;
    switch (category) {
      case 'gaming':
        iconData = PhosphorIcons.gameController();
        break;
      case 'developer':
        iconData = PhosphorIcons.code();
        break;
      case 'professional':
        iconData = PhosphorIcons.briefcase();
        break;
      case 'dark':
        iconData = PhosphorIcons.moon();
        break;
      case 'light':
        iconData = PhosphorIcons.sun();
        break;
      default:
        iconData = PhosphorIcons.square();
    }
    return Icon(iconData, size: 16);
  }

  String _formatCategoryName(String category) {
    return category.split('_').map((word) => word.substring(0, 1).toUpperCase() + word.substring(1)).join(' ');
  }

  Widget _buildColorSwatch(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
    );
  }

  void _showCategoryThemes(BuildContext context, WidgetRef ref, String category) {
    final themes = ref.read(enhancedThemeProvider.notifier).getThemesByCategory(category);

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatCategoryName(category),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.5,
                ),
                itemCount: themes.length,
                itemBuilder: (context, index) {
                  final theme = themes[index];
                  return InkWell(
                    onTap: () {
                      ref.read(enhancedThemeProvider.notifier).setTheme(theme.metadata.id);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colors.surface,
                        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                        border: Border.all(color: theme.colors.outline),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            theme.metadata.previewIcon,
                            color: theme.colors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              theme.metadata.name,
                              style: TextStyle(
                                color: theme.colors.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
