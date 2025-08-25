import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../services/share_intent_service.dart';
import 'standardized_spacing.dart';
import 'standardized_text.dart';

/// Comprehensive settings widget for ShareIntent functionality
class ShareIntentSettingsWidget extends ConsumerStatefulWidget {
  const ShareIntentSettingsWidget({super.key});

  @override
  ConsumerState<ShareIntentSettingsWidget> createState() => _ShareIntentSettingsWidgetState();
}

class _ShareIntentSettingsWidgetState extends ConsumerState<ShareIntentSettingsWidget> {
  final ShareIntentService _shareIntentService = ShareIntentService();
  final TextEditingController _trustedContactController = TextEditingController();
  final List<String> _trustedContacts = ['wife', 'Wife', 'WIFE'];
  bool _autoTaskCreation = true;
  bool _showConfirmationDialog = true;
  bool _enableMessageFiltering = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    // Load existing trusted contacts (in a real implementation, this would come from preferences)
    setState(() {
      // Default settings loaded
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: StandardizedSpacing.padding(SpacingSize.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(PhosphorIcons.share(), color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const StandardizedText(
                  'Share Intent Settings',
                  style: StandardizedTextStyle.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Auto Task Creation Toggle
            SwitchListTile(
              title: const StandardizedText('Auto Task Creation', style: StandardizedTextStyle.bodyMedium),
              subtitle: const StandardizedText('Automatically create tasks from shared content', style: StandardizedTextStyle.bodySmall),
              value: _autoTaskCreation,
              onChanged: (value) {
                setState(() {
                  _autoTaskCreation = value;
                });
                _saveSettings();
              },
            ),

            // Confirmation Dialog Toggle
            SwitchListTile(
              title: const StandardizedText('Show Confirmation Dialog', style: StandardizedTextStyle.bodyMedium),
              subtitle: const StandardizedText('Show dialog before creating tasks from shared content', style: StandardizedTextStyle.bodySmall),
              value: _showConfirmationDialog,
              onChanged: (value) {
                setState(() {
                  _showConfirmationDialog = value;
                });
                _saveSettings();
              },
            ),

            // Message Filtering Toggle
            SwitchListTile(
              title: const StandardizedText('Enable Message Filtering', style: StandardizedTextStyle.bodyMedium),
              subtitle: const StandardizedText('Only process messages from trusted contacts', style: StandardizedTextStyle.bodySmall),
              value: _enableMessageFiltering,
              onChanged: (value) {
                setState(() {
                  _enableMessageFiltering = value;
                });
                _saveSettings();
              },
            ),

            const Divider(),

            // Trusted Contacts Section
            const StandardizedText(
              'Trusted Contacts',
              style: StandardizedTextStyle.titleSmall,
            ),
            const SizedBox(height: 8),
            const StandardizedText(
              'Messages from these contacts will be processed for task creation:',
              style: StandardizedTextStyle.bodySmall,
              color: Colors.grey,
            ),
            const SizedBox(height: 12),

            // Add Trusted Contact
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _trustedContactController,
                    decoration: const InputDecoration(
                      labelText: 'Contact name',
                      hintText: 'Enter contact name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTrustedContact,
                  child: const StandardizedText('Add', style: StandardizedTextStyle.buttonText),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Trusted Contacts List
            if (_trustedContacts.isNotEmpty) ...[
              const StandardizedText(
                'Current trusted contacts:',
                style: StandardizedTextStyle.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _trustedContacts
                    .map((contact) => Chip(
                          label: StandardizedText(contact, style: StandardizedTextStyle.bodyMedium),
                          deleteIcon: Icon(PhosphorIcons.x(), size: 18),
                          onDeleted: () => _removeTrustedContact(contact),
                        ))
                    .toList(),
              ),
            ],

            const Divider(),

            // Test Section
            const StandardizedText(
              'Test Share Intent',
              style: StandardizedTextStyle.titleSmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _testShareIntent,
                  icon: Icon(PhosphorIcons.share()),
                  label: const StandardizedText('Test Share', style: StandardizedTextStyle.buttonText),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _runSampleMessages,
                  icon: Icon(PhosphorIcons.chatCircle()),
                  label: const StandardizedText('Test Messages', style: StandardizedTextStyle.buttonText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addTrustedContact() {
    final contact = _trustedContactController.text.trim();
    if (contact.isNotEmpty && !_trustedContacts.contains(contact)) {
      setState(() {
        _trustedContacts.add(contact);
      });
      _shareIntentService.addTrustedContact(contact);
      _trustedContactController.clear();
      _saveSettings();
      _showSnackBar('Contact "$contact" added to trusted list');
    }
  }

  void _removeTrustedContact(String contact) {
    setState(() {
      _trustedContacts.remove(contact);
    });
    _shareIntentService.removeTrustedContact(contact);
    _saveSettings();
    _showSnackBar('Contact "$contact" removed from trusted list');
  }

  Future<void> _testShareIntent() async {
    try {
      const testMessage = 'Can you pick up milk on your way home?';
      await _shareIntentService.testWifeMessage(testMessage);
      _showSnackBar('Test share intent processed!');
    } catch (e) {
      _showSnackBar('Error testing share intent: $e', isError: true);
    }
  }

  Future<void> _runSampleMessages() async {
    try {
      await _shareIntentService.runTestMessages();
      _showSnackBar('Sample messages processed!');
    } catch (e) {
      _showSnackBar('Error running sample messages: $e', isError: true);
    }
  }

  void _saveSettings() {
    // In a real implementation, save settings to shared preferences or database
    // For now, we'll just update the service
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: StandardizedText(message, style: StandardizedTextStyle.bodyMedium),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _trustedContactController.dispose();
    super.dispose();
  }
}
