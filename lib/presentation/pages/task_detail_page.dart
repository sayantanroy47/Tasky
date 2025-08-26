import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/design_system/design_tokens.dart';
import '../../core/theme/typography_constants.dart';
import '../../core/utils/text_utils.dart';
import '../../domain/entities/task_audio_extensions.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../providers/audio_providers.dart';
import '../providers/task_provider.dart' show taskOperationsProvider;
import '../providers/task_providers.dart';
import '../widgets/enhanced_subtask_list.dart';
import '../widgets/glassmorphism_container.dart';
import '../widgets/standardized_app_bar.dart';
import '../widgets/standardized_text.dart';
import '../widgets/status_badge_widget.dart';
import '../widgets/task_form_dialog.dart';
import '../widgets/theme_background_widget.dart';
import '../widgets/standardized_icons.dart' show StandardizedIcon, StandardizedIconSize, StandardizedIconStyle;
import '../widgets/standardized_page_dialogs.dart';
import '../widgets/standardized_notifications.dart';
import '../widgets/standardized_colors.dart';

/// Task detail page showing comprehensive task information
class TaskDetailPage extends ConsumerWidget {
  final String taskId;

  const TaskDetailPage({
    super.key,
    required this.taskId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTasksAsync = ref.watch(tasksProvider);

    return allTasksAsync.when(
      loading: () => const ThemeBackgroundWidget(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: StandardizedAppBar(title: 'Task Details'),
          body: Center(child: CircularProgressIndicator()),
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
                StandardizedIcon(
                  PhosphorIcons.warningCircle(),
                  size: StandardizedIconSize.xxxl,
                  style: StandardizedIconStyle.error,
                ),
                const SizedBox(height: 16),
                StandardizedText('Error loading task: $error', style: StandardizedTextStyle.bodyMedium),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const StandardizedText('Go Back', style: StandardizedTextStyle.buttonText),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (tasks) {
        final task = tasks.cast<TaskModel?>().firstWhere(
              (t) => t?.id == taskId,
              orElse: () => null,
            );

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
                    StandardizedIcon(
                      PhosphorIcons.checkSquare(),
                      size: StandardizedIconSize.xxxl,
                      style: StandardizedIconStyle.disabled,
                    ),
                    const SizedBox(height: 16),
                    const StandardizedText('Task not found', style: StandardizedTextStyle.bodyMedium),
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

/// Main task detail view widget
class _TaskDetailView extends ConsumerWidget {
  final TaskModel task;

  const _TaskDetailView({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return ThemeBackgroundWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: StandardizedAppBar(
          title: 'Task Details',
          actions: [
            IconButton(
              icon: Icon(PhosphorIcons.pencil()),
              onPressed: () => _editTask(context, ref),
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(context, ref, value),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'duplicate',
                  child: SizedBox(
                    width: 150,
                    child: ListTile(
                      leading: Icon(PhosphorIcons.copy()),
                      title: const StandardizedText('Duplicate', style: StandardizedTextStyle.bodyMedium),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'share',
                  child: SizedBox(
                    width: 150,
                    child: ListTile(
                      leading: Icon(PhosphorIcons.share()),
                      title: const StandardizedText('Share', style: StandardizedTextStyle.bodyMedium),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: SizedBox(
                    width: 150,
                    child: ListTile(
                      leading: Icon(PhosphorIcons.trash(), color: context.errorColor),
                      title: StandardizedText('Delete', style: StandardizedTextStyle.bodyMedium, color: context.errorColor),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task header
              _TaskHeader(task: task),
              const SizedBox(height: 24),

              // Task dependencies
              if (task.dependencies.isNotEmpty) ...[
                _TaskDependencies(task: task),
                const SizedBox(height: 24),
              ],

              // Audio/voice section for voice tasks
              if (task.hasVoiceMetadata) ...[
                const SizedBox(height: 24),
                _buildVoiceSection(task),
              ],

              // Subtasks section
              const SizedBox(height: 24),
              EnhancedSubTaskList(
                task: task,
                isEditable: true,
                showHeader: true,
              ),

              // Lazy-loaded sections for better performance
              const SizedBox(height: 24),
              _LazySection(
                title: 'Attachments',
                icon: PhosphorIcons.paperclip(),
                builder: () => _buildAttachmentsSection(context, theme, task),
              ),

              const SizedBox(height: 24),
              _LazySection(
                title: 'Activity History',
                icon: PhosphorIcons.clockCounterClockwise(),
                builder: () => _buildHistorySection(context, theme, task),
              ),

              const SizedBox(height: 24),
              _LazySection(
                title: 'Collaboration',
                icon: PhosphorIcons.users(),
                builder: () => _buildCollaborationSection(context, theme, task, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editTask(BuildContext context, WidgetRef ref) {
    // Navigate to task form in full-screen edit mode
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TaskFormDialog(
          task: task,
          isEditing: true,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'duplicate':
        _duplicateTask(context, ref);
        break;
      case 'share':
        _shareTask(context, ref);
        break;
      case 'delete':
        _deleteTask(context, ref);
        break;
    }
  }

  void _duplicateTask(BuildContext context, WidgetRef ref) {
    final duplicatedTask = task.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '${TextUtils.autoCapitalize(task.title)} (Copy)',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      completedAt: null,
      status: TaskStatus.pending,
    );

    ref.read(taskOperationsProvider).createTask(duplicatedTask);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: StandardizedText('Task duplicated successfully', style: StandardizedTextStyle.bodyMedium)),
    );
  }

  void _shareTask(BuildContext context, WidgetRef ref) {
    // Implement basic task sharing
    final taskText = _generateShareText(task);

    // For now, copy to clipboard - can be extended to use Share package
    // Clipboard.setData(ClipboardData(text: taskText));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: StandardizedText('Task details: $taskText', style: StandardizedTextStyle.bodyMedium),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _generateShareText(TaskModel task) {
    final buffer = StringBuffer();
    buffer.writeln('Task: ${TextUtils.autoCapitalize(task.title)}');

    if (task.description != null) {
      buffer.writeln('Description: ${task.description}');
    }

    buffer.writeln('Status: ${task.status.name}');
    buffer.writeln('Priority: ${task.priority.name}');

    if (task.dueDate != null) {
      buffer.writeln('Due: ${_formatDateTime(task.dueDate!)}');
    }

    if (task.tags.isNotEmpty) {
      buffer.writeln('Tags: ${task.tags.join(', ')}');
    }

    return buffer.toString();
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _deleteTask(BuildContext context, WidgetRef ref) async {
    final navigator = Navigator.of(context);
    final confirmed = await context.showConfirmationDialog(
      title: 'Delete Task',
      message: 'Are you sure you want to delete this task?',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      isDestructive: true,
    );
    
    if (confirmed == true) {
      ref.read(taskOperationsProvider).deleteTask(task);
      navigator.pop(); // Go back to previous screen
      if (context.mounted) {
        context.notifyTaskDeleted();
      }
    }
  }

  Widget _buildAttachmentsSection(BuildContext context, ThemeData theme, TaskModel task) {
    final attachments = task.metadata['attachments'] as List<Map<String, dynamic>>? ?? [];

    return GlassmorphismContainer(
      level: GlassLevel.content,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.paperclip(),
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              StandardizedTextVariants.sectionHeader('Attachments'),
              const Spacer(),
              IconButton(
                onPressed: () => _addAttachment(context, task),
                icon: Icon(PhosphorIcons.plus()),
                iconSize: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (attachments.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    PhosphorIcons.paperclip(),
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  StandardizedText(
                    'No attachments yet',
                    style: StandardizedTextStyle.bodyMedium,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            )
          else
            ...attachments.map((attachment) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard), // 8.0 - Fixed border radius hierarchy
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getAttachmentIcon(attachment['type'] as String? ?? ''),
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StandardizedText(
                              attachment['name'] as String? ?? 'Unknown',
                              style: StandardizedTextStyle.titleMedium,
                            ),
                            if (attachment['size'] != null)
                              StandardizedText(
                                _formatFileSize(attachment['size'] as int),
                                style: StandardizedTextStyle.bodySmall,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _openAttachment(attachment),
                        icon: Icon(PhosphorIcons.arrowSquareOut()),
                        iconSize: 16,
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildHistorySection(BuildContext context, ThemeData theme, TaskModel task) {
    final history = _generateTaskHistory(task, context);

    return GlassmorphismContainer(
      level: GlassLevel.content,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.clockCounterClockwise(),
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              StandardizedTextVariants.sectionHeader('Activity History'),
            ],
          ),
          const SizedBox(height: 16),
          if (history.isEmpty)
            Center(
              child: StandardizedText(
                'No activity history',
                style: StandardizedTextStyle.bodyMedium,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            Column(
              children: history
                  .take(5)
                  .map((entry) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(top: 8),
                              decoration: BoxDecoration(
                                color: entry['color'] as Color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  StandardizedText(
                                    entry['action'] as String,
                                    style: StandardizedTextStyle.titleMedium,
                                  ),
                                  StandardizedText(
                                    _formatDateTime(entry['timestamp'] is DateTime
                                        ? entry['timestamp'] as DateTime
                                        : DateTime.now()),
                                    style: StandardizedTextStyle.bodySmall,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          if (history.length > 5)
            Center(
              child: TextButton(
                onPressed: () => _showFullHistory(context, task),
                child: StandardizedText('View all ${history.length} entries', style: StandardizedTextStyle.buttonText),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCollaborationSection(BuildContext context, ThemeData theme, TaskModel task, WidgetRef ref) {
    final collaborators = task.metadata['collaborators'] as List<String>? ?? [];

    return GlassmorphismContainer(
      level: GlassLevel.content,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.users(),
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              StandardizedTextVariants.sectionHeader('Collaboration'),
              const Spacer(),
              IconButton(
                onPressed: () => _inviteCollaborator(context, task),
                icon: Icon(PhosphorIcons.userPlus()),
                iconSize: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (collaborators.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    PhosphorIcons.userPlus(),
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  StandardizedText(
                    'No collaborators yet',
                    style: StandardizedTextStyle.bodyMedium,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => _inviteCollaborator(context, task),
                    child: const StandardizedText('Invite someone', style: StandardizedTextStyle.buttonText),
                  ),
                ],
              ),
            )
          else
            ...collaborators.map((email) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard), // 8.0 - Fixed border radius hierarchy
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                        child: StandardizedText(
                          email.substring(0, 1).toUpperCase(),
                          style: StandardizedTextStyle.labelLarge,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StandardizedText(
                          email,
                          style: StandardizedTextStyle.bodyMedium,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _removeCollaborator(context, task, email),
                        icon: Icon(PhosphorIcons.minusCircle(), size: 16),
                      ),
                    ],
                  ),
                )),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _shareTask(context, ref),
                  icon: Icon(PhosphorIcons.share()),
                  label: const StandardizedText('Share Task', style: StandardizedTextStyle.buttonText),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _exportTask(context, task),
                  icon: Icon(PhosphorIcons.download()),
                  label: const StandardizedText('Export', style: StandardizedTextStyle.buttonText),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    foregroundColor: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods for new functionality

  void _addAttachment(BuildContext context, TaskModel task) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: StandardizedText('Attachment feature coming soon!', style: StandardizedTextStyle.bodyMedium)),
    );
  }

  void _openAttachment(Map<String, dynamic> attachment) {
    // Open attachment logic
  }

  void _inviteCollaborator(BuildContext context, TaskModel task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const StandardizedText('Invite Collaborator', style: StandardizedTextStyle.titleMedium),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Enter email address...',
            prefixIcon: Icon(PhosphorIcons.envelope()),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const StandardizedText('Cancel', style: StandardizedTextStyle.buttonText),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: StandardizedText('Invitation sent!', style: StandardizedTextStyle.bodyMedium)),
              );
            },
            child: const StandardizedText('Invite', style: StandardizedTextStyle.buttonText),
          ),
        ],
      ),
    );
  }

  void _removeCollaborator(BuildContext context, TaskModel task, String email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const StandardizedText('Remove Collaborator', style: StandardizedTextStyle.titleMedium),
        content: StandardizedText('Remove $email from this task?', style: StandardizedTextStyle.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const StandardizedText('Cancel', style: StandardizedTextStyle.buttonText),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: StandardizedText('Collaborator removed', style: StandardizedTextStyle.bodyMedium)),
              );
            },
            child: const StandardizedText('Remove', style: StandardizedTextStyle.buttonText),
          ),
        ],
      ),
    );
  }

  void _exportTask(BuildContext context, TaskModel task) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: StandardizedText('Export feature coming soon!', style: StandardizedTextStyle.bodyMedium)),
    );
  }

  void _showFullHistory(BuildContext context, TaskModel task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const StandardizedText('Full History', style: StandardizedTextStyle.titleLarge)),
          body: const Center(
            child: StandardizedText('Full history view coming soon!', style: StandardizedTextStyle.bodyMedium),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _generateTaskHistory(TaskModel task, BuildContext context) {
    return [
      {
        'action': 'Task created',
        'timestamp': task.createdAt,
        'color': Theme.of(context).colorScheme.tertiary,
      },
      if (task.updatedAt != task.createdAt)
        {
          'action': 'Task updated',
          'timestamp': task.updatedAt,
          'color': Theme.of(context).colorScheme.primary,
        },
      if (task.isCompleted)
        {
          'action': 'Task completed',
          'timestamp': task.updatedAt,
          'color': Theme.of(context).colorScheme.tertiary,
        },
    ];
  }

  IconData _getAttachmentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'image':
        return PhosphorIcons.image();
      case 'pdf':
        return PhosphorIcons.filePdf();
      case 'document':
        return PhosphorIcons.fileText();
      case 'audio':
        return PhosphorIcons.fileAudio();
      case 'video':
        return PhosphorIcons.video();
      default:
        return PhosphorIcons.paperclip();
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Widget _buildVoiceSection(TaskModel task) {
    // For voice tasks, show either audio player or transcription display
    if (task.hasPlayableAudio) {
      // Has actual audio file - show player
      return _FullAudioPlayer(
        taskId: task.id,
        audioFilePath: task.audioFilePath!,
        duration: task.audioDuration,
      );
    } else if (task.hasVoiceMetadata) {
      // Voice-created but no audio file (e.g., native speech-to-text) - show transcription
      return _VoiceTranscriptionDisplay(task: task);
    }

    return const SizedBox.shrink();
  }
}

/// Task header widget with title and basic info
class _TaskHeader extends StatelessWidget {
  final TaskModel task;

  const _TaskHeader({required this.task});

  @override
  Widget build(BuildContext context) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: StandardizedTextVariants.taskTitle(
                  task.title,
                  maxLines: null,
                ),
              ),
              const SizedBox(width: 12),
              StatusBadgeWidget(status: task.status),
            ],
          ),

          if (task.description != null) ...[
            const SizedBox(height: 16),
            StandardizedTextVariants.taskDescription(
              task.description!,
              maxLines: null,
            ),
          ],

          const SizedBox(height: 16),

          // Task metadata
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              if (task.dueDate != null)
                _InfoChip(
                  icon: PhosphorIcons.clock(),
                  label: 'Due: ${_formatDateTime(task.dueDate!)}',
                ),
              if (task.priority != TaskPriority.medium)
                _InfoChip(
                  icon: PhosphorIcons.flag(),
                  label: 'Priority: ${task.priority.name}',
                ),
              if (task.tags.isNotEmpty)
                _InfoChip(
                  icon: PhosphorIcons.tag(),
                  label: '${task.tags.length} tags',
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// Info chip widget for displaying task metadata
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge), // 16.0 - Fixed border radius hierarchy
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          StandardizedText(
            label,
            style: StandardizedTextStyle.bodySmall,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

/// Voice transcription display widget for voice-to-text tasks
class _VoiceTranscriptionDisplay extends StatelessWidget {
  final TaskModel task;

  const _VoiceTranscriptionDisplay({required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transcription = task.transcriptionText ?? task.description ?? '';

    if (transcription.isEmpty) return const SizedBox.shrink();

    return GlassmorphismContainer(
      level: GlassLevel.interactive,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: const EdgeInsets.all(20),
      glassTint: theme.colorScheme.secondaryContainer.withValues(alpha: 0.2),
      borderColor: theme.colorScheme.secondary.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                PhosphorIcons.microphone(),
                size: 20,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StandardizedText(
                  'Voice Transcription',
                  style: StandardizedTextStyle.titleMedium,
                  color: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(TypographyConstants.radiusMedium), // 12.0 - Fixed border radius hierarchy
                  border: Border.all(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.2),
                  ),
                ),
                child: StandardizedText(
                  task.creationMode == 'voiceToText' ? 'Speech-to-Text' : 'Voice Created',
                  style: StandardizedTextStyle.labelLarge,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Transcription text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
            child: StandardizedText(
              transcription,
              style: StandardizedTextStyle.bodyLarge,
              lineHeight: 1.5,
            ),
          ),

          if (task.audioRecordingTimestamp != null) ...[
            const SizedBox(height: 12),
            StandardizedText(
              'Recorded: ${_formatDateTime(task.audioRecordingTimestamp!)}',
              style: StandardizedTextStyle.bodySmall,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// Full audio player widget for task detail page
class _FullAudioPlayer extends ConsumerStatefulWidget {
  final String taskId;
  final String audioFilePath;
  final Duration? duration;

  const _FullAudioPlayer({
    required this.taskId,
    required this.audioFilePath,
    this.duration,
  });

  @override
  ConsumerState<_FullAudioPlayer> createState() => _FullAudioPlayerState();
}

class _FullAudioPlayerState extends ConsumerState<_FullAudioPlayer> {
  bool _isPlaying = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassmorphismContainer(
      level: GlassLevel.interactive,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: const EdgeInsets.all(20),
      glassTint: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.2),
      borderColor: theme.colorScheme.tertiary.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                PhosphorIcons.fileAudio(),
                size: 20,
                color: theme.colorScheme.tertiary,
              ),
              const SizedBox(width: 8),
              StandardizedText(
                'Voice Recording',
                style: StandardizedTextStyle.titleMedium,
                color: theme.colorScheme.tertiary,
              ),
              const Spacer(),
              if (widget.duration != null)
                StandardizedText(
                  _formatDuration(widget.duration!),
                  style: StandardizedTextStyle.bodySmall,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Play/Pause button
              GlassmorphismContainer(
                level: GlassLevel.interactive,
                borderRadius: BorderRadius.circular(30),
                padding: const EdgeInsets.all(12),
                glassTint: theme.colorScheme.tertiary.withValues(alpha: 0.2),
                borderColor: theme.colorScheme.tertiary.withValues(alpha: 0.4),
                child: IconButton(
                  onPressed: _isLoading ? null : _togglePlayPause,
                  icon: _isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.tertiary,
                          ),
                        )
                      : Icon(
                          _isPlaying ? PhosphorIcons.pause() : PhosphorIcons.play(),
                          size: 32,
                          color: theme.colorScheme.tertiary,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _togglePlayPause() async {
    setState(() => _isLoading = true);

    try {
      final audioService = ref.read(audioPlayerServiceProvider);

      if (_isPlaying) {
        await audioService.stop();
      } else {
        await audioService.loadAudio(widget.audioFilePath, widget.taskId);
        await audioService.play();
      }

      setState(() => _isPlaying = !_isPlaying);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: StandardizedText('Error: $e', style: StandardizedTextStyle.bodyMedium),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Task dependencies widget
class _TaskDependencies extends ConsumerWidget {
  final TaskModel task;

  const _TaskDependencies({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return GlassmorphismContainer(
      level: GlassLevel.content,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: const EdgeInsets.all(20),
      glassTint: theme.colorScheme.secondaryContainer.withValues(alpha: 0.1),
      borderColor: theme.colorScheme.secondary.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.tree(),
                size: 20,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              StandardizedText(
                'Task Dependencies',
                style: StandardizedTextStyle.titleMedium,
                color: theme.colorScheme.secondary,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Dependencies list
          if (task.dependencies.isNotEmpty) ...[
            const StandardizedText(
              'Depends on:',
              style: StandardizedTextStyle.titleMedium,
            ),
            const SizedBox(height: 8),
            ...task.dependencies.map((depId) => Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard), // 8.0 - Fixed border radius hierarchy
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: StandardizedText(
                    'Task ID: $depId',
                    style: StandardizedTextStyle.bodySmall,
                  ),
                )),
          ] else ...[
            StandardizedText(
              'No dependencies',
              style: StandardizedTextStyle.bodyMedium,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ],
      ),
    );
  }
}

/// Lazy loading widget that only builds content when expanded
class _LazySection extends StatefulWidget {
  final String title;
  final IconData icon;
  final Widget Function() builder;

  const _LazySection({
    required this.title,
    required this.icon,
    required this.builder,
  });

  @override
  State<_LazySection> createState() => _LazySectionState();
}

class _LazySectionState extends State<_LazySection> {
  bool _isExpanded = false;
  Widget? _cachedContent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassmorphismContainer(
      level: GlassLevel.content,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Expandable header
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
                if (_isExpanded && _cachedContent == null) {
                  // Build content only when first expanded
                  _cachedContent = widget.builder();
                }
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Icon(
                    widget.icon,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StandardizedTextVariants.sectionHeader(
                      widget.title,
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      PhosphorIcons.caretRight(),
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable content
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: _isExpanded ? null : 0,
            child: AnimatedOpacity(
              opacity: _isExpanded ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: _isExpanded && _cachedContent != null
                  ? Column(
                      children: [
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),
                        _cachedContent!,
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
