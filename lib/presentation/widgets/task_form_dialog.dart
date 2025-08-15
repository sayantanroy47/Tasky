import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/typography_constants.dart';
import '../../core/theme/material3/motion_system.dart';
import '../../core/design_system/design_tokens.dart' hide BorderRadius;
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../providers/task_provider.dart';
import 'glassmorphism_container.dart';
import 'theme_aware_dialog_components.dart';

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

class _TaskFormDialogState extends ConsumerState<TaskFormDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;
  String? _projectId;
  List<String> _tags = [];
  bool _isPinned = false;
  int? _estimatedDuration;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: ExpressiveMotionSystem.durationMedium3,
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: ExpressiveMotionSystem.durationMedium2,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: ExpressiveMotionSystem.emphasizedDecelerate,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: ExpressiveMotionSystem.emphasizedDecelerate,
    ));
    
    _initializeForm();
    _fadeController.forward();
    _scaleController.forward();
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
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ThemeAwareTaskDialog(
          title: isEditing ? 'Edit Task' : 'Create Task',
          subtitle: isEditing ? 'Update task details' : 'Fill in task information',
          icon: isEditing ? Icons.edit : Icons.add_task,
          onBack: () => Navigator.of(context).pop(),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTitleField(theme),
                          const SizedBox(height: 16),
                          _buildDescriptionField(theme),
                          const SizedBox(height: 16),
                          _buildPrioritySelector(theme),
                          const SizedBox(height: 16),
                          _buildDueDateSelector(theme),
                          const SizedBox(height: 16),
                          _buildTagsField(theme),
                          const SizedBox(height: 16),
                          _buildPinToggle(theme),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildFooter(context, theme, isEditing),
              ],
            ),
        ),
      ),
    );
  }

  // Header is now handled by ThemeAwareTaskDialog - this method is no longer needed

  Widget _buildTitleField(ThemeData theme) {
    return ThemeAwareFormField(
      controller: _titleController,
      labelText: 'Task Title',
      hintText: 'Enter task title...',
      prefixIcon: Icons.title,
      required: true,
      autofocus: widget.task == null,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a task title';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField(ThemeData theme) {
    return ThemeAwareFormField(
      controller: _descriptionController,
      labelText: 'Description (Optional)',
      hintText: 'Enter task description...',
      prefixIcon: Icons.description,
      maxLines: 3,
      textInputAction: TextInputAction.newline,
      keyboardType: TextInputType.multiline,
    );
  }

  Widget _buildPrioritySelector(ThemeData theme) {
    return ThemeAwarePrioritySelector(
      selectedPriority: _priority.name,
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
          _priority = priority;
        });
      },
    );
  }

  Widget _buildDueDateSelector(ThemeData theme) {
    return GestureDetector(
      onTap: _selectDueDate,
      child: GlassmorphismContainer(
        level: GlassLevel.content,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
        padding: const EdgeInsets.all(16),
        glassTint: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderColor: theme.colorScheme.outline.withOpacity(0.3),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: _dueDate == null 
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _dueDate == null 
                    ? 'Set Due Date (Optional)'
                    : 'Due: ${_formatDate(_dueDate!)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: _dueDate == null 
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (_dueDate != null)
              IconButton(
                onPressed: () {
                  setState(() {
                    _dueDate = null;
                  });
                },
                icon: const Icon(Icons.clear),
                iconSize: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsField(ThemeData theme) {
    return ThemeAwareFormField(
      labelText: 'Tags (Optional)',
      hintText: 'Enter tags separated by commas...',
      prefixIcon: Icons.tag,
    );
  }

  Widget _buildPinToggle(ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.interactive,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      glassTint: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
      child: SwitchListTile(
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
    );
  }

  Widget _buildFooter(BuildContext context, ThemeData theme, bool isEditing) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(TypographyConstants.dialogRadius),
        bottomRight: Radius.circular(TypographyConstants.dialogRadius),
      ),
      padding: const EdgeInsets.all(20),
      glassTint: theme.colorScheme.surface.withOpacity(0.8),
      borderColor: Colors.transparent,
      child: Row(
        children: [
          Expanded(
            child: RoundedGlassButton(
              label: 'Cancel',
              onPressed: () => Navigator.of(context).pop(),
              icon: Icons.cancel,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: RoundedGlassButton(
              label: isEditing ? 'Update Task' : 'Create Task',
              onPressed: _saveTask,
              icon: isEditing ? Icons.edit : Icons.add,
              isPrimary: true,
            ),
          ),
        ],
      ),
    );
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