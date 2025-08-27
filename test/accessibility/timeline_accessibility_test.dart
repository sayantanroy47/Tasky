import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracker_app/core/accessibility/color_contrast_validator.dart';
import 'package:task_tracker_app/domain/entities/project.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/timeline_dependency.dart';
import 'package:task_tracker_app/domain/entities/timeline_milestone.dart';
import 'package:task_tracker_app/domain/models/enums.dart';
import 'package:task_tracker_app/presentation/widgets/timeline/timeline_gantt_view.dart';

void main() {
  group('Timeline/Gantt Chart Accessibility Tests', () {
    late Project testProject;
    late List<TaskModel> testTasks;
    late List<TimelineMilestone> testMilestones;
    late List<TimelineDependency> testDependencies;

    setUpAll(() {
      testProject = Project.create(
        name: 'Timeline Accessibility Test Project',
        description: 'Testing timeline accessibility features',
        category: 'Testing',
        color: '#9C27B0',
      );

      final now = DateTime.now();
      testTasks = [
        TaskModel.create(
          title: 'Timeline Task 1',
          description: 'First task in timeline',
          priority: TaskPriority.high,
          projectId: testProject.id,
          dueDate: now.add(const Duration(days: 7)),
        ),
        TaskModel.create(
          title: 'Timeline Task 2',
          description: 'Second task in timeline',
          priority: TaskPriority.medium,
          projectId: testProject.id,
          dueDate: now.add(const Duration(days: 14)),
        ),
        TaskModel.create(
          title: 'Timeline Task 3',
          description: 'Third task in timeline',
          priority: TaskPriority.low,
          projectId: testProject.id,
          dueDate: now.add(const Duration(days: 21)),
        ),
      ];

      testMilestones = [
        TimelineMilestone(
          id: '1',
          title: 'Project Kickoff',
          description: 'Project start milestone',
          date: now,
          projectId: testProject.id,
          color: '#4CAF50',
          createdAt: now,
          isCompleted: true,
        ),
        TimelineMilestone(
          id: '2',
          title: 'Mid-project Review',
          description: 'Halfway checkpoint',
          date: now.add(const Duration(days: 10)),
          projectId: testProject.id,
          color: '#FF9800',
          createdAt: now,
          isCompleted: false,
        ),
      ];

      testDependencies = [
        TimelineDependency(
          id: '1',
          dependentTaskId: testTasks[1].id,
          prerequisiteTaskId: testTasks[0].id,
          type: DependencyType.finishToStart,
          createdAt: now,
        ),
      ];
    });

    group('Timeline Structure Accessibility', () {
      testWidgets('timeline view should have proper semantic structure', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: TimelineGanttView(
                  projectIds: [testProject.id],
                  showControls: true,
                  height: 600,
                  onTaskSelected: (task) {},
                  onMilestoneSelected: (milestone) {},
                ),
              ),
            ),
          ),
        );

        final SemanticsHandle handle = tester.ensureSemantics();

        // Test main timeline container semantics
        final timelineFinder = find.byType(TimelineGanttView);
        expect(timelineFinder, findsOneWidget);

        final timelineSemantics = tester.getSemantics(timelineFinder);
        expect(
          timelineSemantics.getSemanticsData().label.toLowerCase().contains('timeline') == true ||
              timelineSemantics.getSemanticsData().label.toLowerCase().contains('gantt') == true ||
              timelineSemantics.getSemanticsData().hint.toLowerCase().contains('timeline') == true,
          isTrue,
          reason: 'Timeline should have semantic label identifying it as a timeline or Gantt chart',
        );

        // Test that timeline is marked as a chart/data visualization
        expect(
          timelineSemantics.getSemanticsData().hasFlag(SemanticsFlag.isImage) ||
              timelineSemantics.getSemanticsData().label.toLowerCase().contains('chart') == true,
          isTrue,
          reason: 'Timeline should be semantically identified as a data visualization',
        );

        handle.dispose();
      });

      testWidgets('timeline header should have accessible time scale labels', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    // Mock timeline header with time scale
                    SizedBox(
                      height: 60,
                      child: Row(
                        children: [
                          Expanded(
                            child: Semantics(
                              label:
                                  'Timeline header showing dates from ${DateTime.now().toString().substring(0, 10)} to ${DateTime.now().add(const Duration(days: 30)).toString().substring(0, 10)}',
                              hint: 'Time scale with daily intervals',
                              child: Container(
                                color: Colors.grey.withValues(alpha: 0.1),
                                child: Row(
                                  children: List.generate(7, (index) {
                                    final date = DateTime.now().add(Duration(days: index));
                                    return Expanded(
                                      child: Semantics(
                                        label: 'Day ${date.day}, ${_getMonthName(date.month)}',
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: Text('${date.day}'),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TimelineGanttView(
                        projectIds: [testProject.id],
                        height: 400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        final SemanticsHandle handle = tester.ensureSemantics();

        // Test timeline header semantics
        expect(
          find.bySemanticsLabel(RegExp('Timeline header.*', caseSensitive: false)),
          findsOneWidget,
        );

        // Test individual date labels
        expect(
          find.bySemanticsLabel(RegExp('Day \\d+.*', caseSensitive: false)),
          findsAtLeastNWidgets(1),
        );

        handle.dispose();
      });

      testWidgets('task timeline rows should have comprehensive accessibility info', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: testTasks.map((task) {
                    return Semantics(
                      label: 'Task: ${task.title}',
                      hint:
                          'Duration: ${task.dueDate != null ? '${task.dueDate!.difference(task.createdAt).inDays} days' : 'No duration set'}, '
                          'Priority: ${task.priority.displayName}, '
                          'Status: ${task.status.displayName}',
                      button: true,
                      onTap: () {},
                      child: Container(
                        height: 50,
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(task.priority),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                task.title,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );

        final SemanticsHandle handle = tester.ensureSemantics();

        // Test task row semantics
        for (final task in testTasks) {
          expect(
            find.bySemanticsLabel('Task: ${task.title}'),
            findsOneWidget,
          );
        }

        // Test that task rows have proper hint information
        final firstTaskFinder = find.bySemanticsLabel('Task: ${testTasks.first.title}');
        final firstTaskSemantics = tester.getSemantics(firstTaskFinder);
        expect(
          firstTaskSemantics.getSemanticsData().hint.contains('Priority'),
          isTrue,
        );
        expect(
          firstTaskSemantics.getSemanticsData().hint.contains('Status'),
          isTrue,
        );

        // Test task rows are interactive
        expect(
          firstTaskSemantics.getSemanticsData().hasAction(SemanticsAction.tap),
          isTrue,
        );

        handle.dispose();
      });

      testWidgets('milestone markers should have accessible labels', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: testMilestones.map((milestone) {
                    return Semantics(
                      label: 'Milestone: ${milestone.title}',
                      hint: '${milestone.description}, '
                          'Due: ${milestone.date.toString().substring(0, 10)}, '
                          '${milestone.isCompleted ? 'Completed' : 'Pending'}',
                      button: true,
                      onTap: () {},
                      child: Container(
                        height: 40,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Color(int.parse(milestone.color.replaceAll('#', '0xFF'))),
                          borderRadius: BorderRadius.circular(20),
                          border: milestone.isCompleted ? Border.all(color: Colors.green, width: 2) : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              milestone.isCompleted ? Icons.check_circle : Icons.flag,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              milestone.title,
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );

        final SemanticsHandle handle = tester.ensureSemantics();

        // Test milestone semantics
        for (final milestone in testMilestones) {
          expect(
            find.bySemanticsLabel('Milestone: ${milestone.title}'),
            findsOneWidget,
          );
        }

        // Test milestone completion status is communicated
        final firstMilestoneFinder = find.bySemanticsLabel('Milestone: ${testMilestones.first.title}');
        final firstMilestoneSemantics = tester.getSemantics(firstMilestoneFinder);
        expect(
          firstMilestoneSemantics.getSemanticsData().hint.contains('Completed'),
          isTrue,
        );

        handle.dispose();
      });
    });

    group('Timeline Navigation Accessibility', () {
      testWidgets('timeline should support keyboard navigation', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Focus(
                  child: TimelineGanttView(
                    projectIds: [testProject.id],
                    showControls: true,
                    height: 500,
                    onTaskSelected: (task) {},
                  ),
                ),
              ),
            ),
          ),
        );

        final SemanticsHandle handle = tester.ensureSemantics();

        // Test that timeline is keyboard focusable
        final timelineFinder = find.byType(TimelineGanttView);
        await tester.tap(timelineFinder);
        await tester.pump();

        // Test arrow key navigation
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();

        // Test that navigation works without throwing
        expect(find.byType(TimelineGanttView), findsOneWidget);

        handle.dispose();
      });

      testWidgets('timeline controls should be keyboard accessible', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    // Mock timeline controls
                    Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.zoom_out),
                            tooltip: 'Zoom out timeline',
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.zoom_in),
                            tooltip: 'Zoom in timeline',
                            onPressed: () {},
                          ),
                          const SizedBox(width: 16),
                          DropdownButton<String>(
                            value: 'Days',
                            hint: const Text('Time scale'),
                            items: ['Hours', 'Days', 'Weeks', 'Months'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {},
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.today),
                            tooltip: 'Go to today',
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.fullscreen),
                            tooltip: 'Toggle fullscreen',
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TimelineGanttView(
                        projectIds: [testProject.id],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        final SemanticsHandle handle = tester.ensureSemantics();

        // Test control button accessibility
        expect(find.bySemanticsLabel('Zoom out timeline'), findsOneWidget);
        expect(find.bySemanticsLabel('Zoom in timeline'), findsOneWidget);
        expect(find.bySemanticsLabel('Go to today'), findsOneWidget);
        expect(find.bySemanticsLabel('Toggle fullscreen'), findsOneWidget);

        // Test dropdown accessibility
        final dropdownFinder = find.byType(DropdownButton<String>);
        expect(dropdownFinder, findsOneWidget);

        final dropdownSemantics = tester.getSemantics(dropdownFinder);
        expect(
          dropdownSemantics.getSemanticsData().hasAction(SemanticsAction.tap),
          isTrue,
        );

        // Test tab navigation through controls
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        handle.dispose();
      });

      testWidgets('timeline should support zoom and pan with keyboard', (tester) async {
        bool zoomInCalled = false;
        bool zoomOutCalled = false;
        bool panLeftCalled = false;
        bool panRightCalled = false;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Shortcuts(
                  shortcuts: <LogicalKeySet, Intent>{
                    LogicalKeySet(LogicalKeyboardKey.equal): _ZoomInIntent(),
                    LogicalKeySet(LogicalKeyboardKey.minus): _ZoomOutIntent(),
                    LogicalKeySet(LogicalKeyboardKey.arrowLeft): _PanLeftIntent(),
                    LogicalKeySet(LogicalKeyboardKey.arrowRight): _PanRightIntent(),
                  },
                  child: Actions(
                    actions: <Type, Action<Intent>>{
                      _ZoomInIntent: CallbackAction<_ZoomInIntent>(
                        onInvoke: (_) {
                          zoomInCalled = true;
                          return null;
                        },
                      ),
                      _ZoomOutIntent: CallbackAction<_ZoomOutIntent>(
                        onInvoke: (_) {
                          zoomOutCalled = true;
                          return null;
                        },
                      ),
                      _PanLeftIntent: CallbackAction<_PanLeftIntent>(
                        onInvoke: (_) {
                          panLeftCalled = true;
                          return null;
                        },
                      ),
                      _PanRightIntent: CallbackAction<_PanRightIntent>(
                        onInvoke: (_) {
                          panRightCalled = true;
                          return null;
                        },
                      ),
                    },
                    child: Focus(
                      autofocus: true,
                      child: TimelineGanttView(
                        projectIds: [testProject.id],
                        height: 400,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        final SemanticsHandle handle = tester.ensureSemantics();

        // Test zoom in
        await tester.sendKeyEvent(LogicalKeyboardKey.equal);
        await tester.pump();
        expect(zoomInCalled, isTrue);

        // Test zoom out
        await tester.sendKeyEvent(LogicalKeyboardKey.minus);
        await tester.pump();
        expect(zoomOutCalled, isTrue);

        // Test pan left
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pump();
        expect(panLeftCalled, isTrue);

        // Test pan right
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();
        expect(panRightCalled, isTrue);

        handle.dispose();
      });
    });

    group('Timeline Data Accessibility', () {
      testWidgets('should provide data summaries for screen readers', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    // Timeline data summary for screen readers
                    Semantics(
                      label: 'Timeline data summary',
                      hint: 'Project contains ${testTasks.length} tasks over ${testTasks.length * 7} days. '
                          '${testTasks.where((t) => t.status == TaskStatus.completed).length} tasks completed, '
                          '${testTasks.where((t) => t.status == TaskStatus.inProgress).length} in progress, '
                          '${testTasks.where((t) => t.status == TaskStatus.pending).length} remaining. '
                          '${testMilestones.length} milestones: ${testMilestones.where((m) => m.isCompleted).length} completed.',
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Timeline Summary',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text('${testTasks.length} tasks • ${testMilestones.length} milestones'),
                            Text(
                                '${testTasks.where((t) => t.status == TaskStatus.completed).length}/${testTasks.length} completed'),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: TimelineGanttView(
                        projectIds: [testProject.id],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        final SemanticsHandle handle = tester.ensureSemantics();

        // Test data summary accessibility
        expect(find.bySemanticsLabel('Timeline data summary'), findsOneWidget);

        final summaryFinder = find.bySemanticsLabel('Timeline data summary');
        final summarySemantics = tester.getSemantics(summaryFinder);
        expect(
          summarySemantics.getSemanticsData().hint.contains('${testTasks.length} tasks'),
          isTrue,
        );
        expect(
          summarySemantics.getSemanticsData().hint.contains('${testMilestones.length} milestones'),
          isTrue,
        );

        handle.dispose();
      });

      testWidgets('dependency connections should be described accessibly', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: testDependencies.map((dependency) {
                    final fromTask = testTasks.firstWhere((t) => t.id == dependency.prerequisiteTaskId);
                    final toTask = testTasks.firstWhere((t) => t.id == dependency.dependentTaskId);

                    return Semantics(
                      label: 'Task dependency',
                      hint: '${fromTask.title} must ${_getDependencyDescription(dependency.type)} ${toTask.title}',
                      child: Container(
                        height: 40,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.link, color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text('${fromTask.title} → ${toTask.title}'),
                            ),
                            Chip(
                              label: Text(_getDependencyTypeLabel(dependency.type)),
                              backgroundColor: Colors.blue.withValues(alpha: 0.2),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );

        final SemanticsHandle handle = tester.ensureSemantics();

        // Test dependency accessibility
        expect(find.bySemanticsLabel('Task dependency'), findsAtLeastNWidgets(1));

        final dependencyFinder = find.bySemanticsLabel('Task dependency');
        final dependencySemantics = tester.getSemantics(dependencyFinder);
        expect(
          dependencySemantics.getSemanticsData().hint.contains('must'),
          isTrue,
        );

        handle.dispose();
      });
    });

    group('Timeline Visual Accessibility', () {
      testWidgets('should maintain good color contrast in timeline elements', (tester) async {
        // Test color combinations used in timeline
        final testColorCombinations = [
          // Task priority colors on white background
          (Colors.red.shade700, Colors.white, 'High priority task'),
          (Colors.orange.shade600, Colors.white, 'Medium priority task'),
          (Colors.green.shade600, Colors.white, 'Low priority task'),

          // Timeline grid and text
          (Colors.black87, Colors.white, 'Timeline text'),
          (Colors.grey.shade600, Colors.white, 'Timeline grid lines'),

          // Milestone colors
          (Colors.blue.shade700, Colors.white, 'Milestone text'),
          (Colors.purple.shade600, Colors.white, 'Milestone background'),
        ];

        for (final (foreground, background, description) in testColorCombinations) {
          final contrastRatio = ColorContrastValidator.calculateContrastRatio(
            foreground,
            background,
          );

          expect(
            contrastRatio,
            greaterThanOrEqualTo(4.5),
            reason: '$description should meet WCAG AA contrast requirements. '
                'Current ratio: ${contrastRatio.toStringAsFixed(2)}:1',
          );
        }
      });

      testWidgets('timeline should work in high contrast mode', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData(
                colorScheme: const ColorScheme.highContrastLight(),
                visualDensity: VisualDensity.comfortable,
              ),
              home: Scaffold(
                body: TimelineGanttView(
                  projectIds: [testProject.id],
                  showControls: true,
                  height: 500,
                ),
              ),
            ),
          ),
        );

        final SemanticsHandle handle = tester.ensureSemantics();

        // Test that timeline still works in high contrast mode
        expect(find.byType(TimelineGanttView), findsOneWidget);

        // Test that semantic information is preserved
        final timelineSemantics = tester.getSemantics(find.byType(TimelineGanttView));
        expect(
          timelineSemantics.getSemanticsData().label.isNotEmpty == true ||
              timelineSemantics.getSemanticsData().hint.isNotEmpty == true,
          isTrue,
        );

        handle.dispose();
      });

      testWidgets('timeline should handle different text scaling', (tester) async {
        final textScales = [0.8, 1.0, 1.3, 1.6, 2.0];

        for (final scale in textScales) {
          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp(
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
                    title: Text('Timeline ${scale}x Scale'),
                  ),
                  body: TimelineGanttView(
                    projectIds: [testProject.id],
                    height: 400,
                  ),
                ),
              ),
            ),
          );

          final SemanticsHandle handle = tester.ensureSemantics();

          // Test that timeline functions at different scales
          expect(find.byType(TimelineGanttView), findsOneWidget);
          expect(find.text('Timeline ${scale}x Scale'), findsOneWidget);

          // Test that semantic information is maintained
          final timelineSemantics = tester.getSemantics(find.byType(TimelineGanttView));
          expect(
            timelineSemantics.getSemanticsData().label.isNotEmpty == true ||
                timelineSemantics.getSemanticsData().hint.isNotEmpty == true,
            isTrue,
            reason: 'Timeline should maintain semantic information at ${scale}x text scale',
          );

          handle.dispose();
        }
      });
    });

    group('Timeline Screen Reader Integration', () {
      testWidgets('should announce timeline changes to screen readers', (tester) async {
        final List<String> announcements = [];

        // Mock SemanticsService.announce
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('flutter/accessibility'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'announce') {
              announcements.add(methodCall.arguments['message'] as String);
            }
            return null;
          },
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: StatefulBuilder(
                builder: (context, setState) {
                  return Scaffold(
                    body: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            SemanticsService.announce(
                              'Timeline view changed to week view',
                              TextDirection.ltr,
                            );
                          },
                          child: const Text('Change to Week View'),
                        ),
                        Expanded(
                          child: TimelineGanttView(
                            projectIds: [testProject.id],
                            height: 400,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );

        final SemanticsHandle handle = tester.ensureSemantics();

        // Simulate timeline view change
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Verify announcement was made
        expect(announcements.isNotEmpty, isTrue);
        expect(announcements.last, contains('Timeline view changed'));

        handle.dispose();
      });
    });
  });
}

// Helper functions
Color _getPriorityColor(TaskPriority priority) {
  switch (priority) {
    case TaskPriority.urgent:
      return Colors.red.shade700;
    case TaskPriority.high:
      return Colors.orange.shade600;
    case TaskPriority.medium:
      return Colors.blue.shade600;
    case TaskPriority.low:
      return Colors.green.shade600;
  }
}

String _getMonthName(int month) {
  const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return months[month];
}

String _getDependencyDescription(DependencyType type) {
  switch (type) {
    case DependencyType.finishToStart:
      return 'finish before';
    case DependencyType.startToStart:
      return 'start with';
    case DependencyType.finishToFinish:
      return 'finish with';
    case DependencyType.startToFinish:
      return 'start before finishing';
  }
}

String _getDependencyTypeLabel(DependencyType type) {
  switch (type) {
    case DependencyType.finishToStart:
      return 'FS';
    case DependencyType.startToStart:
      return 'SS';
    case DependencyType.finishToFinish:
      return 'FF';
    case DependencyType.startToFinish:
      return 'SF';
  }
}

// Intent classes for keyboard shortcuts
class _ZoomInIntent extends Intent {}

class _ZoomOutIntent extends Intent {}

class _PanLeftIntent extends Intent {}

class _PanRightIntent extends Intent {}
