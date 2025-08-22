import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/standardized_app_bar.dart';
import '../widgets/theme_background_widget.dart';

import '../providers/notification_providers.dart';
import '../../services/notification/notification_models.dart';
import '../../core/theme/typography_constants.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Page for viewing notification history and statistics
class NotificationHistoryPage extends ConsumerWidget {
  const NotificationHistoryPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduledNotificationsAsync = ref.watch(scheduledNotificationsProvider);

    return ThemeBackgroundWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: StandardizedAppBar(
          title: 'Notification History',
          actions: [
            IconButton(
              icon: Icon(PhosphorIcons.arrowClockwise()),
              onPressed: () => ref.refresh(scheduledNotificationsProvider),
            ),
          ],
        ),
        body: scheduledNotificationsAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(PhosphorIcons.warningCircle(), size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading notifications: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(scheduledNotificationsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (notifications) => _buildContent(context, ref, notifications),
      ),
    ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<ScheduledNotification> notifications,
  ) {
    return ListView(
      padding: const EdgeInsets.only(
        top: kToolbarHeight + 8,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      children: [
        _buildStatsCard(notifications),
        const SizedBox(height: 16),
        _buildNotificationsList(notifications),
      ],
    );
  }

  Widget _buildStatsCard(List<ScheduledNotification> notifications) {
    final now = DateTime.now();
    final todayNotifications = notifications.where((n) => 
      n.scheduledTime.year == now.year &&
      n.scheduledTime.month == now.month &&
      n.scheduledTime.day == now.day
    ).length;
    
    final pendingNotifications = notifications.where((n) => 
      !n.sent && n.scheduledTime.isAfter(now)
    ).length;
    
    final sentNotifications = notifications.where((n) => n.sent).length;
    
    final typeStats = <NotificationTypeModel, int>{};
    for (final notification in notifications) {
      typeStats[notification.type] = (typeStats[notification.type] ?? 0) + 1;
    }
    
    final mostCommonType = typeStats.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notification Statistics',
              style: TextStyle(fontSize: TypographyConstants.headlineSmall, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total',
                    notifications.length.toString(),
                    PhosphorIcons.bell(),
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Today',
                    todayNotifications.toString(),
                    PhosphorIcons.calendar(),
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Pending',
                    pendingNotifications.toString(),
                    PhosphorIcons.clock(),
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Sent',
                    sentNotifications.toString(),
                    PhosphorIcons.checkCircle(),
                    Colors.green,
                  ),
                ),
              ],
            ),
            if (notifications.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    _getNotificationTypeIcon(mostCommonType),
                    size: 20,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Most common: ${mostCommonType.displayName}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: TypographyConstants.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: TypographyConstants.displaySmall,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: TypographyConstants.bodySmall,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsList(List<ScheduledNotification> notifications) {
    if (notifications.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                PhosphorIcons.bellSlash(),
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No notifications scheduled',
                style: TextStyle(
                  fontSize: TypographyConstants.bodyLarge,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Sort notifications by scheduled time (most recent first)
    final sortedNotifications = List<ScheduledNotification>.from(notifications)
      ..sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Scheduled Notifications',
              style: TextStyle(fontSize: TypographyConstants.headlineSmall, fontWeight: FontWeight.bold),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedNotifications.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final notification = sortedNotifications[index];
              return _buildNotificationTile(notification);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(ScheduledNotification notification) {
    final now = DateTime.now();
    final isPast = notification.scheduledTime.isBefore(now);
    final isToday = notification.scheduledTime.year == now.year &&
        notification.scheduledTime.month == now.month &&
        notification.scheduledTime.day == now.day;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: notification.sent 
            ? Colors.green.withValues(alpha: 0.2)
            : isPast 
                ? Colors.red.withValues(alpha: 0.2)
                : Colors.blue.withValues(alpha: 0.2),
        child: Icon(
          _getNotificationTypeIcon(notification.type),
          color: notification.sent 
              ? Colors.green
              : isPast 
                  ? Colors.red
                  : Colors.blue,
          size: 20,
        ),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: notification.sent ? Colors.grey[600] : null,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notification.body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: notification.sent ? Colors.grey[500] : Colors.grey[700],
            ),
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(
                PhosphorIcons.clock(),
                size: 14,
                color: Colors.grey[500],
              ),
              const SizedBox(width: 4),
              Text(
                _formatDateTime(notification.scheduledTime, isToday),
                style: TextStyle(
                  fontSize: TypographyConstants.bodySmall,
                  color: Colors.grey[500],
                ),
              ),
              if (notification.sent) ...[
                const SizedBox(width: 8),
                Icon(
                  PhosphorIcons.checkCircle(),
                  size: 14,
                  color: Colors.green[600],
                ),
                const SizedBox(width: 2),
                Text(
                  'Sent',
                  style: TextStyle(
                    fontSize: TypographyConstants.bodySmall,
                    color: Colors.green[600],
                  ),
                ),
              ] else if (isPast) ...[
                const SizedBox(width: 8),
                Icon(
                  PhosphorIcons.warningCircle(),
                  size: 14,
                  color: Colors.red[600],
                ),
                const SizedBox(width: 2),
                Text(
                  'Missed',
                  style: TextStyle(
                    fontSize: TypographyConstants.bodySmall,
                    color: Colors.red[600],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      trailing: notification.sent || isPast
          ? null
          : PopupMenuButton<String>(
              onSelected: (value) {
                // Handle notification actions
                switch (value) {
                  case 'cancel':
                    // Cancel the notification
                    break;
                  case 'reschedule':
                    // Show reschedule dialog
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'cancel',
                  child: Row(
                    children: [
                      Icon(PhosphorIcons.xCircle(), size: 18),
                      SizedBox(width: 8),
                      Text('Cancel'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'reschedule',
                  child: Row(
                    children: [
                      Icon(PhosphorIcons.clock(), size: 18),
                      SizedBox(width: 8),
                      Text('Reschedule'),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  IconData _getNotificationTypeIcon(NotificationTypeModel type) {
    switch (type) {
      case NotificationTypeModel.taskReminder:
        return PhosphorIcons.alarm();
      case NotificationTypeModel.dailySummary:
        return PhosphorIcons.listBullets();
      case NotificationTypeModel.overdueTask:
        return PhosphorIcons.warning();
      case NotificationTypeModel.taskCompleted:
        return PhosphorIcons.checkCircle();
      case NotificationTypeModel.locationReminder:
        return PhosphorIcons.mapPin();
      case NotificationTypeModel.locationBased:
        return PhosphorIcons.mapPin();
      case NotificationTypeModel.emergency:
        return PhosphorIcons.warning();
      case NotificationTypeModel.smartSuggestion:
        return PhosphorIcons.lightbulb();
      case NotificationTypeModel.collaboration:
        return PhosphorIcons.users();
      case NotificationTypeModel.automationTrigger:
        return PhosphorIcons.sparkle();
    }
  }

  String _formatDateTime(DateTime dateTime, bool isToday) {
    if (isToday) {
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else {
      final month = dateTime.month.toString().padLeft(2, '0');
      final day = dateTime.day.toString().padLeft(2, '0');
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$month/$day $hour:$minute';
    }
  }
}


