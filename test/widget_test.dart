import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracker_app/main.dart';

void main() {
  group('TaskTrackerApp', () {
    testWidgets('should display welcome message', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const TaskTrackerApp());

      // Verify that the welcome message is displayed
      expect(find.text('Welcome to Task Tracker'), findsOneWidget);
      expect(find.text('Your voice-driven task management app'), findsOneWidget);
      
      // Verify that the FAB is present
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Add Task'), findsOneWidget);
      
      // Verify bottom navigation is present
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('should have proper app bar', (WidgetTester tester) async {
      await tester.pumpWidget(const TaskTrackerApp());

      // Verify app bar elements
      expect(find.text('Task Tracker'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('should use Material 3 theme', (WidgetTester tester) async {
      await tester.pumpWidget(const TaskTrackerApp());

      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.theme?.useMaterial3, isTrue);
      expect(app.darkTheme?.useMaterial3, isTrue);
    });
  });
}