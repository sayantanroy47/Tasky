import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../domain/models/enums.dart';
import 'standardized_text.dart';
import 'standardized_spacing.dart';
import 'standardized_error_states.dart';

// Stub providers for compilation
final dataExportNotifierProvider = StateNotifierProvider<DataExportNotifier, Object>((ref) {
  return DataExportNotifier();
});

final isExportingProvider = Provider<bool>((ref) => false);

class DataExportNotifier extends StateNotifier<Object> {
  DataExportNotifier() : super(Object());
  
  Future<void> exportData({required ExportFormat format}) async {
    // Stub implementation
    await Future.delayed(const Duration(milliseconds: 100));
  }
  
  Future<void> shareData({required ExportFormat format}) async {
    // Stub implementation
    await Future.delayed(const Duration(milliseconds: 100));
  }
}

/// Temporary minimal analytics widgets to fix compilation errors
/// This file provides basic implementations until full analytics widgets are created

class TimePeriodSelector extends ConsumerWidget {
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;

  const TimePeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periods = ['Week', 'Month', 'Quarter', 'Year'];
    
    return Card(
      child: Padding(
        padding: StandardizedSpacing.padding(SpacingSize.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StandardizedText(
              'Time Period',
              style: StandardizedTextStyle.titleMedium,
            ),
            StandardizedGaps.vertical(SpacingSize.xs),
            SegmentedButton<String>(
              segments: periods.map((period) => ButtonSegment<String>(
                value: period,
                label: StandardizedText(period, style: StandardizedTextStyle.bodyMedium),
              )).toList(),
              selected: {selectedPeriod},
              onSelectionChanged: (Set<String> selection) {
                if (selection.isNotEmpty) {
                  onPeriodChanged(selection.first);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AnalyticsMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final String? subtitle;
  final String? trend;
  final bool? isPositiveTrend;

  const AnalyticsMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.subtitle,
    this.trend,
    this.isPositiveTrend,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: StandardizedSpacing.padding(SpacingSize.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color ?? Theme.of(context).colorScheme.primary),
                StandardizedGaps.horizontal(SpacingSize.xs),
                StandardizedText(title, style: StandardizedTextStyle.titleSmall),
              ],
            ),
            StandardizedGaps.vertical(SpacingSize.xs),
            StandardizedText(
              value,
              style: StandardizedTextStyle.headlineSmall,
              color: color ?? Theme.of(context).colorScheme.primary,
            ),
            if (subtitle != null) ...[
              StandardizedGaps.vertical(SpacingSize.xs),
              StandardizedText(
                subtitle!,
                style: StandardizedTextStyle.bodySmall,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
            if (trend != null) ...[
              StandardizedGaps.vertical(SpacingSize.xs),
              Row(
                children: [
                  Icon(
                    isPositiveTrend == true ? PhosphorIcons.trendUp() : PhosphorIcons.trendDown(),
                    size: 16,
                    color: isPositiveTrend == true ? Colors.green : Colors.red,
                  ),
                  StandardizedGaps.horizontal(SpacingSize.xs),
                  StandardizedText(
                    trend!,
                    style: StandardizedTextStyle.bodySmall,
                    color: isPositiveTrend == true ? Colors.green /* TODO: context.colors.success */ : Colors.red, /* TODO: context.colors.error */
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class StreakWidget extends StatelessWidget {
  final Map<String, dynamic>? streakInfo;
  
  const StreakWidget({
    super.key,
    this.streakInfo,
  });

  @override
  Widget build(BuildContext context) {
    final streak = streakInfo?['current'] ?? 7;
    final longestStreak = streakInfo?['longest'] ?? 12;
    
    return Card(
      child: Padding(
        padding: StandardizedSpacing.padding(SpacingSize.md),
        child: Column(
          children: [
            const StandardizedText(
              'Current Streak',
              style: StandardizedTextStyle.titleMedium,
            ),
            StandardizedGaps.vertical(SpacingSize.xs),
            StandardizedText(
              '$streak days',
              style: StandardizedTextStyle.headlineMedium,
              color: Theme.of(context).colorScheme.primary,
            ),
            StandardizedGaps.vertical(SpacingSize.xs),
            StandardizedText(
              'Longest: $longestStreak days',
              style: StandardizedTextStyle.bodySmall,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class SimpleBarChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final String title;
  
  const SimpleBarChart({
    super.key,
    required this.values,
    required this.labels,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: StandardizedSpacing.padding(SpacingSize.md),
        child: Column(
          children: [
            StandardizedText(
              title,
              style: StandardizedTextStyle.titleMedium,
            ),
            StandardizedGaps.vertical(SpacingSize.md),
            // Simple placeholder for chart
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: StandardizedText(
                  'Chart: ${values.length} data points',
                  style: StandardizedTextStyle.bodyMedium,
                ),
              ),
            ),
            StandardizedGaps.vertical(SpacingSize.xs),
            if (labels.isNotEmpty)
              StandardizedText(
                'Labels: ${labels.join(', ')}',
                style: StandardizedTextStyle.bodySmall,
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}

class CategoryBreakdownWidget extends StatelessWidget {
  const CategoryBreakdownWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: StandardizedSpacing.padding(SpacingSize.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StandardizedText(
              'Category Breakdown',
              style: StandardizedTextStyle.titleMedium,
            ),
            StandardizedGaps.vertical(SpacingSize.md),
            _buildCategoryItem(context, 'Work', 45, Colors.blue),
            _buildCategoryItem(context, 'Personal', 30, Colors.green),
            _buildCategoryItem(context, 'Health', 25, Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, String category, int percentage, Color color) {
    return Padding(
      padding: StandardizedSpacing.paddingSymmetric(vertical: SpacingSize.xs),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          StandardizedText(category, style: StandardizedTextStyle.bodyMedium),
          const Spacer(),
          StandardizedText('$percentage%', style: StandardizedTextStyle.bodyMedium),
        ],
      ),
    );
  }
}

class ProductivityInsightsWidget extends StatelessWidget {
  const ProductivityInsightsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: StandardizedSpacing.padding(SpacingSize.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StandardizedText(
              'Productivity Insights',
              style: StandardizedTextStyle.titleMedium,
            ),
            StandardizedGaps.vertical(SpacingSize.md),
            const StandardizedText(
              '• Your most productive time is 9-11 AM',
              style: StandardizedTextStyle.bodyMedium,
            ),
            StandardizedGaps.vertical(SpacingSize.xs),
            const StandardizedText(
              '• You complete 23% more tasks on Tuesdays',
              style: StandardizedTextStyle.bodyMedium,
            ),
            StandardizedGaps.vertical(SpacingSize.xs),
            const StandardizedText(
              '• Average task completion time: 45 minutes',
              style: StandardizedTextStyle.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class ProductivityPatternsWidget extends StatelessWidget {
  const ProductivityPatternsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: StandardizedSpacing.padding(SpacingSize.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StandardizedText(
              'Productivity Patterns',
              style: StandardizedTextStyle.titleMedium,
            ),
            StandardizedGaps.vertical(SpacingSize.md),
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: StandardizedText(
                  'Pattern Analysis Placeholder',
                  style: StandardizedTextStyle.bodyMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PeakHoursAnalysisWidget extends StatelessWidget {
  const PeakHoursAnalysisWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: StandardizedSpacing.padding(SpacingSize.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StandardizedText(
              'Peak Hours Analysis',
              style: StandardizedTextStyle.titleMedium,
            ),
            StandardizedGaps.vertical(SpacingSize.md),
            Row(
              children: [
                Icon(PhosphorIcons.clock(), color: Theme.of(context).colorScheme.primary),
                StandardizedGaps.horizontal(SpacingSize.xs),
                const StandardizedText('Peak productivity: 9:00 AM - 11:00 AM', style: StandardizedTextStyle.bodyMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AdvancedCategoryAnalyticsWidget extends StatelessWidget {
  final Map<String, dynamic>? analytics;
  
  const AdvancedCategoryAnalyticsWidget({
    super.key,
    this.analytics,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: StandardizedSpacing.padding(SpacingSize.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StandardizedText(
              'Advanced Category Analytics',
              style: StandardizedTextStyle.titleMedium,
            ),
            StandardizedGaps.vertical(SpacingSize.md),
            const StandardizedText(
              'Detailed category performance analysis will be shown here.',
              style: StandardizedTextStyle.bodyMedium,
            ),
            if (analytics != null) ...[
              StandardizedGaps.vertical(SpacingSize.xs),
              StandardizedText(
                'Analytics data: ${analytics!.keys.length} categories',
                style: StandardizedTextStyle.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AdvancedProductivityInsightsWidget extends StatelessWidget {
  final Map<String, dynamic>? insights;
  
  const AdvancedProductivityInsightsWidget({
    super.key,
    this.insights,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: StandardizedSpacing.padding(SpacingSize.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StandardizedText(
              'Advanced Productivity Insights',
              style: StandardizedTextStyle.titleMedium,
            ),
            StandardizedGaps.vertical(SpacingSize.md),
            const StandardizedText(
              'Advanced insights and recommendations will be shown here.',
              style: StandardizedTextStyle.bodyMedium,
            ),
            if (insights != null) ...[
              StandardizedGaps.vertical(SpacingSize.xs),
              StandardizedText(
                'Insights available: ${insights!.keys.length} data points',
                style: StandardizedTextStyle.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AnalyticsExportWidget extends ConsumerWidget {
  final VoidCallback? onExportCsv;
  final VoidCallback? onExportJson;
  final VoidCallback? onExportPdf;
  final VoidCallback? onExportExcel;
  
  const AnalyticsExportWidget({
    super.key,
    this.onExportCsv,
    this.onExportJson,
    this.onExportPdf,
    this.onExportExcel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataExportNotifier = ref.read(dataExportNotifierProvider.notifier);
    final isExporting = ref.watch(isExportingProvider);
    return Card(
      child: Padding(
        padding: StandardizedSpacing.padding(SpacingSize.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StandardizedText(
              'Export Analytics',
              style: StandardizedTextStyle.titleMedium,
            ),
            StandardizedGaps.vertical(SpacingSize.md),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: isExporting ? null : (onExportCsv ?? () async {
                    try {
                      await dataExportNotifier.exportData(format: ExportFormat.csv);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: StandardizedText('Analytics exported to CSV successfully', style: StandardizedTextStyle.bodyMedium),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: StandardizedText('Export failed: $e', style: StandardizedTextStyle.bodyMedium),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }),
                  child: isExporting ? SizedBox(
                    width: 16,
                    height: 16,
                    child: StandardizedErrorStates.loading(),
                  ) : const StandardizedText('Export CSV', style: StandardizedTextStyle.buttonText),
                ),
                ElevatedButton(
                  onPressed: isExporting ? null : (onExportJson ?? () async {
                    try {
                      await dataExportNotifier.exportData(format: ExportFormat.json);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: StandardizedText('Analytics exported to JSON successfully', style: StandardizedTextStyle.bodyMedium),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: StandardizedText('Export failed: $e', style: StandardizedTextStyle.bodyMedium),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }),
                  child: const StandardizedText('Export JSON', style: StandardizedTextStyle.buttonText),
                ),
                ElevatedButton(
                  onPressed: isExporting ? null : (onExportPdf ?? () async {
                    try {
                      await dataExportNotifier.exportData(format: ExportFormat.pdf);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: StandardizedText('Analytics exported to PDF successfully', style: StandardizedTextStyle.bodyMedium),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: StandardizedText('Export failed: $e', style: StandardizedTextStyle.bodyMedium),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }),
                  child: const StandardizedText('Export PDF', style: StandardizedTextStyle.buttonText),
                ),
                ElevatedButton(
                  onPressed: isExporting ? null : (onExportExcel ?? () async {
                    try {
                      await dataExportNotifier.shareData(format: ExportFormat.excel);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: StandardizedText('Analytics shared as Excel successfully', style: StandardizedTextStyle.bodyMedium),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Share failed: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }),
                  child: const StandardizedText('Export Excel', style: StandardizedTextStyle.buttonText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

