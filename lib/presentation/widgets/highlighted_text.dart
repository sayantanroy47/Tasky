import 'package:flutter/material.dart';

/// A widget that highlights specific text within a larger text string
class HighlightedText extends StatelessWidget {
  final String text;
  final String highlight;
  final TextStyle? style;
  final TextStyle? highlightStyle;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  const HighlightedText({
    super.key,
    required this.text,
    required this.highlight,
    this.style,
    this.highlightStyle,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    if (highlight.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
      );
    }

    final spans = _buildTextSpans(context);

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
      textAlign: textAlign ?? TextAlign.start,
    );
  }

  List<TextSpan> _buildTextSpans(BuildContext context) {
    final spans = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerHighlight = highlight.toLowerCase();

    int start = 0;
    int index = lowerText.indexOf(lowerHighlight);

    final defaultStyle = style ?? DefaultTextStyle.of(context).style;
    final defaultHighlightStyle = highlightStyle ??
        TextStyle(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w500,
        );

    while (index != -1) {
      // Add text before the highlight
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: defaultStyle,
        ));
      }

      // Add the highlighted text
      spans.add(TextSpan(
        text: text.substring(index, index + highlight.length),
        style: defaultStyle.merge(defaultHighlightStyle),
      ));

      start = index + highlight.length;
      index = lowerText.indexOf(lowerHighlight, start);
    }

    // Add remaining text
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: defaultStyle,
      ));
    }

    return spans;
  }
}

/// A widget that highlights multiple search terms in text
class MultiHighlightedText extends StatelessWidget {
  final String text;
  final List<String> highlights;
  final TextStyle? style;
  final List<TextStyle>? highlightStyles;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  const MultiHighlightedText({
    super.key,
    required this.text,
    required this.highlights,
    this.style,
    this.highlightStyles,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    if (highlights.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
      );
    }

    final spans = _buildTextSpans(context);

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
      textAlign: textAlign ?? TextAlign.start,
    );
  }

  List<TextSpan> _buildTextSpans(BuildContext context) {
    final spans = <TextSpan>[];
    final lowerText = text.toLowerCase();

    final defaultStyle = style ?? DefaultTextStyle.of(context).style;
    final defaultHighlightColors = [
      Theme.of(context).colorScheme.primaryContainer,
      Theme.of(context).colorScheme.secondaryContainer,
      Theme.of(context).colorScheme.tertiaryContainer,
    ];

    // Create a list of all highlight positions
    final highlightPositions = <_HighlightPosition>[];

    for (int i = 0; i < highlights.length; i++) {
      final highlight = highlights[i].toLowerCase();
      if (highlight.isEmpty) continue;

      int index = lowerText.indexOf(highlight);
      while (index != -1) {
        highlightPositions.add(_HighlightPosition(
          start: index,
          end: index + highlight.length,
          highlightIndex: i,
          originalText: text.substring(index, index + highlight.length),
        ));
        index = lowerText.indexOf(highlight, index + 1);
      }
    }

    // Sort by start position
    highlightPositions.sort((a, b) => a.start.compareTo(b.start));

    // Merge overlapping highlights
    final mergedPositions = _mergeOverlappingHighlights(highlightPositions);

    int currentPos = 0;

    for (final position in mergedPositions) {
      // Add text before highlight
      if (position.start > currentPos) {
        spans.add(TextSpan(
          text: text.substring(currentPos, position.start),
          style: defaultStyle,
        ));
      }

      // Add highlighted text
      final highlightStyle = highlightStyles != null && position.highlightIndex < highlightStyles!.length
          ? highlightStyles![position.highlightIndex]
          : TextStyle(
              backgroundColor: defaultHighlightColors[position.highlightIndex % defaultHighlightColors.length],
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w500,
            );

      spans.add(TextSpan(
        text: position.originalText,
        style: defaultStyle.merge(highlightStyle),
      ));

      currentPos = position.end;
    }

    // Add remaining text
    if (currentPos < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentPos),
        style: defaultStyle,
      ));
    }

    return spans;
  }

  List<_HighlightPosition> _mergeOverlappingHighlights(List<_HighlightPosition> positions) {
    if (positions.isEmpty) return positions;

    final merged = <_HighlightPosition>[];
    _HighlightPosition current = positions.first;

    for (int i = 1; i < positions.length; i++) {
      final next = positions[i];

      if (next.start <= current.end) {
        // Overlapping - merge them
        current = _HighlightPosition(
          start: current.start,
          end: next.end > current.end ? next.end : current.end,
          highlightIndex: current.highlightIndex, // Keep first highlight's style
          originalText: text.substring(
            current.start,
            next.end > current.end ? next.end : current.end,
          ),
        );
      } else {
        // No overlap - add current and move to next
        merged.add(current);
        current = next;
      }
    }

    merged.add(current);
    return merged;
  }
}

class _HighlightPosition {
  final int start;
  final int end;
  final int highlightIndex;
  final String originalText;

  _HighlightPosition({
    required this.start,
    required this.end,
    required this.highlightIndex,
    required this.originalText,
  });
}
