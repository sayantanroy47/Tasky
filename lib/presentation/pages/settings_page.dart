import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/design_system/design_tokens.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/typography_constants.dart';
import '../../services/background/simple_background_service.dart';
import '../../services/platform/platform_service_adapter.dart';
import '../widgets/batch_task_operations_widget.dart';
import '../widgets/enhanced_location_task_dialog.dart';
import '../widgets/glassmorphism_container.dart';
import '../widgets/recurring_task_scheduling_widget.dart';
import '../widgets/simple_theme_toggle.dart';
import '../widgets/standardized_app_bar.dart';
import '../widgets/standardized_text.dart';
import 'ai_settings_page.dart' as ai_settings;
// import 'data_export_page.dart';
import 'help_page.dart';
import 'import_export_page.dart';
import 'location_settings_page.dart';
import 'nearby_tasks_page.dart';
import 'notification_history_page.dart';
import 'notification_settings_page.dart';
import 'profile_settings_page.dart';
import 'projects_page.dart';
import 'tasks_page.dart';
import 'themes_page.dart';
import 'analytics_page.dart';

/// Settings page for app configuration and preferences
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  Widget _buildListTile({
    required BuildContext context,
    required IconData leadingIcon,
    required String title,
    required String subtitle,
    IconData? trailingIcon,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(leadingIcon),
      title: StandardizedText(
        title,
        style: StandardizedTextStyle.titleMedium,
      ),
      subtitle: StandardizedText(
        subtitle,
        style: StandardizedTextStyle.bodyMedium,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      trailing: Icon(trailingIcon ?? PhosphorIcons.caretRight()),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true, // Show phone status bar
      appBar: const StandardizedAppBar(
        title: 'Settings',
        forceBackButton: false, // Settings is main tab - no back button
        actions: [
          ThemeToggleButton(),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(
            top: kToolbarHeight + 8, // App bar height + spacing
            left: 16,
            right: 16,
            bottom: 16,
          ),
          children: [
            // Navigation section
            GlassmorphismContainer(
              padding: const EdgeInsets.all(SpacingTokens.md),
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StandardizedTextVariants.sectionHeader('Navigation'),
                  const SizedBox(height: 16),
                  _buildListTile(
                    context: context,
                    leadingIcon: PhosphorIcons.checkSquare(),
                    title: 'Tasks',
                    subtitle: 'View and manage all tasks',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const TasksPage(),
                        ),
                      );
                    },
                  ),
                  _buildListTile(
                    context: context,
                    leadingIcon: PhosphorIcons.folder(),
                    title: 'Projects',
                    subtitle: 'Organize tasks by projects',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ProjectsPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Analytics section
            GlassmorphismContainer(
              padding: const EdgeInsets.all(SpacingTokens.md),
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StandardizedTextVariants.sectionHeader('Analytics & Insights'),
                  const SizedBox(height: 16),
                  _buildListTile(
                    context: context,
                    leadingIcon: PhosphorIcons.chartBar(),
                    title: 'Task Analytics',
                    subtitle: 'View productivity metrics and insights',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AnalyticsPage(),
                        ),
                      );
                    },
                  ),
                  _buildListTile(
                    context: context,
                    leadingIcon: PhosphorIcons.trendUp(),
                    title: 'Productivity Patterns',
                    subtitle: 'Analyze your task completion trends',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AnalyticsPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Profile section
            GlassmorphismContainer(
              padding: const EdgeInsets.all(SpacingTokens.md),
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StandardizedTextVariants.sectionHeader('Profile'),
                  const SizedBox(height: 16),
                  _buildListTile(
                    context: context,
                    leadingIcon: PhosphorIcons.user(),
                    title: 'Profile Settings',
                    subtitle: 'Manage your profile and personal information',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ProfileSettingsPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Appearance section
            GlassmorphismContainer(
              padding: const EdgeInsets.all(SpacingTokens.md),
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StandardizedTextVariants.sectionHeader('Appearance'),
                  const SizedBox(height: 16),
                  _buildListTile(
                    context: context,
                    leadingIcon: PhosphorIcons.palette(),
                    title: 'Themes',
                    subtitle: 'Customize app appearance',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ThemesPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // AI & Voice section
            GlassmorphismContainer(
              padding: const EdgeInsets.all(SpacingTokens.md),
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StandardizedTextVariants.sectionHeader('AI & Voice'),
                  const SizedBox(height: 16),
                  _buildListTile(
                    context: context,
                    leadingIcon: PhosphorIcons.robot(),
                    title: 'AI Settings',
                    subtitle: 'Configure AI task parsing and features',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ai_settings.AISettingsPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Location section
            GlassmorphismContainer(
              padding: const EdgeInsets.all(SpacingTokens.md),
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StandardizedTextVariants.sectionHeader('Location'),
                  const SizedBox(height: 16),
                  _buildListTile(
                    context: context,
                    leadingIcon: PhosphorIcons.mapPin(),
                    title: 'Location Settings',
                    subtitle: 'Configure location-based features',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LocationSettingsPage(),
                        ),
                      );
                    },
                  ),
                  _buildListTile(
                    context: context,
                    leadingIcon: PhosphorIcons.crosshair(),
                    title: 'Nearby Tasks',
                    subtitle: 'View tasks near your location',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const NearbyTasksPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tasks section
            GlassmorphismContainer(
              padding: const EdgeInsets.all(SpacingTokens.md),
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StandardizedTextVariants.sectionHeader('Tasks'),
                  const SizedBox(height: 16),
                  _buildListTile(
                    context: context,
                    leadingIcon: PhosphorIcons.calendar(),
                    title: 'Today\'s Tasks',
                    subtitle: 'View tasks due today',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const TasksPage(),
                        ),
                      );
                    },
                  ),
                  _buildListTile(
                    context: context,
                    leadingIcon: PhosphorIcons.clock(),
                    title: 'Upcoming Tasks',
                    subtitle: 'View future scheduled tasks',
                    onTap: () {
                      AppRouter.navigateToRoute(context, AppRouter.calendar);
                    },
                  ),
                  _buildListTile(
                    context: context,
                    leadingIcon: PhosphorIcons.repeat(),
                    title: 'Recurring Tasks',
                    subtitle: 'Manage automatic task scheduling',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const RecurringTaskSchedulingWidget(),
                        ),
                      );
                    },
                  ),
                  _buildListTile(
                    context: context,
                    leadingIcon: PhosphorIcons.tree(),
                    title: 'Task Dependencies',
                    subtitle: 'Manage task relationships and prerequisites',
                    onTap: () {
                      Navigator.of(context).pushNamed('/task-dependencies');
                    },
                  ),
                  _buildListTile(
                    context: context,
                    leadingIcon: PhosphorIcons.mapPin(),
                    title: 'Create Location Task',
                    subtitle: 'Add tasks with location-based reminders',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => const EnhancedLocationTaskDialog(),
                      );
                    },
                  ),
                  _buildListTile(
                    context: context,
                    leadingIcon: PhosphorIcons.listChecks(),
                    title: 'Batch Operations',
                    subtitle: 'Manage multiple tasks at once',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const BatchTaskOperationsWidget(),
                        ),
                      );
                    },
                  ),
                  _buildListTile(
                    context: context,
                    leadingIcon: PhosphorIcons.bell(),
                    title: 'Notification Settings',
                    subtitle: 'Configure task reminders and alerts',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const NotificationSettingsPage(),
                        ),
                      );
                    },
                  ),
                  _buildListTile(
                    context: context,
                    leadingIcon: PhosphorIcons.clockCounterClockwise(),
                    title: 'Notification History',
                    subtitle: 'View past notifications',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const NotificationHistoryPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(PhosphorIcons.arrowsClockwise()),
                    title: const StandardizedText('Auto Sync', style: StandardizedTextStyle.titleMedium),
                    subtitle: const StandardizedText('Sync tasks across devices', style: StandardizedTextStyle.bodyMedium),
                    trailing: Switch(
                      value: false,
                      onChanged: (value) {
                        // Handle sync settings toggle
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: StandardizedText(value ? 'Auto sync enabled' : 'Auto sync disabled', style: StandardizedTextStyle.bodyMedium),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Data section
            GlassmorphismContainer(
              padding: const EdgeInsets.all(SpacingTokens.md),
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StandardizedTextVariants.sectionHeader('Data'),
                  const SizedBox(height: 16),
                  _buildListTile(
                    context: context,
                    leadingIcon: PhosphorIcons.arrowsCounterClockwise(),
                    title: 'Import & Export',
                    subtitle: 'Backup and restore your tasks',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ImportExportPage(),
                        ),
                      );
                    },
                  ),
                  _buildListTile(
                    context: context,
                    leadingIcon: PhosphorIcons.download(),
                    title: 'Data Export',
                    subtitle: 'Export analytics and task data',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const Placeholder(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // System section
            GlassmorphismContainer(
              padding: const EdgeInsets.all(SpacingTokens.md),
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StandardizedTextVariants.sectionHeader('System'),
                  const SizedBox(height: 16),

                  // Background Services Status
                  _buildBackgroundServicesCard(context),

                  const SizedBox(height: 12),

                  _buildListTile(
                    context: context,
                    leadingIcon: PhosphorIcons.cpu(),
                    title: 'Platform Capabilities',
                    subtitle: 'View device capabilities and limitations',
                    onTap: () => _showPlatformCapabilities(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // About section
            GlassmorphismContainer(
              padding: const EdgeInsets.all(SpacingTokens.md),
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StandardizedTextVariants.sectionHeader('About'),
                  const SizedBox(height: 16),
                  _buildListTile(
                    context: context,
                    leadingIcon: PhosphorIcons.question(),
                    title: 'Help & Support',
                    subtitle: 'Get help using the app',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const HelpPage(),
                        ),
                      );
                    },
                  ),
                  _buildListTile(
                    context: context,
                    leadingIcon: PhosphorIcons.info(),
                    title: 'About',
                    subtitle: 'Version 1.0.0',
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'Tasky',
                        applicationVersion: '1.0.0',
                        applicationLegalese: '© 2024 Tasky App',
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build background services status card
  Widget _buildBackgroundServicesCard(BuildContext context) {
    try {
      final backgroundService = SimpleBackgroundService.instance;
      final serviceStatus = backgroundService.getServiceStatus();
      final isRunning = serviceStatus['running'] as bool? ?? false;
      final isEnabled = serviceStatus['service_enabled'] as bool? ?? true;
      final lastCleanup = serviceStatus['last_cleanup'] as String?;
      final lastReminderCheck = serviceStatus['last_reminder_check'] as String?;

      return GlassmorphismContainer(
        level: GlassLevel.content,
        padding: const EdgeInsets.all(SpacingTokens.md),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
        glassTint: Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.5),
        borderColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        borderWidth: 1.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              children: [
                Icon(
                  PhosphorIcons.arrowsClockwise(),
                  color: isRunning && isEnabled ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: StandardizedText(
                    'Background Services',
                    style: StandardizedTextStyle.titleSmall,
                  ),
                ),
                GlassmorphismContainer(
                  level: GlassLevel.interactive,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  borderRadius: BorderRadius.circular(8),
                  glassTint:
                      isRunning && isEnabled ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2) : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                  child: StandardizedText(
                    isRunning && isEnabled ? 'Running' : 'Stopped',
                    style: StandardizedTextStyle.bodySmall,
                    color: isRunning && isEnabled ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Service details
            if (lastCleanup != null) ...[
              Row(
                children: [
                  Icon(
                    PhosphorIcons.broom(),
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StandardizedText(
                      'Last cleanup: ${_formatTimestamp(lastCleanup)}',
                      style: StandardizedTextStyle.bodySmall,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],

            if (lastReminderCheck != null) ...[
              Row(
                children: [
                  Icon(
                    PhosphorIcons.bell(),
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StandardizedText(
                      'Last reminder check: ${_formatTimestamp(lastReminderCheck)}',
                      style: StandardizedTextStyle.bodySmall,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Toggle switch
            Row(
              children: [
                const StandardizedText(
                  'Enable background processing',
                  style: StandardizedTextStyle.bodyMedium,
                ),
                const Spacer(),
                Switch(
                  value: isEnabled,
                  onChanged: (value) async {
                    try {
                      await backgroundService.setServiceEnabled(value);
                      // Force rebuild to update UI
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: StandardizedText(
                              value ? 'Background services enabled' : 'Background services disabled',
                              style: StandardizedTextStyle.bodyMedium,
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: StandardizedText('Failed to update services: $e', style: StandardizedTextStyle.bodyMedium),
                            backgroundColor: Theme.of(context).colorScheme.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('Error building background services card: $e');
      return GlassmorphismContainer(
        level: GlassLevel.content,
        padding: const EdgeInsets.all(SpacingTokens.md),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
        glassTint: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
        borderColor: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
        borderWidth: 1.0,
        child: Row(
          children: [
            Icon(
              PhosphorIcons.warningCircle(),
              color: Theme.of(context).colorScheme.error,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StandardizedText(
                'Background services unavailable',
                style: StandardizedTextStyle.bodyMedium,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      );
    }
  }

  /// Show platform capabilities dialog
  void _showPlatformCapabilities(BuildContext context) {
    try {
      final adapter = PlatformServiceAdapter.instance;
      final capabilities = adapter.serviceCapabilities;
      final supportSummary = capabilities.supportSummary;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const StandardizedText('Platform Capabilities', style: StandardizedTextStyle.titleLarge),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const StandardizedText(
                  'This device supports the following features:',
                  style: StandardizedTextStyle.bodyMedium,
                ),
                const SizedBox(height: 16),

                ...supportSummary.entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            entry.value ? PhosphorIcons.checkCircle() : PhosphorIcons.xCircle(),
                            color: entry.value ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StandardizedText(
                              _formatCapabilityName(entry.key),
                              style: StandardizedTextStyle.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    )),

                const SizedBox(height: 16),

                // Platform specific info
                GlassmorphismContainer(
                  level: GlassLevel.content,
                  padding: const EdgeInsets.all(12),
                  borderRadius: BorderRadius.circular(8),
                  glassTint: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StandardizedTextVariants.cardTitle('Platform Details'),
                      const SizedBox(height: 8),
                      StandardizedText(
                        'Speech Recognition: ${capabilities.speechRecognition.isSupported ? "Supported" : "Not Available"}',
                        style: StandardizedTextStyle.bodySmall,
                      ),
                      StandardizedText(
                        'Audio Recording: ${capabilities.audioRecording.isSupported ? "Supported" : "Not Available"}',
                        style: StandardizedTextStyle.bodySmall,
                      ),
                      StandardizedText(
                        'Background Processing: ${capabilities.backgroundProcessing.isSupported ? "Supported" : "Not Available"}',
                        style: StandardizedTextStyle.bodySmall,
                      ),
                      StandardizedText(
                        'Notifications: ${capabilities.notifications.isSupported ? "Supported" : "Not Available"}',
                        style: StandardizedTextStyle.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const StandardizedText('Close', style: StandardizedTextStyle.buttonText),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('Error showing platform capabilities: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: StandardizedText('Unable to load platform capabilities: $e', style: StandardizedTextStyle.bodyMedium),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Format timestamp for display
  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return 'Never';

    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Format capability name for display
  String _formatCapabilityName(String key) {
    switch (key) {
      case 'speechRecognition':
        return 'Speech Recognition';
      case 'audioRecording':
        return 'Audio Recording';
      case 'backgroundProcessing':
        return 'Background Processing';
      case 'notifications':
        return 'Push Notifications';
      case 'continuousSpeech':
        return 'Continuous Speech';
      case 'backgroundAudio':
        return 'Background Audio';
      case 'periodicTasks':
        return 'Periodic Tasks';
      case 'scheduledNotifications':
        return 'Scheduled Notifications';
      default:
        return key
            .replaceAllMapped(
              RegExp(r'([A-Z])'),
              (match) => ' ${match.group(1)}',
            )
            .trim();
    }
  }
}
