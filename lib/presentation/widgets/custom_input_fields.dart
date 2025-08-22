import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Custom text field with consistent styling
class CustomTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.focusNode,
    this.validator,
  });
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      onTap: onTap,
      readOnly: readOnly,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      enabled: enabled,
      focusNode: focusNode,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        errorText: errorText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

/// Search field with search icon and clear button
class SearchField extends StatefulWidget {
  final String? hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  const SearchField({
    super.key,
    this.hint,
    this.onChanged,
    this.onClear,
    this.controller,
    this.focusNode,
  });
  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _showClearButton = false;
  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    
    _controller.addListener(_onTextChanged);
    _showClearButton = _controller.text.isNotEmpty;
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

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _showClearButton) {
      setState(() {
        _showClearButton = hasText;
      });
    }
    widget.onChanged?.call(_controller.text);
  }

  void _onClear() {
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: InputDecoration(
        hintText: widget.hint ?? 'Search...',
        prefixIcon: Icon(PhosphorIcons.magnifyingGlass()),
        suffixIcon: _showClearButton
            ? IconButton(
                icon: Icon(PhosphorIcons.x()),
                onPressed: _onClear,
              )
            : null,
      ),
    );
  }
}

/// Date picker field
class DatePickerField extends StatelessWidget {
  final String? label;
  final DateTime? selectedDate;
  final ValueChanged<DateTime?>? onDateSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? errorText;
  final bool enabled;

  const DatePickerField({
    super.key,
    this.label,
    this.selectedDate,
    this.onDateSelected,
    this.firstDate,
    this.lastDate,
    this.errorText,
    this.enabled = true,
  });
  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: label,
      hint: 'Select date',
      errorText: errorText,
      readOnly: true,
      enabled: enabled,
      controller: TextEditingController(
        text: selectedDate != null 
          ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
          : '',
      ),
      suffixIcon: Icon(PhosphorIcons.calendar()),
      onTap: enabled ? () => _selectDate(context) : null,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
    );
    
    if (picked != null && picked != selectedDate) {
      onDateSelected?.call(picked);
    }
  }
}

/// Time picker field
class TimePickerField extends StatelessWidget {
  final String? label;
  final TimeOfDay? selectedTime;
  final ValueChanged<TimeOfDay?>? onTimeSelected;
  final String? errorText;
  final bool enabled;

  const TimePickerField({
    super.key,
    this.label,
    this.selectedTime,
    this.onTimeSelected,
    this.errorText,
    this.enabled = true,
  });
  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: label,
      hint: 'Select time',
      errorText: errorText,
      readOnly: true,
      enabled: enabled,
      controller: TextEditingController(
        text: selectedTime != null 
          ? selectedTime!.format(context)
          : '',
      ),
      suffixIcon: Icon(PhosphorIcons.clock()),
      onTap: enabled ? () => _selectTime(context) : null,
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    
    if (picked != null && picked != selectedTime) {
      onTimeSelected?.call(picked);
    }
  }
}

/// Dropdown field with consistent styling
class CustomDropdownField<T> extends StatelessWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? errorText;
  final bool enabled;

  const CustomDropdownField({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.errorText,
    this.enabled = true,
  });
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
      ),
    );
  }
}

/// Tag input field for adding multiple tags
class TagInputField extends StatefulWidget {
  final List<String> tags;
  final ValueChanged<List<String>>? onTagsChanged;
  final String? label;
  final String? hint;
  final int? maxTags;

  const TagInputField({
    super.key,
    this.tags = const [],
    this.onTagsChanged,
    this.label,
    this.hint,
    this.maxTags,
  });
  @override
  State<TagInputField> createState() => _TagInputFieldState();
}

class _TagInputFieldState extends State<TagInputField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    final trimmedTag = tag.trim();
    if (trimmedTag.isNotEmpty && 
        !widget.tags.contains(trimmedTag) &&
        (widget.maxTags == null || widget.tags.length < widget.maxTags!)) {
      final newTags = [...widget.tags, trimmedTag];
      widget.onTagsChanged?.call(newTags);
      _controller.clear();
    }
  }

  void _removeTag(String tag) {
    final newTags = widget.tags.where((t) => t != tag).toList();
    widget.onTagsChanged?.call(newTags);
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 8),
        ],
        
        // Tags display
        if (widget.tags.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: widget.tags.map((tag) => Chip(
              label: Text(tag),
              deleteIcon: Icon(PhosphorIcons.x(), size: 18),
              onDeleted: () => _removeTag(tag),
            )).toList(),
          ),
          const SizedBox(height: 8),
        ],
        
        // Input field
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: widget.hint ?? 'Add tag and press Enter',
            suffixIcon: IconButton(
              icon: Icon(PhosphorIcons.plus()),
              onPressed: () => _addTag(_controller.text),
            ),
          ),
          onSubmitted: _addTag,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }
}


