
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/design_system/design_tokens.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/typography_constants.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../providers/task_provider.dart';
import '../providers/task_providers.dart';
import '../widgets/advanced_task_card.dart';
import '../widgets/custom_dialogs.dart';
import '../widgets/glassmorphism_container.dart';
import '../widgets/loading_error_widgets.dart' as loading_widgets;
import '../widgets/manual_task_creation_dialog.dart';
import '../widgets/simple_theme_toggle.dart';
import '../widgets/standardized_app_bar.dart';
import '../widgets/standardized_fab.dart';
import '../widgets/standardized_text.dart';
import '../widgets/task_form_dialog.dart';
import '../widgets/theme_background_widget.dart';
import '../widgets/standardized_colors.dart';
import '../widgets/standardized_spacing.dart';
import 'voice_recording_page.dart';

class TasksPage extends ConsumerWidget {
  const TasksPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ThemeBackgroundWidget(
      child: Scaffold(
        backgroundColor: context.colors.backgroundTransparent,
        extendBodyBehindAppBar: true,
        appBar: StandardizedAppBar(
          title: 'Tasks',
          forceBackButton: false, // Tasks is main tab - no back button
          actions: [
            const ThemeToggleButton(),
            IconButton(
              icon: Icon(PhosphorIcons.funnel()),
              onPressed: () => _showFilterDialog(context, ref),
              tooltip: 'Filter tasks',
            ),
          ],
        ),
        body: const SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              top: kToolbarHeight + SpacingTokens.sm,
              left: SpacingTokens.md,
              right: SpacingTokens.md,
              bottom: SpacingTokens.md,
            ),
            child: TasksPageBody(),
          ),
        ),
        floatingActionButton: StandardizedFABVariants.create(
          onPressed: () => _showTaskCreationMenu(context),
          heroTag: 'tasksFAB',
          isLarge: true,
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _FilterDialog(),
    );
  }


  /// Show task creation options menu
  void _showTaskCreationMenu(BuildContext context) {
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
                const StandardizedText(
                  'Create New Task',
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
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge), // 16.0 - Fixed border radius hierarchy
      child: GlassmorphismContainer(
        level: GlassLevel.interactive,
        padding: StandardizedSpacing.padding(SpacingSize.md),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge), // 16.0 - Fixed border radius hierarchy
        child: Row(
          children: [
            GlassmorphismContainer(
              level: GlassLevel.interactive,
              width: 48,
              height: 48,
              borderRadius: BorderRadius.circular(TypographyConstants.radiusMedium), // 12.0 - Fixed border radius hierarchy
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
                      Theme.of(context).colorScheme.onSurface,
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

class TasksPageBody extends ConsumerWidget {
  const TasksPageBody({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(searchQueryProvider);
    final filter = ref.watch(taskFilterProvider);

    return SingleChildScrollView(
      padding: StandardizedSpacing.padding(SpacingSize.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SearchBar(),
          StandardizedGaps.vertical(SpacingSize.md),
          _SmartFilters(),
          StandardizedGaps.vertical(SpacingSize.md),
          if (filter.hasFilters || searchQuery.isNotEmpty) ...[
            _ActiveFiltersIndicator(
              filter: filter,
              searchQuery: searchQuery,
              onClearFilters: () => _clearFilters(ref),
            ),
            StandardizedGaps.vertical(SpacingSize.md),
          ],
          _TaskList(),
        ],
      ),
    );
  }

  void _clearFilters(WidgetRef ref) {
    ref.read(taskFilterProvider.notifier).state = const TaskFilter();
    ref.read(searchQueryProvider.notifier).state = '';
  }
}

class _SearchBar extends ConsumerStatefulWidget {
  @override
  ConsumerState<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<_SearchBar> {
  final _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(searchQueryProvider);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    ref.read(searchQueryProvider.notifier).state = _searchController.text.trim();
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(searchQueryProvider);

    return GlassmorphismContainer(
      level: GlassLevel.interactive,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search tasks by title, description, or tags...',
          prefixIcon: Icon(PhosphorIcons.magnifyingGlass()),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(PhosphorIcons.x()),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(searchQueryProvider.notifier).state = '';
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }
}

class _SmartFilters extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(taskFilterProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StandardizedTextVariants.cardTitle(
          'Quick Filters',
        ),
        StandardizedGaps.vertical(SpacingSize.xs),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _SmartFilterChip(
                label: 'Today',
                isSelected: _isTodayFilterActive(filter),
                onTap: () => _applyTodayFilter(ref),
              ),
              StandardizedGaps.horizontal(SpacingSize.xs),
              _SmartFilterChip(
                label: 'This Week',
                isSelected: _isThisWeekFilterActive(filter),
                onTap: () => _applyThisWeekFilter(ref),
              ),
              StandardizedGaps.horizontal(SpacingSize.xs),
              _SmartFilterChip(
                label: 'Overdue',
                isSelected: filter.isOverdue == true,
                onTap: () => _applyOverdueFilter(ref),
              ),
              StandardizedGaps.horizontal(SpacingSize.xs),
              _SmartFilterChip(
                label: 'High Priority',
                isSelected: filter.priority == TaskPriority.high || filter.priority == TaskPriority.urgent,
                onTap: () => _applyHighPriorityFilter(ref),
              ),
              StandardizedGaps.horizontal(SpacingSize.xs),
              _SmartFilterChip(
                label: 'Completed',
                isSelected: filter.status == TaskStatus.completed,
                onTap: () => _applyCompletedFilter(ref),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _isTodayFilterActive(TaskFilter filter) {
    if (filter.dueDateFrom == null || filter.dueDateTo == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return filter.dueDateFrom!.isAtSameMomentAs(today) && filter.dueDateTo!.isAtSameMomentAs(tomorrow);
  }

  bool _isThisWeekFilterActive(TaskFilter filter) {
    if (filter.dueDateFrom == null || filter.dueDateTo == null) return false;

    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endOfWeekDate = startOfWeekDate.add(const Duration(days: 7));

    return filter.dueDateFrom!.isAtSameMomentAs(startOfWeekDate) && filter.dueDateTo!.isAtSameMomentAs(endOfWeekDate);
  }

  void _applyTodayFilter(WidgetRef ref) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    ref.read(taskFilterProvider.notifier).state = TaskFilter(
      dueDateFrom: today,
      dueDateTo: tomorrow,
    );
  }

  void _applyThisWeekFilter(WidgetRef ref) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endOfWeekDate = startOfWeekDate.add(const Duration(days: 7));

    ref.read(taskFilterProvider.notifier).state = TaskFilter(
      dueDateFrom: startOfWeekDate,
      dueDateTo: endOfWeekDate,
    );
  }

  void _applyOverdueFilter(WidgetRef ref) {
    ref.read(taskFilterProvider.notifier).state = const TaskFilter(
      isOverdue: true,
    );
  }

  void _applyHighPriorityFilter(WidgetRef ref) {
    ref.read(taskFilterProvider.notifier).state = const TaskFilter(
      priority: TaskPriority.high,
    );
  }

  void _applyCompletedFilter(WidgetRef ref) {
    ref.read(taskFilterProvider.notifier).state = const TaskFilter(
      status: TaskStatus.completed,
    );
  }
}

class _SmartFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SmartFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GlassmorphismContainer(
      level: isSelected ? GlassLevel.interactive : GlassLevel.content,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusXLarge), // 20.0 - Fixed border radius hierarchy
      glassTint: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TypographyConstants.radiusXLarge), // 20.0 - Fixed border radius hierarchy
          child: Container(
            padding: StandardizedSpacing.paddingSymmetric(horizontal: SpacingSize.md, vertical: SpacingSize.xs),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              borderRadius: BorderRadius.circular(TypographyConstants.radiusXLarge), // 20.0 - Fixed border radius hierarchy
            ),
            child: StandardizedText(
              label,
              style: StandardizedTextStyle.labelMedium,
              color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveFiltersIndicator extends StatelessWidget {
  final TaskFilter filter;
  final String searchQuery;
  final VoidCallback onClearFilters;

  const _ActiveFiltersIndicator({
    required this.filter,
    required this.searchQuery,
    required this.onClearFilters,
  });
  @override
  Widget build(BuildContext context) {
    final activeFilters = <String>[];

    if (searchQuery.isNotEmpty) {
      activeFilters.add('Search: "$searchQuery"');
    }

    if (filter.status != null) {
      activeFilters.add('Status: ${filter.status!.displayName}');
    }

    if (filter.priority != null) {
      activeFilters.add('Priority: ${filter.priority!.displayName}');
    }

    return GlassmorphismContainer(
      level: GlassLevel.content,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: StandardizedSpacing.padding(SpacingSize.sm),
      child: Row(
        children: [
          Icon(
            PhosphorIcons.funnel(),
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StandardizedText(
              'Active filters: ${activeFilters.join(', ')}',
              style: StandardizedTextStyle.bodySmall,
            ),
          ),
          GlassmorphismContainer(
            level: GlassLevel.interactive,
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard), // 8.0 - Fixed border radius hierarchy
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onClearFilters,
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard), // 8.0 - Fixed border radius hierarchy
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: StandardizedText(
                    'Clear',
                    style: StandardizedTextStyle.labelMedium,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(searchQueryProvider);
    final filter = ref.watch(taskFilterProvider);

    if (searchQuery.isNotEmpty) {
      return ref.watch(searchedTasksProvider).when(
            data: (tasks) => _buildTaskList(context, ref, tasks),
            loading: () => const loading_widgets.LoadingWidget(),
            error: (error, stack) => loading_widgets.ErrorWidget(
              message: 'Failed to search tasks',
              details: error.toString(),
              onRetry: () => ref.refresh(searchedTasksProvider),
            ),
          );
    } else if (filter.hasFilters) {
      return ref.watch(filteredTasksProvider).when(
            data: (tasks) => _buildTaskList(context, ref, tasks),
            loading: () => const loading_widgets.LoadingWidget(),
            error: (error, stack) => loading_widgets.ErrorWidget(
              message: 'Failed to filter tasks',
              details: error.toString(),
              onRetry: () => ref.refresh(filteredTasksProvider),
            ),
          );
    } else {
      return ref.watch(tasksProvider).when(
            data: (tasks) => _buildTaskList(context, ref, tasks),
            loading: () => const loading_widgets.LoadingWidget(),
            error: (error, stack) => loading_widgets.ErrorWidget(
              message: 'Failed to load tasks',
              details: error.toString(),
              onRetry: () => ref.refresh(tasksProvider),
            ),
          );
    }
  }

  Widget _buildTaskList(BuildContext context, WidgetRef ref, List<TaskModel> tasks) {
    if (tasks.isEmpty) {
      return const _EmptyTaskList();
    }

    return Column(
      children: tasks
          .map((task) => AdvancedTaskCard(
                task: task,
                onTap: () => _navigateToTaskDetail(context, task.id),
                onEdit: () => _editTask(context, task),
                onDelete: () => _deleteTask(context, ref, task),
                showProgress: true,
                showSubtasks: task.subTasks.isNotEmpty,
                style: TaskCardStyle.elevated,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              ))
          .toList(),
    );
  }

  void _navigateToTaskDetail(BuildContext context, String taskId) {
    Navigator.of(context).pushNamed(
      AppRouter.taskDetail,
      arguments: taskId,
    );
  }

  void _editTask(BuildContext context, TaskModel task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TaskFormDialog(task: task),
        fullscreenDialog: true,
      ),
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
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Task deleted successfully')),
            );
          }
        },
      ),
    );
  }
}

class _EmptyTaskList extends StatelessWidget {
  const _EmptyTaskList();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.checkSquare(),
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          StandardizedGaps.vertical(SpacingSize.md),
          const StandardizedText(
            'No tasks found',
            style: StandardizedTextStyle.titleLarge,
          ),
          StandardizedGaps.vertical(SpacingSize.xs),
          StandardizedText(
            'Create your first task to get started!',
            style: StandardizedTextStyle.bodyMedium,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FilterDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends ConsumerState<_FilterDialog> {
  late TaskFilter _currentFilter;
  @override
  void initState() {
    super.initState();
    _currentFilter = ref.read(taskFilterProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassmorphismContainer(
        level: GlassLevel.floating,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StandardizedTextVariants.sectionHeader(
                'Filter Tasks',
              ),
              const SizedBox(height: 24),
              StandardizedTextVariants.cardTitle(
                'Status',
              ),
              StandardizedGaps.vertical(SpacingSize.xs),
              Wrap(
                spacing: 8,
                children: [
                  _buildFilterChip(
                    context,
                    'All',
                    _currentFilter.status == null,
                    () => setState(() {
                      _currentFilter = _currentFilter.copyWith(status: null);
                    }),
                  ),
                  ...TaskStatus.values.map((status) => _buildFilterChip(
                        context,
                        status.displayName,
                        _currentFilter.status == status,
                        () => setState(() {
                          _currentFilter = _currentFilter.copyWith(status: status);
                        }),
                      )),
                ],
              ),
              StandardizedGaps.vertical(SpacingSize.md),
              StandardizedTextVariants.cardTitle(
                'Priority',
              ),
              StandardizedGaps.vertical(SpacingSize.xs),
              Wrap(
                spacing: 8,
                children: [
                  _buildFilterChip(
                    context,
                    'All',
                    _currentFilter.priority == null,
                    () => setState(() {
                      _currentFilter = _currentFilter.copyWith(priority: null);
                    }),
                  ),
                  ...TaskPriority.values.map((priority) => _buildFilterChip(
                        context,
                        priority.displayName,
                        _currentFilter.priority == priority,
                        () => setState(() {
                          _currentFilter = _currentFilter.copyWith(priority: priority);
                        }),
                      )),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GlassmorphismContainer(
                    level: GlassLevel.interactive,
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard), // 8.0 - Fixed border radius hierarchy
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard), // 8.0 - Fixed border radius hierarchy
                        child: Padding(
                          padding: StandardizedSpacing.paddingSymmetric(horizontal: SpacingSize.md, vertical: SpacingSize.xs),
                          child: StandardizedText(
                            'Cancel',
                            style: StandardizedTextStyle.labelLarge,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                  StandardizedGaps.horizontal(SpacingSize.xs),
                  GlassmorphismContainer(
                    level: GlassLevel.interactive,
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard), // 8.0 - Fixed border radius hierarchy
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _clearFilters,
                        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard), // 8.0 - Fixed border radius hierarchy
                        child: Padding(
                          padding: StandardizedSpacing.paddingSymmetric(horizontal: SpacingSize.md, vertical: SpacingSize.xs),
                          child: StandardizedText(
                            'Clear',
                            style: StandardizedTextStyle.labelLarge,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                  ),
                  StandardizedGaps.horizontal(SpacingSize.xs),
                  GlassmorphismContainer(
                    level: GlassLevel.interactive,
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard), // 8.0 - Fixed border radius hierarchy
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _applyFilters,
                        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard), // 8.0 - Fixed border radius hierarchy
                        child: Container(
                          padding: StandardizedSpacing.paddingSymmetric(horizontal: SpacingSize.md, vertical: SpacingSize.xs),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                                Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard), // 8.0 - Fixed border radius hierarchy
                          ),
                          child: const StandardizedText(
                            'Apply',
                            style: StandardizedTextStyle.labelLarge,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearFilters() {
    ref.read(taskFilterProvider.notifier).state = const TaskFilter();
    Navigator.of(context).pop();
  }

  void _applyFilters() {
    ref.read(taskFilterProvider.notifier).state = _currentFilter;
    Navigator.of(context).pop();
  }

  Widget _buildFilterChip(BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    return GlassmorphismContainer(
      level: isSelected ? GlassLevel.interactive : GlassLevel.content,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusXLarge), // 20.0 - Fixed border radius hierarchy
      glassTint: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TypographyConstants.radiusXLarge), // 20.0 - Fixed border radius hierarchy
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              borderRadius: BorderRadius.circular(TypographyConstants.radiusXLarge), // 20.0 - Fixed border radius hierarchy
            ),
            child: StandardizedText(
              label,
              style: StandardizedTextStyle.labelSmall,
              color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
