import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'dart:math' as math;
import '../../domain/entities/task_model.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/models/enums.dart';
import '../providers/enhanced_calendar_provider.dart';
import '../../core/theme/typography_constants.dart';
import '../pages/manual_task_creation_page.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'glassmorphism_container.dart';
import '../../core/design_system/design_tokens.dart';

/// Enhanced calendar widget that integrates tasks and events
class EnhancedCalendarWidget extends ConsumerWidget {
  const EnhancedCalendarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(enhancedCalendarProvider);
    final calendarNotifier = ref.read(enhancedCalendarProvider.notifier);

    return Column(
      children: [
        // Calendar statistics with design system spacing
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xs, vertical: SpacingTokens.xs / 2),
          child: _buildCalendarStats(context, ref),
        ),
        
        const SizedBox(height: SpacingTokens.sm),
        
        // View mode selector with design system padding
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xs),
          child: _buildViewModeSelector(context, calendarState, calendarNotifier),
        ),
        
        const SizedBox(height: SpacingTokens.sm),
        
        // Calendar with enhanced sizing constraints and geometry validation
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Validate available space before rendering calendar
              final availableHeight = constraints.maxHeight;
              final availableWidth = constraints.maxWidth;
              
              // Ensure minimum viable dimensions to prevent geometry errors
              if (availableHeight < 150 || availableWidth < 150) {
                return Container(
                  constraints: BoxConstraints(
                    minHeight: math.max(150, availableHeight),
                    minWidth: math.max(150, availableWidth),
                  ),
                  child: const Center(
                    child: Text(
                      'Calendar needs more space to display properly',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              
              return Container(
                height: availableHeight, // Use all available height
                width: availableWidth, // Use all available width
                padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xs / 2),
                child: _buildCalendarView(context, calendarState, calendarNotifier, ref),
              );
            },
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Selected date details with design system spacing
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xs, vertical: SpacingTokens.xs / 2),
          child: _buildSelectedDateDetails(context, ref, calendarState),
        ),
      ],
    );
  }

  Widget _buildCalendarStats(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(calendarStatsProvider);
    
    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm, vertical: SpacingTokens.xs),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(context, 'Today', stats.todaysTasks.toString(), Theme.of(context).colorScheme.primary),
          _buildStatItem(context, 'Upcoming', stats.upcomingTasks.toString(), Theme.of(context).colorScheme.secondary),
          _buildStatItem(context, 'Overdue', stats.overdueTasks.toString(), Theme.of(context).colorScheme.error),
          _buildStatItem(context, 'Total', stats.totalTasks.toString(), Theme.of(context).colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: TypographyConstants.titleMedium,
            fontWeight: TypographyConstants.medium,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: TypographyConstants.bodySmall,
            fontWeight: TypographyConstants.regular,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildViewModeSelector(
    BuildContext context,
    EnhancedCalendarState state,
    EnhancedCalendarNotifier notifier,
  ) {
    return GlassmorphismContainer(
      level: GlassLevel.interactive,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: CalendarViewMode.values.map((mode) {
          final isSelected = state.viewMode == mode;
          return GestureDetector(
            onTap: () {
              // Prevent rapid view mode switches that could cause duplicate key errors
              if (state.viewMode != mode) {
                notifier.changeViewMode(mode);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.elementPadding, vertical: SpacingTokens.md / 1.3),
              margin: const EdgeInsets.symmetric(horizontal: SpacingTokens.xs / 2),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).colorScheme.primary : null,
                borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
              ),
              child: Text(
                _getViewModeLabel(mode),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: TypographyConstants.labelLarge,
                  color: isSelected 
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? TypographyConstants.medium : TypographyConstants.regular,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getViewModeLabel(CalendarViewMode mode) {
    switch (mode) {
      case CalendarViewMode.month:
        return 'Month';
      case CalendarViewMode.week:
        return 'Week';
      case CalendarViewMode.day:
        return 'Day';
    }
  }

  Widget _buildCalendarView(
    BuildContext context,
    EnhancedCalendarState state,
    EnhancedCalendarNotifier notifier,
    WidgetRef ref,
  ) {
    try {
      final tasksByDate = notifier.getTasksByDate();
      final eventsByDate = notifier.getEventsByDate();
      
      // Task and event count logging for debugging markers
      final totalTasks = tasksByDate.values.fold(0, (sum, tasks) => sum + tasks.length);
      if (totalTasks > 0) {
        debugPrint('Calendar Debug: Loaded $totalTasks tasks with due dates');
      }

      // Convert tasks to calendar appointments with enhanced styling
      final appointments = <Appointment>[];
      
      // Add tasks as appointments with enhanced date normalization and visibility
      for (final entry in tasksByDate.entries) {
        for (final task in entry.value) {
          // Normalize date to ensure exact calendar day matching (crucial for indicators)
          final normalizedDate = DateTime(entry.key.year, entry.key.month, entry.key.day, 12, 0, 0);
          
          final hasSpecificTime = task.dueDate != null && 
            (task.dueDate!.hour != 0 || task.dueDate!.minute != 0);
          
          final taskColor = _getEnhancedTaskColor(task, context);
          
          // Create appointment for calendar display
          
          appointments.add(Appointment(
            startTime: normalizedDate,
            endTime: hasSpecificTime 
              ? normalizedDate.add(const Duration(hours: 2)) // Longer duration for visibility
              : normalizedDate.add(const Duration(hours: 23, minutes: 59)), // Almost full day
            subject: _getTaskDisplayText(task),
            color: taskColor,
            notes: task.description ?? '',
            isAllDay: false, // Force non-all-day for better indicator visibility
            id: task.id,
          ));
        }
      }
      
      // Add events as appointments with enhanced styling
      for (final entry in eventsByDate.entries) {
        for (final event in entry.value) {
          appointments.add(Appointment(
            startTime: event.startTime,
            endTime: event.endTime,
            subject: _getEventDisplayText(event),
            color: Color(int.parse(event.color.replaceFirst('#', '0xFF'))).withValues(alpha: 0.8),
            notes: event.description ?? '',
            isAllDay: event.isAllDay,
            id: event.id, // Add unique ID for event identification
          ));
        }
      }
      
      // Log appointment count for debugging
      if (appointments.isNotEmpty) {
        debugPrint('Calendar Debug: Created ${appointments.length} appointments for display');
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        child: SfCalendar(
          key: ValueKey('calendar_${state.viewMode.name}'), // Stable key that only changes with view mode
          view: _mapViewModeToCalendarView(state.viewMode),
          initialDisplayDate: state.focusedDate,
          initialSelectedDate: state.selectedDate,
          dataSource: MeetingDataSource(appointments),
          
          // Enhanced month view settings with optimized cell space
          monthViewSettings: MonthViewSettings(
            // Always use indicator mode for consistent marker display
            appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
            showAgenda: false, // Disable agenda to give more space to cells
            dayFormat: 'EEE',
            appointmentDisplayCount: 25, // Increased for maximum indicator visibility
            
            // Enhanced indicator styling for better visibility
            
            // Maximize space for indicators
            agendaViewHeight: 0, // Minimize agenda height
            showTrailingAndLeadingDates: true, // Show full month context
            navigationDirection: MonthNavigationDirection.horizontal,
            
            // Force indicator display even for overlapping appointments
            numberOfWeeksInView: 6, // Show full 6-week month view
            monthCellStyle: MonthCellStyle(
              backgroundColor: Theme.of(context).colorScheme.surface,
              leadingDatesBackgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              trailingDatesBackgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              textStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: TypographyConstants.regular,
                fontSize: TypographyConstants.bodyLarge,
              ),
              // todayTextStyle is deprecated and moved to SfCalendar class
              leadingDatesTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                fontWeight: TypographyConstants.regular,
                fontSize: TypographyConstants.bodyMedium,
              ),
              trailingDatesTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                fontWeight: TypographyConstants.regular,
                fontSize: TypographyConstants.bodyMedium,
              ),
            ),
            agendaStyle: AgendaStyle(
              backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
              appointmentTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: TypographyConstants.bodyMedium,
                fontWeight: TypographyConstants.medium,
              ),
              dateTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: TypographyConstants.titleSmall,
                fontWeight: TypographyConstants.medium,
              ),
              dayTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: TypographyConstants.bodyMedium,
                fontWeight: TypographyConstants.regular,
              ),
            ),
          ),
          
          // Enhanced time slot settings for week and day views
          timeSlotViewSettings: TimeSlotViewSettings(
            startHour: 6, // Start at 6 AM
            endHour: 23, // End at 11 PM  
            timeIntervalHeight: 100, // Further increased for better readability
            timeFormat: 'HH:mm',
            timeTextStyle: TextStyle(
              fontSize: TypographyConstants.bodyLarge,
              fontWeight: TypographyConstants.medium,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            timeRulerSize: 85, // Slightly increased time ruler size
          ),
          
          // All-day panel settings
          showCurrentTimeIndicator: true,
          showNavigationArrow: true,
          allowViewNavigation: true,
          headerStyle: CalendarHeaderStyle(
            textAlign: TextAlign.center,
            backgroundColor: Theme.of(context).colorScheme.surface,
            textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: TypographyConstants.titleLarge,
              fontWeight: TypographyConstants.medium,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          headerHeight: 55, // Slightly increased header height
          cellBorderColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          selectionDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1), // Reduced opacity for better text visibility
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 2.0, // Design system standard border width
            ),
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.2),
                blurRadius: 4,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          // Subtle today highlight for better visibility while maintaining design consistency
          todayHighlightColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
          // Use same text style as regular dates for consistency
          todayTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: TypographyConstants.regular,
            fontSize: TypographyConstants.bodyLarge,
          ),
          onTap: (CalendarTapDetails details) {
            if (details.date != null) {
              // Defer state updates to ensure they happen outside build cycle
              // Use microtask to prevent duplicate key issues during rapid taps
              Future.microtask(() {
                if (context.mounted) {
                  try {
                    notifier.selectDate(details.date!);
                    // Only update focused date if it's significantly different
                    if (state.focusedDate.month != details.date!.month ||
                        state.focusedDate.year != details.date!.year) {
                      notifier.changeFocusedDate(details.date!);
                    }
                  } catch (e) {
                    // Ignore errors that occur during widget disposal
                    debugPrint('Calendar tap error (can be safely ignored): $e');
                  }
                }
              });
            }
          },
          onViewChanged: (ViewChangedDetails details) {
            if (details.visibleDates.isNotEmpty) {
              // Defer state update to avoid modifying provider during build
              // Use microtask with additional safety checks to prevent duplicate keys
              Future.microtask(() {
                if (context.mounted) {
                  try {
                    if (details.visibleDates.isNotEmpty) {
                      final newDate = details.visibleDates.first;
                      // Only update if the focused date has actually changed significantly
                      final currentFocused = state.focusedDate;
                      if (newDate.month != currentFocused.month ||
                          newDate.year != currentFocused.year ||
                          (newDate.day != currentFocused.day && 
                           state.viewMode == CalendarViewMode.day)) {
                        notifier.changeFocusedDate(newDate);
                      }
                    }
                  } catch (e) {
                    // Ignore errors that occur during widget disposal or view transitions
                    debugPrint('Calendar view change error (can be safely ignored): $e');
                  }
                }
              });
            }
          }
      ),
      );
    } catch (e) {
      debugPrint('Calendar rendering error: $e');
      return _buildCalendarErrorWidget(context, e.toString(), ref);
    }
  }
  
  Widget _buildCalendarErrorWidget(BuildContext context, String error, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.warningCircle(),
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Calendar Display Error',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: TypographyConstants.titleMedium,
              fontWeight: TypographyConstants.medium,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'The calendar encountered a display error. Please try switching views or refreshing.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: TypographyConstants.bodySmall,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              final notifier = ref.read(enhancedCalendarProvider.notifier);
              notifier.refresh();
            },
            icon: Icon(PhosphorIcons.arrowsClockwise()),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  CalendarView _mapViewModeToCalendarView(CalendarViewMode viewMode) {
    switch (viewMode) {
      case CalendarViewMode.month:
        return CalendarView.month;
      case CalendarViewMode.week:
        return CalendarView.week;
      case CalendarViewMode.day:
        return CalendarView.day;
    }
  }

  Color _getEnhancedTaskColor(TaskModel task, BuildContext context) {
    // Ultra-vibrant colors specifically designed for calendar indicator visibility
    Color baseColor;
    switch (task.priority) {
      case TaskPriority.urgent:
        // Bright red that stands out on any background
        baseColor = const Color(0xFFE53E3E); // Material Red 500
        break;
      case TaskPriority.high:
        // Vibrant orange for high visibility
        baseColor = const Color(0xFFFF8C00); // Dark Orange
        break;
      case TaskPriority.medium:
        // Electric blue for medium priority
        baseColor = const Color(0xFF0066FF); // Bright Blue
        break;
      case TaskPriority.low:
        // Vibrant green for low priority
        baseColor = const Color(0xFF00C851); // Green
        break;
    }
    
    // Always use maximum visibility colors for calendar indicators
    if (task.status == TaskStatus.completed) {
      // Darker but still visible for completed tasks
      return Color.fromARGB(255, 
        (baseColor.r * 255.0 * 0.6).round() & 0xff, 
        (baseColor.g * 255.0 * 0.6).round() & 0xff, 
        (baseColor.b * 255.0 * 0.6).round() & 0xff);
    }
    
    // Maximum saturation and visibility for active tasks
    return baseColor;
  }
  
  String _getTaskDisplayText(TaskModel task) {
    // Add priority and status indicators to improve visibility
    String priorityPrefix = '';
    switch (task.priority) {
      case TaskPriority.urgent:
        priorityPrefix = '[!] ';
        break;
      case TaskPriority.high:
        priorityPrefix = '[H] ';
        break;
      case TaskPriority.medium:
        priorityPrefix = '[M] ';
        break;
      case TaskPriority.low:
        priorityPrefix = '[L] ';
        break;
    }
    
    final String statusPrefix = task.status == TaskStatus.completed ? '[DONE] ' : '';
    
    return '$statusPrefix$priorityPrefix${task.title}';
  }
  
  String _getEventDisplayText(CalendarEvent event) {
    // Add event indicator to distinguish from tasks
    return '[EVENT] ${event.title}';
  }

  Widget _buildSelectedDateDetails(
    BuildContext context,
    WidgetRef ref,
    EnhancedCalendarState state,
  ) {
    final tasks = state.tasksForSelectedDate;
    
    if (tasks.isEmpty) {
      return _buildEmptySelectedDate(context, state.selectedDate, ref);
    }
    
    return Container(
      constraints: const BoxConstraints(maxHeight: 120), // Reduced max height
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tasks for ${_formatDate(state.selectedDate)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: TypographyConstants.titleMedium,
              fontWeight: TypographyConstants.medium,
            ),
          ),
          const SizedBox(height: 8),
          
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return _buildTaskListItem(context, ref, task);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySelectedDate(BuildContext context, DateTime date, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            PhosphorIcons.calendar(),
            size: 32,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'No tasks for ${_formatDate(date)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: TypographyConstants.bodyMedium,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _navigateToTaskCreation(context, ref, date),
            icon: Icon(PhosphorIcons.plus()),
            label: const Text('Add Task'),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskListItem(BuildContext context, WidgetRef ref, TaskModel task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        dense: true,
        leading: IconButton(
          icon: Icon(
            task.status == TaskStatus.completed
                ? PhosphorIcons.checkCircle()
                : PhosphorIcons.circle(),
            color: task.status == TaskStatus.completed
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.primary,
          ),
          onPressed: () {
            if (task.status != TaskStatus.completed) {
              ref.read(enhancedCalendarProvider.notifier).completeTask(task.id);
            }
          },
        ),
        title: Text(
          task.title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: TypographyConstants.bodyLarge,
            fontWeight: TypographyConstants.regular,
            decoration: task.status == TaskStatus.completed
                ? TextDecoration.lineThrough
                : null,
          ),
        ),
        subtitle: task.description?.isNotEmpty == true
            ? Text(
                task.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: TypographyConstants.bodySmall,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              )
            : null,
        trailing: _buildPriorityIndicator(context, task.priority),
      ),
    );
  }

  Widget _buildPriorityIndicator(BuildContext context, TaskPriority priority) {
    Color color;
    IconData icon;
    
    switch (priority) {
      case TaskPriority.low:
        color = Theme.of(context).colorScheme.secondary;
        icon = PhosphorIcons.caretDown();
        break;
      case TaskPriority.medium:
        color = Theme.of(context).colorScheme.primary;
        icon = PhosphorIcons.minus();
        break;
      case TaskPriority.high:
        color = Theme.of(context).colorScheme.errorContainer;
        icon = PhosphorIcons.caretUp();
        break;
      case TaskPriority.urgent:
        color = Theme.of(context).colorScheme.error;
        icon = PhosphorIcons.arrowUp();
        break;
    }
    
    return Icon(icon, color: color, size: 16);
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _navigateToTaskCreation(BuildContext context, WidgetRef ref, DateTime date) {
    // Navigate to manual task creation page with the selected date
    final dateString = date.toIso8601String();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManualTaskCreationPage(
          prePopulatedData: {
            'dueDate': dateString,
            'creationMode': 'calendar',
          },
        ),
      ),
    );
  }
}


/// Data source for Syncfusion Calendar
class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].startTime;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].endTime;
  }

  @override
  String getSubject(int index) {
    return appointments![index].subject;
  }

  @override
  Color getColor(int index) {
    return appointments![index].color;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}