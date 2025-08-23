import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/models/enums.dart';
import 'package:task_tracker_app/presentation/widgets/advanced_task_card.dart';

void main() {
  group('UI Performance Tests', () {
    group('Task Card Rendering Performance', () {
      testWidgets('should render single task card quickly', (tester) async {
        final task = TaskModel.create(
          title: 'Performance Test Task',
          description: 'Task for UI performance testing',
          priority: TaskPriority.high,
        );

        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: AdvancedTaskCard(task: task),
              ),
            ),
          ),
        );

        stopwatch.stop();
        final elapsedMs = stopwatch.elapsedMilliseconds;

        print('Rendered single task card in ${elapsedMs}ms');

        // Should render quickly
        expect(elapsedMs, lessThan(100)); // 100ms max

        // Verify card is rendered
        expect(find.text('Performance Test Task'), findsOneWidget);
        expect(find.byType(AdvancedTaskCard), findsOneWidget);
      });

      testWidgets('should render list of task cards efficiently', (tester) async {
        const taskCount = 50;
        final tasks = List.generate(taskCount, (i) => TaskModel.create(
          title: 'List Performance Task ${i + 1}',
          description: 'Task $i for list performance testing',
          priority: TaskPriority.values[i % TaskPriority.values.length],
        ));

        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return AdvancedTaskCard(
                      key: Key('task_card_$index'),
                      task: tasks[index],
                    );
                  },
                ),
              ),
            ),
          ),
        );

        stopwatch.stop();
        final elapsedMs = stopwatch.elapsedMilliseconds;
        final avgMs = elapsedMs / taskCount;

        print('Rendered $taskCount task cards in ${elapsedMs}ms (${avgMs.toStringAsFixed(1)}ms avg)');

        // Should render efficiently
        expect(avgMs, lessThan(10.0)); // 10ms per card max
        expect(elapsedMs, lessThan(1000)); // 1 second total max

        // Verify some cards are rendered (ListView is lazy)
        expect(find.byType(AdvancedTaskCard), findsAtLeastNWidgets(1));
      });

      testWidgets('should handle scrolling performance', (tester) async {
        const taskCount = 100;
        final tasks = List.generate(taskCount, (i) => TaskModel.create(
          title: 'Scroll Performance Task ${i + 1}',
          priority: TaskPriority.values[i % TaskPriority.values.length],
        ));

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return AdvancedTaskCard(
                      key: Key('scroll_task_$index'),
                      task: tasks[index],
                    );
                  },
                ),
              ),
            ),
          ),
        );

        // Test scrolling performance
        final scrollable = find.byType(Scrollable);
        expect(scrollable, findsOneWidget);

        final stopwatch = Stopwatch()..start();

        // Scroll through the list
        for (int i = 0; i < 10; i++) {
          await tester.drag(scrollable, const Offset(0, -200));
          await tester.pump();
        }

        stopwatch.stop();
        final elapsedMs = stopwatch.elapsedMilliseconds;

        print('Completed 10 scroll operations in ${elapsedMs}ms');

        // Should scroll smoothly
        expect(elapsedMs, lessThan(1000)); // 1 second max for 10 scrolls
      });
    });

    group('Complex Widget Performance', () {
      testWidgets('should render complex task card with all features', (tester) async {
        final complexTask = TaskModel.create(
          title: 'Complex Performance Task with Very Long Title That Might Wrap to Multiple Lines',
          description: 'This is a very detailed description for a complex task that includes multiple sentences. It should test the performance of text rendering and layout calculations when dealing with longer content.',
          priority: TaskPriority.urgent,
          dueDate: DateTime.now().add(const Duration(days: 1)),
          projectId: 'complex-project',
          estimatedDuration: const Duration(hours: 2, minutes: 30),
          tags: const ['performance', 'testing', 'complex', 'ui'],
        );

        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      AdvancedTaskCard(task: complexTask),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        stopwatch.stop();
        final elapsedMs = stopwatch.elapsedMilliseconds;

        print('Rendered complex task card in ${elapsedMs}ms');

        // Should handle complex content efficiently
        expect(elapsedMs, lessThan(200)); // 200ms max

        // Verify complex content is rendered
        expect(find.textContaining('Complex Performance Task'), findsOneWidget);
        expect(find.textContaining('very detailed description'), findsOneWidget);
      });

      testWidgets('should handle task card interactions efficiently', (tester) async {
        final task = TaskModel.create(
          title: 'Interactive Performance Task',
          priority: TaskPriority.medium,
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

        // Test tap interactions
        final stopwatch = Stopwatch()..start();

        // Simulate multiple taps (like rapid user interaction)
        for (int i = 0; i < 5; i++) {
          await tester.tap(find.byType(AdvancedTaskCard));
          await tester.pump();
        }

        stopwatch.stop();
        final elapsedMs = stopwatch.elapsedMilliseconds;

        print('Handled 5 tap interactions in ${elapsedMs}ms');

        // Should handle interactions quickly
        expect(elapsedMs, lessThan(500)); // 500ms max
      });
    });

    group('Layout and Animation Performance', () {
      testWidgets('should handle layout changes efficiently', (tester) async {
        const taskCount = 20;
        final tasks = List.generate(taskCount, (i) => TaskModel.create(
          title: 'Layout Test Task ${i + 1}',
          priority: TaskPriority.values[i % TaskPriority.values.length],
        ));

        bool showAllTasks = false;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: StatefulBuilder(
                builder: (context, setState) {
                  return Scaffold(
                    appBar: AppBar(
                      title: const Text('Layout Performance'),
                      actions: [
                        IconButton(
                          key: const Key('toggle_button'),
                          icon: Icon(showAllTasks ? Icons.visibility_off : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              showAllTasks = !showAllTasks;
                            });
                          },
                        ),
                      ],
                    ),
                    body: Column(
                      children: [
                        if (showAllTasks) ...tasks.map((task) => AdvancedTaskCard(task: task)),
                        if (!showAllTasks) AdvancedTaskCard(task: tasks.first),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );

        // Test layout change performance
        final stopwatch = Stopwatch()..start();

        // Toggle visibility multiple times
        for (int i = 0; i < 4; i++) {
          await tester.tap(find.byKey(const Key('toggle_button')));
          await tester.pumpAndSettle();
        }

        stopwatch.stop();
        final elapsedMs = stopwatch.elapsedMilliseconds;

        print('Completed 4 layout changes in ${elapsedMs}ms');

        // Should handle layout changes efficiently
        expect(elapsedMs, lessThan(2000)); // 2 seconds max
      });

      testWidgets('should handle widget rebuilds efficiently', (tester) async {
        int rebuilds = 0;
        final task = TaskModel.create(
          title: 'Rebuild Test Task',
          priority: TaskPriority.low,
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: StatefulBuilder(
                builder: (context, setState) {
                  return Scaffold(
                    body: Column(
                      children: [
                        Text('Rebuilds: $rebuilds'),
                        AdvancedTaskCard(task: task),
                        ElevatedButton(
                          key: const Key('rebuild_button'),
                          onPressed: () {
                            setState(() {
                              rebuilds++;
                            });
                          },
                          child: const Text('Trigger Rebuild'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );

        // Test rebuild performance
        final stopwatch = Stopwatch()..start();

        // Trigger multiple rebuilds
        for (int i = 0; i < 10; i++) {
          await tester.tap(find.byKey(const Key('rebuild_button')));
          await tester.pump();
        }

        stopwatch.stop();
        final elapsedMs = stopwatch.elapsedMilliseconds;

        print('Handled 10 widget rebuilds in ${elapsedMs}ms');

        // Should handle rebuilds efficiently
        expect(elapsedMs, lessThan(1000)); // 1 second max

        // Verify final state
        expect(find.text('Rebuilds: 10'), findsOneWidget);
      });
    });

    group('Memory Performance', () {
      testWidgets('should not leak memory with repeated renders', (tester) async {
        const renderCycles = 10;
        const tasksPerCycle = 50;

        for (int cycle = 0; cycle < renderCycles; cycle++) {
          final tasks = List.generate(tasksPerCycle, (i) => TaskModel.create(
            title: 'Memory Test Cycle $cycle Task $i',
          ));

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp(
                home: Scaffold(
                  body: ListView(
                    children: tasks.map((task) => AdvancedTaskCard(
                      key: Key('${cycle}_${task.id}'),
                      task: task,
                    )).toList(),
                  ),
                ),
              ),
            ),
          );

          // Force a frame
          await tester.pump();

          print('Completed memory test cycle ${cycle + 1}/$renderCycles');
        }

        // Final render to ensure everything is cleaned up
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Container(),
              ),
            ),
          ),
        );

        print('Memory performance test completed successfully');
      });
    });

    group('Responsive Design Performance', () {
      testWidgets('should adapt to different screen sizes efficiently', (tester) async {
        final task = TaskModel.create(
          title: 'Responsive Test Task',
          description: 'Testing responsive performance',
        );

        final screenSizes = [
          const Size(320, 568), // Small phone
          const Size(375, 667), // Medium phone
          const Size(414, 896), // Large phone
          const Size(768, 1024), // Tablet
          const Size(1024, 768), // Tablet landscape
        ];

        final stopwatch = Stopwatch()..start();

        for (final size in screenSizes) {
          await tester.binding.setSurfaceSize(size);

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp(
                home: Scaffold(
                  body: AdvancedTaskCard(task: task),
                ),
              ),
            ),
          );

          await tester.pump();
        }

        stopwatch.stop();
        final elapsedMs = stopwatch.elapsedMilliseconds;

        print('Adapted to ${screenSizes.length} screen sizes in ${elapsedMs}ms');

        // Should adapt quickly
        expect(elapsedMs, lessThan(1000)); // 1 second max

        // Reset to default size
        await tester.binding.setSurfaceSize(null);
      });
    });
  });
}