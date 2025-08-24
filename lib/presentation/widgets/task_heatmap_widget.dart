import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/typography_constants.dart';
import '../../services/analytics/analytics_models.dart';
import 'glassmorphism_container.dart';

/// A beautiful heatmap widget showing daily task completion patterns
/// 
/// Displays a GitHub-style activity heatmap with color intensity based
/// on the number of tasks completed each day. Uses Material 3 color
/// scheme and maintains consistent design patterns.
class TaskHeatmapWidget extends StatelessWidget {
  final List<DailyStats> dailyStats;
  final String title;
  final VoidCallback? onTap;

  const TaskHeatmapWidget({
    super.key,
    required this.dailyStats,
    this.title = 'Task Activity Heatmap',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and icon
          Row(
            children: [
              Icon(
                PhosphorIcons.calendar(),
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              if (onTap != null)
                IconButton(
                  icon: Icon(
                    PhosphorIcons.arrowSquareOut(),
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: onTap,
                  tooltip: 'View details',
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Heatmap grid
          _buildHeatmapGrid(context),
          
          const SizedBox(height: 12),
          
          // Legend and stats
          _buildLegendAndStats(context),
        ],
      ),
    );
  }

  Widget _buildHeatmapGrid(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    if (dailyStats.isEmpty) {
      return Container(
        height: 170,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
          color: colorScheme.surface.withValues(alpha: 0.3),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIcons.calendar(),
                size: 32,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 8),
              Text(
                'No activity data',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Calculate max completed tasks for color scaling
    final maxCompleted = dailyStats.map((s) => s.completedTasks).fold(0, (a, b) => a > b ? a : b);
    
    // Create a map for quick lookup using date strings
    final statsMap = <String, DailyStats>{};
    for (final stat in dailyStats) {
      final key = '${stat.date.year}-${stat.date.month.toString().padLeft(2, '0')}-${stat.date.day.toString().padLeft(2, '0')}';
      statsMap[key] = stat;
    }
    
    // Generate grid for last 16 weeks (112 days) - fits well on screen
    final today = DateTime.now();
    final startDate = DateTime(today.year, today.month, today.day).subtract(const Duration(days: 112));
    
    // Debug: Log the date range
    print('Heatmap date range: ${startDate.toString().substring(0, 10)} to ${today.toString().substring(0, 10)}');
    
    // Build weeks array (each week is 7 days)
    final List<List<DateTime>> weeks = [];
    for (int w = 0; w < 16; w++) {
      final weekStart = startDate.add(Duration(days: w * 7));
      final week = <DateTime>[];
      for (int d = 0; d < 7; d++) {
        week.add(weekStart.add(Duration(days: d)));
      }
      weeks.add(week);
    }
    
    const double cellSize = 18.0;
    const double cellSpacing = 2.0;
    
    return SizedBox(
      height: 170,
      child: ClipRect(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weekday labels column (left side) - fixed
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 28), // Space for month labels
                ...['M', 'T', 'W', 'T', 'F', 'S', 'S'].asMap().entries.map((entry) {
                  final index = entry.key;
                  final day = entry.value;
                  return Container(
                    height: cellSize,
                    width: 16,
                    margin: EdgeInsets.only(
                      bottom: index < 6 ? cellSpacing : 0,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      day,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: TypographyConstants.labelSmall, // 11.0 - Fixed critical WCAG violation (was 10px)
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
            
            const SizedBox(width: 8),
            
            // Single scrollable container with both month labels and heatmap
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Month labels row
                    SizedBox(
                      height: 20,
                      child: Row(
                        children: weeks.asMap().entries.map((entry) {
                          final weekIndex = entry.key;
                          final week = entry.value;
                          final firstDay = week.first;
                          
                          // Show month when it's the first week OR when month changes from previous week
                          String? monthText;
                          bool showMonth = false;
                          
                          if (weekIndex == 0) {
                            // Always show first month
                            showMonth = true;
                          } else {
                            // Show when month changes
                            final previousMonth = weeks[weekIndex - 1].first.month;
                            final currentMonth = firstDay.month;
                            showMonth = previousMonth != currentMonth;
                          }
                          
                          if (showMonth) {
                            monthText = _getMonthAbbrev(firstDay.month);
                          }
                          
                          return Container(
                            width: cellSize + cellSpacing,
                            child: monthText != null ? Text(
                              monthText,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 9,
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.left,
                            ) : null,
                          );
                        }).toList(),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Heatmap grid
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: weeks.map((week) {
                        return Padding(
                          padding: const EdgeInsets.only(right: cellSpacing),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: week.asMap().entries.map((dayEntry) {
                              final dayIndex = dayEntry.key;
                              final date = dayEntry.value;
                              final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                              final stat = statsMap[key];
                              final completedTasks = stat?.completedTasks ?? 0;
                              
                              return RepaintBoundary(
                                child: Container(
                                  width: cellSize,
                                  height: cellSize,
                                  margin: EdgeInsets.only(
                                    bottom: dayIndex < 6 ? cellSpacing : 0,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    color: _getHeatmapColor(context, completedTasks, maxCompleted),
                                    border: Border.all(
                                      color: colorScheme.outline.withValues(alpha: 0.12),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(3),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(3),
                                      onTap: stat != null ? () => _showDayDetails(context, stat) : null,
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: completedTasks > 0 && completedTasks <= 9
                                            ? Text(
                                                '$completedTasks',
                                                style: theme.textTheme.labelSmall?.copyWith(
                                                  fontSize: TypographyConstants.labelSmall, // 11.0 - Fixed accessibility violation (was 9px)
                                                  fontWeight: FontWeight.w700,
                                                  color: _getTextColor(context, completedTasks, maxCompleted),
                                                ),
                                              )
                                            : null,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      }).toList(),
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

  Widget _buildLegendAndStats(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final totalCompleted = dailyStats.fold(0, (sum, stat) => sum + stat.completedTasks);
    final averagePerDay = dailyStats.isNotEmpty ? (totalCompleted / dailyStats.length).round() : 0;
    final maxDay = dailyStats.fold(0, (max, stat) => stat.completedTasks > max ? stat.completedTasks : max);
    
    return Row(
      children: [
        // Stats chips
        Expanded(
          child: Wrap(
            spacing: 8,
            children: [
              _buildStatChip(context, '$totalCompleted', 'Total', PhosphorIcons.checkCircle()),
              _buildStatChip(context, '$averagePerDay', 'Avg/day', PhosphorIcons.trendUp()),
              _buildStatChip(context, '$maxDay', 'Best day', PhosphorIcons.fire()),
            ],
          ),
        ),
        
        // Legend
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Less',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: TypographyConstants.labelSmall, // 11.0 - Fixed critical WCAG violation (was 10px)
              ),
            ),
            const SizedBox(width: 4),
            ...List.generate(5, (index) => Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(left: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: _getHeatmapColor(context, index, 4),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
            )),
            const SizedBox(width: 4),
            Text(
              'More',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: TypographyConstants.labelSmall, // 11.0 - Fixed critical WCAG violation (was 10px)
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatChip(BuildContext context, String value, String label, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: TypographyConstants.labelSmall, // 11.0 - Fixed critical WCAG violation (was 10px)
            ),
          ),
        ],
      ),
    );
  }

  Color _getHeatmapColor(BuildContext context, int completedTasks, int maxCompleted) {
    final colorScheme = Theme.of(context).colorScheme;
    
    if (completedTasks == 0) {
      return colorScheme.surface.withValues(alpha: 0.8);
    }
    
    final intensity = maxCompleted > 0 ? (completedTasks / maxCompleted).clamp(0.0, 1.0) : 0.0;
    
    // Beautiful gradient from light to dark primary color
    if (intensity <= 0.2) {
      return colorScheme.primary.withValues(alpha: 0.3);
    } else if (intensity <= 0.4) {
      return colorScheme.primary.withValues(alpha: 0.5);
    } else if (intensity <= 0.6) {
      return colorScheme.primary.withValues(alpha: 0.7);
    } else if (intensity <= 0.8) {
      return colorScheme.primary.withValues(alpha: 0.85);
    } else {
      return colorScheme.primary;
    }
  }

  Color _getTextColor(BuildContext context, int completedTasks, int maxCompleted) {
    final intensity = maxCompleted > 0 ? (completedTasks / maxCompleted).clamp(0.0, 1.0) : 0.0;
    final colorScheme = Theme.of(context).colorScheme;
    
    return intensity > 0.5 ? Colors.white : colorScheme.onSurface.withValues(alpha: 0.9);
  }

  String _getMonthAbbrev(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  void _showDayDetails(BuildContext context, DailyStats stat) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              PhosphorIcons.calendar(),
              color: colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Day Details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${stat.date.day}/${stat.date.month}/${stat.date.year}',
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(context, PhosphorIcons.checkCircle(), 'Completed Tasks', '${stat.completedTasks}'),
            _buildDetailRow(context, PhosphorIcons.listBullets(), 'Total Tasks', '${stat.totalTasks}'),
            _buildDetailRow(context, PhosphorIcons.plus(), 'Created Tasks', '${stat.createdTasks}'),
            _buildDetailRow(context, PhosphorIcons.percent(), 'Completion Rate', '${(stat.completionRate * 100).round()}%'),
            _buildDetailRow(context, PhosphorIcons.clock(), 'Total Duration', '${(stat.totalDuration / 60).toStringAsFixed(1)}h'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}