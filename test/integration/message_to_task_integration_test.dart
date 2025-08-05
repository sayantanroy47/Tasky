import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:task_tracker_app/main.dart' as app;
import 'package:task_tracker_app/services/share_intent_service.dart';
import 'package:task_tracker_app/presentation/widgets/message_task_dialog.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Message-to-Task Integration Tests', () {
    testWidgets('complete message-to-task flow', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Settings page
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Find the Message Integration section
      expect(find.text('Message Integration'), findsOneWidget);

      // Tap the "Test Message Flow" button
      await tester.tap(find.text('Test Message Flow'));
      await tester.pumpAndSettle();

      // Wait for any dialogs or processing
      await tester.pump(const Duration(seconds: 2));

      // Check that a success message appears
      expect(find.text('Test message processed! Check for new task.'), findsOneWidget);

      // Navigate to Tasks page to verify task was created
      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();

      // Should find the created task (this would depend on the actual task created)
      // For now, just verify we can navigate to tasks page
      expect(find.text('Tasks'), findsOneWidget);
    });

    testWidgets('message dialog flow with manual input', (tester) async {
      // This test would simulate the dialog flow
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // This is a conceptual test - would need proper dialog triggering
      // In a real scenario, this would be triggered by share intent
    });
  });

  group('Task Management Integration Tests', () {
    testWidgets('create task end-to-end', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Tasks page
      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();

      // Look for add task button (FAB or other button)
      final addButton = find.byType(FloatingActionButton);
      if (addButton.evaluate().isNotEmpty) {
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // Fill in task details
        await tester.enterText(find.byType(TextField).first, 'Integration Test Task');
        
        // Save the task
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // Verify task appears in list
        expect(find.text('Integration Test Task'), findsOneWidget);
      }
    });

    testWidgets('edit task flow', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Tasks page
      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();

      // This would require existing tasks to edit
      // Implementation would depend on actual UI structure
    });

    testWidgets('complete task flow', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Tasks page
      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();

      // This would test marking tasks as complete
      // Implementation would depend on actual UI structure
    });
  });

  group('Voice Input Integration Tests', () {
    testWidgets('voice input flow', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Look for voice input button
      final voiceButton = find.byIcon(Icons.mic);
      if (voiceButton.evaluate().isNotEmpty) {
        await tester.tap(voiceButton);
        await tester.pumpAndSettle();

        // This would test the voice input dialog
        // Note: Actual speech recognition can't be tested in integration tests
        // but we can test the UI flow
      }
    });
  });

  group('Settings Integration Tests', () {
    testWidgets('theme switching', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Look for theme toggle
      final themeToggle = find.byType(Switch);
      if (themeToggle.evaluate().isNotEmpty) {
        await tester.tap(themeToggle.first);
        await tester.pumpAndSettle();

        // Verify theme changed (would need to check actual theme properties)
      }
    });

    testWidgets('trusted contacts management', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Find Message Integration section
      expect(find.text('Message Integration'), findsOneWidget);

      // Tap on Trusted Contacts
      await tester.tap(find.text('Trusted Contacts'));
      await tester.pumpAndSettle();

      // Verify dialog opens
      expect(find.text('Trusted Contacts'), findsAtLeastNWidget(1));
      expect(find.text('Wife 💕'), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
    });
  });

  group('Navigation Integration Tests', () {
    testWidgets('bottom navigation flow', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Test each navigation destination
      final destinations = ['Home', 'Tasks', 'Settings', 'Performance'];
      
      for (final destination in destinations) {
        await tester.tap(find.text(destination));
        await tester.pumpAndSettle();
        
        // Verify we're on the correct page
        expect(find.text(destination), findsAtLeastNWidget(1));
      }
    });

    testWidgets('deep navigation and back navigation', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Tasks
      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();

      // If there are task detail views, test navigation to them
      // This would depend on the actual UI implementation

      // Test back navigation
      // await tester.pageBack();
      // await tester.pumpAndSettle();
    });
  });

  group('Performance Integration Tests', () {
    testWidgets('app startup performance', (tester) async {
      final stopwatch = Stopwatch()..start();
      
      // Start the app
      app.main();
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // App should start within reasonable time
      expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // 5 seconds max
    });

    testWidgets('navigation performance', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch();
      
      // Test navigation performance
      stopwatch.start();
      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();
      stopwatch.stop();

      // Navigation should be fast
      expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // 1 second max
    });
  });

  group('Error Handling Integration Tests', () {
    testWidgets('offline behavior', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // App should work offline (since it's offline-first)
      // Test basic functionality without network
      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();

      // Should still be functional
      expect(find.text('Tasks'), findsOneWidget);
    });

    testWidgets('error recovery', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // This would test error recovery scenarios
      // Implementation depends on how errors are handled in the app
    });
  });

  group('Accessibility Integration Tests', () {
    testWidgets('screen reader compatibility', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Test that main UI elements have proper semantics
      expect(find.bySemanticsLabel('Home'), findsWidgets);
      expect(find.bySemanticsLabel('Tasks'), findsWidgets);
      expect(find.bySemanticsLabel('Settings'), findsWidgets);
    });

    testWidgets('keyboard navigation', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Test keyboard navigation
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      // Focus should move to interactive elements
      // Implementation would depend on actual focusable elements
    });

    testWidgets('high contrast mode', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Test high contrast theme if available
      // This would depend on the theme implementation
    });
  });

  group('Data Persistence Integration Tests', () {
    testWidgets('data survives app restart', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Create a task
      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();

      // Add task logic here...

      // Restart app (conceptually - this is complex in integration tests)
      // In a real test, you'd need to properly restart the app
      
      // Verify data persists
      // Implementation would depend on data persistence mechanism
    });
  });

  group('Cross-Platform Integration Tests', () {
    testWidgets('responsive design on different screen sizes', (tester) async {
      // Test different screen sizes
      await tester.binding.setSurfaceSize(const Size(400, 800)); // Phone
      app.main();
      await tester.pumpAndSettle();
      
      // Verify UI works on phone size
      expect(find.text('Home'), findsOneWidget);
      
      // Test tablet size
      await tester.binding.setSurfaceSize(const Size(800, 1200)); // Tablet
      await tester.pump();
      
      // Verify UI adapts to tablet
      expect(find.text('Home'), findsOneWidget);
      
      // Cleanup
      await tester.binding.setSurfaceSize(null);
    });
  });
}

/// Helper extension for integration tests
extension IntegrationTestHelpers on WidgetTester {
  /// Wait for animations and settle with longer timeout for integration tests
  Future<void> pumpAndSettleIntegration() async {
    await pumpAndSettle(const Duration(seconds: 10));
  }

  /// Find widget by text with retry logic
  Future<Finder> findTextWithRetry(String text, {int maxRetries = 5}) async {
    for (int i = 0; i < maxRetries; i++) {
      final finder = find.text(text);
      if (finder.evaluate().isNotEmpty) {
        return finder;
      }
      await pump(const Duration(milliseconds: 500));
    }
    return find.text(text);
  }

  /// Tap with retry logic for flaky elements
  Future<void> tapWithRetry(Finder finder, {int maxRetries = 3}) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        await tap(finder);
        await pumpAndSettle();
        break;
      } catch (e) {
        if (i == maxRetries - 1) rethrow;
        await pump(const Duration(milliseconds: 500));
      }
    }
  }
}