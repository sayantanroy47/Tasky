import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:task_tracker_app/presentation/widgets/standardized_app_bar.dart';
import 'package:task_tracker_app/presentation/widgets/universal_profile_picture.dart';

Widget createTestWidget({required PreferredSizeWidget appBar}) {
  return MaterialApp(
    home: Scaffold(
      appBar: appBar,
      body: const Text('Test Body'),
    ),
  );
}

void main() {
  group('StandardizedAppBar Widget Tests', () {
    testWidgets('should display basic app bar with title', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          appBar: const StandardizedAppBar(
            title: 'Test Title',
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Test Title'), findsOneWidget);
      expect(find.byType(StandardizedAppBar), findsOneWidget);
    });

    testWidgets('should display app bar with custom leading widget', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          appBar: const StandardizedAppBar(
            title: 'Custom Leading',
            leading: Icon(Icons.menu),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Custom Leading'), findsOneWidget);
      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.byType(StandardizedAppBar), findsOneWidget);
    });

    testWidgets('should display app bar with actions', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          appBar: const StandardizedAppBar(
            title: 'With Actions',
            actions: [
              Icon(Icons.search),
              Icon(Icons.more_vert),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('With Actions'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
      expect(find.byType(StandardizedAppBar), findsOneWidget);
    });

    testWidgets('should handle different elevation values', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          appBar: const StandardizedAppBar(
            title: 'No Elevation',
            elevation: 0,
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('No Elevation'), findsOneWidget);
      expect(find.byType(StandardizedAppBar), findsOneWidget);
      
      await tester.pumpWidget(
        createTestWidget(
          appBar: const StandardizedAppBar(
            title: 'High Elevation',
            elevation: 10,
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('High Elevation'), findsOneWidget);
    });

    testWidgets('should handle custom background color', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          appBar: const StandardizedAppBar(
            title: 'Custom Color',
            backgroundColor: Colors.red,
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Custom Color'), findsOneWidget);
      expect(find.byType(StandardizedAppBar), findsOneWidget);
    });

    testWidgets('should show profile picture by default', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          appBar: const StandardizedAppBar(
            title: 'With Profile Picture',
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('With Profile Picture'), findsOneWidget);
      expect(find.byType(UniversalProfilePicture), findsOneWidget);
      expect(find.byType(StandardizedAppBar), findsOneWidget);
    });

    testWidgets('should handle center title property', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          appBar: const StandardizedAppBar(
            title: 'Centered Title',
            centerTitle: true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Centered Title'), findsOneWidget);
      expect(find.byType(StandardizedAppBar), findsOneWidget);
    });

    testWidgets('should handle automaticallyImplyLeading property', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          appBar: const StandardizedAppBar(
            title: 'No Auto Leading',
            automaticallyImplyLeading: false,
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('No Auto Leading'), findsOneWidget);
      expect(find.byType(StandardizedAppBar), findsOneWidget);
    });

    testWidgets('should work with navigation context', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: const StandardizedAppBar(
              title: 'First Page',
            ),
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Scaffold(
                        appBar: StandardizedAppBar(
                          title: 'Second Page',
                        ),
                        body: Text('Second Page Body'),
                      ),
                    ),
                  );
                },
                child: const Text('Navigate'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('First Page'), findsOneWidget);
      
      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();
      
      expect(find.text('Second Page'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('should handle empty title', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          appBar: const StandardizedAppBar(
            title: '',
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(StandardizedAppBar), findsOneWidget);
    });

    testWidgets('should handle long titles', (tester) async {
      const longTitle = 'This is a very long title that might overflow in the app bar';
      
      await tester.pumpWidget(
        createTestWidget(
          appBar: const StandardizedAppBar(
            title: longTitle,
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(StandardizedAppBar), findsOneWidget);
    });

    testWidgets('should work with different themes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            appBar: StandardizedAppBar(
              title: 'Dark Theme',
            ),
            body: Text('Dark Body'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Dark Theme'), findsOneWidget);
      expect(find.byType(StandardizedAppBar), findsOneWidget);
    });

    testWidgets('should handle multiple actions', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          appBar: const StandardizedAppBar(
            title: 'Multiple Actions',
            actions: [
              Icon(Icons.search),
              Icon(Icons.notifications),
              Icon(Icons.settings),
              Icon(Icons.more_vert),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Multiple Actions'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('should handle action tap events', (tester) async {
      bool actionTapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: StandardizedAppBar(
              title: 'Action Test',
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => actionTapped = true,
                ),
              ],
            ),
            body: const Text('Body'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      
      expect(actionTapped, isTrue);
    });

    testWidgets('should be accessible', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          appBar: const StandardizedAppBar(
            title: 'Accessible App Bar',
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(StandardizedAppBar), findsOneWidget);
      
      final semantics = tester.getSemantics(find.byType(StandardizedAppBar));
      expect(semantics, isNotNull);
    });

    testWidgets('should maintain proper height', (tester) async {
      const appBar = StandardizedAppBar(
        title: 'Height Test',
      );
      
      expect(appBar.preferredSize.height, kToolbarHeight);
    });
  });
}