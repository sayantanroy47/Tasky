import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:task_tracker_app/core/accessibility/color_contrast_validator.dart';
import 'package:task_tracker_app/domain/entities/project.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/models/enums.dart';
import 'package:task_tracker_app/presentation/widgets/project_card.dart';
import 'package:task_tracker_app/presentation/widgets/kanban_board_view.dart';
import 'package:task_tracker_app/presentation/widgets/advanced_task_card.dart';
import 'package:task_tracker_app/presentation/widgets/bulk_operations/bulk_action_toolbar.dart';

void main() {
  group('High Contrast and Color Accessibility Tests', () {
    late Project testProject;
    late List<TaskModel> testTasks;

    setUpAll(() {
      testProject = Project.create(
        name: 'High Contrast Test Project',
        description: 'Testing high contrast accessibility',
        category: 'Accessibility',
        color: '#2196F3',
      );

      testTasks = [
        TaskModel.create(
          title: 'High Priority Task',
          description: 'Testing high priority display',
          priority: TaskPriority.urgent,
          projectId: testProject.id,
        ),
        TaskModel.create(
          title: 'Medium Priority Task',
          description: 'Testing medium priority display',
          priority: TaskPriority.medium,
          projectId: testProject.id,
        ),
        TaskModel.create(
          title: 'Low Priority Task',
          description: 'Testing low priority display',
          priority: TaskPriority.low,
          projectId: testProject.id,
        ),
      ];
    });

    group('High Contrast Mode Support', () {
      testWidgets('project cards should work in high contrast light mode', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData(
                colorScheme: const ColorScheme.highContrastLight(),
                useMaterial3: true,
              ),
              home: Scaffold(
                body: ListView(
                  children: [
                    ProjectCard(
                      project: testProject,
                      onTap: () {},
                      onEdit: () {},
                      onDelete: () {},
                    ),
                    ...testTasks.map((task) => AdvancedTaskCard(
                      task: task,
                      onTap: () {},
                    )),
                  ],
                ),
              ),
            ),
          ),
        );

        final SemanticsHandle handle = tester.ensureSemantics();

        // Verify widgets render in high contrast mode
        expect(find.byType(ProjectCard), findsOneWidget);
        expect(find.byType(AdvancedTaskCard), findsNWidgets(testTasks.length));

        // Test semantic information is preserved
        final projectCardSemantics = tester.getSemantics(find.byType(ProjectCard));
        expect(
          projectCardSemantics.getSemanticsData().label.isNotEmpty == true,
          isTrue,
          reason: 'Project card should maintain semantic label in high contrast mode',
        );

        // Test task cards maintain accessibility
        for (int i = 0; i < testTasks.length; i++) {
          final taskCardFinder = find.byType(AdvancedTaskCard).at(i);
          final taskCardSemantics = tester.getSemantics(taskCardFinder);
          expect(
            taskCardSemantics.getSemanticsData().hasAction(SemanticsAction.tap),
            isTrue,
            reason: 'Task cards should remain interactive in high contrast mode',
          );
        }

        handle.dispose();
      });

      testWidgets('project cards should work in high contrast dark mode', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData(
                colorScheme: const ColorScheme.highContrastDark(),
                useMaterial3: true,
              ),
              home: Scaffold(
                body: ListView(
                  children: [
                    ProjectCard(
                      project: testProject,
                      onTap: () {},
                    ),
                    ...testTasks.map((task) => AdvancedTaskCard(
                      task: task,
                      onTap: () {},
                    )),
                  ],
                ),
              ),
            ),
          ),
        );

        final SemanticsHandle handle = tester.ensureSemantics();

        // Verify widgets render in high contrast dark mode
        expect(find.byType(ProjectCard), findsOneWidget);
        expect(find.byType(AdvancedTaskCard), findsNWidgets(testTasks.length));

        // Test semantic information is preserved in dark mode
        final projectCardSemantics = tester.getSemantics(find.byType(ProjectCard));
        expect(
          projectCardSemantics.getSemanticsData().label.isNotEmpty == true,
          isTrue,
          reason: 'Project card should maintain semantic label in high contrast dark mode',
        );

        handle.dispose();
      });

      testWidgets('kanban board should work in high contrast mode', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData(
                colorScheme: const ColorScheme.highContrastLight(),
                useMaterial3: true,
              ),
              home: Scaffold(
                body: KanbanBoardView(
                  projectId: testProject.id,
                  initialColumns: [
                    KanbanColumnConfig(
                      id: 'pending',
                      title: 'To Do',
                      status: TaskStatus.pending,
                      icon: Icons.radio_button_unchecked,
                      color: Colors.red,
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
                  enableDragAndDrop: true,
                  showControls: true,
                ),
              ),
            ),
          ),
        );

        final SemanticsHandle handle = tester.ensureSemantics();

        // Test Kanban board renders in high contrast
        expect(find.byType(KanbanBoardView), findsOneWidget);

        // Test semantic structure is maintained
        final kanbanSemantics = tester.getSemantics(find.byType(KanbanBoardView));
        expect(
          kanbanSemantics.getSemanticsData().label.isNotEmpty == true ||
          kanbanSemantics.getSemanticsData().hint.isNotEmpty == true,
          isTrue,
          reason: 'Kanban board should maintain semantic information in high contrast',
        );

        // Test column labels are accessible
        expect(
          find.bySemanticsLabel(RegExp('.*To Do.*', caseSensitive: false)),
          findsOneWidget,
        );
        expect(
          find.bySemanticsLabel(RegExp('.*In Progress.*', caseSensitive: false)),
          findsOneWidget,
        );
        expect(
          find.bySemanticsLabel(RegExp('.*Done.*', caseSensitive: false)),
          findsOneWidget,
        );

        handle.dispose();
      });

      testWidgets('bulk operations should work in high contrast mode', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData(
                colorScheme: const ColorScheme.highContrastLight(),
                useMaterial3: true,
              ),
              home: Scaffold(
                body: Column(
                  children: [
                    BulkActionToolbar(
                      selectedTasks: testTasks,
                    ),
                    Expanded(
                      child: ListView(
                        children: testTasks.map((task) =>
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Semantics(
                                  label: 'Select ${task.title}',
                                  child: Checkbox(
                                    value: true,
                                    onChanged: (value) {},
                                  ),
                                ),
                                Expanded(child: AdvancedTaskCard(task: task)),
                              ],
                            ),
                          ),
                        ).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        final SemanticsHandle handle = tester.ensureSemantics();

        // Test bulk operations toolbar renders
        expect(find.byType(BulkActionToolbar), findsOneWidget);

        // Test checkboxes are accessible in high contrast
        final checkboxFinder = find.byType(Checkbox);
        expect(checkboxFinder.evaluate().length, greaterThan(0));

        for (int i = 0; i < checkboxFinder.evaluate().length; i++) {
          final checkboxSemantics = tester.getSemantics(checkboxFinder.at(i));
          expect(
            checkboxSemantics.getSemanticsData().hasFlag(SemanticsFlag.hasCheckedState),
            isTrue,
            reason: 'Checkboxes should maintain checked state semantics in high contrast',
          );
        }

        // Test action buttons are accessible
        final iconButtonFinder = find.byType(IconButton);
        if (iconButtonFinder.evaluate().isNotEmpty) {
          for (int i = 0; i < iconButtonFinder.evaluate().length; i++) {
            final buttonSemantics = tester.getSemantics(iconButtonFinder.at(i));
            expect(
              buttonSemantics.getSemanticsData().hasAction(SemanticsAction.tap),
              isTrue,
              reason: 'Action buttons should remain tappable in high contrast mode',
            );
          }
        }

        handle.dispose();
      });
    });

    group('Color Contrast Validation', () {
      test('project management color schemes should meet WCAG AA standards', () {
        final colorTestCases = [
          // Project status colors
          _ColorTestCase(
            foreground: Colors.blue.shade700,
            background: Colors.white,
            description: 'Active project on light background',
            mustMeetAA: true,
            shouldMeetAAA: false,
          ),
          _ColorTestCase(
            foreground: Colors.green.shade700,
            background: Colors.white,
            description: 'Completed project on light background',
            mustMeetAA: true,
            shouldMeetAAA: false,
          ),
          _ColorTestCase(
            foreground: Colors.orange.shade700,
            background: Colors.white,
            description: 'Warning project on light background',
            mustMeetAA: true,
            shouldMeetAAA: false,
          ),
          _ColorTestCase(
            foreground: Colors.red.shade700,
            background: Colors.white,
            description: 'Overdue project on light background',
            mustMeetAA: true,
            shouldMeetAAA: false,
          ),

          // Task priority colors
          _ColorTestCase(
            foreground: Colors.white,
            background: Colors.red.shade700,
            description: 'White text on urgent priority background',
            mustMeetAA: true,
            shouldMeetAAA: true,
          ),
          _ColorTestCase(
            foreground: Colors.white,
            background: Colors.orange.shade600,
            description: 'White text on high priority background',
            mustMeetAA: true,
            shouldMeetAAA: false,
          ),
          _ColorTestCase(
            foreground: Colors.white,
            background: Colors.blue.shade600,
            description: 'White text on medium priority background',
            mustMeetAA: true,
            shouldMeetAAA: false,
          ),
          _ColorTestCase(
            foreground: Colors.white,
            background: Colors.green.shade600,
            description: 'White text on low priority background',
            mustMeetAA: true,
            shouldMeetAAA: false,
          ),

          // Dark mode colors
          _ColorTestCase(
            foreground: Colors.white,
            background: Colors.grey.shade800,
            description: 'White text on dark background',
            mustMeetAA: true,
            shouldMeetAAA: true,
          ),
          _ColorTestCase(
            foreground: Colors.grey.shade300,
            background: Colors.grey.shade900,
            description: 'Light text on very dark background',
            mustMeetAA: true,
            shouldMeetAAA: false,
          ),

          // Interactive elements
          _ColorTestCase(
            foreground: Colors.blue.shade600,
            background: Colors.grey.shade100,
            description: 'Link color on light grey background',
            mustMeetAA: true,
            shouldMeetAAA: false,
          ),
          _ColorTestCase(
            foreground: Colors.red.shade600,
            background: Colors.white,
            description: 'Error color on white background',
            mustMeetAA: true,
            shouldMeetAAA: false,
          ),
        ];

        for (final testCase in colorTestCases) {
          final contrastRatio = ColorContrastValidator.calculateContrastRatio(
            testCase.foreground,
            testCase.background,
          );

          if (testCase.mustMeetAA) {
            expect(
              contrastRatio,
              greaterThanOrEqualTo(4.5),
              reason: '${testCase.description} must meet WCAG AA standards. '
                     'Current ratio: ${contrastRatio.toStringAsFixed(2)}:1, '
                     'Required: 4.5:1',
            );
          }

          if (testCase.shouldMeetAAA) {
            expect(
              contrastRatio,
              greaterThanOrEqualTo(7.0),
              reason: '${testCase.description} should meet WCAG AAA standards. '
                     'Current ratio: ${contrastRatio.toStringAsFixed(2)}:1, '
                     'Required: 7.0:1',
            );
          }
        }
      });

      test('chart colors should be distinguishable for colorblind users', () {
        // Test color combinations that should be distinguishable
        final chartColorSets = [
          // Standard chart colors (should work for most colorblind types)
          [
            Colors.blue.shade600,    // Blue - safe for all types
            Colors.orange.shade600,  // Orange - safe for all types  
            Colors.green.shade700,   // Dark green - better than light green
            Colors.red.shade700,     // Dark red - better contrast
            Colors.purple.shade600,  // Purple - distinguishable
            Colors.brown.shade600,   // Brown - good alternative
          ],
          
          // Alternative colorblind-friendly palette
          [
            Colors.indigo.shade600,
            Colors.amber.shade700,
            Colors.teal.shade600,
            Colors.pink.shade600,
            Colors.grey.shade700,
          ],
        ];

        for (int setIndex = 0; setIndex < chartColorSets.length; setIndex++) {
          final colorSet = chartColorSets[setIndex];
          
          // Test each color against white background for contrast
          for (int i = 0; i < colorSet.length; i++) {
            final contrastRatio = ColorContrastValidator.calculateContrastRatio(
              colorSet[i],
              Colors.white,
            );
            
            expect(
              contrastRatio,
              greaterThanOrEqualTo(3.0), // Minimum for large graphical elements
              reason: 'Chart color set $setIndex, color $i should have sufficient '
                     'contrast against white background. '
                     'Current ratio: ${contrastRatio.toStringAsFixed(2)}:1',
            );
          }
          
          // Test color distinction within the set
          // This is a simplified test - real colorblind testing would need specialized algorithms
          for (int i = 0; i < colorSet.length; i++) {
            for (int j = i + 1; j < colorSet.length; j++) {
              final color1 = colorSet[i];
              final color2 = colorSet[j];
              
              // Test that colors are sufficiently different
              final luminance1 = color1.computeLuminance();
              final luminance2 = color2.computeLuminance();
              final luminanceDiff = (luminance1 - luminance2).abs();
              
              expect(
                luminanceDiff,
                greaterThan(0.05), // Minimum perceptible difference
                reason: 'Chart colors in set $setIndex should be distinguishable: '
                       'Color $i vs Color $j have insufficient luminance difference',
              );
            }
          }
        }
      });

      testWidgets('should validate color scheme accessibility reports', (tester) async {
        final testColorSchemes = [
          // Standard Material 3 light
          ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          
          // Standard Material 3 dark
          ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          
          // High contrast light
          const ColorScheme.highContrastLight(),
          
          // High contrast dark
          const ColorScheme.highContrastDark(),
          
          // Custom accessible scheme
          ColorContrastValidator.createAccessibleColorScheme(
            primary: Colors.blue,
            background: Colors.white,
            brightness: Brightness.light,
          ),
        ];

        final schemeNames = [
          'Material 3 Light',
          'Material 3 Dark', 
          'High Contrast Light',
          'High Contrast Dark',
          'Custom Accessible',
        ];

        for (int i = 0; i < testColorSchemes.length; i++) {
          final scheme = testColorSchemes[i];
          final name = schemeNames[i];
          
          final report = ColorContrastValidator.generateReport(scheme);
          
          // High contrast schemes should have no critical issues
          if (name.contains('High Contrast')) {
            expect(
              report.criticalIssues,
              equals(0),
              reason: '$name should have no critical accessibility issues',
            );
            
            expect(
              report.overallGrade,
              isIn([AccessibilityGrade.a, AccessibilityGrade.b]),
              reason: '$name should have excellent accessibility grade',
            );
          }
          
          // All schemes should be generally accessible
          expect(
            report.isAccessible,
            isTrue,
            reason: '$name should be marked as accessible',
          );
          
          // No scheme should have excessive issues
          expect(
            report.criticalIssues,
            lessThanOrEqualTo(2),
            reason: '$name should have minimal critical issues (≤2)',
          );
        }
      });
    });

    group('Alternative Text and Non-Color Information', () {
      testWidgets('priority should be communicated through text and icons, not just color', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: ListView(
                  children: testTasks.map((task) {
                    return Semantics(
                      label: 'Task: ${task.title}',
                      hint: 'Priority: ${task.priority.displayName}, Status: ${task.status.displayName}',
                      child: ListTile(
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Priority icon (non-color indicator)
                            Icon(_getPriorityIcon(task.priority)),
                            const SizedBox(width: 4),
                            // Priority color indicator
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _getPriorityColor(task.priority),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        title: Text(task.title),
                        subtitle: Text('${task.priority.displayName} priority • ${task.status.displayName}'),
                        trailing: Chip(
                          label: Text(_getPriorityLabel(task.priority)),
                          backgroundColor: _getPriorityColor(task.priority).withOpacity(0.1),
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

        // Test that priority information is available through text
        for (final task in testTasks) {
          final taskFinder = find.bySemanticsLabel('Task: ${task.title}');
          expect(taskFinder, findsOneWidget);
          
          final taskSemantics = tester.getSemantics(taskFinder);
          expect(
            taskSemantics.getSemanticsData().hint.contains(task.priority.displayName),
            isTrue,
            reason: 'Task should include priority information in semantic hint',
          );
        }

        // Test that priority icons are present
        expect(find.byIcon(Icons.keyboard_double_arrow_up), findsAtLeastNWidgets(1)); // Urgent
        expect(find.byIcon(Icons.keyboard_arrow_up), findsAtLeastNWidgets(1));        // High  
        expect(find.byIcon(Icons.remove), findsAtLeastNWidgets(1));                  // Medium
        expect(find.byIcon(Icons.keyboard_arrow_down), findsAtLeastNWidgets(1));     // Low

        // Test priority text labels
        expect(find.text('URGENT'), findsAtLeastNWidgets(1));
        expect(find.text('HIGH'), findsAtLeastNWidgets(1));
        expect(find.text('MEDIUM'), findsAtLeastNWidgets(1));
        expect(find.text('LOW'), findsAtLeastNWidgets(1));

        handle.dispose();
      });

      testWidgets('status should be communicated through multiple channels', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: ListView(
                  children: testTasks.map((task) {
                    return Semantics(
                      label: 'Task: ${task.title}',
                      hint: 'Status: ${task.status.displayName}',
                      child: Card(
                        child: ListTile(
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Status icon
                              Icon(_getStatusIcon(task.status)),
                              const SizedBox(width: 8),
                              // Status color indicator
                              Container(
                                width: 4,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _getStatusColor(task.status),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                          title: Text(task.title),
                          subtitle: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(task.status).withOpacity(0.1),
                                  border: Border.all(color: _getStatusColor(task.status)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  task.status.displayName.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusColor(task.status),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('• ${task.priority.displayName} priority'),
                            ],
                          ),
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

        // Test status information is available through text
        for (final task in testTasks) {
          expect(
            find.text(task.status.displayName.toUpperCase()),
            findsAtLeastNWidgets(1),
          );
        }

        // Test status icons are present
        expect(find.byIcon(Icons.radio_button_unchecked), findsAtLeastNWidgets(1)); // To Do
        expect(find.byIcon(Icons.hourglass_empty), findsAtLeastNWidgets(1));        // In Progress
        expect(find.byIcon(Icons.check_circle), findsAtLeastNWidgets(1));          // Done

        handle.dispose();
      });
    });

    group('Reduced Motion and Visual Effects', () {
      testWidgets('should respect reduced motion preferences', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: MediaQuery(
                data: const MediaQueryData(
                  disableAnimations: true, // Simulate reduced motion preference
                ),
                child: Scaffold(
                  body: Column(
                    children: [
                      ProjectCard(
                        project: testProject,
                        onTap: () {},
                      ),
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
          ),
        );

        final SemanticsHandle handle = tester.ensureSemantics();

        // Test that components render without animations
        expect(find.byType(ProjectCard), findsOneWidget);
        expect(find.byType(KanbanBoardView), findsOneWidget);

        // Test that functionality is preserved without animations
        final projectCardSemantics = tester.getSemantics(find.byType(ProjectCard));
        expect(
          projectCardSemantics.getSemanticsData().hasAction(SemanticsAction.tap),
          isTrue,
          reason: 'Project card should remain interactive with reduced motion',
        );

        handle.dispose();
      });

      testWidgets('should provide static alternatives to animated content', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    // Static progress indicator as alternative to animated one
                    Semantics(
                      label: 'Project progress',
                      hint: '3 of 5 tasks completed (60%)',
                      child: Container(
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Stack(
                          children: [
                            // Background
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            // Progress fill (static, no animation)
                            FractionallySizedBox(
                              widthFactor: 0.6, // 60% complete
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            // Progress text overlay
                            const Center(
                              child: Text(
                                '60%',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Static chart representation
                    Semantics(
                      label: 'Task completion chart',
                      hint: 'Bar chart showing: Monday 2 tasks, Tuesday 3 tasks, Wednesday 1 task, Thursday 4 tasks, Friday 2 tasks',
                      child: Container(
                        height: 200,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildStaticBar('Mon', 2, 4),
                            _buildStaticBar('Tue', 3, 4),
                            _buildStaticBar('Wed', 1, 4),
                            _buildStaticBar('Thu', 4, 4),
                            _buildStaticBar('Fri', 2, 4),
                          ],
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

        // Test static progress indicator accessibility
        expect(find.bySemanticsLabel('Project progress'), findsOneWidget);
        
        final progressSemantics = tester.getSemantics(find.bySemanticsLabel('Project progress'));
        expect(
          progressSemantics.getSemanticsData().hint.contains('60%'),
          isTrue,
          reason: 'Progress indicator should provide percentage in hint',
        );

        // Test static chart accessibility
        expect(find.bySemanticsLabel('Task completion chart'), findsOneWidget);
        
        final chartSemantics = tester.getSemantics(find.bySemanticsLabel('Task completion chart'));
        expect(
          chartSemantics.getSemanticsData().hint.contains('Bar chart showing'),
          isTrue,
          reason: 'Chart should provide data summary in hint',
        );

        handle.dispose();
      });
    });
  });
}

// Helper classes and functions
class _ColorTestCase {
  final Color foreground;
  final Color background;
  final String description;
  final bool mustMeetAA;
  final bool shouldMeetAAA;

  const _ColorTestCase({
    required this.foreground,
    required this.background,
    required this.description,
    required this.mustMeetAA,
    required this.shouldMeetAAA,
  });
}

// KanbanColumnConfig is imported from kanban_board_view.dart

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

IconData _getPriorityIcon(TaskPriority priority) {
  switch (priority) {
    case TaskPriority.urgent:
      return Icons.keyboard_double_arrow_up;
    case TaskPriority.high:
      return Icons.keyboard_arrow_up;
    case TaskPriority.medium:
      return Icons.remove;
    case TaskPriority.low:
      return Icons.keyboard_arrow_down;
  }
}

String _getPriorityLabel(TaskPriority priority) {
  return priority.displayName.toUpperCase();
}

Color _getStatusColor(TaskStatus status) {
  switch (status) {
    case TaskStatus.pending:
      return Colors.grey.shade600;
    case TaskStatus.inProgress:
      return Colors.blue.shade600;
    case TaskStatus.completed:
      return Colors.green.shade600;
    case TaskStatus.cancelled:
      return Colors.red.shade600;
  }
}

IconData _getStatusIcon(TaskStatus status) {
  switch (status) {
    case TaskStatus.pending:
      return Icons.radio_button_unchecked;
    case TaskStatus.inProgress:
      return Icons.hourglass_empty;
    case TaskStatus.completed:
      return Icons.check_circle;
    case TaskStatus.cancelled:
      return Icons.cancel;
  }
}

Widget _buildStaticBar(String label, int value, int maxValue) {
  final heightFactor = value / maxValue;
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(value.toString()),
          const SizedBox(height: 4),
          Container(
            height: 100 * heightFactor,
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    ),
  );
}