import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../providers/enhanced_calendar_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Enhanced calendar widget that integrates tasks and events
class EnhancedCalendarWidget extends ConsumerWidget {
  const EnhancedCalendarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(enhancedCalendarProvider);
    final calendarNotifier = ref.read(enhancedCalendarProvider.notifier);

    return Column(
      children: [
        // Calendar statistics
        _buildCalendarStats(context, ref),
        
        const SizedBox(height: 16),
        
        // View mode selector
        _buildViewModeSelector(context, calendarState, calendarNotifier),
        
        const SizedBox(height: 12),
        
        // Calendar
        Expanded(
          child: _buildCalendarView(context, calendarState, calendarNotifier),
        ),
        
        const SizedBox(height: 16),
        
        // Selected date details
        _buildSelectedDateDetails(context, ref, calendarState),
      ],
    );
  }

  Widget _buildCalendarStats(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(calendarStatsProvider);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(context, 'Today', stats.todaysTasks.toString(), Colors.blue),
          _buildStatItem(context, 'Upcoming', stats.upcomingTasks.toString(), Colors.green),
          _buildStatItem(context, 'Overdue', stats.overdueTasks.toString(), Colors.red),
          _buildStatItem(context, 'Total', stats.totalTasks.toString(), Colors.grey),
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
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: CalendarViewMode.values.map((mode) {
          final isSelected = state.viewMode == mode;
          return GestureDetector(
            onTap: () => notifier.changeViewMode(mode),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).colorScheme.primary : null,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _getViewModeLabel(mode),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isSelected 
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w500 : null,
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
  ) {
    final tasksByDate = notifier.getTasksByDate();
    final eventsByDate = notifier.getEventsByDate();

    // Convert tasks to calendar appointments
    final appointments = <Appointment>[];
    
    // Add tasks as appointments
    for (final entry in tasksByDate.entries) {
      for (final task in entry.value) {
        appointments.add(Appointment(
          startTime: entry.key,
          endTime: entry.key.add(const Duration(hours: 1)),
          subject: task.title,
          color: _getTaskColor(task),
          notes: task.description ?? '',
        ));
      }
    }
    
    // Add events as appointments
    for (final entry in eventsByDate.entries) {
      for (final event in entry.value) {
        appointments.add(Appointment(
          startTime: event.startTime,
          endTime: event.endTime,
          subject: event.title,
          color: Colors.blue,
          notes: event.description ?? '',
        ));
      }
    }

    return SfCalendar(
      view: _getCalendarView(state.calendarFormat),
      initialDisplayDate: state.focusedDate,
      initialSelectedDate: state.selectedDate,
      dataSource: MeetingDataSource(appointments),
      monthViewSettings: MonthViewSettings(
        appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
        showAgenda: false,
        dayFormat: 'EEE',
        monthCellStyle: MonthCellStyle(
          backgroundColor: Theme.of(context).colorScheme.surface,
          todayBackgroundColor: Theme.of(context).colorScheme.primaryContainer,
          leadingDatesBackgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          trailingDatesBackgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        ),
      ),
      headerStyle: CalendarHeaderStyle(
        textAlign: TextAlign.center,
        backgroundColor: Theme.of(context).colorScheme.surface,
        textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      selectionDecoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      todayHighlightColor: Theme.of(context).colorScheme.secondary,
      onTap: (CalendarTapDetails details) {
        if (details.date != null) {
          // Defer state updates to ensure they happen outside build cycle
          Future(() {
            notifier.selectDate(details.date!);
            notifier.changeFocusedDate(details.date!);
          });
        }
      },
      onViewChanged: (ViewChangedDetails details) {
        if (details.visibleDates.isNotEmpty) {
          // Defer state update to avoid modifying provider during build
          Future(() => notifier.changeFocusedDate(details.visibleDates.first));
        }
      },
    );
  }

  CalendarView _getCalendarView(CalendarView format) {
    switch (format) {
      case CalendarView.month:
        return CalendarView.month;
      case CalendarView.week:
        return CalendarView.week;
      case CalendarView.workWeek:
        return CalendarView.workWeek;
      case CalendarView.day:
        return CalendarView.day;
      default:
        return CalendarView.month;
    }
  }

  Color _getTaskColor(TaskModel task) {
    switch (task.priority) {
      case TaskPriority.urgent:
        return Colors.red;
      case TaskPriority.high:
        return Colors.orange;
      case TaskPriority.medium:
        return Colors.blue;
      case TaskPriority.low:
        return Colors.green;
    }
  }

  // Removed unused marker methods

  Widget _buildSelectedDateDetails(
    BuildContext context,
    WidgetRef ref,
    EnhancedCalendarState state,
  ) {
    final tasks = state.tasksForSelectedDate;
    
    if (tasks.isEmpty) {
      return _buildEmptySelectedDate(context, state.selectedDate);
    }
    
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tasks for ${_formatDate(state.selectedDate)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
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

  Widget _buildEmptySelectedDate(BuildContext context, DateTime date) {
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
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _showCreateTaskDialog(context, date),
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
                ? Colors.green
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
          style: TextStyle(
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
        color = Colors.green;
        icon = PhosphorIcons.caretDown();
        break;
      case TaskPriority.medium:
        color = Colors.orange;
        icon = PhosphorIcons.minus();
        break;
      case TaskPriority.high:
        color = Colors.red;
        icon = PhosphorIcons.caretUp();
        break;
      case TaskPriority.urgent:
        color = Colors.red;
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

  void _showCreateTaskDialog(BuildContext context, DateTime date) {
    showDialog(
      context: context,
      builder: (context) => _CreateTaskDialog(selectedDate: date),
    );
  }
}

/// Dialog for creating a new task for a specific date
class _CreateTaskDialog extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  
  const _CreateTaskDialog({required this.selectedDate});

  @override
  ConsumerState<_CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends ConsumerState<_CreateTaskDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TaskPriority _selectedPriority = TaskPriority.medium;
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create Task for ${_formatDate(widget.selectedDate)}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Task Title',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<TaskPriority>(
            initialValue: _selectedPriority,
            decoration: const InputDecoration(
              labelText: 'Priority',
              border: OutlineInputBorder(),
            ),
            items: TaskPriority.values.map((priority) {
              return DropdownMenuItem(
                value: priority,
                child: Text(priority.name.toUpperCase()),
              );
            }).toList(),
            onChanged: (priority) {
              if (priority != null) {
                setState(() => _selectedPriority = priority);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _canCreate() ? _createTask : null,
          child: const Text('Create'),
        ),
      ],
    );
  }

  bool _canCreate() {
    return _titleController.text.trim().isNotEmpty;
  }

  void _createTask() async {
    if (!_canCreate()) return;
    
    final task = TaskModel.create(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      priority: _selectedPriority,
      dueDate: widget.selectedDate,
    );
    
    final success = await ref.read(enhancedCalendarProvider.notifier).createTaskForDate(task);
    
    if (mounted) {
      Navigator.of(context).pop();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to create task'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
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

