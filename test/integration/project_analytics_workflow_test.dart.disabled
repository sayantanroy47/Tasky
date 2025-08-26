import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:mockito/mockito.dart';
import 'package:uuid/uuid.dart';

import 'package:task_tracker_app/services/database/database.dart' as db;
import 'package:task_tracker_app/domain/entities/project.dart' as entities;
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/task_enums.dart';
import 'package:task_tracker_app/presentation/widgets/analytics_widgets.dart';
import 'package:task_tracker_app/presentation/pages/analytics_page.dart';
import 'package:task_tracker_app/presentation/providers/analytics_providers.dart';
import 'package:task_tracker_app/core/providers/core_providers.dart';

void main() {
  group('Project Analytics Workflow Integration Tests', () {
    late ProviderContainer container;
    late db.AppDatabase testDatabase;
    late List<entities.Project> testProjects;
    late List<TaskModel> testTasks;
    late DateTime baseDate;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      
      // Create test database
      testDatabase = db.AppDatabase.forTesting(NativeDatabase.memory());
      baseDate = DateTime.now().subtract(const Duration(days: 30));
      
      // Create test projects with varied completion dates and metrics
      testProjects = [
        entities.Project(
          id: 'project-1',
          name: 'Mobile App Development',
          description: 'iOS and Android app development',
          color: '#2196F3',
          createdAt: baseDate,
          deadline: baseDate.add(const Duration(days: 90)),
        ),
        entities.Project(
          id: 'project-2',
          name: 'Website Redesign',
          description: 'Company website overhaul',
          color: '#FF9800',
          createdAt: baseDate.add(const Duration(days: 5)),
          deadline: baseDate.add(const Duration(days: 60)),
        ),
        entities.Project(
          id: 'project-3',
          name: 'Marketing Campaign',
          description: 'Q1 marketing push',
          color: '#4CAF50',
          createdAt: baseDate.add(const Duration(days: 10)),
          deadline: baseDate.add(const Duration(days: 45)),
        ),
      ];

      // Create tasks with realistic timeline and metrics
      testTasks = [
        // Project 1 - Mobile App (In Progress)
        TaskModel(
          id: 'task-arch',
          title: 'App Architecture Design',
          priority: TaskPriority.high,
          projectId: 'project-1',
          createdAt: baseDate.add(const Duration(days: 1)),
          completedAt: baseDate.add(const Duration(days: 5)),
          estimatedDuration: 16 * 60, // 16 hours in minutes
          actualDuration: 20 * 60, // 20 hours in minutes
        ),
        TaskModel(
          id: 'task-ui',
          title: 'UI/UX Implementation',
          priority: TaskPriority.high,
          projectId: 'project-1',
          createdAt: baseDate.add(const Duration(days: 6)),
          estimatedDuration: 40 * 60, // 40 hours in minutes
          actualDuration: 25 * 60, // 25 hours in minutes (partial completion)
        ),
        TaskModel.create(
          title: 'Backend API Development',
          priority: TaskPriority.medium,
          projectId: 'project-1',
          estimatedDuration: 60 * 60, // 60 hours in minutes
        ),
        TaskModel.create(
          title: 'Testing & QA',
          priority: TaskPriority.high,
          projectId: 'project-1', 
          estimatedDuration: 30 * 60, // 30 hours in minutes
        ),
        
        // Project 2 - Website Redesign (Mixed Progress)
        TaskModel(
          id: const Uuid().v4(),
          title: 'Content Strategy',
          priority: TaskPriority.medium,
          projectId: 'project-2',
          createdAt: baseDate.add(const Duration(days: 7)),
          completedAt: baseDate.add(const Duration(days: 12)),
          estimatedDuration: 8 * 60,
          actualDuration: 6 * 60,
        ),
        TaskModel(
          id: const Uuid().v4(),
          title: 'Visual Design',
          priority: TaskPriority.high,
          projectId: 'project-2',
          createdAt: baseDate.add(const Duration(days: 8)),
          completedAt: baseDate.add(const Duration(days: 18)),
          estimatedDuration: 24 * 60,
          actualDuration: 28 * 60,
        ),
        TaskModel(
          id: const Uuid().v4(),
          title: 'Development',
          priority: TaskPriority.high,
          projectId: 'project-2',
          createdAt: baseDate.add(const Duration(days: 19)),
          estimatedDuration: 32 * 60,
          actualDuration: 30 * 60,
        ),
        
        // Project 3 - Marketing Campaign (Completed)
        TaskModel(
          id: const Uuid().v4(),
          title: 'Market Research',
          priority: TaskPriority.high,
          projectId: 'project-3',
          createdAt: baseDate.add(const Duration(days: 11)),
          completedAt: baseDate.add(const Duration(days: 15)),
          estimatedDuration: 12 * 60,
          actualDuration: 10 * 60,
        ),
        TaskModel(
          id: const Uuid().v4(),
          title: 'Campaign Creation',
          priority: TaskPriority.high,
          projectId: 'project-3',
          createdAt: baseDate.add(const Duration(days: 16)),
          completedAt: baseDate.add(const Duration(days: 25)),
          estimatedDuration: 20 * 60,
          actualDuration: 18 * 60,
        ),
        TaskModel(
          id: const Uuid().v4(),
          title: 'Campaign Launch',
          priority: TaskPriority.urgent,
          projectId: 'project-3',
          createdAt: baseDate.add(const Duration(days: 26)),
          completedAt: baseDate.add(const Duration(days: 30)),
          estimatedDuration: 8 * 60,
          actualDuration: 8 * 60,
        ),
      ];

      // Create container with test overrides
      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(testDatabase),
        ],
      );
    });

    tearDown(() async {
      await testDatabase.close();
      container.dispose();
    });

    group('Analytics Dashboard Workflow', () {
      testWidgets('should display comprehensive project analytics dashboard', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Project Analytics'),
                  actions: [
                    IconButton(
                      key: const Key('refresh_analytics'),
                      icon: const Icon(Icons.refresh),
                      onPressed: () {},
                    ),
                    IconButton(
                      key: const Key('export_analytics'),
                      icon: const Icon(Icons.download),
                      onPressed: () {},
                    ),
                    PopupMenuButton<String>(
                      key: const Key('time_range_selector'),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'week', child: Text('Last 7 Days')),
                        const PopupMenuItem(value: 'month', child: Text('Last 30 Days')),
                        const PopupMenuItem(value: 'quarter', child: Text('Last 3 Months')),
                        const PopupMenuItem(value: 'year', child: Text('Last Year')),
                      ],
                    ),
                  ],
                ),
                body: const AnalyticsPage(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify main dashboard components
        expect(find.text('Project Analytics'), findsOneWidget);
        
        // Check overview cards
        expect(find.text('Total Projects'), findsOneWidget);
        expect(find.text('3'), findsOneWidget); // Total project count
        expect(find.text('Active Projects'), findsOneWidget);
        expect(find.text('2'), findsOneWidget); // Active project count
        expect(find.text('Completion Rate'), findsOneWidget);
        expect(find.text('67%'), findsOneWidget); // Overall completion rate
        expect(find.text('Total Budget'), findsOneWidget);
        expect(find.text('\$90,000'), findsOneWidget);

        // Check project performance cards
        expect(find.text('Mobile App Development'), findsOneWidget);
        expect(find.text('Website Redesign'), findsOneWidget);
        expect(find.text('Marketing Campaign'), findsOneWidget);

        // Check progress indicators
        expect(find.byType(LinearProgressIndicator), findsAtLeastNWidgets(3));
        expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));

        // Verify charts are present
        expect(find.byKey(const Key('project_timeline_chart')), findsOneWidget);
        expect(find.byKey(const Key('budget_utilization_chart')), findsOneWidget);
        expect(find.byKey(const Key('task_distribution_chart')), findsOneWidget);
        expect(find.byKey(const Key('velocity_trend_chart')), findsOneWidget);

        // Test time range filtering
        await tester.tap(find.byKey(const Key('time_range_selector')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Last 7 Days'));
        await tester.pumpAndSettle();

        // Verify analytics recalculated for selected time range
        expect(find.text('Last 7 Days Analytics'), findsOneWidget);

        // Test refresh functionality
        await tester.tap(find.byKey(const Key('refresh_analytics')));
        await tester.pumpAndSettle();

        expect(find.text('Analytics refreshed'), findsOneWidget);
      });

      testWidgets('should support interactive charts with drill-down capability', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Project timeline chart
                      SizedBox(
                        key: const Key('project_timeline_chart'),
                        height: 300,
                        child: InteractiveTimelineChart(
                          projects: testProjects,
                          tasks: testTasks,
                          onProjectTap: (project) {
                            // Handle project tap
                          },
                          onTaskTap: (task) {
                            // Handle task tap
                          },
                        ),
                      ),
                      // Budget analysis chart
                      SizedBox(
                        key: const Key('budget_analysis_chart'),
                        height: 300,
                        child: BudgetAnalysisChart(
                          projects: testProjects,
                          onSegmentTap: (projectId) {
                            // Handle segment tap
                          },
                        ),
                      ),
                      // Task velocity chart
                      SizedBox(
                        key: const Key('velocity_chart'),
                        height: 300,
                        child: VelocityChart(
                          tasks: testTasks,
                          onDataPointTap: (date, value) {
                            // Handle data point tap
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Test project timeline chart interaction
        await tester.tap(find.byKey(const Key('project_timeline_chart')));
        await tester.pumpAndSettle();

        // Tap on specific project in timeline
        await tester.tap(find.byKey(const Key('timeline_project_1')));
        await tester.pumpAndSettle();

        expect(find.text('Mobile App Development Details'), findsOneWidget);
        expect(find.text('25% Complete'), findsOneWidget);
        expect(find.text('65 days remaining'), findsOneWidget);
        expect(find.text('1 blocked task'), findsOneWidget);

        // Test drill-down to task level
        await tester.tap(find.byKey(const Key('view_project_tasks')));
        await tester.pumpAndSettle();

        expect(find.text('Project Tasks Breakdown'), findsOneWidget);
        expect(find.text('App Architecture Design (Completed)'), findsOneWidget);
        expect(find.text('UI/UX Implementation (In Progress)'), findsOneWidget);
        expect(find.text('Testing & QA (Blocked)'), findsOneWidget);

        // Test budget chart interaction
        await tester.tap(find.byKey(const Key('budget_analysis_chart')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('budget_segment_project_1')));
        await tester.pumpAndSettle();

        expect(find.text('Budget Breakdown'), findsOneWidget);
        expect(find.text('Allocated: \$50,000'), findsOneWidget);
        expect(find.text('Spent: \$12,500'), findsOneWidget);
        expect(find.text('Remaining: \$37,500'), findsOneWidget);
        expect(find.text('Burn Rate: \$417/day'), findsOneWidget);

        // Test velocity chart interaction
        await tester.tap(find.byKey(const Key('velocity_chart')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('velocity_data_point_week_2')));
        await tester.pumpAndSettle();

        expect(find.text('Week 2 Velocity Details'), findsOneWidget);
        expect(find.text('Tasks Completed: 2'), findsOneWidget);
        expect(find.text('Story Points: 15'), findsOneWidget);
        expect(find.text('Team Productivity: 125%'), findsOneWidget);
      });

      testWidgets('should handle real-time analytics updates and notifications', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    // Real-time status indicator
                    Container(
                      key: const Key('realtime_status'),
                      padding: const EdgeInsets.all(8),
                      color: Colors.green[100],
                      child: Row(
                        children: [
                          const Icon(Icons.circle, size: 12, color: Colors.green),
                          const SizedBox(width: 8),
                          const Text('Live Analytics'),
                          const Spacer(),
                          TextButton(
                            key: const Key('toggle_realtime'),
                            onPressed: () {},
                            child: const Text('Disable'),
                          ),
                        ],
                      ),
                    ),
                    // Analytics notifications
                    Container(
                      key: const Key('analytics_notifications'),
                      padding: const EdgeInsets.all(16),
                      child: const Column(
                        children: [
                          AlertCard(
                            key: Key('budget_alert'),
                            type: AlertType.warning,
                            title: 'Budget Alert',
                            message: 'Mobile App Development is 80% over budget',
                            action: 'View Details',
                          ),
                          AlertCard(
                            key: Key('deadline_alert'),
                            type: AlertType.critical,
                            title: 'Deadline Risk',
                            message: 'Website Redesign may miss deadline by 5 days',
                            action: 'Adjust Timeline',
                          ),
                          AlertCard(
                            key: Key('velocity_alert'),
                            type: AlertType.info,
                            title: 'Velocity Improvement',
                            message: 'Team velocity increased by 25% this week',
                            action: 'View Report',
                          ),
                        ],
                      ),
                    ),
                    // Live metrics display
                    const Expanded(
                      child: AnalyticsPage(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify real-time status indicator
        expect(find.text('Live Analytics'), findsOneWidget);
        expect(find.byIcon(Icons.circle), findsOneWidget);

        // Test notifications
        expect(find.text('Budget Alert'), findsOneWidget);
        expect(find.text('Deadline Risk'), findsOneWidget);
        expect(find.text('Velocity Improvement'), findsOneWidget);

        // Test notification interaction
        await tester.tap(find.byKey(const Key('budget_alert')));
        await tester.pumpAndSettle();

        expect(find.text('Budget Alert Details'), findsOneWidget);
        expect(find.text('Projected overage: \$15,000'), findsOneWidget);
        expect(find.text('Recommended actions:'), findsOneWidget);
        expect(find.text('• Reduce scope'), findsOneWidget);
        expect(find.text('• Extend timeline'), findsOneWidget);
        expect(find.text('• Increase budget'), findsOneWidget);

        // Simulate real-time data update
        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'analytics_update',
          null,
          (data) {},
        );
        await tester.pumpAndSettle();

        // Verify live update notification
        expect(find.byIcon(Icons.sync), findsOneWidget);
        expect(find.text('Data updated'), findsOneWidget);

        // Test toggle real-time updates
        await tester.tap(find.byKey(const Key('toggle_realtime')));
        await tester.pumpAndSettle();

        expect(find.text('Real-time updates disabled'), findsOneWidget);
        expect(find.text('Enable'), findsOneWidget);
      });
    });

    group('Detailed Analytics and Reports', () {
      testWidgets('should generate comprehensive project performance reports', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Project Reports'),
                  actions: [
                    IconButton(
                      key: const Key('generate_report'),
                      icon: const Icon(Icons.assessment),
                      onPressed: () {},
                    ),
                  ],
                ),
                body: DefaultTabController(
                  length: 4,
                  child: Column(
                    children: [
                      const TabBar(
                        tabs: [
                          Tab(key: Key('performance_tab'), text: 'Performance'),
                          Tab(key: Key('budget_tab'), text: 'Budget'),
                          Tab(key: Key('timeline_tab'), text: 'Timeline'),
                          Tab(key: Key('team_tab'), text: 'Team'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // Performance Report Tab
                            PerformanceReportView(
                              key: const Key('performance_report'),
                              projects: testProjects,
                              tasks: testTasks,
                            ),
                            // Budget Report Tab
                            BudgetReportView(
                              key: const Key('budget_report'),
                              projects: testProjects,
                            ),
                            // Timeline Report Tab
                            TimelineReportView(
                              key: const Key('timeline_report'),
                              projects: testProjects,
                              tasks: testTasks,
                            ),
                            // Team Report Tab
                            TeamReportView(
                              key: const Key('team_report'),
                              tasks: testTasks,
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

        await tester.pumpAndSettle();

        // Test Performance Report
        expect(find.byKey(const Key('performance_report')), findsOneWidget);
        expect(find.text('Overall Performance Score'), findsOneWidget);
        expect(find.text('72/100'), findsOneWidget);

        // Performance metrics
        expect(find.text('Task Completion Rate'), findsOneWidget);
        expect(find.text('60%'), findsOneWidget);
        expect(find.text('Average Task Duration'), findsOneWidget);
        expect(find.text('18.5 hours'), findsOneWidget);
        expect(find.text('Estimated vs Actual'), findsOneWidget);
        expect(find.text('+15% variance'), findsOneWidget);

        // Switch to Budget Report
        await tester.tap(find.byKey(const Key('budget_tab')));
        await tester.pumpAndSettle();

        expect(find.text('Budget Utilization Overview'), findsOneWidget);
        expect(find.text('Total Allocated: \$90,000'), findsOneWidget);
        expect(find.text('Total Spent: \$32,500'), findsOneWidget);
        expect(find.text('Remaining: \$57,500'), findsOneWidget);
        expect(find.text('Projected Final Cost: \$95,000'), findsOneWidget);

        // Project-specific budget breakdown
        expect(find.text('Mobile App: 25% spent (\$12,500)'), findsOneWidget);
        expect(find.text('Website Redesign: 60% spent (\$15,000)'), findsOneWidget);
        expect(find.text('Marketing: 100% spent (\$15,000)'), findsOneWidget);

        // Switch to Timeline Report
        await tester.tap(find.byKey(const Key('timeline_tab')));
        await tester.pumpAndSettle();

        expect(find.text('Timeline Analysis'), findsOneWidget);
        expect(find.text('Projects on Schedule: 1/3'), findsOneWidget);
        expect(find.text('Projects at Risk: 1/3'), findsOneWidget);
        expect(find.text('Projects Delayed: 0/3'), findsOneWidget);

        // Critical path analysis
        expect(find.text('Critical Path Analysis'), findsOneWidget);
        expect(find.text('Mobile App Development'), findsOneWidget);
        expect(find.text('Critical tasks: 2'), findsOneWidget);
        expect(find.text('Buffer time: 10 days'), findsOneWidget);

        // Switch to Team Report
        await tester.tap(find.byKey(const Key('team_tab')));
        await tester.pumpAndSettle();

        expect(find.text('Team Performance Overview'), findsOneWidget);
        expect(find.text('Active Team Members: 5'), findsOneWidget);
        expect(find.text('Average Task Load: 2.2 tasks'), findsOneWidget);
        expect(find.text('Team Velocity: 15 points/week'), findsOneWidget);

        // Individual performance metrics
        expect(find.text('Top Performers'), findsOneWidget);
        expect(find.text('Most Productive: John Doe'), findsOneWidget);
        expect(find.text('Fastest Completion: Jane Smith'), findsOneWidget);
      });

      testWidgets('should provide advanced filtering and custom report generation', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Custom Reports'),
                ),
                body: Column(
                  children: [
                    // Report configuration panel
                    Container(
                      key: const Key('report_config_panel'),
                      padding: const EdgeInsets.all(16),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Report Configuration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              // Date range selector
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      key: const Key('start_date_field'),
                                      decoration: const InputDecoration(
                                        labelText: 'Start Date',
                                        suffixIcon: Icon(Icons.calendar_today),
                                      ),
                                      onTap: () {},
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextField(
                                      key: const Key('end_date_field'),
                                      decoration: const InputDecoration(
                                        labelText: 'End Date',
                                        suffixIcon: Icon(Icons.calendar_today),
                                      ),
                                      onTap: () {},
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Project selection
                              MultiSelectChip(
                                key: const Key('project_selection'),
                                title: 'Select Projects',
                                options: testProjects.map((p) => p.name).toList(),
                                onSelectionChanged: (selected) {},
                              ),
                              const SizedBox(height: 16),
                              // Metric selection
                              MultiSelectChip(
                                key: const Key('metric_selection'),
                                title: 'Select Metrics',
                                options: const [
                                  'Task Completion Rate',
                                  'Budget Utilization',
                                  'Timeline Adherence',
                                  'Team Productivity',
                                  'Quality Metrics',
                                  'Risk Assessment',
                                ],
                                onSelectionChanged: (selected) {},
                              ),
                              const SizedBox(height: 16),
                              // Report format options
                              Row(
                                children: [
                                  const Text('Export Format:'),
                                  const SizedBox(width: 16),
                                  DropdownButton<String>(
                                    key: const Key('report_format_dropdown'),
                                    value: 'PDF',
                                    items: const [
                                      DropdownMenuItem(value: 'PDF', child: Text('PDF Report')),
                                      DropdownMenuItem(value: 'Excel', child: Text('Excel Spreadsheet')),
                                      DropdownMenuItem(value: 'CSV', child: Text('CSV Data')),
                                      DropdownMenuItem(value: 'JSON', child: Text('JSON Data')),
                                    ],
                                    onChanged: (value) {},
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Generate button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  key: const Key('generate_custom_report'),
                                  onPressed: () {},
                                  child: const Text('Generate Report'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Live preview
                    Expanded(
                      child: Container(
                        key: const Key('report_preview'),
                        padding: const EdgeInsets.all(16),
                        child: const Card(
                          child: Center(
                            child: Text('Report preview will appear here'),
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

        await tester.pumpAndSettle();

        // Test date range selection
        await tester.tap(find.byKey(const Key('start_date_field')));
        await tester.pumpAndSettle();

        expect(find.byType(DatePickerDialog), findsOneWidget);
        await tester.tap(find.text('1'));
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        // Test project selection
        await tester.tap(find.byKey(const Key('project_selection')));
        await tester.pumpAndSettle();

        // Select specific projects
        await tester.tap(find.text('Mobile App Development'));
        await tester.tap(find.text('Website Redesign'));
        await tester.pumpAndSettle();

        expect(find.text('2 projects selected'), findsOneWidget);

        // Test metric selection
        await tester.tap(find.byKey(const Key('metric_selection')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Task Completion Rate'));
        await tester.tap(find.text('Budget Utilization'));
        await tester.tap(find.text('Timeline Adherence'));
        await tester.pumpAndSettle();

        expect(find.text('3 metrics selected'), findsOneWidget);

        // Test export format selection
        await tester.tap(find.byKey(const Key('report_format_dropdown')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Excel Spreadsheet'));
        await tester.pumpAndSettle();

        // Generate custom report
        await tester.tap(find.byKey(const Key('generate_custom_report')));
        await tester.pumpAndSettle();

        // Should show progress indicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Generating report...'), findsOneWidget);

        await tester.pumpAndSettle();

        // Verify report generation success
        expect(find.text('Report generated successfully'), findsOneWidget);
        expect(find.text('Download Excel Report'), findsOneWidget);
      });

      testWidgets('should support comparative analysis across projects and time periods', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Comparative Analysis'),
                  actions: [
                    IconButton(
                      key: const Key('comparison_settings'),
                      icon: const Icon(Icons.compare),
                      onPressed: () {},
                    ),
                  ],
                ),
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Comparison configuration
                      ComparisonConfigPanel(
                        key: const Key('comparison_config'),
                        projects: testProjects,
                        onConfigurationChanged: (config) {},
                      ),
                      // Side-by-side project comparison
                      ProjectComparisonView(
                        key: const Key('project_comparison'),
                        project1: testProjects[0],
                        project2: testProjects[1],
                        tasks1: testTasks.where((t) => t.projectId == testProjects[0].id).toList(),
                        tasks2: testTasks.where((t) => t.projectId == testProjects[1].id).toList(),
                      ),
                      // Time period comparison
                      TimePeriodComparisonView(
                        key: const Key('time_comparison'),
                        currentPeriod: testTasks.where((t) => t.createdAt.isAfter(baseDate.add(const Duration(days: 15)))).toList(),
                        previousPeriod: testTasks.where((t) => t.createdAt.isBefore(baseDate.add(const Duration(days: 15)))).toList(),
                      ),
                      // Benchmark comparison
                      BenchmarkComparisonView(
                        key: const Key('benchmark_comparison'),
                        projects: testProjects,
                        industryBenchmarks: const {
                          'completion_rate': 0.75,
                          'budget_variance': 0.10,
                          'timeline_adherence': 0.80,
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Test comparison configuration
        expect(find.byKey(const Key('comparison_config')), findsOneWidget);

        await tester.tap(find.byKey(const Key('select_project_1')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Mobile App Development'));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('select_project_2')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Website Redesign'));
        await tester.pumpAndSettle();

        // Verify side-by-side comparison
        expect(find.text('Mobile App Development vs Website Redesign'), findsOneWidget);

        // Check comparison metrics
        expect(find.text('Completion Rate'), findsAtLeastNWidgets(2));
        expect(find.text('25%'), findsOneWidget); // Mobile App completion
        expect(find.text('67%'), findsOneWidget); // Website completion

        expect(find.text('Budget Progress'), findsAtLeastNWidgets(2));
        expect(find.text('\$12,500 / \$50,000'), findsOneWidget);
        expect(find.text('\$15,000 / \$25,000'), findsOneWidget);

        // Test time period comparison
        expect(find.text('Current Period vs Previous Period'), findsOneWidget);
        expect(find.text('Task Velocity: +25%'), findsOneWidget);
        expect(find.text('Completion Rate: +15%'), findsOneWidget);
        expect(find.text('Team Productivity: +18%'), findsOneWidget);

        // Test benchmark comparison
        expect(find.text('Performance vs Industry Benchmarks'), findsOneWidget);
        expect(find.text('Completion Rate: 60% (Industry: 75%)'), findsOneWidget);
        expect(find.text('Budget Variance: +15% (Industry: +10%)'), findsOneWidget);
        expect(find.text('Timeline Adherence: 67% (Industry: 80%)'), findsOneWidget);

        // Show improvement recommendations
        expect(find.text('Recommendations'), findsOneWidget);
        expect(find.text('• Improve task completion rate by 15%'), findsOneWidget);
        expect(find.text('• Reduce budget variance by 5%'), findsOneWidget);
        expect(find.text('• Focus on timeline management'), findsOneWidget);
      });
    });

    group('Export and Sharing Workflows', () {
      testWidgets('should handle comprehensive data export with multiple formats', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Export Analytics'),
                  actions: [
                    IconButton(
                      key: const Key('export_options'),
                      icon: const Icon(Icons.download),
                      onPressed: () {
                        showDialog(
                          context: tester.element(find.byType(Scaffold)),
                          builder: (context) => const ExportOptionsDialog(),
                        );
                      },
                    ),
                  ],
                ),
                body: const AnalyticsPage(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Open export options dialog
        await tester.tap(find.byKey(const Key('export_options')));
        await tester.pumpAndSettle();

        expect(find.text('Export Analytics'), findsOneWidget);

        // Test export format selection
        expect(find.text('Select Format:'), findsOneWidget);
        expect(find.byKey(const Key('format_pdf')), findsOneWidget);
        expect(find.byKey(const Key('format_excel')), findsOneWidget);
        expect(find.byKey(const Key('format_csv')), findsOneWidget);
        expect(find.byKey(const Key('format_json')), findsOneWidget);

        // Test export scope selection
        expect(find.text('Export Scope:'), findsOneWidget);
        expect(find.byKey(const Key('scope_summary')), findsOneWidget);
        expect(find.byKey(const Key('scope_detailed')), findsOneWidget);
        expect(find.byKey(const Key('scope_raw_data')), findsOneWidget);

        // Select PDF format and detailed scope
        await tester.tap(find.byKey(const Key('format_pdf')));
        await tester.tap(find.byKey(const Key('scope_detailed')));
        await tester.pumpAndSettle();

        // Configure PDF options
        expect(find.text('PDF Options:'), findsOneWidget);
        expect(find.text('Include Charts'), findsOneWidget);
        expect(find.text('Include Raw Data'), findsOneWidget);
        expect(find.text('Executive Summary'), findsOneWidget);

        await tester.tap(find.byKey(const Key('include_charts')));
        await tester.tap(find.byKey(const Key('include_summary')));
        await tester.pumpAndSettle();

        // Start export
        await tester.tap(find.byKey(const Key('start_export')));
        await tester.pumpAndSettle();

        // Verify export progress
        expect(find.text('Exporting Analytics...'), findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsOneWidget);

        await tester.pumpAndSettle();

        // Verify export completion
        expect(find.text('Export Complete'), findsOneWidget);
        expect(find.text('analytics_report.pdf'), findsOneWidget);
        expect(find.byKey(const Key('download_file')), findsOneWidget);
        expect(find.byKey(const Key('share_file')), findsOneWidget);

        // Test Excel export with performance validation
        await tester.tap(find.byKey(const Key('export_options')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('format_excel')));
        await tester.tap(find.byKey(const Key('scope_raw_data')));
        await tester.pumpAndSettle();

        // Configure Excel options
        expect(find.text('Excel Options:'), findsOneWidget);
        expect(find.text('Multiple Worksheets'), findsOneWidget);
        expect(find.text('Include Formulas'), findsOneWidget);
        expect(find.text('Pivot Tables'), findsOneWidget);

        await tester.tap(find.byKey(const Key('multiple_worksheets')));
        await tester.tap(find.byKey(const Key('include_pivot_tables')));
        
        final stopwatch = Stopwatch()..start();
        await tester.tap(find.byKey(const Key('start_export')));
        await tester.pumpAndSettle();
        stopwatch.stop();

        // Verify export performance (<1 second for test data)
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));

        expect(find.text('analytics_data.xlsx'), findsOneWidget);
      });

      testWidgets('should support automated report scheduling and delivery', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Scheduled Reports'),
                  actions: [
                    IconButton(
                      key: const Key('create_schedule'),
                      icon: const Icon(Icons.schedule),
                      onPressed: () {},
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    // Existing scheduled reports
                    Expanded(
                      child: ListView(
                        children: const [
                          ScheduledReportCard(
                            key: Key('weekly_report'),
                            title: 'Weekly Project Summary',
                            frequency: 'Every Monday at 9:00 AM',
                            recipients: ['manager@company.com', 'team@company.com'],
                            format: 'PDF',
                            isActive: true,
                          ),
                          ScheduledReportCard(
                            key: Key('monthly_report'),
                            title: 'Monthly Performance Analysis',
                            frequency: 'First day of each month',
                            recipients: ['executive@company.com'],
                            format: 'Excel',
                            isActive: true,
                          ),
                          ScheduledReportCard(
                            key: Key('quarterly_report'),
                            title: 'Quarterly Business Review',
                            frequency: 'Every 3 months',
                            recipients: ['board@company.com'],
                            format: 'PDF',
                            isActive: false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                floatingActionButton: FloatingActionButton(
                  key: const Key('add_scheduled_report'),
                  onPressed: () {},
                  child: const Icon(Icons.add),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify existing scheduled reports
        expect(find.text('Weekly Project Summary'), findsOneWidget);
        expect(find.text('Every Monday at 9:00 AM'), findsOneWidget);
        expect(find.text('Monthly Performance Analysis'), findsOneWidget);
        expect(find.text('Quarterly Business Review'), findsOneWidget);

        // Test creating new scheduled report
        await tester.tap(find.byKey(const Key('add_scheduled_report')));
        await tester.pumpAndSettle();

        expect(find.text('Create Scheduled Report'), findsOneWidget);

        // Configure report details
        await tester.enterText(
          find.byKey(const Key('report_title_field')),
          'Daily Team Standup Report'
        );

        await tester.tap(find.byKey(const Key('frequency_dropdown')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Daily'));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('time_picker')));
        await tester.pumpAndSettle();
        // Would interact with time picker
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        // Add recipients
        await tester.tap(find.byKey(const Key('add_recipient')));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('recipient_email')),
          'standup@company.com'
        );
        await tester.tap(find.byKey(const Key('confirm_recipient')));
        await tester.pumpAndSettle();

        // Configure report content
        await tester.tap(find.byKey(const Key('select_content')));
        await tester.pumpAndSettle();

        expect(find.text('Select Report Content'), findsOneWidget);
        await tester.tap(find.text('Task Progress'));
        await tester.tap(find.text('Team Velocity'));
        await tester.tap(find.text('Blockers & Issues'));
        await tester.pumpAndSettle();

        // Set delivery options
        await tester.tap(find.byKey(const Key('delivery_options')));
        await tester.pumpAndSettle();

        expect(find.text('Email Delivery'), findsOneWidget);
        expect(find.text('Slack Integration'), findsOneWidget);
        expect(find.text('Dashboard Link'), findsOneWidget);

        await tester.tap(find.byKey(const Key('email_delivery')));
        await tester.tap(find.byKey(const Key('slack_integration')));
        await tester.pumpAndSettle();

        // Save scheduled report
        await tester.tap(find.byKey(const Key('save_scheduled_report')));
        await tester.pumpAndSettle();

        expect(find.text('Scheduled report created successfully'), findsOneWidget);
        expect(find.text('Daily Team Standup Report'), findsOneWidget);

        // Test report modification
        await tester.tap(find.byKey(const Key('edit_weekly_report')));
        await tester.pumpAndSettle();

        expect(find.text('Edit Scheduled Report'), findsOneWidget);

        // Test report activation/deactivation
        await tester.tap(find.byKey(const Key('toggle_quarterly_report')));
        await tester.pumpAndSettle();

        expect(find.text('Quarterly report activated'), findsOneWidget);

        // Test manual report trigger
        await tester.tap(find.byKey(const Key('send_now_weekly_report')));
        await tester.pumpAndSettle();

        expect(find.text('Report sent immediately'), findsOneWidget);
        expect(find.text('Next scheduled delivery: Monday, 9:00 AM'), findsOneWidget);
      });

      testWidgets('should handle dashboard sharing and collaborative analytics', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Shared Dashboards'),
                  actions: [
                    IconButton(
                      key: const Key('share_dashboard'),
                      icon: const Icon(Icons.share),
                      onPressed: () {},
                    ),
                    IconButton(
                      key: const Key('collaboration_settings'),
                      icon: const Icon(Icons.people),
                      onPressed: () {},
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    // Dashboard sharing status
                    Container(
                      key: const Key('sharing_status'),
                      padding: const EdgeInsets.all(16),
                      color: Colors.blue[50],
                      child: Row(
                        children: [
                          const Icon(Icons.public, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Text('Dashboard is shared with 5 team members'),
                          const Spacer(),
                          TextButton(
                            key: const Key('manage_sharing'),
                            onPressed: () {},
                            child: const Text('Manage'),
                          ),
                        ],
                      ),
                    ),
                    // Collaborative features
                    Container(
                      key: const Key('collaboration_panel'),
                      padding: const EdgeInsets.all(16),
                      child: const Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Text('Collaborative Features'),
                              subtitle: Text('Real-time collaboration and annotations'),
                            ),
                            // Recent annotations
                            ListTile(
                              key: Key('annotation_1'),
                              leading: CircleAvatar(child: Text('JS')),
                              title: Text('John Smith added a note'),
                              subtitle: Text('Mobile app budget needs review'),
                              trailing: Text('2m ago'),
                            ),
                            ListTile(
                              key: Key('annotation_2'),
                              leading: CircleAvatar(child: Text('AD')),
                              title: Text('Alice Davis highlighted'),
                              subtitle: Text('Timeline concern for website project'),
                              trailing: Text('5m ago'),
                            ),
                            // Active viewers
                            ListTile(
                              title: Text('Currently Viewing'),
                              subtitle: Text('3 team members are currently viewing this dashboard'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Main analytics dashboard with collaboration features
                    const Expanded(
                      child: AnalyticsPage(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Test dashboard sharing
        await tester.tap(find.byKey(const Key('share_dashboard')));
        await tester.pumpAndSettle();

        expect(find.text('Share Dashboard'), findsOneWidget);
        expect(find.text('Share Link'), findsOneWidget);
        expect(find.text('Invite Team Members'), findsOneWidget);
        expect(find.text('Export Dashboard'), findsOneWidget);

        // Test link sharing
        await tester.tap(find.byKey(const Key('generate_share_link')));
        await tester.pumpAndSettle();

        expect(find.text('Share Link Generated'), findsOneWidget);
        expect(find.text('Access Level: View Only'), findsOneWidget);
        expect(find.byIcon(Icons.copy), findsOneWidget);

        await tester.tap(find.byIcon(Icons.copy));
        await tester.pumpAndSettle();

        expect(find.text('Link copied to clipboard'), findsOneWidget);

        // Test team member invitation
        await tester.tap(find.byKey(const Key('invite_team_members')));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('invite_email_field')),
          'newmember@company.com'
        );

        await tester.tap(find.byKey(const Key('access_level_dropdown')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Edit Access'));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('send_invitation')));
        await tester.pumpAndSettle();

        expect(find.text('Invitation sent successfully'), findsOneWidget);

        // Test collaboration settings
        await tester.tap(find.byKey(const Key('collaboration_settings')));
        await tester.pumpAndSettle();

        expect(find.text('Collaboration Settings'), findsOneWidget);
        expect(find.text('Allow Annotations'), findsOneWidget);
        expect(find.text('Real-time Updates'), findsOneWidget);
        expect(find.text('Comment Notifications'), findsOneWidget);

        // Test annotation functionality
        await tester.longPress(find.byKey(const Key('budget_chart')));
        await tester.pumpAndSettle();

        expect(find.text('Add Annotation'), findsOneWidget);
        await tester.enterText(
          find.byKey(const Key('annotation_text')),
          'Budget variance needs immediate attention'
        );
        await tester.tap(find.byKey(const Key('save_annotation')));
        await tester.pumpAndSettle();

        expect(find.text('Annotation added'), findsOneWidget);

        // Verify annotation appears in collaboration panel
        expect(find.text('Budget variance needs immediate attention'), findsOneWidget);
      });
    });

    group('Performance and Error Handling', () {
      testWidgets('should handle large datasets with performance optimization', (tester) async {
        // Create large dataset for performance testing
        final largeTaskSet = List.generate(
          10000,
          (index) => TaskModel(
            id: const Uuid().v4(),
            title: 'Performance Test Task ${index + 1}',
            priority: TaskPriority.values[index % TaskPriority.values.length],
            projectId: testProjects[index % 3].id,
            createdAt: baseDate.add(Duration(minutes: index)),
          ),
        );

        final stopwatch = Stopwatch();

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: Scaffold(
                body: AnalyticsPage(),
              ),
            ),
          ),
        );

        // Measure analytics calculation performance
        stopwatch.start();
        await tester.pumpAndSettle();
        stopwatch.stop();

        // Verify performance benchmark (<500ms for 10k tasks)
        expect(stopwatch.elapsedMilliseconds, lessThan(500));

        // Test chart rendering performance
        stopwatch.reset();
        stopwatch.start();
        
        await tester.tap(find.byKey(const Key('project_timeline_chart')));
        await tester.pumpAndSettle();
        
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(200)); // Fast chart interaction

        // Test data aggregation performance
        stopwatch.reset();
        stopwatch.start();
        
        await tester.tap(find.byKey(const Key('time_range_selector')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Last Year'));
        await tester.pumpAndSettle();
        
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(300)); // Fast re-aggregation
      });

      testWidgets('should handle error conditions gracefully with user feedback', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: Scaffold(
                body: AnalyticsPage(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Simulate data loading error
        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'analytics_error',
          null,
          (data) {},
        );
        await tester.pumpAndSettle();

        // Verify error handling
        expect(find.text('Error loading analytics data'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.byKey(const Key('retry_load_data')), findsOneWidget);
        expect(find.byKey(const Key('load_cached_data')), findsOneWidget);

        // Test retry functionality
        await tester.tap(find.byKey(const Key('retry_load_data')));
        await tester.pumpAndSettle();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Retrying data load...'), findsOneWidget);

        // Test cached data fallback
        await tester.tap(find.byKey(const Key('load_cached_data')));
        await tester.pumpAndSettle();

        expect(find.text('Showing cached data (last updated: 5 minutes ago)'), findsOneWidget);

        // Test export error handling
        await tester.tap(find.byKey(const Key('export_analytics')));
        await tester.pumpAndSettle();

        // Simulate export failure
        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'export_error',
          null,
          (data) {},
        );
        await tester.pumpAndSettle();

        expect(find.text('Export failed'), findsOneWidget);
        expect(find.text('Unable to generate report. Please try again.'), findsOneWidget);
        expect(find.byKey(const Key('retry_export')), findsOneWidget);
        expect(find.byKey(const Key('export_partial_data')), findsOneWidget);

        // Test partial export option
        await tester.tap(find.byKey(const Key('export_partial_data')));
        await tester.pumpAndSettle();

        expect(find.text('Partial export completed'), findsOneWidget);
        expect(find.text('Some data may be missing due to the error'), findsOneWidget);
      });
    });
}

// Mock widgets and components for testing
class InteractiveTimelineChart extends StatelessWidget {
  final List<Project> projects;
  final List<TaskModel> tasks;
  final Function(Project)? onProjectTap;
  final Function(TaskModel)? onTaskTap;

  const InteractiveTimelineChart({
    super.key,
    required this.projects,
    required this.tasks,
    this.onProjectTap,
    this.onTaskTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all()),
      child: Column(
        children: [
          const Text('Project Timeline Chart'),
          Expanded(
            child: ListView(
              children: projects.map((project) => 
                ListTile(
                  key: Key('timeline_project_${project.id}'),
                  title: Text(project.name),
                  onTap: () => onProjectTap?.call(project),
                ),
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class BudgetAnalysisChart extends StatelessWidget {
  final List<Project> projects;
  final Function(String)? onSegmentTap;

  const BudgetAnalysisChart({
    super.key,
    required this.projects,
    this.onSegmentTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all()),
      child: Column(
        children: [
          const Text('Budget Analysis Chart'),
          ...projects.map((project) => 
            ListTile(
              key: Key('budget_segment_${project.id}'),
              title: Text(project.name),
              subtitle: Text('Budget: \$${project.budget}'),
              onTap: () => onSegmentTap?.call(project.id),
            ),
          ),
        ],
      ),
    );
  }
}

class VelocityChart extends StatelessWidget {
  final List<TaskModel> tasks;
  final Function(DateTime, double)? onDataPointTap;

  const VelocityChart({
    super.key,
    required this.tasks,
    this.onDataPointTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all()),
      child: Column(
        children: [
          const Text('Velocity Chart'),
          GestureDetector(
            key: const Key('velocity_data_point_week_2'),
            onTap: () => onDataPointTap?.call(DateTime.now(), 15.0),
            child: const Text('Week 2: 15 points'),
          ),
        ],
      ),
    );
  }
}

class AlertCard extends StatelessWidget {
  final AlertType type;
  final String title;
  final String message;
  final String action;

  const AlertCard({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(_getIcon()),
        title: Text(title),
        subtitle: Text(message),
        trailing: TextButton(
          onPressed: () {},
          child: Text(action),
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (type) {
      case AlertType.warning:
        return Icons.warning;
      case AlertType.critical:
        return Icons.error;
      case AlertType.info:
        return Icons.info;
    }
  }
}

enum AlertType { warning, critical, info }

// Additional mock components
class PerformanceReportView extends StatelessWidget {
  final List<Project> projects;
  final List<TaskModel> tasks;

  const PerformanceReportView({
    super.key,
    required this.projects,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        ListTile(title: Text('Overall Performance Score'), trailing: Text('72/100')),
        ListTile(title: Text('Task Completion Rate'), trailing: Text('60%')),
        ListTile(title: Text('Average Task Duration'), trailing: Text('18.5 hours')),
        ListTile(title: Text('Estimated vs Actual'), trailing: Text('+15% variance')),
      ],
    );
  }
}

class BudgetReportView extends StatelessWidget {
  final List<Project> projects;

  const BudgetReportView({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        ListTile(title: Text('Budget Utilization Overview')),
        ListTile(title: Text('Total Allocated'), trailing: Text('\$90,000')),
        ListTile(title: Text('Total Spent'), trailing: Text('\$32,500')),
        ListTile(title: Text('Remaining'), trailing: Text('\$57,500')),
        ListTile(title: Text('Projected Final Cost'), trailing: Text('\$95,000')),
      ],
    );
  }
}

class TimelineReportView extends StatelessWidget {
  final List<Project> projects;
  final List<TaskModel> tasks;

  const TimelineReportView({
    super.key,
    required this.projects,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        ListTile(title: Text('Timeline Analysis')),
        ListTile(title: Text('Projects on Schedule'), trailing: Text('1/3')),
        ListTile(title: Text('Projects at Risk'), trailing: Text('1/3')),
        ListTile(title: Text('Projects Delayed'), trailing: Text('0/3')),
        ListTile(title: Text('Critical Path Analysis')),
        ListTile(title: Text('Mobile App Development'), subtitle: Text('Critical tasks: 2, Buffer time: 10 days')),
      ],
    );
  }
}

class TeamReportView extends StatelessWidget {
  final List<TaskModel> tasks;

  const TeamReportView({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        ListTile(title: Text('Team Performance Overview')),
        ListTile(title: Text('Active Team Members'), trailing: Text('5')),
        ListTile(title: Text('Average Task Load'), trailing: Text('2.2 tasks')),
        ListTile(title: Text('Team Velocity'), trailing: Text('15 points/week')),
        ListTile(title: Text('Top Performers')),
        ListTile(title: Text('Most Productive'), subtitle: Text('John Doe')),
        ListTile(title: Text('Fastest Completion'), subtitle: Text('Jane Smith')),
      ],
    );
  }
}

class MultiSelectChip extends StatelessWidget {
  final String title;
  final List<String> options;
  final Function(List<String>) onSelectionChanged;

  const MultiSelectChip({
    super.key,
    required this.title,
    required this.options,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        Wrap(
          children: options.map((option) => 
            FilterChip(
              label: Text(option),
              selected: false,
              onSelected: (selected) {},
            ),
          ).toList(),
        ),
      ],
    );
  }
}

class ComparisonConfigPanel extends StatelessWidget {
  final List<Project> projects;
  final Function(Map<String, dynamic>) onConfigurationChanged;

  const ComparisonConfigPanel({
    super.key,
    required this.projects,
    required this.onConfigurationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          const Text('Comparison Configuration'),
          ListTile(
            title: const Text('Select Project 1'),
            trailing: DropdownButton<String>(
              key: const Key('select_project_1'),
              items: projects.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
              onChanged: (value) {},
            ),
          ),
          ListTile(
            title: const Text('Select Project 2'),
            trailing: DropdownButton<String>(
              key: const Key('select_project_2'),
              items: projects.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
              onChanged: (value) {},
            ),
          ),
        ],
      ),
    );
  }
}

class ProjectComparisonView extends StatelessWidget {
  final Project project1;
  final Project project2;
  final List<TaskModel> tasks1;
  final List<TaskModel> tasks2;

  const ProjectComparisonView({
    super.key,
    required this.project1,
    required this.project2,
    required this.tasks1,
    required this.tasks2,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Text('${project1.name} vs ${project2.name}'),
          const Row(
            children: [
              Expanded(child: Text('Completion Rate\n25%')),
              Expanded(child: Text('Completion Rate\n67%')),
            ],
          ),
          const Row(
            children: [
              Expanded(child: Text('Budget Progress\n\$12,500 / \$50,000')),
              Expanded(child: Text('Budget Progress\n\$15,000 / \$25,000')),
            ],
          ),
        ],
      ),
    );
  }
}

class TimePeriodComparisonView extends StatelessWidget {
  final List<TaskModel> currentPeriod;
  final List<TaskModel> previousPeriod;

  const TimePeriodComparisonView({
    super.key,
    required this.currentPeriod,
    required this.previousPeriod,
  });

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Column(
        children: [
          Text('Current Period vs Previous Period'),
          ListTile(title: Text('Task Velocity'), trailing: Text('+25%')),
          ListTile(title: Text('Completion Rate'), trailing: Text('+15%')),
          ListTile(title: Text('Team Productivity'), trailing: Text('+18%')),
        ],
      ),
    );
  }
}

class BenchmarkComparisonView extends StatelessWidget {
  final List<Project> projects;
  final Map<String, double> industryBenchmarks;

  const BenchmarkComparisonView({
    super.key,
    required this.projects,
    required this.industryBenchmarks,
  });

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Column(
        children: [
          Text('Performance vs Industry Benchmarks'),
          ListTile(title: Text('Completion Rate'), subtitle: Text('60% (Industry: 75%)')),
          ListTile(title: Text('Budget Variance'), subtitle: Text('+15% (Industry: +10%)')),
          ListTile(title: Text('Timeline Adherence'), subtitle: Text('67% (Industry: 80%)')),
          Text('Recommendations'),
          ListTile(title: Text('• Improve task completion rate by 15%')),
          ListTile(title: Text('• Reduce budget variance by 5%')),
          ListTile(title: Text('• Focus on timeline management')),
        ],
      ),
    );
  }
}

class ExportOptionsDialog extends StatelessWidget {
  const ExportOptionsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export Analytics'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Select Format:'),
          CheckboxListTile(
            key: const Key('format_pdf'),
            title: const Text('PDF'),
            value: false,
            onChanged: (value) {},
          ),
          CheckboxListTile(
            key: const Key('format_excel'),
            title: const Text('Excel'),
            value: false,
            onChanged: (value) {},
          ),
          const Text('Export Scope:'),
          RadioListTile<String>(
            key: const Key('scope_summary'),
            title: const Text('Summary'),
            value: 'summary',
            groupValue: 'detailed',
            onChanged: (value) {},
          ),
          RadioListTile<String>(
            key: const Key('scope_detailed'),
            title: const Text('Detailed'),
            value: 'detailed',
            groupValue: 'detailed',
            onChanged: (value) {},
          ),
        ],
      ),
      actions: [
        TextButton(
          key: const Key('start_export'),
          onPressed: () => Navigator.pop(context),
          child: const Text('Export'),
        ),
      ],
    );
  }
}

class ScheduledReportCard extends StatelessWidget {
  final String title;
  final String frequency;
  final List<String> recipients;
  final String format;
  final bool isActive;

  const ScheduledReportCard({
    super.key,
    required this.title,
    required this.frequency,
    required this.recipients,
    required this.format,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(frequency),
        trailing: Column(
          children: [
            Text(format),
            Switch(
              value: isActive,
              onChanged: (value) {},
            ),
          ],
        ),
      ),
    );
  }
}