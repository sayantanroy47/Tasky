import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../../core/theme/typography_constants.dart';
import '../../core/design_system/design_tokens.dart';
import '../../core/constants/phosphor_icons.dart';
import '../../presentation/providers/task_providers.dart';
import '../../presentation/providers/kanban_providers.dart';
import 'glassmorphism_container.dart';
import 'kanban_board_view.dart';

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
          const Text('Filter Tasks'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Priority filter
            Text(
              'Priority',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: TypographyConstants.medium,
              ),
            ),
            const SizedBox(height: SpacingTokens.sm),
            
            Wrap(
              spacing: SpacingTokens.sm,
              children: [
                // Clear priority chip
                FilterChip(
                  label: const Text('Any'),
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
                      Text(priority.displayName),
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
            Text(
              'Tags',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: TypographyConstants.medium,
              ),
            ),
            const SizedBox(height: SpacingTokens.sm),
            
            availableTagsAsync.when(
              data: (availableTags) {
                if (availableTags.isEmpty) {
                  return Text(
                    'No tags available',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  );
                }
                
                return Wrap(
                  spacing: SpacingTokens.sm,
                  runSpacing: SpacingTokens.xs,
                  children: availableTags.map((tag) => FilterChip(
                    label: Text(tag),
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
              error: (error, _) => Text('Error loading tags: $error'),
            ),
            
            if (_selectedTags.isNotEmpty) ...[
              const SizedBox(height: SpacingTokens.sm),
              Row(
                children: [
                  Text(
                    '${_selectedTags.length} tag${_selectedTags.length != 1 ? 's' : ''} selected',
                    style: theme.textTheme.bodySmall,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedTags.clear();
                      });
                    },
                    child: const Text('Clear all'),
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
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _clearFilters,
          child: const Text('Clear'),
        ),
        FilledButton(
          onPressed: () {
            widget.onFiltersChanged(_selectedPriority, _selectedTags);
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
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
              Text(
                'View Options',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: TypographyConstants.medium,
                ),
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
                title: const Text('Show task counts'),
                subtitle: const Text('Display number of tasks in each column header'),
                value: config.showTaskCounts,
                onChanged: (_) => configNotifier.toggleTaskCounts(),
              ),
              SwitchListTile(
                title: const Text('Enable drag & drop'),
                subtitle: const Text('Allow moving tasks between columns'),
                value: config.enableDragAndDrop,
                onChanged: (_) => configNotifier.toggleDragAndDrop(),
              ),
              SwitchListTile(
                title: const Text('Batch operations'),
                subtitle: const Text('Enable selecting multiple tasks'),
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
              Text(
                'Quick Presets',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: TypographyConstants.medium,
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              
              Wrap(
                spacing: SpacingTokens.sm,
                children: presets.entries.map((entry) => ActionChip(
                  label: Text(_getPresetDisplayName(entry.key)),
                  onPressed: () => _applyPreset(entry.value),
                )).toList(),
              ),

              const SizedBox(height: SpacingTokens.md),

              // Column list
              Text(
                'Columns (${_workingColumns.length})',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: TypographyConstants.medium,
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              
              ..._workingColumns.asMap().entries.map((entry) {
                final index = entry.key;
                final column = entry.value;
                
                return _buildColumnTile(column, index, theme);
              }).toList(),
            ],
          ),

          const SizedBox(height: SpacingTokens.lg),

          // Action buttons
          Row(
            children: [
              TextButton(
                onPressed: _resetToDefaults,
                child: const Text('Reset to Default'),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: SpacingTokens.sm),
              FilledButton(
                onPressed: _applyChanges,
                child: const Text('Apply'),
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
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: TypographyConstants.medium,
            color: theme.colorScheme.primary,
          ),
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
        title: Text(column.title),
        subtitle: Text(column.status.displayName),
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
  List<String> _selectedTags = [];
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
          Text('Create Task - ${widget.initialStatus.displayName}'),
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
                  Text(
                    'Priority:',
                    style: theme.textTheme.titleSmall,
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
                            Text(priority.displayName),
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
                  Text(
                    'Due Date:',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  Expanded(
                    child: Row(
                      children: [
                        if (_dueDate != null) ...[
                          Text(
                            '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(width: SpacingTokens.sm),
                          IconButton(
                            onPressed: () => setState(() => _dueDate = null),
                            icon: Icon(PhosphorIcons.x(), size: 16),
                            tooltip: 'Clear date',
                          ),
                        ] else
                          Text(
                            'No due date',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        const Spacer(),
                        FilledButton.tonal(
                          onPressed: _selectDueDate,
                          child: const Text('Set Date'),
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
                      Text(
                        'Tags:',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: SpacingTokens.sm),
                      
                      if (availableTags.isNotEmpty)
                        Wrap(
                          spacing: SpacingTokens.xs,
                          runSpacing: SpacingTokens.xs,
                          children: availableTags.take(10).map((tag) => FilterChip(
                            label: Text(tag),
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
                        Text(
                          '${_selectedTags.length} tag${_selectedTags.length != 1 ? 's' : ''} selected',
                          style: theme.textTheme.bodySmall,
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
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _createTask,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
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
          const SnackBar(
            content: Text('Task created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create task: $e'),
            backgroundColor: Colors.red,
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
          const Text('Select Priority'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: TaskPriority.values.map((priority) => ListTile(
          leading: Icon(
            _getPriorityIcon(priority),
            color: priority.color,
          ),
          title: Text(priority.displayName),
          onTap: () {
            onPrioritySelected(priority);
            Navigator.of(context).pop();
          },
        )).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
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
  List<String> _selectedTags = [];

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
          const Text('Add Tags'),
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
                  child: const Text('Add'),
                ),
              ],
            ),

            const SizedBox(height: SpacingTokens.md),

            // Available tags
            availableTagsAsync.when(
              data: (availableTags) {
                if (availableTags.isEmpty) {
                  return Text(
                    'No existing tags. Create a new tag above.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Tags',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: TypographyConstants.medium,
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.sm),
                    
                    Wrap(
                      spacing: SpacingTokens.sm,
                      runSpacing: SpacingTokens.xs,
                      children: availableTags.map((tag) => FilterChip(
                        label: Text(tag),
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
              error: (error, _) => Text('Error loading tags: $error'),
            ),

            if (_selectedTags.isNotEmpty) ...[
              const SizedBox(height: SpacingTokens.md),
              Row(
                children: [
                  Text(
                    '${_selectedTags.length} tag${_selectedTags.length != 1 ? 's' : ''} selected',
                    style: theme.textTheme.bodySmall,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedTags.clear();
                      });
                    },
                    child: const Text('Clear all'),
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
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _selectedTags.isNotEmpty ? () {
            widget.onTagsSelected(_selectedTags);
            Navigator.of(context).pop();
          } : null,
          child: const Text('Add Tags'),
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