import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracker_app/presentation/widgets/optimized_list_widgets.dart';

void main() {
  group('OptimizedListView', () {
    testWidgets('should render list items correctly', (WidgetTester tester) async {
      final items = ['Item 1', 'Item 2', 'Item 3'];
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedListView<String>(
              items: items,
              itemBuilder: (context, item, index) {
                return ListTile(
                  title: Text(item),
                  key: Key('item_$index'),
                );
              },
            ),
          ),
        ),
      );

      // Verify all items are rendered
      for (int i = 0; i < items.length; i++) {
        expect(find.byKey(Key('item_$i')), findsOneWidget);
        expect(find.text(items[i]), findsOneWidget);
      }
    });

    testWidgets('should handle empty list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedListView<String>(
              items: const [],
              itemBuilder: (context, item, index) {
                return ListTile(title: Text(item));
              },
            ),
          ),
        ),
      );

      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('should use RepaintBoundary for performance', (WidgetTester tester) async {
      final items = ['Item 1', 'Item 2'];
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedListView<String>(
              items: items,
              itemBuilder: (context, item, index) {
                return ListTile(title: Text(item));
              },
            ),
          ),
        ),
      );

      expect(find.byType(RepaintBoundary), findsAtLeastNWidgets(items.length));
    });

    testWidgets('should handle scroll events', (WidgetTester tester) async {
      final items = List.generate(100, (index) => 'Item $index');
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedListView<String>(
              items: items,
              itemBuilder: (context, item, index) {
                return SizedBox(
                  height: 50,
                  child: ListTile(title: Text(item)),
                );
              },
              itemExtent: 50,
            ),
          ),
        ),
      );

      // Scroll down
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Verify scrolling worked
      expect(find.text('Item 0'), findsNothing);
      expect(find.text('Item 10'), findsOneWidget);
    });

    testWidgets('should trigger lazy loading callback', (WidgetTester tester) async {
      final items = List.generate(20, (index) => 'Item $index');
      bool loadMoreCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedListView<String>(
              items: items,
              itemBuilder: (context, item, index) {
                return SizedBox(
                  height: 50,
                  child: ListTile(title: Text(item)),
                );
              },
              itemExtent: 50,
              enableLazyLoading: true,
              onScrollEnd: () {
                loadMoreCalled = true;
              },
            ),
          ),
        ),
      );

      // Scroll to bottom
      await tester.drag(find.byType(ListView), const Offset(0, -1000));
      await tester.pumpAndSettle();

      expect(loadMoreCalled, isTrue);
    });
  });

  group('OptimizedGridView', () {
    testWidgets('should render grid items correctly', (WidgetTester tester) async {
      final items = ['Item 1', 'Item 2', 'Item 3', 'Item 4'];
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedGridView<String>(
              items: items,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemBuilder: (context, item, index) {
                return Card(
                  child: Center(
                    child: Text(item, key: Key('item_$index')),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Verify all items are rendered
      for (int i = 0; i < items.length; i++) {
        expect(find.byKey(Key('item_$i')), findsOneWidget);
        expect(find.text(items[i]), findsOneWidget);
      }
    });

    testWidgets('should use RepaintBoundary for performance', (WidgetTester tester) async {
      final items = ['Item 1', 'Item 2'];
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedGridView<String>(
              items: items,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemBuilder: (context, item, index) {
                return Card(child: Text(item));
              },
            ),
          ),
        ),
      );

      expect(find.byType(RepaintBoundary), findsAtLeastNWidgets(items.length));
    });
  });

  group('OptimizedSliverList', () {
    testWidgets('should render sliver list items correctly', (WidgetTester tester) async {
      final items = ['Item 1', 'Item 2', 'Item 3'];
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                OptimizedSliverList<String>(
                  items: items,
                  itemBuilder: (context, item, index) {
                    return ListTile(
                      title: Text(item),
                      key: Key('item_$index'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );

      // Verify all items are rendered
      for (int i = 0; i < items.length; i++) {
        expect(find.byKey(Key('item_$i')), findsOneWidget);
        expect(find.text(items[i]), findsOneWidget);
      }
    });
  });

  group('OptimizedAnimatedList', () {
    testWidgets('should render animated list items correctly', (WidgetTester tester) async {
      final items = ['Item 1', 'Item 2', 'Item 3'];
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedAnimatedList<String>(
              items: items,
              itemBuilder: (context, item, index, animation) {
                return SlideTransition(
                  position: animation.drive(
                    Tween(begin: const Offset(1, 0), end: Offset.zero),
                  ),
                  child: ListTile(
                    title: Text(item),
                    key: Key('item_$index'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Wait for animations to complete
      await tester.pumpAndSettle();

      // Verify all items are rendered
      for (int i = 0; i < items.length; i++) {
        expect(find.byKey(Key('item_$i')), findsOneWidget);
        expect(find.text(items[i]), findsOneWidget);
      }
    });

    testWidgets('should animate item insertions', (WidgetTester tester) async {
      List<String> items = ['Item 1', 'Item 2'];
      
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: OptimizedAnimatedList<String>(
                  items: items,
                  itemBuilder: (context, item, index, animation) {
                    return SlideTransition(
                      position: animation.drive(
                        Tween(begin: const Offset(1, 0), end: Offset.zero),
                      ),
                      child: ListTile(
                        title: Text(item),
                        key: Key('item_$index'),
                      ),
                    );
                  },
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      items = [...items, 'Item ${items.length + 1}'];
                    });
                  },
                  child: const Icon(Icons.add),
                ),
              );
            },
          ),
        ),
      );

      // Initial state
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsNothing);

      // Add new item
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      // Wait for animation
      await tester.pumpAndSettle();

      // Verify new item is added
      expect(find.text('Item 3'), findsOneWidget);
    });
  });

  group('LazyLoadingWrapper', () {
    testWidgets('should show loading indicator when loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LazyLoadingWrapper(
              isLoading: true,
              hasMore: true,
              onLoadMore: () {},
              child: const Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should not show loading indicator when not loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LazyLoadingWrapper(
              isLoading: false,
              hasMore: true,
              onLoadMore: () {},
              child: const Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should use custom loading widget', (WidgetTester tester) async {
      const customLoadingWidget = Text('Custom Loading');
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LazyLoadingWrapper(
              isLoading: true,
              hasMore: true,
              onLoadMore: () {},
              loadingWidget: customLoadingWidget,
              child: const Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.text('Custom Loading'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}