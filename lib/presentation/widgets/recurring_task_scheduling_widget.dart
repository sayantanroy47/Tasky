import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/entities/recurrence_pattern.dart';
import '../../domain/models/enums.dart';
import '../providers/recurring_task_providers.dart';
import 'glassmorphism_container.dart';
import 'loading_error_widgets.dart' as loading_widgets;
import '../../core/theme/typography_constants.dart';
import '../../core/routing/app_router.dart';
import '../pages/recurring_task_creation_page.dart';

/// Comprehensive recurring task management widget
class RecurringTaskSchedulingWidget extends ConsumerWidget {
  const RecurringTaskSchedulingWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recurringTasksAsync = ref.watch(recurringTasksProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Recurring Tasks'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateRecurringTaskDialog(context, ref),
            tooltip: 'Create recurring task',
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, ref, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'process',
                child: ListTile(
                  leading: Icon(Icons.sync),
                  title: Text('Process Recurring Tasks'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'refresh',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('Refresh'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Section
            _buildSummarySection(context, theme, recurringTasksAsync),
            const SizedBox(height: 16),
            
            // Recurring Tasks List
            Expanded(
              child: recurringTasksAsync.when(
                data: (tasks) => tasks.isEmpty
                    ? _buildEmptyState(context, theme)
                    : _buildRecurringTasksList(context, ref, theme, tasks),
                loading: () => const loading_widgets.LoadingWidget(
                  message: 'Loading recurring tasks...',
                ),
                error: (error, stack) => loading_widgets.ErrorWidget(
                  message: 'Failed to load recurring tasks',
                  details: error.toString(),
                  onRetry: () => ref.refresh(recurringTasksProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build summary section with stats
  Widget _buildSummarySection(
    BuildContext context,
    ThemeData theme,
    AsyncValue<List<TaskModel>> recurringTasksAsync,
  ) {
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: const EdgeInsets.all(16),
      child: recurringTasksAsync.when(
        data: (tasks) {
          final activeCount = tasks.where((t) => !t.isCompleted).length;
          final completedCount = tasks.where((t) => t.isCompleted).length;
          final dailyCount = tasks.where((t) => t.recurrence?.type == RecurrenceType.daily).length;
          final weeklyCount = tasks.where((t) => t.recurrence?.type == RecurrenceType.weekly).length;
          final monthlyCount = tasks.where((t) => t.recurrence?.type == RecurrenceType.monthly).length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.repeat, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Recurring Tasks Overview',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Stats grid
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(theme, 'Active', activeCount, Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(theme, 'Completed', completedCount, Colors.green),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(theme, 'Daily', dailyCount, Colors.orange),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(theme, 'Weekly', weeklyCount, Colors.purple),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(theme, 'Monthly', monthlyCount, Colors.teal),
                  ),
                ],
              ),
            ],
          );
        },
        loading: () => const SizedBox(height: 100),
        error: (_, __) => const SizedBox(height: 100),
      ),
    );
  }

  /// Build individual stat card
  Widget _buildStatCard(ThemeData theme, String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
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
      ),
    );
  }

  /// Build recurring tasks list
  Widget _buildRecurringTasksList(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    List<TaskModel> tasks,
  ) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildRecurringTaskCard(context, ref, theme, task);
      },
    );
  }

  /// Build individual recurring task card
  Widget _buildRecurringTaskCard(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    TaskModel task,
  ) {
    final recurrence = task.recurrence;
    if (recurrence == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => AppRouter.navigateToTaskDetail(context, task.id),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                  _buildRecurrenceTypeChip(theme, recurrence),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleTaskAction(context, ref, task, value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Edit Pattern'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'instances',
                        child: ListTile(
                          leading: Icon(Icons.list),
                          title: Text('View Instances'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'complete',
                        child: ListTile(
                          leading: Icon(Icons.check_circle),
                          title: Text('Complete & Generate Next'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'stop',
                        child: ListTile(
                          leading: Icon(Icons.stop, color: Colors.red),
                          title: Text('Stop Recurring', style: TextStyle(color: Colors.red)),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Recurrence details
              Text(
                _formatRecurrencePattern(recurrence),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              
              if (task.dueDate != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Next due: ${_formatDateTime(task.dueDate!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
              
              // Priority and status indicators
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildPriorityChip(theme, task.priority),
                  const SizedBox(width: 8),
                  _buildStatusChip(theme, task.status),
                  if (task.isCompleted && task.completedAt != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      'Completed ${_formatDateTime(task.completedAt!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build recurrence type chip
  Widget _buildRecurrenceTypeChip(ThemeData theme, RecurrencePattern recurrence) {
    Color chipColor;
    switch (recurrence.type) {
      case RecurrenceType.daily:
        chipColor = Colors.orange;
        break;
      case RecurrenceType.weekly:
        chipColor = Colors.purple;
        break;
      case RecurrenceType.monthly:
        chipColor = Colors.teal;
        break;
      case RecurrenceType.yearly:
        chipColor = Colors.blue;
        break;
      case RecurrenceType.custom:
        chipColor = Colors.indigo;
        break;
      case RecurrenceType.none:
        chipColor = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        recurrence.type.name.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: chipColor,
        ),
      ),
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
        color: chipColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        priority.name.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
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
        color: chipColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: chipColor,
        ),
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.repeat_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No Recurring Tasks',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create recurring tasks to automate your routine',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateRecurringTaskDialog(context, null),
            icon: const Icon(Icons.add),
            label: const Text('Create Recurring Task'),
          ),
        ],
      ),
    );
  }

  /// Format recurrence pattern for display
  String _formatRecurrencePattern(RecurrencePattern recurrence) {
    switch (recurrence.type) {
      case RecurrenceType.daily:
        return recurrence.interval == 1
            ? 'Every day'
            : 'Every ${recurrence.interval} days';
      case RecurrenceType.weekly:
        final days = recurrence.daysOfWeek;
        if (days == null || days.isEmpty) {
          return recurrence.interval == 1
              ? 'Every week'
              : 'Every ${recurrence.interval} weeks';
        }
        final dayNames = days.map(_getDayName).join(', ');
        return recurrence.interval == 1
            ? 'Weekly on $dayNames'
            : 'Every ${recurrence.interval} weeks on $dayNames';
      case RecurrenceType.monthly:
        return recurrence.interval == 1
            ? 'Every month'
            : 'Every ${recurrence.interval} months';
      case RecurrenceType.yearly:
        return recurrence.interval == 1
            ? 'Every year'
            : 'Every ${recurrence.interval} years';
      case RecurrenceType.custom:
        return 'Custom pattern';
      case RecurrenceType.none:
        return 'No recurrence';
    }
  }

  /// Get day name from number
  String _getDayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return 'Unknown';
    }
  }

  /// Format date time
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (date == today) {
      return 'Today ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (date == today.add(const Duration(days: 1))) {
      return 'Tomorrow ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  /// Handle menu actions
  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) async {
    switch (action) {
      case 'process':
        try {
          final newTasks = await ref.read(recurringTaskNotifierProvider.notifier).processRecurringTasks();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Processed recurring tasks. Generated ${newTasks.length} new tasks.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to process recurring tasks: $e'),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
        break;
      case 'refresh':
        final _ = ref.refresh(recurringTasksProvider);
        _showSnackBar(context, 'Refreshed recurring tasks');
        break;
    }
  }

  /// Handle task-specific actions
  void _handleTaskAction(BuildContext context, WidgetRef ref, TaskModel task, String action) async {
    switch (action) {
      case 'edit':
        // TODO: Navigate to edit recurrence pattern dialog
        break;
      case 'instances':
        // TODO: Show task instances dialog
        break;
      case 'complete':
        try {
          await ref.read(recurringTaskNotifierProvider.notifier).completeRecurringTask(task.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Task completed and next instance generated'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to complete task: $e'),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
        break;
      case 'stop':
        _showStopRecurringDialog(context, ref, task);
        break;
    }
  }

  /// Show create recurring task dialog
  void _showCreateRecurringTaskDialog(BuildContext context, WidgetRef? ref) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RecurringTaskCreationPage(),
      ),
    );
  }

  /// Show stop recurring task confirmation dialog
  void _showStopRecurringDialog(BuildContext context, WidgetRef ref, TaskModel task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stop Recurring Task'),
        content: Text(
          'Are you sure you want to stop the recurring pattern for "${task.title}"? '
          'This will also delete all future instances of this task.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ref.read(recurringTaskNotifierProvider.notifier).stopRecurringTask(task.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Recurring task stopped successfully'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to stop recurring task: $e'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Stop Recurring'),
          ),
        ],
      ),
    );
  }

  /// Show a simple snack bar message
  void _showSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}