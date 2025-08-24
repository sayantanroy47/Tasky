import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/design_system/design_tokens.dart';
import '../../core/design_system/responsive_builder.dart';
import '../../core/design_system/responsive_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/typography_constants.dart';
import '../../services/onboarding_service.dart';
import '../widgets/glassmorphism_container.dart';
import '../widgets/theme_background_widget.dart';
import '../widgets/standardized_animations.dart';

/// Comprehensive onboarding page for new users
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  int _currentPage = 0;
  bool _isAnimating = false;

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      title: 'onboarding_welcome',
      subtitle: 'onboarding_subtitle',
      description: 'Welcome to your personal task management companion. Organize your life with style and efficiency.',
      icon: PhosphorIcons.handWaving(),
      gradient: [Colors.blue, Colors.purple],
      features: ['AI-powered task parsing', 'Voice commands', 'Smart scheduling'],
    ),
    OnboardingStep(
      title: 'Voice-Powered Tasks',
      subtitle: 'Speak Your Mind',
      description:
          'Create tasks by simply speaking. Our AI understands context and creates perfect tasks from your voice.',
      icon: PhosphorIcons.microphone(),
      gradient: [Colors.green, Colors.teal],
      features: ['Natural language processing', 'Context awareness', 'Multi-language support'],
    ),
    OnboardingStep(
      title: 'Smart Organization',
      subtitle: 'Intelligent Categorization',
      description: 'Tasks are automatically categorized, prioritized, and scheduled using advanced AI algorithms.',
      icon: PhosphorIcons.sparkle(),
      gradient: [Colors.orange, Colors.red],
      features: ['Auto-categorization', 'Smart priorities', 'Deadline management'],
    ),
    OnboardingStep(
      title: 'Beautiful Themes',
      subtitle: 'Express Yourself',
      description: 'Choose from stunning themes that adapt to your mood and environment.',
      icon: PhosphorIcons.palette(),
      gradient: [Colors.pink, Colors.indigo],
      features: ['Dynamic themes', 'Dark/Light modes', 'Custom color schemes'],
    ),
    OnboardingStep(
      title: 'Cross-Platform Sync',
      subtitle: 'Always Connected',
      description: 'Your tasks sync seamlessly across all your devices with end-to-end encryption.',
      icon: PhosphorIcons.arrowsClockwise(),
      gradient: [Colors.cyan, Colors.blue],
      features: ['Real-time sync', 'Offline support', 'Secure encryption'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupPageController();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: StandardizedAnimations.slower,
      vsync: this,
    );

    _slideController = AnimationController(
      duration: StandardizedAnimations.drawerTransition,
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: StandardizedAnimations.modalTransition,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Start initial animations
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  void _setupPageController() {
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _nextPage() async {
    if (_isAnimating) return;

    setState(() => _isAnimating = true);

    if (_currentPage < _steps.length - 1) {
      // Animate out current content
      await Future.wait([
        _fadeController.reverse(),
        _slideController.reverse(),
      ]);

      // Move to next page
      await _pageController.nextPage(
        duration: StandardizedAnimations.modalTransition,
        curve: Curves.easeInOut,
      );

      // Animate in new content
      await Future.wait([
        _fadeController.forward(),
        _slideController.forward(),
      ]);
    } else {
      await _finishOnboarding();
    }

    setState(() => _isAnimating = false);
  }

  Future<void> _previousPage() async {
    if (_isAnimating || _currentPage == 0) return;

    setState(() => _isAnimating = true);

    // Animate out current content
    await Future.wait([
      _fadeController.reverse(),
      _slideController.reverse(),
    ]);

    // Move to previous page
    await _pageController.previousPage(
      duration: StandardizedAnimations.modalTransition,
      curve: Curves.easeInOut,
    );

    // Animate in new content
    await Future.wait([
      _fadeController.forward(),
      _slideController.forward(),
    ]);

    setState(() => _isAnimating = false);
  }

  Future<void> _skipOnboarding() async {
    await _finishOnboarding();
  }

  Future<void> _finishOnboarding() async {
    final onboardingService = ref.read(onboardingServiceProvider);
    await onboardingService.completeOnboarding();

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ThemeBackgroundWidget(
      child: ResponsiveBuilder(
        builder: (context, config) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                // Main content
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemCount: _steps.length,
                  itemBuilder: (context, index) {
                    return _buildOnboardingStep(context, config, _steps[index], l10n);
                  },
                ),

                // Progress indicator
                _buildProgressIndicator(context, config),

                // Navigation buttons
                _buildNavigationButtons(context, config, l10n),

                // Skip button
                _buildSkipButton(context, config, l10n),

                // Performance indicator removed - widget doesn't exist
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOnboardingStep(
    BuildContext context,
    ResponsiveConfig config,
    OnboardingStep step,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: config.padding,
      child: Column(
        children: [
          // Hero section
          Expanded(
            flex: 3,
            child: AnimatedBuilder(
              animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: _buildHeroSection(context, config, step, theme),
                  ),
                );
              },
            ),
          ),

          // Content section
          Expanded(
            flex: 2,
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildContentSection(context, config, step, theme, l10n),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(
    BuildContext context,
    ResponsiveConfig config,
    OnboardingStep step,
    ThemeData theme,
  ) {
    return Center(
      child: SizedBox(
        width: config.isMobile ? 250 : 350,
        height: config.isMobile ? 250 : 350,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background gradient circle
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    step.gradient[0].withValues(alpha: 0.3),
                    step.gradient[1].withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // Animated rings
            ..._buildAnimatedRings(step.gradient),

            // Main icon
            GlassmorphismContainer(
              level: GlassLevel.floating,
              width: config.isMobile ? 120 : 150,
              height: config.isMobile ? 120 : 150,
              borderRadius: BorderRadius.circular(config.isMobile ? BorderRadiusTokens.full : BorderRadiusTokens.full),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: step.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  step.icon,
                  size: config.isMobile ? 60 : 75,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAnimatedRings(List<Color> gradient) {
    return List.generate(3, (index) {
      return AnimatedBuilder(
        animation: _scaleController,
        builder: (context, child) {
          final scale = 1.0 + (index * 0.2) + (_scaleController.value * 0.1);
          final opacity = (1.0 - index * 0.3) * (1.0 - _scaleController.value * 0.5);

          return Transform.scale(
            scale: scale,
            child: Container(
              width: 180.0 + (index * 40),
              height: 180.0 + (index * 40),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: gradient[0].withValues(alpha: opacity),
                  width: 2,
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildContentSection(
    BuildContext context,
    ResponsiveConfig config,
    OnboardingStep step,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        // Title
        Text(
          step.title.startsWith('onboarding_') ? _getLocalizedString(l10n, step.title) : step.title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w500,
            // Removed hardcoded fontSize - using theme.textTheme.headlineMedium default (28.0)
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        // Subtitle
        Text(
          step.subtitle.startsWith('onboarding_') ? _getLocalizedString(l10n, step.subtitle) : step.subtitle,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            // Removed hardcoded fontSize - using theme.textTheme.titleLarge default (22.0)
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 24),

        // Description
        Padding(
          padding: EdgeInsets.symmetric(horizontal: config.isMobile ? 20 : 40),
          child: Text(
            step.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              // Removed hardcoded fontSize - using theme.textTheme.bodyLarge default (16.0)
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 32),

        // Features
        if (step.features.isNotEmpty) ...[
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: step.features.map((feature) {
              return GlassmorphismContainer(
                level: GlassLevel.background,
                borderRadius: BorderRadius.circular(BorderRadiusTokens.lg),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PhosphorIcons.checkCircle(),
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      feature,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildProgressIndicator(BuildContext context, ResponsiveConfig config) {
    return Positioned(
      top: config.isMobile ? 80 : 100,
      left: 0,
      right: 0,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_steps.length, (index) {
            return AnimatedContainer(
              duration: StandardizedAnimations.modalTransition,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(BorderRadiusTokens.xs),
                color: _currentPage == index
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(
    BuildContext context,
    ResponsiveConfig config,
    AppLocalizations l10n,
  ) {
    return Positioned(
      bottom: config.isMobile ? 40 : 60,
      left: config.padding.left,
      right: config.padding.right,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          AnimatedOpacity(
            opacity: _currentPage > 0 ? 1.0 : 0.0,
            duration: StandardizedAnimations.pageTransition,
            child: GestureDetector(
              onTap: _currentPage > 0 ? _previousPage : null,
              child: GlassmorphismContainer(
                level: GlassLevel.background,
                borderRadius: BorderRadius.circular(BorderRadiusTokens.xl),
                padding: EdgeInsets.symmetric(
                  horizontal: config.isMobile ? 20 : 24,
                  vertical: config.isMobile ? 12 : 16,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PhosphorIcons.arrowLeft(),
                      size: config.isMobile ? 18 : 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Back',
                      style: TextStyle(
                        fontSize: TypographyConstants.bodyMedium, // 14.0 - Fixed hardcoded font size
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Next/Finish button
          GestureDetector(
            onTap: _nextPage,
            child: GlassmorphismContainer(
              level: GlassLevel.floating,
              borderRadius: BorderRadius.circular(BorderRadiusTokens.xl),
              padding: EdgeInsets.symmetric(
                horizontal: config.isMobile ? 24 : 32,
                vertical: config.isMobile ? 12 : 16,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(BorderRadiusTokens.xl),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _currentPage == _steps.length - 1 ? l10n.onboardingFinish : l10n.onboardingNext,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary, // Fixed hardcoded color (was Colors.white)
                        fontSize: TypographyConstants.bodyMedium, // 14.0 - Fixed hardcoded font size
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _currentPage == _steps.length - 1 ? PhosphorIcons.check() : PhosphorIcons.arrowRight(),
                      color: Colors.white,
                      size: config.isMobile ? 18 : 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkipButton(
    BuildContext context,
    ResponsiveConfig config,
    AppLocalizations l10n,
  ) {
    return Positioned(
      top: config.isMobile ? 50 : 60,
      right: config.padding.right,
      child: GestureDetector(
        onTap: _skipOnboarding,
        child: GlassmorphismContainer(
          level: GlassLevel.background,
          borderRadius: BorderRadius.circular(BorderRadiusTokens.lg),
          padding: EdgeInsets.symmetric(
            horizontal: config.isMobile ? 16 : 20,
            vertical: config.isMobile ? 8 : 10,
          ),
          child: Text(
            l10n.onboardingSkip,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  // Removed hardcoded fontSize - using theme.textTheme.labelLarge default (14.0)
                ),
          ),
        ),
      ),
    );
  }

  String _getLocalizedString(AppLocalizations l10n, String key) {
    switch (key) {
      case 'onboarding_welcome':
        return l10n.onboardingWelcome;
      case 'onboarding_subtitle':
        return l10n.onboardingSubtitle;
      default:
        return key;
    }
  }
}

/// Onboarding step data model
class OnboardingStep {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final List<Color> gradient;
  final List<String> features;

  const OnboardingStep({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.gradient,
    this.features = const [],
  });
}
