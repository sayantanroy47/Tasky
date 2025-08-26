import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/enhanced_theme_provider.dart';
import '../../core/theme/theme_persistence_service.dart';
import '../widgets/glassmorphism_container.dart';
import '../widgets/standardized_text.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Advanced theme settings page with persistence features
class AdvancedThemeSettingsPage extends ConsumerStatefulWidget {
  const AdvancedThemeSettingsPage({super.key});

  @override
  ConsumerState<AdvancedThemeSettingsPage> createState() => _AdvancedThemeSettingsPageState();
}

class _AdvancedThemeSettingsPageState extends ConsumerState<AdvancedThemeSettingsPage> {
  bool _exportInProgress = false;
  bool _importInProgress = false;

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(enhancedThemeProvider);
    final themeNotifier = ref.watch(enhancedThemeProvider.notifier);
    final favoriteThemes = ref.watch(favoriteThemesProvider);
    final mostUsedThemes = ref.watch(mostUsedThemesProvider);
    final usageStats = ref.watch(themeUsageStatsProvider);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const StandardizedText('Advanced Theme Settings', style: StandardizedTextStyle.titleLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Theme Info
            _buildCurrentThemeSection(themeState),
            const SizedBox(height: 24),

            // Theme Preferences
            _buildPreferencesSection(themeState.preferences, themeNotifier),
            const SizedBox(height: 24),

            // Favorite Themes
            _buildFavoriteThemesSection(favoriteThemes, themeNotifier),
            const SizedBox(height: 24),

            // Usage Statistics
            _buildUsageStatsSection(mostUsedThemes, usageStats),
            const SizedBox(height: 24),

            // Data Management
            _buildDataManagementSection(themeNotifier),
            const SizedBox(height: 24),

            // Advanced Actions
            _buildAdvancedActionsSection(themeNotifier),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentThemeSection(EnhancedThemeState themeState) {
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIcons.palette(), color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              StandardizedTextVariants.sectionHeader('Current Theme'),
            ],
          ),
          const SizedBox(height: 16),
          if (themeState.currentTheme != null) ...[
            _buildThemeInfoRow('Name', themeState.currentTheme!.metadata.name),
            _buildThemeInfoRow('Category', themeState.currentTheme!.metadata.category),
            _buildThemeInfoRow('Description', themeState.currentTheme!.metadata.description),
            if (themeState.currentTheme!.metadata.tags.isNotEmpty)
              _buildThemeInfoRow('Tags', themeState.currentTheme!.metadata.tags.join(', ')),
            const SizedBox(height: 16),
            if (themeState.usageStats.containsKey(themeState.currentThemeId))
              _buildUsageInfo(themeState.usageStats[themeState.currentThemeId]!),
          ] else
            const StandardizedText('No theme loaded', style: StandardizedTextStyle.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection(ThemePreferences preferences, EnhancedThemeNotifier notifier) {
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIcons.gear(), color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              StandardizedTextVariants.sectionHeader('Theme Preferences'),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const StandardizedText('Follow System Theme', style: StandardizedTextStyle.titleMedium),
            subtitle: const StandardizedText('Automatically switch between light and dark themes', style: StandardizedTextStyle.bodyMedium),
            value: preferences.followSystemTheme,
            onChanged: (value) {
              final updatedPreferences = preferences.copyWith(followSystemTheme: value);
              notifier.saveThemePreferences(updatedPreferences);
            },
          ),
          SwitchListTile(
            title: const StandardizedText('Auto Theme Switching', style: StandardizedTextStyle.titleMedium),
            subtitle: const StandardizedText('Automatically switch themes at scheduled times', style: StandardizedTextStyle.bodyMedium),
            value: preferences.autoSwitchEnabled,
            onChanged: (value) {
              final updatedPreferences = preferences.copyWith(autoSwitchEnabled: value);
              notifier.saveThemePreferences(updatedPreferences);
            },
          ),
          SwitchListTile(
            title: const StandardizedText('Theme Animations', style: StandardizedTextStyle.titleMedium),
            subtitle: const StandardizedText('Enable smooth theme transition animations', style: StandardizedTextStyle.bodyMedium),
            value: preferences.animationsEnabled,
            onChanged: (value) {
              final updatedPreferences = preferences.copyWith(animationsEnabled: value);
              notifier.saveThemePreferences(updatedPreferences);
            },
          ),
          const SizedBox(height: 16),
          StandardizedText(
            'Animation Duration: ${preferences.animationDuration.inMilliseconds}ms',
            style: StandardizedTextStyle.bodyMedium,
          ),
          Slider(
            value: preferences.animationDuration.inMilliseconds.toDouble(),
            min: 100,
            max: 1000,
            divisions: 18,
            label: '${preferences.animationDuration.inMilliseconds}ms',
            onChanged: (value) {
              final updatedPreferences = preferences.copyWith(
                animationDuration: Duration(milliseconds: value.toInt()),
              );
              notifier.saveThemePreferences(updatedPreferences);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteThemesSection(List<dynamic> favoriteThemes, EnhancedThemeNotifier notifier) {
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIcons.heart(), color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              StandardizedTextVariants.sectionHeader('Favorite Themes'),
              const Spacer(),
              StandardizedText(
                '${favoriteThemes.length} themes',
                style: StandardizedTextStyle.bodyMedium,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (favoriteThemes.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      PhosphorIcons.heart(),
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    StandardizedText(
                      'No favorite themes yet',
                      style: StandardizedTextStyle.bodyMedium,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            )
          else
            ...favoriteThemes.take(3).map((theme) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: StandardizedText(
                    theme.metadata.name.substring(0, 1).toUpperCase(),
                    style: StandardizedTextStyle.bodyMedium,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                title: StandardizedText(theme.metadata.name, style: StandardizedTextStyle.titleMedium),
                subtitle: StandardizedText(theme.metadata.category, style: StandardizedTextStyle.bodyMedium),
                trailing: IconButton(
                  icon: Icon(PhosphorIcons.heart()),
                  color: Colors.red,
                  onPressed: () => notifier.toggleFavoriteTheme(theme.metadata.id),
                ),
                onTap: () => notifier.setTheme(theme.metadata.id),
              ),
            )),
          if (favoriteThemes.length > 3)
            Center(
              child: TextButton(
                onPressed: () {
                  // Navigate to full favorites list
                },
                child: StandardizedText('View all ${favoriteThemes.length} favorites', style: StandardizedTextStyle.buttonText),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUsageStatsSection(List<dynamic> mostUsedThemes, Map<String, ThemeUsageStats> usageStats) {
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIcons.chartBar(), color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              StandardizedTextVariants.sectionHeader('Usage Statistics'),
            ],
          ),
          const SizedBox(height: 16),
          if (mostUsedThemes.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: StandardizedText(
                  'No usage data available yet',
                  style: StandardizedTextStyle.bodyMedium,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            ...mostUsedThemes.take(5).map((theme) {
              final stats = usageStats[theme.metadata.id];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StandardizedText(
                            theme.metadata.name,
                            style: StandardizedTextStyle.titleMedium,
                          ),
                          if (stats != null) ...[
                            StandardizedText(
                              'Used ${stats.usageCount} times',
                              style: StandardizedTextStyle.bodySmall,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            StandardizedText(
                              'Last used: ${_formatDate(stats.lastUsed)}',
                              style: StandardizedTextStyle.bodySmall,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (stats != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: StandardizedText(
                          '${stats.usageCount}',
                          style: StandardizedTextStyle.labelMedium,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildDataManagementSection(EnhancedThemeNotifier notifier) {
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIcons.database(), color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              StandardizedTextVariants.sectionHeader('Data Management'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _exportInProgress ? null : () => _exportThemeData(notifier),
                  icon: _exportInProgress 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(PhosphorIcons.download()),
                  label: StandardizedText(_exportInProgress ? 'Exporting...' : 'Export Data', style: StandardizedTextStyle.buttonText),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _importInProgress ? null : () => _importThemeData(notifier),
                  icon: _importInProgress 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(PhosphorIcons.upload()),
                  label: StandardizedText(_importInProgress ? 'Importing...' : 'Import Data', style: StandardizedTextStyle.buttonText),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          StandardizedText(
            'Export your theme preferences and custom themes for backup, or import data from another device.',
            style: StandardizedTextStyle.bodySmall,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedActionsSection(EnhancedThemeNotifier notifier) {
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIcons.wrench(), color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              StandardizedTextVariants.sectionHeader('Advanced Actions'),
            ],
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(PhosphorIcons.shuffle()),
            title: const StandardizedText('Random Theme', style: StandardizedTextStyle.titleMedium),
            subtitle: const StandardizedText('Apply a random theme', style: StandardizedTextStyle.bodyMedium),
            onTap: () => notifier.applyRandomTheme(),
          ),
          ListTile(
            leading: Icon(PhosphorIcons.arrowClockwise()),
            title: const StandardizedText('Reset to Default', style: StandardizedTextStyle.titleMedium),
            subtitle: const StandardizedText('Reset to the default theme', style: StandardizedTextStyle.bodyMedium),
            onTap: () => notifier.resetToDefault(),
          ),
          ListTile(
            leading: Icon(PhosphorIcons.trash(), color: Theme.of(context).colorScheme.error),
            title: StandardizedText(
              'Clear All Data',
              style: StandardizedTextStyle.titleMedium,
              color: Theme.of(context).colorScheme.error,
            ),
            subtitle: const StandardizedText('Remove all theme data and preferences', style: StandardizedTextStyle.bodyMedium),
            onTap: () => _showClearDataDialog(notifier),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: StandardizedText(
              '$label:',
              style: StandardizedTextStyle.titleSmall,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: StandardizedText(
              value,
              style: StandardizedTextStyle.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageInfo(ThemeUsageStats stats) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StandardizedText(
            'Usage Statistics',
            style: StandardizedTextStyle.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const StandardizedText('Times used:', style: StandardizedTextStyle.bodySmall),
              StandardizedText('${stats.usageCount}', style: StandardizedTextStyle.bodySmall),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const StandardizedText('Last used:', style: StandardizedTextStyle.bodySmall),
              StandardizedText(_formatDate(stats.lastUsed), style: StandardizedTextStyle.bodySmall),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const StandardizedText('First used:', style: StandardizedTextStyle.bodySmall),
              StandardizedText(_formatDate(stats.firstUsed), style: StandardizedTextStyle.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _exportThemeData(EnhancedThemeNotifier notifier) async {
    setState(() {
      _exportInProgress = true;
    });

    try {
      final data = await notifier.exportThemeData();
      if (data != null) {
        // In a real app, you'd save this to a file or share it
        // For demo purposes, just show a success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: StandardizedText(
                'Theme data exported successfully (${data.keys.length} items)', 
                style: StandardizedTextStyle.bodyMedium,
                color: Theme.of(context).colorScheme.onTertiary, // Proper contrast for success color
              ),
              backgroundColor: Theme.of(context).colorScheme.tertiary, // Use theme's success color
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: StandardizedText(
                'Failed to export theme data', 
                style: StandardizedTextStyle.bodyMedium,
                color: Theme.of(context).colorScheme.onError, // Proper contrast for error color
              ),
              backgroundColor: Theme.of(context).colorScheme.error, // Use theme's error color
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _exportInProgress = false;
        });
      }
    }
  }

  Future<void> _importThemeData(EnhancedThemeNotifier notifier) async {
    setState(() {
      _importInProgress = true;
    });

    try {
      // In a real app, you'd select and read a file
      // For demo purposes, just show a message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: StandardizedText(
              'Import feature would open file picker in real app', 
              style: StandardizedTextStyle.bodyMedium,
              color: Theme.of(context).colorScheme.onPrimary, // Proper contrast for info color
            ),
            backgroundColor: Theme.of(context).colorScheme.primary, // Use theme's primary color for info
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _importInProgress = false;
        });
      }
    }
  }

  void _showClearDataDialog(EnhancedThemeNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const StandardizedText('Clear All Theme Data', style: StandardizedTextStyle.titleLarge),
        content: const StandardizedText(
          'This will remove all theme preferences, custom themes, usage statistics, and favorites. This action cannot be undone.',
          style: StandardizedTextStyle.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const StandardizedText('Cancel', style: StandardizedTextStyle.buttonText),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              final colorScheme = Theme.of(context).colorScheme;
              navigator.pop();
              final success = await notifier.clearAllThemeData();
              if (mounted) {
                messenger.showSnackBar(
                  SnackBar(
                    content: StandardizedText(
                      success 
                        ? 'All theme data cleared successfully'
                        : 'Failed to clear theme data', 
                      style: StandardizedTextStyle.bodyMedium,
                      color: success 
                        ? colorScheme.onTertiary // Success contrast
                        : colorScheme.onError,   // Error contrast
                    ),
                    backgroundColor: success 
                      ? colorScheme.tertiary // Success color
                      : colorScheme.error,    // Error color
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const StandardizedText('Clear All', style: StandardizedTextStyle.buttonText),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

