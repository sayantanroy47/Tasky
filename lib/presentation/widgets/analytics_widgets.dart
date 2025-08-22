import 'package:flutter/material.dart';
import '../../services/analytics/analytics_models.dart';
import 'glassmorphism_container.dart';
import '../../core/theme/typography_constants.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  SizedBox(width: 8),
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
                          ? PhosphorIcons.arrowUp()
                          : isPositiveTrend == false
                              ? PhosphorIcons.arrowDown()
                              : PhosphorIcons.minus(),
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
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
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
                                top: Radius.circular(TypographyConstants.radiusStandard),
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

    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
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

    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
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
      icon: PhosphorIcons.clock(),
      title: 'Peak Productivity',
      description: 'You\'re most productive at $peakHourFormatted',
      color: Colors.amber,
    ));

    // Streak information
    if (metrics.currentStreak > 0) {
      insights.add(ProductivityInsight(
        icon: PhosphorIcons.fire(),
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
        icon: PhosphorIcons.trendUp(),
        title: 'Improving Trend',
        description: 'Your completion rate improved from $monthlyRate% to $weeklyRate%',
        color: Colors.green,
      ));
    }

    // Average tasks per day
    if (metrics.averageTasksPerDay > 5) {
      insights.add(ProductivityInsight(
        icon: PhosphorIcons.lightbulb(),
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
            color: color.withValues(alpha:  0.1),
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
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
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  PhosphorIcons.fire(),
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
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
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
                  .map((period) => _buildGlassmorphicChip(
                        context,
                        period.displayName,
                        selectedPeriod == period,
                        () => onPeriodChanged(period),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Build a glassmorphic chip for time period selection
  Widget _buildGlassmorphicChip(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      glassTint: isSelected 
          ? theme.colorScheme.primary.withValues(alpha: 0.2)
          : null,
      borderColor: isSelected 
          ? theme.colorScheme.primary.withValues(alpha: 0.3)
          : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: isSelected 
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

/// Advanced analytics widgets for new features

/// Widget for displaying productivity patterns
class ProductivityPatternsWidget extends StatelessWidget {
  final ProductivityPatterns patterns;

  const ProductivityPatternsWidget({
    super.key,
    required this.patterns,
  });
  @override
  Widget build(BuildContext context) {
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Productivity Patterns',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 16),
            
            // Consistency score
            Row(
              children: [
                Icon(PhosphorIcons.trendUp(), color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Consistency Score: ${(patterns.consistencyScore * 100).round()}%',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Peak hours
            if (patterns.peaks.isNotEmpty) ...[
              Text(
                'Peak Productivity Hours',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...patterns.peaks.take(3).map((peak) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  children: [
                    Icon(PhosphorIcons.clock(), color: Colors.orange, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '${_formatHour(peak.hour)} - ${(peak.efficiency * 100).round()}% efficiency',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 16),
            ],
            
            // Category efficiency
            if (patterns.categoryEfficiency.isNotEmpty) ...[
              Text(
                'Category Performance',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...(patterns.categoryEfficiency.entries
                  .toList()
                  ..sort((a, b) => b.value.compareTo(a.value)))
                  .take(3)
                  .map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _getCategoryColor(entry.key),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        Text(
                          '${(entry.value * 100).round()}%',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$hour AM';
    if (hour == 12) return '12 PM';
    return '${hour - 12} PM';
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

/// Widget for displaying peak hours analysis
class PeakHoursAnalysisWidget extends StatelessWidget {
  final PeakHoursAnalysis analysis;

  const PeakHoursAnalysisWidget({
    super.key,
    required this.analysis,
  });
  @override
  Widget build(BuildContext context) {
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Peak Hours Analysis',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 16),
            
            // Peak hours
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Peak Hours',
                    value: analysis.peakHours.take(3).map(_formatHour).join(', '),
                    icon: PhosphorIcons.clock(),
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Optimal Window',
                    value: '${_formatHour(analysis.recommendedWorkingWindow.startHour)}-${_formatHour(analysis.recommendedWorkingWindow.endHour)}',
                    icon: PhosphorIcons.clock(),
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Productivity scores
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Peak Score',
                    value: '${(analysis.peakProductivityScore * 100).round()}%',
                    icon: PhosphorIcons.trendUp(),
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Average Score',
                    value: '${(analysis.averageProductivityScore * 100).round()}%',
                    icon: PhosphorIcons.chartBar(),
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Optimization suggestions
            if (analysis.suggestions.isNotEmpty) ...[
              Text(
                'Optimization Suggestions',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...analysis.suggestions.take(2).map((suggestion) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        suggestion.title,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        suggestion.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$hour AM';
    if (hour == 12) return '12 PM';
    return '${hour - 12} PM';
  }
}

/// Widget for displaying advanced category analytics
class AdvancedCategoryAnalyticsWidget extends StatelessWidget {
  final AdvancedCategoryAnalytics analytics;

  const AdvancedCategoryAnalyticsWidget({
    super.key,
    required this.analytics,
  });
  @override
  Widget build(BuildContext context) {
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Advanced Category Analytics',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 16),
            
            // Performance ranking
            if (analytics.ranking.topPerformingCategories.isNotEmpty) ...[
              Text(
                'Top Performing Categories',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...analytics.ranking.topPerformingCategories.take(3).map((categoryId) {
                final score = analytics.ranking.categoryScores[categoryId] ?? 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    children: [
                      Icon(PhosphorIcons.star(), color: Colors.amber, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          categoryId,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      Text(
                        '${(score * 100).round()}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],
            
            // Category insights
            if (analytics.insights.isNotEmpty) ...[
              Text(
                'Category Insights',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...analytics.insights.take(3).map((insight) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insight.title,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        insight.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget for displaying productivity insights and suggestions
class AdvancedProductivityInsightsWidget extends StatelessWidget {
  final ProductivityInsights insights;

  const AdvancedProductivityInsightsWidget({
    super.key,
    required this.insights,
  });
  @override
  Widget build(BuildContext context) {
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Productivity Insights & Recommendations',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            // Overall productivity score
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getScoreColor(insights.overallScore.overall).withValues(alpha:  0.1),
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getScoreColor(insights.overallScore.overall),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      insights.overallScore.grade,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Overall Productivity Score',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          '${insights.overallScore.overall.round()}/100',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            
            // Score breakdown
            Row(
              children: [
                Expanded(
                  child: _ScoreItem(
                    title: 'Completion',
                    score: insights.overallScore.completion,
                    icon: PhosphorIcons.checkCircle(),
                  ),
                ),
                Expanded(
                  child: _ScoreItem(
                    title: 'Consistency',
                    score: insights.overallScore.consistency,
                    icon: PhosphorIcons.trendUp(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _ScoreItem(
                    title: 'Efficiency',
                    score: insights.overallScore.efficiency,
                    icon: PhosphorIcons.speedometer(),
                  ),
                ),
                Expanded(
                  child: _ScoreItem(
                    title: 'Time Mgmt',
                    score: insights.overallScore.timeManagement,
                    icon: PhosphorIcons.clock(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Top suggestions
            if (insights.suggestions.isNotEmpty) ...[
              Text(
                'Top Recommendations',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...insights.suggestions.take(3).map((suggestion) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _getImpactColor(suggestion.impactScore).withValues(alpha:  0.2),
                          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                        ),
                        child: Icon(
                          _getSuggestionIcon(suggestion.actionType),
                          color: _getImpactColor(suggestion.impactScore),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              suggestion.title,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              suggestion.description,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  Color _getImpactColor(double impact) {
    if (impact >= 0.7) return Colors.red;
    if (impact >= 0.5) return Colors.orange;
    return Colors.blue;
  }

  IconData _getSuggestionIcon(String actionType) {
    switch (actionType) {
      case 'schedule':
        return PhosphorIcons.clock();
      case 'habit':
        return PhosphorIcons.brain();
      case 'tool':
        return PhosphorIcons.wrench();
      default:
        return PhosphorIcons.lightbulb();
    }
  }
}

/// Helper widget for metric cards
class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha:  0.1),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
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
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper widget for score items
class _ScoreItem extends StatelessWidget {
  final String title;
  final double score;
  final IconData icon;

  const _ScoreItem({
    required this.title,
    required this.score,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          '${score.round()}%',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Widget for analytics export functionality
class AnalyticsExportWidget extends StatelessWidget {
  final VoidCallback? onExportJson;
  final VoidCallback? onExportCsv;
  final VoidCallback? onExportPdf;
  final VoidCallback? onExportExcel;

  const AnalyticsExportWidget({
    super.key,
    this.onExportJson,
    this.onExportCsv,
    this.onExportPdf,
    this.onExportExcel,
  });
  @override
  Widget build(BuildContext context) {
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Analytics',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ExportButton(
                    label: 'JSON',
                    icon: PhosphorIcons.code(),
                    onPressed: onExportJson,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ExportButton(
                    label: 'CSV',
                    icon: PhosphorIcons.table(),
                    onPressed: onExportCsv,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _ExportButton(
                    label: 'PDF',
                    icon: PhosphorIcons.filePdf(),
                    onPressed: onExportPdf,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ExportButton(
                    label: 'Excel',
                    icon: PhosphorIcons.gridNine(),
                    onPressed: onExportExcel,
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

/// Helper widget for export buttons
class _ExportButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  const _ExportButton({
    required this.label,
    required this.icon,
    this.onPressed,
  });
  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}



