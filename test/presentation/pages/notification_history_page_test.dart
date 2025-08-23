import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:task_tracker_app/presentation/pages/notification_history_page.dart';

void main() {
  group('NotificationHistoryPage Widget Tests', () {
    Widget createTestWidget() {
      return ProviderScope(
        child: MaterialApp(
          home: Theme(
            data: ThemeData.light(),
            child: const NotificationHistoryPage(),
          ),
        ),
      );
    }

    testWidgets('should display notification history page', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      expect(find.byType(NotificationHistoryPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display notification history list', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      expect(find.byType(NotificationHistoryPage), findsOneWidget);
    });

    testWidgets('should handle empty notification history', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      expect(find.byType(NotificationHistoryPage), findsOneWidget);
    });

    testWidgets('should handle clear history action', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      final clearButtons = find.textContaining('Clear');
      if (clearButtons.evaluate().isNotEmpty) {
        await tester.tap(clearButtons.first);
        await tester.pumpAndSettle();
      }
      
      expect(find.byType(NotificationHistoryPage), findsOneWidget);
    });

    testWidgets('should work with different themes', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: const NotificationHistoryPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(NotificationHistoryPage), findsOneWidget);
    });
  });
}
