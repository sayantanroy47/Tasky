import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import '../../core/errors/failures.dart';
import 'glassmorphism_container.dart';

/// Utility class for accessibility functions
class AccessibilityUtils {
  static bool isLargeTextEnabled(BuildContext context) {
    return MediaQuery.of(context).textScaler.scale(1.0) > 1.3;
  }

  static bool shouldReduceMotion(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  static void announceToScreenReader(BuildContext context, String message) {
    // Implementation for screen reader announcements
    SemanticsService.announce(message, TextDirection.ltr);
  }
}

/// Enhanced error dialog with glassmorphism design and accessibility features
class EnhancedErrorDialog extends StatelessWidget {
  final Failure error;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final String? customTitle;
  final String? customMessage;

  const EnhancedErrorDialog({
    super.key,
    required this.error,
    this.onRetry,
    this.onDismiss,
    this.customTitle,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLargeText = AccessibilityUtils.isLargeTextEnabled(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: GlassmorphismContainer(
          blur: 20,
          opacity: 0.1,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon and title
                _buildHeader(context, theme, isLargeText),
                
                const SizedBox(height: 16),
                
                // Error message
                _buildErrorMessage(theme, isLargeText),
                
                const SizedBox(height: 24),
                
                // Action buttons
                _buildActionButtons(context, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isLargeText) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.error_outline,
            color: theme.colorScheme.onErrorContainer,
            size: isLargeText ? 28 : 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            customTitle ?? 'Error Occurred',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontSize: isLargeText ? 22 : null,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
          tooltip: 'Close error dialog',
        ),
      ],
    );
  }

  Widget _buildErrorMessage(ThemeData theme, bool isLargeText) {
    return Semantics(
      label: 'Error message',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              customMessage ?? error.message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontSize: isLargeText ? 16 : null,
              ),
            ),
            if (error is NetworkFailure) ...[
              const SizedBox(height: 8),
              Text(
                'Please check your internet connection and try again.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: isLargeText ? 14 : null,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    final List<Widget> buttons = [];

    // Retry button
    if (onRetry != null) {
      buttons.add(
        _AccessibleButton(
          label: 'Retry',
          icon: Icons.refresh,
          onPressed: () {
            Navigator.of(context).pop();
            onRetry?.call();
          },
          isPrimary: true,
          semanticHint: 'Retry the failed operation',
        ),
      );
    }

    // Copy error button
    buttons.add(
      _AccessibleButton(
        label: 'Copy Error',
        icon: Icons.copy,
        onPressed: () => _copyErrorToClipboard(context),
        isPrimary: false,
        semanticHint: 'Copy error details to clipboard for support',
      ),
    );

    // Dismiss button
    buttons.add(
      _AccessibleButton(
        label: 'Dismiss',
        icon: Icons.close,
        onPressed: () {
          Navigator.of(context).pop();
          onDismiss?.call();
        },
        isPrimary: false,
        semanticHint: 'Close this error dialog',
      ),
    );

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: buttons,
    );
  }

  void _copyErrorToClipboard(BuildContext context) {
    final errorText = '''
Error: ${error.message}
Type: ${error.runtimeType}
Time: ${DateTime.now().toIso8601String()}
''';

    Clipboard.setData(ClipboardData(text: errorText));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Error details copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );

    AccessibilityUtils.announceToScreenReader(
      context, 
      'Error details copied to clipboard',
    );
  }
}

/// Critical error screen for unrecoverable errors
class CriticalErrorScreen extends StatelessWidget {
  final Failure error;
  final VoidCallback? onRestart;
  final String? customTitle;
  final String? customMessage;

  const CriticalErrorScreen({
    super.key,
    required this.error,
    this.onRestart,
    this.customTitle,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLargeText = AccessibilityUtils.isLargeTextEnabled(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: GlassmorphismContainer(
            blur: 30,
            opacity: 0.15,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Critical error icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error,
                      size: isLargeText ? 64 : 48,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Title
                  Text(
                    customTitle ?? 'Critical Error',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: isLargeText ? 32 : null,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Error message
                  Text(
                    customMessage ?? 'The application has encountered a critical error and needs to restart.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: isLargeText ? 18 : null,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Recovery actions
                  _buildRecoveryActions(context, theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecoveryActions(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AccessibleButton(
          label: 'Restart App',
          icon: Icons.refresh,
          onPressed: onRestart ?? () => _restartApp(context),
          isPrimary: true,
          semanticHint: 'Restart the application to recover from error',
        ),
        const SizedBox(height: 12),
        _AccessibleButton(
          label: 'Report Issue',
          icon: Icons.bug_report,
          onPressed: () => _reportIssue(context),
          isPrimary: false,
          semanticHint: 'Report this issue to the development team',
        ),
        const SizedBox(height: 12),
        _AccessibleButton(
          label: 'Copy Error Details',
          icon: Icons.copy,
          onPressed: () => _copyErrorDetails(context),
          isPrimary: false,
          semanticHint: 'Copy error details to clipboard for support',
        ),
      ],
    );
  }

  void _restartApp(BuildContext context) {
    // Implementation would depend on app architecture
    // For now, we'll just close all dialogs and reset navigation
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  void _reportIssue(BuildContext context) {
    // Implementation would open bug reporting interface
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bug reporting interface would open here'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _copyErrorDetails(BuildContext context) {
    final errorText = '''
CRITICAL ERROR REPORT
=====================
Error: ${error.message}
Type: ${error.runtimeType}
Time: ${DateTime.now().toIso8601String()}
Device: ${Theme.of(context).platform}
''';

    Clipboard.setData(ClipboardData(text: errorText));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Critical error details copied to clipboard'),
        duration: Duration(seconds: 3),
      ),
    );

    AccessibilityUtils.announceToScreenReader(
      context, 
      'Critical error details copied to clipboard',
    );
  }
}

/// Simple error widget for inline error states
class SimpleErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final bool compact;

  const SimpleErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLargeText = AccessibilityUtils.isLargeTextEnabled(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? 16 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: compact ? (isLargeText ? 40 : 32) : (isLargeText ? 64 : 48),
              color: theme.colorScheme.error,
            ),
            SizedBox(height: compact ? 8 : 16),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontSize: isLargeText ? 16 : null,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: compact ? 12 : 16),
              _AccessibleButton(
                label: 'Retry',
                icon: Icons.refresh,
                onPressed: onRetry!,
                isPrimary: true,
                semanticHint: 'Retry the failed operation',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Loading error widget with animation
class LoadingErrorWidget extends StatefulWidget {
  final String message;
  final VoidCallback? onRetry;

  const LoadingErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  State<LoadingErrorWidget> createState() => _LoadingErrorWidgetState();
}

class _LoadingErrorWidgetState extends State<LoadingErrorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLargeText = AccessibilityUtils.isLargeTextEnabled(context);
    final shouldReduceMotion = AccessibilityUtils.shouldReduceMotion(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            shouldReduceMotion
                ? Icon(
                    Icons.error_outline,
                    size: isLargeText ? 64 : 48,
                    color: theme.colorScheme.error,
                  )
                : AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _animation.value * 2 * 3.14159,
                        child: Icon(
                          Icons.refresh,
                          size: isLargeText ? 64 : 48,
                          color: theme.colorScheme.error,
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 16),
            Text(
              widget.message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontSize: isLargeText ? 16 : null,
              ),
              textAlign: TextAlign.center,
            ),
            if (widget.onRetry != null) ...[
              const SizedBox(height: 16),
              _AccessibleButton(
                label: 'Retry',
                icon: Icons.refresh,
                onPressed: widget.onRetry!,
                isPrimary: true,
                semanticHint: 'Retry the failed operation',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Accessible button widget used throughout error widgets
class _AccessibleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;
  final String? semanticHint;

  const _AccessibleButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isPrimary = false,
    this.semanticHint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Semantics(
      button: true,
      hint: semanticHint,
      child: isPrimary
          ? ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(label),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(120, 48),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
            )
          : OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(label),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(120, 48),
                foregroundColor: theme.colorScheme.primary,
              ),
            ),
    );
  }
}