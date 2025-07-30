import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/analytics/analytics_models.dart';

/// Collection of reusable widgets for analytics display

/// Widget for displaying a metric card with value, trend, and icon
class AnalyticsMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String? trend;
  final bool? isPositiveTrend;
  final VoidCallback? onTap;

  const AnalyticsMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.trend,
    this.isPositiveTrend,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              if (trend != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      isPositiveTrend == true
                          ? Icons.arrow_upward
                          : isPositiveTrend == false
                              ? Icons.arrow_downward
                              : Icons.remove,
                      size: 12,
                      color: isPositiveTrend == true
                          ? Colors.green
                          : isPositiveTrend == false
                              ? Colors.red
                              : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trend!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isPositiveTrend == true
                            ? Colors.green
                            : isPositiveTrend == false
                                ? Colors.red
                                : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget for displaying a simple bar chart
class SimpleBarChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final String title;
  final Color? barColor;
  final double height;

  const SimpleBarChart({
    super.key,
    required this.values,
    required this.labels,
    required this.title,
    this.barColor,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 1.0;
    final color = barColor ?? Theme.of(context).colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: height,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(values.length, (index) {
                  final value = values[index];
                  final normalizedHeight = maxValue > 0 ? (value / maxValue) * (height - 40) : 0.0;
                  final label = index < labels.length ? labels[index] : '';

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: normalizedHeight,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            label,
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
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
    );
  }
}

/// Widget for displaying category breakdown with progress bars
class CategoryBreakdownWidget extends StatelessWidget {
  final List<CategoryAnalytics> categories;
  final String title;

  const CategoryBreakdownWidget({
    super.key,
    required this.categories,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final totalTasks = categories.fold<int>(0, (sum, cat) => sum + cat.totalTasks);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...categories.take(5).map((category) {
              final percentage = totalTasks > 0 ? (category.totalTasks / totalTasks * 100).round() : 0;
              final color = _getCategoryColor(category.categoryName);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: CategoryItem(
                  name: category.categoryName,
                  percentage: percentage,
                  color: color,
                  count: category.totalTasks,
                  completionRate: category.completionRate,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String categoryName) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[categoryName.hashCode % colors.length];
  }
}

/// Individual category item widget
class CategoryItem extends StatelessWidget {
  final String name;
  final int percentage;
  final Color color;
  final int count;
  final double completionRate;

  const CategoryItem({
    super.key,
    required this.name,
    required this.percentage,
    required this.color,
    required this.count,
    required this.completionRate,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '${(completionRate * 100).round()}% completion rate',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$count tasks',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '$percentage%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Widget for displaying productivity insights
class ProductivityInsightsWidget extends StatelessWidget {
  final ProductivityMetrics metrics;
  final Map<int, int> hourlyProductivity;
  final Map<int, int> weekdayProductivity;

  const ProductivityInsightsWidget({
    super.key,
    required this.metrics,
    required this.hourlyProductivity,
    required this.weekdayProductivity,
  });

  @override
  Widget build(BuildContext context) {
    final insights = _generateInsights();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Productivity Insights',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...insights.map((insight) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: InsightItem(
                icon: insight.icon,
                title: insight.title,
                description: insight.description,
                color: insight.color,
              ),
            )),
          ],
        ),
      ),
    );
  }

  List<ProductivityInsight> _generateInsights() {
    final insights = <ProductivityInsight>[];

    // Peak productivity hour
    final peakHour = hourlyProductivity.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    final peakHourFormatted = _formatHour(peakHour);
    insights.add(ProductivityInsight(
      icon: Icons.schedule,
      title: 'Peak Productivity',
      description: 'You\'re most productive at $peakHourFormatted',
      color: Colors.amber,
    ));

    // Streak information
    if (metrics.currentStreak > 0) {
      insights.add(ProductivityInsight(
        icon: Icons.local_fire_department,
        title: 'Current Streak',
        description: '${metrics.currentStreak} days of consistent task completion',
        color: Colors.orange,
      ));
    }

    // Completion rate trend
    final weeklyRate = (metrics.weeklyCompletionRate * 100).round();
    final monthlyRate = (metrics.monthlyCompletionRate * 100).round();
    if (weeklyRate > monthlyRate) {
      insights.add(ProductivityInsight(
        icon: Icons.trending_up,
        title: 'Improving Trend',
        description: 'Your completion rate improved from $monthlyRate% to $weeklyRate%',
        color: Colors.green,
      ));
    }

    // Average tasks per day
    if (metrics.averageTasksPerDay > 5) {
      insights.add(ProductivityInsight(
        icon: Icons.lightbulb,
        title: 'High Activity',
        description: 'You complete ${metrics.averageTasksPerDay.toStringAsFixed(1)} tasks per day on average',
        color: Colors.blue,
      ));
    }

    return insights;
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$hour AM';
    if (hour == 12) return '12 PM';
    return '${hour - 12} PM';
  }
}

/// Data class for productivity insights
class ProductivityInsight {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const ProductivityInsight({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

/// Individual insight item widget
class InsightItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const InsightItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Widget for displaying streak information
class StreakWidget extends StatelessWidget {
  final StreakInfo streakInfo;

  const StreakWidget({
    super.key,
    required this.streakInfo,
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
                Icon(
                  Icons.local_fire_department,
                  color: streakInfo.isStreakActive ? Colors.orange : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Task Completion Streak',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StreakMetric(
                    title: 'Current Streak',
                    value: '${streakInfo.currentStreak}',
                    subtitle: 'days',
                    isActive: streakInfo.isStreakActive,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StreakMetric(
                    title: 'Longest Streak',
                    value: '${streakInfo.longestStreak}',
                    subtitle: 'days',
                    isActive: false,
                  ),
                ),
              ],
            ),
            if (streakInfo.lastCompletionDate != null) ...[
              const SizedBox(height: 12),
              Text(
                'Last completion: ${_formatDate(streakInfo.lastCompletionDate!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (dateOnly.isAtSameMomentAs(yesterday)) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Individual streak metric widget
class _StreakMetric extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final bool isActive;

  const _StreakMetric({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: isActive ? Colors.orange : Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Time period selector widget
class TimePeriodSelector extends StatelessWidget {
  final AnalyticsTimePeriod selectedPeriod;
  final ValueChanged<AnalyticsTimePeriod> onPeriodChanged;

  const TimePeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time Period',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AnalyticsTimePeriod.values
                  .where((period) => period != AnalyticsTimePeriod.custom)
                  .map((period) => FilterChip(
                        label: Text(period.displayName),
                        selected: selectedPeriod == period,
                        onSelected: (selected) {
                          if (selected) {
                            onPeriodChanged(period);
                          }
                        },
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}