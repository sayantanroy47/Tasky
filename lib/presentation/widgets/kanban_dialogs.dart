import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../domain/models/enums.dart';
import '../../core/theme/typography_constants.dart';
import '../../core/design_system/design_tokens.dart';
import '../../presentation/providers/task_providers.dart';
import '../../presentation/providers/kanban_providers.dart';
import 'glassmorphism_container.dart';
import 'kanban_board_view.dart';
import 'standardized_text.dart';
import 'standardized_colors.dart';

/// Dialog for filtering tasks in Kanban board
class KanbanFilterDialog extends ConsumerStatefulWidget {
  final TaskPriority? currentPriority;
  final List<String> currentTags;
  final Function(TaskPriority?, List<String>) onFiltersChanged;

  const KanbanFilterDialog({
    super.key,
    this.currentPriority,
    required this.currentTags,
    required this.onFiltersChanged,
  });

  @override
  ConsumerState<KanbanFilterDialog> createState() => _KanbanFilterDialogState();
}

class _KanbanFilterDialogState extends ConsumerState<KanbanFilterDialog> {
  TaskPriority? _selectedPriority;
  List<String> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    _selectedPriority = widget.currentPriority;
    _selectedTags = List.from(widget.currentTags);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final availableTagsAsync = ref.watch(availableSearchTagsProvider);

    return AlertDialog(
      title: Row(
        children: [
          Icon(PhosphorIcons.funnel(), color: theme.colorScheme.primary),
          const SizedBox(width: SpacingTokens.sm),
          const StandardizedText('Filter Tasks', style: StandardizedTextStyle.titleMedium),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Priority filter
            const StandardizedText(
              'Priority',
              style: StandardizedTextStyle.titleSmall,
            ),
            const SizedBox(height: SpacingTokens.sm),
            
            Wrap(
              spacing: SpacingTokens.sm,
              children: [
                // Clear priority chip
                FilterChip(
                  label: const StandardizedText('Any', style: StandardizedTextStyle.bodyMedium),
                  selected: _selectedPriority == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedPriority = selected ? null : _selectedPriority;
                    });
                  },
                ),
                
                // Priority chips
                ...TaskPriority.values.map((priority) => FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getPriorityIcon(priority),
                        size: 16,
                        color: priority.color,
                      ),
                      const SizedBox(width: 4),
                      StandardizedText(priority.displayName, style: StandardizedTextStyle.bodyMedium),
                    ],
                  ),
                  selected: _selectedPriority == priority,
                  onSelected: (selected) {
                    setState(() {
                      _selectedPriority = selected ? priority : null;
                    });
                  },
                )),
              ],
            ),
            
            const SizedBox(height: SpacingTokens.lg),
            
            // Tags filter
            const StandardizedText(
              'Tags',
              style: StandardizedTextStyle.titleSmall,
            ),
            const SizedBox(height: SpacingTokens.sm),
            
            availableTagsAsync.when(
              data: (availableTags) {
                if (availableTags.isEmpty) {
                  return StandardizedText(
                    'No tags available',
                    style: StandardizedTextStyle.bodyMedium,
                    color: theme.colorScheme.onSurfaceVariant,
                  );
                }
                
                return Wrap(
                  spacing: SpacingTokens.sm,
                  runSpacing: SpacingTokens.xs,
                  children: availableTags.map((tag) => FilterChip(
                    label: StandardizedText(tag, style: StandardizedTextStyle.bodyMedium),
                    selected: _selectedTags.contains(tag),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      });
                    },
                  )).toList(),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, _) => StandardizedText('Error loading tags: $error', style: StandardizedTextStyle.bodyMedium, color: context.errorColor),
            ),
            
            if (_selectedTags.isNotEmpty) ...[
              const SizedBox(height: SpacingTokens.sm),
              Row(
                children: [
                  StandardizedText(
                    '${_selectedTags.length} tag${_selectedTags.length != 1 ? 's' : ''} selected',
                    style: StandardizedTextStyle.bodySmall,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedTags.clear();
                      });
                    },
                    child: const StandardizedText('Clear all', style: StandardizedTextStyle.buttonText),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const StandardizedText('Cancel', style: StandardizedTextStyle.buttonText),
        ),
        TextButton(
          onPressed: _clearFilters,
          child: const StandardizedText('Clear', style: StandardizedTextStyle.buttonText),
        ),
        FilledButton(
          onPressed: () {
            widget.onFiltersChanged(_selectedPriority, _selectedTags);
            Navigator.of(context).pop();
          },
          child: const StandardizedText('Apply', style: StandardizedTextStyle.buttonText),
        ),
      ],
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedPriority = null;
      _selectedTags.clear();
    });
  }

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return PhosphorIcons.caretDown();
      case TaskPriority.medium:
        return PhosphorIcons.minus();
      case TaskPriority.high:
        return PhosphorIcons.caretUp();
      case TaskPriority.urgent:
        return PhosphorIcons.arrowUp();
    }
  }
}

/// Dialog for configuring Kanban board view options
class KanbanViewOptionsSheet extends ConsumerStatefulWidget {
  final List<KanbanColumnConfig> columns;
  final Function(List<KanbanColumnConfig>) onColumnsChanged;

  const KanbanViewOptionsSheet({
    super.key,
    required this.columns,
    required this.onColumnsChanged,
  });

  @override
  ConsumerState<KanbanViewOptionsSheet> createState() => _KanbanViewOptionsSheetState();
}

class _KanbanViewOptionsSheetState extends ConsumerState<KanbanViewOptionsSheet> {
  late List<KanbanColumnConfig> _workingColumns;
  
  @override
  void initState() {
    super.initState();
    _workingColumns = List.from(widget.columns);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = ref.watch(kanbanConfigProvider);
    final configNotifier = ref.read(kanbanConfigProvider.notifier);
    final presets = ref.watch(columnPresetsProvider);

    return GlassmorphismContainer(
      level: GlassLevel.floating,
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Icon(PhosphorIcons.gear(), color: theme.colorScheme.primary),
              const SizedBox(width: SpacingTokens.sm),
              const StandardizedText(
                'View Options',
                style: StandardizedTextStyle.headlineSmall,
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(PhosphorIcons.x()),
              ),
            ],
          ),

          const SizedBox(height: SpacingTokens.lg),

          // View settings
          _buildSettingsSection(
            'Display Options',
            [
              SwitchListTile(
                title: const StandardizedText('Show task counts', style: StandardizedTextStyle.bodyMedium),
                subtitle: const StandardizedText('Display number of tasks in each column header', style: StandardizedTextStyle.bodySmall),
                value: config.showTaskCounts,
                onChanged: (_) => configNotifier.toggleTaskCounts(),
              ),
              SwitchListTile(
                title: const StandardizedText('Enable drag & drop', style: StandardizedTextStyle.bodyMedium),
                subtitle: const StandardizedText('Allow moving tasks between columns', style: StandardizedTextStyle.bodySmall),
                value: config.enableDragAndDrop,
                onChanged: (_) => configNotifier.toggleDragAndDrop(),
              ),
              SwitchListTile(
                title: const StandardizedText('Batch operations', style: StandardizedTextStyle.bodyMedium),
                subtitle: const StandardizedText('Enable selecting multiple tasks', style: StandardizedTextStyle.bodySmall),
                value: config.enableBatchOperations,
                onChanged: (_) => configNotifier.toggleBatchOperations(),
              ),
            ],
          ),

          const SizedBox(height: SpacingTokens.lg),

          // Column configuration
          _buildSettingsSection(
            'Column Configuration',
            [
              // Column presets
              const StandardizedText(
                'Quick Presets',
                style: StandardizedTextStyle.titleSmall,
              ),
              const SizedBox(height: SpacingTokens.sm),
              
              Wrap(
                spacing: SpacingTokens.sm,
                children: presets.entries.map((entry) => ActionChip(
                  label: StandardizedText(_getPresetDisplayName(entry.key), style: StandardizedTextStyle.bodyMedium),
                  onPressed: () => _applyPreset(entry.value),
                )).toList(),
              ),

              const SizedBox(height: SpacingTokens.md),

              // Column list
              StandardizedText(
                'Columns (${_workingColumns.length})',
                style: StandardizedTextStyle.titleSmall,
              ),
              const SizedBox(height: SpacingTokens.sm),
              
              ..._workingColumns.asMap().entries.map((entry) {
                final index = entry.key;
                final column = entry.value;
                
                return _buildColumnTile(column, index, theme);
              }),
            ],
          ),

          const SizedBox(height: SpacingTokens.lg),

          // Action buttons
          Row(
            children: [
              TextButton(
                onPressed: _resetToDefaults,
                child: const StandardizedText('Reset to Default', style: StandardizedTextStyle.buttonText),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const StandardizedText('Cancel', style: StandardizedTextStyle.buttonText),
              ),
              const SizedBox(width: SpacingTokens.sm),
              FilledButton(
                onPressed: _applyChanges,
                child: const StandardizedText('Apply', style: StandardizedTextStyle.buttonText),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StandardizedText(
          title,
          style: StandardizedTextStyle.titleMedium,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: SpacingTokens.md),
        ...children,
      ],
    );
  }

  Widget _buildColumnTile(KanbanColumnConfig column, int index, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: SpacingTokens.sm),
      child: ListTile(
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: column.color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
          ),
          child: Icon(
            column.icon,
            size: 18,
            color: column.color,
          ),
        ),
        title: StandardizedText(column.title, style: StandardizedTextStyle.bodyMedium),
        subtitle: StandardizedText(column.status.displayName, style: StandardizedTextStyle.bodySmall),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Visibility toggle
            IconButton(
              onPressed: () => _toggleColumnVisibility(index),
              icon: Icon(
                column.isVisible ? PhosphorIcons.eye() : PhosphorIcons.eyeSlash(),
                color: column.isVisible ? null : theme.colorScheme.onSurfaceVariant,
              ),
              tooltip: column.isVisible ? 'Hide column' : 'Show column',
            ),
            
            // Reorder handles
            ReorderableDragStartListener(
              index: index,
              child: Icon(
                PhosphorIcons.dotsSixVertical(),
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPresetDisplayName(String presetKey) {
    switch (presetKey) {
      case 'agile':
        return 'Agile';
      case 'simple':
        return 'Simple';
      case 'personal':
        return 'Personal';
      default:
        return presetKey.toUpperCase();
    }
  }

  void _applyPreset(List<KanbanColumnConfig> preset) {
    setState(() {
      _workingColumns = List.from(preset);
    });
  }

  void _toggleColumnVisibility(int index) {
    setState(() {
      _workingColumns[index] = _workingColumns[index].copyWith(
        isVisible: !_workingColumns[index].isVisible,
      );
    });
  }

  void _resetToDefaults() {
    setState(() {
      _workingColumns = List.from(defaultKanbanColumns);
    });
    
    ref.read(kanbanConfigProvider.notifier).resetToDefaults();
  }

  void _applyChanges() {
    widget.onColumnsChanged(_workingColumns);
    ref.read(kanbanConfigProvider.notifier).updateColumns(_workingColumns);
    Navigator.of(context).pop();
  }
}

/// Dialog for creating new tasks
class TaskCreationDialog extends ConsumerStatefulWidget {
  final TaskStatus initialStatus;
  final String? projectId;

  const TaskCreationDialog({
    super.key,
    required this.initialStatus,
    this.projectId,
  });

  @override
  ConsumerState<TaskCreationDialog> createState() => _TaskCreationDialogState();
}

class _TaskCreationDialogState extends ConsumerState<TaskCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;
  final List<String> _selectedTags = [];
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
    final availableTagsAsync = ref.watch(availableSearchTagsProvider);

    return AlertDialog(
      title: Row(
        children: [
          Icon(PhosphorIcons.plus(), color: theme.colorScheme.primary),
          const SizedBox(width: SpacingTokens.sm),
          StandardizedText('Create Task - ${widget.initialStatus.displayName}', style: StandardizedTextStyle.titleMedium),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  hintText: 'Enter task title...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                autofocus: true,
              ),

              const SizedBox(height: SpacingTokens.md),

              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Enter task description...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: SpacingTokens.md),

              // Priority selection
              Row(
                children: [
                  const StandardizedText(
                    'Priority:',
                    style: StandardizedTextStyle.titleSmall,
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  Expanded(
                    child: Wrap(
                      spacing: SpacingTokens.xs,
                      children: TaskPriority.values.map((priority) => ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getPriorityIcon(priority),
                              size: 16,
                              color: priority.color,
                            ),
                            const SizedBox(width: 4),
                            StandardizedText(priority.displayName, style: StandardizedTextStyle.bodyMedium),
                          ],
                        ),
                        selected: _priority == priority,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _priority = priority;
                            });
                          }
                        },
                      )).toList(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: SpacingTokens.md),

              // Due date selection
              Row(
                children: [
                  const StandardizedText(
                    'Due Date:',
                    style: StandardizedTextStyle.titleSmall,
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  Expanded(
                    child: Row(
                      children: [
                        if (_dueDate != null) ...[
                          StandardizedText(
                            '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                            style: StandardizedTextStyle.bodyMedium,
                          ),
                          const SizedBox(width: SpacingTokens.sm),
                          IconButton(
                            onPressed: () => setState(() => _dueDate = null),
                            icon: Icon(PhosphorIcons.x(), size: 16),
                            tooltip: 'Clear date',
                          ),
                        ] else
                          StandardizedText(
                            'No due date',
                            style: StandardizedTextStyle.bodyMedium,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        const Spacer(),
                        FilledButton.tonal(
                          onPressed: _selectDueDate,
                          child: const StandardizedText('Set Date', style: StandardizedTextStyle.buttonText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: SpacingTokens.md),

              // Tags selection
              availableTagsAsync.when(
                data: (availableTags) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const StandardizedText(
                        'Tags:',
                        style: StandardizedTextStyle.titleSmall,
                      ),
                      const SizedBox(height: SpacingTokens.sm),
                      
                      if (availableTags.isNotEmpty)
                        Wrap(
                          spacing: SpacingTokens.xs,
                          runSpacing: SpacingTokens.xs,
                          children: availableTags.take(10).map((tag) => FilterChip(
                            label: StandardizedText(tag, style: StandardizedTextStyle.bodyMedium),
                            selected: _selectedTags.contains(tag),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedTags.add(tag);
                                } else {
                                  _selectedTags.remove(tag);
                                }
                              });
                            },
                          )).toList(),
                        ),
                      
                      if (_selectedTags.isNotEmpty) ...[
                        const SizedBox(height: SpacingTokens.sm),
                        StandardizedText(
                          '${_selectedTags.length} tag${_selectedTags.length != 1 ? 's' : ''} selected',
                          style: StandardizedTextStyle.bodySmall,
                        ),
                      ],
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const StandardizedText('Cancel', style: StandardizedTextStyle.buttonText),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _createTask,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const StandardizedText('Create', style: StandardizedTextStyle.buttonText),
        ),
      ],
    );
  }

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return PhosphorIcons.caretDown();
      case TaskPriority.medium:
        return PhosphorIcons.minus();
      case TaskPriority.high:
        return PhosphorIcons.caretUp();
      case TaskPriority.urgent:
        return PhosphorIcons.arrowUp();
    }
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _dueDate = date;
      });
    }
  }

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final operations = ref.read(kanbanOperationsProvider);
      
      await operations.createTaskInColumn(
        _titleController.text.trim(),
        widget.initialStatus,
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        dueDate: _dueDate,
        priority: _priority,
        tags: _selectedTags,
        projectId: widget.projectId,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const StandardizedText('Task created successfully', style: StandardizedTextStyle.bodyMedium),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: StandardizedText('Failed to create task: $e', style: StandardizedTextStyle.bodyMedium),
            backgroundColor: context.errorColor,
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

/// Dialog for selecting task priority
class PrioritySelectionDialog extends StatelessWidget {
  final Function(TaskPriority) onPrioritySelected;

  const PrioritySelectionDialog({
    super.key,
    required this.onPrioritySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(PhosphorIcons.star(), color: theme.colorScheme.primary),
          const SizedBox(width: SpacingTokens.sm),
          const StandardizedText('Select Priority', style: StandardizedTextStyle.titleMedium),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: TaskPriority.values.map((priority) => ListTile(
          leading: Icon(
            _getPriorityIcon(priority),
            color: priority.color,
          ),
          title: StandardizedText(priority.displayName, style: StandardizedTextStyle.bodyMedium),
          onTap: () {
            onPrioritySelected(priority);
            Navigator.of(context).pop();
          },
        )).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const StandardizedText('Cancel', style: StandardizedTextStyle.buttonText),
        ),
      ],
    );
  }

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return PhosphorIcons.caretDown();
      case TaskPriority.medium:
        return PhosphorIcons.minus();
      case TaskPriority.high:
        return PhosphorIcons.caretUp();
      case TaskPriority.urgent:
        return PhosphorIcons.arrowUp();
    }
  }
}

/// Dialog for selecting tags to add to tasks
class TagSelectionDialog extends ConsumerStatefulWidget {
  final Function(List<String>) onTagsSelected;

  const TagSelectionDialog({
    super.key,
    required this.onTagsSelected,
  });

  @override
  ConsumerState<TagSelectionDialog> createState() => _TagSelectionDialogState();
}

class _TagSelectionDialogState extends ConsumerState<TagSelectionDialog> {
  final _newTagController = TextEditingController();
  final List<String> _selectedTags = [];

  @override
  void dispose() {
    _newTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final availableTagsAsync = ref.watch(availableSearchTagsProvider);

    return AlertDialog(
      title: Row(
        children: [
          Icon(PhosphorIcons.tag(), color: theme.colorScheme.primary),
          const SizedBox(width: SpacingTokens.sm),
          const StandardizedText('Add Tags', style: StandardizedTextStyle.titleMedium),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // New tag input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newTagController,
                    decoration: const InputDecoration(
                      hintText: 'Create new tag...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: SpacingTokens.sm),
                FilledButton(
                  onPressed: _addNewTag,
                  child: const StandardizedText('Add', style: StandardizedTextStyle.buttonText),
                ),
              ],
            ),

            const SizedBox(height: SpacingTokens.md),

            // Available tags
            availableTagsAsync.when(
              data: (availableTags) {
                if (availableTags.isEmpty) {
                  return StandardizedText(
                    'No existing tags. Create a new tag above.',
                    style: StandardizedTextStyle.bodyMedium,
                    color: theme.colorScheme.onSurfaceVariant,
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const StandardizedText(
                      'Available Tags',
                      style: StandardizedTextStyle.titleSmall,
                    ),
                    const SizedBox(height: SpacingTokens.sm),
                    
                    Wrap(
                      spacing: SpacingTokens.sm,
                      runSpacing: SpacingTokens.xs,
                      children: availableTags.map((tag) => FilterChip(
                        label: StandardizedText(tag, style: StandardizedTextStyle.bodyMedium),
                        selected: _selectedTags.contains(tag),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedTags.add(tag);
                            } else {
                              _selectedTags.remove(tag);
                            }
                          });
                        },
                      )).toList(),
                    ),
                  ],
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, _) => StandardizedText('Error loading tags: $error', style: StandardizedTextStyle.bodyMedium, color: context.errorColor),
            ),

            if (_selectedTags.isNotEmpty) ...[
              const SizedBox(height: SpacingTokens.md),
              Row(
                children: [
                  StandardizedText(
                    '${_selectedTags.length} tag${_selectedTags.length != 1 ? 's' : ''} selected',
                    style: StandardizedTextStyle.bodySmall,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedTags.clear();
                      });
                    },
                    child: const StandardizedText('Clear all', style: StandardizedTextStyle.buttonText),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const StandardizedText('Cancel', style: StandardizedTextStyle.buttonText),
        ),
        FilledButton(
          onPressed: _selectedTags.isNotEmpty ? () {
            widget.onTagsSelected(_selectedTags);
            Navigator.of(context).pop();
          } : null,
          child: const StandardizedText('Add Tags', style: StandardizedTextStyle.buttonText),
        ),
      ],
    );
  }

  void _addNewTag() {
    final tagName = _newTagController.text.trim();
    if (tagName.isNotEmpty && !_selectedTags.contains(tagName)) {
      setState(() {
        _selectedTags.add(tagName);
        _newTagController.clear();
      });
    }
  }
}