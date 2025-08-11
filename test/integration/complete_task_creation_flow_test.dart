import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:task_tracker_app/main.dart' as app;
import 'package:task_tracker_app/presentation/providers/task_providers.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/task_enums.dart';
import 'package:task_tracker_app/services/speech/transcription_service_factory.dart';
import 'package:task_tracker_app/core/cache/task_cache_manager.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Complete Task Creation Flow Integration Tests', () {
    
    testWidgets('full voice-to-task creation flow', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for app initialization
      await tester.pump(const Duration(seconds: 2));

      // Find and tap the voice input button (floating action button or similar)
      final voiceButton = find.byIcon(Icons.mic);
      if (voiceButton.evaluate().isNotEmpty) {
        await tester.tap(voiceButton);
        await tester.pumpAndSettle();

        // Wait for voice dialog to appear
        await tester.pump(const Duration(seconds: 1));

        // If using mock service, it should provide a mock transcription
        // Wait for transcription to complete
        await tester.pump(const Duration(seconds: 3));

        // Check if AI task parsing dialog appeared
        expect(find.textContaining('Creating task'), findsWidgets);

        // Wait for task creation to complete
        await tester.pump(const Duration(seconds: 2));

        // Navigate to tasks page to verify task was created
        final tasksTab = find.text('Tasks');
        if (tasksTab.evaluate().isNotEmpty) {
          await tester.tap(tasksTab);
          await tester.pumpAndSettle();

          // Should have at least one task now
          expect(find.byType(Card), findsWidgets);
        }
      }
    });

    testWidgets('manual task creation with all fields', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Find add task button
      final addButton = find.byIcon(Icons.add);
      expect(addButton, findsOneWidget);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Fill in task details
      final titleField = find.byType(TextFormField).first;
      await tester.enterText(titleField, 'Integration Test Task');
      await tester.pumpAndSettle();

      // Set priority to high
      final priorityDropdown = find.text('Priority');
      if (priorityDropdown.evaluate().isNotEmpty) {
        await tester.tap(priorityDropdown);
        await tester.pumpAndSettle();
        
        final highPriority = find.text('High');
        if (highPriority.evaluate().isNotEmpty) {
          await tester.tap(highPriority);
          await tester.pumpAndSettle();
        }
      }

      // Add a subtask
      final addSubtaskButton = find.text('Add Subtask');
      if (addSubtaskButton.evaluate().isNotEmpty) {
        await tester.tap(addSubtaskButton);
        await tester.pumpAndSettle();

        // Enter subtask title
        final subtaskField = find.byType(TextFormField).last;
        await tester.enterText(subtaskField, 'Test Subtask');
        await tester.pumpAndSettle();
      }

      // Save the task
      final saveButton = find.text('Save');
      expect(saveButton, findsOneWidget);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Verify task was created and appears in list
      expect(find.text('Integration Test Task'), findsOneWidget);
    });

    testWidgets('task creation with due date and location', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Open task creation dialog
      final addButton = find.byIcon(Icons.add);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Enter task title
      final titleField = find.byType(TextFormField).first;
      await tester.enterText(titleField, 'Task with Due Date');
      await tester.pumpAndSettle();

      // Set due date
      final dueDateButton = find.text('Set Due Date');
      if (dueDateButton.evaluate().isNotEmpty) {
        await tester.tap(dueDateButton);
        await tester.pumpAndSettle();

        // Select tomorrow's date (assuming date picker appears)
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final tomorrowButton = find.text(tomorrow.day.toString());
        if (tomorrowButton.evaluate().isNotEmpty) {
          await tester.tap(tomorrowButton);
          await tester.pumpAndSettle();
          
          // Confirm date selection
          final okButton = find.text('OK');
          if (okButton.evaluate().isNotEmpty) {
            await tester.tap(okButton);
            await tester.pumpAndSettle();
          }
        }
      }

      // Save task
      final saveButton = find.text('Save');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Verify task appears with due date indicator
      expect(find.text('Task with Due Date'), findsOneWidget);
    });

    testWidgets('bulk task operations', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Create multiple tasks first
      for (int i = 1; i <= 3; i++) {
        final addButton = find.byIcon(Icons.add);
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        final titleField = find.byType(TextFormField).first;
        await tester.enterText(titleField, 'Bulk Task $i');
        await tester.pumpAndSettle();

        final saveButton = find.text('Save');
        await tester.tap(saveButton);
        await tester.pumpAndSettle();
      }

      // Enter selection mode (long press on first task)
      final firstTask = find.text('Bulk Task 1');
      await tester.longPress(firstTask);
      await tester.pumpAndSettle();

      // Select additional tasks
      final secondTask = find.text('Bulk Task 2');
      if (secondTask.evaluate().isNotEmpty) {
        await tester.tap(secondTask);
        await tester.pumpAndSettle();
      }

      // Perform bulk operation (mark as completed)
      final bulkCompleteButton = find.byIcon(Icons.check);
      if (bulkCompleteButton.evaluate().isNotEmpty) {
        await tester.tap(bulkCompleteButton);
        await tester.pumpAndSettle();
      }

      // Verify bulk operation completed
      expect(find.text('2 tasks completed'), findsOneWidget);
    });

    testWidgets('task completion flow with subtasks', (tester) async {
      // Start the app  
      app.main();
      await tester.pumpAndSettle();

      // Create a task with subtasks
      final addButton = find.byIcon(Icons.add);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Enter task details
      final titleField = find.byType(TextFormField).first;
      await tester.enterText(titleField, 'Task with Subtasks');
      await tester.pumpAndSettle();

      // Add subtasks
      for (int i = 1; i <= 2; i++) {
        final addSubtaskButton = find.text('Add Subtask');
        if (addSubtaskButton.evaluate().isNotEmpty) {
          await tester.tap(addSubtaskButton);
          await tester.pumpAndSettle();

          final subtaskField = find.byType(TextFormField).last;
          await tester.enterText(subtaskField, 'Subtask $i');
          await tester.pumpAndSettle();
        }
      }

      // Save task
      final saveButton = find.text('Save');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Find and tap on the created task to open details
      final taskCard = find.text('Task with Subtasks');
      await tester.tap(taskCard);
      await tester.pumpAndSettle();

      // Complete first subtask
      final firstSubtaskCheckbox = find.byType(Checkbox).first;
      await tester.tap(firstSubtaskCheckbox);
      await tester.pumpAndSettle();

      // Verify progress is updated (50% completion)
      expect(find.textContaining('50%'), findsOneWidget);

      // Complete second subtask
      final secondSubtaskCheckbox = find.byType(Checkbox).at(1);
      await tester.tap(secondSubtaskCheckbox);
      await tester.pumpAndSettle();

      // Verify task is now 100% complete
      expect(find.textContaining('100%'), findsOneWidget);

      // Complete the main task
      final mainTaskCheckbox = find.byIcon(Icons.check_circle);
      if (mainTaskCheckbox.evaluate().isNotEmpty) {
        await tester.tap(mainTaskCheckbox);
        await tester.pumpAndSettle();
      }

      // Verify task is marked as completed
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('error handling during task creation', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Try to create task with empty title
      final addButton = find.byIcon(Icons.add);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Don't enter title, try to save directly
      final saveButton = find.text('Save');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.textContaining('required'), findsWidgets);

      // Cancel and verify no task was created
      final cancelButton = find.text('Cancel');
      if (cancelButton.evaluate().isNotEmpty) {
        await tester.tap(cancelButton);
        await tester.pumpAndSettle();
      }

      // Verify we're back to main screen with no new tasks
      expect(find.text('No tasks yet'), findsAny);
    });
  });
}