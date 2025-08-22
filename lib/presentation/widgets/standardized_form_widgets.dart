import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/accessibility/accessibility_constants.dart';
import '../../core/accessibility/touch_target_validator.dart';
import '../../core/theme/typography_constants.dart';
import '../../core/validation/form_validators.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';


/// Standardized form field with consistent validation and accessibility
class StandardizedFormField extends ConsumerStatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final TextEditingController? controller;
  final String? initialValue;
  final FieldValidator? validator;
  final bool isRequired;
  final bool isPassword;
  final bool isReadOnly;
  final bool isMultiline;
  final int? maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final String? semanticLabel;
  final bool showValidationIcon;
  final bool validateOnChange;
  final bool validateOnFocusLost;
  final Map<String, dynamic> validationContext;

  const StandardizedFormField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.controller,
    this.initialValue,
    this.validator,
    this.isRequired = false,
    this.isPassword = false,
    this.isReadOnly = false,
    this.isMultiline = false,
    this.maxLines,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.semanticLabel,
    this.showValidationIcon = true,
    this.validateOnChange = false,
    this.validateOnFocusLost = true,
    this.validationContext = const {},
  });

  @override
  ConsumerState<StandardizedFormField> createState() => _StandardizedFormFieldState();
}

class _StandardizedFormFieldState extends ConsumerState<StandardizedFormField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  ValidationResult? _validationResult;
  bool _hasBeenFocused = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();
    
    _focusNode.addListener(_onFocusChange);
    
    if (widget.validateOnChange) {
      _controller.addListener(_validateOnChange);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _hasBeenFocused = true;
      if (widget.validateOnFocusLost) {
        _validateField();
      }
    }
  }

  void _validateOnChange() {
    if (_hasBeenFocused || widget.validateOnChange) {
      _validateField();
    }
  }

  void _validateField() {
    if (widget.validator != null) {
      final result = widget.validator!.validate(_controller.text, widget.validationContext);
      setState(() {
        _validationResult = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLargeText = AccessibilityUtils.isLargeTextEnabled(context);
    final shouldUseHighContrast = AccessibilityUtils.shouldUseHighContrast(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: widget.label!,
                    style: TextStyle(
                      fontSize: isLargeText 
                          ? TypographyConstants.textBase 
                          : TypographyConstants.textSM,
                      fontWeight: TypographyConstants.medium,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (widget.isRequired)
                    TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontWeight: TypographyConstants.medium,
                      ),
                    ),
                ],
              ),
            ),
          ),

        // Text field
        Semantics(
          label: widget.semanticLabel ?? widget.label,
          hint: widget.hint,
          textField: true,
          child: TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            validator: widget.validator != null
                ? (value) {
                    final result = widget.validator!.validate(value, widget.validationContext);
                    return result.isValid ? null : result.errorMessage;
                  }
                : null,
            obscureText: widget.isPassword && _obscurePassword,
            readOnly: widget.isReadOnly,
            autofocus: widget.autofocus,
            maxLines: widget.isMultiline ? (widget.maxLines ?? 4) : 1,
            maxLength: widget.maxLength,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            textCapitalization: widget.textCapitalization,
            textInputAction: widget.textInputAction,
            style: TextStyle(
              fontSize: isLargeText 
                  ? TypographyConstants.textBase 
                  : TypographyConstants.textSM,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              helperText: widget.helperText,
              helperMaxLines: 2,
              counterText: widget.maxLength != null ? null : '',
              
              // Prefix and suffix icons
              prefixIcon: widget.prefixIcon,
              suffixIcon: _buildSuffixIcon(theme),
              
              // Borders
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline,
                  width: shouldUseHighContrast ? 2.0 : 1.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                borderSide: BorderSide(
                  color: _getBorderColor(theme, shouldUseHighContrast),
                  width: shouldUseHighContrast ? 2.0 : 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: shouldUseHighContrast ? 3.0 : 2.0,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                borderSide: BorderSide(
                  color: theme.colorScheme.error,
                  width: shouldUseHighContrast ? 3.0 : 2.0,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                borderSide: BorderSide(
                  color: theme.colorScheme.error,
                  width: shouldUseHighContrast ? 3.0 : 2.0,
                ),
              ),
              
              // Fill color
              filled: true,
              fillColor: shouldUseHighContrast 
                  ? theme.colorScheme.surface
                  : theme.colorScheme.surface.withValues(alpha: 0.5),
              
              // Content padding for touch targets
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: isLargeText ? 20 : 16,
              ),
            ),
            onTap: widget.onTap,
            onChanged: (value) {
              widget.onChanged?.call(value);
              if (widget.validateOnChange) {
                _validateField();
              }
            },
            onFieldSubmitted: widget.onSubmitted,
          ),
        ),

        // Validation message
        if (_validationResult?.hasMessage == true)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _buildValidationMessage(theme, isLargeText),
          ),
      ],
    );
  }

  Widget? _buildSuffixIcon(ThemeData theme) {
    final icons = <Widget>[];

    // Password visibility toggle
    if (widget.isPassword) {
      icons.add(
        IconButton(
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
          icon: Icon(
            _obscurePassword ? PhosphorIcons.eyeSlash() : PhosphorIcons.eye(),
            color: theme.colorScheme.onSurfaceVariant,
            semanticLabel: _obscurePassword ? 'Show password' : 'Hide password',
          ),
        ),
      );
    }

    // Validation icon
    if (widget.showValidationIcon && _validationResult != null) {
      if (!_validationResult!.isValid) {
        icons.add(
          Icon(
            PhosphorIcons.warningCircle(),
            color: theme.colorScheme.error,
            semanticLabel: 'Error',
          ),
        );
      } else if (_validationResult!.hasWarning) {
        icons.add(
          Icon(
            PhosphorIcons.warningCircle(),
            color: theme.colorScheme.secondary,
            semanticLabel: 'Warning',
          ),
        );
      } else if (_validationResult!.hasSuccess) {
        icons.add(
          Icon(
            PhosphorIcons.checkCircle(),
            color: theme.colorScheme.primary,
            semanticLabel: 'Valid',
          ),
        );
      }
    }

    // Custom suffix icon
    if (widget.suffixIcon != null) {
      icons.add(widget.suffixIcon!);
    }

    if (icons.isEmpty) return null;
    
    if (icons.length == 1) return icons.first;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: icons,
    );
  }

  Color _getBorderColor(ThemeData theme, bool shouldUseHighContrast) {
    if (_validationResult != null) {
      if (!_validationResult!.isValid) {
        return theme.colorScheme.error;
      }
      if (_validationResult!.hasWarning) {
        return theme.colorScheme.secondary;
      }
    }
    
    return shouldUseHighContrast 
        ? theme.colorScheme.outline
        : theme.colorScheme.outline.withValues(alpha: 0.6);
  }

  Widget _buildValidationMessage(ThemeData theme, bool isLargeText) {
    final result = _validationResult!;
    Color messageColor;
    IconData messageIcon;

    if (!result.isValid) {
      messageColor = theme.colorScheme.error;
      messageIcon = PhosphorIcons.warningCircle();
    } else if (result.hasWarning) {
      messageColor = theme.colorScheme.secondary;
      messageIcon = PhosphorIcons.warningCircle();
    } else {
      messageColor = theme.colorScheme.primary;
      messageIcon = PhosphorIcons.checkCircle();
    }

    return Semantics(
      liveRegion: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            messageIcon,
            size: isLargeText ? 20 : 16,
            color: messageColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              result.displayMessage!,
              style: TextStyle(
                fontSize: isLargeText 
                    ? TypographyConstants.textSM 
                    : TypographyConstants.textXS,
                color: messageColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Standardized dropdown field
class StandardizedDropdownField<T> extends ConsumerWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final Widget Function(T)? itemBuilder;
  final ValueChanged<T?>? onChanged;
  final FieldValidator? validator;
  final bool isRequired;
  final String? semanticLabel;

  const StandardizedDropdownField({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    required this.itemLabel,
    this.itemBuilder,
    this.onChanged,
    this.validator,
    this.isRequired = false,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isLargeText = AccessibilityUtils.isLargeTextEnabled(context);
    final shouldUseHighContrast = AccessibilityUtils.shouldUseHighContrast(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: label!,
                    style: TextStyle(
                      fontSize: isLargeText 
                          ? TypographyConstants.textBase 
                          : TypographyConstants.textSM,
                      fontWeight: TypographyConstants.medium,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (isRequired)
                    TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontWeight: TypographyConstants.medium,
                      ),
                    ),
                ],
              ),
            ),
          ),

        // Dropdown
        Semantics(
          label: semanticLabel ?? label,
          hint: hint,
          child: DropdownButtonFormField<T>(
            initialValue: value,
            items: items.map((item) {
              return DropdownMenuItem<T>(
                value: item,
                child: itemBuilder?.call(item) ?? Text(
                  itemLabel(item),
                  style: TextStyle(
                    fontSize: isLargeText 
                        ? TypographyConstants.textBase 
                        : TypographyConstants.textSM,
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            validator: validator != null
                ? (value) {
                    final result = validator!.validate(value?.toString(), {});
                    return result.isValid ? null : result.errorMessage;
                  }
                : null,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: shouldUseHighContrast 
                  ? theme.colorScheme.surface
                  : theme.colorScheme.surface.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline,
                  width: shouldUseHighContrast ? 2.0 : 1.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                borderSide: BorderSide(
                  color: shouldUseHighContrast 
                      ? theme.colorScheme.outline
                      : theme.colorScheme.outline.withValues(alpha: 0.6),
                  width: shouldUseHighContrast ? 2.0 : 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: shouldUseHighContrast ? 3.0 : 2.0,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: isLargeText ? 20 : 16,
              ),
            ),
            style: TextStyle(
              fontSize: isLargeText 
                  ? TypographyConstants.textBase 
                  : TypographyConstants.textSM,
              color: theme.colorScheme.onSurface,
            ),
            dropdownColor: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            menuMaxHeight: 300,
          ),
        ),
      ],
    );
  }
}

/// Standardized checkbox field
class StandardizedCheckboxField extends ConsumerWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final FieldValidator? validator;
  final String? semanticLabel;
  final String? subtitle;

  const StandardizedCheckboxField({
    super.key,
    required this.label,
    required this.value,
    this.onChanged,
    this.validator,
    this.semanticLabel,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isLargeText = AccessibilityUtils.isLargeTextEnabled(context);
    final shouldUseHighContrast = AccessibilityUtils.shouldUseHighContrast(context);

    return Semantics(
      label: semanticLabel ?? label,
      checked: value,
      child: InkWell(
        onTap: onChanged != null ? () => onChanged!(!value) : null,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: AccessibilityConstants.minTouchTarget,
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: [
              Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: shouldUseHighContrast 
                    ? AccessibilityConstants.highContrastPrimary
                    : theme.colorScheme.primary,
                checkColor: shouldUseHighContrast 
                    ? Colors.black
                    : theme.colorScheme.onPrimary,
                side: BorderSide(
                  color: shouldUseHighContrast 
                      ? theme.colorScheme.outline
                      : theme.colorScheme.outline.withValues(alpha: 0.6),
                  width: shouldUseHighContrast ? 2.0 : 1.0,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: isLargeText 
                            ? TypographyConstants.textBase 
                            : TypographyConstants.textSM,
                        fontWeight: TypographyConstants.medium,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: isLargeText 
                              ? TypographyConstants.textSM 
                              : TypographyConstants.textXS,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Standardized radio group field
class StandardizedRadioField<T> extends ConsumerWidget {
  final String? label;
  final T? value;
  final List<T> options;
  final String Function(T) optionLabel;
  final ValueChanged<T?>? onChanged;
  final FieldValidator? validator;
  final bool isRequired;
  final String? semanticLabel;
  final Axis direction;

  const StandardizedRadioField({
    super.key,
    this.label,
    this.value,
    required this.options,
    required this.optionLabel,
    this.onChanged,
    this.validator,
    this.isRequired = false,
    this.semanticLabel,
    this.direction = Axis.vertical,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isLargeText = AccessibilityUtils.isLargeTextEnabled(context);
    final shouldUseHighContrast = AccessibilityUtils.shouldUseHighContrast(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: label!,
                    style: TextStyle(
                      fontSize: isLargeText 
                          ? TypographyConstants.textBase 
                          : TypographyConstants.textSM,
                      fontWeight: TypographyConstants.medium,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (isRequired)
                    TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontWeight: TypographyConstants.medium,
                      ),
                    ),
                ],
              ),
            ),
          ),

        // Radio options
        Semantics(
          label: semanticLabel ?? label,
          child: direction == Axis.vertical
              ? Column(
                  children: options.map((option) => _buildRadioOption(
                    context, theme, option, isLargeText, shouldUseHighContrast,
                  )).toList(),
                )
              : Wrap(
                  children: options.map((option) => _buildRadioOption(
                    context, theme, option, isLargeText, shouldUseHighContrast,
                  )).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildRadioOption(
    BuildContext context,
    ThemeData theme,
    T option,
    bool isLargeText,
    bool shouldUseHighContrast,
  ) {
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: value == option,
      child: InkWell(
        onTap: onChanged != null ? () => onChanged!(option) : null,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: AccessibilityConstants.minTouchTarget,
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            mainAxisSize: direction == Axis.horizontal ? MainAxisSize.min : MainAxisSize.max,
            children: [
              AccessibleRadio<T>(
                value: option,
                groupValue: value,
                onChanged: onChanged,
                semanticLabel: 'Radio option: ${optionLabel(option)}',
              ),
              const SizedBox(width: 8),
              Text(
                optionLabel(option),
                style: TextStyle(
                  fontSize: isLargeText 
                      ? TypographyConstants.textBase 
                      : TypographyConstants.textSM,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

