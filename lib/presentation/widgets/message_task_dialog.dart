import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/typography_constants.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../../core/providers/core_providers.dart';
import '../../presentation/providers/task_providers.dart';

/// Dialog for creating tasks from shared messages
class MessageTaskDialog extends ConsumerStatefulWidget {
  final String messageText;
  final String? sourceName;
  final String? sourceApp;
  final TaskModel? suggestedTask;

  const MessageTaskDialog({
    super.key,
    required this.messageText,
    this.sourceName,
    this.sourceApp,
    this.suggestedTask,
  });

  @override
  ConsumerState<MessageTaskDialog> createState() => _MessageTaskDialogState();
}

class _MessageTaskDialogState extends ConsumerState<MessageTaskDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TaskPriority _selectedPriority;
  DateTime? _selectedDueDate;
  final List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    
    final suggested = widget.suggestedTask;
    _titleController = TextEditingController(
      text: suggested?.title ?? _extractTitleFromMessage(widget.messageText),
    );
    _descriptionController = TextEditingController(
      text: suggested?.description ?? widget.messageText,
    );
    _selectedPriority = suggested?.priority ?? TaskPriority.medium;
    _selectedDueDate = suggested?.dueDate;
    
    if (suggested?.tags != null) {
      _tags.addAll(suggested!.tags);
    } else {
      _tags.addAll(['wife', 'message']);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _extractTitleFromMessage(String message) {
    // Simple title extraction - take first line or first 50 chars
    final lines = message.split('\n');
    final firstLine = lines.first.trim();
    
    if (firstLine.length <= 50) {
      return firstLine;
    }
    
    return '${firstLine.substring(0, 47)}...';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.message_outlined,
                  color: colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Task from Message',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.sourceName != null || widget.sourceApp != null)
                        Text(
                          'From: ${widget.sourceName ?? 'Unknown'} ${widget.sourceApp != null ? '(${widget.sourceApp})' : ''}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Original message preview
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Original Message:',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.messageText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Task form
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title field
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Task Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                        ),
                        prefixIcon: const Icon(Icons.title),
                      ),
                      maxLines: 1,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Description field
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description (Optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                        ),
                        prefixIcon: const Icon(Icons.description),
                      ),
                      maxLines: 3,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Priority selector
                    Text(
                      'Priority',
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<TaskPriority>(
                      segments: const [
                        ButtonSegment<TaskPriority>(
                          value: TaskPriority.low,
                          label: Text('Low'),
                          icon: Icon(Icons.low_priority),
                        ),
                        ButtonSegment<TaskPriority>(
                          value: TaskPriority.medium,
                          label: Text('Medium'),
                          icon: Icon(Icons.remove),
                        ),
                        ButtonSegment<TaskPriority>(
                          value: TaskPriority.high,
                          label: Text('High'),
                          icon: Icon(Icons.priority_high),
                        ),
                      ],
                      selected: {_selectedPriority},
                      onSelectionChanged: (Set<TaskPriority> selection) {
                        setState(() {
                          _selectedPriority = selection.first;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Due date picker
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: Text(_selectedDueDate == null 
                        ? 'No due date' 
                        : 'Due: ${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
                      ),
                      trailing: _selectedDueDate != null 
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _selectedDueDate = null;
                              });
                            },
                          )
                        : null,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDueDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            _selectedDueDate = date;
                          });
                        }
                      },
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Tags display
                    if (_tags.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        children: _tags.map((tag) => Chip(
                          label: Text(tag),
                          backgroundColor: colorScheme.primaryContainer,
                          labelStyle: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                          ),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            setState(() {
                              _tags.remove(tag);
                            });
                          },
                        )).toList(),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _createTask,
                  icon: const Icon(Icons.add_task),
                  label: const Text('Create Task'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _createTask() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a task title'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final task = TaskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty 
        ? null 
        : _descriptionController.text.trim(),
      createdAt: DateTime.now(),
      dueDate: _selectedDueDate,
      priority: _selectedPriority,
      status: TaskStatus.pending,
      tags: _tags,
      subTasks: const [],
      projectId: null,
      dependencies: const [],
      metadata: {
        'source': 'shared_message',
        'original_text': widget.messageText,
        'created_from': widget.sourceName ?? 'unknown',
        'source_app': widget.sourceApp ?? 'unknown',
        'auto_detected': true,
      },
    );

    try {
      await ref.read(taskRepositoryProvider).createTask(task);
      
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task "${task.title}" created successfully!'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'View',
              onPressed: () {
                // Navigate to task details or tasks page
                Navigator.of(context).pushNamed('/tasks');
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create task: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}