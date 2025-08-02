import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/offline_data_service.dart';

/// Widget to display offline/sync status
class OfflineStatusWidget extends ConsumerWidget {
  final bool showDetails;
  final bool compact;

  const OfflineStatusWidget({
    super.key,
    this.showDetails = false,
    this.compact = false,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineStatus = ref.watch(offlineStatusProvider);
    
    if (compact) {
      return _buildCompactStatus(context, offlineStatus);
    }
    
    return _buildFullStatus(context, offlineStatus, showDetails);
  }

  Widget _buildCompactStatus(BuildContext context, OfflineStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: status.statusColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(status),
            size: 16,
            color: status.statusColor,
          ),
          const SizedBox(width: 4),
          Text(
            _getCompactStatusText(status),
            style: TextStyle(
              color: status.statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullStatus(BuildContext context, OfflineStatus status, bool showDetails) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(status),
                  color: status.statusColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    status.statusText,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: status.statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (status.isSyncing)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            
            if (showDetails) ...[
              const SizedBox(height: 8),
              _buildStatusDetails(context, status),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDetails(BuildContext context, OfflineStatus status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (status.hasPendingChanges) ...[
          Text(
            'Pending Changes: ${status.pendingOperationsCount}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
        ],
        
        if (status.lastSyncTime != null) ...[
          Text(
            'Last Sync: ${_formatLastSyncTime(status.lastSyncTime!)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ] else ...[
          Text(
            'Never synced',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  IconData _getStatusIcon(OfflineStatus status) {
    if (status.isSyncing) return Icons.sync;
    if (!status.isOnline) return Icons.cloud_off;
    if (status.hasPendingChanges) return Icons.cloud_sync;
    return Icons.cloud_done;
  }

  String _getCompactStatusText(OfflineStatus status) {
    if (status.isSyncing) return 'Syncing';
    if (!status.isOnline) return 'Offline';
    if (status.hasPendingChanges) return '${status.pendingOperationsCount}';
    return 'Synced';
  }

  String _formatLastSyncTime(DateTime lastSync) {
    final now = DateTime.now();
    final difference = now.difference(lastSync);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

/// Floating action button with sync status
class SyncStatusFAB extends ConsumerWidget {
  final VoidCallback? onPressed;

  const SyncStatusFAB({super.key, this.onPressed});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineStatus = ref.watch(offlineStatusProvider);
    
    return FloatingActionButton.extended(
      onPressed: onPressed ?? () => _showSyncDialog(context, ref),
      backgroundColor: offlineStatus.statusColor,
      icon: Icon(
        offlineStatus.isSyncing ? Icons.sync : _getStatusIcon(offlineStatus),
        color: Colors.white,
      ),
      label: Text(
        offlineStatus.isSyncing 
            ? 'Syncing...' 
            : offlineStatus.hasPendingChanges 
                ? '${offlineStatus.pendingOperationsCount} pending'
                : 'Synced',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  IconData _getStatusIcon(OfflineStatus status) {
    if (!status.isOnline) return Icons.cloud_off;
    if (status.hasPendingChanges) return Icons.cloud_sync;
    return Icons.cloud_done;
  }

  void _showSyncDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const SyncStatusDialog(),
    );
  }
}

/// Dialog showing detailed sync status and controls
class SyncStatusDialog extends ConsumerWidget {
  const SyncStatusDialog({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineStatus = ref.watch(offlineStatusProvider);
    // Note: syncQueueStatus provider needs to be created or we'll use offlineStatus for now
    
    return AlertDialog(
      title: const Text('Sync Status'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current status
            _buildStatusSection(context, offlineStatus),
            const SizedBox(height: 16),
            
            // Sync queue info
            if (offlineStatus.hasPendingChanges) ...[
              _buildSyncQueueSection(context, offlineStatus),
              const SizedBox(height: 16),
            ],
            
            // Last sync info
            _buildLastSyncSection(context, offlineStatus),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        if (offlineStatus.isOnline && !offlineStatus.isSyncing)
          ElevatedButton(
            onPressed: () => _performManualSync(context, ref),
            child: const Text('Sync Now'),
          ),
      ],
    );
  }

  Widget _buildStatusSection(BuildContext context, OfflineStatus status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connection Status',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              status.isOnline ? Icons.wifi : Icons.wifi_off,
              color: status.isOnline ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(
              status.isOnline ? 'Online' : 'Offline',
              style: TextStyle(
                color: status.isOnline ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              _getSyncIcon(status),
              color: status.statusColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                status.statusText,
                style: TextStyle(color: status.statusColor),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSyncQueueSection(BuildContext context, SyncQueueStatus status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pending Changes',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.queue, color: Colors.orange),
            const SizedBox(width: 8),
            Text('${status.pendingOperations} operations waiting to sync'),
          ],
        ),
        if (status.isProcessing) ...[
          const SizedBox(height: 8),
          const Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text('Processing sync queue...'),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildLastSyncSection(BuildContext context, SyncQueueStatus status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sync History',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        if (status.lastSuccessfulSync != null) ...[
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Text('Last successful: ${_formatDateTime(status.lastSuccessfulSync!)}'),
            ],
          ),
        ],
        if (status.lastSyncAttempt != null && 
            status.lastSyncAttempt != status.lastSuccessfulSync) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 8),
              Text('Last attempt: ${_formatDateTime(status.lastSyncAttempt!)}'),
            ],
          ),
        ],
        if (status.lastSuccessfulSync == null && status.lastSyncAttempt == null) ...[
          const Row(
            children: [
              Icon(Icons.info, color: Colors.grey),
              SizedBox(width: 8),
              Text('No sync attempts yet'),
            ],
          ),
        ],
      ],
    );
  }

  IconData _getSyncIcon(OfflineStatus status) {
    if (status.isSyncing) return Icons.sync;
    if (!status.isOnline) return Icons.cloud_off;
    if (status.hasPendingChanges) return Icons.cloud_sync;
    return Icons.cloud_done;
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _performManualSync(BuildContext context, WidgetRef ref) async {
    final offlineService = ref.read(offlineDataServiceProvider);
    
    try {
      Navigator.of(context).pop(); // Close dialog
      
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Syncing...'),
            ],
          ),
        ),
      );
      
      final result = await offlineService.performFullSync();
      
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Sync completed: ${result.syncedTasks} tasks, ${result.syncedEvents} events',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sync failed: ${result.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// App bar with sync status indicator
class AppBarWithSyncStatus extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  const AppBarWithSyncStatus({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: Text(title),
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: [
        // Sync status indicator
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => _showSyncDialog(context),
            child: const OfflineStatusWidget(compact: true),
          ),
        ),
        ...?actions,
      ],
    );
  }

  void _showSyncDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SyncStatusDialog(),
    );
  }
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Bottom sheet for conflict resolution
class ConflictResolutionSheet extends ConsumerWidget {
  final List<SyncConflict> conflicts;

  const ConflictResolutionSheet({
    super.key,
    required this.conflicts,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Title
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Resolve Sync Conflicts',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              
              // Conflicts list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: conflicts.length,
                  itemBuilder: (context, index) {
                    final conflict = conflicts[index];
                    return _buildConflictItem(context, ref, conflict);
                  },
                ),
              ),
              
              // Actions
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _resolveAllConflicts(context, ref),
                        child: const Text('Resolve All'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConflictItem(BuildContext context, WidgetRef ref, SyncConflict conflict) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conflict in ${conflict.entityType.name}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Entity ID: ${conflict.entityId}'),
            const SizedBox(height: 8),
            Text('Local modified: ${_formatDateTime(conflict.localModified)}'),
            Text('Remote modified: ${_formatDateTime(conflict.remoteModified)}'),
            const SizedBox(height: 16),
            
            // Resolution options
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _resolveConflict(
                    context, 
                    ref, 
                    conflict, 
                    ConflictResolutionStrategy.useLocal,
                  ),
                  child: const Text('Use Local'),
                ),
                ElevatedButton(
                  onPressed: () => _resolveConflict(
                    context, 
                    ref, 
                    conflict, 
                    ConflictResolutionStrategy.useRemote,
                  ),
                  child: const Text('Use Remote'),
                ),
                ElevatedButton(
                  onPressed: () => _resolveConflict(
                    context, 
                    ref, 
                    conflict, 
                    ConflictResolutionStrategy.merge,
                  ),
                  child: const Text('Merge'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resolveConflict(
    BuildContext context,
    WidgetRef ref,
    SyncConflict conflict,
    ConflictResolutionStrategy strategy,
  ) async {
    final offlineService = ref.read(offlineDataServiceProvider);
    
    try {
      final result = await offlineService.resolveConflict(conflict, strategy);
      
      if (context.mounted) {
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Conflict resolved: ${result.action}'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to resolve conflict: ${result.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error resolving conflict: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _resolveAllConflicts(BuildContext context, WidgetRef ref) async {
    // This would implement bulk conflict resolution
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bulk conflict resolution not implemented yet')),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}