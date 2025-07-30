import 'package:flutter/material.dart';

/// Widget that highlights search terms in text
class HighlightedText extends StatelessWidget {
  final String text;
  final String? searchQuery;
  final TextStyle? style;
  final Color? highlightColor;
  final int maxLines;
  final TextOverflow overflow;

  const HighlightedText({
    super.key,
    required this.text,
    this.searchQuery,
    this.style,
    this.highlightColor,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    if (searchQuery == null || searchQuery!.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    final theme = Theme.of(context);
    final defaultHighlightColor = highlightColor ?? 
        theme.colorScheme.primary.withValues(alpha: 0.1);

    final spans = _buildHighlightedSpans(
      text,
      searchQuery!,
      style ?? theme.textTheme.bodyMedium!,
      defaultHighlightColor,
    );

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  List<TextSpan> _buildHighlightedSpans(
    String text,
    String query,
    TextStyle baseStyle,
    Color highlightColor,
  ) {
    if (query.isEmpty) {
      return [TextSpan(text: text, style: baseStyle)];
    }

    final spans = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    
    int start = 0;
    int index = lowerText.indexOf(lowerQuery);

    while (index != -1) {
      // Add text before the match
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: baseStyle,
        ));
      }

      // Add highlighted match
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: baseStyle.copyWith(
          backgroundColor: highlightColor,
          fontWeight: FontWeight.bold,
        ),
      ));

      start = index + query.length;
      index = lowerText.indexOf(lowerQuery, start);
    }

    // Add remaining text
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: baseStyle,
      ));
    }

    return spans;
  }
}