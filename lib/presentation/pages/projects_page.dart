import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/project.dart';
import '../providers/project_providers.dart';
import '../widgets/project_card.dart';
import '../widgets/project_form_dialog.dart';

/// Page for managing projects
/// 
/// Displays all projects with their statistics, allows creating,
/// editing, and managing projects.
class ProjectsPage extends ConsumerStatefulWidget {
  const ProjectsPage({super.key});  @override
  ConsumerState<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends ConsumerState<ProjectsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active', icon: Icon(Icons.folder)),
            Tab(text: 'Archived', icon: Icon(Icons.archive)),
            Tab(text: 'At Risk', icon: Icon(Icons.warning)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showSearchDialog,
            icon: const Icon(Icons.search),
            tooltip: 'Search projects',
          ),
          IconButton(
            onPressed: _refreshProjects,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar (if searching)
          if (_searchQuery.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              color: theme.colorScheme.surfaceContainerHighest.withOpacity( 0.1),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
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
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                    icon: const Icon(Icons.clear),
                  ),
                ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: _createProject,
        tooltip: 'Create Project',
        child: const Icon(Icons.add),
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
            icon: Icons.folder_open,
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
            icon: Icons.archive,
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
            icon: Icons.check_circle,
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity( 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity( 0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning,
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
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel),
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
              Icons.error_outline,
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
            ElevatedButton(
              onPressed: _refreshProjects,
              child: const Text('Retry'),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Projects'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Search query',
            hintText: 'Enter project name or description',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            setState(() {
              _searchQuery = value.trim();
            });
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Get the text from the dialog
              Navigator.of(context).pop();
            },
            child: const Text('Search'),
          ),
        ],
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
