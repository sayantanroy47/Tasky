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
import 'package:task_tracker_app/presentation/widgets/project_card.dart';

import '../mocks/mock_providers.dart';
import '../test_helpers/test_data_helper.dart';

void main() {
  group('Comprehensive Theme Golden Tests', () {
    late List<AppThemeData> allThemes;

    setUpAll(() async {
      // Initialize all themes
      allThemes = [
        DraculaIDETheme.create(isDark: true),
        DraculaIDETheme.create(isDark: false),
        MatrixTheme.create(isDark: true),
        MatrixTheme.create(isDark: false),
        VegetaBlueTheme.create(isDark: true),
        VegetaBlueTheme.create(isDark: false),
      ];

      await loadAppFonts();
    });

    testGoldens('Material 3 Components - All Themes', (tester) async {
      for (final theme in allThemes) {
        final themeData = ThemeFactory.createFlutterTheme(theme);
        
        await tester.pumpWidgetBuilder(
          _Material3ComponentShowcase(),
          wrapper: (child) => MaterialApp(
            theme: themeData,
            home: Scaffold(
              backgroundColor: themeData.colorScheme.surface,
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: child,
              ),
            ),
          ),
          surfaceSize: const Size(400, 1000),
        );

        await screenMatchesGolden(
          tester, 
          'material3_components_${theme.metadata.id.toLowerCase()}'
        );
      }
    });

    testGoldens('Glassmorphism Effects - All Themes', (tester) async {
      for (final theme in allThemes) {
        final themeData = ThemeFactory.createFlutterTheme(theme);
        
        await tester.pumpWidgetBuilder(
          _GlassmorphismEffectShowcase(),
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
                      themeData.colorScheme.tertiary.withOpacity(0.1) ?? 
                        themeData.colorScheme.primary.withOpacity(0.1),
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
          'glassmorphism_effects_${theme.metadata.id.toLowerCase()}'
        );
      }
    });

    testGoldens('Phosphor Icons - All Themes', (tester) async {
      for (final theme in allThemes) {
        final themeData = ThemeFactory.createFlutterTheme(theme);
        
        await tester.pumpWidgetBuilder(
          _PhosphorIconsShowcase(),
          wrapper: (child) => MaterialApp(
            theme: themeData,
            home: Scaffold(
              backgroundColor: themeData.colorScheme.surface,
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: child,
              ),
            ),
          ),
          surfaceSize: const Size(400, 800),
        );

        await screenMatchesGolden(
          tester, 
          'phosphor_icons_${theme.metadata.id.toLowerCase()}'
        );
      }
    });

    testGoldens('Project Management Widgets - All Themes', (tester) async {
      for (final theme in allThemes) {
        final themeData = ThemeFactory.createFlutterTheme(theme);
        final projects = TestDataHelper.createTestProjects();
        
        await tester.pumpWidgetBuilder(
          _ProjectManagementWidgetShowcase(projects: projects.take(2).toList()),
          wrapper: (child) => ProviderScope(
            overrides: MockProviders.projectProviders,
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
          surfaceSize: const Size(400, 900),
        );

        await screenMatchesGolden(
          tester, 
          'project_widgets_${theme.metadata.id.toLowerCase()}'
        );
      }
    });

    testGoldens('Color Scheme Showcase - All Themes', (tester) async {
      for (final theme in allThemes) {
        final themeData = ThemeFactory.createFlutterTheme(theme);
        
        await tester.pumpWidgetBuilder(
          _ColorSchemeShowcase(),
          wrapper: (child) => MaterialApp(
            theme: themeData,
            home: Scaffold(
              backgroundColor: themeData.colorScheme.surface,
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: child,
              ),
            ),
          ),
          surfaceSize: const Size(400, 700),
        );

        await screenMatchesGolden(
          tester, 
          'color_scheme_${theme.metadata.id.toLowerCase()}'
        );
      }
    });

    testGoldens('Typography Showcase - All Themes', (tester) async {
      for (final theme in allThemes) {
        final themeData = ThemeFactory.createFlutterTheme(theme);
        
        await tester.pumpWidgetBuilder(
          _TypographyShowcase(),
          wrapper: (child) => MaterialApp(
            theme: themeData,
            home: Scaffold(
              backgroundColor: themeData.colorScheme.surface,
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
          'typography_${theme.metadata.id.toLowerCase()}'
        );
      }
    });

    testGoldens('Form Elements - All Themes', (tester) async {
      for (final theme in allThemes) {
        final themeData = ThemeFactory.createFlutterTheme(theme);
        
        await tester.pumpWidgetBuilder(
          _FormElementsShowcase(),
          wrapper: (child) => MaterialApp(
            theme: themeData,
            home: Scaffold(
              backgroundColor: themeData.colorScheme.surface,
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: child,
              ),
            ),
          ),
          surfaceSize: const Size(400, 1000),
        );

        await screenMatchesGolden(
          tester, 
          'form_elements_${theme.metadata.id.toLowerCase()}'
        );
      }
    });

    testGoldens('Navigation Components - All Themes', (tester) async {
      for (final theme in allThemes) {
        final themeData = ThemeFactory.createFlutterTheme(theme);
        
        await tester.pumpWidgetBuilder(
          _NavigationComponentsShowcase(),
          wrapper: (child) => MaterialApp(
            theme: themeData,
            home: Scaffold(
              backgroundColor: themeData.colorScheme.surface,
              body: child,
            ),
          ),
          surfaceSize: const Size(400, 600),
        );

        await screenMatchesGolden(
          tester, 
          'navigation_components_${theme.metadata.id.toLowerCase()}'
        );
      }
    });

    testGoldens('Dark vs Light Comparison', (tester) async {
      // Create side-by-side comparison for each theme family
      final themeGroups = {
        'dracula_ide': [
          DraculaIDETheme.create(isDark: false),
          DraculaIDETheme.create(isDark: true),
        ],
        'matrix': [
          MatrixTheme.create(isDark: false),
          MatrixTheme.create(isDark: true),
        ],
        'vegeta_blue': [
          VegetaBlueTheme.create(isDark: false),
          VegetaBlueTheme.create(isDark: true),
        ],
      };

      for (final entry in themeGroups.entries) {
        final themeName = entry.key;
        final themes = entry.value;
        
        await tester.pumpWidgetBuilder(
          _ThemeComparisonShowcase(
            lightTheme: ThemeFactory.createFlutterTheme(themes[0]),
            darkTheme: ThemeFactory.createFlutterTheme(themes[1]),
          ),
          wrapper: (child) => child,
          surfaceSize: const Size(800, 600),
        );

        await screenMatchesGolden(
          tester, 
          'theme_comparison_$themeName'
        );
      }
    });

    testGoldens('Accessibility Features - High Contrast', (tester) async {
      for (final theme in allThemes.take(2)) { // Test with 2 themes for variety
        final baseThemeData = ThemeFactory.createFlutterTheme(theme);
        final highContrastTheme = _createHighContrastTheme(baseThemeData);
        
        await tester.pumpWidgetBuilder(
          _AccessibilityFeaturesShowcase(),
          wrapper: (child) => MaterialApp(
            theme: highContrastTheme,
            home: Scaffold(
              backgroundColor: highContrastTheme.colorScheme.surface,
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
          'accessibility_high_contrast_${theme.metadata.id.toLowerCase()}'
        );
      }
    });

    testGoldens('Responsive Breakpoints', (tester) async {
      final theme = allThemes.first;
      final themeData = ThemeFactory.createFlutterTheme(theme);
      
      final breakpoints = [
        {'name': 'mobile', 'size': const Size(360, 640)},
        {'name': 'mobile_large', 'size': const Size(414, 896)},
        {'name': 'tablet', 'size': const Size(768, 1024)},
        {'name': 'desktop', 'size': const Size(1200, 800)},
      ];

      for (final breakpoint in breakpoints) {
        await tester.pumpWidgetBuilder(
          _ResponsiveBreakpointShowcase(
            screenWidth: (breakpoint['size'] as Size).width,
          ),
          wrapper: (child) => MaterialApp(
            theme: themeData,
            home: Scaffold(
              backgroundColor: themeData.colorScheme.surface,
              body: child,
            ),
          ),
          surfaceSize: breakpoint['size'] as Size,
        );

        await screenMatchesGolden(
          tester, 
          'responsive_${breakpoint['name']}'
        );
      }
    });
  });
}

// Showcase widgets for comprehensive theme testing

class _Material3ComponentShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Material 3 Components',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 24),
        
        // Buttons
        _buildSection(context, 'Buttons', [
          Row(
            children: [
              ElevatedButton(onPressed: () {}, child: const Text('Elevated')),
              const SizedBox(width: 8),
              FilledButton(onPressed: () {}, child: const Text('Filled')),
              const SizedBox(width: 8),
              OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton(onPressed: () {}, child: const Text('Text Button')),
              const SizedBox(width: 8),
              IconButton(onPressed: () {}, icon: Icon(PhosphorIcons.heart())),
              const SizedBox(width: 8),
              IconButton.filled(onPressed: () {}, icon: Icon(PhosphorIcons.star())),
            ],
          ),
        ]),
        
        // Cards
        _buildSection(context, 'Cards', [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Standard Card', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const Text('This is a standard Material 3 card with elevation.'),
                ],
              ),
            ),
          ),
          Card.filled(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Filled Card', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const Text('This is a filled Material 3 card with surface tint.'),
                ],
              ),
            ),
          ),
          Card.outlined(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Outlined Card', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const Text('This is an outlined Material 3 card with border.'),
                ],
              ),
            ),
          ),
        ]),
        
        // Chips
        _buildSection(context, 'Chips', [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              const Chip(label: Text('Standard Chip')),
              FilterChip(label: const Text('Filter Chip'), onSelected: (selected) {}),
              ChoiceChip(label: const Text('Choice Chip'), selected: true, onSelected: (selected) {}),
              ActionChip(label: const Text('Action Chip'), onPressed: () {}),
              InputChip(label: const Text('Input Chip'), onDeleted: () {}),
            ],
          ),
        ]),
        
        // Progress Indicators
        _buildSection(context, 'Progress Indicators', [
          const LinearProgressIndicator(value: 0.7),
          const SizedBox(height: 16),
          const Row(
            children: [
              CircularProgressIndicator(value: 0.7),
              SizedBox(width: 24),
              CircularProgressIndicator(),
            ],
          ),
        ]),
        
        // Switches and Checkboxes
        _buildSection(context, 'Selection Controls', [
          Row(
            children: [
              Checkbox(value: true, onChanged: (value) {}),
              const Text('Checkbox'),
              const SizedBox(width: 24),
              Switch(value: true, onChanged: (value) {}),
              const Text('Switch'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Radio<int>(value: 1, groupValue: 1, onChanged: (value) {}),
              const Text('Radio 1'),
              const SizedBox(width: 16),
              Radio<int>(value: 2, groupValue: 1, onChanged: (value) {}),
              const Text('Radio 2'),
            ],
          ),
        ]),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
        const SizedBox(height: 24),
      ],
    );
  }
}

class _GlassmorphismEffectShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Glassmorphism Effects',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          
          // Large glassmorphism card
          GlassmorphismContainer(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
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
                    'Beautiful glass-like effect with backdrop blur and subtle transparency',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Grid of smaller glassmorphism containers
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              GlassmorphismContainer(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(PhosphorIcons.chartBar(), size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Analytics',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '127 tasks',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              GlassmorphismContainer(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(PhosphorIcons.bell(), size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Notifications',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '5 new alerts',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              GlassmorphismContainer(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(PhosphorIcons.clock(), size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Time Tracking',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '4.5 hours',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              GlassmorphismContainer(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(PhosphorIcons.target(), size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Goals',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '8/10 reached',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
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
    final iconCategories = {
      'Project Management': [
        PhosphorIcons.folder(),
        PhosphorIcons.folderOpen(),
        PhosphorIcons.kanban(),
        PhosphorIcons.listChecks(),
      ],
      'Navigation & Actions': [
        PhosphorIcons.house(),
        PhosphorIcons.magnifyingGlass(),
        PhosphorIcons.plus(),
        PhosphorIcons.gear(),
      ],
      'Communication': [
        PhosphorIcons.bell(),
        PhosphorIcons.chatCircle(),
        PhosphorIcons.envelope(),
        PhosphorIcons.share(),
      ],
      'Media & Files': [
        PhosphorIcons.image(),
        PhosphorIcons.file(),
        PhosphorIcons.camera(),
        PhosphorIcons.download(),
      ],
      'Analytics & Charts': [
        PhosphorIcons.chartBar(),
        PhosphorIcons.chartLine(),
        PhosphorIcons.chartPie(),
        PhosphorIcons.trendUp(),
      ],
      'Time & Calendar': [
        PhosphorIcons.clock(),
        PhosphorIcons.calendar(),
        PhosphorIcons.timer(),
        PhosphorIcons.clockCountdown(),
      ],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phosphor Icons',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 24),
        
        ...iconCategories.entries.map((entry) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.key,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
              children: entry.value.map((icon) => Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 28),
                      const SizedBox(height: 4),
                      Text(
                        'Icon',
                        style: Theme.of(context).textTheme.labelSmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )).toList(),
            ),
            
            const SizedBox(height: 24),
          ],
        )),
      ],
    );
  }
}

class _ProjectManagementWidgetShowcase extends StatelessWidget {
  final List<dynamic> projects;

  const _ProjectManagementWidgetShowcase({required this.projects});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Project Management Widgets',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 24),
        
        // Project cards
        Text(
          'Project Cards',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        ...projects.map((project) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ProjectCard(
            project: project,
            onTap: () {},
            onEdit: () {},
            onDelete: () {},
          ),
        )),
        
        const SizedBox(height: 24),
        
        // Project creation form
        Text(
          'Project Creation Form',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Project Name',
                    hintText: 'Enter project name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.folder),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter project description',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.tag),
                  ),
                  items: ['Work', 'Personal', 'Learning', 'Health']
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {},
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
    );
  }
}

class _ColorSchemeShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    final colors = [
      {'name': 'Primary', 'color': colorScheme.primary, 'onColor': colorScheme.onPrimary},
      {'name': 'Primary Container', 'color': colorScheme.primaryContainer, 'onColor': colorScheme.onPrimaryContainer},
      {'name': 'Secondary', 'color': colorScheme.secondary, 'onColor': colorScheme.onSecondary},
      {'name': 'Secondary Container', 'color': colorScheme.secondaryContainer, 'onColor': colorScheme.onSecondaryContainer},
      {'name': 'Tertiary', 'color': colorScheme.tertiary ?? colorScheme.primary, 'onColor': colorScheme.onTertiary ?? colorScheme.onPrimary},
      {'name': 'Surface', 'color': colorScheme.surface, 'onColor': colorScheme.onSurface},
      {'name': 'Surface Variant', 'color': colorScheme.surfaceContainerHighest, 'onColor': colorScheme.onSurfaceVariant},
      {'name': 'Error', 'color': colorScheme.error, 'onColor': colorScheme.onError},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color Scheme',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 24),
        
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2,
          children: colors.map((colorInfo) => Container(
            decoration: BoxDecoration(
              color: colorInfo['color'] as Color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  colorInfo['name'] as String,
                  style: TextStyle(
                    color: colorInfo['onColor'] as Color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '#${(colorInfo['color'] as Color).value.toRadixString(16).toUpperCase().substring(2)}',
                  style: TextStyle(
                    color: (colorInfo['onColor'] as Color).withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          )).toList(),
        ),
      ],
    );
  }
}

class _TypographyShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    final typographyStyles = [
      {'name': 'Display Large', 'style': textTheme.displayLarge, 'text': 'Display Large'},
      {'name': 'Display Medium', 'style': textTheme.displayMedium, 'text': 'Display Medium'},
      {'name': 'Display Small', 'style': textTheme.displaySmall, 'text': 'Display Small'},
      {'name': 'Headline Large', 'style': textTheme.headlineLarge, 'text': 'Headline Large'},
      {'name': 'Headline Medium', 'style': textTheme.headlineMedium, 'text': 'Headline Medium'},
      {'name': 'Headline Small', 'style': textTheme.headlineSmall, 'text': 'Headline Small'},
      {'name': 'Title Large', 'style': textTheme.titleLarge, 'text': 'Title Large'},
      {'name': 'Title Medium', 'style': textTheme.titleMedium, 'text': 'Title Medium'},
      {'name': 'Title Small', 'style': textTheme.titleSmall, 'text': 'Title Small'},
      {'name': 'Label Large', 'style': textTheme.labelLarge, 'text': 'Label Large'},
      {'name': 'Label Medium', 'style': textTheme.labelMedium, 'text': 'Label Medium'},
      {'name': 'Label Small', 'style': textTheme.labelSmall, 'text': 'Label Small'},
      {'name': 'Body Large', 'style': textTheme.bodyLarge, 'text': 'Body Large'},
      {'name': 'Body Medium', 'style': textTheme.bodyMedium, 'text': 'Body Medium'},
      {'name': 'Body Small', 'style': textTheme.bodySmall, 'text': 'Body Small'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Typography Scale',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 24),
        
        ...typographyStyles.map((typeInfo) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                typeInfo['name'] as String,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                typeInfo['text'] as String,
                style: typeInfo['style'] as TextStyle?,
              ),
            ],
          ),
        )),
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
        const SizedBox(height: 24),
        
        // Text fields
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Standard Text Field',
            hintText: 'Enter text here',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.text_fields),
          ),
        ),
        const SizedBox(height: 16),
        
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Filled Text Field',
            hintText: 'Enter text here',
            filled: true,
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.text_fields),
            suffixIcon: Icon(Icons.visibility),
          ),
        ),
        const SizedBox(height: 16),
        
        TextFormField(
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Multiline Text Field',
            hintText: 'Enter multiple lines of text here',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.note),
          ),
        ),
        const SizedBox(height: 24),
        
        // Dropdowns and selectors
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Dropdown Selection',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.arrow_drop_down),
          ),
          items: ['Option 1', 'Option 2', 'Option 3']
              .map((option) => DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  ))
              .toList(),
          onChanged: (value) {},
        ),
        const SizedBox(height: 24),
        
        // Sliders
        Text('Slider', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Slider(
          value: 0.7,
          onChanged: (value) {},
          divisions: 10,
          label: '70%',
        ),
        const SizedBox(height: 16),
        
        RangeSlider(
          values: const RangeValues(0.2, 0.8),
          onChanged: (values) {},
          divisions: 10,
          labels: const RangeLabels('20%', '80%'),
        ),
        const SizedBox(height: 24),
        
        // Date and time pickers (represented as buttons)
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(PhosphorIcons.calendar()),
                label: const Text('Select Date'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(PhosphorIcons.clock()),
                label: const Text('Select Time'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NavigationComponentsShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // App bar
        AppBar(
          title: const Text('Navigation Components'),
          leading: IconButton(
            icon: Icon(PhosphorIcons.list()),
            onPressed: () {},
          ),
          actions: [
            IconButton(
              icon: Icon(PhosphorIcons.magnifyingGlass()),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(PhosphorIcons.bell()),
              onPressed: () {},
            ),
          ],
        ),
        
        // Tab bar
        DefaultTabController(
          length: 3,
          child: Column(
            children: [
              TabBar(
                tabs: [
                  Tab(icon: Icon(PhosphorIcons.house()), text: 'Home'),
                  Tab(icon: Icon(PhosphorIcons.chartBar()), text: 'Analytics'),
                  Tab(icon: Icon(PhosphorIcons.gear()), text: 'Settings'),
                ],
              ),
              const SizedBox(
                height: 200,
                child: TabBarView(
                  children: [
                    Center(child: Text('Home Content')),
                    Center(child: Text('Analytics Content')),
                    Center(child: Text('Settings Content')),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Bottom navigation bar
        BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(PhosphorIcons.house()),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(PhosphorIcons.kanban()),
              label: 'Projects',
            ),
            BottomNavigationBarItem(
              icon: Icon(PhosphorIcons.chartBar()),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: Icon(PhosphorIcons.gear()),
              label: 'Settings',
            ),
          ],
        ),
      ],
    );
  }
}

class _ThemeComparisonShowcase extends StatelessWidget {
  final ThemeData lightTheme;
  final ThemeData darkTheme;

  const _ThemeComparisonShowcase({
    required this.lightTheme,
    required this.darkTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Light theme side
        Expanded(
          child: MaterialApp(
            theme: lightTheme,
            home: Scaffold(
              backgroundColor: lightTheme.colorScheme.surface,
              body: const _ThemeVariantContent(isLight: true),
            ),
          ),
        ),
        
        // Divider
        Container(
          width: 2,
          color: Colors.grey,
        ),
        
        // Dark theme side
        Expanded(
          child: MaterialApp(
            theme: darkTheme,
            home: Scaffold(
              backgroundColor: darkTheme.colorScheme.surface,
              body: const _ThemeVariantContent(isLight: false),
            ),
          ),
        ),
      ],
    );
  }
}

class _ThemeVariantContent extends StatelessWidget {
  final bool isLight;

  const _ThemeVariantContent({required this.isLight});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isLight ? 'Light Theme' : 'Dark Theme',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sample Card',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text('This demonstrates the theme colors and typography.'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Primary'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text('Secondary'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Icon(PhosphorIcons.palette()),
              const SizedBox(width: 8),
              const Text('Color scheme preview'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Color swatches
          Row(
            children: [
              _ColorSwatch(color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              _ColorSwatch(color: Theme.of(context).colorScheme.secondary),
              const SizedBox(width: 8),
              _ColorSwatch(color: Theme.of(context).colorScheme.tertiary ?? Theme.of(context).colorScheme.primary),
            ],
          ),
        ],
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final Color color;

  const _ColorSwatch({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
    );
  }
}

class _AccessibilityFeaturesShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accessibility Features',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 24),
        
        // High contrast elements
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
                const SizedBox(height: 16),
                
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
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Checkbox(value: true, onChanged: (value) {}),
                    const Text('Accessible checkbox'),
                    const SizedBox(width: 24),
                    Switch(value: true, onChanged: (value) {}),
                    const Text('Accessible switch'),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Touch target sizes
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Touch Target Sizes',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(PhosphorIcons.plus()),
                      tooltip: 'Add item (48dp minimum)',
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.edit),
                      tooltip: 'Edit item (48dp minimum)',
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(PhosphorIcons.trash()),
                      tooltip: 'Delete item (48dp minimum)',
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

class _ResponsiveBreakpointShowcase extends StatelessWidget {
  final double screenWidth;

  const _ResponsiveBreakpointShowcase({required this.screenWidth});

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
            'Responsive Layout - ${isMobile ? 'Mobile' : isTablet ? 'Tablet' : 'Desktop'} (${screenWidth.round()}dp)',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          
          if (isMobile) ...[
            // Mobile layout - single column
            _buildMobileLayout(context),
          ] else if (isTablet) ...[
            // Tablet layout - two columns
            _buildTabletLayout(context),
          ] else ...[
            // Desktop layout - three columns
            _buildDesktopLayout(context),
          ],
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(PhosphorIcons.deviceMobile()),
                const SizedBox(width: 8),
                const Text('Mobile Layout - Single Column'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Card(child: SizedBox(height: 100, child: Center(child: Text('Card 1')))),
        const SizedBox(height: 8),
        const Card(child: SizedBox(height: 100, child: Center(child: Text('Card 2')))),
        const SizedBox(height: 8),
        const Card(child: SizedBox(height: 100, child: Center(child: Text('Card 3')))),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(PhosphorIcons.deviceTablet()),
                const SizedBox(width: 8),
                const Text('Tablet Layout - Two Columns'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            Expanded(child: Card(child: SizedBox(height: 150, child: Center(child: Text('Card 1'))))),
            SizedBox(width: 8),
            Expanded(child: Card(child: SizedBox(height: 150, child: Center(child: Text('Card 2'))))),
          ],
        ),
        const SizedBox(height: 8),
        const Row(
          children: [
            Expanded(child: Card(child: SizedBox(height: 150, child: Center(child: Text('Card 3'))))),
            SizedBox(width: 8),
            Expanded(child: Card(child: SizedBox(height: 150, child: Center(child: Text('Card 4'))))),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(PhosphorIcons.desktop()),
                const SizedBox(width: 8),
                const Text('Desktop Layout - Three Columns'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            Expanded(child: Card(child: SizedBox(height: 200, child: Center(child: Text('Card 1'))))),
            SizedBox(width: 8),
            Expanded(child: Card(child: SizedBox(height: 200, child: Center(child: Text('Card 2'))))),
            SizedBox(width: 8),
            Expanded(child: Card(child: SizedBox(height: 200, child: Center(child: Text('Card 3'))))),
          ],
        ),
      ],
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