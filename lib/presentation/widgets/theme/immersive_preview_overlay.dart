import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_theme_data.dart';
import '../glassmorphism_container.dart';

/// Immersive full-screen theme preview overlay with live UI component showcase
class ImmersivePreviewOverlay extends StatefulWidget {
  final AppThemeData theme;
  final VoidCallback onClose;
  final VoidCallback onApply;

  const ImmersivePreviewOverlay({
    super.key,
    required this.theme,
    required this.onClose,
    required this.onApply,
  });

  @override
  State<ImmersivePreviewOverlay> createState() => _ImmersivePreviewOverlayState();
}

class _ImmersivePreviewOverlayState extends State<ImmersivePreviewOverlay> with TickerProviderStateMixin {
  late AnimationController _overlayController;
  late AnimationController _contentController;
  late AnimationController _componentController;

  late Animation<double> _overlayAnimation;
  late Animation<double> _contentAnimation;
  late Animation<double> _componentAnimation;
  late Animation<Offset> _slideAnimation;

  int _selectedComponentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startEntryAnimation();
  }

  void _initializeAnimations() {
    // Overlay backdrop animation
    _overlayController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _overlayAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _overlayController, curve: Curves.easeOut));

    // Content slide-in animation
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _contentAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic));

    // Component showcase animation
    _componentController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _componentAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _componentController, curve: Curves.easeOutCubic));
  }

  void _startEntryAnimation() async {
    await _overlayController.forward();
    await _contentController.forward();
    await _componentController.forward();
  }

  Future<void> _exitAnimation() async {
    await _componentController.reverse();
    await _contentController.reverse();
    await _overlayController.reverse();
  }

  @override
  void dispose() {
    _overlayController.dispose();
    _contentController.dispose();
    _componentController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _buildPreviewThemeData(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_overlayAnimation, _contentAnimation, _componentAnimation]),
        builder: (context, child) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                // Backdrop with blur
                Opacity(
                  opacity: _overlayAnimation.value,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 20 * _overlayAnimation.value,
                      sigmaY: 20 * _overlayAnimation.value,
                    ),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.3 * _overlayAnimation.value),
                    ),
                  ),
                ),

                // Main preview content
                SlideTransition(
                  position: _slideAnimation,
                  child: Opacity(
                    opacity: _contentAnimation.value,
                    child: _buildPreviewContent(),
                  ),
                ),

                // Top controls
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 16,
                  right: 16,
                  child: Opacity(
                    opacity: _contentAnimation.value,
                    child: _buildTopControls(),
                  ),
                ),

                // Bottom action bar
                Positioned(
                  bottom: MediaQuery.of(context).padding.bottom + 16,
                  left: 16,
                  right: 16,
                  child: Opacity(
                    opacity: _contentAnimation.value,
                    child: _buildBottomActionBar(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  ThemeData _buildPreviewThemeData() {
    // Create a preview ThemeData based on the selected theme
    final colors = widget.theme.colors;

    return ThemeData(
      useMaterial3: true,
      brightness: widget.theme.metadata.id.contains('dark') ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.primary,
        brightness: widget.theme.metadata.id.contains('dark') ? Brightness.dark : Brightness.light,
        primary: colors.primary,
        secondary: colors.secondary,
        surface: colors.surface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  Widget _buildPreviewContent() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 80, 16, 100),
      child: GlassmorphismContainer(
        blur: 25,
        opacity: 0.15,
        borderWidth: 0.1,
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // Theme header
            _buildThemeHeader(),

            // Component showcase
            Expanded(
              child: AnimatedBuilder(
                animation: _componentAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 0.8 + (_componentAnimation.value * 0.2),
                    child: Opacity(
                      opacity: _componentAnimation.value,
                      child: _buildComponentShowcase(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeHeader() {
    final theme = Theme.of(context);
    final metadata = widget.theme.metadata;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.theme.colors.primary.withValues(alpha: 0.1),
            widget.theme.colors.secondary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Theme icon and name
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [widget.theme.colors.primary, widget.theme.colors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: widget.theme.colors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  metadata.previewIcon,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metadata.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      metadata.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Color palette showcase
          _buildColorPalette(),
        ],
      ),
    );
  }

  Widget _buildColorPalette() {
    final colors = widget.theme.colors;

    return Row(
      children: [
        Text(
          'Color Palette',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Row(
            children: [
              _buildColorSwatch('Primary', colors.primary),
              const SizedBox(width: 12),
              _buildColorSwatch('Secondary', colors.secondary),
              const SizedBox(width: 12),
              _buildColorSwatch('Accent', colors.accent),
              const SizedBox(width: 12),
              _buildColorSwatch('Surface', colors.surface),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColorSwatch(String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 0.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: TypographyConstants.labelSmall, // 11.0 - Fixed critical WCAG violation (was 10px)
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildComponentShowcase() {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _selectedComponentIndex = index;
        });
        HapticFeedback.selectionClick();
      },
      children: [
        _buildButtonShowcase(),
        _buildCardShowcase(),
        _buildInputShowcase(),
        _buildNavigationShowcase(),
      ],
    );
  }

  Widget _buildButtonShowcase() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Buttons & Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 24),

          // Primary buttons
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: Icon(PhosphorIcons.play()),
                  label: const Text('Primary'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(PhosphorIcons.heart()),
                  label: const Text('Outlined'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Text buttons and FAB
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () {},
                  icon: Icon(PhosphorIcons.share()),
                  label: const Text('Text Button'),
                ),
              ),
              const SizedBox(width: 12),
              FloatingActionButton(
                heroTag: 'themePreviewFAB',
                mini: true,
                onPressed: () {},
                child: Icon(PhosphorIcons.plus()),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Chips
          Wrap(
            spacing: 8,
            children: [
              Chip(
                label: const Text('Chip'),
                avatar: Icon(PhosphorIcons.star(), size: 16),
              ),
              FilterChip(
                label: const Text('Filter'),
                selected: true,
                onSelected: (_) {},
              ),
              ActionChip(
                label: const Text('Action'),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardShowcase() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cards & Surfaces',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Icon(
                          PhosphorIcons.user(),
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sample Card',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              'This is how cards look in this theme',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: const Text('Action 1'),
                      ),
                      FilledButton(
                        onPressed: () {},
                        child: const Text('Action 2'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputShowcase() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Inputs & Forms',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 24),
          TextField(
            decoration: InputDecoration(
              labelText: 'Text Field',
              hintText: 'Enter some text',
              prefixIcon: Icon(PhosphorIcons.textAa()),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: const Text('Checkbox'),
                  value: true,
                  onChanged: (_) {},
                ),
              ),
              Expanded(
                child: SwitchListTile(
                  title: const Text('Switch'),
                  value: true,
                  onChanged: (_) {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Slider(
            value: 0.5,
            onChanged: (_) {},
            label: 'Slider',
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationShowcase() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Navigation & Lists',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(PhosphorIcons.house()),
                  title: const Text('Home'),
                  trailing: Icon(PhosphorIcons.caretRight(), size: 16),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(PhosphorIcons.gear()),
                  title: const Text('Settings'),
                  subtitle: const Text('App preferences'),
                  trailing: Icon(PhosphorIcons.caretRight(), size: 16),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(PhosphorIcons.info()),
                  title: const Text('About'),
                  trailing: Icon(PhosphorIcons.caretRight(), size: 16),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Close button
        GlassmorphismContainer(
          blur: 20,
          opacity: 0.15,
          borderWidth: 0.1,
          padding: const EdgeInsets.all(12),
          child: GestureDetector(
            onTap: () async {
              await _exitAnimation();
              widget.onClose();
            },
            child: Icon(
              PhosphorIcons.x(),
              color: Theme.of(context).colorScheme.onSurface,
              size: 24,
            ),
          ),
        ),

        // Component navigation dots
        Row(
          children: List.generate(4, (index) {
            return GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _selectedComponentIndex == index
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        ),

        const SizedBox(width: 48), // Balance for close button
      ],
    );
  }

  Widget _buildBottomActionBar() {
    return Row(
      children: [
        Expanded(
          child: GlassmorphismContainer(
            blur: 20,
            opacity: 0.15,
            borderWidth: 0.1,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: OutlinedButton.icon(
              onPressed: () async {
                await _exitAnimation();
                widget.onClose();
              },
              icon: Icon(PhosphorIcons.arrowLeft()),
              label: const Text('Back to Gallery'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GlassmorphismContainer(
            blur: 20,
            opacity: 0.15,
            borderWidth: 0.1,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: FilledButton.icon(
              onPressed: () async {
                await _exitAnimation();
                widget.onApply();
              },
              icon: Icon(PhosphorIcons.check()),
              label: const Text('Apply Theme'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
