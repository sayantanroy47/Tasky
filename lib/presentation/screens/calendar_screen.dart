import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/calendar_widgets.dart';
import '../widgets/standardized_app_bar.dart';
import '../providers/calendar_provider.dart';
import '../providers/task_providers.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/models/enums.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Calendar screen with task scheduling and event management
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardizedAppBar(
        title: 'Calendar',
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(PhosphorIcons.calendar()), text: 'Calendar'),
            Tab(icon: Icon(PhosphorIcons.clock()), text: 'Schedule Tasks'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _showCreateEventDialog(context),
            icon: Icon(PhosphorIcons.plusCircle()),
            tooltip: 'Create Event',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          // Calendar view
          CalendarWidget(),
          
          // Task scheduling view
          TaskSchedulingView(),
        ],
      ),
    );
  }

  void _showCreateEventDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateEventDialog(),
    );
  }
}

/// Task scheduling view for scheduling unscheduled tasks
class TaskSchedulingView extends ConsumerWidget {
  const TaskSchedulingView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);
    final calendarState = ref.watch(calendarProvider);

    return tasksAsync.when(
      data: (tasks) {
        // Filter unscheduled tasks
        final unscheduledTasks = tasks.where((task) {
          return task.status != TaskStatus.completed &&
                 !_isTaskScheduled(task, calendarState.events);
        }).toList();

        if (unscheduledTasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(PhosphorIcons.checkCircle(), size: 64, color: Colors.green),
                SizedBox(height: 16),
                Text(
                  'All tasks are scheduled!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('Great job staying organized!'),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Unscheduled Tasks (${unscheduledTasks.length})',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            
            Expanded(
              child: ListView.builder(
                itemCount: unscheduledTasks.length,
                itemBuilder: (context, index) {
                  final task = unscheduledTasks[index];
                  return UnscheduledTaskCard(task: task);
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading tasks: $error'),
      ),
    );
  }

  bool _isTaskScheduled(TaskModel task, List<CalendarEvent> events) {
    return events.any((event) => event.taskId == task.id);
  }
}

/// Card for unscheduled tasks with scheduling options
class UnscheduledTaskCard extends ConsumerWidget {
  final TaskModel task;

  const UnscheduledTaskCard({super.key, required this.task});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getPriorityColor(task.priority),
          child: Icon(
            _getPriorityIcon(task.priority),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null && task.description!.isNotEmpty)
              Text(
                task.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(PhosphorIcons.flag(), size: 16, color: _getPriorityColor(task.priority)),
                const SizedBox(width: 4),
                Text(
                  task.priority.name.toUpperCase(),
                  style: TextStyle(
                    color: _getPriorityColor(task.priority),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                if (task.dueDate != null) ...[
                  const SizedBox(width: 16),
                  Icon(PhosphorIcons.clock(), size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Due ${_formatDueDate(task.dueDate!)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Quick schedule buttons
            IconButton(
              onPressed: () => _quickSchedule(context, ref, task, DateTime.now()),
              icon: Icon(PhosphorIcons.calendar()),
              tooltip: 'Schedule for today',
            ),
            IconButton(
              onPressed: () => _quickSchedule(
                context,
                ref,
                task,
                DateTime.now().add(const Duration(days: 1)),
              ),
              icon: Icon(PhosphorIcons.calendar()),
              tooltip: 'Schedule for tomorrow',
            ),
            IconButton(
              onPressed: () => _showScheduleDialog(context, task),
              icon: Icon(PhosphorIcons.clock()),
              tooltip: 'Custom schedule',
            ),
          ],
        ),
        onTap: () => _showScheduleDialog(context, task),
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
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

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return PhosphorIcons.arrowUp();
      case TaskPriority.high:
        return PhosphorIcons.caretUp();
      case TaskPriority.medium:
        return PhosphorIcons.minus();
      case TaskPriority.low:
        return PhosphorIcons.caretDown();
    }
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    
    if (difference == 0) return 'today';
    if (difference == 1) return 'tomorrow';
    if (difference == -1) return 'yesterday';
    if (difference < 0) return '${-difference} days ago';
    return 'in $difference days';
  }

  void _quickSchedule(
    BuildContext context,
    WidgetRef ref,
    TaskModel task,
    DateTime date,
  ) async {
    final calendarNotifier = ref.read(calendarProvider.notifier);
    
    // Schedule for 9 AM - 10 AM by default
    final startTime = DateTime(date.year, date.month, date.day, 9, 0);
    final endTime = startTime.add(const Duration(hours: 1));
    
    final event = CalendarEvent.create(
      taskId: task.id,
      title: task.title,
      description: task.description,
      startTime: startTime,
      endTime: endTime,
      color: _getColorForPriority(task.priority),
    );

    await calendarNotifier.addEvent(event);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Scheduled "${task.title}" for ${_formatScheduleDate(date)}'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => calendarNotifier.deleteEvent(event.id),
          ),
        ),
      );
    }
  }

  void _showScheduleDialog(BuildContext context, TaskModel task) {
    showDialog(
      context: context,
      builder: (context) => TaskSchedulingWidget(
        task: task,
        onScheduled: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Scheduled "${task.title}"')),
          );
        },
      ),
    );
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

  String _formatScheduleDate(DateTime date) {
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

/// Dialog for creating new calendar events
class CreateEventDialog extends ConsumerStatefulWidget {
  const CreateEventDialog({super.key});
  @override
  ConsumerState<CreateEventDialog> createState() => _CreateEventDialogState();
}

class _CreateEventDialogState extends ConsumerState<CreateEventDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  
  DateTime selectedDate = DateTime.now();
  TimeOfDay startTime = TimeOfDay.now();
  TimeOfDay endTime = TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);
  bool isAllDay = false;
  String selectedColor = '#2196F3';

  final List<String> colorOptions = [
    '#2196F3', // Blue
    '#4CAF50', // Green
    '#FF9800', // Orange
    '#F44336', // Red
    '#9C27B0', // Purple
    '#607D8B', // Blue Grey
    '#795548', // Brown
    '#E91E63', // Pink
  ];
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create Event'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title field
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Event Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Description field
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            
            // Location field
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Date picker
            ListTile(
              leading: Icon(PhosphorIcons.calendar()),
              title: const Text('Date'),
              subtitle: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => selectedDate = date);
                }
              },
            ),
            
            // All day toggle
            SwitchListTile(
              title: Text('All Day'),
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
            
            // Color picker
            SizedBox(height: 16),
            const Text('Event Color'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: colorOptions.map((color) {
                final isSelected = color == selectedColor;
                return GestureDetector(
                  onTap: () => setState(() => selectedColor = color),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.black, width: 3)
                          : null,
                    ),
                    child: isSelected
                        ? Icon(PhosphorIcons.check(), color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _titleController.text.isEmpty ? null : () => _createEvent(),
          child: const Text('Create'),
        ),
      ],
    );
  }

  Future<void> _createEvent() async {
    final calendarNotifier = ref.read(calendarProvider.notifier);
    
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
      title: _titleController.text,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      location: _locationController.text.isEmpty ? null : _locationController.text,
      startTime: startDateTime,
      endTime: endDateTime,
      isAllDay: isAllDay,
      color: selectedColor,
    );

    await calendarNotifier.addEvent(event);
    
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Created event "${event.title}"')),
      );
    }
  }
}

