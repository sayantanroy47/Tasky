import 'package:flutter/material.dart';

/// A reusable confirmation dialog widget
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final bool isDestructive;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final IconData? icon;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.isDestructive = false,
    this.onConfirm,
    this.onCancel,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: icon != null 
        ? Icon(
            icon,
            color: isDestructive 
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.primary,
          )
        : null,
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onCancel?.call();
          },
          child: Text(cancelText),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm?.call();
          },
          style: isDestructive
            ? FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              )
            : null,
          child: Text(confirmText),
        ),
      ],
    );
  }
}

/// A dialog for displaying information with an OK button
class InfoDialog extends StatelessWidget {
  final String title;
  final String content;
  final String buttonText;
  final VoidCallback? onPressed;
  final IconData? icon;

  const InfoDialog({
    super.key,
    required this.title,
    required this.content,
    this.buttonText = 'OK',
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: icon != null 
        ? Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
          )
        : null,
      title: Text(title),
      content: Text(content),
      actions: [
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            onPressed?.call();
          },
          child: Text(buttonText),
        ),
      ],
    );
  }
}

/// A dialog for text input
class TextInputDialog extends StatefulWidget {
  final String title;
  final String? content;
  final String? hintText;
  final String? initialValue;
  final String confirmText;
  final String cancelText;
  final Function(String)? onConfirm;
  final VoidCallback? onCancel;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputType keyboardType;

  const TextInputDialog({
    super.key,
    required this.title,
    this.content,
    this.hintText,
    this.initialValue,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.validator,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<TextInputDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialValue ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.content != null) ...[
              Text(widget.content!),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: const OutlineInputBorder(),
              ),
              validator: widget.validator,
              maxLines: widget.maxLines,
              keyboardType: widget.keyboardType,
              autofocus: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.onCancel?.call();
          },
          child: Text(widget.cancelText),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop();
              widget.onConfirm?.call(_controller.text);
            }
          },
          child: Text(widget.confirmText),
        ),
      ],
    );
  }
}

/// A dialog for selecting from a list of options
class SelectionDialog<T> extends StatelessWidget {
  final String title;
  final List<T> options;
  final String Function(T) getDisplayText;
  final Function(T)? onSelected;
  final T? selectedValue;
  final bool allowMultipleSelection;

  const SelectionDialog({
    super.key,
    required this.title,
    required this.options,
    required this.getDisplayText,
    this.onSelected,
    this.selectedValue,
    this.allowMultipleSelection = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: options.length,
          itemBuilder: (context, index) {
            final option = options[index];
            final isSelected = selectedValue == option;
            
            return ListTile(
              title: Text(getDisplayText(option)),
              leading: isSelected 
                ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : const Icon(Icons.radio_button_unchecked),
              onTap: () {
                Navigator.of(context).pop();
                onSelected?.call(option);
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

/// A dialog for displaying a loading state
class LoadingDialog extends StatelessWidget {
  final String title;
  final String? message;

  const LoadingDialog({
    super.key,
    required this.title,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!),
          ],
        ],
      ),
    );
  }
}

/// Utility functions for showing dialogs
class DialogUtils {
  /// Show a confirmation dialog
  static Future<bool> showConfirmation(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
    IconData? icon,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
        icon: icon,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
    
    return result ?? false;
  }

  /// Show an info dialog
  static Future<void> showInfo(
    BuildContext context, {
    required String title,
    required String content,
    String buttonText = 'OK',
    IconData? icon,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => InfoDialog(
        title: title,
        content: content,
        buttonText: buttonText,
        icon: icon,
      ),
    );
  }

  /// Show a text input dialog
  static Future<String?> showTextInput(
    BuildContext context, {
    required String title,
    String? content,
    String? hintText,
    String? initialValue,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) async {
    return await showDialog<String>(
      context: context,
      builder: (context) => TextInputDialog(
        title: title,
        content: content,
        hintText: hintText,
        initialValue: initialValue,
        confirmText: confirmText,
        cancelText: cancelText,
        validator: validator,
        maxLines: maxLines,
        keyboardType: keyboardType,
        onConfirm: (value) => Navigator.of(context).pop(value),
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Show a selection dialog
  static Future<T?> showSelection<T>(
    BuildContext context, {
    required String title,
    required List<T> options,
    required String Function(T) getDisplayText,
    T? selectedValue,
  }) async {
    return await showDialog<T>(
      context: context,
      builder: (context) => SelectionDialog<T>(
        title: title,
        options: options,
        getDisplayText: getDisplayText,
        selectedValue: selectedValue,
        onSelected: (value) => Navigator.of(context).pop(value),
      ),
    );
  }

  /// Show a loading dialog
  static void showLoading(
    BuildContext context, {
    required String title,
    String? message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingDialog(
        title: title,
        message: message,
      ),
    );
  }

  /// Hide the currently shown dialog
  static void hideDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
}