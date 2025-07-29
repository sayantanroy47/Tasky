import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/theme_selector.dart';
import '../widgets/app_scaffold.dart';

/// Tasks page for managing and viewing tasks
class TasksPage extends ConsumerWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: 'Tasks',
      actions: [
        const ThemeToggleButton(),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // TODO: Implement search functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Search functionality coming soon!')),
            );
          },
          tooltip: 'Search tasks',
        ),
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () {
            // TODO: Implement filter functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Filter functionality coming soon!')),
            );
          },
          tooltip: 'Filter tasks',
        ),
      ],
      body: const TasksPageBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to add task
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add task functionality coming soon!')),
          );
        },
        icon: const Icon(Icons.mic),
        label: const Text('Voice Task'),
        tooltip: 'Create task with voice',
      ),
    );
  }
}

/// Tasks page body content
class TasksPageBody extends ConsumerWidget {
  const TasksPageBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Task summary cards
          Row(
            children: [
              Expanded(
                child: _TaskSummaryCard(
                  title: 'Today',
                  count: 5,
                  icon: Icons.today,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TaskSummaryCard(
                  title: 'Pending',
                  count: 12,
                  icon: Icons.pending_actions,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TaskSummaryCard(
                  title: 'Completed',
                  count: 8,
                  icon: Icons.check_circle,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Task sections
          Text(
            'Recent Tasks',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          
          // Placeholder task list
          ...List.generate(5, (index) => _TaskListItem(
            title: 'Sample Task ${index + 1}',
            description: 'This is a sample task description for task ${index + 1}',
            isCompleted: index % 3 == 0,
            priority: index % 4,
            dueDate: DateTime.now().add(Duration(days: index)),
          )),
          
          const SizedBox(height: 16),
          
          // Empty state or load more
          Center(
            child: TextButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Load more functionality coming soon!')),
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Load More Tasks'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Task summary card widget
class _TaskSummaryCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const _TaskSummaryCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
    );
  }
}

/// Task list item widget
class _TaskListItem extends StatelessWidget {
  final String title;
  final String description;
  final bool isCompleted;
  final int priority;
  final DateTime dueDate;

  const _TaskListItem({
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.priority,
    required this.dueDate,
  });

  @override
  Widget build(BuildContext context) {
    final priorityColors = [
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: isCompleted,
          onChanged: (value) {
            // TODO: Implement task completion toggle
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  value == true ? 'Task completed!' : 'Task marked as pending',
                ),
              ),
            );
          },
        ),
        title: Text(
          title,
          style: TextStyle(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted 
              ? Theme.of(context).colorScheme.onSurfaceVariant 
              : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: priorityColors[priority % priorityColors.length],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ['Low', 'Medium', 'High', 'Urgent'][priority % 4],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.schedule,
                  size: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${dueDate.day}/${dueDate.month}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$value functionality coming soon!')),
            );
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'Edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'Delete',
              child: ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'Duplicate',
              child: ListTile(
                leading: Icon(Icons.copy),
                title: Text('Duplicate'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        onTap: () {
          // TODO: Navigate to task details
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task details coming soon!')),
          );
        },
      ),
    );
  }
}