import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/design_system/design_tokens.dart';
import '../../core/theme/typography_constants.dart';
import '../../services/notification/notification_models.dart' as models;
import '../providers/notification_providers.dart';
import '../widgets/glassmorphism_container.dart';
import '../widgets/modern_radio_widgets.dart';
import '../widgets/standardized_app_bar.dart';
import '../widgets/theme_background_widget.dart';

/// Page for configuring notification settings
class NotificationSettingsPage extends ConsumerWidget {
  const NotificationSettingsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(notificationSettingsProvider);
    final permissionsAsync = ref.watch(notificationPermissionsProvider);

    return ThemeBackgroundWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: const StandardizedAppBar(title: 'Notification Settings'),
        body: settingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(PhosphorIcons.warningCircle(), size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading settings: $error'),
                const SizedBox(height: 16),
                GlassmorphismContainer(
                  level: GlassLevel.interactive,
                  borderRadius: BorderRadius.circular(8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => ref.refresh(notificationSettingsProvider),
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: Text(
                          'Retry',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          data: (settings) => _buildSettingsContent(context, ref, settings, permissionsAsync),
        ),
      ),
    );
  }

  Widget _buildSettingsContent(
    BuildContext context,
    WidgetRef ref,
    models.NotificationSettings settings,
    AsyncValue<bool> permissionsAsync,
  ) {
    return ListView(
      padding: const EdgeInsets.only(
        top: kToolbarHeight + 8,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      children: [
        // Permissions section
        _buildPermissionsSection(context, ref, permissionsAsync),
        const SizedBox(height: 24),

        // General settings
        _buildGeneralSection(context, ref, settings),
        const SizedBox(height: 24),

        // Reminder settings
        _buildReminderSection(context, ref, settings),
        const SizedBox(height: 24),

        // Daily summary settings
        _buildDailySummarySection(context, ref, settings),
        const SizedBox(height: 24),

        // Quiet hours settings
        _buildQuietHoursSection(context, ref, settings),
        const SizedBox(height: 24),

        // Advanced settings
        _buildAdvancedSection(context, ref, settings),
        const SizedBox(height: 24),

        // Test notification button
        _buildTestSection(context, ref),
      ],
    );
  }

  Widget _buildPermissionsSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<bool> permissionsAsync,
  ) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Permissions',
            style: TextStyle(fontSize: TypographyConstants.headlineSmall, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          permissionsAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (error, stack) => Text('Error: $error'),
            data: (hasPermissions) => Row(
              children: [
                Icon(
                  hasPermissions ? PhosphorIcons.checkCircle() : PhosphorIcons.warningCircle(),
                  color: hasPermissions ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hasPermissions ? 'Notification permissions granted' : 'Notification permissions required',
                  ),
                ),
                if (!hasPermissions)
                  GlassmorphismContainer(
                    level: GlassLevel.interactive,
                    borderRadius: BorderRadius.circular(8),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => ref.read(notificationPermissionsProvider.notifier).requestPermissions(),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                                Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Grant',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralSection(
    BuildContext context,
    WidgetRef ref,
    models.NotificationSettings settings,
  ) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'General',
            style: TextStyle(fontSize: TypographyConstants.headlineSmall, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Turn on/off all notifications'),
            value: settings.enabled,
            onChanged: (value) => ref.read(notificationSettingsProvider.notifier).toggleNotifications(value),
          ),
          SwitchListTile(
            title: const Text('Overdue Task Notifications'),
            subtitle: const Text('Get notified when tasks become overdue'),
            value: settings.overdueNotifications,
            onChanged: settings.enabled
                ? (value) => ref.read(notificationSettingsProvider.notifier).toggleOverdueNotifications(value)
                : null,
          ),
          SwitchListTile(
            title: const Text('Vibration'),
            subtitle: const Text('Vibrate when receiving notifications'),
            value: settings.vibrate,
            onChanged: settings.enabled
                ? (value) => ref.read(notificationSettingsProvider.notifier).toggleVibration(value)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildReminderSection(
    BuildContext context,
    WidgetRef ref,
    models.NotificationSettings settings,
  ) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Task Reminders',
            style: TextStyle(fontSize: TypographyConstants.headlineSmall, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Default Reminder Time'),
            subtitle: Text(_formatDuration(settings.defaultReminder)),
            trailing: Icon(PhosphorIcons.caretRight()),
            enabled: settings.enabled,
            onTap: settings.enabled ? () => _showReminderTimePicker(context, ref, settings) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDailySummarySection(
    BuildContext context,
    WidgetRef ref,
    models.NotificationSettings settings,
  ) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Summary',
            style: TextStyle(fontSize: TypographyConstants.headlineSmall, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Daily Summary'),
            subtitle: const Text('Get a summary of your tasks each morning'),
            value: settings.dailySummary,
            onChanged: settings.enabled
                ? (value) => ref.read(notificationSettingsProvider.notifier).toggleDailySummary(value)
                : null,
          ),
          ListTile(
            title: const Text('Summary Time'),
            subtitle: Text(_formatNotificationTime(settings.dailySummaryTime)),
            trailing: Icon(PhosphorIcons.caretRight()),
            enabled: settings.enabled && settings.dailySummary,
            onTap: settings.enabled && settings.dailySummary
                ? () => _showTimePicker(context, ref, settings.dailySummaryTime)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildQuietHoursSection(
    BuildContext context,
    WidgetRef ref,
    models.NotificationSettings settings,
  ) {
    final hasQuietHours = settings.quietHoursStart != null && settings.quietHoursEnd != null;

    return GlassmorphismContainer(
      level: GlassLevel.content,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quiet Hours',
            style: TextStyle(fontSize: TypographyConstants.headlineSmall, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          if (hasQuietHours) ...[
            ListTile(
              title: const Text('Start Time'),
              subtitle: Text(_formatNotificationTime(settings.quietHoursStart!)),
              trailing: Icon(PhosphorIcons.caretRight()),
              enabled: settings.enabled,
              onTap: settings.enabled ? () => _showQuietHoursStartPicker(context, ref, settings) : null,
            ),
            ListTile(
              title: const Text('End Time'),
              subtitle: Text(_formatNotificationTime(settings.quietHoursEnd!)),
              trailing: Icon(PhosphorIcons.caretRight()),
              enabled: settings.enabled,
              onTap: settings.enabled ? () => _showQuietHoursEndPicker(context, ref, settings) : null,
            ),
            ListTile(
              title: const Text('Remove Quiet Hours'),
              leading: Icon(PhosphorIcons.trash()),
              enabled: settings.enabled,
              onTap: settings.enabled
                  ? () => ref.read(notificationSettingsProvider.notifier).setQuietHours(null, null)
                  : null,
            ),
          ] else ...[
            ListTile(
              title: const Text('Set Quiet Hours'),
              subtitle: const Text('No notifications during specified hours'),
              leading: Icon(PhosphorIcons.moon()),
              trailing: Icon(PhosphorIcons.caretRight()),
              enabled: settings.enabled,
              onTap: settings.enabled ? () => _showQuietHoursSetup(context, ref) : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdvancedSection(
    BuildContext context,
    WidgetRef ref,
    models.NotificationSettings settings,
  ) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Advanced',
            style: TextStyle(fontSize: TypographyConstants.headlineSmall, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Respect Do Not Disturb'),
            subtitle: const Text('Honor system do-not-disturb settings'),
            value: settings.respectDoNotDisturb,
            onChanged: settings.enabled
                ? (value) {
                    final updatedSettings = settings.copyWith(respectDoNotDisturb: value);
                    ref.read(notificationSettingsProvider.notifier).updateSettings(updatedSettings);
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildTestSection(BuildContext context, WidgetRef ref) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Test',
            style: TextStyle(fontSize: TypographyConstants.headlineSmall, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          GlassmorphismContainer(
            level: GlassLevel.interactive,
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  try {
                    // Check if notifications are enabled first
                    final settings = ref.read(notificationSettingsProvider).value;
                    if (settings != null && !settings.enabled) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enable notifications first'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                      return;
                    }

                    // Check permissions
                    final permissionsAsync = ref.read(notificationPermissionsProvider);
                    final hasPermissions = permissionsAsync.maybeWhen(
                      data: (value) => value,
                      orElse: () => false,
                    );

                    if (!hasPermissions) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please grant notification permissions first'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                      return;
                    }

                    // Ensure plugin is initialized
                    final notificationManager = ref.read(notificationManagerProvider);
                    final isInitialized = await notificationManager.initialize();

                    if (!isInitialized) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to initialize notifications'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                      return;
                    }

                    // Send test notification
                    final testNotification = ref.read(testNotificationProvider);
                    await testNotification();

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Test notification sent!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (error) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to send test notification: $error'),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }
                  }
                },
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        PhosphorIcons.bell(),
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Send Test Notification',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays == 1 ? '' : 's'} before';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours == 1 ? '' : 's'} before';
    } else {
      return '${duration.inMinutes} minute${duration.inMinutes == 1 ? '' : 's'} before';
    }
  }

  String _formatNotificationTime(models.NotificationTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _showReminderTimePicker(
    BuildContext context,
    WidgetRef ref,
    models.NotificationSettings settings,
  ) async {
    final durations = [
      const Duration(minutes: 15),
      const Duration(minutes: 30),
      const Duration(hours: 1),
      const Duration(hours: 2),
      const Duration(hours: 4),
      const Duration(hours: 8),
      const Duration(days: 1),
    ];

    final selectedDuration = await showDialog<Duration>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default Reminder Time'),
        content: ModernRadioGroup<Duration>(
          groupValue: settings.defaultReminder,
          onChanged: (value) => Navigator.of(context).pop(value),
          options: durations
              .map((duration) => ModernRadioOption<Duration>(
                    value: duration,
                    title: Text(_formatDuration(duration)),
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selectedDuration != null) {
      ref.read(notificationSettingsProvider.notifier).updateDefaultReminder(selectedDuration);
    }
  }

  Future<void> _showTimePicker(
    BuildContext context,
    WidgetRef ref,
    models.NotificationTime currentTime,
  ) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentTime.hour, minute: currentTime.minute),
    );

    if (time != null) {
      final newTime = models.NotificationTime(hour: time.hour, minute: time.minute);
      ref.read(notificationSettingsProvider.notifier).updateDailySummaryTime(newTime);
    }
  }

  Future<void> _showQuietHoursSetup(BuildContext context, WidgetRef ref) async {
    models.NotificationTime? startTime;
    models.NotificationTime? endTime;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Set Quiet Hours'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Start Time'),
                subtitle: Text(startTime != null ? _formatNotificationTime(startTime!) : 'Not set'),
                trailing: Icon(PhosphorIcons.clock()),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: const TimeOfDay(hour: 22, minute: 0),
                  );
                  if (time != null) {
                    setState(() {
                      startTime = models.NotificationTime(hour: time.hour, minute: time.minute);
                    });
                  }
                },
              ),
              ListTile(
                title: const Text('End Time'),
                subtitle: Text(endTime != null ? _formatNotificationTime(endTime!) : 'Not set'),
                trailing: Icon(PhosphorIcons.clock()),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: const TimeOfDay(hour: 8, minute: 0),
                  );
                  if (time != null) {
                    setState(() {
                      endTime = models.NotificationTime(hour: time.hour, minute: time.minute);
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: startTime != null && endTime != null ? () => Navigator.of(context).pop(true) : null,
              child: const Text('Set'),
            ),
          ],
        ),
      ),
    );

    if (result == true && startTime != null && endTime != null) {
      ref.read(notificationSettingsProvider.notifier).setQuietHours(startTime, endTime);
    }
  }

  Future<void> _showQuietHoursStartPicker(
    BuildContext context,
    WidgetRef ref,
    models.NotificationSettings settings,
  ) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: settings.quietHoursStart!.hour,
        minute: settings.quietHoursStart!.minute,
      ),
    );

    if (time != null) {
      final newStartTime = models.NotificationTime(hour: time.hour, minute: time.minute);
      ref.read(notificationSettingsProvider.notifier).setQuietHours(newStartTime, settings.quietHoursEnd);
    }
  }

  Future<void> _showQuietHoursEndPicker(
    BuildContext context,
    WidgetRef ref,
    models.NotificationSettings settings,
  ) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: settings.quietHoursEnd!.hour,
        minute: settings.quietHoursEnd!.minute,
      ),
    );

    if (time != null) {
      final newEndTime = models.NotificationTime(hour: time.hour, minute: time.minute);
      ref.read(notificationSettingsProvider.notifier).setQuietHours(settings.quietHoursStart, newEndTime);
    }
  }
}
