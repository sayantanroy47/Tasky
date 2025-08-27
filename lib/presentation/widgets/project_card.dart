import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/typography_constants.dart';
import '../../core/utils/text_utils.dart';
import '../../domain/entities/project.dart';
import '../../services/project_service.dart';
import '../../services/ui/slidable_action_service.dart';
import '../../services/ui/slidable_feedback_service.dart';
import '../../services/ui/slidable_theme_service.dart';
import '../providers/project_providers.dart';
import '../providers/tag_providers.dart';
import 'standardized_card.dart';
import 'standardized_error_states.dart';
import 'tag_chip.dart';

/// A card widget that displays project information
///
/// Shows project name, description, progress, and provides
/// actions for editing, archiving, and deleting projects.
class ProjectCard extends ConsumerWidget {
  final Project project;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final projectStatsAsync = ref.watch(projectStatsProvider(project.id));

    final leftActions = SlidableActionService.getProjectActions(
      project,
      colorScheme: theme.colorScheme,
      onEdit: onEdit,
      onViewTasks: () => _viewProjectTasks(context),
      onShare: () => _shareProject(context),
      onArchive: () => _toggleArchiveProject(ref),
      onDelete: () => _showDeleteConfirmation(context, ref),
    );

    // Split actions for left and right panes
    final startActions = leftActions.take(2).toList(); // Edit, View Tasks
    final endActions = leftActions.skip(2).toList(); // Share, Archive, Delete

    final projectCard = StandardizedCardVariants.project(
      onTap: onTap,
      accentColor: _parseColor(project.color, context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with project name and actions
          Row(
            children: [
              // Project color indicator
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: _parseColor(project.color, context),
                  borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                ),
              ),
              const SizedBox(width: 12),

              // Project name and description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TextUtils.autoCapitalize(project.name),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (project.description != null && project.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          project.description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),

              // Actions menu
              if (showActions)
                PopupMenuButton<String>(
                  onSelected: (value) => _handleAction(context, ref, value),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(PhosphorIcons.pencil()),
                          const SizedBox(width: 8),
                          const Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: project.isArchived ? 'unarchive' : 'archive',
                      child: Row(
                        children: [
                          Icon(project.isArchived ? PhosphorIcons.archive() : PhosphorIcons.archive()),
                          const SizedBox(width: 8),
                          Text(project.isArchived ? 'Unarchive' : 'Archive'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Builder(
                        builder: (context) => Row(
                          children: [
                            Icon(PhosphorIcons.trash(), color: Theme.of(context).colorScheme.error),
                            const SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Project tags
          if (project.tagIds.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildProjectTags(),
          ],

          const SizedBox(height: 16),

          // Project statistics
          projectStatsAsync.when(
            data: (stats) => _buildProjectStats(context, stats),
            loading: () => StandardizedErrorStateVariants.loadingData(
              message: 'Loading project stats...',
              compact: true,
            ),
            error: (error, _) => StandardizedErrorStates.error(
              message: 'Failed to load project statistics',
              severity: ErrorSeverity.moderate,
              compact: true,
            ),
          ),

          // Deadline and status indicators
          const SizedBox(height: 12),
          Row(
            children: [
              // Task count
              _buildInfoChip(
                context,
                icon: PhosphorIcons.checkSquare(),
                label: '${project.taskCount} tasks',
              ),

              const SizedBox(width: 8),

              // Deadline
              if (project.hasDeadline)
                _buildInfoChip(
                  context,
                  icon: PhosphorIcons.clock(),
                  label: _formatDeadline(project.deadline!),
                  color: project.isOverdue ? theme.colorScheme.error : null,
                ),

              const Spacer(),

              // Archived indicator
              if (project.isArchived)
                Icon(
                  PhosphorIcons.archive(),
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ],
      ),
    );

    return SlidableThemeService.createProjectCardSlidable(
      key: ValueKey('project-${project.id}'),
      groupTag: 'project-cards',
      leftActions: startActions,
      rightActions: endActions,
      accentColor: _parseColor(project.color, context),
      child: projectCard,
    );
  }

  Widget _buildProjectStats(BuildContext context, ProjectStats stats) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Progress bar
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: stats.completionPercentage,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _parseColor(project.color, context),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${(stats.completionPercentage * 100).round()}%',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Task breakdown
        Row(
          children: [
            _buildStatItem(
              context,
              label: 'Completed',
              value: stats.completedTasks.toString(),
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 16),
            _buildStatItem(
              context,
              label: 'In Progress',
              value: stats.inProgressTasks.toString(),
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(width: 16),
            _buildStatItem(
              context,
              label: 'Pending',
              value: stats.pendingTasks.toString(),
              color: theme.colorScheme.tertiary,
            ),
            if (stats.overdueTasks > 0) ...[
              const SizedBox(width: 16),
              _buildStatItem(
                context,
                label: 'Overdue',
                value: stats.overdueTasks.toString(),
                color: theme.colorScheme.error,
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    Color? color,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? theme.colorScheme.surfaceContainerHighest).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color ?? theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color ?? theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for project slide actions

  void _viewProjectTasks(BuildContext context) {
    SlidableFeedbackService.provideFeedback(SlidableActionType.neutral);
    Navigator.of(context).pushNamed('/project-detail', arguments: project.id);
  }

  void _shareProject(BuildContext context) {
    SlidableFeedbackService.provideFeedback(SlidableActionType.neutral);
    // Implementation would share project details
  }

  void _toggleArchiveProject(WidgetRef ref) {
    SlidableFeedbackService.provideFeedback(SlidableActionType.archive);
    if (project.isArchived) {
      ref.read(projectsProvider.notifier).unarchiveProject(project.id);
    } else {
      ref.read(projectsProvider.notifier).archiveProject(project.id);
    }
  }

  void _handleAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'edit':
        onEdit?.call();
        break;
      case 'archive':
        ref.read(projectsProvider.notifier).archiveProject(project.id);
        break;
      case 'unarchive':
        ref.read(projectsProvider.notifier).unarchiveProject(project.id);
        break;
      case 'delete':
        _showDeleteConfirmation(context, ref);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text(
          'Are you sure you want to delete "${TextUtils.autoCapitalize(project.name)}"? This will remove the project from all associated tasks but will not delete the tasks themselves.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(projectsProvider.notifier).deleteProject(project.id);
              onDelete?.call();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String colorString, BuildContext context) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Theme.of(context).colorScheme.primary; // Default color
    }
  }

  String _formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now).inDays;

    if (difference < 0) {
      return 'Overdue';
    } else if (difference == 0) {
      return 'Due today';
    } else if (difference == 1) {
      return 'Due tomorrow';
    } else if (difference <= 7) {
      return 'Due in $difference days';
    } else {
      return 'Due ${deadline.day}/${deadline.month}';
    }
  }

  /// Builds the project tags display using TagChipList with proper provider
  Widget _buildProjectTags() {
    if (project.tagIds.isEmpty) return const SizedBox.shrink();

    return Consumer(
      builder: (context, ref, child) {
        final tagsProvider = ref.watch(tagsByIdsProvider(project.tagIds));
        return tagsProvider.when(
          data: (tags) => TagChipList(
            tags: tags,
            chipSize: TagChipSize.small,
            maxChips: 4, // Show more chips for projects since they typically have fewer tags
            spacing: 3.0, // 3px spacing as requested
            onTagTap: onTap != null ? (_) => onTap!() : null,
          ),
          loading: () => const SizedBox(
            height: 20,
            child: Row(
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 1),
                ),
              ],
            ),
          ),
          error: (_, __) => const SizedBox.shrink(), // Hide on error
        );
      },
    );
  }
}
