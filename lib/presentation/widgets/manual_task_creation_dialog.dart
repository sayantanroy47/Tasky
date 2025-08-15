import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/entities/recurrence_pattern.dart';
import '../../domain/models/enums.dart';
import '../providers/task_provider.dart' show taskOperationsProvider;
import 'glassmorphism_container.dart';
import '../../core/theme/material3/motion_system.dart';
import '../../core/theme/typography_constants.dart';
import '../../core/design_system/design_tokens.dart' hide BorderRadius;
import 'recurring_task_scheduling_widget.dart';
import 'theme_aware_dialog_components.dart';

/// Manual Task Creation Dialog with form inputs
class ManualTaskCreationDialog extends ConsumerStatefulWidget {
  const ManualTaskCreationDialog({super.key});
  
  @override
  ConsumerState<ManualTaskCreationDialog> createState() => _ManualTaskCreationDialogState();
}

class _ManualTaskCreationDialogState extends ConsumerState<ManualTaskCreationDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _selectedDueDate;
  bool _isCreating = false;
  
  // Recurring task scheduling
  RecurrencePattern? _recurrencePattern;
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ThemeAwareTaskDialog(
      title: 'Create Task',
      subtitle: 'Fill in task information',
      icon: Icons.edit,
      // No onBack - remove back button for manual task creation
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title field
                ThemeAwareFormField(
                controller: _titleController,
                labelText: 'Task Title',
                hintText: 'Enter task title...',
                prefixIcon: Icons.title,
                required: true,
                autofocus: true,
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
                labelText: 'Description (Optional)',
                hintText: 'Enter task description...',
                prefixIcon: Icons.description,
                maxLines: 3,
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
              ),
              
                const SizedBox(height: 16),
              
                // Priority selection
                ThemeAwarePrioritySelector(
                selectedPriority: _selectedPriority.name,
                priorities: TaskPriority.values.map((priority) => PriorityOption(
                  value: priority.name,
                  name: _getPriorityLabel(priority),
                  icon: Icons.flag,
                  color: _getPriorityColor(priority),
                )).toList(),
                onPriorityChanged: (String value) {
                  final priority = TaskPriority.values.firstWhere(
                    (p) => p.name == value,
                    orElse: () => TaskPriority.medium,
                  );
                  setState(() {
                    _selectedPriority = priority;
                  });
                },
              ),
              
                const SizedBox(height: 16),
              
                // Universal Recurring Task Scheduling Widget
                RecurringTaskSchedulingWidget(
                onRecurrenceChanged: (RecurrencePattern? pattern) {
                  setState(() {
                    _recurrencePattern = pattern;
                  });
                },
                initiallyEnabled: _recurrencePattern != null,
                initialRecurrence: _recurrencePattern,
              ),
              
                const SizedBox(height: 16),
              
                // Enhanced Due date selection with glassmorphism
                Semantics(
                label: _selectedDueDate == null 
                    ? 'Select due date, optional' 
                    : 'Due date: ${_formatDate(_selectedDueDate!)}',
                button: true,
                child: GlassmorphismContainer(
                  level: GlassLevel.content,
                  borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
                  glassTint: theme.colorScheme.secondaryContainer.withOpacity(0.1),
                  child: InkWell(
                    onTap: () => _selectDueDate(context),
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today, 
                            color: _selectedDueDate == null 
                                ? theme.colorScheme.onSurfaceVariant
                                : theme.colorScheme.secondary,
                            size: 20,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _selectedDueDate == null 
                                  ? 'Select due date (Optional)'
                                  : 'Due: ${_formatDate(_selectedDueDate!)}',
                              style: TextStyle(
                                fontSize: TypographyConstants.textBase,
                                color: _selectedDueDate == null 
                                    ? theme.colorScheme.onSurfaceVariant
                                    : theme.colorScheme.onSurface,
                                fontWeight: _selectedDueDate == null 
                                    ? TypographyConstants.regular
                                    : TypographyConstants.medium,
                              ),
                            ),
                          ),
                          if (_selectedDueDate != null)
                            Semantics(
                              label: 'Clear due date',
                              button: true,
                              child: GlassmorphismContainer(
                                level: GlassLevel.interactive,
                                width: 32,
                                height: 32,
                                borderRadius: BorderRadius.circular(TypographyConstants.radiusXSmall),
                                glassTint: theme.colorScheme.error.withOpacity(0.1),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedDueDate = null;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(TypographyConstants.radiusXSmall),
                                  child: Icon(
                                    Icons.clear, 
                                    size: 16,
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
                const SizedBox(height: 32),
              
                // Action buttons
                Row(
                children: [
                  Expanded(
                    child: RoundedGlassButton(
                      label: 'Cancel',
                      onPressed: _isCreating ? null : () => Navigator.of(context).pop(),
                      icon: Icons.cancel,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: RoundedGlassButton(
                      label: 'Create Task',
                      onPressed: _isCreating ? null : _createTask,
                      icon: Icons.add,
                      isPrimary: true,
                      isLoading: _isCreating,
                    ),
                  ),
                ],
              ),
              ],
            ),
          ),
        ),
    );
  }
  
  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }
  
  void _createTask() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isCreating = true;
    });
    
    try {
      final task = TaskModel.create(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        priority: _selectedPriority,
        dueDate: _selectedDueDate,
        recurrence: _recurrencePattern,
      );
      
      // Add task through provider
      await ref.read(taskOperationsProvider).createTask(task);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Task created successfully!',
                  style: TextStyle(
                    fontSize: TypographyConstants.textSM,
                    fontWeight: TypographyConstants.medium,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.error,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Error creating task: $e',
                    style: TextStyle(
                      fontSize: TypographyConstants.textSM,
                      fontWeight: TypographyConstants.medium,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }
  
  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.blue;
      case TaskPriority.high:
        return Colors.orange;
      case TaskPriority.urgent:
        return Colors.red;
    }
  }
  
  String _getPriorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'Low Priority';
      case TaskPriority.medium:
        return 'Medium Priority';
      case TaskPriority.high:
        return 'High Priority';
      case TaskPriority.urgent:
        return 'Urgent Priority';
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}