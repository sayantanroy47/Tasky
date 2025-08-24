import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/design_system/design_tokens.dart';
import '../../core/theme/typography_constants.dart';
import '../../services/accessibility_service.dart';
import '../widgets/accessible_widgets.dart';
import '../widgets/glassmorphism_container.dart';
import '../widgets/standardized_app_bar.dart';

/// Screen for managing accessibility settings
class AccessibilitySettingsScreen extends ConsumerWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessibilityService = ref.read(accessibilityServiceProvider);
    final settings = ref.watch(accessibilitySettingsProvider);

    return Scaffold(
      appBar: StandardizedAppBar(
        title: 'Accessibility Settings',
        leading: AccessibleIconButton(
          icon: PhosphorIcons.arrowLeft(),
          semanticLabel: 'Go back',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Visual accessibility section
          _buildSectionHeader(context, 'Visual Accessibility'),
          GlassmorphismContainer(
            level: GlassLevel.content,
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                AccessibleListTile(
                  leading: Icon(PhosphorIcons.circleHalf()),
                  title: const Text('High Contrast Mode'),
                  subtitle: const Text('Increase contrast for better visibility'),
                  trailing: AccessibleSwitch(
                    value: settings.highContrastMode,
                    onChanged: (value) => accessibilityService.setHighContrastMode(value),
                    semanticLabel: 'High contrast mode',
                    activeLabel: 'High contrast enabled',
                    inactiveLabel: 'High contrast disabled',
                  ),
                  semanticLabel: 'High contrast mode setting',
                ),
                AccessibleListTile(
                  leading: Icon(PhosphorIcons.textAa()),
                  title: const Text('Large Text'),
                  subtitle: const Text('Enable larger text for better readability'),
                  trailing: AccessibleSwitch(
                    value: settings.largeTextMode,
                    onChanged: (value) => accessibilityService.setLargeTextMode(value),
                    semanticLabel: 'Large text mode',
                    activeLabel: 'Large text enabled',
                    inactiveLabel: 'Large text disabled',
                  ),
                  semanticLabel: 'Large text mode setting',
                ),
                AccessibleListTile(
                  leading: Icon(PhosphorIcons.clock()),
                  title: const Text('Reduce Motion'),
                  subtitle: const Text('Minimize animations and transitions'),
                  trailing: AccessibleSwitch(
                    value: settings.reducedMotionMode,
                    onChanged: (value) => accessibilityService.setReducedMotionMode(value),
                    semanticLabel: 'Reduce motion',
                    activeLabel: 'Motion reduction enabled',
                    inactiveLabel: 'Motion reduction disabled',
                  ),
                  semanticLabel: 'Reduce motion setting',
                ),
                AccessibleListTile(
                  leading: Icon(PhosphorIcons.palette()),
                  title: const Text('Color Blind Support'),
                  subtitle: Text(_getColorBlindModeDescription(settings.colorBlindMode)),
                  trailing: Icon(PhosphorIcons.caretRight()),
                  onTap: () => _showColorBlindModeDialog(context, ref),
                  semanticLabel: 'Color blind support settings',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Audio and haptic section
          _buildSectionHeader(context, 'Audio & Haptic'),
          GlassmorphismContainer(
            level: GlassLevel.content,
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                AccessibleListTile(
                  leading: Icon(PhosphorIcons.wheelchair()),
                  title: const Text('Screen Reader Support'),
                  subtitle: const Text('Enhanced support for screen readers'),
                  trailing: AccessibleSwitch(
                    value: settings.screenReaderEnabled,
                    onChanged: (value) => accessibilityService.setScreenReaderEnabled(value),
                    semanticLabel: 'Screen reader support',
                    activeLabel: 'Screen reader support enabled',
                    inactiveLabel: 'Screen reader support disabled',
                  ),
                  semanticLabel: 'Screen reader support setting',
                ),
                AccessibleListTile(
                  leading: Icon(PhosphorIcons.microphone()),
                  title: const Text('Voice Over'),
                  subtitle: const Text('Enable voice descriptions'),
                  trailing: AccessibleSwitch(
                    value: settings.voiceOverEnabled,
                    onChanged: (value) => accessibilityService.setVoiceOverEnabled(value),
                    semanticLabel: 'Voice over',
                    activeLabel: 'Voice over enabled',
                    inactiveLabel: 'Voice over disabled',
                  ),
                  semanticLabel: 'Voice over setting',
                ),
                AccessibleListTile(
                  leading: Icon(PhosphorIcons.vibrate()),
                  title: const Text('Haptic Feedback'),
                  subtitle: const Text('Enable vibration feedback'),
                  trailing: AccessibleSwitch(
                    value: settings.hapticFeedbackEnabled,
                    onChanged: (value) => accessibilityService.setHapticFeedbackEnabled(value),
                    semanticLabel: 'Haptic feedback',
                    activeLabel: 'Haptic feedback enabled',
                    inactiveLabel: 'Haptic feedback disabled',
                  ),
                  semanticLabel: 'Haptic feedback setting',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  String _getColorBlindModeDescription(ColorBlindMode mode) {
    switch (mode) {
      case ColorBlindMode.none:
        return 'No color blind support';
      case ColorBlindMode.protanopia:
        return 'Red-blind (Protanopia) support';
      case ColorBlindMode.deuteranopia:
        return 'Green-blind (Deuteranopia) support';
      case ColorBlindMode.tritanopia:
        return 'Blue-blind (Tritanopia) support';
    }
  }

  Future<void> _showColorBlindModeDialog(BuildContext context, WidgetRef ref) async {
    // Show color blind mode selection dialog
    // Implementation would go here
  }
}
