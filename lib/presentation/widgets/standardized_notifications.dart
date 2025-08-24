import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/design_system/design_tokens.dart';
import '../../core/theme/typography_constants.dart';
import 'glassmorphism_container.dart';
import 'standardized_animations.dart';
import 'standardized_colors.dart';
import 'standardized_icons.dart';
import 'standardized_text.dart';

/// Standardized notification system that eliminates notification chaos
/// 
/// Eliminates Notification Pattern Inconsistency by:
/// - Providing centralized notification management and theming
/// - Enforcing consistent notification styling and behavior
/// - Supporting semantic notification types (success, warning, error, info)
/// - Preventing direct ScaffoldMessenger.of(context).show calls
/// - Centralizing notification analytics and user feedback patterns
class StandardizedNotifications {
  static final _notificationHistory = <NotificationEvent>[];
  
  /// Show success notification
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSuccess(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onAction,
    String? actionLabel,
    bool showCloseButton = false,
    bool hapticFeedback = true,
  }) {
    if (hapticFeedback) {
      HapticFeedback.lightImpact();
    }
    
    _trackNotification(NotificationType.success, message, title);
    
    return _showNotification(
      context,
      type: NotificationType.success,
      message: message,
      title: title,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
      showCloseButton: showCloseButton,
    );
  }
  
  /// Show error notification
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showError(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 6),
    VoidCallback? onAction,
    String? actionLabel,
    bool showCloseButton = true,
    bool hapticFeedback = true,
  }) {
    if (hapticFeedback) {
      HapticFeedback.heavyImpact();
    }
    
    _trackNotification(NotificationType.error, message, title);
    
    return _showNotification(
      context,
      type: NotificationType.error,
      message: message,
      title: title,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
      showCloseButton: showCloseButton,
    );
  }
  
  /// Show warning notification
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showWarning(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 5),
    VoidCallback? onAction,
    String? actionLabel,
    bool showCloseButton = true,
    bool hapticFeedback = true,
  }) {
    if (hapticFeedback) {
      HapticFeedback.mediumImpact();
    }
    
    _trackNotification(NotificationType.warning, message, title);
    
    return _showNotification(
      context,
      type: NotificationType.warning,
      message: message,
      title: title,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
      showCloseButton: showCloseButton,
    );
  }
  
  /// Show info notification
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showInfo(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onAction,
    String? actionLabel,
    bool showCloseButton = false,
    bool hapticFeedback = false,
  }) {
    if (hapticFeedback) {
      HapticFeedback.selectionClick();
    }
    
    _trackNotification(NotificationType.info, message, title);
    
    return _showNotification(
      context,
      type: NotificationType.info,
      message: message,
      title: title,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
      showCloseButton: showCloseButton,
    );
  }
  
  /// Show loading notification
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showLoading(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 30),
    bool showCloseButton = false,
  }) {
    _trackNotification(NotificationType.loading, message, title);
    
    return _showNotification(
      context,
      type: NotificationType.loading,
      message: message,
      title: title,
      duration: duration,
      showCloseButton: showCloseButton,
      showProgress: true,
    );
  }
  
  /// Show progress notification with percentage
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showProgress(
    BuildContext context, {
    required String message,
    String? title,
    required double progress, // 0.0 to 1.0
    Duration duration = const Duration(seconds: 30),
    bool showCloseButton = false,
  }) {
    _trackNotification(NotificationType.progress, message, title);
    
    return _showNotification(
      context,
      type: NotificationType.progress,
      message: message,
      title: title,
      duration: duration,
      showCloseButton: showCloseButton,
      showProgress: true,
      progress: progress,
    );
  }
  
  /// Semantic notification shortcuts
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> taskCreated(
    BuildContext context, {
    String message = 'Task created successfully',
    VoidCallback? onViewTask,
  }) {
    return showSuccess(
      context,
      message: message,
      onAction: onViewTask,
      actionLabel: 'View',
    );
  }
  
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> taskCompleted(
    BuildContext context, {
    String message = 'Task completed!',
    VoidCallback? onUndo,
  }) {
    return showSuccess(
      context,
      message: message,
      onAction: onUndo,
      actionLabel: 'Undo',
    );
  }
  
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> taskDeleted(
    BuildContext context, {
    String message = 'Task deleted',
    VoidCallback? onUndo,
  }) {
    return showWarning(
      context,
      message: message,
      onAction: onUndo,
      actionLabel: 'Undo',
    );
  }
  
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> networkError(
    BuildContext context, {
    String message = 'Network connection failed',
    VoidCallback? onRetry,
  }) {
    return showError(
      context,
      message: message,
      onAction: onRetry,
      actionLabel: 'Retry',
    );
  }
  
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> syncInProgress(
    BuildContext context, {
    String message = 'Syncing data...',
  }) {
    return showLoading(
      context,
      message: message,
    );
  }
  
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> dataExported(
    BuildContext context, {
    String message = 'Data exported successfully',
    VoidCallback? onOpen,
  }) {
    return showSuccess(
      context,
      message: message,
      onAction: onOpen,
      actionLabel: 'Open',
    );
  }
  
  /// Core notification display method
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _showNotification(
    BuildContext context, {
    required NotificationType type,
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onAction,
    String? actionLabel,
    bool showCloseButton = false,
    bool showProgress = false,
    double? progress,
  }) {
    final colors = StandardizedColors(Theme.of(context));
    
    final snackBar = SnackBar(
      content: StandardizedNotificationContent(
        type: type,
        title: title,
        message: message,
        showProgress: showProgress,
        progress: progress,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(SpacingTokens.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      ),
      action: (onAction != null && actionLabel != null) 
          ? SnackBarAction(
              label: actionLabel,
              textColor: _getActionColor(type, colors),
              onPressed: onAction,
            )
          : showCloseButton
              ? SnackBarAction(
                  label: 'Dismiss',
                  textColor: _getActionColor(type, colors),
                  onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                )
              : null,
    );
    
    return ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  
  /// Get action color based on notification type
  static Color _getActionColor(NotificationType type, StandardizedColors colors) {
    switch (type) {
      case NotificationType.success:
        return colors.success;
      case NotificationType.error:
        return colors.error;
      case NotificationType.warning:
        return colors.warning;
      case NotificationType.info:
      case NotificationType.loading:
      case NotificationType.progress:
        return colors.info;
    }
  }
  
  /// Hide current notification
  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
  
  /// Clear all notifications
  static void clearAll(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }
  
  /// Track notification for analytics
  static void _trackNotification(
    NotificationType type,
    String message,
    String? title,
  ) {
    final event = NotificationEvent(
      type: type,
      message: message,
      title: title,
      timestamp: DateTime.now(),
    );
    
    _notificationHistory.add(event);
    
    // Keep only last 50 notification events
    if (_notificationHistory.length > 50) {
      _notificationHistory.removeAt(0);
    }
  }
  
  /// Get notification history for analytics
  static List<NotificationEvent> get notificationHistory => 
      List.unmodifiable(_notificationHistory);
  
  /// Clear notification history
  static void clearNotificationHistory() {
    _notificationHistory.clear();
  }
  
  /// Get notification statistics
  static Map<NotificationType, int> getNotificationStats() {
    final stats = <NotificationType, int>{};
    
    for (final event in _notificationHistory) {
      stats[event.type] = (stats[event.type] ?? 0) + 1;
    }
    
    return stats;
  }
}

/// Notification content widget
class StandardizedNotificationContent extends StatefulWidget {
  final NotificationType type;
  final String? title;
  final String message;
  final bool showProgress;
  final double? progress;
  
  const StandardizedNotificationContent({
    super.key,
    required this.type,
    this.title,
    required this.message,
    this.showProgress = false,
    this.progress,
  });
  
  @override
  State<StandardizedNotificationContent> createState() => 
      _StandardizedNotificationContentState();
}

class _StandardizedNotificationContentState 
    extends State<StandardizedNotificationContent> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: StandardizedAnimations.modalTransition,
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: StandardizedAnimations.emphasizedCurve,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: StandardizedAnimations.decelerateCurve,
    ));
    
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = StandardizedColors(theme);
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: GlassmorphismContainer(
              level: GlassLevel.floating,
              borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
              padding: const EdgeInsets.all(SpacingTokens.md),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getTypeColor(widget.type, colors).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
                    ),
                    child: StandardizedIcon(
                      _getTypeIcon(widget.type),
                      size: StandardizedIconSize.md,
                      color: _getTypeColor(widget.type, colors),
                    ),
                  ),
                  
                  const SizedBox(width: SpacingTokens.sm),
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title (optional)
                        if (widget.title != null)
                          StandardizedText(
                            widget.title!,
                            style: StandardizedTextStyle.titleMedium,
                            color: theme.colorScheme.onSurface,
                          ),
                        
                        // Message
                        StandardizedText(
                          widget.message,
                          style: StandardizedTextStyle.bodyMedium,
                          color: widget.title != null 
                              ? theme.colorScheme.onSurfaceVariant
                              : theme.colorScheme.onSurface,
                          maxLines: 3,
                        ),
                        
                        // Progress indicator (optional)
                        if (widget.showProgress) ...[
                          const SizedBox(height: SpacingTokens.xs),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
                            child: LinearProgressIndicator(
                              value: widget.progress,
                              backgroundColor: colors.glassTintLight,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getTypeColor(widget.type, colors),
                              ),
                              minHeight: 4,
                            ),
                          ),
                          if (widget.progress != null) ...[
                            const SizedBox(height: SpacingTokens.xs),
                            StandardizedText(
                              '${(widget.progress! * 100).round()}%',
                              style: StandardizedTextStyle.labelSmall,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Color _getTypeColor(NotificationType type, StandardizedColors colors) {
    switch (type) {
      case NotificationType.success:
        return colors.success;
      case NotificationType.error:
        return colors.error;
      case NotificationType.warning:
        return colors.warning;
      case NotificationType.info:
      case NotificationType.loading:
      case NotificationType.progress:
        return colors.info;
    }
  }
  
  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return PhosphorIcons.checkCircle();
      case NotificationType.error:
        return PhosphorIcons.warningCircle();
      case NotificationType.warning:
        return PhosphorIcons.warning();
      case NotificationType.info:
        return PhosphorIcons.info();
      case NotificationType.loading:
        return PhosphorIcons.circleNotch();
      case NotificationType.progress:
        return PhosphorIcons.downloadSimple();
    }
  }
}

/// Notification types
enum NotificationType {
  success,
  error,
  warning,
  info,
  loading,
  progress,
}

/// Notification event for analytics
class NotificationEvent {
  final NotificationType type;
  final String message;
  final String? title;
  final DateTime timestamp;
  
  const NotificationEvent({
    required this.type,
    required this.message,
    this.title,
    required this.timestamp,
  });
  
  @override
  String toString() {
    return 'NotificationEvent(type: $type, title: $title, message: $message, time: $timestamp)';
  }
}

/// Extensions for easy context-based notifications
extension StandardizedNotificationsExtension on BuildContext {
  /// Quick notification methods
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSuccessNotification(
    String message, {
    String? title,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    return StandardizedNotifications.showSuccess(
      this,
      message: message,
      title: title,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }
  
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showErrorNotification(
    String message, {
    String? title,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    return StandardizedNotifications.showError(
      this,
      message: message,
      title: title,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }
  
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showWarningNotification(
    String message, {
    String? title,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    return StandardizedNotifications.showWarning(
      this,
      message: message,
      title: title,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }
  
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showInfoNotification(
    String message, {
    String? title,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    return StandardizedNotifications.showInfo(
      this,
      message: message,
      title: title,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }
  
  /// Semantic notification shortcuts
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> notifyTaskCreated({
    String message = 'Task created successfully',
    VoidCallback? onViewTask,
  }) => StandardizedNotifications.taskCreated(this, message: message, onViewTask: onViewTask);
  
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> notifyTaskCompleted({
    String message = 'Task completed!',
    VoidCallback? onUndo,
  }) => StandardizedNotifications.taskCompleted(this, message: message, onUndo: onUndo);
  
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> notifyTaskDeleted({
    String message = 'Task deleted',
    VoidCallback? onUndo,
  }) => StandardizedNotifications.taskDeleted(this, message: message, onUndo: onUndo);
  
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> notifyNetworkError({
    String message = 'Network connection failed',
    VoidCallback? onRetry,
  }) => StandardizedNotifications.networkError(this, message: message, onRetry: onRetry);
  
  /// Hide notifications
  void hideNotification() => StandardizedNotifications.hide(this);
  void clearAllNotifications() => StandardizedNotifications.clearAll(this);
}