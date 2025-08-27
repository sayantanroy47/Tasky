
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
import '../providers/tag_providers.dart';
import '../widgets/custom_dialogs.dart';
import '../widgets/glassmorphism_container.dart';
import '../widgets/loading_error_widgets.dart' as loading_widgets;

import '../widgets/simple_theme_toggle.dart';
import '../widgets/standardized_app_bar.dart';
import '../widgets/standardized_text.dart';
import '../widgets/standardized_card.dart';
import '../widgets/audio_indicator_widget.dart';
import '../widgets/tag_chip.dart';
import '../widgets/task_form_dialog.dart';
import '../widgets/theme_background_widget.dart';
import '../widgets/standardized_colors.dart';
import '../widgets/standardized_spacing.dart';
import '../widgets/standardized_border_radius.dart';
import '../../core/utils/category_utils.dart';

import 'package:flutter_slidable/flutter_slidable.dart';


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
              left: SpacingTokens.xs,
              right: SpacingTokens.xs,
              bottom: SpacingTokens.md,
            ),
            child: TasksPageBody(),
          ),
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

    final theme = Theme.of(context);
    return Column(
      children: tasks
          .map((task) => _buildCompactTaskCard(task, theme, ref, context))
          .toList(),
    );
  }

  /// Reuse exact same compact task card from home screen for consistency
  Widget _buildCompactTaskCard(TaskModel task, ThemeData theme, WidgetRef ref, BuildContext context, {bool isOverdue = false}) {
    // Simplified actions to avoid context issues
    final endActions = [
      SlidableAction(
        onPressed: (_) => _editTask(context, task),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        icon: PhosphorIcons.pencil(),
        label: 'Edit',
      ),
      SlidableAction(
        onPressed: (_) => _deleteTask(context, ref, task),
        backgroundColor: theme.colorScheme.error,
        foregroundColor: Colors.white,
        icon: PhosphorIcons.trash(),
        label: 'Delete',
      ),
    ];

    // Choose card style based on task state for enhanced visual hierarchy
    final cardStyle = _getTaskCardStyle(task, isOverdue);

    final cardContent = SizedBox(
      height: SpacingTokens.taskCardHeight, // Golden ratio optimized height
      child: StandardizedCard(
        style: cardStyle,
        onTap: () => _navigateToTaskDetail(context, task.id),
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
                    color: task.priority.color,
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusXSmall),
                  ),
                ),
                const SizedBox(width: SpacingTokens.phi1), // Golden ratio spacing
                // Category icon container second
                if (task.tagIds.isNotEmpty) ...[
                  CategoryUtils.buildCategoryIconContainer(
                    category: task.tagIds.first,
                    size: 32,
                    theme: theme,
                    iconSizeRatio: 0.5,
                    borderRadius: 16, // Half of size (32/2) for circular design
                  ),
                  const SizedBox(width: SpacingTokens.phi1), // Golden ratio spacing
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Sophisticated audio indicator for voice tasks
                        if (task.metadata.containsKey('audioPath') && 
                            task.metadata['audioPath'] != null &&
                            (task.metadata['audioPath'] as String).isNotEmpty) ...[
                          StandardizedGaps.horizontal(SpacingSize.xs),
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
                              onTagTap: (_) {}, // No action on tap for tasks cards
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
      child: Slidable(
        key: ValueKey('compact-task-${task.id}'),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: endActions,
        ),
        child: cardContent,
      ),
    );
  }

  /// Get appropriate tertiary card style based on task state
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



  void _showTaskContextMenu(BuildContext context, TaskModel task) {
    // Show context menu with quick actions
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title),
        content: const Text('Quick actions for this task'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
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
