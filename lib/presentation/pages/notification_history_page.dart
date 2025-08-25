import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/standardized_app_bar.dart';
import '../widgets/theme_background_widget.dart';
import '../widgets/standardized_text.dart';
import '../widgets/standardized_colors.dart';
import '../widgets/standardized_spacing.dart';
import '../../core/design_system/design_tokens.dart';
import '../widgets/standardized_error_states.dart';
import '../widgets/standardized_card.dart';

import '../providers/notification_providers.dart';
import '../../services/notification/notification_models.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Page for viewing notification history and statistics
class NotificationHistoryPage extends ConsumerWidget {
  const NotificationHistoryPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduledNotificationsAsync = ref.watch(scheduledNotificationsProvider);

    return ThemeBackgroundWidget(
      child: Scaffold(
        backgroundColor: context.colors.backgroundTransparent,
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
        loading: () => StandardizedErrorStates.loading(),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIcons.warningCircle(),
                size: 64,
                color: context.colors.error,
              ),
              StandardizedGaps.md,
              StandardizedText(
                'Error loading notifications: $error',
                style: StandardizedTextStyle.bodyMedium,
              ),
              StandardizedGaps.md,
              ElevatedButton(
                onPressed: () => ref.refresh(scheduledNotificationsProvider),
                child: const StandardizedText(
                  'Retry',
                  style: StandardizedTextStyle.buttonText,
                ),
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
        left: SpacingTokens.md,
        right: SpacingTokens.md,
        bottom: SpacingTokens.md,
      ),
      children: [
        _buildStatsCard(context, notifications),
        StandardizedGaps.md,
        _buildNotificationsList(context, notifications),
      ],
    );
  }

  Widget _buildStatsCard(BuildContext context, List<ScheduledNotification> notifications) {
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

    return StandardizedCard(
      child: Padding(
        padding: StandardizedSpacing.padding(SpacingSize.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StandardizedText(
              'Notification Statistics',
              style: StandardizedTextStyle.titleLarge,
            ),
            StandardizedGaps.md,
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total',
                    notifications.length.toString(),
                    PhosphorIcons.bell(),
                    context.colors.info,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Today',
                    todayNotifications.toString(),
                    PhosphorIcons.calendar(),
                    context.colors.success,
                  ),
                ),
              ],
            ),
            StandardizedGaps.vertical(SpacingSize.sm),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Pending',
                    pendingNotifications.toString(),
                    PhosphorIcons.clock(),
                    context.colors.warning,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Sent',
                    sentNotifications.toString(),
                    PhosphorIcons.checkCircle(),
                    context.colors.success,
                  ),
                ),
              ],
            ),
            if (notifications.isNotEmpty) ...[
              StandardizedGaps.md,
              const Divider(),
              StandardizedGaps.vertical(SpacingSize.sm),
              Row(
                children: [
                  Icon(
                    _getNotificationTypeIcon(mostCommonType),
                    size: 20,
                    color: context.colors.withSemanticOpacity(
                      Theme.of(context).colorScheme.onSurface,
                      SemanticOpacity.strong,
                    ),
                  ),
                  StandardizedGaps.horizontal(SpacingSize.sm),
                  StandardizedText(
                    'Most common: ${mostCommonType.displayName}',
                    style: StandardizedTextStyle.bodySmall,
                    color: context.colors.withSemanticOpacity(
                      Theme.of(context).colorScheme.onSurface,
                      SemanticOpacity.strong,
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
    return Builder(
      builder: (context) => Column(
        children: [
          Icon(icon, color: color, size: 32),
          StandardizedGaps.vertical(SpacingSize.sm),
          StandardizedText(
            value,
            style: StandardizedTextStyle.displaySmall,
          ),
          StandardizedText(
            label,
            style: StandardizedTextStyle.bodySmall,
            color: context.colors.withSemanticOpacity(
              Theme.of(context).colorScheme.onSurface,
              SemanticOpacity.strong,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(BuildContext context, List<ScheduledNotification> notifications) {
    if (notifications.isEmpty) {
      return StandardizedCard(
        padding: StandardizedSpacing.padding(SpacingSize.xl),
        child: Column(
          children: [
            Icon(
              PhosphorIcons.bellSlash(),
              size: 64,
              color: context.colors.withSemanticOpacity(
                Theme.of(context).colorScheme.onSurface,
                SemanticOpacity.light,
              ),
            ),
            StandardizedGaps.md,
            StandardizedText(
              'No notifications scheduled',
              style: StandardizedTextStyle.bodyLarge,
              color: context.colors.withSemanticOpacity(
                Theme.of(context).colorScheme.onSurface,
                SemanticOpacity.strong,
              ),
            ),
          ],
        ),
      );
    }

    // Sort notifications by scheduled time (most recent first)
    final sortedNotifications = List<ScheduledNotification>.from(notifications)
      ..sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));

    return StandardizedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: StandardizedSpacing.padding(SpacingSize.md),
            child: const StandardizedText(
              'Scheduled Notifications',
              style: StandardizedTextStyle.titleMedium,
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedNotifications.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final notification = sortedNotifications[index];
              return _buildNotificationTile(context, notification);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(BuildContext context, ScheduledNotification notification) {
    final now = DateTime.now();
    final isPast = notification.scheduledTime.isBefore(now);
    final isToday = notification.scheduledTime.year == now.year &&
        notification.scheduledTime.month == now.month &&
        notification.scheduledTime.day == now.day;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: notification.sent 
            ? context.colors.withSemanticOpacity(context.colors.success, SemanticOpacity.subtle)
            : isPast 
                ? context.colors.withSemanticOpacity(context.colors.error, SemanticOpacity.subtle)
                : context.colors.withSemanticOpacity(context.colors.info, SemanticOpacity.subtle),
        child: Icon(
          _getNotificationTypeIcon(notification.type),
          color: notification.sent 
              ? context.colors.success
              : isPast 
                  ? context.colors.error
                  : context.colors.info,
          size: 20,
        ),
      ),
      title: StandardizedText(
        notification.title,
        style: StandardizedTextStyle.bodyLarge,
        color: notification.sent ? context.colors.withSemanticOpacity(
          Theme.of(context).colorScheme.onSurface,
          SemanticOpacity.strong,
        ) : null,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StandardizedText(
            notification.body,
            style: StandardizedTextStyle.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            color: notification.sent 
              ? context.colors.withSemanticOpacity(
                  Theme.of(context).colorScheme.onSurface,
                  SemanticOpacity.light,
                )
              : context.colors.withSemanticOpacity(
                  Theme.of(context).colorScheme.onSurface,
                  SemanticOpacity.strong,
                ),
          ),
          StandardizedGaps.vertical(SpacingSize.xs),
          Row(
            children: [
              Icon(
                PhosphorIcons.clock(),
                size: 14,
                color: context.colors.withSemanticOpacity(
                  Theme.of(context).colorScheme.onSurface,
                  SemanticOpacity.light,
                ),
              ),
              StandardizedGaps.horizontal(SpacingSize.xs),
              StandardizedText(
                _formatDateTime(notification.scheduledTime, isToday),
                style: StandardizedTextStyle.bodySmall,
                color: context.colors.withSemanticOpacity(
                  Theme.of(context).colorScheme.onSurface,
                  SemanticOpacity.strong,
                ),
              ),
              if (notification.sent) ...[
                StandardizedGaps.horizontal(SpacingSize.sm),
                Icon(
                  PhosphorIcons.checkCircle(),
                  size: 14,
                  color: context.colors.success,
                ),
                StandardizedGaps.horizontal(SpacingSize.xs),
                StandardizedText(
                  'Sent',
                  style: StandardizedTextStyle.bodySmall,
                  color: context.colors.success,
                ),
              ] else if (isPast) ...[
                StandardizedGaps.horizontal(SpacingSize.sm),
                Icon(
                  PhosphorIcons.warningCircle(),
                  size: 14,
                  color: context.colors.error,
                ),
                StandardizedGaps.horizontal(SpacingSize.xs),
                StandardizedText(
                  'Missed',
                  style: StandardizedTextStyle.bodySmall,
                  color: context.colors.error,
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
                      StandardizedGaps.horizontal(SpacingSize.sm),
                      const StandardizedText('Cancel', style: StandardizedTextStyle.bodyMedium),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'reschedule',
                  child: Row(
                    children: [
                      Icon(PhosphorIcons.clock(), size: 18),
                      StandardizedGaps.horizontal(SpacingSize.sm),
                      const StandardizedText('Reschedule', style: StandardizedTextStyle.bodyMedium),
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


