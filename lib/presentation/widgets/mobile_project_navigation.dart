import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/typography_constants.dart';
import '../../core/design_system/design_tokens.dart';
import '../../domain/entities/project.dart';
import '../../services/ui/mobile_gesture_service.dart';
import '../providers/project_providers.dart';
import 'enhanced_ux_widgets.dart';
import 'glassmorphism_container.dart';
import 'mobile_kanban_board.dart';
import 'analytics/project_analytics_dashboard.dart';

/// Mobile-optimized project navigation with gesture support
class MobileProjectNavigation extends ConsumerStatefulWidget {
  final String projectId;
  final int initialViewIndex;
  final bool enableSwipeNavigation;
  final bool enableGestureShortcuts;

  const MobileProjectNavigation({
    super.key,
    required this.projectId,
    this.initialViewIndex = 0,
    this.enableSwipeNavigation = true,
    this.enableGestureShortcuts = true,
  });

  @override
  ConsumerState<MobileProjectNavigation> createState() => _MobileProjectNavigationState();
}

class _MobileProjectNavigationState extends ConsumerState<MobileProjectNavigation>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _navigationAnimationController;
  late AnimationController _gestureAnimationController;
  
  int _currentViewIndex = 0;
  
  static const List<ProjectView> _projectViews = [
    ProjectView(
      name: 'Overview',
      icon: PhosphorIcons.info,
      shortcut: 'Double tap for overview',
    ),
    ProjectView(
      name: 'Kanban',
      icon: PhosphorIcons.kanban,
      shortcut: 'Swipe up for Kanban',
    ),
    ProjectView(
      name: 'Timeline',
      icon: PhosphorIcons.calendarBlank,
      shortcut: 'Swipe down for Timeline',
    ),
    ProjectView(
      name: 'Analytics',
      icon: PhosphorIcons.chartBar,
      shortcut: 'Long press for Analytics',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentViewIndex = widget.initialViewIndex.clamp(0, _projectViews.length - 1);
    
    _pageController = PageController(initialPage: _currentViewIndex);
    _navigationAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _gestureAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _navigationAnimationController.dispose();
    _gestureAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mobileGestureService = ref.read(mobileGestureServiceProvider);
    final projectAsync = ref.watch(projectProvider(widget.projectId));

    return projectAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => _buildErrorState(error.toString()),
      data: (project) => _buildProjectNavigation(context, theme, mobileGestureService, project),
    );
  }

  Widget _buildProjectNavigation(
    BuildContext context,
    ThemeData theme,
    MobileGestureService gestureService,
    Project? project,
  ) {
    if (project == null) {
      return _buildErrorState('Project not found');
    }

    return Scaffold(
      body: Column(
        children: [
          // Mobile navigation header
          _buildMobileNavigationHeader(theme, project),
          
          // Navigation tabs
          _buildNavigationTabs(theme, gestureService),
          
          // Project views with gesture support
          Expanded(
            child: _buildProjectViews(context, theme, gestureService, project),
          ),
        ],
      ),
      
      // Floating action button with gesture shortcuts
      floatingActionButton: _buildGestureShortcutsFAB(theme, gestureService),
      
      // Bottom navigation for mobile
      bottomNavigationBar: _buildMobileBottomNavigation(theme),
    );
  }

  Widget _buildMobileNavigationHeader(ThemeData theme, Project project) {
    return SafeArea(
      bottom: false,
      child: GlassmorphismContainer(
        level: GlassLevel.floating,
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Back button
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    PhosphorIcons.arrowLeft(),
                    color: theme.colorScheme.onSurface,
                    size: 20,
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Project info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _projectViews[_currentViewIndex].name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Quick actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildQuickActionButton(
                    theme,
                    PhosphorIcons.magnifyingGlass(),
                    'Search',
                    () => _showProjectSearch(),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickActionButton(
                    theme,
                    PhosphorIcons.funnel(),
                    'Filter',
                    () => _showProjectFilter(),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickActionButton(
                    theme,
                    PhosphorIcons.dotsThreeVertical(),
                    'More',
                    () => _showProjectMenu(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationTabs(ThemeData theme, MobileGestureService gestureService) {
    return gestureService.createTabNavigationGestureDetector(
      currentIndex: _currentViewIndex,
      totalTabs: _projectViews.length,
      onTabChanged: _navigateToView,
      enableSwipeNavigation: widget.enableSwipeNavigation,
      semanticLabel: 'Project navigation tabs',
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: List.generate(_projectViews.length, (index) {
            final view = _projectViews[index];
            final isActive = index == _currentViewIndex;
            
            return Expanded(
              child: GestureDetector(
                onTap: () => _navigateToView(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isActive
                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                    border: isActive
                        ? Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3))
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        view.icon(),
                        size: 20,
                        color: isActive
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        view.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isActive
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: isActive ? FontWeight.w500 : null,
                          // Using theme labelSmall size
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildProjectViews(
    BuildContext context,
    ThemeData theme,
    MobileGestureService gestureService,
    Project project,
  ) {
    return gestureService.createDragDropGestureDetector(
      itemId: 'project_view',
      itemType: 'view_container',
      canDrag: false,
      semanticLabel: 'Project views container',
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemCount: _projectViews.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double value = 1.0;
              if (_pageController.position.haveDimensions) {
                value = _pageController.page! - index;
                value = (1 - (value.abs() * 0.3)).clamp(0.7, 1.0);
              }

              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value,
                  child: _buildProjectView(context, theme, gestureService, project, index),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProjectView(
    BuildContext context,
    ThemeData theme,
    MobileGestureService gestureService,
    Project project,
    int viewIndex,
  ) {
    switch (viewIndex) {
      case 0: // Overview
        return _buildOverviewView(theme, project);
      case 1: // Kanban
        return MobileKanbanBoard(projectId: project.id);
      case 2: // Timeline
        return _buildTimelineView(theme, gestureService, project);
      case 3: // Analytics
        return ProjectAnalyticsDashboard(project: project);
      default:
        return const Center(child: Text('Unknown view'));
    }
  }

  Widget _buildOverviewView(ThemeData theme, Project project) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project summary cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  theme,
                  'Tasks',
                  project.taskCount.toString(),
                  PhosphorIcons.checkSquare(),
                  theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  theme,
                  'Progress',
                  '${(project.progress * 100).round()}%',
                  PhosphorIcons.trendUp(),
                  theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Recent activity
          _buildRecentActivity(theme, project),
          
          const SizedBox(height: 16),
          
          // Quick actions
          _buildQuickActions(theme, project),
        ],
      ),
    );
  }

  Widget _buildTimelineView(
    ThemeData theme,
    MobileGestureService gestureService,
    Project project,
  ) {
    return gestureService.createZoomableGestureDetector(
      minScale: 0.5,
      maxScale: 3.0,
      onScaleStart: () => HapticFeedback.selectionClick(),
      onScaleChanged: (scale) {
        // Update timeline scale
      },
      semanticLabel: 'Zoomable project timeline',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Project Timeline',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Pinch to zoom timeline view',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            // Timeline implementation would go here
            Container(
              height: 400,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              ),
              child: const Center(
                child: Text('Timeline View - Coming Soon'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    ThemeData theme,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      glassTint: color.withValues(alpha: 0.05),
      borderColor: color.withValues(alpha: 0.2),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(ThemeData theme, Project project) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            // Activity items would be generated here
            Text(
              'No recent activity',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme, Project project) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildActionChip(theme, 'Add Task', PhosphorIcons.plus(), () {}),
                _buildActionChip(theme, 'Edit Project', PhosphorIcons.pencil(), () {}),
                _buildActionChip(theme, 'Share', PhosphorIcons.share(), () {}),
                _buildActionChip(theme, 'Export', PhosphorIcons.download(), () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip(
    ThemeData theme,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    ThemeData theme,
    IconData icon,
    String tooltip,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(
          icon,
          color: theme.colorScheme.onSurface,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildGestureShortcutsFAB(ThemeData theme, MobileGestureService gestureService) {
    if (!widget.enableGestureShortcuts) return Container();

    return EnhancedFAB(
      onPressed: _showGestureShortcuts,
      tooltip: 'Gesture shortcuts',
      semanticLabel: 'Show gesture shortcuts',
      child: Icon(PhosphorIcons.hand()),
    );
  }

  Widget _buildMobileBottomNavigation(ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.floating,
      height: 80,
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBottomNavItem(theme, PhosphorIcons.house(), 'Home', () {
              Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
            }),
            _buildBottomNavItem(theme, PhosphorIcons.folder(), 'Projects', () {
              Navigator.pushReplacementNamed(context, '/projects');
            }),
            _buildBottomNavItem(theme, PhosphorIcons.checkSquare(), 'Tasks', () {
              Navigator.pushReplacementNamed(context, '/tasks');
            }),
            _buildBottomNavItem(theme, PhosphorIcons.chartBar(), 'Analytics', () {
              Navigator.pushReplacementNamed(context, '/analytics');
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(
    ThemeData theme,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: theme.colorScheme.onSurface,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.warningCircle(),
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading project',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            EnhancedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  // Event handlers
  void _navigateToView(int index) {
    if (index != _currentViewIndex) {
      setState(() => _currentViewIndex = index);
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      HapticFeedback.selectionClick();
    }
  }

  void _onPageChanged(int index) {
    if (index != _currentViewIndex) {
      setState(() => _currentViewIndex = index);
    }
  }

  void _showProjectSearch() {
    // Implement project search
    HapticFeedback.selectionClick();
  }

  void _showProjectFilter() {
    // Implement project filter
    HapticFeedback.selectionClick();
  }

  void _showProjectMenu() {
    // Implement project menu
    HapticFeedback.selectionClick();
  }

  void _showGestureShortcuts() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildGestureShortcutsSheet(),
    );
  }

  Widget _buildGestureShortcutsSheet() {
    final theme = Theme.of(context);
    
    return GlassmorphismContainer(
      level: GlassLevel.floating,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gesture Shortcuts',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            ...List.generate(_projectViews.length, (index) {
              final view = _projectViews[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(view.icon(), color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            view.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            view.shortcut,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            
            const SizedBox(height: 16),
            
            Center(
              child: EnhancedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Project view configuration
class ProjectView {
  final String name;
  final IconData Function() icon;
  final String shortcut;

  const ProjectView({
    required this.name,
    required this.icon,
    required this.shortcut,
  });
}