import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/enhanced_theme_provider.dart';
import '../widgets/glassmorphism_container.dart';
import '../widgets/standardized_app_bar.dart';
import '../widgets/theme_background_widget.dart';
import '../../core/theme/app_theme_data.dart';
import '../../core/theme/typography_constants.dart';
import '../../core/design_system/design_tokens.dart';

/// Ultra-modern theme gallery with glassmorphism design and immersive previews
class ThemesPage extends ConsumerStatefulWidget {
  const ThemesPage({super.key});

  @override
  ConsumerState<ThemesPage> createState() => _ThemesPageState();
}

class _ThemesPageState extends ConsumerState<ThemesPage> 
    with TickerProviderStateMixin {
  
  late AnimationController _headerAnimationController;
  late AnimationController _gridAnimationController;
  late AnimationController _floatingAnimationController;
  
  late Animation<double> _headerAnimation;
  late Animation<double> _gridAnimation;
  late Animation<Offset> _floatingAnimation;
  
  String _searchQuery = '';
  String? _selectedCategory;
  bool _isGridView = true;
  AppThemeData? _previewTheme;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Header entrance animation
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _headerAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    );

    // Grid entrance animation
    _gridAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _gridAnimation = CurvedAnimation(
      parent: _gridAnimationController,
      curve: Curves.easeOutCubic,
    );

    // Floating action animation
    _floatingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _floatingAnimation = Tween<Offset>(
      begin: const Offset(0, 1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _floatingAnimationController,
      curve: Curves.elasticOut,
    ));

    // Start animations
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _gridAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _floatingAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _gridAnimationController.dispose();
    _floatingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeState = ref.watch(enhancedThemeProvider);
    final availableThemes = ref.watch(availableThemesProvider);
    final filteredThemes = _getFilteredThemes(availableThemes);

    return ThemeBackgroundWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
      appBar: StandardizedAppBar(
        title: 'Theme Gallery',
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Search toggle
          GlassmorphismContainer(
            level: GlassLevel.interactive,
            width: 40,
            height: 40,
            borderRadius: BorderRadius.circular(20),
            margin: const EdgeInsets.only(right: 4),
            child: IconButton(
              icon: const Icon(Icons.search, size: 18),
              onPressed: () => _showSearchDialog(context),
              tooltip: 'Search themes',
              padding: EdgeInsets.zero,
            ),
          ),
          // View toggle
          GlassmorphismContainer(
            level: GlassLevel.interactive,
            width: 40,
            height: 40,
            borderRadius: BorderRadius.circular(20),
            margin: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view, size: 18),
              onPressed: () {
                setState(() {
                  _isGridView = !_isGridView;
                });
                HapticFeedback.selectionClick();
              },
              tooltip: _isGridView ? 'List view' : 'Grid view',
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          CustomScrollView(
            slivers: [
              // Header section
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _headerAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.3),
                      end: Offset.zero,
                    ).animate(_headerAnimation),
                    child: _buildHeader(theme, themeState),
                  ),
                ),
              ),
              
              // Search results or categories
              if (_searchQuery.isNotEmpty || _selectedCategory != null)
                SliverToBoxAdapter(
                  child: _buildActiveFilters(),
                ),
              
              // Themes grid/list
              _isGridView 
                ? _buildThemesGrid(filteredThemes, themeState)
                : _buildThemesList(filteredThemes, themeState),
              
              // Bottom spacing
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
          
          // Floating action button
          Positioned(
            bottom: 24,
            right: 24,
            child: SlideTransition(
              position: _floatingAnimation,
              child: _buildFloatingActions(theme),
            ),
          ),
          
          // Preview overlay
          if (_previewTheme != null)
            _buildPreviewOverlay(),
        ],
      ),
    ),
    );
  }

  Widget _buildHeader(ThemeData theme, EnhancedThemeState themeState) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 100, 20, 16),
      child: GlassmorphismContainer(
        level: GlassLevel.floating,
        borderRadius: BorderRadius.circular(24),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header icon and title
            Row(
              children: [
                GlassmorphismContainer(
                  level: GlassLevel.interactive,
                  width: 56,
                  height: 56,
                  borderRadius: BorderRadius.circular(16),
                  // Let glassmorphism container auto-determine tint based on theme
                  child: Icon(
                    Icons.palette_rounded,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Theme Gallery',
                        style: TextStyle(
                          fontSize: TypographyConstants.text2XL,
                          fontWeight: TypographyConstants.bold,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: TypographyConstants.tightLetterSpacing,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Express your style',
                        style: TextStyle(
                          fontSize: TypographyConstants.textBase,
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: TypographyConstants.medium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Current theme showcase
            GlassmorphismContainer(
              level: GlassLevel.content,
              borderRadius: BorderRadius.circular(16),
              padding: const EdgeInsets.all(20),
              // Let glassmorphism container auto-determine tint based on theme
              child: Row(
                children: [
                  // Theme preview circle
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                          theme.colorScheme.tertiary,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.brush_rounded,
                      color: theme.colorScheme.onPrimary,
                      size: 24,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Theme',
                          style: TextStyle(
                            fontSize: TypographyConstants.textSM,
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: TypographyConstants.medium,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          themeState.currentThemeName,
                          style: TextStyle(
                            fontSize: TypographyConstants.textLG,
                            fontWeight: TypographyConstants.semiBold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Quick actions
                  GlassmorphismContainer(
                    level: GlassLevel.interactive,
                    width: 44,
                    height: 44,
                    borderRadius: BorderRadius.circular(22),
                    child: IconButton(
                      icon: const Icon(Icons.shuffle_rounded, size: 20),
                      onPressed: () => _applyRandomTheme(),
                      tooltip: 'Random theme',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GlassmorphismContainer(
        level: GlassLevel.content,
        borderRadius: BorderRadius.circular(16),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.filter_alt_rounded,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _searchQuery.isNotEmpty 
                  ? 'Search: \'$_searchQuery\''
                  : 'Category: ${_selectedCategory ?? 'All'}',
                style: TextStyle(
                  fontSize: TypographyConstants.textSM,
                  fontWeight: TypographyConstants.medium,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            GlassmorphismContainer(
              level: GlassLevel.interactive,
              width: 32,
              height: 32,
              borderRadius: BorderRadius.circular(16),
              child: IconButton(
                icon: const Icon(Icons.close, size: 16),
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _selectedCategory = null;
                  });
                },
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemesGrid(List<AppThemeData> themes, EnhancedThemeState themeState) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => FadeTransition(
            opacity: _gridAnimation,
            child: _buildThemeCard(themes[index], themeState, index),
          ),
          childCount: themes.length,
        ),
      ),
    );
  }

  Widget _buildThemesList(List<AppThemeData> themes, EnhancedThemeState themeState) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => FadeTransition(
            opacity: _gridAnimation,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildThemeListItem(themes[index], themeState),
            ),
          ),
          childCount: themes.length,
        ),
      ),
    );
  }

  Widget _buildThemeCard(AppThemeData theme, EnhancedThemeState themeState, int index) {
    final isActive = theme.metadata.id == themeState.currentTheme?.metadata.id;
    
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: GlassmorphismContainer(
              level: isActive ? GlassLevel.floating : GlassLevel.content,
              borderRadius: BorderRadius.circular(20),
              padding: const EdgeInsets.all(16),
              // Let glassmorphism container auto-determine tint, just use border for selection
              borderColor: isActive 
                ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                : null,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _selectTheme(theme),
                  onLongPress: () => _showThemePreview(theme),
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Theme preview
                      Expanded(
                        flex: 3,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(theme.colors.primary.value),
                                Color(theme.colors.secondary.value),
                                Color(theme.colors.tertiary.value),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(theme.colors.primary.value).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Subtle pattern
                              CustomPaint(
                                size: Size.infinite,
                                painter: _ThemePatternPainter(
                                  Color(theme.colors.onPrimary.value).withOpacity(0.1),
                                ),
                              ),
                              
                              // Active indicator
                              if (isActive)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Color(theme.colors.primary.value),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Theme info
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Text(
                                theme.metadata.name,
                                style: TextStyle(
                                  fontSize: TypographyConstants.textBase,
                                  fontWeight: TypographyConstants.semiBold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            
                            const SizedBox(height: 4),
                            
                            Flexible(
                              child: Text(
                                theme.metadata.description,
                                  style: TextStyle(
                                    fontSize: TypographyConstants.textXS,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            
                            const Spacer(),
                            
                            // Color palette
                            Row(
                              children: [
                                _buildColorDot(Color(theme.colors.primary.value)),
                                const SizedBox(width: 4),
                                _buildColorDot(Color(theme.colors.secondary.value)),
                                const SizedBox(width: 4),
                                _buildColorDot(Color(theme.colors.tertiary.value)),
                                const Spacer(),
                                if (theme.metadata.popularityScore > 0.8)
                                  const Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeListItem(AppThemeData theme, EnhancedThemeState themeState) {
    final isActive = theme.metadata.id == themeState.currentTheme?.metadata.id;
    
    return GlassmorphismContainer(
      level: isActive ? GlassLevel.floating : GlassLevel.content,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(16),
      // Let glassmorphism container auto-determine tint, just use border for selection
      borderColor: isActive 
        ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
        : null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectTheme(theme),
          onLongPress: () => _showThemePreview(theme),
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              // Theme preview circle
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: [
                      Color(theme.colors.primary.value),
                      Color(theme.colors.secondary.value),
                      Color(theme.colors.tertiary.value),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(theme.colors.primary.value).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: isActive
                  ? Icon(
                      Icons.check,
                      color: Color(theme.colors.onPrimary.value),
                      size: 24,
                    )
                  : null,
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      theme.metadata.name,
                      style: TextStyle(
                        fontSize: TypographyConstants.textLG,
                        fontWeight: TypographyConstants.semiBold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    Text(
                      theme.metadata.description,
                      style: TextStyle(
                        fontSize: TypographyConstants.textSM,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Color palette
              Column(
                children: [
                  _buildColorDot(Color(theme.colors.primary.value), size: 12),
                  const SizedBox(height: 4),
                  _buildColorDot(Color(theme.colors.secondary.value), size: 12),
                  const SizedBox(height: 4),
                  _buildColorDot(Color(theme.colors.tertiary.value), size: 12),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorDot(Color color, {double size = 10}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActions(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GlassmorphismContainer(
          level: GlassLevel.floating,
          width: 56,
          height: 56,
          borderRadius: BorderRadius.circular(28),
          child: FloatingActionButton(
            heroTag: 'random',
            onPressed: () => _applyRandomTheme(),
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Icon(
              Icons.shuffle_rounded,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        GlassmorphismContainer(
          level: GlassLevel.floating,
          width: 56,
          height: 56,
          borderRadius: BorderRadius.circular(28),
          child: FloatingActionButton(
            heroTag: 'favorite',
            onPressed: () => _showFavoriteThemes(),
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Icon(
              Icons.favorite_rounded,
              color: theme.colorScheme.secondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewOverlay() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _previewTheme = null),
        child: Container(
          color: Colors.black.withOpacity(0.7),
          child: Center(
            child: GlassmorphismContainer(
              level: GlassLevel.floating,
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.6,
              borderRadius: BorderRadius.circular(24),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Theme Preview',
                    style: TextStyle(
                      fontSize: TypographyConstants.text2XL,
                      fontWeight: TypographyConstants.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            Color(_previewTheme!.colors.primary.value),
                            Color(_previewTheme!.colors.secondary.value),
                            Color(_previewTheme!.colors.tertiary.value),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    _previewTheme!.metadata.name,
                    style: TextStyle(
                      fontSize: TypographyConstants.textXL,
                      fontWeight: TypographyConstants.semiBold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Row(
                    children: [
                      const Expanded(
                        child: OutlinedButton(
                          onPressed: null,
                          child:  Text('Cancel'),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _selectTheme(_previewTheme!);
                            setState(() => _previewTheme = null);
                          },
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<AppThemeData> _getFilteredThemes(List<AppThemeData> themes) {
    var filtered = themes;
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((theme) =>
        theme.metadata.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        theme.metadata.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    if (_selectedCategory != null) {
      filtered = filtered.where((theme) =>
        theme.metadata.category == _selectedCategory
      ).toList();
    }
    
    // Sort by popularity and name
    filtered.sort((a, b) {
      final popularityComparison = b.metadata.popularityScore.compareTo(a.metadata.popularityScore);
      if (popularityComparison != 0) return popularityComparison;
      return a.metadata.name.compareTo(b.metadata.name);
    });
    
    return filtered;
  }

  void _selectTheme(AppThemeData theme) {
    ref.read(enhancedThemeProvider.notifier).setTheme(theme.metadata.id);
    HapticFeedback.mediumImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.brush_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text('${theme.metadata.name} applied!'),
          ],
        ),
        backgroundColor: Color(theme.colors.primary.value),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showThemePreview(AppThemeData theme) {
    setState(() => _previewTheme = theme);
    HapticFeedback.lightImpact();
  }

  void _applyRandomTheme() async {
    await ref.read(enhancedThemeProvider.notifier).applyRandomTheme();
    HapticFeedback.heavyImpact();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(
                Icons.shuffle_rounded,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 12),
              Text('Random theme applied!'),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Themes'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Enter theme name or description...',
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (query) {
            setState(() => _searchQuery = query);
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showFavoriteThemes() {
    // Show favorite themes in a dialog with filtering options
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Favorite Themes'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              const Text('Your favorite themes will appear here.'),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_outline,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No favorite themes yet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the heart icon on any theme to add it to favorites',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
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

/// Custom painter for theme card patterns
class _ThemePatternPainter extends CustomPainter {
  final Color color;
  
  _ThemePatternPainter(this.color);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    // Draw subtle geometric pattern
    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 5; j++) {
        final x = (size.width / 5) * i + (size.width / 10);
        final y = (size.height / 5) * j + (size.height / 10);
        
        if ((i + j) % 2 == 0) {
          canvas.drawCircle(
            Offset(x, y),
            2,
            paint,
          );
        }
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}