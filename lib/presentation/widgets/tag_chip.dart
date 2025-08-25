import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../domain/entities/tag.dart';

/// A reusable chip component for displaying tags with custom colors
/// 
/// Features:
/// - Custom colors from Tag entity
/// - Multiple sizes (small, medium, large)
/// - Optional close button for removal
/// - Configurable spacing (3px default as requested)
/// - Material 3 design system compliance
/// - Accessible touch targets
/// - Tap callbacks for interaction
class TagChip extends StatelessWidget {
  /// The tag to display
  final Tag tag;
  
  /// Size variant of the chip
  final TagChipSize size;
  
  /// Whether to show a close button for removing the tag
  final bool showCloseButton;
  
  /// Callback when the chip is tapped
  final VoidCallback? onTap;
  
  /// Callback when the close button is tapped
  final VoidCallback? onClose;
  
  /// Whether the chip is selected/active
  final bool isSelected;
  
  /// Custom color override (uses tag.color if null)
  final Color? customColor;
  
  /// Whether to use outlined style instead of filled
  final bool outlined;

  const TagChip({
    super.key,
    required this.tag,
    this.size = TagChipSize.medium,
    this.showCloseButton = false,
    this.onTap,
    this.onClose,
    this.isSelected = false,
    this.customColor,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Parse color from tag or use custom color
    final chipColor = customColor ?? _parseColor(tag.color, context);
    
    // Size-specific dimensions
    final (height, horizontalPadding, fontSize, iconSize) = _getSizeDimensions();
    
    // Color variants based on style
    final backgroundColor = outlined 
        ? Colors.transparent
        : isSelected 
            ? chipColor
            : chipColor.withValues(alpha: 0.12);
    
    final borderColor = outlined ? chipColor : Colors.transparent;
    final textColor = outlined || isSelected 
        ? _getContrastingTextColor(chipColor, colorScheme)
        : chipColor;

    return Container(
      height: height,
      constraints: const BoxConstraints(minWidth: 32),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(height / 2),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(height / 2),
          child: Container(
            decoration: BoxDecoration(
              border: outlined ? Border.all(color: borderColor, width: 1) : null,
              borderRadius: BorderRadius.circular(height / 2),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tag text
                Flexible(
                  child: Text(
                    tag.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                // Close button
                if (showCloseButton) ...[
                  const SizedBox(width: 4),
                  SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(iconSize / 2),
                      child: InkWell(
                        onTap: onClose,
                        borderRadius: BorderRadius.circular(iconSize / 2),
                        child: Icon(
                          PhosphorIcons.x(),
                          size: iconSize * 0.7,
                          color: textColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Returns size-specific dimensions (height, horizontalPadding, fontSize, iconSize)
  (double, double, double, double) _getSizeDimensions() {
    switch (size) {
      case TagChipSize.small:
        return (20.0, 8.0, 10.0, 16.0);
      case TagChipSize.medium:
        return (24.0, 10.0, 12.0, 18.0);
      case TagChipSize.large:
        return (28.0, 12.0, 14.0, 20.0);
    }
  }

  /// Parses color string to Color object
  Color _parseColor(String? colorString, BuildContext context) {
    if (colorString == null || colorString.isEmpty) {
      return Theme.of(context).colorScheme.primary;
    }
    
    try {
      // Handle different color formats
      String cleanColor = colorString.replaceAll('#', '');
      
      // Add alpha if not present
      if (cleanColor.length == 6) {
        cleanColor = 'FF$cleanColor';
      }
      
      final intValue = int.parse(cleanColor, radix: 16);
      return Color(intValue);
    } catch (e) {
      // Fallback to primary color if parsing fails
      return Theme.of(context).colorScheme.primary;
    }
  }

  /// Gets contrasting text color for better readability
  Color _getContrastingTextColor(Color backgroundColor, ColorScheme colorScheme) {
    final brightness = backgroundColor.computeLuminance();
    return brightness > 0.5 ? colorScheme.onSurface : colorScheme.surface;
  }
}

/// Size variants for TagChip
enum TagChipSize {
  small,
  medium,
  large,
}

/// Widget for displaying multiple tags with proper spacing
/// Handles overflow with "+X more" indicator as requested
class TagChipList extends StatelessWidget {
  /// List of tags to display
  final List<Tag> tags;
  
  /// Size of the chips
  final TagChipSize chipSize;
  
  /// Maximum number of chips to show before showing "+X more"
  final int maxChips;
  
  /// Spacing between chips (defaults to 3px as requested)
  final double spacing;
  
  /// Whether to show close buttons on chips
  final bool showCloseButtons;
  
  /// Callback when a tag is tapped
  final Function(Tag)? onTagTap;
  
  /// Callback when a tag is removed
  final Function(Tag)? onTagRemove;
  
  /// Callback when "+X more" is tapped
  final VoidCallback? onMoreTap;
  
  /// Whether to use outlined style
  final bool outlined;

  const TagChipList({
    super.key,
    required this.tags,
    this.chipSize = TagChipSize.medium,
    this.maxChips = 3,
    this.spacing = 3.0,
    this.showCloseButtons = false,
    this.onTagTap,
    this.onTagRemove,
    this.onMoreTap,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return const SizedBox.shrink();
    
    final displayTags = tags.take(maxChips).toList();
    final remainingCount = tags.length - maxChips;
    
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: [
        // Display visible tags
        ...displayTags.map((tag) => TagChip(
          tag: tag,
          size: chipSize,
          showCloseButton: showCloseButtons,
          outlined: outlined,
          onTap: onTagTap != null ? () => onTagTap!(tag) : null,
          onClose: onTagRemove != null ? () => onTagRemove!(tag) : null,
        )),
        
        // Show "+X more" if there are hidden tags
        if (remainingCount > 0)
          _MoreTagsChip(
            count: remainingCount,
            size: chipSize,
            onTap: onMoreTap,
          ),
      ],
    );
  }
}

/// Internal widget for showing "+X more" indicator
class _MoreTagsChip extends StatelessWidget {
  final int count;
  final TagChipSize size;
  final VoidCallback? onTap;

  const _MoreTagsChip({
    required this.count,
    required this.size,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final (height, horizontalPadding, fontSize, _) = _getSizeDimensions();
    
    return SizedBox(
      height: height,
      child: Material(
        color: colorScheme.outline.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(height / 2),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(height / 2),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 0,
            ),
            child: Text(
              '+$count',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }

  (double, double, double, double) _getSizeDimensions() {
    switch (size) {
      case TagChipSize.small:
        return (20.0, 8.0, 10.0, 16.0);
      case TagChipSize.medium:
        return (24.0, 10.0, 12.0, 18.0);
      case TagChipSize.large:
        return (28.0, 12.0, 14.0, 20.0);
    }
  }
}