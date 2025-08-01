import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/theme_selector.dart';
import '../widgets/app_scaffold.dart';
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
            AppRouter.navigateToRoute(context, AppRouter.settings, ref);
          },
          tooltip: 'Settings',
        ),
      ],
      body: const HomePageBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to add task
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Voice task creation coming soon!')),
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
                      AppRouter.navigateToRoute(context, AppRouter.tasks, ref);
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
          Row(
            children: [
              Expanded(
                child: _QuickStatCard(
                  title: 'Pending',
                  count: 12,
                  icon: Icons.pending_actions,
                  color: Theme.of(context).colorScheme.primary,
                  onTap: () {
                    AppRouter.navigateToRoute(context, AppRouter.tasks, ref);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickStatCard(
                  title: 'Today',
                  count: 5,
                  icon: Icons.today,
                  color: Theme.of(context).colorScheme.secondary,
                  onTap: () {
                    AppRouter.navigateToRoute(context, AppRouter.calendar, ref);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickStatCard(
                  title: 'Completed',
                  count: 8,
                  icon: Icons.check_circle,
                  color: Theme.of(context).colorScheme.tertiary,
                  onTap: () {
                    AppRouter.navigateToRoute(context, AppRouter.analytics, ref);
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Recent tasks section
          Card(
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
                          AppRouter.navigateToRoute(context, AppRouter.tasks, ref);
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Sample recent tasks
                  ...List.generate(3, (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      leading: Checkbox(
                        value: index == 0,
                        onChanged: (value) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                value == true 
                                  ? 'Task completed!' 
                                  : 'Task marked as pending',
                              ),
                            ),
                          );
                        },
                      ),
                      title: Text(
                        'Sample Task ${index + 1}',
                        style: TextStyle(
                          decoration: index == 0 
                            ? TextDecoration.lineThrough 
                            : null,
                        ),
                      ),
                      subtitle: Text('Due ${index + 1} day${index == 0 ? '' : 's'} ago'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Task details coming soon!'),
                          ),
                        );
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  )),
                  
                  // Theme selector hidden in production
                ],
              ),
            ),
          ),
          
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Voice task creation coming soon!'),
                              ),
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Quick add coming soon!'),
                              ),
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
