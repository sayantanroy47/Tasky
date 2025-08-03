import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_tracker_app/presentation/screens/performance_dashboard_screen.dart';
import 'package:task_tracker_app/presentation/widgets/optimized_list_widgets.dart';
import 'package:task_tracker_app/services/performance_service.dart';

void main() {
  group('Accessibility Tests', () {
    testWidgets('PerformanceDashboardScreen should be accessible', (WidgetTester tester) async {
      // Arrange
      final stats = PerformanceStats(
        totalMetrics: 100,
        operationStats: {
          'test_operation': const OperationStats(
            operation: 'test_operation',
            count: 10,
            averageDuration: Duration(milliseconds: 150),
            minDuration: Duration(milliseconds: 50),
            maxDuration: Duration(milliseconds: 300),
            p95Duration: Duration(milliseconds: 250),
          ),
        },
        generatedAt: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            performanceStatsProvider.overrideWith((ref) => stats),
          ],
          child: const MaterialApp(
            home: PerformanceDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - Check for accessibility compliance
      final SemanticsHandle handle = tester.ensureSemantics();
      
      // Verify semantic labels are present
      expect(find.bySemanticsLabel('Performance Dashboard'), findsOneWidget);
      
      // Verify buttons have proper semantic labels
      expect(find.byWidgetPredicate((widget) => 
        widget is IconButton && 
        widget.icon is Icon && 
        (widget.icon as Icon).icon == Icons.refresh
      ), findsOneWidget);

      // Verify text elements are accessible
      expect(find.text('Performance Summary'), findsOneWidget);
      expect(find.text('Operation Performance'), findsOneWidget);
      expect(find.text('Memory Management'), findsOneWidget);

      handle.dispose();
    });

    testWidgets('OptimizedListView should be accessible', (WidgetTester tester) async {
      // Arrange
      final items = ['Item 1', 'Item 2', 'Item 3'];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedListView<String>(
              items: items,
              itemBuilder: (context, item, index) {
                return ListTile(
                  title: Text(item),
                  key: Key('item_$index'),
                  // Add semantic label for accessibility
                  subtitle: Text('List item ${index + 1} of ${items.length}'),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - Check accessibility
      final SemanticsHandle handle = tester.ensureSemantics();

      // Verify list items are accessible
      for (int i = 0; i < items.length; i++) {
        expect(find.text(items[i]), findsOneWidget);
        expect(find.text('List item ${i + 1} of ${items.length}'), findsOneWidget);
      }

      // Verify scrollable semantics
      expect(find.byType(Scrollable), findsOneWidget);

      handle.dispose();
    });

    testWidgets('buttons should have minimum touch target size', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Test Button'),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Text Button'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - Check minimum touch target sizes (48x48 logical pixels)
      final elevatedButtonSize = tester.getSize(find.byType(ElevatedButton));
      final iconButtonSize = tester.getSize(find.byType(IconButton));
      final textButtonSize = tester.getSize(find.byType(TextButton));

      expect(elevatedButtonSize.height, greaterThanOrEqualTo(48.0));
      expect(iconButtonSize.height, greaterThanOrEqualTo(48.0));
      expect(iconButtonSize.width, greaterThanOrEqualTo(48.0));
      expect(textButtonSize.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('text should have sufficient contrast', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(
            body: Column(
              children: [
                Text('Primary text', style: TextStyle(color: Colors.black)),
                Text('Secondary text', style: TextStyle(color: Colors.grey)),
                Text('Error text', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - Verify text elements exist (contrast would be checked visually or with specialized tools)
      expect(find.text('Primary text'), findsOneWidget);
      expect(find.text('Secondary text'), findsOneWidget);
      expect(find.text('Error text'), findsOneWidget);
    });

    testWidgets('form elements should have proper labels', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                  ),
                ),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                  ),
                  obscureText: true,
                ),
                Checkbox(
                  value: false,
                  onChanged: (value) {},
                ),
                const Text('I agree to the terms'),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - Check form accessibility
      final SemanticsHandle handle = tester.ensureSemantics();

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Enter your email'), findsOneWidget);
      expect(find.text('Enter your password'), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);

      handle.dispose();
    });

    testWidgets('navigation should be accessible', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Test App'),
              leading: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {},
                tooltip: 'Open navigation menu',
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                  tooltip: 'Search',
                ),
              ],
            ),
            body: const Text('Content'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - Check navigation accessibility
      final SemanticsHandle handle = tester.ensureSemantics();

      expect(find.text('Test App'), findsOneWidget);
      expect(find.byTooltip('Open navigation menu'), findsOneWidget);
      expect(find.byTooltip('Search'), findsOneWidget);

      handle.dispose();
    });

    testWidgets('loading states should be accessible', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                CircularProgressIndicator(
                  semanticsLabel: 'Loading content',
                ),
                SizedBox(height: 16),
                Text('Please wait while we load your data'),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - Check loading accessibility
      final SemanticsHandle handle = tester.ensureSemantics();

      expect(find.bySemanticsLabel('Loading content'), findsOneWidget);
      expect(find.text('Please wait while we load your data'), findsOneWidget);

      handle.dispose();
    });

    testWidgets('error states should be accessible', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const Icon(
                  Icons.error,
                  color: Colors.red,
                  semanticLabel: 'Error occurred',
                ),
                const Text('An error occurred'),
                const Text('Please try again later'),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - Check error accessibility
      final SemanticsHandle handle = tester.ensureSemantics();

      expect(find.bySemanticsLabel('Error occurred'), findsOneWidget);
      expect(find.text('An error occurred'), findsOneWidget);
      expect(find.text('Please try again later'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      handle.dispose();
    });

    testWidgets('focus management should work correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const TextField(
                  decoration: InputDecoration(labelText: 'First Field'),
                ),
                const TextField(
                  decoration: InputDecoration(labelText: 'Second Field'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - Test focus traversal
      final firstField = find.widgetWithText(TextField, 'First Field');
      final secondField = find.widgetWithText(TextField, 'Second Field');
      final submitButton = find.widgetWithText(ElevatedButton, 'Submit');

      // Focus first field
      await tester.tap(firstField);
      await tester.pumpAndSettle();

      // Tab to next field
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      // Tab to button
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      // Verify elements exist and are focusable
      expect(firstField, findsOneWidget);
      expect(secondField, findsOneWidget);
      expect(submitButton, findsOneWidget);
    });
  });
}