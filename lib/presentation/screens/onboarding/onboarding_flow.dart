import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/accessibility/accessibility_constants.dart';
import '../../../core/theme/typography_constants.dart';
import '../../../core/navigation/page_transitions.dart';
import '../../../core/design_system/design_tokens.dart';
import '../../widgets/glassmorphism_container.dart';
import '../../widgets/accessible_button.dart';
import '../../widgets/theme_background_widget.dart';
import 'onboarding_pages.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Comprehensive onboarding flow with glassmorphism design
class OnboardingFlow extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;

  const OnboardingFlow({
    super.key,
    this.onComplete,
  });

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  
  int _currentPage = 0;
  final int _totalPages = OnboardingPages.pages.length;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLargeText = AccessibilityUtils.isLargeTextEnabled(context);

    return ThemeBackgroundWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Skip button
              _buildSkipButton(theme),
              
              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _totalPages,
                  itemBuilder: (context, index) {
                    return _buildPage(context, OnboardingPages.pages[index]);
                  },
                ),
              ),
              
              // Bottom navigation
              _buildBottomNavigation(theme, isLargeText),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, right: 16),
      child: Align(
        alignment: Alignment.centerRight,
        child: Semantics(
          button: true,
          label: 'Skip onboarding tutorial',
          child: TextButton(
            onPressed: _skipOnboarding,
            child: Text(
              'Skip',
              style: TextStyle(
                fontSize: TypographyConstants.textSM,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context, OnboardingPageData pageData) {
    final theme = Theme.of(context);
    final isLargeText = AccessibilityUtils.isLargeTextEnabled(context);
    final shouldReduceMotion = AccessibilityUtils.shouldReduceMotion(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          
          // Illustration
          Expanded(
            flex: 3,
            child: Center(
              child: AnimatedBuilder(
                animation: _fadeController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeController.value,
                    child: Transform.scale(
                      scale: shouldReduceMotion ? 1.0 : 0.8 + (0.2 * _fadeController.value),
                      child: GlassmorphismContainer(
                        level: GlassLevel.content,
                        width: 280,
                        height: 280,
                        borderRadius: BorderRadius.circular(BorderRadiusTokens.xl),
                        child: Center(
                          child: Icon(
                            pageData.icon,
                            size: 120,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Content
          Expanded(
            flex: 2,
            child: AnimatedBuilder(
              animation: _slideController,
              builder: (context, child) {
                return Transform.translate(
                  offset: shouldReduceMotion 
                      ? Offset.zero 
                      : Offset(0, 50 * (1 - _slideController.value)),
                  child: Opacity(
                    opacity: _slideController.value,
                    child: GlassmorphismContainer(
                      level: GlassLevel.content,
                      borderRadius: BorderRadius.circular(BorderRadiusTokens.lg),
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          // Title
                          Semantics(
                            header: true,
                            child: Text(
                              pageData.title,
                              style: TextStyle(
                                fontSize: isLargeText 
                                    ? TypographyConstants.text2XL 
                                    : TypographyConstants.textXL,
                                fontWeight: TypographyConstants.medium,
                                color: theme.colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Description
                          Text(
                            pageData.description,
                            style: TextStyle(
                              fontSize: isLargeText 
                                  ? TypographyConstants.textLG 
                                  : TypographyConstants.textBase,
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          // Feature highlights
                          if (pageData.highlights.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            ...pageData.highlights.map((highlight) => 
                              _buildFeatureHighlight(theme, highlight, isLargeText)
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureHighlight(ThemeData theme, String highlight, bool isLargeText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.7),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              PhosphorIcons.check(),
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              highlight,
              style: TextStyle(
                fontSize: isLargeText 
                    ? TypographyConstants.textBase 
                    : TypographyConstants.textSM,
                color: theme.colorScheme.onSurface,
                fontWeight: TypographyConstants.medium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(ThemeData theme, bool isLargeText) {
    final isLastPage = _currentPage == _totalPages - 1;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: GlassmorphismContainer(
        level: GlassLevel.interactive,
        borderRadius: BorderRadius.circular(BorderRadiusTokens.xl),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Page indicators
            _buildPageIndicators(theme),
            
            const SizedBox(height: 20),
            
            // Navigation buttons
            Row(
              children: [
                // Previous button
                if (_currentPage > 0)
                  Expanded(
                    child: AccessibleButton.secondary(
                      label: 'Previous',
                      icon: PhosphorIcons.arrowLeft(),
                      onPressed: _previousPage,
                      semanticHint: 'Go to previous onboarding step',
                    ),
                  )
                else
                  const Spacer(),
                
                const SizedBox(width: 16),
                
                // Next/Get Started button
                Expanded(
                  flex: isLastPage ? 2 : 1,
                  child: AccessibleButton.primary(
                    label: isLastPage ? 'Get Started' : 'Next',
                    icon: isLastPage ? PhosphorIcons.rocket() : PhosphorIcons.arrowRight(),
                    onPressed: isLastPage ? _completeOnboarding : _nextPage,
                    semanticHint: isLastPage 
                        ? 'Complete onboarding and start using the app'
                        : 'Go to next onboarding step',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicators(ThemeData theme) {
    return Semantics(
      label: 'Onboarding progress: page ${_currentPage + 1} of $_totalPages',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_totalPages, (index) {
          final isActive = index == _currentPage;
          final isPassed = index < _currentPage;
          
          return GestureDetector(
            onTap: () => _goToPage(index),
            child: Semantics(
              button: true,
              label: 'Go to page ${index + 1}',
              selected: isActive,
              child: Container(
                width: isActive ? 32 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isActive || isPassed
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(BorderRadiusTokens.xs),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    
    // Restart animations for new page
    _fadeController.reset();
    _slideController.reset();
    _fadeController.forward();
    _slideController.forward();
    
    // Announce page change for accessibility
    final pageData = OnboardingPages.pages[page];
    AccessibilityUtils.announceToScreenReader(
      context,
      'Page ${page + 1} of $_totalPages: ${pageData.title}',
    );
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: AccessibilityUtils.getAnimationDuration(
          context, 
          const Duration(milliseconds: 300),
        ),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: AccessibilityUtils.getAnimationDuration(
          context, 
          const Duration(milliseconds: 300),
        ),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: AccessibilityUtils.getAnimationDuration(
        context, 
        const Duration(milliseconds: 300),
      ),
      curve: Curves.easeInOut,
    );
  }

  void _skipOnboarding() {
    _showSkipConfirmation();
  }

  void _showSkipConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: GlassmorphismContainer(
          level: GlassLevel.floating,
          borderRadius: BorderRadius.circular(BorderRadiusTokens.lg),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                PhosphorIcons.skipForward(),
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Skip Tutorial?',
                style: TextStyle(
                  fontSize: TypographyConstants.textLG,
                  fontWeight: TypographyConstants.medium,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'You can always access the tutorial later from the settings menu.',
                style: TextStyle(
                  fontSize: TypographyConstants.textSM,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: AccessibleButton.secondary(
                      label: 'Continue Tutorial',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AccessibleButton.primary(
                      label: 'Skip',
                      onPressed: () {
                        Navigator.of(context).pop();
                        _completeOnboarding();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _completeOnboarding() {
    AccessibilityUtils.announceToScreenReader(
      context,
      'Onboarding completed. Welcome to Tasky!',
    );
    
    widget.onComplete?.call();
    
    // Navigate to main app
    NavigationUtils.navigateTo(
      context,
      const MainAppScreen(), // This would be your main app screen
      replacement: true,
      clearStack: true,
      accessibilityLabel: 'Main application',
      transitionType: TransitionType.fade,
    );
  }
}

// Placeholder for main app screen
class MainAppScreen extends StatelessWidget {
  const MainAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Main App Screen'),
      ),
    );
  }
}


