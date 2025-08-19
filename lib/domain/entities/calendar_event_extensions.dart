import 'package:uuid/uuid.dart';
import 'calendar_event.dart';
import 'task_model.dart';
import '../models/enums.dart';

/// Extension for CalendarEvent to support task integration
extension CalendarEventTaskExtension on CalendarEvent {
  /// Creates a calendar event from a task
  static CalendarEvent fromTask(TaskModel task) {
    final startTime = task.dueDate ?? DateTime.now();
    final endTime = startTime.add(const Duration(hours: 1)); // Default 1 hour duration
    
    return CalendarEvent(
      id: const Uuid().v4(),
      taskId: task.id,
      title: task.title,
      description: task.description,
      startTime: startTime,
      endTime: endTime,
      isAllDay: false,
      color: _getPriorityColor(task.priority),
      isRecurring: false,
      location: null,
      attendees: const [],
      reminders: const [15], // 15 minute reminder
      metadata: {
        'task_id': task.id,
        'task_priority': task.priority.name,
        'task_status': task.status.name,
      },
    );
  }

  /// Get color based on task priority
  static String _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return '#4CAF50'; // Green
      case TaskPriority.medium:
        return '#FF9800'; // Orange
      case TaskPriority.high:
        return '#F44336'; // Red
      case TaskPriority.urgent:
        return '#9C27B0'; // Purple
    }
  }
}