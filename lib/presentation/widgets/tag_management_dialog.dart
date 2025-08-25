import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../domain/entities/tag.dart';
import 'tag_chip.dart';

/// Dialog for managing tags - creating, editing, and selecting tags
/// 
/// Features:
/// - Create new tags with custom names and colors  
/// - Edit existing tags
/// - Color picker with predefined and custom colors
/// - Tag selection for tasks/projects
/// - Search and filter existing tags
/// - Preview of tag appearance
class TagManagementDialog extends ConsumerStatefulWidget {
  /// Currently selected tags (for selection mode)
  final List<Tag> selectedTags;
  
  /// All available tags to choose from
  final List<Tag> availableTags;
  
  /// Whether this dialog is for selection or management
  final TagDialogMode mode;
  
  /// Maximum number of tags that can be selected
  final int? maxSelection;
  
  /// Title to display in the dialog
  final String? title;
  
  /// Callback when tags are selected/deselected
  final Function(List<Tag>)? onTagsSelected;
  
  /// Callback when a new tag is created
  final Function(Tag)? onTagCreated;
  
  /// Callback when a tag is updated
  final Function(Tag)? onTagUpdated;
  
  /// Callback when a tag is deleted
  final Function(Tag)? onTagDeleted;

  const TagManagementDialog({
    super.key,
    this.selectedTags = const [],
    this.availableTags = const [],
    this.mode = TagDialogMode.selection,
    this.maxSelection,
    this.title,
    this.onTagsSelected,
    this.onTagCreated,
    this.onTagUpdated,
    this.onTagDeleted,
  });

  @override
  ConsumerState<TagManagementDialog> createState() => _TagManagementDialogState();
}

class _TagManagementDialogState extends ConsumerState<TagManagementDialog> {
  late List<Tag> _selectedTags;
  late List<Tag> _availableTags;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showCreateForm = false;
  Tag? _editingTag;

  @override
  void initState() {
    super.initState();
    _selectedTags = List.from(widget.selectedTags);
    _availableTags = List.from(widget.availableTags);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Tag> get _filteredTags {
    if (_searchQuery.isEmpty) return _availableTags;
    
    return _availableTags.where((tag) =>
      tag.name.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Dialog(
      child: Container(
        width: 400,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(
                    PhosphorIcons.tag(),
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title ?? _getDefaultTitle(),
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(PhosphorIcons.x()),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search bar
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search tags...',
                        prefixIcon: Icon(PhosphorIcons.magnifyingGlass()),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Selected tags (if in selection mode)
                    if (widget.mode == TagDialogMode.selection && _selectedTags.isNotEmpty) ...[
                      Text(
                        'Selected Tags (${_selectedTags.length})',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      TagChipList(
                        tags: _selectedTags,
                        chipSize: TagChipSize.medium,
                        showCloseButtons: true,
                        onTagRemove: _removeTag,
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                    ],
                    
                    // Available tags section
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Available Tags (${_filteredTags.length})',
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                        if (widget.mode == TagDialogMode.management || widget.onTagCreated != null)
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _showCreateForm = !_showCreateForm;
                                _editingTag = null;
                              });
                            },
                            icon: Icon(_showCreateForm ? PhosphorIcons.x() : PhosphorIcons.plus()),
                            label: Text(_showCreateForm ? 'Cancel' : 'New Tag'),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Create/Edit tag form
                    if (_showCreateForm || _editingTag != null)
                      _TagForm(
                        tag: _editingTag,
                        onSave: _saveTag,
                        onCancel: () {
                          setState(() {
                            _showCreateForm = false;
                            _editingTag = null;
                          });
                        },
                      ),
                    
                    if (_showCreateForm || _editingTag != null)
                      const SizedBox(height: 16),
                    
                    // Tags list
                    if (_filteredTags.isEmpty)
                      _EmptyTagsState(searchQuery: _searchQuery)
                    else
                      _TagsList(
                        tags: _filteredTags,
                        selectedTags: _selectedTags,
                        mode: widget.mode,
                        maxSelection: widget.maxSelection,
                        onTagSelected: _selectTag,
                        onTagEdit: widget.mode == TagDialogMode.management 
                            ? _editTag 
                            : null,
                        onTagDelete: widget.mode == TagDialogMode.management
                            ? _deleteTag
                            : null,
                      ),
                  ],
                ),
              ),
            ),
            
            // Footer actions
            if (widget.mode == TagDialogMode.selection)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: colorScheme.outlineVariant),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      '${_selectedTags.length} selected',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        widget.onTagsSelected?.call(_selectedTags);
                        Navigator.of(context).pop(_selectedTags);
                      },
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getDefaultTitle() {
    switch (widget.mode) {
      case TagDialogMode.selection:
        return 'Select Tags';
      case TagDialogMode.management:
        return 'Manage Tags';
    }
  }

  void _selectTag(Tag tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        if (widget.maxSelection == null || _selectedTags.length < widget.maxSelection!) {
          _selectedTags.add(tag);
        }
      }
    });
  }

  void _removeTag(Tag tag) {
    setState(() {
      _selectedTags.remove(tag);
    });
  }

  void _editTag(Tag tag) {
    setState(() {
      _editingTag = tag;
      _showCreateForm = false;
    });
  }

  void _saveTag(Tag tag) {
    if (_editingTag != null) {
      // Update existing tag
      widget.onTagUpdated?.call(tag);
      setState(() {
        final index = _availableTags.indexWhere((t) => t.id == tag.id);
        if (index != -1) {
          _availableTags[index] = tag;
        }
        _editingTag = null;
      });
    } else {
      // Create new tag
      widget.onTagCreated?.call(tag);
      setState(() {
        _availableTags.add(tag);
        _showCreateForm = false;
      });
    }
  }

  void _deleteTag(Tag tag) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tag'),
        content: Text('Are you sure you want to delete "${tag.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              widget.onTagDeleted?.call(tag);
              setState(() {
                _availableTags.remove(tag);
                _selectedTags.remove(tag);
              });
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Tag creation/editing form
class _TagForm extends StatefulWidget {
  final Tag? tag;
  final Function(Tag) onSave;
  final VoidCallback onCancel;

  const _TagForm({
    this.tag,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<_TagForm> createState() => _TagFormState();
}

class _TagFormState extends State<_TagForm> {
  late TextEditingController _nameController;
  late String _selectedColor;
  final _formKey = GlobalKey<FormState>();

  // Predefined colors for quick selection
  static const List<String> _predefinedColors = [
    '#2196F3', '#4CAF50', '#FF9800', '#F44336', '#9C27B0',
    '#607D8B', '#795548', '#FF5722', '#3F51B5', '#009688',
    '#CDDC39', '#FFC107', '#E91E63', '#00BCD4', '#8BC34A',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tag?.name ?? '');
    _selectedColor = widget.tag?.color ?? '#2196F3';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.tag != null ? 'Edit Tag' : 'Create New Tag',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              
              // Tag name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tag Name',
                  hintText: 'Enter tag name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Tag name is required';
                  }
                  if (value.trim().length > 30) {
                    return 'Tag name cannot exceed 30 characters';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Color selection
              Text(
                'Tag Color',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              
              // Color preview and current selection
              Row(
                children: [
                  Text('Preview: ', style: theme.textTheme.bodySmall),
                  TagChip(
                    tag: Tag(
                      id: 'preview',
                      name: _nameController.text.isEmpty ? 'Tag Name' : _nameController.text,
                      color: _selectedColor,
                      createdAt: DateTime.now(),
                    ),
                    size: TagChipSize.medium,
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Predefined colors grid
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _predefinedColors.map((color) => _ColorOption(
                  color: color,
                  isSelected: _selectedColor == color,
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                )).toList(),
              ),
              
              const SizedBox(height: 16),
              
              // Action buttons
              Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: widget.onCancel,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _saveTag,
                    child: Text(widget.tag != null ? 'Update' : 'Create'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveTag() {
    if (_formKey.currentState?.validate() ?? false) {
      final tag = Tag(
        id: widget.tag?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        color: _selectedColor,
        createdAt: widget.tag?.createdAt ?? DateTime.now(),
        updatedAt: widget.tag != null ? DateTime.now() : null,
      );
      
      widget.onSave(tag);
    }
  }
}

/// Color selection option widget
class _ColorOption extends StatelessWidget {
  final String color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorOption({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorValue = _parseColor(color);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: colorValue,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: Theme.of(context).colorScheme.primary, width: 3)
              : Border.all(color: Theme.of(context).colorScheme.outline, width: 1),
        ),
        child: isSelected
            ? Icon(
                PhosphorIcons.check(),
                size: 16,
                color: _getContrastingColor(colorValue),
              )
            : null,
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      String cleanColor = colorString.replaceAll('#', '');
      if (cleanColor.length == 6) {
        cleanColor = 'FF$cleanColor';
      }
      return Color(int.parse(cleanColor, radix: 16));
    } catch (e) {
      return Colors.blue;
    }
  }

  Color _getContrastingColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}

/// List of tags with selection/management functionality
class _TagsList extends StatelessWidget {
  final List<Tag> tags;
  final List<Tag> selectedTags;
  final TagDialogMode mode;
  final int? maxSelection;
  final Function(Tag) onTagSelected;
  final Function(Tag)? onTagEdit;
  final Function(Tag)? onTagDelete;

  const _TagsList({
    required this.tags,
    required this.selectedTags,
    required this.mode,
    this.maxSelection,
    required this.onTagSelected,
    this.onTagEdit,
    this.onTagDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: tags.map((tag) => _TagListItem(
        tag: tag,
        isSelected: selectedTags.contains(tag),
        mode: mode,
        canSelect: maxSelection == null || selectedTags.length < maxSelection! || selectedTags.contains(tag),
        onTap: () => onTagSelected(tag),
        onEdit: onTagEdit != null ? () => onTagEdit!(tag) : null,
        onDelete: onTagDelete != null ? () => onTagDelete!(tag) : null,
      )).toList(),
    );
  }
}

/// Individual tag list item
class _TagListItem extends StatelessWidget {
  final Tag tag;
  final bool isSelected;
  final TagDialogMode mode;
  final bool canSelect;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _TagListItem({
    required this.tag,
    required this.isSelected,
    required this.mode,
    required this.canSelect,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        leading: mode == TagDialogMode.selection
            ? Checkbox(
                value: isSelected,
                onChanged: canSelect ? (_) => onTap() : null,
              )
            : TagChip(
                tag: tag,
                size: TagChipSize.small,
              ),
        title: mode == TagDialogMode.selection
            ? TagChip(
                tag: tag,
                size: TagChipSize.medium,
              )
            : Text(tag.name),
        subtitle: mode == TagDialogMode.management
            ? Text(
                'Created ${_formatDate(tag.createdAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            : null,
        trailing: mode == TagDialogMode.management
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onEdit != null)
                    IconButton(
                      onPressed: onEdit,
                      icon: Icon(PhosphorIcons.pencil()),
                      tooltip: 'Edit tag',
                    ),
                  if (onDelete != null)
                    IconButton(
                      onPressed: onDelete,
                      icon: Icon(
                        PhosphorIcons.trash(),
                        color: theme.colorScheme.error,
                      ),
                      tooltip: 'Delete tag',
                    ),
                ],
              )
            : null,
        onTap: mode == TagDialogMode.selection && canSelect ? onTap : null,
        enabled: canSelect,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Empty state when no tags are found
class _EmptyTagsState extends StatelessWidget {
  final String searchQuery;

  const _EmptyTagsState({required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            searchQuery.isEmpty ? PhosphorIcons.tag() : PhosphorIcons.magnifyingGlass(),
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isEmpty
                ? 'No tags available'
                : 'No tags found for "$searchQuery"',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (searchQuery.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Create your first tag to get started',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

/// Dialog mode enumeration
enum TagDialogMode {
  selection,
  management,
}