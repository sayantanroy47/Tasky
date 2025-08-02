import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:task_tracker_app/presentation/widgets/analytics_widgets.dart';
import 'package:task_tracker_app/services/analytics/analytics_models.dart';

void main() {
  group('AnalyticsMetricCard', () {
    testWidgets('should display metric information correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnalyticsMetricCard(
              title: 'Completed Tasks',
              value: '42',
              subtitle: 'this week',
              icon: Icons.check_circle,
              color: Colors.green,
              trend: '+12%',
              isPositiveTrend: true,
            ),
          ),
        ),
      );

      expect(find.text('Completed Tasks'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
      expect(find.text('this week'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('+12%'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
    });

    testWidgets('should handle negative trend correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnalyticsMetricCard(
              title: 'Productivity',
              value: '75%',
              subtitle: 'completion rate',
              icon: Icons.trending_down,
              color: Colors.red,
              trend: '-5%',
              isPositiveTrend: false,
            ),
          ),
        ),
      );

      expect(find.text('-5%'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
    });

    testWidgets('should handle no trend correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnalyticsMetricCard(
              title: 'Total Tasks',
              value: '100',
              subtitle: 'all time',
              icon: Icons.task,
              color: Colors.blue,
            ),
          ),
        ),
      );

      expect(find.text('Total Tasks'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward), findsNothing);
      expect(find.byIcon(Icons.arrow_downward), findsNothing);
    });

    testWidgets('should handle tap correctly', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalyticsMetricCard(
              title: 'Tappable Card',
              value: '1',
              subtitle: 'tap me',
              icon: Icons.touch_app,
              color: Colors.purple,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AnalyticsMetricCard));
      expect(tapped, isTrue);
    });
  });

  group('SimpleBarChart', () {
    testWidgets('should display chart with correct data', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SimpleBarChart(
              values: [10, 20, 15, 25, 30],
              labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
              title: 'Daily Completion',
            ),
          ),
        ),
      );

      expect(find.text('Daily Completion'), findsOneWidget);
      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Tue'), findsOneWidget);
      expect(find.text('Wed'), findsOneWidget);
      expect(find.text('Thu'), findsOneWidget);
      expect(find.text('Fri'), findsOneWidget);
    });

    testWidgets('should handle empty data', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SimpleBarChart(
              values: [],
              labels: [],
              title: 'Empty Chart',
            ),
          ),
        ),
      );

      expect(find.text('Empty Chart'), findsOneWidget);
    });

    testWidgets('should use custom color when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SimpleBarChart(
              values: [10, 20],
              labels: ['A', 'B'],
              title: 'Custom Color Chart',
              barColor: Colors.red,
            ),
          ),
        ),
      );

      expect(find.text('Custom Color Chart'), findsOneWidget);
    });
  });

  group('CategoryBreakdownWidget', () {
    testWidgets('should display category analytics correctly', (tester) async {
      final categories = [
        const CategoryAnalytics(
          categoryName: 'Work',
          categoryId: 'work',
          totalTasks: 20,
          completedTasks: 15,
          pendingTasks: 5,
          completionRate: 0.75,
          averageDuration: 60.0,
          priorityDistribution: {'High': 5, 'Medium': 10, 'Low': 5},
        ),
        const CategoryAnalytics(
          categoryName: 'Personal',
          categoryId: 'personal',
          totalTasks: 10,
          completedTasks: 8,
          pendingTasks: 2,
          completionRate: 0.8,
          averageDuration: 30.0,
          priorityDistribution: {'High': 2, 'Medium': 5, 'Low': 3},
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryBreakdownWidget(
              categories: categories,
              title: 'Task Categories',
            ),
          ),
        ),
      );

      expect(find.text('Task Categories'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('Personal'), findsOneWidget);
      expect(find.text('20 tasks'), findsOneWidget);
      expect(find.text('10 tasks'), findsOneWidget);
      expect(find.text('75% completion rate'), findsOneWidget);
      expect(find.text('80% completion rate'), findsOneWidget);
    });

    testWidgets('should handle empty categories', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CategoryBreakdownWidget(
              categories: [],
              title: 'Empty Categories',
            ),
          ),
        ),
      );

      expect(find.text('Empty Categories'), findsOneWidget);
    });

    testWidgets('should limit to 5 categories', (tester) async {
      final categories = List.generate(10, (index) => CategoryAnalytics(
        categoryName: 'Category $index',
        categoryId: 'cat_$index',
        totalTasks: 10 - index,
        completedTasks: 5,
        pendingTasks: 5 - index,
        completionRate: 0.5,
        averageDuration: 30.0,
        priorityDistribution: const {'Medium': 10},
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryBreakdownWidget(
              categories: categories,
              title: 'Many Categories',
            ),
          ),
        ),
      );

      expect(find.text('Many Categories'), findsOneWidget);
      expect(find.text('Category 0'), findsOneWidget);
      expect(find.text('Category 4'), findsOneWidget);
      expect(find.text('Category 5'), findsNothing); // Should be limited to 5
    });
  });

  group('ProductivityInsightsWidget', () {
    testWidgets('should display productivity insights', (tester) async {
      final metrics = ProductivityMetrics(
        weeklyCompletionRate: 0.8,
        monthlyCompletionRate: 0.7,
        tasksCompletedThisWeek: 20,
        tasksCompletedThisMonth: 80,
        currentStreak: 5,
        longestStreak: 10,
        weeklyTrend: const [5, 6, 4, 8, 7, 9, 6],
        monthlyTrend: List.filled(30, 3),
        hourlyProductivity: const {9: 10, 14: 8, 19: 5},
        weekdayProductivity: const {1: 15, 2: 12, 3: 18, 4: 10, 5: 8, 6: 5, 7: 3},
        averageTasksPerDay: 3.5,
        averageCompletionTime: 45.0,
      );

      const hourlyProductivity = {9: 10, 14: 8, 19: 5};
      const weekdayProductivity = {1: 15, 2: 12, 3: 18, 4: 10, 5: 8, 6: 5, 7: 3};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductivityInsightsWidget(
              metrics: metrics,
              hourlyProductivity: hourlyProductivity,
              weekdayProductivity: weekdayProductivity,
            ),
          ),
        ),
      );

      expect(find.text('Productivity Insights'), findsOneWidget);
      expect(find.text('Peak Productivity'), findsOneWidget);
      expect(find.text('Current Streak'), findsOneWidget);
      expect(find.text('Improving Trend'), findsOneWidget);
    });
  });

  group('StreakWidget', () {
    testWidgets('should display active streak correctly', (tester) async {
      final now = DateTime.now();
      final streakInfo = StreakInfo(
        currentStreak: 7,
        longestStreak: 15,
        lastCompletionDate: now,
        streakStartDate: now.subtract(const Duration(days: 6)),
        completionDates: List.generate(7, (i) => now.subtract(Duration(days: i))),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StreakWidget(streakInfo: streakInfo),
          ),
        ),
      );

      expect(find.text('Task Completion Streak'), findsOneWidget);
      expect(find.text('Current Streak'), findsOneWidget);
      expect(find.text('Longest Streak'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
      expect(find.text('Last completion: Today'), findsOneWidget);
    });

    testWidgets('should display inactive streak correctly', (tester) async {
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      final streakInfo = StreakInfo(
        currentStreak: 0,
        longestStreak: 5,
        lastCompletionDate: twoDaysAgo,
        completionDates: [twoDaysAgo],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StreakWidget(streakInfo: streakInfo),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.textContaining('Last completion:'), findsOneWidget);
    });

    testWidgets('should handle no completion date', (tester) async {
      const streakInfo = StreakInfo(
        currentStreak: 0,
        longestStreak: 0,
        completionDates: [],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StreakWidget(streakInfo: streakInfo),
          ),
        ),
      );

      expect(find.text('0'), findsNWidgets(2)); // Both current and longest streak
      expect(find.textContaining('Last completion:'), findsNothing);
    });
  });

  group('TimePeriodSelector', () {
    testWidgets('should display all time periods except custom', (tester) async {
      AnalyticsTimePeriod? selectedPeriod;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimePeriodSelector(
              selectedPeriod: AnalyticsTimePeriod.thisWeek,
              onPeriodChanged: (period) => selectedPeriod = period,
            ),
          ),
        ),
      );

      expect(find.text('Time Period'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('This Week'), findsOneWidget);
      expect(find.text('This Month'), findsOneWidget);
      expect(find.text('This Year'), findsOneWidget);
      expect(find.text('Last 7 Days'), findsOneWidget);
      expect(find.text('Last 30 Days'), findsOneWidget);
      expect(find.text('Last 90 Days'), findsOneWidget);
      expect(find.text('Custom Range'), findsNothing);
    });

    testWidgets('should handle period selection', (tester) async {
      AnalyticsTimePeriod? selectedPeriod;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimePeriodSelector(
              selectedPeriod: AnalyticsTimePeriod.thisWeek,
              onPeriodChanged: (period) => selectedPeriod = period,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();

      expect(selectedPeriod, equals(AnalyticsTimePeriod.today));
    });

    testWidgets('should show selected period correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimePeriodSelector(
              selectedPeriod: AnalyticsTimePeriod.thisMonth,
              onPeriodChanged: (period) {},
            ),
          ),
        ),
      );

      // Find the FilterChip for "This Month" and verify it's selected
      final thisMonthChip = find.widgetWithText(FilterChip, 'This Month');
      expect(thisMonthChip, findsOneWidget);
      
      final chip = tester.widget<FilterChip>(thisMonthChip);
      expect(chip.selected, isTrue);
    });
  });

  group('CategoryItem', () {
    testWidgets('should display category information correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CategoryItem(
              name: 'Work Tasks',
              percentage: 65,
              color: Colors.blue,
              count: 25,
              completionRate: 0.8,
            ),
          ),
        ),
      );

      expect(find.text('Work Tasks'), findsOneWidget);
      expect(find.text('25 tasks'), findsOneWidget);
      expect(find.text('65%'), findsOneWidget);
      expect(find.text('80% completion rate'), findsOneWidget);
    });
  });

  group('InsightItem', () {
    testWidgets('should display insight information correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InsightItem(
              icon: Icons.lightbulb,
              title: 'Peak Hours',
              description: 'You are most productive in the morning',
              color: Colors.amber,
            ),
          ),
        ),
      );

      expect(find.text('Peak Hours'), findsOneWidget);
      expect(find.text('You are most productive in the morning'), findsOneWidget);
      expect(find.byIcon(Icons.lightbulb), findsOneWidget);
    });
  });
}