import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:task_tracker_app/presentation/widgets/glassmorphism_container.dart';

Widget createTestWidget({required Widget child}) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}

void main() {
  group('GlassmorphismContainer Widget Tests', () {
    testWidgets('should display glassmorphism container with child', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GlassmorphismContainer(
            child: Text('Test Content'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Test Content'), findsOneWidget);
      expect(find.byType(GlassmorphismContainer), findsOneWidget);
    });

    testWidgets('should handle custom blur radius', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GlassmorphismContainer(
            blur: 20.0,
            child: Text('Blurred Content'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Blurred Content'), findsOneWidget);
      expect(find.byType(GlassmorphismContainer), findsOneWidget);
    });

    testWidgets('should handle custom opacity', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GlassmorphismContainer(
            opacity: 0.3,
            child: Text('Transparent Content'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Transparent Content'), findsOneWidget);
      expect(find.byType(GlassmorphismContainer), findsOneWidget);
    });

    testWidgets('should handle custom border radius', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GlassmorphismContainer(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            child: Text('Rounded Content'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Rounded Content'), findsOneWidget);
      expect(find.byType(GlassmorphismContainer), findsOneWidget);
    });

    testWidgets('should handle custom color', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GlassmorphismContainer(
            glassTint: Colors.red,
            child: Text('Colored Content'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Colored Content'), findsOneWidget);
      expect(find.byType(GlassmorphismContainer), findsOneWidget);
    });

    testWidgets('should handle custom padding', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GlassmorphismContainer(
            padding: EdgeInsets.all(24.0),
            child: Text('Padded Content'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Padded Content'), findsOneWidget);
      expect(find.byType(GlassmorphismContainer), findsOneWidget);
    });

    testWidgets('should handle custom margin', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GlassmorphismContainer(
            margin: EdgeInsets.all(16.0),
            child: Text('Margin Content'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Margin Content'), findsOneWidget);
      expect(find.byType(GlassmorphismContainer), findsOneWidget);
    });

    testWidgets('should handle complex child widgets', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GlassmorphismContainer(
            child: Column(
              children: [
                Text('Title'),
                Icon(Icons.star),
                ElevatedButton(onPressed: null, child: Text('Button')),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Title'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('Button'), findsOneWidget);
      expect(find.byType(GlassmorphismContainer), findsOneWidget);
    });

    testWidgets('should work with different themes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: GlassmorphismContainer(
              child: Text('Dark Theme'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Dark Theme'), findsOneWidget);
      expect(find.byType(GlassmorphismContainer), findsOneWidget);
    });

    testWidgets('should handle extreme blur values', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GlassmorphismContainer(
            blur: 0.0,
            child: Text('No Blur'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('No Blur'), findsOneWidget);
      
      await tester.pumpWidget(
        createTestWidget(
          child: const GlassmorphismContainer(
            blur: 100.0,
            child: Text('Max Blur'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Max Blur'), findsOneWidget);
    });

    testWidgets('should handle extreme opacity values', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GlassmorphismContainer(
            opacity: 0.0,
            child: Text('Invisible'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(GlassmorphismContainer), findsOneWidget);
      
      await tester.pumpWidget(
        createTestWidget(
          child: const GlassmorphismContainer(
            opacity: 1.0,
            child: Text('Opaque'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Opaque'), findsOneWidget);
    });

    testWidgets('should maintain structure with null properties', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GlassmorphismContainer(
            child: Text('Basic Container'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Basic Container'), findsOneWidget);
      expect(find.byType(GlassmorphismContainer), findsOneWidget);
    });

    testWidgets('should be accessible', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GlassmorphismContainer(
            child: Text('Accessible Content'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(GlassmorphismContainer), findsOneWidget);
      
      final semantics = tester.getSemantics(find.byType(GlassmorphismContainer));
      expect(semantics, isNotNull);
    });
  });
}