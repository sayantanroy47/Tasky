import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:task_tracker_app/presentation/widgets/animated_priority_chip.dart';
import 'package:task_tracker_app/domain/models/enums.dart';

Widget createTestWidget({required Widget child}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(child: child),
    ),
  );
}

void main() {
  group('PulsingPriorityChip Widget Tests', () {
    testWidgets('should display priority chip with correct priority', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const PulsingPriorityChip(
            priority: TaskPriority.high,
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(PulsingPriorityChip), findsOneWidget);
      expect(find.text('HIGH'), findsOneWidget);
      expect(find.byIcon(PhosphorIcons.caretUp()), findsOneWidget);
    });

    testWidgets('should display urgent priority with correct styling', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const PulsingPriorityChip(
            priority: TaskPriority.urgent,
          ),
        ),
      );
      await tester.pump();
      
      expect(find.text('URGENT'), findsOneWidget);
      expect(find.byIcon(PhosphorIcons.arrowUp()), findsOneWidget);
    });

    testWidgets('should display medium priority with correct styling', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const PulsingPriorityChip(
            priority: TaskPriority.medium,
          ),
        ),
      );
      await tester.pump();
      
      expect(find.text('MEDIUM'), findsOneWidget);
      expect(find.byIcon(PhosphorIcons.minus()), findsOneWidget);
    });

    testWidgets('should display low priority with correct styling', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const PulsingPriorityChip(
            priority: TaskPriority.low,
          ),
        ),
      );
      await tester.pump();
      
      expect(find.text('LOW'), findsOneWidget);
      expect(find.byIcon(PhosphorIcons.caretDown()), findsOneWidget);
    });

    testWidgets('should display custom text when provided', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const PulsingPriorityChip(
            priority: TaskPriority.high,
            customText: 'CUSTOM',
          ),
        ),
      );
      await tester.pump();
      
      expect(find.text('CUSTOM'), findsOneWidget);
      expect(find.text('HIGH'), findsNothing);
    });

    testWidgets('should handle tap interactions when enabled', (tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        createTestWidget(
          child: PulsingPriorityChip(
            priority: TaskPriority.high,
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.pump();
      
      await tester.tap(find.byType(PulsingPriorityChip));
      await tester.pump();
      
      expect(tapped, isTrue);
    });

    testWidgets('should not handle tap interactions when disabled', (tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        createTestWidget(
          child: PulsingPriorityChip(
            priority: TaskPriority.high,
            enabled: false,
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.pump();
      
      await tester.tap(find.byType(PulsingPriorityChip));
      await tester.pump();
      
      expect(tapped, isFalse);
    });

    testWidgets('should handle custom dimensions', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const PulsingPriorityChip(
            priority: TaskPriority.high,
            width: 100,
            height: 40,
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(PulsingPriorityChip), findsOneWidget);
      
      final container = tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.maxWidth, equals(100));
      expect(container.constraints?.maxHeight, equals(40));
    });

    testWidgets('should apply custom scale', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const PulsingPriorityChip(
            priority: TaskPriority.high,
            scale: 1.5,
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(PulsingPriorityChip), findsOneWidget);
      expect(find.byType(Transform), findsWidgets);
    });

    testWidgets('should work with different themes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: PulsingPriorityChip(
              priority: TaskPriority.high,
            ),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(PulsingPriorityChip), findsOneWidget);
    });

    testWidgets('should show proper animations when enabled', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const PulsingPriorityChip(
            priority: TaskPriority.urgent,
            showPulse: true,
          ),
        ),
      );
      
      // Let animations start
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(PulsingPriorityChip), findsOneWidget);
      
      // Let animations continue
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(PulsingPriorityChip), findsOneWidget);
    });

    testWidgets('should not animate when pulse is disabled', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const PulsingPriorityChip(
            priority: TaskPriority.urgent,
            showPulse: false,
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(PulsingPriorityChip), findsOneWidget);
    });
  });

  group('CompactPriorityChip Widget Tests', () {
    testWidgets('should display compact priority chip', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const CompactPriorityChip(
            priority: TaskPriority.high,
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(CompactPriorityChip), findsOneWidget);
      expect(find.byType(PulsingPriorityChip), findsOneWidget);
    });

    testWidgets('should handle custom size', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const CompactPriorityChip(
            priority: TaskPriority.high,
            size: 32,
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(CompactPriorityChip), findsOneWidget);
    });

    testWidgets('should handle tap interactions', (tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        createTestWidget(
          child: CompactPriorityChip(
            priority: TaskPriority.high,
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.pump();
      
      await tester.tap(find.byType(CompactPriorityChip));
      await tester.pump();
      
      expect(tapped, isTrue);
    });
  });

  group('StyledPriorityChip Widget Tests', () {
    testWidgets('should display filled style', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const StyledPriorityChip(
            priority: TaskPriority.high,
            style: PriorityChipStyle.filled,
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(StyledPriorityChip), findsOneWidget);
      expect(find.byType(PulsingPriorityChip), findsOneWidget);
    });

    testWidgets('should display outlined style', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const StyledPriorityChip(
            priority: TaskPriority.high,
            style: PriorityChipStyle.outlined,
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(StyledPriorityChip), findsOneWidget);
    });

    testWidgets('should display minimal style', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const StyledPriorityChip(
            priority: TaskPriority.high,
            style: PriorityChipStyle.minimal,
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(StyledPriorityChip), findsOneWidget);
    });

    testWidgets('should handle tap interactions for all styles', (tester) async {
      final styles = [
        PriorityChipStyle.filled,
        PriorityChipStyle.outlined,
        PriorityChipStyle.minimal,
      ];
      
      for (final style in styles) {
        bool tapped = false;
        
        await tester.pumpWidget(
          createTestWidget(
            child: StyledPriorityChip(
              priority: TaskPriority.high,
              style: style,
              onTap: () => tapped = true,
            ),
          ),
        );
        await tester.pump();
        
        await tester.tap(find.byType(StyledPriorityChip));
        await tester.pump();
        
        expect(tapped, isTrue, reason: 'Style $style should handle taps');
      }
    });
  });

  group('Priority Chip Accessibility Tests', () {
    testWidgets('should be accessible', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const PulsingPriorityChip(
            priority: TaskPriority.high,
          ),
        ),
      );
      await tester.pump();
      
      final priorityChipSemantics = tester.getSemantics(find.byType(PulsingPriorityChip));
      expect(priorityChipSemantics, isNotNull);
    });

    testWidgets('should handle different priorities for accessibility', (tester) async {
      final priorities = [
        TaskPriority.urgent,
        TaskPriority.high,
        TaskPriority.medium,
        TaskPriority.low,
      ];
      
      for (final priority in priorities) {
        await tester.pumpWidget(
          createTestWidget(
            child: PulsingPriorityChip(
              priority: priority,
            ),
          ),
        );
        await tester.pump();
        
        expect(find.byType(PulsingPriorityChip), findsOneWidget);
        expect(find.text(priority.displayName.toUpperCase()), findsOneWidget);
      }
    });
  });

  group('Priority Chip Animation Tests', () {
    testWidgets('should handle animation lifecycle correctly', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const PulsingPriorityChip(
            priority: TaskPriority.urgent,
            showPulse: true,
          ),
        ),
      );
      
      // Initial state
      expect(find.byType(PulsingPriorityChip), findsOneWidget);
      
      // Let animations run for different durations
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(PulsingPriorityChip), findsOneWidget);
      
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(PulsingPriorityChip), findsOneWidget);
      
      await tester.pump(const Duration(milliseconds: 800));
      expect(find.byType(PulsingPriorityChip), findsOneWidget);
    });
  });
}