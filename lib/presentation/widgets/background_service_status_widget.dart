import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/background_service_providers.dart';
import '../../core/theme/typography_constants.dart';
import '../../core/design_system/design_tokens.dart';
import 'glassmorphism_container.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
      padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
      margin: const EdgeInsets.symmetric(
        horizontal: TypographyConstants.paddingMedium,
        vertical: TypographyConstants.paddingSmall,
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
              SizedBox(width: 8),
              Text(
                'Background Services',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => backgroundServiceNotifier.refreshStatus(),
                icon: Icon(PhosphorIcons.arrowClockwise()),
                tooltip: 'Refresh status',
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          backgroundServiceState.when(
            loading: () => const Center(
              child: CircularProgressIndicator(),
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
            SizedBox(width: 8),
            Text(
              isRunning ? 'Running' : 'Stopped',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isRunning ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Switch(
              value: isRunning,
              onChanged: (value) => notifier.toggleService(value),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Status details
        if (status['last_cleanup'] != null) ...[
          _buildStatusRow(
            theme,
            'Last Cleanup',
            _formatDateTime(status['last_cleanup']),
            PhosphorIcons.broom(),
          ),
          const SizedBox(height: 8),
        ],
        
        if (status['analytics_cleanup'] != null) ...[
          _buildStatusRow(
            theme,
            'Analytics Cleanup',
            _formatDateTime(status['analytics_cleanup']),
            PhosphorIcons.chartBar(),
          ),
          const SizedBox(height: 8),
        ],

        if (status['last_manual_processing'] != null) ...[
          _buildStatusRow(
            theme,
            'Last Manual Processing',
            _formatDateTime(status['last_manual_processing']),
            PhosphorIcons.arrowClockwise(),
          ),
          const SizedBox(height: 8),
        ],
        
        const SizedBox(height: 12),
        
        // Manual trigger buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => notifier.forceProcessRecurringTasks(),
                icon: Icon(PhosphorIcons.repeat(), size: 16),
                label: const Text('Process Recurring'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showServiceDetails(context, status),
                icon: Icon(PhosphorIcons.info(), size: 16),
                label: const Text('Details'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
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
      padding: const EdgeInsets.all(12),
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
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
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
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
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
        title: const Text('Background Service Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final entry in status.entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(
                          '${entry.key}:',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        child: Text(entry.value?.toString() ?? 'null'),
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
            child: const Text('Close'),
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

