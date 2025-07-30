import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/entities/task_enums.dart';
import '../../domain/repositories/task_repository.dart';
import '../../core/routing/app_router.dart';
import '../providers/task_providers.dart';
import '../widgets/theme_selector.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/task_card.dart';
import '../widgets/task_form_dialog.dart';
import '../widgets/loading_error_widgets.dart' as loading_widgets;
import '../widgets/custom_dialogs.dart';

class TasksPage extends ConsumerWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: 'Tasks',
      actions: [
        const ThemeToggleButton(),
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () => _showFilterDialog(context, ref),
          tooltip: 'Filter tasks',
        ),
      ],
      body: const TasksPageBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
        tooltip: 'Create new task',
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const TaskFormDialog(),
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SearchBar(),
          const SizedBox(height: 16),
          _SmartFilters(),
          const SizedBox(height: 16),
          if (filter.hasFilters || searchQuery.isNotEmpty) ...[
            _ActiveFiltersIndicator(
              filter: filter,
              searchQuery: searchQuery,
              onClearFilters: () => _clearFilters(ref),
            ),
            const SizedBox(height: 16),
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
    
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search tasks by title, description, or tags...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  ref.read(searchQueryProvider.notifier).state = '';
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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
        Text(
          'Quick Filters',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _SmartFilterChip(
                label: 'Today',
                isSelected: _isTodayFilterActive(filter),
                onTap: () => _applyTodayFilter(ref),
              ),
              const SizedBox(width: 8),
              _SmartFilterChip(
                label: 'This Week',
                isSelected: _isThisWeekFilterActive(filter),
                onTap: () => _applyThisWeekFilter(ref),
              ),
              const SizedBox(width: 8),
              _SmartFilterChip(
                label: 'Overdue',
                isSelected: filter.isOverdue == true,
                onTap: () => _applyOverdueFilter(ref),
              ),
              const SizedBox(width: 8),
              _SmartFilterChip(
                label: 'High Priority',
                isSelected: filter.priority == TaskPriority.high || filter.priority == TaskPriority.urgent,
                onTap: () => _applyHighPriorityFilter(ref),
              ),
              const SizedBox(width: 8),
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
    
    return filter.dueDateFrom!.isAtSameMomentAs(today) && 
           filter.dueDateTo!.isAtSameMomentAs(tomorrow);
  }

  bool _isThisWeekFilterActive(TaskFilter filter) {
    if (filter.dueDateFrom == null || filter.dueDateTo == null) return false;
    
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endOfWeekDate = startOfWeekDate.add(const Duration(days: 7));
    
    return filter.dueDateFrom!.isAtSameMomentAs(startOfWeekDate) && 
           filter.dueDateTo!.isAtSameMomentAs(endOfWeekDate);
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
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
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

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.filter_alt,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Active filters: ${activeFilters.join(', ')}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            TextButton(
              onPressed: onClearFilters,
              child: const Text('Clear'),
            ),
          ],
        ),
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

    final searchQuery = ref.watch(searchQueryProvider);

    return Column(
      children: tasks.map((task) => TaskCard(
        title: task.title,
        description: task.description,
        isCompleted: task.status == TaskStatus.completed,
        priority: task.priority.index,
        dueDate: task.dueDate,
        tags: task.tags,
        searchQuery: searchQuery.isNotEmpty ? searchQuery : null,
        onTap: () => _navigateToTaskDetail(context, task.id),
        onToggleComplete: () => _toggleTaskCompletion(ref, task),
        onEdit: () => _editTask(context, task),
        onDelete: () => _deleteTask(context, ref, task),
      )).toList(),
    );
  }

  void _navigateToTaskDetail(BuildContext context, String taskId) {
    Navigator.of(context).pushNamed(
      AppRouter.taskDetail,
      arguments: taskId,
    );
  }

  void _toggleTaskCompletion(WidgetRef ref, TaskModel task) {
    ref.read(taskOperationsProvider).toggleTaskCompletion(task);
  }

  void _editTask(BuildContext context, TaskModel task) {
    showDialog(
      context: context,
      builder: (context) => TaskFormDialog(task: task),
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
          await ref.read(taskOperationsProvider).deleteTask(task.id);
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
            Icons.task_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first task to get started!',
            style: Theme.of(context).textTheme.bodyMedium,
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
    return AlertDialog(
      title: const Text('Filter Tasks'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _currentFilter.status == null,
                  onSelected: (_) => setState(() {
                    _currentFilter = _currentFilter.copyWith(status: null);
                  }),
                ),
                ...TaskStatus.values.map((status) => FilterChip(
                  label: Text(status.displayName),
                  selected: _currentFilter.status == status,
                  onSelected: (_) => setState(() {
                    _currentFilter = _currentFilter.copyWith(status: status);
                  }),
                )),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Priority',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _currentFilter.priority == null,
                  onSelected: (_) => setState(() {
                    _currentFilter = _currentFilter.copyWith(priority: null);
                  }),
                ),
                ...TaskPriority.values.map((priority) => FilterChip(
                  label: Text(priority.displayName),
                  selected: _currentFilter.priority == priority,
                  onSelected: (_) => setState(() {
                    _currentFilter = _currentFilter.copyWith(priority: priority);
                  }),
                )),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _clearFilters,
          child: const Text('Clear'),
        ),
        ElevatedButton(
          onPressed: _applyFilters,
          child: const Text('Apply'),
        ),
      ],
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
}