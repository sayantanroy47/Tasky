import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../services/ui/mobile_gesture_service.dart';
import '../../services/ui/mobile_touch_targets_service.dart';
import '../../services/ui/slidable_feedback_service.dart';
import 'mobile_kanban_board.dart';
import 'mobile_project_navigation.dart';
import 'mobile_zoomable_timeline.dart';
import 'mobile_project_form.dart';
import 'enhanced_ux_widgets.dart';
import 'glassmorphism_container.dart';
import '../../core/theme/typography_constants.dart';

/// Integration widget that demonstrates all mobile gesture features
/// This serves as both a showcase and integration point for mobile optimizations
class MobileGestureIntegration extends ConsumerStatefulWidget {
  final String projectId;
  
  const MobileGestureIntegration({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<MobileGestureIntegration> createState() => _MobileGestureIntegrationState();
}

class _MobileGestureIntegrationState extends ConsumerState<MobileGestureIntegration>
    with TickerProviderStateMixin {
  late TabController _mainTabController;
  late AnimationController _tutorialAnimationController;
  
  bool _showTutorial = false;
  bool _gesturesEnabled = true;
  int _currentView = 0;

  final List<MobileView> _views = [
    const MobileView(
      name: 'Kanban Board',
      description: 'Touch-optimized drag & drop',
      icon: PhosphorIcons.kanban,
      gestures: ['Drag to move tasks', 'Swipe for actions', 'Long press for menu'],
    ),
    const MobileView(
      name: 'Timeline View',
      description: 'Pinch to zoom timeline',
      icon: PhosphorIcons.calendarBlank,
      gestures: ['Pinch to zoom', 'Pan to navigate', 'Tap for details'],
    ),
    const MobileView(
      name: 'Project Form',
      description: 'Mobile-first form design',
      icon: PhosphorIcons.folder,
      gestures: ['Swipe between steps', 'Tap color palette', 'Pull to refresh'],
    ),
    const MobileView(
      name: 'Navigation Hub',
      description: 'Gesture-based navigation',
      icon: PhosphorIcons.compass,
      gestures: ['Swipe between tabs', 'Double tap shortcuts', 'Edge swipe navigation'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: _views.length, vsync: this);
    _tutorialAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // Show tutorial on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showGestureTutorial();
    });
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _tutorialAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mobileGestureService = ref.read(mobileGestureServiceProvider);
    final touchService = ref.read(mobileTouchTargetsServiceProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              // Header with gesture controls
              _buildGestureHeader(theme, touchService),
              
              // Tab indicator
              _buildTabIndicator(theme, touchService),
              
              // Main content area with gesture navigation
              Expanded(
                child: mobileGestureService.createTabNavigationGestureDetector(
                  currentIndex: _currentView,
                  totalTabs: _views.length,
                  onTabChanged: _switchView,
                  enableSwipeNavigation: _gesturesEnabled,
                  semanticLabel: 'Mobile gesture demo views',
                  child: _buildMainContent(theme, mobileGestureService, touchService),
                ),
              ),
              
              // Bottom action bar
              _buildBottomActionBar(theme, touchService),
            ],
          ),
          
          // Gesture tutorial overlay
          if (_showTutorial)
            _buildTutorialOverlay(theme, mobileGestureService),
        ],
      ),
    );
  }

  Widget _buildGestureHeader(ThemeData theme, MobileTouchTargetsService touchService) {
    return SafeArea(
      bottom: false,
      child: GlassmorphismContainer(
        level: GlassLevel.floating,
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header row
              Row(
                children: [
                  // Back button
                  touchService.createTouchIconButton(
                    icon: PhosphorIcons.arrowLeft(),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Go back',
                    size: TouchTargetSize.standard,
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mobile Gestures',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Touch-optimized project management',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Settings button
                  touchService.createTouchIconButton(
                    icon: PhosphorIcons.gear(),
                    onPressed: _showGestureSettings,
                    tooltip: 'Gesture settings',
                    size: TouchTargetSize.standard,
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Help button
                  touchService.createTouchIconButton(
                    icon: PhosphorIcons.question(),
                    onPressed: _showGestureTutorial,
                    tooltip: 'Show tutorial',
                    size: TouchTargetSize.standard,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Current view info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                ),
                child: Row(
                  children: [
                    Icon(
                      _views[_currentView].icon(),
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _views[_currentView].name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _views[_currentView].description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Gesture toggle
                    touchService.createTouchToggle(
                      value: _gesturesEnabled,
                      onChanged: (value) {
                        setState(() => _gesturesEnabled = value);
                      },
                      semanticLabel: 'Toggle gestures',
                      child: Switch(
                        value: _gesturesEnabled,
                        onChanged: (value) {
                          setState(() => _gesturesEnabled = value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabIndicator(ThemeData theme, MobileTouchTargetsService touchService) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(_views.length, (index) {
          final view = _views[index];
          final isActive = index == _currentView;
          
          return Expanded(
            child: touchService.createTouchTarget(
              onTap: () => _switchView(index),
              size: TouchTargetSize.standard,
              enableHapticFeedback: true,
              enableVisualFeedback: true,
              backgroundColor: isActive
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
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
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMainContent(
    ThemeData theme,
    MobileGestureService gestureService,
    MobileTouchTargetsService touchService,
  ) {
    return PageView.builder(
      controller: PageController(initialPage: _currentView),
      onPageChanged: _switchView,
      itemCount: _views.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _mainTabController,
          builder: (context, child) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: _buildViewContent(index, theme, gestureService, touchService),
            );
          },
        );
      },
    );
  }

  Widget _buildViewContent(
    int viewIndex,
    ThemeData theme,
    MobileGestureService gestureService,
    MobileTouchTargetsService touchService,
  ) {
    switch (viewIndex) {
      case 0: // Kanban Board
        return MobileKanbanBoard(
          projectId: widget.projectId,
          enableDragDrop: _gesturesEnabled,
          enableSwipeActions: _gesturesEnabled,
          onRefresh: () {
            // Handle refresh
          },
        );
        
      case 1: // Timeline View
        return MobileZoomableTimeline(
          projectId: widget.projectId,
          enablePinchZoom: _gesturesEnabled,
          enablePanNavigation: _gesturesEnabled,
        );
        
      case 2: // Project Form
        return MobileProjectForm(
          project: null, // New project
          isFullScreen: false,
          onSuccess: () {
            // Handle success
          },
          onCancel: () {
            // Handle cancel
          },
        );
        
      case 3: // Navigation Hub
        return MobileProjectNavigation(
          projectId: widget.projectId,
          enableSwipeNavigation: _gesturesEnabled,
          enableGestureShortcuts: _gesturesEnabled,
        );
        
      default:
        return const Center(child: Text('Unknown view'));
    }
  }

  Widget _buildBottomActionBar(ThemeData theme, MobileTouchTargetsService touchService) {
    return GlassmorphismContainer(
      level: GlassLevel.floating,
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Previous view
              touchService.createTouchButton(
                onPressed: _currentView > 0 ? _previousView : null,
                size: TouchTargetSize.standard,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(PhosphorIcons.caretLeft(), size: 16),
                    const SizedBox(width: 4),
                    const Text('Previous'),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Gesture info
              touchService.createTouchTarget(
                onTap: _showCurrentGestures,
                size: TouchTargetSize.standard,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        PhosphorIcons.hand(),
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_views[_currentView].gestures.length} gestures',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Next view
              touchService.createTouchButton(
                onPressed: _currentView < _views.length - 1 ? _nextView : null,
                size: TouchTargetSize.standard,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Next'),
                    const SizedBox(width: 4),
                    Icon(PhosphorIcons.caretRight(), size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTutorialOverlay(ThemeData theme, MobileGestureService gestureService) {
    return AnimatedBuilder(
      animation: _tutorialAnimationController,
      builder: (context, child) {
        return Container(
          color: Colors.black.withValues(alpha: 0.7 * _tutorialAnimationController.value),
          child: Center(
            child: Transform.scale(
              scale: _tutorialAnimationController.value,
              child: GlassmorphismContainer(
                level: GlassLevel.floating,
                margin: const EdgeInsets.all(32),
                borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tutorial header
                      Row(
                        children: [
                          Icon(
                            PhosphorIcons.hand(),
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Mobile Gestures Tutorial',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _hideTutorial,
                            icon: Icon(PhosphorIcons.x()),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Current view gestures
                      ...List.generate(_views[_currentView].gestures.length, (index) {
                        final gesture = _views[_currentView].gestures[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  gesture,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      
                      const SizedBox(height: 20),
                      
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _hideTutorial,
                              child: const Text('Skip'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _hideTutorial,
                              child: const Text('Got it!'),
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
      },
    );
  }

  // Event handlers
  void _switchView(int index) {
    if (index != _currentView && index >= 0 && index < _views.length) {
      setState(() => _currentView = index);
      _mainTabController.animateTo(index);
    }
  }

  void _previousView() {
    if (_currentView > 0) {
      _switchView(_currentView - 1);
    }
  }

  void _nextView() {
    if (_currentView < _views.length - 1) {
      _switchView(_currentView + 1);
    }
  }

  void _showGestureTutorial() {
    setState(() => _showTutorial = true);
    _tutorialAnimationController.forward();
  }

  void _hideTutorial() {
    _tutorialAnimationController.reverse().then((_) {
      setState(() => _showTutorial = false);
    });
  }

  void _showGestureSettings() {
    Navigator.pushNamed(context, '/settings/gestures');
  }

  void _showCurrentGestures() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildGesturesSheet(),
    );
  }

  Widget _buildGesturesSheet() {
    final theme = Theme.of(context);
    final currentView = _views[_currentView];
    
    return GlassmorphismContainer(
      level: GlassLevel.floating,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(currentView.icon(), color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${currentView.name} Gestures',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Gestures list
            ...currentView.gestures.map((gesture) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        PhosphorIcons.hand(),
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          gesture,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
            
            const SizedBox(height: 16),
            
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mobile view configuration
class MobileView {
  final String name;
  final String description;
  final IconData Function() icon;
  final List<String> gestures;

  const MobileView({
    required this.name,
    required this.description,
    required this.icon,
    required this.gestures,
  });
}