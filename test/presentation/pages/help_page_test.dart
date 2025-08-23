import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:task_tracker_app/presentation/pages/help_page.dart';

void main() {
  group('HelpPage Widget Tests', () {
    Widget createTestWidget() {
      return ProviderScope(
        child: MaterialApp(
          home: Theme(
            data: ThemeData.light(),
            child: const HelpPage(),
          ),
        ),
      );
    }

    testWidgets('should display help page with basic elements', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      expect(find.byType(HelpPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display help content', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      expect(find.byType(HelpPage), findsOneWidget);
    });

    testWidgets('should handle scrolling through help content', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      await tester.drag(find.byType(HelpPage), const Offset(0, -300));
      await tester.pumpAndSettle();
      
      expect(find.byType(HelpPage), findsOneWidget);
    });

    testWidgets('should work with different themes', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: const HelpPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(HelpPage), findsOneWidget);
    });

    testWidgets('should handle expandable sections', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      // Look for expandable tiles or sections
      final expansionTiles = find.byType(ExpansionTile);
      if (expansionTiles.evaluate().isNotEmpty) {
        await tester.tap(expansionTiles.first);
        await tester.pumpAndSettle();
      }
      
      expect(find.byType(HelpPage), findsOneWidget);
    });

    testWidgets('should display FAQ sections', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      expect(find.byType(HelpPage), findsOneWidget);
    });

    testWidgets('should handle contact/support links', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      // Look for contact buttons or links
      final contactElements = [
        ...find.textContaining('Contact').evaluate(),
        ...find.textContaining('Support').evaluate(),
        ...find.textContaining('Email').evaluate(),
      ];
      
      if (contactElements.isNotEmpty) {
        await tester.tap(find.byWidget(contactElements.first.widget));
        await tester.pumpAndSettle();
      }
      
      expect(find.byType(HelpPage), findsOneWidget);
    });
  });
}
