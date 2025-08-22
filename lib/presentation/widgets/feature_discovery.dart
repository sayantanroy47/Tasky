import 'package:flutter/material.dart';
import '../../core/design_system/design_tokens.dart';
import '../../core/accessibility/accessibility_constants.dart';
import '../../core/theme/typography_constants.dart';
import 'glassmorphism_container.dart';
import 'accessible_button.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Feature discovery system with glassmorphism tooltips and guided tours
class FeatureDiscovery {
  static FeatureDiscovery? _instance;
  static FeatureDiscovery get instance => _instance ??= FeatureDiscovery._internal();
  
  FeatureDiscovery._internal();

  final Set<String> _shownFeatures = {};
  final Map<String, FeatureSpotlight> _activeSpotlights = {};

  /// Show a feature tooltip
  void showFeature({
    required BuildContext context,
    required String featureId,
    required String title,
    required String description,
    required GlobalKey targetKey,
    IconData? icon,
    VoidCallback? onNext,
    VoidCallback? onSkip,
    VoidCallback? onComplete,
    Duration? autoHideDuration,
    bool canDismiss = true,
    TooltipPosition position = TooltipPosition.auto,
  }) {
    if (_shownFeatures.contains(featureId)) return;

    final spotlight = FeatureSpotlight(
      featureId: featureId,
      title: title,
      description: description,
      targetKey: targetKey,
      icon: icon,
      onNext: onNext,
      onSkip: onSkip,
      onComplete: onComplete,
      canDismiss: canDismiss,
      position: position,
    );

    _activeSpotlights[featureId] = spotlight;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      barrierDismissible: canDismiss,
      builder: (context) => FeatureSpotlightOverlay(
        spotlight: spotlight,
        onDismiss: () => _dismissFeature(featureId),
      ),
    );

    // Auto hide if duration is specified
    if (autoHideDuration != null) {
      Future.delayed(autoHideDuration, () {
        if (_activeSpotlights.containsKey(featureId) && context.mounted) {
          _dismissFeature(featureId);
          Navigator.of(context).pop();
        }
      });
    }

    // Mark as shown
    _shownFeatures.add(featureId);

    // Announce for accessibility
    AccessibilityUtils.announceToScreenReader(
      context,
      'New feature: $title. $description',
    );
  }

  /// Start a guided tour
  void startGuidedTour({
    required BuildContext context,
    required List<TourStep> steps,
    VoidCallback? onComplete,
    VoidCallback? onSkip,
  }) {
    if (steps.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GuidedTour(
        steps: steps,
        onComplete: onComplete,
        onSkip: onSkip,
      ),
    );
  }

  /// Show contextual hint
  void showHint({
    required BuildContext context,
    required String message,
    required GlobalKey targetKey,
    Duration duration = const Duration(seconds: 3),
    IconData? icon,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => ContextualHint(
        message: message,
        targetKey: targetKey,
        icon: icon,
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);

    // Auto dismiss
    Future.delayed(duration, () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }

  /// Dismiss a feature
  void _dismissFeature(String featureId) {
    _activeSpotlights.remove(featureId);
  }

  /// Check if feature has been shown
  bool hasShownFeature(String featureId) {
    return _shownFeatures.contains(featureId);
  }

  /// Reset all shown features (for testing)
  void resetFeatures() {
    _shownFeatures.clear();
    _activeSpotlights.clear();
  }
}

/// Feature spotlight overlay
class FeatureSpotlightOverlay extends StatefulWidget {
  final FeatureSpotlight spotlight;
  final VoidCallback onDismiss;

  const FeatureSpotlightOverlay({
    super.key,
    required this.spotlight,
    required this.onDismiss,
  });

  @override
  State<FeatureSpotlightOverlay> createState() => _FeatureSpotlightOverlayState();
}

class _FeatureSpotlightOverlayState extends State<FeatureSpotlightOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Stack(
            children: [
              // Spotlight effect
              _buildSpotlight(),
              
              // Tooltip
              _buildTooltip(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpotlight() {
    final RenderBox? renderBox = widget.spotlight.targetKey.currentContext
        ?.findRenderObject() as RenderBox?;
    
    if (renderBox == null) {
      return const SizedBox.shrink();
    }

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    return Positioned(
      left: position.dx - 20,
      top: position.dy - 20,
      child: Container(
        width: size.width + 40,
        height: size.height + 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTooltip() {
    final theme = Theme.of(context);
    final isLargeText = AccessibilityUtils.isLargeTextEnabled(context);
    final shouldReduceMotion = AccessibilityUtils.shouldReduceMotion(context);

    return Center(
      child: Transform.scale(
        scale: shouldReduceMotion ? 1.0 : _scaleAnimation.value,
        child: GlassmorphismContainer(
          level: GlassLevel.floating,
          width: MediaQuery.of(context).size.width * 0.85,
          borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              if (widget.spotlight.icon != null) ...[
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withValues(alpha: 0.7),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.spotlight.icon,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Title
              Semantics(
                header: true,
                child: Text(
                  widget.spotlight.title,
                  style: TextStyle(
                    fontSize: isLargeText 
                        ? TypographyConstants.textXL 
                        : TypographyConstants.textLG,
                    fontWeight: TypographyConstants.medium,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Description
              Text(
                widget.spotlight.description,
                style: TextStyle(
                  fontSize: isLargeText 
                      ? TypographyConstants.textBase 
                      : TypographyConstants.textSM,
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Action buttons
              Row(
                children: [
                  if (widget.spotlight.onSkip != null) ...[
                    Expanded(
                      child: AccessibleButton.secondary(
                        label: 'Skip',
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.spotlight.onSkip?.call();
                          widget.onDismiss();
                        },
                        semanticHint: 'Skip this feature introduction',
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  
                  Expanded(
                    child: AccessibleButton.primary(
                      label: widget.spotlight.onNext != null ? 'Next' : 'Got It',
                      icon: widget.spotlight.onNext != null 
                          ? PhosphorIcons.arrowRight() 
                          : PhosphorIcons.check(),
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (widget.spotlight.onNext != null) {
                          widget.spotlight.onNext!();
                        } else {
                          widget.spotlight.onComplete?.call();
                        }
                        widget.onDismiss();
                      },
                      semanticHint: widget.spotlight.onNext != null
                          ? 'Continue to next feature'
                          : 'Acknowledge and close feature introduction',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Guided tour widget
class GuidedTour extends StatefulWidget {
  final List<TourStep> steps;
  final VoidCallback? onComplete;
  final VoidCallback? onSkip;

  const GuidedTour({
    super.key,
    required this.steps,
    this.onComplete,
    this.onSkip,
  });

  @override
  State<GuidedTour> createState() => _GuidedTourState();
}

class _GuidedTourState extends State<GuidedTour> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_currentStep];
    
    return FeatureSpotlightOverlay(
      spotlight: FeatureSpotlight(
        featureId: 'tour_step_$_currentStep',
        title: '${_currentStep + 1} of ${widget.steps.length}: ${step.title}',
        description: step.description,
        targetKey: step.targetKey,
        icon: step.icon,
        onNext: _currentStep < widget.steps.length - 1 ? _nextStep : null,
        onSkip: widget.onSkip,
        onComplete: _currentStep == widget.steps.length - 1 ? widget.onComplete : null,
      ),
      onDismiss: () {},
    );
  }

  void _nextStep() {
    if (_currentStep < widget.steps.length - 1) {
      setState(() => _currentStep++);
    }
  }
}

/// Contextual hint widget
class ContextualHint extends StatefulWidget {
  final String message;
  final GlobalKey targetKey;
  final IconData? icon;
  final VoidCallback onDismiss;

  const ContextualHint({
    super.key,
    required this.message,
    required this.targetKey,
    this.icon,
    required this.onDismiss,
  });

  @override
  State<ContextualHint> createState() => _ContextualHintState();
}

class _ContextualHintState extends State<ContextualHint>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final RenderBox? renderBox = widget.targetKey.currentContext
        ?.findRenderObject() as RenderBox?;
    
    if (renderBox == null) {
      return const SizedBox.shrink();
    }

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final theme = Theme.of(context);

    return Positioned(
      left: position.dx,
      top: position.dy + size.height + 8,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: GestureDetector(
                onTap: widget.onDismiss,
                child: Semantics(
                  label: 'Hint: ${widget.message}',
                  button: true,
                  hint: 'Tap to dismiss',
                  child: GlassmorphismContainer(
                    level: GlassLevel.floating,
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    glassTint: theme.colorScheme.primaryContainer.withValues(alpha: 0.9),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            size: 16,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(
                            widget.message,
                            style: TextStyle(
                              fontSize: TypographyConstants.textXS,
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: TypographyConstants.medium,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          PhosphorIcons.x(),
                          size: 14,
                          color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Feature spotlight data model
class FeatureSpotlight {
  final String featureId;
  final String title;
  final String description;
  final GlobalKey targetKey;
  final IconData? icon;
  final VoidCallback? onNext;
  final VoidCallback? onSkip;
  final VoidCallback? onComplete;
  final bool canDismiss;
  final TooltipPosition position;

  FeatureSpotlight({
    required this.featureId,
    required this.title,
    required this.description,
    required this.targetKey,
    this.icon,
    this.onNext,
    this.onSkip,
    this.onComplete,
    this.canDismiss = true,
    this.position = TooltipPosition.auto,
  });
}

/// Tour step data model
class TourStep {
  final String title;
  final String description;
  final GlobalKey targetKey;
  final IconData? icon;
  final VoidCallback? action;

  TourStep({
    required this.title,
    required this.description,
    required this.targetKey,
    this.icon,
    this.action,
  });
}

/// Tooltip position options
enum TooltipPosition {
  auto,
  above,
  below,
  left,
  right,
  center,
}

/// Feature discovery helper widget
class FeatureHighlight extends StatelessWidget {
  final GlobalKey featureKey;
  final Widget child;
  final String? featureId;
  final String? title;
  final String? description;
  final IconData? icon;
  final bool autoShow;

  const FeatureHighlight({
    super.key,
    required this.featureKey,
    required this.child,
    this.featureId,
    this.title,
    this.description,
    this.icon,
    this.autoShow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: featureKey,
      child: child,
    );
  }

  void show(BuildContext context) {
    if (featureId != null && title != null && description != null) {
      FeatureDiscovery.instance.showFeature(
        context: context,
        featureId: featureId!,
        title: title!,
        description: description!,
        targetKey: featureKey,
        icon: icon,
      );
    }
  }
}

