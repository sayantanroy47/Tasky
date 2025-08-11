import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/enhanced_theme_provider.dart';
import '../widgets/glassmorphism_container.dart';
import '../widgets/standardized_app_bar.dart';
import '../../core/theme/app_theme_data.dart';
import '../../core/theme/typography_constants.dart';

/// Visual theme selection gallery with beautiful theme previews
class ThemesPage extends ConsumerWidget {
  const ThemesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(enhancedThemeProvider);
    final availableThemes = ref.watch(availableThemesProvider);

    return Scaffold(
      appBar: const StandardizedAppBar(
        title: 'Theme Gallery',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current theme info section
            GlassmorphismContainer(
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                        ),
                        child: Icon(
                          Icons.palette_outlined,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Theme',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              themeState.currentThemeName,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await ref.read(enhancedThemeProvider.notifier).applyRandomTheme();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Random theme applied!'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.shuffle),
                      label: const Text('Random Theme'),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Themes grid
            Text(
              'Available Themes',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            availableThemes.isEmpty
                ? GlassmorphismContainer(
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                    padding: const EdgeInsets.all(40),
                    child: const Center(
                      child: Column(
                        children: [
                          Icon(Icons.palette, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No themes available'),
                          Text('Themes are loading...'),
                        ],
                      ),
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: availableThemes.length,
                    itemBuilder: (context, index) {
                      final theme = availableThemes[index];
                      final isActive = theme.metadata.id == themeState.currentTheme?.metadata.id;
                      
                      return GlassmorphismContainer(
                        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                        padding: const EdgeInsets.all(16),
                        child: InkWell(
                          onTap: () {
                            // ACTUALLY SWITCH THE THEME
                            ref.read(enhancedThemeProvider.notifier).setTheme(theme.metadata.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${theme.metadata.name} theme applied!'),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // SHOW ACTUAL THEME COLORS - NOT CURRENT THEME
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Color(theme.colors.primary.value),
                                      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Color(theme.colors.secondary.value),
                                      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Color(theme.colors.tertiary.value),
                                      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                                    ),
                                  ),
                                  const Spacer(),
                                  if (isActive)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                theme.metadata.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (theme.metadata.description != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  theme.metadata.description!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}