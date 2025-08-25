import 'package:flutter/material.dart';
import '../../domain/entities/project_template.dart' as domain;

/// Marketplace widget for browsing and selecting project templates
class ProjectTemplateMarketplace extends StatefulWidget {
  final List<domain.ProjectTemplate> templates;
  final Function(domain.ProjectTemplate)? onTemplateSelected;

  const ProjectTemplateMarketplace({
    super.key,
    this.templates = const [],
    this.onTemplateSelected,
  });

  @override
  State<ProjectTemplateMarketplace> createState() => _ProjectTemplateMarketplaceState();
}

class _ProjectTemplateMarketplaceState extends State<ProjectTemplateMarketplace> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final filteredTemplates = _filterTemplates();

    return Column(
      children: [
        _buildSearchAndFilter(),
        Expanded(
          child: _buildTemplateGrid(filteredTemplates),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search templates...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _getCategories().map((category) {
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = category);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateGrid(List<domain.ProjectTemplate> templates) {
    if (templates.isEmpty) {
      return const Center(
        child: Text('No templates found'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        return _buildTemplateCard(templates[index]);
      },
    );
  }

  Widget _buildTemplateCard(domain.ProjectTemplate template) {
    return Card(
      child: InkWell(
        onTap: () => widget.onTemplateSelected?.call(template),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getTemplateIcon(template.type),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      template.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (template.shortDescription != null)
                Text(
                  template.shortDescription!,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              const Spacer(),
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    size: 16,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    template.rating?.averageRating.toStringAsFixed(1) ?? '0.0',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Text(
                    '${template.taskTemplates.length} tasks',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<domain.ProjectTemplate> _filterTemplates() {
    var filtered = widget.templates;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((template) {
        return template.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               (template.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered.where((template) {
        return template.categoryId == _selectedCategory;
      }).toList();
    }

    return filtered;
  }

  List<String> _getCategories() {
    final categories = <String>{'All'};
    for (final template in widget.templates) {
      if (template.categoryId != null) {
        categories.add(template.categoryId!);
      }
    }
    return categories.toList();
  }

  IconData _getTemplateIcon(domain.ProjectTemplateType type) {
    switch (type) {
      case domain.ProjectTemplateType.simple:
        return Icons.description;
      case domain.ProjectTemplateType.wizard:
        return Icons.auto_fix_high;
      case domain.ProjectTemplateType.advanced:
        return Icons.settings;
    }
  }
}