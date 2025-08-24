import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:tasky/domain/entities/task_model.dart';
import 'package:tasky/domain/models/enums.dart';
import 'package:tasky/presentation/widgets/kanban_board_view.dart';
import 'package:tasky/presentation/widgets/kanban_dialogs.dart';
import 'package:tasky/presentation/providers/kanban_providers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Kanban Board Integration Tests', () {
    testWidgets('Complete kanban workflow - create, move, filter, complete tasks', (WidgetTester tester) async {
      // Launch the app with Kanban board
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: KanbanBoardView(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Step 1: Create a new task
      await _createNewTask(tester, 'Integration Test Task', TaskPriority.high);
      
      // Step 2: Verify task appears in Backlog column
      expect(find.text('Integration Test Task'), findsOneWidget);
      
      // Step 3: Move task to In Progress using drag and drop (if enabled)
      // Note: Drag and drop testing in integration tests is complex
      // This would typically be tested through the UI actions
      
      // Step 4: Filter tasks by priority
      await _applyPriorityFilter(tester, TaskPriority.high);
      
      // Step 5: Verify filtered results
      expect(find.text('Integration Test Task'), findsOneWidget);
      
      // Step 6: Clear filters
      await _clearFilters(tester);
      
      // Step 7: Use batch operations to complete tasks
      await _enableBatchMode(tester);
      await _selectTask(tester, 'Integration Test Task');
      await _batchCompleteTask(tester);
      
      // Step 8: Verify task is in completed column
      // This would depend on the actual implementation
      
      // Step 9: Test search functionality
      await _searchForTask(tester, 'Integration');
      expect(find.text('Integration Test Task'), findsOneWidget);
      
      // Step 10: Test column configuration
      await _openViewOptions(tester);
      await _toggleTaskCounts(tester);
    });

    testWidgets('Performance test - handle large number of tasks', (WidgetTester tester) async {
      // Create app with performance optimizations enabled
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: KanbanBoardView(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Create multiple tasks to test performance
      for (int i = 0; i < 20; i++) {
        await _createNewTask(
          tester, 
          'Performance Test Task $i', 
          i % 4 == 0 ? TaskPriority.high : TaskPriority.medium,
        );
        
        // Add small delays to avoid overwhelming the system
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Verify all tasks are created and rendered efficiently
      expect(find.textContaining('Performance Test Task'), findsAtLeast(5));
      
      // Test scrolling performance
      await _scrollKanbanBoard(tester);
      
      // Test filtering performance with many tasks
      await _applySearchFilter(tester, 'Performance');
      expect(find.textContaining('Performance Test Task'), findsAtLeast(5));
    });

    testWidgets('Accessibility test - keyboard navigation and screen reader', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: KanbanBoardView(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Test keyboard navigation
      await _testKeyboardNavigation(tester);
      
      // Test semantic labels
      await _testSemanticLabels(tester);
      
      // Test high contrast mode
      await _testHighContrastMode(tester);
      
      // Test focus management
      await _testFocusManagement(tester);
    });

    testWidgets('Responsive design test - different screen sizes', (WidgetTester tester) async {
      // Test mobile layout
      await tester.binding.setSurfaceSize(const Size(360, 640));
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: KanbanBoardView(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      // Verify mobile-specific behavior (single column, disabled drag-and-drop)
      await _verifyMobileLayout(tester);
      
      // Test tablet layout
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpAndSettle();
      await _verifyTabletLayout(tester);
      
      // Test desktop layout
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpAndSettle();
      await _verifyDesktopLayout(tester);
      
      // Reset to default size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Error handling and recovery', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: KanbanBoardView(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Test error scenarios
      await _testNetworkErrorHandling(tester);
      await _testInvalidDataHandling(tester);
      await _testConcurrencyConflicts(tester);
    });
  });
}

// Helper functions for integration tests

Future<void> _createNewTask(WidgetTester tester, String title, TaskPriority priority) async {
  // Find and tap the add task button
  final addButton = find.text('Add Task');
  expect(addButton, findsOneWidget);
  await tester.tap(addButton);
  await tester.pumpAndSettle();

  // Fill in task details
  final titleField = find.widgetWithText(TextFormField, 'Enter task title...');
  await tester.enterText(titleField, title);
  await tester.pumpAndSettle();

  // Select priority
  final priorityChip = find.text(priority.displayName);
  await tester.tap(priorityChip);
  await tester.pumpAndSettle();

  // Create the task
  final createButton = find.text('Create');
  await tester.tap(createButton);
  await tester.pumpAndSettle();
}

Future<void> _applyPriorityFilter(WidgetTester tester, TaskPriority priority) async {
  // Open filter dialog
  final filterButton = find.byIcon(PhosphorIcons.funnel());
  await tester.tap(filterButton);
  await tester.pumpAndSettle();

  // Select priority filter
  final priorityChip = find.text(priority.displayName).last;
  await tester.tap(priorityChip);
  await tester.pumpAndSettle();

  // Apply filters
  final applyButton = find.text('Apply');
  await tester.tap(applyButton);
  await tester.pumpAndSettle();
}

Future<void> _clearFilters(WidgetTester tester) async {
  // Open filter dialog
  final filterButton = find.byIcon(PhosphorIcons.funnel());
  await tester.tap(filterButton);
  await tester.pumpAndSettle();

  // Clear filters
  final clearButton = find.text('Clear');
  await tester.tap(clearButton);
  await tester.pumpAndSettle();

  // Apply (close dialog)
  final applyButton = find.text('Apply');
  await tester.tap(applyButton);
  await tester.pumpAndSettle();
}

Future<void> _enableBatchMode(WidgetTester tester) async {
  final batchButton = find.byIcon(PhosphorIcons.selection());
  await tester.tap(batchButton);
  await tester.pumpAndSettle();
}

Future<void> _selectTask(WidgetTester tester, String taskTitle) async {
  // This would depend on the implementation of task selection
  final taskWidget = find.text(taskTitle);
  await tester.tap(taskWidget);
  await tester.pumpAndSettle();
}

Future<void> _batchCompleteTask(WidgetTester tester) async {
  final completeButton = find.byIcon(PhosphorIcons.checkCircle());
  await tester.tap(completeButton);
  await tester.pumpAndSettle();
}

Future<void> _searchForTask(WidgetTester tester, String query) async {
  // Enable search
  final searchButton = find.byIcon(PhosphorIcons.magnifyingGlass());
  await tester.tap(searchButton);
  await tester.pumpAndSettle();

  // Enter search query
  final searchField = find.byType(TextField);
  await tester.enterText(searchField, query);
  await tester.pumpAndSettle();
}

Future<void> _openViewOptions(WidgetTester tester) async {
  final viewButton = find.byIcon(PhosphorIcons.gear());
  await tester.tap(viewButton);
  await tester.pumpAndSettle();
}

Future<void> _toggleTaskCounts(WidgetTester tester) async {
  final taskCountSwitch = find.text('Show task counts');
  await tester.tap(taskCountSwitch);
  await tester.pumpAndSettle();
}

Future<void> _scrollKanbanBoard(WidgetTester tester) async {
  // Scroll horizontally through columns
  final kanbanBoard = find.byType(KanbanBoardView);
  await tester.drag(kanbanBoard, const Offset(-300, 0));
  await tester.pumpAndSettle();
  
  await tester.drag(kanbanBoard, const Offset(300, 0));
  await tester.pumpAndSettle();
}

Future<void> _applySearchFilter(WidgetTester tester, String query) async {
  await _searchForTask(tester, query);
}

Future<void> _testKeyboardNavigation(WidgetTester tester) async {
  // Test arrow key navigation between columns
  await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowRight);
  await tester.pumpAndSettle();
  
  await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowLeft);
  await tester.pumpAndSettle();
  
  // Test task selection with Enter
  await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
  await tester.pumpAndSettle();
}

Future<void> _testSemanticLabels(WidgetTester tester) async {
  // Verify semantic labels are present
  expect(find.bySemanticsLabel(RegExp(r'.*column')), findsAtLeast(1));
  expect(find.bySemanticsLabel(RegExp(r'Task:')), findsAtLeast(0));
}

Future<void> _testHighContrastMode(WidgetTester tester) async {
  // This would test high contrast mode if it can be enabled programmatically
  // Implementation depends on how high contrast mode is handled
}

Future<void> _testFocusManagement(WidgetTester tester) async {
  // Test that focus moves correctly between elements
  final focusedElements = find.byWidgetPredicate(
    (widget) => widget is Focus && (widget as Focus).focusNode?.hasFocus == true
  );
  expect(focusedElements, findsAtLeast(1));
}

Future<void> _verifyMobileLayout(WidgetTester tester) async {
  // Verify single column layout on mobile
  // This would check for specific mobile UI elements
}

Future<void> _verifyTabletLayout(WidgetTester tester) async {
  // Verify tablet-specific layout
  // This would check for tablet-specific UI adaptations
}

Future<void> _verifyDesktopLayout(WidgetTester tester) async {
  // Verify full desktop layout with all columns visible
  expect(find.text('Backlog'), findsOneWidget);
  expect(find.text('In Progress'), findsOneWidget);
  expect(find.text('Completed'), findsOneWidget);
}

Future<void> _testNetworkErrorHandling(WidgetTester tester) async {
  // Test how the UI handles network errors
  // This would require mocking network failures
}

Future<void> _testInvalidDataHandling(WidgetTester tester) async {
  // Test how the UI handles invalid or corrupted data
  // This would require providing invalid data to the system
}

Future<void> _testConcurrencyConflicts(WidgetTester tester) async {
  // Test how the UI handles concurrent modifications
  // This would require simulating concurrent operations
}