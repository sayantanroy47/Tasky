import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/theme_selector.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/analytics_widgets.dart';
import '../providers/analytics_providers.dart';
import '../../services/analytics/analytics_models.dart';

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
    final selectedPeriod = ref.watch(analyticsTimePeriodProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time period selector
          TimePeriodSelector(
            selectedPeriod: selectedPeriod,
            onPeriodChanged: (period) {
              ref.read(analyticsTimePeriodProvider.notifier).state = period;
            },
          ),
          
          const SizedBox(height: 16),
          
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
                              icon: Icons.check_circle,
                              color: Colors.green,
                              trend: _calculateCompletionTrend(metrics),
                              isPositiveTrend: _isPositiveCompletionTrend(metrics),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AnalyticsMetricCard(
                              title: 'Completion Rate',
                              value: '${(summary.completionRate * 100).round()}%',
                              subtitle: 'of all tasks',
                              icon: Icons.trending_up,
                              color: Colors.blue,
                              trend: _calculateRateTrend(metrics),
                              isPositiveTrend: _isPositiveRateTrend(metrics),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: AnalyticsMetricCard(
                              title: 'Current Streak',
                              value: '${summary.currentStreak}',
                              subtitle: 'days active',
                              icon: Icons.local_fire_department,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AnalyticsMetricCard(
                              title: 'Avg Duration',
                              value: _formatDuration(summary.averageTaskDuration),
                              subtitle: 'per task',
                              icon: Icons.schedule,
                              color: Colors.purple,
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
          
          const SizedBox(height: 24),
          
          // Streak widget
          Consumer(
            builder: (context, ref, child) {
              final streakAsync = ref.watch(streakInfoProvider);
              return streakAsync.when(
                data: (streak) => StreakWidget(streakInfo: streak),
                loading: () => const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (error, stack) => _ErrorWidget(error: error.toString()),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
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
                loading: () => const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (error, stack) => _ErrorWidget(error: error.toString()),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Category breakdown
          Consumer(
            builder: (context, ref, child) {
              final categoryAsync = ref.watch(categoryAnalyticsProvider);
              return categoryAsync.when(
                data: (categories) => CategoryBreakdownWidget(
                  categories: categories,
                  title: 'Task Categories',
                ),
                loading: () => const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (error, stack) => _ErrorWidget(error: error.toString()),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
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
                    loading: () => const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                    error: (error, stack) => _ErrorWidget(error: error.toString()),
                  ),
                  loading: () => const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  error: (error, stack) => _ErrorWidget(error: error.toString()),
                ),
                loading: () => const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (error, stack) => _ErrorWidget(error: error.toString()),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Advanced analytics sections
          
          // Productivity patterns
          Consumer(
            builder: (context, ref, child) {
              final patternsAsync = ref.watch(productivityPatternsProvider);
              return patternsAsync.when(
                data: (patterns) => ProductivityPatternsWidget(patterns: patterns),
                loading: () => const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (error, stack) => _ErrorWidget(error: error.toString()),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Peak hours analysis
          Consumer(
            builder: (context, ref, child) {
              final peakHoursAsync = ref.watch(peakHoursAnalysisProvider);
              return peakHoursAsync.when(
                data: (analysis) => PeakHoursAnalysisWidget(analysis: analysis),
                loading: () => const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (error, stack) => _ErrorWidget(error: error.toString()),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Advanced category analytics
          Consumer(
            builder: (context, ref, child) {
              final advancedCategoryAsync = ref.watch(advancedCategoryAnalyticsProvider);
              return advancedCategoryAsync.when(
                data: (analytics) => AdvancedCategoryAnalyticsWidget(analytics: analytics),
                loading: () => const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (error, stack) => _ErrorWidget(error: error.toString()),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Advanced productivity insights
          Consumer(
            builder: (context, ref, child) {
              final insightsAsync = ref.watch(productivityInsightsProvider);
              return insightsAsync.when(
                data: (insights) => AdvancedProductivityInsightsWidget(insights: insights),
                loading: () => const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (error, stack) => _ErrorWidget(error: error.toString()),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
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

  String? _calculateCompletionTrend(ProductivityMetrics metrics) {
    if (metrics.weeklyTrend.length >= 2) {
      final current = metrics.weeklyTrend.last;
      final previous = metrics.weeklyTrend[metrics.weeklyTrend.length - 2];
      final diff = current - previous;
      if (diff != 0) {
        return '${diff > 0 ? '+' : ''}$diff';
      }
    }
    return null;
  }

  bool? _isPositiveCompletionTrend(ProductivityMetrics metrics) {
    if (metrics.weeklyTrend.length >= 2) {
      final current = metrics.weeklyTrend.last;
      final previous = metrics.weeklyTrend[metrics.weeklyTrend.length - 2];
      return current > previous;
    }
    return null;
  }

  String? _calculateRateTrend(ProductivityMetrics metrics) {
    final weeklyRate = (metrics.weeklyCompletionRate * 100).round();
    final monthlyRate = (metrics.monthlyCompletionRate * 100).round();
    final diff = weeklyRate - monthlyRate;
    if (diff != 0) {
      return '${diff > 0 ? '+' : ''}${diff}%';
    }
    return null;
  }

  bool? _isPositiveRateTrend(ProductivityMetrics metrics) {
    return metrics.weeklyCompletionRate > metrics.monthlyCompletionRate;
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
          content: Text('Exporting analytics as ${format.displayName}...'),
          duration: const Duration(seconds: 2),
        ),
      );

      final exportData = await ref.read(analyticsExportProvider(format).future);
      
      // In a real implementation, you would save the file or share it
      // For now, we'll just show a success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analytics exported as ${format.displayName} successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: ${e.toString()}'),
            backgroundColor: Colors.red,
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
              child: Card(
                child: Container(
                  height: 120,
                  padding: const EdgeInsets.all(16.0),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Card(
                child: Container(
                  height: 120,
                  padding: const EdgeInsets.all(16.0),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Card(
                child: Container(
                  height: 120,
                  padding: const EdgeInsets.all(16.0),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Card(
                child: Container(
                  height: 120,
                  padding: const EdgeInsets.all(16.0),
                  child: const Center(child: CircularProgressIndicator()),
                ),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              'Error loading analytics',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              error,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

