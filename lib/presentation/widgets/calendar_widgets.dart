import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../providers/calendar_provider.dart' as calendar;
import '../providers/task_providers.dart';
import '../../core/theme/typography_constants.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Main calendar widget with month/week/day views
class CalendarWidget extends ConsumerWidget {
  const CalendarWidget({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendar.calendarProvider);
    final calendarNotifier = ref.read(calendar.calendarProvider.notifier);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.65, // Optimized height for better proportions
      child: Column(
        children: [
          // Calendar view mode selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _CalendarViewModeSelector(),
          ),
          const SizedBox(height: 12),
          
          // Calendar widget
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildCalendarView(context, calendarState, calendarNotifier),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarView(
    BuildContext context,
    calendar.CalendarState state,
    calendar.CalendarNotifier notifier,
  ) {
    switch (state.viewMode) {
      case calendar.CalendarViewMode.month:
        return _MonthCalendarView(state: state, notifier: notifier);
      case calendar.CalendarViewMode.week:
        return _WeekCalendarViewSyncfusion(state: state, notifier: notifier);
      case calendar.CalendarViewMode.day:
        return _DayCalendarView(state: state, notifier: notifier);
    }
  }
}

/// Calendar view mode selector
class _CalendarViewModeSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendar.calendarProvider);
    final calendarNotifier = ref.read(calendar.calendarProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Today button - compact
        TextButton(
          onPressed: () => calendarNotifier.goToToday(),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: const Size(60, 32),
          ),
          child: Text('Today', style: Theme.of(context).textTheme.bodySmall),
        ),
        
        const SizedBox(width: 8),
        
        // View mode buttons - compact
        Expanded(
          child: SizedBox(
            height: 32, // Reduced height
            child: SegmentedButton<calendar.CalendarViewMode>(
              segments: [
                ButtonSegment(
                  value: calendar.CalendarViewMode.month,
                  label: Text('Month', style: Theme.of(context).textTheme.labelSmall), // Tab label
                ),
                ButtonSegment(
                  value: calendar.CalendarViewMode.week,
                  label: Text('Week', style: Theme.of(context).textTheme.labelSmall), // Tab label
                ),
                ButtonSegment(
                  value: calendar.CalendarViewMode.day,
                  label: Text('Day', style: Theme.of(context).textTheme.labelSmall), // Tab label
                ),
              ],
              selected: {calendarState.viewMode},
              onSelectionChanged: (Set<calendar.CalendarViewMode> selection) {
                calendarNotifier.changeViewMode(selection.first);
              },
              style: ButtonStyle(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                minimumSize: WidgetStateProperty.all(const Size(60, 40)),
                padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Month calendar view
class _MonthCalendarView extends ConsumerWidget {
  final calendar.CalendarState state;
  final calendar.CalendarNotifier notifier;

  const _MonthCalendarView({
    required this.state,
    required this.notifier,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointments = <Appointment>[];
    
    // Add events as appointments
    for (final event in state.events) {
      appointments.add(Appointment(
        startTime: event.startTime,
        endTime: event.endTime,
        subject: event.title,
        color: Color(int.parse(event.color.replaceFirst('#', '0xFF'))),
        isAllDay: event.isAllDay,
        notes: event.description,
        location: event.location,
        id: event.id,
      ));
    }
    
    // Add tasks as appointments
    final allTasksAsync = ref.watch(tasksProvider);
    allTasksAsync.whenData((allTasks) {
      for (final task in allTasks) {
        if (task.dueDate != null) {
          appointments.add(Appointment(
            startTime: task.dueDate!,
            endTime: task.dueDate!.add(const Duration(hours: 1)),
            subject: task.title,
            color: _getPriorityColor(task.priority),
            notes: task.description,
            id: task.id,
          ));
        }
      }
    });
    
    return SfCalendar(
      view: CalendarView.month,
      initialDisplayDate: state.focusedDate,
      initialSelectedDate: state.selectedDate,
      dataSource: MeetingDataSource(appointments),
      firstDayOfWeek: 1, // Monday
      headerStyle: const CalendarHeaderStyle(
        textAlign: TextAlign.center,
      ),
      monthViewSettings: const MonthViewSettings(
        appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
        showAgenda: false,
        appointmentDisplayCount: 3,
      ),
      onTap: (CalendarTapDetails details) {
        if (details.date != null) {
          notifier.selectDate(details.date!);
          notifier.changeFocusedDate(details.date!);
        }
      },
      onViewChanged: (ViewChangedDetails details) {
        if (details.visibleDates.isNotEmpty) {
          notifier.changeFocusedDate(details.visibleDates.first);
        }
      },
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return const Color(0xFFFF1744); // Bright red
      case TaskPriority.high:
        return const Color(0xFFFF9100); // Orange
      case TaskPriority.medium:
        return const Color(0xFF2196F3); // Blue
      case TaskPriority.low:
        return const Color(0xFF4CAF50); // Green
    }
  }
}

/// Meeting data source for Syncfusion Calendar
class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }
}

class _WeekCalendarViewSyncfusion extends ConsumerWidget {
  final calendar.CalendarState state;
  final calendar.CalendarNotifier notifier;

  const _WeekCalendarViewSyncfusion({
    required this.state,
    required this.notifier,
  });

  MeetingDataSource _getWeekDataSource(WidgetRef ref, calendar.CalendarState state, calendar.CalendarNotifier notifier) {
    final appointments = <Appointment>[];
    
    // Add events as appointments
    for (final event in state.events) {
      appointments.add(Appointment(
        startTime: event.startTime,
        endTime: event.endTime,
        subject: event.title,
        color: Color(int.parse(event.color.replaceFirst('#', '0xFF'))),
        isAllDay: event.isAllDay,
        notes: event.description,
        location: event.location,
        id: event.id,
      ));
    }
    
    // Add tasks as appointments
    final allTasksAsync = ref.watch(tasksProvider);
    allTasksAsync.whenData((allTasks) {
      for (final task in allTasks) {
        if (task.dueDate != null) {
          appointments.add(Appointment(
            startTime: task.dueDate!,
            endTime: task.dueDate!.add(const Duration(hours: 1)),
            subject: task.title,
            color: _getPriorityColor(task.priority),
            notes: task.description,
            id: task.id,
          ));
        }
      }
    });
    
    return MeetingDataSource(appointments);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SfCalendar(
      view: CalendarView.week,
      initialDisplayDate: state.focusedDate,
      initialSelectedDate: state.selectedDate,
      dataSource: _getWeekDataSource(ref, state, notifier),
      firstDayOfWeek: 1,
      headerStyle: const CalendarHeaderStyle(
        textAlign: TextAlign.center,
      ),
      onTap: (CalendarTapDetails details) {
        if (details.date != null) {
          notifier.selectDate(details.date!);
          notifier.changeFocusedDate(details.date!);
        }
      },
      onViewChanged: (ViewChangedDetails details) {
        if (details.visibleDates.isNotEmpty) {
          notifier.changeFocusedDate(details.visibleDates.first);
        }
      },
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return const Color(0xFFFF1744); // Bright red
      case TaskPriority.high:
        return const Color(0xFFFF9100); // Orange
      case TaskPriority.medium:
        return const Color(0xFF2196F3); // Blue
      case TaskPriority.low:
        return const Color(0xFF4CAF50); // Green
    }
  }
}


/// Day calendar view
class _DayCalendarView extends StatelessWidget {
  final calendar.CalendarState state;
  final calendar.CalendarNotifier notifier;

  const _DayCalendarView({
    required this.state,
    required this.notifier,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Day header
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  final previousDay = state.selectedDate.subtract(const Duration(days: 1));
                  notifier.selectDate(previousDay);
                  notifier.changeFocusedDate(previousDay);
                },
                icon: Icon(PhosphorIcons.caretLeft()),
              ),
              Text(
                _formatDayHeader(state.selectedDate),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              IconButton(
                onPressed: () {
                  final nextDay = state.selectedDate.add(const Duration(days: 1));
                  notifier.selectDate(nextDay);
                  notifier.changeFocusedDate(nextDay);
                },
                icon: Icon(PhosphorIcons.caretRight()),
              ),
            ],
          ),
        ),
        
        // Day events
        Expanded(
          child: _DayEventsView(
            date: state.selectedDate,
            events: state.selectedDateEvents,
          ),
        ),
      ],
    );
  }

  String _formatDayHeader(DateTime date) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }
}

// Removed unused _WeekEventsView class

/// Day events view with time slots - Enhanced to show both events and tasks
class _DayEventsView extends ConsumerWidget {
  final DateTime date;
  final List<CalendarEvent> events;

  const _DayEventsView({
    required this.date,
    required this.events,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get tasks for this specific date
    final allTasksAsync = ref.watch(tasksProvider);
    final dayTasks = allTasksAsync.maybeWhen(
      data: (allTasks) => allTasks.where((task) {
        if (task.dueDate == null) return false;
        final taskDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
        final targetDate = DateTime(date.year, date.month, date.day);
        return taskDate.isAtSameMomentAs(targetDate);
      }).toList(),
      orElse: () => <TaskModel>[],
    );

    // Combine events and tasks
    final allItems = <dynamic>[...events, ...dayTasks];

    if (allItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.calendar(),
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks or events today',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    // Sort all items by time (events by start time, tasks by due date)
    allItems.sort((a, b) {
      final aTime = a is CalendarEvent ? a.startTime : (a as TaskModel).dueDate!;
      final bTime = b is CalendarEvent ? b.startTime : (b as TaskModel).dueDate!;
      return aTime.compareTo(bTime);
    });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: allItems.length,
      itemBuilder: (context, index) {
        final item = allItems[index];
        if (item is CalendarEvent) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: EventCard(event: item, showTime: true),
          );
        } else if (item is TaskModel) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TaskEventCard(task: item, showTime: true),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

/// Event card widget
class EventCard extends ConsumerWidget {
  final CalendarEvent event;
  final bool showTime;
  final VoidCallback? onTap;

  const EventCard({
    super.key,
    required this.event,
    this.showTime = false,
    this.onTap,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: onTap ?? () => _showEventDetails(context, ref),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            border: Border(
              left: BorderSide(
                width: 4,
                color: Color(int.parse(event.color.replaceFirst('#', '0xFF'))),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      event.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (event.isAllDay)
                    Chip(
                      label: const Text('All Day'),
                      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    ),
                ],
              ),
              
              if (showTime && !event.isAllDay) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      PhosphorIcons.clock(),
                      size: 16,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
              
              if (event.description != null && event.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  event.description!,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              if (event.location != null && event.location!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      PhosphorIcons.mapPin(),
                      size: 16,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.location!,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _showEventDetails(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => EventDetailsDialog(event: event),
    );
  }
}

/// Event details dialog
class EventDetailsDialog extends ConsumerWidget {
  final CalendarEvent event;

  const EventDetailsDialog({super.key, required this.event});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text(event.title),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (event.description != null && event.description!.isNotEmpty) ...[
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(event.description!),
              const SizedBox(height: 16),
            ],
            
            Text(
              'Time',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              event.isAllDay
                  ? 'All Day'
                  : '${_formatDateTime(event.startTime)} - ${_formatDateTime(event.endTime)}',
            ),
            
            if (event.location != null && event.location!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Location',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(event.location!),
            ],
            
            if (event.attendees.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Attendees',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              ...event.attendees.map((attendee) => Text('• $attendee')),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        if (event.taskId != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to task details
              _navigateToTask(context, ref, event.taskId!);
            },
            child: const Text('View Task'),
          ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final date = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    final time = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }

  void _navigateToTask(BuildContext context, WidgetRef ref, String taskId) {
    // This would navigate to the task details screen
    // Implementation depends on your navigation setup
  }
}

/// Task scheduling widget for creating events from tasks
class TaskSchedulingWidget extends ConsumerStatefulWidget {
  final TaskModel task;
  final VoidCallback? onScheduled;

  const TaskSchedulingWidget({
    super.key,
    required this.task,
    this.onScheduled,
  });
  @override
  ConsumerState<TaskSchedulingWidget> createState() => _TaskSchedulingWidgetState();
}

class _TaskSchedulingWidgetState extends ConsumerState<TaskSchedulingWidget> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay startTime = TimeOfDay.now();
  TimeOfDay endTime = TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);
  bool isAllDay = false;
  @override
  Widget build(BuildContext context) {
    final calendarNotifier = ref.read(calendar.calendarProvider.notifier);

    return AlertDialog(
      title: Text('Schedule: ${widget.task.title}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Date picker
            ListTile(
              leading: Icon(PhosphorIcons.calendar()),
              title: const Text('Date'),
              subtitle: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => selectedDate = date);
                }
              },
            ),
            
            // All day toggle
            SwitchListTile(
              title: const Text('All Day'),
              value: isAllDay,
              onChanged: (value) => setState(() => isAllDay = value),
            ),
            
            if (!isAllDay) ...[
              // Start time picker
              ListTile(
                leading: Icon(PhosphorIcons.clock()),
                title: const Text('Start Time'),
                subtitle: Text(startTime.format(context)),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: startTime,
                  );
                  if (time != null) {
                    setState(() => startTime = time);
                  }
                },
              ),
              
              // End time picker
              ListTile(
                leading: Icon(PhosphorIcons.clock()),
                title: const Text('End Time'),
                subtitle: Text(endTime.format(context)),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: endTime,
                  );
                  if (time != null) {
                    setState(() => endTime = time);
                  }
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final navigator = Navigator.of(context);
            await _scheduleTask(calendarNotifier);
            if (mounted) {
              navigator.pop();
              widget.onScheduled?.call();
            }
          },
          child: const Text('Schedule'),
        ),
      ],
    );
  }

  Future<void> _scheduleTask(calendar.CalendarNotifier calendarNotifier) async {
    final DateTime startDateTime;
    final DateTime endDateTime;

    if (isAllDay) {
      startDateTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      endDateTime = startDateTime.add(const Duration(days: 1));
    } else {
      startDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        startTime.hour,
        startTime.minute,
      );
      endDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        endTime.hour,
        endTime.minute,
      );
    }

    final event = CalendarEvent.create(
      taskId: widget.task.id,
      title: widget.task.title,
      description: widget.task.description,
      startTime: startDateTime,
      endTime: endDateTime,
      isAllDay: isAllDay,
      color: _getColorForPriority(widget.task.priority),
    );

    await calendarNotifier.addEvent(event);
  }

  String _getColorForPriority(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return '#F44336';
      case TaskPriority.high:
        return '#FF9800';
      case TaskPriority.medium:
        return '#2196F3';
      case TaskPriority.low:
        return '#4CAF50';
    }
  }
}

/// Task event card widget for displaying tasks in calendar views
class TaskEventCard extends ConsumerWidget {
  final TaskModel task;
  final bool showTime;
  final VoidCallback? onTap;

  const TaskEventCard({
    super.key,
    required this.task,
    this.showTime = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      elevation: 2,
      child: InkWell(
        onTap: onTap ?? () => _showTaskDetails(context, ref),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            border: Border(
              left: BorderSide(
                width: 4,
                color: _getPriorityColor(task.priority),
              ),
            ),
            // Enhanced glow for task cards
            boxShadow: [
              BoxShadow(
                color: _getPriorityColor(task.priority).withValues(alpha: 0.2),
                blurRadius: 4,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Enhanced status indicator with stronger visibility
                  Container(
                    width: task.priority == TaskPriority.urgent ? 16 : 14,
                    height: task.priority == TaskPriority.urgent ? 16 : 14,
                    decoration: BoxDecoration(
                      color: _getStatusColor(task.status),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _getStatusColor(task.status).withValues(alpha: 0.8),
                        width: 2,
                      ),
                      // Multi-layer glow effects for maximum visibility
                      boxShadow: [
                        // Outer glow
                        BoxShadow(
                          color: _getStatusColor(task.status).withValues(alpha: 0.6),
                          blurRadius: task.status == TaskStatus.inProgress ? 8 : 6,
                          spreadRadius: task.status == TaskStatus.inProgress ? 2 : 1,
                        ),
                        // Inner glow
                        BoxShadow(
                          color: _getStatusColor(task.status).withValues(alpha: 0.4),
                          blurRadius: 3,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        decoration: task.status == TaskStatus.completed 
                          ? TextDecoration.lineThrough 
                          : null,
                      ),
                    ),
                  ),
                  // Priority badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(task.priority).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard), // 8.0 - Fixed border radius hierarchy
                      border: Border.all(
                        color: _getPriorityColor(task.priority),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      task.priority.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: TypographyConstants.labelSmall, // 11.0 - Fixed critical WCAG violation (was 10px)
                        fontWeight: FontWeight.w500,
                        color: _getPriorityColor(task.priority),
                      ),
                    ),
                  ),
                ],
              ),

              if (showTime && task.dueDate != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      PhosphorIcons.clock(),
                      size: 16,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Due: ${_formatTime(task.dueDate!)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],

              if (task.description != null && task.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  task.description!,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Tags
              if (task.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: task.tags.take(3).map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard), // 8.0 - Fixed border radius hierarchy
                    ),
                    child: Text(
                      '#$tag',
                      style: TextStyle(
                        fontSize: TypographyConstants.labelSmall, // 11.0 - Fixed critical WCAG violation (was 10px)
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return const Color(0xFFFF1744); // Bright red
      case TaskPriority.high:
        return const Color(0xFFFF9100); // Orange
      case TaskPriority.medium:
        return const Color(0xFF2196F3); // Blue
      case TaskPriority.low:
        return const Color(0xFF4CAF50); // Green
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return const Color(0xFFFF9800); // Orange
      case TaskStatus.inProgress:
        return const Color(0xFF2196F3); // Blue
      case TaskStatus.completed:
        return const Color(0xFF4CAF50); // Green
      case TaskStatus.cancelled:
        return const Color(0xFFFF1744); // Red
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _showTaskDetails(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => TaskDetailsDialog(task: task),
    );
  }
}

/// Task details dialog
class TaskDetailsDialog extends ConsumerWidget {
  final TaskModel task;

  const TaskDetailsDialog({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text(task.title),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (task.description != null && task.description!.isNotEmpty) ...[
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(task.description!),
              const SizedBox(height: 16),
            ],

            Text(
              'Priority',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(task.priority.name.toUpperCase()),

            if (task.dueDate != null) ...[
              const SizedBox(height: 16),
              Text(
                'Due Date',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(_formatDateTime(task.dueDate!)),
            ],

            if (task.tags.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Tags',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children: task.tags.map((tag) => Chip(
                  label: Text('#$tag'),
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                )).toList(),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final date = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    final time = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }
}


