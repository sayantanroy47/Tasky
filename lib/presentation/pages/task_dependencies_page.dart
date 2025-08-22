import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/standardized_app_bar.dart';
import '../widgets/task_dependency_visualization.dart';
import '../widgets/theme_background_widget.dart';

/// Page for managing task dependencies
class TaskDependenciesPage extends ConsumerWidget {
  const TaskDependenciesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ThemeBackgroundWidget(
      child: Scaffold(
        appBar: const StandardizedAppBar(
          title: 'Task Dependencies',
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page header
                Text(
                  'Manage Task Dependencies',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Visualize and manage relationships between your tasks. Set up dependencies to ensure tasks are completed in the right order.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Dependency visualization
                const Expanded(
                  child: TaskDependencyVisualization(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}