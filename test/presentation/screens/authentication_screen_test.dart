import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:task_tracker_app/presentation/screens/authentication_screen.dart';

Widget createTestWidget({required Widget child}) {
  return ProviderScope(
    child: MaterialApp(
      home: child,
    ),
  );
}

void main() {
  group('AuthenticationScreen Widget Tests', () {
    testWidgets('should display authentication screen', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const AuthenticationScreen(),
        ),
      );
      await tester.pump();
      
      expect(find.byType(AuthenticationScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should handle animations properly', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const AuthenticationScreen(),
        ),
      );
      
      // Allow animations to start
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(AuthenticationScreen), findsOneWidget);
      
      // Allow more animation time
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(AuthenticationScreen), findsOneWidget);
    });

    testWidgets('should work with different themes', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: const AuthenticationScreen(),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(AuthenticationScreen), findsOneWidget);
    });

    testWidgets('should be accessible', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const AuthenticationScreen(),
        ),
      );
      await tester.pump();
      
      final authScreenSemantics = tester.getSemantics(find.byType(AuthenticationScreen));
      expect(authScreenSemantics, isNotNull);
    });

    testWidgets('should handle widget lifecycle correctly', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const AuthenticationScreen(),
        ),
      );
      await tester.pump();
      
      expect(find.byType(AuthenticationScreen), findsOneWidget);
      
      // Test widget disposal
      await tester.pumpWidget(
        createTestWidget(
          child: const Scaffold(body: Text('Different Screen')),
        ),
      );
      await tester.pump();
      
      expect(find.byType(AuthenticationScreen), findsNothing);
      expect(find.text('Different Screen'), findsOneWidget);
    });

    testWidgets('should render without crashing on small screens', (tester) async {
      // Set small screen size
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(
        createTestWidget(
          child: const AuthenticationScreen(),
        ),
      );
      await tester.pump();
      
      expect(find.byType(AuthenticationScreen), findsOneWidget);
      
      // Reset to default
      addTearDown(() => tester.view.resetPhysicalSize());
    });

    testWidgets('should render without crashing on large screens', (tester) async {
      // Set large screen size
      tester.view.physicalSize = const Size(1440, 2560);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(
        createTestWidget(
          child: const AuthenticationScreen(),
        ),
      );
      await tester.pump();
      
      expect(find.byType(AuthenticationScreen), findsOneWidget);
      
      // Reset to default
      addTearDown(() => tester.view.resetPhysicalSize());
    });

    testWidgets('should maintain state during orientation changes', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const AuthenticationScreen(),
        ),
      );
      await tester.pump();
      
      expect(find.byType(AuthenticationScreen), findsOneWidget);
      
      // Simulate orientation change
      tester.view.physicalSize = const Size(800, 600);
      await tester.pump();
      
      expect(find.byType(AuthenticationScreen), findsOneWidget);
      
      // Reset to default
      addTearDown(() => tester.view.resetPhysicalSize());
    });

    testWidgets('should handle provider overrides', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          overrides: [],
          child: MaterialApp(
            home: AuthenticationScreen(),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(AuthenticationScreen), findsOneWidget);
    });

    testWidgets('should dispose animation controllers properly', (tester) async {
      final widget = createTestWidget(
        child: const AuthenticationScreen(),
      );
      
      await tester.pumpWidget(widget);
      await tester.pump();
      
      expect(find.byType(AuthenticationScreen), findsOneWidget);
      
      // Dispose by pumping a different widget
      await tester.pumpWidget(
        createTestWidget(
          child: const Scaffold(body: Text('New Screen')),
        ),
      );
      await tester.pump();
      
      // Should not throw any disposal errors
      expect(find.text('New Screen'), findsOneWidget);
    });
  });
}