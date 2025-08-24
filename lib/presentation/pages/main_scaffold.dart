import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/accessibility/accessibility_constants.dart';
import '../../core/design_system/design_tokens.dart';
import '../../core/design_system/responsive_builder.dart';
import '../../core/design_system/responsive_constants.dart';
import '../../core/providers/navigation_provider.dart';
import '../../core/theme/typography_constants.dart';
import '../widgets/adaptive_navigation.dart';
import '../widgets/glassmorphism_container.dart';
import '../widgets/standardized_fab.dart';
import '../widgets/standardized_text.dart';
import '../widgets/theme_background_widget.dart';
import 'analytics_page.dart';
import 'calendar_page.dart';
import 'home_page_m3.dart';
import 'location_task_creation_page.dart';
import 'manual_task_creation_page.dart';
import 'settings_page.dart';
import 'voice_only_creation_page.dart';
import 'voice_recording_page.dart';

/// Responsive main scaffold with adaptive navigation
class MainScaffold extends ConsumerWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);

    // Define the pages
    final pages = [
      const HomePage(),
      const CalendarPage(),
      const AnalyticsPage(),
      const SettingsPage(),
    ];

    // Define navigation items (labels removed for mobile bottom nav per REQ 0)
    final navigationItems = [
      AdaptiveNavigationItem(
        icon: PhosphorIcons.house(),
        selectedIcon: PhosphorIcons.house(),
        label: '',
        tooltip: 'Go to home screen',
      ),
      AdaptiveNavigationItem(
        icon: PhosphorIcons.calendar(),
        selectedIcon: PhosphorIcons.calendar(),
        label: '',
        tooltip: 'Go to calendar view',
      ),
      AdaptiveNavigationItem(
        icon: PhosphorIcons.chartBar(),
        selectedIcon: PhosphorIcons.chartBar(),
        label: '',
        tooltip: 'Go to analytics and insights',
      ),
      AdaptiveNavigationItem(
        icon: PhosphorIcons.gear(),
        selectedIcon: PhosphorIcons.gear(),
        label: '',
        tooltip: 'Go to settings and menu',
      ),
    ];

    return ThemeBackgroundWidget(
      child: ResponsiveLayout(
        mobile: _buildMobileLayout(context, ref, selectedIndex, pages, navigationItems),
        tablet: _buildTabletLayout(context, ref, selectedIndex, pages, navigationItems),
        desktop: _buildDesktopLayout(context, ref, selectedIndex, pages, navigationItems),
      ),
    );
  }

  /// Build mobile layout with bottom navigation
  Widget _buildMobileLayout(
    BuildContext context,
    WidgetRef ref,
    int selectedIndex,
    List<Widget> pages,
    List<AdaptiveNavigationItem> navigationItems,
  ) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true, // Allow background behind app bar
      extendBody: true, // Allow background behind bottom navigation
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: _buildBottomNavigation(context, ref, selectedIndex, navigationItems),
      floatingActionButton: StandardizedFABVariants.create(
        onPressed: () => _showTaskCreationMenu(context),
        heroTag: 'mainFAB',
        isLarge: true,
      ),
      floatingActionButtonLocation: const CenterDockedFloatingActionButtonLocation(),
    );
  }

  /// Build tablet layout with navigation rail
  Widget _buildTabletLayout(
    BuildContext context,
    WidgetRef ref,
    int selectedIndex,
    List<Widget> pages,
    List<AdaptiveNavigationItem> navigationItems,
  ) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true, // Allow background behind app bar
      extendBody: true, // Allow background behind navigation elements
      body: Row(
        children: [
          // Navigation rail
          Container(
            width: ResponsiveConstants.navRailWidth,
            padding: const EdgeInsets.all(16),
            child: GlassmorphismContainer(
              level: GlassLevel.background,
              borderRadius: BorderRadius.circular(ResponsiveConstants.tabletCardRadius),
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  // App logo
                  Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      PhosphorIcons.checkSquare(),
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 24,
                    ),
                  ),

                  // Navigation items
                  Expanded(
                    child: Column(
                      children: navigationItems.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final isSelected = selectedIndex == index;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Semantics(
                            label: '${item.label} navigation',
                            hint: item.tooltip,
                            button: true,
                            selected: isSelected,
                            child: InkWell(
                              onTap: () => ref.read(navigationProvider.notifier).navigateToIndex(index),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color:
                                      isSelected ? Theme.of(context).colorScheme.primaryContainer : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  isSelected ? item.selectedIcon : item.icon,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurfaceVariant,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // FAB
                  StandardizedFABVariants.create(
                    onPressed: () => _showTaskCreationMenu(context),
                    heroTag: 'tabletFAB',
                  ),
                ],
              ),
            ),
          ),

          // Main content
          Expanded(
            child: IndexedStack(
              index: selectedIndex,
              children: pages,
            ),
          ),
        ],
      ),
    );
  }

  /// Build desktop layout with navigation drawer
  Widget _buildDesktopLayout(
    BuildContext context,
    WidgetRef ref,
    int selectedIndex,
    List<Widget> pages,
    List<AdaptiveNavigationItem> navigationItems,
  ) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true, // Allow background behind app bar
      extendBody: true, // Allow background behind navigation elements
      body: Row(
        children: [
          // Navigation drawer
          Container(
            width: ResponsiveConstants.navDrawerWidth,
            padding: const EdgeInsets.all(24),
            child: GlassmorphismContainer(
              level: GlassLevel.background,
              borderRadius: BorderRadius.circular(ResponsiveConstants.desktopCardRadius),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            PhosphorIcons.checkSquare(),
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Task Tracker',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Navigation items
                  Expanded(
                    child: Column(
                      children: navigationItems.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final isSelected = selectedIndex == index;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Semantics(
                            label: '${item.label} navigation',
                            hint: item.tooltip,
                            button: true,
                            selected: isSelected,
                            child: ListTile(
                              leading: Icon(
                                isSelected ? item.selectedIcon : item.icon,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                                size: 28,
                              ),
                              title: Text(
                                item.label,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: isSelected
                                          ? Theme.of(context).colorScheme.primary
                                          : Theme.of(context).colorScheme.onSurfaceVariant,
                                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                                    ),
                              ),
                              selected: isSelected,
                              selectedTileColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              onTap: () => ref.read(navigationProvider.notifier).navigateToIndex(index),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Bottom section with FAB
                  const Divider(),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: StandardizedFABVariants.create(
                      onPressed: () => _showTaskCreationMenu(context),
                      heroTag: 'desktopFAB',
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main content with max width constraint
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: ResponsiveConstants.maxContentWidth,
                ),
                child: IndexedStack(
                  index: selectedIndex,
                  children: pages,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build bottom navigation for mobile with Material 3 design and glassmorphism
  Widget _buildBottomNavigation(
    BuildContext context,
    WidgetRef ref,
    int selectedIndex,
    List<AdaptiveNavigationItem> navigationItems,
  ) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        // Enhanced glassmorphism background with better transparency
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.surface.withValues(alpha: 0.5),
            theme.colorScheme.surface.withValues(alpha: 0.7),
          ],
        ),
        // Subtle shadow for depth
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
          child: BottomAppBar(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            notchMargin: 3, // 3px notch around FAB as requested
            shape: const CircularNotchedRectangle(),
            color: Colors.transparent, // Make transparent to show glassmorphism
            elevation: 0, // Remove default elevation
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // First two navigation items
                for (int i = 0; i < 2; i++)
                  _buildNavItem(
                    context: context,
                    item: navigationItems[i],
                    isSelected: selectedIndex == i,
                    onTap: () => ref.read(navigationProvider.notifier).navigateToIndex(i),
                  ),

                // Enhanced spacer for FAB with proper sizing
                const SizedBox(width: 88), // Increased width for better spacing

                // Last two navigation items
                for (int i = 2; i < navigationItems.length; i++)
                  _buildNavItem(
                    context: context,
                    item: navigationItems[i],
                    isSelected: selectedIndex == i,
                    onTap: () => ref.read(navigationProvider.notifier).navigateToIndex(i),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  /// Build navigation item for bottom app bar with accessibility and glassmorphism
  Widget _buildNavItem({
    required BuildContext context,
    required AdaptiveNavigationItem item,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Semantics(
      label: '${item.label} ${AccessibilityConstants.navigationSemanticLabel}',
      hint: item.tooltip,
      button: true,
      selected: isSelected,
      child: SizedBox(
        width: AccessibilityConstants.minTouchTarget,
        height: AccessibilityConstants.minTouchTarget,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TypographyConstants.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Enhanced icon with perfectly centered selection rectangle (REQ 0 alignment fix)
                Flexible(
                  child: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 32,
                      height: 32,
                      decoration: isSelected
                          ? BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                ),
                              ],
                            )
                          : null,
                      child: Icon(
                        isSelected ? item.selectedIcon : item.icon,
                        size: 24,
                        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Show task creation options menu
  void _showTaskCreationMenu(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ThemeBackgroundWidget(
        child: GlassmorphismContainer(
          level: GlassLevel.floating,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          margin: EdgeInsets.zero,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  StandardizedTextVariants.sectionHeader(
                    'Create New Task',
                  ),
                  const SizedBox(height: 8),
                  StandardizedTextVariants.body(
                    'Choose how you\'d like to create your task',
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 24),

                  // Task Creation Options in order: AI, Voice-Only, Location, Manual
                  _buildTaskCreationOption(
                    context: context,
                    icon: PhosphorIcons.microphone(),
                    iconColor: theme.colorScheme.primary,
                    title: 'AI Voice Entry',
                    subtitle: 'Speak your task, we\'ll transcribe it',
                    onTap: () async {
                      Navigator.pop(context);

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VoiceRecordingPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  _buildTaskCreationOption(
                    context: context,
                    icon: PhosphorIcons.waveform(),
                    iconColor: Colors.orange,
                    title: 'Voice-Only',
                    subtitle: 'Record audio notes without transcription',
                    onTap: () async {
                      Navigator.pop(context);

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VoiceOnlyCreationPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  _buildTaskCreationOption(
                    context: context,
                    icon: PhosphorIcons.mapPin(),
                    iconColor: Colors.blue,
                    title: 'Location-Based',
                    subtitle: 'Create task with geofencing alerts',
                    onTap: () async {
                      Navigator.pop(context);

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LocationTaskCreationPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  _buildTaskCreationOption(
                    context: context,
                    icon: PhosphorIcons.pencil(),
                    iconColor: Colors.green,
                    title: 'Manual Entry',
                    subtitle: 'Type your task details manually',
                    onTap: () async {
                      Navigator.pop(context);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManualTaskCreationPage(
                            prePopulatedData: <String, dynamic>{
                              'creationMode': 'manual',
                            },
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build individual task creation option
  Widget _buildTaskCreationOption({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge), // 16.0 - Fixed border radius hierarchy
      child: GlassmorphismContainer(
        level: GlassLevel.interactive,
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge), // 16.0 - Fixed border radius hierarchy
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(TypographyConstants.radiusMedium), // 12.0 - Fixed border radius hierarchy
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StandardizedTextVariants.cardTitle(
                    title,
                  ),
                  const SizedBox(height: 2),
                  StandardizedText(
                    subtitle,
                    style: StandardizedTextStyle.bodySmall,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
            Icon(
              PhosphorIcons.caretRight(),
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom FloatingActionButtonLocation that centers the FAB vertically within the bottom toolbar
class CenterDockedFloatingActionButtonLocation extends FloatingActionButtonLocation {
  const CenterDockedFloatingActionButtonLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    // Get the FAB size (72x72 as defined in _buildFloatingActionButton)
    const fabSize = 72.0;

    // Get the bottom navigation bar height (80px as defined in _buildBottomNavigation)
    const bottomNavHeight = 80.0;

    // Calculate horizontal center
    final double fabX = (scaffoldGeometry.scaffoldSize.width - fabSize) / 2.0;

    // Calculate vertical center within the bottom navigation bar
    // Position FAB so its center aligns with the center of the 80px toolbar
    // Fixed position - ignore system insets to prevent FAB movement
    final double fabY = scaffoldGeometry.scaffoldSize.height - bottomNavHeight + (bottomNavHeight - fabSize) / 2.0;

    return Offset(fabX, fabY);
  }

  @override
  String toString() => 'CenterDockedFloatingActionButtonLocation';
}
