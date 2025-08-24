import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

void main() {
  group('Theme Consistency Golden Tests', () {
    setUpAll(() async {
      // Skip font loading for now to avoid asset loading issues
      // await loadAppFonts();
    });

    testGoldens('Material 3 Components - Light vs Dark Comparison', (tester) async {
      await tester.pumpWidgetBuilder(
        _ComprehensiveThemeShowcase(),
        wrapper: (child) => Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              // Light theme side
              Expanded(
                child: MaterialApp(
                  theme: ThemeData.light(useMaterial3: true),
                  home: Scaffold(
                    backgroundColor: Colors.grey[50],
                    body: child,
                  ),
                ),
              ),
              
              // Dark theme side
              Expanded(
                child: MaterialApp(
                  theme: ThemeData.dark(useMaterial3: true),
                  home: Scaffold(
                    backgroundColor: Colors.grey[900],
                    body: child,
                  ),
                ),
              ),
            ],
          ),
        ),
        surfaceSize: const Size(800, 1000),
      );

      await screenMatchesGolden(tester, 'material3_light_vs_dark');
    });

    testGoldens('Project Management UI Components', (tester) async {
      for (final isDark in [false, true]) {
        await tester.pumpWidgetBuilder(
          _ProjectManagementShowcase(),
          wrapper: (child) => MaterialApp(
            theme: isDark 
                ? ThemeData.dark(useMaterial3: true)
                : ThemeData.light(useMaterial3: true),
            home: Scaffold(
              backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
              body: SingleChildScrollView(child: child),
            ),
          ),
          surfaceSize: const Size(400, 1200),
        );

        await screenMatchesGolden(
          tester, 
          'project_management_${isDark ? 'dark' : 'light'}'
        );
      }
    });

    testGoldens('Kanban Board Layout', (tester) async {
      for (final isDark in [false, true]) {
        await tester.pumpWidgetBuilder(
          _KanbanBoardShowcase(),
          wrapper: (child) => MaterialApp(
            theme: isDark 
                ? ThemeData.dark(useMaterial3: true)
                : ThemeData.light(useMaterial3: true),
            home: Scaffold(
              backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
              body: child,
            ),
          ),
          surfaceSize: const Size(900, 600),
        );

        await screenMatchesGolden(
          tester, 
          'kanban_board_${isDark ? 'dark' : 'light'}'
        );
      }
    });

    testGoldens('Analytics Dashboard Components', (tester) async {
      for (final isDark in [false, true]) {
        await tester.pumpWidgetBuilder(
          _AnalyticsDashboardShowcase(),
          wrapper: (child) => MaterialApp(
            theme: isDark 
                ? ThemeData.dark(useMaterial3: true)
                : ThemeData.light(useMaterial3: true),
            home: Scaffold(
              backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
              body: SingleChildScrollView(child: child),
            ),
          ),
          surfaceSize: const Size(400, 800),
        );

        await screenMatchesGolden(
          tester, 
          'analytics_dashboard_${isDark ? 'dark' : 'light'}'
        );
      }
    });

    testGoldens('Glassmorphism Effects', (tester) async {
      for (final isDark in [false, true]) {
        await tester.pumpWidgetBuilder(
          _GlassmorphismShowcase(),
          wrapper: (child) => MaterialApp(
            theme: isDark 
                ? ThemeData.dark(useMaterial3: true)
                : ThemeData.light(useMaterial3: true),
            home: Scaffold(
              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark ? [
                      Colors.purple.withOpacity(0.2),
                      Colors.blue.withOpacity(0.2),
                    ] : [
                      Colors.blue.withOpacity(0.1),
                      Colors.purple.withOpacity(0.1),
                    ],
                  ),
                ),
                child: child,
              ),
            ),
          ),
          surfaceSize: const Size(400, 600),
        );

        await screenMatchesGolden(
          tester, 
          'glassmorphism_${isDark ? 'dark' : 'light'}'
        );
      }
    });

    testGoldens('Phosphor Icons Grid', (tester) async {
      for (final isDark in [false, true]) {
        await tester.pumpWidgetBuilder(
          _PhosphorIconsGrid(),
          wrapper: (child) => MaterialApp(
            theme: isDark 
                ? ThemeData.dark(useMaterial3: true)
                : ThemeData.light(useMaterial3: true),
            home: Scaffold(
              backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: child,
              ),
            ),
          ),
          surfaceSize: const Size(400, 600),
        );

        await screenMatchesGolden(
          tester, 
          'phosphor_icons_${isDark ? 'dark' : 'light'}'
        );
      }
    });

    testGoldens('Form Elements Showcase', (tester) async {
      for (final isDark in [false, true]) {
        await tester.pumpWidgetBuilder(
          _FormElementsShowcase(),
          wrapper: (child) => MaterialApp(
            theme: isDark 
                ? ThemeData.dark(useMaterial3: true)
                : ThemeData.light(useMaterial3: true),
            home: Scaffold(
              backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: child,
              ),
            ),
          ),
          surfaceSize: const Size(400, 800),
        );

        await screenMatchesGolden(
          tester, 
          'form_elements_${isDark ? 'dark' : 'light'}'
        );
      }
    });

    testGoldens('Responsive Layout - Mobile vs Tablet vs Desktop', (tester) async {
      final breakpoints = [
        {'name': 'mobile', 'width': 375.0, 'height': 667.0},
        {'name': 'tablet', 'width': 768.0, 'height': 1024.0},
        {'name': 'desktop', 'width': 1200.0, 'height': 800.0},
      ];

      for (final breakpoint in breakpoints) {
        await tester.pumpWidgetBuilder(
          _ResponsiveLayoutShowcase(screenWidth: breakpoint['width'] as double),
          wrapper: (child) => MaterialApp(
            theme: ThemeData.light(useMaterial3: true),
            home: Scaffold(
              backgroundColor: Colors.grey[50],
              body: child,
            ),
          ),
          surfaceSize: Size(breakpoint['width'] as double, breakpoint['height'] as double),
        );

        await screenMatchesGolden(
          tester, 
          'responsive_${breakpoint['name']}'
        );
      }
    });

    testGoldens('High Contrast Accessibility', (tester) async {
      final highContrastTheme = ThemeData.light(useMaterial3: true).copyWith(
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
          onPrimary: Colors.white,
          secondary: Color(0xFF000080),
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
          surfaceContainerHighest: Color(0xFFF5F5F5),
          onSurfaceVariant: Colors.black,
          outline: Colors.black,
          error: Colors.red,
          onError: Colors.white,
        ),
      );

      await tester.pumpWidgetBuilder(
        _AccessibilityShowcase(),
        wrapper: (child) => MaterialApp(
          theme: highContrastTheme,
          home: Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ),
        surfaceSize: const Size(400, 700),
      );

      await screenMatchesGolden(tester, 'accessibility_high_contrast');
    });

    testGoldens('Large Text Accessibility', (tester) async {
      await tester.pumpWidgetBuilder(
        _AccessibilityShowcase(),
        wrapper: (child) => MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(1.4),
          ),
          child: MaterialApp(
            theme: ThemeData.light(useMaterial3: true),
            home: Scaffold(
              backgroundColor: Colors.grey[50],
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: child,
              ),
            ),
          ),
        ),
        surfaceSize: const Size(400, 900),
      );

      await screenMatchesGolden(tester, 'accessibility_large_text');
    });
  });
}

class _ComprehensiveThemeShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Material 3 Components',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          
          // Buttons
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Buttons', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton(onPressed: () {}, child: const Text('Elevated')),
                      FilledButton(onPressed: () {}, child: const Text('Filled')),
                      OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
                      TextButton(onPressed: () {}, child: const Text('Text')),
                      IconButton(onPressed: () {}, icon: Icon(PhosphorIcons.heart())),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Cards
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cards', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('Standard Card'),
                    ),
                  ),
                  const Card.filled(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('Filled Card'),
                    ),
                  ),
                  const Card.outlined(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('Outlined Card'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Form elements
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Form Elements', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Sample Input',
                      hintText: 'Enter text here',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(value: true, onChanged: (value) {}),
                      const Text('Checkbox'),
                      const SizedBox(width: 16),
                      Switch(value: true, onChanged: (value) {}),
                      const Text('Switch'),
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

class _ProjectManagementShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Project Management UI',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          
          // Project cards
          _buildProjectCard(
            context,
            'Mobile App Development',
            'Flutter task management app with advanced features',
            Colors.blue,
            0.75,
          ),
          const SizedBox(height: 12),
          _buildProjectCard(
            context,
            'Web Dashboard',
            'Analytics dashboard for project management',
            Colors.green,
            0.45,
          ),
          const SizedBox(height: 12),
          _buildProjectCard(
            context,
            'API Integration',
            'RESTful API endpoints and documentation',
            Colors.orange,
            0.20,
          ),
          
          const SizedBox(height: 24),
          
          // Project creation form
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(PhosphorIcons.folder()),
                      const SizedBox(width: 8),
                      Text(
                        'Create New Project',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Project Name',
                      hintText: 'Enter project name',
                      border: const OutlineInputBorder(),
                      prefixIcon: Icon(PhosphorIcons.textAa()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter project description',
                      border: const OutlineInputBorder(),
                      prefixIcon: Icon(PhosphorIcons.note()),
                    ),
                  ),
                  const SizedBox(height: 20),
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
                        child: const Text('Create Project'),
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

  Widget _buildProjectCard(
    BuildContext context,
    String title,
    String description,
    Color color,
    double progress,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(PhosphorIcons.dotsThreeVertical()),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ],
        ),
      ),
    );
  }
}

class _KanbanBoardShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIcons.kanban()),
              const SizedBox(width: 8),
              Text(
                'Kanban Board',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
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
          const SizedBox(height: 16),
          
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildKanbanColumn(context, 'To Do', Colors.blue, [
                  'Design UI mockups',
                  'Set up authentication',
                  'API documentation',
                ]),
                const SizedBox(width: 16),
                _buildKanbanColumn(context, 'In Progress', Colors.orange, [
                  'Dashboard components',
                  'Database schema',
                ]),
                const SizedBox(width: 16),
                _buildKanbanColumn(context, 'Done', Colors.green, [
                  'Project structure',
                  'Package research',
                  'Initial setup',
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKanbanColumn(
    BuildContext context,
    String title,
    Color color,
    List<String> tasks,
  ) {
    return Expanded(
      child: Container(
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
                      color: color,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${tasks.length}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: color,
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
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          tasks[index],
                          style: Theme.of(context).textTheme.bodyMedium,
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
    );
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
          Row(
            children: [
              Icon(PhosphorIcons.chartBar()),
              const SizedBox(width: 8),
              Text(
                'Analytics Dashboard',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Overview cards
          Row(
            children: [
              Expanded(child: _buildStatCard(context, 'Total Tasks', '127', PhosphorIcons.listChecks(), Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard(context, 'Completed', '89', PhosphorIcons.checkCircle(), Colors.green)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard(context, 'In Progress', '28', PhosphorIcons.clock(), Colors.orange)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard(context, 'Pending', '10', PhosphorIcons.circle(), Colors.grey)),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Chart placeholder
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
                            Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Chart Visualization Area',
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
          
          // Progress breakdown
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Project Progress',
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

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
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

  Widget _buildProgressItem(
    BuildContext context,
    String name,
    double progress,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: Theme.of(context).textTheme.bodyMedium),
            Text(
              '${(progress * 100).round()}%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation(color),
        ),
      ],
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
          
          // Main glassmorphism card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  PhosphorIcons.sparkle(),
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Glassmorphism Container',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Beautiful glass-like effect with subtle transparency',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Grid of smaller glass containers
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildGlassCard(context, PhosphorIcons.chartBar(), 'Analytics', '127 tasks'),
              _buildGlassCard(context, PhosphorIcons.bell(), 'Notifications', '5 new'),
              _buildGlassCard(context, PhosphorIcons.clock(), 'Time', '4.5 hours'),
              _buildGlassCard(context, PhosphorIcons.target(), 'Goals', '8/10 reached'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _PhosphorIconsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final icons = [
      {'icon': PhosphorIcons.folder(), 'label': 'Folder'},
      {'icon': PhosphorIcons.kanban(), 'label': 'Kanban'},
      {'icon': PhosphorIcons.chartBar(), 'label': 'Chart'},
      {'icon': PhosphorIcons.bell(), 'label': 'Bell'},
      {'icon': PhosphorIcons.gear(), 'label': 'Settings'},
      {'icon': PhosphorIcons.user(), 'label': 'User'},
      {'icon': PhosphorIcons.calendar(), 'label': 'Calendar'},
      {'icon': PhosphorIcons.clock(), 'label': 'Clock'},
      {'icon': PhosphorIcons.plus(), 'label': 'Plus'},
      {'icon': PhosphorIcons.magnifyingGlass(), 'label': 'Search'},
      {'icon': PhosphorIcons.heart(), 'label': 'Heart'},
      {'icon': PhosphorIcons.star(), 'label': 'Star'},
    ];

    return Column(
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
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: icons.map((iconInfo) => Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(iconInfo['icon'] as IconData, size: 28),
                  const SizedBox(height: 4),
                  Text(
                    iconInfo['label'] as String,
                    style: Theme.of(context).textTheme.labelSmall,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }
}

class _FormElementsShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Form Elements',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Project Name',
            hintText: 'Enter project name',
            border: const OutlineInputBorder(),
            prefixIcon: Icon(PhosphorIcons.textAa()),
          ),
        ),
        const SizedBox(height: 16),
        
        TextFormField(
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Description',
            hintText: 'Enter description',
            border: const OutlineInputBorder(),
            prefixIcon: Icon(PhosphorIcons.note()),
          ),
        ),
        const SizedBox(height: 16),
        
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Category',
            border: const OutlineInputBorder(),
            prefixIcon: Icon(PhosphorIcons.hash()),
          ),
          items: ['Work', 'Personal', 'Learning', 'Health']
              .map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  ))
              .toList(),
          onChanged: (value) {},
        ),
        
        const SizedBox(height: 24),
        
        Row(
          children: [
            Checkbox(value: true, onChanged: (value) {}),
            const Text('Enable notifications'),
            const SizedBox(width: 24),
            Switch(value: false, onChanged: (value) {}),
            const Text('Dark mode'),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Text('Priority Level', style: Theme.of(context).textTheme.titleMedium),
        Slider(
          value: 0.6,
          onChanged: (value) {},
          divisions: 4,
          label: 'Medium',
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
              child: const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ResponsiveLayoutShowcase extends StatelessWidget {
  final double screenWidth;

  const _ResponsiveLayoutShowcase({required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final isDesktop = screenWidth >= 1200;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Responsive Layout - ${isMobile ? 'Mobile' : isTablet ? 'Tablet' : 'Desktop'}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          
          if (isMobile) ...[
            // Mobile: Single column
            _buildProjectCard(context, 'Project Alpha', 0.75),
            const SizedBox(height: 8),
            _buildProjectCard(context, 'Project Beta', 0.45),
            const SizedBox(height: 8),
            _buildProjectCard(context, 'Project Gamma', 0.20),
          ] else if (isTablet) ...[
            // Tablet: Two columns
            Row(
              children: [
                Expanded(child: _buildProjectCard(context, 'Project Alpha', 0.75)),
                const SizedBox(width: 12),
                Expanded(child: _buildProjectCard(context, 'Project Beta', 0.45)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildProjectCard(context, 'Project Gamma', 0.20)),
                const SizedBox(width: 12),
                Expanded(child: _buildProjectCard(context, 'Project Delta', 0.90)),
              ],
            ),
          ] else ...[
            // Desktop: Three columns
            Row(
              children: [
                Expanded(child: _buildProjectCard(context, 'Project Alpha', 0.75)),
                const SizedBox(width: 12),
                Expanded(child: _buildProjectCard(context, 'Project Beta', 0.45)),
                const SizedBox(width: 12),
                Expanded(child: _buildProjectCard(context, 'Project Gamma', 0.20)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, String title, double progress) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('${(progress * 100).round()}% Complete'),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress),
          ],
        ),
      ),
    );
  }
}

class _AccessibilityShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accessibility Features',
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
                      child: const Text('Primary Action'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () {},
                      child: const Text('Secondary'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Accessible Input',
                    hintText: 'High contrast text field',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Touch Targets',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(PhosphorIcons.plus()),
                      tooltip: 'Add item',
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(PhosphorIcons.pencil()),
                      tooltip: 'Edit item',
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(PhosphorIcons.trash()),
                      tooltip: 'Delete item',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}