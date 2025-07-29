import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/theme_selector.dart';
import '../widgets/app_scaffold.dart';

/// Analytics page for viewing productivity metrics and insights
class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: 'Analytics',
      actions: [
        const ThemeToggleButton(),
        IconButton(
          icon: const Icon(Icons.date_range),
          onPressed: () {
            // TODO: Change date range
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Date range selector coming soon!')),
            );
          },
          tooltip: 'Change date range',
        ),
        IconButton(
          icon: const Icon(Icons.file_download),
          onPressed: () {
            // TODO: Export analytics
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Export analytics coming soon!')),
            );
          },
          tooltip: 'Export data',
        ),
      ],
      body: const AnalyticsPageBody(),
    );
  }
}

/// Analytics page body content
class AnalyticsPageBody extends ConsumerWidget {
  const AnalyticsPageBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time period selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'This Week',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'week', label: Text('Week')),
                      ButtonSegment(value: 'month', label: Text('Month')),
                      ButtonSegment(value: 'year', label: Text('Year')),
                    ],
                    selected: {'week'},
                    onSelectionChanged: (selection) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${selection.first} analytics coming soon!'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Key metrics
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Completed',
                  value: '24',
                  subtitle: 'tasks this week',
                  icon: Icons.check_circle,
                  color: Colors.green,
                  trend: '+12%',
                  isPositive: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Productivity',
                  value: '87%',
                  subtitle: 'completion rate',
                  icon: Icons.trending_up,
                  color: Colors.blue,
                  trend: '+5%',
                  isPositive: true,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Streak',
                  value: '7',
                  subtitle: 'days active',
                  icon: Icons.local_fire_department,
                  color: Colors.orange,
                  trend: '+2 days',
                  isPositive: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Avg Time',
                  value: '2.5h',
                  subtitle: 'per task',
                  icon: Icons.schedule,
                  color: Colors.purple,
                  trend: '-15min',
                  isPositive: true,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Charts section
          Text(
            'Productivity Trends',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          
          // Placeholder chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Task Completion',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  
                  // Simple bar chart placeholder
                  SizedBox(
                    height: 200,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(7, (index) {
                        final height = [60, 80, 45, 90, 70, 85, 95][index];
                        final day = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index];
                        
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  height: height.toDouble(),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  day,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Category breakdown
          Text(
            'Task Categories',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _CategoryItem(
                    name: 'Work',
                    percentage: 45,
                    color: Colors.blue,
                    count: 18,
                  ),
                  const SizedBox(height: 12),
                  _CategoryItem(
                    name: 'Personal',
                    percentage: 30,
                    color: Colors.green,
                    count: 12,
                  ),
                  const SizedBox(height: 12),
                  _CategoryItem(
                    name: 'Health',
                    percentage: 15,
                    color: Colors.orange,
                    count: 6,
                  ),
                  const SizedBox(height: 12),
                  _CategoryItem(
                    name: 'Learning',
                    percentage: 10,
                    color: Colors.purple,
                    count: 4,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Insights section
          Text(
            'Insights',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InsightItem(
                    icon: Icons.lightbulb,
                    title: 'Peak Productivity',
                    description: 'You\'re most productive between 9 AM - 11 AM',
                    color: Colors.amber,
                  ),
                  const Divider(),
                  _InsightItem(
                    icon: Icons.trending_up,
                    title: 'Improvement',
                    description: 'Task completion rate improved by 12% this week',
                    color: Colors.green,
                  ),
                  const Divider(),
                  _InsightItem(
                    icon: Icons.schedule,
                    title: 'Time Management',
                    description: 'Consider breaking down large tasks into smaller ones',
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Metric card widget
class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String trend;
  final bool isPositive;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.trend,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 12,
                  color: isPositive ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  trend,
                  style: TextStyle(
                    fontSize: 12,
                    color: isPositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Category item widget
class _CategoryItem extends StatelessWidget {
  final String name;
  final int percentage;
  final Color color;
  final int count;

  const _CategoryItem({
    required this.name,
    required this.percentage,
    required this.color,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(name),
        ),
        Text(
          '$count tasks',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(width: 16),
        Text(
          '$percentage%',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Insight item widget
class _InsightItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _InsightItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}