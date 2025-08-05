import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_tracker_app/presentation/pages/home_page.dart';
import 'package:task_tracker_app/core/theme/app_theme.dart';

void main() {
  group('TaskTrackerApp', () {
    testWidgets('should display welcome message', (WidgetTester tester) async {
      // Build the HomePage directly to avoid initialization issues
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const HomePage(),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pump();

      // Verify that the welcome message is displayed
      expect(find.text('Welcome to Task Tracker'), findsOneWidget);
      expect(find.text('Your voice-driven task management app'), findsOneWidget);
      
      // Verify that the FAB is present
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Voice Task'), findsWidgets); // Allow multiple instances
      
      // Verify that the create task button is present
      expect(find.text('Create Your First Task'), findsOneWidget);
    });

    testWidgets('should have proper app bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const HomePage(),
          ),
        ),
      );

      await tester.pump();

      // Verify app bar elements
      expect(find.text('Task Tracker'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsAtLeastNWidgets(1)); // Allow multiple instances
      expect(find.byIcon(Icons.settings), findsAtLeastNWidgets(1)); // Allow multiple instances
    });

    testWidgets('should use Material 3 theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const HomePage(),
          ),
        ),
      );

      await tester.pump();

      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.theme?.useMaterial3, isTrue);
      expect(app.darkTheme?.useMaterial3, isTrue);
    });
  });
}