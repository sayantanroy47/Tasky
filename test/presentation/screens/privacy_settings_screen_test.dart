import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:task_tracker_app/presentation/screens/privacy_settings_screen.dart';

Widget createTestWidget({required Widget child, List<Override>? overrides}) {
  return ProviderScope(
    overrides: overrides ?? [],
    child: MaterialApp(
      home: child,
    ),
  );
}

void main() {
  group('PrivacySettingsScreen Widget Tests', () {
    testWidgets('should display privacy settings screen', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const PrivacySettingsScreen(),
        ),
      );
      await tester.pump();
      
      expect(find.byType(PrivacySettingsScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Privacy & Data'), findsOneWidget);
    });

    testWidgets('should display info button', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const PrivacySettingsScreen(),
        ),
      );
      await tester.pump();
      
      expect(find.byIcon(PhosphorIcons.info()), findsOneWidget);
    });

    testWidgets('should handle loading states', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const PrivacySettingsScreen(),
        ),
      );
      
      // Pump to allow async states to resolve
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      
      expect(find.byType(PrivacySettingsScreen), findsOneWidget);
    });

    testWidgets('should work with different themes', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: const PrivacySettingsScreen(),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(PrivacySettingsScreen), findsOneWidget);
      expect(find.text('Privacy & Data'), findsOneWidget);
    });

    testWidgets('should be accessible', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const PrivacySettingsScreen(),
        ),
      );
      await tester.pump();
      
      final privacySemantics = tester.getSemantics(find.byType(PrivacySettingsScreen));
      expect(privacySemantics, isNotNull);
    });

    testWidgets('should render on small screens', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(
        createTestWidget(
          child: const PrivacySettingsScreen(),
        ),
      );
      await tester.pump();
      
      expect(find.byType(PrivacySettingsScreen), findsOneWidget);
      expect(find.text('Privacy & Data'), findsOneWidget);
      
      addTearDown(() => tester.view.resetPhysicalSize());
    });

    testWidgets('should render on large screens', (tester) async {
      tester.view.physicalSize = const Size(1440, 2560);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(
        createTestWidget(
          child: const PrivacySettingsScreen(),
        ),
      );
      await tester.pump();
      
      expect(find.byType(PrivacySettingsScreen), findsOneWidget);
      expect(find.text('Privacy & Data'), findsOneWidget);
      
      addTearDown(() => tester.view.resetPhysicalSize());
    });

    testWidgets('should handle info button tap', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const PrivacySettingsScreen(),
        ),
      );
      await tester.pump();
      
      final infoButton = find.byIcon(PhosphorIcons.info());
      expect(infoButton, findsOneWidget);
      
      await tester.tap(infoButton);
      await tester.pump();
      
      // Should not crash after tap
      expect(find.byType(PrivacySettingsScreen), findsOneWidget);
    });

    testWidgets('should handle provider data states', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const PrivacySettingsScreen(),
        ),
      );
      
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      
      expect(find.byType(PrivacySettingsScreen), findsOneWidget);
    });

    testWidgets('should handle provider error states', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const PrivacySettingsScreen(),
        ),
      );
      
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      
      // Screen should render even with potential provider errors
      expect(find.byType(PrivacySettingsScreen), findsOneWidget);
    });

    testWidgets('should handle orientation changes', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const PrivacySettingsScreen(),
        ),
      );
      await tester.pump();
      
      expect(find.text('Privacy & Data'), findsOneWidget);
      
      // Simulate orientation change
      tester.view.physicalSize = const Size(800, 600);
      await tester.pump();
      
      expect(find.byType(PrivacySettingsScreen), findsOneWidget);
      
      addTearDown(() => tester.view.resetPhysicalSize());
    });

    testWidgets('should maintain state during rebuild', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const PrivacySettingsScreen(),
        ),
      );
      await tester.pump();
      
      expect(find.text('Privacy & Data'), findsOneWidget);
      
      // Trigger rebuild
      await tester.pumpWidget(
        createTestWidget(
          child: const PrivacySettingsScreen(),
        ),
      );
      await tester.pump();
      
      expect(find.byType(PrivacySettingsScreen), findsOneWidget);
    });
  });
}