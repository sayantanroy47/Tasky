import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Comprehensive keyboard navigation support
class KeyboardNavigationManager {
  static final KeyboardNavigationManager _instance = KeyboardNavigationManager._internal();
  factory KeyboardNavigationManager() => _instance;
  KeyboardNavigationManager._internal();

  static KeyboardNavigationManager get instance => _instance;

  final List<FocusNode> _registeredNodes = [];
  FocusNode? _currentFocus;

  /// Register a focus node for keyboard navigation
  void registerFocusNode(FocusNode node) {
    if (!_registeredNodes.contains(node)) {
      _registeredNodes.add(node);
    }
  }

  /// Unregister a focus node
  void unregisterFocusNode(FocusNode node) {
    _registeredNodes.remove(node);
    if (_currentFocus == node) {
      _currentFocus = null;
    }
  }

  /// Get next focusable node
  FocusNode? getNextFocusableNode(FocusNode currentNode) {
    final currentIndex = _registeredNodes.indexOf(currentNode);
    if (currentIndex == -1) return null;

    for (int i = currentIndex + 1; i < _registeredNodes.length; i++) {
      if (_registeredNodes[i].canRequestFocus) {
        return _registeredNodes[i];
      }
    }

    // Wrap around to beginning
    for (int i = 0; i < currentIndex; i++) {
      if (_registeredNodes[i].canRequestFocus) {
        return _registeredNodes[i];
      }
    }

    return null;
  }

  /// Get previous focusable node
  FocusNode? getPreviousFocusableNode(FocusNode currentNode) {
    final currentIndex = _registeredNodes.indexOf(currentNode);
    if (currentIndex == -1) return null;

    for (int i = currentIndex - 1; i >= 0; i--) {
      if (_registeredNodes[i].canRequestFocus) {
        return _registeredNodes[i];
      }
    }

    // Wrap around to end
    for (int i = _registeredNodes.length - 1; i > currentIndex; i--) {
      if (_registeredNodes[i].canRequestFocus) {
        return _registeredNodes[i];
      }
    }

    return null;
  }

  /// Focus next node
  bool focusNext(FocusNode currentNode) {
    final nextNode = getNextFocusableNode(currentNode);
    if (nextNode != null) {
      nextNode.requestFocus();
      _currentFocus = nextNode;
      return true;
    }
    return false;
  }

  /// Focus previous node
  bool focusPrevious(FocusNode currentNode) {
    final previousNode = getPreviousFocusableNode(currentNode);
    if (previousNode != null) {
      previousNode.requestFocus();
      _currentFocus = previousNode;
      return true;
    }
    return false;
  }

  /// Clear all registered nodes
  void clearAll() {
    _registeredNodes.clear();
    _currentFocus = null;
  }
}

/// Keyboard navigation intent definitions
class NavigateNextIntent extends Intent {
  const NavigateNextIntent();
}

class NavigatePreviousIntent extends Intent {
  const NavigatePreviousIntent();
}

class ActivateIntent extends Intent {
  const ActivateIntent();
}

class EscapeIntent extends Intent {
  const EscapeIntent();
}

/// Keyboard navigation action definitions
class NavigateNextAction extends Action<NavigateNextIntent> {
  @override
  bool invoke(NavigateNextIntent intent) {
    final currentFocus = FocusManager.instance.primaryFocus;
    if (currentFocus != null) {
      return KeyboardNavigationManager.instance.focusNext(currentFocus);
    }
    return false;
  }
}

class NavigatePreviousAction extends Action<NavigatePreviousIntent> {
  @override
  bool invoke(NavigatePreviousIntent intent) {
    final currentFocus = FocusManager.instance.primaryFocus;
    if (currentFocus != null) {
      return KeyboardNavigationManager.instance.focusPrevious(currentFocus);
    }
    return false;
  }
}

class ActivateAction extends Action<ActivateIntent> {
  final VoidCallback? onActivate;

  ActivateAction({this.onActivate});

  @override
  bool invoke(ActivateIntent intent) {
    onActivate?.call();
    return onActivate != null;
  }
}

class EscapeAction extends Action<EscapeIntent> {
  final VoidCallback? onEscape;

  EscapeAction({this.onEscape});

  @override
  bool invoke(EscapeIntent intent) {
    onEscape?.call();
    return onEscape != null;
  }
}

/// Widget that provides keyboard navigation shortcuts
class KeyboardNavigationProvider extends StatefulWidget {
  final Widget child;
  final VoidCallback? onEscape;
  final Map<ShortcutActivator, Intent>? shortcuts;

  const KeyboardNavigationProvider({
    super.key,
    required this.child,
    this.onEscape,
    this.shortcuts,
  });

  @override
  State<KeyboardNavigationProvider> createState() => _KeyboardNavigationProviderState();
}

class _KeyboardNavigationProviderState extends State<KeyboardNavigationProvider> {
  late Map<ShortcutActivator, Intent> _shortcuts;
  late Map<Type, Action<Intent>> _actions;

  @override
  void initState() {
    super.initState();
    _setupShortcutsAndActions();
  }

  void _setupShortcutsAndActions() {
    _shortcuts = {
      // Tab navigation
      const SingleActivator(LogicalKeyboardKey.tab): const NavigateNextIntent(),
      const SingleActivator(LogicalKeyboardKey.tab, shift: true): const NavigatePreviousIntent(),
      
      // Arrow navigation
      const SingleActivator(LogicalKeyboardKey.arrowDown): const NavigateNextIntent(),
      const SingleActivator(LogicalKeyboardKey.arrowUp): const NavigatePreviousIntent(),
      
      // Activation
      const SingleActivator(LogicalKeyboardKey.enter): const ActivateIntent(),
      const SingleActivator(LogicalKeyboardKey.space): const ActivateIntent(),
      
      // Escape
      const SingleActivator(LogicalKeyboardKey.escape): const EscapeIntent(),
      
      // Add any custom shortcuts
      ...?widget.shortcuts,
    };

    _actions = {
      NavigateNextIntent: NavigateNextAction(),
      NavigatePreviousIntent: NavigatePreviousAction(),
      ActivateIntent: ActivateAction(),
      EscapeIntent: EscapeAction(onEscape: widget.onEscape),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: _shortcuts,
      child: Actions(
        actions: _actions,
        child: widget.child,
      ),
    );
  }
}

/// Enhanced focus node with keyboard navigation support
class NavigationFocusNode extends FocusNode {
  final VoidCallback? onActivate;
  final String? semanticLabel;
  final bool isModal;
  
  NavigationFocusNode({
    this.onActivate,
    this.semanticLabel,
    this.isModal = false,
    super.debugLabel,
    super.onKeyEvent,
    super.skipTraversal,
    super.canRequestFocus,
    super.descendantsAreFocusable,
    super.descendantsAreTraversable,
  });

  @override
  void requestFocus([FocusNode? node]) {
    super.requestFocus(node);
    // Register with navigation manager when focused
    KeyboardNavigationManager.instance.registerFocusNode(this);
  }

  @override
  void dispose() {
    KeyboardNavigationManager.instance.unregisterFocusNode(this);
    super.dispose();
  }

  /// Activate the focused element
  void activate() {
    onActivate?.call();
  }
}

/// Widget that automatically handles keyboard navigation
class KeyboardNavigable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onActivate;
  final String? semanticLabel;
  final bool autofocus;
  final FocusNode? focusNode;
  final bool skipTraversal;
  final Widget? focusIndicator;

  const KeyboardNavigable({
    super.key,
    required this.child,
    this.onTap,
    this.onActivate,
    this.semanticLabel,
    this.autofocus = false,
    this.focusNode,
    this.skipTraversal = false,
    this.focusIndicator,
  });

  @override
  State<KeyboardNavigable> createState() => _KeyboardNavigableState();
}

class _KeyboardNavigableState extends State<KeyboardNavigable> {
  late NavigationFocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode as NavigationFocusNode? ?? NavigationFocusNode(
      onActivate: widget.onActivate ?? widget.onTap,
      semanticLabel: widget.semanticLabel,
    );
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
      },
      child: Actions(
        actions: {
          ActivateIntent: ActivateAction(onActivate: () {
            if (widget.onActivate != null) {
              widget.onActivate!();
            } else if (widget.onTap != null) {
              widget.onTap!();
            }
          }),
        },
        child: Focus(
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          skipTraversal: widget.skipTraversal,
          child: Builder(
            builder: (context) {
              final hasFocus = Focus.of(context).hasFocus;
              
              Widget result = widget.child;
              
              // Add focus indicator
              if (hasFocus && widget.focusIndicator != null) {
                result = Stack(
                  children: [
                    result,
                    widget.focusIndicator!,
                  ],
                );
              } else if (hasFocus) {
                result = Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: result,
                );
              }

              // Add gesture detector if onTap is provided
              if (widget.onTap != null) {
                result = GestureDetector(
                  onTap: widget.onTap,
                  child: result,
                );
              }

              // Add semantics
              if (widget.semanticLabel != null) {
                result = Semantics(
                  label: widget.semanticLabel,
                  button: widget.onTap != null || widget.onActivate != null,
                  focused: hasFocus,
                  child: result,
                );
              }

              return result;
            },
          ),
        ),
      ),
    );
  }
}

/// Keyboard navigation scope for managing focus within a specific area
class KeyboardNavigationScope extends StatefulWidget {
  final Widget child;
  final List<FocusNode>? focusOrder;
  final bool trapFocus;
  final VoidCallback? onEscape;

  const KeyboardNavigationScope({
    super.key,
    required this.child,
    this.focusOrder,
    this.trapFocus = false,
    this.onEscape,
  });

  @override
  State<KeyboardNavigationScope> createState() => _KeyboardNavigationScopeState();
}

class _KeyboardNavigationScopeState extends State<KeyboardNavigationScope> {
  late FocusScopeNode _scopeNode;

  @override
  void initState() {
    super.initState();
    _scopeNode = FocusScopeNode();
  }

  @override
  void dispose() {
    _scopeNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      node: _scopeNode,
      child: KeyboardNavigationProvider(
        onEscape: widget.onEscape,
        child: widget.trapFocus
            ? FocusTraversalGroup(
                policy: OrderedTraversalPolicy(),
                child: widget.child,
              )
            : widget.child,
      ),
    );
  }
}

/// Keyboard shortcut helper
class KeyboardShortcutHelper {
  /// Format shortcut for display
  static String formatShortcut(ShortcutActivator activator) {
    if (activator is SingleActivator) {
      final parts = <String>[];
      
      if (activator.control) parts.add('Ctrl');
      if (activator.meta) parts.add('Cmd');
      if (activator.alt) parts.add('Alt');
      if (activator.shift) parts.add('Shift');
      
      final keyName = _getKeyName(activator.trigger);
      if (keyName.isNotEmpty) parts.add(keyName);
      
      return parts.join(' + ');
    }
    
    return activator.toString();
  }

  /// Get human readable key name
  static String _getKeyName(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.enter) return 'Enter';
    if (key == LogicalKeyboardKey.space) return 'Space';
    if (key == LogicalKeyboardKey.tab) return 'Tab';
    if (key == LogicalKeyboardKey.escape) return 'Esc';
    if (key == LogicalKeyboardKey.arrowUp) return '↑';
    if (key == LogicalKeyboardKey.arrowDown) return '↓';
    if (key == LogicalKeyboardKey.arrowLeft) return '←';
    if (key == LogicalKeyboardKey.arrowRight) return '→';
    if (key == LogicalKeyboardKey.backspace) return 'Backspace';
    if (key == LogicalKeyboardKey.delete) return 'Delete';
    
    return key.keyLabel.toUpperCase();
  }

  /// Show keyboard shortcuts help
  static void showShortcutsHelp(BuildContext context, Map<ShortcutActivator, String> shortcuts) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keyboard Shortcuts'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: shortcuts.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        formatShortcut(entry.key),
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(entry.value),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Focus debug helper for development
class FocusDebugHelper {
  /// Show focus tree (debug only)
  static void showFocusTree(BuildContext context) {
    assert(() {
      final focusManager = FocusManager.instance;
      debugPrint('=== Focus Tree ===');
      _printFocusNode(focusManager.rootScope, 0);
      return true;
    }());
  }

  static void _printFocusNode(FocusNode node, int depth) {
    final indent = '  ' * depth;
    final hasChildren = node.children.isNotEmpty;
    final isFocused = node.hasFocus;
    final canFocus = node.canRequestFocus;
    
    debugPrint('$indent${node.runtimeType} '
        '${isFocused ? "[FOCUSED]" : ""} '
        '${!canFocus ? "[DISABLED]" : ""} '
        '${hasChildren ? "(${node.children.length} children)" : ""}');
    
    for (final child in node.children) {
      _printFocusNode(child, depth + 1);
    }
  }
}