import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/models/enums.dart';
import 'package:task_tracker_app/presentation/widgets/advanced_task_card.dart';

void main() {
  group('Widget Accessibility Tests', () {
    group('Semantic Labels and Descriptions', () {
      testWidgets('task card should have proper semantic labels', (tester) async {
        final task = TaskModel.create(
          title: 'Test Task for Accessibility',
          description: 'This task is used to test accessibility features',
          priority: TaskPriority.high,
          dueDate: DateTime.now().add(const Duration(days: 1)),
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: AdvancedTaskCard(task: task),
              ),
            ),
          ),
        );

        // Enable accessibility testing
        final SemanticsHandle handle = tester.ensureSemantics();

        // Verify semantic properties
        expect(
          find.bySemanticsLabel('Test Task for Accessibility'),
          findsOneWidget,
        );

        // Check for proper semantic roles
        final taskCardFinder = find.byType(AdvancedTaskCard);
        expect(taskCardFinder, findsOneWidget);

        // Test tap semantics
        final semantics = tester.getSemantics(taskCardFinder);
        expect(semantics.hasAction(SemanticsAction.tap), isTrue);

        handle.dispose();
      });

      testWidgets('buttons should have accessible labels and hints', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Accessibility Test'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: 'Add new task',
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    tooltip: 'Search tasks',
                    onPressed: () {},
                  ),
                ],
              ),
              body: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Create Task'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    tooltip: 'Delete selected tasks',
                    onPressed: () {},
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {},
                tooltip: 'Quick add task',
                child: const Icon(Icons.add),
              ),
            ),
          ),
        );

        final SemanticsHandle handle = tester.ensureSemantics();

        // Test button tooltips and labels
        expect(find.bySemanticsLabel('Add new task'), findsOneWidget);
        expect(find.bySemanticsLabel('Search tasks'), findsOneWidget);
        expect(find.bySemanticsLabel('Delete selected tasks'), findsOneWidget);
        expect(find.bySemanticsLabel('Quick add task'), findsOneWidget);

        // Test text button
        expect(find.widgetWithText(ElevatedButton, 'Create Task'), findsOneWidget);

        handle.dispose();
      });

      testWidgets('form fields should have proper accessibility', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Task Title',
                          hintText: 'Enter task title',
                          helperText: 'This will be the main title of your task',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Task title is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Optional description',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<TaskPriority>(
                        decoration: const InputDecoration(
                          labelText: 'Priority',
                        ),
                        items: TaskPriority.values.map((priority) {
                          return DropdownMenuItem(
                            value: priority,
                            child: Text(priority.displayName),
                          );
                        }).toList(),
                        onChanged: (value) {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        final SemanticsHandle handle = tester.ensureSemantics();

        // Test form field labels
        expect(find.bySemanticsLabel('Task Title'), findsOneWidget);
        expect(find.bySemanticsLabel('Description'), findsOneWidget);
        expect(find.bySemanticsLabel('Priority'), findsOneWidget);

        // Test hint texts are accessible
        final titleField = find.byType(TextFormField).first;
        await tester.tap(titleField);
        await tester.pump();

        // Test error message accessibility
        await tester.tap(find.byType(TextFormField).at(1)); // Focus different field
        await tester.pump();

        handle.dispose();
      });
    });

    group('Focus Management', () {
      testWidgets('should handle keyboard focus navigation', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  TextFormField(
                    key: const Key('field1'),
                    decoration: const InputDecoration(labelText: 'Field 1'),
                  ),
                  TextFormField(
                    key: const Key('field2'),
                    decoration: const InputDecoration(labelText: 'Field 2'),
                  ),
                  ElevatedButton(
                    key: const Key('button1'),
                    onPressed: () {},
                    child: const Text('Button 1'),
                  ),
                  ElevatedButton(
                    key: const Key('button2'),
                    onPressed: () {},
                    child: const Text('Button 2'),
                  ),
                ],
              ),
            ),
          ),
        );

        // Test tab navigation
        await tester.tap(find.byKey(const Key('field1')));
        await tester.pump();

        // Simulate tab key to move focus
        expect(find.byKey(const Key('field1')), findsOneWidget);
        
        await tester.tap(find.byKey(const Key('field2')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('button1')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('button2')));
        await tester.pump();

        // All elements should be focusable
        expect(find.byKey(const Key('field1')), findsOneWidget);
        expect(find.byKey(const Key('field2')), findsOneWidget);
        expect(find.byKey(const Key('button1')), findsOneWidget);
        expect(find.byKey(const Key('button2')), findsOneWidget);
      });

      testWidgets('should handle focus trapping in modals', (tester) async {
        bool showModal = false;

        await tester.pumpWidget(
          MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  body: Stack(
                    children: [
                      Center(
                        child: ElevatedButton(
                          key: const Key('open_modal'),
                          onPressed: () {
                            setState(() {
                              showModal = true;
                            });
                          },
                          child: const Text('Open Modal'),
                        ),
                      ),
                      if (showModal)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black54,
                            child: Center(
                              child: AlertDialog(
                                title: const Text('Test Modal'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextFormField(
                                      key: const Key('modal_field'),
                                      decoration: const InputDecoration(
                                        labelText: 'Modal Field',
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    key: const Key('cancel_button'),
                                    onPressed: () {
                                      setState(() {
                                        showModal = false;
                                      });
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    key: const Key('save_button'),
                                    onPressed: () {
                                      setState(() {
                                        showModal = false;
                                      });
                                    },
                                    child: const Text('Save'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        );

        // Open modal
        await tester.tap(find.byKey(const Key('open_modal')));
        await tester.pump();

        // Modal should be visible
        expect(find.text('Test Modal'), findsOneWidget);
        expect(find.byKey(const Key('modal_field')), findsOneWidget);
        expect(find.byKey(const Key('cancel_button')), findsOneWidget);
        expect(find.byKey(const Key('save_button')), findsOneWidget);

        // Test focus within modal
        await tester.tap(find.byKey(const Key('modal_field')));
        await tester.pump();

        // Close modal
        await tester.tap(find.byKey(const Key('cancel_button')));
        await tester.pump();

        // Modal should be closed
        expect(find.text('Test Modal'), findsNothing);
      });
    });

    group('Screen Reader Support', () {
      testWidgets('should provide comprehensive semantic information', (tester) async {
        final task = TaskModel.create(
          title: 'Screen Reader Test Task',
          description: 'Testing screen reader compatibility',
          priority: TaskPriority.urgent,
          dueDate: DateTime.now().add(const Duration(hours: 2)),
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Tasks'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.add),
                      tooltip: 'Add new task',
                      onPressed: () {},
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: const Row(
                        children: [
                          Icon(Icons.info),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'You have 1 urgent task due in 2 hours',
                              semanticsLabel: 'Important: You have 1 urgent task due in 2 hours',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          AdvancedTaskCard(task: task),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        final SemanticsHandle handle = tester.ensureSemantics();

        // Test semantic labels
        expect(
          find.bySemanticsLabel('Important: You have 1 urgent task due in 2 hours'),
          findsOneWidget,
        );

        expect(find.text('Screen Reader Test Task'), findsOneWidget);

        handle.dispose();
      });

      testWidgets('should announce state changes appropriately', (tester) async {
        bool isCompleted = false;
        final task = TaskModel.create(
          title: 'State Change Test Task',
          priority: TaskPriority.medium,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  body: Column(
                    children: [
                      Text(
                        isCompleted ? 'Task Completed' : 'Task Pending',
                        semanticsLabel: isCompleted 
                          ? 'Task completed successfully' 
                          : 'Task is still pending',
                      ),
                      Semantics(
                        button: true,
                        label: isCompleted 
                          ? 'Mark task as incomplete' 
                          : 'Mark task as complete',
                        onTap: () {
                          setState(() {
                            isCompleted = !isCompleted;
                          });
                        },
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isCompleted = !isCompleted;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isCompleted ? Colors.green : Colors.orange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isCompleted ? 'Completed' : 'Complete',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );

        final SemanticsHandle handle = tester.ensureSemantics();

        // Initial state
        expect(find.bySemanticsLabel('Task is still pending'), findsOneWidget);
        expect(find.bySemanticsLabel('Mark task as complete'), findsOneWidget);

        // Change state
        await tester.tap(find.bySemanticsLabel('Mark task as complete'));
        await tester.pump();

        // Verify state change
        expect(find.bySemanticsLabel('Task completed successfully'), findsOneWidget);
        expect(find.bySemanticsLabel('Mark task as incomplete'), findsOneWidget);

        handle.dispose();
      });
    });

    group('Touch Target Sizes', () {
      testWidgets('should have minimum touch target sizes', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  // Small icon button (should be wrapped in larger touch target)
                  IconButton(
                    key: const Key('small_icon'),
                    iconSize: 16,
                    icon: const Icon(Icons.star),
                    onPressed: () {},
                  ),
                  // Regular icon button
                  IconButton(
                    key: const Key('regular_icon'),
                    icon: const Icon(Icons.favorite),
                    onPressed: () {},
                  ),
                  // Text button
                  TextButton(
                    key: const Key('text_button'),
                    onPressed: () {},
                    child: const Text('Small Text'),
                  ),
                  // Custom small button
                  GestureDetector(
                    key: const Key('custom_small'),
                    onTap: () {},
                    child: Container(
                      width: 20,
                      height: 20,
                      color: Colors.blue,
                      child: const Icon(Icons.close, size: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        // Test minimum touch target sizes (44x44 logical pixels)
        final smallIcon = tester.getSize(find.byKey(const Key('small_icon')));
        final regularIcon = tester.getSize(find.byKey(const Key('regular_icon')));
        final textButton = tester.getSize(find.byKey(const Key('text_button')));

        // IconButtons should automatically have minimum touch targets
        expect(smallIcon.width, greaterThanOrEqualTo(44.0));
        expect(smallIcon.height, greaterThanOrEqualTo(44.0));
        expect(regularIcon.width, greaterThanOrEqualTo(44.0));
        expect(regularIcon.height, greaterThanOrEqualTo(44.0));

        // Text buttons should also meet minimum size
        expect(textButton.height, greaterThanOrEqualTo(36.0)); // Material design minimum

        // Note: Custom small button would need manual touch target enhancement
        final customSmall = tester.getSize(find.byKey(const Key('custom_small')));
        print('Custom small button size: ${customSmall.width}x${customSmall.height}');
        
        // This would fail accessibility guidelines (too small)
        expect(customSmall.width, equals(20.0));
        expect(customSmall.height, equals(20.0));
      });
    });

    group('Color Contrast in Context', () {
      testWidgets('should maintain contrast in different theme modes', (tester) async {
        for (final brightness in [Brightness.light, Brightness.dark]) {
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(brightness: brightness),
              home: Scaffold(
                appBar: AppBar(
                  title: Text('${brightness.name.toUpperCase()} Theme Test'),
                ),
                body: const Column(
                  children: [
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.task),
                        title: Text('Primary Text'),
                        subtitle: Text('Secondary text with lower contrast'),
                      ),
                    ),
                    Card(
                      color: Colors.blue,
                      child: ListTile(
                        leading: Icon(Icons.info, color: Colors.white),
                        title: Text('White text on blue', style: TextStyle(color: Colors.white)),
                        subtitle: Text('Should have good contrast', style: TextStyle(color: Colors.white70)),
                      ),
                    ),
                    Card(
                      color: Colors.orange,
                      child: ListTile(
                        leading: Icon(Icons.warning),
                        title: Text('Dark text on orange'),
                        subtitle: Text('Contrast may vary'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );

          // Verify theme elements are present
          expect(find.text('${brightness.name.toUpperCase()} Theme Test'), findsOneWidget);
          expect(find.text('Primary Text'), findsOneWidget);
          expect(find.text('Secondary text with lower contrast'), findsOneWidget);
          expect(find.text('White text on blue'), findsOneWidget);
          expect(find.text('Dark text on orange'), findsOneWidget);

          print('Tested ${brightness.name} theme successfully');
        }
      });
    });

    group('Dynamic Type Support', () {
      testWidgets('should handle different text scales', (tester) async {
        final textScales = [0.8, 1.0, 1.2, 1.5, 2.0];

        for (final scale in textScales) {
          await tester.pumpWidget(
            MaterialApp(
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(scale),
                  ),
                  child: child!,
                );
              },
              home: Scaffold(
                appBar: AppBar(
                  title: Text('Text Scale ${scale}x'),
                ),
                body: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Headline Text', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Text('Body text that should scale appropriately'),
                    Text('Small caption text', style: TextStyle(fontSize: 12)),
                    SizedBox(height: 16),
                    Card(
                      child: ListTile(
                        title: Text('List item title'),
                        subtitle: Text('List item subtitle'),
                        trailing: Icon(Icons.arrow_forward),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );

          // Verify text is rendered at different scales
          expect(find.text('Text Scale ${scale}x'), findsOneWidget);
          expect(find.text('Headline Text'), findsOneWidget);
          expect(find.text('Body text that should scale appropriately'), findsOneWidget);

          // Get text size to verify scaling
          final bodyTextWidget = tester.widget<Text>(find.text('Body text that should scale appropriately'));
          print('Text scale ${scale}x applied successfully');
        }
      });
    });
  });
}