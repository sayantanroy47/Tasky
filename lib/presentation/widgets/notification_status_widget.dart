import 'package:flutter/material.dart';
import '../../domain/entities/task_model.dart';

/// Widget that displays notification status with proper icons instead of emojis
class NotificationStatusWidget extends StatelessWidget {
  final List<TaskModel> overdueTasks;
  final List<TaskModel> todayTasks;
  final List<TaskModel> upcomingTasks;
  
  const NotificationStatusWidget({
    super.key,
    required this.overdueTasks,
    required this.todayTasks,
    required this.upcomingTasks,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (overdueTasks.isNotEmpty) ...[
          Icon(
            Icons.warning_rounded,
            size: 16,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: 4),
          Text(
            '${overdueTasks.length} overdue',
            style: TextStyle(
              color: theme.colorScheme.error,
              fontSize: 12,
            ),
          ),
          if (todayTasks.isNotEmpty || upcomingTasks.isNotEmpty)
            const SizedBox(width: 8),
        ],
        
        if (todayTasks.isNotEmpty) ...[
          Icon(
            Icons.today_rounded,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            '${todayTasks.length} due today',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 12,
            ),
          ),
          if (upcomingTasks.isNotEmpty)
            const SizedBox(width: 8),
        ],
        
        if (upcomingTasks.isNotEmpty) ...[
          Icon(
            Icons.schedule_rounded,
            size: 16,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(width: 4),
          Text(
            '${upcomingTasks.length} upcoming',
            style: TextStyle(
              color: theme.colorScheme.secondary,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}

/// Icon widget for welcome messages
class WelcomeMessageIcon extends StatelessWidget {
  final IconData? icon;
  final Color? color;
  final double size;
  
  const WelcomeMessageIcon({
    super.key,
    this.icon,
    this.color,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    if (icon == null) return const SizedBox.shrink();
    
    final theme = Theme.of(context);
    
    return Icon(
      icon,
      size: size,
      color: color ?? theme.colorScheme.primary,
    );
  }
}

/// Task status icon widget
class TaskStatusIcon extends StatelessWidget {
  final String type;
  final Color? color;
  final double size;
  
  const TaskStatusIcon({
    super.key,
    required this.type,
    this.color,
    this.size = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    IconData iconData;
    Color iconColor = color ?? theme.colorScheme.onSurface;
    
    switch (type.toLowerCase()) {
      case 'priority':
        iconData = Icons.priority_high_rounded;
        iconColor = color ?? theme.colorScheme.error;
        break;
      case 'due':
        iconData = Icons.schedule_rounded;
        iconColor = color ?? theme.colorScheme.primary;
        break;
      case 'tags':
        iconData = Icons.local_offer_rounded;
        iconColor = color ?? theme.colorScheme.secondary;
        break;
      case 'location':
        iconData = Icons.location_on_rounded;
        iconColor = color ?? theme.colorScheme.tertiary;
        break;
      case 'home':
        iconData = Icons.home_rounded;
        break;
      case 'urgent':
        iconData = Icons.warning_rounded;
        iconColor = color ?? theme.colorScheme.error;
        break;
      case 'suggestion':
        iconData = Icons.lightbulb_rounded;
        iconColor = color ?? theme.colorScheme.primary;
        break;
      default:
        iconData = Icons.info_rounded;
    }
    
    return Icon(
      iconData,
      size: size,
      color: iconColor,
    );
  }
}