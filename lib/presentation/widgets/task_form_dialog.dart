import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/design_system/design_tokens.dart';
import '../../core/theme/typography_constants.dart';
import '../../domain/entities/recurrence_pattern.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../providers/task_provider.dart' show taskOperationsProvider;
import 'glassmorphism_container.dart';
import 'project_selector.dart';
import 'theme_aware_dialog_components.dart';

/// Category option for task categorization
class CategoryOption {
  final String id;
  final String label;
  final IconData icon;
  
  const CategoryOption(this.id, this.label, this.icon);
}

/// Task form dialog for creating or editing tasks
class TaskFormDialog extends ConsumerStatefulWidget {
  final TaskModel? task;
  final bool isEditing;
  
  const TaskFormDialog({
    super.key,
    this.task,
    this.isEditing = false,
  });
  
  @override
  ConsumerState<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends ConsumerState<TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  // Notes are stored in description field
  
  TaskPriority _selectedPriority = TaskPriority.medium;
  String? _selectedProjectId;
  List<String> _selectedTags = [];
  DateTime? _dueDate = DateTime.now();
  TimeOfDay? _dueTime;
  RecurrencePattern? _recurrencePattern;
  bool _isLoading = false;
  
  // Performance optimization: removed unused cached priority options
  
  // Priority options
  static final List<PriorityOption> _priorityOptions = [
    PriorityOption(
      value: 'low',
      name: 'Low',
      icon: PhosphorIcons.arrowDown(),
      color: const Color(0xFF4CAF50), // Material Green for low priority
    ),
    PriorityOption(
      value: 'medium',
      name: 'Medium',
      icon: PhosphorIcons.minus(),
      color: const Color(0xFFFF9800), // Material Orange for medium priority
    ),
    PriorityOption(
      value: 'high',
      name: 'High',
      icon: PhosphorIcons.arrowUp(),
      color: const Color(0xFFE53935), // Material Red for high priority
    ),
    PriorityOption(
      value: 'urgent',
      name: 'Urgent',
      icon: PhosphorIcons.warning(),
      color: Colors.deepPurple,
    ),
  ];
  
  @override
  void initState() {
    super.initState();
    _initializeFromTask();
  }
  
  void _initializeFromTask() {
    if (widget.task != null && widget.isEditing) {
      final task = widget.task!;
      _titleController.text = task.title;
      _descriptionController.text = task.description ?? '';
      // Notes are handled via description
      _selectedPriority = task.priority;
      _selectedProjectId = task.projectId;
      _selectedTags = task.tags;
      _dueDate = task.dueDate;
      _recurrencePattern = task.recurrence;
      
      if (task.dueDate != null) {
        _dueTime = TimeOfDay.fromDateTime(task.dueDate!);
      }
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    // No notes controller to dispose
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return ThemeAwareTaskDialog(
      title: widget.isEditing ? 'Edit Task' : 'Create Task',
      subtitle: widget.isEditing ? 'Update task details' : 'Add a new task',
      icon: widget.isEditing ? PhosphorIcons.pencil() : PhosphorIcons.plus(),
      onBack: () => Navigator.of(context).pop(),
      actions: [
        ThemeAwareButton(
          label: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
          icon: PhosphorIcons.x(),
        ),
        ThemeAwareButton(
          label: widget.isEditing ? 'Update' : 'Create',
          onPressed: _isLoading ? null : _saveTask,
          icon: widget.isEditing ? PhosphorIcons.floppyDisk() : PhosphorIcons.plus(),
          isPrimary: true,
          isLoading: _isLoading,
        ),
      ],
      child: _buildForm(context),
    );
  }
  
  Widget _buildForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title field
              ThemeAwareFormField(
                controller: _titleController,
                labelText: 'Task Title',
                hintText: 'Enter task title',
                prefixIcon: PhosphorIcons.textT(),
                autofocus: !widget.isEditing,
                required: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Description field
              ThemeAwareFormField(
                controller: _descriptionController,
                labelText: 'Description',
                hintText: 'Enter task description (optional)',
                prefixIcon: PhosphorIcons.fileText(),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              
              // Priority selector
              ThemeAwarePrioritySelector(
                selectedPriority: _selectedPriority.name.toLowerCase(),
                onPriorityChanged: (priority) {
                  setState(() {
                    _selectedPriority = TaskPriority.values.firstWhere(
                      (p) => p.name.toLowerCase() == priority,
                      orElse: () => TaskPriority.medium,
                    );
                  });
                },
                priorities: _priorityOptions,
              ),
              const SizedBox(height: 16),
              
              // Project selector
              ProjectSelector(
                selectedProjectId: _selectedProjectId,
                onProjectSelected: (project) {
                  setState(() {
                    _selectedProjectId = project?.id;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Category selector
              _buildCategorySelector(context),
              const SizedBox(height: 16),
              
              // Due date picker
              _buildDueDatePicker(context),
              const SizedBox(height: 16),
              
              // Recurrence pattern (placeholder)
              GlassmorphismContainer(
                level: GlassLevel.interactive,
                borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Recurring Tasks: Coming Soon',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Additional fields could go here
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDueDatePicker(BuildContext context) {
    final theme = Theme.of(context);
    
    return GlassmorphismContainer(
      level: GlassLevel.interactive,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Due Date',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDateButton(context, theme),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTimeButton(context, theme),
              ),
            ],
          ),
          if (_dueDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _dueDate = null;
                    _dueTime = null;
                  });
                },
                icon: Icon(PhosphorIcons.x(), size: 16),
                label: const Text('Clear due date'),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildDateButton(BuildContext context, ThemeData theme) {
    return InkWell(
      onTap: _selectDueDate,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              PhosphorIcons.calendar(),
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              _dueDate != null
                  ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                  : 'Select date',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _dueDate != null
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTimeButton(BuildContext context, ThemeData theme) {
    return InkWell(
      onTap: _dueDate != null ? _selectDueTime : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              PhosphorIcons.clock(),
              size: 18,
              color: _dueDate != null
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 8),
            Text(
              _dueTime != null
                  ? '${_dueTime!.hour.toString().padLeft(2, '0')}:${_dueTime!.minute.toString().padLeft(2, '0')}'
                  : 'Select time',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _dueTime != null
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 
                        _dueDate != null ? 1.0 : 0.5,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    
    if (date != null) {
      setState(() {
        _dueDate = date;
      });
    }
  }
  
  Future<void> _selectDueTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );
    
    if (time != null) {
      setState(() {
        _dueTime = time;
      });
    }
  }
  
  // Predefined categories with icons
  static final List<CategoryOption> _predefinedCategories = [
    CategoryOption('work', 'Work', PhosphorIcons.briefcase()),
    CategoryOption('personal', 'Personal', PhosphorIcons.user()),
    CategoryOption('shopping', 'Shopping', PhosphorIcons.shoppingCart()),
    CategoryOption('health', 'Health', PhosphorIcons.heartbeat()),
    CategoryOption('fitness', 'Fitness', PhosphorIcons.barbell()),
    CategoryOption('finance', 'Finance', PhosphorIcons.wallet()),
    CategoryOption('education', 'Education', PhosphorIcons.graduationCap()),
    CategoryOption('travel', 'Travel', PhosphorIcons.airplane()),
    CategoryOption('home', 'Home', PhosphorIcons.house()),
    CategoryOption('family', 'Family', PhosphorIcons.users()),
    CategoryOption('entertainment', 'Entertainment', PhosphorIcons.filmStrip()),
    CategoryOption('food', 'Food', PhosphorIcons.forkKnife()),
  ];
  
  Widget _buildCategorySelector(BuildContext context) {
    final theme = Theme.of(context);
    
    return GlassmorphismContainer(
      level: GlassLevel.interactive,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categories',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          
          // Predefined category chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _predefinedCategories.map((category) {
              final isSelected = _selectedTags.contains(category.id);
              return _buildCategoryChip(
                context,
                category,
                isSelected,
                () => _toggleCategory(category.id),
              );
            }).toList(),
          ),
          
          // Selected tags display
          if (_selectedTags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Selected: ${_selectedTags.join(', ')}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          
          // Custom tag input (future enhancement)
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => _showAddCustomTagDialog(context),
            icon: Icon(PhosphorIcons.plus(), size: 16),
            label: const Text('Add custom tag'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoryChip(
    BuildContext context,
    CategoryOption category,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.15)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: 16,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              category.label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _toggleCategory(String categoryId) {
    setState(() {
      if (_selectedTags.contains(categoryId)) {
        _selectedTags.remove(categoryId);
      } else {
        _selectedTags.add(categoryId);
      }
    });
  }
  
  Future<void> _showAddCustomTagDialog(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Tag'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter tag name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final tag = controller.text.trim();
              if (tag.isNotEmpty) {
                Navigator.pop(context, tag);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    
    if (result != null && result.isNotEmpty && !_selectedTags.contains(result)) {
      setState(() {
        _selectedTags.add(result);
      });
    }
  }
  
  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Combine date and time if both are set
      DateTime? finalDueDate;
      if (_dueDate != null) {
        finalDueDate = DateTime(
          _dueDate!.year,
          _dueDate!.month,
          _dueDate!.day,
          _dueTime?.hour ?? 23,
          _dueTime?.minute ?? 59,
        );
      }
      
      final task = TaskModel(
        id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        priority: _selectedPriority,
        status: widget.task?.status ?? TaskStatus.pending,
        projectId: _selectedProjectId,
        tags: _selectedTags,
        dueDate: finalDueDate,
        recurrence: _recurrencePattern,
        // Notes stored in description field
        createdAt: widget.task?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      if (widget.isEditing && widget.task != null) {
        await ref.read(taskOperationsProvider).updateTask(task);
      } else {
        await ref.read(taskOperationsProvider).createTask(task);
      }
      
      if (mounted) {
        Navigator.of(context).pop(task);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving task: ${e.toString()}'),
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
}

/// Show task form dialog
Future<TaskModel?> showTaskFormDialog(
  BuildContext context, {
  TaskModel? task,
  bool isEditing = false,
}) {
  return showDialog<TaskModel>(
    context: context,
    builder: (context) => TaskFormDialog(
      task: task,
      isEditing: isEditing,
    ),
  );
}



