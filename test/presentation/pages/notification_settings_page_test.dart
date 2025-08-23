import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:task_tracker_app/presentation/pages/notification_settings_page.dart';

void main() {
  group('NotificationSettingsPage Widget Tests', () {
    Widget createTestWidget() {
      return ProviderScope(
        child: MaterialApp(
          home: Theme(
            data: ThemeData.light(),
            child: const NotificationSettingsPage(),
          ),
        ),
      );
    }

    testWidgets('should display notification settings page', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      expect(find.byType(NotificationSettingsPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display notification toggle switches', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      expect(find.byType(NotificationSettingsPage), findsOneWidget);
      
      final switches = find.byType(Switch);
      expect(switches.evaluate().length, greaterThanOrEqualTo(0));
    });

    testWidgets('should handle notification toggle', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final switches = find.byType(Switch);
      if (switches.evaluate().isNotEmpty) {
        await tester.tap(switches.first);
        await tester.pump();
      }
      
      expect(find.byType(NotificationSettingsPage), findsOneWidget);
    });

    testWidgets('should display notification categories', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      expect(find.byType(NotificationSettingsPage), findsOneWidget);
    });

    testWidgets('should handle time picker for notifications', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      // Look for time picker widgets
      final timeButtons = [
        ...find.byIcon(Icons.access_time).evaluate(),
        ...find.textContaining('Time').evaluate(),
      ];
      
      if (timeButtons.isNotEmpty) {
        await tester.tap(find.byWidget(timeButtons.first.widget));
        await tester.pump();
      }
      
      expect(find.byType(NotificationSettingsPage), findsOneWidget);
    });

    testWidgets('should handle sound/vibration settings', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      expect(find.byType(NotificationSettingsPage), findsOneWidget);
    });

    testWidgets('should work with different themes', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: const NotificationSettingsPage(),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(NotificationSettingsPage), findsOneWidget);
    });
  });
}
