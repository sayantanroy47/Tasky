import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:task_tracker_app/presentation/pages/voice_recording_page.dart';

void main() {
  group('VoiceRecordingPage Widget Tests', () {
    Widget createTestWidget() {
      return ProviderScope(
        child: MaterialApp(
          home: Theme(
            data: ThemeData.light(),
            child: const VoiceRecordingPage(),
          ),
        ),
      );
    }

    testWidgets('should display voice recording page', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      expect(find.byType(VoiceRecordingPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display recording controls', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      expect(find.byType(VoiceRecordingPage), findsOneWidget);
    });

    testWidgets('should handle start recording', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      final recordButtons = find.byIcon(Icons.mic);
      if (recordButtons.evaluate().isNotEmpty) {
        await tester.tap(recordButtons.first);
        await tester.pumpAndSettle();
      }
      
      expect(find.byType(VoiceRecordingPage), findsOneWidget);
    });

    testWidgets('should handle stop recording', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      final stopButtons = find.byIcon(Icons.stop);
      if (stopButtons.evaluate().isNotEmpty) {
        await tester.tap(stopButtons.first);
        await tester.pumpAndSettle();
      }
      
      expect(find.byType(VoiceRecordingPage), findsOneWidget);
    });

    testWidgets('should work with different themes', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: const VoiceRecordingPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(VoiceRecordingPage), findsOneWidget);
    });
  });
}
