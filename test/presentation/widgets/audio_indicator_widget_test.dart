import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:task_tracker_app/presentation/widgets/audio_indicator_widget.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';

Widget createTestWidget({
  required TaskModel task,
  double? size,
  VoidCallback? onTap,
}) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: AudioIndicatorWidget(
          task: task,
          size: size ?? 16,
          onTap: onTap,
        ),
      ),
    ),
  );
}

TaskModel createTestTask({
  String? id,
  String? title,
  String? audioFilePath,
}) {
  final task = TaskModel.create(
    title: title ?? 'Test Task',
  );
  
  if (audioFilePath != null) {
    return task.copyWith(
      metadata: {
        ...task.metadata,
        'audio': {
          'filePath': audioFilePath,
          'duration': 30,
          'format': 'm4a',
        }
      }
    );
  }
  
  return task;
}

void main() {
  group('AudioIndicatorWidget Widget Tests', () {
    testWidgets('should display nothing when task has no audio', (tester) async {
      final task = createTestTask(); // No audio file path
      
      await tester.pumpWidget(
        createTestWidget(task: task),
      );
      await tester.pump();
      
      expect(find.byType(AudioIndicatorWidget), findsOneWidget);
      expect(find.byType(GestureDetector), findsNothing);
      expect(find.byType(Container), findsNothing);
    });

    testWidgets('should display audio indicator when task has audio', (tester) async {
      final task = createTestTask(audioFilePath: '/path/to/audio.m4a');
      
      await tester.pumpWidget(
        createTestWidget(task: task),
      );
      await tester.pump();
      
      expect(find.byType(AudioIndicatorWidget), findsOneWidget);
      expect(find.byType(GestureDetector), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
      expect(find.byIcon(PhosphorIcons.speakerHigh()), findsOneWidget);
    });

    testWidgets('should handle custom size', (tester) async {
      final task = createTestTask(audioFilePath: '/path/to/audio.m4a');
      
      await tester.pumpWidget(
        createTestWidget(
          task: task,
          size: 24,
        ),
      );
      await tester.pump();
      
      final container = tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.maxWidth, equals(28)); // size + 4
      expect(container.constraints?.maxHeight, equals(28));
      
      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.size, closeTo(16.8, 0.1)); // size * 0.7 with tolerance
    });

    testWidgets('should call custom onTap when provided', (tester) async {
      final task = createTestTask(audioFilePath: '/path/to/audio.m4a');
      bool customTapCalled = false;
      
      await tester.pumpWidget(
        createTestWidget(
          task: task,
          onTap: () => customTapCalled = true,
        ),
      );
      await tester.pump();
      
      await tester.tap(find.byType(GestureDetector));
      await tester.pump();
      
      expect(customTapCalled, isTrue);
    });

    testWidgets('should handle theming correctly', (tester) async {
      final task = createTestTask(audioFilePath: '/path/to/audio.m4a');
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: AudioIndicatorWidget(task: task),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(AudioIndicatorWidget), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
      expect(find.byIcon(PhosphorIcons.speakerHigh()), findsOneWidget);
    });

    testWidgets('should be accessible', (tester) async {
      final task = createTestTask(audioFilePath: '/path/to/audio.m4a');
      
      await tester.pumpWidget(
        createTestWidget(task: task),
      );
      await tester.pump();
      
      final audioIndicatorSemantics = tester.getSemantics(find.byType(AudioIndicatorWidget));
      expect(audioIndicatorSemantics, isNotNull);
      
      final gestureDetectorSemantics = tester.getSemantics(find.byType(GestureDetector));
      expect(gestureDetectorSemantics, isNotNull);
    });

    testWidgets('should handle different audio file formats', (tester) async {
      final tasks = [
        createTestTask(audioFilePath: '/path/to/audio.mp3'),
        createTestTask(audioFilePath: '/path/to/audio.wav'),
        createTestTask(audioFilePath: '/path/to/audio.aac'),
        createTestTask(audioFilePath: '/path/to/audio.m4a'),
      ];
      
      for (final task in tasks) {
        await tester.pumpWidget(
          createTestWidget(task: task),
        );
        await tester.pump();
        
        expect(find.byType(AudioIndicatorWidget), findsOneWidget);
        expect(find.byType(GestureDetector), findsOneWidget);
        expect(find.byIcon(PhosphorIcons.speakerHigh()), findsOneWidget);
      }
    });

    testWidgets('should handle different sizes correctly', (tester) async {
      final task = createTestTask(audioFilePath: '/path/to/audio.m4a');
      final sizes = [8.0, 16.0, 24.0, 32.0];
      
      for (final size in sizes) {
        await tester.pumpWidget(
          createTestWidget(
            task: task,
            size: size,
          ),
        );
        await tester.pump();
        
        expect(find.byType(AudioIndicatorWidget), findsOneWidget);
        
        final icon = tester.widget<Icon>(find.byType(Icon));
        expect(icon.size, closeTo(size * 0.7, 0.1));
      }
    });

    testWidgets('should maintain correct visual styling', (tester) async {
      final task = createTestTask(audioFilePath: '/path/to/audio.m4a');
      
      await tester.pumpWidget(
        createTestWidget(task: task),
      );
      await tester.pump();
      
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      
      expect(decoration.borderRadius, isA<BorderRadius>());
      expect(decoration.border, isA<Border>());
      expect(decoration.color, isNotNull);
    });
  });
}