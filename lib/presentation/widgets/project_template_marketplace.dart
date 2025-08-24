import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/constants/phosphor_icons.dart';
import '../../core/design_system/design_tokens.dart';
import '../../core/theme/typography_constants.dart';
import '../../domain/entities/project_template.dart';
import 'glassmorphism_container.dart';

/// Comprehensive project template marketplace widget
/// 
/// Provides browsing, searching, and filtering of project templates
/// with categorization, ratings, and preview capabilities.
class ProjectTemplateMarketplace extends StatefulWidget {
  final List<ProjectTemplate> templates;
  final Function(ProjectTemplate template) onTemplateSelected;
  final Function(ProjectTemplate template)? onTemplatePreview;
  final Function(String query)? onSearch;
  final Function(ProjectTemplateFilter filter)? onFilterChanged;
  final bool showUserTemplates;
  final bool showSystemTemplates;

  const ProjectTemplateMarketplace({
    super.key,
    required this.templates,
    required this.onTemplateSelected,
    this.onTemplatePreview,
    this.onSearch,
    this.onFilterChanged,
    this.showUserTemplates = true,
    this.showSystemTemplates = true,
  });

  @override
  State<ProjectTemplateMarketplace> createState() => _ProjectTemplateMarketplaceState();
}

class _ProjectTemplateMarketplaceState extends State<ProjectTemplateMarketplace>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _searchController;
  
  ProjectTemplateFilter _currentFilter = const ProjectTemplateFilter();
  MarketplaceView _currentView = MarketplaceView.grid;
  List<ProjectTemplate> _filteredTemplates = [];

  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 4, vsync: this);
    _searchController = TextEditingController();
    
    _filteredTemplates = widget.templates;
    _applyFilters();
  }

  @override
  void didUpdateWidget(ProjectTemplateMarketplace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.templates != widget.templates) {
      _filteredTemplates = widget.templates;
      _applyFilters();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    List<ProjectTemplate> filtered = widget.templates;

    // Filter by search query
    if (_currentFilter.searchQuery.isNotEmpty) {
      final query = _currentFilter.searchQuery.toLowerCase();
      filtered = filtered.where((template) {
        return template.name.toLowerCase().contains(query) ||
               template.description?.toLowerCase().contains(query) == true ||
               template.tags.any((tag) => tag.toLowerCase().contains(query)) ||
               template.industryTags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    }

    // Filter by type
    if (_currentFilter.type != null) {
      filtered = filtered.where((t) => t.type == _currentFilter.type).toList();
    }

    // Filter by difficulty
    if (_currentFilter.maxDifficulty != null) {
      filtered = filtered.where((t) => t.difficultyLevel <= _currentFilter.maxDifficulty!).toList();
    }

    // Filter by category
    if (_currentFilter.categoryId != null) {
      filtered = filtered.where((t) => t.categoryId == _currentFilter.categoryId).toList();
    }

    // Filter by tags
    if (_currentFilter.tags.isNotEmpty) {
      filtered = filtered.where((template) {
        return _currentFilter.tags.any((tag) => 
            template.tags.contains(tag) || template.industryTags.contains(tag));
      }).toList();
    }

    // Filter by premium status
    if (_currentFilter.showOnlyFree) {
      filtered = filtered.where((t) => !t.isPremium).toList();
    }

    // Filter by template source
    if (!widget.showSystemTemplates) {
      filtered = filtered.where((t) => !t.isSystemTemplate).toList();
    }
    if (!widget.showUserTemplates) {
      filtered = filtered.where((t) => t.isSystemTemplate).toList();
    }

    // Sort templates
    switch (_currentFilter.sortBy) {
      case TemplateSortOption.name:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case TemplateSortOption.popularity:
        filtered.sort((a, b) => b.usageStats.usageCount.compareTo(a.usageStats.usageCount));
        break;
      case TemplateSortOption.rating:
        filtered.sort((a, b) {
          final ratingA = a.rating?.averageRating ?? 0;
          final ratingB = b.rating?.averageRating ?? 0;
          return ratingB.compareTo(ratingA);
        });
        break;
      case TemplateSortOption.newest:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case TemplateSortOption.difficulty:
        filtered.sort((a, b) => a.difficultyLevel.compareTo(b.difficultyLevel));
        break;
    }

    setState(() {
      _filteredTemplates = filtered;
    });
  }

  void _updateSearch(String query) {
    _currentFilter = _currentFilter.copyWith(searchQuery: query);
    _applyFilters();
    widget.onSearch?.call(query);
  }

  void _updateFilter(ProjectTemplateFilter filter) {
    _currentFilter = filter;
    _applyFilters();
    widget.onFilterChanged?.call(filter);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        _buildSearchAndFilter(theme),
        const SizedBox(height: TypographyConstants.paddingMedium),
        _buildTabBar(theme),
        const SizedBox(height: TypographyConstants.paddingMedium),
        Expanded(
          child: _buildContent(theme),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter(ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusMedium),
      padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
      child: Column(
        children: [
          // Search bar and view toggle
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search templates...',
                    prefixIcon: Icon(PhosphorIcons.magnifyingGlass()),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(PhosphorIcons.x()),
                            onPressed: () {
                              _searchController.clear();
                              _updateSearch('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
                    ),
                  ),
                  onChanged: _updateSearch,
                ),
              ),
              const SizedBox(width: TypographyConstants.paddingSmall),
              
              // View toggle
              ToggleButtons(
                isSelected: [
                  _currentView == MarketplaceView.grid,
                  _currentView == MarketplaceView.list,
                ],
                onPressed: (index) {
                  setState(() {
                    _currentView = index == 0 
                        ? MarketplaceView.grid 
                        : MarketplaceView.list;
                  });
                },
                children: [
                  Icon(PhosphorIcons.gridFour()),
                  Icon(PhosphorIcons.list()),
                ],
              ),
              
              const SizedBox(width: TypographyConstants.paddingSmall),
              
              // Filter button
              IconButton(
                icon: Icon(PhosphorIcons.funnel()),
                onPressed: () => _showFilterDialog(theme),
              ),
            ],
          ),
          
          const SizedBox(height: TypographyConstants.paddingSmall),
          
          // Active filters
          if (_hasActiveFilters()) _buildActiveFilters(theme),
        ],
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return TabBar(
      controller: _tabController,
      labelColor: theme.colorScheme.primary,
      unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
      indicatorColor: theme.colorScheme.primary,
      tabs: [
        Tab(
          icon: Icon(PhosphorIcons.star()),
          text: 'Featured',
        ),
        Tab(
          icon: Icon(PhosphorIcons.trendUp()),
          text: 'Popular',
        ),
        Tab(
          icon: Icon(PhosphorIcons.clock()),
          text: 'Recent',
        ),
        Tab(
          icon: Icon(PhosphorIcons.folder()),
          text: 'All',
        ),
      ],
    );
  }

  Widget _buildContent(ThemeData theme) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildTemplateGrid(theme, _getFeaturedTemplates()),
        _buildTemplateGrid(theme, _getPopularTemplates()),
        _buildTemplateGrid(theme, _getRecentTemplates()),
        _buildTemplateGrid(theme, _filteredTemplates),
      ],
    );
  }

  List<ProjectTemplate> _getFeaturedTemplates() {
    return _filteredTemplates.where((template) {
      final hasGoodRating = template.rating?.averageRating != null && 
                           template.rating!.averageRating >= 4.0;
      final hasGoodUsage = template.usageStats.usageCount >= 10;
      return hasGoodRating || hasGoodUsage || template.isSystemTemplate;
    }).toList();
  }

  List<ProjectTemplate> _getPopularTemplates() {
    final popular = List<ProjectTemplate>.from(_filteredTemplates);
    popular.sort((a, b) => b.usageStats.usageCount.compareTo(a.usageStats.usageCount));
    return popular;
  }

  List<ProjectTemplate> _getRecentTemplates() {
    final recent = List<ProjectTemplate>.from(_filteredTemplates);
    recent.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return recent.take(20).toList();
  }

  Widget _buildTemplateGrid(ThemeData theme, List<ProjectTemplate> templates) {
    if (templates.isEmpty) {
      return _buildEmptyState(theme);
    }

    if (_currentView == MarketplaceView.list) {
      return _buildTemplateList(theme, templates);
    }

    return GridView.builder(
      padding: const EdgeInsets.all(TypographyConstants.paddingSmall),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: TypographyConstants.paddingMedium,
        mainAxisSpacing: TypographyConstants.paddingMedium,
        childAspectRatio: 0.8,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        return ProjectTemplateCard(
          template: templates[index],
          onTap: () => widget.onTemplateSelected(templates[index]),
          onPreview: widget.onTemplatePreview,
          showDetails: true,
        );
      },
    );
  }

  Widget _buildTemplateList(ThemeData theme, List<ProjectTemplate> templates) {
    return ListView.builder(
      padding: const EdgeInsets.all(TypographyConstants.paddingSmall),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: TypographyConstants.paddingMedium),
          child: ProjectTemplateListItem(
            template: templates[index],
            onTap: () => widget.onTemplateSelected(templates[index]),
            onPreview: widget.onTemplatePreview,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.magnifyingGlass(),
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: TypographyConstants.paddingMedium),
          Text(
            'No templates found',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: TypographyConstants.paddingSmall),
          Text(
            'Try adjusting your search or filters',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return _currentFilter.type != null ||
           _currentFilter.maxDifficulty != null ||
           _currentFilter.categoryId != null ||
           _currentFilter.tags.isNotEmpty ||
           _currentFilter.showOnlyFree;
  }

  Widget _buildActiveFilters(ThemeData theme) {
    final filters = <Widget>[];

    if (_currentFilter.type != null) {
      filters.add(_buildFilterChip(
        theme,
        'Type: ${_currentFilter.type!.name}',
        () => _updateFilter(_currentFilter.copyWith(type: null)),
      ));
    }

    if (_currentFilter.maxDifficulty != null) {
      filters.add(_buildFilterChip(
        theme,
        'Max Difficulty: ${_currentFilter.maxDifficulty}',
        () => _updateFilter(_currentFilter.copyWith(maxDifficulty: null)),
      ));
    }

    for (final tag in _currentFilter.tags) {
      filters.add(_buildFilterChip(
        theme,
        tag,
        () {
          final newTags = List<String>.from(_currentFilter.tags)..remove(tag);
          _updateFilter(_currentFilter.copyWith(tags: newTags));
        },
      ));
    }

    if (_currentFilter.showOnlyFree) {
      filters.add(_buildFilterChip(
        theme,
        'Free only',
        () => _updateFilter(_currentFilter.copyWith(showOnlyFree: false)),
      ));
    }

    return Wrap(
      spacing: TypographyConstants.paddingSmall,
      runSpacing: TypographyConstants.paddingXSmall,
      children: filters,
    );
  }

  Widget _buildFilterChip(ThemeData theme, String label, VoidCallback onRemove) {
    return Chip(
      label: Text(label),
      deleteIcon: Icon(PhosphorIcons.x(), size: 14),
      onDeleted: onRemove,
      backgroundColor: theme.colorScheme.primaryContainer,
      labelStyle: TextStyle(color: theme.colorScheme.onPrimaryContainer),
    );
  }

  void _showFilterDialog(ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => ProjectTemplateFilterDialog(
        currentFilter: _currentFilter,
        onFilterChanged: _updateFilter,
      ),
    );
  }
}

/// Template card for grid view
class ProjectTemplateCard extends StatelessWidget {
  final ProjectTemplate template;
  final VoidCallback onTap;
  final Function(ProjectTemplate)? onPreview;
  final bool showDetails;

  const ProjectTemplateCard({
    super.key,
    required this.template,
    required this.onTap,
    this.onPreview,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GlassmorphismContainer(
      level: GlassLevel.content,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and type
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(TypographyConstants.paddingSmall),
                    decoration: BoxDecoration(
                      color: Color(int.parse(template.defaultColor.substring(1), radix: 16) + 0xFF000000)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
                    ),
                    child: Icon(
                      PhosphorIconConstants.getIconByName('template'),
                      color: Color(int.parse(template.defaultColor.substring(1), radix: 16) + 0xFF000000),
                      size: 16,
                    ),
                  ),
                  const Spacer(),
                  if (template.isPremium)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: TypographyConstants.paddingSmall,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
                      ),
                      child: Text(
                        'PRO',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: TypographyConstants.paddingMedium),
              
              // Template name
              Text(
                template.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: TypographyConstants.paddingSmall),
              
              // Short description
              if (template.shortDescription != null)
                Text(
                  template.shortDescription!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              
              const Spacer(),
              
              if (showDetails) ...[
                // Stats and rating
                Row(
                  children: [
                    // Difficulty
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          PhosphorIcons.star(
                            index < template.difficultyLevel 
                                ? PhosphorIconsStyle.fill 
                                : PhosphorIconsStyle.regular,
                          ),
                          size: 12,
                          color: index < template.difficultyLevel
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        );
                      }),
                    ),
                    
                    const Spacer(),
                    
                    // Usage count
                    Row(
                      children: [
                        Icon(
                          PhosphorIcons.users(),
                          size: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${template.usageStats.usageCount}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: TypographyConstants.paddingSmall),
                
                // Tags
                if (template.tags.isNotEmpty)
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: template.tags.take(2).map((tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: TypographyConstants.paddingSmall,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
                      ),
                      child: Text(
                        tag,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )).toList(),
                  ),
              ],
              
              const SizedBox(height: TypographyConstants.paddingSmall),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onTap,
                      child: const Text('Use Template'),
                    ),
                  ),
                  if (onPreview != null) ...[
                    const SizedBox(width: TypographyConstants.paddingSmall),
                    IconButton(
                      onPressed: () => onPreview!(template),
                      icon: Icon(PhosphorIcons.eye()),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Template list item for list view
class ProjectTemplateListItem extends StatelessWidget {
  final ProjectTemplate template;
  final VoidCallback onTap;
  final Function(ProjectTemplate)? onPreview;

  const ProjectTemplateListItem({
    super.key,
    required this.template,
    required this.onTap,
    this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GlassmorphismContainer(
      level: GlassLevel.content,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusMedium),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Color(int.parse(template.defaultColor.substring(1), radix: 16) + 0xFF000000)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
          ),
          child: Icon(
            PhosphorIconConstants.getIconByName('template'),
            color: Color(int.parse(template.defaultColor.substring(1), radix: 16) + 0xFF000000),
          ),
        ),
        title: Text(
          template.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (template.shortDescription != null)
              Text(
                template.shortDescription!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                // Difficulty stars
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      PhosphorIcons.star(
                        index < template.difficultyLevel 
                            ? PhosphorIconsStyle.fill 
                            : PhosphorIconsStyle.regular,
                      ),
                      size: 12,
                      color: index < template.difficultyLevel
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    );
                  }),
                ),
                const SizedBox(width: TypographyConstants.paddingSmall),
                Text(
                  '${template.usageStats.usageCount} uses',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (template.isPremium) ...[
                  const SizedBox(width: TypographyConstants.paddingSmall),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      'PRO',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontSize: TypographyConstants.labelSmall, // 11.0 - Fixed accessibility violation (was 10px)
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onPreview != null)
              IconButton(
                onPressed: () => onPreview!(template),
                icon: Icon(PhosphorIcons.eye()),
              ),
            IconButton(
              onPressed: onTap,
              icon: Icon(PhosphorIcons.arrowRight()),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

/// Filter dialog for advanced filtering
class ProjectTemplateFilterDialog extends StatefulWidget {
  final ProjectTemplateFilter currentFilter;
  final Function(ProjectTemplateFilter) onFilterChanged;

  const ProjectTemplateFilterDialog({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  State<ProjectTemplateFilterDialog> createState() => _ProjectTemplateFilterDialogState();
}

class _ProjectTemplateFilterDialogState extends State<ProjectTemplateFilterDialog> {
  late ProjectTemplateFilter _tempFilter;

  @override
  void initState() {
    super.initState();
    _tempFilter = widget.currentFilter;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: GlassmorphismContainer(
          level: GlassLevel.modal,
          borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
          padding: const EdgeInsets.all(TypographyConstants.paddingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    PhosphorIcons.funnel(),
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: TypographyConstants.paddingMedium),
                  Text(
                    'Filter Templates',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(PhosphorIcons.x()),
                  ),
                ],
              ),
              
              const SizedBox(height: TypographyConstants.paddingLarge),
              
              // Filter options
              // Template type
              DropdownButtonFormField<ProjectTemplateType?>(
                initialValue: _tempFilter.type,
                decoration: const InputDecoration(
                  labelText: 'Template Type',
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All types')),
                  ...ProjectTemplateType.values.map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type.name),
                  )),
                ],
                onChanged: (value) {
                  setState(() {
                    _tempFilter = _tempFilter.copyWith(type: value);
                  });
                },
              ),
              
              const SizedBox(height: TypographyConstants.paddingMedium),
              
              // Difficulty
              DropdownButtonFormField<int?>(
                initialValue: _tempFilter.maxDifficulty,
                decoration: const InputDecoration(
                  labelText: 'Max Difficulty',
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Any difficulty')),
                  ...List.generate(5, (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text('${index + 1} star${index > 0 ? 's' : ''}'),
                  )),
                ],
                onChanged: (value) {
                  setState(() {
                    _tempFilter = _tempFilter.copyWith(maxDifficulty: value);
                  });
                },
              ),
              
              const SizedBox(height: TypographyConstants.paddingMedium),
              
              // Sort by
              DropdownButtonFormField<TemplateSortOption>(
                initialValue: _tempFilter.sortBy,
                decoration: const InputDecoration(
                  labelText: 'Sort by',
                ),
                items: TemplateSortOption.values.map((option) => DropdownMenuItem(
                  value: option,
                  child: Text(option.displayName),
                )).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _tempFilter = _tempFilter.copyWith(sortBy: value);
                    });
                  }
                },
              ),
              
              const SizedBox(height: TypographyConstants.paddingMedium),
              
              // Free only checkbox
              CheckboxListTile(
                title: const Text('Free templates only'),
                value: _tempFilter.showOnlyFree,
                onChanged: (value) {
                  setState(() {
                    _tempFilter = _tempFilter.copyWith(showOnlyFree: value ?? false);
                  });
                },
              ),
              
              const SizedBox(height: TypographyConstants.paddingLarge),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _tempFilter = const ProjectTemplateFilter(); // Reset to defaults
                      });
                    },
                    child: const Text('Clear All'),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: TypographyConstants.paddingMedium),
                      ElevatedButton(
                        onPressed: () {
                          widget.onFilterChanged(_tempFilter);
                          Navigator.of(context).pop();
                        },
                        child: const Text('Apply'),
                      ),
                    ],
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

// ============================================================================
// SUPPORTING CLASSES
// ============================================================================

/// Filter configuration for project templates
class ProjectTemplateFilter {
  final String searchQuery;
  final ProjectTemplateType? type;
  final int? maxDifficulty;
  final String? categoryId;
  final List<String> tags;
  final bool showOnlyFree;
  final TemplateSortOption sortBy;

  const ProjectTemplateFilter({
    this.searchQuery = '',
    this.type,
    this.maxDifficulty,
    this.categoryId,
    this.tags = const [],
    this.showOnlyFree = false,
    this.sortBy = TemplateSortOption.popularity,
  });

  ProjectTemplateFilter copyWith({
    String? searchQuery,
    ProjectTemplateType? type,
    int? maxDifficulty,
    String? categoryId,
    List<String>? tags,
    bool? showOnlyFree,
    TemplateSortOption? sortBy,
  }) {
    return ProjectTemplateFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      type: type ?? this.type,
      maxDifficulty: maxDifficulty ?? this.maxDifficulty,
      categoryId: categoryId ?? this.categoryId,
      tags: tags ?? this.tags,
      showOnlyFree: showOnlyFree ?? this.showOnlyFree,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

/// Sort options for templates
enum TemplateSortOption {
  name,
  popularity,
  rating,
  newest,
  difficulty;

  String get displayName {
    switch (this) {
      case TemplateSortOption.name:
        return 'Name';
      case TemplateSortOption.popularity:
        return 'Popularity';
      case TemplateSortOption.rating:
        return 'Rating';
      case TemplateSortOption.newest:
        return 'Newest';
      case TemplateSortOption.difficulty:
        return 'Difficulty';
    }
  }
}

/// View modes for the marketplace
enum MarketplaceView {
  grid,
  list,
}