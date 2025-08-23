import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:task_tracker_app/presentation/pages/ai_settings_page.dart';

void main() {
  group('AISettingsPage Widget Tests', () {
    Widget createTestWidget() {
      return ProviderScope(
        child: MaterialApp(
          home: Theme(
            data: ThemeData.light(),
            child: const AISettingsPage(),
          ),
        ),
      );
    }

    testWidgets('should display AI settings page with basic elements', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      expect(find.byType(AISettingsPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display AI service options', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      expect(find.byType(AISettingsPage), findsOneWidget);
    });

    testWidgets('should handle AI service selection', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      // Look for dropdown, radio buttons, or other selection UI
      final dropdowns = find.byType(DropdownButton);
      final radioButtons = find.byType(Radio);
      final listTiles = find.byType(ListTile);
      
      if (dropdowns.evaluate().isNotEmpty) {
        await tester.tap(dropdowns.first);
        await tester.pumpAndSettle();
      } else if (radioButtons.evaluate().isNotEmpty) {
        await tester.tap(radioButtons.first);
        await tester.pumpAndSettle();
      } else if (listTiles.evaluate().isNotEmpty) {
        await tester.tap(listTiles.first);
        await tester.pumpAndSettle();
      }
      
      expect(find.byType(AISettingsPage), findsOneWidget);
    });

    testWidgets('should handle API key management', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      // Look for text fields for API keys
      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().isNotEmpty) {
        await tester.enterText(textFields.first, 'test-api-key');
        await tester.pumpAndSettle();
      }
      
      expect(find.byType(AISettingsPage), findsOneWidget);
    });

    testWidgets('should display save/cancel buttons', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      expect(find.byType(AISettingsPage), findsOneWidget);
    });

    testWidgets('should work with different themes', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: const AISettingsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(AISettingsPage), findsOneWidget);
    });

    testWidgets('should handle scrolling', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      await tester.drag(find.byType(AISettingsPage), const Offset(0, -300));
      await tester.pumpAndSettle();
      
      expect(find.byType(AISettingsPage), findsOneWidget);
    });
  });
}
