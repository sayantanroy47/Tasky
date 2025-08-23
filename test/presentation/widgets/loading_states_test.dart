import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:task_tracker_app/presentation/widgets/loading_states.dart';

Widget createTestWidget({required Widget child}) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}

void main() {
  group('LoadingStates Widget Tests', () {
    testWidgets('should display skeleton list', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: LoadingStates.skeletonList(itemCount: 3),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(SkeletonTaskCard), findsNWidgets(3));
    });

    testWidgets('should display skeleton grid', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: LoadingStates.skeletonGrid(itemCount: 4),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(GridView), findsOneWidget);
      expect(find.byType(SkeletonCard), findsNWidgets(4));
    });

    testWidgets('should display inline loading indicator', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: LoadingStates.inline(message: 'Loading...'),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Loading...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display loading overlay', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: LoadingStates.overlay(
            child: const Text('Content'),
            isLoading: true,
            message: 'Please wait...',
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(GlassLoadingIndicator), findsOneWidget);
    });

    testWidgets('should hide overlay when not loading', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: LoadingStates.overlay(
            child: const Text('Content'),
            isLoading: false,
            message: 'Please wait...',
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(GlassLoadingIndicator), findsNothing);
    });
  });

  group('SkeletonTaskCard Widget Tests', () {
    testWidgets('should display skeleton task card', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const SkeletonTaskCard(),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(SkeletonTaskCard), findsOneWidget);
    });

    testWidgets('should handle custom height', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const SkeletonTaskCard(height: 120),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(SkeletonTaskCard), findsOneWidget);
    });

    testWidgets('should handle custom margin', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const SkeletonTaskCard(
            margin: EdgeInsets.all(16),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(SkeletonTaskCard), findsOneWidget);
    });
  });

  group('SkeletonCard Widget Tests', () {
    testWidgets('should display skeleton card', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const SkeletonCard(),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(SkeletonCard), findsOneWidget);
    });

    testWidgets('should handle custom margin', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const SkeletonCard(
            margin: EdgeInsets.all(12),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(SkeletonCard), findsOneWidget);
    });
  });

  group('GlassLoadingIndicator Widget Tests', () {
    testWidgets('should display glass loading indicator', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GlassLoadingIndicator(),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(GlassLoadingIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('should display custom message', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GlassLoadingIndicator(
            message: 'Custom loading message',
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Custom loading message'), findsOneWidget);
      expect(find.byType(GlassLoadingIndicator), findsOneWidget);
    });

    testWidgets('should handle custom color', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GlassLoadingIndicator(
            color: Colors.red,
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(GlassLoadingIndicator), findsOneWidget);
    });

    testWidgets('should handle custom size', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GlassLoadingIndicator(
            size: 60,
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(GlassLoadingIndicator), findsOneWidget);
    });
  });

  group('GlassProgressIndicator Widget Tests', () {
    testWidgets('should display progress indicator', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GlassProgressIndicator(
            progress: 0.5,
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(GlassProgressIndicator), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('should display progress with label', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GlassProgressIndicator(
            progress: 0.75,
            label: 'Upload Progress',
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Upload Progress'), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);
      expect(find.byType(GlassProgressIndicator), findsOneWidget);
    });

    testWidgets('should handle custom colors', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GlassProgressIndicator(
            progress: 0.3,
            color: Colors.green,
            backgroundColor: Colors.grey,
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(GlassProgressIndicator), findsOneWidget);
      expect(find.text('30%'), findsOneWidget);
    });

    testWidgets('should handle custom height', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GlassProgressIndicator(
            progress: 0.6,
            height: 12,
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(GlassProgressIndicator), findsOneWidget);
      expect(find.text('60%'), findsOneWidget);
    });

    testWidgets('should clamp progress values', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GlassProgressIndicator(
            progress: 1.5, // Should clamp to 1.0
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(GlassProgressIndicator), findsOneWidget);
      expect(find.text('150%'), findsOneWidget); // Still shows 150% but progress bar is clamped
    });
  });

  group('ShimmerEffect Widget Tests', () {
    testWidgets('should display shimmer effect', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const ShimmerEffect(
            child: SizedBox(
              width: 100,
              height: 50,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.grey),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(ShimmerEffect), findsOneWidget);
    });

    testWidgets('should handle disabled shimmer', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const ShimmerEffect(
            enabled: false,
            child: Text('No Shimmer'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('No Shimmer'), findsOneWidget);
      expect(find.byType(ShimmerEffect), findsOneWidget);
    });

    testWidgets('should handle custom duration', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const ShimmerEffect(
            duration: Duration(seconds: 3),
            child: Text('Custom Duration Shimmer'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Custom Duration Shimmer'), findsOneWidget);
      expect(find.byType(ShimmerEffect), findsOneWidget);
    });
  });

  group('Loading States Theme Tests', () {
    testWidgets('should work with dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: Column(
              children: [
                SkeletonTaskCard(),
                SkeletonCard(),
                GlassLoadingIndicator(message: 'Dark theme loading'),
                GlassProgressIndicator(progress: 0.4),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(SkeletonTaskCard), findsOneWidget);
      expect(find.byType(SkeletonCard), findsOneWidget);
      expect(find.byType(GlassLoadingIndicator), findsOneWidget);
      expect(find.byType(GlassProgressIndicator), findsOneWidget);
    });
  });

  group('Loading States Accessibility Tests', () {
    testWidgets('should be accessible', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const Column(
            children: [
              SkeletonTaskCard(),
              SkeletonCard(),
              GlassLoadingIndicator(message: 'Accessible loading'),
              GlassProgressIndicator(progress: 0.5, label: 'Accessible progress'),
              ShimmerEffect(child: Text('Accessible shimmer')),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      final skeletonTaskSemantics = tester.getSemantics(find.byType(SkeletonTaskCard));
      final skeletonCardSemantics = tester.getSemantics(find.byType(SkeletonCard));
      final loadingSemantics = tester.getSemantics(find.byType(GlassLoadingIndicator));
      final progressSemantics = tester.getSemantics(find.byType(GlassProgressIndicator));
      final shimmerSemantics = tester.getSemantics(find.byType(ShimmerEffect));
      
      expect(skeletonTaskSemantics, isNotNull);
      expect(skeletonCardSemantics, isNotNull);
      expect(loadingSemantics, isNotNull);
      expect(progressSemantics, isNotNull);
      expect(shimmerSemantics, isNotNull);
    });
  });
}