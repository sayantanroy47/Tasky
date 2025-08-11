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
        floatingActionButton: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
            child: FloatingActionButton(
              heroTag: "mainFAB",
              onPressed: () => _showTaskCreationMenu(context),
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.9), // FILLED like before
              elevation: 8,
              child: Icon(
                Icons.add, 
                color: Colors.white, // White icon on colored background
                size: 28,
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
            child: BottomAppBar(
              notchMargin: 6,
              shape: const CircularNotchedRectangle(),
              color: Theme.of(context).colorScheme.surface.withOpacity(0.85), // Consistent with theme colors
              elevation: 8, // Match FAB elevation
              child: SizedBox(
                height: 80,
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
          ),
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
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: TypographyConstants.labelSmall,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.onSurfaceVariant,
              ),
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