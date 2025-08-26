import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/design_system/design_tokens.dart';
import '../../domain/entities/tag.dart';
import '../providers/tag_providers.dart';
import 'tag_chip.dart';
import 'standardized_text.dart';
import 'standardized_spacing.dart';
import 'standardized_form_widgets.dart';
import 'glassmorphism_container.dart';

/// Widget for selecting tags with ability to create new ones
class TagSelectionWidget extends ConsumerStatefulWidget {
  /// Currently selected tags
  final List<Tag> selectedTags;
  
  /// Callback when tags selection changes
  final Function(List<Tag>) onTagsChanged;
  
  /// Maximum number of tags that can be selected
  final int? maxTags;
  
  /// Whether to show the create new tag option
  final bool allowCreate;
  
  /// Whether to show in compact mode (single row)
  final bool isCompact;

  const TagSelectionWidget({
    super.key,
    required this.selectedTags,
    required this.onTagsChanged,
    this.maxTags,
    this.allowCreate = true,
    this.isCompact = false,
  });

  @override
  ConsumerState<TagSelectionWidget> createState() => _TagSelectionWidgetState();
}

class _TagSelectionWidgetState extends ConsumerState<TagSelectionWidget> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _createTagController = TextEditingController();
  bool _showCreateForm = false;
  String? _selectedColor;

  @override
  void dispose() {
    _searchController.dispose();
    _createTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredTags = ref.watch(filteredTagsProvider);
    final isCreating = ref.watch(tagOperationsProvider).isLoading;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title and search
        if (!widget.isCompact) ...[
          Row(
            children: [
              const Expanded(
                child: StandardizedText(
                  'Tags',
                  style: StandardizedTextStyle.titleMedium,
                ),
              ),
              if (widget.allowCreate)
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () => setState(() => _showCreateForm = !_showCreateForm),
                  icon: Icon(
                    _showCreateForm ? PhosphorIcons.x() : PhosphorIcons.plus(),
                    size: 16,
                  ),
                  label: Text(_showCreateForm ? 'Cancel' : 'New Tag'),
                ),
            ],
          ),
          StandardizedGaps.vertical(SpacingSize.sm),
          
          // Search field
          StandardizedFormField(
            controller: _searchController,
            hint: 'Search tags...',
            prefixIcon: Icon(PhosphorIcons.magnifyingGlass()),
            onChanged: (value) {
              ref.read(tagSearchQueryProvider.notifier).state = value;
            },
          ),
          StandardizedGaps.vertical(SpacingSize.sm),
        ],

        // Create new tag form
        if (_showCreateForm && widget.allowCreate) ...[
          _buildCreateTagForm(theme, isCreating),
          StandardizedGaps.vertical(SpacingSize.sm),
        ],

        // Selected tags
        if (widget.selectedTags.isNotEmpty) ...[
          const StandardizedText(
            'Selected',
            style: StandardizedTextStyle.labelMedium,
          ),
          StandardizedGaps.vertical(SpacingSize.xs),
          TagChipList(
            tags: widget.selectedTags,
            chipSize: TagChipSize.medium,
            showCloseButtons: true,
            onTagRemove: _removeTag,
            spacing: 8.0,
          ),
          StandardizedGaps.vertical(SpacingSize.md),
        ],

        // Available tags
        filteredTags.when(
          data: (tags) => _buildTagsList(tags, theme),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: StandardizedText(
              'Failed to load tags: $error',
              style: StandardizedTextStyle.bodyMedium,
              color: theme.colorScheme.error,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateTagForm(ThemeData theme, bool isCreating) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StandardizedText(
            'Create New Tag',
            style: StandardizedTextStyle.titleSmall,
          ),
          StandardizedGaps.vertical(SpacingSize.sm),
          
          // Tag name field
          StandardizedFormField(
            controller: _createTagController,
            hint: 'Tag name...',
            prefixIcon: Icon(PhosphorIcons.tag()),
            textCapitalization: TextCapitalization.words,
          ),
          StandardizedGaps.vertical(SpacingSize.sm),
          
          // Color selection
          const StandardizedText(
            'Color',
            style: StandardizedTextStyle.labelMedium,
          ),
          StandardizedGaps.vertical(SpacingSize.xs),
          _buildColorPicker(theme),
          StandardizedGaps.vertical(SpacingSize.md),
          
          // Create button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isCreating ? null : _createNewTag,
              child: isCreating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create Tag'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPicker(ThemeData theme) {
    final colors = ref.watch(predefinedTagColorsProvider);
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((colorHex) {
        final color = Color(int.parse(colorHex.replaceAll('#', '0xFF')));
        final isSelected = _selectedColor == colorHex;
        
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = colorHex),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: theme.colorScheme.primary, width: 3)
                  : Border.all(
                      color: theme.colorScheme.outline.withValues(
                        alpha: theme.brightness == Brightness.light ? 0.6 : 0.3
                      ),
                      width: 1.5
                    ),
            ),
            child: isSelected
                ? Icon(
                    PhosphorIcons.check(),
                    color: _getContrastingColor(color),
                    size: 16,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTagsList(List<Tag> tags, ThemeData theme) {
    // Filter out already selected tags
    final availableTags = tags.where((tag) => 
      !widget.selectedTags.any((selected) => selected.id == tag.id)
    ).toList();

    if (availableTags.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              Icon(
                PhosphorIcons.tag(),
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              StandardizedGaps.vertical(SpacingSize.sm),
              StandardizedText(
                widget.selectedTags.isEmpty ? 'No tags available' : 'No more tags available',
                style: StandardizedTextStyle.bodyMedium,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      );
    }

    if (widget.isCompact) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: availableTags.take(6).map((tag) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TagChip(
              tag: tag,
              size: TagChipSize.medium,
              outlined: true,
              onTap: () => _addTag(tag),
            ),
          )).toList(),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableTags.map((tag) => TagChip(
        tag: tag,
        size: TagChipSize.medium,
        outlined: true,
        onTap: () => _addTag(tag),
      )).toList(),
    );
  }

  void _addTag(Tag tag) {
    if (widget.maxTags != null && widget.selectedTags.length >= widget.maxTags!) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum ${widget.maxTags} tags allowed'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final updatedTags = [...widget.selectedTags, tag];
    widget.onTagsChanged(updatedTags);
  }

  void _removeTag(Tag tag) {
    final updatedTags = widget.selectedTags.where((t) => t.id != tag.id).toList();
    widget.onTagsChanged(updatedTags);
  }

  Future<void> _createNewTag() async {
    final name = _createTagController.text.trim();
    if (name.isEmpty) return;

    try {
      final tag = await ref.read(tagOperationsProvider.notifier).createTag(
        name: name,
        color: _selectedColor ?? '#2196F3', // Default blue
      );

      // Add the new tag to selection
      _addTag(tag);

      // Reset form
      _createTagController.clear();
      setState(() {
        _selectedColor = null;
        _showCreateForm = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tag "$name" created successfully!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create tag: $error'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Color _getContrastingColor(Color backgroundColor) {
    final brightness = backgroundColor.computeLuminance();
    return brightness > 0.5 ? Colors.black : Colors.white;
  }
}