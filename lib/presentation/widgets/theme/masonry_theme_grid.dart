import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_theme_data.dart';

import 'ultra_modern_theme_card.dart';

/// Pinterest-style masonry grid for theme display with dynamic card sizing
class MasonryThemeGrid extends StatefulWidget {
  final List<AppThemeData> themes;
  final AppThemeData? currentTheme;
  final Function(String) onThemeSelected;
  final Function(AppThemeData)? onThemePreview;
  final String searchQuery;
  final double spacing;
  final int columnCount;

  const MasonryThemeGrid({
    super.key,
    required this.themes,
    required this.currentTheme,
    required this.onThemeSelected,
    this.onThemePreview,
    this.searchQuery = '',
    this.spacing = 16.0,
    this.columnCount = 2,
  });

  @override
  State<MasonryThemeGrid> createState() => _MasonryThemeGridState();
}

class _MasonryThemeGridState extends State<MasonryThemeGrid>
    with TickerProviderStateMixin {
  
  late AnimationController _staggerController;
  final List<AnimationController> _cardControllers = [];
  final List<Animation<double>> _cardAnimations = [];
  final List<Animation<Offset>> _slideAnimations = [];
  
  // Layout calculations
  final List<double> _columnHeights = [];
  final List<Widget> _positionedCards = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _calculateLayout();
  }

  @override
  void didUpdateWidget(MasonryThemeGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.themes.length != widget.themes.length ||
        oldWidget.searchQuery != widget.searchQuery) {
      _recalculateLayout();
    }
  }

  void _initializeAnimations() {
    _staggerController = AnimationController(
      duration: Duration(milliseconds: 300 + (widget.themes.length * 50)),
      vsync: this,
    );

    // Create animations for each theme card
    for (int i = 0; i < widget.themes.length; i++) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
      _cardControllers.add(controller);

      // Staggered fade-in animation
      final animation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _staggerController,
        curve: Interval(
          i / widget.themes.length,
          math.min(1.0, (i + 1) / widget.themes.length + 0.2),
          curve: Curves.easeOutCubic,
        ),
      ));
      _cardAnimations.add(animation);

      // Slide-in animation
      final slideAnimation = Tween<Offset>(
        begin: Offset(0, 0.5 + (i % 2) * 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _staggerController,
        curve: Interval(
          i / widget.themes.length,
          math.min(1.0, (i + 1) / widget.themes.length + 0.2),
          curve: Curves.easeOutCubic,
        ),
      ));
      _slideAnimations.add(slideAnimation);
    }

    // Start stagger animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _staggerController.forward();
    });
  }

  void _calculateLayout() {
    _columnHeights.clear();
    _positionedCards.clear();
    
    // Initialize column heights
    for (int i = 0; i < widget.columnCount; i++) {
      _columnHeights.add(0);
    }
  }

  void _recalculateLayout() {
    _staggerController.reset();
    _calculateLayout();
    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    for (final controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.themes.isEmpty) {
      return _buildEmptyState(context);
    }

    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.spacing),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return _buildMasonryLayout(constraints);
            },
          ),
        );
      },
    );
  }

  Widget _buildMasonryLayout(BoxConstraints constraints) {
    final columnWidth = (constraints.maxWidth - (widget.spacing * (widget.columnCount - 1))) / widget.columnCount;
    
    // Reset column heights for layout calculation
    for (int i = 0; i < _columnHeights.length; i++) {
      _columnHeights[i] = 0;
    }

    final List<Widget> positionedCards = [];

    for (int index = 0; index < widget.themes.length; index++) {
      final theme = widget.themes[index];
      final isSelected = widget.currentTheme?.metadata.id == theme.metadata.id;
      
      // Find the shortest column
      int shortestColumn = 0;
      for (int i = 1; i < _columnHeights.length; i++) {
        if (_columnHeights[i] < _columnHeights[shortestColumn]) {
          shortestColumn = i;
        }
      }

      // Calculate dynamic card height based on theme complexity
      final cardHeight = _calculateCardHeight(theme, isSelected);
      
      // Calculate position
      final left = shortestColumn * (columnWidth + widget.spacing);
      final top = _columnHeights[shortestColumn];

      // Create positioned card with animations
      final positionedCard = Positioned(
        left: left,
        top: top,
        width: columnWidth,
        child: index < _cardAnimations.length ? AnimatedBuilder(
          animation: Listenable.merge([_cardAnimations[index], _slideAnimations[index]]),
          builder: (context, child) {
            return Transform.translate(
              offset: _slideAnimations[index].value * 50,
              child: Opacity(
                opacity: _cardAnimations[index].value,
                child: Transform.scale(
                  scale: 0.8 + (_cardAnimations[index].value * 0.2),
                  child: UltraModernThemeCard(
                    theme: theme,
                    isSelected: isSelected,
                    height: cardHeight,
                    onTap: () => _handleThemeTap(theme),
                    onLongPress: () => _handleThemePreview(theme),
                    searchQuery: widget.searchQuery,
                  ),
                ),
              ),
            );
          },
        ) : UltraModernThemeCard(
          theme: theme,
          isSelected: isSelected,
          height: cardHeight,
          onTap: () => _handleThemeTap(theme),
          onLongPress: () => _handleThemePreview(theme),
          searchQuery: widget.searchQuery,
        ),
      );

      positionedCards.add(positionedCard);

      // Update column height
      _columnHeights[shortestColumn] += cardHeight + widget.spacing;
    }

    // Calculate total height
    final totalHeight = _columnHeights.reduce(math.max);

    return SizedBox(
      height: totalHeight,
      child: Stack(
        children: positionedCards,
      ),
    );
  }

  double _calculateCardHeight(AppThemeData theme, bool isSelected) {
    // Base height
    double height = 280;
    
    // Add height based on theme complexity and content
    final hasEffects = theme.metadata.tags.contains('animated') || 
                      theme.metadata.tags.contains('effects');
    if (hasEffects) height += 40;
    
    // Selected themes get more height for selection indicator
    if (isSelected) height += 20;
    
    // Add slight random variation for natural masonry look
    final variation = (theme.metadata.id.hashCode % 40) - 20;
    height += variation;
    
    // Add height for themes with longer descriptions
    if (theme.metadata.description.length > 50) height += 30;
    
    // Ensure minimum and maximum heights
    return height.clamp(240.0, 400.0);
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 400,
      margin: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.palette_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            widget.searchQuery.isNotEmpty 
                ? 'No themes found for "${widget.searchQuery}"'
                : 'No themes available',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            widget.searchQuery.isNotEmpty 
                ? 'Try adjusting your search terms or filters'
                : 'Themes will appear here once loaded',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.searchQuery.isNotEmpty) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                // This would trigger clearing the search in the parent
              },
              icon: const Icon(PhosphorIcons.x()),
              label: const Text('Clear Search'),
            ),
          ],
        ],
      ),
    );
  }

  void _handleThemeTap(AppThemeData theme) {
    widget.onThemeSelected(theme.metadata.id);
    HapticFeedback.selectionClick();
    
    // Add ripple effect animation
    _triggerSelectionAnimation(theme);
  }

  void _handleThemePreview(AppThemeData theme) {
    if (widget.onThemePreview != null) {
      widget.onThemePreview!(theme);
      HapticFeedback.lightImpact();
    }
  }

  void _triggerSelectionAnimation(AppThemeData theme) {
    // Find the card index for this theme
    final index = widget.themes.indexWhere((t) => t.metadata.id == theme.metadata.id);
    if (index >= 0 && index < _cardControllers.length) {
      final controller = _cardControllers[index];
      controller.forward().then((_) {
        controller.reverse();
      });
    }
  }
}

/// Utility extension for theme analysis
extension ThemeAnalysis on AppThemeData {
  bool get hasComplexEffects {
    return metadata.tags.contains('animated') ||
           metadata.tags.contains('effects') ||
           metadata.tags.contains('particles');
  }
  
  bool get isPopular {
    return metadata.popularityScore > 4.0;
  }
  
  bool get isRecent {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    return metadata.createdAt.isAfter(thirtyDaysAgo);
  }
}