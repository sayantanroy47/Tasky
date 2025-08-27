import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/typography_constants.dart';
import '../../domain/entities/project.dart';
import '../../core/utils/text_utils.dart';
import '../../domain/entities/task_model.dart';
import '../../services/project_service.dart';
import '../providers/project_providers.dart';
import '../providers/task_providers.dart';
import '../widgets/advanced_task_card.dart';
import '../widgets/project_form_dialog.dart';
import '../widgets/enhanced_task_creation_dialog.dart';
import '../widgets/standardized_app_bar.dart';
import '../widgets/standardized_text.dart';
import '../widgets/standardized_colors.dart';
import '../widgets/standardized_spacing.dart';
import '../widgets/glassmorphism_container.dart';
import '../widgets/theme_background_widget.dart';
import '../pages/voice_recording_page.dart';
import '../widgets/manual_task_creation_dialog.dart';
import '../../core/design_system/design_tokens.dart';

/// Detailed view of a single project
///
/// Shows project information, statistics, tasks, and progress tracking.
class ProjectDetailPage extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectDetailPage({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends ConsumerState<ProjectDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projectsAsync = ref.watch(projectsProvider);
    final projectStatsAsync = ref.watch(projectStatsProvider(widget.projectId));

    return projectsAsync.when(
      data: (projects) {
        final project = projects.firstWhere(
          (p) => p.id == widget.projectId,
          orElse: () => throw Exception('Project not found'),
        );

        return ThemeBackgroundWidget(
          child: Scaffold(
            backgroundColor: context.colors.backgroundTransparent,
            extendBodyBehindAppBar: true,
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showTaskCreationMenu(context, project),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 8,
              child: Icon(PhosphorIcons.plus()),
            ),
            appBar: StandardizedAppBar(
              title: TextUtils.autoCapitalize(project.name),
              actions: [
                IconButton(
                  onPressed: () => _editProject(project),
                  icon: Icon(PhosphorIcons.pencil()),
                  tooltip: 'Edit Project',
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(project, value),
                  itemBuilder: (context) => [
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
                      value: 'duplicate',
                      child: Row(
                        children: [
                          Icon(PhosphorIcons.copy()),
                          const SizedBox(width: 8),
                          const Text('Duplicate'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(PhosphorIcons.trash(), color: Theme.of(context).colorScheme.error),
                          const SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.only(top: kToolbarHeight + 8),
              child: Column(
                children: [
                  // Project header with stats
                  _buildProjectHeader(project, projectStatsAsync),

                  // Sophisticated tab bar with elegant styling (matches home screen)
                  Container(
                    height: 56, // Increased for touch accessibility
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true, // Make tabs scrollable to prevent cutoff
                      tabAlignment: TabAlignment.start, // Align tabs to start
                      // Sophisticated gradient indicator for premium feel
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.1),
                            theme.colorScheme.primary.withValues(alpha: 0.05),
                          ],
                        ),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                          width: 0.5, // Ultra-thin for sophistication
                        ),
                      ),

                      // Sophisticated typography and colors
                      labelColor: theme.colorScheme.primary,
                      unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                      dividerColor: Colors.transparent,
                      indicatorSize: TabBarIndicatorSize.tab,

                      // Elegant text styling
                      labelStyle: StandardizedTextStyle.titleMedium.toTextStyle(context).copyWith(
                        fontWeight: TypographyConstants.regular, // Regular weight for sophistication
                        letterSpacing: 0.1, // Subtle letter spacing
                      ),
                      unselectedLabelStyle: StandardizedTextStyle.titleMedium.toTextStyle(context).copyWith(
                        fontWeight: TypographyConstants.light, // Light weight for unselected
                        letterSpacing: 0.1,
                      ),

                      tabs: const [
                        // Text-only tabs for sophisticated elegance
                        Tab(text: 'Tasks'),
                        Tab(text: 'Kanban'),
                        Tab(text: 'Progress'),
                        Tab(text: 'Overview'),
                      ],
                    ),
                  ),

                  // Tab content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildTasksTab(project),
                        _buildKanbanTab(project),
                        _buildProgressTab(project),
                        _buildOverviewTab(project),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: const StandardizedAppBar(title: 'Error'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIcons.warningCircle(),
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              StandardizedTextVariants.pageHeader('Error loading project'),
              const SizedBox(height: 8),
              Text(error.toString()),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(projectsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectHeader(Project project, AsyncValue<ProjectStats> statsAsync) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _parseColor(project.color).withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project name and description
          Row(
            children: [
              Container(
                width: 4,
                height: 32,
                decoration: BoxDecoration(
                  color: _parseColor(project.color),
                  borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StandardizedTextVariants.pageHeader(TextUtils.autoCapitalize(project.name)),
                    if (project.description != null && project.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: StandardizedText(
                          project.description!,
                          style: StandardizedTextStyle.bodyMedium,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              if (project.isArchived)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        PhosphorIcons.archive(),
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      StandardizedText(
                        'Archived',
                        style: StandardizedTextStyle.bodySmall,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Project statistics
          statsAsync.when(
            data: (stats) => _buildStatsRow(stats),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text(
              'Error loading stats: $error',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),

          // Deadline info
          if (project.deadline != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  PhosphorIcons.clock(),
                  size: 16,
                  color: project.isOverdue ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                StandardizedText(
                  'Deadline: ${_formatDate(project.deadline!)}',
                  style: StandardizedTextStyle.bodyMedium,
                  color: project.isOverdue ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant,
                ),
                if (project.isOverdue) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                    ),
                    child: StandardizedText(
                      'OVERDUE',
                      style: StandardizedTextStyle.labelSmall,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsRow(ProjectStats stats) {
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
                  _parseColor(
                      ref.read(projectsProvider).value?.firstWhere((p) => p.id == widget.projectId).color ?? '#2196F3'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            StandardizedText(
              '${(stats.completionPercentage * 100).round()}%',
              style: StandardizedTextStyle.titleMedium,
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Scrollable stats cards - wider and always visible
        SizedBox(
          height: 110, // Increased height to match card height + margin
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              children: [
                _buildScrollableStatCard(
                  'Total',
                  stats.totalTasks.toString(),
                  PhosphorIcons.checkSquare(),
                  theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                _buildScrollableStatCard(
                  'Completed',
                  stats.completedTasks.toString(),
                  PhosphorIcons.checkCircle(),
                  Colors.green,
                ),
                const SizedBox(width: 12),
                _buildScrollableStatCard(
                  'In Progress',
                  stats.inProgressTasks.toString(),
                  PhosphorIcons.playCircle(),
                  Colors.blue,
                ),
                const SizedBox(width: 12),
                _buildScrollableStatCard(
                  'Pending',
                  stats.pendingTasks.toString(),
                  PhosphorIcons.clock(),
                  Colors.orange,
                ),
                const SizedBox(width: 12),
                // Always show overdue card for consistency
                _buildScrollableStatCard(
                  'Overdue',
                  stats.overdueTasks.toString(),
                  PhosphorIcons.warning(),
                  stats.overdueTasks > 0 ? Colors.red : Colors.grey.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }



  Widget _buildScrollableStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      width: 110, // Increased width for better text space
      height: 100, // Increased height to ensure text is visible
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12), // Optimized padding
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusMedium),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Changed to spaceBetween for better distribution
        mainAxisSize: MainAxisSize.max, // Ensure column takes full height
        children: [
          // Icon at top
          Icon(icon, color: color, size: 20), // Slightly smaller icon for more space
          
          // Value in middle
          Flexible(
            child: StandardizedText(
              value,
              style: StandardizedTextStyle.titleLarge, // Changed from headlineSmall to titleLarge
              color: color,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Label at bottom
          StandardizedText(
            label,
            style: StandardizedTextStyle.labelSmall, // Changed from labelMedium to labelSmall
            color: color,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTasksTab(Project project) {
    final tasksAsync = ref.watch(tasksProvider);

    return tasksAsync.when(
      data: (allTasks) {
        final projectTasks = allTasks.where((task) => task.projectId == project.id).toList();

        if (projectTasks.isEmpty) {
          return _buildEmptyTasksState();
        }

        // Group tasks by status
        final pendingTasks = projectTasks.where((t) => t.status.isPending).toList();
        final inProgressTasks = projectTasks.where((t) => t.status.isInProgress).toList();
        final completedTasks = projectTasks.where((t) => t.status.isCompleted).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (pendingTasks.isNotEmpty) ...[
              _buildTaskSection('Pending Tasks', pendingTasks, PhosphorIcons.clock(), Colors.orange),
              const SizedBox(height: 16),
            ],
            if (inProgressTasks.isNotEmpty) ...[
              _buildTaskSection('In Progress', inProgressTasks, PhosphorIcons.playCircle(), Colors.blue),
              const SizedBox(height: 16),
            ],
            if (completedTasks.isNotEmpty) ...[
              _buildTaskSection('Completed Tasks', completedTasks, PhosphorIcons.checkCircle(), Colors.green),
              const SizedBox(height: 80), // Account for FAB
            ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Error loading tasks: $error'),
      ),
    );
  }

  Widget _buildTaskSection(String title, List<TaskModel> tasks, IconData icon, Color color) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            StandardizedText(
              '$title (${tasks.length})',
              style: StandardizedTextStyle.titleSmall,
              color: color,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (tasks.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.5),
              ),
            ),
            child: StandardizedText(
              'No tasks in this category',
              style: StandardizedTextStyle.bodyMedium,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          )
        else
          ...tasks.map((task) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AdvancedTaskCard(
                  task: task,
                  onTap: () => _viewTask(task),
                ),
              )),
      ],
    );
  }

  Widget _buildKanbanTab(Project project) {
    final tasksAsync = ref.watch(tasksProvider);

    return tasksAsync.when(
      data: (allTasks) {
        final projectTasks = allTasks.where((task) => task.projectId == project.id).toList();

        if (projectTasks.isEmpty) {
          return _buildEmptyTasksState();
        }

        // Group tasks by status for Kanban columns
        final todoTasks = projectTasks.where((t) => t.status.isPending).toList();
        final inProgressTasks = projectTasks.where((t) => t.status.isInProgress).toList();
        final completedTasks = projectTasks.where((t) => t.status.isCompleted).toList();

        return Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 300, // Constrain height
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // To Do Column
                Expanded(
                  child: _buildKanbanColumn('To Do', todoTasks, Colors.orange),
                ),
                const SizedBox(width: 12),
                // In Progress Column
                Expanded(
                  child: _buildKanbanColumn('In Progress', inProgressTasks, Colors.blue),
                ),
                const SizedBox(width: 12),
                // Done Column
                Expanded(
                  child: _buildKanbanColumn('Done', completedTasks, Colors.green),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Error loading Kanban board: $error'),
      ),
    );
  }

  Widget _buildKanbanColumn(String title, List<TaskModel> tasks, Color color) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard), // 8.0 - Fixed border radius hierarchy
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 16,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusXSmall), // 2.0 - Fixed border radius hierarchy
                  ),
                ),
                const SizedBox(width: 8),
                StandardizedText(
                  '$title (${tasks.length})',
                  style: StandardizedTextStyle.labelLarge,
                  color: color,
                ),
              ],
            ),
          ),
          // Tasks
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StandardizedText(
                            task.title,
                            style: StandardizedTextStyle.bodySmall,
                          ),
                          if (task.description != null && task.description!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              task.description!,
                              style: StandardizedTextStyle.labelSmall.toTextStyle(context),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (task.dueDate != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  PhosphorIcons.clock(),
                                  size: 12,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                StandardizedText(
                                  _formatDate(task.dueDate!),
                                  style: StandardizedTextStyle.labelSmall,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTab(Project project) {
    // This would show charts and progress tracking
    // For now, we'll show a placeholder
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(PhosphorIcons.trendUp(), size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          StandardizedText(
            'Progress Charts',
            style: StandardizedTextStyle.headlineSmall,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            'Coming soon - detailed progress tracking and analytics',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(Project project) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Project details
        Card(
          color: theme.colorScheme.surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StandardizedTextVariants.sectionHeader('Project Details'),
                const SizedBox(height: 12),
                _buildDetailRow('Created', _formatDate(project.createdAt)),
                if (project.updatedAt != null) _buildDetailRow('Last Updated', _formatDate(project.updatedAt!)),
                if (project.deadline != null) _buildDetailRow('Deadline', _formatDate(project.deadline!)),
                _buildDetailRow('Status', project.isArchived ? 'Archived' : 'Active'),
                _buildDetailRow('Color', project.color),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Quick actions
        Card(
          color: theme.colorScheme.surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StandardizedTextVariants.sectionHeader('Quick Actions'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _editProject(project),
                      icon: Icon(PhosphorIcons.pencil()),
                      label: const Text('Edit Project'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _duplicateProject(project),
                      icon: Icon(PhosphorIcons.copy()),
                      label: const Text('Duplicate'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: StandardizedText(
              label,
              style: StandardizedTextStyle.bodyMedium,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: StandardizedTextStyle.bodyMedium.toTextStyle(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTasksState() {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.checkSquare(),
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            StandardizedText(
              'No Tasks Yet',
              style: StandardizedTextStyle.headlineSmall,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            StandardizedText(
              'Add your first task to this project to get started',
              style: StandardizedTextStyle.bodyMedium,
              color: theme.colorScheme.onSurfaceVariant,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(Project project, String action) {
    switch (action) {
      case 'archive':
        ref.read(projectsProvider.notifier).archiveProject(project.id);
        break;
      case 'unarchive':
        ref.read(projectsProvider.notifier).unarchiveProject(project.id);
        break;
      case 'duplicate':
        _duplicateProject(project);
        break;
      case 'delete':
        _deleteProject(project);
        break;
    }
  }

  void _editProject(Project project) {
    showDialog(
      context: context,
      builder: (context) => ProjectFormDialog(
        project: project,
        onSuccess: () => ref.invalidate(projectsProvider),
      ),
    );
  }

  void _duplicateProject(Project project) {
    // This would call the project service to duplicate the project
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Project duplication coming soon'),
      ),
    );
  }

  void _deleteProject(Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text(
          'Are you sure you want to delete "${project.name}"? This will remove the project from all associated tasks but will not delete the tasks themselves.',
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
              Navigator.of(context).pop(); // Go back to projects list
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

  void _createTaskForProject(Project project) {
    showDialog(
      context: context,
      builder: (context) => EnhancedTaskCreationDialog(
        prePopulatedData: {
          'projectId': project.id,
        },
        onTaskCreated: (task) {
          // Refresh the tasks for this project
          ref.invalidate(tasksForProjectProvider(project.id));
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Task "${task.title}" created for ${project.name}'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        },
      ),
    );
  }

  void _viewTask(TaskModel task) {
    Navigator.of(context).pushNamed('/task-detail', arguments: task.id);
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Show task creation options menu (same as home screen)
  void _showTaskCreationMenu(BuildContext context, Project project) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.backgroundTransparent,
      isScrollControlled: true,
      builder: (context) => GlassmorphismContainer(
        level: GlassLevel.floating,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        margin: EdgeInsets.zero,
        child: SafeArea(
          child: Padding(
            padding: StandardizedSpacing.padding(SpacingSize.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                StandardizedText(
                  'Add Task to ${project.name}',
                  style: StandardizedTextStyle.headlineSmall,
                ),
                StandardizedGaps.vertical(SpacingSize.sm),
                StandardizedText(
                  'Choose how you\'d like to create your task',
                  style: StandardizedTextStyle.bodyMedium,
                  color: context.colors.withSemanticOpacity(
                    Theme.of(context).colorScheme.onSurface,
                    SemanticOpacity.strong,
                  ),
                ),
                StandardizedGaps.lg,

                // Task Creation Options
                _buildTaskCreationOption(
                  context: context,
                  icon: PhosphorIcons.microphone(),
                  iconColor: theme.colorScheme.primary,
                  title: 'AI Voice Entry',
                  subtitle: 'Speak your task, we\'ll transcribe it',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VoiceRecordingPage(),
                      ),
                    );
                  },
                ),

                StandardizedGaps.md,

                _buildTaskCreationOption(
                  context: context,
                  icon: PhosphorIcons.pencil(),
                  iconColor: context.colors.success,
                  title: 'Manual Entry',
                  subtitle: 'Type your task details manually',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManualTaskCreationDialog(),
                      ),
                    );
                  },
                ),

                StandardizedGaps.md,

                _buildTaskCreationOption(
                  context: context,
                  icon: PhosphorIcons.sparkle(),
                  iconColor: theme.colorScheme.tertiary,
                  title: 'Quick Add',
                  subtitle: 'Add a simple task quickly',
                  onTap: () {
                    Navigator.pop(context);
                    _createTaskForProject(project);
                  },
                ),

                StandardizedGaps.md,
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build task creation option tile
  Widget _buildTaskCreationOption({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      child: GlassmorphismContainer(
        level: GlassLevel.interactive,
        padding: StandardizedSpacing.padding(SpacingSize.md),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
        child: Row(
          children: [
            GlassmorphismContainer(
              level: GlassLevel.interactive,
              width: 48,
              height: 48,
              borderRadius: BorderRadius.circular(TypographyConstants.radiusMedium),
              glassTint: iconColor.withValues(alpha: 0.15),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            StandardizedGaps.md,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StandardizedText(
                    title,
                    style: StandardizedTextStyle.titleMedium,
                  ),
                  StandardizedGaps.vertical(SpacingSize.xs),
                  StandardizedText(
                    subtitle,
                    style: StandardizedTextStyle.bodySmall,
                    color: context.colors.withSemanticOpacity(
                      theme.colorScheme.onSurface,
                      SemanticOpacity.strong,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              PhosphorIcons.caretRight(),
              size: 16,
              color: context.colors.withSemanticOpacity(
                Theme.of(context).colorScheme.onSurface,
                SemanticOpacity.strong,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
