import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/standardized_app_bar.dart';
import '../widgets/theme_background_widget.dart';

import '../providers/notification_providers.dart';
import '../../services/notification/notification_models.dart' as models;
import '../../core/theme/typography_constants.dart';

/// Page for configuring notification settings
class NotificationSettingsPage extends ConsumerWidget {
  const NotificationSettingsPage({super.key});  @override
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
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading settings: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(notificationSettingsProvider),
                child: const Text('Retry'),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Permissions',
              style: TextStyle(fontSize: TypographyConstants.headlineSmall, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            permissionsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
              data: (hasPermissions) => Row(
                children: [
                  Icon(
                    hasPermissions ? Icons.check_circle : Icons.error,
                    color: hasPermissions ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hasPermissions
                          ? 'Notification permissions granted'
                          : 'Notification permissions required',
                    ),
                  ),
                  if (!hasPermissions)
                    ElevatedButton(
                      onPressed: () => ref.read(notificationPermissionsProvider.notifier).requestPermissions(),
                      child: const Text('Grant'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralSection(
    BuildContext context,
    WidgetRef ref,
    models.NotificationSettings settings,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'General',
              style: TextStyle(fontSize: TypographyConstants.headlineSmall, fontWeight: FontWeight.bold),
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
      ),
    );
  }

  Widget _buildReminderSection(
    BuildContext context,
    WidgetRef ref,
    models.NotificationSettings settings,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Task Reminders',
              style: TextStyle(fontSize: TypographyConstants.headlineSmall, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Default Reminder Time'),
              subtitle: Text(_formatDuration(settings.defaultReminder)),
              trailing: const Icon(Icons.chevron_right),
              enabled: settings.enabled,
              onTap: settings.enabled ? () => _showReminderTimePicker(context, ref, settings) : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailySummarySection(
    BuildContext context,
    WidgetRef ref,
    models.NotificationSettings settings,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Summary',
              style: TextStyle(fontSize: TypographyConstants.headlineSmall, fontWeight: FontWeight.bold),
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
              trailing: const Icon(Icons.chevron_right),
              enabled: settings.enabled && settings.dailySummary,
              onTap: settings.enabled && settings.dailySummary
                  ? () => _showTimePicker(context, ref, settings.dailySummaryTime)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuietHoursSection(
    BuildContext context,
    WidgetRef ref,
    models.NotificationSettings settings,
  ) {
    final hasQuietHours = settings.quietHoursStart != null && settings.quietHoursEnd != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quiet Hours',
              style: TextStyle(fontSize: TypographyConstants.headlineSmall, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (hasQuietHours) ...[
              ListTile(
                title: const Text('Start Time'),
                subtitle: Text(_formatNotificationTime(settings.quietHoursStart!)),
                trailing: const Icon(Icons.chevron_right),
                enabled: settings.enabled,
                onTap: settings.enabled
                    ? () => _showQuietHoursStartPicker(context, ref, settings)
                    : null,
              ),
              ListTile(
                title: const Text('End Time'),
                subtitle: Text(_formatNotificationTime(settings.quietHoursEnd!)),
                trailing: const Icon(Icons.chevron_right),
                enabled: settings.enabled,
                onTap: settings.enabled
                    ? () => _showQuietHoursEndPicker(context, ref, settings)
                    : null,
              ),
              ListTile(
                title: const Text('Remove Quiet Hours'),
                leading: const Icon(Icons.delete_outline),
                enabled: settings.enabled,
                onTap: settings.enabled
                    ? () => ref.read(notificationSettingsProvider.notifier).setQuietHours(null, null)
                    : null,
              ),
            ] else ...[
              ListTile(
                title: const Text('Set Quiet Hours'),
                subtitle: const Text('No notifications during specified hours'),
                leading: const Icon(Icons.bedtime),
                trailing: const Icon(Icons.chevron_right),
                enabled: settings.enabled,
                onTap: settings.enabled
                    ? () => _showQuietHoursSetup(context, ref)
                    : null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSection(
    BuildContext context,
    WidgetRef ref,
    models.NotificationSettings settings,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Advanced',
              style: TextStyle(fontSize: TypographyConstants.headlineSmall, fontWeight: FontWeight.bold),
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
      ),
    );
  }

  Widget _buildTestSection(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test',
              style: TextStyle(fontSize: TypographyConstants.headlineSmall, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final testNotification = ref.read(testNotificationProvider);
                  await testNotification();
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Test notification sent!')),
                    );
                  }
                },
                icon: const Icon(Icons.notifications_active),
                label: const Text('Send Test Notification'),
              ),
            ),
          ],
        ),
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: durations.map((duration) {
            return RadioListTile<Duration>(
              title: Text(_formatDuration(duration)),
              value: duration,
              groupValue: settings.defaultReminder,
              onChanged: (value) => Navigator.of(context).pop(value),
            );
          }).toList(),
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
                trailing: const Icon(Icons.access_time),
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
                trailing: const Icon(Icons.access_time),
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
              onPressed: startTime != null && endTime != null
                  ? () => Navigator.of(context).pop(true)
                  : null,
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
