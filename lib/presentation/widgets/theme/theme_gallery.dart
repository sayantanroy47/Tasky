import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/typography_constants.dart';
import '../standardized_app_bar.dart';
import '../../../core/providers/enhanced_theme_provider.dart';
import '../../../core/theme/app_theme_data.dart';
import '../../../core/theme/models/theme_animations.dart';
import '../../../core/theme/models/theme_effects.dart';
import '../../../core/theme/painters/particle_painters.dart';
import '../../../core/theme/painters/background_painters.dart';

/// A beautiful gallery for browsing and selecting themes
class ThemeGallery extends ConsumerStatefulWidget {
  final VoidCallback? onThemeSelected;
  final bool showSearchBar;
  final bool showCategories;
  final bool showAnimatedPreviews;

  const ThemeGallery({
    super.key,
    this.onThemeSelected,
    this.showSearchBar = true,
    this.showCategories = true,
    this.showAnimatedPreviews = true,
  });

  @override
  ConsumerState<ThemeGallery> createState() => _ThemeGalleryState();
}

class _ThemeGalleryState extends ConsumerState<ThemeGallery>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(enhancedThemeProvider);
    final themes = _getFilteredThemes();
    final categories = ref.watch(themeCategoriesProvider);

    return Scaffold(
      appBar: StandardizedAppBar(
        title: 'Theme Gallery',
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: () {
              ref.read(enhancedThemeProvider.notifier).applyRandomTheme();
              widget.onThemeSelected?.call();
            },
            tooltip: 'Random Theme',
          ),
        ],
      ),
      body: Column(
        children: [
          if (widget.showSearchBar) ...[
            _buildSearchBar(),
            const SizedBox(height: 8),
          ],
          if (widget.showCategories) ...[
            _buildCategoryTabs(categories.toList()),
            const SizedBox(height: 16),
          ],
          Expanded(
            child: _buildThemeGrid(themes, themeState.currentTheme),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Search themes...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildCategoryTabs(List<String> categories) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildCategoryChip('All', _selectedCategory == null),
          const SizedBox(width: 8),
          ...categories.map((category) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildCategoryChip(
                  _formatCategoryName(category),
                  _selectedCategory == category,
                  category: category,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected, {String? category}) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = selected ? category : null;
        });
      },
    );
  }

  String _formatCategoryName(String category) {
    return category.split('_').map((word) => 
        word.substring(0, 1).toUpperCase() + word.substring(1)
    ).join(' ');
  }

  Widget _buildThemeGrid(List<AppThemeData> themes, AppThemeData? currentTheme) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: themes.length,
      itemBuilder: (context, index) {
        final theme = themes[index];
        final isSelected = currentTheme?.metadata.id == theme.metadata.id;
        
        return AnimatedThemePreviewCard(
          theme: theme,
          isSelected: isSelected,
          animationController: widget.showAnimatedPreviews ? _animationController : null,
          onTap: () => _selectTheme(theme.metadata.id),
        );
      },
    );
  }

  List<AppThemeData> _getFilteredThemes() {
    final themeNotifier = ref.read(enhancedThemeProvider.notifier);
    List<AppThemeData> themes;

    if (_selectedCategory != null) {
      themes = themeNotifier.getThemesByCategory(_selectedCategory!);
    } else {
      themes = themeNotifier.getAllThemes();
    }

    if (_searchQuery.isNotEmpty) {
      themes = themeNotifier.searchThemes(_searchQuery);
    }

    // Sort by popularity
    themes.sort((a, b) => b.metadata.popularityScore.compareTo(a.metadata.popularityScore));

    return themes;
  }

  void _selectTheme(String themeId) {
    ref.read(enhancedThemeProvider.notifier).setTheme(themeId);
    widget.onThemeSelected?.call();
  }
}

/// Animated theme preview card with particle effects
class AnimatedThemePreviewCard extends StatefulWidget {
  final AppThemeData theme;
  final bool isSelected;
  final AnimationController? animationController;
  final VoidCallback? onTap;

  const AnimatedThemePreviewCard({
    super.key,
    required this.theme,
    this.isSelected = false,
    this.animationController,
    this.onTap,
  });

  @override
  State<AnimatedThemePreviewCard> createState() => _AnimatedThemePreviewCardState();
}

class _AnimatedThemePreviewCardState extends State<AnimatedThemePreviewCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _hoverAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _hoverAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _hoverAnimation.value,
              child: _buildCard(context),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    final colors = widget.theme.colors;
    final metadata = widget.theme.metadata;
    final effects = widget.theme.effects;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: effects.getBorderRadius(5.0),
        border: Border.all(
          color: widget.isSelected ? colors.primary : colors.outline,
          width: widget.isSelected ? 3.0 : 1.0,
        ),
        boxShadow: effects.getShadows(
          widget.isSelected ? 8.0 : 4.0,
          colors.shadow,
        ),
      ),
      child: ClipRRect(
        borderRadius: effects.getBorderRadius(5.0),
        child: Stack(
          children: [
            // Background effects
            if (widget.animationController != null) ...[
              _buildBackgroundEffect(),
              if (widget.theme.animations.enableParticles) _buildParticleEffect(),
            ],
            
            // Theme preview content
            _buildThemeContent(colors, metadata),
            
            // Selection indicator
            if (widget.isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: colors.onPrimary,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundEffect() {
    final colors = widget.theme.colors;
    final effects = widget.theme.effects;

    Widget? backgroundPainter;

    switch (effects.backgroundEffects.particleType) {
      case BackgroundParticleType.energy:
        backgroundPainter = CustomPaint(
          painter: MetallicGradientMeshPainter(
            animation: widget.animationController!,
            primaryColor: colors.primary,
            secondaryColor: colors.secondary,
            config: effects.backgroundEffects,
            opacity: 0.3,
          ),
          size: Size.infinite,
        );
        break;
      case BackgroundParticleType.codeRain:
        backgroundPainter = CustomPaint(
          painter: MatrixScanlinesPainter(
            animation: widget.animationController!,
            primaryColor: colors.primary,
            secondaryColor: colors.secondary,
            config: effects.backgroundEffects,
            opacity: 0.4,
          ),
          size: Size.infinite,
        );
        break;
      case BackgroundParticleType.floating:
        backgroundPainter = CustomPaint(
          painter: SubtleFloatingElementsPainter(
            animation: widget.animationController!,
            primaryColor: colors.primary,
            secondaryColor: colors.secondary,
            config: effects.backgroundEffects,
            opacity: 0.2,
          ),
          size: Size.infinite,
        );
        break;
    }

    return Positioned.fill(child: backgroundPainter ?? const SizedBox());
  }

  Widget _buildParticleEffect() {
    final colors = widget.theme.colors;
    final config = widget.theme.animations.particleConfig;

    Widget? particlePainter;

    switch (config.style) {
      case ParticleStyle.geometric:
        particlePainter = CustomPaint(
          painter: EnergyOrbParticlePainter(
            animation: widget.animationController!,
            primaryColor: colors.primary,
            secondaryColor: colors.accent,
            config: config,
            opacity: 0.6,
          ),
          size: Size.infinite,
        );
        break;
      case ParticleStyle.digital:
        // Use smaller code rain for preview
        particlePainter = CustomPaint(
          painter: CodeRainParticlePainter(
            animation: widget.animationController!,
            primaryColor: colors.primary,
            secondaryColor: colors.highlight,
            config: config,
            opacity: 0.5,
          ),
          size: Size.infinite,
        );
        break;
      case ParticleStyle.organic:
        particlePainter = CustomPaint(
          painter: FloatingSymbolParticlePainter(
            animation: widget.animationController!,
            primaryColor: colors.primary,
            secondaryColor: colors.secondary,
            config: config,
            opacity: 0.4,
          ),
          size: Size.infinite,
        );
        break;
    }

    return Positioned.fill(child: particlePainter ?? const SizedBox());
  }

  Widget _buildThemeContent(dynamic colors, dynamic metadata) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Theme icon and name
          Row(
            children: [
              Icon(
                metadata.previewIcon,
                color: colors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  metadata.name,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Theme description
          Text(
            metadata.description,
            style: TextStyle(
              color: colors.onSurface.withOpacity(0.7),
              fontSize: 12,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          
          const Spacer(),
          
          // Color swatches
          Row(
            children: [
              _buildColorSwatch(colors.primary),
              const SizedBox(width: 4),
              _buildColorSwatch(colors.secondary),
              const SizedBox(width: 4),
              _buildColorSwatch(colors.accent),
              const SizedBox(width: 4),
              _buildColorSwatch(colors.background),
              
              const Spacer(),
              
              // Popularity score
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                ),
                child: Text(
                  '${metadata.popularityScore.toStringAsFixed(1)}★',
                  style: TextStyle(
                    color: colors.onPrimaryContainer,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Tags
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: metadata.tags.take(3).map<Widget>((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 8,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSwatch(Color color) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 0.5,
        ),
      ),
    );
  }

  void _setHovered(bool hovered) {
    if (_isHovered != hovered) {
      _isHovered = hovered;
      if (hovered) {
        _hoverController.forward();
      } else {
        _hoverController.reverse();
      }
    }
  }
}

/// Extension to add copyWith method to ParticleConfig
// ParticleConfig extension removed - using built-in copyWith method