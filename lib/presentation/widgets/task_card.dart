import 'package:flutter/material.dart';
import '../../domain/models/enums.dart';
import '../../domain/entities/task_audio_metadata.dart';
import 'highlighted_text.dart';
import 'audio_playback_widget.dart';

/// A card widget that displays task information
class TaskCard extends StatelessWidget {
  final String title;
  final String? description;
  final bool isCompleted;
  final int priority;
  final DateTime? dueDate;
  final List<String> tags;
  final int? subTasksTotal;
  final int? subTasksCompleted;
  final String? searchQuery;
  final VoidCallback? onTap;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isPinned;
  final String? audioFilePath;
  final Duration? audioDuration;
  final TaskType taskType;

  const TaskCard({
    super.key,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.priority = 1,
    this.dueDate,
    this.tags = const [],
    this.subTasksTotal,
    this.subTasksCompleted,
    this.searchQuery,
    this.onTap,
    this.onToggleComplete,
    this.onEdit,
    this.onDelete,
    this.isPinned = false,
    this.audioFilePath,
    this.audioDuration,
    this.taskType = TaskType.text,
  });

  @override
  Widget build(BuildContext context) {
    final taskPriority = TaskPriority.values[priority.clamp(0, TaskPriority.values.length - 1)];
    final isOverdue = dueDate != null && 
                     dueDate!.isBefore(DateTime.now()) && 
                     !isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isPinned ? 4 : 1,
      child: Dismissible(
        key: Key('task_$title'),
        background: Container(
          color: Colors.green,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 32,
          ),
        ),
        secondaryBackground: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(
            Icons.delete,
            color: Colors.white,
            size: 32,
          ),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            // Swipe right - toggle completion
            onToggleComplete?.call();
            return false; // Don't actually dismiss
          } else if (direction == DismissDirection.endToStart) {
            // Swipe left - delete
            return await _showDeleteConfirmation(context);
          }
          return false;
        },
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with checkbox, title, and priority
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Completion checkbox
                    Checkbox(
                      value: isCompleted,
                      onChanged: (_) => onToggleComplete?.call(),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Title and content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title with pin indicator
                          Row(
                            children: [
                              if (isPinned) ...[
                                Icon(
                                  Icons.push_pin,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                              ],
                              Expanded(
                                child: searchQuery != null && searchQuery!.isNotEmpty
                                  ? HighlightedText(
                                      text: title,
                                      highlight: searchQuery!,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        decoration: isCompleted 
                                          ? TextDecoration.lineThrough 
                                          : null,
                                        color: isCompleted 
                                          ? Theme.of(context).colorScheme.onSurfaceVariant
                                          : null,
                                      ),
                                    )
                                  : Text(
                                      title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        decoration: isCompleted 
                                          ? TextDecoration.lineThrough 
                                          : null,
                                        color: isCompleted 
                                          ? Theme.of(context).colorScheme.onSurfaceVariant
                                          : null,
                                      ),
                                    ),
                              ),
                            ],
                          ),
                          
                          // Description
                          if (description != null && description!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            searchQuery != null && searchQuery!.isNotEmpty
                              ? HighlightedText(
                                  text: description!,
                                  highlight: searchQuery!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    decoration: isCompleted 
                                      ? TextDecoration.lineThrough 
                                      : null,
                                  ),
                                  maxLines: 2,
                                )
                              : Text(
                                  description!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    decoration: isCompleted 
                                      ? TextDecoration.lineThrough 
                                      : null,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          ],
                          
                          // Audio playback widget for voice tasks
                          if (audioFilePath != null) ...[
                            const SizedBox(height: 8),
                            AudioPlaybackWidget(
                              audioFilePath: audioFilePath!,
                              audioDuration: audioDuration,
                              isCompact: true,
                            ),
                          ],
                          
                          // Task type indicator
                          if (taskType != TaskType.text) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  taskType.icon,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  taskType.displayName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Priority indicator
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: taskPriority.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // More options button
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit?.call();
                            break;
                          case 'delete':
                            onDelete?.call();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      child: const Icon(Icons.more_vert),
                    ),
                  ],
                ),
                
                // Footer with due date, subtasks, and tags
                if (dueDate != null || 
                    (subTasksTotal != null && subTasksTotal! > 0) || 
                    tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      // Due date
                      if (dueDate != null) ...[
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: isOverdue 
                            ? Colors.red 
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDueDate(dueDate!),
                          style: TextStyle(
                            fontSize: 12,
                            color: isOverdue 
                              ? Colors.red 
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: isOverdue ? FontWeight.w600 : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      
                      // Subtasks progress
                      if (subTasksTotal != null && subTasksTotal! > 0) ...[
                        Icon(
                          Icons.checklist,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${subTasksCompleted ?? 0}/$subTasksTotal',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      
                      // Tags
                      if (tags.isNotEmpty) ...[
                        Expanded(
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: tags.take(3).map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        if (tags.length > 3) ...[
                          const SizedBox(width: 4),
                          Text(
                            '+${tags.length - 3}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);
    
    if (taskDate.isAtSameMomentAs(today)) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (taskDate.isAtSameMomentAs(today.add(const Duration(days: 1)))) {
      return 'Tomorrow ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (taskDate.isBefore(today)) {
      final difference = today.difference(taskDate).inDays;
      return '$difference day${difference == 1 ? '' : 's'} ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              onDelete?.call();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  }
}