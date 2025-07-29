import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Reusable task card widget for displaying task information
class TaskCard extends StatelessWidget {
  final String title;
  final String? description;
  final bool isCompleted;
  final int priority;
  final DateTime? dueDate;
  final List<String> tags;
  final VoidCallback? onTap;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const TaskCard({
    super.key,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.priority = 1,
    this.dueDate,
    this.tags = const [],
    this.onTap,
    this.onToggleComplete,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final priorityColor = AppColors.getPriorityColor(priority);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with checkbox and actions
              Row(
                children: [
                  // Completion checkbox
                  Checkbox(
                    value: isCompleted,
                    onChanged: onToggleComplete != null 
                      ? (value) => onToggleComplete?.call()
                      : null,
                  ),
                  
                  // Priority indicator
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: priorityColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Title and description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            decoration: isCompleted 
                              ? TextDecoration.lineThrough 
                              : null,
                            color: isCompleted 
                              ? theme.colorScheme.onSurfaceVariant 
                              : null,
                          ),
                        ),
                        if (description != null && description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            description!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              decoration: isCompleted 
                                ? TextDecoration.lineThrough 
                                : null,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Actions menu
                  if (showActions)
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
                          child: ListTile(
                            leading: Icon(Icons.edit),
                            title: Text('Edit'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete),
                            title: Text('Delete'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              
              // Footer with due date and tags
              if (dueDate != null || tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Due date
                    if (dueDate != null) ...[
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: _getDueDateColor(theme),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDueDate(dueDate!),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getDueDateColor(theme),
                          fontWeight: _isOverdue(dueDate!) 
                            ? FontWeight.bold 
                            : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    
                    // Tags
                    Expanded(
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: tags.take(3).map((tag) => _TagChip(
                          label: tag,
                          color: AppColors.getTagColor(tags.indexOf(tag)),
                        )).toList(),
                      ),
                    ),
                    
                    // More tags indicator
                    if (tags.length > 3)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '+${tags.length - 3}',
                          style: theme.textTheme.bodySmall,
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

  Color _getDueDateColor(ThemeData theme) {
    if (dueDate == null) return theme.colorScheme.onSurfaceVariant;
    
    if (_isOverdue(dueDate!)) {
      return theme.colorScheme.error;
    } else if (_isDueToday(dueDate!)) {
      return Colors.orange;
    } else {
      return theme.colorScheme.onSurfaceVariant;
    }
  }

  bool _isOverdue(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(date.year, date.month, date.day);
    return dueDay.isBefore(today);
  }

  bool _isDueToday(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(date.year, date.month, date.day);
    return dueDay.isAtSameMomentAs(today);
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dueDay = DateTime(date.year, date.month, date.day);
    
    if (dueDay.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (dueDay.isAtSameMomentAs(tomorrow)) {
      return 'Tomorrow';
    } else if (_isOverdue(date)) {
      final difference = today.difference(dueDay).inDays;
      return '$difference day${difference == 1 ? '' : 's'} overdue';
    } else {
      final difference = dueDay.difference(today).inDays;
      if (difference <= 7) {
        return 'In $difference day${difference == 1 ? '' : 's'}';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    }
  }
}

/// Tag chip widget
class _TagChip extends StatelessWidget {
  final String label;
  final Color color;

  const _TagChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}