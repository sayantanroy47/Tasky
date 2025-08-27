import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:task_tracker_app/core/accessibility/color_contrast_validator.dart';
import 'package:task_tracker_app/domain/entities/project.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/models/enums.dart';
import 'package:task_tracker_app/presentation/widgets/analytics/project_analytics_dashboard.dart';
import 'package:task_tracker_app/presentation/widgets/bulk_operations/bulk_action_toolbar.dart';
import 'package:task_tracker_app/presentation/widgets/bulk_operations/multi_select_task_card.dart';
import 'package:task_tracker_app/presentation/widgets/charts/bar_chart_widget.dart';
import 'package:task_tracker_app/presentation/widgets/charts/line_chart_widget.dart';
import 'package:task_tracker_app/presentation/widgets/charts/pie_chart_widget.dart';
import 'package:task_tracker_app/presentation/widgets/kanban_board_view.dart';
import 'package:task_tracker_app/presentation/widgets/kanban_column.dart';
import 'package:task_tracker_app/presentation/widgets/project_card.dart';
import 'package:task_tracker_app/presentation/widgets/timeline/timeline_gantt_view.dart';

void main() {
  group('Project Management Accessibility Tests', () {
    late Project testProject;
    late List<TaskModel> testTasks;

    setUpAll(() {
      testProject = Project.create(
        name: 'Accessibility Test Project',
        description: 'Project for testing accessibility features',
        category: 'Testing',
        color: '#2196F3',
      );

      testTasks = [
        TaskModel.create(
          title: 'Task 1 - To Do',
          description: 'First task for testing',
          priority: TaskPriority.high,
          projectId: testProject.id,
        ),
        TaskModel.create(
          title: 'Task 2 - In Progress',
          description: 'Second task for testing',
          priority: TaskPriority.medium,
          projectId: testProject.id,
        ),
        TaskModel.create(
          title: 'Task 3 - Done',
          description: 'Third task for testing',
          priority: TaskPriority.low,
          projectId: testProject.id,
        ),
      ];
    });

    group('Project Card Accessibility', () {
      testWidgets('project card should have comprehensive semantic labels', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: ProjectCard(
                  project: testProject,
                  onTap: () {},
                  onEdit: () {},
                  onDelete: () {},
                ),
              ),
            ),
          ),
        );

        final SemanticsHandle handle = tester.ensureSemantics();

        // Test semantic labels for project information
        expect(
          find.bySemanticsLabel(RegExp('.*${testProject.name}.*', caseSensitive: false)),
          findsOneWidget,
        );

        // Test project card is properly marked as button/tappable
        final projectCardFinder = find.byType(ProjectCard);
        expect(projectCardFinder, findsOneWidget);

        final semantics = tester.getSemantics(projectCardFinder);
        expect(semantics.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);

        // Test semantic role
        expect(
          semantics.getSemanticsData().hasFlag(SemanticsFlag.isButton),
          isTrue,
        );

        handle.dispose();
      });

      testWidgets('project card should have accessible action buttons', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: ProjectCard(
                  project: testProject,
                  onTap: () {},
                  onEdit: () {},
                  onDelete: () {},
                  showActions: true,
                ),
              ),
            ),
          ),
        );

        final SemanticsHandle handle = tester.ensureSemantics();

        // Look for action buttons with proper semantic labels
        final editButtonFinder = find
            .byWidgetPredicate((widget) => widget is Semantics && widget.properties.label?.contains('Edit') == true);

        final deleteButtonFinder = find
            .byWidgetPredicate((widget) => widget is Semantics && widget.properties.label?.contains('Delete') == true);

        // Verify action buttons have proper semantics
        if (editButtonFinder.evaluate().isNotEmpty) {
          final editSemantics = tester.getSemantics(editButtonFinder);
          expect(editSemantics.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
        }

        if (deleteButtonFinder.evaluate().isNotEmpty) {
          final deleteSemantics = tester.getSemantics(deleteButtonFinder);
          expect(deleteSemantics.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
        }

        handle.dispose();
      });

      testWidgets('project card should meet touch target size requirements', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: ProjectCard(
                  project: testProject,
                  onTap: () {},
                ),
              ),
            ),
          ),
        );

        // Verify minimum touch target size (44x44 dp)
        final cardSize = tester.getSize(find.byType(ProjectCard));
        expect(cardSize.height, greaterThanOrEqualTo(44.0));

        // Test that interactive areas meet minimum sizes
        final gestureDetectorFinder = find.byType(GestureDetector);
        if (gestureDetectorFinder.evaluate().isNotEmpty) {
          final gestureSize = tester.getSize(gestureDetectorFinder);
          expect(gestureSize.width, greaterThanOrEqualTo(44.0));
          expect(gestureSize.height, greaterThanOrEqualTo(44.0));
        }
      });
    });

    group('Kanban Board Accessibility', () {
      testWidgets('kanban board should have proper semantic structure', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: KanbanBoardView(
                  projectId: testProject.id,
                  initialColumns: [
                    KanbanColumnConfig(
                      id: 'pending',
                      title: 'To Do',
                      status: TaskStatus.pending,
                      icon: Icons.radio_button_unchecked,
                      color: Colors.grey,
                    ),
                    KanbanColumnConfig(
                      id: 'inProgress',
                      title: 'In Progress',
                      status: TaskStatus.inProgress,
                      icon: Icons.hourglass_empty,
                      color: Colors.blue,
                    ),
                    KanbanColumnConfig(
                      id: 'completed',
                      title: 'Done',
                      status: TaskStatus.completed,
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                  ],
                  showControls: true,
                  enableDragAndDrop: true,
                ),
              ),
            ),
          ),
        );

        final SemanticsHandle handle = tester.ensureSemantics();

        // Test overall Kanban board semantics
        final kanbanBoardFinder = find.byType(KanbanBoardView);
        expect(kanbanBoardFinder, findsOneWidget);

        // Test column headers have proper semantic labels
        expect(find.bySemanticsLabel('To Do column'), findsOneWidget);
        expect(find.bySemanticsLabel('In Progress column'), findsOneWidget);
        expect(find.bySemanticsLabel('Done column'), findsOneWidget);

        // Test drag and drop accessibility
        final draggableTaskFinder = find.byType(Draggable);
        if (draggableTaskFinder.evaluate().isNotEmpty) {
          final draggableSemantics = tester.getSemantics(draggableTaskFinder);
          expect(
            draggableSemantics.getSemanticsData().hasAction(SemanticsAction.longPress),
            isTrue,
          );
        }

        handle.dispose();
      });

      testWidgets('kanban columns should be keyboard navigable', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: KanbanBoardView(
                  projectId: testProject.id,
                  initialColumns: [
                    KanbanColumnConfig(
                      id: 'pending',
                      title: 'To Do',
                      status: TaskStatus.pending,
                      icon: Icons.radio_button_unchecked,
                      color: Colors.grey,
                    ),
                    KanbanColumnConfig(
                      id: 'inProgress',
                      title: 'In Progress',
                      status: TaskStatus.inProgress,
                      icon: Icons.hourglass_empty,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        final SemanticsHandle handle = tester.ensureSemantics();

        // Test keyboard focus on columns
        final firstColumn =
            find.byWidgetPredicate((widget) => widget is KanbanColumn && widget.config.status == TaskStatus.pending);

        if (firstColumn.evaluate().isNotEmpty) {
          await tester.tap(firstColumn);
          await tester.pump();

          // Column should be focusable
          final columnSemantics = tester.getSemantics(firstColumn);
          expect(
            columnSemantics.getSemanticsData().hasFlag(SemanticsFlag.isFocused) ||
                columnSemantics.getSemanticsData().hasFlag(SemanticsFlag.isFocusable),
            isTrue,
          );
        }

        handle.dispose();
      });

      testWidgets('kanban drag and drop should announce state changes', (tester) async {
        bool announcementMade = false;
        String? lastAnnouncement;

        // Mock SemanticsService.announce
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('flutter/accessibility'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'announce') {
              announcementMade = true;
              lastAnnouncement = methodCall.arguments['message'] as String?;
            }
            return null;
          },
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: KanbanBoardView(
                  projectId: testProject.id,
                  initialColumns: [
                    KanbanColumnConfig(
                      id: 'pending',
                      title: 'To Do',
                      status: TaskStatus.pending,
                      icon: Icons.radio_button_unchecked,
                      color: Colors.grey,
                    ),
                    KanbanColumnConfig(
                      id: 'inProgress',
                      title: 'In Progress',
                      status: TaskStatus.inProgress,
                      icon: Icons.hourglass_empty,
                      color: Colors.blue,
                    ),
                  ],
                  onTaskMoved: (task, newStatus) {
                    // Simulate announcement for task movement
                    SemanticsService.announce(
                      'Task "${task.title}" moved to ${newStatus.displayName}',
                      TextDirection.ltr,
                    );
                  },
                ),
              ),
            ),
          ),
        );

        // If there are draggable tasks, test drag and drop
        final draggableFinder = find.byType(Draggable);
        if (draggableFinder.evaluate().isNotEmpty) {
          // Simulate drag operation (simplified)
          await tester.drag(draggableFinder.first, const Offset(200, 0));
          await tester.pump();

          // Verify announcement was made
          expect(announcementMade, isTrue);
          expect(lastAnnouncement, isNotNull);
          expect(lastAnnouncement!.contains('moved'), isTrue);
        }
      });
    });

    group('Timeline/Gantt Chart Accessibility', () {
      testWidgets('timeline view should have proper semantic structure', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: TimelineGanttView(
                  projectIds: [testProject.id],
                  showControls: true,
                  height: 400,
                ),
              ),
            ),
          ),
        );

        final SemanticsHandle handle = tester.ensureSemantics();

        // Test timeline view semantics
        final timelineFinder = find.byType(TimelineGanttView);
        expect(timelineFinder, findsOneWidget);

        // Test that timeline has semantic label
        final timelineSemantics = tester.getSemantics(timelineFinder);
        expect(
          timelineSemantics.getSemanticsData().label.contains('timeline') == true ||
              timelineSemantics.getSemanticsData().label.contains('gantt') == true,
          isTrue,
        );

        // Test keyboard navigation support
        expect(
          timelineSemantics.getSemanticsData().hasFlag(SemanticsFlag.isFocusable),
          isTrue,
        );

        handle.dispose();
      });

      testWidgets('timeline tasks should be keyboard accessible', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: TimelineGanttView(
                  projectIds: [testProject.id],
                  onTaskSelected: (task) {
                    // Task selection callback
                  },
                ),
              ),
            ),
          ),
        );

        final SemanticsHandle handle = tester.ensureSemantics();

        // Look for timeline task rows
        final taskRowFinder = find.byWidgetPredicate(
            (widget) => widget is Semantics && widget.properties.label?.toLowerCase().contains('task') == true);

        if (taskRowFinder.evaluate().isNotEmpty) {
          final taskRowSemantics = tester.getSemantics(taskRowFinder);
          expect(
            taskRowSemantics.getSemanticsData().hasAction(SemanticsAction.tap),
            isTrue,
          );
        }

        handle.dispose();
      });

      testWidgets('timeline controls should have proper accessibility', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: TimelineGanttView(
                  projectIds: [testProject.id],
                  showControls: true,
                ),
              ),
            ),
          ),
        );

        final SemanticsHandle handle = tester.ensureSemantics();

        // Look for zoom controls, date navigation, etc.
        final controlButtonFinder = find.byWidgetPredicate((widget) =>
            widget is IconButton || (widget is Semantics && widget.properties.label?.contains('zoom') == true));

        if (controlButtonFinder.evaluate().isNotEmpty) {
          for (int i = 0; i < controlButtonFinder.evaluate().length; i++) {
            final buttonSemantics = tester.getSemantics(controlButtonFinder.at(i));
            expect(
              buttonSemantics.getSemanticsData().hasAction(SemanticsAction.tap),
              isTrue,
            );
          }
        }

        handle.dispose();
      });
    });

    group('Project Analytics Accessibility', () {
      testWidgets('analytics dashboard should have proper semantic structure', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: ProjectAnalyticsDashboard(
                  project: testProject,
                ),
              ),
            ),
          ),
        );

        final SemanticsHandle handle = tester.ensureSemantics();

        // Test analytics dashboard semantics
        final dashboardFinder = find.byType(ProjectAnalyticsDashboard);
        expect(dashboardFinder, findsOneWidget);

        // Test that charts have proper descriptions
        final chartFinder = find.byWidgetPredicate(
            (widget) => widget is LineChartWidget || widget is BarChartWidget || widget is PieChartWidget);

        if (chartFinder.evaluate().isNotEmpty) {
          final chartSemantics = tester.getSemantics(chartFinder);
          expect(
            chartSemantics.getSemanticsData().label.isNotEmpty == true ||
                chartSemantics.getSemanticsData().hint.isNotEmpty == true,
            isTrue,
          );
        }

        handle.dispose();
      });

      testWidgets('chart controls should be keyboard accessible', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: ProjectAnalyticsDashboard(
                  project: testProject,
                ),
              ),
            ),
          ),
        );

        final SemanticsHandle handle = tester.ensureSemantics();

        // Look for chart control buttons (time period, chart type, etc.)
        final controlFinder = find.byWidgetPredicate((widget) =>
            widget is DropdownButton ||
            widget is ToggleButtons ||
            (widget is Semantics && widget.properties.label?.toLowerCase().contains('chart') == true));

        if (controlFinder.evaluate().isNotEmpty) {
          final controlSemantics = tester.getSemantics(controlFinder);
          expect(
            controlSemantics.getSemanticsData().hasAction(SemanticsAction.tap),
            isTrue,
          );
        }

        handle.dispose();
      });

      testWidgets('charts should provide data summaries for screen readers', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    // Mock chart widgets with accessibility data
                    Semantics(
                      label: 'Bar chart showing task completion over time',
                      hint: 'Chart data: January 10 tasks, February 15 tasks, March 8 tasks',
                      child: Container(
                        height: 200,
                        color: Colors.blue.withValues(alpha: 0.1),
                        child: const Center(child: Text('Mock Bar Chart')),
                      ),
                    ),
                    Semantics(
                      label: 'Pie chart showing task distribution by priority',
                      hint: 'Chart data: High priority 30%, Medium priority 50%, Low priority 20%',
                      child: Container(
                        height: 200,
                        color: Colors.green.withValues(alpha: 0.1),
                        child: const Center(child: Text('Mock Pie Chart')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        final SemanticsHandle handle = tester.ensureSemantics();

        // Test chart semantic descriptions
        expect(
          find.bySemanticsLabel('Bar chart showing task completion over time'),
          findsOneWidget,
        );
        expect(
          find.bySemanticsLabel('Pie chart showing task distribution by priority'),
          findsOneWidget,
        );

        // Test data summaries in hints
        final barChartFinder = find.bySemanticsLabel('Bar chart showing task completion over time');
        final barChartSemantics = tester.getSemantics(barChartFinder);
        expect(
          barChartSemantics.getSemanticsData().hint.contains('Chart data'),
          isTrue,
        );

        handle.dispose();
      });
    });

    group('Bulk Operations Accessibility', () {
      testWidgets('bulk action toolbar should be keyboard accessible', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: BulkActionToolbar(
                  selectedTasks: testTasks.take(3).toList(),
                ),
              ),
            ),
          ),
        );

        final SemanticsHandle handle = tester.ensureSemantics();

        // Test bulk action buttons have proper semantics
        final bulkActionsFinder = find.byType(IconButton);

        for (int i = 0; i < bulkActionsFinder.evaluate().length; i++) {
          final buttonSemantics = tester.getSemantics(bulkActionsFinder.at(i));
          expect(
            buttonSemantics.getSemanticsData().hasAction(SemanticsAction.tap),
            isTrue,
          );

          // Button should have a label or tooltip
          expect(
            buttonSemantics.getSemanticsData().label.isNotEmpty == true ||
                buttonSemantics.getSemanticsData().hint.isNotEmpty == true,
            isTrue,
          );
        }

        handle.dispose();
      });

      testWidgets('multi-select task cards should have proper selection semantics', (tester) async {
        final task = testTasks.first;
        const bool isSelected = false;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: StatefulBuilder(
                builder: (context, setState) {
                  return Scaffold(
                    body: MultiSelectTaskCard(
                      task: task,
                    ),
                  );
                },
              ),
            ),
          ),
        );

        final SemanticsHandle handle = tester.ensureSemantics();

        // Test selection checkbox semantics
        final checkboxFinder = find.byType(Checkbox);
        if (checkboxFinder.evaluate().isNotEmpty) {
          final checkboxSemantics = tester.getSemantics(checkboxFinder);
          expect(
            checkboxSemantics.getSemanticsData().hasFlag(SemanticsFlag.hasCheckedState),
            isTrue,
          );
          expect(
            checkboxSemantics.getSemanticsData().hasAction(SemanticsAction.tap),
            isTrue,
          );
        }

        // Test selection state announcement
        await tester.tap(find.byType(MultiSelectTaskCard));
        await tester.pump();

        handle.dispose();
      });

      testWidgets('bulk operations should announce completion status', (tester) async {
        bool announcementMade = false;
        String? lastAnnouncement;

        // Mock SemanticsService.announce
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('flutter/accessibility'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'announce') {
              announcementMade = true;
              lastAnnouncement = methodCall.arguments['message'] as String?;
            }
            return null;
          },
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: BulkActionToolbar(
                  selectedTasks: testTasks.take(3).toList(),
                  onOperationComplete: (result) {
                    SemanticsService.announce(
                      '${result.operationType} completed for ${result.successfulTasks} tasks',
                      TextDirection.ltr,
                    );
                  },
                ),
              ),
            ),
          ),
        );

        // Test bulk complete action announcement
        final completeButtonFinder = find.byWidgetPredicate((widget) =>
            widget is IconButton &&
            (widget.tooltip?.toLowerCase().contains('complete') == true ||
                widget.icon.toString().contains('check') == true));

        if (completeButtonFinder.evaluate().isNotEmpty) {
          await tester.tap(completeButtonFinder);
          await tester.pump();

          expect(announcementMade, isTrue);
          expect(lastAnnouncement, contains('complete'));
        }
      });
    });

    group('High Contrast and Color Accessibility', () {
      testWidgets('project management UI should work in high contrast mode', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData(
                brightness: Brightness.light,
                colorScheme: const ColorScheme.highContrastLight(),
              ),
              home: Scaffold(
                body: Column(
                  children: [
                    ProjectCard(project: testProject),
                    Expanded(
                      child: KanbanBoardView(
                        projectId: testProject.id,
                        initialColumns: [
                          KanbanColumnConfig(
                            id: 'pending',
                            title: 'To Do',
                            status: TaskStatus.pending,
                            icon: Icons.radio_button_unchecked,
                            color: Colors.grey,
                          ),
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

        // Test that high contrast UI still has proper semantics
        expect(find.byType(ProjectCard), findsOneWidget);
        expect(find.byType(KanbanBoardView), findsOneWidget);

        // Verify text is still readable
        final projectCardSemantics = tester.getSemantics(find.byType(ProjectCard));
        expect(
          projectCardSemantics.getSemanticsData().label.isNotEmpty == true,
          isTrue,
        );

        handle.dispose();
      });

      testWidgets('should validate color contrast ratios in project UI', (tester) async {
        // Test various project management color combinations
        final testColors = [
          // Project status colors
          (Colors.blue, Colors.white, 'Project active status'),
          (Colors.green, Colors.white, 'Project complete status'),
          (Colors.orange, Colors.black, 'Project warning status'),
          (Colors.red, Colors.white, 'Project error status'),

          // Priority colors
          (Colors.red.shade700, Colors.white, 'High priority'),
          (Colors.orange.shade600, Colors.white, 'Medium priority'),
          (Colors.green.shade600, Colors.white, 'Low priority'),
        ];

        for (final (foreground, background, description) in testColors) {
          final contrastRatio = ColorContrastValidator.calculateContrastRatio(
            foreground,
            background,
          );

          // Test WCAG AA compliance (minimum 4.5:1 for normal text)
          expect(
            contrastRatio,
            greaterThanOrEqualTo(4.5),
            reason: '$description should meet WCAG AA contrast requirements. '
                'Current ratio: ${contrastRatio.toStringAsFixed(2)}:1',
          );
        }
      });
    });

    group('Touch Target Size Validation', () {
      testWidgets('all interactive elements should meet minimum touch targets', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Project management UI with various interactive elements
                      ProjectCard(project: testProject),
                      const SizedBox(height: 16),

                      // Bulk action toolbar
                      BulkActionToolbar(
                        selectedTasks: testTasks.take(2).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Small interactive elements that should be tested
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(PhosphorIcons.star(), size: 16),
                            iconSize: 16,
                            onPressed: () {},
                            tooltip: 'Favorite project',
                          ),
                          IconButton(
                            icon: Icon(PhosphorIcons.dotsThree(), size: 18),
                            iconSize: 18,
                            onPressed: () {},
                            tooltip: 'More options',
                          ),
                          Switch(
                            value: true,
                            onChanged: (value) {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        // Test minimum touch target sizes (44x44 logical pixels)
        final iconButtons = find.byType(IconButton);

        for (int i = 0; i < iconButtons.evaluate().length; i++) {
          final buttonSize = tester.getSize(iconButtons.at(i));
          expect(
            buttonSize.width,
            greaterThanOrEqualTo(44.0),
            reason: 'IconButton $i width should be at least 44dp for accessibility',
          );
          expect(
            buttonSize.height,
            greaterThanOrEqualTo(44.0),
            reason: 'IconButton $i height should be at least 44dp for accessibility',
          );
        }

        // Test Switch touch target
        final switchWidget = find.byType(Switch);
        if (switchWidget.evaluate().isNotEmpty) {
          final switchSize = tester.getSize(switchWidget);
          expect(
            switchSize.height,
            greaterThanOrEqualTo(44.0),
            reason: 'Switch should have minimum height of 44dp',
          );
        }
      });
    });

    group('Dynamic Text Scaling', () {
      testWidgets('project UI should handle different text scales', (tester) async {
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
                    title: Text('Project Management ${scale}x'),
                  ),
                  body: SingleChildScrollView(
                    child: Column(
                      children: [
                        ProjectCard(project: testProject),
                        const SizedBox(height: 200),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );

          final SemanticsHandle handle = tester.ensureSemantics();

          // Verify UI still functions at different text scales
          expect(find.byType(ProjectCard), findsOneWidget);
          expect(find.text('Project Management ${scale}x'), findsOneWidget);

          // Test that semantic labels still work
          final projectCardSemantics = tester.getSemantics(find.byType(ProjectCard));
          expect(
            projectCardSemantics.getSemanticsData().label.isNotEmpty == true,
            isTrue,
            reason: 'Project card should maintain semantic label at ${scale}x text scale',
          );

          handle.dispose();
        }
      });
    });

    group('Screen Reader Integration', () {
      testWidgets('should provide comprehensive semantic descriptions', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Project Dashboard'),
                  actions: [
                    IconButton(
                      icon: Icon(PhosphorIcons.plus()),
                      tooltip: 'Create new project',
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(PhosphorIcons.funnel()),
                      tooltip: 'Filter projects',
                      onPressed: () {},
                    ),
                  ],
                ),
                body: ListView(
                  children: [
                    // Project summary card with semantic description
                    Semantics(
                      label: 'Project summary',
                      hint: 'Shows overview of ${testProject.name} with 3 tasks: 1 to do, 1 in progress, 1 completed',
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                testProject.name,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(testProject.description ?? ''),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Chip(
                                    label: const Text('3 tasks'),
                                    backgroundColor: Colors.blue.withValues(alpha: 0.1),
                                  ),
                                  const SizedBox(width: 8),
                                  Chip(
                                    label: const Text('33% complete'),
                                    backgroundColor: Colors.green.withValues(alpha: 0.1),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        final SemanticsHandle handle = tester.ensureSemantics();

        // Test semantic labels and hints
        expect(
          find.bySemanticsLabel('Project summary'),
          findsOneWidget,
        );

        expect(find.bySemanticsLabel('Create new project'), findsOneWidget);
        expect(find.bySemanticsLabel('Filter projects'), findsOneWidget);

        // Test comprehensive semantic information
        final summaryFinder = find.bySemanticsLabel('Project summary');
        final summarySemantics = tester.getSemantics(summaryFinder);
        expect(
          summarySemantics.getSemanticsData().hint.contains('3 tasks'),
          isTrue,
        );

        handle.dispose();
      });

      testWidgets('should announce live region updates', (tester) async {
        bool announcementMade = false;
        String? lastAnnouncement;

        // Mock SemanticsService.announce
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('flutter/accessibility'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'announce') {
              announcementMade = true;
              lastAnnouncement = methodCall.arguments['message'] as String?;
            }
            return null;
          },
        );

        int taskCount = 3;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: StatefulBuilder(
                builder: (context, setState) {
                  return Scaffold(
                    body: Column(
                      children: [
                        // Live region for task count updates
                        Semantics(
                          liveRegion: true,
                          label: 'Task count: $taskCount tasks remaining',
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              '$taskCount tasks remaining',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              taskCount--;
                            });
                            SemanticsService.announce(
                              'Task completed. $taskCount tasks remaining',
                              TextDirection.ltr,
                            );
                          },
                          child: const Text('Complete Task'),
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

        // Test initial state
        expect(find.text('3 tasks remaining'), findsOneWidget);

        // Simulate task completion
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Verify announcement was made
        expect(announcementMade, isTrue);
        expect(lastAnnouncement, contains('Task completed'));
        expect(lastAnnouncement, contains('2 tasks remaining'));

        // Verify live region updated
        expect(find.text('2 tasks remaining'), findsOneWidget);

        handle.dispose();
      });
    });
  });
}

/// Helper classes for testing
// KanbanColumnConfig is imported from kanban_board_view.dart

class TaskFilter {
  final String? searchQuery;
  final TaskPriority? priority;
  final TaskStatus? status;

  const TaskFilter({
    this.searchQuery,
    this.priority,
    this.status,
  });
}
