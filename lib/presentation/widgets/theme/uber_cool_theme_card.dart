import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme_data.dart';
import '../../../core/theme/typography_constants.dart';

/// Ultra-cool, performant theme card with minimal animations and maximum visual impact
class UberCoolThemeCard extends StatefulWidget {
  final AppThemeData theme;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String searchQuery;
  final double? height;

  const UberCoolThemeCard({
    super.key,
    required this.theme,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
    this.searchQuery = '',
    this.height,
  });

  @override
  State<UberCoolThemeCard> createState() => _UberCoolThemeCardState();
}

class _UberCoolThemeCardState extends State<UberCoolThemeCard>
    with SingleTickerProviderStateMixin {
  
  // Single animation controller for all interactions
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;
  late Animation<double> _elevationAnimation;
  
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _hoverAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _hoverController, curve: Curves.easeOut));
    
    _elevationAnimation = Tween<double>(begin: 2.0, end: 8.0)
        .animate(_hoverAnimation);
  }

  @override
  void dispose() {
    _hoverController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: GestureDetector(
        onTap: () {
          widget.onTap?.call();
          HapticFeedback.mediumImpact();
        },
        onLongPress: () {
          widget.onLongPress?.call();
          HapticFeedback.heavyImpact();
        },
        child: AnimatedBuilder(
          animation: _hoverAnimation,
          builder: (context, child) => _buildCard(theme),
        ),
      ),
    );
  }

  Widget _buildCard(ThemeData theme) {
    final colors = widget.theme.colors;
    final metadata = widget.theme.metadata;
    final isDark = metadata.id.contains('dark') || metadata.id.contains('_dark');

    return Container(
      height: widget.height ?? 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1 + (_hoverAnimation.value * 0.1)),
            blurRadius: _elevationAnimation.value,
            spreadRadius: _hoverAnimation.value * 1.5,
            offset: Offset(0, _elevationAnimation.value * 0.5),
          ),
          if (widget.isSelected)
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 0),
            )]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [// Base background with theme surface
            Container(
              decoration: BoxDecoration(
                color: colors.surface,
                border: widget.isSelected 
                    ? Border.all(color: colors.primary.withValues(alpha: 0.4), width: 2)
                    : Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
              ),
            ),
            
            // Color palette preview strip
            _buildColorPaletteStrip(),
            
            // Glassmorphism overlay
            _buildGlassmorphismOverlay(isDark),
            
            // Content
            _buildCardContent(theme, metadata, colors),
            
            // Selection indicator
            if (widget.isSelected) _buildSelectionIndicator(),
            
            // Hover glow overlay
            if (_isHovered) _buildHoverGlow(colors)]),
      ),
    );
  }

  Widget _buildColorPaletteStrip() {
    final colors = widget.theme.colors;
    
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 4,
      child: Row(
        children: [Expanded(
            flex: 2,
            child: Container(color: colors.primary),
          ),
          Expanded(
            flex: 2,
            child: Container(color: colors.secondary),
          ),
          Expanded(
            flex: 1,
            child: Container(color: colors.accent),
          ),
          if (colors.tertiary != colors.accent) ...[
            Expanded(
              flex: 1,
              child: Container(color: colors.tertiary),
            ),]]),
    );
  }

  Widget _buildGlassmorphismOverlay(bool isDark) {
    return Positioned.fill(
      top: 4, // Start below color strip
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              (isDark ? Colors.black : Colors.white).withValues(alpha: 0.8),
            ],
            stops: const [0.3, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(ThemeData theme, dynamic metadata, dynamic colors) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [const SizedBox(height: 8), // Space for color strip
          
          // Theme name - smaller, 2-line, centered
          Center(
            child: _buildHighlightedText(
              metadata.name,
              TextStyle(
                fontSize: TypographyConstants.textBase,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
                letterSpacing: 0.2,
                height: 1.2,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
          
          const Spacer(),
          
          // Color demonstration rectangles
          _buildColorDemoRectangles(colors)]),
    );
  }

  Widget _buildHighlightedText(String text, TextStyle style, {int? maxLines, TextAlign? textAlign}) {
    if (widget.searchQuery.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        textAlign: textAlign ?? TextAlign.start,
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
        textAlign: textAlign ?? TextAlign.start,
        overflow: maxLines != null ? TextOverflow.ellipsis : null,
      );
    }

    return RichText(
      maxLines: maxLines,
      textAlign: textAlign ?? TextAlign.start,
      overflow: maxLines != null ? TextOverflow.ellipsis : TextOverflow.visible,
      text: TextSpan(
        style: style,
        children: [TextSpan(text: text.substring(0, queryIndex)),
          TextSpan(
            text: text.substring(queryIndex, queryIndex + query.length),
            style: style.copyWith(
              backgroundColor: widget.theme.colors.primary.withValues(alpha: 0.3),
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: text.substring(queryIndex + query.length))]),
    );
  }

  Widget _buildColorDemoRectangles(dynamic colors) {
    return Column(
      children: [Row(
          children: [
            // Primary color demo
            Expanded(
              flex: 2,
              child: Container(
                height: 32,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    PhosphorIcons.circle(),
                    color: colors.onPrimary,
                    size: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            // Surface color demo
            Expanded(
              flex: 3,
              child: Container(
                height: 32,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colors.outline.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 12,
                        height: 3,
                        decoration: BoxDecoration(
                          color: colors.onSurface.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Container(
                        width: 16,
                        height: 3,
                        decoration: BoxDecoration(
                          color: colors.onSurface.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      )]),
                ),
              ),
            ),
            const SizedBox(width: 6),
            // Accent color demo
            Expanded(
              flex: 1,
              child: Container(
                height: 32,
                decoration: BoxDecoration(
                  color: colors.accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colors.onSecondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            )]),
        const SizedBox(height: 6),
        // Secondary color demo - full width, shorter
        Container(
          height: 20,
          decoration: BoxDecoration(
            color: colors.secondary,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.onSecondary,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.onSecondary,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.onSecondary,
                  shape: BoxShape.circle,
                ),
              )]),
        )]);
  }

  Widget _buildSelectionIndicator() {
    return Positioned(
      top: 85,
      right: 12,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: widget.theme.colors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.theme.colors.primary.withValues(alpha: 0.4),
              blurRadius: 8,
              spreadRadius: 1,
            )]),
        child: Icon(
          PhosphorIcons.check(),
          color: widget.theme.colors.onPrimary,
          size: 14,
        ),
      ),
    );
  }

  Widget _buildHoverGlow(dynamic colors) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colors.primary.withValues(alpha: 0.3 * _hoverAnimation.value),
            width: 1,
          ),
        ),
      ),
    );
  }

}

