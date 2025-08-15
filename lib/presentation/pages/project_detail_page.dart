import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/standardized_app_bar.dart';
import '../widgets/theme_background_widget.dart';

import '../../domain/entities/project.dart';
import '../../domain/entities/task_model.dart';
import '../../services/project_service.dart';
import '../providers/project_providers.dart';
import '../providers/task_providers.dart';
import '../widgets/advanced_task_card.dart';
import '../widgets/project_form_dialog.dart';
import '../../core/theme/typography_constants.dart';

/// Detailed view of a single project
/// 
/// Shows project information, statistics, tasks, and progress tracking.
class ProjectDetailPage extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectDetailPage({
    super.key,
    required this.projectId,
  });  @override
  ConsumerState<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends ConsumerState<ProjectDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }  @override
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
            backgroundColor: Colors.transparent,
            extendBodyBehindAppBar: true,
            appBar: StandardizedAppBar(
              title: project.name,
              actions: [
                IconButton(
                  onPressed: () => _editProject(project),
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit Project',
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(project, value),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: project.isArchived ? 'unarchive' : 'archive',
                      child: Row(
                        children: [
                          Icon(project.isArchived ? Icons.unarchive : Icons.archive),
                          const SizedBox(width: 8),
                          Text(project.isArchived ? 'Unarchive' : 'Archive'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'duplicate',
                      child: Row(
                        children: [
                          Icon(Icons.copy),
                          SizedBox(width: 8),
                          Text('Duplicate'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
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
              
              // Tabs
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Tasks', icon: Icon(Icons.task_alt)),
                  Tab(text: 'Progress', icon: Icon(Icons.trending_up)),
                  Tab(text: 'Overview', icon: Icon(Icons.info)),
                ],
              ),
              
              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTasksTab(project),
                    _buildProgressTab(project),
                    _buildOverviewTab(project),
                  ],
                ),
              ),
            ],
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
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading project',
                style: theme.textTheme.headlineSmall,
              ),
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
        color: _parseColor(project.color).withOpacity( 0.1),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity( 0.1),
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
                    Text(
                      project.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (project.description != null && project.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          project.description!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
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
                        Icons.archive,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Archived',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: TypographyConstants.bodySmall,
                        ),
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
          if (project.hasDeadline) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: project.isOverdue 
                      ? theme.colorScheme.error 
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Deadline: ${_formatDate(project.deadline!)}',
                  style: TextStyle(
                    color: project.isOverdue 
                        ? theme.colorScheme.error 
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: project.isOverdue ? FontWeight.w600 : null,
                  ),
                ),
                if (project.isOverdue) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withOpacity( 0.1),
                      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                    ),
                    child: Text(
                      'OVERDUE',
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontSize: TypographyConstants.labelSmall,
                        fontWeight: FontWeight.w600,
                      ),
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
                  _parseColor(ref.read(projectsProvider).value
                      ?.firstWhere((p) => p.id == widget.projectId)
                      .color ?? '#2196F3'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${(stats.completionPercentage * 100).round()}%',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Stats grid
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total',
                stats.totalTasks.toString(),
                Icons.task_alt,
                theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Completed',
                stats.completedTasks.toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'In Progress',
                stats.inProgressTasks.toString(),
                Icons.play_circle,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Pending',
                stats.pendingTasks.toString(),
                Icons.pending,
                Colors.orange,
              ),
            ),
            if (stats.overdueTasks > 0) ...[
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Overdue',
                  stats.overdueTasks.toString(),
                  Icons.warning,
                  Colors.red,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity( 0.1),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        border: Border.all(color: color.withOpacity( 0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: TypographyConstants.bodyLarge,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: TypographyConstants.labelSmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksTab(Project project) {
    final tasksAsync = ref.watch(tasksProvider);
    
    return tasksAsync.when(
      data: (allTasks) {
        final projectTasks = allTasks
            .where((task) => task.projectId == project.id)
            .toList();

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
              _buildTaskSection('Pending Tasks', pendingTasks, Icons.pending, Colors.orange),
              const SizedBox(height: 16),
            ],
            if (inProgressTasks.isNotEmpty) ...[
              _buildTaskSection('In Progress', inProgressTasks, Icons.play_circle, Colors.blue),
              const SizedBox(height: 16),
            ],
            if (completedTasks.isNotEmpty) ...[
              _buildTaskSection('Completed Tasks', completedTasks, Icons.check_circle, Colors.green),
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
            Text(
              '$title (${tasks.length})',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
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

  Widget _buildProgressTab(Project project) {
    // This would show charts and progress tracking
    // For now, we'll show a placeholder
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.trending_up, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Progress Charts',
            style: TextStyle(fontSize: TypographyConstants.headlineSmall, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Coming soon - detailed progress tracking and analytics',
            style: TextStyle(color: Colors.grey),
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Project Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDetailRow('Created', _formatDate(project.createdAt)),
                if (project.updatedAt != null)
                  _buildDetailRow('Last Updated', _formatDate(project.updatedAt!)),
                if (project.hasDeadline)
                  _buildDetailRow('Deadline', _formatDate(project.deadline!)),
                _buildDetailRow('Status', project.isArchived ? 'Archived' : 'Active'),
                _buildDetailRow('Color', project.color),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Quick actions
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Actions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _createTaskForProject(project),
                      icon: const Icon(Icons.add_task),
                      label: const Text('Add Task'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _editProject(project),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Project'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _duplicateProject(project),
                      icon: const Icon(Icons.copy),
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
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
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
              Icons.task_alt,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No Tasks Yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first task to this project to get started',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _createTaskForProject(
                ref.read(projectsProvider).value!
                    .firstWhere((p) => p.id == widget.projectId),
              ),
              icon: const Icon(Icons.add_task),
              label: const Text('Add Task'),
            ),
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
    // This would open the task creation dialog with the project pre-selected
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task creation with project assignment coming soon'),
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
}
