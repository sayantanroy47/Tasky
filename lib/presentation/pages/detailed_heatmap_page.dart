import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/typography_constants.dart';
import '../../services/analytics/analytics_models.dart';
import '../providers/analytics_providers.dart';
import '../widgets/glassmorphism_container.dart';
import '../widgets/standardized_app_bar.dart';
import '../widgets/standardized_text.dart';
import '../widgets/standardized_colors.dart';
import '../widgets/standardized_spacing.dart';
import '../widgets/standardized_error_states.dart';
import '../widgets/theme_background_widget.dart';
import '../../core/design_system/design_tokens.dart';

/// Detailed heatmap page showing comprehensive productivity analytics
/// 
/// Features:
/// - Full-year heatmap with 12 months of data
/// - Multiple view modes (daily, weekly, monthly)
/// - Detailed statistics panel
/// - Interactive exploration and filtering
/// - Export capabilities
class DetailedHeatmapPage extends ConsumerStatefulWidget {
  const DetailedHeatmapPage({super.key});

  @override
  ConsumerState<DetailedHeatmapPage> createState() => _DetailedHeatmapPageState();
}

class _DetailedHeatmapPageState extends ConsumerState<DetailedHeatmapPage> {
  HeatmapViewMode _viewMode = HeatmapViewMode.daily;
  int _selectedYear = DateTime.now().year;
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return ThemeBackgroundWidget(
      child: Scaffold(
        backgroundColor: context.colors.backgroundTransparent,
        extendBodyBehindAppBar: true,
        appBar: StandardizedAppBar(
        title: 'Productivity Heatmap',
        forceBackButton: true,
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.calendar()),
            onPressed: _showYearPicker,
            tooltip: 'Select year',
          ),
          PopupMenuButton<HeatmapViewMode>(
            icon: Icon(PhosphorIcons.gridNine()),
            tooltip: 'View mode',
            onSelected: (mode) => setState(() => _viewMode = mode),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: HeatmapViewMode.daily,
                child: Row(
                  children: [
                    Icon(PhosphorIcons.calendar(), size: 16),
                    StandardizedGaps.horizontal(SpacingSize.sm),
                    const StandardizedText('Daily View', style: StandardizedTextStyle.bodyMedium),
                  ],
                ),
              ),
              PopupMenuItem(
                value: HeatmapViewMode.weekly,
                child: Row(
                  children: [
                    Icon(PhosphorIcons.calendarBlank(), size: 16),
                    StandardizedGaps.horizontal(SpacingSize.sm),
                    const StandardizedText('Weekly View', style: StandardizedTextStyle.bodyMedium),
                  ],
                ),
              ),
              PopupMenuItem(
                value: HeatmapViewMode.monthly,
                child: Row(
                  children: [
                    Icon(PhosphorIcons.gridFour(), size: 16),
                    StandardizedGaps.horizontal(SpacingSize.sm),
                    const StandardizedText('Monthly View', style: StandardizedTextStyle.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            top: kToolbarHeight + SpacingTokens.sm,
            left: SpacingTokens.md,
            right: SpacingTokens.md,
            bottom: SpacingTokens.md,
          ),
          child: Column(
            children: [
              // Header with year and view mode info
              _buildHeader(),
              
              StandardizedGaps.md,
              
              // Main heatmap view
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    // Use the existing heatmap provider but filter data by year
                    final heatmapAsync = ref.watch(heatmapDataProvider);
                    return heatmapAsync.when(
                      data: (allData) {
                        // Filter data for the selected year
                        final yearData = allData.where((stat) => stat.date.year == _selectedYear).toList();
                        return _buildHeatmapView(yearData);
                      },
                      loading: () => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            StandardizedErrorStates.loading(),
                            StandardizedGaps.md,
                            StandardizedText(
                              'Loading $_selectedYear productivity data...',
                              style: StandardizedTextStyle.bodyMedium,
                              color: context.colors.withSemanticOpacity(
                                Theme.of(context).colorScheme.onSurface,
                                SemanticOpacity.strong,
                              ),
                            ),
                          ],
                        ),
                      ),
                      error: (error, stack) => _buildErrorView(error.toString()),
                    );
                  },
                ),
              ),
              
              // Selected date details panel
              if (_selectedDate != null) ...[
                StandardizedGaps.md,
                _buildSelectedDatePanel(),
              ],
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      padding: StandardizedSpacing.padding(SpacingSize.lg),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StandardizedText(
                  '$_selectedYear Productivity Overview',
                  style: StandardizedTextStyle.headlineMedium,
                  color: theme.colorScheme.onSurface,
                ),
                StandardizedGaps.vertical(SpacingSize.xs),
                StandardizedText(
                  '${_viewMode.displayName} view • Tap any cell to explore details',
                  style: StandardizedTextStyle.bodyMedium,
                  color: context.colors.withSemanticOpacity(
                    Theme.of(context).colorScheme.onSurface,
                    SemanticOpacity.strong,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: StandardizedSpacing.paddingSymmetric(
              horizontal: SpacingSize.md,
              vertical: SpacingSize.sm,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _viewMode.icon,
                  size: 16,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                StandardizedGaps.horizontal(SpacingSize.xs),
                StandardizedText(
                  _viewMode.displayName,
                  style: StandardizedTextStyle.labelMedium,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapView(List<DailyStats> yearData) {
    return Column(
      children: [
        // Year statistics section
        _buildYearStats(yearData),
        StandardizedGaps.lg,
        
        // Heatmap display based on view mode
        Expanded(
          child: switch (_viewMode) {
            HeatmapViewMode.daily => _buildDailyHeatmap(yearData),
            HeatmapViewMode.weekly => _buildWeeklyHeatmap(yearData),
            HeatmapViewMode.monthly => _buildMonthlyHeatmap(yearData),
          },
        ),
      ],
    );
  }

  Widget _buildDailyHeatmap(List<DailyStats> yearData) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Create a comprehensive year view with all 12 months
    final maxCompleted = yearData.fold(0, (max, stat) => 
        stat.completedTasks > max ? stat.completedTasks : max);
    
    final statsMap = <String, DailyStats>{};
    for (final stat in yearData) {
      final key = '${stat.date.year}-${stat.date.month.toString().padLeft(2, '0')}-${stat.date.day.toString().padLeft(2, '0')}';
      statsMap[key] = stat;
    }
    
    
    // Build year grid - 53 weeks max
    final startOfYear = DateTime(_selectedYear, 1, 1);
    final endOfYear = DateTime(_selectedYear, 12, 31);
    final weeks = <List<DateTime>>[];
    
    var currentWeek = <DateTime>[];
    var currentDate = startOfYear;
    
    // Pad to start of week (Sunday)
    final startWeekday = currentDate.weekday % 7; // Sunday = 0
    for (int i = 0; i < startWeekday; i++) {
      currentWeek.add(currentDate.subtract(Duration(days: startWeekday - i)));
    }
    
    // Add all days of the year
    while (currentDate.isBefore(endOfYear) || currentDate.isAtSameMomentAs(endOfYear)) {
      currentWeek.add(currentDate);
      
      if (currentWeek.length == 7) {
        weeks.add(currentWeek);
        currentWeek = <DateTime>[];
      }
      
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    // Add remaining days
    if (currentWeek.isNotEmpty) {
      while (currentWeek.length < 7) {
        currentWeek.add(currentDate);
        currentDate = currentDate.add(const Duration(days: 1));
      }
      weeks.add(currentWeek);
    }
    
    const double cellSize = 18.0;
    const double cellSpacing = 3.0;
    
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      padding: StandardizedSpacing.padding(SpacingSize.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weekday labels column (left side) - fixed
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StandardizedGaps.vertical(SpacingSize.xxl), // Space for month labels
              ...['S', 'M', 'T', 'W', 'T', 'F', 'S'].asMap().entries.map((entry) {
                final index = entry.key;
                final day = entry.value;
                return Container(
                  height: cellSize,
                  width: 24,
                  margin: EdgeInsets.only(
                    bottom: index < 6 ? cellSpacing : 0,
                  ),
                  alignment: Alignment.centerRight,
                  child: Text(
                    day,
                    style: StandardizedTextStyle.labelMedium.toTextStyle(context).copyWith(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }),
            ],
          ),
          
          const SizedBox(width: 8),
          
          // Single scrollable container with both month labels and heatmap
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month labels row
                  SizedBox(
                    height: 20,
                    child: Row(
                      children: List.generate(12, (month) {
                        // Calculate proper weeks for each month - minimum 28px to fit month names
                        final weeksInMonth = (DateTime(_selectedYear, month + 2, 0).day / 7).ceil();
                        final calculatedWidth = weeksInMonth * (cellSize + cellSpacing);
                        final width = calculatedWidth < 28 ? 28.0 : calculatedWidth; // Ensure minimum width
                        
                        return Container(
                          width: width,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _getMonthName(month + 1),
                            style: StandardizedTextStyle.labelSmall.toTextStyle(context).copyWith(
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Heatmap grid
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: weeks.map((week) {
                        return Padding(
                          padding: const EdgeInsets.only(right: cellSpacing),
                          child: Column(
                            children: week.asMap().entries.map((dayEntry) {
                              final dayIndex = dayEntry.key;
                              final date = dayEntry.value;
                              final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                              final stat = statsMap[key];
                              final completedTasks = stat?.completedTasks ?? 0;
                              final isCurrentYear = date.year == _selectedYear;
                              final isToday = _isToday(date);
                              final isSelected = _selectedDate != null && _isSameDay(date, _selectedDate!);
                              
                              return GestureDetector(
                                onTap: isCurrentYear ? () => setState(() => _selectedDate = date) : null,
                                child: Container(
                                  width: cellSize,
                                  height: cellSize,
                                  margin: EdgeInsets.only(
                                    bottom: dayIndex < 6 ? cellSpacing : 0,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: isCurrentYear 
                                        ? _getHeatmapColor(context, completedTasks, maxCompleted)
                                        : colorScheme.surface.withValues(alpha: 0.3),
                                    border: Border.all(
                                      color: isToday 
                                          ? colorScheme.primary
                                          : isSelected
                                              ? colorScheme.secondary
                                              : colorScheme.outline.withValues(alpha: 0.2),
                                      width: isToday || isSelected ? 2.0 : 0.5,
                                    ),
                                  ),
                                  child: isCurrentYear && completedTasks > 0 && completedTasks <= 9
                                      ? Center(
                                          child: Text(
                                            '$completedTasks',
                                            style: StandardizedTextStyle.labelSmall.toTextStyle(context).copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: _getTextColor(context, completedTasks, maxCompleted),
                                            ),
                                          ),
                                        )
                                      : null,
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
    );
  }

  Widget _buildWeeklyHeatmap(List<DailyStats> yearData) {
    // Group data by weeks and show weekly completion totals
    return const Center(
      child: StandardizedText('Weekly view - Coming soon!', style: StandardizedTextStyle.bodyMedium),
    );
  }

  Widget _buildMonthlyHeatmap(List<DailyStats> yearData) {
    // Show monthly grid with completion totals
    return const Center(
      child: StandardizedText('Monthly view - Coming soon!', style: StandardizedTextStyle.bodyMedium),
    );
  }

  Widget _buildSelectedDatePanel() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Find stats for selected date from existing data
    final heatmapAsync = ref.watch(heatmapDataProvider);
    
    return heatmapAsync.when(
      data: (allData) {
        // Find the stats for the selected date
        final stats = allData.where((stat) => _isSameDay(stat.date, _selectedDate!)).isNotEmpty
            ? allData.where((stat) => _isSameDay(stat.date, _selectedDate!)).first
            : null;
        return GlassmorphismContainer(
          borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
          padding: StandardizedSpacing.padding(SpacingSize.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    PhosphorIcons.calendar(),
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StandardizedTextVariants.cardTitle(
                      _formatSelectedDate(_selectedDate!),
                    ),
                  ),
                  IconButton(
                    icon: Icon(PhosphorIcons.x()),
                    onPressed: () => setState(() => _selectedDate = null),
                    iconSize: 18,
                  ),
                ],
              ),
              const SizedBox(height: 16),
            if (stats != null) ...[
              Row(
                children: [
                  _buildStatChip(
                    PhosphorIcons.checkCircle(),
                    'Completed',
                    '${stats.completedTasks}',
                    Colors.green,
                  ),
                  const SizedBox(width: 12),
                  _buildStatChip(
                    PhosphorIcons.listBullets(),
                    'Total',
                    '${stats.totalTasks}',
                    Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  _buildStatChip(
                    PhosphorIcons.percent(),
                    'Rate',
                    '${(stats.completionRate * 100).round()}%',
                    Colors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatChip(
                    PhosphorIcons.plus(),
                    'Created',
                    '${stats.createdTasks}',
                    Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  _buildStatChip(
                    PhosphorIcons.clock(),
                    'Duration',
                    '${(stats.totalDuration / 60).toStringAsFixed(1)}h',
                    Colors.teal,
                  ),
                ],
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      PhosphorIcons.calendar(),
                      color: colorScheme.onSurfaceVariant,
                      size: 16,
                    ),
                    StandardizedGaps.horizontal(SpacingSize.sm),
                    StandardizedText(
                      'No activity recorded for this day',
                      style: StandardizedTextStyle.bodyMedium,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ], // Close the if (stats != null) block
            ], // Close the Column children
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => StandardizedText('Error: $error', style: StandardizedTextStyle.bodyMedium),
    );
  }

  Widget _buildStatChip(IconData icon, String label, String value, Color color) {
    
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 6),
                Flexible(
                  child: StandardizedText(
                    label,
                    style: StandardizedTextStyle.labelMedium,
                    color: color,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            StandardizedText(
              value,
              style: StandardizedTextStyle.titleLarge,
              color: color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearStats(List<DailyStats> yearData) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final totalCompleted = yearData.fold(0, (sum, stat) => sum + stat.completedTasks);
    final averagePerDay = yearData.isNotEmpty ? (totalCompleted / yearData.length) : 0.0;
    final bestDay = yearData.fold(0, (max, stat) => stat.completedTasks > max ? stat.completedTasks : max);
    final activeDays = yearData.where((stat) => stat.completedTasks > 0).length;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StandardizedTextVariants.cardTitle(
          '$_selectedYear Statistics',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildYearStatItem('Total Completed', '$totalCompleted', Colors.green),
            _buildYearStatItem('Active Days', '$activeDays', Colors.blue),
            _buildYearStatItem('Best Day', '$bestDay', Colors.orange),
            _buildYearStatItem('Daily Avg', averagePerDay.toStringAsFixed(1), Colors.purple),
          ],
        ),
        const SizedBox(height: 12),
        // Legend
        Row(
          children: [
            StandardizedText(
              'Less',
              style: StandardizedTextStyle.labelSmall,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            ...List.generate(5, (index) => Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.only(left: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: _getHeatmapColor(context, index, 4),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
            )),
            const SizedBox(width: 8),
            StandardizedText(
              'More',
              style: StandardizedTextStyle.labelSmall,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildYearStatItem(String label, String value, Color color) {
    final theme = Theme.of(context);
    
    return Expanded(
      child: Column(
        children: [
          StandardizedText(
            value,
            style: StandardizedTextStyle.titleSmall,
            color: color,
          ),
          StandardizedText(
            label,
            style: StandardizedTextStyle.labelSmall,
            color: theme.colorScheme.onSurfaceVariant,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.warningCircle(),
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          const StandardizedText('Error loading heatmap data', style: StandardizedTextStyle.bodyMedium),
          const SizedBox(height: 8),
          StandardizedText(
            error,
            style: StandardizedTextStyle.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showYearPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const StandardizedText('Select Year', style: StandardizedTextStyle.titleMedium),
        content: SizedBox(
          width: 300,
          height: 300,
          child: YearPicker(
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
            selectedDate: DateTime(_selectedYear),
            onChanged: (date) {
              setState(() => _selectedYear = date.year);
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }

  // Helper methods
  Color _getHeatmapColor(BuildContext context, int completedTasks, int maxCompleted) {
    final colorScheme = Theme.of(context).colorScheme;
    
    if (completedTasks == 0) {
      return colorScheme.surface.withValues(alpha: 0.8);
    }
    
    final intensity = maxCompleted > 0 ? (completedTasks / maxCompleted).clamp(0.0, 1.0) : 0.0;
    
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

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String _formatSelectedDate(DateTime date) {
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
                   'July', 'August', 'September', 'October', 'November', 'December'];
    
    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    
    return '$weekday, $month ${date.day}, ${date.year}';
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year && date.month == today.month && date.day == today.day;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

}

/// View modes for the heatmap
enum HeatmapViewMode {
  daily('Daily'),
  weekly('Weekly'),
  monthly('Monthly');

  const HeatmapViewMode(this.displayName);
  
  final String displayName;
  
  IconData get icon {
    switch (this) {
      case HeatmapViewMode.daily:
        return PhosphorIcons.calendar();
      case HeatmapViewMode.weekly:
        return PhosphorIcons.calendarBlank();
      case HeatmapViewMode.monthly:
        return PhosphorIcons.gridFour();
    }
  }
}