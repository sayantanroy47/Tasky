import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/design_system/design_tokens.dart';
import '../pages/main_scaffold.dart';
import '../providers/profile_providers.dart';
import 'glassmorphism_container.dart';
import 'profile_setup_flow.dart';

/// Wrapper that shows profile setup flow for first-time users
class ProfileSetupWrapper extends ConsumerWidget {
  const ProfileSetupWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileSetupNeededAsync = ref.watch(profileSetupNeededProvider);
    
    return profileSetupNeededAsync.when(
      data: (needsSetup) {
        if (needsSetup) {
          // Show profile setup flow for first-time users
          return ProfileSetupFlow(
            onCompleted: () {
              // Invalidate providers to refresh the UI after setup
              ref.invalidate(profileSetupNeededProvider);
              ref.invalidate(currentProfileProvider);
            },
          );
        } else {
          // Show main app for existing users
          return const MainScaffold();
        }
      },
      loading: () => _buildLoadingScreen(context),
      error: (error, stackTrace) => _buildErrorScreen(context, error.toString()),
    );
  }

  Widget _buildLoadingScreen(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading your profile...',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Just a moment while we get things ready',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, String error) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIcons.warningCircle(),
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Profile Setup Error',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'We encountered an issue while checking your profile setup.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              GlassmorphismContainer(
                level: GlassLevel.content,
                padding: const EdgeInsets.all(16),
                borderRadius: BorderRadius.circular(12),
                glassTint: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                child: Column(
                  children: [
                    Icon(
                      PhosphorIcons.info(),
                      color: theme.colorScheme.onErrorContainer,
                      size: 20,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Error Details',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      error,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Force show main app as fallback
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const MainScaffold(),
                      ),
                    );
                  },
                  icon: Icon(PhosphorIcons.arrowRight()),
                  label: const Text('Continue to App'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}