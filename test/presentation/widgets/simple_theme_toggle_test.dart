import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:task_tracker_app/presentation/widgets/simple_theme_toggle.dart';
import 'package:task_tracker_app/core/providers/enhanced_theme_provider.dart';
import 'package:task_tracker_app/core/theme/app_theme_data.dart';
import 'package:task_tracker_app/core/theme/themes/matrix_theme.dart';
import 'package:task_tracker_app/core/theme/themes/vegeta_blue_theme.dart';

/// Mock Enhanced Theme Notifier for testing
class MockEnhancedThemeNotifier extends EnhancedThemeNotifier {
  String? lastSetThemeId;
  
  @override
  Future<void> setTheme(String themeId, {bool saveToPrefs = true}) async {
    lastSetThemeId = themeId;
    // Don't call super to avoid actual theme changes in tests
  }
}

Widget createTestWidget({
  AppThemeData? currentTheme,
  MockEnhancedThemeNotifier? mockNotifier,
}) {
  final notifier = mockNotifier ?? MockEnhancedThemeNotifier();
  
  return ProviderScope(
    overrides: [
      enhancedThemeProvider.overrideWith((ref) => notifier),
      if (currentTheme != null)
        enhancedThemeProvider.overrideWith((ref) {
          notifier.state = EnhancedThemeState(currentTheme: currentTheme);
          return notifier;
        }),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: ThemeToggleButton(),
      ),
    ),
  );
}

void main() {
  group('ThemeToggleButton Widget Tests', () {
    testWidgets('should display nothing when no theme is available', (tester) async {
      await tester.pumpWidget(
        createTestWidget(),
      );
      await tester.pump();
      
      expect(find.byType(ThemeToggleButton), findsOneWidget);
      expect(find.byType(IconButton), findsNothing);
    });

    testWidgets('should display sun icon for dark themes', (tester) async {
      final darkTheme = MatrixTheme.createDark();
      
      await tester.pumpWidget(
        createTestWidget(currentTheme: darkTheme),
      );
      await tester.pump();
      
      expect(find.byType(ThemeToggleButton), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);
      expect(find.byIcon(PhosphorIcons.sun()), findsOneWidget);
    });

    testWidgets('should display moon icon for light themes', (tester) async {
      final lightTheme = MatrixTheme.createLight();
      
      await tester.pumpWidget(
        createTestWidget(currentTheme: lightTheme),
      );
      await tester.pump();
      
      expect(find.byType(ThemeToggleButton), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);
      expect(find.byIcon(PhosphorIcons.moon()), findsOneWidget);
    });

    testWidgets('should show correct tooltip for dark themes', (tester) async {
      final darkTheme = MatrixTheme.createDark();
      
      await tester.pumpWidget(
        createTestWidget(currentTheme: darkTheme),
      );
      await tester.pump();
      
      final iconButton = find.byType(IconButton);
      expect(iconButton, findsOneWidget);
      
      // Long press to show tooltip
      await tester.longPress(iconButton);
      await tester.pump();
      
      expect(find.text('Switch to light variant'), findsOneWidget);
    });

    testWidgets('should show correct tooltip for light themes', (tester) async {
      final lightTheme = MatrixTheme.createLight();
      
      await tester.pumpWidget(
        createTestWidget(currentTheme: lightTheme),
      );
      await tester.pump();
      
      final iconButton = find.byType(IconButton);
      expect(iconButton, findsOneWidget);
      
      // Long press to show tooltip
      await tester.longPress(iconButton);
      await tester.pump();
      
      expect(find.text('Switch to dark variant'), findsOneWidget);
    });

    testWidgets('should toggle from dark to light theme on tap', (tester) async {
      final darkTheme = MatrixTheme.createDark();
      final mockNotifier = MockEnhancedThemeNotifier();
      
      await tester.pumpWidget(
        createTestWidget(
          currentTheme: darkTheme,
          mockNotifier: mockNotifier,
        ),
      );
      await tester.pump();
      
      await tester.tap(find.byType(IconButton));
      await tester.pump();
      
      expect(mockNotifier.lastSetThemeId, equals('matrix'));
    });

    testWidgets('should toggle from light to dark theme on tap', (tester) async {
      final lightTheme = MatrixTheme.createLight();
      final mockNotifier = MockEnhancedThemeNotifier();
      
      await tester.pumpWidget(
        createTestWidget(
          currentTheme: lightTheme,
          mockNotifier: mockNotifier,
        ),
      );
      await tester.pump();
      
      await tester.tap(find.byType(IconButton));
      await tester.pump();
      
      expect(mockNotifier.lastSetThemeId, equals('matrix_dark'));
    });

    testWidgets('should handle vegeta theme variants correctly', (tester) async {
      final vegetaLightTheme = VegetaBlueTheme.createLight();
      final mockNotifier = MockEnhancedThemeNotifier();
      
      await tester.pumpWidget(
        createTestWidget(
          currentTheme: vegetaLightTheme,
          mockNotifier: mockNotifier,
        ),
      );
      await tester.pump();
      
      await tester.tap(find.byType(IconButton));
      await tester.pump();
      
      expect(mockNotifier.lastSetThemeId, equals('vegeta_blue_dark'));
    });

    testWidgets('should handle vegeta dark theme variants correctly', (tester) async {
      final vegetaDarkTheme = VegetaBlueTheme.createDark();
      final mockNotifier = MockEnhancedThemeNotifier();
      
      await tester.pumpWidget(
        createTestWidget(
          currentTheme: vegetaDarkTheme,
          mockNotifier: mockNotifier,
        ),
      );
      await tester.pump();
      
      await tester.tap(find.byType(IconButton));
      await tester.pump();
      
      expect(mockNotifier.lastSetThemeId, equals('vegeta_blue'));
    });

    testWidgets('should work with different theme variants', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: ThemeToggleButton(),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(ThemeToggleButton), findsOneWidget);
    });

    testWidgets('should be accessible', (tester) async {
      final lightTheme = MatrixTheme.createLight();
      
      await tester.pumpWidget(
        createTestWidget(currentTheme: lightTheme),
      );
      await tester.pump();
      
      final toggleButtonSemantics = tester.getSemantics(find.byType(ThemeToggleButton));
      expect(toggleButtonSemantics, isNotNull);
      
      final iconButtonSemantics = tester.getSemantics(find.byType(IconButton));
      expect(iconButtonSemantics, isNotNull);
    });

    testWidgets('should handle theme changes reactively', (tester) async {
      final lightTheme = MatrixTheme.createLight();
      final mockNotifier = MockEnhancedThemeNotifier();
      
      await tester.pumpWidget(
        createTestWidget(
          currentTheme: lightTheme,
          mockNotifier: mockNotifier,
        ),
      );
      await tester.pump();
      
      // Should show moon icon for light theme
      expect(find.byIcon(PhosphorIcons.moon()), findsOneWidget);
      
      // Simulate theme change to dark
      final darkTheme = MatrixTheme.createDark();
      mockNotifier.state = EnhancedThemeState(currentTheme: darkTheme);
      
      await tester.pumpWidget(
        createTestWidget(
          currentTheme: darkTheme,
          mockNotifier: mockNotifier,
        ),
      );
      await tester.pump();
      
      // Should now show sun icon for dark theme
      expect(find.byIcon(PhosphorIcons.sun()), findsOneWidget);
    });

    testWidgets('should handle button interactions correctly', (tester) async {
      final lightTheme = MatrixTheme.createLight();
      final mockNotifier = MockEnhancedThemeNotifier();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            enhancedThemeProvider.overrideWith((ref) {
              mockNotifier.state = EnhancedThemeState(currentTheme: lightTheme);
              return mockNotifier;
            }),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ThemeToggleButton(),
            ),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(IconButton), findsOneWidget);
      
      await tester.tap(find.byType(IconButton));
      await tester.pump();
      
      // Should have called setTheme on the notifier
      expect(mockNotifier.lastSetThemeId, isNotNull);
    });
  });
}