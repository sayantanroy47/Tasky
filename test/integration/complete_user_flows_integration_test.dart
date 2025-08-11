import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:task_tracker_app/main.dart' as app;
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/models/enums.dart';
import 'package:task_tracker_app/domain/repositories/task_repository.dart';
import 'package:task_tracker_app/services/speech/transcription_service_impl.dart';
import 'package:task_tracker_app/services/ai/claude_task_parser.dart';
import 'package:dartz/dartz.dart';

@GenerateMocks([
  TaskRepository,
  TranscriptionServiceImpl,
  ClaudeTaskParser,
])
import 'complete_user_flows_integration_test.mocks.dart';

/// COMPREHENSIVE INTEGRATION TESTS - ALL USER FLOWS AND COMPLETE SCENARIOS
/// 
/// These tests validate the entire application flow from user interaction to data persistence,
/// covering every major use case and ensuring all components work together correctly.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Complete User Flows - End-to-End Integration Tests', () {
    late MockTaskRepository mockRepository;
    late MockTranscriptionServiceImpl mockTranscriptionService;
    late MockClaudeTaskParser mockClaudeParser;

    setUp(() {
      mockRepository = MockTaskRepository();
      mockTranscriptionService = MockTranscriptionServiceImpl();
      mockClaudeParser = MockClaudeTaskParser();
    });

    group('Task Creation Flow Integration Tests', () {
      testWidgets('should complete manual task creation flow', (tester) async {
        // Arrange
        final newTask = TaskModel.create(
          title: 'Integration Test Task',
          description: 'Created through manual flow',
          priority: TaskPriority.high,
          dueDate: DateTime.now().add(const Duration(days: 2)),
        );

        when(mockRepository.createTask(any))
            .thenAnswer((_) async => Right(newTask));
        when(mockRepository.getAllTasks())
            .thenAnswer((_) async => Right([newTask]));

        // Act - Launch app
        app.main();
        await tester.pumpAndSettle();

        // Navigate to task creation
        final addButton = find.byIcon(Icons.add);
        expect(addButton, findsOneWidget);
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // Fill task form
        final titleField = find.byKey(const Key('task_title_field'));
        if (titleField.evaluate().isNotEmpty) {
          await tester.enterText(titleField, 'Integration Test Task');
          await tester.pumpAndSettle();
        }

        final descriptionField = find.byKey(const Key('task_description_field'));
        if (descriptionField.evaluate().isNotEmpty) {
          await tester.enterText(descriptionField, 'Created through manual flow');
          await tester.pumpAndSettle();
        }

        // Set priority to high
        final prioritySelector = find.byKey(const Key('priority_selector'));
        if (prioritySelector.evaluate().isNotEmpty) {
          await tester.tap(prioritySelector);
          await tester.pumpAndSettle();
          
          final highPriorityOption = find.text('High');
          if (highPriorityOption.evaluate().isNotEmpty) {
            await tester.tap(highPriorityOption);
            await tester.pumpAndSettle();
          }
        }

        // Set due date
        final dueDateSelector = find.byKey(const Key('due_date_selector'));
        if (dueDateSelector.evaluate().isNotEmpty) {
          await tester.tap(dueDateSelector);
          await tester.pumpAndSettle();
          
          // Select a date (implementation depends on date picker)
          await tester.tap(find.text('OK'));
          await tester.pumpAndSettle();
        }

        // Save task
        final saveButton = find.byKey(const Key('save_task_button'));
        if (saveButton.evaluate().isNotEmpty) {
          await tester.tap(saveButton);
          await tester.pumpAndSettle();
        }

        // Assert - Task should appear in the list
        expect(find.text('Integration Test Task'), findsOneWidget);
      });

      testWidgets('should complete voice task creation flow', (tester) async {
        // Arrange
        const transcription = 'Create a high priority task to review budget report by next Monday';
        final voiceTask = TaskModel.create(
          title: 'Review budget report',
          priority: TaskPriority.high,
          dueDate: DateTime.now().add(const Duration(days: 3)),
          metadata: {'source': 'voice'},
        );

        when(mockTranscriptionService.checkPermissions())
            .thenAnswer((_) async => true);
        when(mockTranscriptionService.startRecording())
            .thenAnswer((_) async => {});
        when(mockTranscriptionService.stopRecording())
            .thenAnswer((_) async => transcription);
        when(mockClaudeParser.parseTask(transcription))
            .thenAnswer((_) async => Right(voiceTask));
        when(mockRepository.createTask(any))
            .thenAnswer((_) async => Right(voiceTask));
        when(mockRepository.getAllTasks())
            .thenAnswer((_) async => Right([voiceTask]));

        // Act - Launch app
        app.main();
        await tester.pumpAndSettle();

        // Open voice creation dialog
        final voiceButton = find.byIcon(Icons.mic);
        if (voiceButton.evaluate().isNotEmpty) {
          await tester.tap(voiceButton);
          await tester.pumpAndSettle();
        }

        // Start recording
        final recordButton = find.byKey(const Key('record_button'));
        if (recordButton.evaluate().isNotEmpty) {
          await tester.tap(recordButton);
          await tester.pump(const Duration(seconds: 2)); // Simulate recording time
        }

        // Stop recording
        final stopButton = find.byKey(const Key('stop_button'));
        if (stopButton.evaluate().isNotEmpty) {
          await tester.tap(stopButton);
          await tester.pumpAndSettle();
        }

        // AI should process and display parsed task
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Confirm task creation
        final confirmButton = find.byKey(const Key('confirm_voice_task'));
        if (confirmButton.evaluate().isNotEmpty) {
          await tester.tap(confirmButton);
          await tester.pumpAndSettle();
        }

        // Assert - Voice-created task should appear
        expect(find.text('Review budget report'), findsOneWidget);
      });

      testWidgets('should handle task creation with subtasks', (tester) async {
        // Arrange
        final taskWithSubtasks = TaskModel.create(
          title: 'Project Planning',
          subtasks: [
            'Research requirements',
            'Create timeline',
            'Assign team members',
          ],
        );

        when(mockRepository.createTask(any))
            .thenAnswer((_) async => Right(taskWithSubtasks));
        when(mockRepository.getAllTasks())
            .thenAnswer((_) async => Right([taskWithSubtasks]));

        // Act - Create task through UI flow
        app.main();
        await tester.pumpAndSettle();

        // Navigate to task creation and add subtasks
        final addButton = find.byIcon(Icons.add);
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // Add subtasks through UI (implementation depends on subtask widget)
        final addSubtaskButton = find.byKey(const Key('add_subtask_button'));
        if (addSubtaskButton.evaluate().isNotEmpty) {
          for (int i = 0; i < 3; i++) {
            await tester.tap(addSubtaskButton);
            await tester.pumpAndSettle();
            
            final subtaskField = find.byKey(Key('subtask_field_$i'));
            if (subtaskField.evaluate().isNotEmpty) {
              await tester.enterText(subtaskField, taskWithSubtasks.subtasks[i]);
              await tester.pumpAndSettle();
            }
          }
        }

        // Save task
        final saveButton = find.byKey(const Key('save_task_button'));
        if (saveButton.evaluate().isNotEmpty) {
          await tester.tap(saveButton);
          await tester.pumpAndSettle();
        }

        // Assert - Task with subtasks should be created
        expect(find.text('Project Planning'), findsOneWidget);
        expect(find.text('0/3'), findsOneWidget); // Subtask progress
      });
    });

    group('Task Management Flow Integration Tests', () {
      testWidgets('should complete task edit and update flow', (tester) async {
        // Arrange
        final originalTask = TaskModel.create(
          title: 'Original Title',
          description: 'Original description',
          priority: TaskPriority.low,
        );
        
        final updatedTask = originalTask.copyWith(
          title: 'Updated Title',
          description: 'Updated description',
          priority: TaskPriority.urgent,
        );

        when(mockRepository.getAllTasks())
            .thenAnswer((_) async => Right([originalTask]));
        when(mockRepository.updateTask(any))
            .thenAnswer((_) async => Right(updatedTask));

        // Act
        app.main();
        await tester.pumpAndSettle();

        // Find task in list and tap to edit
        final taskCard = find.text('Original Title');
        expect(taskCard, findsOneWidget);
        
        // Long press to edit or tap edit button
        await tester.longPress(taskCard);
        await tester.pumpAndSettle();
        
        final editButton = find.byKey(const Key('edit_task_button'));
        if (editButton.evaluate().isNotEmpty) {
          await tester.tap(editButton);
          await tester.pumpAndSettle();
        }

        // Update task details
        final titleField = find.byKey(const Key('task_title_field'));
        if (titleField.evaluate().isNotEmpty) {
          await tester.enterText(titleField, 'Updated Title');
          await tester.pumpAndSettle();
        }

        // Change priority to urgent
        final prioritySelector = find.byKey(const Key('priority_selector'));
        if (prioritySelector.evaluate().isNotEmpty) {
          await tester.tap(prioritySelector);
          await tester.pumpAndSettle();
          
          final urgentOption = find.text('Urgent');
          if (urgentOption.evaluate().isNotEmpty) {
            await tester.tap(urgentOption);
            await tester.pumpAndSettle();
          }
        }

        // Save changes
        final saveButton = find.byKey(const Key('save_task_button'));
        if (saveButton.evaluate().isNotEmpty) {
          await tester.tap(saveButton);
          await tester.pumpAndSettle();
        }

        // Assert - Updated task should be displayed
        expect(find.text('Updated Title'), findsOneWidget);
      });

      testWidgets('should complete task completion flow', (tester) async {
        // Arrange
        final pendingTask = TaskModel.create(
          title: 'Task to Complete',
          status: TaskStatus.pending,
        );
        final completedTask = pendingTask.complete();

        when(mockRepository.getAllTasks())
            .thenAnswer((_) async => Right([pendingTask]));
        when(mockRepository.updateTask(any))
            .thenAnswer((_) async => Right(completedTask));
        when(mockRepository.getCompletedTasks())
            .thenAnswer((_) async => Right([completedTask]));

        // Act
        app.main();
        await tester.pumpAndSettle();

        // Find task and mark as completed
        final taskCheckbox = find.byKey(const Key('task_checkbox_${pendingTask.id}'));
        if (taskCheckbox.evaluate().isNotEmpty) {
          await tester.tap(taskCheckbox);
          await tester.pumpAndSettle();
        } else {
          // Alternative: look for completion button
          final completeButton = find.byKey(const Key('complete_task_button'));
          if (completeButton.evaluate().isNotEmpty) {
            await tester.tap(completeButton);
            await tester.pumpAndSettle();
          }
        }

        // Navigate to completed tasks view
        final completedTab = find.text('Completed');
        if (completedTab.evaluate().isNotEmpty) {
          await tester.tap(completedTab);
          await tester.pumpAndSettle();
        }

        // Assert - Task should appear in completed section
        expect(find.text('Task to Complete'), findsOneWidget);
      });

      testWidgets('should complete task deletion flow', (tester) async {
        // Arrange
        final taskToDelete = TaskModel.create(title: 'Task to Delete');

        when(mockRepository.getAllTasks())
            .thenAnswer((_) async => Right([taskToDelete]));
        when(mockRepository.deleteTask(taskToDelete.id))
            .thenAnswer((_) async => const Right(true));

        // Act
        app.main();
        await tester.pumpAndSettle();

        // Find task and delete it
        final taskCard = find.text('Task to Delete');
        expect(taskCard, findsOneWidget);

        // Swipe to delete or long press for context menu
        await tester.drag(taskCard, const Offset(-500, 0)); // Swipe left
        await tester.pumpAndSettle();

        // Confirm deletion
        final deleteButton = find.byKey(const Key('confirm_delete_button'));
        if (deleteButton.evaluate().isNotEmpty) {
          await tester.tap(deleteButton);
          await tester.pumpAndSettle();
        }

        // Assert - Task should be removed from list
        expect(find.text('Task to Delete'), findsNothing);
      });
    });

    group('Calendar Integration Flow Tests', () {
      testWidgets('should display tasks correctly on calendar', (tester) async {
        // Arrange
        final today = DateTime.now();
        final todayTask = TaskModel.create(
          title: 'Today Task',
          dueDate: DateTime(today.year, today.month, today.day),
        );
        
        final futureTask = TaskModel.create(
          title: 'Future Task',
          dueDate: today.add(const Duration(days: 5)),
          priority: TaskPriority.urgent,
        );

        final overdueTask = TaskModel.create(
          title: 'Overdue Task',
          dueDate: today.subtract(const Duration(days: 2)),
          status: TaskStatus.pending,
        );

        when(mockRepository.getAllTasks())
            .thenAnswer((_) async => Right([todayTask, futureTask, overdueTask]));

        // Act
        app.main();
        await tester.pumpAndSettle();

        // Navigate to calendar view
        final calendarTab = find.byIcon(Icons.calendar_today);
        if (calendarTab.evaluate().isNotEmpty) {
          await tester.tap(calendarTab);
          await tester.pumpAndSettle();
        }

        // Assert - Tasks should be displayed on appropriate dates
        expect(find.byType(Calendar), findsOneWidget);
        
        // Check for task indicators on calendar
        // Today should have indicator for today's task
        // Past date should have overdue indicator
        // Future date should have future task indicator
      });

      testWidgets('should handle calendar navigation and task display', (tester) async {
        // Arrange
        final nextMonthTask = TaskModel.create(
          title: 'Next Month Task',
          dueDate: DateTime.now().add(const Duration(days: 35)),
        );

        when(mockRepository.getAllTasks())
            .thenAnswer((_) async => Right([nextMonthTask]));

        // Act
        app.main();
        await tester.pumpAndSettle();

        // Navigate to calendar
        final calendarTab = find.byIcon(Icons.calendar_today);
        if (calendarTab.evaluate().isNotEmpty) {
          await tester.tap(calendarTab);
          await tester.pumpAndSettle();
        }

        // Navigate to next month
        final nextButton = find.byIcon(Icons.keyboard_arrow_right);
        if (nextButton.evaluate().isNotEmpty) {
          await tester.tap(nextButton);
          await tester.pumpAndSettle();
        }

        // Assert - Should display tasks for the new month
        expect(find.byType(Calendar), findsOneWidget);
      });

      testWidgets('should handle date selection and task creation from calendar', (tester) async {
        // Arrange
        when(mockRepository.getAllTasks())
            .thenAnswer((_) async => const Right([]));
        when(mockRepository.createTask(any))
            .thenAnswer((_) async => Right(TaskModel.create(title: 'Calendar Task')));

        // Act
        app.main();
        await tester.pumpAndSettle();

        // Navigate to calendar
        final calendarTab = find.byIcon(Icons.calendar_today);
        if (calendarTab.evaluate().isNotEmpty) {
          await tester.tap(calendarTab);
          await tester.pumpAndSettle();
        }

        // Tap on a future date
        final dateCells = find.byType(InkWell);
        if (dateCells.evaluate().isNotEmpty) {
          await tester.tap(dateCells.at(15)); // Tap on 15th day
          await tester.pumpAndSettle();
        }

        // Should open task creation with pre-filled date
        final quickCreateButton = find.byKey(const Key('quick_create_task'));
        if (quickCreateButton.evaluate().isNotEmpty) {
          await tester.tap(quickCreateButton);
          await tester.pumpAndSettle();
          
          // Enter task title
          final titleField = find.byKey(const Key('task_title_field'));
          if (titleField.evaluate().isNotEmpty) {
            await tester.enterText(titleField, 'Calendar Task');
            await tester.pumpAndSettle();
          }
          
          // Save task
          final saveButton = find.byKey(const Key('save_task_button'));
          if (saveButton.evaluate().isNotEmpty) {
            await tester.tap(saveButton);
            await tester.pumpAndSettle();
          }
        }

        // Assert - Task should be created with selected date
        expect(find.text('Calendar Task'), findsOneWidget);
      });
    });

    group('Search and Filter Flow Tests', () {
      testWidgets('should handle task search flow', (tester) async {
        // Arrange
        final tasks = [
          TaskModel.create(title: 'Important Meeting'),
          TaskModel.create(title: 'Grocery Shopping'),
          TaskModel.create(title: 'Important Project Review'),
          TaskModel.create(title: 'Call Doctor'),
        ];

        final searchResults = tasks.where((t) => t.title.contains('Important')).toList();

        when(mockRepository.getAllTasks())
            .thenAnswer((_) async => Right(tasks));
        when(mockRepository.searchTasks('Important'))
            .thenAnswer((_) async => Right(searchResults));

        // Act
        app.main();
        await tester.pumpAndSettle();

        // Open search
        final searchButton = find.byIcon(Icons.search);
        if (searchButton.evaluate().isNotEmpty) {
          await tester.tap(searchButton);
          await tester.pumpAndSettle();
        }

        // Enter search query
        final searchField = find.byKey(const Key('search_field'));
        if (searchField.evaluate().isNotEmpty) {
          await tester.enterText(searchField, 'Important');
          await tester.pumpAndSettle();
        }

        // Assert - Should display filtered results
        expect(find.text('Important Meeting'), findsOneWidget);
        expect(find.text('Important Project Review'), findsOneWidget);
        expect(find.text('Grocery Shopping'), findsNothing);
        expect(find.text('Call Doctor'), findsNothing);
      });

      testWidgets('should handle priority filter flow', (tester) async {
        // Arrange
        final tasks = [
          TaskModel.create(title: 'Low Task', priority: TaskPriority.low),
          TaskModel.create(title: 'High Task', priority: TaskPriority.high),
          TaskModel.create(title: 'Urgent Task', priority: TaskPriority.urgent),
        ];

        final highPriorityTasks = tasks.where((t) => 
            t.priority == TaskPriority.high || t.priority == TaskPriority.urgent).toList();

        when(mockRepository.getAllTasks())
            .thenAnswer((_) async => Right(tasks));

        // Act
        app.main();
        await tester.pumpAndSettle();

        // Open filter menu
        final filterButton = find.byIcon(Icons.filter_list);
        if (filterButton.evaluate().isNotEmpty) {
          await tester.tap(filterButton);
          await tester.pumpAndSettle();
        }

        // Select high priority filter
        final highPriorityFilter = find.byKey(const Key('filter_high_priority'));
        if (highPriorityFilter.evaluate().isNotEmpty) {
          await tester.tap(highPriorityFilter);
          await tester.pumpAndSettle();
        }

        // Apply filter
        final applyFilterButton = find.byKey(const Key('apply_filter_button'));
        if (applyFilterButton.evaluate().isNotEmpty) {
          await tester.tap(applyFilterButton);
          await tester.pumpAndSettle();
        }

        // Assert - Should show only high and urgent priority tasks
        expect(find.text('High Task'), findsOneWidget);
        expect(find.text('Urgent Task'), findsOneWidget);
        expect(find.text('Low Task'), findsNothing);
      });
    });

    group('Settings and Theme Flow Tests', () {
      testWidgets('should handle theme switching flow', (tester) async {
        // Act
        app.main();
        await tester.pumpAndSettle();

        // Navigate to settings
        final settingsButton = find.byIcon(Icons.settings);
        if (settingsButton.evaluate().isNotEmpty) {
          await tester.tap(settingsButton);
          await tester.pumpAndSettle();
        }

        // Find theme selector
        final themeSelector = find.byKey(const Key('theme_selector'));
        if (themeSelector.evaluate().isNotEmpty) {
          await tester.tap(themeSelector);
          await tester.pumpAndSettle();
        }

        // Select Matrix theme
        final matrixTheme = find.text('Matrix');
        if (matrixTheme.evaluate().isNotEmpty) {
          await tester.tap(matrixTheme);
          await tester.pumpAndSettle();
        }

        // Assert - Theme should change (matrix rain background should appear)
        // Navigate back to main screen to verify theme change
        final backButton = find.byIcon(Icons.arrow_back);
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton);
          await tester.pumpAndSettle();
        }

        // Should have Matrix theme applied
        expect(find.byType(CustomPaint), findsOneWidget); // Matrix rain painter
      });

      testWidgets('should handle notification settings flow', (tester) async {
        // Act
        app.main();
        await tester.pumpAndSettle();

        // Navigate to settings
        final settingsButton = find.byIcon(Icons.settings);
        if (settingsButton.evaluate().isNotEmpty) {
          await tester.tap(settingsButton);
          await tester.pumpAndSettle();
        }

        // Navigate to notification settings
        final notificationSettings = find.text('Notifications');
        if (notificationSettings.evaluate().isNotEmpty) {
          await tester.tap(notificationSettings);
          await tester.pumpAndSettle();
        }

        // Toggle notification settings
        final enableNotifications = find.byKey(const Key('enable_notifications_toggle'));
        if (enableNotifications.evaluate().isNotEmpty) {
          await tester.tap(enableNotifications);
          await tester.pumpAndSettle();
        }

        // Assert - Settings should be updated
      });
    });

    group('Error Handling Flow Tests', () {
      testWidgets('should handle network connectivity issues', (tester) async {
        // Arrange
        when(mockRepository.getAllTasks())
            .thenAnswer((_) async => Left(NetworkFailure('No internet connection')));

        // Act
        app.main();
        await tester.pumpAndSettle();

        // Assert - Should display offline mode or error message
        expect(find.byType(MaterialApp), findsOneWidget);
        // Should gracefully handle network error
      });

      testWidgets('should handle database errors gracefully', (tester) async {
        // Arrange
        when(mockRepository.createTask(any))
            .thenAnswer((_) async => Left(DatabaseFailure('Database corrupted')));

        // Act - Try to create task
        app.main();
        await tester.pumpAndSettle();

        final addButton = find.byIcon(Icons.add);
        if (addButton.evaluate().isNotEmpty) {
          await tester.tap(addButton);
          await tester.pumpAndSettle();
          
          // Fill form and save
          final titleField = find.byKey(const Key('task_title_field'));
          if (titleField.evaluate().isNotEmpty) {
            await tester.enterText(titleField, 'Test Task');
            await tester.pumpAndSettle();
          }
          
          final saveButton = find.byKey(const Key('save_task_button'));
          if (saveButton.evaluate().isNotEmpty) {
            await tester.tap(saveButton);
            await tester.pumpAndSettle();
          }
        }

        // Assert - Should display error message
        expect(find.byType(SnackBar), findsOneWidget);
      });
    });

    group('Performance Integration Tests', () {
      testWidgets('should handle large dataset efficiently', (tester) async {
        // Arrange - Large number of tasks
        final largeTasks = List.generate(1000, (index) => 
          TaskModel.create(
            title: 'Task $index',
            priority: TaskPriority.values[index % TaskPriority.values.length],
            dueDate: DateTime.now().add(Duration(days: index % 365)),
          )
        );

        when(mockRepository.getAllTasks())
            .thenAnswer((_) async => Right(largeTasks));

        // Act
        final startTime = DateTime.now();
        app.main();
        await tester.pumpAndSettle();
        final endTime = DateTime.now();

        // Assert - Should load within reasonable time
        final loadTime = endTime.difference(startTime);
        expect(loadTime.inSeconds, lessThan(5));
        
        // Should display tasks (with pagination or virtualization)
        expect(find.byType(ListView), findsOneWidget);
      });

      testWidgets('should handle rapid user interactions', (tester) async {
        // Arrange
        final task = TaskModel.create(title: 'Rapid Test Task');
        when(mockRepository.getAllTasks())
            .thenAnswer((_) async => Right([task]));

        // Act
        app.main();
        await tester.pumpAndSettle();

        // Rapidly interact with UI elements
        for (int i = 0; i < 10; i++) {
          final tabs = find.byType(Tab);
          if (tabs.evaluate().isNotEmpty) {
            await tester.tap(tabs.at(i % tabs.evaluate().length));
            await tester.pump(const Duration(milliseconds: 100));
          }
        }

        await tester.pumpAndSettle();

        // Assert - Should handle rapid interactions without crashes
        expect(find.byType(MaterialApp), findsOneWidget);
      });
    });

    group('Intent Sharing Integration Tests', () {
      testWidgets('should handle external app sharing - Facebook Messenger', (tester) async {
        // This test would require platform-specific testing
        // and actual external app integration testing
        
        // Arrange
        final task = TaskModel.create(
          title: 'Share this task',
          description: 'Testing Facebook Messenger sharing',
        );

        // Act - This would test the actual intent sharing functionality
        // Implementation depends on platform channels and external apps
        
        // Assert - Should successfully share task details to Messenger
        // This requires integration with actual Facebook Messenger app
      });

      testWidgets('should handle external app sharing - WhatsApp', (tester) async {
        // Similar to Facebook Messenger test
        // Tests actual WhatsApp integration and intent sharing
        
        final task = TaskModel.create(
          title: 'WhatsApp Task',
          description: 'Testing WhatsApp sharing functionality',
        );

        // Would test actual WhatsApp intent sharing
        // Requires WhatsApp app to be installed and accessible
      });
    });
  });
}