import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/accessibility/accessibility_constants.dart';
import '../../core/design_system/design_tokens.dart';
import '../../core/theme/typography_constants.dart';
import 'glassmorphism_container.dart';

/// Accessible text form field with glassmorphism design and WCAG AA compliance
class AccessibleFormField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? semanticLabel;
  final String? semanticHint;
  final String? initialValue;
  final String? errorText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool required;
  final bool readOnly;
  final int? maxLength;
  final int maxLines;
  final int minLines;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final void Function()? onTap;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;
  final BorderRadiusGeometry? borderRadius;
  final bool showCharacterCount;
  final bool enableIMEPersonalizedLearning;

  const AccessibleFormField({
    super.key,
    required this.label,
    this.hint,
    this.semanticLabel,
    this.semanticHint,
    this.initialValue,
    this.errorText,
    this.controller,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.enabled = true,
    this.required = false,
    this.readOnly = false,
    this.maxLength,
    this.maxLines = 1,
    this.minLines = 1,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.fillColor,
    this.contentPadding,
    this.borderRadius,
    this.showCharacterCount = false,
    this.enableIMEPersonalizedLearning = true,
  });

  @override
  State<AccessibleFormField> createState() => _AccessibleFormFieldState();
}

class _AccessibleFormFieldState extends State<AccessibleFormField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_handleFocusChange);
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  void didUpdateWidget(AccessibleFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLargeText = AccessibilityUtils.isLargeTextEnabled(context);
    
    // Build semantic label
    final semanticLabel = widget.semanticLabel ?? _buildSemanticLabel();
    final semanticHint = widget.semanticHint ?? _buildSemanticHint();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with required indicator
        if (widget.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Semantics(
              label: semanticLabel,
              child: RichText(
                text: TextSpan(
                  text: widget.label,
                  style: TextStyle(
                    fontSize: isLargeText 
                        ? TypographyConstants.textBase 
                        : TypographyConstants.textSM,
                    fontWeight: TypographyConstants.medium,
                    color: theme.colorScheme.onSurface,
                  ),
                  children: widget.required
                      ? [
                          TextSpan(
                            text: ' *',
                            style: TextStyle(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          ),
        
        // Text field container
        Semantics(
          label: semanticLabel,
          hint: semanticHint,
          textField: true,
          child: GlassmorphismContainer(
            level: GlassLevel.content,
            borderRadius: widget.borderRadius ??
                BorderRadius.circular(TypographyConstants.radiusStandard),
            glassTint: _getFieldBackgroundColor(theme),
            borderColor: _getBorderColor(theme),
            borderWidth: _isFocused ? 2.0 : 1.0,
            child: TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              initialValue: widget.initialValue,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              obscureText: widget.obscureText,
              enabled: widget.enabled,
              readOnly: widget.readOnly,
              maxLength: widget.maxLength,
              maxLines: widget.maxLines,
              minLines: widget.minLines,
              inputFormatters: widget.inputFormatters,
              validator: widget.validator,
              onChanged: widget.onChanged,
              onFieldSubmitted: widget.onFieldSubmitted,
              onTap: widget.onTap,
              enableIMEPersonalizedLearning: widget.enableIMEPersonalizedLearning,
              style: TextStyle(
                fontSize: isLargeText 
                    ? TypographyConstants.textLG 
                    : TypographyConstants.textBase,
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(
                  fontSize: isLargeText 
                      ? TypographyConstants.textLG 
                      : TypographyConstants.textBase,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                prefixIcon: widget.prefixIcon,
                suffixIcon: widget.suffixIcon,
                contentPadding: widget.contentPadding ??
                    EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: isLargeText ? 20 : 16,
                    ),
                border: InputBorder.none,
                errorBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                counterText: widget.showCharacterCount ? null : '',
              ),
            ),
          ),
        ),
        
        // Error message
        if (_hasError)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Semantics(
              liveRegion: true,
              child: Text(
                widget.errorText!,
                style: TextStyle(
                  fontSize: isLargeText 
                      ? TypographyConstants.textSM 
                      : TypographyConstants.textXS,
                  color: theme.colorScheme.error,
                  fontWeight: TypographyConstants.medium,
                ),
              ),
            ),
          ),
        
        // Character count (if enabled and no error)
        if (widget.showCharacterCount && !_hasError && widget.maxLength != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${widget.controller?.text.length ?? 0}/${widget.maxLength}',
                style: TextStyle(
                  fontSize: TypographyConstants.textXS,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _buildSemanticLabel() {
    String label = widget.label;
    if (widget.required) {
      label += ', required';
    }
    if (widget.readOnly) {
      label += ', read only';
    }
    return label;
  }

  String _buildSemanticHint() {
    final List<String> hints = [];
    
    if (widget.hint != null && widget.hint!.isNotEmpty) {
      hints.add(widget.hint!);
    }
    
    if (widget.maxLength != null) {
      hints.add('Maximum ${widget.maxLength} characters');
    }
    
    if (widget.keyboardType == TextInputType.emailAddress) {
      hints.add('Email address field');
    } else if (widget.keyboardType == TextInputType.phone) {
      hints.add('Phone number field');
    } else if (widget.keyboardType == TextInputType.url) {
      hints.add('URL field');
    }
    
    if (widget.obscureText) {
      hints.add('Password field');
    }
    
    return hints.join('. ');
  }

  Color _getFieldBackgroundColor(ThemeData theme) {
    if (widget.fillColor != null) return widget.fillColor!;
    
    if (!widget.enabled) {
      return theme.colorScheme.surfaceContainerHighest.withOpacity(0.3);
    }
    
    if (_hasError) {
      return theme.colorScheme.errorContainer.withOpacity(0.1);
    }
    
    if (_isFocused) {
      return theme.colorScheme.primaryContainer.withOpacity(0.1);
    }
    
    return theme.colorScheme.surface.withOpacity(0.6);
  }

  Color _getBorderColor(ThemeData theme) {
    if (!widget.enabled) {
      return theme.colorScheme.outline.withOpacity(0.2);
    }
    
    if (_hasError) {
      return theme.colorScheme.error;
    }
    
    if (_isFocused) {
      return theme.colorScheme.primary;
    }
    
    return theme.colorScheme.outline.withOpacity(0.4);
  }
}

/// Accessible dropdown field with glassmorphism design
class AccessibleDropdownField<T> extends StatefulWidget {
  final String label;
  final String? hint;
  final String? semanticLabel;
  final String? semanticHint;
  final T? value;
  final List<AccessibleDropdownItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool enabled;
  final bool required;
  final Widget? prefixIcon;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;
  final BorderRadiusGeometry? borderRadius;

  const AccessibleDropdownField({
    super.key,
    required this.label,
    required this.items,
    this.hint,
    this.semanticLabel,
    this.semanticHint,
    this.value,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.required = false,
    this.prefixIcon,
    this.fillColor,
    this.contentPadding,
    this.borderRadius,
  });

  @override
  State<AccessibleDropdownField<T>> createState() => _AccessibleDropdownFieldState<T>();
}

class _AccessibleDropdownFieldState<T> extends State<AccessibleDropdownField<T>> {
  final bool _isFocused = false;
  final bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLargeText = AccessibilityUtils.isLargeTextEnabled(context);
    
    // Build semantic label
    final semanticLabel = widget.semanticLabel ?? _buildSemanticLabel();
    final semanticHint = widget.semanticHint ?? _buildSemanticHint();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with required indicator
        if (widget.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Semantics(
              label: semanticLabel,
              child: RichText(
                text: TextSpan(
                  text: widget.label,
                  style: TextStyle(
                    fontSize: isLargeText 
                        ? TypographyConstants.textBase 
                        : TypographyConstants.textSM,
                    fontWeight: TypographyConstants.medium,
                    color: theme.colorScheme.onSurface,
                  ),
                  children: widget.required
                      ? [
                          TextSpan(
                            text: ' *',
                            style: TextStyle(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          ),
        
        // Dropdown container
        Semantics(
          label: semanticLabel,
          hint: semanticHint,
          button: true,
          child: GlassmorphismContainer(
            level: GlassLevel.content,
            borderRadius: widget.borderRadius ??
                BorderRadius.circular(TypographyConstants.radiusStandard),
            glassTint: _getFieldBackgroundColor(theme),
            borderColor: _getBorderColor(theme),
            borderWidth: _isFocused ? 2.0 : 1.0,
            child: DropdownButtonFormField<T>(
              value: widget.value,
              items: widget.items.map((item) {
                return DropdownMenuItem<T>(
                  value: item.value,
                  child: Semantics(
                    label: item.semanticLabel ?? item.text,
                    child: Text(
                      item.text,
                      style: TextStyle(
                        fontSize: isLargeText 
                            ? TypographyConstants.textLG 
                            : TypographyConstants.textBase,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              }).toList(),
              onChanged: widget.enabled ? widget.onChanged : null,
              validator: widget.validator,
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(
                  fontSize: isLargeText 
                      ? TypographyConstants.textLG 
                      : TypographyConstants.textBase,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                prefixIcon: widget.prefixIcon,
                contentPadding: widget.contentPadding ??
                    EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: isLargeText ? 20 : 16,
                    ),
                border: InputBorder.none,
                errorBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
              ),
              dropdownColor: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              style: TextStyle(
                fontSize: isLargeText 
                    ? TypographyConstants.textLG 
                    : TypographyConstants.textBase,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _buildSemanticLabel() {
    String label = '${widget.label} dropdown';
    if (widget.required) {
      label += ', required';
    }
    return label;
  }

  String _buildSemanticHint() {
    return widget.semanticHint ?? 'Select an option from the dropdown menu';
  }

  Color _getFieldBackgroundColor(ThemeData theme) {
    if (widget.fillColor != null) return widget.fillColor!;
    
    if (!widget.enabled) {
      return theme.colorScheme.surfaceContainerHighest.withOpacity(0.3);
    }
    
    if (_hasError) {
      return theme.colorScheme.errorContainer.withOpacity(0.1);
    }
    
    if (_isFocused) {
      return theme.colorScheme.primaryContainer.withOpacity(0.1);
    }
    
    return theme.colorScheme.surface.withOpacity(0.6);
  }

  Color _getBorderColor(ThemeData theme) {
    if (!widget.enabled) {
      return theme.colorScheme.outline.withOpacity(0.2);
    }
    
    if (_hasError) {
      return theme.colorScheme.error;
    }
    
    if (_isFocused) {
      return theme.colorScheme.primary;
    }
    
    return theme.colorScheme.outline.withOpacity(0.4);
  }
}

/// Data class for dropdown items
class AccessibleDropdownItem<T> {
  final T value;
  final String text;
  final String? semanticLabel;
  final Widget? icon;

  const AccessibleDropdownItem({
    required this.value,
    required this.text,
    this.semanticLabel,
    this.icon,
  });
}