import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../providers/task_provider.dart' show taskOperationsProvider;
import '../widgets/glassmorphism_container.dart';
import '../widgets/theme_background_widget.dart';
import '../widgets/standardized_app_bar.dart';
import '../../core/theme/typography_constants.dart';
import '../../core/design_system/design_tokens.dart';
import '../../core/theme/material3/motion_system.dart';

/// Ultra-modern full-screen manual task creation page
class ManualTaskCreationPage extends ConsumerStatefulWidget {
  final Map<String, String>? prePopulatedData;
  
  const ManualTaskCreationPage({
    super.key,
    this.prePopulatedData,
  });
  
  @override
  ConsumerState<ManualTaskCreationPage> createState() => _ManualTaskCreationPageState();
}

class _ManualTaskCreationPageState extends ConsumerState<ManualTaskCreationPage>
    with TickerProviderStateMixin {
  
  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Task properties
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  DateTime? _reminderDate;
  TimeOfDay? _reminderTime;
  bool _isCreating = false;
  
  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: ExpressiveMotionSystem.durationMedium2,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    
    // Pre-populate from widget data
    if (widget.prePopulatedData != null) {
      _titleController.text = widget.prePopulatedData!['title'] ?? '';
      _descriptionController.text = widget.prePopulatedData!['description'] ?? '';
    }
    
    _fadeController.forward();
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  String _formatDuration(DateTime date, TimeOfDay? time) {
    final now = DateTime.now();
    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time?.hour ?? 0,
      time?.minute ?? 0,
    );
    
    if (dateTime.day == now.day && dateTime.month == now.month && dateTime.year == now.year) {
      return time != null ? 'Today at ${time.format(context)}' : 'Today';
    }
    
    final tomorrow = now.add(Duration(days: 1));
    if (dateTime.day == tomorrow.day && dateTime.month == tomorrow.month && dateTime.year == tomorrow.year) {
      return time != null ? 'Tomorrow at ${time.format(context)}' : 'Tomorrow';
    }
    
    final dateStr = '${date.day}/${date.month}/${date.year}';
    return time != null ? '$dateStr at ${time.format(context)}' : dateStr;
  }
  
  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() => _isCreating = true);
    
    try {
      DateTime? fullDueDate;
      if (_dueDate != null) {
        fullDueDate = DateTime(
          _dueDate!.year,
          _dueDate!.month,
          _dueDate!.day,
          _dueTime?.hour ?? 23,
          _dueTime?.minute ?? 59,
        );
      }
      
      DateTime? fullReminderDate;
      if (_reminderDate != null) {
        fullReminderDate = DateTime(
          _reminderDate!.year,
          _reminderDate!.month,
          _reminderDate!.day,
          _reminderTime?.hour ?? 9,
          _reminderTime?.minute ?? 0,
        );
      }
      
      final task = TaskModel.create(
        title: _titleController.text,
        description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
        priority: _priority,
        dueDate: fullDueDate,
        metadata: {
          'created_from': 'manual_creation',
          'creation_mode': widget.prePopulatedData?['creationMode'] ?? 'manual',
          'reminder_date': fullReminderDate?.toIso8601String(),
        },
      );
      
      await ref.read(taskOperationsProvider).createTask(task);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task created successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create task: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ThemeBackgroundWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: StandardizedAppBar(
          title: 'Create Task',
          actions: [
            SizedBox(
              width: 80,
              child: TextButton(
                onPressed: _isCreating ? null : _createTask,
                child: _isCreating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Create"),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [SizedBox(height: 20),
                    
                    // Title Section
                    _buildTitleSection(context, theme),
                    
                    SizedBox(height: 20),
                    
                    // Description Section
                    _buildDescriptionSection(context, theme),
                    
                    SizedBox(height: 20),
                    
                    // Priority Section
                    _buildPrioritySection(context, theme),
                    
                    SizedBox(height: 20),
                    
                    // Due Date Section
                    _buildDueDateSection(context, theme),
                    
                    SizedBox(height: 20),
                    
                    // Reminder Section
                    _buildReminderSection(context, theme),
                    
                    SizedBox(height: 32),
                    
                    // Create Button
                    _buildCreateButton(context, theme),
                    
                    SizedBox(height: 100), // Bottom padding
                  ],
                ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildTitleSection(BuildContext context, ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Row(
            children: [
              Icon(
                PhosphorIcons.listChecks(),
                size: 24,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: 8),
              Text(
                'Task Title',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              )]),
          SizedBox(height: 12),
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'Enter a clear, actionable task title...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Task title is required';
              }
              return null;
            },
            textInputAction: TextInputAction.next,
          )]),
    );
  }
  
  Widget _buildDescriptionSection(BuildContext context, ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Row(
            children: [
              Icon(
                PhosphorIcons.textAa(),
                size: 20,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: 8),
              Text(
                'Description',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Text(
                '(Optional)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )]),
          SizedBox(height: 12),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              hintText: 'Add additional details, notes, or context...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              ),
            ),
            maxLines: 3,
            textInputAction: TextInputAction.newline,
          )]),
    );
  }
  
  Widget _buildPrioritySection(BuildContext context, ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Row(
            children: [
              Icon(
                PhosphorIcons.flag(),
                size: 20,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: 8),
              Text(
                'Priority',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              )]),
          SizedBox(height: 12),
          Row(
            children: TaskPriority.values.map((priority) {
              final isSelected = _priority == priority;
              final color = priority == TaskPriority.high
                  ? theme.colorScheme.error
                  : priority == TaskPriority.medium
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.tertiary;
              
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => setState(() => _priority = priority),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? color : theme.colorScheme.outline.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              priority == TaskPriority.high ? PhosphorIcons.caretUp() :
                              priority == TaskPriority.medium ? PhosphorIcons.minus() :
                              PhosphorIcons.caretDown(),
                              color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                            SizedBox(height: 4),
                            Text(
                              priority.name.toUpperCase(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
                              ),
                            )]),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          )]),
    );
  }
  
  Widget _buildDueDateSection(BuildContext context, ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Row(
            children: [
              Icon(
                PhosphorIcons.calendar(),
                size: 20,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: 8),
              Text(
                'Due Date',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Text(
                '(Optional)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )]),
          SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _dueDate ?? DateTime.now().add(Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => _dueDate = date);
                    }
                  },
                  icon: Icon(PhosphorIcons.calendar()),
                  label: Text(_dueDate != null 
                      ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                      : 'Select Date'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _dueDate == null ? null : () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _dueTime ?? TimeOfDay(hour: 23, minute: 59),
                    );
                    if (time != null) {
                      setState(() => _dueTime = time);
                    }
                  },
                  icon: Icon(PhosphorIcons.clock()),
                  label: Text(_dueTime != null 
                      ? _dueTime!.format(context)
                      : 'Set Time'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              if (_dueDate != null)
                IconButton(
                  onPressed: () => setState(() {
                    _dueDate = null;
                    _dueTime = null;
                  }),
                  icon: Icon(PhosphorIcons.x()),
                  tooltip: 'Clear due date',
                )]),
          
          if (_dueDate != null) ...[
            SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Due: ${_formatDuration(_dueDate!, _dueTime)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ]]),
    );
  }
  
  Widget _buildReminderSection(BuildContext context, ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Row(
            children: [
              Icon(
                PhosphorIcons.bell(),
                size: 20,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: 8),
              Text(
                'Reminder',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Text(
                '(Optional)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )]),
          SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _reminderDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => _reminderDate = date);
                    }
                  },
                  icon: Icon(PhosphorIcons.calendar()),
                  label: Text(_reminderDate != null 
                      ? '${_reminderDate!.day}/${_reminderDate!.month}/${_reminderDate!.year}'
                      : 'Select Date'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _reminderDate == null ? null : () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _reminderTime ?? TimeOfDay(hour: 9, minute: 0),
                    );
                    if (time != null) {
                      setState(() => _reminderTime = time);
                    }
                  },
                  icon: Icon(PhosphorIcons.clock()),
                  label: Text(_reminderTime != null 
                      ? _reminderTime!.format(context)
                      : 'Set Time'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              if (_reminderDate != null)
                IconButton(
                  onPressed: () => setState(() {
                    _reminderDate = null;
                    _reminderTime = null;
                  }),
                  icon: Icon(PhosphorIcons.x()),
                  tooltip: 'Clear reminder',
                )]),
          
          if (_reminderDate != null) ...[
            SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Reminder: ${_formatDuration(_reminderDate!, _reminderTime)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ),
          ]]),
    );
  }
  
  Widget _buildCreateButton(BuildContext context, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isCreating ? null : _createTask,
        icon: _isCreating 
            ? SizedBox(width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(PhosphorIcons.plus()),
        label: Text(_isCreating ? 'Creating...' : 'Create Task'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
          ),
        ),
      ),
    );
  }
}

