import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:task_tracker_app/presentation/widgets/error_widgets.dart';
import 'package:task_tracker_app/core/errors/failures.dart';

Widget createTestWidget({required Widget child}) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}

void main() {
  group('SimpleErrorWidget Widget Tests', () {
    testWidgets('should display basic error message', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const SimpleErrorWidget(
            message: 'Something went wrong',
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.byType(SimpleErrorWidget), findsOneWidget);
    });

    testWidgets('should display error message with retry button', (tester) async {
      bool retryPressed = false;
      
      await tester.pumpWidget(
        createTestWidget(
          child: SimpleErrorWidget(
            message: 'Error with retry',
            onRetry: () => retryPressed = true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Error with retry'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byType(SimpleErrorWidget), findsOneWidget);
      
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      
      expect(retryPressed, isTrue);
    });

    testWidgets('should display error message with custom icon', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const SimpleErrorWidget(
            message: 'Custom icon error',
            icon: Icons.warning,
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Custom icon error'), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsOneWidget);
      expect(find.byType(SimpleErrorWidget), findsOneWidget);
    });

    testWidgets('should handle compact mode', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const SimpleErrorWidget(
            message: 'Compact error',
            compact: true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Compact error'), findsOneWidget);
      expect(find.byType(SimpleErrorWidget), findsOneWidget);
    });
  });

  group('EnhancedErrorDialog Widget Tests', () {
    testWidgets('should display error dialog with message', (tester) async {
      const error = UnknownFailure('Test error message');
      
      await tester.pumpWidget(
        createTestWidget(
          child: const EnhancedErrorDialog(error: error),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Error Occurred'), findsOneWidget);
      expect(find.text('Test error message'), findsOneWidget);
      expect(find.byType(EnhancedErrorDialog), findsOneWidget);
    });

    testWidgets('should display error dialog with retry button', (tester) async {
      bool retryPressed = false;
      const error = UnknownFailure('Test error message');
      
      await tester.pumpWidget(
        createTestWidget(
          child: EnhancedErrorDialog(
            error: error,
            onRetry: () => retryPressed = true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Error Occurred'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byType(EnhancedErrorDialog), findsOneWidget);
      
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      
      expect(retryPressed, isTrue);
    });

    testWidgets('should display custom title and message', (tester) async {
      const error = UnknownFailure('Test error message');
      
      await tester.pumpWidget(
        createTestWidget(
          child: const EnhancedErrorDialog(
            error: error,
            customTitle: 'Custom Error Title',
            customMessage: 'Custom error description',
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Custom Error Title'), findsOneWidget);
      expect(find.text('Custom error description'), findsOneWidget);
      expect(find.byType(EnhancedErrorDialog), findsOneWidget);
    });

    testWidgets('should handle dismiss callback', (tester) async {
      bool dismissPressed = false;
      const error = UnknownFailure('Test error message');
      
      await tester.pumpWidget(
        createTestWidget(
          child: EnhancedErrorDialog(
            error: error,
            onDismiss: () => dismissPressed = true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Dismiss'), findsOneWidget);
      
      await tester.tap(find.text('Dismiss'));
      await tester.pumpAndSettle();
      
      expect(dismissPressed, isTrue);
    });

    testWidgets('should show copy error button', (tester) async {
      const error = UnknownFailure('Test error message');
      
      await tester.pumpWidget(
        createTestWidget(
          child: const EnhancedErrorDialog(error: error),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Copy Error'), findsOneWidget);
      expect(find.byType(EnhancedErrorDialog), findsOneWidget);
    });
  });

  group('CriticalErrorScreen Widget Tests', () {
    testWidgets('should display critical error screen', (tester) async {
      const error = UnknownFailure('Critical error message');
      
      await tester.pumpWidget(
        createTestWidget(
          child: const CriticalErrorScreen(error: error),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Critical Error'), findsOneWidget);
      expect(find.byType(CriticalErrorScreen), findsOneWidget);
    });

    testWidgets('should display restart button', (tester) async {
      const error = UnknownFailure('Critical error message');
      
      await tester.pumpWidget(
        createTestWidget(
          child: const CriticalErrorScreen(error: error),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Restart App'), findsOneWidget);
      expect(find.byType(CriticalErrorScreen), findsOneWidget);
    });

    testWidgets('should handle custom restart callback', (tester) async {
      bool restartPressed = false;
      const error = UnknownFailure('Critical error message');
      
      await tester.pumpWidget(
        createTestWidget(
          child: CriticalErrorScreen(
            error: error,
            onRestart: () => restartPressed = true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Restart App'));
      await tester.pumpAndSettle();
      
      expect(restartPressed, isTrue);
    });

    testWidgets('should display custom title and message', (tester) async {
      const error = UnknownFailure('Critical error message');
      
      await tester.pumpWidget(
        createTestWidget(
          child: const CriticalErrorScreen(
            error: error,
            customTitle: 'Custom Critical Error',
            customMessage: 'Custom critical error description',
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Custom Critical Error'), findsOneWidget);
      expect(find.text('Custom critical error description'), findsOneWidget);
    });

    testWidgets('should show report issue and copy error buttons', (tester) async {
      const error = UnknownFailure('Critical error message');
      
      await tester.pumpWidget(
        createTestWidget(
          child: const CriticalErrorScreen(error: error),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Report Issue'), findsOneWidget);
      expect(find.text('Copy Error Details'), findsOneWidget);
    });
  });

  group('LoadingErrorWidget Widget Tests', () {
    testWidgets('should display loading error widget', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const LoadingErrorWidget(
            message: 'Loading error message',
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Loading error message'), findsOneWidget);
      expect(find.byType(LoadingErrorWidget), findsOneWidget);
    });

    testWidgets('should display loading error with retry button', (tester) async {
      bool retryPressed = false;
      
      await tester.pumpWidget(
        createTestWidget(
          child: LoadingErrorWidget(
            message: 'Loading error with retry',
            onRetry: () => retryPressed = true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Loading error with retry'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byType(LoadingErrorWidget), findsOneWidget);
      
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      
      expect(retryPressed, isTrue);
    });
  });

  group('Error Widget Theme Tests', () {
    testWidgets('should work with dark theme', (tester) async {
      const error = UnknownFailure('Dark theme error');
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: const Column(
              children: [
                SimpleErrorWidget(message: 'Dark theme error'),
                EnhancedErrorDialog(error: error),
                CriticalErrorScreen(error: error),
                LoadingErrorWidget(message: 'Loading error'),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(SimpleErrorWidget), findsOneWidget);
      expect(find.byType(EnhancedErrorDialog), findsOneWidget);
      expect(find.byType(CriticalErrorScreen), findsOneWidget);
      expect(find.byType(LoadingErrorWidget), findsOneWidget);
    });
  });

  group('Error Widget Accessibility Tests', () {
    testWidgets('should be accessible', (tester) async {
      const error = UnknownFailure('Accessible error');
      
      await tester.pumpWidget(
        createTestWidget(
          child: const Column(
            children: [
              SimpleErrorWidget(message: 'Accessible error'),
              EnhancedErrorDialog(error: error),
              CriticalErrorScreen(error: error),
              LoadingErrorWidget(message: 'Accessible loading error'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      final simpleErrorSemantics = tester.getSemantics(find.byType(SimpleErrorWidget));
      final enhancedErrorSemantics = tester.getSemantics(find.byType(EnhancedErrorDialog));
      final criticalErrorSemantics = tester.getSemantics(find.byType(CriticalErrorScreen));
      final loadingErrorSemantics = tester.getSemantics(find.byType(LoadingErrorWidget));
      
      expect(simpleErrorSemantics, isNotNull);
      expect(enhancedErrorSemantics, isNotNull);
      expect(criticalErrorSemantics, isNotNull);
      expect(loadingErrorSemantics, isNotNull);
    });
  });
}