import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/models/enums.dart';
import '../providers/calendar_provider.dart';

/// Draggable task widget for rescheduling tasks via drag and drop
class DraggableTaskWidget extends ConsumerWidget {
  final TaskModel task;
  final CalendarEvent? event;
  final Widget child;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnd;

  const DraggableTaskWidget({
    super.key,
    required this.task,
    this.event,
    required this.child,
    this.onDragStarted,
    this.onDragEnd,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Draggable<TaskDragData>(
      data: TaskDragData(
        task: task,
        event: event,
      ),
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.drag_handle,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  task.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: child,
      ),
      onDragStarted: onDragStarted,
      onDragEnd: (_) => onDragEnd?.call(),
      child: child,
    );
  }
}

/// Data class for task drag operations
class TaskDragData {
  final TaskModel task;
  final CalendarEvent? event;

  const TaskDragData({
    required this.task,
    this.event,
  });
}

/// Drop target widget for calendar dates
class CalendarDropTarget extends ConsumerWidget {
  final DateTime date;
  final Widget child;
  final bool isHighlighted;

  const CalendarDropTarget({
    super.key,
    required this.date,
    required this.child,
    this.isHighlighted = false,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DragTarget<TaskDragData>(
      onWillAcceptWithDetails: (details) => details.data != null,
      onAcceptWithDetails: (details) => _handleTaskDrop(context, ref, details.data),
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            border: isHovering || isHighlighted
                ? Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  )
                : null,
            borderRadius: BorderRadius.circular(8),
            color: isHovering
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : null,
          ),
          child: child,
        );
      },
    );
  }

  Future<void> _handleTaskDrop(
    BuildContext context,
    WidgetRef ref,
    TaskDragData dragData,
  ) async {
    try {
      if (dragData.event != null) {
        // Reschedule existing event
        await _rescheduleEvent(context, ref, dragData.event!, date);
      } else {
        // Create new event for unscheduled task
        await _scheduleTask(context, ref, dragData.task, date);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reschedule task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rescheduleEvent(
    BuildContext context,
    WidgetRef ref,
    CalendarEvent event,
    DateTime newDate,
  ) async {
    // Show time selection dialog for rescheduling
    final result = await showDialog<RescheduleResult>(
      context: context,
      builder: (context) => RescheduleDialog(
        event: event,
        newDate: newDate,
      ),
    );

    if (result != null) {
      final calendarNotifier = ref.read(calendarProvider.notifier);
      final success = await calendarNotifier.rescheduleEvent(
        event.id,
        result.startTime,
        result.endTime,
      );

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Rescheduled "${event.title}" to ${_formatDate(newDate)}'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () => _undoReschedule(ref, event),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cannot reschedule: Time slot conflicts with another event'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }

  Future<void> _scheduleTask(
    BuildContext context,
    WidgetRef ref,
    TaskModel task,
    DateTime date,
  ) async {
    // Show scheduling dialog
    final result = await showDialog<ScheduleResult>(
      context: context,
      builder: (context) => ScheduleTaskDialog(
        task: task,
        date: date,
      ),
    );

    if (result != null) {
      final event = CalendarEvent.create(
        taskId: task.id,
        title: task.title,
        description: task.description,
        startTime: result.startTime,
        endTime: result.endTime,
        isAllDay: result.isAllDay,
        color: _getColorForPriority(task.priority),
      );

      final calendarNotifier = ref.read(calendarProvider.notifier);
      await calendarNotifier.addEvent(event);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scheduled "${task.title}" for ${_formatDate(date)}'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () => calendarNotifier.deleteEvent(event.id),
            ),
          ),
        );
      }
    }
  }

  void _undoReschedule(WidgetRef ref, CalendarEvent originalEvent) {
    final calendarNotifier = ref.read(calendarProvider.notifier);
    calendarNotifier.rescheduleEvent(
      originalEvent.id,
      originalEvent.startTime,
      originalEvent.endTime,
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      return 'today';
    }
    if (date.day == now.day + 1 && date.month == now.month && date.year == now.year) {
      return 'tomorrow';
    }
    return '${date.day}/${date.month}/${date.year}';
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

/// Result class for rescheduling operations
class RescheduleResult {
  final DateTime startTime;
  final DateTime endTime;

  const RescheduleResult({
    required this.startTime,
    required this.endTime,
  });
}

/// Result class for scheduling operations
class ScheduleResult {
  final DateTime startTime;
  final DateTime endTime;
  final bool isAllDay;

  const ScheduleResult({
    required this.startTime,
    required this.endTime,
    required this.isAllDay,
  });
}

/// Dialog for rescheduling existing events
class RescheduleDialog extends StatefulWidget {
  final CalendarEvent event;
  final DateTime newDate;

  const RescheduleDialog({
    super.key,
    required this.event,
    required this.newDate,
  });
  @override
  State<RescheduleDialog> createState() => _RescheduleDialogState();
}

class _RescheduleDialogState extends State<RescheduleDialog> {
  late TimeOfDay startTime;
  late TimeOfDay endTime;
  late bool isAllDay;
  @override
  void initState() {
    super.initState();
    startTime = TimeOfDay.fromDateTime(widget.event.startTime);
    endTime = TimeOfDay.fromDateTime(widget.event.endTime);
    isAllDay = widget.event.isAllDay;
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Reschedule: ${widget.event.title}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Moving to ${_formatDate(widget.newDate)}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => _confirmReschedule(),
          child: const Text('Reschedule'),
        ),
      ],
    );
  }

  void _confirmReschedule() {
    final DateTime startDateTime;
    final DateTime endDateTime;

    if (isAllDay) {
      startDateTime = DateTime(widget.newDate.year, widget.newDate.month, widget.newDate.day);
      endDateTime = startDateTime.add(const Duration(days: 1));
    } else {
      startDateTime = DateTime(
        widget.newDate.year,
        widget.newDate.month,
        widget.newDate.day,
        startTime.hour,
        startTime.minute,
      );
      endDateTime = DateTime(
        widget.newDate.year,
        widget.newDate.month,
        widget.newDate.day,
        endTime.hour,
        endTime.minute,
      );
    }

    Navigator.of(context).pop(
      RescheduleResult(
        startTime: startDateTime,
        endTime: endDateTime,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      return 'today';
    }
    if (date.day == now.day + 1 && date.month == now.month && date.year == now.year) {
      return 'tomorrow';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Dialog for scheduling unscheduled tasks
class ScheduleTaskDialog extends StatefulWidget {
  final TaskModel task;
  final DateTime date;

  const ScheduleTaskDialog({
    super.key,
    required this.task,
    required this.date,
  });
  @override
  State<ScheduleTaskDialog> createState() => _ScheduleTaskDialogState();
}

class _ScheduleTaskDialogState extends State<ScheduleTaskDialog> {
  TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 0);
  bool isAllDay = false;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Schedule: ${widget.task.title}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Scheduling for ${_formatDate(widget.date)}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => _confirmSchedule(),
          child: const Text('Schedule'),
        ),
      ],
    );
  }

  void _confirmSchedule() {
    final DateTime startDateTime;
    final DateTime endDateTime;

    if (isAllDay) {
      startDateTime = DateTime(widget.date.year, widget.date.month, widget.date.day);
      endDateTime = startDateTime.add(const Duration(days: 1));
    } else {
      startDateTime = DateTime(
        widget.date.year,
        widget.date.month,
        widget.date.day,
        startTime.hour,
        startTime.minute,
      );
      endDateTime = DateTime(
        widget.date.year,
        widget.date.month,
        widget.date.day,
        endTime.hour,
        endTime.minute,
      );
    }

    Navigator.of(context).pop(
      ScheduleResult(
        startTime: startDateTime,
        endTime: endDateTime,
        isAllDay: isAllDay,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      return 'today';
    }
    if (date.day == now.day + 1 && date.month == now.month && date.year == now.year) {
      return 'tomorrow';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}