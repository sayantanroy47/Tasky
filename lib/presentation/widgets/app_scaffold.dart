import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'standardized_app_bar.dart';
import '../../core/routing/app_router.dart';
import '../../core/providers/navigation_provider.dart';

/// Common scaffold widget with consistent navigation
class AppScaffold extends ConsumerWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showBottomNavigation;
  final PreferredSizeWidget? bottom;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.showBottomNavigation = true,
    this.bottom,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    final destinations = AppRouter.bottomNavigationDestinations;
    
    // Clamp selectedIndex to valid range to prevent out of bounds errors
    final safeSelectedIndex = selectedIndex.clamp(0, destinations.length - 1);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true, // Show phone status bar
      appBar: StandardizedAppBar(
        title: title,
        actions: actions,
        bottom: bottom,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: kToolbarHeight + 8),
          child: body,
        ),
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: showBottomNavigation
          ? BottomAppBar(
              shape: floatingActionButton != null 
                  ? const CircularNotchedRectangle() 
                  : null,
              notchMargin: 10.5, // For 72px FAB: cutout radius (38.5) - FAB radius (36) = 2.5, but BottomAppBar needs larger margin
              height: 80,
              color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
              child: NavigationBar(
                selectedIndex: safeSelectedIndex,
                onDestinationSelected: (index) {
                  AppRouter.navigateToIndexWithContext(context, index);
                  ref.read(navigationProvider.notifier).navigateToIndex(index);
                },
                destinations: destinations,
                height: 80,
                backgroundColor: Colors.transparent,
                indicatorColor: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
                indicatorShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              ),
            )
          : null,
      floatingActionButtonLocation: floatingActionButton != null 
          ? FloatingActionButtonLocation.centerDocked 
          : null,
    );
  }
}
