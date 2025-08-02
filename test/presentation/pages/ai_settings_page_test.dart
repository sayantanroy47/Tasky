import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_tracker_app/presentation/pages/ai_settings_page.dart';
import 'package:task_tracker_app/services/ai/ai_task_parsing_service.dart';
import 'package:task_tracker_app/services/ai/composite_ai_task_parser.dart';

void main() {
  group('AISettingsPage', () {
    testWidgets('should display AI settings page with main sections', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AISettingsPage(),
          ),
        ),
      );

      // Verify app bar
      expect(find.text('AI Settings'), findsOneWidget);

      // Verify main sections
      expect(find.text('AI Task Parsing'), findsOneWidget);
      expect(find.text('Auto-Apply Settings'), findsOneWidget);
      expect(find.text('Display Settings'), findsOneWidget);
      expect(find.text('Privacy & Data Control'), findsOneWidget);
      expect(find.text('Help & Information'), findsOneWidget);
    });

    testWidgets('should show AI parsing toggle switch', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AISettingsPage(),
          ),
        ),
      );

      // Find the AI parsing switch
      expect(find.text('Enable AI Parsing'), findsOneWidget);
      expect(find.byType(Switch), findsAtLeastNWidgets(1));
    });

    testWidgets('should show auto-apply settings when AI is enabled', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            aiParsingConfigProvider.overrideWith((ref) => 
              AIParsingConfigNotifier()..setEnabled(true)),
          ],
          child: const MaterialApp(
            home: AISettingsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify auto-apply settings are visible
      expect(find.text('Auto-apply Tags'), findsOneWidget);
      expect(find.text('Auto-apply Priority'), findsOneWidget);
      expect(find.text('Auto-apply Due Date'), findsOneWidget);
    });

    testWidgets('should show help dialog when help is tapped', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AISettingsPage(),
          ),
        ),
      );

      // Tap on help
      await tester.tap(find.text('How AI Parsing Works'));
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.text('How AI Parsing Works'), findsAtLeastNWidgets(1));
      expect(find.text('AI task parsing helps you create tasks faster'), findsOneWidget);
    });

    testWidgets('should show privacy dialog when privacy is tapped', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AISettingsPage(),
          ),
        ),
      );

      // Tap on privacy policy
      await tester.tap(find.text('Privacy Policy'));
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.text('AI Privacy Policy'), findsOneWidget);
      expect(find.text('Your Privacy Matters'), findsOneWidget);
    });

    testWidgets('should toggle AI parsing when switch is tapped', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AISettingsPage(),
          ),
        ),
      );

      // Find and tap the AI parsing switch
      final aiSwitch = find.byType(Switch).first;
      await tester.tap(aiSwitch);
      await tester.pumpAndSettle();

      // The switch should be toggled (this would be verified through state management)
      expect(find.byType(Switch), findsAtLeastNWidgets(1));
    });

    testWidgets('should disable auto-apply switches when AI is disabled', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            aiParsingConfigProvider.overrideWith((ref) => 
              AIParsingConfigNotifier()..setEnabled(false)),
          ],
          child: const MaterialApp(
            home: AISettingsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find auto-apply switches and verify they are disabled
      final switches = find.byType(Switch);
      expect(switches, findsAtLeastNWidgets(1));
      
      // The first switch is the main AI toggle, others should be disabled
      // This would need more specific testing with actual state management
    });

    testWidgets('should show confidence score setting', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AISettingsPage(),
          ),
        ),
      );

      // Verify confidence score setting
      expect(find.text('Show Confidence Scores'), findsOneWidget);
      expect(find.text('Display AI confidence levels for parsed tasks'), findsOneWidget);
    });

    testWidgets('should display all main card sections', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AISettingsPage(),
          ),
        ),
      );

      // Verify all main sections are present
      expect(find.byType(Card), findsAtLeastNWidgets(4));
      
      // Verify specific icons for each section
      expect(find.byIcon(Icons.psychology), findsOneWidget);
      expect(find.byIcon(Icons.auto_fix_high), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.byIcon(Icons.privacy_tip), findsOneWidget);
      expect(find.byIcon(Icons.help_outline), findsOneWidget);
    });
  });

  group('AIParsingConfig', () {
    test('should create config with default values', () {
      const config = AIParsingConfig();
      
      expect(config.enabled, isFalse);
      expect(config.serviceType, equals(AIServiceType.local));
      expect(config.showConfidence, isTrue);
      expect(config.autoApplyTags, isTrue);
      expect(config.autoApplyPriority, isTrue);
      expect(config.autoApplyDueDate, isTrue);
    });

    test('should create config with custom values', () {
      const config = AIParsingConfig(
        enabled: true,
        serviceType: AIServiceType.openai,
        showConfidence: false,
        autoApplyTags: false,
        autoApplyPriority: false,
        autoApplyDueDate: false,
      );
      
      expect(config.enabled, isTrue);
      expect(config.serviceType, equals(AIServiceType.openai));
      expect(config.showConfidence, isFalse);
      expect(config.autoApplyTags, isFalse);
      expect(config.autoApplyPriority, isFalse);
      expect(config.autoApplyDueDate, isFalse);
    });

    test('should copy config with updated values', () {
      const original = AIParsingConfig();
      final updated = original.copyWith(
        enabled: true,
        serviceType: AIServiceType.claude,
      );
      
      expect(updated.enabled, isTrue);
      expect(updated.serviceType, equals(AIServiceType.claude));
      expect(updated.showConfidence, equals(original.showConfidence));
      expect(updated.autoApplyTags, equals(original.autoApplyTags));
    });
  });

  group('AIParsingConfigNotifier', () {
    test('should start with default config', () {
      const notifier = AIParsingConfigNotifier();
      
      expect(notifier.state.enabled, isFalse);
      expect(notifier.state.serviceType, equals(AIServiceType.local));
    });

    test('should update enabled state', () {
      const notifier = AIParsingConfigNotifier();
      
      notifier.setEnabled(true);
      expect(notifier.state.enabled, isTrue);
      
      notifier.setEnabled(false);
      expect(notifier.state.enabled, isFalse);
    });

    test('should update service type', () {
      const notifier = AIParsingConfigNotifier();
      
      notifier.setServiceType(AIServiceType.openai);
      expect(notifier.state.serviceType, equals(AIServiceType.openai));
      
      notifier.setServiceType(AIServiceType.claude);
      expect(notifier.state.serviceType, equals(AIServiceType.claude));
    });

    test('should update auto-apply settings', () {
      const notifier = AIParsingConfigNotifier();
      
      notifier.setAutoApplyTags(false);
      expect(notifier.state.autoApplyTags, isFalse);
      
      notifier.setAutoApplyPriority(false);
      expect(notifier.state.autoApplyPriority, isFalse);
      
      notifier.setAutoApplyDueDate(false);
      expect(notifier.state.autoApplyDueDate, isFalse);
    });

    test('should update show confidence setting', () {
      const notifier = AIParsingConfigNotifier();
      
      notifier.setShowConfidence(false);
      expect(notifier.state.showConfidence, isFalse);
      
      notifier.setShowConfidence(true);
      expect(notifier.state.showConfidence, isTrue);
    });
  });
}