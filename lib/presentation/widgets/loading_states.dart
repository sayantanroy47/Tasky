import 'package:flutter/material.dart';
import '../../core/design_system/design_tokens.dart';
import '../../core/accessibility/accessibility_constants.dart';
import '../../core/theme/typography_constants.dart';
import 'glassmorphism_container.dart';

/// Comprehensive loading states with glassmorphism design
class LoadingStates {
  /// Skeleton loader for list items
  static Widget skeletonList({
    int itemCount = 5,
    double itemHeight = 80,
    EdgeInsetsGeometry? padding,
  }) {
    return ListView.builder(
      padding: padding ?? const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: SkeletonTaskCard(height: itemHeight),
      ),
    );
  }

  /// Skeleton loader for grid items
  static Widget skeletonGrid({
    int itemCount = 6,
    int crossAxisCount = 2,
    double childAspectRatio = 1.0,
    EdgeInsetsGeometry? padding,
  }) {
    return GridView.builder(
      padding: padding ?? const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => const SkeletonCard(),
    );
  }

  /// Inline loading indicator
  static Widget inline({
    String? message,
    Color? color,
    double size = 20,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: color,
          ),
        ),
        if (message != null) ...[
          const SizedBox(width: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: TypographyConstants.textSM,
              color: color,
            ),
          ),
        ],
      ],
    );
  }

  /// Full screen loading overlay
  static Widget overlay({
    required Widget child,
    required bool isLoading,
    String message = 'Loading...',
    Color? backgroundColor,
  }) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: backgroundColor ?? Colors.black.withOpacity(0.3),
              child: Center(
                child: GlassLoadingIndicator(message: message),
              ),
            ),
          ),
      ],
    );
  }
}

/// Skeleton task card for loading states
class SkeletonTaskCard extends StatelessWidget {
  final double height;
  final EdgeInsetsGeometry? margin;

  const SkeletonTaskCard({
    super.key,
    this.height = 80,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Loading task card',
      child: Container(
        height: height,
        margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: GlassmorphismContainer(
          level: GlassLevel.content,
          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
          padding: const EdgeInsets.all(16),
          child: ShimmerEffect(
            duration: const Duration(milliseconds: 1500),
            child: _buildSkeletonContent(context, theme),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonContent(BuildContext context, ThemeData theme) {
    final color = theme.colorScheme.onSurface.withOpacity(0.3);

    return Row(
      children: [
        // Priority indicator
        Container(
          width: 4,
          height: height - 32,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title line
              Container(
                height: 16,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Description line
              Container(
                height: 12,
                width: MediaQuery.of(context).size.width * 0.6,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              
              const Spacer(),
              
              // Bottom row (date and priority)
              Row(
                children: [
                  Container(
                    height: 10,
                    width: 60,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 10,
                    width: 40,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Skeleton card for grid layouts
class SkeletonCard extends StatelessWidget {
  final EdgeInsetsGeometry? margin;

  const SkeletonCard({
    super.key,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Loading card',
      child: Container(
        margin: margin,
        child: GlassmorphismContainer(
          level: GlassLevel.content,
          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
          padding: const EdgeInsets.all(16),
          child: ShimmerEffect(
            duration: const Duration(milliseconds: 1500),
            child: _buildContent(context, theme),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme) {
    final color = theme.colorScheme.onSurface.withOpacity(0.3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          height: 20,
          width: double.infinity,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Content lines
        Container(
          height: 14,
          width: double.infinity,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(7),
          ),
        ),
        
        const SizedBox(height: 8),
        
        Container(
          height: 14,
          width: MediaQuery.of(context).size.width * 0.7,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(7),
          ),
        ),
        
        const Spacer(),
        
        // Footer
        Container(
          height: 12,
          width: 80,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }
}

/// Glass loading indicator with message
class GlassLoadingIndicator extends StatelessWidget {
  final String message;
  final Color? color;
  final double size;

  const GlassLoadingIndicator({
    super.key,
    this.message = 'Loading...',
    this.color,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLargeText = AccessibilityUtils.isLargeTextEnabled(context);
    final shouldReduceMotion = AccessibilityUtils.shouldReduceMotion(context);

    return Semantics(
      label: 'Loading: $message',
      liveRegion: true,
      child: GlassmorphismContainer(
        level: GlassLevel.floating,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Loading spinner
            SizedBox(
              width: size,
              height: size,
              child: shouldReduceMotion
                  ? Icon(
                      Icons.hourglass_empty,
                      size: size,
                      color: color ?? theme.colorScheme.primary,
                    )
                  : CircularProgressIndicator(
                      color: color ?? theme.colorScheme.primary,
                      strokeWidth: 3,
                    ),
            ),
            
            const SizedBox(height: 16),
            
            // Loading message
            Text(
              message,
              style: TextStyle(
                fontSize: isLargeText 
                    ? TypographyConstants.textBase 
                    : TypographyConstants.textSM,
                fontWeight: TypographyConstants.medium,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Progress indicator with glassmorphism
class GlassProgressIndicator extends StatelessWidget {
  final double progress;
  final String? label;
  final Color? color;
  final Color? backgroundColor;
  final double height;
  final BorderRadiusGeometry? borderRadius;

  const GlassProgressIndicator({
    super.key,
    required this.progress,
    this.label,
    this.color,
    this.backgroundColor,
    this.height = 8,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = color ?? theme.colorScheme.primary;
    final bgColor = backgroundColor ?? theme.colorScheme.surfaceContainerHighest;

    return Semantics(
      label: label != null 
          ? '$label: ${(progress * 100).round()}% complete'
          : '${(progress * 100).round()}% complete',
      value: '${(progress * 100).round()}%',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: TextStyle(
                fontSize: TypographyConstants.textSM,
                fontWeight: TypographyConstants.medium,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
          ],
          
          GlassmorphismContainer(
            level: GlassLevel.content,
            height: height,
            borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
            glassTint: bgColor.withOpacity(0.3),
            child: Stack(
              children: [
                // Progress fill
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    height: height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          progressColor,
                          progressColor.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Percentage text
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(progress * 100).round()}%',
              style: TextStyle(
                fontSize: TypographyConstants.textXS,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer effect for loading states
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final Duration duration;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.enabled = true,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
    
    if (widget.enabled && !AccessibilityUtils.shouldReduceMotion(context)) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shouldReduceMotion = AccessibilityUtils.shouldReduceMotion(context);

    if (!widget.enabled || shouldReduceMotion) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.surface.withOpacity(0.1),
                theme.colorScheme.onSurface.withOpacity(0.3),
                theme.colorScheme.surface.withOpacity(0.1),
              ],
              stops: [
                _animation.value - 0.5,
                _animation.value,
                _animation.value + 0.5,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}