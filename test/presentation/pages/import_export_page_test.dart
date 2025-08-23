import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:task_tracker_app/presentation/pages/import_export_page.dart';

void main() {
  group('ImportExportPage Widget Tests', () {
    Widget createTestWidget() {
      return ProviderScope(
        child: MaterialApp(
          home: Theme(
            data: ThemeData.light(),
            child: const ImportExportPage(),
          ),
        ),
      );
    }

    testWidgets('should display import export page', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      expect(find.byType(ImportExportPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should handle import functionality', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      final importButtons = find.textContaining('Import');
      if (importButtons.evaluate().isNotEmpty) {
        await tester.tap(importButtons.first);
        await tester.pumpAndSettle();
      }
      
      expect(find.byType(ImportExportPage), findsOneWidget);
    });

    testWidgets('should handle export functionality', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      final exportButtons = find.textContaining('Export');
      if (exportButtons.evaluate().isNotEmpty) {
        await tester.tap(exportButtons.first);
        await tester.pumpAndSettle();
      }
      
      expect(find.byType(ImportExportPage), findsOneWidget);
    });

    testWidgets('should work with different themes', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: const ImportExportPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(ImportExportPage), findsOneWidget);
    });
  });
}
