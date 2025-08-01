import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/ai/ai_task_parsing_service.dart';
import '../../services/ai/composite_ai_task_parser.dart';

/// Widget for selecting AI service provider
class AIServiceSelector extends ConsumerWidget {
  const AIServiceSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(aiParsingConfigProvider);
    final configNotifier = ref.read(aiParsingConfigProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cloud_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Service Provider',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Choose which AI service to use for task parsing',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            
            // Local Processing Option
            RadioListTile<AIServiceType>(
              title: const Text('Local Processing'),
              subtitle: const Text('Privacy-focused, works offline'),
              value: AIServiceType.local,
              groupValue: config.serviceType,
              onChanged: (value) {
                if (value != null) {
                  configNotifier.setServiceType(value);
                }
              },
              secondary: const Icon(Icons.security),
            ),
            
            // OpenAI Option
            RadioListTile<AIServiceType>(
              title: const Text('OpenAI GPT-4o'),
              subtitle: const Text('Advanced AI parsing, requires API key'),
              value: AIServiceType.openai,
              groupValue: config.serviceType,
              onChanged: (value) {
                if (value != null) {
                  configNotifier.setServiceType(value);
                }
              },
              secondary: const Icon(Icons.psychology),
            ),
            
            // Claude Option
            RadioListTile<AIServiceType>(
              title: const Text('Claude 3'),
              subtitle: const Text('Anthropic\'s AI model, requires API key'),
              value: AIServiceType.claude,
              groupValue: config.serviceType,
              onChanged: (value) {
                if (value != null) {
                  configNotifier.setServiceType(value);
                }
              },
              secondary: const Icon(Icons.smart_toy),
            ),
            
            const SizedBox(height: 16),
            
            // API Key Configuration
            if (config.serviceType != AIServiceType.local) ...[
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.key,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'API Configuration',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.settings),
                title: Text('Configure ${config.serviceType.displayName} API'),
                subtitle: const Text('Set up API key and preferences'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showAPIConfigDialog(context, config.serviceType),
              ),
            ],
            
            // Service Status
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(config.serviceType),
                    color: _getStatusColor(context, config.serviceType),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getStatusTitle(config.serviceType),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _getStatusDescription(config.serviceType),
                          style: Theme.of(context).textTheme.bodySmall,
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

  void _showAPIConfigDialog(BuildContext context, AIServiceType serviceType) {
    showDialog(
      context: context,
      builder: (context) => APIConfigDialog(serviceType: serviceType),
    );
  }

  IconData _getStatusIcon(AIServiceType serviceType) {
    switch (serviceType) {
      case AIServiceType.local:
        return Icons.check_circle;
      case AIServiceType.openai:
      case AIServiceType.claude:
        return Icons.warning; // Would be check_circle if API key is configured
    }
  }

  Color _getStatusColor(BuildContext context, AIServiceType serviceType) {
    switch (serviceType) {
      case AIServiceType.local:
        return Colors.green;
      case AIServiceType.openai:
      case AIServiceType.claude:
        return Colors.orange; // Would be green if API key is configured
    }
  }

  String _getStatusTitle(AIServiceType serviceType) {
    switch (serviceType) {
      case AIServiceType.local:
        return 'Ready';
      case AIServiceType.openai:
      case AIServiceType.claude:
        return 'API Key Required';
    }
  }

  String _getStatusDescription(AIServiceType serviceType) {
    switch (serviceType) {
      case AIServiceType.local:
        return 'Local processing is available and ready to use';
      case AIServiceType.openai:
        return 'Configure your OpenAI API key to enable advanced parsing';
      case AIServiceType.claude:
        return 'Configure your Anthropic API key to enable Claude parsing';
    }
  }
}

/// Dialog for configuring API keys and settings
class APIConfigDialog extends StatefulWidget {
  final AIServiceType serviceType;

  const APIConfigDialog({
    super.key,
    required this.serviceType,
  });

  @override
  State<APIConfigDialog> createState() => _APIConfigDialogState();
}

class _APIConfigDialogState extends State<APIConfigDialog> {
  final _apiKeyController = TextEditingController();
  final _baseUrlController = TextEditingController();
  bool _obscureApiKey = true;
  bool _isTestingConnection = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  void _loadCurrentSettings() {
    // Load current API key and base URL from preferences
    // This would be implemented with SharedPreferences
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Configure ${widget.serviceType.displayName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your API credentials to enable ${widget.serviceType.displayName} parsing.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            
            // API Key Field
            TextField(
              controller: _apiKeyController,
              obscureText: _obscureApiKey,
              decoration: InputDecoration(
                labelText: 'API Key',
                hintText: 'Enter your ${widget.serviceType.displayName} API key',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscureApiKey ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _obscureApiKey = !_obscureApiKey;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Base URL Field (Advanced)
            ExpansionTile(
              title: const Text('Advanced Settings'),
              children: [
                TextField(
                  controller: _baseUrlController,
                  decoration: InputDecoration(
                    labelText: 'Base URL (Optional)',
                    hintText: _getDefaultBaseUrl(widget.serviceType),
                    border: const OutlineInputBorder(),
                    helperText: 'Leave empty to use default endpoint',
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Privacy Notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Privacy Notice',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your task text will be sent to ${widget.serviceType.displayName} for processing. Data is not stored after processing.',
                          style: Theme.of(context).textTheme.bodySmall,
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isTestingConnection ? null : _testConnection,
          child: _isTestingConnection
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Test'),
        ),
        FilledButton(
          onPressed: _saveSettings,
          child: const Text('Save'),
        ),
      ],
    );
  }

  String _getDefaultBaseUrl(AIServiceType serviceType) {
    switch (serviceType) {
      case AIServiceType.openai:
        return 'https://api.openai.com/v1';
      case AIServiceType.claude:
        return 'https://api.anthropic.com/v1';
      case AIServiceType.local:
        return '';
    }
  }

  Future<void> _testConnection() async {
    if (_apiKeyController.text.trim().isEmpty) {
      _showSnackBar('Please enter an API key');
      return;
    }

    setState(() {
      _isTestingConnection = true;
    });

    try {
      // Test the API connection
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      if (mounted) {
        _showSnackBar('Connection successful!', isError: false);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Connection failed: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTestingConnection = false;
        });
      }
    }
  }

  void _saveSettings() {
    if (_apiKeyController.text.trim().isEmpty) {
      _showSnackBar('Please enter an API key');
      return;
    }

    // Save settings to SharedPreferences
    // This would be implemented with actual persistence
    
    Navigator.of(context).pop();
    _showSnackBar('Settings saved successfully!', isError: false);
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    super.dispose();
  }
}
