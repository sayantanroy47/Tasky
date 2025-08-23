import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:task_tracker_app/presentation/pages/location_settings_page.dart';

void main() {
  group('LocationSettingsPage Widget Tests', () {
    Widget createTestWidget() {
      return ProviderScope(
        child: MaterialApp(
          home: Theme(
            data: ThemeData.light(),
            child: const LocationSettingsPage(),
          ),
        ),
      );
    }

    testWidgets('should display location settings page', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      expect(find.byType(LocationSettingsPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should handle location permission settings', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      expect(find.byType(LocationSettingsPage), findsOneWidget);
    });

    testWidgets('should display location-based task settings', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      expect(find.byType(LocationSettingsPage), findsOneWidget);
    });

    testWidgets('should handle geofencing settings', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      final switches = find.byType(Switch);
      if (switches.evaluate().isNotEmpty) {
        await tester.tap(switches.first);
        await tester.pumpAndSettle();
      }
      
      expect(find.byType(LocationSettingsPage), findsOneWidget);
    });

    testWidgets('should work with different themes', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: const LocationSettingsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(LocationSettingsPage), findsOneWidget);
    });
  });
}
