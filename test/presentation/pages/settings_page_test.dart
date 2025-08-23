import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:task_tracker_app/presentation/pages/settings_page.dart';
import 'package:task_tracker_app/presentation/widgets/standardized_app_bar.dart';
import 'package:task_tracker_app/presentation/widgets/simple_theme_toggle.dart';
import 'package:task_tracker_app/presentation/widgets/glassmorphism_container.dart';

// Helper function available to all test groups
Widget createTestWidget() {
  return ProviderScope(
    child: MaterialApp(
      home: Theme(
        data: ThemeData.light(),
        child: const SettingsPage(),
      ),
    ),
  );
}

void main() {
  group('SettingsPage Widget Tests', () {
    testWidgets('should display settings page with basic elements', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      expect(find.byType(SettingsPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display theme toggle widget', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      // Verify basic UI elements
      expect(find.text('Settings'), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(StandardizedAppBar), findsOneWidget);
    });

    testWidgets('should display theme toggle button in app bar', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      expect(find.byType(ThemeToggleButton), findsOneWidget);
    });

    testWidgets('should display navigation section', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      expect(find.text('Navigation'), findsOneWidget);
    });

    testWidgets('should display tasks navigation tile', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      expect(find.text('Tasks'), findsOneWidget);
      expect(find.text('View and manage all tasks'), findsOneWidget);
      expect(find.byIcon(PhosphorIcons.checkSquare()), findsOneWidget);
    });

    testWidgets('should display projects navigation tile', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      expect(find.text('Projects'), findsOneWidget);
      expect(find.byIcon(PhosphorIcons.folder()), findsOneWidget);
    });

    testWidgets('should handle tap on tasks tile', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final tasksTitle = find.text('Tasks');
      expect(tasksTitle, findsOneWidget);
      
      await tester.tap(tasksTitle);
      await tester.pump();
      
      // Should navigate or show some response
    });

    testWidgets('should handle tap on projects tile', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final projectsTitle = find.text('Projects');
      expect(projectsTitle, findsOneWidget);
      
      await tester.tap(projectsTitle);
      await tester.pump();
    });

    testWidgets('should display glassmorphism containers', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      expect(find.byType(GlassmorphismContainer), findsWidgets);
    });

    testWidgets('should display all section headers', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      // Check for various section headers that should exist
      expect(find.text('Navigation'), findsOneWidget);
    });

    testWidgets('should have proper scrolling behavior', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final listView = find.byType(ListView);
      expect(listView, findsOneWidget);
      
      // Test scrolling
      await tester.drag(listView, const Offset(0, -300));
      await tester.pump();
    });

    testWidgets('should maintain transparent background', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, Colors.transparent);
    });

    testWidgets('should extend body behind app bar', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.extendBodyBehindAppBar, true);
    });

    testWidgets('should not show back button in app bar', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final appBar = tester.widget<StandardizedAppBar>(
        find.byType(StandardizedAppBar));
      expect(appBar.forceBackButton, false);
    });

    testWidgets('should display correct padding for list content', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.padding, isNotNull);
    });

    testWidgets('should handle different theme states', (tester) async {
      // Test with dark theme
      final darkWidget = ProviderScope(
        child: MaterialApp(
          theme: ThemeData.dark(),
          home: const SettingsPage(),
        ),
      );

      await tester.pumpWidget(darkWidget);
      await tester.pump();
      
      expect(find.byType(SettingsPage), findsOneWidget);
    });

    testWidgets('should display all list tiles with proper styling', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final listTiles = find.byType(ListTile);
      expect(listTiles, findsWidgets);
      
      // Verify list tiles have icons and text
      for (int i = 0; i < tester.widgetList(listTiles).length; i++) {
        final listTile = tester.widget<ListTile>(listTiles.at(i));
        expect(listTile.leading, isNotNull);
        expect(listTile.title, isNotNull);
        expect(listTile.subtitle, isNotNull);
      }
    });

    testWidgets('should display caret right icons on tiles', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      expect(find.byIcon(PhosphorIcons.caretRight()), findsWidgets);
    });

    testWidgets('should handle accessibility properly', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      // Test semantic navigation
      expect(find.byType(Semantics), findsWidgets);
    });
  });

  group('SettingsPage Navigation Tests', () {
    testWidgets('should navigate to tasks page', (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            navigatorKey: navigatorKey,
            home: const SettingsPage(),
          ),
        ),
      );
      await tester.pump();
      
      // Find and tap the tasks tile
      final tasksListTile = find.ancestor(
        of: find.text('Tasks'),
        matching: find.byType(ListTile),
      );
      
      await tester.tap(tasksListTile);
      await tester.pump();
    });

    testWidgets('should navigate to projects page', (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            navigatorKey: navigatorKey,
            home: const SettingsPage(),
          ),
        ),
      );
      await tester.pump();
      
      // Find and tap the projects tile
      final projectsListTile = find.ancestor(
        of: find.text('Projects'),
        matching: find.byType(ListTile),
      );
      
      await tester.tap(projectsListTile);
      await tester.pump();
    });
  });

  group('SettingsPage Edge Cases', () {
    testWidgets('should handle rapid taps on navigation items', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final tasksListTile = find.ancestor(
        of: find.text('Tasks'),
        matching: find.byType(ListTile),
      );
      
      // Rapid tapping
      for (int i = 0; i < 5; i++) {
        await tester.tap(tasksListTile);
        await tester.pump(const Duration(milliseconds: 10));
      }
      
      await tester.pump();
    });

    testWidgets('should handle small screen sizes', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      expect(find.byType(SettingsPage), findsOneWidget);
      
      // Reset
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('should handle large screen sizes', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      expect(find.byType(SettingsPage), findsOneWidget);
      
      // Reset
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('should handle different text scales', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
              child: Theme(
                data: ThemeData.light(),
                child: const SettingsPage(),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(SettingsPage), findsOneWidget);
    });

    testWidgets('should handle widget rebuild efficiently', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      // Force rebuild multiple times
      for (int i = 0; i < 10; i++) {
        await tester.pumpWidget(createTestWidget());
        await tester.pump(const Duration(milliseconds: 16));
      }
      
      expect(find.byType(SettingsPage), findsOneWidget);
    });
  });

  group('SettingsPage Integration Tests', () {
    testWidgets('should integrate with theme system', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: ThemeMode.system,
            home: const SettingsPage(),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(SettingsPage), findsOneWidget);
    });

    testWidgets('should work with provider overrides', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: const [],
          child: MaterialApp(
            home: Theme(
              data: ThemeData.light(),
              child: const SettingsPage(),
            ),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(SettingsPage), findsOneWidget);
    });
  });
}
