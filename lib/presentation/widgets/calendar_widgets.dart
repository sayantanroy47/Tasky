import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../providers/calendar_provider.dart';
import '../providers/task_providers.dart';
import '../../core/theme/typography_constants.dart';

/// Main calendar widget with month/week/day views
class CalendarWidget extends ConsumerWidget {
  const CalendarWidget({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarProvider);
    final calendarNotifier = ref.read(calendarProvider.notifier);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75, // Fixed height to prevent layout issues
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
    CalendarState state,
    CalendarNotifier notifier,
  ) {
    switch (state.viewMode) {
      case CalendarViewMode.month:
        return _MonthCalendarView(state: state, notifier: notifier);
      case CalendarViewMode.week:
        return _WeekCalendarView(state: state, notifier: notifier);
      case CalendarViewMode.day:
        return _DayCalendarView(state: state, notifier: notifier);
    }
  }
}

/// Calendar view mode selector
class _CalendarViewModeSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarProvider);
    final calendarNotifier = ref.read(calendarProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Today button
        Flexible(
          child: TextButton.icon(
            onPressed: () => calendarNotifier.goToToday(),
            icon: const Icon(Icons.today),
            label: const Text('Today'),
          ),
        ),
        
        // View mode buttons - optimized height and sizing
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 36, // Reduced height to better match content
            child: SegmentedButton<CalendarViewMode>(
              segments: [
                ButtonSegment(
                  value: CalendarViewMode.month,
                  label: Text('Month', style: TextStyle(fontSize: TypographyConstants.labelMedium)),
                  icon: Icon(Icons.calendar_view_month, size: 16),
                ),
                ButtonSegment(
                  value: CalendarViewMode.week,
                  label: Text('Week', style: TextStyle(fontSize: TypographyConstants.labelMedium)),
                  icon: Icon(Icons.calendar_view_week, size: 16),
                ),
                ButtonSegment(
                  value: CalendarViewMode.day,
                  label: Text('Day', style: TextStyle(fontSize: TypographyConstants.labelMedium)),
                  icon: Icon(Icons.calendar_view_day, size: 16),
                ),
              ],
              selected: {calendarState.viewMode},
              onSelectionChanged: (Set<CalendarViewMode> selection) {
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
  final CalendarState state;
  final CalendarNotifier notifier;

  const _MonthCalendarView({
    required this.state,
    required this.notifier,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TableCalendar<CalendarEvent>(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: state.focusedDate,
      selectedDayPredicate: (day) => isSameDay(day, state.selectedDate),
      calendarFormat: state.calendarFormat,
      eventLoader: (day) => notifier.getEventsForDate(day),
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        weekendTextStyle: TextStyle(color: Theme.of(context).colorScheme.error),
        holidayTextStyle: TextStyle(color: Theme.of(context).colorScheme.errorContainer),
        markerDecoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        leftChevronIcon: Icon(Icons.chevron_left),
        rightChevronIcon: Icon(Icons.chevron_right),
      ),
      onDaySelected: (selectedDay, focusedDay) {
        notifier.selectDate(selectedDay);
        notifier.changeFocusedDate(focusedDay);
      },
      onPageChanged: (focusedDay) {
        notifier.changeFocusedDate(focusedDay);
      },
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          return _buildTaskDots(context, ref, date, events, notifier);
        },
      ),
    );
  }

  Widget? _buildTaskDots(BuildContext context, WidgetRef ref, DateTime date, List<CalendarEvent> events, CalendarNotifier notifier) {
    // Get tasks for this date
    final allTasksAsync = ref.watch(tasksProvider);
    final tasksForDate = allTasksAsync.maybeWhen(
      data: (allTasks) => allTasks.where((task) {
        if (task.dueDate == null) return false;
        final taskDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
        final targetDate = DateTime(date.year, date.month, date.day);
        return taskDate.isAtSameMomentAs(targetDate);
      }).toList(),
      orElse: () => <TaskModel>[],
    );
    
    // Combine events and tasks
    final allItems = <dynamic>[...events, ...tasksForDate];
    
    if (allItems.isEmpty) return null;

    // Limit to 3 dots maximum to avoid overcrowding
    final displayItems = allItems.take(3).toList();
    
    return Positioned(
      right: 1,
      bottom: 1,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: displayItems.map((item) {
          Color dotColor;
          
          if (item is CalendarEvent) {
            // Use event color
            dotColor = Color(int.parse(item.color.replaceFirst('#', '0xFF')));
          } else if (item is TaskModel) {
            // Use priority color for tasks
            dotColor = _getPriorityColor(item.priority);
          } else {
            dotColor = Theme.of(context).primaryColor;
          }
          
          return Container(
            margin: const EdgeInsets.only(left: 1),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).colorScheme.onPrimary, width: 0.5),
            ),
          );
        }).toList(),
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
}

/// Week calendar view
class _WeekCalendarView extends StatelessWidget {
  final CalendarState state;
  final CalendarNotifier notifier;

  const _WeekCalendarView({
    required this.state,
    required this.notifier,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Week header - constrained height
        SizedBox(
          height: 120, // Fixed height for week calendar
          child: TableCalendar<CalendarEvent>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: state.focusedDate,
            selectedDayPredicate: (day) => isSameDay(day, state.selectedDate),
            calendarFormat: CalendarFormat.week,
            eventLoader: (day) => notifier.getEventsForDate(day),
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerVisible: true,
            daysOfWeekVisible: true,
            onDaySelected: (selectedDay, focusedDay) {
              notifier.selectDate(selectedDay);
              notifier.changeFocusedDate(focusedDay);
            },
            onPageChanged: (focusedDay) {
              notifier.changeFocusedDate(focusedDay);
            },
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: TextStyle(color: Theme.of(context).colorScheme.error),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronIcon: Icon(Icons.chevron_left),
              rightChevronIcon: Icon(Icons.chevron_right),
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Week events list
        Expanded(
          child: _WeekEventsView(state: state),
        ),
      ],
    );
  }
}

/// Day calendar view
class _DayCalendarView extends StatelessWidget {
  final CalendarState state;
  final CalendarNotifier notifier;

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
                icon: const Icon(Icons.chevron_left),
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
                icon: const Icon(Icons.chevron_right),
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

/// Week events view
class _WeekEventsView extends StatelessWidget {
  final CalendarState state;

  const _WeekEventsView({required this.state});
  @override
  Widget build(BuildContext context) {
    // Get events for the current week
    final weekStart = state.focusedDate.subtract(Duration(days: state.focusedDate.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    final weekEvents = state.events.where((event) {
      final eventDate = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
      return eventDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
             eventDate.isBefore(weekEnd.add(const Duration(days: 1)));
    }).toList();

    if (weekEvents.isEmpty) {
      return const Center(
        child: Text('No events this week'),
      );
    }

    return ListView.builder(
      itemCount: weekEvents.length,
      itemBuilder: (context, index) {
        final event = weekEvents[index];
        return EventCard(event: event);
      },
    );
  }
}

/// Day events view with time slots
class _DayEventsView extends StatelessWidget {
  final DateTime date;
  final List<CalendarEvent> events;

  const _DayEventsView({
    required this.date,
    required this.events,
  });
  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const Center(
        child: Text('No events today'),
      );
    }

    // Sort events by start time
    final sortedEvents = List<CalendarEvent>.from(events)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    return ListView.builder(
      itemCount: sortedEvents.length,
      itemBuilder: (context, index) {
        final event = sortedEvents[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: EventCard(event: event, showTime: true),
        );
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (event.isAllDay)
                    Chip(
                      label: const Text('All Day'),
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    ),
                ],
              ),
              
              if (showTime && !event.isAllDay) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
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
                      Icons.location_on,
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
    final calendarNotifier = ref.read(calendarProvider.notifier);

    return AlertDialog(
      title: Text('Schedule: ${widget.task.title}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Date picker
            ListTile(
              leading: const Icon(Icons.calendar_today),
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
                leading: const Icon(Icons.access_time),
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
                leading: const Icon(Icons.access_time_filled),
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

  Future<void> _scheduleTask(CalendarNotifier calendarNotifier) async {
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