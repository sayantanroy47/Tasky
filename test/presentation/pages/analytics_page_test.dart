import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:task_tracker_app/presentation/pages/analytics_page.dart';
import 'package:task_tracker_app/presentation/providers/analytics_providers.dart';
import 'package:task_tracker_app/services/analytics/analytics_models.dart';

void main() {
  group('AnalyticsPage Widget Tests', () {
    AnalyticsSummary createDefaultAnalyticsSummary() {
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      
      return AnalyticsSummary(
        startDate: weekAgo,
        endDate: now,
        totalTasks: 0,
        completedTasks: 0,
        pendingTasks: 0,
        cancelledTasks: 0,
        completionRate: 0.0,
        currentStreak: 0,
        longestStreak: 0,
        averageTaskDuration: 0.0,
        tasksByPriority: const <String, int>{},
        tasksByStatus: const <String, int>{},
        tasksByTag: const <String, int>{},
        tasksByProject: const <String, int>{},
        dailyStats: const <DailyStats>[],
      );
    }

    Widget createTestWidget({
      AnalyticsSummary? analyticsSummary,
      bool hasError = false,
      bool isLoading = false,
    }) {

      return ProviderScope(
        overrides: [
          analyticsSummaryProvider.overrideWith((ref) async {
            if (isLoading) {
              await Future.delayed(const Duration(seconds: 1));
              return analyticsSummary ?? createDefaultAnalyticsSummary();
            }
            if (hasError) {
              throw Exception('Test error');
            }
            return analyticsSummary ?? createDefaultAnalyticsSummary();
          }),
        ],
        child: MaterialApp(
          home: Theme(
            data: ThemeData.light(),
            child: const AnalyticsPage(),
          ),
        ),
      );
    }


    AnalyticsSummary createTestAnalyticsData() {
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      
      return AnalyticsSummary(
        startDate: weekAgo,
        endDate: now,
        totalTasks: 100,
        completedTasks: 75,
        pendingTasks: 20,
        cancelledTasks: 5,
        completionRate: 0.75,
        currentStreak: 3,
        longestStreak: 10,
        averageTaskDuration: 120.0,
        tasksByPriority: const {
          'urgent': 10,
          'high': 25,
          'medium': 40,
          'low': 25,
        },
        tasksByStatus: const {
          'completed': 75,
          'pending': 20,
          'cancelled': 5,
        },
        tasksByTag: const {
          'work': 40,
          'personal': 35,
          'urgent': 15,
          'shopping': 10,
        },
        tasksByProject: const {
          'project1': 30,
          'project2': 25,
          'no_project': 45,
        },
        dailyStats: [
          DailyStats(
            date: now.subtract(const Duration(days: 1)),
            totalTasks: 15,
            completedTasks: 12,
            createdTasks: 5,
            completionRate: 0.8,
            totalDuration: 180.0,
            tasksByPriority: const {'high': 5, 'medium': 7, 'low': 3},
            tasksByTag: const {'work': 8, 'personal': 7},
          ),
        ],
      );
    }

    testWidgets('should display analytics page with basic elements', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      expect(find.byType(AnalyticsPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display loading state', (tester) async {
      await tester.pumpWidget(createTestWidget(isLoading: true));
      await tester.pump();
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display error state', (tester) async {
      await tester.pumpWidget(createTestWidget(hasError: true));
      await tester.pump();
      
      expect(find.textContaining('error'), findsOneWidget, reason: 'Should display error message');
    });

    testWidgets('should display analytics data when available', (tester) async {
      final data = createTestAnalyticsData();
      
      await tester.pumpWidget(createTestWidget(analyticsSummary: data));
      await tester.pump();
      
      expect(find.byType(AnalyticsPage), findsOneWidget);
    });

    testWidgets('should handle empty analytics data', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      expect(find.byType(AnalyticsPage), findsOneWidget);
    });

    testWidgets('should work with different themes', (tester) async {
      final data = createTestAnalyticsData();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            analyticsSummaryProvider.overrideWith((ref) async => data),
          ],
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: const AnalyticsPage(),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(AnalyticsPage), findsOneWidget);
    });
  });
}
