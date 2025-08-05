import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/theme_selector.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/voice_task_creation_dialog.dart';
import '../providers/task_provider.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../../core/routing/app_router.dart';

/// Home page - main dashboard of the app
class HomePage extends ConsumerWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: 'Task Tracker',
      actions: [
        const ThemeToggleButton(),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // TODO: Navigate to search
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Search functionality coming soon!')),
            );
          },
          tooltip: 'Search',
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            AppRouter.navigateToRoute(context, AppRouter.settings);
          },
          tooltip: 'Settings',
        ),
      ],
      body: const HomePageBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const VoiceTaskCreationDialog(),
          );
        },
        icon: const Icon(Icons.mic),
        label: const Text('Voice Task'),
        tooltip: 'Create task with voice',
      ),
    );
  }
}

/// Home page body content
class HomePageBody extends ConsumerWidget {
  const HomePageBody({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Welcome section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(
                    Icons.task_alt,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome to Task Tracker',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your voice-driven task management app',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () {
                      AppRouter.navigateToRoute(context, AppRouter.tasks);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create Your First Task'),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Quick stats cards
          _QuickStatsSection(),
          
          const SizedBox(height: 16),
          
          // Recent tasks section
          _RecentTasksSection(),
          
          const SizedBox(height: 16),
          
          // Quick actions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.mic,
                          label: 'Voice Task',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => const VoiceTaskCreationDialog(),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.add,
                          label: 'Quick Add',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => const VoiceTaskCreationDialog(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick stat card widget
class _QuickStatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickStatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                count.toString(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Quick stats section showing real task counts
class _QuickStatsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingTasks = ref.watch(pendingTasksProvider);
    final completedTasks = ref.watch(completedTasksProvider);
    final todayTasks = ref.watch(todayTasksProvider);

    return Row(
      children: [
        Expanded(
          child: pendingTasks.when(
            data: (tasks) => _QuickStatCard(
              title: 'Pending',
              count: tasks.length,
              icon: Icons.pending_actions,
              color: Theme.of(context).colorScheme.primary,
              onTap: () {
                AppRouter.navigateToRoute(context, AppRouter.tasks);
              },
            ),
            loading: () => _QuickStatCard(
              title: 'Pending',
              count: 0,
              icon: Icons.pending_actions,
              color: Theme.of(context).colorScheme.primary,
              onTap: () {
                AppRouter.navigateToRoute(context, AppRouter.tasks);
              },
            ),
            error: (_, __) => _QuickStatCard(
              title: 'Pending',
              count: 0,
              icon: Icons.pending_actions,
              color: Theme.of(context).colorScheme.primary,
              onTap: () {
                AppRouter.navigateToRoute(context, AppRouter.tasks);
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: todayTasks.when(
            data: (tasks) => _QuickStatCard(
              title: 'Today',
              count: tasks.length,
              icon: Icons.today,
              color: Theme.of(context).colorScheme.secondary,
              onTap: () {
                AppRouter.navigateToRoute(context, AppRouter.calendar);
              },
            ),
            loading: () => _QuickStatCard(
              title: 'Today',
              count: 0,
              icon: Icons.today,
              color: Theme.of(context).colorScheme.secondary,
              onTap: () {
                AppRouter.navigateToRoute(context, AppRouter.calendar);
              },
            ),
            error: (_, __) => _QuickStatCard(
              title: 'Today',
              count: 0,
              icon: Icons.today,
              color: Theme.of(context).colorScheme.secondary,
              onTap: () {
                AppRouter.navigateToRoute(context, AppRouter.calendar);
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: completedTasks.when(
            data: (tasks) => _QuickStatCard(
              title: 'Completed',
              count: tasks.length,
              icon: Icons.check_circle,
              color: Theme.of(context).colorScheme.tertiary,
              onTap: () {
                AppRouter.navigateToRoute(context, AppRouter.analytics);
              },
            ),
            loading: () => _QuickStatCard(
              title: 'Completed',
              count: 0,
              icon: Icons.check_circle,
              color: Theme.of(context).colorScheme.tertiary,
              onTap: () {
                AppRouter.navigateToRoute(context, AppRouter.analytics);
              },
            ),
            error: (_, __) => _QuickStatCard(
              title: 'Completed',
              count: 0,
              icon: Icons.check_circle,
              color: Theme.of(context).colorScheme.tertiary,
              onTap: () {
                AppRouter.navigateToRoute(context, AppRouter.analytics);
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Recent tasks section showing actual tasks from database
class _RecentTasksSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTasks = ref.watch(tasksProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Recent Tasks',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    AppRouter.navigateToRoute(context, AppRouter.tasks);
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            allTasks.when(
              data: (tasks) {
                if (tasks.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.task_outlined,
                          size: 48,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No tasks yet',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Create your first task to get started!',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                // Show last 3 tasks, sorted by most recent
                final recentTasks = tasks.take(3).toList();
                
                return Column(
                  children: recentTasks.map((task) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      leading: Checkbox(
                        value: task.status == TaskStatus.completed,
                        onChanged: (value) {
                          ref.read(taskOperationsProvider).toggleTaskCompletion(task);
                        },
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: task.status == TaskStatus.completed 
                            ? TextDecoration.lineThrough 
                            : null,
                        ),
                      ),
                      subtitle: task.dueDate != null 
                        ? Text('Due ${_formatDueDate(task.dueDate!)}')
                        : null,
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          AppRouter.taskDetail,
                          arguments: task.id,
                        );
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  )).toList(),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Failed to load tasks',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    TextButton(
                      onPressed: () => ref.refresh(tasksProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 1) {
      return 'In $difference days';
    } else {
      return '${-difference} days ago';
    }
  }
}

/// Quick action button widget
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });
  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}
