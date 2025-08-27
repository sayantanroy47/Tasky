import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:task_tracker_app/core/theme/app_theme_data.dart';
import 'package:task_tracker_app/core/theme/theme_factory.dart';
import 'package:task_tracker_app/core/theme/themes/dracula_ide_theme.dart';
import 'package:task_tracker_app/core/theme/themes/matrix_theme.dart';
import 'package:task_tracker_app/core/theme/themes/vegeta_blue_theme.dart';
import 'package:task_tracker_app/domain/entities/project.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/models/enums.dart';
import 'package:task_tracker_app/presentation/widgets/glassmorphism_container.dart';
import 'package:task_tracker_app/presentation/widgets/project_card.dart';

import '../mocks/mock_providers.dart';
import '../test_helpers/test_data_helper.dart';

void main() {
  group('Project Management UI Golden Tests', () {
    late List<AppThemeData> allThemes;
    late List<Project> testProjects;
    late List<TaskModel> testTasks;

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
      testProjects = TestDataHelper.createTestProjects();
      testTasks = TestDataHelper.createTestTasks();

      // Load fonts for golden tests
      await loadAppFonts();
    });

    testGoldens('Project Cards - All Theme Variations', (tester) async {
      for (final theme in allThemes) {
        final themeData = ThemeFactory.createFlutterTheme(theme);

        await tester.pumpWidgetBuilder(
          _ProjectCardShowcase(projects: testProjects.take(3).toList()),
          wrapper: (child) => ProviderScope(
            overrides: [
              // Mock providers for project stats
              ...MockProviders.projectProviders,
            ],
            child: MaterialApp(
              theme: themeData,
              home: Scaffold(
                backgroundColor: themeData.colorScheme.surface,
                body: SingleChildScrollView(child: child),
              ),
            ),
          ),
          surfaceSize: const Size(400, 800),
        );

        await screenMatchesGolden(tester, 'project_cards_${theme.metadata.id.toLowerCase()}');
      }
    });

    testGoldens('Project Form Dialog - Theme Variations', (tester) async {
      for (final theme in allThemes) {
        final themeData = ThemeFactory.createFlutterTheme(theme);

        await tester.pumpWidgetBuilder(
          _ProjectFormShowcase(),
          wrapper: (child) => ProviderScope(
            overrides: MockProviders.projectProviders,
            child: MaterialApp(
              theme: themeData,
              home: Scaffold(
                backgroundColor: themeData.colorScheme.surface,
                body: Center(child: child),
              ),
            ),
          ),
          surfaceSize: const Size(400, 600),
        );

        await screenMatchesGolden(tester, 'project_form_${theme.metadata.id.toLowerCase()}');
      }
    });

    testGoldens('Kanban Board - Theme Variations', (tester) async {
      for (final theme in allThemes) {
        final themeData = ThemeFactory.createFlutterTheme(theme);

        await tester.pumpWidgetBuilder(
          _KanbanBoardShowcase(tasks: testTasks),
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
          surfaceSize: const Size(800, 600),
        );

        await screenMatchesGolden(tester, 'kanban_board_${theme.metadata.id.toLowerCase()}');
      }
    });

    testGoldens('Analytics Dashboard - Theme Variations', (tester) async {
      for (final theme in allThemes) {
        final themeData = ThemeFactory.createFlutterTheme(theme);

        await tester.pumpWidgetBuilder(
          _AnalyticsDashboardShowcase(),
          wrapper: (child) => ProviderScope(
            overrides: [
              ...MockProviders.analyticsProviders,
              ...MockProviders.taskProviders,
            ],
            child: MaterialApp(
              theme: themeData,
              home: Scaffold(
                backgroundColor: themeData.colorScheme.surface,
                body: SingleChildScrollView(child: child),
              ),
            ),
          ),
          surfaceSize: const Size(400, 800),
        );

        await screenMatchesGolden(tester, 'analytics_dashboard_${theme.metadata.id.toLowerCase()}');
      }
    });

    testGoldens('Task Heatmap - Theme Variations', (tester) async {
      for (final theme in allThemes) {
        final themeData = ThemeFactory.createFlutterTheme(theme);

        await tester.pumpWidgetBuilder(
          _TaskHeatmapShowcase(),
          wrapper: (child) => ProviderScope(
            overrides: MockProviders.analyticsProviders,
            child: MaterialApp(
              theme: themeData,
              home: Scaffold(
                backgroundColor: themeData.colorScheme.surface,
                body: Center(child: child),
              ),
            ),
          ),
          surfaceSize: const Size(600, 400),
        );

        await screenMatchesGolden(tester, 'task_heatmap_${theme.metadata.id.toLowerCase()}');
      }
    });

    testGoldens('Glassmorphism Effects - Theme Consistency', (tester) async {
      for (final theme in allThemes) {
        final themeData = ThemeFactory.createFlutterTheme(theme);

        await tester.pumpWidgetBuilder(
          _GlassmorphismShowcase(),
          wrapper: (child) => MaterialApp(
            theme: themeData,
            home: Scaffold(
              backgroundColor: themeData.colorScheme.surface,
              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      themeData.colorScheme.primary.withValues(alpha:0.1),
                      themeData.colorScheme.secondary.withValues(alpha:0.1),
                    ],
                  ),
                ),
                child: child,
              ),
            ),
          ),
          surfaceSize: const Size(400, 600),
        );

        await screenMatchesGolden(tester, 'glassmorphism_effects_${theme.metadata.id.toLowerCase()}');
      }
    });

    testGoldens('Phosphor Icons - Theme Consistency', (tester) async {
      for (final theme in allThemes) {
        final themeData = ThemeFactory.createFlutterTheme(theme);

        await tester.pumpWidgetBuilder(
          _PhosphorIconsShowcase(),
          wrapper: (child) => MaterialApp(
            theme: themeData,
            home: Scaffold(
              backgroundColor: themeData.colorScheme.surface,
              body: child,
            ),
          ),
          surfaceSize: const Size(400, 600),
        );

        await screenMatchesGolden(tester, 'phosphor_icons_${theme.metadata.id.toLowerCase()}');
      }
    });

    testGoldens('Responsive Design - Mobile', (tester) async {
      final theme = allThemes.first; // Test with one theme for responsiveness
      final themeData = ThemeFactory.createFlutterTheme(theme);

      await tester.pumpWidgetBuilder(
        _ResponsiveProjectShowcase(projects: testProjects.take(2).toList()),
        wrapper: (child) => ProviderScope(
          overrides: MockProviders.projectProviders,
          child: MaterialApp(
            theme: themeData,
            home: Scaffold(
              backgroundColor: themeData.colorScheme.surface,
              body: child,
            ),
          ),
        ),
        surfaceSize: const Size(320, 600), // Mobile size
      );

      await screenMatchesGolden(tester, 'responsive_mobile_320');
    });

    testGoldens('Responsive Design - Tablet', (tester) async {
      final theme = allThemes.first;
      final themeData = ThemeFactory.createFlutterTheme(theme);

      await tester.pumpWidgetBuilder(
        _ResponsiveProjectShowcase(projects: testProjects.take(4).toList()),
        wrapper: (child) => ProviderScope(
          overrides: MockProviders.projectProviders,
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

      await screenMatchesGolden(tester, 'responsive_tablet_768');
    });

    testGoldens('Responsive Design - Desktop', (tester) async {
      final theme = allThemes.first;
      final themeData = ThemeFactory.createFlutterTheme(theme);

      await tester.pumpWidgetBuilder(
        _ResponsiveProjectShowcase(projects: testProjects),
        wrapper: (child) => ProviderScope(
          overrides: MockProviders.projectProviders,
          child: MaterialApp(
            theme: themeData,
            home: Scaffold(
              backgroundColor: themeData.colorScheme.surface,
              body: child,
            ),
          ),
        ),
        surfaceSize: const Size(1200, 800), // Desktop size
      );

      await screenMatchesGolden(tester, 'responsive_desktop_1200');
    });

    testGoldens('High Contrast Accessibility', (tester) async {
      // Test high contrast version of each theme
      for (final theme in allThemes) {
        final themeData = ThemeFactory.createFlutterTheme(theme);
        final highContrastTheme = _createHighContrastTheme(themeData);

        await tester.pumpWidgetBuilder(
          _AccessibilityTestShowcase(projects: testProjects.take(2).toList()),
          wrapper: (child) => ProviderScope(
            overrides: MockProviders.projectProviders,
            child: MaterialApp(
              theme: highContrastTheme,
              home: Scaffold(
                backgroundColor: highContrastTheme.colorScheme.surface,
                body: child,
              ),
            ),
          ),
          surfaceSize: const Size(400, 600),
        );

        await screenMatchesGolden(tester, 'high_contrast_${theme.metadata.id.toLowerCase()}');
      }
    });

    testGoldens('Large Text Accessibility', (tester) async {
      final theme = allThemes.first;
      final themeData = ThemeFactory.createFlutterTheme(theme);

      await tester.pumpWidgetBuilder(
        _AccessibilityTestShowcase(projects: testProjects.take(2).toList()),
        wrapper: (child) => MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(1.5), // Large text
          ),
          child: ProviderScope(
            overrides: MockProviders.projectProviders,
            child: MaterialApp(
              theme: themeData,
              home: Scaffold(
                backgroundColor: themeData.colorScheme.surface,
                body: SingleChildScrollView(child: child),
              ),
            ),
          ),
        ),
        surfaceSize: const Size(400, 800),
      );

      await screenMatchesGolden(tester, 'large_text_accessibility');
    });
  });
}

// Showcase widgets for testing

class _ProjectCardShowcase extends StatelessWidget {
  final List<Project> projects;

  const _ProjectCardShowcase({required this.projects});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Project Cards',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          ...projects.map((project) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ProjectCard(
                  project: project,
                  onTap: () {},
                  onEdit: () {},
                  onDelete: () {},
                ),
              )),
        ],
      ),
    );
  }
}

class _ProjectFormShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      child: Container(
        width: 350,
        height: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(PhosphorIcons.folder()),
                const SizedBox(width: 8),
                Text(
                  'New Project',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Project Name',
                hintText: 'Enter project name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter project description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: ['Work', 'Personal', 'Health', 'Learning']
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (value) {},
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Create'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _KanbanBoardShowcase extends StatelessWidget {
  final List<TaskModel> tasks;

  const _KanbanBoardShowcase({required this.tasks});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKanbanColumn(context, 'To Do', tasks.where((t) => t.status == TaskStatus.pending).toList()),
          const SizedBox(width: 16),
          _buildKanbanColumn(context, 'In Progress', tasks.where((t) => t.status == TaskStatus.inProgress).toList()),
          const SizedBox(width: 16),
          _buildKanbanColumn(context, 'Done', tasks.where((t) => t.status == TaskStatus.completed).toList()),
        ],
      ),
    );
  }

  Widget _buildKanbanColumn(BuildContext context, String title, List<TaskModel> tasks) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Chip(
                  label: Text('${tasks.length}'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...tasks.take(3).map((task) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: Theme.of(context).textTheme.bodyLarge,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (task.description?.isNotEmpty == true) ...[
                          const SizedBox(height: 4),
                          Text(
                            task.description!,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              _getTaskPriorityIcon(task.priority),
                              size: 16,
                              color: _getTaskPriorityColor(context, task.priority),
                            ),
                            const Spacer(),
                            Icon(PhosphorIcons.clock(), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '2h',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  IconData _getTaskPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return PhosphorIcons.arrowDown();
      case TaskPriority.medium:
        return PhosphorIcons.equals();
      case TaskPriority.high:
        return PhosphorIcons.arrowUp();
      case TaskPriority.urgent:
        return PhosphorIcons.warning();
    }
  }

  Color _getTaskPriorityColor(BuildContext context, TaskPriority priority) {
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
}

class _AnalyticsDashboardShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics Dashboard',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          // Stats cards
          Row(
            children: [
              Expanded(child: _buildStatCard(context, 'Total Tasks', '127', PhosphorIcons.listChecks())),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard(context, 'Completed', '89', PhosphorIcons.checkCircle())),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard(context, 'In Progress', '28', PhosphorIcons.clock())),
            ],
          ),
          const SizedBox(height: 24),
          // Productivity chart placeholder
          Card(
            child: Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Productivity',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Chart Visualization',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Project breakdown
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Project Breakdown',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  _buildProgressItem(context, 'Mobile App', 0.75, Colors.blue),
                  const SizedBox(height: 8),
                  _buildProgressItem(context, 'Web Dashboard', 0.45, Colors.green),
                  const SizedBox(height: 8),
                  _buildProgressItem(context, 'API Integration', 0.20, Colors.orange),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const Spacer(),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(BuildContext context, String name, double progress, Color color) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(name, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Expanded(
          flex: 4,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(progress * 100).round()}%',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _TaskHeatmapShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(PhosphorIcons.calendar()),
                const SizedBox(width: 8),
                Text(
                  'Task Activity Heatmap',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemCount: 49, // 7 weeks
                itemBuilder: (context, index) {
                  final intensity = (index % 5) / 4; // Mock data
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha:intensity),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha:0.3),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Less',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Row(
                  children: List.generate(
                      5,
                      (index) => Container(
                            width: 12,
                            height: 12,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha:index / 4),
                              borderRadius: BorderRadius.circular(2),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline.withValues(alpha:0.3),
                              ),
                            ),
                          )),
                ),
                Text(
                  'More',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassmorphismShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Glassmorphism Effects',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          GlassmorphismContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    PhosphorIcons.sparkle(),
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Glassmorphism Card',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Testing glass effect with background blur and subtle opacity',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: GlassmorphismContainer(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(Icons.bar_chart),
                        const SizedBox(height: 8),
                        Text('Stats', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassmorphismContainer(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(PhosphorIcons.bell()),
                        const SizedBox(height: 8),
                        Text('Alerts', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PhosphorIconsShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final icons = [
      PhosphorIcons.folder(),
      PhosphorIcons.folderOpen(),
      PhosphorIcons.listChecks(),
      PhosphorIcons.kanban(),
      PhosphorIcons.chartLine(),
      PhosphorIcons.calendar(),
      PhosphorIcons.clock(),
      PhosphorIcons.bell(),
      PhosphorIcons.gear(),
      PhosphorIcons.user(),
      PhosphorIcons.plus(),
      PhosphorIcons.checkCircle(),
      PhosphorIcons.warning(),
      PhosphorIcons.info(),
      PhosphorIcons.sparkle(),
      PhosphorIcons.lightning(),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phosphor Icons',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: icons
                .map((icon) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(icon, size: 32),
                            const SizedBox(height: 8),
                            Text(
                              'Icon',
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ResponsiveProjectShowcase extends StatelessWidget {
  final List<Project> projects;

  const _ResponsiveProjectShowcase({required this.projects});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1024;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Projects - ${isDesktop ? 'Desktop' : isTablet ? 'Tablet' : 'Mobile'} Layout',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          if (isDesktop) ...[
            // Desktop: Grid layout
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: projects.length,
              itemBuilder: (context, index) => ProjectCard(
                project: projects[index],
                onTap: () {},
              ),
            ),
          ] else if (isTablet) ...[
            // Tablet: 2-column grid
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: projects.length,
              itemBuilder: (context, index) => ProjectCard(
                project: projects[index],
                onTap: () {},
              ),
            ),
          ] else ...[
            // Mobile: Single column
            ...projects.map((project) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ProjectCard(
                    project: project,
                    onTap: () {},
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

class _AccessibilityTestShowcase extends StatelessWidget {
  final List<Project> projects;

  const _AccessibilityTestShowcase({required this.projects});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Accessibility Test',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'High Contrast Elements',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Primary Button'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text('Secondary'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Text Input',
                      hintText: 'Enter text here',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...projects.take(2).map((project) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ProjectCard(
                  project: project,
                  onTap: () {},
                ),
              )),
        ],
      ),
    );
  }
}

// Helper function to create high contrast theme
ThemeData _createHighContrastTheme(ThemeData baseTheme) {
  return baseTheme.copyWith(
    colorScheme: baseTheme.colorScheme.copyWith(
      primary: Colors.black,
      onPrimary: Colors.white,
      secondary: const Color(0xFF000080),
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
      surfaceContainerHighest: const Color(0xFFF5F5F5),
      onSurfaceVariant: Colors.black,
      outline: Colors.black,
      error: Colors.red,
      onError: Colors.white,
    ),
  );
}
