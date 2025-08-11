import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/typography_constants.dart';
import '../../../core/providers/enhanced_theme_provider.dart';
import '../../../core/theme/app_theme_data.dart';

/// Theme gallery widget with animated previews
class ThemeGalleryWidget extends ConsumerStatefulWidget {
  final bool showTitle;
  final EdgeInsets padding;
  final double itemHeight;
  final int crossAxisCount;
  
  const ThemeGalleryWidget({
    super.key,
    this.showTitle = true,
    this.padding = const EdgeInsets.all(16.0),
    this.itemHeight = 140.0,
    this.crossAxisCount = 2,
  });

  @override
  ConsumerState<ThemeGalleryWidget> createState() => _ThemeGalleryWidgetState();
}

class _ThemeGalleryWidgetState extends ConsumerState<ThemeGalleryWidget> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availableThemes = ref.watch(availableThemesProvider);
    final currentThemeState = ref.watch(enhancedThemeProvider);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showTitle) ...[
            Padding(
              padding: widget.padding,
              child: Text(
                'Theme Gallery',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          
          Padding(
            padding: widget.padding,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.crossAxisCount,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
              ),
              itemCount: availableThemes.length,
              itemBuilder: (context, index) {
                final theme = availableThemes[index];
                final isSelected = theme.metadata.id == currentThemeState.currentThemeId;
                
                return ThemePreviewCard(
                  theme: theme,
                  isSelected: isSelected,
                  onTap: () {
                    ref.read(enhancedThemeProvider.notifier).setTheme(theme.metadata.id);
                    _showThemeSelectedSnackBar(context, theme);
                  },
                  animationDelay: Duration(milliseconds: index * 100),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showThemeSelectedSnackBar(BuildContext context, AppThemeData theme) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Applied ${theme.metadata.name} theme'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Individual theme preview card with animations
class ThemePreviewCard extends StatefulWidget {
  final AppThemeData theme;
  final bool isSelected;
  final VoidCallback onTap;
  final Duration animationDelay;

  const ThemePreviewCard({
    super.key,
    required this.theme,
    required this.isSelected,
    required this.onTap,
    this.animationDelay = Duration.zero,
  });

  @override
  State<ThemePreviewCard> createState() => _ThemePreviewCardState();
}

class _ThemePreviewCardState extends State<ThemePreviewCard>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _glowController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _glowAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Start animation with delay
    Future.delayed(widget.animationDelay, () {
      if (mounted) {
        _slideController.forward();
        if (widget.isSelected) {
          _glowController.repeat(reverse: true);
        }
      }
    });
  }

  @override
  void didUpdateWidget(ThemePreviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _glowController.repeat(reverse: true);
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _glowController.stop();
      _glowController.reset();
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedBuilder(
          animation: widget.isSelected ? _glowAnimation : kAlwaysCompleteAnimation,
          builder: (context, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: Matrix4.identity()
                ..scale(_isHovered ? 1.05 : 1.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                  boxShadow: [
                    if (widget.isSelected)
                      BoxShadow(
                        color: widget.theme.colors.primary.withOpacity(
                          0.4 * _glowAnimation.value,
                        ),
                        blurRadius: 20.0,
                        spreadRadius: 2.0,
                      ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8.0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    onTap: widget.onTap,
                    child: _buildThemePreview(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildThemePreview() {
    final theme = widget.theme;
    final colors = theme.colors;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.background,
            colors.surface,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background pattern based on theme
          _buildBackgroundPattern(),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon and selection indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                      ),
                      child: Icon(
                        theme.metadata.previewIcon,
                        color: colors.onPrimaryContainer,
                        size: 20.0,
                      ),
                    ),
                    if (widget.isSelected)
                      Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: colors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: colors.onPrimary,
                          size: 16.0,
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Theme name
                Text(
                  theme.metadata.name,
                  style: TextStyle(
                    color: colors.onBackground,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4),
                
                // Theme category
                Text(
                  theme.metadata.category.toUpperCase(),
                  style: TextStyle(
                    color: colors.onBackground.withOpacity(0.7),
                    fontSize: 11.0,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                
                const Spacer(),
                
                // Color palette preview
                _buildColorPalette(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    final colors = widget.theme.colors;
    
    // Different patterns based on theme category
    switch (widget.theme.metadata.category) {
      case 'gaming':
        return _buildVegetaPattern(colors);
      case 'developer':
        if (widget.theme.metadata.id.contains('matrix')) {
          return _buildMatrixPattern(colors);
        } else {
          return _buildDraculaPattern(colors);
        }
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildVegetaPattern(colors) {
    return Positioned.fill(
      child: CustomPaint(
        painter: VegetaPatternPainter(
          primaryColor: colors.primary,
          secondaryColor: colors.secondary,
        ),
      ),
    );
  }

  Widget _buildMatrixPattern(colors) {
    return Positioned.fill(
      child: CustomPaint(
        painter: MatrixPatternPainter(
          codeColor: colors.primary,
          backgroundColor: colors.background,
        ),
      ),
    );
  }

  Widget _buildDraculaPattern(colors) {
    return Positioned.fill(
      child: CustomPaint(
        painter: DraculaPatternPainter(
          accentColor: colors.primary,
          backgroundColor: colors.background,
        ),
      ),
    );
  }

  Widget _buildColorPalette() {
    final colors = widget.theme.colors;
    final paletteColors = [
      colors.primary,
      colors.secondary,
      colors.tertiary,
      colors.accent,
    ];

    return Row(
      children: paletteColors.map((color) {
        return Container(
          width: 16.0,
          height: 16.0,
          margin: const EdgeInsets.only(right: 4.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            border: Border.all(
              color: colors.outline.withOpacity(0.3),
              width: 0.5,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// Custom painters for theme-specific patterns
class VegetaPatternPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  VegetaPatternPainter({
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw angular energy lines
    for (int i = 0; i < 3; i++) {
      paint.color = primaryColor.withOpacity(0.1 - (i * 0.03));
      final path = Path();
      path.moveTo(size.width * 0.2 + (i * 10), 0);
      path.lineTo(size.width * 0.8 - (i * 10), size.height * 0.4);
      path.moveTo(size.width * 0.1 + (i * 15), size.height * 0.6);
      path.lineTo(size.width * 0.9 - (i * 15), size.height);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MatrixPatternPainter extends CustomPainter {
  final Color codeColor;
  final Color backgroundColor;

  MatrixPatternPainter({
    required this.codeColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = codeColor.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw falling code columns
    for (int i = 0; i < 8; i++) {
      final x = (i * size.width / 7);
      for (int j = 0; j < 6; j++) {
        final y = (j * size.height / 5);
        canvas.drawRect(
          Rect.fromLTWH(x, y, 2.0, 8.0),
          paint..color = codeColor.withOpacity(0.1 - (j * 0.015)),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DraculaPatternPainter extends CustomPainter {
  final Color accentColor;
  final Color backgroundColor;

  DraculaPatternPainter({
    required this.accentColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accentColor.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    // Draw subtle geometric pattern
    final path = Path();
    path.moveTo(size.width * 0.3, 0);
    path.lineTo(size.width * 0.7, size.height * 0.3);
    path.lineTo(size.width, size.height * 0.1);
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);

    path.reset();
    path.moveTo(0, size.height * 0.6);
    path.lineTo(size.width * 0.4, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint..color = accentColor.withOpacity(0.05));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}