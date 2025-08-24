import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/accessibility/touch_target_validator.dart';
import '../../core/theme/typography_constants.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../providers/project_providers.dart';
import '../providers/task_provider.dart' show taskOperationsProvider;
import '../providers/task_providers.dart';
import 'glassmorphism_container.dart';
import 'loading_error_widgets.dart' as loading_widgets;
import 'standardized_spacing.dart';

/// Comprehensive batch operations widget for managing multiple tasks
class BatchTaskOperationsWidget extends ConsumerStatefulWidget {
  final List<TaskModel> preselectedTasks;
  final VoidCallback? onOperationComplete;

  const BatchTaskOperationsWidget({
    super.key,
    this.preselectedTasks = const [],
    this.onOperationComplete,
  });

  @override
  ConsumerState<BatchTaskOperationsWidget> createState() => _BatchTaskOperationsWidgetState();
}

class _BatchTaskOperationsWidgetState extends ConsumerState<BatchTaskOperationsWidget> {
  final Set<String> _selectedTaskIds = {};
  String _searchQuery = '';
  TaskStatus? _filterStatus;
  TaskPriority? _filterPriority;
  String? _filterProject;

  @override
  void initState() {
    super.initState();
    // Pre-select provided tasks
    _selectedTaskIds.addAll(widget.preselectedTasks.map((t) => t.id));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          _selectedTaskIds.isEmpty ? 'Batch Operations' : '${_selectedTaskIds.length} tasks selected',
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_selectedTaskIds.isNotEmpty) ...[
            PopupMenuButton<String>(
              onSelected: _handleBatchOperation,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'complete',
                  child: ListTile(
                    leading: Icon(PhosphorIcons.checkCircle(), color: Colors.green),
                    title: const Text('Mark as Complete'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'incomplete',
                  child: ListTile(
                    leading: Icon(PhosphorIcons.circle()),
                    title: const Text('Mark as Incomplete'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'priority',
                  child: ListTile(
                    leading: Icon(PhosphorIcons.flag()),
                    title: const Text('Change Priority'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'project',
                  child: ListTile(
                    leading: Icon(PhosphorIcons.folder()),
                    title: const Text('Move to Project'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'duplicate',
                  child: ListTile(
                    leading: Icon(PhosphorIcons.copy()),
                    title: const Text('Duplicate Tasks'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'export',
                  child: ListTile(
                    leading: Icon(PhosphorIcons.download()),
                    title: const Text('Export Tasks'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(PhosphorIcons.trash(), color: Colors.red),
                    title: const Text('Delete Tasks', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: () => setState(() => _selectedTaskIds.clear()),
              icon: Icon(PhosphorIcons.x()),
              tooltip: 'Clear selection',
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          _buildSearchAndFilters(theme),

          // Selection Controls
          if (_selectedTaskIds.isNotEmpty) _buildSelectionControls(theme),

          // Tasks List
          Expanded(
            child: tasksAsync.when(
              data: (tasks) => _buildTasksList(theme, tasks),
              loading: () => const loading_widgets.LoadingWidget(
                message: 'Loading tasks...',
              ),
              error: (error, stack) => loading_widgets.ErrorWidget(
                message: 'Failed to load tasks',
                details: error.toString(),
                onRetry: () => ref.refresh(tasksProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build search and filters section
  Widget _buildSearchAndFilters(ThemeData theme) {
    return GlassmorphismContainer(
      margin: StandardizedSpacing.margin(SpacingSize.md),
      padding: StandardizedSpacing.padding(SpacingSize.md),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      child: Column(
        children: [
          // Search field
          TextField(
            decoration: InputDecoration(
              hintText: 'Search tasks...',
              prefixIcon: Icon(PhosphorIcons.magnifyingGlass()),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () => setState(() => _searchQuery = ''),
                      icon: Icon(PhosphorIcons.x()),
                    )
                  : null,
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),

          StandardizedGaps.md, // Consistent 16px spacing

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Status filter
                FilterChip(
                  label: Text(_filterStatus?.displayName ?? 'All Status'),
                  selected: _filterStatus != null,
                  onSelected: (_) => _showStatusFilter(),
                ),
                StandardizedGaps.hSm,

                // Priority filter
                FilterChip(
                  label: Text(_filterPriority?.displayName ?? 'All Priorities'),
                  selected: _filterPriority != null,
                  onSelected: (_) => _showPriorityFilter(),
                ),
                StandardizedGaps.hSm,

                // Project filter
                FilterChip(
                  label: Text(_filterProject ?? 'All Projects'),
                  selected: _filterProject != null,
                  onSelected: (_) => _showProjectFilter(),
                ),
                StandardizedGaps.hSm,

                // Clear filters
                if (_filterStatus != null || _filterPriority != null || _filterProject != null)
                  ActionChip(
                    label: const Text('Clear Filters'),
                    onPressed: () => setState(() {
                      _filterStatus = null;
                      _filterPriority = null;
                      _filterProject = null;
                    }),
                    avatar: Icon(PhosphorIcons.x(), size: 16),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build selection controls
  Widget _buildSelectionControls(ThemeData theme) {
    return Container(
      margin: StandardizedSpacing.marginSymmetric(horizontal: SpacingSize.md),
      padding: StandardizedSpacing.padding(SpacingSize.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            PhosphorIcons.checkCircle(),
            color: theme.colorScheme.primary,
            size: 20,
          ),
          StandardizedGaps.hSm,
          Expanded(
            child: Text(
              '${_selectedTaskIds.length} task${_selectedTaskIds.length == 1 ? '' : 's'} selected',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _selectedTaskIds.clear()),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  /// Build tasks list
  Widget _buildTasksList(ThemeData theme, List<TaskModel> allTasks) {
    final filteredTasks = _filterTasks(allTasks);

    if (filteredTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.checkSquare(),
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            StandardizedGaps.md,
            Text(
              'No tasks found',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            StandardizedGaps.sm,
            Text(
              'Try adjusting your filters or search query',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: StandardizedSpacing.padding(SpacingSize.md),
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = filteredTasks[index];
        final isSelected = _selectedTaskIds.contains(task.id);

        return Card(
          margin: StandardizedSpacing.marginOnly(bottom: SpacingSize.sm),
          child: InkWell(
            onTap: () => _toggleTaskSelection(task.id),
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            child: Padding(
              padding: StandardizedSpacing.padding(SpacingSize.sm),
              child: Row(
                children: [
                  // Selection checkbox
                  Checkbox(
                    value: isSelected,
                    onChanged: (_) => _toggleTaskSelection(task.id),
                  ),

                  StandardizedGaps.horizontal(SpacingSize.sm),

                  // Task content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        if (task.description != null && task.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            task.description!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildPriorityChip(theme, task.priority),
                            const SizedBox(width: 8),
                            _buildStatusChip(theme, task.status),
                            if (task.dueDate != null) ...[
                              const SizedBox(width: 8),
                              Icon(
                                PhosphorIcons.clock(),
                                size: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                _formatDate(task.dueDate!),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build priority chip
  Widget _buildPriorityChip(ThemeData theme, TaskPriority priority) {
    Color chipColor;
    switch (priority) {
      case TaskPriority.urgent:
        chipColor = Colors.red;
        break;
      case TaskPriority.high:
        chipColor = Colors.orange;
        break;
      case TaskPriority.medium:
        chipColor = Colors.blue;
        break;
      case TaskPriority.low:
        chipColor = Colors.green;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        priority.name.toUpperCase(),
        style: TextStyle(
          fontSize: TypographyConstants.labelSmall, // 11.0 - Fixed critical WCAG violation (was 10px)
          fontWeight: FontWeight.w500,
          color: chipColor,
        ),
      ),
    );
  }

  /// Build status chip
  Widget _buildStatusChip(ThemeData theme, TaskStatus status) {
    Color chipColor;
    switch (status) {
      case TaskStatus.pending:
        chipColor = Colors.grey;
        break;
      case TaskStatus.inProgress:
        chipColor = Colors.blue;
        break;
      case TaskStatus.completed:
        chipColor = Colors.green;
        break;
      case TaskStatus.cancelled:
        chipColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          fontSize: TypographyConstants.labelSmall, // 11.0 - Fixed critical WCAG violation (was 10px)
          fontWeight: FontWeight.w500,
          color: chipColor,
        ),
      ),
    );
  }

  /// Filter tasks based on search and filters
  List<TaskModel> _filterTasks(List<TaskModel> allTasks) {
    return allTasks.where((task) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final title = task.title.toLowerCase();
        final description = (task.description ?? '').toLowerCase();
        final tags = task.tags.join(' ').toLowerCase();

        if (!title.contains(query) && !description.contains(query) && !tags.contains(query)) {
          return false;
        }
      }

      // Status filter
      if (_filterStatus != null && task.status != _filterStatus) {
        return false;
      }

      // Priority filter
      if (_filterPriority != null && task.priority != _filterPriority) {
        return false;
      }

      // Project filter
      if (_filterProject != null && task.projectId != _filterProject) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Toggle task selection
  void _toggleTaskSelection(String taskId) {
    setState(() {
      if (_selectedTaskIds.contains(taskId)) {
        _selectedTaskIds.remove(taskId);
      } else {
        _selectedTaskIds.add(taskId);
      }
    });
  }

  /// Handle batch operations
  void _handleBatchOperation(String operation) async {
    if (_selectedTaskIds.isEmpty) return;

    switch (operation) {
      case 'complete':
        await _markTasksComplete(true);
        break;
      case 'incomplete':
        await _markTasksComplete(false);
        break;
      case 'priority':
        _showPriorityChangeDialog();
        break;
      case 'project':
        _showProjectMoveDialog();
        break;
      case 'duplicate':
        await _duplicateTasks();
        break;
      case 'export':
        await _exportTasks();
        break;
      case 'delete':
        _showDeleteConfirmation();
        break;
    }
  }

  /// Mark tasks as complete/incomplete
  Future<void> _markTasksComplete(bool completed) async {
    try {
      final tasksAsync = ref.read(tasksProvider);
      final allTasks = tasksAsync.valueOrNull ?? [];
      final selectedTasks = allTasks.where((t) => _selectedTaskIds.contains(t.id));

      for (final task in selectedTasks) {
        final updatedTask = task.copyWith(
          status: completed ? TaskStatus.completed : TaskStatus.pending,
          completedAt: completed ? DateTime.now() : null,
        );
        await ref.read(taskOperationsProvider).updateTask(updatedTask);
      }

      _showSuccess('Tasks ${completed ? 'completed' : 'marked as incomplete'} successfully');
      setState(() => _selectedTaskIds.clear());
      widget.onOperationComplete?.call();
    } catch (e) {
      _showError('Failed to update tasks: $e');
    }
  }

  /// Duplicate selected tasks
  Future<void> _duplicateTasks() async {
    try {
      final tasksAsync = ref.read(tasksProvider);
      final allTasks = tasksAsync.valueOrNull ?? [];
      final selectedTasks = allTasks.where((t) => _selectedTaskIds.contains(t.id));

      for (final task in selectedTasks) {
        final duplicatedTask = TaskModel.create(
          title: '${task.title} (Copy)',
          description: task.description,
          dueDate: task.dueDate,
          priority: task.priority,
          tags: task.tags,
          projectId: task.projectId,
          locationTrigger: task.locationTrigger,
          recurrence: task.recurrence,
          estimatedDuration: task.estimatedDuration,
        );
        await ref.read(taskOperationsProvider).createTask(duplicatedTask);
      }

      _showSuccess('${selectedTasks.length} tasks duplicated successfully');
      setState(() => _selectedTaskIds.clear());
      widget.onOperationComplete?.call();
    } catch (e) {
      _showError('Failed to duplicate tasks: $e');
    }
  }

  /// Export selected tasks
  Future<void> _exportTasks() async {
    // TODO: Implement task export functionality
    _showSuccess('Export functionality coming soon!');
  }

  /// Show status filter
  void _showStatusFilter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Status'),
              leading: AccessibleRadio<TaskStatus?>(
                value: null,
                groupValue: _filterStatus,
                semanticLabel: 'All Status',
                onChanged: (value) {
                  setState(() => _filterStatus = value);
                  Navigator.pop(context);
                },
              ),
            ),
            ...TaskStatus.values.map((status) => ListTile(
                  title: Text(status.displayName),
                  leading: AccessibleRadio<TaskStatus?>(
                    value: status,
                    groupValue: _filterStatus,
                    semanticLabel: 'Filter by ${status.displayName}',
                    onChanged: (value) {
                      setState(() => _filterStatus = value);
                      Navigator.pop(context);
                    },
                  ),
                )),
          ],
        ),
      ),
    );
  }

  /// Show priority filter
  void _showPriorityFilter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Priority'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Priorities'),
              leading: AccessibleRadio<TaskPriority?>(
                value: null,
                groupValue: _filterPriority,
                semanticLabel: 'All Priorities',
                onChanged: (value) {
                  setState(() => _filterPriority = value);
                  Navigator.pop(context);
                },
              ),
            ),
            ...TaskPriority.values.map((priority) => ListTile(
                  title: Text(priority.displayName),
                  leading: AccessibleRadio<TaskPriority?>(
                    value: priority,
                    groupValue: _filterPriority,
                    semanticLabel: 'Filter by ${priority.displayName}',
                    onChanged: (value) {
                      setState(() => _filterPriority = value);
                      Navigator.pop(context);
                    },
                  ),
                )),
          ],
        ),
      ),
    );
  }

  /// Show project filter
  void _showProjectFilter() {
    final projectsAsync = ref.read(projectsProvider);
    projectsAsync.when(
      data: (projects) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Filter by Project'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('All Projects'),
                  leading: AccessibleRadio<String?>(
                    value: null,
                    groupValue: _filterProject,
                    semanticLabel: 'All Projects',
                    onChanged: (value) {
                      setState(() => _filterProject = value);
                      Navigator.pop(context);
                    },
                  ),
                ),
                ...projects.map((project) => ListTile(
                      title: Text(project.name),
                      leading: AccessibleRadio<String?>(
                        value: project.id,
                        groupValue: _filterProject,
                        semanticLabel: 'Filter by project ${project.name}',
                        onChanged: (value) {
                          setState(() => _filterProject = value);
                          Navigator.pop(context);
                        },
                      ),
                    )),
              ],
            ),
          ),
        );
      },
      loading: () => _showError('Loading projects...'),
      error: (_, __) => _showError('Failed to load projects'),
    );
  }

  /// Show priority change dialog
  void _showPriorityChangeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Priority'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: TaskPriority.values.map((priority) {
            return ListTile(
              title: Text(priority.displayName),
              onTap: () {
                Navigator.pop(context);
                _changePriority(priority);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Show project move dialog
  void _showProjectMoveDialog() {
    final projectsAsync = ref.read(projectsProvider);
    projectsAsync.when(
      data: (projects) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Move to Project'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('No Project'),
                  onTap: () {
                    Navigator.pop(context);
                    _moveToProject(null);
                  },
                ),
                ...projects.map((project) => ListTile(
                      title: Text(project.name),
                      onTap: () {
                        Navigator.pop(context);
                        _moveToProject(project.id);
                      },
                    )),
              ],
            ),
          ),
        );
      },
      loading: () => _showError('Loading projects...'),
      error: (_, __) => _showError('Failed to load projects'),
    );
  }

  /// Show delete confirmation
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tasks'),
        content: Text(
          'Are you sure you want to delete ${_selectedTaskIds.length} task${_selectedTaskIds.length == 1 ? '' : 's'}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTasks();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Change priority of selected tasks
  Future<void> _changePriority(TaskPriority newPriority) async {
    try {
      final tasksAsync = ref.read(tasksProvider);
      final allTasks = tasksAsync.valueOrNull ?? [];
      final selectedTasks = allTasks.where((t) => _selectedTaskIds.contains(t.id));

      for (final task in selectedTasks) {
        final updatedTask = task.copyWith(priority: newPriority);
        await ref.read(taskOperationsProvider).updateTask(updatedTask);
      }

      _showSuccess('Priority changed to ${newPriority.displayName}');
      setState(() => _selectedTaskIds.clear());
      widget.onOperationComplete?.call();
    } catch (e) {
      _showError('Failed to change priority: $e');
    }
  }

  /// Move selected tasks to project
  Future<void> _moveToProject(String? projectId) async {
    try {
      final tasksAsync = ref.read(tasksProvider);
      final allTasks = tasksAsync.valueOrNull ?? [];
      final selectedTasks = allTasks.where((t) => _selectedTaskIds.contains(t.id));

      for (final task in selectedTasks) {
        final updatedTask = task.copyWith(projectId: projectId);
        await ref.read(taskOperationsProvider).updateTask(updatedTask);
      }

      _showSuccess(
        projectId != null ? 'Tasks moved to project' : 'Tasks removed from project',
      );
      setState(() => _selectedTaskIds.clear());
      widget.onOperationComplete?.call();
    } catch (e) {
      _showError('Failed to move tasks: $e');
    }
  }

  /// Delete selected tasks
  Future<void> _deleteTasks() async {
    try {
      final tasksAsync = ref.read(tasksProvider);
      final allTasks = tasksAsync.valueOrNull ?? [];
      final selectedTasks = allTasks.where((t) => _selectedTaskIds.contains(t.id));

      for (final task in selectedTasks) {
        await ref.read(taskOperationsProvider).deleteTask(
              task,
              context: context,
              showFeedback: false, // We'll show batch feedback instead
              requireConfirmation: false, // Already confirmed in dialog
            );
      }

      _showSuccess('${_selectedTaskIds.length} tasks deleted successfully');
      setState(() => _selectedTaskIds.clear());
      widget.onOperationComplete?.call();
    } catch (e) {
      _showError('Failed to delete tasks: $e');
    }
  }

  /// Helper methods
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return 'Today';
    } else if (taskDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else if (taskDate.isBefore(today)) {
      final days = today.difference(taskDate).inDays;
      return '$days day${days == 1 ? '' : 's'} ago';
    } else {
      return '${date.month}/${date.day}';
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
