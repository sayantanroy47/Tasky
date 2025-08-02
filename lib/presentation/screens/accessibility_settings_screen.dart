import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/accessibility_service.dart';
import '../widgets/accessible_widgets.dart';

/// Screen for managing accessibility settings
class AccessibilitySettingsScreen extends ConsumerWidget {
  const AccessibilitySettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessibilityService = ref.read(accessibilityServiceProvider);
    final settings = ref.watch(accessibilitySettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accessibility Settings'),
        leading: AccessibleIconButton(
          icon: Icons.arrow_back,
          semanticLabel: 'Go back',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Visual accessibility section
          _buildSectionCard(
            context,
            'Visual Accessibility',
            Icons.visibility,
            [
              AccessibleListTile(
                leading: const Icon(Icons.contrast),
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
                leading: const Icon(Icons.text_fields),
                title: const Text('Large Text'),
                subtitle: const Text('Increase text size throughout the app'),
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
                leading: const Icon(Icons.motion_photos_off),
                title: const Text('Reduce Motion'),
                subtitle: const Text('Minimize animations and transitions'),
                trailing: AccessibleSwitch(
                  value: settings.reducedMotionMode,
                  onChanged: (value) => accessibilityService.setReducedMotionMode(value),
                  semanticLabel: 'Reduce motion mode',
                  activeLabel: 'Reduced motion enabled',
                  inactiveLabel: 'Reduced motion disabled',
                ),
                semanticLabel: 'Reduce motion setting',
              ),
              
              AccessibleListTile(
                leading: const Icon(Icons.palette),
                title: const Text('Color Blind Support'),
                subtitle: Text(_getColorBlindModeDescription(settings.colorBlindMode)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showColorBlindModeDialog(context, ref),
                semanticLabel: 'Color blind support settings',
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Audio and haptic section
          _buildSectionCard(
            context,
            'Audio & Haptic',
            Icons.volume_up,
            [
              AccessibleListTile(
                leading: const Icon(Icons.accessibility),
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
                leading: const Icon(Icons.record_voice_over),
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
                leading: const Icon(Icons.vibration),
                title: const Text('Haptic Feedback'),
                subtitle: const Text('Vibration feedback for interactions'),
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
          
          const SizedBox(height: 16),
          
          // Testing section
          _buildSectionCard(
            context,
            'Accessibility Testing',
            Icons.bug_report,
            [
              AccessibleListTile(
                leading: const Icon(Icons.science),
                title: const Text('Test Screen Reader'),
                subtitle: const Text('Test screen reader announcements'),
                onTap: () => _testScreenReader(context, accessibilityService),
                semanticLabel: 'Test screen reader functionality',
              ),
              
              AccessibleListTile(
                leading: const Icon(Icons.vibration),
                title: const Text('Test Haptic Feedback'),
                subtitle: const Text('Test different haptic patterns'),
                onTap: () => _testHapticFeedback(context, accessibilityService),
                semanticLabel: 'Test haptic feedback',
              ),
              
              AccessibleListTile(
                leading: const Icon(Icons.color_lens),
                title: const Text('Test Color Contrast'),
                subtitle: const Text('Check color contrast ratios'),
                onTap: () => _showColorContrastTest(context),
                semanticLabel: 'Test color contrast',
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Information section
          _buildSectionCard(
            context,
            'Information',
            Icons.info,
            [
              AccessibleListTile(
                leading: const Icon(Icons.help),
                title: const Text('Accessibility Guide'),
                subtitle: const Text('Learn about accessibility features'),
                onTap: () => _showAccessibilityGuide(context),
                semanticLabel: 'Accessibility guide',
              ),
              
              AccessibleListTile(
                leading: const Icon(Icons.feedback),
                title: const Text('Accessibility Feedback'),
                subtitle: const Text('Report accessibility issues'),
                onTap: () => _showFeedbackDialog(context),
                semanticLabel: 'Accessibility feedback',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return AccessibleCard(
      semanticLabel: '$title section',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
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

  void _showColorBlindModeDialog(BuildContext context, WidgetRef ref) {
    final accessibilityService = ref.read(accessibilityServiceProvider);
    final currentMode = ref.read(accessibilitySettingsProvider).colorBlindMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Color Blind Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ColorBlindMode.values.map((mode) {
            return AccessibleRadio<ColorBlindMode>(
              value: mode,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  accessibilityService.setColorBlindMode(value);
                  Navigator.of(context).pop();
                }
              },
              semanticLabel: _getColorBlindModeDescription(mode),
            );
          }).toList(),
        ),
        actions: [
          AccessibleButton(
            onPressed: () => Navigator.of(context).pop(),
            semanticLabel: 'Close dialog',
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _testScreenReader(BuildContext context, AccessibilityService service) {
    service.announceForScreenReader('This is a test announcement for screen readers');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Screen reader test announcement sent'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _testHapticFeedback(BuildContext context, AccessibilityService service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test Haptic Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AccessibleButton(
              onPressed: () => service.provideHapticFeedback(HapticFeedbackType.light),
              semanticLabel: 'Test light haptic feedback',
              child: const Text('Light'),
            ),
            const SizedBox(height: 8),
            AccessibleButton(
              onPressed: () => service.provideHapticFeedback(HapticFeedbackType.medium),
              semanticLabel: 'Test medium haptic feedback',
              child: const Text('Medium'),
            ),
            const SizedBox(height: 8),
            AccessibleButton(
              onPressed: () => service.provideHapticFeedback(HapticFeedbackType.heavy),
              semanticLabel: 'Test heavy haptic feedback',
              child: const Text('Heavy'),
            ),
            const SizedBox(height: 8),
            AccessibleButton(
              onPressed: () => service.provideHapticFeedback(HapticFeedbackType.selection),
              semanticLabel: 'Test selection haptic feedback',
              child: const Text('Selection'),
            ),
          ],
        ),
        actions: [
          AccessibleButton(
            onPressed: () => Navigator.of(context).pop(),
            semanticLabel: 'Close haptic test dialog',
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showColorContrastTest(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Color Contrast Test'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildContrastExample('Good Contrast', Colors.black, Colors.white),
            const SizedBox(height: 8),
            _buildContrastExample('Poor Contrast', Colors.grey[400]!, Colors.grey[300]!),
            const SizedBox(height: 8),
            _buildContrastExample('Medium Contrast', Colors.blue[800]!, Colors.blue[100]!),
          ],
        ),
        actions: [
          AccessibleButton(
            onPressed: () => Navigator.of(context).pop(),
            semanticLabel: 'Close contrast test dialog',
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildContrastExample(String label, Color foreground, Color background) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: foreground, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showAccessibilityGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accessibility Guide'),
        content: const SingleChildScrollView(
          child: Text(
            'Accessibility Features:\n\n'
            '• High Contrast Mode: Increases contrast between text and background for better visibility\n\n'
            '• Large Text: Makes all text larger throughout the app\n\n'
            '• Screen Reader Support: Enhanced labels and descriptions for screen readers\n\n'
            '• Haptic Feedback: Vibration feedback for button presses and interactions\n\n'
            '• Voice Over: Audio descriptions of interface elements\n\n'
            '• Reduce Motion: Minimizes animations that might cause discomfort\n\n'
            '• Color Blind Support: Adjusts colors for different types of color blindness\n\n'
            'Keyboard Navigation:\n'
            '• Use Tab to move between elements\n'
            '• Use Enter or Space to activate buttons\n'
            '• Use arrow keys in lists and menus',
          ),
        ),
        actions: [
          AccessibleButton(
            onPressed: () => Navigator.of(context).pop(),
            semanticLabel: 'Close accessibility guide',
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accessibility Feedback'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Help us improve accessibility by sharing your feedback:',
            ),
            SizedBox(height: 16),
            AccessibleTextField(
              controller: feedbackController,
              labelText: 'Your feedback',
              hintText: 'Describe any accessibility issues or suggestions...',
              maxLines: 4,
              semanticLabel: 'Accessibility feedback text field',
            ),
          ],
        ),
        actions: [
          AccessibleButton(
            onPressed: () => Navigator.of(context).pop(),
            semanticLabel: 'Cancel feedback',
            child: const Text('Cancel'),
          ),
          AccessibleButton(
            onPressed: () {
              // Here you would send the feedback
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thank you for your feedback!'),
                ),
              );
            },
            semanticLabel: 'Send feedback',
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}