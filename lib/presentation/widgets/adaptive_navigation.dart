import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_system/responsive_builder.dart';
import '../../core/design_system/responsive_constants.dart';
import '../../core/design_system/design_tokens.dart';
import '../../core/providers/navigation_provider.dart';
import 'glassmorphism_container.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Adaptive navigation that changes based on screen size
class AdaptiveNavigation extends ConsumerWidget {
  final List<AdaptiveNavigationItem> items;
  final Widget? floatingActionButton;
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const AdaptiveNavigation({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveBuilder(
      builder: (context, config) {
        switch (config.deviceType) {
          case ResponsiveDeviceType.mobile:
            return _buildBottomNavigation(context, config);
          case ResponsiveDeviceType.tablet:
            return _buildNavigationRail(context, config);
          case ResponsiveDeviceType.desktop:
          case ResponsiveDeviceType.largeDesktop:
            return _buildNavigationDrawer(context, config);
        }
      },
    );
  }

  /// Build bottom navigation for mobile devices
  Widget _buildBottomNavigation(BuildContext context, ResponsiveConfig config) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Bottom navigation container with cutout
        Container(
          height: ResponsiveConstants.bottomNavHeight,
          margin: EdgeInsets.only(
            bottom: config.margin.bottom,
            left: config.margin.left,
            right: config.margin.right,
          ),
          child: floatingActionButton != null
              ? ClipPath(
                  clipper: _BottomNavCutoutClipper(),
                  child: GlassmorphismContainer(
                    level: GlassLevel.floating,
                    height: ResponsiveConstants.bottomNavHeight - 16,
                    borderRadius: BorderRadius.circular(config.cardRadius),
                    padding: EdgeInsets.zero,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _buildNavigationItems(context, config, isHorizontal: true),
                    ),
                  ),
                )
              : GlassmorphismContainer(
                  level: GlassLevel.floating,
                  height: ResponsiveConstants.bottomNavHeight - 16,
                  borderRadius: BorderRadius.circular(config.cardRadius),
                  padding: EdgeInsets.zero,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _buildNavigationItems(context, config, isHorizontal: true),
                  ),
                ),
        ),
        
        // Floating Action Button
        if (floatingActionButton != null)
          Positioned(
            bottom: config.margin.bottom + 30,
            left: MediaQuery.of(context).size.width / 2 - 28,
            child: floatingActionButton!,
          ),
      ],
    );
  }

  /// Build navigation rail for tablets
  Widget _buildNavigationRail(BuildContext context, ResponsiveConfig config) {
    final theme = Theme.of(context);
    
    return Container(
      width: ResponsiveConstants.navRailWidth,
      padding: config.padding,
      child: GlassmorphismContainer(
        level: GlassLevel.content,
        borderRadius: BorderRadius.circular(config.cardRadius),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            // App logo or title
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                PhosphorIcons.checkSquare(),
                color: theme.colorScheme.onPrimary,
                size: 24,
              ),
            ),
            
            // Navigation items
            Expanded(
              child: Column(
                children: _buildNavigationItems(context, config, isHorizontal: false),
              ),
            ),
            
            // Floating Action Button
            if (floatingActionButton != null) ...[
              const SizedBox(height: 16),
              floatingActionButton!,
            ],
          ],
        ),
      ),
    );
  }

  /// Build navigation drawer for desktop
  Widget _buildNavigationDrawer(BuildContext context, ResponsiveConfig config) {
    final theme = Theme.of(context);
    
    return Container(
      width: ResponsiveConstants.navDrawerWidth,
      padding: config.padding,
      child: GlassmorphismContainer(
        level: GlassLevel.content,
        borderRadius: BorderRadius.circular(config.cardRadius),
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
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      PhosphorIcons.checkSquare(),
                      color: theme.colorScheme.onPrimary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Task Tracker',
                    style: theme.textTheme.titleLarge?.copyWith(
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
                children: _buildNavigationItems(context, config, isHorizontal: false, showLabels: true),
              ),
            ),
            
            // Bottom section with FAB
            if (floatingActionButton != null) ...[
              const Divider(),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: floatingActionButton!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build navigation items list
  List<Widget> _buildNavigationItems(
    BuildContext context, 
    ResponsiveConfig config, {
    required bool isHorizontal,
    bool showLabels = false,
  }) {
    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isSelected = selectedIndex == index;
      
      return _buildNavigationItem(
        context,
        config,
        item,
        isSelected,
        () => onDestinationSelected(index),
        isHorizontal: isHorizontal,
        showLabel: showLabels || !isHorizontal,
      );
    }).toList();
  }

  /// Build individual navigation item
  Widget _buildNavigationItem(
    BuildContext context,
    ResponsiveConfig config,
    AdaptiveNavigationItem item,
    bool isSelected,
    VoidCallback onTap, {
    required bool isHorizontal,
    required bool showLabel,
  }) {
    final theme = Theme.of(context);
    
    Widget child;
    
    if (isHorizontal) {
      // Bottom navigation item
      child = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(config.cardRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: isSelected ? BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ) : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? item.selectedIcon : item.icon,
                size: config.iconSize,
                color: isSelected 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.onSurfaceVariant,
              ),
              if (showLabel) ...[
                const SizedBox(height: 4),
                Text(
                  item.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isSelected 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      );
    } else {
      // Rail or drawer item
      child = Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Icon(
            isSelected ? item.selectedIcon : item.icon,
            size: config.iconSize,
            color: isSelected 
              ? theme.colorScheme.primary 
              : theme.colorScheme.onSurfaceVariant,
          ),
          title: showLabel ? Text(
            item.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isSelected 
                ? theme.colorScheme.primary 
                : theme.colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
          ) : null,
          selected: isSelected,
          selectedTileColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(config.cardRadius),
          ),
          onTap: onTap,
        ),
      );
    }

    return Semantics(
      label: '${item.label} navigation',
      hint: 'Go to ${item.label} screen',
      button: true,
      selected: isSelected,
      child: child,
    );
  }
}

/// Navigation item for adaptive navigation
class AdaptiveNavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String tooltip;

  const AdaptiveNavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.tooltip,
  });
}

/// Adaptive scaffold that uses responsive navigation
class AdaptiveScaffold extends ConsumerWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final List<AdaptiveNavigationItem> navigationItems;
  final Widget? drawer;
  final Widget? endDrawer;

  const AdaptiveScaffold({
    super.key,
    required this.body,
    required this.navigationItems,
    this.appBar,
    this.floatingActionButton,
    this.drawer,
    this.endDrawer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);

    return ResponsiveBuilder(
      builder: (context, config) {
        switch (config.deviceType) {
          case ResponsiveDeviceType.mobile:
            return _buildMobileScaffold(context, config, ref, selectedIndex);
          case ResponsiveDeviceType.tablet:
            return _buildTabletScaffold(context, config, ref, selectedIndex);
          case ResponsiveDeviceType.desktop:
          case ResponsiveDeviceType.largeDesktop:
            return _buildDesktopScaffold(context, config, ref, selectedIndex);
        }
      },
    );
  }

  /// Build mobile scaffold with bottom navigation
  Widget _buildMobileScaffold(
    BuildContext context, 
    ResponsiveConfig config, 
    WidgetRef ref, 
    int selectedIndex,
  ) {
    return Scaffold(
      appBar: appBar,
      body: body,
      drawer: drawer,
      endDrawer: endDrawer,
      bottomNavigationBar: AdaptiveNavigation(
        items: navigationItems,
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          ref.read(navigationProvider.notifier).navigateToIndex(index);
        },
        floatingActionButton: floatingActionButton,
      ),
      floatingActionButton: null, // Handled by adaptive navigation
    );
  }

  /// Build tablet scaffold with navigation rail
  Widget _buildTabletScaffold(
    BuildContext context, 
    ResponsiveConfig config, 
    WidgetRef ref, 
    int selectedIndex,
  ) {
    return Scaffold(
      body: Row(
        children: [
          AdaptiveNavigation(
            items: navigationItems,
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              ref.read(navigationProvider.notifier).navigateToIndex(index);
            },
            floatingActionButton: floatingActionButton,
          ),
          Expanded(
            child: Column(
              children: [
                if (appBar != null) appBar!,
                Expanded(child: body),
              ],
            ),
          ),
        ],
      ),
      drawer: drawer,
      endDrawer: endDrawer,
    );
  }

  /// Build desktop scaffold with navigation drawer
  Widget _buildDesktopScaffold(
    BuildContext context, 
    ResponsiveConfig config, 
    WidgetRef ref, 
    int selectedIndex,
  ) {
    return Scaffold(
      body: Row(
        children: [
          AdaptiveNavigation(
            items: navigationItems,
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              ref.read(navigationProvider.notifier).navigateToIndex(index);
            },
            floatingActionButton: floatingActionButton,
          ),
          Expanded(
            child: Column(
              children: [
                if (appBar != null) appBar!,
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: ResponsiveConstants.maxContentWidth,
                    ),
                    child: body,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      endDrawer: endDrawer,
    );
  }
}


/// Custom clipper for bottom navigation cutout
class _BottomNavCutoutClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    
    // Create path with circular cutout in center
    const cutoutRadius = 38.5; // FAB diameter (72) + 5px = 77px diameter / 2 = 38.5px radius
    final center = Offset(size.width / 2, size.height / 2); // Center of navigation bar
    
    // Create the entire navigation bar rectangle first
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    
    // Subtract the circular cutout in the center
    path.addOval(Rect.fromCircle(center: center, radius: cutoutRadius));
    
    // Use even-odd fill rule to create the cutout
    path.fillType = PathFillType.evenOdd;

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

