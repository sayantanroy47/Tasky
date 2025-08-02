import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/task_model.dart';
import '../../domain/entities/task_enums.dart';
import '../providers/dependency_providers.dart';
import '../providers/task_providers.dart';

/// Widget for managing task dependencies
/// 
/// Allows users to view, add, and remove dependencies for a task.
/// Shows prerequisites (tasks this task depends on) and dependents
/// (tasks that depend on this task).
class DependencyManager extends ConsumerStatefulWidget {
  final String taskId;
  final VoidCallback? onChanged;

  const DependencyManager({
    super.key,
    required this.taskId,
    this.onChanged,
  });  @override
  ConsumerState<DependencyManager> createState() => _DependencyManagerState();
}

class _DependencyManagerState extends ConsumerState<DependencyManager> {  @override
  void initState() {
    super.initState();
    // Load dependencies when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dependencyManagerProvider.notifier).selectTask(widget.taskId);
    });
  }  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dependencyState = ref.watch(dependencyManagerProvider);
    final prerequisitesAsync = ref.watch(taskPrerequisitesProvider(widget.taskId));
    final dependentsAsync = ref.watch(taskDependentsProvider(widget.taskId));
    final canCompleteAsync = ref.watch(canCompleteTaskProvider(widget.taskId));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.account_tree,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Task Dependencies',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                // Can complete indicator
                canCompleteAsync.when(
                  data: (canComplete) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: canComplete ? Colors.green.withOpacity( 0.1) : Colors.orange.withOpacity( 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          canComplete ? Icons.check_circle : Icons.block,
                          size: 16,
                          color: canComplete ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          canComplete ? 'Ready' : 'Blocked',
                          style: TextStyle(
                            color: canComplete ? Colors.green : Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  loading: () => const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Error message
            if (dependencyState.error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        dependencyState.error!,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        ref.read(dependencyManagerProvider.notifier).clearError();
                      },
                      icon: const Icon(Icons.close),
                      iconSize: 20,
                    ),
                  ],
                ),
              ),
            
            if (dependencyState.error != null) const SizedBox(height: 16),
            
            // Prerequisites section
            Text(
              'Prerequisites',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            prerequisitesAsync.when(
              data: (prerequisites) => prerequisites.isEmpty
                  ? _buildEmptyState('No prerequisites set')
                  : Column(
                      children: prerequisites.map((task) => 
                        _buildDependencyTile(
                          context,
                          task,
                          isPrerequisite: true,
                          onRemove: () => _removeDependency(task.id),
                        ),
                      ).toList(),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _buildErrorState(error.toString()),
            ),
            
            // Add prerequisite button
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _showAddDependencyDialog(context, isPrerequisite: true),
              icon: const Icon(Icons.add),
              label: const Text('Add Prerequisite'),
            ),
            
            const SizedBox(height: 24),
            
            // Dependents section
            Text(
              'Dependents',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            dependentsAsync.when(
              data: (dependents) => dependents.isEmpty
                  ? _buildEmptyState('No tasks depend on this one')
                  : Column(
                      children: dependents.map((task) => 
                        _buildDependencyTile(
                          context,
                          task,
                          isPrerequisite: false,
                          onRemove: () => _removeDependentTask(task.id),
                        ),
                      ).toList(),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _buildErrorState(error.toString()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDependencyTile(
    BuildContext context,
    TaskModel task, {
    required bool isPrerequisite,
    required VoidCallback onRemove,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline.withOpacity( 0.1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Task status indicator
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getStatusColor(task.status),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          
          // Task info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    decoration: task.status.isCompleted 
                        ? TextDecoration.lineThrough 
                        : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (task.dueDate != null)
                  Text(
                    'Due: ${_formatDate(task.dueDate!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: task.isOverdue 
                          ? theme.colorScheme.error 
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          
          // Priority indicator
          if (task.priority.index > 1) // Medium and above
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getPriorityColor(task.priority).withOpacity( 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                task.priority.name.toUpperCase(),
                style: TextStyle(
                  color: _getPriorityColor(task.priority),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          
          const SizedBox(width: 8),
          
          // Remove button
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.remove_circle_outline),
            iconSize: 20,
            tooltip: isPrerequisite ? 'Remove prerequisite' : 'Remove dependent',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity( 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            message,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDependencyDialog(BuildContext context, {required bool isPrerequisite}) {
    showDialog(
      context: context,
      builder: (context) => AddDependencyDialog(
        taskId: widget.taskId,
        isPrerequisite: isPrerequisite,
        onAdded: () {
          widget.onChanged?.call();
          // Refresh the dependencies
          ref.read(dependencyManagerProvider.notifier).selectTask(widget.taskId);
        },
      ),
    );
  }

  Future<void> _removeDependency(String prerequisiteTaskId) async {
    final success = await ref.read(dependencyManagerProvider.notifier)
        .removeDependency(widget.taskId, prerequisiteTaskId);
    
    if (success) {
      widget.onChanged?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dependency removed')),
        );
      }
    }
  }

  Future<void> _removeDependentTask(String dependentTaskId) async {
    final success = await ref.read(dependencyManagerProvider.notifier)
        .removeDependency(dependentTaskId, widget.taskId);
    
    if (success) {
      widget.onChanged?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dependent task removed')),
        );
      }
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.cancelled:
        return Colors.red;
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 0 && difference <= 7) {
      return 'In $difference days';
    } else if (difference < 0 && difference >= -7) {
      return '${-difference} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Dialog for adding a new dependency
class AddDependencyDialog extends ConsumerStatefulWidget {
  final String taskId;
  final bool isPrerequisite;
  final VoidCallback? onAdded;

  const AddDependencyDialog({
    super.key,
    required this.taskId,
    required this.isPrerequisite,
    this.onAdded,
  });  @override
  ConsumerState<AddDependencyDialog> createState() => _AddDependencyDialogState();
}

class _AddDependencyDialogState extends ConsumerState<AddDependencyDialog> {
  String _searchQuery = '';
  TaskModel? _selectedTask;  @override
  Widget build(BuildContext context) {
    final allTasksAsync = ref.watch(tasksProvider);

    return AlertDialog(
      title: Text(widget.isPrerequisite ? 'Add Prerequisite' : 'Add Dependent Task'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            // Search field
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search tasks',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Task list
            Expanded(
              child: allTasksAsync.when(
                data: (tasks) {
                  final filteredTasks = tasks.where((task) {
                    // Exclude the current task
                    if (task.id == widget.taskId) return false;
                    
                    // Apply search filter
                    if (_searchQuery.isNotEmpty) {
                      return task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                             (task.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
                    }
                    
                    return true;
                  }).toList();

                  if (filteredTasks.isEmpty) {
                    return const Center(
                      child: Text('No tasks found'),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      final isSelected = _selectedTask?.id == task.id;
                      
                      return ListTile(
                        selected: isSelected,
                        leading: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _getStatusColor(task.status),
                            shape: BoxShape.circle,
                          ),
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.status.isCompleted 
                                ? TextDecoration.lineThrough 
                                : null,
                          ),
                        ),
                        subtitle: task.dueDate != null
                            ? Text('Due: ${_formatDate(task.dueDate!)}')
                            : null,
                        trailing: task.priority.index > 1
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getPriorityColor(task.priority).withOpacity( 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  task.priority.name.toUpperCase(),
                                  style: TextStyle(
                                    color: _getPriorityColor(task.priority),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedTask = isSelected ? null : task;
                          });
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Text('Error loading tasks: $error'),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedTask == null ? null : _addDependency,
          child: const Text('Add'),
        ),
      ],
    );
  }

  Future<void> _addDependency() async {
    if (_selectedTask == null) return;

    final dependencyManager = ref.read(dependencyManagerProvider.notifier);
    
    bool success;
    if (widget.isPrerequisite) {
      success = await dependencyManager.addDependency(widget.taskId, _selectedTask!.id);
    } else {
      success = await dependencyManager.addDependency(_selectedTask!.id, widget.taskId);
    }

    if (success && mounted) {
      Navigator.of(context).pop();
      widget.onAdded?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isPrerequisite 
                ? 'Prerequisite added successfully' 
                : 'Dependent task added successfully',
          ),
        ),
      );
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.cancelled:
        return Colors.red;
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
