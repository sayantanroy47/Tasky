import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../standardized_app_bar.dart';
import '../../../core/providers/enhanced_theme_provider.dart';
import '../../../core/theme/app_theme_data.dart';
import 'epic_theme_preview_card.dart';
import 'ultra_modern_theme_gallery.dart';

/// A beautiful gallery for browsing and selecting themes
/// Now with ultra-modern design and enhanced preview capabilities
class ThemeGallery extends ConsumerStatefulWidget {
  final VoidCallback? onThemeSelected;
  final bool showSearchBar;
  final bool showCategories;
  final bool showAnimatedPreviews;
  final bool useUltraModernDesign;

  const ThemeGallery({
    super.key,
    this.onThemeSelected,
    this.showSearchBar = true,
    this.showCategories = true,
    this.showAnimatedPreviews = true,
    this.useUltraModernDesign = true, // Default to ultra-modern design
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
    // Use ultra-modern design by default
    if (widget.useUltraModernDesign) {
      return UltraModernThemeGallery(
        onThemeSelected: widget.onThemeSelected,
        enablePreviewMode: widget.showAnimatedPreviews,
        showFloatingControls: true,
      );
    }

    // Legacy theme gallery (fallback)
    final themeState = ref.watch(enhancedThemeProvider);
    final themes = _getFilteredThemes();
    final categories = ref.watch(themeCategoriesProvider);

    return Scaffold(
      appBar: StandardizedAppBar(
        title: 'Theme Gallery (Legacy)',
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
        crossAxisSpacing: 20,  // Increased spacing for epic cards
        mainAxisSpacing: 20,   // Increased spacing for epic cards
        childAspectRatio: 0.65, // Adjusted for taller epic cards
      ),
      itemCount: themes.length,
      itemBuilder: (context, index) {
        final theme = themes[index];
        final isSelected = currentTheme?.metadata.id == theme.metadata.id;
        
        return EpicThemePreviewCard(
          theme: theme,
          isSelected: isSelected,
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
