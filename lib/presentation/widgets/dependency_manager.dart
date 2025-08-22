import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../providers/dependency_providers.dart';
import '../providers/task_providers.dart';
import '../../core/theme/typography_constants.dart';
import '../../core/design_system/design_tokens.dart';
import 'glassmorphism_container.dart';
import 'status_badge_widget.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Comprehensive dependency management widget for tasks
/// 
/// Provides functionality to:
/// - View task dependencies and prerequisites
/// - Add/remove dependencies
/// - Visualize dependency chains
/// - Validate dependency cycles
/// - Show dependency status and blocked tasks
class DependencyManager extends ConsumerStatefulWidget {
  final String? initialTaskId;
  final VoidCallback? onTaskSelected;
  final bool showCreateButton;
  final EdgeInsets? padding;

  const DependencyManager({
    super.key,
    this.initialTaskId,
    this.onTaskSelected,
    this.showCreateButton = true,
    this.padding,
  });

  @override
  ConsumerState<DependencyManager> createState() => _DependencyManagerState();
}

class _DependencyManagerState extends ConsumerState<DependencyManager>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedTaskId;
  bool _showAddDependencyDialog = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _selectedTaskId = widget.initialTaskId;
    
    if (_selectedTaskId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(dependencyManagerProvider.notifier).selectTask(_selectedTaskId!);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dependencyState = ref.watch(dependencyManagerProvider);

    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: widget.padding ?? const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme),
          const SizedBox(height: 16),
          _buildTaskSelector(theme),
          if (_selectedTaskId != null) ...[
            const SizedBox(height: 16),
            _buildTabBar(theme),
            const SizedBox(height: 16),
            Expanded(child: _buildTabContent(theme, dependencyState)),
          ] else
            _buildEmptyState(theme),
          if (_showAddDependencyDialog)
            _buildAddDependencyDialog(theme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Icon(
          PhosphorIcons.tree(),
          color: theme.colorScheme.primary,
          size: 24,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dependency Manager',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Manage task relationships and prerequisites',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (widget.showCreateButton)
          IconButton(
            onPressed: () => _showCreateDependencyDialog(),
            icon: Icon(PhosphorIcons.plus()),
            tooltip: 'Add Dependency',
          ),
      ],
    );
  }

  Widget _buildTaskSelector(ThemeData theme) {
    final allTasksAsync = ref.watch(tasksProvider);

    return allTasksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorWidget(theme, error.toString()),
      data: (tasks) => _buildTaskDropdown(theme, tasks),
    );
  }

  Widget _buildTaskDropdown(ThemeData theme, List<TaskModel> tasks) {
    final incompleteTasks = tasks.where((task) => !task.isCompleted).toList();

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButton<String>(
        value: _selectedTaskId,
        hint: Text(
          'Select a task to manage dependencies',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        isExpanded: true,
        underline: const SizedBox.shrink(),
        items: incompleteTasks.map((task) {
          return DropdownMenuItem<String>(
            value: task.id,
            child: Row(
              children: [
                Icon(
                  _getPriorityIcon(task.priority),
                  color: _getPriorityColor(task.priority),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task.title,
                    style: theme.textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (task.dueDate != null)
                  Text(
                    _formatDueDate(task.dueDate!),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
        onChanged: (String? taskId) {
          if (taskId != null) {
            setState(() {
              _selectedTaskId = taskId;
            });
            ref.read(dependencyManagerProvider.notifier).selectTask(taskId);
            widget.onTaskSelected?.call();
          }
        },
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: theme.colorScheme.primary,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        labelStyle: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'Prerequisites'),
          Tab(text: 'Dependents'),
          Tab(text: 'Chain'),
          Tab(text: 'Overview'),
        ],
      ),
    );
  }

  Widget _buildTabContent(ThemeData theme, DependencyManagerState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return _buildErrorWidget(theme, state.error!);
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildPrerequisitesTab(theme, state),
        _buildDependentsTab(theme, state),
        _buildChainTab(theme),
        _buildOverviewTab(theme),
      ],
    );
  }

  Widget _buildPrerequisitesTab(ThemeData theme, DependencyManagerState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Prerequisites (${state.prerequisites.length})',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            IconButton(
              onPressed: () => setState(() => _showAddDependencyDialog = true),
              icon: Icon(PhosphorIcons.plus()),
              tooltip: 'Add Prerequisite',
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (state.prerequisites.isEmpty)
          _buildEmptyDependencies(theme, 'No prerequisites set')
        else
          Expanded(
            child: ListView.builder(
              itemCount: state.prerequisites.length,
              itemBuilder: (context, index) {
                return _buildDependencyCard(
                  theme,
                  state.prerequisites[index],
                  isPrerequisite: true,
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildDependentsTab(ThemeData theme, DependencyManagerState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dependent Tasks (${state.dependents.length})',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (state.dependents.isEmpty)
          _buildEmptyDependencies(theme, 'No dependent tasks')
        else
          Expanded(
            child: ListView.builder(
              itemCount: state.dependents.length,
              itemBuilder: (context, index) {
                return _buildDependencyCard(
                  theme,
                  state.dependents[index],
                  isPrerequisite: false,
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildChainTab(ThemeData theme) {
    if (_selectedTaskId == null) return const SizedBox.shrink();

    final chainAsync = ref.watch(taskDependencyChainProvider(_selectedTaskId!));

    return chainAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorWidget(theme, error.toString()),
      data: (chain) => _buildDependencyChain(theme, chain),
    );
  }

  Widget _buildOverviewTab(ThemeData theme) {
    final blockedTasksAsync = ref.watch(blockedTasksProvider);
    final readyTasksAsync = ref.watch(readyTasksProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickStats(theme),
          const SizedBox(height: 20),
          Text(
            'Blocked Tasks',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          blockedTasksAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => _buildErrorWidget(theme, error.toString()),
            data: (blockedTasks) => _buildTaskList(theme, blockedTasks, isBlocked: true),
          ),
          const SizedBox(height: 20),
          Text(
            'Ready Tasks',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          readyTasksAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => _buildErrorWidget(theme, error.toString()),
            data: (readyTasks) => _buildTaskList(theme, readyTasks, isBlocked: false),
          ),
        ],
      ),
    );
  }

  Widget _buildDependencyCard(ThemeData theme, TaskModel task, {required bool isPrerequisite}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
          isPrerequisite ? PhosphorIcons.arrowDown() : PhosphorIcons.arrowUp(),
          color: isPrerequisite ? Colors.orange : Colors.blue,
        ),
        title: Text(
          task.title,
          style: theme.textTheme.bodyMedium?.copyWith(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description?.isNotEmpty == true)
              Text(
                task.description!,
                style: theme.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            Row(
              children: [
                Icon(
                  _getPriorityIcon(task.priority),
                  color: _getPriorityColor(task.priority),
                  size: 14,
                ),
                SizedBox(width: 4),
                Text(
                  task.priority.name.toUpperCase(),
                  style: theme.textTheme.labelSmall,
                ),
                if (task.dueDate != null) ...[
                  const SizedBox(width: 12),
                  Text(
                    _formatDueDate(task.dueDate!),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatusBadgeWidget(status: task.status),
            IconButton(
              onPressed: () => _removeDependency(task.id, isPrerequisite),
              icon: Icon(PhosphorIcons.minusCircle()),
              iconSize: 20,
              tooltip: 'Remove Dependency',
            ),
          ],
        ),
        onTap: () => _navigateToTask(task.id),
      ),
    );
  }

  Widget _buildDependencyChain(ThemeData theme, List<TaskModel> chain) {
    if (chain.isEmpty) {
      return _buildEmptyDependencies(theme, 'No dependency chain');
    }

    return ListView.builder(
      itemCount: chain.length,
      itemBuilder: (context, index) {
        final task = chain[index];
        final isCurrentTask = task.id == _selectedTaskId;
        
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isCurrentTask 
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                : null,
            borderRadius: BorderRadius.circular(8),
            border: isCurrentTask 
                ? Border.all(color: theme.colorScheme.primary, width: 2)
                : null,
          ),
          child: ListTile(
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: isCurrentTask 
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainer,
              child: Text(
                '${index + 1}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isCurrentTask 
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              task.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isCurrentTask ? FontWeight.w600 : null,
              ),
            ),
            subtitle: Row(
              children: [
                Icon(
                  _getPriorityIcon(task.priority),
                  color: _getPriorityColor(task.priority),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  task.priority.name.toUpperCase(),
                  style: theme.textTheme.labelSmall,
                ),
                if (task.dueDate != null) ...[
                  const SizedBox(width: 12),
                  Text(
                    _formatDueDate(task.dueDate!),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
            trailing: StatusBadgeWidget(status: task.status),
            onTap: () => _navigateToTask(task.id),
          ),
        );
      },
    );
  }

  Widget _buildQuickStats(ThemeData theme) {
    final allTasksAsync = ref.watch(tasksProvider);

    return allTasksAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
      data: (tasks) {
        final total = tasks.length;
        final completed = tasks.where((t) => t.isCompleted).length;
        final inProgress = tasks.where((t) => t.status == TaskStatus.inProgress).length;
        final pending = tasks.where((t) => t.status == TaskStatus.pending).length;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatCard(theme, 'Total', total.toString(), Colors.blue),
            _buildStatCard(theme, 'Completed', completed.toString(), Colors.green),
            _buildStatCard(theme, 'In Progress', inProgress.toString(), Colors.orange),
            _buildStatCard(theme, 'Pending', pending.toString(), Colors.grey),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(ThemeData theme, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(ThemeData theme, List<TaskModel> tasks, {required bool isBlocked}) {
    if (tasks.isEmpty) {
      return _buildEmptyDependencies(
        theme, 
        isBlocked ? 'No blocked tasks' : 'No ready tasks',
      );
    }

    return Column(
      children: tasks.take(5).map((task) => Card(
        margin: const EdgeInsets.symmetric(vertical: 2),
        child: ListTile(
          leading: Icon(
            isBlocked ? PhosphorIcons.prohibit() : PhosphorIcons.checkCircle(),
            color: isBlocked ? Colors.red : Colors.green,
          ),
          title: Text(
            task.title,
            style: theme.textTheme.bodyMedium,
          ),
          subtitle: Row(
            children: [
              Icon(
                _getPriorityIcon(task.priority),
                color: _getPriorityColor(task.priority),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                task.priority.name.toUpperCase(),
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
          trailing: StatusBadgeWidget(status: task.status),
          onTap: () => _navigateToTask(task.id),
        ),
      )).toList(),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.tree(),
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Select a Task',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a task to view and manage its dependencies',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDependencies(ThemeData theme, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.link(),
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(ThemeData theme, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.warningCircle(),
            size: 48,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(dependencyManagerProvider.notifier).clearError();
              if (_selectedTaskId != null) {
                ref.read(dependencyManagerProvider.notifier).selectTask(_selectedTaskId!);
              }
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildAddDependencyDialog(ThemeData theme) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Dialog(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add Prerequisite',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  'Select a task that must be completed before the current task can be started.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                // Task selector would go here
                _buildDependencyTaskSelector(theme),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => setState(() => _showAddDependencyDialog = false),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _addSelectedDependency(),
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDependencyTaskSelector(ThemeData theme) {
    final allTasksAsync = ref.watch(tasksProvider);

    return allTasksAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
      data: (tasks) {
        final availableTasks = tasks
            .where((task) => task.id != _selectedTaskId && !task.isCompleted)
            .toList();

        return Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.builder(
            itemCount: availableTasks.length,
            itemBuilder: (context, index) {
              final task = availableTasks[index];
              return ListTile(
                leading: Icon(
                  _getPriorityIcon(task.priority),
                  color: _getPriorityColor(task.priority),
                  size: 16,
                ),
                title: Text(task.title),
                subtitle: Text(task.priority.name.toUpperCase()),
                onTap: () => _selectTaskForDependency(task.id),
              );
            },
          ),
        );
      },
    );
  }

  // Helper methods
  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return PhosphorIcons.caretDown();
      case TaskPriority.medium:
        return PhosphorIcons.minus();
      case TaskPriority.high:
        return PhosphorIcons.caretUp();
      case TaskPriority.urgent:
        return PhosphorIcons.arrowUp();
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.urgent:
        return Colors.purple;
    }
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);
    
    final difference = taskDate.difference(today).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 1 && difference <= 7) {
      return 'In $difference days';
    } else if (difference < -1 && difference >= -7) {
      return '${-difference} days ago';
    } else {
      return '${date.day}/${date.month}';
    }
  }

  // Action methods
  void _showCreateDependencyDialog() {
    setState(() => _showAddDependencyDialog = true);
  }

  String? _selectedDependencyTaskId;

  void _selectTaskForDependency(String taskId) {
    setState(() {
      _selectedDependencyTaskId = taskId;
    });
  }

  Future<void> _addSelectedDependency() async {
    if (_selectedTaskId != null && _selectedDependencyTaskId != null) {
      final success = await ref
          .read(dependencyManagerProvider.notifier)
          .addDependency(_selectedTaskId!, _selectedDependencyTaskId!);
      
      if (success) {
        setState(() {
          _showAddDependencyDialog = false;
          _selectedDependencyTaskId = null;
        });
      }
    }
  }

  Future<void> _removeDependency(String prerequisiteTaskId, bool isPrerequisite) async {
    if (_selectedTaskId != null) {
      final success = await ref
          .read(dependencyManagerProvider.notifier)
          .removeDependency(_selectedTaskId!, prerequisiteTaskId);
      
      if (success) {
        // Refresh the dependencies
        ref.read(dependencyManagerProvider.notifier).selectTask(_selectedTaskId!);
      }
    }
  }

  void _navigateToTask(String taskId) {
    // Navigate to task detail page
    Navigator.of(context).pushNamed('/task-detail', arguments: taskId);
  }
}

/// Simplified dependency widget for inline display
class SimpleDependencyWidget extends ConsumerWidget {
  final String taskId;
  final bool showCount;

  const SimpleDependencyWidget({
    super.key,
    required this.taskId,
    this.showCount = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final canCompleteAsync = ref.watch(canCompleteTaskProvider(taskId));
    final prerequisitesAsync = ref.watch(taskPrerequisitesProvider(taskId));

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        canCompleteAsync.when(
          loading: () => SizedBox(width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          error: (error, stack) => Icon(
            PhosphorIcons.warningCircle(),
            size: 16,
            color: theme.colorScheme.error,
          ),
          data: (canComplete) => Icon(
            canComplete ? PhosphorIcons.checkCircle() : PhosphorIcons.prohibit(),
            size: 16,
            color: canComplete ? Colors.green : Colors.red,
          ),
        ),
        if (showCount) ...[
          const SizedBox(width: 4),
          prerequisitesAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => const SizedBox.shrink(),
            data: (prerequisites) => Text(
              '${prerequisites.length}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

