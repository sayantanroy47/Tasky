import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/typography_constants.dart';
import '../../../core/design_system/design_tokens.dart';
import '../../../domain/entities/timeline_settings.dart';
import '../glassmorphism_container.dart';

/// Timeline header showing date navigation and time periods
/// 
/// Features:
/// - Multi-level date display (e.g., months/weeks, weeks/days)
/// - Responsive date formatting based on zoom level
/// - Interactive date selection
/// - Weekend highlighting
/// - Working hours visualization
/// - Smooth scrolling synchronization
class TimelineHeader extends StatefulWidget {
  /// Start date of the visible timeline
  final DateTime startDate;
  
  /// End date of the visible timeline  
  final DateTime endDate;
  
  /// Timeline display settings
  final TimelineSettings settings;
  
  /// Horizontal scroll controller to synchronize with
  final ScrollController? scrollController;
  
  /// Callback when a date is tapped
  final void Function(DateTime date)? onDateTap;
  
  /// Height of the header
  final double? height;

  const TimelineHeader({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.settings,
    this.scrollController,
    this.onDateTap,
    this.height,
  });

  @override
  State<TimelineHeader> createState() => _TimelineHeaderState();
}

class _TimelineHeaderState extends State<TimelineHeader> {
  late ScrollController _headerScrollController;
  bool _isScrollingSynced = true;

  @override
  void initState() {
    super.initState();
    _initializeScrollController();
  }

  void _initializeScrollController() {
    _headerScrollController = ScrollController();
    
    // Sync with provided scroll controller
    if (widget.scrollController != null) {
      widget.scrollController!.addListener(_onExternalScroll);
    }
    
    _headerScrollController.addListener(_onHeaderScroll);
  }

  void _onExternalScroll() {
    if (!_isScrollingSynced) return;
    
    if (widget.scrollController!.hasClients && _headerScrollController.hasClients) {
      _isScrollingSynced = false;
      _headerScrollController.jumpTo(widget.scrollController!.offset);
      _isScrollingSynced = true;
    }
  }

  void _onHeaderScroll() {
    if (!_isScrollingSynced) return;
    
    if (widget.scrollController != null && 
        widget.scrollController!.hasClients && 
        _headerScrollController.hasClients) {
      _isScrollingSynced = false;
      widget.scrollController!.jumpTo(_headerScrollController.offset);
      _isScrollingSynced = true;
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onExternalScroll);
    _headerScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassmorphismContainer(
      level: GlassLevel.interactive,
      height: widget.height ?? widget.settings.headerHeight,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Primary time period row
          _buildPrimaryTimePeriodRow(),
          
          // Secondary time period row
          _buildSecondaryTimePeriodRow(),
        ],
      ),
    );
  }

  Widget _buildPrimaryTimePeriodRow() {
    return Expanded(
      flex: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: SingleChildScrollView(
          controller: _headerScrollController,
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          child: SizedBox(
            width: _calculateTimelineWidth(),
            child: _buildPrimaryPeriods(),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryTimePeriodRow() {
    return Expanded(
      flex: 1,
      child: SingleChildScrollView(
        controller: _headerScrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: SizedBox(
          width: _calculateTimelineWidth(),
          child: _buildSecondaryPeriods(),
        ),
      ),
    );
  }

  Widget _buildPrimaryPeriods() {
    final periods = _getPrimaryTimePeriods();
    
    return Row(
      children: periods.map((period) {
        return _buildPrimaryPeriodCell(period);
      }).toList(),
    );
  }

  Widget _buildSecondaryPeriods() {
    final periods = _getSecondaryTimePeriods();
    
    return Row(
      children: periods.map((period) {
        return _buildSecondaryPeriodCell(period);
      }).toList(),
    );
  }

  Widget _buildPrimaryPeriodCell(TimePeriod period) {
    return Container(
      width: period.width,
      height: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Center(
        child: Text(
          period.label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: TypographyConstants.medium,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildSecondaryPeriodCell(TimePeriod period) {
    final isWeekend = _isWeekend(period.startDate);
    final isToday = _isToday(period.startDate);
    final isPast = period.startDate.isBefore(DateTime.now());
    
    return GestureDetector(
      onTap: () => widget.onDateTap?.call(period.startDate),
      child: Container(
        width: period.width,
        height: double.infinity,
        decoration: BoxDecoration(
          color: _getCellBackgroundColor(isWeekend, isToday, isPast),
          border: Border(
            right: BorderSide(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Date number or label
            Text(
              period.label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isToday ? TypographyConstants.medium : TypographyConstants.regular,
                color: _getCellTextColor(isWeekend, isToday, isPast),
              ),
              textAlign: TextAlign.center,
            ),
            
            // Day of week for day view
            if (widget.settings.zoomLevel == TimelineZoom.days || 
                widget.settings.zoomLevel == TimelineZoom.hours) ...[
              const SizedBox(height: 2),
              Text(
                DateFormat.E().format(period.startDate),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: _getCellTextColor(isWeekend, isToday, isPast)?.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            // Today indicator
            if (isToday) ...[
              const SizedBox(height: 2),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color? _getCellBackgroundColor(bool isWeekend, bool isToday, bool isPast) {
    if (isToday) {
      return Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3);
    } else if (isWeekend && !widget.settings.showWeekends) {
      return Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
    } else if (isWeekend) {
      return Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2);
    }
    return null;
  }

  Color? _getCellTextColor(bool isWeekend, bool isToday, bool isPast) {
    if (isToday) {
      return Theme.of(context).colorScheme.primary;
    } else if (isWeekend) {
      return Theme.of(context).colorScheme.onSurfaceVariant;
    } else if (isPast) {
      return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    }
    return Theme.of(context).colorScheme.onSurface;
  }

  List<TimePeriod> _getPrimaryTimePeriods() {
    final periods = <TimePeriod>[];
    
    switch (widget.settings.zoomLevel) {
      case TimelineZoom.hours:
        // Show days
        DateTime current = DateTime(
          widget.startDate.year,
          widget.startDate.month,
          widget.startDate.day,
        );
        
        while (current.isBefore(widget.endDate)) {
          final nextDay = current.add(const Duration(days: 1));
          final width = _calculateDayWidth();
          
          periods.add(TimePeriod(
            startDate: current,
            endDate: nextDay,
            label: DateFormat('MMM d').format(current),
            width: width,
          ));
          
          current = nextDay;
        }
        break;
        
      case TimelineZoom.days:
        // Show weeks  
        DateTime current = _getWeekStart(widget.startDate);
        
        while (current.isBefore(widget.endDate)) {
          final nextWeek = current.add(const Duration(days: 7));
          final width = _calculateWeekWidth();
          
          periods.add(TimePeriod(
            startDate: current,
            endDate: nextWeek,
            label: 'Week of ${DateFormat('MMM d').format(current)}',
            width: width,
          ));
          
          current = nextWeek;
        }
        break;
        
      case TimelineZoom.weeks:
        // Show months
        DateTime current = DateTime(widget.startDate.year, widget.startDate.month, 1);
        
        while (current.isBefore(widget.endDate)) {
          final nextMonth = DateTime(current.year, current.month + 1, 1);
          final width = _calculateMonthWidth(current);
          
          periods.add(TimePeriod(
            startDate: current,
            endDate: nextMonth,
            label: DateFormat('MMMM yyyy').format(current),
            width: width,
          ));
          
          current = nextMonth;
        }
        break;
        
      case TimelineZoom.months:
        // Show quarters
        DateTime current = DateTime(widget.startDate.year, 1, 1);
        
        while (current.isBefore(widget.endDate)) {
          final nextYear = DateTime(current.year + 1, 1, 1);
          final width = _calculateYearWidth(current);
          
          periods.add(TimePeriod(
            startDate: current,
            endDate: nextYear,
            label: current.year.toString(),
            width: width,
          ));
          
          current = nextYear;
        }
        break;
    }
    
    return periods;
  }

  List<TimePeriod> _getSecondaryTimePeriods() {
    final periods = <TimePeriod>[];
    
    switch (widget.settings.zoomLevel) {
      case TimelineZoom.hours:
        // Show hours
        DateTime current = DateTime(
          widget.startDate.year,
          widget.startDate.month,
          widget.startDate.day,
          widget.startDate.hour,
        );
        
        while (current.isBefore(widget.endDate)) {
          final nextHour = current.add(const Duration(hours: 1));
          final width = widget.settings.pixelsPerTimeUnit;
          
          periods.add(TimePeriod(
            startDate: current,
            endDate: nextHour,
            label: DateFormat('H').format(current),
            width: width,
          ));
          
          current = nextHour;
        }
        break;
        
      case TimelineZoom.days:
        // Show days
        DateTime current = DateTime(
          widget.startDate.year,
          widget.startDate.month,
          widget.startDate.day,
        );
        
        while (current.isBefore(widget.endDate)) {
          final nextDay = current.add(const Duration(days: 1));
          final width = widget.settings.pixelsPerTimeUnit;
          
          periods.add(TimePeriod(
            startDate: current,
            endDate: nextDay,
            label: current.day.toString(),
            width: width,
          ));
          
          current = nextDay;
        }
        break;
        
      case TimelineZoom.weeks:
        // Show weeks
        DateTime current = _getWeekStart(widget.startDate);
        
        while (current.isBefore(widget.endDate)) {
          final nextWeek = current.add(const Duration(days: 7));
          final width = widget.settings.pixelsPerTimeUnit;
          
          final weekNumber = _getWeekOfYear(current);
          periods.add(TimePeriod(
            startDate: current,
            endDate: nextWeek,
            label: 'W$weekNumber',
            width: width,
          ));
          
          current = nextWeek;
        }
        break;
        
      case TimelineZoom.months:
        // Show months
        DateTime current = DateTime(widget.startDate.year, widget.startDate.month, 1);
        
        while (current.isBefore(widget.endDate)) {
          final nextMonth = DateTime(current.year, current.month + 1, 1);
          final width = _calculateMonthWidthForMonthView(current);
          
          periods.add(TimePeriod(
            startDate: current,
            endDate: nextMonth,
            label: DateFormat('MMM').format(current),
            width: width,
          ));
          
          current = nextMonth;
        }
        break;
    }
    
    return periods;
  }

  // Utility methods
  double _calculateTimelineWidth() {
    final duration = widget.endDate.difference(widget.startDate);
    return (duration.inMilliseconds / widget.settings.timeUnit.inMilliseconds) * 
           widget.settings.pixelsPerTimeUnit;
  }

  double _calculateDayWidth() {
    return 24 * widget.settings.pixelsPerTimeUnit; // 24 hours per day
  }

  double _calculateWeekWidth() {
    return 7 * widget.settings.pixelsPerTimeUnit; // 7 days per week
  }

  double _calculateMonthWidth(DateTime month) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    return (daysInMonth * widget.settings.pixelsPerTimeUnit) / 7; // Convert to weeks
  }

  double _calculateMonthWidthForMonthView(DateTime month) {
    return widget.settings.pixelsPerTimeUnit; // Each month gets one unit
  }

  double _calculateYearWidth(DateTime year) {
    return 12 * widget.settings.pixelsPerTimeUnit; // 12 months per year
  }

  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  int _getWeekOfYear(DateTime date) {
    final yearStart = DateTime(date.year, 1, 1);
    final weekStart = _getWeekStart(date);
    return ((weekStart.difference(yearStart).inDays) / 7).floor() + 1;
  }

  bool _isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}

/// Represents a time period in the timeline header
class TimePeriod {
  final DateTime startDate;
  final DateTime endDate;
  final String label;
  final double width;

  const TimePeriod({
    required this.startDate,
    required this.endDate,
    required this.label,
    required this.width,
  });
}