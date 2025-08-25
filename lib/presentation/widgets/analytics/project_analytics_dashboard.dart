import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/design_system/design_tokens.dart';
import '../../../core/theme/typography_constants.dart';
import '../../../domain/entities/project.dart';
import '../../../domain/models/enums.dart';
import '../../../services/analytics/project_analytics_service.dart';
import '../../providers/project_analytics_providers.dart';
import '../glassmorphism_container.dart';
import '../standardized_text.dart';
import '../charts/base_chart_widget.dart';
import '../charts/line_chart_widget.dart';
import '../charts/pie_chart_widget.dart';
import '../charts/chart_controls_widget.dart';
import '../charts/analytics_drill_down.dart';

/// Comprehensive project analytics dashboard widget
class ProjectAnalyticsDashboard extends ConsumerStatefulWidget {
  final Project project;

  const ProjectAnalyticsDashboard({
    super.key,
    required this.project,
  });

  @override
  ConsumerState<ProjectAnalyticsDashboard> createState() => _ProjectAnalyticsDashboardState();
}

class _ProjectAnalyticsDashboardState extends ConsumerState<ProjectAnalyticsDashboard> {
  ChartTimePeriod _selectedPeriod = ChartTimePeriod.last30Days;
  ChartType _selectedChartType = ChartType.line;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final analyticsAsync = ref.watch(projectAnalyticsProvider(AnalyticsRequest(
      projectId: widget.project.id,
      period: _selectedPeriod.toTimePeriod(),
    )));

    return analyticsAsync.when(
      data: (analytics) => _buildDashboardContent(context, theme, analytics),
      loading: () => _buildLoadingState(context, theme),
      error: (error, stackTrace) => _buildErrorState(context, theme, error.toString()),
    );
  }

  Widget _buildDashboardContent(BuildContext context, ThemeData theme, ProjectAnalytics analytics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dashboard header with controls
          _buildDashboardHeader(context, theme, analytics),
          
          const SizedBox(height: TypographyConstants.spacingLarge),
          
          // Key metrics overview
          _buildKeyMetricsSection(context, theme, analytics),
          
          const SizedBox(height: TypographyConstants.spacingLarge),
          
          // Progress charts section
          _buildProgressChartsSection(context, theme, analytics),
          
          const SizedBox(height: TypographyConstants.spacingLarge),
          
          // Performance insights section
          _buildPerformanceSection(context, theme, analytics),
          
          const SizedBox(height: TypographyConstants.spacingLarge),
          
          // Risk and milestone section
          _buildRiskAndMilestoneSection(context, theme, analytics),
          
          const SizedBox(height: TypographyConstants.spacingXLarge), // Extra space for FAB
        ],
      ),
    );
  }

  Widget _buildDashboardHeader(BuildContext context, ThemeData theme, ProjectAnalytics analytics) {
    return GlassmorphismContainer(
      level: GlassLevel.background,
      padding: const EdgeInsets.all(TypographyConstants.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(TypographyConstants.radiusMedium),
                ),
                child: Icon(
                  PhosphorIcons.chartBar(),
                  size: 28,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: TypographyConstants.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Project Analytics',
                      style: StandardizedTextStyle.headlineMedium.toTextStyle(context).copyWith(
                        fontSize: TypographyConstants.headlineMedium,
                        fontWeight: TypographyConstants.medium,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_selectedPeriod.displayName} • Updated ${_formatLastUpdated(DateTime.now())}',
                      style: StandardizedTextStyle.bodyMedium.toTextStyle(context).copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Export button
              IconButton(
                onPressed: () => _showExportOptions(context, analytics),
                icon: Icon(PhosphorIcons.export()),
                tooltip: 'Export Analytics',
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  foregroundColor: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: TypographyConstants.spacingLarge),
          
          // Chart controls
          ChartControlsWidget(
            selectedPeriod: _selectedPeriod,
            selectedChartType: _selectedChartType,
            onPeriodChanged: (period) {
              setState(() {
                _selectedPeriod = period;
              });
            },
            onChartTypeChanged: (type) {
              setState(() {
                _selectedChartType = type;
              });
            },
            onExport: () => _showExportOptions(context, analytics),
            onRefresh: () => ref.invalidate(projectAnalyticsProvider),
            availableChartTypes: const [ChartType.line, ChartType.bar, ChartType.area],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetricsSection(BuildContext context, ThemeData theme, ProjectAnalytics analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Metrics',
          style: StandardizedTextStyle.titleLarge.toTextStyle(context).copyWith(
            fontSize: TypographyConstants.titleLarge,
            fontWeight: TypographyConstants.medium,
          ),
        ),
        const SizedBox(height: TypographyConstants.spacingMedium),
        
        // Metrics grid
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            return isWide 
              ? _buildWideMetricsGrid(context, theme, analytics)
              : _buildCompactMetricsGrid(context, theme, analytics);
          },
        ),
      ],
    );
  }

  Widget _buildWideMetricsGrid(BuildContext context, ThemeData theme, ProjectAnalytics analytics) {
    return Row(
      children: [
        Expanded(
          child: _buildHealthScoreCard(context, theme, analytics),
        ),
        const SizedBox(width: TypographyConstants.spacingMedium),
        Expanded(
          child: _buildVelocityCard(context, theme, analytics),
        ),
        const SizedBox(width: TypographyConstants.spacingMedium),
        Expanded(
          child: _buildCompletionCard(context, theme, analytics),
        ),
        const SizedBox(width: TypographyConstants.spacingMedium),
        Expanded(
          child: _buildRiskCard(context, theme, analytics),
        ),
      ],
    );
  }

  Widget _buildCompactMetricsGrid(BuildContext context, ThemeData theme, ProjectAnalytics analytics) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildHealthScoreCard(context, theme, analytics)),
            const SizedBox(width: TypographyConstants.spacingMedium),
            Expanded(child: _buildVelocityCard(context, theme, analytics)),
          ],
        ),
        const SizedBox(height: TypographyConstants.spacingMedium),
        Row(
          children: [
            Expanded(child: _buildCompletionCard(context, theme, analytics)),
            const SizedBox(width: TypographyConstants.spacingMedium),
            Expanded(child: _buildRiskCard(context, theme, analytics)),
          ],
        ),
      ],
    );
  }

  Widget _buildHealthScoreCard(BuildContext context, ThemeData theme, ProjectAnalytics analytics) {
    final healthScore = analytics.healthScore;
    final healthColor = _getHealthColor(healthScore, theme.colorScheme);
    final healthStatus = _getHealthStatus(healthScore);

    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.heartbeat(),
                size: 20,
                color: healthColor,
              ),
              const SizedBox(width: TypographyConstants.spacingSmall),
              Text(
                'Health Score',
                style: StandardizedTextStyle.labelLarge.toTextStyle(context).copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: TypographyConstants.spacingSmall),
          Text(
            '${(healthScore * 100).round()}%',
            style: StandardizedTextStyle.headlineMedium.toTextStyle(context).copyWith(
              color: healthColor,
              fontWeight: TypographyConstants.medium,
            ),
          ),
          Text(
            healthStatus,
            style: StandardizedTextStyle.bodySmall.toTextStyle(context).copyWith(
              color: healthColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVelocityCard(BuildContext context, ThemeData theme, ProjectAnalytics analytics) {
    final velocity = analytics.velocityData.averageTasksPerDay;
    final trend = analytics.velocityData.trend;
    final trendColor = _getTrendColor(trend);
    final trendIcon = _getTrendIcon(trend);

    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.speedometer(),
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: TypographyConstants.spacingSmall),
              Text(
                'Velocity',
                style: StandardizedTextStyle.labelLarge.toTextStyle(context).copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: TypographyConstants.spacingSmall),
          Text(
            '${velocity.toStringAsFixed(1)} tasks/day',
            style: StandardizedTextStyle.titleLarge.toTextStyle(context).copyWith(
              fontWeight: TypographyConstants.medium,
            ),
          ),
          Row(
            children: [
              Icon(trendIcon, size: 14, color: trendColor),
              const SizedBox(width: 4),
              Text(
                trend.name.toUpperCase(),
                style: StandardizedTextStyle.bodySmall.toTextStyle(context).copyWith(
                  color: trendColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionCard(BuildContext context, ThemeData theme, ProjectAnalytics analytics) {
    final completionRate = analytics.performanceData.onTimeCompletionRate;
    final predictedDate = analytics.predictedCompletionDate;

    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.target(),
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: TypographyConstants.spacingSmall),
              Text(
                'On-Time Rate',
                style: StandardizedTextStyle.labelLarge.toTextStyle(context).copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: TypographyConstants.spacingSmall),
          Text(
            '${(completionRate * 100).round()}%',
            style: StandardizedTextStyle.titleLarge.toTextStyle(context).copyWith(
              fontWeight: TypographyConstants.medium,
            ),
          ),
          if (predictedDate != null)
            Text(
              'ETC: ${_formatDate(predictedDate)}',
              style: StandardizedTextStyle.bodySmall.toTextStyle(context).copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRiskCard(BuildContext context, ThemeData theme, ProjectAnalytics analytics) {
    final riskLevel = analytics.riskData.riskLevel;
    final riskColor = _getRiskColor(riskLevel);
    final riskStatus = _getRiskStatus(riskLevel);
    final overdueTasks = analytics.riskData.overdueTasksRatio;

    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.warning(),
                size: 20,
                color: riskColor,
              ),
              const SizedBox(width: TypographyConstants.spacingSmall),
              Text(
                'Risk Level',
                style: StandardizedTextStyle.labelLarge.toTextStyle(context).copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: TypographyConstants.spacingSmall),
          Text(
            riskStatus,
            style: StandardizedTextStyle.titleLarge.toTextStyle(context).copyWith(
              color: riskColor,
              fontWeight: TypographyConstants.medium,
            ),
          ),
          if (overdueTasks > 0)
            Text(
              '${(overdueTasks * 100).round()}% overdue',
              style: StandardizedTextStyle.bodySmall.toTextStyle(context).copyWith(
                color: riskColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressChartsSection(BuildContext context, ThemeData theme, ProjectAnalytics analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress Tracking',
          style: StandardizedTextStyle.titleLarge.toTextStyle(context).copyWith(
            fontSize: TypographyConstants.titleLarge,
            fontWeight: TypographyConstants.medium,
          ),
        ),
        const SizedBox(height: TypographyConstants.spacingMedium),
        
        // Main progress chart
        _buildProgressChart(context, theme, analytics),
        
        const SizedBox(height: TypographyConstants.spacingMedium),
        
        // Burndown and distribution charts
        Row(
          children: [
            Expanded(
              child: _buildBurndownChart(context, theme, analytics),
            ),
            const SizedBox(width: TypographyConstants.spacingMedium),
            Expanded(
              child: _buildDistributionChart(context, theme, analytics),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressChart(BuildContext context, ThemeData theme, ProjectAnalytics analytics) {
    final progressData = analytics.progressData.dailyProgress.map((point) =>
      TimeSeriesDataPoint(
        date: point.date,
        value: point.completionPercentage * 100,
        metadata: {
          'completedTasks': point.completedTasks,
          'totalTasks': point.totalTasks,
          'velocity': point.velocity,
        },
      ),
    ).toList();

    return LineChartWidget(
      title: 'Progress Over Time',
      subtitle: '${_selectedPeriod.displayName} completion percentage',
      icon: PhosphorIcons.trendUp(),
      accentColor: _parseColor(widget.project.color),
      data: progressData,
      fillArea: true,
      onPointTap: (point) => _showProgressDrillDown(context, point, analytics),
      onTap: () => _showDetailedProgressAnalysis(context, analytics),
    );
  }

  Widget _buildBurndownChart(BuildContext context, ThemeData theme, ProjectAnalytics analytics) {
    final burndownData = analytics.progressData.burndownData.map((point) =>
      TimeSeriesDataPoint(
        date: point.date,
        value: point.remainingWork.toDouble(),
        metadata: {
          'idealBurndown': point.idealBurndown,
          'remainingWork': point.remainingWork,
        },
      ),
    ).toList();

    return LineChartWidget(
      title: 'Burndown Chart',
      subtitle: 'Remaining work vs ideal',
      icon: PhosphorIcons.chartLineDown(),
      accentColor: theme.colorScheme.secondary,
      data: burndownData,
      onPointTap: (point) => _showBurndownDrillDown(context, point, analytics),
    );
  }

  Widget _buildDistributionChart(BuildContext context, ThemeData theme, ProjectAnalytics analytics) {
    final distributionData = analytics.distributionData.byStatus.entries.map((entry) =>
      ChartDataPoint(
        label: entry.key.name.toUpperCase(),
        value: entry.value.toDouble(),
        color: _getStatusColor(entry.key),
      ),
    ).toList();

    return PieChartWidget(
      title: 'Task Distribution',
      subtitle: 'By status',
      icon: PhosphorIcons.chartPie(),
      data: distributionData,
      isDonut: true,
      centerWidget: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${analytics.basicStats.totalTasks}',
            style: StandardizedTextStyle.headlineMedium.toTextStyle(context).copyWith(
              fontWeight: TypographyConstants.medium,
            ),
          ),
          Text(
            'Total Tasks',
            style: StandardizedTextStyle.bodySmall.toTextStyle(context).copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      onSliceTap: (slice) => _showStatusDrillDown(context, slice, analytics),
    );
  }

  Widget _buildPerformanceSection(BuildContext context, ThemeData theme, ProjectAnalytics analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Insights',
          style: StandardizedTextStyle.titleLarge.toTextStyle(context).copyWith(
            fontSize: TypographyConstants.titleLarge,
            fontWeight: TypographyConstants.medium,
          ),
        ),
        const SizedBox(height: TypographyConstants.spacingMedium),
        
        // Performance metrics cards
        _buildPerformanceMetrics(context, theme, analytics),
        
        const SizedBox(height: TypographyConstants.spacingMedium),
        
        // Bottlenecks and insights
        if (analytics.performanceData.bottlenecks.isNotEmpty)
          _buildBottlenecksCard(context, theme, analytics),
      ],
    );
  }

  Widget _buildPerformanceMetrics(BuildContext context, ThemeData theme, ProjectAnalytics analytics) {
    final performance = analytics.performanceData;
    
    return Row(
      children: [
        Expanded(
          child: GlassmorphismContainer(
            level: GlassLevel.content,
            padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(PhosphorIcons.clock(), size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Avg Completion Time',
                      style: StandardizedTextStyle.labelMedium.toTextStyle(context).copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDuration(performance.averageCompletionTime),
                  style: StandardizedTextStyle.titleMedium.toTextStyle(context).copyWith(
                    fontWeight: TypographyConstants.medium,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: TypographyConstants.spacingMedium),
        Expanded(
          child: GlassmorphismContainer(
            level: GlassLevel.content,
            padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(PhosphorIcons.target(), size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Estimation Accuracy',
                      style: StandardizedTextStyle.labelMedium.toTextStyle(context).copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${(performance.estimationAccuracy * 100).round()}%',
                  style: StandardizedTextStyle.titleMedium.toTextStyle(context).copyWith(
                    fontWeight: TypographyConstants.medium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottlenecksCard(BuildContext context, ThemeData theme, ProjectAnalytics analytics) {
    final bottlenecks = analytics.performanceData.bottlenecks;
    
    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.warning(),
                size: 20,
                color: theme.colorScheme.tertiary,
              ),
              const SizedBox(width: TypographyConstants.spacingSmall),
              Text(
                'Identified Bottlenecks',
                style: StandardizedTextStyle.titleMedium.toTextStyle(context).copyWith(
                  fontWeight: TypographyConstants.medium,
                ),
              ),
            ],
          ),
          const SizedBox(height: TypographyConstants.spacingMedium),
          ...bottlenecks.take(3).map((bottleneck) => Padding(
            padding: const EdgeInsets.only(bottom: TypographyConstants.spacingSmall),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getBottleneckColor(bottleneck.severity),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: TypographyConstants.spacingSmall),
                Expanded(
                  child: Text(
                    bottleneck.description,
                    style: StandardizedTextStyle.bodyMedium.toTextStyle(context),
                  ),
                ),
                Text(
                  bottleneck.severity.name.toUpperCase(),
                  style: StandardizedTextStyle.labelSmall.toTextStyle(context).copyWith(
                    color: _getBottleneckColor(bottleneck.severity),
                    fontWeight: TypographyConstants.medium,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildRiskAndMilestoneSection(BuildContext context, ThemeData theme, ProjectAnalytics analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Milestones & Risk',
          style: StandardizedTextStyle.titleLarge.toTextStyle(context).copyWith(
            fontSize: TypographyConstants.titleLarge,
            fontWeight: TypographyConstants.medium,
          ),
        ),
        const SizedBox(height: TypographyConstants.spacingMedium),
        
        Row(
          children: [
            Expanded(
              child: _buildMilestonesCard(context, theme, analytics),
            ),
            const SizedBox(width: TypographyConstants.spacingMedium),
            Expanded(
              child: _buildRiskIndicatorsCard(context, theme, analytics),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMilestonesCard(BuildContext context, ThemeData theme, ProjectAnalytics analytics) {
    final milestones = analytics.milestoneData;
    
    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.flagBanner(),
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: TypographyConstants.spacingSmall),
              Text(
                'Milestones',
                style: StandardizedTextStyle.titleMedium.toTextStyle(context).copyWith(
                  fontWeight: TypographyConstants.medium,
                ),
              ),
            ],
          ),
          const SizedBox(height: TypographyConstants.spacingMedium),
          
          _buildMilestoneMetric('Total', milestones.totalMilestones.toString()),
          _buildMilestoneMetric('Completed', milestones.completedMilestones.toString()),
          _buildMilestoneMetric('Upcoming', milestones.upcomingMilestones.toString()),
          
          if (milestones.totalMilestones > 0) ...[
            const SizedBox(height: TypographyConstants.spacingSmall),
            LinearProgressIndicator(
              value: milestones.completedMilestones / milestones.totalMilestones,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMilestoneMetric(String label, String value) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: StandardizedTextStyle.bodyMedium.toTextStyle(context).copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: StandardizedTextStyle.bodyMedium.toTextStyle(context).copyWith(
              fontWeight: TypographyConstants.medium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskIndicatorsCard(BuildContext context, ThemeData theme, ProjectAnalytics analytics) {
    final risk = analytics.riskData;
    
    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.shieldWarning(),
                size: 20,
                color: _getRiskColor(risk.riskLevel),
              ),
              const SizedBox(width: TypographyConstants.spacingSmall),
              Text(
                'Risk Indicators',
                style: StandardizedTextStyle.titleMedium.toTextStyle(context).copyWith(
                  fontWeight: TypographyConstants.medium,
                ),
              ),
            ],
          ),
          const SizedBox(height: TypographyConstants.spacingMedium),
          
          if (risk.upcomingDeadlines > 0)
            _buildRiskIndicator(
              'Upcoming Deadlines',
              '${risk.upcomingDeadlines} tasks',
              theme.colorScheme.tertiary,
            ),
          
          if (risk.overdueTasksRatio > 0)
            _buildRiskIndicator(
              'Overdue Tasks',
              '${(risk.overdueTasksRatio * 100).round()}%',
              theme.colorScheme.error,
            ),
          
          if (risk.highPriorityPendingTasks > 0)
            _buildRiskIndicator(
              'High Priority Pending',
              '${risk.highPriorityPendingTasks} tasks',
              theme.colorScheme.secondary,
            ),
          
          if (risk.blockageRisk > 0.3)
            _buildRiskIndicator(
              'Blocked Tasks',
              '${(risk.blockageRisk * 100).round()}%',
              theme.colorScheme.tertiaryContainer,
            ),
        ],
      ),
    );
  }

  Widget _buildRiskIndicator(String label, String value, Color color) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: TypographyConstants.spacingSmall),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: TypographyConstants.spacingSmall),
          Expanded(
            child: Text(
              label,
              style: StandardizedTextStyle.bodyMedium.toTextStyle(context).copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: StandardizedTextStyle.bodyMedium.toTextStyle(context).copyWith(
              color: color,
              fontWeight: TypographyConstants.medium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(TypographyConstants.paddingXLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(_parseColor(widget.project.color)),
          ),
          const SizedBox(height: TypographyConstants.spacingLarge),
          Text(
            'Loading Analytics...',
            style: StandardizedTextStyle.titleMedium.toTextStyle(context).copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: TypographyConstants.spacingSmall),
          Text(
            'Calculating project insights and metrics',
            style: StandardizedTextStyle.bodyMedium.toTextStyle(context).copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ThemeData theme, String error) {
    return Container(
      padding: const EdgeInsets.all(TypographyConstants.paddingXLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.warningCircle(),
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: TypographyConstants.spacingLarge),
          Text(
            'Analytics Unavailable',
            style: StandardizedTextStyle.titleLarge.toTextStyle(context).copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: TypographyConstants.spacingSmall),
          Text(
            error,
            style: StandardizedTextStyle.bodyMedium.toTextStyle(context).copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TypographyConstants.spacingLarge),
          ElevatedButton.icon(
            onPressed: () => ref.invalidate(projectAnalyticsProvider),
            icon: Icon(PhosphorIcons.arrowClockwise()),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Event handlers and drill-down methods
  void _showExportOptions(BuildContext context, ProjectAnalytics analytics) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ExportOptionsSheet(
        project: widget.project,
        analytics: analytics,
      ),
    );
  }

  void _showProgressDrillDown(BuildContext context, TimeSeriesDataPoint point, ProjectAnalytics analytics) {
    // Get tasks completed on this date
    final completedTasks = analytics.progressData.dailyProgress
        .firstWhere((p) => p.date == point.date, orElse: () => 
          ProgressPoint(date: point.date, completedTasks: 0, totalTasks: 0, completionPercentage: 0, velocity: 0))
        .completedTasks;
    
    showAnalyticsDrillDown(
      context,
      title: 'Progress on ${_formatDate(point.date)}',
      subtitle: '${point.value.round()}% completion • $completedTasks tasks completed',
      tasks: [], // TODO: Get actual tasks for this date
    );
  }

  void _showBurndownDrillDown(BuildContext context, TimeSeriesDataPoint point, ProjectAnalytics analytics) {
    showAnalyticsDrillDown(
      context,
      title: 'Burndown Analysis',
      subtitle: '${point.value.round()} tasks remaining on ${_formatDate(point.date)}',
      tasks: [], // TODO: Get remaining tasks for this date
    );
  }

  void _showStatusDrillDown(BuildContext context, ChartDataPoint slice, ProjectAnalytics analytics) {
    showAnalyticsDrillDown(
      context,
      title: '${slice.label} Tasks',
      subtitle: '${slice.value.round()} tasks in ${slice.label.toLowerCase()} status',
      tasks: [], // TODO: Get tasks with this status
    );
  }

  void _showDetailedProgressAnalysis(BuildContext context, ProjectAnalytics analytics) {
    // Show detailed progress analysis modal
    // TODO: Implement detailed progress analysis view
  }

  // Helper methods
  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Theme.of(context).colorScheme.primary;
    }
  }

  Color _getHealthColor(double healthScore, ColorScheme colorScheme) {
    if (healthScore >= 0.8) return colorScheme.primary;
    if (healthScore >= 0.6) return colorScheme.secondary;
    if (healthScore >= 0.4) return colorScheme.tertiary;
    return colorScheme.error;
  }

  String _getHealthStatus(double healthScore) {
    if (healthScore >= 0.8) return 'Excellent';
    if (healthScore >= 0.6) return 'Good';
    if (healthScore >= 0.4) return 'Fair';
    return 'Needs Attention';
  }

  Color _getTrendColor(VelocityTrend trend) {
    final theme = Theme.of(context);
    switch (trend) {
      case VelocityTrend.increasing:
        return theme.colorScheme.tertiary; // Success/positive trend
      case VelocityTrend.stable:
        return theme.colorScheme.primary;
      case VelocityTrend.decreasing:
        return theme.colorScheme.error;
    }
  }

  IconData _getTrendIcon(VelocityTrend trend) {
    switch (trend) {
      case VelocityTrend.increasing:
        return PhosphorIcons.trendUp();
      case VelocityTrend.stable:
        return PhosphorIcons.minus();
      case VelocityTrend.decreasing:
        return PhosphorIcons.trendDown();
    }
  }

  Color _getRiskColor(double riskLevel) {
    final theme = Theme.of(context);
    if (riskLevel >= 0.7) return theme.colorScheme.error;
    if (riskLevel >= 0.4) return theme.colorScheme.onTertiaryContainer; // Warning state
    return theme.colorScheme.tertiary; // Low risk/success state
  }

  String _getRiskStatus(double riskLevel) {
    if (riskLevel >= 0.7) return 'High Risk';
    if (riskLevel >= 0.4) return 'Medium Risk';
    return 'Low Risk';
  }

  Color _getStatusColor(TaskStatus status) {
    final theme = Theme.of(context);
    switch (status) {
      case TaskStatus.pending:
        return theme.colorScheme.onTertiaryContainer; // Warning/pending state
      case TaskStatus.inProgress:
        return theme.colorScheme.primary;
      case TaskStatus.completed:
        return theme.colorScheme.tertiary; // Success/completion state
      case TaskStatus.cancelled:
        return theme.colorScheme.outline;
    }
  }

  Color _getBottleneckColor(BottleneckSeverity severity) {
    final theme = Theme.of(context);
    switch (severity) {
      case BottleneckSeverity.low:
        return theme.colorScheme.tertiary; // Low severity - success-like state
      case BottleneckSeverity.medium:
        return theme.colorScheme.onTertiaryContainer; // Medium severity - warning state
      case BottleneckSeverity.high:
        return theme.colorScheme.error; // High severity - error state
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatLastUpdated(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) return 'just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}

// Export options sheet widget
class _ExportOptionsSheet extends ConsumerWidget {
  final Project project;
  final ProjectAnalytics analytics;

  const _ExportOptionsSheet({
    required this.project,
    required this.analytics,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return GlassmorphismContainer(
      level: GlassLevel.floating,
      padding: EdgeInsets.zero,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(TypographyConstants.radiusLarge),
      ),
      child: Container(
        padding: const EdgeInsets.all(TypographyConstants.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: TypographyConstants.spacingLarge),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            Text(
              'Export Analytics',
              style: StandardizedTextStyle.headlineSmall.toTextStyle(context).copyWith(
                fontWeight: TypographyConstants.medium,
              ),
            ),
            const SizedBox(height: TypographyConstants.spacingMedium),
            
            // Export options
            _buildExportOption(
              context,
              ref,
              'JSON Data Export',
              'Complete analytics data in JSON format',
              PhosphorIcons.fileText(),
              ExportFormat.json,
            ),
            _buildExportOption(
              context,
              ref,
              'CSV Spreadsheet',
              'Task data and metrics for Excel/Sheets',
              PhosphorIcons.fileX(),
              ExportFormat.csv,
            ),
            _buildExportOption(
              context,
              ref,
              'Text Report',
              'Human-readable summary report',
              PhosphorIcons.fileDoc(),
              ExportFormat.txt,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOption(
    BuildContext context,
    WidgetRef ref,
    String title,
    String subtitle,
    IconData icon,
    ExportFormat format,
  ) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: TypographyConstants.spacingMedium),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _exportData(context, ref, format),
          borderRadius: BorderRadius.circular(TypographyConstants.radiusMedium),
          child: Container(
            padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
              borderRadius: BorderRadius.circular(TypographyConstants.radiusMedium),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: TypographyConstants.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: StandardizedTextStyle.titleMedium.toTextStyle(context).copyWith(
                          fontWeight: TypographyConstants.medium,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  PhosphorIcons.caretRight(),
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref, ExportFormat format) async {
    Navigator.of(context).pop(); // Close the sheet
    
    try {
      final exportService = ref.read(analyticsExportServiceProvider);
      
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      // Perform export
      final result = await ref.read(analyticsExportProvider(ExportRequest(
        projectId: project.id,
        analytics: analytics,
        format: format,
      )).future);
      
      Navigator.of(context).pop(); // Close loading
      
      if (result.success) {
        // Show success and share option
        await exportService.shareAnalytics(
          exportResult: result,
          subject: 'Analytics Report - ${project.name}',
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Analytics exported successfully!'),
            backgroundColor: Theme.of(context).colorScheme.tertiary, // Success state
          ),
        );
      } else {
        throw Exception(result.error ?? 'Export failed');
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading if still open
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}