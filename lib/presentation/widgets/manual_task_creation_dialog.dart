import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/entities/recurrence_pattern.dart';

import '../../domain/models/enums.dart';
import '../providers/task_provider.dart' show taskOperationsProvider;


import 'glassmorphism_container.dart';

import '../../core/theme/typography_constants.dart';
import '../../core/design_system/design_tokens.dart';

import 'theme_aware_dialog_components.dart';
import 'project_selector.dart';
import 'recurrence_pattern_picker.dart';
import 'dart:async';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Manual task creation dialog with form fields
class ManualTaskCreationDialog extends ConsumerStatefulWidget {
  final TaskModel? editingTask;
  final Function(TaskModel)? onTaskCreated;
  
  const ManualTaskCreationDialog({
    super.key,
    this.editingTask,
    this.onTaskCreated,
  });
  
  @override
  ConsumerState<ManualTaskCreationDialog> createState() => _ManualTaskCreationDialogState();
}

class _ManualTaskCreationDialogState extends ConsumerState<ManualTaskCreationDialog> {
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
  
  // Priority options
  final List<PriorityOption> _priorityOptions = [
    PriorityOption(
      value: 'low',
      name: 'Low',
      icon: PhosphorIcons.arrowDown(),
      color: Colors.green,
    ),
    PriorityOption(
      value: 'medium',
      name: 'Medium',
      icon: PhosphorIcons.minus(),
      color: Colors.orange,
    ),
    PriorityOption(
      value: 'high',
      name: 'High',
      icon: PhosphorIcons.arrowUp(),
      color: Colors.red,
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
    _initializeFromEditingTask();
  }
  
  void _initializeFromEditingTask() {
    if (widget.editingTask != null) {
      final task = widget.editingTask!;
      _titleController.text = task.title;
      _descriptionController.text = task.description ?? '';
      // Notes are handled via description
      _selectedPriority = task.priority;
      _selectedProjectId = task.projectId;
      _selectedTags = task.tags;
      _dueDate = task.dueDate;
      _recurrencePattern = task.recurrence;
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
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(widget.editingTask != null ? 'Edit Task' : 'Create Task'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveTask,
            child: _isLoading 
              ? const SizedBox(width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
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
                      autofocus: true,
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
                    
                    // Due date picker
                    _buildDueDatePicker(context, theme),
                    const SizedBox(height: 16),
                    
                    // Recurrence pattern picker
                    GlassmorphismContainer(
                      level: GlassLevel.interactive,
                      borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                PhosphorIcons.repeat(),
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Recurring Task',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          RecurrencePatternPicker(
                            initialPattern: _recurrencePattern,
                            onPatternChanged: (pattern) {
                              setState(() {
                                _recurrencePattern = pattern;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Additional fields could go here
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
        ),
      ),
    );
  }
  
  Widget _buildDueDatePicker(BuildContext context, ThemeData theme) {
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
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _selectDueDate,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
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
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: _dueDate != null ? _selectDueTime : null,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
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
                ),
              ),
            ],
          ),
          if (_dueDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
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
        id: widget.editingTask?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        priority: _selectedPriority,
        status: widget.editingTask?.status ?? TaskStatus.pending,
        projectId: _selectedProjectId,
        tags: _selectedTags,
        dueDate: finalDueDate,
        recurrence: _recurrencePattern,
        // Notes stored in description field
        createdAt: widget.editingTask?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      if (widget.editingTask != null) {
        await ref.read(taskOperationsProvider).updateTask(task);
      } else {
        await ref.read(taskOperationsProvider).createTask(task);
      }
      
      if (mounted) {
        widget.onTaskCreated?.call(task);
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



