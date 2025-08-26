import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/entities/tag.dart';
import '../../domain/entities/recurrence_pattern.dart';
import '../../domain/models/enums.dart';
import '../providers/task_provider.dart' show taskOperationsProvider;
import '../providers/project_providers.dart';
import '../../core/providers/core_providers.dart';
import '../../core/theme/typography_constants.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'glassmorphism_container.dart';
import '../../core/design_system/design_tokens.dart';
import 'standardized_text.dart';
import 'standardized_spacing.dart';
import 'standardized_form_widgets.dart';
import 'standardized_navigation.dart';
import 'tag_selection_widget.dart';
import 'location_task_section.dart';
import '../../services/location/location_models.dart';
import '../providers/location_providers.dart';

/// Category option for task categorization
class CategoryOption {
  final String id;
  final String label;
  final IconData icon;
  
  const CategoryOption(this.id, this.label, this.icon);
}

/// Predefined category options with icons  
final List<CategoryOption> _predefinedCategories = [
  CategoryOption('work', 'Work', PhosphorIcons.briefcase()),
  CategoryOption('personal', 'Personal', PhosphorIcons.user()),
  CategoryOption('shopping', 'Shopping', PhosphorIcons.shoppingCart()),
  CategoryOption('health', 'Health', PhosphorIcons.heartbeat()),
  CategoryOption('finance', 'Finance', PhosphorIcons.currencyDollar()),
  CategoryOption('learning', 'Learning', PhosphorIcons.graduationCap()),
  CategoryOption('family', 'Family', PhosphorIcons.house()),
  CategoryOption('travel', 'Travel', PhosphorIcons.airplane()),
  CategoryOption('fitness', 'Fitness', PhosphorIcons.barbell()),
  CategoryOption('social', 'Social', PhosphorIcons.users()),
  CategoryOption('creative', 'Creative', PhosphorIcons.paintBrush()),
  CategoryOption('urgent', 'Urgent', PhosphorIcons.warning()),
];

/// Enhanced unified task creation dialog - rebuilt with proper constraint handling
class EnhancedTaskCreationDialog extends ConsumerStatefulWidget {
  final TaskModel? editingTask;
  final Map<String, dynamic>? prePopulatedData;
  final Function(TaskModel)? onTaskCreated;
  
  const EnhancedTaskCreationDialog({
    super.key,
    this.editingTask,
    this.prePopulatedData,
    this.onTaskCreated,
  });
  
  @override
  ConsumerState<EnhancedTaskCreationDialog> createState() => _EnhancedTaskCreationDialogState();
}

class _EnhancedTaskCreationDialogState extends ConsumerState<EnhancedTaskCreationDialog> {
  late final GlobalKey<FormState> _formKey;
  
  @override
  void initState() {
    super.initState();
    // Create unique form key to prevent duplicate GlobalKey errors
    _formKey = GlobalKey<FormState>();
    debugPrint('Manual: Building EnhancedTaskCreationDialog');
    _initializeFromData();
  }
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  TaskPriority _selectedPriority = TaskPriority.medium;
  String? _selectedProjectId;
  DateTime? _selectedDueDate;
  TimeOfDay? _selectedDueTime;
  RecurrencePattern? _recurrencePattern;
  String? _audioFilePath;
  String? _creationMode;
  List<Tag> _selectedTags = [];
  List<String> _tags = []; // Keep category-style tags separate
  String _notes = '';
  bool _isLoading = false;
  Set<String> _selectedCategories = {};
  LocationData? _selectedLocation;
  
  final _tagsController = TextEditingController();
  final _notesController = TextEditingController();
  
  
  void _initializeFromData() {
    if (widget.editingTask != null) {
      final task = widget.editingTask!;
      _titleController.text = task.title;
      _descriptionController.text = task.description ?? '';
      _selectedPriority = task.priority;
      _selectedProjectId = task.projectId;
      _selectedDueDate = task.dueDate;
      _recurrencePattern = task.recurrence;
      // Extract tags and notes from metadata if they exist
      if (task.metadata.isNotEmpty) {
        _tags = List<String>.from(task.metadata['tags'] ?? []);
        _notes = task.metadata['notes'] ?? '';
        _notesController.text = _notes;
        // Initialize selected categories from existing tags
        _selectedCategories = _tags.where((tag) => 
          _predefinedCategories.any((cat) => cat.id == tag.toLowerCase())
        ).map((tag) => tag.toLowerCase()).toSet();
      }
      // Load existing tags asynchronously for editing
      if (task.tagIds.isNotEmpty) {
        _loadExistingTags(task.tagIds);
      }
    } else if (widget.prePopulatedData != null) {
      final data = widget.prePopulatedData!;
      
      // Handle title
      _titleController.text = data['title'] ?? '';
      
      // Handle AI Voice Entry mode - description comes from transcription
      if (data['creationMode'] == 'voiceToText' && data['transcribedText'] != null) {
        _descriptionController.text = data['transcribedText'];
      } else {
        _descriptionController.text = data['description'] ?? '';
      }
      
      // Store audio file path and creation mode
      _audioFilePath = data['audioFilePath'];
      _creationMode = data['creationMode'];
      
      // Handle priority
      if (data['priority'] != null) {
        _selectedPriority = TaskPriority.values.firstWhere(
          (p) => p.name.toLowerCase() == data['priority'].toString().toLowerCase(),
          orElse: () => TaskPriority.medium,
        );
      }
      
      // Handle due date
      if (data['dueDate'] != null && data['dueDate'] is DateTime) {
        _selectedDueDate = data['dueDate'];
      }
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Load existing tags when editing a task
  Future<void> _loadExistingTags(List<String> tagIds) async {
    if (!mounted) return;
    
    try {
      final tagRepository = ref.read(tagRepositoryProvider);
      final List<Tag> existingTags = [];
      
      for (final tagId in tagIds) {
        final tag = await tagRepository.getTagById(tagId);
        if (tag != null) {
          existingTags.add(tag);
        }
      }
      
      if (mounted) {
        setState(() {
          _selectedTags = existingTags;
        });
      }
    } catch (e) {
      // Handle error silently - tags will just remain empty
      print('Error loading existing tags: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  widget.editingTask != null ? PhosphorIcons.pencil() : PhosphorIcons.plus(),
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getDialogTitle(),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        widget.editingTask != null ? 'Update task details' : 'Add a new task to your list',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Form
            Flexible(child: _buildTaskForm(context)),
            const SizedBox(height: 24),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveTask,
                  child: _isLoading 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.editingTask != null ? 'Update Task' : 'Save Task'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Audio attachment section (if present)
            if (_audioFilePath != null) ...[
              _buildAudioSection(Theme.of(context)),
              StandardizedGaps.md,
            ],
            
            // Creation mode indicator
            if (_creationMode != null) ...[
              _buildCreationModeIndicator(Theme.of(context)),
              StandardizedGaps.md,
            ],
            
            // Title field with validation
            StandardizedFormField(
              label: 'Task Title',
              hint: 'Enter a clear, actionable task title...',
              helperText: 'Required field',
              controller: _titleController,
              isRequired: true,
              autofocus: _titleController.text.isEmpty,
              textCapitalization: TextCapitalization.sentences,
              prefixIcon: Icon(PhosphorIcons.checkSquare()),
            ),
            StandardizedGaps.vertical(SpacingSize.phi2),
            
            // Description field
            StandardizedFormField(
              label: 'Description',
              hint: 'Add details, context, or notes about this task...',
              controller: _descriptionController,
              isMultiline: true,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              prefixIcon: Icon(PhosphorIcons.fileText()),
            ),
            StandardizedGaps.vertical(SpacingSize.phi2),
            
            // Priority selector with visual indicators
            _buildEnhancedPrioritySelector(Theme.of(context)),
            StandardizedGaps.vertical(SpacingSize.phi2),
            
            // Project selector
            _buildProjectSelector(Theme.of(context)),
            StandardizedGaps.vertical(SpacingSize.phi2),
            
            // Due date and time picker
            _buildEnhancedDateTimePicker(context, Theme.of(context)),
            StandardizedGaps.vertical(SpacingSize.phi2),
            
            // Categories section (predefined options)
            _buildCategoriesSection(Theme.of(context)),
            StandardizedGaps.vertical(SpacingSize.phi2),
            
            // Tags section (user-created tags with colors)
            TagSelectionWidget(
              selectedTags: _selectedTags,
              onTagsChanged: (tags) => setState(() => _selectedTags = tags),
              maxTags: 5,
              allowCreate: true,
            ),
            StandardizedGaps.vertical(SpacingSize.phi2),
            
            // Recurring task section
            _buildRecurrenceSection(Theme.of(context)),
            StandardizedGaps.vertical(SpacingSize.phi2),
            
            // Location section
            LocationTaskSection(
              initialLocation: _selectedLocation,
              onLocationChanged: (location) {
                setState(() {
                  _selectedLocation = location;
                });
              },
            ),
            StandardizedGaps.vertical(SpacingSize.phi2),
            
            // Additional notes
            StandardizedFormField(
              label: 'Additional Notes',
              hint: 'Any extra information or reminders...',
              controller: _notesController,
              isMultiline: true,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              prefixIcon: Icon(PhosphorIcons.note()),
              onChanged: (value) => _notes = value,
            ),
            StandardizedGaps.xl,
          ],
        ),
      ),
    );
  }
  
  String _getDialogTitle() {
    if (widget.editingTask != null) {
      return 'Edit Task';
    }
    if (_creationMode == 'voiceToText') {
      return 'AI Voice Task';
    }
    return 'Create New Task';
  }
  
  Widget _buildEnhancedPrioritySelector(ThemeData theme) {
    final priorities = [
      {'value': TaskPriority.low, 'label': 'Low', 'icon': PhosphorIcons.arrowDown(), 'color': theme.colorScheme.primary},
      {'value': TaskPriority.medium, 'label': 'Medium', 'icon': PhosphorIcons.minus(), 'color': theme.colorScheme.secondary},
      {'value': TaskPriority.high, 'label': 'High', 'icon': PhosphorIcons.arrowUp(), 'color': theme.colorScheme.tertiary},
      {'value': TaskPriority.urgent, 'label': 'Urgent', 'icon': PhosphorIcons.warning(), 'color': theme.colorScheme.error},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StandardizedText(
          'Priority Level',
          style: StandardizedTextStyle.titleMedium,
        ),
        StandardizedGaps.vertical(SpacingSize.sm),
        SizedBox(
          width: double.infinity,
          child: DropdownButtonFormField<TaskPriority>(
            initialValue: _selectedPriority,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              prefixIcon: Icon(PhosphorIcons.flag()),
            ),
            items: priorities.map((priority) {
              return DropdownMenuItem<TaskPriority>(
                value: priority['value'] as TaskPriority,
                child: Row(
                  children: [
                    Icon(
                      priority['icon'] as IconData,
                      size: 20,
                      color: priority['color'] as Color,
                    ),
                    StandardizedGaps.horizontal(SpacingSize.sm),
                    StandardizedText(
                      priority['label'] as String,
                      style: StandardizedTextStyle.bodyMedium,
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedPriority = value;
                });
              }
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildProjectSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StandardizedText(
          'Project',
          style: StandardizedTextStyle.titleMedium,
        ),
        const SizedBox(height: 8),
        Consumer(
          builder: (context, ref, child) {
            final projects = ref.watch(projectsProvider);
            return projects.when(
              data: (projectList) {
                return SizedBox(
                  width: double.infinity,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedProjectId,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      prefixIcon: Icon(PhosphorIcons.folder()),
                      hintText: 'Select a project (optional)',
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: StandardizedText(
                          'No project',
                          style: StandardizedTextStyle.bodyMedium,
                        ),
                      ),
                      ...projectList.map((project) {
                        return DropdownMenuItem<String>(
                          value: project.id,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: project.color.isNotEmpty ? Color(int.tryParse(project.color) ?? 0xFF2196F3) : const Color(0xFF2196F3), // Fixed hardcoded Colors.blue
                                  shape: BoxShape.circle,
                                ),
                              ),
                              StandardizedGaps.horizontal(SpacingSize.sm),
                              Expanded(
                                child: StandardizedText(
                                  project.name,
                                  style: StandardizedTextStyle.bodyMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedProjectId = value;
                      });
                    },
                  ),
                );
              },
              loading: () => SizedBox(
                width: double.infinity,
                height: 56,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusXSmall), // 2.0 - Fixed border radius hierarchy (was 4px)
                  ),
                  child: Row(
                    children: [
                      Icon(PhosphorIcons.folder(), color: theme.colorScheme.onSurfaceVariant),
                      StandardizedGaps.horizontal(SpacingSize.sm),
                      StandardizedText(
                        'Loading projects...',
                        style: StandardizedTextStyle.bodyMedium,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const Spacer(),
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ],
                  ),
                ),
              ),
              error: (error, stack) => SizedBox(
                width: double.infinity,
                height: 56,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.error),
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusXSmall), // 2.0 - Fixed border radius hierarchy (was 4px)
                  ),
                  child: Row(
                    children: [
                      Icon(PhosphorIcons.warningCircle(), color: theme.colorScheme.error),
                      StandardizedGaps.horizontal(SpacingSize.sm),
                      Expanded(
                        child: StandardizedText(
                          'Error loading projects',
                          style: StandardizedTextStyle.bodyMedium,
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildEnhancedDateTimePicker(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StandardizedText(
          'Due Date & Time',
          style: StandardizedTextStyle.titleMedium,
        ),
        StandardizedGaps.vertical(SpacingSize.sm),
        SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              // Date picker
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDueDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedDueDate = date;
                      });
                    }
                  },
                  icon: Icon(PhosphorIcons.calendar()),
                  label: StandardizedText(
                    _selectedDueDate != null 
                      ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
                      : 'Set Date',
                    style: StandardizedTextStyle.buttonText,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              StandardizedGaps.horizontal(SpacingSize.sm),
              // Time picker
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectedDueDate != null ? () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _selectedDueTime ?? TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() {
                        _selectedDueTime = time;
                      });
                    }
                  } : null,
                  icon: Icon(PhosphorIcons.clock()),
                  label: StandardizedText(
                    _selectedDueTime != null 
                      ? _selectedDueTime!.format(context)
                      : 'Time',
                    style: StandardizedTextStyle.buttonText,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_selectedDueDate != null) ...[
          StandardizedGaps.vertical(SpacingSize.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedDueDate = null;
                  _selectedDueTime = null;
                });
              },
              icon: Icon(PhosphorIcons.x()),
              label: const StandardizedText(
                'Clear due date',
                style: StandardizedTextStyle.buttonText,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ],
    );
  }
  



  
  Widget _buildCategoriesSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const StandardizedText(
              'Quick Categories',
              style: StandardizedTextStyle.titleMedium,
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _showAddCustomTagDialog,
              icon: Icon(PhosphorIcons.plus(), size: 16),
              label: const StandardizedText(
                'Custom',
                style: StandardizedTextStyle.labelMedium,
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        StandardizedGaps.vertical(SpacingSize.sm),
        // Predefined categories
        Wrap(
          spacing: SpacingTokens.sm,
          runSpacing: SpacingTokens.sm,
          children: _predefinedCategories.map((category) {
            return _buildCategoryChip(category, theme);
          }).toList(),
        ),
        // Custom tags (non-predefined categories)
        if (_tags.where((tag) => !_predefinedCategories.any((cat) => cat.id == tag.toLowerCase())).isNotEmpty) ...[
          StandardizedGaps.md,
          StandardizedText(
            'Custom Quick Tags',
            style: StandardizedTextStyle.titleSmall,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          StandardizedGaps.vertical(SpacingSize.sm),
          Wrap(
            spacing: SpacingTokens.sm,
            runSpacing: SpacingTokens.xs,
            children: _tags
                .where((tag) => !_predefinedCategories.any((cat) => cat.id == tag.toLowerCase()))
                .map((tag) {
              return Chip(
                label: StandardizedText(
                  tag,
                  style: StandardizedTextStyle.labelMedium,
                ),
                deleteIcon: Icon(PhosphorIcons.x(), size: 16),
                onDeleted: () {
                  setState(() {
                    _tags.remove(tag);
                  });
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildCategoryChip(CategoryOption category, ThemeData theme) {
    final isSelected = _selectedCategories.contains(category.id);
    return FilterChip(
      selected: isSelected,
      onSelected: (selected) => _toggleCategory(category.id),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            category.icon,
            size: 16,
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.primary,
          ),
          StandardizedGaps.horizontal(SpacingSize.xs),
          StandardizedText(
            category.label,
            style: StandardizedTextStyle.labelMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      selectedColor: theme.colorScheme.primary,
      checkmarkColor: theme.colorScheme.onPrimary,
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSurface,
      ),
    );
  }

  void _toggleCategory(String categoryId) {
    setState(() {
      if (_selectedCategories.contains(categoryId)) {
        _selectedCategories.remove(categoryId);
        _tags.remove(categoryId);
      } else {
        _selectedCategories.add(categoryId);
        if (!_tags.contains(categoryId)) {
          _tags.add(categoryId);
        }
      }
    });
  }

  Future<void> _showAddCustomTagDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassmorphismContainer(
          level: GlassLevel.floating,
          borderRadius: BorderRadius.circular(TypographyConstants.dialogRadius),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StandardizedText(
                'Add Custom Category',
                style: StandardizedTextStyle.headlineSmall,
              ),
              StandardizedGaps.md,
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Category name',
                  hintText: 'Enter custom category name',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
                textCapitalization: TextCapitalization.words,
              ),
              StandardizedGaps.vertical(SpacingSize.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const StandardizedText(
                      'Cancel',
                      style: StandardizedTextStyle.buttonText,
                    ),
                  ),
                  StandardizedGaps.horizontal(SpacingSize.sm),
                  FilledButton(
                    onPressed: () {
                      if (controller.text.trim().isNotEmpty) {
                        Navigator.of(context).pop(controller.text.trim().toLowerCase());
                      }
                    },
                    child: const StandardizedText(
                      'Add',
                      style: StandardizedTextStyle.buttonText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    
    if (result != null && result.isNotEmpty && !_tags.contains(result)) {
      setState(() {
        _tags.add(result);
      });
    }
    controller.dispose();
  }

  Widget _buildRecurrenceSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StandardizedText(
          'Recurring Task',
          style: StandardizedTextStyle.titleMedium,
        ),
        StandardizedGaps.vertical(SpacingSize.sm),
        SizedBox(
          width: double.infinity,
          child: DropdownButtonFormField<RecurrenceType?>(
            initialValue: _recurrencePattern?.type,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              prefixIcon: Icon(PhosphorIcons.repeat()),
              hintText: 'Select recurrence (optional)',
            ),
            items: [
              const DropdownMenuItem<RecurrenceType?>(
                value: null,
                child: StandardizedText(
                  'No recurrence',
                  style: StandardizedTextStyle.bodyMedium,
                ),
              ),
              ...RecurrenceType.values.where((type) => type != RecurrenceType.none).map((type) {
                String label = '';
                switch (type) {
                  case RecurrenceType.none:
                    label = 'None';
                    break;
                  case RecurrenceType.daily:
                    label = 'Daily';
                    break;
                  case RecurrenceType.weekly:
                    label = 'Weekly';
                    break;
                  case RecurrenceType.monthly:
                    label = 'Monthly';
                    break;
                  case RecurrenceType.yearly:
                    label = 'Yearly';
                    break;
                  case RecurrenceType.custom:
                    label = 'Custom';
                    break;
                }
                return DropdownMenuItem<RecurrenceType?>(
                  value: type,
                  child: Row(
                    children: [
                      Icon(
                        _getRecurrenceIcon(type),
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      StandardizedGaps.horizontal(SpacingSize.sm),
                      StandardizedText(
                        label,
                        style: StandardizedTextStyle.bodyMedium,
                      ),
                    ],
                  ),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                if (value == null) {
                  _recurrencePattern = null;
                } else {
                  _recurrencePattern = RecurrencePattern(
                    type: value,
                    interval: 1,
                    endDate: null,
                  );
                }
              });
            },
          ),
        ),
        if (_recurrencePattern != null) ...[
          StandardizedGaps.vertical(SpacingSize.sm),
          StandardizedText(
            'Repeats every ${_recurrencePattern!.interval} ${_getRecurrenceLabel(_recurrencePattern!.type)}',
            style: StandardizedTextStyle.bodySmall,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ],
    );
  }
  
  IconData _getRecurrenceIcon(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.none:
        return PhosphorIcons.repeat();
      case RecurrenceType.daily:
        return PhosphorIcons.calendar();
      case RecurrenceType.weekly:
        return PhosphorIcons.calendar();
      case RecurrenceType.monthly:
        return PhosphorIcons.calendar();
      case RecurrenceType.yearly:
        return PhosphorIcons.repeat();
      case RecurrenceType.custom:
        return PhosphorIcons.gear();
    }
  }
  
  String _getRecurrenceLabel(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.none:
        return '';
      case RecurrenceType.daily:
        return 'day(s)';
      case RecurrenceType.weekly:
        return 'week(s)';
      case RecurrenceType.monthly:
        return 'month(s)';
      case RecurrenceType.yearly:
        return 'year(s)';
      case RecurrenceType.custom:
        return 'custom interval(s)';
    }
  }
  
  Widget _buildAudioSection(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard), // 8.0 - Fixed border radius hierarchy
      ),
      child: Row(
        children: [
          Icon(
            PhosphorIcons.microphone(),
            size: 20,
            color: theme.colorScheme.primary,
          ),
          StandardizedGaps.horizontal(SpacingSize.sm),
          StandardizedText(
            'Audio recording attached',
            style: StandardizedTextStyle.bodyMedium,
            color: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
  
  Widget _buildCreationModeIndicator(ThemeData theme) {
    final IconData modeIcon = _creationMode == 'voiceToText' 
        ? PhosphorIcons.microphone() 
        : PhosphorIcons.pencil();
    final String modeText = _creationMode == 'voiceToText' 
        ? 'Created with AI Voice Entry' 
        : 'Manual Entry';
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard), // 8.0 - Fixed border radius hierarchy
      ),
      child: Row(
        children: [
          Icon(
            modeIcon,
            size: 16,
            color: theme.colorScheme.secondary,
          ),
          StandardizedGaps.horizontal(SpacingSize.sm),
          StandardizedText(
            modeText,
            style: StandardizedTextStyle.bodySmall,
            color: theme.colorScheme.secondary,
          ),
        ],
      ),
    );
  }
  
  
  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final metadata = <String, dynamic>{};
      
      // Store creation mode
      if (_creationMode != null) {
        metadata['creationMode'] = _creationMode;
      }
      
      // Store audio data if present
      if (_audioFilePath != null) {
        metadata['hasAudio'] = true;
        
        final audioMetadata = <String, dynamic>{
          'filePath': _audioFilePath,
          'format': 'aac', // AudioRecordingService creates AAC files
          'recordingTimestamp': DateTime.now().toIso8601String(),
        };
        
        // Include additional audio metadata from pre-populated data
        if (widget.prePopulatedData != null && widget.prePopulatedData!['audioData'] != null) {
          final prePopulatedAudio = widget.prePopulatedData!['audioData'] as Map<String, dynamic>;
          
          if (prePopulatedAudio['duration'] != null) {
            audioMetadata['duration'] = prePopulatedAudio['duration'];
          }
          
          if (prePopulatedAudio['fileSize'] != null) {
            audioMetadata['fileSize'] = prePopulatedAudio['fileSize'];
          }
          
          if (prePopulatedAudio['format'] != null) {
            audioMetadata['format'] = prePopulatedAudio['format'];
          }
          
          if (prePopulatedAudio['timestamp'] != null) {
            audioMetadata['recordingTimestamp'] = prePopulatedAudio['timestamp'];
          }
        }
        
        metadata['audio'] = audioMetadata;
      }
      
      // Store voice/transcription metadata if present
      if (_creationMode == 'voiceToText' && widget.prePopulatedData?['transcribedText'] != null) {
        metadata['hasTranscription'] = true;
        metadata['isVoiceCreated'] = true;
        metadata['voice'] = {
          'transcription': widget.prePopulatedData!['transcribedText'],
          'originalText': widget.prePopulatedData!['transcribedText'],
        };
      }
      
      // Store category tags and notes in metadata, real tags in tagIds
      if (_tags.isNotEmpty) {
        metadata['tags'] = _tags;
      }
      if (_notes.trim().isNotEmpty) {
        metadata['notes'] = _notes.trim();
      }
      
      // Combine date and time if both are set
      DateTime? finalDueDate;
      if (_selectedDueDate != null) {
        if (_selectedDueTime != null) {
          finalDueDate = DateTime(
            _selectedDueDate!.year,
            _selectedDueDate!.month,
            _selectedDueDate!.day,
            _selectedDueTime!.hour,
            _selectedDueTime!.minute,
          );
        } else {
          finalDueDate = _selectedDueDate;
        }
      }


      final task = widget.editingTask != null
        ? TaskModel(
            id: widget.editingTask!.id,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
            priority: _selectedPriority,
            projectId: _selectedProjectId,
            dueDate: finalDueDate,
            recurrence: _recurrencePattern,
            metadata: metadata.isNotEmpty ? metadata : const {},
            createdAt: widget.editingTask!.createdAt,
            updatedAt: DateTime.now(),
            status: widget.editingTask!.status,
            tagIds: widget.editingTask!.tagIds,
            subTasks: widget.editingTask!.subTasks,
            locationTrigger: widget.editingTask!.locationTrigger,
            dependencies: widget.editingTask!.dependencies,
            isPinned: widget.editingTask!.isPinned,
            estimatedDuration: widget.editingTask!.estimatedDuration,
            actualDuration: widget.editingTask!.actualDuration,
            completedAt: widget.editingTask!.completedAt,
          )
        : TaskModel.create(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
            priority: _selectedPriority,
            projectId: _selectedProjectId,
            dueDate: finalDueDate,
            recurrence: _recurrencePattern,
            tagIds: _selectedTags.map((tag) => tag.id).toList(), // Use real tag IDs
            metadata: {
              ...metadata,
              // Location metadata
              if (_selectedLocation != null) 'hasLocation': true,
              if (_selectedLocation != null) 'locationData': _selectedLocation!.toJson(),
            },
          );
      
      if (widget.editingTask != null) {
        final result = await ref.read(taskOperationsProvider).updateTask(task, context: context);
        if (!result.isSuccess) {
          throw Exception(result.error ?? 'Failed to update task');
        }
      } else {
        final result = await ref.read(taskOperationsProvider).createTask(task, context: context);
        if (!result.isSuccess) {
          throw Exception(result.error ?? 'Failed to create task');
        }
      }
      
      // Add location trigger if location is set (for both create and update)
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
        widget.onTaskCreated?.call(task);
        context.popRoute(task);
        
        String successMessage;
        if (_creationMode == 'voiceToText') {
          successMessage = 'AI Voice task created successfully!';
        } else {
          successMessage = widget.editingTask != null ? 'Task updated successfully!' : 'Task created successfully!';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: StandardizedText(successMessage, style: StandardizedTextStyle.bodyMedium),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: StandardizedText('Error saving task: ${e.toString()}', style: StandardizedTextStyle.bodyMedium),
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



