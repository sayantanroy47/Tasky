import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/typography_constants.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/entities/task_audio_extensions.dart';
import '../../domain/models/enums.dart';
import '../../core/providers/core_providers.dart';
import '../providers/task_provider.dart';
import '../providers/task_providers.dart';
import '../widgets/standardized_app_bar.dart';
import '../widgets/theme_background_widget.dart';
import '../widgets/task_form_dialog.dart';
import '../widgets/subtask_list.dart';
import '../widgets/custom_dialogs.dart';
import '../widgets/dependency_manager.dart';
import '../widgets/glassmorphism_container.dart';
import '../widgets/status_badge_widget.dart';
import '../widgets/audio_widgets.dart';
import '../../core/design_system/design_tokens.dart' hide BorderRadius;

/// Task detail page showing full task information
class TaskDetailPage extends ConsumerWidget {
  final String taskId;

  const TaskDetailPage({
    super.key,
    required this.taskId,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch all tasks to get live updates when task status changes
    final allTasksAsync = ref.watch(tasksProvider);
    
    return allTasksAsync.when(
      loading: () => ThemeBackgroundWidget(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: const StandardizedAppBar(title: 'Task Details'),
          body: const Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stackTrace) => ThemeBackgroundWidget(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: const StandardizedAppBar(title: 'Task Details'),
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
                  error.toString(),
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
        ),
      ),
      data: (tasks) {
        // Find the specific task by ID
        final task = tasks.where((t) => t.id == taskId).isEmpty 
            ? null 
            : tasks.where((t) => t.id == taskId).first;
        
        if (task == null) {
          return ThemeBackgroundWidget(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              extendBodyBehindAppBar: true,
              appBar: const StandardizedAppBar(title: 'Task Details'),
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
    return ThemeBackgroundWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: StandardizedAppBar(
          title: 'Task Details',
          actions: [
            IconButton(
              onPressed: () => _editTask(context, task),
              icon: const Icon(Icons.edit),
              tooltip: 'Edit task',
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(context, ref, value, task),
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
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(
            top: kToolbarHeight + 8,
            left: 16,
            right: 16,
            bottom: 16,
          ),
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
            SubTaskList(task: task),
            const SizedBox(height: 24),
            
            // Dependencies section
            DependencyManager(
              taskId: task.id,
              onChanged: () {
                // Refresh the task data when dependencies change
                // This would trigger a rebuild with updated data
              },
            ),
            const SizedBox(height: 24),
            
            // Task metadata
            _TaskMetadata(task: task),
          ],
        ),
      ),
    ),
    );
  }

  void _editTask(BuildContext context, TaskModel task) {
    showDialog(
      context: context,
      builder: (context) => TaskFormDialog(task: task),
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action, TaskModel task) {
    final taskOperations = ref.read(taskOperationsProvider);
    
    switch (action) {
      case 'pin':
        taskOperations.updateTask(task.copyWith(isPinned: !task.isPinned));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(task.isPinned ? 'Task unpinned' : 'Task pinned'),
          ),
        );
        break;
        
      case 'duplicate':
        _duplicateTask(context, ref, task);
        break;
        
      case 'delete':
        _deleteTask(context, ref, task);
        break;
    }
  }

  void _duplicateTask(BuildContext context, WidgetRef ref, TaskModel task) {
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

  void _deleteTask(BuildContext context, WidgetRef ref, TaskModel task) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Delete Task',
        content: 'Are you sure you want to delete "${task.title}"? This action cannot be undone.',
        confirmText: 'Delete',
        cancelText: 'Cancel',
        isDestructive: true,
        onConfirm: () async {
          await ref.read(taskOperationsProvider).deleteTask(task);
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

/// Task header widget with enhanced glassmorphism design
class _TaskHeader extends ConsumerWidget {
  final TaskModel task;

  const _TaskHeader({required this.task});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return GlassmorphismContainer(
      level: GlassLevel.content,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: const EdgeInsets.all(20),
      glassTint: theme.colorScheme.primaryContainer.withOpacity(0.1),
      borderColor: theme.colorScheme.primary.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Enhanced completion checkbox with glassmorphism
              GlassmorphismContainer(
                level: GlassLevel.interactive,
                borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
                padding: const EdgeInsets.all(4),
                glassTint: task.status == TaskStatus.completed 
                    ? theme.colorScheme.tertiary.withOpacity(0.2)
                    : theme.colorScheme.outline.withOpacity(0.1),
                child: Checkbox(
                  value: task.status == TaskStatus.completed,
                  onChanged: (value) {
                    ref.read(taskOperationsProvider).toggleTaskCompletion(task);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Title and enhanced badges
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        decoration: task.status == TaskStatus.completed
                            ? TextDecoration.lineThrough
                            : null,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Enhanced status and priority badges
                    Row(
                      children: [
                        StatusBadgeWidget(
                          status: task.status,
                          showText: true,
                          compact: false,
                        ),
                        const SizedBox(width: 8),
                        PriorityBadgeWidget(
                          priority: task.priority,
                          showText: true,
                          compact: false,
                        ),
                      ],
                    ),
                    
                    // Pin indicator
                    if (task.isPinned) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(TypographyConstants.radiusXSmall),
                              border: Border.all(
                                color: theme.colorScheme.secondary.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.push_pin,
                                  size: 14,
                                  color: theme.colorScheme.secondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Pinned',
                                  style: TextStyle(
                                    fontSize: TypographyConstants.textXS,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          
          // Description with enhanced styling
          if (task.description != null && task.description!.isNotEmpty) ...[
            const SizedBox(height: 20),
            GlassmorphismContainer(
              level: GlassLevel.interactive,
              borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
              padding: const EdgeInsets.all(16),
              glassTint: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.description,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Description',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    task.description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Audio player section for voice tasks
          if (task.hasAudio && task.audioFilePath != null) ...[
            const SizedBox(height: 20),
            FullAudioPlayer(
              taskId: task.id,
              audioFilePath: task.audioFilePath!,
              showMetadata: true,
            ),
          ],
        ],
      ),
    );
  }
}

/// Task status actions widget with glassmorphism design
class _TaskStatusActions extends ConsumerWidget {
  final TaskModel task;

  const _TaskStatusActions({required this.task});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final taskOperations = ref.read(taskOperationsProvider);
    
    return GlassmorphismContainer(
      level: GlassLevel.content,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: const EdgeInsets.all(20),
      glassTint: theme.colorScheme.secondaryContainer.withOpacity(0.1),
      borderColor: theme.colorScheme.secondary.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.touch_app,
                size: 20,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Quick Actions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              if (task.status != TaskStatus.completed)
                _buildActionButton(
                  theme: theme,
                  onPressed: () => taskOperations.toggleTaskCompletion(task),
                  icon: Icons.check_circle,
                  label: 'Complete',
                  color: theme.colorScheme.tertiary,
                ),
              
              if (task.status == TaskStatus.completed)
                _buildActionButton(
                  theme: theme,
                  onPressed: () => taskOperations.toggleTaskCompletion(task),
                  icon: Icons.undo,
                  label: 'Reopen',
                  color: theme.colorScheme.primary,
                ),
              
              if (task.status == TaskStatus.pending)
                _buildActionButton(
                  theme: theme,
                  onPressed: () => taskOperations.updateTask(task.copyWith(status: TaskStatus.inProgress)),
                  icon: Icons.play_arrow,
                  label: 'Start',
                  color: theme.colorScheme.secondary,
                ),
              
              if (task.status != TaskStatus.cancelled)
                _buildActionButton(
                  theme: theme,
                  onPressed: () => taskOperations.updateTask(task.copyWith(status: TaskStatus.cancelled)),
                  icon: Icons.cancel,
                  label: 'Cancel',
                  color: theme.colorScheme.error,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required ThemeData theme,
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return GlassmorphismContainer(
      level: GlassLevel.interactive,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      glassTint: color.withOpacity(0.15),
      borderColor: color.withOpacity(0.3),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: color,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: TypographyConstants.textSM,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Task details widget with glassmorphism design
class _TaskDetails extends StatelessWidget {
  final TaskModel task;

  const _TaskDetails({required this.task});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GlassmorphismContainer(
      level: GlassLevel.content,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: const EdgeInsets.all(20),
      glassTint: theme.colorScheme.surfaceContainerHighest.withOpacity(0.1),
      borderColor: theme.colorScheme.outline.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Task Details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Due date
          if (task.dueDate != null)
            _DetailRow(
              icon: Icons.schedule,
              label: 'Due Date',
              value: _formatDate(task.dueDate!),
              valueColor: task.isOverdue ? theme.colorScheme.error : null,
              theme: theme,
            ),
          
          // Tags
          if (task.tags.isNotEmpty)
            _DetailRow(
              icon: Icons.label,
              label: 'Categories',
              theme: theme,
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: task.tags.map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusXSmall),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '#$tag',
                    style: TextStyle(
                      fontSize: TypographyConstants.textXS,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                )).toList(),
              ),
            ),
          
          // Project
          if (task.hasProject)
            _DetailRow(
              icon: Icons.folder,
              label: 'Project',
              value: task.projectId!,
              theme: theme,
            ),
          
          // Location trigger
          if (task.hasLocationTrigger)
            _DetailRow(
              icon: Icons.location_on,
              label: 'Location Trigger',
              value: task.locationTrigger!,
              theme: theme,
            ),
          
          // Estimated duration
          if (task.estimatedDuration != null)
            _DetailRow(
              icon: Icons.timer,
              label: 'Estimated Duration',
              value: '${task.estimatedDuration} minutes',
              theme: theme,
            ),
          
          // Actual duration
          if (task.actualDuration != null)
            _DetailRow(
              icon: Icons.timer_outlined,
              label: 'Actual Duration',
              value: '${task.actualDuration} minutes',
              theme: theme,
            ),
          
          // Audio recording section
          if (task.hasAudio)
            _DetailRow(
              icon: Icons.audio_file,
              label: 'Voice Recording',
              theme: theme,
              child: FullAudioPlayer(
                taskId: task.id,
                audioFilePath: task.audioFilePath!,
                showMetadata: true,
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}



/// Task metadata widget with glassmorphism design
class _TaskMetadata extends StatelessWidget {
  final TaskModel task;

  const _TaskMetadata({required this.task});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GlassmorphismContainer(
      level: GlassLevel.content,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: const EdgeInsets.all(20),
      glassTint: theme.colorScheme.tertiaryContainer.withOpacity(0.1),
      borderColor: theme.colorScheme.tertiary.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history,
                size: 20,
                color: theme.colorScheme.tertiary,
              ),
              const SizedBox(width: 8),
              Text(
                'Activity History',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _DetailRow(
            icon: Icons.add_circle_outline,
            label: 'Created',
            value: _formatDateTime(task.createdAt),
            theme: theme,
          ),
          
          if (task.updatedAt != null)
            _DetailRow(
              icon: Icons.edit_note,
              label: 'Last Modified',
              value: _formatDateTime(task.updatedAt!),
              theme: theme,
            ),
          
          if (task.completedAt != null)
            _DetailRow(
              icon: Icons.check_circle_outline,
              label: 'Completed',
              value: _formatDateTime(task.completedAt!),
              theme: theme,
            ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// Enhanced detail row widget with glassmorphism styling
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? child;
  final Color? valueColor;
  final ThemeData theme;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.theme,
    this.value,
    this.child,
    this.valueColor,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(TypographyConstants.radiusXSmall),
            ),
            child: Icon(
              icon, 
              size: 16,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                child ?? Text(
                  value ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: valueColor ?? theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

