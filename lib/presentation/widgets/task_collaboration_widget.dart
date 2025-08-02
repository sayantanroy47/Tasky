import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/collaboration_provider.dart';
import '../../services/collaboration_service.dart';
import '../../domain/entities/task_model.dart';

class TaskCollaborationWidget extends ConsumerWidget {
  final TaskModel task;

  const TaskCollaborationWidget({
    super.key,
    required this.task,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharedListsAsync = ref.watch(collaborationNotifierProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Collaboration',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            sharedListsAsync.when(
              data: (sharedLists) => _buildCollaborationContent(context, ref, sharedLists),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error: $error'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollaborationContent(
    BuildContext context,
    WidgetRef ref,
    List<SharedTaskList> sharedLists,
  ) {
    // Find shared lists that contain this task
    final taskSharedLists = sharedLists
        .where((list) => list.taskIds.contains(task.id))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (taskSharedLists.isNotEmpty) ...[
          const Text(
            'This task is shared in:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          ...taskSharedLists.map((sharedList) => _buildSharedListChip(context, sharedList)),
          const SizedBox(height: 16),
        ],
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showShareTaskDialog(context, ref, sharedLists),
                icon: const Icon(Icons.share),
                label: const Text('Share Task'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _createNewSharedList(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('New List'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSharedListChip(BuildContext context, SharedTaskList sharedList) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Chip(
        avatar: Icon(
          sharedList.isPublic ? Icons.public : Icons.group,
          size: 16,
        ),
        label: Text(sharedList.name),
        onDeleted: () => _showRemoveFromListDialog(context, sharedList),
        deleteIcon: const Icon(Icons.close, size: 16),
      ),
    );
  }

  void _showShareTaskDialog(
    BuildContext context,
    WidgetRef ref,
    List<SharedTaskList> sharedLists,
  ) {
    // Filter out lists that already contain this task
    final availableLists = sharedLists
        .where((list) => !list.taskIds.contains(task.id))
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Task'),
        content: availableLists.isEmpty
            ? const Text('No available shared lists. Create a new one first.')
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Select a shared list to add this task to:'),
                  const SizedBox(height: 16),
                  ...availableLists.map((sharedList) => ListTile(
                    leading: Icon(
                      sharedList.isPublic ? Icons.public : Icons.group,
                    ),
                    title: Text(sharedList.name),
                    subtitle: Text('${sharedList.collaborators.length} collaborators'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _addTaskToSharedList(context, ref, sharedList.id);
                    },
                  )),
                ],
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          if (availableLists.isNotEmpty)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _createNewSharedList(context, ref);
              },
              child: const Text('Create New'),
            ),
        ],
      ),
    );
  }

  void _showRemoveFromListDialog(BuildContext context, SharedTaskList sharedList) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from Shared List'),
        content: Text('Remove this task from "${sharedList.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement remove task from shared list
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Remove from shared list functionality coming soon!'),
                ),
              );
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _createNewSharedList(BuildContext context, WidgetRef ref) {
    Navigator.of(context).pushNamed('/task-sharing', arguments: {
      'taskId': task.id,
    });
  }

  Future<void> _addTaskToSharedList(
    BuildContext context,
    WidgetRef ref,
    String sharedListId,
  ) async {
    try {
      await ref.read(collaborationNotifierProvider.notifier).addTaskToSharedList(
        taskListId: sharedListId,
        taskId: task.id,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task added to shared list successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add task to shared list: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Widget for displaying collaboration activity for a task
class TaskCollaborationActivity extends ConsumerWidget {
  final String taskId;

  const TaskCollaborationActivity({
    super.key,
    required this.taskId,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final changesStream = ref.watch(collaborationChangesProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            changesStream.when(
              data: (change) => _buildActivityItem(change),
              loading: () => const Text('No recent activity'),
              error: (error, stack) => Text('Error: $error'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(CollaborationChange change) {
    if (change.taskId != taskId) {
      return const Text('No recent activity for this task');
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getChangeTypeColor(change.changeType).withOpacity(0.1),
        child: Icon(
          _getChangeTypeIcon(change.changeType),
          color: _getChangeTypeColor(change.changeType),
          size: 16,
        ),
      ),
      title: Text(_getChangeDescription(change)),
      subtitle: Text(
        '${change.userName} • ${_formatDateTime(change.timestamp)}',
        style: const TextStyle(fontSize: 12),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Color _getChangeTypeColor(CollaborationChangeType changeType) {
    switch (changeType) {
      case CollaborationChangeType.taskCreated:
        return Colors.green;
      case CollaborationChangeType.taskUpdated:
        return Colors.blue;
      case CollaborationChangeType.taskCompleted:
        return Colors.purple;
      case CollaborationChangeType.taskDeleted:
        return Colors.red;
      case CollaborationChangeType.collaboratorAdded:
        return Colors.teal;
      case CollaborationChangeType.collaboratorRemoved:
        return Colors.orange;
      case CollaborationChangeType.permissionChanged:
        return Colors.amber;
    }
  }

  IconData _getChangeTypeIcon(CollaborationChangeType changeType) {
    switch (changeType) {
      case CollaborationChangeType.taskCreated:
        return Icons.add_task;
      case CollaborationChangeType.taskUpdated:
        return Icons.edit;
      case CollaborationChangeType.taskCompleted:
        return Icons.check_circle;
      case CollaborationChangeType.taskDeleted:
        return Icons.delete;
      case CollaborationChangeType.collaboratorAdded:
        return Icons.person_add;
      case CollaborationChangeType.collaboratorRemoved:
        return Icons.person_remove;
      case CollaborationChangeType.permissionChanged:
        return Icons.security;
    }
  }

  String _getChangeDescription(CollaborationChange change) {
    switch (change.changeType) {
      case CollaborationChangeType.taskCreated:
        return 'Task was created';
      case CollaborationChangeType.taskUpdated:
        return 'Task was updated';
      case CollaborationChangeType.taskCompleted:
        return 'Task was completed';
      case CollaborationChangeType.taskDeleted:
        return 'Task was deleted';
      case CollaborationChangeType.collaboratorAdded:
        return 'Collaborator was added';
      case CollaborationChangeType.collaboratorRemoved:
        return 'Collaborator was removed';
      case CollaborationChangeType.permissionChanged:
        return 'Permissions were changed';
    }
  }

  String _formatDateTime(DateTime dateTime) {
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
  }
}