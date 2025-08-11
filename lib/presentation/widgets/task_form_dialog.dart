import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/typography_constants.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../providers/task_provider.dart';

/// Dialog for creating or editing tasks
class TaskFormDialog extends ConsumerStatefulWidget {
  final TaskModel? task;
  final String? initialTitle;
  final String? initialDescription;

  const TaskFormDialog({
    super.key,
    this.task,
    this.initialTitle,
    this.initialDescription,
  });

  @override
  ConsumerState<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends ConsumerState<TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;
  String? _projectId;
  List<String> _tags = [];
  bool _isPinned = false;
  int? _estimatedDuration;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.task != null) {
      // Editing existing task
      final task = widget.task!;
      _titleController.text = task.title;
      _descriptionController.text = task.description ?? '';
      _priority = task.priority;
      _dueDate = task.dueDate;
      _projectId = task.projectId;
      _tags = List.from(task.tags);
      _isPinned = task.isPinned;
      _estimatedDuration = task.estimatedDuration;
    } else {
      // Creating new task
      _titleController.text = widget.initialTitle ?? '';
      _descriptionController.text = widget.initialDescription ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;
    
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(TypographyConstants.radiusStandard),
                  topRight: Radius.circular(TypographyConstants.radiusStandard),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isEditing ? Icons.edit : Icons.add_task,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEditing ? 'Edit Task' : 'Create Task',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            
            // Form content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title field
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Task Title',
                          hintText: 'Enter task title...',
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a task title';
                          }
                          return null;
                        },
                        autofocus: !isEditing,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Description field
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description (Optional)',
                          hintText: 'Enter task description...',
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Priority selector
                      DropdownButtonFormField<TaskPriority>(
                        value: _priority,
                        decoration: const InputDecoration(
                          labelText: 'Priority',
                          prefixIcon: Icon(Icons.flag),
                        ),
                        items: TaskPriority.values.map((priority) {
                          return DropdownMenuItem(
                            value: priority,
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: priority.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(priority.displayName),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _priority = value;
                            });
                          }
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Due date picker
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text(_dueDate == null 
                          ? 'Set Due Date (Optional)' 
                          : 'Due: ${_formatDate(_dueDate!)}'),
                        trailing: _dueDate != null 
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _dueDate = null;
                                });
                              },
                            )
                          : const Icon(Icons.arrow_forward_ios),
                        onTap: _selectDueDate,
                        contentPadding: EdgeInsets.zero,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Tags input (simplified for now)
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Tags (Optional)',
                          hintText: 'Enter tags separated by commas...',
                          prefixIcon: Icon(Icons.tag),
                        ),
                        initialValue: _tags.join(', '),
                        onChanged: (value) {
                          _tags = value
                              .split(',')
                              .map((tag) => tag.trim())
                              .where((tag) => tag.isNotEmpty)
                              .toList();
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Pin toggle
                      SwitchListTile(
                        title: const Text('Pin Task'),
                        subtitle: const Text('Pin to top of task list'),
                        value: _isPinned,
                        onChanged: (value) {
                          setState(() {
                            _isPinned = value;
                          });
                        },
                        secondary: const Icon(Icons.push_pin),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Action buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(TypographyConstants.radiusStandard),
                  bottomRight: Radius.circular(TypographyConstants.radiusStandard),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _saveTask,
                    child: Text(isEditing ? 'Update' : 'Create'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDueDate() async {
    if (!mounted) return;
    
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dueDate ?? DateTime.now()),
      );

      if (mounted) {
        if (time != null) {
          setState(() {
            _dueDate = DateTime(
              date.year,
              date.month,
              date.day,
              time.hour,
              time.minute,
            );
          });
        } else {
          setState(() {
            _dueDate = DateTime(
              date.year,
              date.month,
              date.day,
              23,
              59,
            );
          });
        }
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Store context before async operations
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    try {
      final taskOperations = ref.read(taskOperationsProvider);
      
      if (widget.task != null) {
        // Update existing task
        final updatedTask = widget.task!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
          priority: _priority,
          dueDate: _dueDate,
          projectId: _projectId,
          tags: _tags,
          isPinned: _isPinned,
          estimatedDuration: _estimatedDuration,
        );
        
        await taskOperations.updateTask(updatedTask);
        
        if (mounted) {
          navigator.pop();
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Task updated successfully')),
          );
        }
      } else {
        // Create new task
        final newTask = TaskModel.create(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
          priority: _priority,
          dueDate: _dueDate,
          tags: _tags,
          projectId: _projectId,
          isPinned: _isPinned,
          estimatedDuration: _estimatedDuration,
        );
        
        await taskOperations.createTask(newTask);
        
        if (mounted) {
          navigator.pop();
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Task created successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error saving task: $e'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    }
  }
}