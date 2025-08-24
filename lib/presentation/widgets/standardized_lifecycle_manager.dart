import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Standardized lifecycle management system that eliminates resource management chaos
/// 
/// Eliminates Lifecycle Pattern Inconsistency by:
/// - Providing centralized resource cleanup and disposal patterns
/// - Preventing memory leaks through systematic resource management
/// - Offering standardized patterns for controllers, streams, timers, and listeners
/// - Tracking resource lifecycle and providing debugging information
/// - Supporting automatic cleanup on widget disposal
class StandardizedLifecycleManager {
  static final Map<String, LifecycleRegistry> _registries = {};
  
  /// Get or create a lifecycle registry for a component
  static LifecycleRegistry getRegistry(String componentId) {
    return _registries.putIfAbsent(componentId, () => LifecycleRegistry(componentId));
  }
  
  /// Clear all registries (useful for testing)
  static void clearAll() {
    for (final registry in _registries.values) {
      registry.disposeAll();
    }
    _registries.clear();
  }
  
  /// Get lifecycle statistics
  static Map<String, LifecycleStats> getStats() {
    return _registries.map((id, registry) => MapEntry(id, registry.getStats()));
  }
  
  /// Log lifecycle events for debugging
  static bool debugEnabled = false;
  
  static void _debugLog(String message) {
    if (debugEnabled) {
      print('[LifecycleManager] $message');
    }
  }
}

/// Registry for managing resources in a specific component
class LifecycleRegistry {
  final String componentId;
  final List<AnimationController> _controllers = [];
  final List<StreamSubscription> _subscriptions = [];
  final List<Timer> _timers = [];
  final List<TextEditingController> _textControllers = [];
  final List<FocusNode> _focusNodes = [];
  final List<VoidCallback> _listeners = [];
  final List<ChangeNotifier> _notifiers = [];
  final List<VoidCallback> _customDisposables = [];
  final DateTime _createdAt;
  
  LifecycleRegistry(this.componentId) : _createdAt = DateTime.now() {
    StandardizedLifecycleManager._debugLog('Registry created for $componentId');
  }
  
  /// Register an AnimationController
  T registerController<T extends AnimationController>(T controller) {
    _controllers.add(controller);
    StandardizedLifecycleManager._debugLog(
      'Controller registered in $componentId (${_controllers.length} total)'
    );
    return controller;
  }
  
  /// Register a StreamSubscription
  T registerSubscription<T extends StreamSubscription>(T subscription) {
    _subscriptions.add(subscription);
    StandardizedLifecycleManager._debugLog(
      'Subscription registered in $componentId (${_subscriptions.length} total)'
    );
    return subscription;
  }
  
  /// Register a Timer
  T registerTimer<T extends Timer>(T timer) {
    _timers.add(timer);
    StandardizedLifecycleManager._debugLog(
      'Timer registered in $componentId (${_timers.length} total)'
    );
    return timer;
  }
  
  /// Register a TextEditingController
  T registerTextController<T extends TextEditingController>(T controller) {
    _textControllers.add(controller);
    StandardizedLifecycleManager._debugLog(
      'TextController registered in $componentId (${_textControllers.length} total)'
    );
    return controller;
  }
  
  /// Register a FocusNode
  T registerFocusNode<T extends FocusNode>(T focusNode) {
    _focusNodes.add(focusNode);
    StandardizedLifecycleManager._debugLog(
      'FocusNode registered in $componentId (${_focusNodes.length} total)'
    );
    return focusNode;
  }
  
  /// Register a listener function
  void registerListener(VoidCallback listener) {
    _listeners.add(listener);
    StandardizedLifecycleManager._debugLog(
      'Listener registered in $componentId (${_listeners.length} total)'
    );
  }
  
  /// Register a ChangeNotifier
  T registerNotifier<T extends ChangeNotifier>(T notifier) {
    _notifiers.add(notifier);
    StandardizedLifecycleManager._debugLog(
      'ChangeNotifier registered in $componentId (${_notifiers.length} total)'
    );
    return notifier;
  }
  
  /// Register a custom disposable function
  void registerCustomDisposable(VoidCallback disposable) {
    _customDisposables.add(disposable);
    StandardizedLifecycleManager._debugLog(
      'Custom disposable registered in $componentId (${_customDisposables.length} total)'
    );
  }
  
  /// Create and register common resources
  AnimationController createController({
    required Duration duration,
    required TickerProvider vsync,
  }) {
    return registerController(AnimationController(duration: duration, vsync: vsync));
  }
  
  TextEditingController createTextController([String? initialValue]) {
    return registerTextController(TextEditingController(text: initialValue));
  }
  
  FocusNode createFocusNode() {
    return registerFocusNode(FocusNode());
  }
  
  Timer createTimer(Duration duration, VoidCallback callback) {
    return registerTimer(Timer(duration, callback));
  }
  
  Timer createPeriodicTimer(Duration duration, void Function(Timer) callback) {
    return registerTimer(Timer.periodic(duration, callback));
  }
  
  StreamSubscription<T> createSubscription<T>(
    Stream<T> stream,
    void Function(T) onData, {
    Function? onError,
    void Function()? onDone,
  }) {
    return registerSubscription(
      stream.listen(onData, onError: onError, onDone: onDone)
    );
  }
  
  /// Dispose specific resource types
  void disposeControllers() {
    for (final controller in _controllers) {
      try {
        controller.dispose();
      } catch (e) {
        StandardizedLifecycleManager._debugLog('Error disposing controller: $e');
      }
    }
    _controllers.clear();
  }
  
  void disposeSubscriptions() {
    for (final subscription in _subscriptions) {
      try {
        subscription.cancel();
      } catch (e) {
        StandardizedLifecycleManager._debugLog('Error canceling subscription: $e');
      }
    }
    _subscriptions.clear();
  }
  
  void disposeTimers() {
    for (final timer in _timers) {
      try {
        if (timer.isActive) {
          timer.cancel();
        }
      } catch (e) {
        StandardizedLifecycleManager._debugLog('Error canceling timer: $e');
      }
    }
    _timers.clear();
  }
  
  void disposeTextControllers() {
    for (final controller in _textControllers) {
      try {
        controller.dispose();
      } catch (e) {
        StandardizedLifecycleManager._debugLog('Error disposing text controller: $e');
      }
    }
    _textControllers.clear();
  }
  
  void disposeFocusNodes() {
    for (final focusNode in _focusNodes) {
      try {
        focusNode.dispose();
      } catch (e) {
        StandardizedLifecycleManager._debugLog('Error disposing focus node: $e');
      }
    }
    _focusNodes.clear();
  }
  
  void disposeNotifiers() {
    for (final notifier in _notifiers) {
      try {
        notifier.dispose();
      } catch (e) {
        StandardizedLifecycleManager._debugLog('Error disposing notifier: $e');
      }
    }
    _notifiers.clear();
  }
  
  void disposeCustom() {
    for (final disposable in _customDisposables) {
      try {
        disposable();
      } catch (e) {
        StandardizedLifecycleManager._debugLog('Error running custom disposable: $e');
      }
    }
    _customDisposables.clear();
  }
  
  /// Dispose all resources
  void disposeAll() {
    StandardizedLifecycleManager._debugLog('Disposing all resources for $componentId');
    
    disposeTimers(); // Cancel timers first to prevent callbacks
    disposeSubscriptions(); // Cancel subscriptions
    disposeControllers(); // Dispose animation controllers
    disposeTextControllers(); // Dispose text controllers
    disposeFocusNodes(); // Dispose focus nodes
    disposeNotifiers(); // Dispose change notifiers
    disposeCustom(); // Run custom cleanup
    
    // Clear listeners (no disposal needed, just clearing references)
    _listeners.clear();
    
    StandardizedLifecycleManager._debugLog('All resources disposed for $componentId');
  }
  
  /// Get lifecycle statistics
  LifecycleStats getStats() {
    return LifecycleStats(
      componentId: componentId,
      createdAt: _createdAt,
      controllersCount: _controllers.length,
      subscriptionsCount: _subscriptions.length,
      timersCount: _timers.length,
      textControllersCount: _textControllers.length,
      focusNodesCount: _focusNodes.length,
      listenersCount: _listeners.length,
      notifiersCount: _notifiers.length,
      customDisposablesCount: _customDisposables.length,
    );
  }
  
  /// Check if any resources are registered
  bool get hasResources {
    return _controllers.isNotEmpty ||
        _subscriptions.isNotEmpty ||
        _timers.isNotEmpty ||
        _textControllers.isNotEmpty ||
        _focusNodes.isNotEmpty ||
        _listeners.isNotEmpty ||
        _notifiers.isNotEmpty ||
        _customDisposables.isNotEmpty;
  }
}

/// Mixin for StatefulWidgets to automatically manage lifecycle
mixin StandardizedLifecycleMixin<T extends StatefulWidget> on State<T> {
  late final LifecycleRegistry _lifecycleRegistry;
  
  @override
  void initState() {
    super.initState();
    _lifecycleRegistry = StandardizedLifecycleManager.getRegistry(
      '${widget.runtimeType}_$hashCode'
    );
  }
  
  @override
  void dispose() {
    _lifecycleRegistry.disposeAll();
    super.dispose();
  }
  
  /// Access to the lifecycle registry
  LifecycleRegistry get lifecycle => _lifecycleRegistry;
  
  /// Convenience methods
  AnimationController createController({
    required Duration duration,
    required TickerProvider vsync,
  }) => lifecycle.createController(duration: duration, vsync: vsync);
  
  TextEditingController createTextController([String? initialValue]) =>
      lifecycle.createTextController(initialValue);
  
  FocusNode createFocusNode() => lifecycle.createFocusNode();
  
  Timer createTimer(Duration duration, VoidCallback callback) =>
      lifecycle.createTimer(duration, callback);
  
  Timer createPeriodicTimer(Duration duration, void Function(Timer) callback) =>
      lifecycle.createPeriodicTimer(duration, callback);
  
  StreamSubscription<S> createSubscription<S>(
    Stream<S> stream,
    void Function(S) onData, {
    Function? onError,
    void Function()? onDone,
  }) => lifecycle.createSubscription(stream, onData, onError: onError, onDone: onDone);
}

/// Mixin for ConsumerStatefulWidget to automatically manage lifecycle
mixin StandardizedLifecycleConsumerMixin<T extends ConsumerStatefulWidget> 
    on ConsumerState<T> {
  late final LifecycleRegistry _lifecycleRegistry;
  
  @override
  void initState() {
    super.initState();
    _lifecycleRegistry = StandardizedLifecycleManager.getRegistry(
      '${widget.runtimeType}_$hashCode'
    );
  }
  
  @override
  void dispose() {
    _lifecycleRegistry.disposeAll();
    super.dispose();
  }
  
  /// Access to the lifecycle registry
  LifecycleRegistry get lifecycle => _lifecycleRegistry;
  
  /// Convenience methods
  AnimationController createController({
    required Duration duration,
    required TickerProvider vsync,
  }) => lifecycle.createController(duration: duration, vsync: vsync);
  
  TextEditingController createTextController([String? initialValue]) =>
      lifecycle.createTextController(initialValue);
  
  FocusNode createFocusNode() => lifecycle.createFocusNode();
  
  Timer createTimer(Duration duration, VoidCallback callback) =>
      lifecycle.createTimer(duration, callback);
  
  Timer createPeriodicTimer(Duration duration, void Function(Timer) callback) =>
      lifecycle.createPeriodicTimer(duration, callback);
  
  StreamSubscription<S> createSubscription<S>(
    Stream<S> stream,
    void Function(S) onData, {
    Function? onError,
    void Function()? onDone,
  }) => lifecycle.createSubscription(stream, onData, onError: onError, onDone: onDone);
}

/// Widget that automatically manages lifecycle for its children
class StandardizedLifecycleProvider extends StatefulWidget {
  final Widget child;
  final String? componentId;
  final void Function(LifecycleRegistry)? onRegistryCreated;
  
  const StandardizedLifecycleProvider({
    super.key,
    required this.child,
    this.componentId,
    this.onRegistryCreated,
  });
  
  @override
  State<StandardizedLifecycleProvider> createState() => 
      _StandardizedLifecycleProviderState();
}

class _StandardizedLifecycleProviderState extends State<StandardizedLifecycleProvider> {
  late final LifecycleRegistry _lifecycleRegistry;
  
  @override
  void initState() {
    super.initState();
    _lifecycleRegistry = StandardizedLifecycleManager.getRegistry(
      widget.componentId ?? 'LifecycleProvider_$hashCode'
    );
    widget.onRegistryCreated?.call(_lifecycleRegistry);
  }
  
  @override
  void dispose() {
    _lifecycleRegistry.disposeAll();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return _LifecycleRegistryProvider(
      registry: _lifecycleRegistry,
      child: widget.child,
    );
  }
}

/// InheritedWidget to provide lifecycle registry down the widget tree
class _LifecycleRegistryProvider extends InheritedWidget {
  final LifecycleRegistry registry;
  
  const _LifecycleRegistryProvider({
    required this.registry,
    required super.child,
  });
  
  @override
  bool updateShouldNotify(_LifecycleRegistryProvider oldWidget) {
    return registry != oldWidget.registry;
  }
  
  static LifecycleRegistry? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_LifecycleRegistryProvider>()?.registry;
  }
  
  static LifecycleRegistry of(BuildContext context) {
    final registry = maybeOf(context);
    assert(registry != null, 'No LifecycleRegistry found in context. Wrap with StandardizedLifecycleProvider.');
    return registry!;
  }
}

/// Extension for easy access to lifecycle registry
extension StandardizedLifecycleExtension on BuildContext {
  LifecycleRegistry? get lifecycleRegistry => _LifecycleRegistryProvider.maybeOf(this);
  
  LifecycleRegistry get requireLifecycleRegistry => _LifecycleRegistryProvider.of(this);
}

/// Lifecycle statistics for debugging and monitoring
class LifecycleStats {
  final String componentId;
  final DateTime createdAt;
  final int controllersCount;
  final int subscriptionsCount;
  final int timersCount;
  final int textControllersCount;
  final int focusNodesCount;
  final int listenersCount;
  final int notifiersCount;
  final int customDisposablesCount;
  
  const LifecycleStats({
    required this.componentId,
    required this.createdAt,
    required this.controllersCount,
    required this.subscriptionsCount,
    required this.timersCount,
    required this.textControllersCount,
    required this.focusNodesCount,
    required this.listenersCount,
    required this.notifiersCount,
    required this.customDisposablesCount,
  });
  
  int get totalResourcesCount {
    return controllersCount +
        subscriptionsCount +
        timersCount +
        textControllersCount +
        focusNodesCount +
        listenersCount +
        notifiersCount +
        customDisposablesCount;
  }
  
  Duration get age => DateTime.now().difference(createdAt);
  
  @override
  String toString() {
    return 'LifecycleStats($componentId: $totalResourcesCount resources, age: ${age.inSeconds}s)';
  }
}

/// Common lifecycle patterns as static helpers
class LifecyclePatterns {
  /// Auto-dispose pattern for async operations
  static Future<T> withAutoDispose<T>(
    BuildContext context,
    Future<T> future, {
    Duration? timeout,
  }) async {
    final registry = context.requireLifecycleRegistry;
    final completer = Completer<T>();
    
    // Create cancellation mechanism
    bool cancelled = false;
    registry.registerCustomDisposable(() {
      cancelled = true;
      if (!completer.isCompleted) {
        completer.completeError('Operation cancelled');
      }
    });
    
    // Handle timeout
    Timer? timeoutTimer;
    if (timeout != null) {
      timeoutTimer = registry.createTimer(timeout, () {
        if (!completer.isCompleted) {
          completer.completeError('Operation timed out');
        }
      });
    }
    
    // Execute future
    future.then((value) {
      if (!cancelled && !completer.isCompleted) {
        timeoutTimer?.cancel();
        completer.complete(value);
      }
    }).catchError((error) {
      if (!cancelled && !completer.isCompleted) {
        timeoutTimer?.cancel();
        completer.completeError(error);
      }
    });
    
    return completer.future;
  }
  
  /// Debounced callback pattern
  static VoidCallback createDebouncedCallback(
    BuildContext context,
    VoidCallback callback, {
    Duration delay = const Duration(milliseconds: 300),
  }) {
    Timer? timer;
    final registry = context.requireLifecycleRegistry;
    
    return () {
      timer?.cancel();
      timer = registry.createTimer(delay, callback);
    };
  }
  
  /// Throttled callback pattern
  static VoidCallback createThrottledCallback(
    BuildContext context,
    VoidCallback callback, {
    Duration interval = const Duration(milliseconds: 100),
  }) {
    Timer? timer;
    final registry = context.requireLifecycleRegistry;
    
    return () {
      if (timer?.isActive != true) {
        callback();
        timer = registry.createTimer(interval, () {});
      }
    };
  }
}