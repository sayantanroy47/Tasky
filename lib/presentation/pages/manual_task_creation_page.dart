import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/design_system/design_tokens.dart';
import '../../core/theme/material3/motion_system.dart';
import '../../core/theme/typography_constants.dart';
import '../../core/utils/category_utils.dart';
import '../../domain/entities/tag.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../../domain/entities/recurrence_pattern.dart';
import '../../services/location/location_models.dart';
import '../providers/task_provider.dart' show taskOperationsProvider;
import '../providers/location_providers.dart';
import '../widgets/glassmorphism_container.dart';
import '../widgets/standardized_app_bar.dart';
import '../widgets/standardized_text.dart';
import '../widgets/theme_background_widget.dart';
import '../widgets/recurrence_pattern_picker.dart';
import '../widgets/tag_selection_widget.dart';
import '../widgets/location_task_section.dart';

/// Ultra-modern full-screen manual task creation page
class ManualTaskCreationPage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? prePopulatedData;

  const ManualTaskCreationPage({
    super.key,
    this.prePopulatedData,
  });

  @override
  ConsumerState<ManualTaskCreationPage> createState() => _ManualTaskCreationPageState();
}

class _ManualTaskCreationPageState extends ConsumerState<ManualTaskCreationPage> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Task properties
  TaskPriority _priority = TaskPriority.medium;
  String? _selectedCategory;
  List<Tag> _selectedTags = [];
  DateTime? _dueDate = DateTime.now();
  TimeOfDay? _dueTime;
  DateTime? _reminderDate;
  TimeOfDay? _reminderTime;
  String? _audioFilePath;
  bool _isCreating = false;
  
  // Recurring task properties
  bool _isRecurringTask = false;
  RecurrencePattern? _recurrencePattern;

  // Location properties
  LocationData? _selectedLocation;

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
      // Handle title from manual entry - transcribedText should go to description
      _titleController.text = (widget.prePopulatedData!['title'] as String?) ?? '';
      _descriptionController.text = (widget.prePopulatedData!['description'] as String?) ?? 
                                   (widget.prePopulatedData!['transcribedText'] as String?) ?? '';
      
      // Handle due date pre-population
      final dueDateString = widget.prePopulatedData!['dueDate'] as String?;
      if (dueDateString != null && dueDateString.isNotEmpty) {
        try {
          _dueDate = DateTime.parse(dueDateString);
        } catch (e) {
          debugPrint('Error parsing due date: $dueDateString, error: $e');
        }
      }
      
      // Handle audio file from voice recording
      final audioFilePath = widget.prePopulatedData!['audioFilePath'] as String?;
      if (audioFilePath != null && audioFilePath.isNotEmpty) {
        _audioFilePath = audioFilePath;
        debugPrint('Pre-populated audio file: $audioFilePath');
      }
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

    final tomorrow = now.add(const Duration(days: 1));
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

      // Debug: Log what we're trying to save
      debugPrint('🔍 Creating task with category: $_selectedCategory and ${_selectedTags.length} tags: ${_selectedTags.map((t) => t.name).join(', ')}');
      final tags = <String>[if (_selectedCategory != null) _selectedCategory!];
      final tagIds = _selectedTags.map((tag) => tag.id).toList();
      debugPrint('🔍 Legacy tags array: $tags, TagIds array: $tagIds');


      final task = TaskModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
        priority: _priority,
        status: TaskStatus.pending,
        tags: tags, // Legacy category system
        tagIds: tagIds, // New tag system
        dueDate: fullDueDate,
        recurrence: _isRecurringTask ? _recurrencePattern : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: {
          'created_from': 'manual_creation',
          'creation_mode': (widget.prePopulatedData?['creationMode'] as String?) ?? 'manual',
          'reminder_date': fullReminderDate?.toIso8601String(),
          // Use correct audio metadata format matching voice-only page and TaskAudioExtensions
          if (_audioFilePath != null) 'audio': _buildAudioMetadata(),
          if (_audioFilePath != null) 'isVoiceCreated': widget.prePopulatedData?['creationMode'] == 'voiceToText',
          if (_audioFilePath != null) 'hasTranscription': (widget.prePopulatedData?['transcribedText'] as String?)?.isNotEmpty ?? false,
          // Location metadata
          if (_selectedLocation != null) 'hasLocation': true,
          if (_selectedLocation != null) 'locationData': _selectedLocation!.toJson(),
        },
      );

      // Debug: Log task after creation but before saving
      debugPrint('🔍 Created TaskModel with legacy tags: ${task.tags} and tagIds: ${task.tagIds}');
      debugPrint('🔍 TaskModel details: id=${task.id}, title=${task.title}, tags=${task.tags}, tagIds=${task.tagIds}');

      await ref.read(taskOperationsProvider).createTask(task);
      
      // Debug: Log after database operation
      debugPrint('🔍 Task saved to database');

      // Add location trigger if location is set
      if (_selectedLocation != null) {
        try {
          final geofence = GeofenceData(
            id: '${DateTime.now().millisecondsSinceEpoch}_geofence',
            name: 'Task: ${task.title}',
            latitude: _selectedLocation!.latitude,
            longitude: _selectedLocation!.longitude,
            radius: 300.0, // 300 meters as requested
            isActive: true,
            type: GeofenceType.enter,
            createdAt: DateTime.now(),
          );
          
          final locationTaskService = ref.read(locationTaskServiceProvider);
          await locationTaskService.addLocationTriggerToTask(
            taskId: task.id,
            geofence: geofence,
          );
          
          debugPrint('🔍 Location trigger added for task ${task.id}');
        } catch (e) {
          debugPrint('🚨 Error adding location trigger: $e');
          // Don't fail the task creation if location trigger fails
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Task created successfully!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to create task: $e',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onError,
              ),
            ),
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
            IconButton(
              onPressed: _isCreating ? null : _createTask,
              icon: _isCreating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(PhosphorIcons.check()),
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
                  children: [
                    const SizedBox(height: 20),

                    // Title Section
                    _buildTitleSection(context, theme),

                    const SizedBox(height: 20),

                    // Description Section
                    _buildDescriptionSection(context, theme),

                    const SizedBox(height: 20),

                    // Priority Section
                    _buildPrioritySection(context, theme),

                    const SizedBox(height: 20),

                    // Category Section
                    _buildCategorySection(context, theme),

                    const SizedBox(height: 20),

                    // Tags Section  
                    _buildTagsSection(context, theme),

                    const SizedBox(height: 20),

                    // Due Date Section
                    _buildDueDateSection(context, theme),

                    const SizedBox(height: 20),

                    // Reminder Section
                    _buildReminderSection(context, theme),

                    const SizedBox(height: 20),

                    // Recurring Task Section
                    _buildRecurringTaskSection(context, theme),

                    const SizedBox(height: 20),

                    // Location Section
                    LocationTaskSection(
                      initialLocation: _selectedLocation,
                      onLocationChanged: (location) {
                        setState(() {
                          _selectedLocation = location;
                        });
                      },
                    ),

                    const SizedBox(height: 32),

                    // Create Button
                    _buildCreateButton(context, theme),

                    const SizedBox(height: 100), // Bottom padding
                  ],
                ),
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
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.listChecks(),
                size: 24,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              StandardizedTextVariants.sectionHeader('Title'),
            ],
          ),
          const SizedBox(height: 12),
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
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context, ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.textAa(),
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              StandardizedTextVariants.sectionHeader('Description'),
              const SizedBox(width: 8),
              StandardizedText(
                '(Optional)',
                style: StandardizedTextStyle.taskMeta,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: 12),
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
          ),
        ],
      ),
    );
  }

  Widget _buildPrioritySection(BuildContext context, ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.flag(),
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              StandardizedTextVariants.sectionHeader('Priority'),
            ],
          ),
          const SizedBox(height: 12),
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
                              priority == TaskPriority.high
                                  ? PhosphorIcons.caretUp()
                                  : priority == TaskPriority.medium
                                      ? PhosphorIcons.minus()
                                      : PhosphorIcons.caretDown(),
                              color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                            const SizedBox(height: 4),
                            StandardizedText(
                              priority.name.toUpperCase(),
                              style: StandardizedTextStyle.labelMedium,
                              color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDueDateSection(BuildContext context, ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            Icon(
              PhosphorIcons.calendar(),
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            StandardizedTextVariants.sectionHeader('Due Date'),
            const SizedBox(width: 8),
            StandardizedText(
              '(Optional)',
              style: StandardizedTextStyle.taskMeta,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _dueDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => _dueDate = date);
                  }
                },
                icon: Icon(PhosphorIcons.calendar()),
                label: StandardizedText(_dueDate != null ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}' : 'Select Date', style: StandardizedTextStyle.buttonText),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _dueDate == null
                    ? null
                    : () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _dueTime ?? const TimeOfDay(hour: 23, minute: 59),
                        );
                        if (time != null) {
                          setState(() => _dueTime = time);
                        }
                      },
                icon: Icon(PhosphorIcons.clock()),
                label: StandardizedText(_dueTime != null ? _dueTime!.format(context) : 'Set Time', style: StandardizedTextStyle.buttonText),
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
              ),
          ],
        ),
        if (_dueDate != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: StandardizedText(
              'Due: ${_formatDuration(_dueDate!, _dueTime)}',
              style: StandardizedTextStyle.labelMedium,
              color: theme.colorScheme.primary,
            ),
          ),
        ]
      ]),
    );
  }

  Widget _buildReminderSection(BuildContext context, ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            Icon(
              PhosphorIcons.bell(),
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            StandardizedTextVariants.sectionHeader('Reminder'),
            const SizedBox(width: 8),
            StandardizedText(
              '(Optional)',
              style: StandardizedTextStyle.taskMeta,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _reminderDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => _reminderDate = date);
                  }
                },
                icon: Icon(PhosphorIcons.calendar()),
                label: StandardizedText(_reminderDate != null
                    ? '${_reminderDate!.day}/${_reminderDate!.month}/${_reminderDate!.year}'
                    : 'Select Date', style: StandardizedTextStyle.buttonText),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _reminderDate == null
                    ? null
                    : () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _reminderTime ?? const TimeOfDay(hour: 9, minute: 0),
                        );
                        if (time != null) {
                          setState(() => _reminderTime = time);
                        }
                      },
                icon: Icon(PhosphorIcons.clock()),
                label: StandardizedText(_reminderTime != null ? _reminderTime!.format(context) : 'Set Time', style: StandardizedTextStyle.buttonText),
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
              ),
          ],
        ),
        if (_reminderDate != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: StandardizedText(
              'Reminder: ${_formatDuration(_reminderDate!, _reminderTime)}',
              style: StandardizedTextStyle.labelMedium,
              color: theme.colorScheme.secondary,
            ),
          ),
        ]
      ]),
    );
  }

  Widget _buildCreateButton(BuildContext context, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isCreating ? null : _createTask,
        icon: _isCreating
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(PhosphorIcons.plus()),
        label: StandardizedText(_isCreating ? 'Saving...' : 'Save Task', style: StandardizedTextStyle.buttonText),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, ThemeData theme) {
    // Get available categories from CategoryUtils
    final categories = [
      'work', 'personal', 'shopping', 'health', 'fitness', 'finance',
      'education', 'travel', 'home', 'family', 'entertainment', 'food',
    ];

    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.folder(),
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              StandardizedTextVariants.sectionHeader('Category'),
              const SizedBox(width: 8),
              StandardizedText(
                '(Optional)',
                style: StandardizedTextStyle.taskMeta,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCategory,
                hint: Row(
                  children: [
                    Icon(
                      PhosphorIcons.folder(),
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    const StandardizedText('Select Category', style: StandardizedTextStyle.bodyMedium),
                  ],
                ),
                isExpanded: true,
                items: [
                  // Clear selection option
                  DropdownMenuItem<String>(
                    value: null,
                    child: Row(
                      children: [
                        Icon(
                          PhosphorIcons.x(),
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: StandardizedText(
                            'No Category',
                            style: StandardizedTextStyle.bodyMedium,
                            color: theme.colorScheme.onSurfaceVariant,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Category options
                  ...categories.map((category) => DropdownMenuItem<String>(
                    value: category,
                    child: Row(
                      children: [
                        CategoryUtils.buildCategoryIconContainer(
                          category: category,
                          size: 20,
                          theme: theme,
                          iconSizeRatio: 0.7,
                          borderRadius: 4,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StandardizedText(
                            CategoryUtils.getCategoryDisplayName(category), 
                            style: StandardizedTextStyle.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
            ),
          ),
          if (_selectedCategory != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CategoryUtils.getCategoryColor(_selectedCategory!, theme: theme)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: CategoryUtils.getCategoryColor(_selectedCategory!, theme: theme)
                      .withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  CategoryUtils.buildCategoryIconContainer(
                    category: _selectedCategory!,
                    size: 24,
                    theme: theme,
                    iconSizeRatio: 0.6,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StandardizedText(
                      'Selected: ${CategoryUtils.getCategoryDisplayName(_selectedCategory!)}',
                      style: StandardizedTextStyle.labelMedium,
                      color: CategoryUtils.getCategoryColor(_selectedCategory!, theme: theme),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTagsSection(BuildContext context, ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.tag(),
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              StandardizedTextVariants.sectionHeader('Tags'),
              const SizedBox(width: 8),
              StandardizedText(
                '(Optional)',
                style: StandardizedTextStyle.taskMeta,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: 12),
          TagSelectionWidget(
            selectedTags: _selectedTags,
            onTagsChanged: (tags) {
              setState(() {
                _selectedTags = tags;
              });
            },
            maxTags: 5,
            allowCreate: true,
            isCompact: false,
          ),
        ],
      ),
    );
  }

  Widget _buildRecurringTaskSection(BuildContext context, ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            Icon(
              PhosphorIcons.clockCounterClockwise(),
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            StandardizedTextVariants.sectionHeader('Recurring Task'),
            const Spacer(),
            Switch(
              value: _isRecurringTask,
              onChanged: (value) {
                setState(() {
                  _isRecurringTask = value;
                  if (!value) {
                    _recurrencePattern = null;
                  }
                });
              },
            ),
          ],
        ),
        if (_isRecurringTask) ...[
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
      ]),
    );
  }

  /// Build audio metadata in the correct format expected by TaskAudioExtensions
  Map<String, dynamic> _buildAudioMetadata() {
    final audioData = widget.prePopulatedData?['audioData'] as Map<String, dynamic>?;
    
    // Use data from voice recording if available, otherwise create basic metadata
    if (audioData != null) {
      return {
        'filePath': _audioFilePath!,
        'duration': audioData['totalDuration'] ?? 0,
        'format': audioData['format'] ?? 'aac',
        'fileSize': audioData['fileSize'],
        'recordingTimestamp': audioData['recordingTimestamp'] ?? DateTime.now().toIso8601String(),
        // Additional metadata from concatenated recordings
        'isConcatenated': audioData['isConcatenated'] ?? false,
        'originalFileCount': audioData['originalFileCount'] ?? 1,
        'hasMultipleRecordings': audioData['hasMultipleRecordings'] ?? false,
        'recordingCount': audioData['recordingCount'] ?? 1,
      };
    } else {
      // Fallback for cases without detailed audio metadata
      return {
        'filePath': _audioFilePath!,
        'duration': 0,
        'format': 'aac',
        'recordingTimestamp': DateTime.now().toIso8601String(),
        'isConcatenated': false,
        'originalFileCount': 1,
      };
    }
  }
}
