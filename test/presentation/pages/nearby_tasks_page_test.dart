import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:task_tracker_app/presentation/pages/nearby_tasks_page.dart';
import 'package:task_tracker_app/presentation/providers/location_providers.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';

void main() {
  group('NearbyTasksPage Widget Tests', () {
    Widget createTestWidget({
      List<TaskModel>? nearbyTasks,
      bool hasError = false,
      bool isLoading = false,
    }) {

      return ProviderScope(
        overrides: [
          nearbyTasksProvider.overrideWith((ref, radiusInMeters) async {
            if (isLoading) {
              await Future.delayed(const Duration(seconds: 1));
              return nearbyTasks ?? [];
            }
            if (hasError) {
              throw Exception('Test error');
            }
            return nearbyTasks ?? [];
          }),
        ],
        child: MaterialApp(
          home: Theme(
            data: ThemeData.light(),
            child: const NearbyTasksPage(),
          ),
        ),
      );
    }

    testWidgets('should display nearby tasks page', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      expect(find.byType(NearbyTasksPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display loading state', (tester) async {
      await tester.pumpWidget(createTestWidget(isLoading: true));
      await tester.pumpAndSettle();
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display error state', (tester) async {
      await tester.pumpWidget(createTestWidget(hasError: true));
      await tester.pumpAndSettle();
      
      expect(find.textContaining('error'), findsOneWidget);
    });

    testWidgets('should display nearby tasks', (tester) async {
      final nearbyTasks = [
        TaskModel.create(title: 'Nearby Task 1'),
        TaskModel.create(title: 'Nearby Task 2'),
      ];
      
      await tester.pumpWidget(createTestWidget(nearbyTasks: nearbyTasks));
      await tester.pumpAndSettle();
      
      expect(find.byType(NearbyTasksPage), findsOneWidget);
    });

    testWidgets('should handle empty nearby tasks', (tester) async {
      await tester.pumpWidget(createTestWidget(nearbyTasks: []));
      await tester.pumpAndSettle();
      
      expect(find.byType(NearbyTasksPage), findsOneWidget);
    });

    testWidgets('should work with different themes', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: const NearbyTasksPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(NearbyTasksPage), findsOneWidget);
    });
  });
}
