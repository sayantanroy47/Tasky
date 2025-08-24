import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/design_system/design_tokens.dart';
import '../../core/theme/typography_constants.dart';
import 'glassmorphism_container.dart';
import 'standardized_text.dart';
import 'theme_aware_dialog_components.dart';

/// Standardized page-level dialogs that eliminate dialog chaos
/// 
/// Eliminates Page-level Dialog Inconsistency by:
/// - Replacing raw AlertDialog with consistent themed dialogs
/// - Providing unified confirmation, info, and action dialogs
/// - Maintaining visual hierarchy across all page interactions
/// - Using proper glassmorphism and Material 3 theming
class StandardizedPageDialogs {
  /// Show confirmation dialog with consistent styling
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    IconData? icon,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => StandardizedConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        icon: icon,
        isDestructive: isDestructive,
      ),
    );
  }

  /// Show information dialog with consistent styling
  static Future<void> showInfo({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    IconData? icon,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => StandardizedInfoDialog(
        title: title,
        message: message,
        buttonText: buttonText,
        icon: icon,
      ),
    );
  }

  /// Show error dialog with consistent styling
  static Future<void> showError({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => StandardizedInfoDialog(
        title: title,
        message: message,
        buttonText: buttonText,
        icon: PhosphorIcons.warning(),
        isError: true,
      ),
    );
  }

  /// Show loading dialog with consistent styling
  static void showLoading({
    required BuildContext context,
    String message = 'Loading...',
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StandardizedLoadingDialog(
        message: message,
      ),
    );
  }

  /// Dismiss loading dialog
  static void hideLoading(BuildContext context) {
    Navigator.of(context).pop();
  }
}

/// Standardized confirmation dialog
class StandardizedConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final IconData? icon;
  final bool isDestructive;

  const StandardizedConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    this.icon,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassmorphismContainer(
        level: GlassLevel.floating,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with icon and title
            if (icon != null) ...[
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: (isDestructive 
                    ? theme.colorScheme.error 
                    : theme.colorScheme.primary).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isDestructive 
                    ? theme.colorScheme.error 
                    : theme.colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
            ],
            
            // Title
            StandardizedTextVariants.cardTitle(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            
            const SizedBox(height: SpacingTokens.sm),
            
            // Message
            StandardizedTextVariants.body(
              message,
              textAlign: TextAlign.center,
              maxLines: 4,
            ),
            
            const SizedBox(height: SpacingTokens.lg),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: ThemeAwareButton(
                    label: cancelText,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: isDestructive
                    ? ThemeAwareButton(
                        label: confirmText,
                        onPressed: () => Navigator.of(context).pop(true),
                      )
                    : ThemeAwareButton(
                        label: confirmText,
                        onPressed: () => Navigator.of(context).pop(true),
                        isPrimary: true,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Standardized information dialog
class StandardizedInfoDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final IconData? icon;
  final bool isError;

  const StandardizedInfoDialog({
    super.key,
    required this.title,
    required this.message,
    required this.buttonText,
    this.icon,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassmorphismContainer(
        level: GlassLevel.floating,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with icon and title
            if (icon != null) ...[
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: (isError 
                    ? theme.colorScheme.error 
                    : theme.colorScheme.primary).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isError 
                    ? theme.colorScheme.error 
                    : theme.colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
            ],
            
            // Title
            StandardizedTextVariants.cardTitle(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            
            const SizedBox(height: SpacingTokens.sm),
            
            // Message
            StandardizedTextVariants.body(
              message,
              textAlign: TextAlign.center,
              maxLines: 6,
            ),
            
            const SizedBox(height: SpacingTokens.lg),
            
            // Action
            SizedBox(
              width: double.infinity,
              child: ThemeAwareButton(
                label: buttonText,
                onPressed: () => Navigator.of(context).pop(),
                isPrimary: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Standardized loading dialog
class StandardizedLoadingDialog extends StatelessWidget {
  final String message;

  const StandardizedLoadingDialog({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassmorphismContainer(
        level: GlassLevel.floating,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
        padding: const EdgeInsets.all(SpacingTokens.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Loading indicator
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
            
            const SizedBox(height: SpacingTokens.lg),
            
            // Message
            StandardizedTextVariants.body(
              message,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Extensions for common dialog patterns
extension StandardizedPageDialogExtensions on BuildContext {
  /// Show confirmation dialog
  Future<bool?> showConfirmationDialog({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    IconData? icon,
    bool isDestructive = false,
  }) {
    return StandardizedPageDialogs.showConfirmation(
      context: this,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      icon: icon,
      isDestructive: isDestructive,
    );
  }

  /// Show info dialog
  Future<void> showInfoDialog({
    required String title,
    required String message,
    String buttonText = 'OK',
    IconData? icon,
  }) {
    return StandardizedPageDialogs.showInfo(
      context: this,
      title: title,
      message: message,
      buttonText: buttonText,
      icon: icon,
    );
  }

  /// Show error dialog
  Future<void> showErrorDialog({
    required String title,
    required String message,
    String buttonText = 'OK',
  }) {
    return StandardizedPageDialogs.showError(
      context: this,
      title: title,
      message: message,
      buttonText: buttonText,
    );
  }
}