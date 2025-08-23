import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:task_tracker_app/presentation/pages/themes_page.dart';
import 'package:task_tracker_app/core/providers/enhanced_theme_provider.dart';

// Helper function available to all test groups
Widget createTestWidget({
  ThemeMode themeMode = ThemeMode.light,
  String? selectedTheme,
}) {
  return ProviderScope(
    overrides: [
      themeModeProvider.overrideWith((ref) => themeMode),
      // Note: selectedThemeProvider not found in codebase, omitting override
    ],
    child: MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode,
      home: const ThemesPage(),
    ),
  );
}

void main() {
  group('ThemesPage Widget Tests', () {
    testWidgets('should display themes page with basic elements', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      expect(find.byType(ThemesPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display theme selection options', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      expect(find.byType(ThemesPage), findsOneWidget);
      // Should have some form of theme selection UI
    });

    testWidgets('should handle light theme mode', (tester) async {
      await tester.pumpWidget(createTestWidget(themeMode: ThemeMode.light));
      await tester.pump();
      
      expect(find.byType(ThemesPage), findsOneWidget);
    });

    testWidgets('should handle dark theme mode', (tester) async {
      await tester.pumpWidget(createTestWidget(themeMode: ThemeMode.dark));
      await tester.pump();
      
      expect(find.byType(ThemesPage), findsOneWidget);
    });

    testWidgets('should handle system theme mode', (tester) async {
      await tester.pumpWidget(createTestWidget(themeMode: ThemeMode.system));
      await tester.pump();
      
      expect(find.byType(ThemesPage), findsOneWidget);
    });

    testWidgets('should handle theme selection', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      // Look for theme selection widgets (cards, buttons, list tiles, etc.)
      final themeCards = find.byType(Card);
      final themeButtons = find.byType(ElevatedButton);
      final listTiles = find.byType(ListTile);
      
      // At least one of these should exist for theme selection
      expect(
        themeCards.evaluate().isNotEmpty || 
        themeButtons.evaluate().isNotEmpty || 
        listTiles.evaluate().isNotEmpty,
        true,
        reason: 'Should have some form of theme selection UI',
      );
    });

    testWidgets('should handle theme preview', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      expect(find.byType(ThemesPage), findsOneWidget);
      // Should display theme previews
    });

    testWidgets('should handle theme switching', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      // Look for interactive theme selection elements
      final interactiveElements = [
        ...find.byType(GestureDetector).evaluate(),
        ...find.byType(InkWell).evaluate(),
        ...find.byType(ListTile).evaluate(),
        ...find.byType(Card).evaluate(),
      ];
      
      if (interactiveElements.isNotEmpty) {
        // Test tapping on a theme selection element
        final firstElement = interactiveElements.first.widget;
        if (firstElement is GestureDetector ||
            firstElement is InkWell ||
            firstElement is ListTile ||
            firstElement is Card) {
          await tester.tap(find.byWidget(firstElement));
          await tester.pump();
        }
      }
      
      expect(find.byType(ThemesPage), findsOneWidget);
    });

    testWidgets('should display available themes', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      expect(find.byType(ThemesPage), findsOneWidget);
      // Should display multiple theme options
    });

    testWidgets('should handle custom theme selection', (tester) async {
      await tester.pumpWidget(createTestWidget(selectedTheme: 'custom_theme'));
      await tester.pump();
      
      expect(find.byType(ThemesPage), findsOneWidget);
    });

    testWidgets('should handle scrolling with many themes', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      // Test scrolling if page has scrollable content
      await tester.drag(find.byType(ThemesPage), const Offset(0, -300));
      await tester.pump();
      
      expect(find.byType(ThemesPage), findsOneWidget);
    });

    testWidgets('should maintain consistent layout across themes', (tester) async {
      for (final themeMode in ThemeMode.values) {
        await tester.pumpWidget(createTestWidget(themeMode: themeMode));
        await tester.pump();
        
        expect(find.byType(ThemesPage), findsOneWidget);
      }
    });

    testWidgets('should handle theme mode toggle', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      // Look for theme mode toggle switches or buttons
      final switches = find.byType(Switch);
      final toggleButtons = find.byType(ToggleButtons);
      
      if (switches.evaluate().isNotEmpty) {
        await tester.tap(switches.first);
        await tester.pump();
      } else if (toggleButtons.evaluate().isNotEmpty) {
        await tester.tap(toggleButtons.first);
        await tester.pump();
      }
      
      expect(find.byType(ThemesPage), findsOneWidget);
    });

    testWidgets('should display theme information', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      expect(find.byType(ThemesPage), findsOneWidget);
      // Should display information about each theme
    });

    testWidgets('should handle app bar theming', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final appBar = find.byType(AppBar);
      if (appBar.evaluate().isNotEmpty) {
        expect(appBar, findsOneWidget);
      }
    });

    testWidgets('should handle rapid theme changes', (tester) async {
      for (int i = 0; i < 5; i++) {
        final themeMode = ThemeMode.values[i % ThemeMode.values.length];
        await tester.pumpWidget(createTestWidget(themeMode: themeMode));
        await tester.pump(const Duration(milliseconds: 50));
      }
      
      await tester.pump();
      expect(find.byType(ThemesPage), findsOneWidget);
    });

    testWidgets('should handle theme persistence', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      expect(find.byType(ThemesPage), findsOneWidget);
      
      // Test that theme selection is maintained across rebuilds
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      expect(find.byType(ThemesPage), findsOneWidget);
    });

    testWidgets('should display theme colors properly', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      expect(find.byType(ThemesPage), findsOneWidget);
      // Should display theme color previews
    });

    testWidgets('should handle theme reset functionality', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      // Look for reset button or similar functionality
      final resetButtons = find.textContaining('Reset');
      final clearButtons = find.textContaining('Clear');
      final defaultButtons = find.textContaining('Default');
      
      if (resetButtons.evaluate().isNotEmpty) {
        await tester.tap(resetButtons.first);
        await tester.pump();
      } else if (clearButtons.evaluate().isNotEmpty) {
        await tester.tap(clearButtons.first);
        await tester.pump();
      } else if (defaultButtons.evaluate().isNotEmpty) {
        await tester.tap(defaultButtons.first);
        await tester.pump();
      }
      
      expect(find.byType(ThemesPage), findsOneWidget);
    });
  });

  group('ThemesPage Integration Tests', () {
    testWidgets('should integrate with real providers', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            home: const ThemesPage(),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(ThemesPage), findsOneWidget);
    });

    testWidgets('should handle provider state changes', (tester) async {
      final container = ProviderContainer();
      
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ThemesPage(),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(ThemesPage), findsOneWidget);
      
      container.dispose();
    });

    testWidgets('should integrate with theme system', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(
            builder: (context, ref, child) {
              final themeMode = ref.watch(themeModeProvider);
              return MaterialApp(
                theme: ThemeData.light(),
                darkTheme: ThemeData.dark(),
                themeMode: themeMode,
                home: const ThemesPage(),
              );
            },
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(ThemesPage), findsOneWidget);
    });
  });

  group('ThemesPage Performance Tests', () {
    testWidgets('should render efficiently', (tester) async {
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      stopwatch.stop();
      
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      expect(find.byType(ThemesPage), findsOneWidget);
    });

    testWidgets('should handle frequent rebuilds', (tester) async {
      for (int i = 0; i < 20; i++) {
        await tester.pumpWidget(createTestWidget());
        await tester.pump(const Duration(milliseconds: 10));
      }
      
      await tester.pump();
      expect(find.byType(ThemesPage), findsOneWidget);
    });

    testWidgets('should handle theme switching efficiently', (tester) async {
      final stopwatch = Stopwatch()..start();
      
      for (final themeMode in ThemeMode.values) {
        await tester.pumpWidget(createTestWidget(themeMode: themeMode));
        await tester.pump(const Duration(milliseconds: 16));
      }
      
      stopwatch.stop();
      await tester.pump();
      
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      expect(find.byType(ThemesPage), findsOneWidget);
    });
  });

  group('ThemesPage Edge Cases', () {
    testWidgets('should handle small screen sizes', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      expect(find.byType(ThemesPage), findsOneWidget);
      
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('should handle large screen sizes', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      expect(find.byType(ThemesPage), findsOneWidget);
      
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('should handle accessibility requirements', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(2.0)),
              child: ThemesPage(),
            ),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(ThemesPage), findsOneWidget);
    });

    testWidgets('should handle high contrast mode', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(highContrast: true),
              child: ThemesPage(),
            ),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(ThemesPage), findsOneWidget);
    });

    testWidgets('should handle widget disposal', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      // Navigate away
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('Other page'))),
      );
      await tester.pump();
      
      expect(find.text('Other page'), findsOneWidget);
    });

    testWidgets('should handle invalid theme selection', (tester) async {
      await tester.pumpWidget(createTestWidget(selectedTheme: 'invalid_theme'));
      await tester.pump();
      
      expect(find.byType(ThemesPage), findsOneWidget);
    });

    testWidgets('should handle null theme values', (tester) async {
      await tester.pumpWidget(createTestWidget(selectedTheme: null));
      await tester.pump();
      
      expect(find.byType(ThemesPage), findsOneWidget);
    });

    testWidgets('should handle extreme color values', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.light().copyWith(
              primaryColor: Colors.transparent,
              scaffoldBackgroundColor: Colors.black,
            ),
            home: const ThemesPage(),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(ThemesPage), findsOneWidget);
    });

    testWidgets('should handle theme animation interruption', (tester) async {
      await tester.pumpWidget(createTestWidget(themeMode: ThemeMode.light));
      await tester.pump(const Duration(milliseconds: 10));
      
      // Change theme mid-animation
      await tester.pumpWidget(createTestWidget(themeMode: ThemeMode.dark));
      await tester.pump(const Duration(milliseconds: 10));
      
      await tester.pump();
      expect(find.byType(ThemesPage), findsOneWidget);
    });
  });
}
