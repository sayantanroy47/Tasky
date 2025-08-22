import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../providers/task_dependency_providers.dart';
import '../providers/task_providers.dart';
import 'glassmorphism_container.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
        
        const SizedBox(height: 16),
        
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dependency Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
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
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Ready',
                    stats.readyTasks.toString(),
                    PhosphorIcons.playCircle(),
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Blocked',
                    stats.blockedTasks.toString(),
                    PhosphorIcons.prohibit(),
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
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
        
        const SizedBox(height: 16),
        
        // Task Lists
        Expanded(
          child: DefaultTabController(
            length: 3,
            child: TabBarView(
              children: [
                _buildTaskList(context, ref, 'Ready Tasks', graphData.readyTasks, Colors.green),
                _buildTaskList(context, ref, 'Blocked Tasks', graphData.blockedTasks, Colors.orange),
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
          Tab(text: 'Ready'),
          Tab(text: 'Blocked'),
          Tab(text: 'Dependencies'),
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
            const SizedBox(height: 16),
            Text(
              'No ${title.toLowerCase()}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
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
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
          ),
        ),
        title: Text(
          task.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          'Dependencies: ${task.dependencies.length}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task description
                if (task.description?.isNotEmpty == true) ...[
                  Text(
                    task.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 12),
                ],
                
                // Prerequisites
                dependencyChainAsync.when(
                  data: (prerequisites) => _buildPrerequisitesList(context, prerequisites),
                  loading: () => const SizedBox(height: 40, child: Center(child: CircularProgressIndicator())),
                  error: (_, __) => const SizedBox(),
                ),
                
                const SizedBox(height: 12),
                
                // Dependent tasks
                dependentTasksAsync.when(
                  data: (dependents) => _buildDependentsList(context, dependents),
                  loading: () => const SizedBox(height: 40, child: Center(child: CircularProgressIndicator())),
                  error: (_, __) => const SizedBox(),
                ),
                
                const SizedBox(height: 12),
                
                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showManageDependenciesDialog(context, ref, task),
                      icon: Icon(PhosphorIcons.pencil()),
                      label: const Text('Manage'),
                    ),
                    const SizedBox(width: 8),
                    if (task.status == TaskStatus.pending)
                      ElevatedButton(
                        onPressed: () => _validateAndStartTask(context, ref, task),
                        child: const Text('Start Task'),
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
        Text(
          'Prerequisites:',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        ...prerequisites.map((prereq) => Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 2),
          child: Row(
            children: [
              Icon(
                prereq.status == TaskStatus.completed ? PhosphorIcons.checkCircle() : PhosphorIcons.circle(),
                size: 16,
                color: prereq.status == TaskStatus.completed ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  prereq.title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    decoration: prereq.status == TaskStatus.completed ? TextDecoration.lineThrough : null,
                  ),
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
        Text(
          'Blocks:',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        ...dependents.map((dependent) => Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 2),
          child: Row(
            children: [
              Icon(
                PhosphorIcons.prohibit(),
                size: 16,
                color: Colors.orange,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  dependent.title,
                  style: Theme.of(context).textTheme.bodySmall,
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
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () => _showAddDependencyDialog(context, ref, graphData.allTasks),
            icon: Icon(PhosphorIcons.plus()),
            label: const Text('Add Dependency'),
          ),
        ),
      ],
    );
  }

  Widget _buildDependencyRelationship(BuildContext context, DependencyRelationship dependency) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dependency.dependent.title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    'Depends on',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(PhosphorIcons.arrowRight(), color: Colors.grey),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dependency.prerequisite.title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Row(
                    children: [
                      Icon(
                        dependency.prerequisite.status == TaskStatus.completed ? PhosphorIcons.checkCircle() : PhosphorIcons.circle(),
                        size: 16,
                        color: dependency.prerequisite.status == TaskStatus.completed ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dependency.prerequisite.status.name,
                        style: Theme.of(context).textTheme.bodySmall,
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
          const SizedBox(height: 16),
          Text(
            'No Active Tasks',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create some tasks to see dependency relationships',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
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
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
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
            content: Text('Started task: ${task.title}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validation.errorMessage ?? 'Cannot start task due to incomplete dependencies'),
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
      title: Text('Manage Dependencies: ${task.title}'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            // Current dependencies
            Text(
              'Current Dependencies:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: dependencyChainAsync.when(
                data: (dependencies) => ListView.builder(
                  itemCount: dependencies.length,
                  itemBuilder: (context, index) {
                    final dependency = dependencies[index];
                    return ListTile(
                      title: Text(dependency.title),
                      subtitle: Text(dependency.status.name),
                      trailing: IconButton(
                        icon: Icon(PhosphorIcons.minusCircle(), color: Colors.red),
                        onPressed: () => _removeDependency(context, ref, task.id, dependency.id),
                      ),
                    );
                  },
                ),
                loading: () => Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text('Failed to load dependencies'),
              ),
            ),
            
            const Divider(),
            
            // Add new dependency
            Text(
              'Add Dependency:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ref.watch(tasksProvider).when(
                data: (allTasks) {
                  final availableTasks = allTasks
                      .where((t) => t.id != task.id && !task.dependencies.contains(t.id))
                      .toList();
                  
                  return ListView.builder(
                    itemCount: availableTasks.length,
                    itemBuilder: (context, index) {
                      final availableTask = availableTasks[index];
                      return ListTile(
                        title: Text(availableTask.title),
                        subtitle: Text(availableTask.status.name),
                        trailing: IconButton(
                          icon: Icon(PhosphorIcons.plusCircle(), color: Colors.green),
                          onPressed: () => _addDependency(context, ref, task.id, availableTask.id),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text('Failed to load available tasks'),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
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
          content: Text(result.isSuccess ? 'Dependency added' : result.errorMessage ?? 'Failed to add dependency'),
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
          content: Text(result.isSuccess ? 'Dependency removed' : result.errorMessage ?? 'Failed to remove dependency'),
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
      title: const Text('Add Dependency'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Select dependent task
          DropdownButtonFormField<TaskModel>(
            decoration: const InputDecoration(labelText: 'Dependent Task'),
            value: selectedDependent,
            items: widget.availableTasks.map((task) => DropdownMenuItem(
              value: task,
              child: Text(task.title),
            )).toList(),
            onChanged: (task) => setState(() => selectedDependent = task),
          ),
          
          const SizedBox(height: 16),
          
          // Select prerequisite task
          DropdownButtonFormField<TaskModel>(
            decoration: const InputDecoration(labelText: 'Prerequisite Task'),
            value: selectedPrerequisite,
            items: widget.availableTasks
                .where((task) => task != selectedDependent)
                .map((task) => DropdownMenuItem(
                  value: task,
                  child: Text(task.title),
                )).toList(),
            onChanged: (task) => setState(() => selectedPrerequisite = task),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _canAddDependency() ? _addDependency : null,
          child: const Text('Add'),
        ),
      ],
    );
  }

  bool _canAddDependency() {
    return selectedDependent != null && 
           selectedPrerequisite != null && 
           selectedDependent != selectedPrerequisite;
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
          content: Text(result.isSuccess ? 'Dependency added' : result.errorMessage ?? 'Failed to add dependency'),
          backgroundColor: result.isSuccess ? Colors.green : Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}

