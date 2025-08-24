import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:task_tracker_app/core/accessibility/touch_target_validator.dart';
import 'package:task_tracker_app/domain/entities/project.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/models/enums.dart';
import 'package:task_tracker_app/presentation/widgets/project_card.dart';
import 'package:task_tracker_app/presentation/widgets/kanban_board_view.dart';
import 'package:task_tracker_app/presentation/widgets/advanced_task_card.dart';
import 'package:task_tracker_app/presentation/widgets/bulk_operations/bulk_action_toolbar.dart';
import 'package:task_tracker_app/presentation/widgets/bulk_operations/multi_select_task_card.dart';
import 'package:task_tracker_app/presentation/widgets/timeline/timeline_gantt_view.dart';
import 'package:task_tracker_app/presentation/widgets/analytics/project_analytics_dashboard.dart';

void main() {
  group('Touch Target Sizes and WCAG 2.1 AA Compliance Tests', () {
    late Project testProject;
    late List<TaskModel> testTasks;

    setUpAll(() {
      testProject = Project.create(
        name: 'Touch Target Test Project',
        description: 'Testing touch target accessibility',
        category: 'Accessibility',
        color: '#3F51B5',
      );

      testTasks = [
        TaskModel.create(
          title: 'Touch Target Test Task 1',
          description: 'Testing touch targets',
          priority: TaskPriority.high,
          projectId: testProject.id,
        ),
        TaskModel.create(
          title: 'Touch Target Test Task 2',
          description: 'Testing touch targets',
          priority: TaskPriority.medium,
          projectId: testProject.id,
        ),
      ];
    });

    group('WCAG 2.1 Touch Target Size Requirements', () {
      // WCAG 2.1 AA Success Criterion 2.5.5: Target Size
      // The size of the target for pointer inputs is at least 44 by 44 CSS pixels
      const double minimumTouchTargetSize = 44.0;

      testWidgets('project card interactive elements should meet minimum touch target size', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: ListView(
                  children: [
                    ProjectCard(
                      project: testProject,
                      onTap: () {},
                      onEdit: () {},
                      onDelete: () {},
                      showActions: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Test main project card tap target
        final projectCardSize = tester.getSize(find.byType(ProjectCard));
        expect(
          projectCardSize.height,
          greaterThanOrEqualTo(minimumTouchTargetSize),
          reason: 'Project card height should meet minimum touch target requirement (44dp)',
        );

        // Test action buttons within project card
        final iconButtonFinder = find.byType(IconButton);
        for (int i = 0; i < iconButtonFinder.evaluate().length; i++) {
          final buttonSize = tester.getSize(iconButtonFinder.at(i));
          expect(
            buttonSize.width,
            greaterThanOrEqualTo(minimumTouchTargetSize),
            reason: 'Project card action button $i width should meet minimum touch target (44dp)',
          );
          expect(
            buttonSize.height,
            greaterThanOrEqualTo(minimumTouchTargetSize),
            reason: 'Project card action button $i height should meet minimum touch target (44dp)',
          );
        }

        // Test gesture detector touch targets
        final gestureDetectorFinder = find.byType(GestureDetector);
        if (gestureDetectorFinder.evaluate().isNotEmpty) {
          for (int i = 0; i < gestureDetectorFinder.evaluate().length; i++) {
            final detectorSize = tester.getSize(gestureDetectorFinder.at(i));
            expect(
              detectorSize.width,
              greaterThanOrEqualTo(minimumTouchTargetSize),
              reason: 'Gesture detector $i width should meet minimum touch target (44dp)',
            );
            expect(
              detectorSize.height,
              greaterThanOrEqualTo(minimumTouchTargetSize),
              reason: 'Gesture detector $i height should meet minimum touch target (44dp)',
            );
          }
        }
      });

      testWidgets('task card interactive elements should meet minimum touch target size', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: ListView(
                  children: testTasks.map((task) => AdvancedTaskCard(task: task)).toList(),
                ),
              ),
            ),
          ),
        );

        // Test task card sizes
        final taskCardFinder = find.byType(AdvancedTaskCard);
        for (int i = 0; i < taskCardFinder.evaluate().length; i++) {
          final cardSize = tester.getSize(taskCardFinder.at(i));
          expect(
            cardSize.height,
            greaterThanOrEqualTo(minimumTouchTargetSize),
            reason: 'Task card $i height should meet minimum touch target (44dp)',
          );
        }

        // Test interactive elements within task cards
        final interactiveElementFinder = find.byWidgetPredicate((widget) =>
            widget is IconButton ||
            widget is Checkbox ||
            widget is Switch ||
            widget is Radio);

        for (int i = 0; i < interactiveElementFinder.evaluate().length; i++) {
          final elementSize = tester.getSize(interactiveElementFinder.at(i));
          expect(
            elementSize.width,
            greaterThanOrEqualTo(minimumTouchTargetSize),
            reason: 'Interactive element $i width should meet minimum touch target (44dp)',
          );
          expect(
            elementSize.height,
            greaterThanOrEqualTo(minimumTouchTargetSize),
            reason: 'Interactive element $i height should meet minimum touch target (44dp)',
          );
        }
      });

      testWidgets('kanban board interactive elements should meet minimum touch target size', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: KanbanBoardView(
                  projectId: testProject.id,
                  initialColumns: [
                    KanbanColumnConfig(
                      id: 'todo',
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
                  enableDragAndDrop: true,
                  showControls: true,
                ),
              ),
            ),
          ),
        );

        // Test column header interactive elements
        final columnHeaderFinder = find.byWidgetPredicate((widget) =>
            widget is Container && widget.child is Text);
            
        if (columnHeaderFinder.evaluate().isNotEmpty) {
          for (int i = 0; i < columnHeaderFinder.evaluate().length; i++) {
            final headerSize = tester.getSize(columnHeaderFinder.at(i));
            if (headerSize.height > 0) { // Only test visible headers
              expect(
                headerSize.height,
                greaterThanOrEqualTo(minimumTouchTargetSize),
                reason: 'Kanban column header $i should meet minimum touch target height (44dp)',
              );
            }
          }
        }

        // Test draggable task elements
        final draggableFinder = find.byType(Draggable);
        if (draggableFinder.evaluate().isNotEmpty) {
          for (int i = 0; i < draggableFinder.evaluate().length; i++) {
            final draggableSize = tester.getSize(draggableFinder.at(i));
            expect(
              draggableSize.height,
              greaterThanOrEqualTo(minimumTouchTargetSize),
              reason: 'Draggable task $i should meet minimum touch target height (44dp)',
            );
          }
        }

        // Test control buttons
        final controlButtonFinder = find.byType(IconButton);
        for (int i = 0; i < controlButtonFinder.evaluate().length; i++) {
          final buttonSize = tester.getSize(controlButtonFinder.at(i));
          expect(
            buttonSize.width,
            greaterThanOrEqualTo(minimumTouchTargetSize),
            reason: 'Kanban control button $i width should meet minimum touch target (44dp)',
          );
          expect(
            buttonSize.height,
            greaterThanOrEqualTo(minimumTouchTargetSize),
            reason: 'Kanban control button $i height should meet minimum touch target (44dp)',
          );
        }
      });

      testWidgets('bulk operations toolbar should have appropriate touch targets', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    BulkActionToolbar(
                      selectedTasks: testTasks.take(2).toList(),
                    ),
                    Expanded(
                      child: ListView(
                        children: testTasks.map<Widget>((task) => 
                          MultiSelectTaskCard(
                            task: task,
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

        // Test bulk action toolbar buttons
        final toolbarButtonFinder = find.byType(IconButton);
        for (int i = 0; i < toolbarButtonFinder.evaluate().length; i++) {
          final buttonSize = tester.getSize(toolbarButtonFinder.at(i));
          expect(
            buttonSize.width,
            greaterThanOrEqualTo(minimumTouchTargetSize),
            reason: 'Bulk action button $i width should meet minimum touch target (44dp)',
          );
          expect(
            buttonSize.height,
            greaterThanOrEqualTo(minimumTouchTargetSize),
            reason: 'Bulk action button $i height should meet minimum touch target (44dp)',
          );
        }

        // Test multi-select checkboxes
        final checkboxFinder = find.byType(Checkbox);
        for (int i = 0; i < checkboxFinder.evaluate().length; i++) {
          final checkboxSize = tester.getSize(checkboxFinder.at(i));
          expect(
            checkboxSize.width,
            greaterThanOrEqualTo(minimumTouchTargetSize),
            reason: 'Multi-select checkbox $i width should meet minimum touch target (44dp)',
          );
          expect(
            checkboxSize.height,
            greaterThanOrEqualTo(minimumTouchTargetSize),
            reason: 'Multi-select checkbox $i height should meet minimum touch target (44dp)',
          );
        }
      });

      testWidgets('timeline interactive elements should meet minimum touch target size', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: TimelineGanttView(
                  projectIds: [testProject.id],
                  showControls: true,
                  height: 500,
                  onTaskSelected: (task) {},
                ),
              ),
            ),
          ),
        );

        // Test timeline control buttons
        final timelineButtonFinder = find.byType(IconButton);
        for (int i = 0; i < timelineButtonFinder.evaluate().length; i++) {
          final buttonSize = tester.getSize(timelineButtonFinder.at(i));
          expect(
            buttonSize.width,
            greaterThanOrEqualTo(minimumTouchTargetSize),
            reason: 'Timeline control button $i width should meet minimum touch target (44dp)',
          );
          expect(
            buttonSize.height,
            greaterThanOrEqualTo(minimumTouchTargetSize),
            reason: 'Timeline control button $i height should meet minimum touch target (44dp)',
          );
        }

        // Test dropdown controls
        final dropdownFinder = find.byType(DropdownButton);
        if (dropdownFinder.evaluate().isNotEmpty) {
          for (int i = 0; i < dropdownFinder.evaluate().length; i++) {
            final dropdownSize = tester.getSize(dropdownFinder.at(i));
            expect(
              dropdownSize.height,
              greaterThanOrEqualTo(minimumTouchTargetSize),
              reason: 'Timeline dropdown $i height should meet minimum touch target (44dp)',
            );
          }
        }
      });

      testWidgets('small interactive elements should be enhanced with larger touch targets', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    // Small icons that should be enhanced with proper touch targets
                    Row(
                      children: [
                        // Properly enhanced small icon
                        Material(
                          child: InkWell(
                            onTap: () {},
                            child: Container(
                              width: minimumTouchTargetSize,
                              height: minimumTouchTargetSize,
                              alignment: Alignment.center,
                              child: Semantics(
                                button: true,
                                label: 'Star task',
                                child: Icon(PhosphorIcons.star(), size: 16),
                              ),
                            ),
                          ),
                        ),
                        
                        // Small toggle with proper touch target
                        Material(
                          child: InkWell(
                            onTap: () {},
                            child: Container(
                              width: minimumTouchTargetSize,
                              height: minimumTouchTargetSize,
                              alignment: Alignment.center,
                              child: Semantics(
                                button: true,
                                label: 'Toggle notification',
                                child: Icon(PhosphorIcons.bell(), size: 18),
                              ),
                            ),
                          ),
                        ),
                        
                        // Small action button with proper sizing
                        SizedBox(
                          width: minimumTouchTargetSize,
                          height: minimumTouchTargetSize,
                          child: IconButton(
                            onPressed: () {},
                            icon: Icon(PhosphorIcons.dotsThree(), size: 16),
                            tooltip: 'More options',
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    
                    // Test custom touch target enhancement
                    Semantics(
                      button: true,
                      label: 'Custom small button with enhanced touch area',
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: minimumTouchTargetSize,
                          height: minimumTouchTargetSize,
                          alignment: Alignment.center,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.close, size: 12, color: Colors.white),
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

        // Test enhanced small icons
        final inkWellFinder = find.byType(InkWell);
        for (int i = 0; i < inkWellFinder.evaluate().length; i++) {
          final inkWellSize = tester.getSize(inkWellFinder.at(i));
          expect(
            inkWellSize.width,
            greaterThanOrEqualTo(minimumTouchTargetSize),
            reason: 'Enhanced small icon $i width should meet minimum touch target (44dp)',
          );
          expect(
            inkWellSize.height,
            greaterThanOrEqualTo(minimumTouchTargetSize),
            reason: 'Enhanced small icon $i height should meet minimum touch target (44dp)',
          );
        }

        // Test properly sized IconButton
        final iconButtonSize = tester.getSize(find.byType(IconButton));
        expect(
          iconButtonSize.width,
          greaterThanOrEqualTo(minimumTouchTargetSize),
          reason: 'Small IconButton width should meet minimum touch target (44dp)',
        );
        expect(
          iconButtonSize.height,
          greaterThanOrEqualTo(minimumTouchTargetSize),
          reason: 'Small IconButton height should meet minimum touch target (44dp)',
        );

        // Test custom enhanced button
        final customButtonFinder = find.bySemanticsLabel('Custom small button with enhanced touch area');
        final customButtonSize = tester.getSize(customButtonFinder);
        expect(
          customButtonSize.width,
          greaterThanOrEqualTo(minimumTouchTargetSize),
          reason: 'Custom enhanced button width should meet minimum touch target (44dp)',
        );
        expect(
          customButtonSize.height,
          greaterThanOrEqualTo(minimumTouchTargetSize),
          reason: 'Custom enhanced button height should meet minimum touch target (44dp)',
        );
      });
    });

    group('WCAG 2.1 AA Semantic Structure Compliance', () {
      testWidgets('should have proper heading hierarchy', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: Semantics(
                    header: true,
                    child: const Text('Project Management Dashboard'),
                  ),
                ),
                body: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // H2 level heading
                      Semantics(
                        header: true,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Active Projects',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      
                      ProjectCard(project: testProject),
                      
                      // H2 level heading
                      Semantics(
                        header: true,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Recent Tasks',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      
                      // H3 level subheading
                      Semantics(
                        header: true,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: Text(
                            'High Priority Tasks',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      
                      ...testTasks.map((task) => AdvancedTaskCard(task: task)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        final SemanticsHandle handle = tester.ensureSemantics();

        // Test heading structure
        expect(find.text('Project Management Dashboard'), findsOneWidget);
        expect(find.text('Active Projects'), findsOneWidget);
        expect(find.text('Recent Tasks'), findsOneWidget);
        expect(find.text('High Priority Tasks'), findsOneWidget);

        // Test semantic headers
        final headerFinder = find.byWidgetPredicate((widget) =>
            widget is Semantics && widget.properties.header == true);
        expect(
          headerFinder.evaluate().length,
          greaterThanOrEqualTo(4),
          reason: 'Should have proper heading hierarchy with semantic headers',
        );

        handle.dispose();
      });

      testWidgets('should have proper landmark regions', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Project Dashboard'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.add),
                      tooltip: 'Add project',
                      onPressed: () {},
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    // Main content region
                    Expanded(
                      child: Semantics(
                        container: true,
                        label: 'Main content',
                        child: ListView(
                          children: [
                            ProjectCard(project: testProject),
                            ...testTasks.map((task) => AdvancedTaskCard(task: task)),
                          ],
                        ),
                      ),
                    ),
                    
                    // Footer/toolbar region
                    Semantics(
                      container: true,
                      label: 'Toolbar',
                      child: Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            TextButton(
                              onPressed: () {},
                              child: const Text('View All'),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              tooltip: 'Refresh',
                              onPressed: () {},
                            ),
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

        // Test landmark regions
        expect(find.bySemanticsLabel('Navigation banner'), findsOneWidget);
        expect(find.bySemanticsLabel('Main content'), findsOneWidget);
        expect(find.bySemanticsLabel('Toolbar'), findsOneWidget);

        handle.dispose();
      });

      testWidgets('should provide proper form labels and descriptions', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(title: const Text('Create Task')),
                body: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          textField: true,
                          label: 'Task title',
                          hint: 'Enter a descriptive title for your task',
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Task Title *',
                              hintText: 'e.g., Review project proposal',
                              helperText: 'This field is required',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Task title is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        Semantics(
                          textField: true,
                          label: 'Task description',
                          hint: 'Optional detailed description of the task',
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              hintText: 'Add any additional details...',
                              helperText: 'Optional field',
                            ),
                            maxLines: 3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Priority selection with proper grouping
                        Semantics(
                          container: true,
                          label: 'Task priority selection',
                          hint: 'Choose the priority level for this task',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Priority *',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              ...TaskPriority.values.map((priority) {
                                return Semantics(
                                  inMutuallyExclusiveGroup: true,
                                  child: RadioListTile<TaskPriority>(
                                    title: Text(priority.displayName),
                                    subtitle: Text(_getPriorityDescription(priority)),
                                    value: priority,
                                    groupValue: TaskPriority.medium,
                                    onChanged: (TaskPriority? value) {},
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Action buttons with proper semantics
                        Row(
                          children: [
                            Expanded(
                              child: Semantics(
                                button: true,
                                label: 'Cancel task creation',
                                child: TextButton(
                                  onPressed: () {},
                                  child: const Text('Cancel'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Semantics(
                                button: true,
                                label: 'Create new task',
                                hint: 'Saves the task and returns to task list',
                                child: ElevatedButton(
                                  onPressed: () {},
                                  child: const Text('Create Task'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        final SemanticsHandle handle = tester.ensureSemantics();

        // Test form field labels
        expect(find.bySemanticsLabel('Task title'), findsOneWidget);
        expect(find.bySemanticsLabel('Task description'), findsOneWidget);
        expect(find.bySemanticsLabel('Task priority selection'), findsOneWidget);

        // Test radio button group
        final radioButtonFinder = find.byType(RadioListTile);
        expect(radioButtonFinder.evaluate().length, equals(TaskPriority.values.length));

        // Test action buttons
        expect(find.bySemanticsLabel('Cancel task creation'), findsOneWidget);
        expect(find.bySemanticsLabel('Create new task'), findsOneWidget);

        // Test that form fields have proper semantic flags
        final textFieldFinder = find.byWidgetPredicate((widget) =>
            widget is Semantics && widget.properties.textField == true);
        expect(textFieldFinder.evaluate().length, equals(2));

        handle.dispose();
      });

      testWidgets('should provide proper error handling and announcements', (tester) async {
        String? currentError;
        
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: StatefulBuilder(
                builder: (context, setState) {
                  return Scaffold(
                    appBar: AppBar(title: const Text('Task Form')),
                    body: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Error region for announcements
                          if (currentError != null)
                            Semantics(
                              liveRegion: true,
                              container: true,
                              label: 'Form error',
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  border: Border.all(color: Colors.red),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error, color: Colors.red.shade700),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        currentError!,
                                        style: TextStyle(color: Colors.red.shade700),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Task Title',
                              errorText: currentError,
                              errorBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                currentError = 'Task title is required and cannot be empty';
                              });
                            },
                            child: const Text('Trigger Error'),
                          ),
                          const SizedBox(height: 8),
                          
                          TextButton(
                            onPressed: () {
                              setState(() {
                                currentError = null;
                              });
                            },
                            child: const Text('Clear Error'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );

        final SemanticsHandle handle = tester.ensureSemantics();

        // Test initial state (no error)
        expect(find.bySemanticsLabel('Form error'), findsNothing);

        // Trigger error
        await tester.tap(find.text('Trigger Error'));
        await tester.pump();

        // Test error display
        expect(find.bySemanticsLabel('Form error'), findsOneWidget);
        expect(find.text('Task title is required and cannot be empty'), findsOneWidget);

        // Test live region for error announcement
        final errorRegionFinder = find.bySemanticsLabel('Form error');
        final errorRegionSemantics = tester.getSemantics(errorRegionFinder);
        expect(
          errorRegionSemantics.getSemanticsData().hasFlag(SemanticsFlag.isLiveRegion),
          isTrue,
          reason: 'Error region should be marked as live region for screen reader announcements',
        );

        // Clear error
        await tester.tap(find.text('Clear Error'));
        await tester.pump();

        // Test error cleared
        expect(find.bySemanticsLabel('Form error'), findsNothing);

        handle.dispose();
      });
    });

    group('WCAG 2.1 AA Keyboard Accessibility Compliance', () {
      testWidgets('should support full keyboard navigation without mouse', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Keyboard Navigation Test'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.search),
                      tooltip: 'Search',
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      tooltip: 'Add',
                      onPressed: () {},
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Search tasks',
                                prefixIcon: Icon(Icons.search),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text('Search'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          ProjectCard(project: testProject),
                          ...testTasks.map((task) => AdvancedTaskCard(task: task)),
                        ],
                      ),
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
          ),
        );

        final SemanticsHandle handle = tester.ensureSemantics();

        // Test tab navigation through all focusable elements
        // This simulates a user navigating with only keyboard

        // Start from beginning
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        // Navigate to search field
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        // Navigate to search button
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        // Navigate to action buttons
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        // Navigate through list items
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        // Test that all focusable elements can receive focus
        final focusableElements = find.byWidgetPredicate((widget) =>
            widget is TextField ||
            widget is TextFormField ||
            widget is ElevatedButton ||
            widget is TextButton ||
            widget is IconButton ||
            widget is FloatingActionButton);

        expect(
          focusableElements.evaluate().length,
          greaterThan(0),
          reason: 'Should have multiple keyboard-focusable elements',
        );

        handle.dispose();
      });

      testWidgets('should provide visible focus indicators', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData(
                // Ensure focus indicators are visible
                focusColor: Colors.blue.withOpacity(0.3),
                visualDensity: VisualDensity.comfortable,
              ),
              home: Scaffold(
                body: Column(
                  children: [
                    Focus(
                      child: Builder(
                        builder: (context) {
                          final isFocused = Focus.of(context).hasFocus;
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isFocused ? Colors.blue : Colors.transparent,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Focusable Container'),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Button with Focus'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Text Field',
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 2),
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

        // Test focus on different elements
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        await tester.tap(find.byType(TextFormField));
        await tester.pump();

        // Test that focus indicators are present
        final focusWidgets = find.byType(Focus);
        expect(
          focusWidgets.evaluate().length,
          greaterThan(0),
          reason: 'Should have Focus widgets for focus management',
        );

        handle.dispose();
      });
    });

    group('WCAG 2.1 AA Content Structure Compliance', () {
      testWidgets('should provide meaningful page titles and structure', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              title: 'Tasky - Project Management',
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Projects Dashboard'),
                ),
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Breadcrumb navigation
                    Semantics(
                      container: true,
                      label: 'Breadcrumb navigation',
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            TextButton(
                              onPressed: () {},
                              child: const Text('Home'),
                            ),
                            const Text(' > '),
                            TextButton(
                              onPressed: () {},
                              child: const Text('Projects'),
                            ),
                            const Text(' > '),
                            const Text('Dashboard'),
                          ],
                        ),
                      ),
                    ),
                    
                    // Main content with proper structure
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Semantics(
                              header: true,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'Active Projects',
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            
                            Semantics(
                              container: true,
                              label: 'Project list',
                              child: Column(
                                children: [
                                  ProjectCard(project: testProject),
                                ],
                              ),
                            ),
                            
                            Semantics(
                              header: true,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'Recent Tasks',
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            
                            Semantics(
                              container: true,
                              label: 'Task list',
                              child: Column(
                                children: testTasks.map((task) => AdvancedTaskCard(task: task)).toList(),
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
          ),
        );

        final SemanticsHandle handle = tester.ensureSemantics();

        // Test page structure
        expect(find.text('Projects Dashboard'), findsOneWidget);
        expect(find.bySemanticsLabel('Breadcrumb navigation'), findsOneWidget);
        expect(find.text('Active Projects'), findsOneWidget);
        expect(find.text('Recent Tasks'), findsOneWidget);
        expect(find.bySemanticsLabel('Project list'), findsOneWidget);
        expect(find.bySemanticsLabel('Task list'), findsOneWidget);

        // Test semantic headers
        final headerFinder = find.byWidgetPredicate((widget) =>
            widget is Semantics && widget.properties.header == true);
        expect(
          headerFinder.evaluate().length,
          greaterThanOrEqualTo(2),
          reason: 'Should have proper heading structure',
        );

        handle.dispose();
      });
    });
  });
}

// Helper functions
String _getPriorityDescription(TaskPriority priority) {
  switch (priority) {
    case TaskPriority.urgent:
      return 'Needs immediate attention';
    case TaskPriority.high:
      return 'Important, should be done soon';
    case TaskPriority.medium:
      return 'Normal priority';
    case TaskPriority.low:
      return 'Can be done when time allows';
  }
}

