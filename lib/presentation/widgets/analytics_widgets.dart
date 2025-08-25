import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/design_system/design_tokens.dart';
import '../../core/theme/typography_constants.dart';
import '../../services/analytics/analytics_models.dart';
import 'glassmorphism_container.dart';
import 'standardized_text.dart';
import 'standardized_spacing.dart';

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
          padding: StandardizedSpacing.padding(SpacingSize.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  StandardizedGaps.horizontal(SpacingSize.xs),
                  Expanded(
                    child: StandardizedText(
                      title,
                      style: StandardizedTextStyle.bodySmall,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              StandardizedGaps.vertical(SpacingSize.xs),
              StandardizedText(
                value,
                style: StandardizedTextStyle.headlineMedium,
                color: color,
              ),
              StandardizedText(
                subtitle,
                style: StandardizedTextStyle.bodySmall,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              if (trend != null) ...[
                StandardizedGaps.vertical(SpacingSize.xs),
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
                          ? Theme.of(context).colorScheme.tertiary // Success/positive trend color
                          : isPositiveTrend == false
                              ? Theme.of(context).colorScheme.error // Error/negative trend color
                              : Theme.of(context).colorScheme.onSurfaceVariant, // Neutral trend color
                    ),
                    StandardizedGaps.horizontal(SpacingSize.xs),
                    StandardizedText(
                      trend!,
                      style: StandardizedTextStyle.bodySmall,
                      color: isPositiveTrend == true
                          ? Theme.of(context).colorScheme.tertiary
                          : isPositiveTrend == false
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.onSurfaceVariant,
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
        padding: StandardizedSpacing.padding(SpacingSize.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StandardizedText(
              title,
              style: StandardizedTextStyle.titleMedium,
            ),
            StandardizedGaps.md,
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
                      padding: StandardizedSpacing.paddingSymmetric(horizontal: SpacingSize.xs),
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
                          StandardizedGaps.vertical(SpacingSize.xs),
                          StandardizedText(
                            label,
                            style: StandardizedTextStyle.bodySmall,
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
        padding: StandardizedSpacing.padding(SpacingSize.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StandardizedText(
              title,
              style: StandardizedTextStyle.titleMedium,
            ),
            StandardizedGaps.md,
            ...categories.take(5).map((category) {
              final percentage = totalTasks > 0 ? (category.totalTasks / totalTasks * 100).round() : 0;
              final color = _getCategoryColor(category.categoryName, context);

              return Padding(
                padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
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

  Color _getCategoryColor(String categoryName, BuildContext context) {
    // Note: This method should ideally use context.colors for semantic colors
    // For now, keeping hardcoded colors for consistent category representation
    final colors = [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.tertiary,
      Theme.of(context).colorScheme.onTertiaryContainer,
      Theme.of(context).colorScheme.secondary,
      Theme.of(context).colorScheme.error,
      Theme.of(context).colorScheme.inversePrimary,
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.secondary,
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
              StandardizedText(
                name,
                style: StandardizedTextStyle.bodyMedium,
              ),
              StandardizedText(
                '${(completionRate * 100).round()}% completion rate',
                style: StandardizedTextStyle.bodySmall,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            StandardizedText(
              '$count tasks',
              style: StandardizedTextStyle.bodySmall,
            ),
            StandardizedText(
              '$percentage%',
              style: StandardizedTextStyle.bodyMedium,
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
    final insights = _generateInsights(context);

    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      child: Padding(
        padding: StandardizedSpacing.padding(SpacingSize.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StandardizedText(
              'Productivity Insights',
              style: StandardizedTextStyle.titleMedium,
            ),
            StandardizedGaps.md,
            ...insights.map((insight) => Padding(
                  padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
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

  List<ProductivityInsight> _generateInsights(BuildContext context) {
    final insights = <ProductivityInsight>[];

    // Peak productivity hour
    final peakHour = hourlyProductivity.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    final peakHourFormatted = _formatHour(peakHour);
    insights.add(ProductivityInsight(
      icon: PhosphorIcons.clock(),
      title: 'Peak Productivity',
      description: 'You\'re most productive at $peakHourFormatted',
      color: Theme.of(context).colorScheme.onTertiaryContainer,
    ));

    // Streak information
    if (metrics.currentStreak > 0) {
      insights.add(ProductivityInsight(
        icon: PhosphorIcons.fire(),
        title: 'Current Streak',
        description: '${metrics.currentStreak} days of consistent task completion',
        color: Theme.of(context).colorScheme.onTertiaryContainer,
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
        color: Colors.green, // TODO: Replace with context.colors.success
      ));
    }

    // Average tasks per day
    if (metrics.averageTasksPerDay > 5) {
      insights.add(ProductivityInsight(
        icon: PhosphorIcons.lightbulb(),
        title: 'High Activity',
        description: 'You complete ${metrics.averageTasksPerDay.toStringAsFixed(1)} tasks per day on average',
        color: Theme.of(context).colorScheme.primary,
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
          padding: const EdgeInsets.all(SpacingTokens.xs), // 8.0 - Fixed spacing hierarchy
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        StandardizedGaps.md,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StandardizedText(
                title,
                style: StandardizedTextStyle.titleSmall,
              ),
              StandardizedText(
                description,
                style: StandardizedTextStyle.bodySmall,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
        padding: StandardizedSpacing.padding(SpacingSize.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  PhosphorIcons.fire(),
                  color: streakInfo.isStreakActive ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.onSurfaceVariant, // Fixed hardcoded colors
                  size: 24,
                ),
                const SizedBox(width: 8),
                const StandardizedText(
                  'Task Completion Streak',
                  style: StandardizedTextStyle.titleMedium,
                ),
              ],
            ),
            StandardizedGaps.md,
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
                StandardizedGaps.md,
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
              StandardizedGaps.vertical(SpacingSize.sm),
              StandardizedText(
                'Last completion: ${_formatDate(streakInfo.lastCompletionDate!)}',
                style: StandardizedTextStyle.bodySmall,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
        StandardizedText(
          title,
          style: StandardizedTextStyle.bodySmall,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            StandardizedText(
              value,
              style: StandardizedTextStyle.headlineMedium,
              color: isActive ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
              child: StandardizedText(
                subtitle,
                style: StandardizedTextStyle.bodySmall,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
        padding: StandardizedSpacing.padding(SpacingSize.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StandardizedText(
              'Time Period',
              style: StandardizedTextStyle.titleMedium,
            ),
            StandardizedGaps.vertical(SpacingSize.sm),
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
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md, vertical: SpacingTokens.xs),
      glassTint: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.2) : null,
      borderColor: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.3) : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        child: StandardizedText(
          label,
          style: StandardizedTextStyle.labelMedium,
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
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
        padding: StandardizedSpacing.padding(SpacingSize.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StandardizedText(
              'Productivity Patterns',
              style: StandardizedTextStyle.titleMedium,
            ),
            StandardizedGaps.md,

            // Consistency score
            Row(
              children: [
                Icon(PhosphorIcons.trendUp(), color: Theme.of(context).colorScheme.primary, size: 20), // Fixed hardcoded blue
                const SizedBox(width: 8),
                StandardizedText(
                  'Consistency Score: ${(patterns.consistencyScore * 100).round()}%',
                  style: StandardizedTextStyle.titleSmall,
                ),
              ],
            ),
            StandardizedGaps.md,

            // Peak hours
            if (patterns.peaks.isNotEmpty) ...[
              const StandardizedText(
                'Peak Productivity Hours',
                style: StandardizedTextStyle.titleSmall,
              ),
              StandardizedGaps.vertical(SpacingSize.xs),
              ...patterns.peaks.take(3).map((peak) => Padding(
                    padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
                    child: Row(
                      children: [
                        Icon(PhosphorIcons.clock(), color: Theme.of(context).colorScheme.secondary, size: 16), // Fixed hardcoded orange
                        StandardizedGaps.horizontal(SpacingSize.xs),
                        StandardizedText(
                          '${_formatHour(peak.hour)} - ${(peak.efficiency * 100).round()}% efficiency',
                          style: StandardizedTextStyle.bodySmall,
                        ),
                      ],
                    ),
                  )),
              StandardizedGaps.md,
            ],

            // Category efficiency
            if (patterns.categoryEfficiency.isNotEmpty) ...[
              const StandardizedText(
                'Category Performance',
                style: StandardizedTextStyle.titleSmall,
              ),
              StandardizedGaps.vertical(SpacingSize.xs),
              ...(patterns.categoryEfficiency.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
                  .take(3)
                  .map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _getCategoryColor(entry.key, context),
                                shape: BoxShape.circle,
                              ),
                            ),
                            StandardizedGaps.horizontal(SpacingSize.xs),
                            Expanded(
                              child: StandardizedText(
                                entry.key,
                                style: StandardizedTextStyle.bodySmall,
                              ),
                            ),
                            StandardizedText(
                              '${(entry.value * 100).round()}%',
                              style: StandardizedTextStyle.bodySmall,
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

  Color _getCategoryColor(String categoryName, BuildContext context) {
    // Note: This method should ideally use context.colors for semantic colors
    // For now, keeping hardcoded colors for consistent category representation
    final colors = [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.tertiary,
      Theme.of(context).colorScheme.onTertiaryContainer,
      Theme.of(context).colorScheme.secondary,
      Theme.of(context).colorScheme.error,
      Theme.of(context).colorScheme.inversePrimary,
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.secondary,
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
        padding: StandardizedSpacing.padding(SpacingSize.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StandardizedText(
              'Peak Hours Analysis',
              style: StandardizedTextStyle.titleMedium,
            ),
            StandardizedGaps.md,

            // Peak hours
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Peak Hours',
                    value: analysis.peakHours.take(3).map(_formatHour).join(', '),
                    icon: PhosphorIcons.clock(),
                    color: Colors.green, // TODO: Replace with context.colors.success // TODO: Replace with context.colors.success
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Optimal Window',
                    value:
                        '${_formatHour(analysis.recommendedWorkingWindow.startHour)}-${_formatHour(analysis.recommendedWorkingWindow.endHour)}',
                    icon: PhosphorIcons.clock(),
                    color: Theme.of(context).colorScheme.primary, // TODO: Replace with context.colors.info
                  ),
                ),
              ],
            ),
            StandardizedGaps.md,

            // Productivity scores
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Peak Score',
                    value: '${(analysis.peakProductivityScore * 100).round()}%',
                    icon: PhosphorIcons.trendUp(),
                    color: Theme.of(context).colorScheme.onTertiaryContainer, // TODO: Replace with context.colors.warning
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Average Score',
                    value: '${(analysis.averageProductivityScore * 100).round()}%',
                    icon: PhosphorIcons.chartBar(),
                    color: Colors.purple, // TODO: Replace with semantic color
                  ),
                ),
              ],
            ),
            StandardizedGaps.md,

            // Optimization suggestions
            if (analysis.suggestions.isNotEmpty) ...[
              const StandardizedText(
                'Optimization Suggestions',
                style: StandardizedTextStyle.titleSmall,
              ),
              StandardizedGaps.vertical(SpacingSize.xs),
              ...analysis.suggestions.take(2).map((suggestion) => Padding(
                    padding: StandardizedSpacing.paddingOnly(bottom: SpacingSize.sm),
                    child: Container(
                      padding: const EdgeInsets.all(SpacingTokens.sm), // 12.0 - Fixed spacing hierarchy
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StandardizedText(
                            suggestion.title,
                            style: StandardizedTextStyle.titleSmall,
                          ),
                          StandardizedGaps.vertical(SpacingSize.xs),
                          StandardizedText(
                            suggestion.description,
                            style: StandardizedTextStyle.bodySmall,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
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
        padding: StandardizedSpacing.padding(SpacingSize.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StandardizedText(
              'Advanced Category Analytics',
              style: StandardizedTextStyle.titleMedium,
            ),
            StandardizedGaps.md,

            // Performance ranking
            if (analytics.ranking.topPerformingCategories.isNotEmpty) ...[
              const StandardizedText(
                'Top Performing Categories',
                style: StandardizedTextStyle.titleSmall,
              ),
              StandardizedGaps.vertical(SpacingSize.xs),
              ...analytics.ranking.topPerformingCategories.take(3).map((categoryId) {
                final score = analytics.ranking.categoryScores[categoryId] ?? 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
                  child: Row(
                    children: [
                      Icon(PhosphorIcons.star(), color: Colors.amber /* TODO: context.colors.warning */, size: 16),
                      StandardizedGaps.horizontal(SpacingSize.xs),
                      Expanded(
                        child: StandardizedText(
                          categoryId,
                          style: StandardizedTextStyle.bodySmall,
                        ),
                      ),
                      StandardizedText(
                        '${(score * 100).round()}%',
                        style: StandardizedTextStyle.bodySmall,
                      ),
                    ],
                  ),
                );
              }),
              StandardizedGaps.md,
            ],

            // Category insights
            if (analytics.insights.isNotEmpty) ...[
              const StandardizedText(
                'Category Insights',
                style: StandardizedTextStyle.titleSmall,
              ),
              StandardizedGaps.vertical(SpacingSize.xs),
              ...analytics.insights.take(3).map((insight) => Padding(
                    padding: StandardizedSpacing.paddingOnly(bottom: SpacingSize.sm),
                    child: Container(
                      padding: const EdgeInsets.all(SpacingTokens.sm), // 12.0 - Fixed spacing hierarchy
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StandardizedText(
                            insight.title,
                            style: StandardizedTextStyle.titleSmall,
                          ),
                          StandardizedGaps.vertical(SpacingSize.xs),
                          StandardizedText(
                            insight.description,
                            style: StandardizedTextStyle.bodySmall,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
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
        padding: StandardizedSpacing.padding(SpacingSize.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StandardizedText(
              'Productivity Insights & Recommendations',
              style: StandardizedTextStyle.titleMedium,
            ),
            StandardizedGaps.md,

            // Overall productivity score
            Container(
              padding: const EdgeInsets.all(SpacingTokens.md), // 16.0 - Fixed spacing hierarchy
              decoration: BoxDecoration(
                color: _getScoreColor(insights.overallScore.overall).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(SpacingTokens.sm), // 12.0 - Fixed spacing hierarchy
                    decoration: BoxDecoration(
                      color: _getScoreColor(insights.overallScore.overall),
                      shape: BoxShape.circle,
                    ),
                    child: StandardizedText(
                      insights.overallScore.grade,
                      style: StandardizedTextStyle.titleMedium,
                      color: Colors.white, // TODO: Use semantic on-color
                    ),
                  ),
                  StandardizedGaps.md,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const StandardizedText(
                          'Overall Productivity Score',
                          style: StandardizedTextStyle.titleSmall,
                        ),
                        StandardizedText(
                          '${insights.overallScore.overall.round()}/100',
                          style: StandardizedTextStyle.headlineSmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            StandardizedGaps.md,

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
            StandardizedGaps.md,

            // Top suggestions
            if (insights.suggestions.isNotEmpty) ...[
              const StandardizedText(
                'Top Recommendations',
                style: StandardizedTextStyle.titleSmall,
              ),
              StandardizedGaps.vertical(SpacingSize.xs),
              ...insights.suggestions.take(3).map((suggestion) => Padding(
                    padding: StandardizedSpacing.paddingOnly(bottom: SpacingSize.sm),
                    child: Container(
                      padding: const EdgeInsets.all(SpacingTokens.sm), // 12.0 - Fixed spacing hierarchy
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(SpacingTokens.xs + 2), // 6.0 - Fixed spacing hierarchy
                            decoration: BoxDecoration(
                              color: _getImpactColor(suggestion.impactScore).withValues(alpha: 0.2),
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
                                StandardizedText(
                                  suggestion.title,
                                  style: StandardizedTextStyle.titleSmall,
                                ),
                                StandardizedText(
                                  suggestion.description,
                                  style: StandardizedTextStyle.bodySmall,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
    // TODO: Replace with semantic colors when context is available
    if (score >= 80) return Colors.green; // TODO: context.colors.success
    if (score >= 60) return Colors.orange; // TODO: context.colors.warning
    return Colors.red; // TODO: context.colors.error
  }

  Color _getImpactColor(double impact) {
    // TODO: Replace with semantic colors when context is available
    if (impact >= 0.7) return Colors.red; // TODO: context.colors.error
    if (impact >= 0.5) return Colors.orange; // TODO: context.colors.warning
    return Colors.blue; // TODO: context.colors.info
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
      padding: const EdgeInsets.all(SpacingTokens.sm), // 12.0 - Fixed spacing hierarchy
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
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
                child: StandardizedText(
                  title,
                  style: StandardizedTextStyle.bodySmall,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          StandardizedText(
            value,
            style: StandardizedTextStyle.titleSmall,
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
        StandardizedText(
          title,
          style: StandardizedTextStyle.bodySmall,
        ),
        StandardizedText(
          '${score.round()}%',
          style: StandardizedTextStyle.titleSmall,
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
        padding: StandardizedSpacing.padding(SpacingSize.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StandardizedText(
              'Export Analytics',
              style: StandardizedTextStyle.titleMedium,
            ),
            StandardizedGaps.md,
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
      label: StandardizedText(label, style: StandardizedTextStyle.buttonText),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
      ),
    );
  }
}
