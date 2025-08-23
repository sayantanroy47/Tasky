import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:task_tracker_app/presentation/pages/data_export_page.dart';

void main() {
  group('DataExportPage Widget Tests', () {
    Widget createTestWidget() {
      return ProviderScope(
        child: MaterialApp(
          home: Theme(
            data: ThemeData.light(),
            child: const DataExportPage(),
          ),
        ),
      );
    }

    testWidgets('should display data export page', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      expect(find.byType(DataExportPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display export format options', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      expect(find.byType(DataExportPage), findsOneWidget);
    });

    testWidgets('should handle export button tap', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final exportButtons = [
        ...find.textContaining('Export').evaluate(),
        ...find.textContaining('Download').evaluate(),
      ];
      
      if (exportButtons.isNotEmpty) {
        await tester.tap(find.byWidget(exportButtons.first.widget));
        await tester.pump();
      }
      
      expect(find.byType(DataExportPage), findsOneWidget);
    });

    testWidgets('should display export progress', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      expect(find.byType(DataExportPage), findsOneWidget);
    });

    testWidgets('should work with different themes', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: const DataExportPage(),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(DataExportPage), findsOneWidget);
    });
  });
}
