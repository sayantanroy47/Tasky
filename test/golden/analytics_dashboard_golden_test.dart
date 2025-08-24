import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:task_tracker_app/core/theme/app_theme_data.dart';
import 'package:task_tracker_app/core/theme/themes/dracula_ide_theme.dart';
import 'package:task_tracker_app/core/theme/themes/matrix_theme.dart';
import 'package:task_tracker_app/core/theme/themes/vegeta_blue_theme.dart';
import 'package:task_tracker_app/core/theme/theme_factory.dart';
import 'package:task_tracker_app/presentation/widgets/glassmorphism_container.dart';

import '../mocks/mock_providers.dart';
import '../test_helpers/test_data_helper.dart';

void main() {
  group('Analytics Dashboard Golden Tests', () {
    late List<AppThemeData> allThemes;
    late Map<String, dynamic> analyticsData;

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

      // Create test analytics data
      analyticsData = TestDataHelper.createAnalyticsData();

      await loadAppFonts();
    });

    testGoldens('Analytics Dashboard - Full View - All Themes', (tester) async {
      for (final theme in allThemes) {
        final themeData = ThemeFactory.createFlutterTheme(theme);
        
        await tester.pumpWidgetBuilder(
          _AnalyticsDashboardFullView(data: analyticsData),
          wrapper: (child) => ProviderScope(
            overrides: MockProviders.analyticsProviders,
            child: MaterialApp(
              theme: themeData,
              home: Scaffold(
                backgroundColor: themeData.colorScheme.surface,
                body: SingleChildScrollView(child: child),
              ),
            ),
          ),
          surfaceSize: const Size(400, 1200),
        );

        await screenMatchesGolden(
          tester, 
          'analytics_dashboard_full_${theme.metadata.id.toLowerCase()}'
        );
      }
    });

    testGoldens('Analytics Overview Cards - Theme Variations', (tester) async {
      for (final theme in allThemes) {
        final themeData = ThemeFactory.createFlutterTheme(theme);
        
        await tester.pumpWidgetBuilder(
          _AnalyticsOverviewCards(data: analyticsData),
          wrapper: (child) => ProviderScope(
            overrides: MockProviders.analyticsProviders,
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
          surfaceSize: const Size(400, 300),
        );

        await screenMatchesGolden(
          tester, 
          'analytics_overview_cards_${theme.metadata.id.toLowerCase()}'
        );
      }
    });

    testGoldens('Productivity Chart - Theme Variations', (tester) async {
      for (final theme in allThemes) {
        final themeData = ThemeFactory.createFlutterTheme(theme);
        
        await tester.pumpWidgetBuilder(
          _ProductivityChart(data: analyticsData),
          wrapper: (child) => ProviderScope(
            overrides: MockProviders.analyticsProviders,
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
          surfaceSize: const Size(600, 400),
        );

        await screenMatchesGolden(
          tester, 
          'productivity_chart_${theme.metadata.id.toLowerCase()}'
        );
      }
    });

    testGoldens('Task Heatmap - All Themes', (tester) async {
      for (final theme in allThemes) {
        final themeData = ThemeFactory.createFlutterTheme(theme);
        
        await tester.pumpWidgetBuilder(
          _TaskHeatmapShowcase(data: analyticsData),
          wrapper: (child) => ProviderScope(
            overrides: MockProviders.analyticsProviders,
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
          surfaceSize: const Size(700, 300),
        );

        await screenMatchesGolden(
          tester, 
          'task_heatmap_${theme.metadata.id.toLowerCase()}'
        );
      }
    });

    testGoldens('Project Progress Breakdown - Theme Variations', (tester) async {
      for (final theme in allThemes) {
        final themeData = ThemeFactory.createFlutterTheme(theme);
        
        await tester.pumpWidgetBuilder(
          _ProjectProgressBreakdown(data: analyticsData),
          wrapper: (child) => ProviderScope(
            overrides: MockProviders.analyticsProviders,
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
          surfaceSize: const Size(400, 350),
        );

        await screenMatchesGolden(
          tester, 
          'project_progress_breakdown_${theme.metadata.id.toLowerCase()}'
        );
      }
    });

    testGoldens('Analytics Mobile Layout', (tester) async {
      final theme = allThemes.first;
      final themeData = ThemeFactory.createFlutterTheme(theme);
      
      await tester.pumpWidgetBuilder(
        _AnalyticsMobileLayout(data: analyticsData),
        wrapper: (child) => ProviderScope(
          overrides: MockProviders.analyticsProviders,
          child: MaterialApp(
            theme: themeData,
            home: Scaffold(
              backgroundColor: themeData.colorScheme.surface,
              body: child,
            ),
          ),
        ),
        surfaceSize: const Size(375, 800),
      );

      await screenMatchesGolden(tester, 'analytics_mobile_layout');
    });

    testGoldens('Analytics Tablet Layout', (tester) async {
      final theme = allThemes[1];
      final themeData = ThemeFactory.createFlutterTheme(theme);
      
      await tester.pumpWidgetBuilder(
        _AnalyticsTabletLayout(data: analyticsData),
        wrapper: (child) => ProviderScope(
          overrides: MockProviders.analyticsProviders,
          child: MaterialApp(
            theme: themeData,
            home: Scaffold(
              backgroundColor: themeData.colorScheme.surface,
              body: child,
            ),
          ),
        ),
        surfaceSize: const Size(768, 1024),
      );

      await screenMatchesGolden(tester, 'analytics_tablet_layout');
    });

    testGoldens('Analytics Desktop Layout', (tester) async {
      final theme = allThemes[2];
      final themeData = ThemeFactory.createFlutterTheme(theme);
      
      await tester.pumpWidgetBuilder(
        _AnalyticsDesktopLayout(data: analyticsData),
        wrapper: (child) => ProviderScope(
          overrides: MockProviders.analyticsProviders,
          child: MaterialApp(
            theme: themeData,
            home: Scaffold(
              backgroundColor: themeData.colorScheme.surface,
              body: child,
            ),
          ),
        ),
        surfaceSize: const Size(1200, 800),
      );

      await screenMatchesGolden(tester, 'analytics_desktop_layout');
    });

    testGoldens('Analytics Empty State', (tester) async {
      final theme = allThemes.first;
      final themeData = ThemeFactory.createFlutterTheme(theme);
      
      final emptyData = {
        'totalTasks': 0,
        'completedTasks': 0,
        'inProgressTasks': 0,
        'todoTasks': 0,
        'productivity': <Map<String, dynamic>>[],
        'projectProgress': <Map<String, dynamic>>[],
        'heatmapData': <Map<String, dynamic>>[],
      };
      
      await tester.pumpWidgetBuilder(
        _AnalyticsEmptyState(data: emptyData),
        wrapper: (child) => ProviderScope(
          overrides: [
            analyticsDataProvider.overrideWith((ref) async => emptyData),
          ],
          child: MaterialApp(
            theme: themeData,
            home: Scaffold(
              backgroundColor: themeData.colorScheme.surface,
              body: child,
            ),
          ),
        ),
        surfaceSize: const Size(400, 600),
      );

      await screenMatchesGolden(tester, 'analytics_empty_state');
    });

    testGoldens('Analytics Glassmorphism Effects', (tester) async {
      for (final theme in allThemes.take(3)) {
        final themeData = ThemeFactory.createFlutterTheme(theme);
        
        await tester.pumpWidgetBuilder(
          _AnalyticsGlassmorphismShowcase(data: analyticsData),
          wrapper: (child) => MaterialApp(
            theme: themeData,
            home: Scaffold(
              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      themeData.colorScheme.primary.withOpacity(0.1),
                      themeData.colorScheme.secondary.withOpacity(0.1),
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
          'analytics_glassmorphism_${theme.metadata.id.toLowerCase()}'
        );
      }
    });

    testGoldens('Analytics High Contrast Accessibility', (tester) async {
      final theme = allThemes.first;
      final baseThemeData = ThemeFactory.createFlutterTheme(theme);
      
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
        _AnalyticsAccessibilityShowcase(data: analyticsData),
        wrapper: (child) => ProviderScope(
          overrides: MockProviders.analyticsProviders,
          child: MaterialApp(
            theme: highContrastTheme,
            home: Scaffold(
              backgroundColor: highContrastTheme.colorScheme.surface,
              body: child,
            ),
          ),
        ),
        surfaceSize: const Size(400, 800),
      );

      await screenMatchesGolden(tester, 'analytics_high_contrast');
    });

    testGoldens('Analytics Large Text Accessibility', (tester) async {
      final theme = allThemes.first;
      final themeData = ThemeFactory.createFlutterTheme(theme);
      
      await tester.pumpWidgetBuilder(
        _AnalyticsAccessibilityShowcase(data: analyticsData),
        wrapper: (child) => MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(1.4),
          ),
          child: ProviderScope(
            overrides: MockProviders.analyticsProviders,
            child: MaterialApp(
              theme: themeData,
              home: Scaffold(
                backgroundColor: themeData.colorScheme.surface,
                body: SingleChildScrollView(child: child),
              ),
            ),
          ),
        ),
        surfaceSize: const Size(400, 1000),
      );

      await screenMatchesGolden(tester, 'analytics_large_text');
    });
  });
}

// Analytics showcase widgets

class _AnalyticsDashboardFullView extends StatelessWidget {
  final Map<String, dynamic> data;

  const _AnalyticsDashboardFullView({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(PhosphorIcons.chartBar()),
              const SizedBox(width: 8),
              Text(
                'Analytics Dashboard',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Spacer(),
              IconButton(
                icon: Icon(PhosphorIcons.calendarBlank()),
                onPressed: () {},
                tooltip: 'Date Range',
              ),
              IconButton(
                icon: Icon(PhosphorIcons.export()),
                onPressed: () {},
                tooltip: 'Export Data',
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Overview cards
          _AnalyticsOverviewCards(data: data),
          
          const SizedBox(height: 24),
          
          // Productivity chart
          _ProductivityChart(data: data),
          
          const SizedBox(height: 24),
          
          // Task heatmap
          _TaskHeatmapShowcase(data: data),
          
          const SizedBox(height: 24),
          
          // Project breakdown
          _ProjectProgressBreakdown(data: data),
          
          const SizedBox(height: 24),
          
          // Additional metrics
          _AdditionalMetrics(data: data),
        ],
      ),
    );
  }
}

class _AnalyticsOverviewCards extends StatelessWidget {
  final Map<String, dynamic> data;

  const _AnalyticsOverviewCards({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Total Tasks',
                '${data['totalTasks']}',
                PhosphorIcons.listChecks(),
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Completed',
                '${data['completedTasks']}',
                PhosphorIcons.checkCircle(),
                Colors.green,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'In Progress',
                '${data['inProgressTasks']}',
                PhosphorIcons.clock(),
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'To Do',
                '${data['todoTasks']}',
                PhosphorIcons.circle(),
                Colors.grey,
              ),
            ),
          ],
        ),
      ],
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
      elevation: 2,
      child: Container(
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
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductivityChart extends StatelessWidget {
  final Map<String, dynamic> data;

  const _ProductivityChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final productivity = data['productivity'] as List<Map<String, dynamic>>;
    
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(20),
        height: 320,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(PhosphorIcons.chartLine()),
                const SizedBox(width: 8),
                Text(
                  'Weekly Productivity',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(PhosphorIcons.eye()),
                  label: const Text('View Details'),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Chart area
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: productivity.map<Widget>((day) {
                  final completed = day['completed'] as int;
                  final maxCompleted = productivity
                      .map((d) => d['completed'] as int)
                      .reduce((a, b) => a > b ? a : b);
                  final height = (completed / maxCompleted) * 200;
                  
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Value label
                          Text(
                            '$completed',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const SizedBox(height: 4),
                          
                          // Bar
                          Container(
                            width: double.infinity,
                            height: height,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.primary.withOpacity(0.6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Day label
                          Text(
                            day['day'] as String,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
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
}

class _TaskHeatmapShowcase extends StatelessWidget {
  final Map<String, dynamic> data;

  const _TaskHeatmapShowcase({required this.data});

  @override
  Widget build(BuildContext context) {
    final heatmapData = data['heatmapData'] as List<Map<String, dynamic>>;
    
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(PhosphorIcons.calendar()),
                const SizedBox(width: 8),
                Text(
                  'Activity Heatmap',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(PhosphorIcons.arrowSquareOut()),
                  label: const Text('Full View'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Heatmap grid
            SizedBox(
              height: 140,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 3,
                  crossAxisSpacing: 3,
                ),
                itemCount: 49, // 7 weeks
                itemBuilder: (context, index) {
                  final intensity = (index % 5) / 4.0; // Mock intensity
                  
                  return Tooltip(
                    message: 'Day ${index + 1}: ${(intensity * 10).round()} tasks',
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(
                          intensity == 0 ? 0.1 : intensity,
                        ),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Less',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Row(
                  children: List.generate(5, (index) {
                    final intensity = index / 4.0;
                    return Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(
                          intensity == 0 ? 0.1 : intensity,
                        ),
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                    );
                  }),
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

class _ProjectProgressBreakdown extends StatelessWidget {
  final Map<String, dynamic> data;

  const _ProjectProgressBreakdown({required this.data});

  @override
  Widget build(BuildContext context) {
    final projects = data['projectProgress'] as List<Map<String, dynamic>>;
    
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(PhosphorIcons.folder()),
                const SizedBox(width: 8),
                Text(
                  'Project Progress',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(PhosphorIcons.listBullets()),
                  label: const Text('All Projects'),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Project progress items
            ...projects.map<Widget>((project) {
              final name = project['name'] as String;
              final progress = project['progress'] as double;
              final color = Color(project['color'] as int);
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            const SizedBox(width: 8),
                            Text(
                              name,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${(progress * 100).round()}%',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(color),
                      minHeight: 6,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _AdditionalMetrics extends StatelessWidget {
  final Map<String, dynamic> data;

  const _AdditionalMetrics({required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(PhosphorIcons.target(), color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'Completion Rate',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '72%',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '+5% from last week',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: Card(
            elevation: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(PhosphorIcons.timer(), color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        'Avg. Task Time',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '2.4h',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '-12min from avg',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AnalyticsMobileLayout extends StatelessWidget {
  final Map<String, dynamic> data;

  const _AnalyticsMobileLayout({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: const Text('Analytics'),
          actions: [
            IconButton(
              icon: Icon(PhosphorIcons.funnel()),
              onPressed: () {},
            ),
          ],
        ),
        
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Compact overview cards
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    _buildCompactStatCard(context, 'Total', '${data['totalTasks']}', PhosphorIcons.listChecks(), Colors.blue),
                    _buildCompactStatCard(context, 'Done', '${data['completedTasks']}', PhosphorIcons.checkCircle(), Colors.green),
                    _buildCompactStatCard(context, 'Active', '${data['inProgressTasks']}', PhosphorIcons.clock(), Colors.orange),
                    _buildCompactStatCard(context, 'Pending', '${data['todoTasks']}', PhosphorIcons.circle(), Colors.grey),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Weekly chart
                Card(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    height: 200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'This Week',
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
                              child: Icon(
                                PhosphorIcons.chartLine(),
                                size: 48,
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                              ),
                            ),
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
      ],
    );
  }

  Widget _buildCompactStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsTabletLayout extends StatelessWidget {
  final Map<String, dynamic> data;

  const _AnalyticsTabletLayout({required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Sidebar
        Container(
          width: 250,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Analytics',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              
              // Quick stats
              _buildSidebarStatCard(context, 'Total Tasks', '${data['totalTasks']}', Colors.blue),
              const SizedBox(height: 12),
              _buildSidebarStatCard(context, 'Completed', '${data['completedTasks']}', Colors.green),
              const SizedBox(height: 12),
              _buildSidebarStatCard(context, 'In Progress', '${data['inProgressTasks']}', Colors.orange),
              
              const SizedBox(height: 24),
              
              ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(PhosphorIcons.export()),
                label: const Text('Export'),
              ),
            ],
          ),
        ),
        
        // Main content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _ProductivityChart(data: data),
                const SizedBox(height: 16),
                _TaskHeatmapShowcase(data: data),
                const SizedBox(height: 16),
                _ProjectProgressBreakdown(data: data),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarStatCard(
    BuildContext context,
    String title,
    String value,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsDesktopLayout extends StatelessWidget {
  final Map<String, dynamic> data;

  const _AnalyticsDesktopLayout({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Analytics Dashboard',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {},
                icon: Icon(PhosphorIcons.calendarBlank()),
                label: const Text('Date Range'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(PhosphorIcons.export()),
                label: const Text('Export'),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Main grid
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _AnalyticsOverviewCards(data: data),
                      const SizedBox(height: 24),
                      Expanded(child: _ProductivityChart(data: data)),
                    ],
                  ),
                ),
                
                const SizedBox(width: 24),
                
                // Right column
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _TaskHeatmapShowcase(data: data),
                      const SizedBox(height: 24),
                      Expanded(child: _ProjectProgressBreakdown(data: data)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsEmptyState extends StatelessWidget {
  final Map<String, dynamic> data;

  const _AnalyticsEmptyState({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.chartBar(),
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No Analytics Data',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Complete some tasks to see your productivity insights',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(PhosphorIcons.plus()),
            label: const Text('Create Your First Task'),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsGlassmorphismShowcase extends StatelessWidget {
  final Map<String, dynamic> data;

  const _AnalyticsGlassmorphismShowcase({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Analytics with Glassmorphism',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          
          const SizedBox(height: 24),
          
          // Glassmorphism cards
          Row(
            children: [
              Expanded(
                child: GlassmorphismContainer(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          PhosphorIcons.chartLine(),
                          size: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${data['completedTasks']}',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Completed',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: GlassmorphismContainer(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          PhosphorIcons.clock(),
                          size: 32,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${data['inProgressTasks']}',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'In Progress',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Large glassmorphism chart container
          GlassmorphismContainer(
            child: Container(
              height: 200,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Productivity Trends',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
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
                          'Glassmorphism Chart Area',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
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

class _AnalyticsAccessibilityShowcase extends StatelessWidget {
  final Map<String, dynamic> data;

  const _AnalyticsAccessibilityShowcase({required this.data});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Analytics dashboard with accessibility features',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                'Accessibility Analytics',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Accessible stat cards
            Semantics(
              label: 'Overview statistics',
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      label: 'Total tasks: ${data['totalTasks']}',
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(
                                PhosphorIcons.listChecks(),
                                color: Theme.of(context).colorScheme.primary,
                                semanticLabel: 'Total tasks icon',
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${data['totalTasks']}',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text('Total Tasks'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Semantics(
                      label: 'Completed tasks: ${data['completedTasks']}',
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(
                                PhosphorIcons.checkCircle(),
                                color: Colors.green,
                                semanticLabel: 'Completed tasks icon',
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${data['completedTasks']}',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text('Completed'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Accessible chart
            Semantics(
              label: 'Weekly productivity chart showing task completion over 7 days',
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weekly Productivity',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 150,
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
                            'Chart showing productivity trends',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}