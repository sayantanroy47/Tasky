import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Smart text widget that automatically prevents overflow with multiple strategies
class SmartText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextAlign textAlign;
  final bool autoSize;
  final bool expandable;
  final double minFontSize;
  final double maxFontSize;
  final Color? color;
  final FontWeight? fontWeight;
  final double? fontSize;
  final TextOverflow overflow;
  final String? semanticsLabel;

  const SmartText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.textAlign = TextAlign.start,
    this.autoSize = false,
    this.expandable = false,
    this.minFontSize = 10,
    this.maxFontSize = 100,
    this.color,
    this.fontWeight,
    this.fontSize,
    this.overflow = TextOverflow.ellipsis,
    this.semanticsLabel,
  });

  @override
  State<SmartText> createState() => _SmartTextState();
}

class _SmartTextState extends State<SmartText> {
  bool _isExpanded = false;
  // final bool _needsExpansion = false;
  TextStyle? _effectiveStyle;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateEffectiveStyle();
  }

  @override
  void didUpdateWidget(SmartText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || 
        oldWidget.style != widget.style ||
        oldWidget.fontSize != widget.fontSize ||
        oldWidget.color != widget.color ||
        oldWidget.fontWeight != widget.fontWeight) {
      _updateEffectiveStyle();
    }
  }

  void _updateEffectiveStyle() {
    _effectiveStyle = (widget.style ?? Theme.of(context).textTheme.bodyMedium!).copyWith(
      color: widget.color,
      fontWeight: widget.fontWeight,
      fontSize: widget.fontSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    // final effectiveStyle = _effectiveStyle ?? Theme.of(context).textTheme.bodyMedium!;
    
    if (widget.autoSize) {
      return _buildAutoSizeText();
    }
    
    if (widget.expandable) {
      return _buildExpandableText();
    }
    
    return _buildSimpleText();
  }

  Widget _buildSimpleText() {
    final effectiveStyle = _effectiveStyle ?? Theme.of(context).textTheme.bodyMedium!;
    return Text(
      widget.text,
      style: effectiveStyle,
      maxLines: widget.maxLines,
      textAlign: widget.textAlign,
      overflow: widget.overflow,
      semanticsLabel: widget.semanticsLabel,
    );
  }

  Widget _buildAutoSizeText() {
    final effectiveStyle = _effectiveStyle ?? Theme.of(context).textTheme.bodyMedium!;
    return LayoutBuilder(
      builder: (context, constraints) {
        return _AutoSizeText(
          text: widget.text,
          style: effectiveStyle,
          maxLines: widget.maxLines,
          textAlign: widget.textAlign,
          minFontSize: widget.minFontSize,
          maxFontSize: widget.maxFontSize,
          constraints: constraints,
          semanticsLabel: widget.semanticsLabel,
        );
      },
    );
  }

  Widget _buildExpandableText() {
    final effectiveStyle = _effectiveStyle ?? Theme.of(context).textTheme.bodyMedium!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(text: widget.text, style: effectiveStyle);
        final tp = TextPainter(
          text: span,
          maxLines: widget.maxLines ?? 1,
          textAlign: widget.textAlign,
          textDirection: TextDirection.ltr,
        );
        tp.layout(maxWidth: constraints.maxWidth);

        final needsExpansion = tp.didExceedMaxLines;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              style: effectiveStyle,
              maxLines: _isExpanded ? null : widget.maxLines,
              textAlign: widget.textAlign,
              overflow: _isExpanded ? TextOverflow.visible : widget.overflow,
              semanticsLabel: widget.semanticsLabel,
            ),
            if (needsExpansion)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                  HapticFeedback.selectionClick();
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _isExpanded ? 'Show less' : 'Show more',
                    style: effectiveStyle.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _AutoSizeText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final int? maxLines;
  final TextAlign textAlign;
  final double minFontSize;
  final double maxFontSize;
  final BoxConstraints constraints;
  final String? semanticsLabel;

  const _AutoSizeText({
    required this.text,
    required this.style,
    this.maxLines,
    required this.textAlign,
    required this.minFontSize,
    required this.maxFontSize,
    required this.constraints,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = _calculateOptimalFontSize();
    
    return Text(
      text,
      style: style.copyWith(fontSize: fontSize),
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: TextOverflow.visible,
      semanticsLabel: semanticsLabel,
    );
  }

  double _calculateOptimalFontSize() {
    double currentFontSize = style.fontSize ?? 14.0;
    currentFontSize = currentFontSize.clamp(minFontSize, maxFontSize);
    
    while (currentFontSize > minFontSize) {
      final testStyle = style.copyWith(fontSize: currentFontSize);
      final span = TextSpan(text: text, style: testStyle);
      final tp = TextPainter(
        text: span,
        maxLines: maxLines,
        textAlign: textAlign,
        textDirection: TextDirection.ltr,
      );
      tp.layout(maxWidth: constraints.maxWidth);
      
      if (!tp.didExceedMaxLines) {
        break;
      }
      
      currentFontSize -= 1.0;
    }
    
    return currentFontSize.clamp(minFontSize, maxFontSize);
  }
}

/// Responsive text that adapts to screen size
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? baseStyle;
  final int? maxLines;
  final TextAlign textAlign;
  final Map<double, double>? fontSizeBreakpoints; // screen width -> font size
  final Color? color;
  final FontWeight? fontWeight;

  const ResponsiveText(
    this.text, {
    super.key,
    this.baseStyle,
    this.maxLines,
    this.textAlign = TextAlign.start,
    this.fontSizeBreakpoints,
    this.color,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = _getFontSizeForScreenWidth(screenWidth);
    
    final effectiveStyle = (baseStyle ?? Theme.of(context).textTheme.bodyMedium!).copyWith(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
    );
    
    return SmartText(
      text,
      style: effectiveStyle,
      maxLines: maxLines,
      textAlign: textAlign,
      autoSize: true,
    );
  }

  double _getFontSizeForScreenWidth(double screenWidth) {
    if (fontSizeBreakpoints == null) {
      // Default responsive scaling
      if (screenWidth < 360) return (baseStyle?.fontSize ?? 14) * 0.9;
      if (screenWidth < 600) return (baseStyle?.fontSize ?? 14);
      if (screenWidth < 900) return (baseStyle?.fontSize ?? 14) * 1.1;
      return (baseStyle?.fontSize ?? 14) * 1.2;
    }
    
    // Custom breakpoints
    final sortedBreakpoints = fontSizeBreakpoints!.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    
    for (final breakpoint in sortedBreakpoints.reversed) {
      if (screenWidth >= breakpoint.key) {
        return breakpoint.value;
      }
    }
    
    return sortedBreakpoints.first.value;
  }
}

/// Text with gradient effect
class GradientText extends StatelessWidget {
  final String text;
  final Gradient gradient;
  final TextStyle? style;
  final int? maxLines;
  final TextAlign textAlign;
  final TextOverflow overflow;

  const GradientText(
    this.text, {
    super.key,
    required this.gradient,
    this.style,
    this.maxLines,
    this.textAlign = TextAlign.start,
    this.overflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: SmartText(
        text,
        style: style?.copyWith(color: Colors.white) ?? 
               Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
        maxLines: maxLines,
        textAlign: textAlign,
        overflow: overflow,
      ),
    );
  }
}

/// Animated text that types itself out
class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;
  final Duration? delay;
  final VoidCallback? onComplete;

  const TypewriterText(
    this.text, {
    super.key,
    this.style,
    this.duration = const Duration(milliseconds: 1000),
    this.delay,
    this.onComplete,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _characterCount;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _characterCount = StepTween(
      begin: 0,
      end: widget.text.length,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    if (widget.delay != null) {
      Future.delayed(widget.delay!, () {
        if (mounted) {
          _controller.forward();
        }
      });
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _characterCount,
      builder: (context, child) {
        final visibleText = widget.text.substring(0, _characterCount.value);
        return SmartText(
          visibleText,
          style: widget.style,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Highlighted text with search term highlighting
class HighlightedText extends StatelessWidget {
  final String text;
  final String? searchTerm;
  final TextStyle? style;
  final TextStyle? highlightStyle;
  final int? maxLines;
  final TextAlign textAlign;

  const HighlightedText(
    this.text, {
    super.key,
    this.searchTerm,
    this.style,
    this.highlightStyle,
    this.maxLines,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    if (searchTerm == null || searchTerm!.isEmpty) {
      return SmartText(
        text,
        style: style,
        maxLines: maxLines,
        textAlign: textAlign,
      );
    }

    final spans = <TextSpan>[];
    final pattern = RegExp(RegExp.escape(searchTerm!), caseSensitive: false);
    final matches = pattern.allMatches(text);

    int currentIndex = 0;
    for (final match in matches) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, match.start),
          style: style,
        ));
      }

      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: highlightStyle ??
            (style ?? Theme.of(context).textTheme.bodyMedium!).copyWith(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
      ));

      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentIndex),
        style: style,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Smart text field that prevents overflow
class SmartTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final TextStyle? style;
  final int? maxLines;
  final int? maxLength;
  final bool autoSize;
  final double minFontSize;
  final double maxFontSize;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  const SmartTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.style,
    this.maxLines,
    this.maxLength,
    this.autoSize = false,
    this.minFontSize = 10,
    this.maxFontSize = 20,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return TextField(
          controller: controller,
          style: autoSize ? _getAutoSizedStyle(context, constraints) : style,
          maxLines: maxLines,
          maxLength: maxLength,
          onChanged: onChanged,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hintText,
            labelText: labelText,
            border: const OutlineInputBorder(),
          ),
        );
      },
    );
  }

  TextStyle? _getAutoSizedStyle(BuildContext context, BoxConstraints constraints) {
    final baseStyle = style ?? Theme.of(context).textTheme.bodyMedium!;
    final text = controller?.text ?? '';
    
    if (text.isEmpty) return baseStyle;
    
    double fontSize = baseStyle.fontSize ?? 14.0;
    fontSize = fontSize.clamp(minFontSize, maxFontSize);
    
    while (fontSize > minFontSize) {
      final testStyle = baseStyle.copyWith(fontSize: fontSize);
      final span = TextSpan(text: text, style: testStyle);
      final tp = TextPainter(
        text: span,
        maxLines: maxLines,
        textDirection: TextDirection.ltr,
      );
      tp.layout(maxWidth: constraints.maxWidth - 24); // Account for padding
      
      if (!tp.didExceedMaxLines) {
        break;
      }
      
      fontSize -= 1.0;
    }
    
    return baseStyle.copyWith(fontSize: fontSize.clamp(minFontSize, maxFontSize));
  }
}

/// Utility functions for text handling
class TextUtils {
  /// Truncate text to fit within constraints
  static String truncateText(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - suffix.length)}$suffix';
  }

  /// Calculate text size
  static Size calculateTextSize({
    required String text,
    required TextStyle style,
    int? maxLines,
    double? maxWidth,
  }) {
    final span = TextSpan(text: text, style: style);
    final tp = TextPainter(
      text: span,
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    );
    tp.layout(maxWidth: maxWidth ?? double.infinity);
    return tp.size;
  }

  /// Check if text will overflow
  static bool willTextOverflow({
    required String text,
    required TextStyle style,
    required BoxConstraints constraints,
    int? maxLines,
  }) {
    final span = TextSpan(text: text, style: style);
    final tp = TextPainter(
      text: span,
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    );
    tp.layout(maxWidth: constraints.maxWidth);
    return tp.didExceedMaxLines || tp.size.height > constraints.maxHeight;
  }
}