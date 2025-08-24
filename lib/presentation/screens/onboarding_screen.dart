import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/typography_constants.dart';
import '../widgets/enhanced_ux_widgets.dart';

/// Onboarding screen with tutorial system
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _currentPage = 0;
  final int _totalPages = 5;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to Task Tracker',
      description: 'Your intelligent task management companion that helps you stay organized and productive.',
      icon: PhosphorIcons.checkSquare(),
      color: const Color(0xFF2196F3), // Material Blue - keeping original intent for onboarding theme
    ),
    OnboardingPage(
      title: 'Voice-Powered Tasks',
      description: 'Create tasks using your voice. Just speak naturally and let AI parse your intentions.',
      icon: PhosphorIcons.microphone(),
      color: const Color(0xFF4CAF50), // Material Green - keeping original intent for onboarding theme
    ),
    OnboardingPage(
      title: 'Smart Organization',
      description: 'Automatically categorize tasks, set priorities, and get intelligent suggestions.',
      icon: PhosphorIcons.sparkle(),
      color: const Color(0xFF9C27B0), // Material Purple - keeping original intent for onboarding theme
    ),
    OnboardingPage(
      title: 'Calendar Integration',
      description: 'Schedule tasks, view them in calendar format, and sync with your device calendar.',
      icon: PhosphorIcons.calendar(),
      color: const Color(0xFFFF9800), // Material Orange - keeping original intent for onboarding theme
    ),
    OnboardingPage(
      title: 'Offline & Sync',
      description: 'Work offline and sync across devices. Your data is always available when you need it.',
      icon: PhosphorIcons.cloudArrowUp(),
      color: const Color(0xFF009688), // Material Teal - keeping original intent for onboarding theme
    ),
  ];
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _completeOnboarding() {
    // Mark onboarding as completed and navigate to main app
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Progress indicator
                  Text(
                    '${_currentPage + 1} of $_totalPages',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  // Skip button
                  if (_currentPage < _totalPages - 1)
                    EnhancedButton(
                      onPressed: _skipOnboarding,
                      semanticLabel: 'Skip onboarding tutorial',
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        elevation: 0,
                      ),
                      child: const Text('Skip'),
                    ),
                ],
              ),
            ),

            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: LinearProgressIndicator(
                value: (_currentPage + 1) / _totalPages,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                  _animationController.reset();
                  _animationController.forward();

                  // Provide haptic feedback for page changes and accessibility
                  HapticFeedback.lightImpact();
                  // Announce page changes for screen readers
                  SemanticsService.announce(
                    'Page ${index + 1} of $_totalPages',
                    TextDirection.ltr,
                  );
                },
                itemCount: _totalPages,
                itemBuilder: (context, index) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildOnboardingPage(_pages[index]),
                    ),
                  );
                },
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous button
                  if (_currentPage > 0)
                    EnhancedButton(
                      onPressed: _previousPage,
                      semanticLabel: 'Go to previous page',
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(PhosphorIcons.arrowLeft(), size: 18),
                          const SizedBox(width: 8),
                          const Text('Previous'),
                        ],
                      ),
                    )
                  else
                    const SizedBox(width: 100), // Placeholder for alignment

                  // Page indicators
                  Row(
                    children: List.generate(_totalPages, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                          color: _currentPage == index
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                      );
                    }),
                  ),

                  // Next/Get Started button
                  EnhancedButton(
                    onPressed: _nextPage,
                    semanticLabel:
                        _currentPage == _totalPages - 1 ? 'Get started with Task Tracker' : 'Go to next page',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_currentPage == _totalPages - 1 ? 'Get Started' : 'Next'),
                        const SizedBox(width: 8),
                        Icon(
                          _currentPage == _totalPages - 1 ? PhosphorIcons.check() : PhosphorIcons.arrowRight(),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: page.color.withValues(alpha: 0.1),
            ),
            child: Icon(
              page.icon,
              size: 60,
              color: page.color,
            ),
          ),

          const SizedBox(height: 48),

          // Title
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Description
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 48),

          // Feature highlights for specific pages
          if (_currentPage == 1) _buildVoiceFeatureDemo(),
          if (_currentPage == 2) _buildSmartFeatureDemo(),
          if (_currentPage == 3) _buildCalendarFeatureDemo(),
        ],
      ),
    );
  }

  Widget _buildVoiceFeatureDemo() {
    return EnhancedCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              PhosphorIcons.microphone(),
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Try saying:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '"Remind me to call mom tomorrow at 3 PM"',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartFeatureDemo() {
    return Column(
      children: [
        _buildFeatureItem(
          icon: PhosphorIcons.tag(),
          title: 'Auto-tagging',
          description: 'Automatically categorizes your tasks',
        ),
        const SizedBox(height: 12),
        _buildFeatureItem(
          icon: PhosphorIcons.arrowUp(),
          title: 'Smart priorities',
          description: 'Detects urgency from your language',
        ),
        const SizedBox(height: 12),
        _buildFeatureItem(
          icon: PhosphorIcons.clock(),
          title: 'Date parsing',
          description: 'Understands "next Friday" or "in 2 hours"',
        ),
      ],
    );
  }

  Widget _buildCalendarFeatureDemo() {
    return EnhancedCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  PhosphorIcons.calendar(),
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'This Week',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF2196F3), // Material Blue - keeping original intent for calendar demo
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Team meeting - Today 2:00 PM'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF4CAF50), // Material Green - keeping original intent for calendar demo
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Grocery shopping - Tomorrow'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Onboarding page data model
class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
