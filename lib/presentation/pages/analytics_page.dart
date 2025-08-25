import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/typography_constants.dart';
import '../../core/design_system/design_tokens.dart';
import '../../services/analytics/analytics_models.dart';
import '../providers/analytics_providers.dart';
import '../widgets/analytics_widgets.dart';
import '../widgets/glassmorphism_container.dart';
import '../widgets/standardized_app_bar.dart';
import '../widgets/standardized_text.dart';
import '../widgets/standardized_colors.dart';
import '../widgets/standardized_spacing.dart';
import '../widgets/standardized_error_states.dart';
import '../widgets/task_heatmap_widget.dart';
import '../widgets/theme_background_widget.dart';
import 'detailed_heatmap_page.dart';

/// Analytics page for viewing productivity metrics and insights
class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ThemeBackgroundWidget(
      child: Scaffold(
      backgroundColor: Colors.transparent, // TODO: Use context.colors.backgroundTransparent
      extendBodyBehindAppBar: true, // Show phone status bar
      appBar: StandardizedAppBar.withTertiaryAccent(
        title: 'Analytics',
        forceBackButton: false, // Analytics is main tab - no back button
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.calendarBlank()),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: StandardizedText('Date range selector coming soon!', style: StandardizedTextStyle.bodyMedium),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            tooltip: 'Change date range',
          ),
          IconButton(
            icon: Icon(PhosphorIcons.download()),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: StandardizedText('Export analytics coming soon!', style: StandardizedTextStyle.bodyMedium),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            tooltip: 'Export data',
          ),
        ],
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            top: kToolbarHeight + SpacingTokens.xs, // App bar height + spacing
            left: SpacingTokens.md,
            right: SpacingTokens.md,
            bottom: SpacingTokens.md,
          ),
          child: AnalyticsPageBody(),
        ),
      ),
    ));
  }
}

/// Analytics page body content
class AnalyticsPageBody extends ConsumerWidget {
  const AnalyticsPageBody({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPeriod = ref.watch(analyticsTimePeriodProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time period selector - same width as metric cards
          TimePeriodSelector(
            selectedPeriod: selectedPeriod,
            onPeriodChanged: (period) {
              ref.read(analyticsTimePeriodProvider.notifier).state = period;
            },
          ),

          StandardizedGaps.md,

          // Task Activity Heatmap - First card showing daily completion patterns
          Consumer(
            builder: (context, ref, child) {
              final heatmapAsync = ref.watch(heatmapDataProvider);
              return heatmapAsync.when(
                data: (heatmapData) => TaskHeatmapWidget(
                  dailyStats: heatmapData,
                  title: 'Task Activity Heatmap',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const DetailedHeatmapPage(),
                      ),
                    );
                  },
                ),
                loading: () => GlassmorphismContainer(
                  borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                  padding: StandardizedSpacing.padding(SpacingSize.md),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            PhosphorIcons.calendar(),
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          StandardizedGaps.horizontal(SpacingSize.xs),
                          const StandardizedText(
                            'Task Activity Heatmap',
                            style: StandardizedTextStyle.titleMedium,
                          ),
                        ],
                      ),
                      StandardizedGaps.lg,
                      Center(child: StandardizedErrorStates.loading()),
                      StandardizedGaps.lg,
                    ],
                  ),
                ),
                error: (error, stack) => _ErrorWidget(error: error.toString()),
              );
            },
          ),

          StandardizedGaps.lg,

          // Key metrics
          Consumer(
            builder: (context, ref, child) {
              final summaryAsync = ref.watch(analyticsSummaryProvider);
              final metricsAsync = ref.watch(productivityMetricsProvider);

              return summaryAsync.when(
                data: (summary) => metricsAsync.when(
                  data: (metrics) => Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AnalyticsMetricCard(
                              title: 'Completed',
                              value: '${summary.completedTasks}',
                              subtitle: 'tasks ${selectedPeriod.displayName.toLowerCase()}',
                              icon: PhosphorIcons.checkCircle(),
                              color: context.successColor,
                            ),
                          ),
                          StandardizedGaps.horizontal(SpacingSize.sm),
                          Expanded(
                            child: AnalyticsMetricCard(
                              title: 'Completion Rate',
                              value: '${(summary.completionRate * 100).round()}%',
                              subtitle: 'of all tasks',
                              icon: PhosphorIcons.trendUp(),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      StandardizedGaps.vertical(SpacingSize.sm),
                      Row(
                        children: [
                          Expanded(
                            child: AnalyticsMetricCard(
                              title: 'Current Streak',
                              value: '${summary.currentStreak}',
                              subtitle: 'days active',
                              icon: PhosphorIcons.fire(),
                              color: context.warningColor,
                            ),
                          ),
                          StandardizedGaps.horizontal(SpacingSize.sm),
                          Expanded(
                            child: AnalyticsMetricCard(
                              title: 'Avg Duration',
                              value: _formatDuration(summary.averageTaskDuration),
                              subtitle: 'per task',
                              icon: PhosphorIcons.clock(),
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  loading: () => const _LoadingMetrics(),
                  error: (error, stack) => _ErrorWidget(error: error.toString()),
                ),
                loading: () => const _LoadingMetrics(),
                error: (error, stack) => _ErrorWidget(error: error.toString()),
              );
            },
          ),

          StandardizedGaps.lg,

          // Streak widget
          Consumer(
            builder: (context, ref, child) {
              final streakAsync = ref.watch(streakInfoProvider);
              return streakAsync.when(
                data: (streak) => StreakWidget(streakInfo: streak),
                loading: () => GlassmorphismContainer(
                  borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                  padding: StandardizedSpacing.padding(SpacingSize.md),
                  child: Center(child: StandardizedErrorStates.loading()),
                ),
                error: (error, stack) => _ErrorWidget(error: error.toString()),
              );
            },
          ),

          StandardizedGaps.md,

          // Daily completion chart
          Consumer(
            builder: (context, ref, child) {
              final dailyStatsAsync = ref.watch(dailyStatsProvider);
              return dailyStatsAsync.when(
                data: (dailyStats) {
                  final values = dailyStats.map((stat) => stat.completedTasks.toDouble()).toList();
                  final labels = dailyStats.map((stat) => _formatDateLabel(stat.date)).toList();

                  return SimpleBarChart(
                    values: values,
                    labels: labels,
                    title: 'Daily Task Completion',
                  );
                },
                loading: () => GlassmorphismContainer(
                  borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                  padding: StandardizedSpacing.padding(SpacingSize.md),
                  child: Center(child: StandardizedErrorStates.loading()),
                ),
                error: (error, stack) => _ErrorWidget(error: error.toString()),
              );
            },
          ),

          StandardizedGaps.md,

          // Category breakdown
          Consumer(
            builder: (context, ref, child) {
              final categoryAsync = ref.watch(categoryAnalyticsProvider);
              return categoryAsync.when(
                data: (categories) => CategoryBreakdownWidget(
                  categories: categories,
                  title: 'Task Categories',
                ),
                loading: () => GlassmorphismContainer(
                  borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                  padding: StandardizedSpacing.padding(SpacingSize.md),
                  child: Center(child: StandardizedErrorStates.loading()),
                ),
                error: (error, stack) => _ErrorWidget(error: error.toString()),
              );
            },
          ),

          StandardizedGaps.md,

          // Productivity insights
          Consumer(
            builder: (context, ref, child) {
              final metricsAsync = ref.watch(productivityMetricsProvider);
              final hourlyAsync = ref.watch(hourlyProductivityProvider);
              final weekdayAsync = ref.watch(weekdayProductivityProvider);

              return metricsAsync.when(
                data: (metrics) => hourlyAsync.when(
                  data: (hourly) => weekdayAsync.when(
                    data: (weekday) => ProductivityInsightsWidget(
                      metrics: metrics,
                      hourlyProductivity: hourly,
                      weekdayProductivity: weekday,
                    ),
                    loading: () => GlassmorphismContainer(
                      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                      padding: StandardizedSpacing.padding(SpacingSize.md),
                      child: Center(child: StandardizedErrorStates.loading()),
                    ),
                    error: (error, stack) => _ErrorWidget(error: error.toString()),
                  ),
                  loading: () => GlassmorphismContainer(
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                    padding: StandardizedSpacing.padding(SpacingSize.md),
                    child: Center(child: StandardizedErrorStates.loading()),
                  ),
                  error: (error, stack) => _ErrorWidget(error: error.toString()),
                ),
                loading: () => GlassmorphismContainer(
                  borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                  padding: StandardizedSpacing.padding(SpacingSize.md),
                  child: Center(child: StandardizedErrorStates.loading()),
                ),
                error: (error, stack) => _ErrorWidget(error: error.toString()),
              );
            },
          ),

          StandardizedGaps.md,

          // Advanced analytics sections

          // Productivity patterns
          Consumer(
            builder: (context, ref, child) {
              final patternsAsync = ref.watch(productivityPatternsProvider);
              return patternsAsync.when(
                data: (patterns) => ProductivityPatternsWidget(patterns: patterns),
                loading: () => GlassmorphismContainer(
                  borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                  padding: StandardizedSpacing.padding(SpacingSize.md),
                  child: Center(child: StandardizedErrorStates.loading()),
                ),
                error: (error, stack) => _ErrorWidget(error: error.toString()),
              );
            },
          ),

          StandardizedGaps.md,

          // Peak hours analysis
          Consumer(
            builder: (context, ref, child) {
              final peakHoursAsync = ref.watch(peakHoursAnalysisProvider);
              return peakHoursAsync.when(
                data: (analysis) => PeakHoursAnalysisWidget(analysis: analysis),
                loading: () => GlassmorphismContainer(
                  borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                  padding: StandardizedSpacing.padding(SpacingSize.md),
                  child: Center(child: StandardizedErrorStates.loading()),
                ),
                error: (error, stack) => _ErrorWidget(error: error.toString()),
              );
            },
          ),

          StandardizedGaps.md,

          // Advanced category analytics
          Consumer(
            builder: (context, ref, child) {
              final advancedCategoryAsync = ref.watch(advancedCategoryAnalyticsProvider);
              return advancedCategoryAsync.when(
                data: (analytics) => AdvancedCategoryAnalyticsWidget(analytics: analytics),
                loading: () => GlassmorphismContainer(
                  borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                  padding: StandardizedSpacing.padding(SpacingSize.md),
                  child: Center(child: StandardizedErrorStates.loading()),
                ),
                error: (error, stack) => _ErrorWidget(error: error.toString()),
              );
            },
          ),

          StandardizedGaps.md,

          // Advanced productivity insights
          Consumer(
            builder: (context, ref, child) {
              final insightsAsync = ref.watch(productivityInsightsProvider);
              return insightsAsync.when(
                data: (insights) => AdvancedProductivityInsightsWidget(insights: insights),
                loading: () => GlassmorphismContainer(
                  borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                  padding: StandardizedSpacing.padding(SpacingSize.md),
                  child: Center(child: StandardizedErrorStates.loading()),
                ),
                error: (error, stack) => _ErrorWidget(error: error.toString()),
              );
            },
          ),

          StandardizedGaps.md,

          // Analytics export
          AnalyticsExportWidget(
            onExportJson: () => _exportAnalytics(context, ref, AnalyticsExportFormat.json),
            onExportCsv: () => _exportAnalytics(context, ref, AnalyticsExportFormat.csv),
            onExportPdf: () => _exportAnalytics(context, ref, AnalyticsExportFormat.pdf),
            onExportExcel: () => _exportAnalytics(context, ref, AnalyticsExportFormat.excel),
          ),
        ],
      ),
    );
  }

  String _formatDuration(double minutes) {
    if (minutes < 60) {
      return '${minutes.round()}m';
    } else {
      final hours = minutes / 60;
      return '${hours.toStringAsFixed(1)}h';
    }
  }

  String _formatDateLabel(DateTime date) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[date.weekday - 1];
  }

  Future<void> _exportAnalytics(BuildContext context, WidgetRef ref, AnalyticsExportFormat format) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: StandardizedText('Exporting analytics as ${format.displayName}...', style: StandardizedTextStyle.bodyMedium),
          duration: const Duration(seconds: 2),
        ),
      );

      await ref.read(analyticsExportProvider(format).future);

      // In a real implementation, you would save the file or share it
      // For now, we'll just show a success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: StandardizedText('Analytics exported as ${format.displayName} successfully!', style: StandardizedTextStyle.bodyMedium),
            backgroundColor: context.successColor,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: StandardizedText('Export failed: ${e.toString()}', style: StandardizedTextStyle.bodyMedium),
            backgroundColor: Colors.red, // TODO: Replace with context.colors.error
          ),
        );
      }
    }
  }
}

/// Loading widget for metrics
class _LoadingMetrics extends StatelessWidget {
  const _LoadingMetrics();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GlassmorphismContainer(
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                height: 120,
                padding: StandardizedSpacing.padding(SpacingSize.md),
                child: Center(child: StandardizedErrorStates.loading()),
              ),
            ),
            StandardizedGaps.horizontal(SpacingSize.sm),
            Expanded(
              child: GlassmorphismContainer(
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                height: 120,
                padding: StandardizedSpacing.padding(SpacingSize.md),
                child: Center(child: StandardizedErrorStates.loading()),
              ),
            ),
          ],
        ),
        StandardizedGaps.vertical(SpacingSize.sm),
        Row(
          children: [
            Expanded(
              child: GlassmorphismContainer(
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                height: 120,
                padding: StandardizedSpacing.padding(SpacingSize.md),
                child: Center(child: StandardizedErrorStates.loading()),
              ),
            ),
            StandardizedGaps.horizontal(SpacingSize.sm),
            Expanded(
              child: GlassmorphismContainer(
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                height: 120,
                padding: StandardizedSpacing.padding(SpacingSize.md),
                child: Center(child: StandardizedErrorStates.loading()),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Error widget for analytics
class _ErrorWidget extends StatelessWidget {
  final String error;

  const _ErrorWidget({required this.error});
  @override
  Widget build(BuildContext context) {
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: StandardizedSpacing.padding(SpacingSize.md),
      child: Column(
        children: [
          Icon(
            PhosphorIcons.warningCircle(),
            color: Theme.of(context).colorScheme.error,
            size: 48,
          ),
          StandardizedGaps.vertical(SpacingSize.xs),
          const StandardizedText(
            'Error loading analytics',
            style: StandardizedTextStyle.titleMedium,
          ),
          StandardizedGaps.vertical(SpacingSize.xs),
          StandardizedText(
            error,
            style: StandardizedTextStyle.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
