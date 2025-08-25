import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/design_system/design_tokens.dart';
import '../../../core/theme/typography_constants.dart';
import '../glassmorphism_container.dart';
import '../standardized_text.dart';
import '../standardized_colors.dart';
import 'base_chart_widget.dart';

/// Widget for chart controls including time period selection, chart type switching, and export
class ChartControlsWidget extends StatelessWidget {
  final ChartTimePeriod selectedPeriod;
  final ChartType selectedChartType;
  final ValueChanged<ChartTimePeriod> onPeriodChanged;
  final ValueChanged<ChartType> onChartTypeChanged;
  final VoidCallback? onExport;
  final VoidCallback? onRefresh;
  final bool isLoading;
  final List<ChartType> availableChartTypes;
  final bool showChartTypeSelector;
  final bool showExportButton;

  const ChartControlsWidget({
    super.key,
    required this.selectedPeriod,
    required this.selectedChartType,
    required this.onPeriodChanged,
    required this.onChartTypeChanged,
    this.onExport,
    this.onRefresh,
    this.isLoading = false,
    this.availableChartTypes = const [ChartType.line, ChartType.bar],
    this.showChartTypeSelector = true,
    this.showExportButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassmorphismContainer(
      level: GlassLevel.whisper,
      padding: const EdgeInsets.all(TypographyConstants.paddingSmall),
      margin: const EdgeInsets.only(bottom: TypographyConstants.spacingMedium),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      child: Column(
        children: [
          // Time period selector
          _buildTimePeriodSelector(context, theme),
          
          if (showChartTypeSelector || showExportButton) ...[
            const SizedBox(height: TypographyConstants.spacingSmall),
            
            // Chart type and actions row
            Row(
              children: [
                if (showChartTypeSelector) ...[
                  Expanded(child: _buildChartTypeSelector(context, theme)),
                  if (showExportButton) const SizedBox(width: TypographyConstants.spacingSmall),
                ],
                if (showExportButton) _buildActionButtons(context, theme),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimePeriodSelector(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Icon(
          PhosphorIcons.calendar(),
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: TypographyConstants.spacingSmall),
        Text(
          'Period:',
          style: StandardizedTextStyle.labelMedium.toTextStyle(context).copyWith(
            fontSize: TypographyConstants.labelMedium,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: TypographyConstants.spacingSmall),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ChartTimePeriod.values.map((period) {
                final isSelected = period == selectedPeriod;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _buildPeriodChip(context, theme, period, isSelected),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodChip(
    BuildContext context,
    ThemeData theme,
    ChartTimePeriod period,
    bool isSelected,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: context.colors.backgroundTransparent,
        child: InkWell(
          onTap: isLoading ? null : () => onPeriodChanged(period),
          borderRadius: BorderRadius.circular(TypographyConstants.radiusXSmall),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected 
                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                : context.colors.backgroundTransparent,
              borderRadius: BorderRadius.circular(TypographyConstants.radiusXSmall),
              border: Border.all(
                color: isSelected 
                  ? theme.colorScheme.primary.withValues(alpha: 0.3)
                  : theme.colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Text(
              period.displayName,
              style: StandardizedTextStyle.labelSmall.toTextStyle(context).copyWith(
                fontSize: TypographyConstants.labelSmall,
                color: isSelected 
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected 
                  ? TypographyConstants.medium 
                  : TypographyConstants.regular,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartTypeSelector(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Icon(
          PhosphorIcons.chartBar(),
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: TypographyConstants.spacingSmall),
        Text(
          'Type:',
          style: StandardizedTextStyle.labelMedium.toTextStyle(context).copyWith(
            fontSize: TypographyConstants.labelMedium,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: TypographyConstants.spacingSmall),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: availableChartTypes.map((type) {
                final isSelected = type == selectedChartType;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _buildChartTypeButton(context, theme, type, isSelected),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChartTypeButton(
    BuildContext context,
    ThemeData theme,
    ChartType type,
    bool isSelected,
  ) {
    final icon = _getChartTypeIcon(type);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: context.colors.backgroundTransparent,
        child: InkWell(
          onTap: isLoading ? null : () => onChartTypeChanged(type),
          borderRadius: BorderRadius.circular(TypographyConstants.radiusXSmall),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isSelected 
                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                : context.colors.backgroundTransparent,
              borderRadius: BorderRadius.circular(TypographyConstants.radiusXSmall),
              border: Border.all(
                color: isSelected 
                  ? theme.colorScheme.primary.withValues(alpha: 0.3)
                  : theme.colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: 16,
              color: isSelected 
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onRefresh != null)
          Material(
            color: context.colors.backgroundTransparent,
            child: InkWell(
              onTap: isLoading ? null : onRefresh,
              borderRadius: BorderRadius.circular(TypographyConstants.radiusXSmall),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: AnimatedRotation(
                  duration: const Duration(milliseconds: 500),
                  turns: isLoading ? 1 : 0,
                  child: Icon(
                    PhosphorIcons.arrowClockwise(),
                    size: 16,
                    color: isLoading 
                      ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                      : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        if (onExport != null) ...[
          const SizedBox(width: 4),
          Material(
            color: context.colors.backgroundTransparent,
            child: InkWell(
              onTap: isLoading ? null : onExport,
              borderRadius: BorderRadius.circular(TypographyConstants.radiusXSmall),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  PhosphorIcons.export(),
                  size: 16,
                  color: isLoading 
                    ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                    : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  IconData _getChartTypeIcon(ChartType type) {
    switch (type) {
      case ChartType.line:
        return PhosphorIcons.chartLine();
      case ChartType.bar:
        return PhosphorIcons.chartBar();
      case ChartType.pie:
        return PhosphorIcons.chartPie();
      case ChartType.donut:
        return PhosphorIcons.chartDonut();
      case ChartType.area:
        return PhosphorIcons.chartLineUp();
    }
  }
}

/// Custom date range picker for analytics
class AnalyticsDateRangePicker extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<DateTimeRange?> onDateRangeChanged;
  final String label;

  const AnalyticsDateRangePicker({
    super.key,
    this.startDate,
    this.endDate,
    required this.onDateRangeChanged,
    this.label = 'Custom Date Range',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDateRange = startDate != null && endDate != null;

    return GlassmorphismContainer(
      level: GlassLevel.whisper,
      padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.calendar(),
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: TypographyConstants.spacingSmall),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontSize: TypographyConstants.titleSmall,
                  fontWeight: TypographyConstants.medium,
                ),
              ),
            ],
          ),
          const SizedBox(height: TypographyConstants.spacingMedium),
          
          Row(
            children: [
              Expanded(
                child: _buildDateButton(
                  context,
                  'Start Date',
                  startDate,
                  () => _selectDate(context, true),
                ),
              ),
              const SizedBox(width: TypographyConstants.spacingSmall),
              Expanded(
                child: _buildDateButton(
                  context,
                  'End Date',
                  endDate,
                  () => _selectDate(context, false),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: TypographyConstants.spacingMedium),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: hasDateRange ? () => onDateRangeChanged(DateTimeRange(start: startDate!, end: endDate!)) : null,
                  icon: Icon(PhosphorIcons.check(), size: 16),
                  label: const Text('Apply Range'),
                ),
              ),
              const SizedBox(width: TypographyConstants.spacingSmall),
              OutlinedButton(
                onPressed: hasDateRange ? () => onDateRangeChanged(null) : null,
                child: const Text('Clear'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton(BuildContext context, String label, DateTime? date, VoidCallback onTap) {
    final theme = Theme.of(context);
    
    return Material(
      color: context.colors.backgroundTransparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
        child: Container(
          padding: const EdgeInsets.all(TypographyConstants.paddingSmall),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date != null ? _formatDate(date) : 'Select date',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: date != null 
                    ? theme.colorScheme.onSurface 
                    : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? startDate : endDate;
    final firstDate = DateTime(2020);
    final lastDate = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      if (isStartDate) {
        onDateRangeChanged(DateTimeRange(
          start: pickedDate,
          end: endDate ?? pickedDate.add(const Duration(days: 30)),
        ));
      } else {
        onDateRangeChanged(DateTimeRange(
          start: startDate ?? pickedDate.subtract(const Duration(days: 30)),
          end: pickedDate,
        ));
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Quick filter buttons for common analytics filters
class AnalyticsQuickFilters extends StatelessWidget {
  final Map<String, bool> activeFilters;
  final ValueChanged<String> onFilterToggled;
  final List<AnalyticsFilter> availableFilters;

  const AnalyticsQuickFilters({
    super.key,
    required this.activeFilters,
    required this.onFilterToggled,
    required this.availableFilters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassmorphismContainer(
      level: GlassLevel.whisper,
      padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.funnel(),
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: TypographyConstants.spacingSmall),
              Text(
                'Filters',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontSize: TypographyConstants.titleSmall,
                  fontWeight: TypographyConstants.medium,
                ),
              ),
            ],
          ),
          const SizedBox(height: TypographyConstants.spacingMedium),
          
          Wrap(
            spacing: TypographyConstants.spacingSmall,
            runSpacing: TypographyConstants.spacingSmall / 2,
            children: availableFilters.map((filter) {
              final isActive = activeFilters[filter.key] ?? false;
              return _buildFilterChip(context, theme, filter, isActive);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    ThemeData theme,
    AnalyticsFilter filter,
    bool isActive,
  ) {
    return Material(
      color: context.colors.backgroundTransparent,
      child: InkWell(
        onTap: () => onFilterToggled(filter.key),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: TypographyConstants.paddingSmall,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: isActive 
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : context.colors.backgroundTransparent,
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            border: Border.all(
              color: isActive 
                ? theme.colorScheme.primary.withValues(alpha: 0.3)
                : theme.colorScheme.outline.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                filter.icon,
                size: 14,
                color: isActive 
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                filter.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isActive 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                  fontWeight: isActive 
                    ? TypographyConstants.medium 
                    : TypographyConstants.regular,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Analytics filter data model
class AnalyticsFilter {
  final String key;
  final String label;
  final IconData icon;
  final String? description;

  const AnalyticsFilter({
    required this.key,
    required this.label,
    required this.icon,
    this.description,
  });
}

/// Common analytics filters
class CommonAnalyticsFilters {
  static final highPriority = AnalyticsFilter(
    key: 'high_priority',
    label: 'High Priority',
    icon: PhosphorIcons.arrowUp(),
    description: 'Show only high and urgent priority tasks',
  );

  static final overdue = AnalyticsFilter(
    key: 'overdue',
    label: 'Overdue',
    icon: PhosphorIcons.warning(),
    description: 'Show only overdue tasks',
  );

  static final completed = AnalyticsFilter(
    key: 'completed',
    label: 'Completed',
    icon: PhosphorIcons.checkCircle(),
    description: 'Show only completed tasks',
  );

  static final inProgress = AnalyticsFilter(
    key: 'in_progress',
    label: 'In Progress',
    icon: PhosphorIcons.playCircle(),
    description: 'Show only tasks in progress',
  );

  static final withDueDate = AnalyticsFilter(
    key: 'with_due_date',
    label: 'With Due Date',
    icon: PhosphorIcons.calendar(),
    description: 'Show only tasks with due dates',
  );

  static final withEstimates = AnalyticsFilter(
    key: 'with_estimates',
    label: 'With Time Estimates',
    icon: PhosphorIcons.clock(),
    description: 'Show only tasks with time estimates',
  );

  static List<AnalyticsFilter> get all => [
    highPriority,
    overdue,
    completed,
    inProgress,
    withDueDate,
    withEstimates,
  ];
}