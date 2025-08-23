import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../presentation/widgets/feature_discovery.dart';

/// Comprehensive feature integration manager for seamless glassmorphism UX
class FeatureIntegrationManager {
  static FeatureIntegrationManager? _instance;
  static FeatureIntegrationManager get instance => _instance ??= FeatureIntegrationManager._internal();
  
  FeatureIntegrationManager._internal();

  final Map<String, FeatureModule> _registeredFeatures = {};
  final Map<String, FeatureState> _featureStates = {};
  final List<FeatureIntegrationRule> _integrationRules = [];
  final Set<String> _enabledFeatures = {};

  bool _isInitialized = false;
  VoidCallback? _onFeatureStateChanged;

  /// Initialize the feature integration system
  Future<void> initialize({
    VoidCallback? onFeatureStateChanged,
  }) async {
    if (_isInitialized) return;
    
    _onFeatureStateChanged = onFeatureStateChanged;
    
    // Register core features
    await _registerCoreFeatures();
    
    // Apply integration rules
    _applyIntegrationRules();
    
    // Initialize enabled features
    await _initializeEnabledFeatures();
    
    _isInitialized = true;
    
    if (kDebugMode) {
      debugPrint('[SUCCESS] Feature Integration Manager initialized with ${_registeredFeatures.length} features');
    }
  }

  /// Register a feature module
  void registerFeature(FeatureModule feature) {
    _registeredFeatures[feature.id] = feature;
    _featureStates[feature.id] = FeatureState(
      id: feature.id,
      isEnabled: feature.defaultEnabled,
      isInitialized: false,
      initializationTime: null,
      errorCount: 0,
      lastError: null,
    );
    
    if (kDebugMode) {
      debugPrint('[EMOJI] Registered feature: ${feature.id}');
    }
  }

  /// Enable a feature
  Future<bool> enableFeature(String featureId, {Map<String, dynamic>? config}) async {
    final feature = _registeredFeatures[featureId];
    if (feature == null) {
      debugPrint('Feature not found: $featureId');
      return false;
    }

    final stopwatch = Stopwatch()..start();
    
    try {
      // Check dependencies
      if (!_checkDependencies(feature)) {
        debugPrint('Feature dependencies not met: $featureId');
        return false;
      }

      // Initialize feature
      final success = await feature.initialize(config ?? {});
      stopwatch.stop();
      
      if (success) {
        _enabledFeatures.add(featureId);
        _featureStates[featureId] = _featureStates[featureId]!.copyWith(
          isEnabled: true,
          isInitialized: true,
          initializationTime: stopwatch.elapsed,
        );
        
        // Feature initialization completed
        
        _onFeatureStateChanged?.call();
        
        if (kDebugMode) {
          debugPrint('[SUCCESS] Feature enabled: $featureId (${stopwatch.elapsedMilliseconds}ms)');
        }
        
        return true;
      } else {
        _recordFeatureError(featureId, 'Initialization failed');
        return false;
      }
    } catch (error) {
      stopwatch.stop();
      _recordFeatureError(featureId, error.toString());
      
      // Feature initialization failed
      
      return false;
    }
  }

  /// Disable a feature
  Future<bool> disableFeature(String featureId) async {
    final feature = _registeredFeatures[featureId];
    if (feature == null) return false;

    try {
      await feature.dispose();
      
      _enabledFeatures.remove(featureId);
      _featureStates[featureId] = _featureStates[featureId]!.copyWith(
        isEnabled: false,
        isInitialized: false,
      );
      
      _onFeatureStateChanged?.call();
      
      if (kDebugMode) {
        debugPrint('[REFRESH] Feature disabled: $featureId');
      }
      
      return true;
    } catch (error) {
      _recordFeatureError(featureId, 'Disposal failed: $error');
      return false;
    }
  }

  /// Check if a feature is enabled
  bool isFeatureEnabled(String featureId) {
    return _enabledFeatures.contains(featureId);
  }

  /// Get feature state
  FeatureState? getFeatureState(String featureId) {
    return _featureStates[featureId];
  }

  /// Get all enabled features
  List<FeatureModule> getEnabledFeatures() {
    return _enabledFeatures
        .map((id) => _registeredFeatures[id])
        .whereType<FeatureModule>()
        .toList();
  }

  /// Add integration rule
  void addIntegrationRule(FeatureIntegrationRule rule) {
    _integrationRules.add(rule);
    
    if (_isInitialized) {
      _applyIntegrationRule(rule);
    }
  }

  /// Show feature discovery for enabled features
  Future<void> showFeatureDiscovery(BuildContext context) async {
    final discoveryFeatures = getEnabledFeatures()
        .where((f) => f.discoveryConfig != null)
        .toList();

    for (final feature in discoveryFeatures) {
      final config = feature.discoveryConfig!;
      
      if (!FeatureDiscovery.instance.hasShownFeature(feature.id)) {
        FeatureDiscovery.instance.showFeature(
          context: context,
          featureId: feature.id,
          title: config.title,
          description: config.description,
          targetKey: config.targetKey,
          icon: config.icon,
        );
        
        // Space out discovery presentations
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  /// Start guided tour of enabled features
  Future<void> startGuidedTour(BuildContext context) async {
    final tourFeatures = getEnabledFeatures()
        .where((f) => f.tourStep != null)
        .toList();

    if (tourFeatures.isEmpty) return;

    final steps = tourFeatures
        .map((f) => f.tourStep!)
        .toList();

    FeatureDiscovery.instance.startGuidedTour(
      context: context,
      steps: steps,
      onComplete: () {
        if (kDebugMode) {
          debugPrint('[SUCCESS] Feature tour completed');
        }
      },
    );
  }

  /// Get integration health report
  IntegrationHealthReport getHealthReport() {
    final totalFeatures = _registeredFeatures.length;
    final enabledCount = _enabledFeatures.length;
    final errorCount = _featureStates.values
        .map((s) => s.errorCount)
        .fold(0, (a, b) => a + b);
    
    final avgInitTime = _featureStates.values
        .where((s) => s.initializationTime != null)
        .map((s) => s.initializationTime!.inMilliseconds)
        .fold(0.0, (a, b) => a + b) / enabledCount;

    final failedFeatures = _featureStates.entries
        .where((e) => e.value.lastError != null)
        .map((e) => e.key)
        .toList();

    final slowFeatures = _featureStates.entries
        .where((e) => e.value.initializationTime != null && 
                     e.value.initializationTime!.inMilliseconds > 1000)
        .map((e) => e.key)
        .toList();

    return IntegrationHealthReport(
      totalFeatures: totalFeatures,
      enabledFeatures: enabledCount,
      totalErrors: errorCount,
      averageInitTime: avgInitTime,
      failedFeatures: failedFeatures,
      slowFeatures: slowFeatures,
      isHealthy: errorCount == 0 && failedFeatures.isEmpty,
    );
  }

  /// Generate integration report
  String generateIntegrationReport() {
    final health = getHealthReport();
    final buffer = StringBuffer();
    
    buffer.writeln('=== Feature Integration Report ===');
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln();
    
    buffer.writeln('Overview:');
    buffer.writeln('  Total features: ${health.totalFeatures}');
    buffer.writeln('  Enabled features: ${health.enabledFeatures}');
    buffer.writeln('  Total errors: ${health.totalErrors}');
    buffer.writeln('  Average init time: ${health.averageInitTime.toStringAsFixed(2)}ms');
    buffer.writeln('  System healthy: ${health.isHealthy}');
    buffer.writeln();
    
    if (health.failedFeatures.isNotEmpty) {
      buffer.writeln('Failed Features:');
      for (final featureId in health.failedFeatures) {
        final state = _featureStates[featureId];
        buffer.writeln('  $featureId: ${state?.lastError ?? "Unknown error"}');
      }
      buffer.writeln();
    }
    
    if (health.slowFeatures.isNotEmpty) {
      buffer.writeln('Slow Features (>1s init):');
      for (final featureId in health.slowFeatures) {
        final state = _featureStates[featureId];
        buffer.writeln('  $featureId: ${state?.initializationTime?.inMilliseconds ?? 0}ms');
      }
      buffer.writeln();
    }
    
    buffer.writeln('Feature Details:');
    for (final feature in _registeredFeatures.values) {
      final state = _featureStates[feature.id];
      buffer.writeln('  ${feature.id}:');
      buffer.writeln('    Enabled: ${state?.isEnabled ?? false}');
      buffer.writeln('    Initialized: ${state?.isInitialized ?? false}');
      buffer.writeln('    Errors: ${state?.errorCount ?? 0}');
      if (state?.initializationTime != null) {
        buffer.writeln('    Init time: ${state!.initializationTime!.inMilliseconds}ms');
      }
    }
    
    return buffer.toString();
  }

  // Private methods

  Future<void> _registerCoreFeatures() async {
    // Register core glassmorphism features
    registerFeature(GlassmorphismCoreFeature());
    registerFeature(AccessibilityFeature());
    registerFeature(FeatureDiscoveryFeature());
    registerFeature(ErrorHandlingFeature());
    registerFeature(NavigationFeature());
  }

  void _applyIntegrationRules() {
    for (final rule in _integrationRules) {
      _applyIntegrationRule(rule);
    }
  }

  void _applyIntegrationRule(FeatureIntegrationRule rule) {
    try {
      rule.apply(_registeredFeatures, _featureStates);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Failed to apply integration rule: $error');
      }
    }
  }

  Future<void> _initializeEnabledFeatures() async {
    final enabledByDefault = _registeredFeatures.values
        .where((f) => f.defaultEnabled)
        .toList();

    for (final feature in enabledByDefault) {
      await enableFeature(feature.id);
    }
  }

  bool _checkDependencies(FeatureModule feature) {
    for (final dependency in feature.dependencies) {
      if (!isFeatureEnabled(dependency)) {
        return false;
      }
    }
    return true;
  }

  void _recordFeatureError(String featureId, String error) {
    final state = _featureStates[featureId];
    if (state != null) {
      _featureStates[featureId] = state.copyWith(
        errorCount: state.errorCount + 1,
        lastError: error,
      );
    }
    
    if (kDebugMode) {
      debugPrint('[ERROR] Feature error [$featureId]: $error');
    }
  }
}

/// Base class for feature modules
abstract class FeatureModule {
  String get id;
  String get name;
  String get description;
  List<String> get dependencies;
  bool get defaultEnabled;
  
  FeatureDiscoveryConfig? get discoveryConfig => null;
  TourStep? get tourStep => null;

  Future<bool> initialize(Map<String, dynamic> config);
  Future<void> dispose();
  Widget? buildWidget(BuildContext context) => null;
  Map<String, dynamic> exportState() => {};
}

/// Feature state tracking
class FeatureState {
  final String id;
  final bool isEnabled;
  final bool isInitialized;
  final Duration? initializationTime;
  final int errorCount;
  final String? lastError;

  const FeatureState({
    required this.id,
    required this.isEnabled,
    required this.isInitialized,
    required this.initializationTime,
    required this.errorCount,
    required this.lastError,
  });

  FeatureState copyWith({
    bool? isEnabled,
    bool? isInitialized,
    Duration? initializationTime,
    int? errorCount,
    String? lastError,
  }) {
    return FeatureState(
      id: id,
      isEnabled: isEnabled ?? this.isEnabled,
      isInitialized: isInitialized ?? this.isInitialized,
      initializationTime: initializationTime ?? this.initializationTime,
      errorCount: errorCount ?? this.errorCount,
      lastError: lastError ?? this.lastError,
    );
  }
}

/// Feature discovery configuration
class FeatureDiscoveryConfig {
  final String title;
  final String description;
  final GlobalKey targetKey;
  final IconData? icon;

  const FeatureDiscoveryConfig({
    required this.title,
    required this.description,
    required this.targetKey,
    this.icon,
  });
}

/// Feature integration rule
abstract class FeatureIntegrationRule {
  void apply(
    Map<String, FeatureModule> features,
    Map<String, FeatureState> states,
  );
}

/// Integration health report
class IntegrationHealthReport {
  final int totalFeatures;
  final int enabledFeatures;
  final int totalErrors;
  final double averageInitTime;
  final List<String> failedFeatures;
  final List<String> slowFeatures;
  final bool isHealthy;

  const IntegrationHealthReport({
    required this.totalFeatures,
    required this.enabledFeatures,
    required this.totalErrors,
    required this.averageInitTime,
    required this.failedFeatures,
    required this.slowFeatures,
    required this.isHealthy,
  });
}

// Core feature implementations

/// Core glassmorphism feature
class GlassmorphismCoreFeature extends FeatureModule {
  @override
  String get id => 'glassmorphism_core';
  
  @override
  String get name => 'Glassmorphism Core';
  
  @override
  String get description => 'Core glassmorphism rendering and effects';
  
  @override
  List<String> get dependencies => [];
  
  @override
  bool get defaultEnabled => true;

  @override
  Future<bool> initialize(Map<String, dynamic> config) async {
    // Initialize glassmorphism core systems
    await Future.delayed(const Duration(milliseconds: 50));
    return true;
  }

  @override
  Future<void> dispose() async {
    // Cleanup glassmorphism resources
  }
}

/// Accessibility feature
class AccessibilityFeature extends FeatureModule {
  @override
  String get id => 'accessibility';
  
  @override
  String get name => 'Accessibility Support';
  
  @override
  String get description => 'WCAG AA accessibility compliance';
  
  @override
  List<String> get dependencies => ['glassmorphism_core'];
  
  @override
  bool get defaultEnabled => true;

  @override
  Future<bool> initialize(Map<String, dynamic> config) async {
    // Initialize accessibility systems
    await Future.delayed(const Duration(milliseconds: 30));
    return true;
  }

  @override
  Future<void> dispose() async {
    // Cleanup accessibility resources
  }
}


/// Feature discovery feature
class FeatureDiscoveryFeature extends FeatureModule {
  @override
  String get id => 'feature_discovery';
  
  @override
  String get name => 'Feature Discovery';
  
  @override
  String get description => 'Interactive feature discovery and tours';
  
  @override
  List<String> get dependencies => ['glassmorphism_core'];
  
  @override
  bool get defaultEnabled => true;

  @override
  Future<bool> initialize(Map<String, dynamic> config) async {
    // Initialize feature discovery
    await Future.delayed(const Duration(milliseconds: 20));
    return true;
  }

  @override
  Future<void> dispose() async {
    FeatureDiscovery.instance.resetFeatures();
  }
}

/// Error handling feature
class ErrorHandlingFeature extends FeatureModule {
  @override
  String get id => 'error_handling';
  
  @override
  String get name => 'Error Handling';
  
  @override
  String get description => 'Comprehensive error handling with glassmorphism UI';
  
  @override
  List<String> get dependencies => ['glassmorphism_core'];
  
  @override
  bool get defaultEnabled => true;

  @override
  Future<bool> initialize(Map<String, dynamic> config) async {
    // Initialize error handling
    await Future.delayed(const Duration(milliseconds: 25));
    return true;
  }

  @override
  Future<void> dispose() async {
    // Cleanup error handling resources
  }
}

/// Navigation feature
class NavigationFeature extends FeatureModule {
  @override
  String get id => 'navigation';
  
  @override
  String get name => 'Navigation';
  
  @override
  String get description => 'Glassmorphism navigation with accessibility';
  
  @override
  List<String> get dependencies => ['glassmorphism_core', 'accessibility'];
  
  @override
  bool get defaultEnabled => true;

  @override
  Future<bool> initialize(Map<String, dynamic> config) async {
    // Initialize navigation systems
    await Future.delayed(const Duration(milliseconds: 40));
    return true;
  }

  @override
  Future<void> dispose() async {
    // Cleanup navigation resources
  }
}

/// Dependency-based integration rule
class DependencyIntegrationRule extends FeatureIntegrationRule {
  @override
  void apply(
    Map<String, FeatureModule> features,
    Map<String, FeatureState> states,
  ) {
    // Automatically enable dependencies when a feature is enabled
    for (final feature in features.values) {
      final state = states[feature.id];
      if (state?.isEnabled == true) {
        for (final dependency in feature.dependencies) {
          final depState = states[dependency];
          if (depState?.isEnabled == false) {
            // Auto-enable dependency
            states[dependency] = depState!.copyWith(isEnabled: true);
          }
        }
      }
    }
  }
}

/// Performance-based integration rule
class PerformanceIntegrationRule extends FeatureIntegrationRule {
  @override
  void apply(
    Map<String, FeatureModule> features,
    Map<String, FeatureState> states,
  ) {
    // Adaptive feature management based on system state
    // Keep all features enabled by default
    // Future: Add adaptive disabling based on battery/memory constraints
    // Non-essential features like 'feature_discovery' can be disabled if needed
  }
}

/// Accessibility-based integration rule
class AccessibilityIntegrationRule extends FeatureIntegrationRule {
  @override
  void apply(
    Map<String, FeatureModule> features,
    Map<String, FeatureState> states,
  ) {
    // Ensure accessibility is always enabled if any other feature is enabled
    final hasEnabledFeatures = states.values.any((s) => s.isEnabled && s.id != 'accessibility');
    
    if (hasEnabledFeatures) {
      final accessibilityState = states['accessibility'];
      if (accessibilityState?.isEnabled == false) {
        states['accessibility'] = accessibilityState!.copyWith(isEnabled: true);
      }
    }
  }
}