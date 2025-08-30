import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/design_system/design_tokens.dart';
import '../providers/background_service_providers.dart';
import 'glassmorphism_container.dart';
import 'standardized_error_states.dart';
import 'standardized_spacing.dart';
import 'standardized_text.dart';

/// Widget to display background service status and controls
class BackgroundServiceStatusWidget extends ConsumerWidget {
  const BackgroundServiceStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backgroundServiceState = ref.watch(backgroundServiceNotifierProvider);
    final backgroundServiceNotifier = ref.read(backgroundServiceNotifierProvider.notifier);
    final theme = Theme.of(context);

    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: StandardizedSpacing.padding(SpacingSize.md),
      margin: StandardizedSpacing.marginSymmetric(
        horizontal: SpacingSize.md,
        vertical: SpacingSize.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.wrench(),
                color: theme.colorScheme.primary,
              ),
              StandardizedGaps.horizontal(SpacingSize.xs),
              const StandardizedText(
                'Background Services',
                style: StandardizedTextStyle.titleMedium,
              ),
              const Spacer(),
              IconButton(
                onPressed: () => backgroundServiceNotifier.refreshStatus(),
                icon: Icon(PhosphorIcons.arrowClockwise()),
                tooltip: 'Refresh status',
              ),
            ],
          ),
          StandardizedGaps.vertical(SpacingSize.sm),
          backgroundServiceState.when(
            loading: () => Center(
              child: StandardizedErrorStates.loading(),
            ),
            ready: (status) => _buildStatusContent(
              context,
              theme,
              status,
              false,
              backgroundServiceNotifier,
            ),
            running: (status) => _buildStatusContent(
              context,
              theme,
              status,
              true,
              backgroundServiceNotifier,
            ),
            error: (message) => _buildErrorContent(theme, message),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusContent(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> status,
    bool isRunning,
    BackgroundServiceNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Service status
        Row(
          children: [
            Icon(
              isRunning ? PhosphorIcons.playCircle() : PhosphorIcons.pauseCircle(),
              color: isRunning ? Colors.green : Colors.orange,
              size: 20,
            ),
            StandardizedGaps.horizontal(SpacingSize.xs),
            StandardizedText(
              isRunning ? 'Running' : 'Stopped',
              style: StandardizedTextStyle.bodyMedium,
              color: isRunning ? Colors.green : Colors.orange,
            ),
            const Spacer(),
            Switch(
              value: isRunning,
              onChanged: (value) => notifier.toggleService(value),
            ),
          ],
        ),

        StandardizedGaps.vertical(SpacingSize.sm),

        // Status details
        if (status['last_cleanup'] != null) ...[
          _buildStatusRow(
            theme,
            'Last Cleanup',
            _formatDateTime(status['last_cleanup']),
            PhosphorIcons.broom(),
          ),
          StandardizedGaps.vertical(SpacingSize.xs),
        ],

        if (status['analytics_cleanup'] != null) ...[
          _buildStatusRow(
            theme,
            'Analytics Cleanup',
            _formatDateTime(status['analytics_cleanup']),
            PhosphorIcons.chartBar(),
          ),
          StandardizedGaps.vertical(SpacingSize.xs),
        ],

        if (status['last_manual_processing'] != null) ...[
          _buildStatusRow(
            theme,
            'Last Manual Processing',
            _formatDateTime(status['last_manual_processing']),
            PhosphorIcons.arrowClockwise(),
          ),
          StandardizedGaps.vertical(SpacingSize.xs),
        ],

        StandardizedGaps.vertical(SpacingSize.sm),

        // Manual trigger buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => notifier.forceProcessRecurringTasks(),
                icon: Icon(PhosphorIcons.repeat(), size: 16),
                label: const StandardizedText('Process Recurring', style: StandardizedTextStyle.buttonText),
                style: OutlinedButton.styleFrom(
                  padding: StandardizedSpacing.paddingSymmetric(
                    horizontal: SpacingSize.sm,
                    vertical: SpacingSize.xs,
                  ),
                ),
              ),
            ),
            StandardizedGaps.horizontal(SpacingSize.xs),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showServiceDetails(context, status),
                icon: Icon(PhosphorIcons.info(), size: 16),
                label: const StandardizedText('Details', style: StandardizedTextStyle.buttonText),
                style: OutlinedButton.styleFrom(
                  padding: StandardizedSpacing.paddingSymmetric(
                    horizontal: SpacingSize.sm,
                    vertical: SpacingSize.xs,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorContent(ThemeData theme, String message) {
    return Container(
      padding: StandardizedSpacing.padding(SpacingSize.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            PhosphorIcons.warningCircle(),
            color: theme.colorScheme.error,
          ),
          StandardizedGaps.horizontal(SpacingSize.xs),
          Expanded(
            child: StandardizedText(
              message,
              style: StandardizedTextStyle.bodyMedium,
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        StandardizedGaps.horizontal(SpacingSize.xs),
        StandardizedText(
          label,
          style: StandardizedTextStyle.bodySmall,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        StandardizedGaps.horizontal(SpacingSize.xs),
        Expanded(
          child: StandardizedText(
            value,
            style: StandardizedTextStyle.bodySmall,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  void _showServiceDetails(BuildContext context, Map<String, dynamic> status) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const StandardizedText('Background Service Details', style: StandardizedTextStyle.headlineSmall),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final entry in status.entries)
                Padding(
                  padding: StandardizedSpacing.paddingSymmetric(vertical: SpacingSize.xs),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 120,
                        child: StandardizedText(
                          '${entry.key}:',
                          style: StandardizedTextStyle.bodyMedium,
                        ),
                      ),
                      Expanded(
                        child: StandardizedText(entry.value?.toString() ?? 'null',
                            style: StandardizedTextStyle.bodyMedium),
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
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) return 'Never';

    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Invalid date';
    }
  }
}
