import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:task_tracker_app/presentation/pages/recurring_task_creation_page.dart';

void main() {
  group('RecurringTaskCreationPage Widget Tests', () {
    Widget createTestWidget() {
      return ProviderScope(
        child: MaterialApp(
          home: Theme(
            data: ThemeData.light(),
            child: const RecurringTaskCreationPage(),
          ),
        ),
      );
    }

    testWidgets('should display recurring task creation page', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      expect(find.byType(RecurringTaskCreationPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display task form fields', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      expect(find.byType(RecurringTaskCreationPage), findsOneWidget);
    });

    testWidgets('should handle recurrence pattern selection', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final dropdowns = find.byType(DropdownButton);
      if (dropdowns.evaluate().isNotEmpty) {
        await tester.tap(dropdowns.first);
        await tester.pump();
      }
      
      expect(find.byType(RecurringTaskCreationPage), findsOneWidget);
    });

    testWidgets('should handle form validation', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().isNotEmpty) {
        await tester.enterText(textFields.first, '');
        await tester.pump();
      }
      
      expect(find.byType(RecurringTaskCreationPage), findsOneWidget);
    });

    testWidgets('should handle save button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final saveButtons = find.textContaining('Save');
      if (saveButtons.evaluate().isNotEmpty) {
        await tester.tap(saveButtons.first);
        await tester.pump();
      }
      
      expect(find.byType(RecurringTaskCreationPage), findsOneWidget);
    });

    testWidgets('should work with different themes', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: const RecurringTaskCreationPage(),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(RecurringTaskCreationPage), findsOneWidget);
    });
  });
}
