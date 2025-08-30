import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/accessibility/accessibility_constants.dart';
import '../../core/design_system/design_tokens.dart';
import '../../core/providers/enhanced_theme_provider.dart';
import '../../core/providers/navigation_provider.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/typography_constants.dart';
import '../../core/utils/category_utils.dart';
import '../../core/utils/text_utils.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/task_audio_extensions.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../../services/project_service.dart';
import '../../services/ui/slidable_action_service.dart';
import '../../services/ui/slidable_feedback_service.dart';
import '../../services/ui/slidable_theme_service.dart';
import '../pages/manual_task_creation_page.dart';
import '../pages/voice_only_creation_page.dart';
import '../pages/voice_recording_page.dart';
import '../providers/project_providers.dart';
import '../providers/tag_providers.dart';
import '../providers/task_provider.dart';
import '../providers/task_providers.dart';
import '../widgets/adaptive_navigation.dart';
import '../widgets/audio_indicator_widget.dart';
import '../widgets/glassmorphism_container.dart';
import '../widgets/project_form_dialog.dart';
import '../widgets/standardized_app_bar.dart';
import '../widgets/standardized_border_radius.dart';
import '../widgets/standardized_card.dart';
import '../widgets/standardized_colors.dart';
import '../widgets/standardized_fab.dart';
import '../widgets/standardized_spacing.dart';
import '../widgets/standardized_text.dart';
import '../widgets/tag_chip.dart';
import '../widgets/theme_background_widget.dart';

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
    final selectedIndex = ref.watch(selectedIndexProvider);

    // Define navigation items (same as MainScaffold)
    final navigationItems = [
      AdaptiveNavigationItem(
        icon: PhosphorIcons.house(),
        selectedIcon: PhosphorIcons.house(),
        label: '',
        tooltip: 'Go to home screen',
      ),
      AdaptiveNavigationItem(
        icon: PhosphorIcons.calendar(),
        selectedIcon: PhosphorIcons.calendar(),
        label: '',
        tooltip: 'Go to calendar view',
      ),
      AdaptiveNavigationItem(
        icon: PhosphorIcons.folder(),
        selectedIcon: PhosphorIcons.folder(),
        label: '',
        tooltip: 'View all projects',
      ),
      AdaptiveNavigationItem(
        icon: PhosphorIcons.gear(),
        selectedIcon: PhosphorIcons.gear(),
        label: '',
        tooltip: 'Go to settings and menu',
      ),
    ];

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
            resizeToAvoidBottomInset: false, // Prevent keyboard from affecting layout
            bottomNavigationBar: _buildBottomNavigation(context, ref, selectedIndex, navigationItems),
            floatingActionButton: StandardizedFABVariants.create(
              onPressed: () => _showTaskCreationMenu(context, project),
              heroTag: 'projectDetailFAB',
              isLarge: true,
            ),
            floatingActionButtonLocation: const CenterDockedFloatingActionButtonLocation(),
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
                child: _buildCompactTaskCard(task, theme),
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                height: constraints.maxHeight - 100, // Better responsive height
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // To Do Column
                      SizedBox(
                        width: constraints.maxWidth * 0.3,
                        child: _buildKanbanColumn('To Do', todoTasks, Colors.orange),
                      ),
                      const SizedBox(width: 8), // Reduce spacing
                      // In Progress Column
                      SizedBox(
                        width: constraints.maxWidth * 0.3,
                        child: _buildKanbanColumn('In Progress', inProgressTasks, Colors.blue),
                      ),
                      const SizedBox(width: 8), // Reduce spacing
                      // Done Column
                      SizedBox(
                        width: constraints.maxWidth * 0.3,
                        child: _buildKanbanColumn('Done', completedTasks, Colors.green),
                      ),
                    ],
                  ),
                ),
              );
            },
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
          // Column header - smaller and supports 2 lines
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 3,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(TypographyConstants.radiusXSmall),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: StandardizedText(
                        title,
                        style: StandardizedTextStyle.labelSmall,
                        color: color,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                StandardizedText(
                  '${tasks.length} task${tasks.length != 1 ? 's' : ''}',
                  style: StandardizedTextStyle.bodySmall,
                  color: theme.colorScheme.onSurfaceVariant,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Tasks with drag and drop
          Flexible(
            child: DragTarget<TaskModel>(
              onWillAcceptWithDetails: (details) => true,
              onAcceptWithDetails: (details) => _moveTaskToColumn(details.data, title),
              builder: (context, candidateData, rejectedData) {
                return Container(
                  decoration: candidateData.isNotEmpty
                      ? BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: color, width: 2),
                        )
                      : null,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Draggable<TaskModel>(
                          data: task,
                          feedback: Material(
                            elevation: 8,
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 200,
                              child: StandardizedCard(
                                style: _getTaskCardStyle(task, false),
                                margin: EdgeInsets.zero,
                                padding: const EdgeInsets.all(8),
                                child: StandardizedText(
                                  task.title,
                                  style: StandardizedTextStyle.bodySmall,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                          childWhenDragging: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: theme.colorScheme.outline.withValues(alpha: 0.5),
                                style: BorderStyle.solid,
                                width: 2,
                              ),
                            ),
                          ),
                          child: StandardizedCard(
                            style: _getTaskCardStyle(task, false),
                            margin: EdgeInsets.zero,
                            padding: const EdgeInsets.all(8),
                            onTap: () => _viewTask(task),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                          StandardizedText(
                            task.title,
                            style: StandardizedTextStyle.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (task.description != null && task.description!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            StandardizedText(
                              task.description!,
                              style: StandardizedTextStyle.labelSmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (task.dueDate != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  PhosphorIcons.clock(),
                                  size: 12,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: StandardizedText(
                                    _formatDate(task.dueDate!),
                                    style: StandardizedTextStyle.labelSmall,
                                    color: theme.colorScheme.onSurfaceVariant,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTab(Project project) {
    final tasksAsync = ref.watch(tasksProvider);
    final projectStatsAsync = ref.watch(projectStatsProvider(project.id));

    return tasksAsync.when(
      data: (allTasks) {
        final projectTasks = allTasks.where((task) => task.projectId == project.id).toList();
        
        return projectStatsAsync.when(
          data: (stats) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overall Progress Section
                  _buildProgressOverview(stats, projectTasks),
                  const SizedBox(height: 24),
                  
                  // Task Status Breakdown
                  _buildTaskStatusBreakdown(projectTasks),
                  const SizedBox(height: 24),
                  
                  // Priority Distribution
                  _buildPriorityDistribution(projectTasks),
                  const SizedBox(height: 24),
                  
                  // Recent Activity
                  _buildRecentActivity(projectTasks),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: StandardizedText(
              'Error loading progress data: $error',
              style: StandardizedTextStyle.bodyMedium,
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: StandardizedText(
          'Error loading tasks: $error',
          style: StandardizedTextStyle.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildOverviewTab(Project project) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Project details
        GlassmorphismContainer(
          level: GlassLevel.content,
          margin: EdgeInsets.zero,
          padding: StandardizedSpacing.padding(SpacingSize.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StandardizedTextVariants.sectionHeader('Project Details'),
              StandardizedGaps.vertical(SpacingSize.xs),
              _buildDetailRow('Created', _formatDate(project.createdAt)),
              if (project.updatedAt != null) _buildDetailRow('Last Updated', _formatDate(project.updatedAt!)),
              if (project.deadline != null) _buildDetailRow('Deadline', _formatDate(project.deadline!)),
              _buildDetailRow('Status', project.isArchived ? 'Archived' : 'Active'),
            ],
          ),
        ),

        StandardizedGaps.vertical(SpacingSize.md),

        // Quick actions
        GlassmorphismContainer(
          level: GlassLevel.content,
          margin: EdgeInsets.zero,
          padding: StandardizedSpacing.padding(SpacingSize.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StandardizedTextVariants.sectionHeader('Quick Actions'),
              StandardizedGaps.vertical(SpacingSize.xs),
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

  /// Show task creation options menu (exact copy from MainScaffold)
  void _showTaskCreationMenu(BuildContext context, Project project) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ThemeBackgroundWidget(
        child: GlassmorphismContainer(
          level: GlassLevel.floating,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          margin: EdgeInsets.zero,
          child: SafeArea(
            child: Padding(
              padding: StandardizedSpacing.padding(SpacingSize.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  StandardizedTextVariants.sectionHeader(
                    'Create New Task',
                  ),
                  StandardizedGaps.vertical(SpacingSize.xs),
                  StandardizedTextVariants.body(
                    'Choose how you\'d like to create your task',
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  StandardizedGaps.vertical(SpacingSize.lg),

                  // Task Creation Options in order: AI, Voice-Only, Manual
                  _buildTaskCreationOption(
                    context: context,
                    icon: PhosphorIcons.microphone(),
                    iconColor: theme.colorScheme.primary,
                    title: 'AI Voice Entry',
                    subtitle: 'Speak your task, we\'ll transcribe it',
                    onTap: () async {
                      Navigator.pop(context);

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VoiceRecordingPage(projectId: project.id),
                        ),
                      );
                      
                      // Invalidate providers to refresh task counts and project stats
                      _invalidateProvidersAfterTaskCreation();
                    },
                  ),

                  StandardizedGaps.vertical(SpacingSize.sm),

                  _buildTaskCreationOption(
                    context: context,
                    icon: PhosphorIcons.waveform(),
                    iconColor: Colors.orange,
                    title: 'Voice-Only',
                    subtitle: 'Record audio notes without transcription',
                    onTap: () async {
                      Navigator.pop(context);

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VoiceOnlyCreationPage(projectId: project.id),
                        ),
                      );
                      
                      // Invalidate providers to refresh task counts and project stats
                      _invalidateProvidersAfterTaskCreation();
                    },
                  ),

                  StandardizedGaps.vertical(SpacingSize.sm),

                  _buildTaskCreationOption(
                    context: context,
                    icon: PhosphorIcons.pencil(),
                    iconColor: Colors.green,
                    title: 'Manual Entry',
                    subtitle: 'Type your task details manually',
                    onTap: () async {
                      Navigator.pop(context);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManualTaskCreationPage(
                            prePopulatedData: <String, dynamic>{
                              'creationMode': 'manual',
                              'projectId': project.id,
                            },
                          ),
                        ),
                      );
                      
                      // Invalidate providers to refresh task counts and project stats
                      _invalidateProvidersAfterTaskCreation();
                    },
                  ),

                  StandardizedGaps.vertical(SpacingSize.md),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build individual task creation option (exact copy from MainScaffold)
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
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge), // 16.0 - Fixed border radius hierarchy
      child: GlassmorphismContainer(
        level: GlassLevel.interactive,
        padding: StandardizedSpacing.padding(SpacingSize.md),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge), // 16.0 - Fixed border radius hierarchy
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius:
                    BorderRadius.circular(TypographyConstants.radiusMedium), // 12.0 - Fixed border radius hierarchy
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            StandardizedGaps.horizontal(SpacingSize.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StandardizedTextVariants.cardTitle(
                    title,
                  ),
                  StandardizedGaps.vertical(SpacingSize.xs),
                  StandardizedText(
                    subtitle,
                    style: StandardizedTextStyle.bodySmall,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
            Icon(
              PhosphorIcons.caretRight(),
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// Navigate to different sections based on bottom nav selection
  void _navigateToIndex(BuildContext context, int index) {
    // Update the navigation provider to set the selected index
    ref.read(navigationProvider.notifier).navigateToIndex(index);

    // Navigate back to the main scaffold (home route) which will show the correct page
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouter.home,
      (route) => false,
    );
  }

  /// Build bottom navigation for mobile with Material 3 design and glassmorphism
  Widget _buildBottomNavigation(
    BuildContext context,
    WidgetRef ref,
    int selectedIndex,
    List<AdaptiveNavigationItem> navigationItems,
  ) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        // Theme-aware glassmorphism background with complementary gradient
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            // Complementary gradient: secondary→primary (opposite of app bar)
            theme.colorScheme.secondary.withValues(alpha: theme.brightness == Brightness.dark ? 0.2 : 0.4),
            theme.colorScheme.primary.withValues(alpha: theme.brightness == Brightness.dark ? 0.25 : 0.45),
          ],
        ),
        // Theme-aware shadow using primary color
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: theme.brightness == Brightness.dark ? 0.15 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
        // Theme-specific border
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.secondary.withValues(alpha: 0.3),
            width: 0.8,
          ),
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
          child: Container(
            // Add theme-aware background tint for better glassmorphism effect
            color: theme.colorScheme.secondaryContainer
                .withValues(alpha: theme.brightness == Brightness.dark ? 0.05 : 0.08),
            child: BottomAppBar(
              height: 80,
              padding: StandardizedSpacing.paddingSymmetric(horizontal: SpacingSize.md),
              notchMargin: 3, // 3px notch around FAB as requested
              shape: const CircularNotchedRectangle(),
              color: Colors.transparent, // Make transparent to show glassmorphism
              elevation: 0, // Remove default elevation
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // First two navigation items
                  for (int i = 0; i < 2; i++)
                    _buildNavItem(
                      context: context,
                      item: navigationItems[i],
                      isSelected: selectedIndex == i,
                      onTap: () => _navigateToIndex(context, i),
                    ),

                  // Enhanced spacer for FAB with proper sizing
                  StandardizedGaps.horizontal(SpacingSize.xxl), // Increased width for better spacing

                  // Last two navigation items
                  for (int i = 2; i < navigationItems.length; i++)
                    _buildNavItem(
                      context: context,
                      item: navigationItems[i],
                      isSelected: selectedIndex == i,
                      onTap: () => _navigateToIndex(context, i),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build navigation item for bottom app bar with accessibility and glassmorphism
  Widget _buildNavItem({
    required BuildContext context,
    required AdaptiveNavigationItem item,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Semantics(
      label: '${item.label} ${AccessibilityConstants.navigationSemanticLabel}',
      hint: item.tooltip,
      button: true,
      selected: isSelected,
      child: SizedBox(
        width: AccessibilityConstants.minTouchTarget,
        height: AccessibilityConstants.minTouchTarget,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TypographyConstants.radiusMedium),
          child: Padding(
            padding: StandardizedSpacing.paddingSymmetric(vertical: SpacingSize.xs, horizontal: SpacingSize.xs),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Enhanced icon with brighter circular border for selection
                Flexible(
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    child: AnimatedScale(
                      scale: isSelected ? 1.15 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.2) : Colors.transparent,
                          shape: BoxShape.circle, // Always circular
                          border: Border.all(
                            color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.8) : Colors.transparent,
                            width: 1.8, // Thinner border as requested
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : [],
                        ),
                        child: Icon(
                          isSelected ? item.selectedIcon : item.icon,
                          size: 22,
                          color: isSelected
                              ? theme.colorScheme.primary // Use primary color for both themes
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Invalidate providers to refresh UI after task creation
  void _invalidateProvidersAfterTaskCreation() {
    // Invalidate project stats to refresh task counts
    ref.invalidate(projectStatsProvider(widget.projectId));
    
    // Invalidate all projects providers to refresh project cards on home screen
    ref.invalidate(projectsProvider);
    ref.invalidate(activeProjectsProvider);
    
    // Invalidate task providers to refresh task lists
    ref.invalidate(tasksProvider);
    ref.invalidate(pendingTasksProvider);
    ref.invalidate(completedTasksProvider);
    ref.invalidate(todayTasksProvider);
    ref.invalidate(tasksCreatedTodayProvider);
  }

  /// Sophisticated task card with golden ratio proportions matching home page design
  Widget _buildCompactTaskCard(TaskModel task, ThemeData theme, {bool isOverdue = false}) {
    final balancedActions = SlidableActionService.getBalancedCompactTaskActions(
      task,
      colorScheme: theme.colorScheme,
      onComplete: () => _toggleTaskCompletion(task),
      onQuickEdit: () => _quickEditTask(task),
      onDelete: () => _confirmDeleteTask(task),
      onMore: () => _showMoreActions(task),
    );

    // Choose card style based on task state for enhanced visual hierarchy
    final cardStyle = _getTaskCardStyle(task, isOverdue);

    final cardContent = SizedBox(
      height: SpacingTokens.taskCardHeight, // Golden ratio optimized height
      child: StandardizedCard(
        style: cardStyle,
        onTap: () => _viewTask(task),
        onLongPress: () => _showTaskContextMenu(context, task),
        margin: EdgeInsets.zero, // No margin - handled by parent
        padding: const EdgeInsets.all(SpacingTokens.taskCardPadding),
        child: Row(
          children: [
            // Sophisticated priority and category indicator
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Priority indicator first - Elegant vertical accent bar
                Container(
                  width: 4,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _getPriorityColor(task.priority, context),
                    borderRadius:
                        BorderRadius.circular(TypographyConstants.radiusXSmall), // 2.0 - Fixed border radius hierarchy
                  ),
                ),
                const SizedBox(width: SpacingTokens.phi1), // Golden ratio spacing
                // Category icon container second
                if (task.tagIds.isNotEmpty) ...[
                  Builder(builder: (context) {
                    return const SizedBox.shrink();
                  }),
                  CategoryUtils.buildCategoryIconContainer(
                    category: task.tagIds.first,
                    size: 32,
                    theme: theme,
                    iconSizeRatio: 0.5,
                    borderRadius: 16, // Half of size (32/2) for circular design
                  ),
                  const SizedBox(width: SpacingTokens.phi1), // Golden ratio spacing
                ] else ...[
                  Builder(builder: (context) {
                    return const SizedBox.shrink();
                  }),
                ],
              ],
            ),

            // Title and tags in the middle (takes up most space)
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title row with audio indicator
                    Row(
                      children: [
                        Expanded(
                          child: StandardizedText(
                            task.title,
                            style: StandardizedTextStyle.labelLarge,
                            color: theme.colorScheme.onSurface,
                            decoration: task.status == TaskStatus.completed ? TextDecoration.lineThrough : null,
                            lineHeight: 1.2,
                            letterSpacing: 0.1,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Sophisticated audio indicator for voice tasks
                        if (task.hasVoiceMetadata) ...[
                          StandardizedGaps.hXs,
                          AudioIndicatorWidget(
                            task: task,
                            size: 20,
                            mode: AudioIndicatorMode.playButton,
                          ),
                        ],
                      ],
                    ),
                    // Tag chips row
                    if (task.tagIds.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Consumer(
                        builder: (context, ref, child) {
                          final tagsProvider = ref.watch(tagsByIdsProvider(task.tagIds));
                          return tagsProvider.when(
                            data: (tags) => TagChipList(
                              tags: tags,
                              chipSize: TagChipSize.small,
                              maxChips: 4, // More tags for horizontal layout
                              spacing: 3.0,
                              onTagTap: (_) {}, // No action on tap for project cards
                            ),
                            loading: () => const SizedBox(
                              height: 16,
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
                            error: (_, __) => const SizedBox.shrink(),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Sophisticated completion indicator on the right
            if (task.status == TaskStatus.completed) ...[
              const SizedBox(width: 16), // 16px spacing
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: context.colors.withSemanticOpacity(context.successColor, SemanticOpacity.subtle),
                  borderRadius: StandardizedBorderRadius.sm,
                  border: Border.all(
                    color: context.colors.withSemanticOpacity(context.successColor, SemanticOpacity.light),
                    width: 0.5,
                  ),
                ),
                child: Icon(
                  PhosphorIcons.check(),
                  size: 12,
                  color: context.successColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: SpacingTokens.taskCardMargin),
      child: SlidableThemeService.createBalancedCompactCardSlidable(
        key: ValueKey('compact-task-${task.id}'),
        groupTag: 'project-compact-cards',
        startActions: balancedActions['startActions'] ?? [],
        endActions: balancedActions['endActions'] ?? [],
        enableFastSwipe: true,
        context: context,
        child: cardContent,
      ),
    );
  }

  // Helper methods for compact card slide actions
  void _toggleTaskCompletion(TaskModel task) async {
    await SlidableFeedbackService.provideFeedback(SlidableActionType.complete);
    try {
      await ref.read(taskOperationsProvider).toggleTaskCompletion(task);
      _invalidateProvidersAfterTaskCreation(); // Refresh UI
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: StandardizedText('Error updating task: $e', style: StandardizedTextStyle.bodyMedium)),
        );
      }
    }
  }

  void _quickEditTask(TaskModel task) {
    SlidableFeedbackService.provideFeedback(SlidableActionType.edit);
    _viewTask(task); // Use existing view task method
  }

  void _showMoreActions(TaskModel task) {
    SlidableFeedbackService.provideFeedback(SlidableActionType.neutral);
    _showTaskContextMenu(context, task);
  }

  void _confirmDeleteTask(TaskModel task) {
    SlidableFeedbackService.provideFeedback(SlidableActionType.destructive);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTask(task);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteTask(TaskModel task) async {
    try {
      await ref.read(taskOperationsProvider).deleteTask(task);
      _invalidateProvidersAfterTaskCreation(); // Refresh UI
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting task: $e')),
        );
      }
    }
  }

  void _showTaskContextMenu(BuildContext context, TaskModel task) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(PhosphorIcons.eye()),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                _viewTask(task);
              },
            ),
            ListTile(
              leading: Icon(task.isCompleted ? PhosphorIcons.arrowClockwise() : PhosphorIcons.checkCircle()),
              title: Text(task.isCompleted ? 'Mark Incomplete' : 'Mark Complete'),
              onTap: () {
                Navigator.pop(context);
                _toggleTaskCompletion(task);
              },
            ),
            ListTile(
              leading: Icon(PhosphorIcons.trash()),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteTask(task);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Get task card style based on state (matching home page exactly)
  StandardizedCardStyle _getTaskCardStyle(TaskModel task, bool isOverdue) {
    if (task.isCompleted) {
      return StandardizedCardStyle.tertiarySuccess; // Completed tasks get success styling
    } else if (isOverdue) {
      return StandardizedCardStyle.tertiaryAccent; // Overdue tasks get attention-grabbing accent
    } else if (task.priority == TaskPriority.urgent) {
      return StandardizedCardStyle.tertiaryAccent; // High priority tasks get accent
    } else {
      return StandardizedCardStyle.tertiaryContainer; // Regular tasks get subtle container
    }
  }

  /// Get theme-aware priority color
  Color _getPriorityColor(TaskPriority priority, BuildContext context) {
    // Get the current theme from enhanced theme provider
    final currentTheme = ref.read(enhancedThemeProvider).currentTheme;
    if (currentTheme == null) {
      return priority.color; // Fallback to enum color
    }

    switch (priority) {
      case TaskPriority.low:
        return currentTheme.colors.taskLowPriority;
      case TaskPriority.medium:
        return currentTheme.colors.taskMediumPriority;
      case TaskPriority.high:
        return currentTheme.colors.taskHighPriority; // Now uses stellar gold!
      case TaskPriority.urgent:
        return currentTheme.colors.taskUrgentPriority;
    }
  }

  /// Move task to different column (change status)
  void _moveTaskToColumn(TaskModel task, String columnTitle) async {
    TaskStatus newStatus;
    switch (columnTitle) {
      case 'To Do':
        newStatus = TaskStatus.pending;
        break;
      case 'In Progress':
        newStatus = TaskStatus.inProgress;
        break;
      case 'Done':
        newStatus = TaskStatus.completed;
        break;
      default:
        return; // Unknown column
    }

    if (task.status == newStatus) return; // No change needed

    final updatedTask = task.copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
    );

    try {
      await ref.read(taskOperationsProvider).updateTask(updatedTask);
      _invalidateProvidersAfterTaskCreation(); // Refresh UI
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task moved to $columnTitle'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error moving task: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }


  // Progress Tab Helper Methods
  Widget _buildProgressOverview(dynamic stats, List<TaskModel> tasks) {
    final theme = Theme.of(context);
    final completionRate = tasks.isEmpty ? 0.0 : (stats.completedTasks / stats.totalTasks);

    return StandardizedCard(
      style: StandardizedCardStyle.elevated,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIcons.chartPie(), size: 24, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              StandardizedText(
                'Project Progress',
                style: StandardizedTextStyle.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StandardizedText(
                    '${stats.completedTasks}/${stats.totalTasks} tasks completed',
                    style: StandardizedTextStyle.bodyMedium,
                  ),
                  StandardizedText(
                    '${(completionRate * 100).round()}%',
                    style: StandardizedTextStyle.labelLarge,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: completionRate,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskStatusBreakdown(List<TaskModel> tasks) {
    final theme = Theme.of(context);
    final pendingCount = tasks.where((t) => t.status.isPending).length;
    final inProgressCount = tasks.where((t) => t.status.isInProgress).length;
    final completedCount = tasks.where((t) => t.status.isCompleted).length;

    return StandardizedCard(
      style: StandardizedCardStyle.filled,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIcons.listChecks(), size: 24, color: theme.colorScheme.secondary),
              const SizedBox(width: 8),
              StandardizedText(
                'Task Status Breakdown',
                style: StandardizedTextStyle.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Status Cards
          Row(
            children: [
              Expanded(child: _buildStatusCard('Pending', pendingCount, Colors.orange, PhosphorIcons.clock())),
              const SizedBox(width: 8),
              Expanded(child: _buildStatusCard('In Progress', inProgressCount, Colors.blue, PhosphorIcons.play())),
              const SizedBox(width: 8),
              Expanded(child: _buildStatusCard('Completed', completedCount, Colors.green, PhosphorIcons.checkCircle())),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String label, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          StandardizedText(
            count.toString(),
            style: StandardizedTextStyle.headlineSmall,
            color: color,
          ),
          const SizedBox(height: 4),
          StandardizedText(
            label,
            style: StandardizedTextStyle.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityDistribution(List<TaskModel> tasks) {
    final theme = Theme.of(context);
    final lowCount = tasks.where((t) => t.priority == TaskPriority.low).length;
    final mediumCount = tasks.where((t) => t.priority == TaskPriority.medium).length;
    final highCount = tasks.where((t) => t.priority == TaskPriority.high).length;
    final urgentCount = tasks.where((t) => t.priority == TaskPriority.urgent).length;

    return StandardizedCard(
      style: StandardizedCardStyle.tertiaryContainer,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIcons.gauge(), size: 24, color: theme.colorScheme.tertiary),
              const SizedBox(width: 8),
              StandardizedText(
                'Priority Distribution',
                style: StandardizedTextStyle.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Column(
            children: [
              _buildPriorityBar('Low', lowCount, Colors.green, tasks.length),
              const SizedBox(height: 8),
              _buildPriorityBar('Medium', mediumCount, Colors.orange, tasks.length),
              const SizedBox(height: 8),
              _buildPriorityBar('High', highCount, Colors.red, tasks.length),
              const SizedBox(height: 8),
              _buildPriorityBar('Urgent', urgentCount, Colors.purple, tasks.length),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBar(String label, int count, Color color, int total) {
    final percentage = total > 0 ? (count / total) : 0.0;
    
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: StandardizedText(
            label,
            style: StandardizedTextStyle.bodySmall,
          ),
        ),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: color,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 30,
          child: StandardizedText(
            count.toString(),
            style: StandardizedTextStyle.bodySmall,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(List<TaskModel> tasks) {
    final theme = Theme.of(context);
    final recentTasks = tasks
        .where((t) => t.updatedAt != null && t.updatedAt!.isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .toList()
      ..sort((a, b) => b.updatedAt!.compareTo(a.updatedAt!));
    
    final recentTasksToShow = recentTasks.take(5).toList();

    return StandardizedCard(
      style: StandardizedCardStyle.outlined,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIcons.clockCounterClockwise(), size: 24, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              StandardizedText(
                'Recent Activity',
                style: StandardizedTextStyle.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (recentTasksToShow.isEmpty)
            StandardizedText(
              'No recent activity in the past 7 days',
              style: StandardizedTextStyle.bodyMedium,
              color: theme.colorScheme.onSurfaceVariant,
            )
          else
            Column(
              children: recentTasksToShow.map((task) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getStatusColor(task.status),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StandardizedText(
                            task.title,
                            style: StandardizedTextStyle.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          StandardizedText(
                            _formatRelativeDate(task.updatedAt ?? task.createdAt),
                            style: StandardizedTextStyle.bodySmall,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Colors.orange;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.cancelled:
        return Colors.red;
    }
  }

  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}

/// Custom FloatingActionButtonLocation that centers the FAB vertically within the bottom toolbar
class CenterDockedFloatingActionButtonLocation extends FloatingActionButtonLocation {
  const CenterDockedFloatingActionButtonLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    // Get the FAB size (72x72 as defined in _buildFloatingActionButton)
    const fabSize = 72.0;

    // Get the bottom navigation bar height (80px as defined in _buildBottomNavigation)
    const bottomNavHeight = 80.0;

    // Calculate horizontal center
    final double fabX = (scaffoldGeometry.scaffoldSize.width - fabSize) / 2.0;

    // Calculate vertical center within the bottom navigation bar
    // Position FAB so its center aligns with the center of the 80px toolbar
    // Fixed position - ignore system insets to prevent FAB movement
    final double fabY = scaffoldGeometry.scaffoldSize.height - bottomNavHeight + (bottomNavHeight - fabSize) / 2.0;

    return Offset(fabX, fabY);
  }

  @override
  String toString() => 'CenterDockedFloatingActionButtonLocation';
}
