import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/entities/task_enums.dart';
import '../providers/task_providers.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/task_form_dialog.dart';

import '../widgets/custom_dialogs.dart';

/// Task detail page showing full task information
class TaskDetailPage extends ConsumerWidget {
  final String taskId;

  const TaskDetailPage({
    super.key,
    required this.taskId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<TaskModel?>(
      future: ref.read(taskRepositoryProvider).getTaskById(taskId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AppScaffold(
            title: 'Task Details',
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return AppScaffold(
            title: 'Task Details',
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading task',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        final task = snapshot.data;
        if (task == null) {
          return AppScaffold(
            title: 'Task Details',
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Task not found',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The task you\'re looking for doesn\'t exist.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        return _TaskDetailView(task: task);
      },
    );
  }
}

/// Task detail view widget
class _TaskDetailView extends ConsumerWidget {
  final TaskModel task;

  const _TaskDetailView({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: 'Task Details',
      actions: [
        IconButton(
          onPressed: () => _editTask(context),
          icon: const Icon(Icons.edit),
          tooltip: 'Edit task',
        ),
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(context, ref, value),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'pin',
              child: ListTile(
                leading: Icon(task.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
                title: Text(task.isPinned ? 'Unpin' : 'Pin'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'duplicate',
              child: ListTile(
                leading: Icon(Icons.copy),
                title: Text('Duplicate'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task header
            _TaskHeader(task: task),
            
            const SizedBox(height: 24),
            
            // Task status actions
            _TaskStatusActions(task: task),
            
            const SizedBox(height: 24),
            
            // Task details
            _TaskDetails(task: task),
            
            const SizedBox(height: 24),
            
            // Subtasks section
            if (task.hasSubTasks) ...[
              _SubTasksSection(task: task),
              const SizedBox(height: 24),
            ],
            
            // Task metadata
            _TaskMetadata(task: task),
          ],
        ),
      ),
    );
  }

  void _editTask(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => TaskFormDialog(task: task),
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    final taskOperations = ref.read(taskOperationsProvider);
    
    switch (action) {
      case 'pin':
        taskOperations.pinTask(task);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(task.isPinned ? 'Task unpinned' : 'Task pinned'),
          ),
        );
        break;
        
      case 'duplicate':
        _duplicateTask(context, ref);
        break;
        
      case 'delete':
        _deleteTask(context, ref);
        break;
    }
  }

  void _duplicateTask(BuildContext context, WidgetRef ref) {
    final duplicatedTask = TaskModel.create(
      title: '${task.title} (Copy)',
      description: task.description,
      priority: task.priority,
      dueDate: task.dueDate,
      tags: task.tags,
      locationTrigger: task.locationTrigger,
      projectId: task.projectId,
      estimatedDuration: task.estimatedDuration,
    );

    ref.read(taskOperationsProvider).createTask(duplicatedTask);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task duplicated successfully')),
    );
  }

  void _deleteTask(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Delete Task',
        content: 'Are you sure you want to delete "${task.title}"? This action cannot be undone.',
        confirmText: 'Delete',
        cancelText: 'Cancel',
        isDestructive: true,
        onConfirm: () async {
          await ref.read(taskOperationsProvider).deleteTask(task.id);
          if (context.mounted) {
            Navigator.of(context).pop(); // Close dialog
            Navigator.of(context).pop(); // Go back to previous screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Task deleted successfully')),
            );
          }
        },
      ),
    );
  }
}

/// Task header widget
class _TaskHeader extends ConsumerWidget {
  final TaskModel task;

  const _TaskHeader({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Completion checkbox
                Checkbox(
                  value: task.status == TaskStatus.completed,
                  onChanged: (value) {
                    ref.read(taskOperationsProvider).toggleTaskCompletion(task);
                  },
                ),
                
                // Priority indicator
                Container(
                  width: 4,
                  height: 32,
                  decoration: BoxDecoration(
                    color: task.priority.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Title and status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          decoration: task.status == TaskStatus.completed
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _StatusChip(status: task.status),
                          const SizedBox(width: 8),
                          _PriorityChip(priority: task.priority),
                          if (task.isPinned) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.push_pin, size: 16),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Description
            if (task.description != null && task.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                task.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Task status actions widget
class _TaskStatusActions extends ConsumerWidget {
  final TaskModel task;

  const _TaskStatusActions({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskOperations = ref.read(taskOperationsProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (task.status != TaskStatus.completed)
                  OutlinedButton.icon(
                    onPressed: () => taskOperations.toggleTaskCompletion(task),
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Mark Complete'),
                  ),
                
                if (task.status == TaskStatus.completed)
                  OutlinedButton.icon(
                    onPressed: () => taskOperations.toggleTaskCompletion(task),
                    icon: const Icon(Icons.undo),
                    label: const Text('Mark Pending'),
                  ),
                
                if (task.status == TaskStatus.pending)
                  OutlinedButton.icon(
                    onPressed: () => taskOperations.markTaskInProgress(task),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                  ),
                
                if (task.status != TaskStatus.cancelled)
                  OutlinedButton.icon(
                    onPressed: () => taskOperations.cancelTask(task),
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Task details widget
class _TaskDetails extends StatelessWidget {
  final TaskModel task;

  const _TaskDetails({required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            
            // Due date
            if (task.dueDate != null)
              _DetailRow(
                icon: Icons.schedule,
                label: 'Due Date',
                value: _formatDate(task.dueDate!),
                valueColor: task.isOverdue ? Colors.red : null,
              ),
            
            // Tags
            if (task.tags.isNotEmpty)
              _DetailRow(
                icon: Icons.label,
                label: 'Tags',
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: task.tags.map((tag) => Chip(
                    label: Text(tag),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )).toList(),
                ),
              ),
            
            // Project
            if (task.hasProject)
              _DetailRow(
                icon: Icons.folder,
                label: 'Project',
                value: task.projectId!,
              ),
            
            // Location trigger
            if (task.hasLocationTrigger)
              _DetailRow(
                icon: Icons.location_on,
                label: 'Location',
                value: task.locationTrigger!,
              ),
            
            // Estimated duration
            if (task.estimatedDuration != null)
              _DetailRow(
                icon: Icons.timer,
                label: 'Estimated Duration',
                value: '${task.estimatedDuration} minutes',
              ),
            
            // Actual duration
            if (task.actualDuration != null)
              _DetailRow(
                icon: Icons.timer_outlined,
                label: 'Actual Duration',
                value: '${task.actualDuration} minutes',
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Subtasks section widget
class _SubTasksSection extends StatelessWidget {
  final TaskModel task;

  const _SubTasksSection({required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Subtasks',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  '${task.subTasks.where((st) => st.isCompleted).length}/${task.subTasks.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Progress indicator
            LinearProgressIndicator(
              value: task.subTaskCompletionPercentage,
            ),
            
            const SizedBox(height: 12),
            
            // Subtasks list
            ...task.subTasks.map((subTask) => CheckboxListTile(
              title: Text(
                subTask.title,
                style: TextStyle(
                  decoration: subTask.isCompleted 
                      ? TextDecoration.lineThrough 
                      : null,
                ),
              ),
              value: subTask.isCompleted,
              onChanged: null, // TODO: Implement subtask toggle
              dense: true,
              contentPadding: EdgeInsets.zero,
            )),
          ],
        ),
      ),
    );
  }
}

/// Task metadata widget
class _TaskMetadata extends StatelessWidget {
  final TaskModel task;

  const _TaskMetadata({required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Metadata',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            
            _DetailRow(
              icon: Icons.add,
              label: 'Created',
              value: _formatDateTime(task.createdAt),
            ),
            
            if (task.updatedAt != null)
              _DetailRow(
                icon: Icons.edit,
                label: 'Updated',
                value: _formatDateTime(task.updatedAt!),
              ),
            
            if (task.completedAt != null)
              _DetailRow(
                icon: Icons.check,
                label: 'Completed',
                value: _formatDateTime(task.completedAt!),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// Detail row widget
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? child;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    this.value,
    this.child,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: child ?? Text(
              value ?? '',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Status chip widget
class _StatusChip extends StatelessWidget {
  final TaskStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(status.displayName),
      backgroundColor: status.color.withOpacity(0.2),
      side: BorderSide(color: status.color),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

/// Priority chip widget
class _PriorityChip extends StatelessWidget {
  final TaskPriority priority;

  const _PriorityChip({required this.priority});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(priority.displayName),
      backgroundColor: priority.color.withOpacity(0.2),
      side: BorderSide(color: priority.color),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}