import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/typography_constants.dart';
import '../../services/performance_service.dart';
import '../providers/performance_providers.dart';
import '../widgets/glassmorphism_container.dart';
import '../widgets/standardized_app_bar.dart';

/// Performance dashboard screen for monitoring app performance
class PerformanceDashboardScreen extends ConsumerWidget {
  const PerformanceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final performanceSnapshot = ref.watch(performanceSnapshotProvider);
    final frameRateState = ref.watch(frameRateProvider);
    final metricsState = ref.watch(performanceMetricsProvider);
    final memoryStats = ref.watch(memoryStatsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: StandardizedAppBar(
        title: 'Performance Dashboard',
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.arrowClockwise()),
            onPressed: () {
              ref.invalidate(performanceSnapshotProvider);
              ref.read(performanceMetricsProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Cards
            _buildOverviewSection(theme, performanceSnapshot.valueOrNull),
            const SizedBox(height: 24),

            // Frame Rate Monitoring
            _buildFrameRateSection(theme, frameRateState),
            const SizedBox(height: 24),

            // Performance Metrics
            _buildMetricsSection(theme, metricsState),
            const SizedBox(height: 24),

            // Memory Usage
            _buildMemorySection(theme, memoryStats),
            const SizedBox(height: 24),

            // Analytics Summary
            performanceSnapshot.when(
              data: (snapshot) => _buildAnalyticsSection(theme, snapshot),
              loading: () => _buildLoadingCard(theme, 'Loading analytics...'),
              error: (error, _) => _buildErrorCard(theme, 'Failed to load analytics: $error'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewSection(ThemeData theme, PerformanceSnapshot? snapshot) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Overview',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                theme,
                'App Uptime',
                snapshot != null ? _formatDuration(snapshot.appUptime) : '--',
                PhosphorIcons.timer(),
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                theme,
                'Events Tracked',
                snapshot?.eventCount.toString() ?? '--',
                PhosphorIcons.chartBar(),
                Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFrameRateSection(ThemeData theme, FrameRateState frameRate) {
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIcons.speedometer(), color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Frame Rate Performance',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFrameRateMetric(
                  theme,
                  'Current FPS',
                  frameRate.currentFps.toStringAsFixed(1),
                  _getFpsColor(frameRate.currentFps),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFrameRateMetric(
                  theme,
                  'Average FPS',
                  frameRate.averageFps.toStringAsFixed(1),
                  _getFpsColor(frameRate.averageFps),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Simple frame rate chart representation
          if (frameRate.recentFrames.isNotEmpty) _buildSimpleChart(theme, frameRate.recentFrames, 'FPS Over Time'),
        ],
      ),
    );
  }

  Widget _buildMetricsSection(ThemeData theme, PerformanceMetricsState metrics) {
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIcons.chartLine(), color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Performance Metrics',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                'Last updated: ${_formatTime(metrics.lastUpdated)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (metrics.currentMetrics.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No metrics recorded yet',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            ...metrics.currentMetrics.entries
                .map((entry) => _buildMetricRow(theme, entry.key, entry.value.toStringAsFixed(2))),
        ],
      ),
    );
  }

  Widget _buildMemorySection(ThemeData theme, Map<String, dynamic> memoryStats) {
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIcons.cpu(), color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Memory Usage',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...memoryStats.entries.map((entry) => _buildMetricRow(theme, entry.key, entry.value.toString())),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => MemoryManager.optimizeMemory(),
                  icon: Icon(PhosphorIcons.broom()),
                  label: const Text('Optimize Memory'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => MemoryManager.collectGarbage(),
                  icon: Icon(PhosphorIcons.trash()),
                  label: const Text('Collect Garbage'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSection(ThemeData theme, PerformanceSnapshot snapshot) {
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIcons.chartBar(), color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Analytics Summary',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMetricRow(theme, 'Session ID', snapshot.sessionId),
          _buildMetricRow(theme, 'Total Events', snapshot.eventCount.toString()),
          _buildMetricRow(theme, 'Metrics Tracked', snapshot.performanceMetrics.length.toString()),
          if (snapshot.performanceMetrics.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Top Performance Metrics',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ...snapshot.performanceMetrics.entries.take(5).map((entry) {
              final stats = entry.value;
              return ExpansionTile(
                title: Text(entry.key),
                subtitle: Text('Avg: ${stats['average']?.toStringAsFixed(2) ?? 'N/A'}'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: stats.entries
                          .map((stat) => _buildMetricRow(theme, stat.key, stat.value.toStringAsFixed(2)))
                          .toList(),
                    ),
                  ),
                ],
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricCard(ThemeData theme, String title, String value, IconData icon, Color color) {
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrameRateMetric(ThemeData theme, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleChart(ThemeData theme, List<double> data, String title) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.take(20).map((value) {
                final normalizedHeight = (value / 60.0).clamp(0.1, 1.0);
                return Expanded(
                  child: Container(
                    height: normalizedHeight * 50,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: _getFpsColor(value),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard(ThemeData theme, String message) {
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(ThemeData theme, String error) {
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            PhosphorIcons.warningCircle(),
            size: 48,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            error,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getFpsColor(double fps) {
    if (fps >= 50) return Colors.green;
    if (fps >= 30) return Colors.orange;
    return Colors.red;
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }
}
