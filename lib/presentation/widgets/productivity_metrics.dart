import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/design_system/design_tokens.dart';
import '../../core/theme/typography_constants.dart';
import 'analytics_widgets.dart';
import 'glassmorphism_container.dart';
import 'standardized_colors.dart';
import 'standardized_text.dart';
import 'standardized_spacing.dart';

/// Widget that displays comprehensive productivity metrics
class ProductivityMetrics extends ConsumerWidget {
  final EdgeInsets? padding;
  final bool showTrends;

  const ProductivityMetrics({
    super.key,
    this.padding,
    this.showTrends = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return GlassmorphismContainer(
      level: GlassLevel.background,
      padding: padding ?? StandardizedSpacing.padding(SpacingSize.md),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.chartLine(),
                color: theme.colorScheme.primary,
                size: 24,
              ),
              StandardizedGaps.horizontal(SpacingSize.sm),
              const StandardizedText(
                'Productivity Overview',
                style: StandardizedTextStyle.titleLarge,
              ),
            ],
          ),
          StandardizedGaps.md,
          _buildMetricsGrid(context, theme),
          if (showTrends) ...[
            StandardizedGaps.md,
            _buildTrendsSection(context, theme),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context, ThemeData theme) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: SpacingTokens.sm,
      mainAxisSpacing: SpacingTokens.sm,
      childAspectRatio: 1.5,
      children: [
        AnalyticsMetricCard(
          title: 'Completed Today',
          value: '12',
          subtitle: 'tasks',
          icon: PhosphorIcons.checkCircle(),
          color: context.colors.success,
          trend: '+2',
          isPositiveTrend: true,
        ),
        AnalyticsMetricCard(
          title: 'This Week',
          value: '47',
          subtitle: 'tasks',
          icon: PhosphorIcons.calendar(),
          color: context.colors.info,
          trend: '+8',
          isPositiveTrend: true,
        ),
        AnalyticsMetricCard(
          title: 'Completion Rate',
          value: '85%',
          subtitle: 'weekly avg',
          icon: PhosphorIcons.percent(),
          color: context.colors.warning,
          trend: '+3%',
          isPositiveTrend: true,
        ),
        AnalyticsMetricCard(
          title: 'Focus Time',
          value: '4.2h',
          subtitle: 'daily avg',
          icon: PhosphorIcons.timer(),
          color: theme.colorScheme.secondary,
          trend: '+12m',
          isPositiveTrend: true,
        ),
      ],
    );
  }

  Widget _buildTrendsSection(BuildContext context, ThemeData theme) {
    return Container(
      padding: StandardizedSpacing.padding(SpacingSize.md),
      decoration: BoxDecoration(
        color: context.colors.withSemanticOpacity(
          theme.colorScheme.surfaceContainerHighest,
          SemanticOpacity.subtle,
        ),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StandardizedText(
            'Recent Trends',
            style: StandardizedTextStyle.titleMedium,
          ),
          StandardizedGaps.vertical(SpacingSize.sm),
          _buildTrendItem(
            context,
            theme,
            'Task Completion',
            'Steady improvement over the last 7 days',
            PhosphorIcons.trendUp(),
            context.colors.success,
          ),
          StandardizedGaps.vertical(SpacingSize.sm),
          _buildTrendItem(
            context,
            theme,
            'Focus Sessions',
            'Average session length increased by 15%',
            PhosphorIcons.clockCounterClockwise(),
            context.colors.info,
          ),
        ],
      ),
    );
  }

  Widget _buildTrendItem(
    BuildContext context,
    ThemeData theme,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        StandardizedGaps.horizontal(SpacingSize.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StandardizedText(
                title,
                style: StandardizedTextStyle.bodyMedium,
              ),
              StandardizedText(
                description,
                style: StandardizedTextStyle.bodySmall,
                color: context.colors.withSemanticOpacity(
                  theme.colorScheme.onSurface,
                  SemanticOpacity.strong,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}