import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/design_system/design_tokens.dart';
import '../../core/accessibility/accessibility_constants.dart';
import '../../core/theme/typography_constants.dart';
import 'glassmorphism_container.dart';
import 'theme_background_widget.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Mobile-optimized scaffold with glassmorphism design
class MobileScaffold extends StatefulWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final Widget? drawer;
  final Widget? endDrawer;
  final bool extendBodyBehindAppBar;
  final bool resizeToAvoidBottomInset;
  final Color? backgroundColor;
  final PreferredSizeWidget? appBar;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const MobileScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.drawer,
    this.endDrawer,
    this.extendBodyBehindAppBar = true,
    this.resizeToAvoidBottomInset = true,
    this.backgroundColor,
    this.appBar,
    this.floatingActionButtonLocation,
  });

  @override
  State<MobileScaffold> createState() => _MobileScaffoldState();
}

class _MobileScaffoldState extends State<MobileScaffold> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    
    return ThemeBackgroundWidget(
      child: Scaffold(
        backgroundColor: widget.backgroundColor ?? Colors.transparent,
        extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
        resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
        drawer: widget.drawer,
        endDrawer: widget.endDrawer,
        floatingActionButton: widget.floatingActionButton,
        floatingActionButtonLocation: widget.floatingActionButtonLocation,
        bottomSheet: widget.bottomSheet,
        
        // Glass app bar
        appBar: widget.appBar ?? (widget.title != null 
            ? _buildGlassAppBar(theme, mediaQuery)
            : null),
        
        // Glass bottom navigation
        bottomNavigationBar: widget.bottomNavigationBar != null
            ? _wrapBottomNavigation(widget.bottomNavigationBar!)
            : null,
            
        body: widget.body,
      ),
    );
  }

  PreferredSizeWidget _buildGlassAppBar(ThemeData theme, MediaQueryData mediaQuery) {
    final isLargeText = AccessibilityUtils.isLargeTextEnabled(context);
    final statusBarHeight = mediaQuery.padding.top;
    
    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight + statusBarHeight),
      child: Container(
        padding: EdgeInsets.only(top: statusBarHeight),
        child: GlassmorphismContainer(
          level: GlassLevel.interactive,
          borderRadius: BorderRadius.zero,
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            title: widget.title != null
                ? Semantics(
                    header: true,
                    child: Text(
                      widget.title!,
                      style: TextStyle(
                        fontSize: isLargeText 
                            ? TypographyConstants.textXL 
                            : TypographyConstants.textLG,
                        fontWeight: TypographyConstants.medium,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  )
                : null,
            actions: widget.actions,
            iconTheme: IconThemeData(
              color: theme.colorScheme.onSurface,
            ),
            actionsIconTheme: IconThemeData(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _wrapBottomNavigation(Widget bottomNav) {
    return GlassmorphismContainer(
      level: GlassLevel.interactive,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: bottomNav,
    );
  }
}

/// Mobile-optimized navigation drawer
class MobileDrawer extends StatefulWidget {
  final String title;
  final List<DrawerItem> items;
  final Widget? header;
  final Widget? footer;
  final VoidCallback? onClose;

  const MobileDrawer({
    super.key,
    required this.title,
    required this.items,
    this.header,
    this.footer,
    this.onClose,
  });

  @override
  State<MobileDrawer> createState() => _MobileDrawerState();
}

class _MobileDrawerState extends State<MobileDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final isLargeText = AccessibilityUtils.isLargeTextEnabled(context);
    final shouldReduceMotion = AccessibilityUtils.shouldReduceMotion(context);

    return Semantics(
      scopesRoute: true,
      label: 'Navigation drawer',
      child: SlideTransition(
        position: shouldReduceMotion ? 
          const AlwaysStoppedAnimation(Offset.zero) : _slideAnimation,
        child: Drawer(
          backgroundColor: Colors.transparent,
          child: GlassmorphismContainer(
            level: GlassLevel.floating,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            child: Column(
              children: [
                // Header
                if (widget.header != null)
                  widget.header!
                else
                  _buildDefaultHeader(theme, mediaQuery, isLargeText),
                
                // Navigation items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: widget.items.length,
                    itemBuilder: (context, index) {
                      return _buildDrawerItem(theme, widget.items[index], isLargeText);
                    },
                  ),
                ),
                
                // Footer
                if (widget.footer != null)
                  widget.footer!,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultHeader(ThemeData theme, MediaQueryData mediaQuery, bool isLargeText) {
    return Container(
      height: 120 + mediaQuery.padding.top,
      padding: EdgeInsets.only(
        top: mediaQuery.padding.top + 16,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: isLargeText 
                      ? TypographyConstants.text2XL 
                      : TypographyConstants.textXL,
                  fontWeight: TypographyConstants.medium,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              widget.onClose?.call();
              Navigator.of(context).pop();
            },
            icon: Icon(PhosphorIcons.x()),
            tooltip: 'Close navigation drawer',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(ThemeData theme, DrawerItem item, bool isLargeText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
          onTap: () {
            HapticFeedback.lightImpact();
            item.onTap?.call();
            if (item.closesDrawer) {
              Navigator.of(context).pop();
            }
          },
          child: Semantics(
            button: true,
            label: item.label,
            hint: item.semanticHint,
            selected: item.isSelected,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  if (item.icon != null) ...[
                    Icon(
                      item.icon,
                      color: item.isSelected 
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 16),
                  ],
                  
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: isLargeText 
                            ? TypographyConstants.textBase 
                            : TypographyConstants.textSM,
                        fontWeight: item.isSelected 
                            ? TypographyConstants.medium 
                            : TypographyConstants.medium,
                        color: item.isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  
                  if (item.trailing != null)
                    item.trailing!,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Drawer item definition
class DrawerItem {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool closesDrawer;
  final Widget? trailing;
  final String? semanticHint;

  const DrawerItem({
    required this.label,
    this.icon,
    this.onTap,
    this.isSelected = false,
    this.closesDrawer = true,
    this.trailing,
    this.semanticHint,
  });
}

/// Mobile-optimized tab bar with glassmorphism
class MobileTabBar extends StatefulWidget implements PreferredSizeWidget {
  final List<TabItem> tabs;
  final TabController? controller;
  final Function(int)? onTap;
  final bool isScrollable;
  final EdgeInsetsGeometry? padding;

  const MobileTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.onTap,
    this.isScrollable = false,
    this.padding,
  });

  @override
  State<MobileTabBar> createState() => _MobileTabBarState();

  @override
  Size get preferredSize => const Size.fromHeight(48);
}

class _MobileTabBarState extends State<MobileTabBar> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLargeText = AccessibilityUtils.isLargeTextEnabled(context);

    return Container(
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
      child: GlassmorphismContainer(
        level: GlassLevel.interactive,
        borderRadius: BorderRadius.circular(24),
        child: TabBar(
          controller: widget.controller,
          onTap: (index) {
            HapticFeedback.selectionClick();
            widget.onTap?.call(index);
            
            AccessibilityUtils.announceToScreenReader(
              context,
              'Selected ${widget.tabs[index].label} tab',
            );
          },
          isScrollable: widget.isScrollable,
          indicator: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.all(4),
          labelColor: theme.colorScheme.onPrimary,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          labelStyle: TextStyle(
            fontSize: isLargeText 
                ? TypographyConstants.textSM 
                : TypographyConstants.textXS,
            fontWeight: TypographyConstants.medium,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: isLargeText 
                ? TypographyConstants.textSM 
                : TypographyConstants.textXS,
            fontWeight: TypographyConstants.medium,
          ),
          tabs: widget.tabs.map((tab) => Tab(
            text: tab.label,
            icon: tab.icon != null ? Icon(tab.icon, size: 18) : null,
          )).toList(),
        ),
      ),
    );
  }
}

/// Tab item definition
class TabItem {
  final String label;
  final IconData? icon;
  final String? semanticLabel;

  const TabItem({
    required this.label,
    this.icon,
    this.semanticLabel,
  });
}

/// Mobile-optimized search bar
class MobileSearchBar extends StatefulWidget {
  final String hintText;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final VoidCallback? onClear;
  final TextEditingController? controller;
  final bool autofocus;
  final List<String>? suggestions;

  const MobileSearchBar({
    super.key,
    this.hintText = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.controller,
    this.autofocus = false,
    this.suggestions,
  });

  @override
  State<MobileSearchBar> createState() => _MobileSearchBarState();
}

class _MobileSearchBarState extends State<MobileSearchBar>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  
  bool _isExpanded = false;
  // bool _hasFocus = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _focusNode.addListener(_onFocusChange);
    
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _expandSearch();
      });
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    // setState(() => _hasFocus = _focusNode.hasFocus);
    if (!_focusNode.hasFocus && _controller.text.isEmpty) {
      _collapseSearch();
    }
  }

  void _expandSearch() {
    setState(() => _isExpanded = true);
    _animationController.forward();
    _focusNode.requestFocus();
  }

  void _collapseSearch() {
    setState(() => _isExpanded = false);
    _animationController.reverse();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLargeText = AccessibilityUtils.isLargeTextEnabled(context);
    final shouldReduceMotion = AccessibilityUtils.shouldReduceMotion(context);

    return AnimatedBuilder(
      animation: shouldReduceMotion ? kAlwaysCompleteAnimation : _expandAnimation,
      builder: (context, child) {
        // final expansion = shouldReduceMotion ? (_isExpanded ? 1.0 : 0.0) : _expandAnimation.value;
        
        return Row(
          children: [
            // Expanded search field
            Expanded(
              child: GlassmorphismContainer(
                level: GlassLevel.interactive,
                borderRadius: BorderRadius.circular(24),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      PhosphorIcons.magnifyingGlass(),
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    
                    Expanded(
                      child: Semantics(
                        textField: true,
                        label: 'Search field',
                        hint: widget.hintText,
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          onChanged: widget.onChanged,
                          onSubmitted: widget.onSubmitted,
                          decoration: InputDecoration(
                            hintText: widget.hintText,
                            hintStyle: TextStyle(
                              fontSize: isLargeText 
                                  ? TypographyConstants.textBase 
                                  : TypographyConstants.textSM,
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            fontSize: isLargeText 
                                ? TypographyConstants.textBase 
                                : TypographyConstants.textSM,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    
                    // Clear button
                    if (_controller.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _controller.clear();
                          widget.onClear?.call();
                          HapticFeedback.lightImpact();
                        },
                        child: Semantics(
                          button: true,
                          label: 'Clear search',
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              PhosphorIcons.x(),
                              size: 18,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            // Cancel button (when expanded)
            if (_isExpanded) ...[
              const SizedBox(width: 12),
              SizeTransition(
                sizeFactor: _expandAnimation,
                axis: Axis.horizontal,
                child: GestureDetector(
                  onTap: () {
                    _controller.clear();
                    _collapseSearch();
                    widget.onClear?.call();
                    HapticFeedback.lightImpact();
                  },
                  child: Semantics(
                    button: true,
                    label: 'Cancel search',
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: isLargeText 
                            ? TypographyConstants.textBase 
                            : TypographyConstants.textSM,
                        color: theme.colorScheme.primary,
                        fontWeight: TypographyConstants.medium,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

