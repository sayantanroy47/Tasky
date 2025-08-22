import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/collaboration_provider.dart';
import '../../services/collaboration_service.dart';
import '../../domain/entities/task_model.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
                Icon(PhosphorIcons.users(), color: Theme.of(context).primaryColor),
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
          const Text('This task is shared in:',
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
                icon: Icon(PhosphorIcons.share()),
                label: const Text('Share Task'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _createNewSharedList(context, ref),
                icon: Icon(PhosphorIcons.plus()),
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
          sharedList.isPublic ? PhosphorIcons.globe() : PhosphorIcons.users(),
          size: 16,
        ),
        label: Text(sharedList.name),
        onDeleted: () => _showRemoveFromListDialog(context, sharedList),
        deleteIcon: Icon(PhosphorIcons.x(), size: 16),
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
                      sharedList.isPublic ? PhosphorIcons.globe() : PhosphorIcons.users(),
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
              // Remove task from shared list
              _removeTaskFromSharedList(context, task);
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

  void _removeTaskFromSharedList(BuildContext context, TaskModel task) {
    // Show confirmation and remove task from shared list
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task "${task.title}" removed from shared list'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Re-add to shared list if undo is pressed
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Task restored to shared list'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ),
    );
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


