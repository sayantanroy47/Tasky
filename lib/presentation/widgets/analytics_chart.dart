import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'charts/line_chart_widget.dart';
import 'charts/bar_chart_widget.dart';
import 'charts/pie_chart_widget.dart';
import 'standardized_text.dart';
import 'standardized_colors.dart';
import 'standardized_spacing.dart';
import 'standardized_error_states.dart';

/// Chart type enumeration
enum ChartType {
  line,
  bar,
  pie,
  donut,
  area,
  doughnut, // Alias for donut
}

/// Analytics chart widget that supports different chart types
class AnalyticsChart extends ConsumerWidget {
  final ChartType type;
  final String? title;
  final List<dynamic>? data;
  final bool isLoading;
  final String? error;

  const AnalyticsChart({
    super.key,
    required this.type,
    this.title,
    this.data,
    this.isLoading = false,
    this.error,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PhosphorIcons.warningCircle(),
              size: 48,
              color: context.colors.error,
            ),
            StandardizedGaps.vertical(SpacingSize.sm),
            StandardizedText(
              error!,
              style: StandardizedTextStyle.bodyMedium,
              color: context.colors.error,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (isLoading) {
      return StandardizedErrorStates.loading();
    }

    switch (type) {
      case ChartType.line:
        return LineChartWidget(
          title: title ?? 'Line Chart',
          icon: PhosphorIcons.trendUp(),
          data: data ?? [],
        );
      case ChartType.bar:
        return BarChartWidget(
          title: title ?? 'Bar Chart',
          icon: PhosphorIcons.chartBar(),
          data: data ?? [],
        );
      case ChartType.pie:
        return PieChartWidget(
          title: title ?? 'Pie Chart',
          icon: PhosphorIcons.chartPie(),
          data: data ?? [],
        );
      case ChartType.donut:
        return PieChartWidget(
          title: title ?? 'Donut Chart',
          icon: PhosphorIcons.chartDonut(),
          data: data ?? [],
        );
      case ChartType.area:
        return LineChartWidget(
          title: title ?? 'Area Chart',
          icon: PhosphorIcons.chartLine(),
          data: data ?? [],
        );
      case ChartType.doughnut:
        return PieChartWidget(
          title: title ?? 'Doughnut Chart',
          icon: PhosphorIcons.chartDonut(),
          data: data ?? [],
        );
    }
  }
}