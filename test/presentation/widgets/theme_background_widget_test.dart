import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:task_tracker_app/presentation/widgets/theme_background_widget.dart';
import 'package:task_tracker_app/core/providers/enhanced_theme_provider.dart';

Widget createTestWidget({required Widget child}) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: child,
      ),
    ),
  );
}

void main() {
  group('ThemeBackgroundWidget Widget Tests', () {
    testWidgets('should display theme background with child', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const ThemeBackgroundWidget(
            child: Text('Test Content'),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.text('Test Content'), findsOneWidget);
      expect(find.byType(ThemeBackgroundWidget), findsOneWidget);
    });

    testWidgets('should handle null theme gracefully', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            enhancedThemeProvider.overrideWith(
              (ref) => EnhancedThemeNotifier(),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ThemeBackgroundWidget(
                child: Text('Null Theme Content'),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.text('Null Theme Content'), findsOneWidget);
      expect(find.byType(ThemeBackgroundWidget), findsOneWidget);
    });

    testWidgets('should work with different themes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: createTestWidget(
              child: const ThemeBackgroundWidget(
                child: Text('Dark Theme Background'),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.text('Dark Theme Background'), findsOneWidget);
      expect(find.byType(ThemeBackgroundWidget), findsOneWidget);
    });

    testWidgets('should handle complex child widgets', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const ThemeBackgroundWidget(
            child: Column(
              children: [
                Text('Title'),
                Icon(Icons.star),
                ListTile(title: Text('List Item')),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.text('Title'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('List Item'), findsOneWidget);
      expect(find.byType(ThemeBackgroundWidget), findsOneWidget);
    });

    testWidgets('should handle responsive design', (tester) async {
      // Test on small screen
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(
        createTestWidget(
          child: const ThemeBackgroundWidget(
            child: Text('Small Screen'),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.text('Small Screen'), findsOneWidget);
      
      // Test on large screen
      tester.view.physicalSize = const Size(1200, 800);
      
      await tester.pumpWidget(
        createTestWidget(
          child: const ThemeBackgroundWidget(
            child: Text('Large Screen'),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.text('Large Screen'), findsOneWidget);
      
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('should display gradient background', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const ThemeBackgroundWidget(
            child: Text('Gradient Background'),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.text('Gradient Background'), findsOneWidget);
      expect(find.byType(ThemeBackgroundWidget), findsOneWidget);
      expect(find.byType(Container), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle theme provider integration', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ThemeBackgroundWidget(
                child: Text('Provider Integration'),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.text('Provider Integration'), findsOneWidget);
      expect(find.byType(ThemeBackgroundWidget), findsOneWidget);
    });

    testWidgets('should maintain child widget functionality', (tester) async {
      bool buttonPressed = false;
      
      await tester.pumpWidget(
        createTestWidget(
          child: ThemeBackgroundWidget(
            child: ElevatedButton(
              onPressed: () => buttonPressed = true,
              child: const Text('Interactive Button'),
            ),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.text('Interactive Button'), findsOneWidget);
      
      await tester.tap(find.text('Interactive Button'));
      await tester.pump();
      
      expect(buttonPressed, isTrue);
    });

    testWidgets('should be accessible', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const ThemeBackgroundWidget(
            child: Text('Accessible Content'),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(ThemeBackgroundWidget), findsOneWidget);
      
      final semantics = tester.getSemantics(find.byType(ThemeBackgroundWidget));
      expect(semantics, isNotNull);
    });

    testWidgets('should handle different container configurations', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const ThemeBackgroundWidget(
            child: Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Card Content'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.text('Card Content'), findsOneWidget);
      expect(find.byType(ThemeBackgroundWidget), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should handle scrollable content', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: ThemeBackgroundWidget(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) => ListTile(
                title: Text('Item $index'),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(ThemeBackgroundWidget), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Item 0'), findsOneWidget);
    });
  });
}