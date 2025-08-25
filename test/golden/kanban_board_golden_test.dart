import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:task_tracker_app/core/theme/app_theme_data.dart';
import 'package:task_tracker_app/domain/models/enums.dart';
import 'package:task_tracker_app/core/theme/themes/dracula_ide_theme.dart';
import 'package:task_tracker_app/core/theme/themes/matrix_theme.dart';
import 'package:task_tracker_app/core/theme/themes/vegeta_blue_theme.dart';
import 'package:task_tracker_app/core/theme/theme_factory.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';

import '../mocks/mock_providers.dart';
import '../test_helpers/test_data_helper.dart';

void main() {
  group('Kanban Board Golden Tests', () {
    late List<AppThemeData> allThemes;
    late List<TaskModel> testTasks;
    late List<KanbanColumnConfig> columnConfigs;

    setUpAll(() async {
      // Initialize themes
      allThemes = [
        DraculaIDETheme.create(isDark: true),
        DraculaIDETheme.create(isDark: false),
        MatrixTheme.create(isDark: true),
        MatrixTheme.create(isDark: false),
        VegetaBlueTheme.create(isDark: true),
        VegetaBlueTheme.create(isDark: false),
      ];

      // Create test data
      testTasks = TestDataHelper.createTestTasks();
      
      // Create column configurations
      columnConfigs = [
        KanbanColumnConfig(
          id: 'todo',
          title: 'To Do',
          status: TaskStatus.pending,
          color: Colors.blue,
          maxTasks: 10,
        ),
        KanbanColumnConfig(
          id: 'in_progress',
          title: 'In Progress',
          status: TaskStatus.inProgress,
          color: Colors.orange,
          maxTasks: 5,
        ),
        KanbanColumnConfig(
          id: 'review',
          title: 'Review',
          status: TaskStatus.inProgress,
          color: Colors.purple,
          maxTasks: 3,
        ),
        KanbanColumnConfig(
          id: 'done',
          title: 'Done',
          status: TaskStatus.completed,
          color: Colors.green,
          maxTasks: 100,
        ),
      ];

      await loadAppFonts();
    });

    testGoldens('Kanban Board - Full View - All Themes', (tester) async {
      for (final theme in allThemes) {
        final themeData = ThemeFactory.createFlutterTheme(theme);
        
        await tester.pumpWidgetBuilder(
          _KanbanBoardFullView(
            tasks: testTasks,
            columns: columnConfigs,
          ),
          wrapper: (child) => ProviderScope(
            overrides: [
              ...MockProviders.taskProviders,
              ...MockProviders.projectProviders,
            ],
            child: MaterialApp(
              theme: themeData,
              home: Scaffold(
                backgroundColor: themeData.colorScheme.surface,
                body: child,
              ),
            ),
          ),
          surfaceSize: const Size(1000, 700),
        );

        await screenMatchesGolden(
          tester, 
          'kanban_full_${theme.metadata.id.toLowerCase()}'
        );
      }
    });

    testGoldens('Kanban Board - Mobile View', (tester) async {
      final theme = allThemes.first; // Test responsive with one theme
      final themeData = ThemeFactory.createFlutterTheme(theme);
      
      await tester.pumpWidgetBuilder(
        _KanbanBoardMobileView(
          tasks: testTasks.take(6).toList(),
          columns: columnConfigs.take(2).toList(), // Only show 2 columns on mobile
        ),
        wrapper: (child) => ProviderScope(
          overrides: MockProviders.taskProviders,
          child: MaterialApp(
            theme: themeData,
            home: Scaffold(
              backgroundColor: themeData.colorScheme.surface,
              body: child,
            ),
          ),
        ),
        surfaceSize: const Size(375, 800), // Mobile size
      );

      await screenMatchesGolden(tester, 'kanban_mobile_responsive');
    });

    testGoldens('Kanban Board - Tablet View', (tester) async {
      final theme = allThemes[1]; // Test with different theme
      final themeData = ThemeFactory.createFlutterTheme(theme);
      
      await tester.pumpWidgetBuilder(
        _KanbanBoardTabletView(
          tasks: testTasks,
          columns: columnConfigs.take(3).toList(), // Show 3 columns on tablet
        ),
        wrapper: (child) => ProviderScope(
          overrides: MockProviders.taskProviders,
          child: MaterialApp(
            theme: themeData,
            home: Scaffold(
              backgroundColor: themeData.colorScheme.surface,
              body: child,
            ),
          ),
        ),
        surfaceSize: const Size(768, 1024), // Tablet size
      );

      await screenMatchesGolden(tester, 'kanban_tablet_responsive');
    });

    testGoldens('Kanban Column - Individual Columns', (tester) async {
      for (final theme in allThemes.take(3)) { // Test with 3 themes for variety
        final themeData = ThemeFactory.createFlutterTheme(theme);
        
        for (final config in columnConfigs) {
          final columnTasks = testTasks
              .where((task) => task.status == config.status)
              .take(4)
              .toList();
              
          await tester.pumpWidgetBuilder(
            _KanbanColumnShowcase(
              config: config,
              tasks: columnTasks,
            ),
            wrapper: (child) => ProviderScope(
              overrides: MockProviders.taskProviders,
              child: MaterialApp(
                theme: themeData,
                home: Scaffold(
                  backgroundColor: themeData.colorScheme.surface,
                  body: Padding(
                    padding: const EdgeInsets.all(16),
                    child: child,
                  ),
                ),
              ),
            ),
            surfaceSize: const Size(320, 600),
          );

          await screenMatchesGolden(
            tester, 
            'kanban_column_${config.id}_${theme.metadata.id.toLowerCase()}'
          );
        }
      }
    });

    testGoldens('Kanban Board - Empty States', (tester) async {
      final theme = allThemes.first;
      final themeData = ThemeFactory.createFlutterTheme(theme);
      
      await tester.pumpWidgetBuilder(
        _KanbanBoardEmptyState(columns: columnConfigs),
        wrapper: (child) => ProviderScope(
          overrides: [
            tasksProvider.overrideWith((ref) async => []), // Empty tasks
          ],
          child: MaterialApp(
            theme: themeData,
            home: Scaffold(
              backgroundColor: themeData.colorScheme.surface,
              body: child,
            ),
          ),
        ),
        surfaceSize: const Size(800, 600),
      );

      await screenMatchesGolden(tester, 'kanban_empty_state');
    });

    testGoldens('Kanban Board - Drag and Drop States', (tester) async {
      final theme = allThemes[2]; // Matrix theme for visual contrast
      final themeData = ThemeFactory.createFlutterTheme(theme);
      
      await tester.pumpWidgetBuilder(
        _KanbanDragDropShowcase(
          tasks: testTasks.take(8).toList(),
          columns: columnConfigs,
        ),
        wrapper: (child) => ProviderScope(
          overrides: MockProviders.taskProviders,
          child: MaterialApp(
            theme: themeData,
            home: Scaffold(
              backgroundColor: themeData.colorScheme.surface,
              body: child,
            ),
          ),
        ),
        surfaceSize: const Size(900, 600),
      );

      await screenMatchesGolden(tester, 'kanban_drag_drop_states');
    });

    testGoldens('Kanban Task Cards - TaskPriority Variations', (tester) async {
      final theme = allThemes[1];
      final themeData = ThemeFactory.createFlutterTheme(theme);
      
      // Create tasks with different priorities
      final priorityTasks = TaskPriority.values.map((priority) => TaskModel(
        id: 'priority_${priority.name}',
        title: '${priority.name.toUpperCase()} TaskPriority Task',
        description: 'This is a ${priority.name} priority task for testing visual hierarchy',
        priority: priority,
        projectId: 'test_project',
        dueDate: DateTime.now().add(Duration(days: TaskPriority.values.indexOf(priority) + 1)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: ['priority', priority.name],
        estimatedDuration: (2 + TaskPriority.values.indexOf(priority)) * 60, // Convert hours to minutes
        dependencies: const [],
        subTasks: const [],
        metadata: const {},
      )).toList();

      await tester.pumpWidgetBuilder(
        _KanbanTaskPriorityShowcase(tasks: priorityTasks),
        wrapper: (child) => ProviderScope(
          overrides: MockProviders.taskProviders,
          child: MaterialApp(
            theme: themeData,
            home: Scaffold(
              backgroundColor: themeData.colorScheme.surface,
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: child,
              ),
            ),
          ),
        ),
        surfaceSize: const Size(400, 800),
      );

      await screenMatchesGolden(tester, 'kanban_task_priorities');
    });

    testGoldens('Kanban Board - Accessibility High Contrast', (tester) async {
      final theme = allThemes.first;
      final baseThemeData = ThemeFactory.createFlutterTheme(theme);
      
      // Create high contrast theme
      final highContrastTheme = baseThemeData.copyWith(
        colorScheme: baseThemeData.colorScheme.copyWith(
          primary: Colors.black,
          onPrimary: Colors.white,
          secondary: const Color(0xFF000080),
          surface: Colors.white,
          onSurface: Colors.black,
          outline: Colors.black,
        ),
      );
      
      await tester.pumpWidgetBuilder(
        _KanbanBoardAccessibilityView(
          tasks: testTasks.take(9).toList(),
          columns: columnConfigs,
        ),
        wrapper: (child) => ProviderScope(
          overrides: MockProviders.taskProviders,
          child: MaterialApp(
            theme: highContrastTheme,
            home: Scaffold(
              backgroundColor: highContrastTheme.colorScheme.surface,
              body: child,
            ),
          ),
        ),
        surfaceSize: const Size(800, 600),
      );

      await screenMatchesGolden(tester, 'kanban_high_contrast');
    });

    testGoldens('Kanban Board - Large Text Accessibility', (tester) async {
      final theme = allThemes.first;
      final themeData = ThemeFactory.createFlutterTheme(theme);
      
      await tester.pumpWidgetBuilder(
        _KanbanBoardAccessibilityView(
          tasks: testTasks.take(6).toList(),
          columns: columnConfigs.take(3).toList(),
        ),
        wrapper: (child) => MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(1.4), // Large text
          ),
          child: ProviderScope(
            overrides: MockProviders.taskProviders,
            child: MaterialApp(
              theme: themeData,
              home: Scaffold(
                backgroundColor: themeData.colorScheme.surface,
                body: SingleChildScrollView(child: child),
              ),
            ),
          ),
        ),
        surfaceSize: const Size(800, 800),
      );

      await screenMatchesGolden(tester, 'kanban_large_text');
    });
  });
}

// Showcase widgets for Kanban board testing

class _KanbanBoardFullView extends StatelessWidget {
  final List<TaskModel> tasks;
  final List<KanbanColumnConfig> columns;

  const _KanbanBoardFullView({
    required this.tasks,
    required this.columns,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(PhosphorIcons.kanban()),
              const SizedBox(width: 8),
              Text(
                'Project Kanban Board',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              IconButton(
                icon: Icon(PhosphorIcons.funnel()),
                onPressed: () {},
                tooltip: 'Filter tasks',
              ),
              IconButton(
                icon: Icon(PhosphorIcons.plus()),
                onPressed: () {},
                tooltip: 'Add task',
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Kanban board
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: columns.map((config) {
                final columnTasks = tasks
                    .where((task) => task.status == config.status)
                    .toList();
                    
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildKanbanColumn(context, config, columnTasks),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKanbanColumn(
    BuildContext context,
    KanbanColumnConfig config,
    List<TaskModel> tasks,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column header
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: config.color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  config.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: config.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${tasks.length}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: config.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Tasks
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildTaskCard(context, tasks[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, TaskModel task) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task title
            Text(
              task.title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            if (task.description?.isNotEmpty == true) ...[
              const SizedBox(height: 4),
              Text(
                task.description!,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            
            const SizedBox(height: 8),
            
            // Task metadata
            Row(
              children: [
                // TaskPriority indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getTaskPriorityColor(task.priority).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getTaskPriorityIcon(task.priority),
                        size: 12,
                        color: _getTaskPriorityColor(task.priority),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        task.priority.name.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: _getTaskPriorityColor(task.priority),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Due date
                if (task.dueDate != null) ...[
                  Icon(
                    PhosphorIcons.clock(),
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${task.dueDate!.day}/${task.dueDate!.month}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ],
            ),
            
            // Tags
            if (task.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: task.tags.take(2).map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tag,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getTaskPriorityColor(TaskPriority priority) {
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

  IconData _getTaskPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return PhosphorIcons.arrowDown();
      case TaskPriority.medium:
        return PhosphorIcons.minus();
      case TaskPriority.high:
        return PhosphorIcons.arrowUp();
      case TaskPriority.urgent:
        return PhosphorIcons.warning();
    }
  }
}

class _KanbanBoardMobileView extends StatelessWidget {
  final List<TaskModel> tasks;
  final List<KanbanColumnConfig> columns;

  const _KanbanBoardMobileView({
    required this.tasks,
    required this.columns,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Mobile header
        AppBar(
          title: const Text('Kanban'),
          actions: [
            IconButton(
              icon: Icon(PhosphorIcons.funnel()),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(PhosphorIcons.plus()),
              onPressed: () {},
            ),
          ],
        ),
        
        // Column selector
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: columns.length,
            itemBuilder: (context, index) {
              final config = columns[index];
              final isSelected = index == 0; // Mock selection
              
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: FilterChip(
                  label: Text('${config.title} (${tasks.where((t) => t.status == config.status).length})'),
                  selected: isSelected,
                  onSelected: (selected) {},
                  avatar: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: config.color,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        // Tasks for selected column
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.where((t) => t.status == columns.first.status).length,
            itemBuilder: (context, index) {
              final columnTasks = tasks.where((t) => t.status == columns.first.status).toList();
              final task = columnTasks[index];
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: ListTile(
                    title: Text(task.title),
                    subtitle: task.description != null ? Text(task.description!) : null,
                    trailing: Icon(_getTaskPriorityIcon(task.priority)),
                    onTap: () {},
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getTaskPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return PhosphorIcons.arrowDown();
      case TaskPriority.medium:
        return PhosphorIcons.minus();
      case TaskPriority.high:
        return PhosphorIcons.arrowUp();
      case TaskPriority.urgent:
        return PhosphorIcons.warning();
    }
  }
}

class _KanbanBoardTabletView extends StatelessWidget {
  final List<TaskModel> tasks;
  final List<KanbanColumnConfig> columns;

  const _KanbanBoardTabletView({
    required this.tasks,
    required this.columns,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Sidebar with controls
        Container(
          width: 200,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kanban Board',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              
              // Quick stats
              ...columns.map((config) {
                final count = tasks.where((t) => t.status == config.status).length;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: config.color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(config.title),
                      const Spacer(),
                      Text('$count'),
                    ],
                  ),
                );
              }),
              
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(PhosphorIcons.plus()),
                label: const Text('Add Task'),
              ),
            ],
          ),
        ),
        
        // Main kanban area
        Expanded(
          child: _KanbanBoardFullView(tasks: tasks, columns: columns),
        ),
      ],
    );
  }
}

class _KanbanColumnShowcase extends StatelessWidget {
  final KanbanColumnConfig config;
  final List<TaskModel> tasks;

  const _KanbanColumnShowcase({
    required this.config,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Column: ${config.title}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                // Column header
                Container(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: config.color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        config.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: config.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${tasks.length}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: config.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Tasks
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          elevation: 1,
                          child: ListTile(
                            dense: true,
                            title: Text(
                              tasks[index].title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: tasks[index].description != null
                                ? Text(
                                    tasks[index].description!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : null,
                            trailing: Icon(
                              _getTaskPriorityIcon(tasks[index].priority),
                              size: 16,
                              color: _getTaskPriorityColor(tasks[index].priority),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getTaskPriorityColor(TaskPriority priority) {
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

  IconData _getTaskPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return PhosphorIcons.arrowDown();
      case TaskPriority.medium:
        return PhosphorIcons.minus();
      case TaskPriority.high:
        return PhosphorIcons.arrowUp();
      case TaskPriority.urgent:
        return PhosphorIcons.warning();
    }
  }
}

class _KanbanBoardEmptyState extends StatelessWidget {
  final List<KanbanColumnConfig> columns;

  const _KanbanBoardEmptyState({required this.columns});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Kanban Board',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: columns.map((config) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Column header
                        Container(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: config.color,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                config.title,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: config.color.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '0',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: config.color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Empty state
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  PhosphorIcons.plus(),
                                  size: 48,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No tasks',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _KanbanDragDropShowcase extends StatelessWidget {
  final List<TaskModel> tasks;
  final List<KanbanColumnConfig> columns;

  const _KanbanDragDropShowcase({
    required this.tasks,
    required this.columns,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Drag & Drop States',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: columns.map((config) {
                final columnTasks = tasks
                    .where((task) => task.status == config.status)
                    .toList();
                    
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildDragDropColumn(context, config, columnTasks),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragDropColumn(
    BuildContext context,
    KanbanColumnConfig config,
    List<TaskModel> tasks,
  ) {
    final isDragTarget = config.id == 'in_progress'; // Mock drag target state
    
    return Container(
      decoration: BoxDecoration(
        color: isDragTarget 
            ? config.color.withOpacity(0.1)
            : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDragTarget 
              ? config.color
              : Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: isDragTarget ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Column header with drag indicator
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: config.color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  config.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDragTarget ? config.color : null,
                  ),
                ),
                const Spacer(),
                if (isDragTarget) Icon(PhosphorIcons.arrowDown(), color: config.color),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: config.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${tasks.length}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: config.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Tasks with drag states
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final isDragging = index == 0 && config.id == 'todo'; // Mock dragging state
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Opacity(
                    opacity: isDragging ? 0.5 : 1.0,
                    child: Transform.rotate(
                      angle: isDragging ? 0.05 : 0,
                      child: Card(
                        elevation: isDragging ? 8 : 2,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (isDragging) Icon(PhosphorIcons.dotsSixVertical(), size: 16),
                                  if (isDragging) const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      tasks[index].title,
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              if (tasks[index].description?.isNotEmpty == true) ...[
                                const SizedBox(height: 4),
                                Text(
                                  tasks[index].description!,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _KanbanTaskPriorityShowcase extends StatelessWidget {
  final List<TaskModel> tasks;

  const _KanbanTaskPriorityShowcase({required this.tasks});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Task TaskPriority Variations',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        
        ...tasks.map((task) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Card(
            elevation: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TaskPriority header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getTaskPriorityColor(task.priority).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getTaskPriorityIcon(task.priority),
                              size: 16,
                              color: _getTaskPriorityColor(task.priority),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              task.priority.name.toUpperCase(),
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: _getTaskPriorityColor(task.priority),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${task.estimatedDuration != null ? (task.estimatedDuration! / 60).round() : 0}h',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Task content
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 6),
                  
                  Text(
                    task.description ?? 'No description',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Tags and metadata
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: task.tags.map((tag) => Chip(
                      label: Text(tag),
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ),
        )),
      ],
    );
  }

  Color _getTaskPriorityColor(TaskPriority priority) {
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

  IconData _getTaskPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return PhosphorIcons.arrowDown();
      case TaskPriority.medium:
        return PhosphorIcons.minus();
      case TaskPriority.high:
        return PhosphorIcons.arrowUp();
      case TaskPriority.urgent:
        return PhosphorIcons.warning();
    }
  }
}

class _KanbanBoardAccessibilityView extends StatelessWidget {
  final List<TaskModel> tasks;
  final List<KanbanColumnConfig> columns;

  const _KanbanBoardAccessibilityView({
    required this.tasks,
    required this.columns,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Kanban board with ${columns.length} columns',
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                'Project Kanban Board',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: columns.map((config) {
                  final columnTasks = tasks
                      .where((task) => task.status == config.status)
                      .toList();
                      
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Semantics(
                        label: '${config.title} column with ${columnTasks.length} tasks',
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            children: [
                              // Accessible header
                              Semantics(
                                label: '${config.title} column header',
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: config.color,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        config.title,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Spacer(),
                                      Semantics(
                                        label: '${columnTasks.length} tasks in this column',
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: config.color.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '${columnTasks.length}',
                                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                              color: config.color,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              // Accessible task list
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  itemCount: columnTasks.length,
                                  itemBuilder: (context, index) {
                                    final task = columnTasks[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Semantics(
                                        label: 'Task: ${task.title}. TaskPriority: ${task.priority.name}. ${task.description ?? "No description"}',
                                        button: true,
                                        child: Card(
                                          elevation: 2,
                                          child: ListTile(
                                            title: Text(task.title),
                                            subtitle: task.description != null ? Text(task.description!) : null,
                                            trailing: Semantics(
                                              label: '${task.priority.name} priority',
                                              child: Icon(
                                                _getTaskPriorityIcon(task.priority),
                                                color: _getTaskPriorityColor(task.priority),
                                              ),
                                            ),
                                            onTap: () {},
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTaskPriorityColor(TaskPriority priority) {
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

  IconData _getTaskPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return PhosphorIcons.arrowDown();
      case TaskPriority.medium:
        return PhosphorIcons.minus();
      case TaskPriority.high:
        return PhosphorIcons.arrowUp();
      case TaskPriority.urgent:
        return PhosphorIcons.warning();
    }
  }
}

// Mock Kanban column configuration
class KanbanColumnConfig {
  final String id;
  final String title;
  final TaskStatus status;
  final Color color;
  final int? maxTasks;
  final bool isCollapsed;

  KanbanColumnConfig({
    required this.id,
    required this.title,
    required this.status,
    required this.color,
    this.maxTasks,
    this.isCollapsed = false,
  });
}