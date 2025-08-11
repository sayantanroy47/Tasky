import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../core/theme/material3/motion_system.dart';
import '../../core/theme/typography_constants.dart';
import '../../core/providers/navigation_provider.dart';

/// Expressive Material 3 Bottom Navigation with theme-aware styling and animations
class ExpressiveBottomNavigation extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final List<ExpressiveNavigationDestination> destinations;

  const ExpressiveBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  @override
  State<ExpressiveBottomNavigation> createState() => _ExpressiveBottomNavigationState();
}

class _ExpressiveBottomNavigationState extends State<ExpressiveBottomNavigation>
    with TickerProviderStateMixin {
  late AnimationController _selectionController;
  late AnimationController _pressController;
  late AnimationController _rippleController;
  
  late Animation<double> _selectionAnimation;
  late Animation<double> _pressAnimation;
  late Animation<double> _rippleAnimation;
  
  int? _pressedIndex;
  int? _rippleIndex;
  late PageController _indicatorController;

  @override
  void initState() {
    super.initState();
    
    _selectionController = AnimationController(
      duration: ExpressiveMotionSystem.durationMedium2,
      vsync: this,
    );
    
    _pressController = AnimationController(
      duration: ExpressiveMotionSystem.durationShort2,
      vsync: this,
    );
    
    _rippleController = AnimationController(
      duration: ExpressiveMotionSystem.durationMedium3,
      vsync: this,
    );
    
    _selectionAnimation = CurvedAnimation(
      parent: _selectionController,
      curve: ExpressiveMotionSystem.emphasizedDecelerate,
    );
    
    _pressAnimation = CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeInOut,
    );
    
    _rippleAnimation = CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    );
    
    _indicatorController = PageController(
      initialPage: widget.selectedIndex,
      viewportFraction: 0.25,
    );
    
    _selectionController.forward();
  }

  @override
  void didUpdateWidget(ExpressiveBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _indicatorController.animateToPage(
        widget.selectedIndex,
        duration: ExpressiveMotionSystem.durationMedium2,
        curve: ExpressiveMotionSystem.emphasizedDecelerate,
      );
      
      _selectionController.reset();
      _selectionController.forward();
    }
  }

  @override
  void dispose() {
    _selectionController.dispose();
    _pressController.dispose();
    _rippleController.dispose();
    _indicatorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.surface.withOpacity(0.0),
            theme.colorScheme.surface.withOpacity(0.8),
            theme.colorScheme.surface,
          ],
          stops: const [0.0, 0.3, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Stack(
            children: [
              // Background indicator
              AnimatedBuilder(
                animation: _selectionAnimation,
                builder: (context, child) {
                  return Positioned(
                    left: _calculateIndicatorPosition(context),
                    top: 8,
                    child: AnimatedContainer(
                      duration: ExpressiveMotionSystem.durationMedium2,
                      curve: ExpressiveMotionSystem.emphasizedDecelerate,
                      width: _calculateItemWidth(context),
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withOpacity(0.15),
                            theme.colorScheme.secondary.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              // Navigation items
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: widget.destinations.asMap().entries.map((entry) {
                  final index = entry.key;
                  final destination = entry.value;
                  final isSelected = index == widget.selectedIndex;
                  final isPressed = index == _pressedIndex;
                  
                  return _buildNavigationItem(
                    context,
                    destination,
                    index,
                    isSelected,
                    isPressed,
                  );
                }).toList(),
              ),
              
              // Ripple effect
              if (_rippleIndex != null)
                AnimatedBuilder(
                  animation: _rippleAnimation,
                  builder: (context, child) {
                    return Positioned(
                      left: _calculateRipplePosition(context),
                      top: 8,
                      child: Container(
                        width: _calculateItemWidth(context),
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary.withOpacity(
                            0.2 * (1 - _rippleAnimation.value),
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem(
    BuildContext context,
    ExpressiveNavigationDestination destination,
    int index,
    bool isSelected,
    bool isPressed,
  ) {
    final theme = Theme.of(context);
    
    return Expanded(
      child: GestureDetector(
        onTapDown: (details) {
          setState(() {
            _pressedIndex = index;
          });
          _pressController.forward();
          
          // Haptic feedback
          HapticFeedback.lightImpact();
        },
        onTapUp: (details) {
          _handleTapUp(index);
        },
        onTapCancel: () {
          _handleTapCancel();
        },
        child: AnimatedBuilder(
          animation: _pressAnimation,
          builder: (context, child) {
            final scale = isPressed 
                ? 1.0 - (_pressAnimation.value * 0.1)
                : 1.0;
                
            return Transform.scale(
              scale: scale,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon with theme-aware styling
                    AnimatedContainer(
                      duration: ExpressiveMotionSystem.durationShort3,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [
                                  theme.colorScheme.primary.withOpacity(0.2),
                                  theme.colorScheme.secondary.withOpacity(0.1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                      ),
                      child: AnimatedScale(
                        scale: isSelected ? 1.1 : 1.0,
                        duration: ExpressiveMotionSystem.durationShort3,
                        curve: ExpressiveMotionSystem.emphasizedDecelerate,
                        child: Icon(
                          isSelected ? destination.selectedIcon ?? destination.icon : destination.icon,
                          size: 20,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 2),
                    
                    // Label with animation
                    AnimatedDefaultTextStyle(
                      duration: ExpressiveMotionSystem.durationShort3,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      child: Text(
                        destination.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleTapUp(int index) {
    _pressController.reverse();
    
    setState(() {
      _rippleIndex = index;
      _pressedIndex = null;
    });
    
    _rippleController.forward().then((_) {
      _rippleController.reset();
      if (mounted) {
        setState(() {
          _rippleIndex = null;
        });
      }
    });
    
    widget.onDestinationSelected(index);
  }

  void _handleTapCancel() {
    _pressController.reverse();
    setState(() {
      _pressedIndex = null;
    });
  }

  double _calculateIndicatorPosition(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = _calculateItemWidth(context);
    final padding = 16.0;
    final availableWidth = screenWidth - (padding * 2);
    final spacing = (availableWidth - (itemWidth * widget.destinations.length)) / (widget.destinations.length - 1);
    
    return padding + (widget.selectedIndex * (itemWidth + spacing));
  }

  double _calculateRipplePosition(BuildContext context) {
    if (_rippleIndex == null) return 0;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = _calculateItemWidth(context);
    final padding = 16.0;
    final availableWidth = screenWidth - (padding * 2);
    final spacing = (availableWidth - (itemWidth * widget.destinations.length)) / (widget.destinations.length - 1);
    
    return padding + (_rippleIndex! * (itemWidth + spacing));
  }

  double _calculateItemWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = 32.0;
    return (screenWidth - padding) / widget.destinations.length;
  }
}

/// Enhanced navigation destination with more options
class ExpressiveNavigationDestination {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final String tooltip;

  const ExpressiveNavigationDestination({
    required this.icon,
    this.selectedIcon,
    required this.label,
    String? tooltip,
  }) : tooltip = tooltip ?? label;
}