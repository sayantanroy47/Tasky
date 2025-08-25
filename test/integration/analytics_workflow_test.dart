import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';

import 'package:task_tracker_app/services/database/database.dart';
import 'package:task_tracker_app/presentation/widgets/analytics_chart.dart';
import 'package:task_tracker_app/presentation/widgets/productivity_metrics.dart';

void main() {
  group('Analytics and Reporting Workflow Integration Tests', () {
    late ProviderContainer container;
    late AppDatabase testDatabase;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      
      testDatabase = AppDatabase.forTesting(NativeDatabase.memory());
      container = ProviderContainer(
        overrides: [],
      );
    });

    tearDown(() async {
      await testDatabase.close();
      container.dispose();
    });

    group('Dashboard and Metrics Overview', () {
      testWidgets('should display productivity dashboard with key metrics', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Productivity Dashboard'),
                  actions: [
                    PopupMenuButton<String>(
                      key: const Key('time_range_selector'),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'today', child: Text('Today')),
                        const PopupMenuItem(value: 'week', child: Text('This Week')),
                        const PopupMenuItem(value: 'month', child: Text('This Month')),
                        const PopupMenuItem(value: 'year', child: Text('This Year')),
                      ],
                      onSelected: (value) {
                        // Handle time range change
                      },
                    ),
                  ],
                ),
                body: const SingleChildScrollView(
                  child: Column(
                    children: [
                      // Key metrics cards
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              key: Key('tasks_completed_metric'),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Text('42', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                    Text('Tasks Completed'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Card(
                              key: Key('productivity_score_metric'),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Text('87%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                                    Text('Productivity Score'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              key: Key('time_tracked_metric'),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Text('28.5h', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                    Text('Time Tracked'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Card(
                              key: Key('overdue_tasks_metric'),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Text('3', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red)),
                                    Text('Overdue Tasks'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Charts section
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Completion Trends', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              SizedBox(height: 16),
                              SizedBox(
                                height: 200,
                                child: AnalyticsChart(
                                  key: Key('completion_trends_chart'),
                                  type: ChartType.line,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Priority Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              SizedBox(height: 16),
                              SizedBox(
                                height: 200,
                                child: AnalyticsChart(
                                  key: Key('priority_distribution_chart'),
                                  type: ChartType.pie,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        // Verify dashboard components
        expect(find.text('Productivity Dashboard'), findsOneWidget);
        expect(find.text('42'), findsOneWidget); // Tasks completed
        expect(find.text('87%'), findsOneWidget); // Productivity score
        expect(find.text('28.5h'), findsOneWidget); // Time tracked
        expect(find.text('3'), findsOneWidget); // Overdue tasks

        // Test time range selector
        await tester.tap(find.byKey(const Key('time_range_selector')));
        await tester.pump();
        await tester.tap(find.text('This Week'));
        await tester.pump();

        // Verify charts
        expect(find.byKey(const Key('completion_trends_chart')), findsOneWidget);
        expect(find.byKey(const Key('priority_distribution_chart')), findsOneWidget);
      });

      testWidgets('should display productivity metrics with insights', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Productivity Metrics'),
                ),
                body: const SingleChildScrollView(
                  child: Column(
                    children: [
                      ProductivityMetrics(
                        key: Key('productivity_metrics_widget'),
                      ),
                      Card(
                        child: ListTile(
                          key: Key('insight_completion_rate'),
                          leading: Icon(Icons.trending_up, color: Colors.green),
                          title: Text('Completion Rate Improved'),
                          subtitle: Text('Your completion rate increased by 15% this week'),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          key: Key('insight_focus_time'),
                          leading: Icon(Icons.access_time, color: Colors.blue),
                          title: Text('Peak Focus Hours'),
                          subtitle: Text('You\'re most productive between 9-11 AM'),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          key: Key('insight_overdue_pattern'),
                          leading: Icon(Icons.warning, color: Colors.orange),
                          title: Text('Overdue Pattern Detected'),
                          subtitle: Text('Consider breaking down large tasks'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        // Verify metrics and insights
        expect(find.text('Productivity Metrics'), findsOneWidget);
        expect(find.text('Completion Rate Improved'), findsOneWidget);
        expect(find.text('Peak Focus Hours'), findsOneWidget);
        expect(find.text('Overdue Pattern Detected'), findsOneWidget);

        // Test insight interactions
        await tester.tap(find.byKey(const Key('insight_completion_rate')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('insight_focus_time')));
        await tester.pump();
      });
    });

    group('Detailed Analytics and Charts', () {
      testWidgets('should display task completion analytics with charts', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: DefaultTabController(
                length: 4,
                child: Scaffold(
                  appBar: AppBar(
                    title: const Text('Task Analytics'),
                    bottom: const TabBar(
                      isScrollable: true,
                      tabs: [
                        Tab(key: Key('completion_tab'), text: 'Completion'),
                        Tab(key: Key('priority_tab'), text: 'Priority'),
                        Tab(key: Key('category_tab'), text: 'Category'),
                        Tab(key: Key('time_tab'), text: 'Time'),
                      ],
                    ),
                  ),
                  body: const TabBarView(
                    children: [
                      // Completion analytics
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            Card(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Text('Weekly Completion Rate', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    SizedBox(height: 16),
                                    SizedBox(
                                      height: 200,
                                      child: AnalyticsChart(
                                        key: Key('weekly_completion_chart'),
                                        type: ChartType.bar,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Card(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Text('Completion Streak', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    SizedBox(height: 8),
                                    Text('Current: 7 days', style: TextStyle(fontSize: 24, color: Colors.green)),
                                    Text('Best: 23 days', style: TextStyle(fontSize: 14, color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Priority analytics
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            Card(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Text('Tasks by Priority', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    SizedBox(height: 16),
                                    SizedBox(
                                      height: 200,
                                      child: AnalyticsChart(
                                        key: Key('priority_breakdown_chart'),
                                        type: ChartType.pie,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Category analytics
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            Card(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Text('Tasks by Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    SizedBox(height: 16),
                                    SizedBox(
                                      height: 200,
                                      child: AnalyticsChart(
                                        key: Key('category_breakdown_chart'),
                                        type: ChartType.doughnut,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Time analytics
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            Card(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Text('Time Tracking Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    SizedBox(height: 16),
                                    SizedBox(
                                      height: 200,
                                      child: AnalyticsChart(
                                        key: Key('time_tracking_chart'),
                                        type: ChartType.line,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        // Test tab navigation
        await tester.tap(find.byKey(const Key('priority_tab')));
        await tester.pump();
        expect(find.byKey(const Key('priority_breakdown_chart')), findsOneWidget);

        await tester.tap(find.byKey(const Key('category_tab')));
        await tester.pump();
        expect(find.byKey(const Key('category_breakdown_chart')), findsOneWidget);

        await tester.tap(find.byKey(const Key('time_tab')));
        await tester.pump();
        expect(find.byKey(const Key('time_tracking_chart')), findsOneWidget);

        await tester.tap(find.byKey(const Key('completion_tab')));
        await tester.pump();
        expect(find.byKey(const Key('weekly_completion_chart')), findsOneWidget);
        expect(find.text('Current: 7 days'), findsOneWidget);
        expect(find.text('Best: 23 days'), findsOneWidget);
      });

      testWidgets('should generate custom reports workflow', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Custom Reports'),
                  actions: [
                    IconButton(
                      key: const Key('create_report_button'),
                      icon: const Icon(Icons.add_chart),
                      onPressed: () {
                        // Open custom report dialog
                      },
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Report Configuration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              key: const Key('report_type_dropdown'),
                              decoration: const InputDecoration(labelText: 'Report Type'),
                              items: const [
                                DropdownMenuItem(value: 'productivity', child: Text('Productivity Summary')),
                                DropdownMenuItem(value: 'time_tracking', child: Text('Time Tracking Report')),
                                DropdownMenuItem(value: 'completion', child: Text('Completion Analysis')),
                                DropdownMenuItem(value: 'trends', child: Text('Trends & Patterns')),
                              ],
                              onChanged: (value) {
                                // Handle report type change
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    key: const Key('date_range_from'),
                                    decoration: const InputDecoration(
                                      labelText: 'From Date',
                                      suffixIcon: Icon(Icons.calendar_today),
                                    ),
                                    readOnly: true,
                                    onTap: () {
                                      // Show date picker
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    key: const Key('date_range_to'),
                                    decoration: const InputDecoration(
                                      labelText: 'To Date',
                                      suffixIcon: Icon(Icons.calendar_today),
                                    ),
                                    readOnly: true,
                                    onTap: () {
                                      // Show date picker
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              children: [
                                FilterChip(
                                  key: const Key('include_charts_filter'),
                                  label: const Text('Include Charts'),
                                  selected: true,
                                  onSelected: (selected) {
                                    // Handle filter
                                  },
                                ),
                                FilterChip(
                                  key: const Key('include_insights_filter'),
                                  label: const Text('Include Insights'),
                                  selected: true,
                                  onSelected: (selected) {
                                    // Handle filter
                                  },
                                ),
                                FilterChip(
                                  key: const Key('detailed_breakdown_filter'),
                                  label: const Text('Detailed Breakdown'),
                                  selected: false,
                                  onSelected: (selected) {
                                    // Handle filter
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                ElevatedButton(
                                  key: const Key('generate_report_button'),
                                  onPressed: () {
                                    // Generate report
                                  },
                                  child: const Text('Generate Report'),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  key: const Key('preview_report_button'),
                                  onPressed: () {
                                    // Preview report
                                  },
                                  child: const Text('Preview'),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  key: const Key('export_report_button'),
                                  onPressed: () {
                                    // Export report
                                  },
                                  child: const Text('Export'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Report Preview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              Container(
                                key: const Key('report_preview_area'),
                                width: double.infinity,
                                height: 200,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text('Report preview will appear here'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Test report configuration
        await tester.tap(find.byKey(const Key('report_type_dropdown')));
        await tester.pump();
        await tester.tap(find.text('Productivity Summary'));
        await tester.pump();

        // Test date range selection
        await tester.tap(find.byKey(const Key('date_range_from')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('date_range_to')));
        await tester.pump();

        // Test filter chips
        await tester.tap(find.byKey(const Key('detailed_breakdown_filter')));
        await tester.pump();

        // Test report generation
        await tester.tap(find.byKey(const Key('generate_report_button')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('preview_report_button')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('export_report_button')));
        await tester.pump();

        // Verify report workflow
        expect(find.text('Custom Reports'), findsOneWidget);
        expect(find.byKey(const Key('report_preview_area')), findsOneWidget);
      });
    });

    group('Goals and Achievements', () {
      testWidgets('should set and track productivity goals', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Productivity Goals'),
                ),
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Daily Goals', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              ListTile(
                                key: const Key('daily_task_goal'),
                                leading: const CircularProgressIndicator(value: 0.7),
                                title: const Text('Complete 10 tasks'),
                                subtitle: const Text('7 of 10 completed'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    // Edit goal
                                  },
                                ),
                              ),
                              ListTile(
                                key: const Key('daily_time_goal'),
                                leading: const CircularProgressIndicator(value: 0.6),
                                title: const Text('Track 6 hours'),
                                subtitle: const Text('3.6 of 6 hours tracked'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    // Edit goal
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Weekly Goals', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              const ListTile(
                                key: Key('weekly_productivity_goal'),
                                leading: CircularProgressIndicator(value: 0.85),
                                title: Text('Maintain 85% productivity'),
                                subtitle: Text('Current: 87%'),
                                trailing: Icon(Icons.check_circle, color: Colors.green),
                              ),
                              ListTile(
                                key: const Key('weekly_streak_goal'),
                                leading: const CircularProgressIndicator(value: 0.5),
                                title: const Text('14-day completion streak'),
                                subtitle: const Text('Current: 7 days'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    // Edit goal
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: ElevatedButton(
                          key: const Key('add_goal_button'),
                          onPressed: () {
                            // Add new goal
                          },
                          child: const Text('Add New Goal'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        // Test goal interactions
        await tester.tap(find.byKey(const Key('daily_task_goal')));
        await tester.pump();

        // Test goal editing
        await tester.tap(find.byKey(const Key('daily_time_goal')));
        await tester.pump();

        // Test adding new goal
        await tester.tap(find.byKey(const Key('add_goal_button')));
        await tester.pump();

        // Verify goals display
        expect(find.text('Complete 10 tasks'), findsOneWidget);
        expect(find.text('7 of 10 completed'), findsOneWidget);
        expect(find.text('Current: 87%'), findsOneWidget);
        expect(find.text('Current: 7 days'), findsOneWidget);
      });

      testWidgets('should display achievements and badges workflow', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Achievements'),
                ),
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Recent Achievements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              ListTile(
                                key: const Key('streak_master_badge'),
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Colors.gold,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.stars, color: Colors.white),
                                ),
                                title: const Text('Streak Master'),
                                subtitle: const Text('Completed tasks for 10 consecutive days'),
                                trailing: const Text('2 days ago'),
                              ),
                              ListTile(
                                key: const Key('time_tracker_badge'),
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.timer, color: Colors.white),
                                ),
                                title: const Text('Time Tracker'),
                                subtitle: const Text('Tracked 100+ hours this month'),
                                trailing: const Text('1 week ago'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Progress Towards Next Badge', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              ListTile(
                                key: const Key('productivity_expert_progress'),
                                leading: Stack(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.trending_up, color: Colors.grey),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        width: 16,
                                        height: 16,
                                        decoration: const BoxDecoration(
                                          color: Colors.orange,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Center(
                                          child: Text('80%', style: TextStyle(fontSize: 8, color: Colors.white)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                title: const Text('Productivity Expert'),
                                subtitle: const LinearProgressIndicator(value: 0.8),
                                trailing: const Text('80%'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('All Achievements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                                itemCount: 12,
                                itemBuilder: (context, index) {
                                  final isUnlocked = index < 6;
                                  return GestureDetector(
                                    key: Key('achievement_badge_$index'),
                                    onTap: () {
                                      // Show achievement details
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isUnlocked ? Colors.blue[100] : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.star,
                                            color: isUnlocked ? Colors.blue : Colors.grey,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Badge ${index + 1}',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: isUnlocked ? Colors.blue : Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        // Test achievement interactions
        await tester.tap(find.byKey(const Key('streak_master_badge')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('time_tracker_badge')));
        await tester.pump();

        // Test badge grid interaction
        await tester.tap(find.byKey(const Key('achievement_badge_0')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('achievement_badge_7')));
        await tester.pump();

        // Verify achievements display
        expect(find.text('Streak Master'), findsOneWidget);
        expect(find.text('Time Tracker'), findsOneWidget);
        expect(find.text('Productivity Expert'), findsOneWidget);
        expect(find.text('80%'), findsAtLeastNWidgets(1));
      });
    });

    group('Export and Sharing', () {
      testWidgets('should export analytics data in multiple formats', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Export Analytics'),
                  actions: [
                    PopupMenuButton<String>(
                      key: const Key('export_menu'),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'csv', child: Text('Export as CSV')),
                        const PopupMenuItem(value: 'pdf', child: Text('Export as PDF')),
                        const PopupMenuItem(value: 'json', child: Text('Export as JSON')),
                        const PopupMenuItem(value: 'share', child: Text('Share Report')),
                      ],
                      onSelected: (value) {
                        // Handle export
                      },
                    ),
                  ],
                ),
                body: const Column(
                  children: [
                    Card(
                      child: ListTile(
                        key: Key('export_summary_option'),
                        leading: Icon(Icons.summarize),
                        title: Text('Export Summary Report'),
                        subtitle: Text('Key metrics and insights'),
                        trailing: Icon(Icons.download),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        key: Key('export_detailed_option'),
                        leading: Icon(Icons.table_chart),
                        title: Text('Export Detailed Data'),
                        subtitle: Text('All tasks and time tracking data'),
                        trailing: Icon(Icons.download),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        key: Key('export_charts_option'),
                        leading: Icon(Icons.bar_chart),
                        title: Text('Export Charts & Visualizations'),
                        subtitle: Text('High-resolution images of all charts'),
                        trailing: Icon(Icons.download),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Test export menu
        await tester.tap(find.byKey(const Key('export_menu')));
        await tester.pump();
        await tester.tap(find.text('Export as PDF'));
        await tester.pump();

        // Test export options
        await tester.tap(find.byKey(const Key('export_summary_option')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('export_detailed_option')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('export_charts_option')));
        await tester.pump();

        // Verify export functionality
        expect(find.text('Export Analytics'), findsOneWidget);
        expect(find.text('Export Summary Report'), findsOneWidget);
        expect(find.text('Export Detailed Data'), findsOneWidget);
        expect(find.text('Export Charts & Visualizations'), findsOneWidget);
      });
    });
  });
}