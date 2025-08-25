import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/typography_constants.dart';
import '../../../core/design_system/design_tokens.dart' as design_tokens;
import '../standardized_text.dart';
import '../standardized_colors.dart';
import '../../../domain/entities/task_model.dart';
import '../../../domain/models/enums.dart';
import '../glassmorphism_container.dart';
import '../advanced_task_card.dart';

/// Drill-down modal for detailed analytics data exploration
class AnalyticsDrillDownModal extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<TaskModel> tasks;
  final DrillDownData data;
  final VoidCallback? onClose;

  const AnalyticsDrillDownModal({
    super.key,
    required this.title,
    required this.subtitle,
    required this.tasks,
    required this.data,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return SizedBox(
      height: mediaQuery.size.height * 0.8,
      child: GlassmorphismContainer(
        level: design_tokens.GlassLevel.floating,
        padding: EdgeInsets.zero,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(TypographyConstants.radiusLarge),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: TypographyConstants.spacingMedium),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  
                  // Title and close button
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: StandardizedTextStyle.headlineSmall.toTextStyle(context).copyWith(
                                fontSize: TypographyConstants.headlineSmall,
                                fontWeight: TypographyConstants.medium,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: StandardizedTextStyle.bodyMedium.toTextStyle(context).copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: onClose ?? () => Navigator.of(context).pop(),
                        icon: Icon(PhosphorIcons.x()),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: TypographyConstants.spacingMedium),
                  
                  // Summary stats
                  _buildSummaryStats(context, theme),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    // Tab bar
                    TabBar(
                      tabs: [
                        Tab(
                          icon: Icon(PhosphorIcons.list(), size: 16),
                          text: 'Tasks (${tasks.length})',
                        ),
                        Tab(
                          icon: Icon(PhosphorIcons.chartBar(), size: 16),
                          text: 'Metrics',
                        ),
                        Tab(
                          icon: Icon(PhosphorIcons.trendUp(), size: 16),
                          text: 'Insights',
                        ),
                      ],
                      labelStyle: theme.textTheme.labelMedium?.copyWith(
                        fontSize: TypographyConstants.labelMedium,
                      ),
                    ),
                    
                    // Tab content
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildTasksList(context, theme),
                          _buildMetricsView(context, theme),
                          _buildInsightsView(context, theme),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStats(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            theme,
            'Total Tasks',
            tasks.length.toString(),
            PhosphorIcons.listChecks(),
            theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: TypographyConstants.spacingSmall),
        Expanded(
          child: _buildStatCard(
            context,
            theme,
            'Completed',
            tasks.where((t) => t.status.isCompleted).length.toString(),
            PhosphorIcons.checkCircle(),
            design_tokens.DesignSystem.getSemanticColor(context, design_tokens.SemanticColorType.success),
          ),
        ),
        const SizedBox(width: TypographyConstants.spacingSmall),
        Expanded(
          child: _buildStatCard(
            context,
            theme,
            'In Progress',
            tasks.where((t) => t.status.isInProgress).length.toString(),
            PhosphorIcons.playCircle(),
            design_tokens.DesignSystem.getSemanticColor(context, design_tokens.SemanticColorType.info),
          ),
        ),
        const SizedBox(width: TypographyConstants.spacingSmall),
        Expanded(
          child: _buildStatCard(
            context,
            theme,
            'Overdue',
            tasks.where((t) => t.isOverdue).length.toString(),
            PhosphorIcons.warning(),
            design_tokens.DesignSystem.getSemanticColor(context, design_tokens.SemanticColorType.error),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(TypographyConstants.paddingSmall),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: TypographyConstants.medium,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList(BuildContext context, ThemeData theme) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.listChecks(),
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: TypographyConstants.spacingMedium),
            Text(
              'No tasks found',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              'Try adjusting your filters',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
      itemCount: tasks.length,
      separatorBuilder: (context, index) => const SizedBox(height: TypographyConstants.spacingSmall),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return AdvancedTaskCard(
          task: task,
          onTap: () => _showTaskDetails(context, task),
          showProjectInfo: false, // Since we're already in project context
        );
      },
    );
  }

  Widget _buildMetricsView(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetricSection(
            context,
            theme,
            'Priority Distribution',
            PhosphorIcons.arrowUp(),
            _buildPriorityDistribution(context, theme),
          ),
          const SizedBox(height: TypographyConstants.spacingLarge),
          
          _buildMetricSection(
            context,
            theme,
            'Status Distribution',
            PhosphorIcons.chartPie(),
            _buildStatusDistribution(context, theme),
          ),
          const SizedBox(height: TypographyConstants.spacingLarge),
          
          _buildMetricSection(
            context,
            theme,
            'Time Metrics',
            PhosphorIcons.clock(),
            _buildTimeMetrics(context, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsView(BuildContext context, ThemeData theme) {
    final insights = _generateInsights(context);
    
    return ListView.separated(
      padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
      itemCount: insights.length,
      separatorBuilder: (context, index) => const SizedBox(height: TypographyConstants.spacingMedium),
      itemBuilder: (context, index) {
        final insight = insights[index];
        return _buildInsightCard(context, theme, insight);
      },
    );
  }

  Widget _buildMetricSection(
    BuildContext context,
    ThemeData theme,
    String title,
    IconData icon,
    Widget content,
  ) {
    return GlassmorphismContainer(
      level: design_tokens.GlassLevel.whisper,
      padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: TypographyConstants.spacingSmall),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: TypographyConstants.medium,
                ),
              ),
            ],
          ),
          const SizedBox(height: TypographyConstants.spacingMedium),
          content,
        ],
      ),
    );
  }

  Widget _buildPriorityDistribution(BuildContext context, ThemeData theme) {
    final priorities = <TaskPriority, int>{};
    for (final task in tasks) {
      priorities[task.priority] = (priorities[task.priority] ?? 0) + 1;
    }

    return Column(
      children: TaskPriority.values.map((priority) {
        final count = priorities[priority] ?? 0;
        final percentage = tasks.isNotEmpty ? (count / tasks.length) * 100 : 0.0;
        final color = _getPriorityColor(context, priority);

        return Padding(
          padding: const EdgeInsets.only(bottom: TypographyConstants.spacingSmall),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: TypographyConstants.spacingSmall),
              Expanded(
                child: Text(
                  priority.name.toUpperCase(),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              Text(
                '$count (${percentage.toStringAsFixed(1)}%)',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: TypographyConstants.medium,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusDistribution(BuildContext context, ThemeData theme) {
    final statuses = <TaskStatus, int>{};
    for (final task in tasks) {
      statuses[task.status] = (statuses[task.status] ?? 0) + 1;
    }

    return Column(
      children: TaskStatus.values.map((status) {
        final count = statuses[status] ?? 0;
        final percentage = tasks.isNotEmpty ? (count / tasks.length) * 100 : 0.0;
        final color = _getStatusColor(context, status);

        return Padding(
          padding: const EdgeInsets.only(bottom: TypographyConstants.spacingSmall),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: TypographyConstants.spacingSmall),
              Expanded(
                child: Text(
                  status.name.toUpperCase(),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              Text(
                '$count (${percentage.toStringAsFixed(1)}%)',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: TypographyConstants.medium,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimeMetrics(BuildContext context, ThemeData theme) {
    final completedTasks = tasks.where((t) => t.status.isCompleted && t.completedAt != null).toList();
    final tasksWithEstimates = tasks.where((t) => t.estimatedDuration != null).toList();
    final overdueTasks = tasks.where((t) => t.isOverdue).toList();

    final avgCompletionTime = completedTasks.isNotEmpty
        ? Duration(
            milliseconds: completedTasks
                .map((t) => t.completedAt!.difference(t.createdAt).inMilliseconds)
                .reduce((a, b) => a + b) ~/
            completedTasks.length,
          )
        : Duration.zero;

    return Column(
      children: [
        _buildTimeMetric(context, 'Average Completion Time', _formatDuration(avgCompletionTime)),
        _buildTimeMetric(context, 'Total Estimated Hours', _formatEstimatedHours(tasksWithEstimates)),
        _buildTimeMetric(context, 'Overdue Tasks', '${overdueTasks.length} tasks'),
        _buildTimeMetric(context, 'Completion Rate', '${((completedTasks.length / tasks.length) * 100).toStringAsFixed(1)}%'),
      ],
    );
  }

  Widget _buildTimeMetric(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TypographyConstants.spacingSmall),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: TypographyConstants.medium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(BuildContext context, ThemeData theme, DrillDownInsight insight) {
    return GlassmorphismContainer(
      level: design_tokens.GlassLevel.whisper,
      padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                insight.icon,
                size: 20,
                color: insight.color,
              ),
              const SizedBox(width: TypographyConstants.spacingSmall),
              Expanded(
                child: Text(
                  insight.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: TypographyConstants.medium,
                    color: insight.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: TypographyConstants.spacingSmall),
          Text(
            insight.description,
            style: theme.textTheme.bodyMedium,
          ),
          if (insight.actionable) ...[
            const SizedBox(height: TypographyConstants.spacingSmall),
            Text(
              'Recommendation: ${insight.recommendation}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<DrillDownInsight> _generateInsights(BuildContext context) {
    final insights = <DrillDownInsight>[];
    final completedTasks = tasks.where((t) => t.status.isCompleted).toList();
    final overdueTasks = tasks.where((t) => t.isOverdue).toList();
    final highPriorityTasks = tasks.where((t) => t.priority == TaskPriority.high || t.priority == TaskPriority.urgent).toList();

    // Completion rate insight
    final completionRate = tasks.isNotEmpty ? (completedTasks.length / tasks.length) * 100 : 0.0;
    if (completionRate >= 80) {
      insights.add(DrillDownInsight(
        title: 'Excellent Progress',
        description: 'This segment shows ${completionRate.toStringAsFixed(1)}% completion rate, which is excellent!',
        icon: PhosphorIcons.checkCircle(),
        color: design_tokens.DesignSystem.getSemanticColor(context, design_tokens.SemanticColorType.success),
        actionable: false,
      ));
    } else if (completionRate < 50) {
      insights.add(DrillDownInsight(
        title: 'Low Completion Rate',
        description: 'This segment has only ${completionRate.toStringAsFixed(1)}% completion rate.',
        recommendation: 'Consider reviewing task priorities and breaking down complex tasks.',
        icon: PhosphorIcons.warning(),
        color: design_tokens.DesignSystem.getSemanticColor(context, design_tokens.SemanticColorType.warning),
        actionable: true,
      ));
    }

    // Overdue insight
    if (overdueTasks.isNotEmpty) {
      final overduePercentage = (overdueTasks.length / tasks.length) * 100;
      insights.add(DrillDownInsight(
        title: 'Overdue Tasks Alert',
        description: '${overdueTasks.length} tasks (${overduePercentage.toStringAsFixed(1)}%) are overdue.',
        recommendation: 'Focus on completing overdue tasks first or adjust their due dates.',
        icon: PhosphorIcons.clock(),
        color: design_tokens.DesignSystem.getSemanticColor(context, design_tokens.SemanticColorType.error),
        actionable: true,
      ));
    }

    // High priority insight
    if (highPriorityTasks.isNotEmpty) {
      final highPriorityCompleted = highPriorityTasks.where((t) => t.status.isCompleted).length;
      final highPriorityRate = (highPriorityCompleted / highPriorityTasks.length) * 100;
      
      if (highPriorityRate < 70) {
        insights.add(DrillDownInsight(
          title: 'High Priority Tasks Need Attention',
          description: 'Only ${highPriorityRate.toStringAsFixed(1)}% of high priority tasks are completed.',
          recommendation: 'Prioritize high and urgent tasks to improve overall project health.',
          icon: PhosphorIcons.arrowUp(),
          color: design_tokens.DesignSystem.getSemanticColor(context, design_tokens.SemanticColorType.error),
          actionable: true,
        ));
      }
    }

    return insights;
  }

  void _showTaskDetails(BuildContext context, TaskModel task) {
    Navigator.of(context).pushNamed('/task-detail', arguments: task.id);
  }

  Color _getPriorityColor(BuildContext context, TaskPriority priority) {
    final colors = StandardizedColors(Theme.of(context));
    switch (priority) {
      case TaskPriority.urgent:
        return colors.priorityCritical; // Error color for critical priority
      case TaskPriority.high:
        return colors.priorityHigh; // Warning color for high priority  
      case TaskPriority.medium:
        return colors.priorityMedium; // Primary color for medium priority
      case TaskPriority.low:
        return colors.priorityLow; // Outline color for low priority
    }
  }

  Color _getStatusColor(BuildContext context, TaskStatus status) {
    final colors = StandardizedColors(Theme.of(context));
    switch (status) {
      case TaskStatus.pending:
        return colors.statusPending; // Warning color for pending
      case TaskStatus.inProgress:
        return colors.statusInProgress; // Primary color for in progress
      case TaskStatus.completed:
        return colors.statusComplete; // Success color for completed
      case TaskStatus.cancelled:
        return colors.statusCancelled; // Error color for cancelled
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  String _formatEstimatedHours(List<TaskModel> tasks) {
    final totalMinutes = tasks
        .where((t) => t.estimatedDuration != null)
        .fold<int>(0, (sum, task) => sum + task.estimatedDuration!);
    
    if (totalMinutes >= 60) {
      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes % 60;
      return '${hours}h ${minutes}m';
    } else {
      return '${totalMinutes}m';
    }
  }
}

/// Data model for drill-down content
class DrillDownData {
  final String category;
  final Map<String, dynamic> metadata;
  final List<MetricData> metrics;

  const DrillDownData({
    required this.category,
    required this.metadata,
    required this.metrics,
  });
}

/// Data model for individual metrics in drill-down
class MetricData {
  final String name;
  final dynamic value;
  final String? unit;
  final IconData? icon;
  final Color? color;

  const MetricData({
    required this.name,
    required this.value,
    this.unit,
    this.icon,
    this.color,
  });
}

/// Insight data model for drill-down
class DrillDownInsight {
  final String title;
  final String description;
  final String? recommendation;
  final IconData icon;
  final Color color;
  final bool actionable;

  const DrillDownInsight({
    required this.title,
    required this.description,
    this.recommendation,
    required this.icon,
    required this.color,
    this.actionable = false,
  });
}

/// Utility function to show drill-down modal
Future<void> showAnalyticsDrillDown(
  BuildContext context, {
  required String title,
  required String subtitle,
  required List<TaskModel> tasks,
  DrillDownData? data,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AnalyticsDrillDownModal(
      title: title,
      subtitle: subtitle,
      tasks: tasks,
      data: data ?? const DrillDownData(
        category: 'general',
        metadata: {},
        metrics: [],
      ),
    ),
  );
}