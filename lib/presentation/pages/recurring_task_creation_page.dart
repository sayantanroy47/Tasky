import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/recurrence_pattern.dart';
import '../../domain/models/enums.dart';
import '../widgets/glassmorphism_container.dart';
import '../widgets/recurrence_pattern_picker.dart';
import '../widgets/project_selector.dart';
import '../../core/theme/typography_constants.dart';
import '../providers/recurring_task_providers.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Full page for creating recurring tasks
class RecurringTaskCreationPage extends ConsumerStatefulWidget {
  const RecurringTaskCreationPage({super.key});
  
  @override
  ConsumerState<RecurringTaskCreationPage> createState() => _RecurringTaskCreationPageState();
}

class _RecurringTaskCreationPageState extends ConsumerState<RecurringTaskCreationPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  TaskPriority _selectedPriority = TaskPriority.medium;
  String? _selectedProjectId;
  final List<String> _selectedTags = [];
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  RecurrencePattern _recurrencePattern = const RecurrencePattern(
    type: RecurrenceType.daily,
    interval: 1,
  );
  bool _isLoading = false;
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Create Recurring Task'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveTask,
            child: _isLoading 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task Details Section
                _buildTaskDetailsSection(theme),
                
                const SizedBox(height: 24),
                
                // Recurrence Pattern Section
                _buildRecurrenceSection(theme),
                
                const SizedBox(height: 24),
                
                // Due Date Section
                _buildDueDateSection(theme),
                
                const SizedBox(height: 24),
                
                // Project Selection Section
                _buildProjectSection(theme),
                
                const SizedBox(height: 24),
                
                // Priority Section
                _buildPrioritySection(theme),
                
                const SizedBox(height: 32),
                
                // Create Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _saveTask,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Create Recurring Task'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildTaskDetailsSection(ThemeData theme) {
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Task Details',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Title Field
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Task Title',
              hintText: 'Enter a descriptive title',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Task title is required';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Description Field
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              hintText: 'Add more details about this task',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecurrenceSection(ThemeData theme) {
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recurrence Pattern',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          RecurrencePatternPicker(
            initialPattern: _recurrencePattern,
            onPatternChanged: (pattern) {
              setState(() {
                _recurrencePattern = pattern ?? const RecurrencePattern(
                  type: RecurrenceType.daily,
                  interval: 1,
                );
              });
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildDueDateSection(ThemeData theme) {
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'First Due Date',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectDate,
                  icon: Icon(PhosphorIcons.calendar()),
                  label: Text(_dueDate != null 
                    ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                    : 'Select Date'),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectTime,
                  icon: Icon(PhosphorIcons.clock()),
                  label: Text(_dueTime != null 
                    ? _dueTime!.format(context)
                    : 'Select Time'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildProjectSection(ThemeData theme) {
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Project Assignment',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ProjectSelector(
            selectedProjectId: _selectedProjectId,
            onProjectSelected: (project) {
              setState(() {
                _selectedProjectId = project?.id;
              });
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildPrioritySection(ThemeData theme) {
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Priority Level',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 12,
            children: TaskPriority.values.map((priority) {
              final isSelected = _selectedPriority == priority;
              final color = _getPriorityColor(priority);
              
              return FilterChip(
                label: Text(priority.name.toUpperCase()),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedPriority = priority;
                  });
                },
                backgroundColor: color.withValues(alpha: 0.1),
                selectedColor: color.withValues(alpha: 0.2),
                checkmarkColor: color,
                labelStyle: TextStyle(
                  color: isSelected ? color : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return Colors.red;
      case TaskPriority.high:
        return Colors.orange;
      case TaskPriority.medium:
        return Colors.blue;
      case TaskPriority.low:
        return Colors.green;
    }
  }
  
  Future<void> _selectDate() async {
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
  
  Future<void> _selectTime() async {
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
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Store context references before async operations
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final errorColor = Theme.of(context).colorScheme.error;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      DateTime? fullDueDate;
      if (_dueDate != null) {
        fullDueDate = DateTime(
          _dueDate!.year,
          _dueDate!.month,
          _dueDate!.day,
          _dueTime?.hour ?? 9,
          _dueTime?.minute ?? 0,
        );
      }
      
      // Create the recurring task
      await ref.read(recurringTaskNotifierProvider.notifier).createRecurringTask(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
          ? null : _descriptionController.text.trim(),
        priority: _selectedPriority,
        dueDate: fullDueDate,
        projectId: _selectedProjectId,
        tags: _selectedTags,
        recurrence: _recurrencePattern,
      );
      
      if (context.mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Recurring task created successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        navigator.pop();
      }
    } catch (e) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Error creating recurring task: $e'),
            backgroundColor: errorColor,
            behavior: SnackBarBehavior.floating,
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

