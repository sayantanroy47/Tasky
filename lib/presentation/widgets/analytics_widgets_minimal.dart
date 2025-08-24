import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../domain/models/enums.dart';

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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time Period',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: periods.map((period) => ButtonSegment<String>(
                value: period,
                label: Text(period),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color ?? Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color ?? Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (trend != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    isPositiveTrend == true ? PhosphorIcons.trendUp() : PhosphorIcons.trendDown(),
                    size: 16,
                    color: isPositiveTrend == true ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    trend!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isPositiveTrend == true ? Colors.green : Colors.red,
                    ),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Current Streak',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '$streak days',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Longest: $longestStreak days',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            // Simple placeholder for chart
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Chart: ${values.length} data points',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (labels.isNotEmpty)
              Text(
                'Labels: ${labels.join(', ')}',
                style: Theme.of(context).textTheme.bodySmall,
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Breakdown',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
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
      padding: const EdgeInsets.symmetric(vertical: 4.0),
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
          Text(category),
          const Spacer(),
          Text('$percentage%'),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Productivity Insights',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text(
              '• Your most productive time is 9-11 AM',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '• You complete 23% more tasks on Tuesdays',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '• Average task completion time: 45 minutes',
              style: Theme.of(context).textTheme.bodyMedium,
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Productivity Patterns',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Pattern Analysis Placeholder',
                  style: Theme.of(context).textTheme.bodyMedium,
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Peak Hours Analysis',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(PhosphorIcons.clock(), color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                const Text('Peak productivity: 9:00 AM - 11:00 AM'),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Advanced Category Analytics',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Detailed category performance analysis will be shown here.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (analytics != null) ...[
              const SizedBox(height: 8),
              Text(
                'Analytics data: ${analytics!.keys.length} categories',
                style: Theme.of(context).textTheme.bodySmall,
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Advanced Productivity Insights',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Advanced insights and recommendations will be shown here.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (insights != null) ...[
              const SizedBox(height: 8),
              Text(
                'Insights available: ${insights!.keys.length} data points',
                style: Theme.of(context).textTheme.bodySmall,
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Analytics',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
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
                            content: Text('Analytics exported to CSV successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Export failed: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }),
                  child: isExporting ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ) : const Text('Export CSV'),
                ),
                ElevatedButton(
                  onPressed: isExporting ? null : (onExportJson ?? () async {
                    try {
                      await dataExportNotifier.exportData(format: ExportFormat.json);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Analytics exported to JSON successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Export failed: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }),
                  child: const Text('Export JSON'),
                ),
                ElevatedButton(
                  onPressed: isExporting ? null : (onExportPdf ?? () async {
                    try {
                      await dataExportNotifier.exportData(format: ExportFormat.pdf);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Analytics exported to PDF successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Export failed: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }),
                  child: const Text('Export PDF'),
                ),
                ElevatedButton(
                  onPressed: isExporting ? null : (onExportExcel ?? () async {
                    try {
                      await dataExportNotifier.shareData(format: ExportFormat.excel);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Analytics shared as Excel successfully'),
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
                  child: const Text('Export Excel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

