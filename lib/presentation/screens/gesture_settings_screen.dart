import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/enhanced_ux_widgets.dart';
import '../../services/gesture_customization_service.dart';

/// Screen for customizing gestures and haptic feedback
class GestureSettingsScreen extends ConsumerWidget {
  const GestureSettingsScreen({super.key});  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gestureSettings = ref.watch(gestureSettingsProvider);
    final hapticSettings = ref.watch(hapticSettingsProvider);
    final gestureNotifier = ref.read(gestureSettingsProvider.notifier);
    final hapticNotifier = ref.read(hapticSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gesture & Haptic Settings'),
        actions: [
          IconButton(
            onPressed: () => _showResetDialog(context, gestureNotifier, hapticNotifier),
            icon: const Icon(Icons.restore),
            tooltip: 'Reset to defaults',
          ),
        ],
      ),
      body: ResponsiveWidget(
        builder: (context, config) {
          return ListView(
            padding: config.padding,
            children: [
              // Haptic Feedback Section
              _buildSectionHeader(context, 'Haptic Feedback'),
              EnhancedCard(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Enable Haptic Feedback'),
                      subtitle: const Text('Provide tactile feedback for interactions'),
                      value: hapticSettings.enabled,
                      onChanged: (value) => hapticNotifier.toggleHapticFeedback(value),
                    ),
                    if (hapticSettings.enabled) ...[
                      const Divider(),
                      _buildHapticIntensitySlider(context, hapticSettings, hapticNotifier),
                      const Divider(),
                      _buildHapticTypeToggles(context, hapticSettings, hapticNotifier),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Gesture Settings Section
              _buildSectionHeader(context, 'Gesture Settings'),
              EnhancedCard(
                child: Column(
                  children: [
                    _buildGestureToggle(
                      context,
                      'Swipe to Complete',
                      'Swipe right on tasks to mark them as complete',
                      Icons.swipe_right,
                      gestureSettings.swipeToComplete,
                      (value) => gestureNotifier.toggleGesture(GestureType.swipeToComplete, value),
                    ),
                    const Divider(),
                    _buildGestureToggle(
                      context,
                      'Swipe to Delete',
                      'Swipe left on tasks to delete them',
                      Icons.swipe_left,
                      gestureSettings.swipeToDelete,
                      (value) => gestureNotifier.toggleGesture(GestureType.swipeToDelete, value),
                    ),
                    const Divider(),
                    _buildGestureToggle(
                      context,
                      'Long Press Menu',
                      'Long press on tasks to show context menu',
                      Icons.touch_app,
                      gestureSettings.longPressMenu,
                      (value) => gestureNotifier.toggleGesture(GestureType.longPressMenu, value),
                    ),
                    const Divider(),
                    _buildGestureToggle(
                      context,
                      'Double Tap to Edit',
                      'Double tap on tasks to edit them',
                      Icons.touch_app,
                      gestureSettings.doubleTapEdit,
                      (value) => gestureNotifier.toggleGesture(GestureType.doubleTapEdit, value),
                    ),
                    const Divider(),
                    _buildGestureToggle(
                      context,
                      'Pull to Refresh',
                      'Pull down on lists to refresh content',
                      Icons.refresh,
                      gestureSettings.pullToRefresh,
                      (value) => gestureNotifier.toggleGesture(GestureType.pullToRefresh, value),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Sensitivity Settings Section
              _buildSectionHeader(context, 'Sensitivity Settings'),
              EnhancedCard(
                child: Column(
                  children: [
                    _buildSensitivitySlider(
                      context,
                      'Swipe Sensitivity',
                      'Adjust how sensitive swipe gestures are',
                      gestureSettings.swipeSensitivity,
                      (value) => gestureNotifier.updateSensitivity(GestureType.swipeToComplete, value),
                    ),
                    const Divider(),
                    _buildSensitivitySlider(
                      context,
                      'Long Press Duration',
                      'Adjust how long to hold for long press (ms)',
                      gestureSettings.longPressDuration / 1000,
                      (value) => gestureNotifier.updateSensitivity(GestureType.longPressMenu, value * 1000),
                      min: 0.2,
                      max: 2.0,
                      divisions: 18,
                      valueFormatter: (value) => '${(value * 1000).round()}ms',
                    ),
                    const Divider(),
                    _buildSensitivitySlider(
                      context,
                      'Double Tap Timeout',
                      'Maximum time between taps for double tap (ms)',
                      gestureSettings.doubleTapTimeout / 1000,
                      (value) => gestureNotifier.updateSensitivity(GestureType.doubleTapEdit, value * 1000),
                      min: 0.1,
                      max: 1.0,
                      divisions: 9,
                      valueFormatter: (value) => '${(value * 1000).round()}ms',
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Test Gestures Section
              _buildSectionHeader(context, 'Test Gestures'),
              EnhancedCard(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.touch_app),
                      title: const Text('Test Haptic Feedback'),
                      subtitle: const Text('Tap to test current haptic settings'),
                      onTap: () => _testHapticFeedback(ref),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.gesture),
                      title: const Text('Gesture Tutorial'),
                      subtitle: const Text('Learn how to use gestures effectively'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => _showGestureTutorial(context),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildGestureToggle(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildHapticIntensitySlider(
    BuildContext context,
    HapticSettings settings,
    HapticSettingsNotifier notifier,
  ) {
    return ListTile(
      leading: const Icon(Icons.vibration),
      title: const Text('Haptic Intensity'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Adjust the strength of haptic feedback'),
          const SizedBox(height: 8),
          Slider(
            value: settings.intensity,
            min: 0.1,
            max: 1.0,
            divisions: 9,
            label: '${(settings.intensity * 100).round()}%',
            onChanged: (value) => notifier.updateIntensity(value),
          ),
        ],
      ),
    );
  }

  Widget _buildHapticTypeToggles(
    BuildContext context,
    HapticSettings settings,
    HapticSettingsNotifier notifier,
  ) {
    return Column(
      children: [
        CheckboxListTile(
          title: const Text('Light Feedback'),
          subtitle: const Text('Subtle feedback for minor interactions'),
          value: settings.lightFeedback,
          onChanged: (value) => notifier.toggleFeedbackType(
            HapticFeedbackType.light,
            value ?? false,
          ),
        ),
        CheckboxListTile(
          title: const Text('Medium Feedback'),
          subtitle: const Text('Moderate feedback for standard interactions'),
          value: settings.mediumFeedback,
          onChanged: (value) => notifier.toggleFeedbackType(
            HapticFeedbackType.medium,
            value ?? false,
          ),
        ),
        CheckboxListTile(
          title: const Text('Heavy Feedback'),
          subtitle: const Text('Strong feedback for important actions'),
          value: settings.heavyFeedback,
          onChanged: (value) => notifier.toggleFeedbackType(
            HapticFeedbackType.heavy,
            value ?? false,
          ),
        ),
        CheckboxListTile(
          title: const Text('Selection Feedback'),
          subtitle: const Text('Feedback when selecting items'),
          value: settings.selectionFeedback,
          onChanged: (value) => notifier.toggleFeedbackType(
            HapticFeedbackType.selection,
            value ?? false,
          ),
        ),
      ],
    );
  }

  Widget _buildSensitivitySlider(
    BuildContext context,
    String title,
    String subtitle,
    double value,
    ValueChanged<double> onChanged, {
    double min = 0.1,
    double max = 1.0,
    int? divisions,
    String Function(double)? valueFormatter,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle),
          const SizedBox(height: 8),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            label: valueFormatter?.call(value) ?? '${(value * 100).round()}%',
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  void _testHapticFeedback(WidgetRef ref) async {
    final service = ref.read(gestureCustomizationServiceProvider);
    final settings = ref.read(hapticSettingsProvider);

    // Test different types of haptic feedback
    await service.provideHapticFeedback(HapticFeedbackType.light, settings);
    await Future.delayed(const Duration(milliseconds: 200));
    await service.provideHapticFeedback(HapticFeedbackType.medium, settings);
    await Future.delayed(const Duration(milliseconds: 200));
    await service.provideHapticFeedback(HapticFeedbackType.heavy, settings);
  }

  void _showGestureTutorial(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gesture Tutorial'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGestureTutorialItem(
                Icons.swipe_right,
                'Swipe Right',
                'Swipe right on a task to mark it as complete',
              ),
              const SizedBox(height: 16),
              _buildGestureTutorialItem(
                Icons.swipe_left,
                'Swipe Left',
                'Swipe left on a task to delete it',
              ),
              const SizedBox(height: 16),
              _buildGestureTutorialItem(
                Icons.touch_app,
                'Long Press',
                'Long press on a task to show the context menu',
              ),
              const SizedBox(height: 16),
              _buildGestureTutorialItem(
                Icons.touch_app,
                'Double Tap',
                'Double tap on a task to edit it quickly',
              ),
              const SizedBox(height: 16),
              _buildGestureTutorialItem(
                Icons.refresh,
                'Pull to Refresh',
                'Pull down on task lists to refresh content',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildGestureTutorialItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showResetDialog(
    BuildContext context,
    GestureSettingsNotifier gestureNotifier,
    HapticSettingsNotifier hapticNotifier,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Defaults'),
        content: const Text(
          'This will reset all gesture and haptic settings to their default values. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await gestureNotifier.resetToDefaults();
              await hapticNotifier.resetToDefaults();
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Settings reset to defaults'),
                  ),
                );
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}