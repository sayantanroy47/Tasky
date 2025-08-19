import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'glassmorphism_container.dart';
import '../../core/theme/typography_constants.dart';
import '../../core/theme/material3/motion_system.dart';
import '../../core/design_system/design_tokens.dart';

/// Beautiful glassmorphism context menu system
class GlassContextMenu extends StatefulWidget {
  final List<ContextMenuItem> items;
  final Offset position;
  final VoidCallback? onDismiss;
  final Duration animationDuration;
  final bool showOnHover;
  final EdgeInsetsGeometry? padding;
  
  const GlassContextMenu({
    super.key,
    required this.items,
    required this.position,
    this.onDismiss,
    this.animationDuration = const Duration(milliseconds: 200),
    this.showOnHover = false,
    this.padding,
  });

  /// Show context menu at specific position
  static Future<T?> show<T>({
    required BuildContext context,
    required List<ContextMenuItem> items,
    required Offset position,
    Duration animationDuration = const Duration(milliseconds: 200),
  }) {
    return showDialog<T>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => _ContextMenuOverlay<T>(
        items: items,
        position: position,
        animationDuration: animationDuration,
      ),
    );
  }

  @override
  State<GlassContextMenu> createState() => _GlassContextMenuState();
}

class _GlassContextMenuState extends State<GlassContextMenu>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _scaleController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: ExpressiveMotionSystem.emphasizedEasing,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: ExpressiveMotionSystem.standard,
    ));
  }

  void _startAnimations() {
    _scaleController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _fadeAnimation]),
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            alignment: Alignment.topLeft,
            child: _buildMenu(context),
          ),
        );
      },
    );
  }

  Widget _buildMenu(BuildContext context) {
    final theme = Theme.of(context);
    
    return GlassmorphismContainer(
      level: GlassLevel.floating,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusMedium),
      padding: widget.padding ?? const EdgeInsets.all(8),
      glassTint: theme.colorScheme.surface.withOpacity(0.9),
      borderColor: theme.colorScheme.outline.withOpacity(0.3),
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: widget.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            
            return Column(
              children: [
                _buildMenuItem(context, item, index),
                if (index < widget.items.length - 1 && !item.isDivider)
                  _buildDivider(theme),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, ContextMenuItem item, int index) {
    if (item.isDivider) {
      return _buildDivider(Theme.of(context));
    }

    // final theme = Theme.of(context);
    
    return _AnimatedMenuItem(
      item: item,
      index: index,
      onTap: () {
        if (item.onTap != null) {
          item.onTap!();
          widget.onDismiss?.call();
        }
      },
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            theme.colorScheme.outline.withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

/// Animated menu item widget
class _AnimatedMenuItem extends StatefulWidget {
  final ContextMenuItem item;
  final int index;
  final VoidCallback onTap;

  const _AnimatedMenuItem({
    required this.item,
    required this.index,
    required this.onTap,
  });

  @override
  State<_AnimatedMenuItem> createState() => _AnimatedMenuItemState();
}

class _AnimatedMenuItemState extends State<_AnimatedMenuItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;
  late Animation<Color?> _backgroundAnimation;
  bool _isHovered = false;


  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _hoverAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOut,
    ));

    _backgroundAnimation = ColorTween(
      begin: Colors.transparent,
      end: Theme.of(context).colorScheme.primary.withOpacity(0.1),
    ).animate(_hoverController);
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    setState(() => _isHovered = isHovered);
    
    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  void _handleTap() {
    HapticFeedback.selectionClick();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: AnimatedBuilder(
        animation: _hoverAnimation,
        builder: (context, child) {
          return GestureDetector(
            onTap: widget.item.enabled ? _handleTap : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _backgroundAnimation.value,
                borderRadius: BorderRadius.circular(TypographyConstants.radiusXSmall),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon with animation
                  if (widget.item.icon != null)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      transform: Matrix4.identity()
                        ..scale(_isHovered ? 1.1 : 1.0),
                      child: Icon(
                        widget.item.icon,
                        size: 20,
                        color: widget.item.enabled
                            ? (widget.item.iconColor ?? theme.colorScheme.onSurface)
                            : theme.colorScheme.onSurface.withOpacity(0.38),
                      ),
                    ),
                  
                  if (widget.item.icon != null) const SizedBox(width: 12),
                  
                  // Text
                  Flexible(
                    child: Text(
                      widget.item.title,
                      style: TextStyle(
                        fontSize: TypographyConstants.textSM,
                        fontWeight: _isHovered 
                            ? TypographyConstants.medium
                            : TypographyConstants.regular,
                        color: widget.item.enabled
                            ? (widget.item.textColor ?? theme.colorScheme.onSurface)
                            : theme.colorScheme.onSurface.withOpacity(0.38),
                      ),
                    ),
                  ),
                  
                  // Keyboard shortcut
                  if (widget.item.shortcut != null) ...[
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(TypographyConstants.radiusXSmall),
                      ),
                      child: Text(
                        widget.item.shortcut!,
                        style: TextStyle(
                          fontSize: TypographyConstants.textXS,
                          color: theme.colorScheme.onSurfaceVariant,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Context menu overlay for showing menus
class _ContextMenuOverlay<T> extends StatefulWidget {
  final List<ContextMenuItem> items;
  final Offset position;
  final Duration animationDuration;

  const _ContextMenuOverlay({
    required this.items,
    required this.position,
    required this.animationDuration,
  });

  @override
  State<_ContextMenuOverlay<T>> createState() => _ContextMenuOverlayState<T>();
}

class _ContextMenuOverlayState<T> extends State<_ContextMenuOverlay<T>> {
  void _dismiss() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dismiss,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
          Positioned(
            left: widget.position.dx,
            top: widget.position.dy,
            child: GlassContextMenu(
              items: widget.items,
              position: widget.position,
              animationDuration: widget.animationDuration,
              onDismiss: _dismiss,
            ),
          ),
        ],
      ),
    );
  }
}

/// Context menu item data class
class ContextMenuItem {
  final String title;
  final IconData? icon;
  final Color? iconColor;
  final Color? textColor;
  final String? shortcut;
  final VoidCallback? onTap;
  final bool enabled;
  final bool isDivider;

  const ContextMenuItem({
    required this.title,
    this.icon,
    this.iconColor,
    this.textColor,
    this.shortcut,
    this.onTap,
    this.enabled = true,
    this.isDivider = false,
  });

  /// Create a divider item
  const ContextMenuItem.divider()
      : title = '',
        icon = null,
        iconColor = null,
        textColor = null,
        shortcut = null,
        onTap = null,
        enabled = true,
        isDivider = true;
}

/// Helper widget for adding context menu support to any widget
class GlassContextMenuWrapper extends StatelessWidget {
  final Widget child;
  final List<ContextMenuItem> items;
  final bool enableRightClick;
  final bool enableLongPress;
  final VoidCallback? onMenuShow;
  final VoidCallback? onMenuHide;

  const GlassContextMenuWrapper({
    super.key,
    required this.child,
    required this.items,
    this.enableRightClick = true,
    this.enableLongPress = true,
    this.onMenuShow,
    this.onMenuHide,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapDown: enableRightClick ? (details) {
        onMenuShow?.call();
        _showContextMenu(context, details.globalPosition);
      } : null,
      onLongPressStart: enableLongPress ? (details) {
        onMenuShow?.call();
        HapticFeedback.heavyImpact();
        _showContextMenu(context, details.globalPosition);
      } : null,
      child: child,
    );
  }

  void _showContextMenu(BuildContext context, Offset globalPosition) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(globalPosition, globalPosition),
      Offset.zero & overlay.size,
    );

    GlassContextMenu.show(
      context: context,
      items: items,
      position: Offset(position.left, position.top),
    ).then((_) => onMenuHide?.call());
  }
}

/// Pre-built common context menu items
class CommonContextMenuItems {
  
  static ContextMenuItem copy({VoidCallback? onTap}) {
    return ContextMenuItem(
      title: 'Copy',
      icon: Icons.copy,
      shortcut: 'Ctrl+C',
      onTap: onTap,
    );
  }

  static ContextMenuItem paste({VoidCallback? onTap}) {
    return ContextMenuItem(
      title: 'Paste',
      icon: Icons.paste,
      shortcut: 'Ctrl+V',
      onTap: onTap,
    );
  }

  static ContextMenuItem delete({VoidCallback? onTap}) {
    return ContextMenuItem(
      title: 'Delete',
      icon: Icons.delete,
      iconColor: Colors.red,
      textColor: Colors.red,
      shortcut: 'Del',
      onTap: onTap,
    );
  }

  static ContextMenuItem edit({VoidCallback? onTap}) {
    return ContextMenuItem(
      title: 'Edit',
      icon: Icons.edit,
      shortcut: 'F2',
      onTap: onTap,
    );
  }

  static ContextMenuItem duplicate({VoidCallback? onTap}) {
    return ContextMenuItem(
      title: 'Duplicate',
      icon: Icons.content_copy,
      shortcut: 'Ctrl+D',
      onTap: onTap,
    );
  }

  static ContextMenuItem markComplete({VoidCallback? onTap}) {
    return ContextMenuItem(
      title: 'Mark Complete',
      icon: Icons.check_circle,
      iconColor: Colors.green,
      onTap: onTap,
    );
  }

  static ContextMenuItem markIncomplete({VoidCallback? onTap}) {
    return ContextMenuItem(
      title: 'Mark Incomplete',
      icon: Icons.radio_button_unchecked,
      onTap: onTap,
    );
  }

  static ContextMenuItem setPriority(TaskPriority priority, {VoidCallback? onTap}) {
    final config = _getPriorityConfig(priority);
    return ContextMenuItem(
      title: 'Set ${config.name}',
      icon: config.icon,
      iconColor: config.color,
      onTap: onTap,
    );
  }

  static _PriorityConfig _getPriorityConfig(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return _PriorityConfig('Low Priority', Icons.flag, Colors.green);
      case TaskPriority.medium:
        return _PriorityConfig('Medium Priority', Icons.flag, Colors.blue);
      case TaskPriority.high:
        return _PriorityConfig('High Priority', Icons.flag, Colors.orange);
      case TaskPriority.urgent:
        return _PriorityConfig('Urgent Priority', Icons.flag, Colors.red);
    }
  }
}

class _PriorityConfig {
  final String name;
  final IconData icon;
  final Color color;

  _PriorityConfig(this.name, this.icon, this.color);
}

// Mock TaskPriority enum for the example
enum TaskPriority { low, medium, high, urgent }