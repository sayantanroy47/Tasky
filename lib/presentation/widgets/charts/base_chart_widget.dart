import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/design_system/design_tokens.dart';
import '../../../core/theme/typography_constants.dart';
import '../glassmorphism_container.dart';
import '../standardized_text.dart';
import '../standardized_colors.dart';

/// Base widget for all chart components with consistent styling
abstract class BaseChartWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? accentColor;
  final VoidCallback? onTap;
  final Widget? trailing;
  final EdgeInsets? padding;
  final bool isLoading;
  final String? error;

  const BaseChartWidget({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.accentColor,
    this.onTap,
    this.trailing,
    this.padding,
    this.isLoading = false,
    this.error,
  });

  /// Build the chart content - to be implemented by subclasses
  Widget buildChart(BuildContext context);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveAccentColor = accentColor ?? theme.colorScheme.primary;

    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: padding ?? const EdgeInsets.all(TypographyConstants.paddingMedium),
      margin: const EdgeInsets.only(bottom: TypographyConstants.spacingMedium),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusMedium),
      child: Material(
        color: context.colors.backgroundTransparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TypographyConstants.radiusMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: effectiveAccentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: effectiveAccentColor,
                    ),
                  ),
                  const SizedBox(width: TypographyConstants.spacingSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: StandardizedTextStyle.titleMedium.toTextStyle(context).copyWith(
                            fontSize: TypographyConstants.titleMedium,
                            fontWeight: TypographyConstants.medium,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: StandardizedTextStyle.bodySmall.toTextStyle(context).copyWith(
                              fontSize: TypographyConstants.bodySmall,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) trailing!,
                  if (onTap != null) ...[
                    const SizedBox(width: 8),
                    Icon(
                      PhosphorIcons.caretRight(),
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ],
              ),

              const SizedBox(height: TypographyConstants.spacingMedium),

              // Chart content
              if (error != null)
                _buildError(context)
              else if (isLoading)
                _buildLoading(context)
              else
                buildChart(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.warningCircle(),
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 8),
            Text(
              'Error loading chart',
              style: StandardizedTextStyle.titleSmall.toTextStyle(context).copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              error!,
              style: StandardizedTextStyle.bodySmall.toTextStyle(context).copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading chart...',
              style: StandardizedTextStyle.bodyMedium.toTextStyle(context).copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chart data point for line/bar charts
class ChartDataPoint {
  final String label;
  final double value;
  final Color? color;
  final Map<String, dynamic>? metadata;

  const ChartDataPoint({
    required this.label,
    required this.value,
    this.color,
    this.metadata,
  });
}

/// Time-series chart data point
class TimeSeriesDataPoint {
  final DateTime date;
  final double value;
  final Color? color;
  final Map<String, dynamic>? metadata;

  const TimeSeriesDataPoint({
    required this.date,
    required this.value,
    this.color,
    this.metadata,
  });
}

/// Chart interaction callback
typedef ChartInteractionCallback = void Function(dynamic data);

/// Chart type for switching between different visualizations
enum ChartType { line, bar, pie, donut, area }

/// Chart time period for filtering
enum ChartTimePeriod { 
  last7Days('Last 7 days'), 
  last30Days('Last 30 days'), 
  last3Months('Last 3 months'), 
  allTime('All time');

  const ChartTimePeriod(this.displayName);
  final String displayName;
}