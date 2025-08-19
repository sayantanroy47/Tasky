import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/entities/recurrence_pattern.dart';
import '../../domain/models/enums.dart';
import '../providers/task_provider.dart' show taskOperationsProvider;
import '../providers/project_providers.dart';
import '../../core/theme/typography_constants.dart';
import '../painters/glassmorphism_painter.dart';

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
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  TaskPriority _selectedPriority = TaskPriority.medium;
  String? _selectedProjectId;
  DateTime? _selectedDueDate;
  TimeOfDay? _selectedDueTime;
  RecurrencePattern? _recurrencePattern;
  String? _audioFilePath;
  String? _creationMode;
  List<String> _tags = [];
  String _notes = '';
  bool _isLoading = false;
  
  final _tagsController = TextEditingController();
  final _notesController = TextEditingController();
  
  
  @override
  void initState() {
    super.initState();
    debugPrint('Manual: Building EnhancedTaskCreationDialog');
    _initializeFromData();
  }
  
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
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog.fullscreen(
      backgroundColor: theme.colorScheme.surface.withOpacity(0.95),
      child: LayoutBuilder(
        builder: (context, constraints) => GlassmorphicContainer(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          borderRadius: TypographyConstants.getBorderRadius(radius: TypographyConstants.dialogRadius),
          blur: 10.0,
          opacity: 0.1,
          color: theme.colorScheme.surface,
          child: Scaffold(
            backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(_getDialogTitle()),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
          actions: [
            // Use TextButton instead of FilledButton.icon to avoid infinite width constraints in AppBar
            TextButton.icon(
              onPressed: _isLoading ? null : _saveTask,
              icon: _isLoading 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save, size: 18),
              label: Text(_isLoading ? 'Saving...' : 'Save'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Audio attachment section (if present)
                if (_audioFilePath != null) ...[
                  _buildAudioSection(theme),
                  const SizedBox(height: 16),
                ],
                
                // Creation mode indicator
                if (_creationMode != null) ...[
                  _buildCreationModeIndicator(theme),
                  const SizedBox(height: 16),
                ],
                
                // Title field with validation
                SizedBox(
                  width: double.infinity,
                  child: TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Task Title *',
                      hintText: 'Enter a clear, actionable task title...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.task_alt),
                      helperText: 'Required field',
                    ),
                    autofocus: _titleController.text.isEmpty,
                    textCapitalization: TextCapitalization.sentences,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a task title';
                      }
                      if (value.trim().length < 3) {
                        return 'Title must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                
                // Description field
                SizedBox(
                  width: double.infinity,
                  child: TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Add details, context, or notes about this task...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Priority selector with visual indicators
                _buildEnhancedPrioritySelector(theme),
                const SizedBox(height: 20),
                
                // Project selector
                _buildProjectSelector(theme),
                const SizedBox(height: 20),
                
                // Due date and time picker
                _buildEnhancedDateTimePicker(context, theme),
                const SizedBox(height: 20),
                
                // Tags section
                _buildTagsSection(theme),
                const SizedBox(height: 20),
                
                // Recurring task section
                _buildRecurrenceSection(theme),
                const SizedBox(height: 20),
                
                // Additional notes
                SizedBox(
                  width: double.infinity,
                  child: TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Additional Notes',
                      hintText: 'Any extra information or reminders...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.notes),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (value) => _notes = value,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        // Bottom Save Button Bar
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.95),
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    label: const Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: _isLoading ? null : _saveTask,
                    icon: _isLoading 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save),
                    label: Text(_isLoading ? 'Saving Task...' : 'Save Task'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: TypographyConstants.getStyle(
                        fontSize: TypographyConstants.buttonText,
                        fontWeight: TypographyConstants.semiBold,
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
      {'value': TaskPriority.low, 'label': 'Low', 'icon': Icons.low_priority, 'color': Colors.green},
      {'value': TaskPriority.medium, 'label': 'Medium', 'icon': Icons.remove, 'color': Colors.orange},
      {'value': TaskPriority.high, 'label': 'High', 'icon': Icons.priority_high, 'color': Colors.red},
      {'value': TaskPriority.urgent, 'label': 'Urgent', 'icon': Icons.warning, 'color': Colors.purple},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority Level',
          style: TypographyConstants.getStyle(
            fontSize: TypographyConstants.titleMedium,
            fontWeight: TypographyConstants.semiBold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: DropdownButtonFormField<TaskPriority>(
            value: _selectedPriority,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.flag),
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
                    const SizedBox(width: 12),
                    Text(priority['label'] as String),
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
        Text(
          'Project',
          style: TypographyConstants.getStyle(
            fontSize: TypographyConstants.titleMedium,
            fontWeight: TypographyConstants.semiBold,
            color: theme.colorScheme.onSurface,
          ),
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
                    value: _selectedProjectId,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.folder),
                      hintText: 'Select a project (optional)',
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('No project'),
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
                                  color: project.color.isNotEmpty ? Color(int.tryParse(project.color) ?? 0xFF2196F3) : Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  project.name,
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
              loading: () => const SizedBox(
                width: double.infinity,
                child: LinearProgressIndicator(),
              ),
              error: (error, stack) => const SizedBox(
                width: double.infinity,
                child: Text('Error loading projects'),
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
        Text(
          'Due Date & Time',
          style: TypographyConstants.getStyle(
            fontSize: TypographyConstants.titleMedium,
            fontWeight: TypographyConstants.semiBold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
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
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    _selectedDueDate != null 
                      ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
                      : 'Set Date',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
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
                  icon: const Icon(Icons.access_time),
                  label: Text(
                    _selectedDueTime != null 
                      ? _selectedDueTime!.format(context)
                      : 'Time',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_selectedDueDate != null) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedDueDate = null;
                  _selectedDueTime = null;
                });
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear due date'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildTagsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: TypographyConstants.getStyle(
            fontSize: TypographyConstants.titleMedium,
            fontWeight: TypographyConstants.semiBold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: TextFormField(
            controller: _tagsController,
            decoration: InputDecoration(
              labelText: 'Add tags',
              hintText: 'Enter tags separated by commas (e.g., urgent, work, meeting)',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.local_offer),
              suffixIcon: _tagsController.text.isNotEmpty ? IconButton(
                onPressed: () {
                  final newTags = _tagsController.text
                      .split(',')
                      .map((tag) => tag.trim())
                      .where((tag) => tag.isNotEmpty && !_tags.contains(tag))
                      .toList();
                  
                  setState(() {
                    _tags.addAll(newTags);
                    _tagsController.clear();
                  });
                },
                icon: const Icon(Icons.add),
              ) : null,
            ),
            onFieldSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                final newTags = value
                    .split(',')
                    .map((tag) => tag.trim())
                    .where((tag) => tag.isNotEmpty && !_tags.contains(tag))
                    .toList();
                
                setState(() {
                  _tags.addAll(newTags);
                  _tagsController.clear();
                });
              }
            },
          ),
        ),
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    setState(() {
                      _tags.remove(tag);
                    });
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildRecurrenceSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recurring Task',
          style: TypographyConstants.getStyle(
            fontSize: TypographyConstants.titleMedium,
            fontWeight: TypographyConstants.semiBold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: DropdownButtonFormField<RecurrenceType?>(
            value: _recurrencePattern?.type,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.repeat),
              hintText: 'Select recurrence (optional)',
            ),
            items: [
              const DropdownMenuItem<RecurrenceType?>(
                value: null,
                child: Text('No recurrence'),
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
                      const SizedBox(width: 8),
                      Text(label),
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
          const SizedBox(height: 12),
          Text(
            'Repeats every ${_recurrencePattern!.interval} ${_getRecurrenceLabel(_recurrencePattern!.type)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
  
  IconData _getRecurrenceIcon(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.none:
        return Icons.repeat_one;
      case RecurrenceType.daily:
        return Icons.today;
      case RecurrenceType.weekly:
        return Icons.view_week;
      case RecurrenceType.monthly:
        return Icons.calendar_month;
      case RecurrenceType.yearly:
        return Icons.event_repeat;
      case RecurrenceType.custom:
        return Icons.settings;
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
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '🎵 Audio recording attached',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
  
  Widget _buildCreationModeIndicator(ThemeData theme) {
    final String modeText = _creationMode == 'voiceToText' 
        ? '🎤 Created with AI Voice Entry' 
        : '✏️ Manual Entry';
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        modeText,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.secondary,
        ),
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
      
      // Store tags and notes in metadata
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
            tags: widget.editingTask!.tags,
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
            metadata: metadata.isNotEmpty ? metadata : const {},
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
      
      if (mounted) {
        widget.onTaskCreated?.call(task);
        Navigator.of(context).pop(task);
        
        String successMessage;
        if (_creationMode == 'voiceToText') {
          successMessage = 'AI Voice task created successfully!';
        } else {
          successMessage = widget.editingTask != null ? 'Task updated successfully!' : 'Task created successfully!';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            behavior: SnackBarBehavior.floating,
          ),
        );
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

