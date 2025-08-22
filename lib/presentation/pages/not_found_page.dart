import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/standardized_app_bar.dart';
import '../widgets/theme_background_widget.dart';
import '../../core/routing/app_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// 404 Not Found page for invalid routes
class NotFoundPage extends ConsumerWidget {
  const NotFoundPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ThemeBackgroundWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: const StandardizedAppBar(title: 'Page Not Found'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.only(
              top: kToolbarHeight + 32,
              left: 24.0,
              right: 24.0,
              bottom: 24.0,
            ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIcons.warningCircle(),
                size: 120,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                '404',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Page Not Found',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'The page you\'re looking for doesn\'t exist or has been moved.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () {
                  AppRouter.navigateToRoute(
                    context,
                    AppRouter.home,
                  );
                },
                icon: Icon(PhosphorIcons.house()),
                label: const Text('Go to Home'),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    AppRouter.navigateToRoute(
                      context,
                      AppRouter.home,
                    );
                  }
                },
                icon: Icon(PhosphorIcons.arrowLeft()),
                label: const Text('Go Back'),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}


