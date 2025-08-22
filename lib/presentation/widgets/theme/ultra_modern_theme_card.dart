import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme_data.dart';
import '../../../core/theme/typography_constants.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';


/// Ultra-modern theme card with refined design and micro-interactions
class UltraModernThemeCard extends StatefulWidget {
  final AppThemeData theme;
  final bool isSelected;
  final double height;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String searchQuery;

  const UltraModernThemeCard({
    super.key,
    required this.theme,
    this.isSelected = false,
    this.height = 280,
    this.onTap,
    this.onLongPress,
    this.searchQuery = '',
  });

  @override
  State<UltraModernThemeCard> createState() => _UltraModernThemeCardState();
}

class _UltraModernThemeCardState extends State<UltraModernThemeCard>
    with TickerProviderStateMixin {
  
  // Animation Controllers
  late AnimationController _hoverController;
  late AnimationController _effectController;
  late AnimationController _selectionController;
  late AnimationController _pressController;
  
  // Animations
  late Animation<double> _hoverAnimation;
  late Animation<double> _effectAnimation;
  late Animation<double> _selectionAnimation;
  late Animation<double> _pressAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<double> _borderAnimation;
  
  // State
  bool _isHovered = false;
  // bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Hover animation
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _hoverAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic));

    // Continuous effect animation
    _effectController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    _effectAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _effectController, curve: Curves.linear));

    // Selection animation
    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _selectionAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _selectionController, curve: Curves.elasticOut));

    // Press animation
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _pressAnimation = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _pressController, curve: Curves.easeInOut));

    // Derived animations
    _elevationAnimation = Tween<double>(begin: 2.0, end: 8.0)
        .animate(_hoverAnimation);
    _borderAnimation = Tween<double>(begin: 0.1, end: 0.3)
        .animate(_hoverAnimation);

    // Start selection animation if selected
    if (widget.isSelected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _selectionController.forward();
      });
    }
  }

  @override
  void didUpdateWidget(UltraModernThemeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _selectionController.forward();
      } else {
        _selectionController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _effectController.dispose();
    _selectionController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _handleHover(bool hovered) {
    if (_isHovered != hovered) {
      setState(() => _isHovered = hovered);
      if (hovered) {
        _hoverController.forward();
        HapticFeedback.selectionClick();
      } else {
        _hoverController.reverse();
      }
    }
  }

  void _handleTapDown() {
    // setState(() => _isPressed = true);
    _pressController.forward();
  }

  void _handleTapUp() {
    // setState(() => _isPressed = false);
    _pressController.reverse();
  }

  void _handleTap() {
    widget.onTap?.call();
    HapticFeedback.mediumImpact();
  }

  void _handleLongPress() {
    widget.onLongPress?.call();
    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: GestureDetector(
        onTap: _handleTap,
        onLongPress: _handleLongPress,
        onTapDown: (_) => _handleTapDown(),
        onTapUp: (_) => _handleTapUp(),
        onTapCancel: () => _handleTapUp(),
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _hoverAnimation,
            _effectAnimation,
            _selectionAnimation,
            _pressAnimation,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: _pressAnimation.value,
              child: _buildUltraModernCard(theme),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUltraModernCard(ThemeData theme) {
    final colors = widget.theme.colors;
    final metadata = widget.theme.metadata;
    final isDark = metadata.id.contains('dark') || metadata.id.contains('_dark');

    return Container(
      height: widget.height,
      margin: EdgeInsets.only(bottom: 8 + (_hoverAnimation.value * 4)),
      child: Stack(
        children: [
          // Main card container with ultra-modern styling
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard * 1.5),
              boxShadow: [
                // Primary shadow
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.1 + (_hoverAnimation.value * 0.15)),
                  blurRadius: _elevationAnimation.value * 2,
                  spreadRadius: _hoverAnimation.value * 2,
                  offset: Offset(0, _elevationAnimation.value),
                ),
                // Selection glow
                if (widget.isSelected)
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.3 + (_selectionAnimation.value * 0.2)),
                    blurRadius: 20 + (_selectionAnimation.value * 10),
                    spreadRadius: 2 + (_selectionAnimation.value * 3),
                    offset: const Offset(0, 0),
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard * 1.5),
              child: Stack(
                children: [
                  // Ultra-modern background
                  _buildUltraModernBackground(colors, isDark),
                  
                  // Glassmorphism overlay
                  _buildGlassmorphismOverlay(theme, colors),
                  
                  // Content
                  _buildCardContent(theme, colors, metadata),
                  
                  // Selection indicator
                  if (widget.isSelected) _buildSelectionIndicator(colors),
                  
                  // Ultra-thin border
                  _buildUltraThinBorder(colors),
                ],
              ),
            ),
          ),
          
          // Floating elements
          if (_isHovered) _buildFloatingElements(colors),
        ],
      ),
    );
  }

  Widget _buildUltraModernBackground(dynamic colors, bool isDark) {
    final themeId = widget.theme.metadata.id;
    
    if (themeId.contains('matrix')) {
      return _buildMatrixBackground(colors, isDark);
    } else if (themeId.contains('vegeta')) {
      return _buildEnergyBackground(colors, isDark);
    } else if (themeId.contains('dracula')) {
      return _buildDraculaBackground(colors, isDark);
    } else if (themeId.contains('expressive')) {
      return _buildExpressiveBackground(colors, isDark);
    } else {
      return _buildMinimalBackground(colors, isDark);
    }
  }

  Widget _buildMatrixBackground(dynamic colors, bool isDark) {
    return Stack(
      children: [
        // Base gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.surface,
                colors.surface.withValues(alpha: 0.8),
                colors.primary.withValues(alpha: 0.05 + (_effectAnimation.value * 0.03)),
              ],
            ),
          ),
        ),
        // Matrix rain particles
        ...List.generate(6, (i) => Positioned(
          left: (i * 40.0 + _effectAnimation.value * 20) % 300,
          top: (_effectAnimation.value * 350 + i * 60) % (widget.height + 50) - 30,
          child: Opacity(
            opacity: 0.3 + (math.sin(_effectAnimation.value * math.pi * 2 + i) * 0.2),
            child: Text(
              ['01', '10', '11', '00'][i % 4],
              style: TextStyle(
                color: colors.primary,
                fontSize: 10 + (i % 2) * 2,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildEnergyBackground(dynamic colors, bool isDark) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topRight,
              radius: 1.2 + (_effectAnimation.value * 0.3),
              colors: [
                colors.primary.withValues(alpha: 0.15 + (_effectAnimation.value * 0.05)),
                colors.secondary.withValues(alpha: 0.1),
                colors.surface,
              ],
            ),
          ),
        ),
        // Energy orbs
        Positioned(
          top: 20 + math.sin(_effectAnimation.value * math.pi * 2) * 15,
          right: 20 + math.cos(_effectAnimation.value * math.pi * 2) * 10,
          child: Container(
            width: 8 + (_effectAnimation.value * 4),
            height: 8 + (_effectAnimation.value * 4),
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.6),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colors.accent.withValues(alpha: 0.4),
                  blurRadius: 10 + (_effectAnimation.value * 5),
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDraculaBackground(dynamic colors, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors.surface,
            colors.primary.withValues(alpha: 0.08 + (_effectAnimation.value * 0.02)),
            colors.surface,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 30,
            right: 25,
            child: Transform.rotate(
              angle: _effectAnimation.value * math.pi * 2,
              child: Icon(
                PhosphorIcons.moon(),
                color: colors.accent.withValues(alpha: 0.3 + (_effectAnimation.value * 0.2)),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpressiveBackground(dynamic colors, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: SweepGradient(
          center: Alignment.center,
          startAngle: _effectAnimation.value * math.pi * 2,
          colors: [
            colors.surface,
            colors.primary.withValues(alpha: 0.1),
            colors.secondary.withValues(alpha: 0.08),
            colors.tertiary.withValues(alpha: 0.12),
            colors.surface,
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalBackground(dynamic colors, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.surface,
            colors.surfaceContainerHighest.withValues(alpha: 0.3),
            colors.surface,
          ],
        ),
      ),
    );
  }

  Widget _buildGlassmorphismOverlay(ThemeData theme, dynamic colors) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              theme.colorScheme.surface.withValues(alpha: 0.85 + (_hoverAnimation.value * 0.1)),
            ],
            stops: const [0.4, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(ThemeData theme, dynamic colors, dynamic metadata) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and theme info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ultra-modern theme icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors.primary.withValues(alpha: 0.8 + (_hoverAnimation.value * 0.2)),
                      colors.secondary.withValues(alpha: 0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.3),
                      blurRadius: 8 + (_hoverAnimation.value * 4),
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  metadata.previewIcon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              
              const Spacer(),
              
              // Popularity indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.3),
                    width: 0.1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PhosphorIcons.star(),
                      color: colors.primary,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      metadata.popularityScore.toStringAsFixed(1),
                      style: TextStyle(
                        color: colors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const Spacer(),
          
          // Theme details section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
                width: 0.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Theme name with search highlighting
                _buildHighlightedText(
                  metadata.name,
                  theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Ultra-thin color palette
                Row(
                  children: [
                    _buildUltraThinColorSwatch(colors.primary),
                    const SizedBox(width: 6),
                    _buildUltraThinColorSwatch(colors.secondary),
                    const SizedBox(width: 6),
                    _buildUltraThinColorSwatch(colors.accent),
                    
                    const Spacer(),
                    
                    // Theme category badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colors.primary.withValues(alpha: 0.2),
                          width: 0.1,
                        ),
                      ),
                      child: Text(
                        metadata.category.toUpperCase(),
                        style: TextStyle(
                          color: colors.primary,
                          fontSize: 8,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Description with search highlighting
                _buildHighlightedText(
                  metadata.description,
                  theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.3,
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedText(String text, TextStyle? style, {int? maxLines}) {
    if (widget.searchQuery.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : null,
      );
    }

    final query = widget.searchQuery.toLowerCase();
    final textLower = text.toLowerCase();
    final queryIndex = textLower.indexOf(query);

    if (queryIndex == -1) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : null,
      );
    }

    return RichText(
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : TextOverflow.visible,
      text: TextSpan(
        style: style,
        children: [
          TextSpan(text: text.substring(0, queryIndex)),
          TextSpan(
            text: text.substring(queryIndex, queryIndex + query.length),
            style: style?.copyWith(
              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(text: text.substring(queryIndex + query.length)),
        ],
      ),
    );
  }

  Widget _buildUltraThinColorSwatch(Color color) {
    return Container(
      width: 24,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 0.1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionIndicator(dynamic colors) {
    return Positioned(
      top: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: _selectionAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _selectionAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.5),
                    blurRadius: 8 + (_selectionAnimation.value * 4),
                    spreadRadius: 1 + (_selectionAnimation.value * 2),
                  ),
                ],
              ),
              child: Icon(
                PhosphorIcons.check(),
                color: colors.onPrimary,
                size: 16,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUltraThinBorder(dynamic colors) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard * 1.5),
          border: Border.all(
            color: widget.isSelected 
                ? colors.primary.withValues(alpha: 0.6 + (_selectionAnimation.value * 0.4))
                : colors.outline.withValues(alpha: 0.1 + (_hoverAnimation.value * 0.2)),
            width: widget.isSelected 
                ? 0.3 + (_selectionAnimation.value * 0.5)
                : _borderAnimation.value,
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingElements(dynamic colors) {
    return Positioned(
      top: -4,
      right: -4,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.6),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.4),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}

