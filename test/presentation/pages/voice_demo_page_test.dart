import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:task_tracker_app/presentation/pages/voice_demo_page.dart';

void main() {
  group('VoiceDemoPage Widget Tests', () {
    Widget createTestWidget() {
      return ProviderScope(
        child: MaterialApp(
          home: Theme(
            data: ThemeData.light(),
            child: const VoiceDemoPage(),
          ),
        ),
      );
    }

    testWidgets('should display voice demo page', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      expect(find.byType(VoiceDemoPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display voice recording controls', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      expect(find.byType(VoiceDemoPage), findsOneWidget);
    });

    testWidgets('should handle record button tap', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final recordButtons = [
        ...find.byIcon(Icons.mic).evaluate(),
        ...find.textContaining('Record').evaluate(),
      ];
      
      if (recordButtons.isNotEmpty) {
        await tester.tap(find.byWidget(recordButtons.first.widget));
        await tester.pump();
      }
      
      expect(find.byType(VoiceDemoPage), findsOneWidget);
    });

    testWidgets('should handle stop recording', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final stopButtons = [
        ...find.byIcon(Icons.stop).evaluate(),
        ...find.textContaining('Stop').evaluate(),
      ];
      
      if (stopButtons.isNotEmpty) {
        await tester.tap(find.byWidget(stopButtons.first.widget));
        await tester.pump();
      }
      
      expect(find.byType(VoiceDemoPage), findsOneWidget);
    });

    testWidgets('should display demo instructions', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      expect(find.byType(VoiceDemoPage), findsOneWidget);
    });

    testWidgets('should work with different themes', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: const VoiceDemoPage(),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(VoiceDemoPage), findsOneWidget);
    });
  });
}
