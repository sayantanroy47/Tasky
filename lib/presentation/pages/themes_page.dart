import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/enhanced_theme_provider.dart';
import '../widgets/glassmorphism_container.dart';
import '../widgets/standardized_app_bar.dart';
import '../widgets/standardized_text.dart';
import '../widgets/theme_background_widget.dart';
import '../../core/theme/app_theme_data.dart';
import '../../core/theme/typography_constants.dart';
import '../../core/design_system/design_tokens.dart';
import '../widgets/standardized_spacing.dart';
import '../widgets/standardized_colors.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
        backgroundColor: context.colors.backgroundTransparent,
        extendBodyBehindAppBar: true,
      appBar: StandardizedAppBar(
        title: 'Theme Gallery',
        backgroundColor: context.colors.backgroundTransparent,
        elevation: 0,
        actions: [
          // Search toggle
          GlassmorphismContainer(
            level: GlassLevel.interactive,
            width: 40,
            height: 40,
            borderRadius: BorderRadius.circular(TypographyConstants.radiusXLarge), // 20.0 - Fixed border radius hierarchy
            margin: StandardizedSpacing.marginOnly(right: SpacingSize.xs),
            child: IconButton(
              icon: Icon(PhosphorIcons.magnifyingGlass(), size: 18),
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
            borderRadius: BorderRadius.circular(TypographyConstants.radiusXLarge), // 20.0 - Fixed border radius hierarchy
            margin: StandardizedSpacing.marginOnly(right: SpacingSize.sm),
            child: IconButton(
              icon: Icon(_isGridView ? PhosphorIcons.list() : PhosphorIcons.gridNine(), size: 18),
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
              SliverToBoxAdapter(
                child: StandardizedGaps.vertical(SpacingSize.xxxl),
              ),
            ],
          ),
          
          // Floating action button
          Positioned(
            bottom: SpacingTokens.lg,
            right: SpacingTokens.lg,
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
      padding: StandardizedSpacing.paddingOnly(
        left: SpacingSize.lg,
        top: SpacingSize.xxxl,
        right: SpacingSize.lg,
        bottom: SpacingSize.md,
      ),
      child: GlassmorphismContainer(
        level: GlassLevel.floating,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusXXLarge), // 24.0 - Fixed border radius hierarchy
        padding: StandardizedSpacing.padding(SpacingSize.lg),
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
                    PhosphorIcons.palette(),
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                ),
                StandardizedGaps.horizontal(SpacingSize.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StandardizedText(
                        'Theme Gallery',
                        style: StandardizedTextStyle.headlineMedium,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: TypographyConstants.tightLetterSpacing,
                      ),
                      StandardizedGaps.xs,
                      StandardizedText(
                        'Express your style',
                        style: StandardizedTextStyle.bodyLarge,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            StandardizedGaps.lg,
            
            // Current theme showcase
            GlassmorphismContainer(
              level: GlassLevel.content,
              borderRadius: BorderRadius.circular(16),
              padding: StandardizedSpacing.padding(SpacingSize.lg),
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
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      PhosphorIcons.paintBrush(),
                      color: theme.colorScheme.onPrimary,
                      size: 24,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StandardizedText(
                          'Current Theme',
                          style: StandardizedTextStyle.bodyMedium,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 4),
                        StandardizedText(
                          themeState.currentThemeName,
                          style: StandardizedTextStyle.titleLarge,
                          color: theme.colorScheme.onSurface,
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
                      icon: Icon(PhosphorIcons.shuffle(), size: 20),
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
              PhosphorIcons.funnel(),
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StandardizedText(
                _searchQuery.isNotEmpty 
                  ? 'Search: \'$_searchQuery\''
                  : 'Category: ${_selectedCategory ?? 'All'}',
                style: StandardizedTextStyle.bodyMedium,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            GlassmorphismContainer(
              level: GlassLevel.interactive,
              width: 32,
              height: 32,
              borderRadius: BorderRadius.circular(16),
              child: IconButton(
                icon: Icon(PhosphorIcons.x(), size: 16),
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
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 0.8,
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
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: isActive 
          ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
          : Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Material(
        color: context.colors.backgroundTransparent,
        child: InkWell(
          onTap: () => _selectTheme(theme),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children: [
              // Rectangular preview block
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context).colorScheme.surfaceContainer,
                  ),
                  child: Stack(
                    children: [
                      // UI sections representation
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            // Top section (header/app bar area) - Updated to show 3 colors including stellar gold
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(TypographyConstants.radiusXSmall), // 2.0 - Fixed border radius hierarchy (was 4px)
                                        color: theme.colors.primary.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(TypographyConstants.radiusXSmall), // 2.0 - Fixed border radius hierarchy (was 4px)
                                        color: theme.colors.secondary.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(TypographyConstants.radiusXSmall), // 2.0 - Fixed border radius hierarchy (was 4px)
                                        color: (theme.colors.stellarGold ?? theme.colors.accent).withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Middle section (calendar/content area)
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(TypographyConstants.radiusXSmall), // 2.0 - Fixed border radius hierarchy (was 4px)
                                        color: theme.colors.tertiary.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(TypographyConstants.radiusXSmall), // 2.0 - Fixed border radius hierarchy (was 4px)
                                        color: theme.colors.surface,
                                        border: Border.all(
                                          color: theme.colors.outline.withValues(alpha: 0.3),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Bottom section (text areas)
                            Expanded(
                              flex: 1,
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: theme.colors.surfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Selection indicator
                      if (isActive)
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface, // Fixed hardcoded white color
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.2), // Fixed hardcoded black color
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              PhosphorIcons.check(),
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              // Theme name
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: StandardizedText(
                  theme.metadata.name,
                  style: StandardizedTextStyle.bodyMedium,
                  color: Theme.of(context).colorScheme.onSurface,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
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
        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
        : null,
      child: Material(
        color: context.colors.backgroundTransparent,
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
                      theme.colors.primary,
                      theme.colors.secondary,
                      theme.colors.tertiary,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: isActive
                  ? Icon(
                      PhosphorIcons.check(),
                      color: theme.colors.onPrimary,
                      size: 24,
                    )
                  : null,
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StandardizedText(
                      theme.metadata.name,
                      style: StandardizedTextStyle.titleLarge,
                      color: Theme.of(context).colorScheme.onSurface,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Color palette
              Column(
                children: [
                  _buildColorDot(theme.colors.primary, size: 12),
                  const SizedBox(height: 4),
                  _buildColorDot(theme.colors.secondary, size: 12),
                  const SizedBox(height: 4),
                  _buildColorDot(theme.colors.tertiary, size: 12),
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
            color: color.withValues(alpha: 0.4),
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
          borderRadius: BorderRadius.circular(TypographyConstants.radiusXXLarge), // 24.0 - Fixed border radius hierarchy (was 28px)
          child: FloatingActionButton(
            heroTag: 'random',
            onPressed: () => _applyRandomTheme(),
            backgroundColor: context.colors.backgroundTransparent,
            elevation: 0,
            child: Icon(
              PhosphorIcons.shuffle(),
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        GlassmorphismContainer(
          level: GlassLevel.floating,
          width: 56,
          height: 56,
          borderRadius: BorderRadius.circular(TypographyConstants.radiusXXLarge), // 24.0 - Fixed border radius hierarchy (was 28px)
          child: FloatingActionButton(
            heroTag: 'favorite',
            onPressed: () => _showFavoriteThemes(),
            backgroundColor: context.colors.backgroundTransparent,
            elevation: 0,
            child: Icon(
              PhosphorIcons.heart(),
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
          color: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.7), // Fixed hardcoded overlay color
          child: Center(
            child: GlassmorphismContainer(
              level: GlassLevel.floating,
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.6,
              borderRadius: BorderRadius.circular(24),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  StandardizedText(
                    'Theme Preview',
                    style: StandardizedTextStyle.headlineMedium,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            _previewTheme!.colors.primary,
                            _previewTheme!.colors.secondary,
                            _previewTheme!.colors.tertiary,
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  StandardizedText(
                    _previewTheme!.metadata.name,
                    style: StandardizedTextStyle.headlineSmall,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Row(
                    children: [
                      const Expanded(
                        child: OutlinedButton(
                          onPressed: null,
                          child: StandardizedText('Cancel', style: StandardizedTextStyle.buttonText),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _selectTheme(_previewTheme!);
                            setState(() => _previewTheme = null);
                          },
                          child: const StandardizedText('Apply', style: StandardizedTextStyle.buttonText),
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
            Icon(
              PhosphorIcons.paintBrush(),
              color: theme.colors.onPrimary, // Use selected theme's contrast color
              size: 20,
            ),
            const SizedBox(width: 12),
            StandardizedText(
              '${theme.metadata.name} applied!', 
              style: StandardizedTextStyle.bodyMedium,
              color: theme.colors.onPrimary, // Ensure text has proper contrast
            ),
          ],
        ),
        backgroundColor: theme.colors.primary,
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
      final currentTheme = Theme.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                PhosphorIcons.shuffle(),
                color: currentTheme.colorScheme.onPrimary, // Use current theme's proper contrast color
                size: 20,
              ),
              const SizedBox(width: 12),
              StandardizedText(
                'Random theme applied!', 
                style: StandardizedTextStyle.bodyMedium,
                color: currentTheme.colorScheme.onPrimary, // Ensure text has proper contrast
              ),
            ],
          ),
          backgroundColor: currentTheme.colorScheme.primary,
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
        title: const StandardizedText('Search Themes', style: StandardizedTextStyle.titleLarge),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Enter theme name or description...',
            prefixIcon: Icon(PhosphorIcons.magnifyingGlass()),
          ),
          onSubmitted: (query) {
            setState(() => _searchQuery = query);
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const StandardizedText('Cancel', style: StandardizedTextStyle.buttonText),
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
        title: const StandardizedText('Favorite Themes', style: StandardizedTextStyle.titleLarge),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              const StandardizedText('Your favorite themes will appear here.', style: StandardizedTextStyle.bodyMedium),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        PhosphorIcons.heart(),
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      const StandardizedText(
                        'No favorite themes yet',
                        style: StandardizedTextStyle.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      const StandardizedText(
                        'Tap the heart icon on any theme to add it to favorites',
                        style: StandardizedTextStyle.bodyMedium,
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
            child: const StandardizedText('Close', style: StandardizedTextStyle.buttonText),
          ),
        ],
      ),
    );
  }
}


