import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/navigation_provider.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/typography_constants.dart';
import 'home_page_m3.dart';
import 'calendar_page.dart';
import 'analytics_page.dart';
import 'settings_page.dart';
import '../widgets/expressive_bottom_navigation.dart';
import '../widgets/manual_task_creation_dialog.dart';
import '../widgets/voice_only_creation_dialog.dart';
import '../widgets/voice_task_creation_dialog_m3.dart';
import '../widgets/theme_background_widget.dart';
import '../widgets/glassmorphism_container.dart';
import 'dart:ui';

/// Main scaffold with bottom navigation that switches between pages
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
      const SettingsPage(), // Menu will show settings
    ];

    return ThemeBackgroundWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent, // Make scaffold transparent to show background
        body: IndexedStack(
          index: selectedIndex,
          children: pages,
        ),
        bottomNavigationBar: Stack(
          clipBehavior: Clip.none, // Allow FAB to extend beyond stack bounds
          children: [
            // Bottom navigation container with notch
            Container(
              height: 70, // Back to original height
              margin: const EdgeInsets.only(bottom: 16.0, top: 14.0), // Add top margin for FAB clearance
              child: Stack(
                children: [
                  // Main glassmorphism container
                  GlassmorphismContainer(
                    height: 70,
                    borderRadius: BorderRadius.zero, // Remove container radius
                    padding: EdgeInsets.zero, // Remove all padding to center content
                    borderWidth: 0, // Remove all borders
                    child: Center( // Center the content vertically
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                    // Home
                    Expanded(
                      child: _buildNavItem(
                        context: context,
                        icon: selectedIndex == 0 ? Icons.home : Icons.home_outlined,
                        label: 'Home',
                        isSelected: selectedIndex == 0,
                        onTap: () => ref.read(navigationProvider.notifier).navigateToIndex(0),
                      ),
                    ),
                    // Calendar  
                    Expanded(
                      child: _buildNavItem(
                        context: context,
                        icon: selectedIndex == 1 ? Icons.calendar_today : Icons.calendar_today_outlined,
                        label: 'Calendar',
                        isSelected: selectedIndex == 1,
                        onTap: () => ref.read(navigationProvider.notifier).navigateToIndex(1),
                      ),
                    ),
                    // Spacer for FAB
                    const SizedBox(width: 80),
                    // Analytics
                    Expanded(
                      child: _buildNavItem(
                        context: context,
                        icon: selectedIndex == 2 ? Icons.analytics : Icons.analytics_outlined,
                        label: 'Analytics',
                        isSelected: selectedIndex == 2,
                        onTap: () => ref.read(navigationProvider.notifier).navigateToIndex(2),
                      ),
                    ),
                    // Menu
                    Expanded(
                      child: _buildNavItem(
                        context: context,
                        icon: selectedIndex == 3 ? Icons.menu : Icons.menu_outlined,
                        label: 'Menu',
                        isSelected: selectedIndex == 3,
                        onTap: () => ref.read(navigationProvider.notifier).navigateToIndex(3),
                      ),
                    ),
                        ],
                      ),
                    ),
                  ),
                  // Notch cutout for FAB (circular hole in the glass container)
                  Positioned(
                    top: 56, // At the top of container where FAB intersects
                    left: MediaQuery.of(context).size.width / 2 - 30,
                    child: Container(
                      width: 60,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                        child: Container(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // FAB positioned with 1/4 outside (above) container, 3/4 inside
            Positioned(
              bottom: 16 + 70 - 42, // Container bottom + height - 3/4 of FAB (42px) = 44px from screen bottom
              left: MediaQuery.of(context).size.width / 2 - 28,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    // Subtle glow effect
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                    child: FloatingActionButton(
                      heroTag: "mainFAB",
                      onPressed: () => _showTaskCreationMenu(context),
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.9),
                      elevation: 0, // Remove default elevation since we have custom glow
                      child: Icon(
                        Icons.add, 
                        color: Colors.white,
                        size: 28,
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

  /// Build navigation item for bottom app bar
  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusMedium),
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 8,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.clip,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Show task creation menu with 3 options
  void _showTaskCreationMenu(BuildContext context) {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 250,
        MediaQuery.of(context).size.height - 300,
        20,
        20,
      ),
      items: [
        PopupMenuItem<String>(
          value: 'manual',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 20),
            ),
            title: const Text('Manual'),
            subtitle: const Text('Type task details', style: TextStyle(fontSize: TypographyConstants.bodySmall)),
          ),
        ),
        PopupMenuItem<String>(
          value: 'voice_only',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.secondary,
                    Theme.of(context).colorScheme.tertiary,
                  ],
                ),
                borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
              ),
              child: const Icon(Icons.mic, color: Colors.white, size: 20),
            ),
            title: const Text('Voice Only'),
            subtitle: const Text('Record voice task', style: TextStyle(fontSize: TypographyConstants.bodySmall)),
          ),
        ),
        PopupMenuItem<String>(
          value: 'voice_to_text',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.tertiary,
                    Theme.of(context).colorScheme.primary,
                  ],
                ),
                borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
              ),
              child: const Icon(Icons.mic_none, color: Colors.white, size: 20),
            ),
            title: const Text('Voice → Text'),
            subtitle: const Text('Speak to fill form', style: TextStyle(fontSize: TypographyConstants.bodySmall)),
          ),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TypographyConstants.radiusMedium),
      ),
      elevation: 8,
    ).then((String? selected) {
      if (selected != null) {
        _handleTaskCreationOption(context, selected);
      }
    });
  }

  /// Handle task creation option selection
  void _handleTaskCreationOption(BuildContext context, String option) {
    // Import the required dialog widgets
    switch (option) {
      case 'manual':
        showDialog(
          context: context,
          builder: (context) => const ManualTaskCreationDialog(),
        );
        break;
      case 'voice_only':
        showDialog(
          context: context,
          builder: (context) => const VoiceOnlyCreationDialog(),
        );
        break;
      case 'voice_to_text':
        showDialog(
          context: context,
          builder: (context) => const VoiceTaskCreationDialog(),
        );
        break;
    }
  }
}