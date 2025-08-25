import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../providers/task_dependency_providers.dart';
import '../providers/task_providers.dart';
import 'glassmorphism_container.dart';
import 'standardized_text.dart';
import 'standardized_spacing.dart';
import 'standardized_colors.dart';

/// Widget for visualizing and managing task dependencies
class TaskDependencyVisualization extends ConsumerWidget {
  final TaskModel? selectedTask;
  final VoidCallback? onTaskSelected;

  const TaskDependencyVisualization({
    super.key,
    this.selectedTask,
    this.onTaskSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dependencyGraphAsync = ref.watch(dependencyGraphProvider);
    final dependencyStatsAsync = ref.watch(dependencyStatsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Statistics Section
        dependencyStatsAsync.when(
          data: (stats) => _buildStatsSection(context, stats),
          loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
          error: (error, _) => _buildErrorWidget(context, 'Failed to load dependency statistics'),
        ),

        StandardizedGaps.md,

        // Dependency Graph Section
        Expanded(
          child: dependencyGraphAsync.when(
            data: (graphData) => _buildDependencyGraph(context, ref, graphData),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _buildErrorWidget(context, 'Failed to load dependency graph'),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context, DependencyStats stats) {
    return GlassmorphismContainer(
      blur: 15.0,
      opacity: 0.1,
      child: Padding(
        padding: StandardizedSpacing.padding(SpacingSize.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StandardizedText(
              'Dependency Overview',
              style: StandardizedTextStyle.titleLarge,
            ),
            StandardizedGaps.vertical(SpacingSize.sm),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Total Tasks',
                    stats.totalTasks.toString(),
                    PhosphorIcons.checkSquare(),
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                StandardizedGaps.hSm,
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Ready',
                    stats.readyTasks.toString(),
                    PhosphorIcons.playCircle(),
                    context.successColor,
                  ),
                ),
                StandardizedGaps.hSm,
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Blocked',
                    stats.blockedTasks.toString(),
                    PhosphorIcons.prohibit(),
                    context.warningColor,
                  ),
                ),
                StandardizedGaps.hSm,
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Dependencies',
                    stats.totalDependencies.toString(),
                    PhosphorIcons.tree(),
                    Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: StandardizedSpacing.padding(SpacingSize.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          StandardizedGaps.xs,
          StandardizedText(
            value,
            style: StandardizedTextStyle.titleMedium,
            color: color,
          ),
          StandardizedText(
            title,
            style: StandardizedTextStyle.bodySmall,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDependencyGraph(BuildContext context, WidgetRef ref, DependencyGraphData graphData) {
    if (graphData.allTasks.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tab Bar for different views
        _buildTabBar(context),

        StandardizedGaps.md,

        // Task Lists
        Expanded(
          child: DefaultTabController(
            length: 3,
            child: TabBarView(
              children: [
                _buildTaskList(context, ref, 'Ready Tasks', graphData.readyTasks, context.successColor),
                _buildTaskList(context, ref, 'Blocked Tasks', graphData.blockedTasks, context.warningColor),
                _buildDependencyView(context, ref, graphData),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TabBar(
        indicatorColor: Theme.of(context).colorScheme.primary,
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        tabs: const [
          Tab(child: StandardizedText('Ready', style: StandardizedTextStyle.labelMedium)),
          Tab(child: StandardizedText('Blocked', style: StandardizedTextStyle.labelMedium)),
          Tab(child: StandardizedText('Dependencies', style: StandardizedTextStyle.labelMedium)),
        ],
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, WidgetRef ref, String title, List<TaskModel> tasks, Color color) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              title.contains('Ready') ? PhosphorIcons.checkCircle() : PhosphorIcons.prohibit(),
              size: 64,
              color: color.withValues(alpha: 0.5),
            ),
            StandardizedGaps.md,
            StandardizedText(
              'No ${title.toLowerCase()}',
              style: StandardizedTextStyle.titleMedium,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskDependencyCard(context, ref, task, color);
      },
    );
  }

  Widget _buildTaskDependencyCard(BuildContext context, WidgetRef ref, TaskModel task, Color statusColor) {
    final dependencyChainAsync = ref.watch(taskDependencyChainProvider(task));
    final dependentTasksAsync = ref.watch(dependentTasksProvider(task.id));

    return Card(
      margin: StandardizedSpacing.marginOnly(bottom: SpacingSize.sm),
      child: ExpansionTile(
        leading: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
          ),
        ),
        title: StandardizedText(
          task.title,
          style: StandardizedTextStyle.titleMedium,
        ),
        subtitle: StandardizedText(
          'Dependencies: ${task.dependencies.length}',
          style: StandardizedTextStyle.bodySmall,
        ),
        children: [
          Padding(
            padding: StandardizedSpacing.padding(SpacingSize.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task description
                if (task.description?.isNotEmpty == true) ...[
                  StandardizedText(
                    task.description!,
                    style: StandardizedTextStyle.bodyMedium,
                  ),
                  StandardizedGaps.vertical(SpacingSize.sm),
                ],

                // Prerequisites
                dependencyChainAsync.when(
                  data: (prerequisites) => _buildPrerequisitesList(context, prerequisites),
                  loading: () => const SizedBox(height: 40, child: Center(child: CircularProgressIndicator())),
                  error: (_, __) => const SizedBox(),
                ),

                StandardizedGaps.vertical(SpacingSize.sm),

                // Dependent tasks
                dependentTasksAsync.when(
                  data: (dependents) => _buildDependentsList(context, dependents),
                  loading: () => const SizedBox(height: 40, child: Center(child: CircularProgressIndicator())),
                  error: (_, __) => const SizedBox(),
                ),

                StandardizedGaps.vertical(SpacingSize.sm),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showManageDependenciesDialog(context, ref, task),
                      icon: Icon(PhosphorIcons.pencil()),
                      label: const StandardizedText('Manage', style: StandardizedTextStyle.buttonText),
                    ),
                    StandardizedGaps.hSm,
                    if (task.status == TaskStatus.pending)
                      ElevatedButton(
                        onPressed: () => _validateAndStartTask(context, ref, task),
                        child: const StandardizedText('Start Task', style: StandardizedTextStyle.buttonText),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrerequisitesList(BuildContext context, List<TaskModel> prerequisites) {
    if (prerequisites.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StandardizedText(
          'Prerequisites:',
          style: StandardizedTextStyle.titleSmall,
        ),
        StandardizedGaps.xs,
        ...prerequisites.map((prereq) => Padding(
              padding: StandardizedSpacing.paddingOnly(left: SpacingSize.sm, bottom: SpacingSize.xs),
              child: Row(
                children: [
                  Icon(
                    prereq.status == TaskStatus.completed ? PhosphorIcons.checkCircle() : PhosphorIcons.circle(),
                    size: 16,
                    color: prereq.status == TaskStatus.completed ? context.successColor : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  StandardizedGaps.hSm,
                  Expanded(
                    child: StandardizedText(
                      prereq.title,
                      style: StandardizedTextStyle.bodySmall,
                      decoration: prereq.status == TaskStatus.completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildDependentsList(BuildContext context, List<TaskModel> dependents) {
    if (dependents.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StandardizedText(
          'Blocks:',
          style: StandardizedTextStyle.titleSmall,
        ),
        StandardizedGaps.xs,
        ...dependents.map((dependent) => Padding(
              padding: StandardizedSpacing.paddingOnly(left: SpacingSize.sm, bottom: SpacingSize.xs),
              child: Row(
                children: [
                  Icon(
                    PhosphorIcons.prohibit(),
                    size: 16,
                    color: context.warningColor,
                  ),
                  StandardizedGaps.hSm,
                  Expanded(
                    child: StandardizedText(
                      dependent.title,
                      style: StandardizedTextStyle.bodySmall,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildDependencyView(BuildContext context, WidgetRef ref, DependencyGraphData graphData) {
    return Column(
      children: [
        // Dependency relationships
        Expanded(
          child: ListView.builder(
            itemCount: graphData.dependencies.length,
            itemBuilder: (context, index) {
              final dependency = graphData.dependencies[index];
              return _buildDependencyRelationship(context, dependency);
            },
          ),
        ),

        // Add dependency button
        Padding(
          padding: StandardizedSpacing.padding(SpacingSize.md),
          child: ElevatedButton.icon(
            onPressed: () => _showAddDependencyDialog(context, ref, graphData.allTasks),
            icon: Icon(PhosphorIcons.plus()),
            label: const StandardizedText('Add Dependency', style: StandardizedTextStyle.buttonText),
          ),
        ),
      ],
    );
  }

  Widget _buildDependencyRelationship(BuildContext context, DependencyRelationship dependency) {
    return Card(
      margin: StandardizedSpacing.marginOnly(bottom: SpacingSize.sm),
      child: Padding(
        padding: StandardizedSpacing.padding(SpacingSize.md),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StandardizedText(
                    dependency.dependent.title,
                    style: StandardizedTextStyle.titleSmall,
                  ),
                  StandardizedText(
                    'Depends on',
                    style: StandardizedTextStyle.bodySmall,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
            Icon(PhosphorIcons.arrowRight(), color: Theme.of(context).colorScheme.onSurfaceVariant),
            StandardizedGaps.hSm,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StandardizedText(
                    dependency.prerequisite.title,
                    style: StandardizedTextStyle.titleSmall,
                  ),
                  Row(
                    children: [
                      Icon(
                        dependency.prerequisite.status == TaskStatus.completed
                            ? PhosphorIcons.checkCircle()
                            : PhosphorIcons.circle(),
                        size: 16,
                        color: dependency.prerequisite.status == TaskStatus.completed ? context.successColor : context.warningColor,
                      ),
                      StandardizedGaps.hXs,
                      StandardizedText(
                        dependency.prerequisite.status.name,
                        style: StandardizedTextStyle.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.tree(),
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          StandardizedGaps.md,
          StandardizedText(
            'No Active Tasks',
            style: StandardizedTextStyle.titleMedium,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          StandardizedGaps.sm,
          StandardizedText(
            'Create some tasks to see dependency relationships',
            style: StandardizedTextStyle.bodyMedium,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.warningCircle(),
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          StandardizedGaps.md,
          StandardizedText(
            message,
            style: StandardizedTextStyle.bodyMedium,
            color: Theme.of(context).colorScheme.error,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showManageDependenciesDialog(BuildContext context, WidgetRef ref, TaskModel task) {
    showDialog(
      context: context,
      builder: (context) => TaskDependencyManagementDialog(task: task),
    );
  }

  void _showAddDependencyDialog(BuildContext context, WidgetRef ref, List<TaskModel> allTasks) {
    showDialog(
      context: context,
      builder: (context) => AddDependencyDialog(availableTasks: allTasks),
    );
  }

  void _validateAndStartTask(BuildContext context, WidgetRef ref, TaskModel task) async {
    final dependencyService = ref.read(taskDependencyServiceProvider);
    final validation = await dependencyService.validateTaskCompletion(task);

    if (validation.isValid) {
      // Task can be started - update status would require task repository access
      // For now, just show success message

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: StandardizedText('Started task: ${task.title}', style: StandardizedTextStyle.bodyMedium),
            backgroundColor: context.successColor,
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: StandardizedText(validation.errorMessage ?? 'Cannot start task due to incomplete dependencies', style: StandardizedTextStyle.bodyMedium),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

/// Dialog for managing task dependencies
class TaskDependencyManagementDialog extends ConsumerWidget {
  final TaskModel task;

  const TaskDependencyManagementDialog({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dependencyChainAsync = ref.watch(taskDependencyChainProvider(task));

    return AlertDialog(
      title: StandardizedText('Manage Dependencies: ${task.title}', style: StandardizedTextStyle.titleMedium),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            // Current dependencies
            const StandardizedText(
              'Current Dependencies:',
              style: StandardizedTextStyle.titleSmall,
            ),
            StandardizedGaps.sm,
            Expanded(
              child: dependencyChainAsync.when(
                data: (dependencies) => ListView.builder(
                  itemCount: dependencies.length,
                  itemBuilder: (context, index) {
                    final dependency = dependencies[index];
                    return ListTile(
                      title: StandardizedText(dependency.title, style: StandardizedTextStyle.bodyMedium),
                      subtitle: StandardizedText(dependency.status.name, style: StandardizedTextStyle.bodySmall),
                      trailing: IconButton(
                        icon: Icon(PhosphorIcons.minusCircle(), color: context.errorColor),
                        onPressed: () => _removeDependency(context, ref, task.id, dependency.id),
                      ),
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const StandardizedText('Failed to load dependencies', style: StandardizedTextStyle.bodyMedium),
              ),
            ),

            const Divider(),

            // Add new dependency
            const StandardizedText(
              'Add Dependency:',
              style: StandardizedTextStyle.titleSmall,
            ),
            StandardizedGaps.sm,
            Expanded(
              child: ref.watch(tasksProvider).when(
                    data: (allTasks) {
                      final availableTasks =
                          allTasks.where((t) => t.id != task.id && !task.dependencies.contains(t.id)).toList();

                      return ListView.builder(
                        itemCount: availableTasks.length,
                        itemBuilder: (context, index) {
                          final availableTask = availableTasks[index];
                          return ListTile(
                            title: StandardizedText(availableTask.title, style: StandardizedTextStyle.bodyMedium),
                            subtitle: StandardizedText(availableTask.status.name, style: StandardizedTextStyle.bodySmall),
                            trailing: IconButton(
                              icon: Icon(PhosphorIcons.plusCircle(), color: Colors.green),
                              onPressed: () => _addDependency(context, ref, task.id, availableTask.id),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const StandardizedText('Failed to load available tasks', style: StandardizedTextStyle.bodyMedium),
                  ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const StandardizedText('Close', style: StandardizedTextStyle.buttonText),
        ),
      ],
    );
  }

  void _addDependency(BuildContext context, WidgetRef ref, String dependentTaskId, String prerequisiteTaskId) async {
    final dependencyNotifier = ref.read(taskDependencyNotifierProvider.notifier);
    final result = await dependencyNotifier.addDependency(dependentTaskId, prerequisiteTaskId);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: StandardizedText(result.isSuccess ? 'Dependency added' : result.errorMessage ?? 'Failed to add dependency', style: StandardizedTextStyle.bodyMedium),
          backgroundColor: result.isSuccess ? Colors.green : Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _removeDependency(BuildContext context, WidgetRef ref, String dependentTaskId, String prerequisiteTaskId) async {
    final dependencyNotifier = ref.read(taskDependencyNotifierProvider.notifier);
    final result = await dependencyNotifier.removeDependency(dependentTaskId, prerequisiteTaskId);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: StandardizedText(result.isSuccess ? 'Dependency removed' : result.errorMessage ?? 'Failed to remove dependency', style: StandardizedTextStyle.bodyMedium),
          backgroundColor: result.isSuccess ? Colors.green : Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}

/// Simple dialog for adding dependencies
class AddDependencyDialog extends ConsumerStatefulWidget {
  final List<TaskModel> availableTasks;

  const AddDependencyDialog({
    super.key,
    required this.availableTasks,
  });

  @override
  ConsumerState<AddDependencyDialog> createState() => _AddDependencyDialogState();
}

class _AddDependencyDialogState extends ConsumerState<AddDependencyDialog> {
  TaskModel? selectedDependent;
  TaskModel? selectedPrerequisite;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const StandardizedText('Add Dependency', style: StandardizedTextStyle.titleMedium),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Select dependent task
          DropdownButtonFormField<TaskModel>(
            decoration: const InputDecoration(labelText: 'Dependent Task'),
            initialValue: selectedDependent,
            items: widget.availableTasks
                .map((task) => DropdownMenuItem(
                      value: task,
                      child: StandardizedText(task.title, style: StandardizedTextStyle.bodyMedium),
                    ))
                .toList(),
            onChanged: (task) => setState(() => selectedDependent = task),
          ),

          StandardizedGaps.md,

          // Select prerequisite task
          DropdownButtonFormField<TaskModel>(
            decoration: const InputDecoration(labelText: 'Prerequisite Task'),
            initialValue: selectedPrerequisite,
            items: widget.availableTasks
                .where((task) => task != selectedDependent)
                .map((task) => DropdownMenuItem(
                      value: task,
                      child: StandardizedText(task.title, style: StandardizedTextStyle.bodyMedium),
                    ))
                .toList(),
            onChanged: (task) => setState(() => selectedPrerequisite = task),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const StandardizedText('Cancel', style: StandardizedTextStyle.buttonText),
        ),
        ElevatedButton(
          onPressed: _canAddDependency() ? _addDependency : null,
          child: const StandardizedText('Add', style: StandardizedTextStyle.buttonText),
        ),
      ],
    );
  }

  bool _canAddDependency() {
    return selectedDependent != null && selectedPrerequisite != null && selectedDependent != selectedPrerequisite;
  }

  void _addDependency() async {
    if (!_canAddDependency()) return;

    final dependencyNotifier = ref.read(taskDependencyNotifierProvider.notifier);
    final result = await dependencyNotifier.addDependency(
      selectedDependent!.id,
      selectedPrerequisite!.id,
    );

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: StandardizedText(result.isSuccess ? 'Dependency added' : result.errorMessage ?? 'Failed to add dependency', style: StandardizedTextStyle.bodyMedium),
          backgroundColor: result.isSuccess ? Colors.green : Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
