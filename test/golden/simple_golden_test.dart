import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/models/enums.dart';

void main() {
  group('Simple Golden Tests', () {
    final testTask = TaskModel.create(
      title: 'Golden Test Task',
      description: 'This is a test task for golden testing',
      priority: TaskPriority.high,
      dueDate: DateTime(2024, 12, 25, 14, 30),
      tags: const ['urgent', 'testing'],
    );

    testGoldens('Basic Widget Showcase - Light Theme', (tester) async {
      await tester.pumpWidgetBuilder(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              leading: Icon(Icons.task_alt),
              title: Text('Sample Task'),
              subtitle: Text('Testing UI consistency'),
              trailing: Icon(Icons.more_vert),
            ),
            const Divider(),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Card Title', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('This is card content for testing theme consistency.'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(onPressed: () {}, child: const Text('Action')),
                        const SizedBox(width: 8),
                        OutlinedButton(onPressed: () {}, child: const Text('Cancel')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        wrapper: (child) => MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            backgroundColor: Colors.grey[100],
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: child,
            ),
          ),
        ),
        surfaceSize: const Size(400, 350),
      );

      await screenMatchesGolden(tester, 'basic_widgets_light');
    });

    testGoldens('Basic Widget Showcase - Dark Theme', (tester) async {
      await tester.pumpWidgetBuilder(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              leading: Icon(Icons.task_alt),
              title: Text('Sample Task'),
              subtitle: Text('Testing UI consistency'),
              trailing: Icon(Icons.more_vert),
            ),
            const Divider(),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Card Title', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('This is card content for testing theme consistency.'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(onPressed: () {}, child: const Text('Action')),
                        const SizedBox(width: 8),
                        OutlinedButton(onPressed: () {}, child: const Text('Cancel')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        wrapper: (child) => MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            backgroundColor: const Color(0xFF121212),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: child,
            ),
          ),
        ),
        surfaceSize: const Size(400, 350),
      );

      await screenMatchesGolden(tester, 'basic_widgets_dark');
    });

    testGoldens('Theme Color Showcase', (tester) async {
      await tester.pumpWidgetBuilder(
        _ColorShowcase(),
        wrapper: (child) => MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(body: child),
        ),
        surfaceSize: const Size(400, 600),
      );

      await screenMatchesGolden(tester, 'color_showcase_light');

      await tester.pumpWidgetBuilder(
        _ColorShowcase(),
        wrapper: (child) => MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(body: child),
        ),
        surfaceSize: const Size(400, 600),
      );

      await screenMatchesGolden(tester, 'color_showcase_dark');
    });

    testGoldens('Button Consistency', (tester) async {
      await tester.pumpWidgetBuilder(
        _ButtonShowcase(),
        wrapper: (child) => MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(body: child),
        ),
        surfaceSize: const Size(400, 400),
      );

      await screenMatchesGolden(tester, 'buttons_light');

      await tester.pumpWidgetBuilder(
        _ButtonShowcase(),
        wrapper: (child) => MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(body: child),
        ),
        surfaceSize: const Size(400, 400),
      );

      await screenMatchesGolden(tester, 'buttons_dark');
    });

    testGoldens('Large Text Accessibility', (tester) async {
      await tester.pumpWidgetBuilder(
        _AccessibilityShowcase(),
        wrapper: (child) => MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(1.3),
          ),
          child: MaterialApp(
            theme: ThemeData.light(),
            home: Scaffold(body: child),
          ),
        ),
        surfaceSize: const Size(400, 600),
      );

      await screenMatchesGolden(tester, 'large_text_accessibility');
    });

    testGoldens('High Contrast Theme', (tester) async {
      final highContrastLight = ThemeData.light().copyWith(
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
          onPrimary: Colors.white,
          secondary: Color(0xFF000080),
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
          error: Colors.red,
          onError: Colors.white,
        ),
      );

      await tester.pumpWidgetBuilder(
        _ColorShowcase(),
        wrapper: (child) => MaterialApp(
          theme: highContrastLight,
          home: Scaffold(body: child),
        ),
        surfaceSize: const Size(400, 600),
      );

      await screenMatchesGolden(tester, 'high_contrast_theme');
    });
  });
}

class _ColorShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Color Scheme', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 16),
          _buildColorBlock('Primary', colorScheme.primary, colorScheme.onPrimary),
          const SizedBox(height: 8),
          _buildColorBlock('Secondary', colorScheme.secondary, colorScheme.onSecondary),
          const SizedBox(height: 8),
          _buildColorBlock('Surface', colorScheme.surface, colorScheme.onSurface),
          const SizedBox(height: 8),
          _buildColorBlock('Error', colorScheme.error, colorScheme.onError),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Sample Card Content', style: theme.textTheme.bodyLarge),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorBlock(String label, Color bgColor, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label\n${bgColor.value.toRadixString(16).toUpperCase()}',
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _ButtonShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Button Styles', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton(onPressed: () {}, child: const Text('Elevated')),
              const SizedBox(width: 8),
              FilledButton(onPressed: () {}, child: const Text('Filled')),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
              const SizedBox(width: 8),
              TextButton(onPressed: () {}, child: const Text('Text')),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              ElevatedButton(onPressed: null, child: Text('Disabled')),
              SizedBox(width: 8),
              OutlinedButton(onPressed: null, child: Text('Disabled')),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.delete)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccessibilityShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Accessibility Test', style: theme.textTheme.headlineLarge),
          const SizedBox(height: 16),
          Text('Large Heading', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Medium Heading', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Body Text', style: theme.textTheme.bodyLarge),
          const SizedBox(height: 8),
          Text('Small Text', style: theme.textTheme.bodySmall),
          const SizedBox(height: 16),
          const Text('Touch Target Tests:'),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.add),
                tooltip: 'Add Item',
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.edit),
                tooltip: 'Edit Item',
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.delete),
                tooltip: 'Delete Item',
              ),
            ],
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Sample Input',
              hintText: 'Enter text here',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}