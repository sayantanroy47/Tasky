import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/entities/task_enums.dart';
import '../../domain/entities/subtask.dart';
import '../../domain/entities/recurrence_pattern.dart';
import '../../domain/entities/task_template.dart';
import '../providers/task_providers.dart';
import '../providers/task_template_providers.dart';
import '../providers/recurring_task_providers.dart';
import 'custom_input_fields.dart';
import 'custom_buttons.dart';
import 'recurrence_pattern_picker.dart';
import 'task_template_selector.dart';

/// Dialog for creating or editing tasks
class TaskFormDialog extends ConsumerStatefulWidget {
  final TaskModel? task;
  final bool isEditing;

  const TaskFormDialog({
    super.key,
    this.task,
  }) : isEditing = task != null;

  @override
  ConsumerState<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends ConsumerState<TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _selectedDueDate;
  List<String> _tags = [];
  List<SubTask> _subTasks = [];
  RecurrencePattern? _recurrencePattern;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _initializeFromTask(widget.task!);
    }
  }

  void _initializeFromTask(TaskModel task) {
    _titleController.text = task.title;
    _descriptionController.text = task.description ?? '';
    _selectedPriority = task.priority;
    _selectedDueDate = task.dueDate;
    _tags = List.from(task.tags);
    _subTasks = List.from(task.subTasks);
    _recurrencePattern = task.recurrence;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    widget.isEditing ? 'Edit Task' : 'Create Task',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Spacer(),
                  if (!widget.isEditing) ...[
                    IconButton(
                      onPressed: _showTemplateSelector,
                      icon: const Icon(Icons.description_outlined),
                      tooltip: 'Use Template',
                    ),
                    const SizedBox(width: 8),
                  ],
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Form fields
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title field
                      CustomTextField(
                        controller: _titleController,
                        label: 'Task Title',
                        hint: 'Enter task title',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a task title';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Description field
                      CustomTextField(
                        controller: _descriptionController,
                        label: 'Description (Optional)',
                        hint: 'Enter task description',
                        maxLines: 3,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Priority selector
                      Text(
                        'Priority',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      _PrioritySelector(
                        selectedPriority: _selectedPriority,
                        onPriorityChanged: (priority) {
                          setState(() {
                            _selectedPriority = priority;
                          });
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Due date selector
                      Text(
                        'Due Date (Optional)',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      _DueDateSelector(
                        selectedDate: _selectedDueDate,
                        onDateChanged: (date) {
                          setState(() {
                            _selectedDueDate = date;
                          });
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Tags section
                      Text(
                        'Tags (Optional)',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      _TagsSection(
                        tags: _tags,
                        onTagsChanged: (tags) {
                          setState(() {
                            _tags = tags;
                          });
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Recurrence pattern section
                      RecurrencePatternPicker(
                        initialPattern: _recurrencePattern,
                        onPatternChanged: (pattern) {
                          setState(() {
                            _recurrencePattern = pattern;
                          });
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Subtasks section
                      Text(
                        'Subtasks (Optional)',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      _SubTasksSection(
                        subTasks: _subTasks,
                        onSubTasksChanged: (subTasks) {
                          setState(() {
                            _subTasks = subTasks;
                          });
                        },
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
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  PrimaryButton(
                    onPressed: _isLoading ? null : _saveTask,
                    isLoading: _isLoading,
                    text: widget.isEditing ? 'Update' : 'Create',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.isEditing) {
        // Update existing task
        final taskOperations = ref.read(taskOperationsProvider);
        final updatedTask = widget.task!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
          priority: _selectedPriority,
          dueDate: _selectedDueDate,
          tags: _tags,
          subTasks: _subTasks,
          recurrence: _recurrencePattern,
        );
        
        await taskOperations.updateTask(updatedTask);
      } else {
        // Create new task (recurring or regular)
        if (_recurrencePattern != null) {
          // Create recurring task
          final recurringTaskNotifier = ref.read(recurringTaskNotifierProvider.notifier);
          await recurringTaskNotifier.createRecurringTask(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim().isEmpty 
                ? null 
                : _descriptionController.text.trim(),
            dueDate: _selectedDueDate,
            recurrence: _recurrencePattern!,
            priority: _selectedPriority,
            tags: _tags,
          );
        } else {
          // Create regular task
          final taskOperations = ref.read(taskOperationsProvider);
          final newTask = TaskModel.create(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim().isEmpty 
                ? null 
                : _descriptionController.text.trim(),
            priority: _selectedPriority,
            dueDate: _selectedDueDate,
            tags: _tags,
          );
          
          // Add subtasks to the new task
          final taskWithSubTasks = _subTasks.isEmpty 
              ? newTask 
              : newTask.copyWith(
                  subTasks: _subTasks.map((st) => st.copyWith(taskId: newTask.id)).toList(),
                );
          
          await taskOperations.createTask(taskWithSubTasks);
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing 
                  ? 'Task updated successfully!' 
                  : 'Task created successfully!',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showTemplateSelector() {
    showDialog(
      context: context,
      builder: (context) => TaskTemplateSelector(
        onTemplateSelected: _applyTemplate,
      ),
    );
  }

  void _applyTemplate(TaskTemplate template) {
    setState(() {
      _titleController.text = template.titleTemplate;
      _descriptionController.text = template.descriptionTemplate ?? '';
      _selectedPriority = template.priority;
      _tags = List.from(template.tags);
      _subTasks = template.subTaskTemplates.map((st) => 
        st.copyWith(taskId: '') // Will be set when task is created
      ).toList();
      _recurrencePattern = template.recurrence;
    });

    // Increment template usage count
    ref.read(taskTemplateNotifierProvider.notifier)
        .incrementTemplateUsage(template.id);
  }
}

/// Priority selector widget
class _PrioritySelector extends StatelessWidget {
  final TaskPriority selectedPriority;
  final ValueChanged<TaskPriority> onPriorityChanged;

  const _PrioritySelector({
    required this.selectedPriority,
    required this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: TaskPriority.values.map((priority) {
        final isSelected = priority == selectedPriority;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(priority.displayName),
              selected: isSelected,
              onSelected: (_) => onPriorityChanged(priority),
              backgroundColor: priority.color.withValues(alpha: 0.1),
              selectedColor: priority.color.withValues(alpha: 0.1),
              checkmarkColor: priority.color,
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Due date selector widget
class _DueDateSelector extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateChanged;

  const _DueDateSelector({
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _selectDate(context),
            icon: const Icon(Icons.calendar_today),
            label: Text(
              selectedDate != null
                  ? _formatDate(selectedDate!)
                  : 'Select due date',
            ),
          ),
        ),
        if (selectedDate != null) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => onDateChanged(null),
            icon: const Icon(Icons.clear),
            tooltip: 'Clear due date',
          ),
        ],
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (date != null) {
      onDateChanged(date);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == tomorrow) {
      return 'Tomorrow';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Tags section widget
class _TagsSection extends StatefulWidget {
  final List<String> tags;
  final ValueChanged<List<String>> onTagsChanged;

  const _TagsSection({
    required this.tags,
    required this.onTagsChanged,
  });

  @override
  State<_TagsSection> createState() => _TagsSectionState();
}

class _TagsSectionState extends State<_TagsSection> {
  final _tagController = TextEditingController();

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add tag field
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                decoration: const InputDecoration(
                  hintText: 'Add a tag',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: _addTag,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _addTag(_tagController.text),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Tags display
        if (widget.tags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: widget.tags.map((tag) {
              return Chip(
                label: Text(tag),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => _removeTag(tag),
              );
            }).toList(),
          ),
      ],
    );
  }

  void _addTag(String tag) {
    final trimmedTag = tag.trim();
    if (trimmedTag.isNotEmpty && !widget.tags.contains(trimmedTag)) {
      final updatedTags = [...widget.tags, trimmedTag];
      widget.onTagsChanged(updatedTags);
      _tagController.clear();
    }
  }

  void _removeTag(String tag) {
    final updatedTags = widget.tags.where((t) => t != tag).toList();
    widget.onTagsChanged(updatedTags);
  }
}
/// Subtasks section widget for the task form
class _SubTasksSection extends StatefulWidget {
  final List<SubTask> subTasks;
  final ValueChanged<List<SubTask>> onSubTasksChanged;

  const _SubTasksSection({
    required this.subTasks,
    required this.onSubTasksChanged,
  });

  @override
  State<_SubTasksSection> createState() => _SubTasksSectionState();
}

class _SubTasksSectionState extends State<_SubTasksSection> {
  final _subTaskController = TextEditingController();

  @override
  void dispose() {
    _subTaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add subtask field
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _subTaskController,
                decoration: const InputDecoration(
                  hintText: 'Add a subtask',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: _addSubTask,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _addSubTask(_subTaskController.text),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Subtasks display
        if (widget.subTasks.isNotEmpty)
          Column(
            children: widget.subTasks.asMap().entries.map((entry) {
              final index = entry.key;
              final subTask = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    // Drag handle for reordering
                    Icon(
                      Icons.drag_handle,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
                    ),
                    const SizedBox(width: 8),
                    
                    // Checkbox
                    Checkbox(
                      value: subTask.isCompleted,
                      onChanged: (value) => _toggleSubTask(index),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    
                    // Title
                    Expanded(
                      child: Text(
                        subTask.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          decoration: subTask.isCompleted 
                              ? TextDecoration.lineThrough 
                              : null,
                          color: subTask.isCompleted 
                              ? Theme.of(context).colorScheme.onSurfaceVariant 
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    
                    // Edit button
                    IconButton(
                      onPressed: () => _editSubTask(index),
                      icon: const Icon(Icons.edit, size: 16),
                      tooltip: 'Edit subtask',
                    ),
                    
                    // Delete button
                    IconButton(
                      onPressed: () => _removeSubTask(index),
                      icon: const Icon(Icons.delete, size: 16),
                      tooltip: 'Delete subtask',
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  void _addSubTask(String title) {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isNotEmpty) {
      final newSubTask = SubTask.create(
        taskId: '', // Will be set when the task is created/updated
        title: trimmedTitle,
        sortOrder: widget.subTasks.length,
      );
      
      final updatedSubTasks = [...widget.subTasks, newSubTask];
      widget.onSubTasksChanged(updatedSubTasks);
      _subTaskController.clear();
    }
  }

  void _removeSubTask(int index) {
    final updatedSubTasks = List<SubTask>.from(widget.subTasks);
    updatedSubTasks.removeAt(index);
    
    // Update sort orders
    for (int i = 0; i < updatedSubTasks.length; i++) {
      updatedSubTasks[i] = updatedSubTasks[i].copyWith(sortOrder: i);
    }
    
    widget.onSubTasksChanged(updatedSubTasks);
  }

  void _toggleSubTask(int index) {
    final updatedSubTasks = List<SubTask>.from(widget.subTasks);
    final subTask = updatedSubTasks[index];
    
    updatedSubTasks[index] = subTask.isCompleted 
        ? subTask.markIncomplete() 
        : subTask.markCompleted();
    
    widget.onSubTasksChanged(updatedSubTasks);
  }

  void _editSubTask(int index) {
    final subTask = widget.subTasks[index];
    final controller = TextEditingController(text: subTask.title);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Subtask'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Subtask title',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty) {
                final updatedSubTasks = List<SubTask>.from(widget.subTasks);
                updatedSubTasks[index] = subTask.copyWith(title: newTitle);
                widget.onSubTasksChanged(updatedSubTasks);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}