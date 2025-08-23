import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/standardized_app_bar.dart';
import '../widgets/theme_background_widget.dart';
import '../../core/theme/typography_constants.dart';

import '../../domain/entities/project.dart';
import '../providers/project_providers.dart';
import '../widgets/project_card.dart';
import '../widgets/project_form_dialog.dart';
import '../widgets/glassmorphism_container.dart';
import '../../core/design_system/design_tokens.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Page for managing projects
/// 
/// Displays all projects with their statistics, allows creating,
/// editing, and managing projects.
class ProjectsPage extends ConsumerStatefulWidget {
  const ProjectsPage({super.key});
  @override
  ConsumerState<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends ConsumerState<ProjectsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ThemeBackgroundWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: StandardizedAppBar(
          title: 'Projects',
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'Active', icon: Icon(PhosphorIcons.folder())),
              Tab(text: 'Archived', icon: Icon(PhosphorIcons.archive())),
              Tab(text: 'At Risk', icon: Icon(PhosphorIcons.warning())),
            ],
          ),
          actions: [
            IconButton(
              onPressed: _showSearchDialog,
              icon: Icon(PhosphorIcons.magnifyingGlass()),
              tooltip: 'Search projects',
            ),
            IconButton(
              onPressed: _refreshProjects,
              icon: Icon(PhosphorIcons.arrowClockwise()),
              tooltip: 'Refresh',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'projectsFAB',
          onPressed: _createProject,
          tooltip: 'Create Project',
          child: Icon(PhosphorIcons.plus()),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: kToolbarHeight + 48), // Account for TabBar
          child: Column(
        children: [
          // Search bar (if searching)
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: GlassmorphismContainer(
                level: GlassLevel.content,
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      PhosphorIcons.magnifyingGlass(),
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Searching for: "$_searchQuery"',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    GlassmorphismContainer(
                      level: GlassLevel.interactive,
                      borderRadius: BorderRadius.circular(20),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(padding: const EdgeInsets.all(8),
                            child: Icon(PhosphorIcons.x(), size: 20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildActiveProjectsTab(),
                _buildArchivedProjectsTab(),
                _buildAtRiskProjectsTab(),
              ],
            ),
          ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildActiveProjectsTab() {
    final projectsAsync = ref.watch(projectsProvider);
    
    return projectsAsync.when(
      data: (projects) {
        final activeProjects = projects
            .where((project) => !project.isArchived)
            .where((project) => _matchesSearch(project))
            .toList();

        if (activeProjects.isEmpty) {
          return _buildEmptyState(
            icon: PhosphorIcons.folder(),
            title: _searchQuery.isEmpty ? 'No Active Projects' : 'No Projects Found',
            subtitle: _searchQuery.isEmpty 
                ? 'Create your first project to get started'
                : 'Try adjusting your search terms',
            actionLabel: _searchQuery.isEmpty ? 'Create Project' : null,
            onAction: _searchQuery.isEmpty ? _createProject : null,
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshProjects,
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80), // Account for FAB
            itemCount: activeProjects.length,
            itemBuilder: (context, index) {
              final project = activeProjects[index];
              return ProjectCard(
                project: project,
                onTap: () => _viewProject(project),
                onEdit: () => _editProject(project),
                onDelete: () => _refreshProjects(),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildArchivedProjectsTab() {
    final projectsAsync = ref.watch(projectsProvider);
    
    return projectsAsync.when(
      data: (projects) {
        final archivedProjects = projects
            .where((project) => project.isArchived)
            .where((project) => _matchesSearch(project))
            .toList();

        if (archivedProjects.isEmpty) {
          return _buildEmptyState(
            icon: PhosphorIcons.archive(),
            title: _searchQuery.isEmpty ? 'No Archived Projects' : 'No Archived Projects Found',
            subtitle: _searchQuery.isEmpty 
                ? 'Archived projects will appear here'
                : 'Try adjusting your search terms',
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshProjects,
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: archivedProjects.length,
            itemBuilder: (context, index) {
              final project = archivedProjects[index];
              return ProjectCard(
                project: project,
                onTap: () => _viewProject(project),
                onEdit: () => _editProject(project),
                onDelete: () => _refreshProjects(),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildAtRiskProjectsTab() {
    final atRiskProjectsAsync = ref.watch(projectsAtRiskProvider);
    
    return atRiskProjectsAsync.when(
      data: (projects) {
        final filteredProjects = projects
            .where((project) => _matchesSearch(project))
            .toList();

        if (filteredProjects.isEmpty) {
          return _buildEmptyState(
            icon: PhosphorIcons.checkCircle(),
            title: _searchQuery.isEmpty ? 'No Projects at Risk' : 'No At-Risk Projects Found',
            subtitle: _searchQuery.isEmpty 
                ? 'All your projects are on track!'
                : 'Try adjusting your search terms',
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshProjects,
          child: Column(
            children: [
              // Warning header
              Padding(
                padding: const EdgeInsets.all(16),
                child: GlassmorphismContainer(
                  level: GlassLevel.interactive,
                  borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                  glassTint: Colors.orange.withValues(alpha: 0.1),
                  borderColor: Colors.orange.withValues(alpha: 0.3),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        PhosphorIcons.warning(),
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'These projects need attention due to overdue tasks, approaching deadlines, or low completion rates.',
                          style: TextStyle(color: Colors.orange.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Projects list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: filteredProjects.length,
                  itemBuilder: (context, index) {
                    final project = filteredProjects[index];
                    return ProjectCard(
                      project: project,
                      onTap: () => _viewProject(project),
                      onEdit: () => _editProject(project),
                      onDelete: () => _refreshProjects(),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              GlassmorphismContainer(
                level: GlassLevel.interactive,
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onAction,
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.8),
                            theme.colorScheme.primary.withValues(alpha: 0.6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                      ),
                      child: Text(
                        actionLabel,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.warningCircle(),
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Projects',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GlassmorphismContainer(
              level: GlassLevel.interactive,
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _refreshProjects,
                  borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.8),
                          theme.colorScheme.primary.withValues(alpha: 0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                    ),
                    child: Text(
                      'Retry',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _matchesSearch(Project project) {
    if (_searchQuery.isEmpty) return true;
    
    final query = _searchQuery.toLowerCase();
    return project.name.toLowerCase().contains(query) ||
           (project.description?.toLowerCase().contains(query) ?? false);
  }

  void _showSearchDialog() {
    final TextEditingController searchController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassmorphismContainer(
          level: GlassLevel.floating,
          borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Search Projects',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              GlassmorphismContainer(
                level: GlassLevel.interactive,
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                child: TextField(
                  controller: searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Search query',
                    hintText: 'Enter project name or description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                  onSubmitted: (value) {
                    setState(() {
                      _searchQuery = value.trim();
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GlassmorphismContainer(
                    level: GlassLevel.interactive,
                    borderRadius: BorderRadius.circular(8),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            'Cancel',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GlassmorphismContainer(
                    level: GlassLevel.interactive,
                    borderRadius: BorderRadius.circular(8),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _searchQuery = searchController.text.trim();
                          });
                          Navigator.of(context).pop();
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                                Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Search',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshProjects() async {
    await ref.read(projectsProvider.notifier).loadProjects();
    ref.invalidate(projectsAtRiskProvider);
  }

  void _createProject() {
    showDialog(
      context: context,
      builder: (context) => ProjectFormDialog(
        onSuccess: _refreshProjects,
      ),
    );
  }

  void _editProject(Project project) {
    showDialog(
      context: context,
      builder: (context) => ProjectFormDialog(
        project: project,
        onSuccess: _refreshProjects,
      ),
    );
  }

  void _viewProject(Project project) {
    Navigator.of(context).pushNamed(
      '/project-detail',
      arguments: project.id,
    );
  }
}



