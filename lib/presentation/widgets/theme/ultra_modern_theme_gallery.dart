import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/typography_constants.dart';
import '../../../core/providers/enhanced_theme_provider.dart';
import '../../../core/theme/app_theme_data.dart';
import '../glassmorphism_container.dart';
import 'masonry_theme_grid.dart';
import 'immersive_preview_overlay.dart';

/// Ultra-modern theme gallery with next-generation design and interactions
class UltraModernThemeGallery extends ConsumerStatefulWidget {
  final VoidCallback? onThemeSelected;
  final bool enablePreviewMode;
  final bool showFloatingControls;

  const UltraModernThemeGallery({
    super.key,
    this.onThemeSelected,
    this.enablePreviewMode = true,
    this.showFloatingControls = true,
  });

  @override
  ConsumerState<UltraModernThemeGallery> createState() => _UltraModernThemeGalleryState();
}

class _UltraModernThemeGalleryState extends ConsumerState<UltraModernThemeGallery>
    with TickerProviderStateMixin {
  
  // Animation Controllers
  late AnimationController _searchController;
  late AnimationController _filterController;
  late AnimationController _scrollController;
  late AnimationController _floatingActionController;
  
  // Animations
  late Animation<double> _searchAnimation;
  late Animation<double> _filterAnimation;
  late Animation<Offset> _floatingActionAnimation;
  
  // State Management
  String _searchQuery = '';
  String? _selectedCategory;
  String _sortBy = 'popularity'; // popularity, name, recent
  bool _isSearchFocused = false;
  bool _showFilters = false;
  AppThemeData? _previewTheme;
  
  // Controllers
  final TextEditingController _searchTextController = TextEditingController();
  final ScrollController _masonryScrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupListeners();
  }

  void _initializeAnimations() {
    // Search animation for focus state
    _searchController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _searchAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _searchController, curve: Curves.easeOutCubic));

    // Filter panel animation
    _filterController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _filterAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _filterController, curve: Curves.easeOutCubic));

    // Scroll-based animations
    _scrollController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Floating action button animation
    _floatingActionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _floatingActionAnimation = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _floatingActionController,
      curve: Curves.elasticOut,
    ));

    // Start initial animations
    _floatingActionController.forward();
  }

  void _setupListeners() {
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
      if (_isSearchFocused) {
        _searchController.forward();
      } else {
        _searchController.reverse();
      }
    });

    _masonryScrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    // Hide floating controls when scrolling down, show when scrolling up
    final velocity = _masonryScrollController.position.userScrollDirection;
    if (velocity == ScrollDirection.forward) {
      _floatingActionController.forward();
    } else if (velocity == ScrollDirection.reverse) {
      _floatingActionController.reverse();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filterController.dispose();
    _scrollController.dispose();
    _floatingActionController.dispose();
    _searchTextController.dispose();
    _masonryScrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeState = ref.watch(enhancedThemeProvider);
    final themes = _getFilteredAndSortedThemes();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.95),
      body: Stack(
        children: [
          // Background with subtle pattern
          _buildBackgroundPattern(theme),
          
          // Main content
          CustomScrollView(
            controller: _masonryScrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Ultra-modern app bar
              _buildUltraModernAppBar(theme),
              
              // Floating search section
              _buildFloatingSearchSection(theme),
              
              // Filter section (expandable)
              if (_showFilters) _buildAdvancedFilters(theme),
              
              // Masonry theme grid
              SliverToBoxAdapter(
                child: MasonryThemeGrid(
                  themes: themes,
                  currentTheme: themeState.currentTheme,
                  onThemeSelected: _selectTheme,
                  onThemePreview: widget.enablePreviewMode ? _showPreviewTheme : null,
                  searchQuery: _searchQuery,
                ),
              ),
              
              // Bottom padding for floating controls
              const SliverToBoxAdapter(
                child: SizedBox(height: 120),
              ),
            ],
          ),
          
          // Floating controls
          if (widget.showFloatingControls) _buildFloatingControls(theme),
          
          // Immersive preview overlay
          if (_previewTheme != null && widget.enablePreviewMode)
            ImmersivePreviewOverlay(
              theme: _previewTheme!,
              onClose: () => setState(() => _previewTheme = null),
              onApply: () {
                _selectTheme(_previewTheme!.metadata.id);
                setState(() => _previewTheme = null);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBackgroundPattern(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surface.withValues(alpha: 0.8),
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          ],
        ),
      ),
      child: CustomPaint(
        painter: _ModernPatternPainter(
          color: theme.colorScheme.outline.withValues(alpha: 0.02),
        ),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildUltraModernAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      snap: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: GlassmorphismContainer(
          blur: 20,
          opacity: 0.1,
          borderWidth: 0.1,
          child: Container(),
        ),
        title: AnimatedBuilder(
          animation: _searchAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 - (_searchAnimation.value * 0.1),
              child: Text(
                'Theme Gallery',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0.5,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        AnimatedBuilder(
          animation: _searchAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 - (_searchAnimation.value * 0.3),
              child: IconButton(
                icon: Icon(
                  PhosphorIcons.shuffle(),
                  color: theme.colorScheme.primary,
                ),
                onPressed: _applyRandomTheme,
                tooltip: 'Random Theme',
              ),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildFloatingSearchSection(ThemeData theme) {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _searchAnimation,
        builder: (context, child) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20 + (_searchAnimation.value * 4),
              vertical: 16,
            ),
            child: GlassmorphismContainer(
              blur: 15 + (_searchAnimation.value * 10),
              opacity: 0.08 + (_searchAnimation.value * 0.04),
              borderWidth: 0.1,
              borderRadius: BorderRadius.circular(
                TypographyConstants.radiusStandard + (_searchAnimation.value * 8),
              ),
              child: TextField(
                controller: _searchTextController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'Search themes by name, mood, or color...',
                  hintStyle: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  prefixIcon: AnimatedRotation(
                    turns: _searchAnimation.value * 0.5,
                    duration: const Duration(milliseconds: 400),
                    child: Icon(
                      PhosphorIcons.magnifyingGlass(),
                      color: theme.colorScheme.primary.withValues(alpha: 
                        0.7 + (_searchAnimation.value * 0.3),
                      ),
                    ),
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_searchQuery.isNotEmpty)
                        IconButton(
                          icon: Icon(PhosphorIcons.x()),
                          onPressed: _clearSearch,
                        ),
                      IconButton(
                        icon: Icon(
                          _showFilters ? PhosphorIcons.funnelSimpleX() : PhosphorIcons.funnel(),
                          color: _showFilters ? theme.colorScheme.primary : null,
                        ),
                        onPressed: _toggleFilters,
                      ),
                    ],
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                  HapticFeedback.selectionClick();
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdvancedFilters(ThemeData theme) {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _filterAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _filterAnimation.value,
            child: Opacity(
              opacity: _filterAnimation.value,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: GlassmorphismContainer(
                  padding: const EdgeInsets.all(20),
                  borderWidth: 0.1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filters & Sorting',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSortOptions(theme),
                      const SizedBox(height: 16),
                      _buildCategoryFilters(theme),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortOptions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort by',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildSortChip('popularity', 'Popular', PhosphorIcons.trendUp()),
              const SizedBox(width: 8),
              _buildSortChip('name', 'Name', PhosphorIcons.sortAscending()),
              const SizedBox(width: 8),
              _buildSortChip('recent', 'Recent', PhosphorIcons.clock()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSortChip(String value, String label, IconData icon) {
    final theme = Theme.of(context);
    final isSelected = _sortBy == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _sortBy = value;
        });
        HapticFeedback.selectionClick();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary.withValues(alpha: 0.15)
              : theme.colorScheme.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary.withValues(alpha: 0.3)
                : theme.colorScheme.outline.withValues(alpha: 0.1),
            width: isSelected ? 1.0 : 0.1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected 
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilters(ThemeData theme) {
    final categories = ref.watch(themeCategoriesProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildCategoryChip('All', _selectedCategory == null),
            ...categories.map((category) =>
                _buildCategoryChip(_formatCategoryName(category), _selectedCategory == category, category)),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected, [String? category]) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = isSelected ? null : category;
        });
        HapticFeedback.selectionClick();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary
              : theme.colorScheme.surface.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 0.1,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isSelected 
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingControls(ThemeData theme) {
    return Positioned(
      bottom: 24,
      right: 24,
      child: SlideTransition(
        position: _floatingActionAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Preview mode toggle
            if (widget.enablePreviewMode)
              GlassmorphismContainer(
                blur: 20,
                opacity: 0.15,
                borderWidth: 0.1,
                padding: const EdgeInsets.all(12),
                child: Icon(
                  PhosphorIcons.eye(),
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
            
            const SizedBox(height: 12),
            
            // Scroll to top
            GestureDetector(
              onTap: _scrollToTop,
              child: GlassmorphismContainer(
                blur: 20,
                opacity: 0.15,
                borderWidth: 0.1,
                padding: const EdgeInsets.all(16),
                child: Icon(
                  PhosphorIcons.caretUp(),
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  String _formatCategoryName(String category) {
    return category.split('_').map((word) => 
        word.substring(0, 1).toUpperCase() + word.substring(1)
    ).join(' ');
  }

  List<AppThemeData> _getFilteredAndSortedThemes() {
    final themeNotifier = ref.read(enhancedThemeProvider.notifier);
    List<AppThemeData> themes;

    // Filter by category
    if (_selectedCategory != null) {
      themes = themeNotifier.getThemesByCategory(_selectedCategory!);
    } else {
      themes = themeNotifier.getAllThemes();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      themes = themeNotifier.searchThemes(_searchQuery);
    }

    // Sort themes
    switch (_sortBy) {
      case 'name':
        themes.sort((a, b) => a.metadata.name.compareTo(b.metadata.name));
        break;
      case 'recent':
        themes.sort((a, b) => b.metadata.createdAt.compareTo(a.metadata.createdAt));
        break;
      case 'popularity':
      default:
        themes.sort((a, b) => b.metadata.popularityScore.compareTo(a.metadata.popularityScore));
        break;
    }

    return themes;
  }

  void _selectTheme(String themeId) {
    ref.read(enhancedThemeProvider.notifier).setTheme(themeId);
    widget.onThemeSelected?.call();
    HapticFeedback.mediumImpact();
  }

  void _showPreviewTheme(AppThemeData theme) {
    setState(() {
      _previewTheme = theme;
    });
    HapticFeedback.lightImpact();
  }

  void _applyRandomTheme() {
    ref.read(enhancedThemeProvider.notifier).applyRandomTheme();
    widget.onThemeSelected?.call();
    HapticFeedback.heavyImpact();
  }

  void _clearSearch() {
    _searchTextController.clear();
    setState(() {
      _searchQuery = '';
    });
    HapticFeedback.selectionClick();
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
    if (_showFilters) {
      _filterController.forward();
    } else {
      _filterController.reverse();
    }
    HapticFeedback.selectionClick();
  }

  void _scrollToTop() {
    _masonryScrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
    );
    HapticFeedback.selectionClick();
  }
}

/// Custom painter for subtle background pattern
class _ModernPatternPainter extends CustomPainter {
  final Color color;

  _ModernPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const spacing = 60.0;
    
    // Draw subtle grid pattern
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ModernPatternPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

