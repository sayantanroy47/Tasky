import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/typography_constants.dart';
import '../../core/accessibility/touch_target_validator.dart';

import '../../services/ai/ai_task_parsing_service.dart';
import '../../services/security/api_key_manager.dart';
import '../../domain/models/ai_service_type.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
                  PhosphorIcons.cloud(),
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
            ListTile(
              title: const Text('Local Processing'),
              subtitle: const Text('Privacy-focused, works offline'),
              leading: AccessibleRadio<AIServiceType>(
                value: AIServiceType.local,
                groupValue: config.serviceType,
                semanticLabel: 'Local Processing - Privacy-focused, works offline',
                onChanged: (value) {
                  if (value != null) {
                    configNotifier.setServiceType(value);
                  }
                },
              ),
              trailing: Icon(PhosphorIcons.shield()),
            ),
            
            // OpenAI Option
            ListTile(
              title: const Text('OpenAI GPT-4o'),
              subtitle: const Text('Advanced AI parsing, requires API key'),
              leading: AccessibleRadio<AIServiceType>(
                value: AIServiceType.openai,
                groupValue: config.serviceType,
                semanticLabel: 'OpenAI GPT-4o - Advanced AI parsing, requires API key',
                onChanged: (value) {
                  if (value != null) {
                    configNotifier.setServiceType(value);
                  }
                },
              ),
              trailing: Icon(PhosphorIcons.brain()),
            ),
            
            // Claude Option
            ListTile(
              title: const Text('Claude 3'),
              subtitle: const Text('Anthropic\'s AI model, requires API key'),
              leading: AccessibleRadio<AIServiceType>(
                value: AIServiceType.claude,
                groupValue: config.serviceType,
                semanticLabel: 'Claude 3 - Anthropic AI model, requires API key',
                onChanged: (value) {
                  if (value != null) {
                    configNotifier.setServiceType(value);
                  }
                },
              ),
              trailing: Icon(PhosphorIcons.robot()),
            ),
            
            const SizedBox(height: 16),
            
            // API Key Configuration
            if (config.serviceType != AIServiceType.local) ...[
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    PhosphorIcons.key(),
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
              FutureBuilder<bool>(
                future: _hasApiKey(config.serviceType),
                builder: (context, snapshot) {
                  final hasKey = snapshot.data ?? false;
                  return ListTile(
                    leading: Icon(
                      hasKey ? PhosphorIcons.checkCircle() : PhosphorIcons.gear(),
                      color: hasKey ? Colors.green : null,
                    ),
                    title: Text('Configure ${config.serviceType.displayName} API'),
                    subtitle: Text(hasKey ? 'API key configured' : 'Set up API key and preferences'),
                    trailing: Icon(PhosphorIcons.caretRight()),
                    onTap: () => _showAPIConfigDialog(context, config.serviceType),
                  );
                },
              ),
            ],
            
            // Service Status
            const SizedBox(height: 16),
            FutureBuilder<bool>(
              future: _hasApiKey(config.serviceType),
              builder: (context, snapshot) {
                final hasKey = snapshot.data ?? false;
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getStatusIcon(config.serviceType, hasKey),
                        color: _getStatusColor(context, config.serviceType, hasKey),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getStatusTitle(config.serviceType, hasKey),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _getStatusDescription(config.serviceType, hasKey),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
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

  IconData _getStatusIcon(AIServiceType serviceType, [bool hasKey = false]) {
    switch (serviceType) {
      case AIServiceType.local:
        return PhosphorIcons.checkCircle();
      case AIServiceType.openai:
      case AIServiceType.claude:
        return hasKey ? PhosphorIcons.checkCircle() : PhosphorIcons.warning();
      case AIServiceType.composite:
        return PhosphorIcons.sparkle();
    }
  }

  Color _getStatusColor(BuildContext context, AIServiceType serviceType, [bool hasKey = false]) {
    switch (serviceType) {
      case AIServiceType.local:
        return Colors.green;
      case AIServiceType.openai:
      case AIServiceType.claude:
        return hasKey ? Colors.green : Colors.orange;
      case AIServiceType.composite:
        return Theme.of(context).colorScheme.primary;
    }
  }

  String _getStatusTitle(AIServiceType serviceType, [bool hasKey = false]) {
    switch (serviceType) {
      case AIServiceType.local:
        return 'Ready';
      case AIServiceType.openai:
      case AIServiceType.claude:
        return hasKey ? 'Ready' : 'API Key Required';
      case AIServiceType.composite:
        return 'Intelligent Selection';
    }
  }

  String _getStatusDescription(AIServiceType serviceType, [bool hasKey = false]) {
    switch (serviceType) {
      case AIServiceType.local:
        return 'Local processing is available and ready to use';
      case AIServiceType.openai:
        return hasKey 
          ? 'OpenAI API key is configured and ready to use'
          : 'Configure your OpenAI API key to enable advanced parsing';
      case AIServiceType.claude:
        return hasKey
          ? 'Claude API key is configured and ready to use' 
          : 'Configure your Anthropic API key to enable Claude parsing';
      case AIServiceType.composite:
        return 'Automatically selects the best available AI service with fallback to local processing';
    }
  }

  Future<bool> _hasApiKey(AIServiceType serviceType) async {
    switch (serviceType) {
      case AIServiceType.openai:
        return await APIKeyManager.hasOpenAIApiKey();
      case AIServiceType.claude:
        return await APIKeyManager.hasClaudeApiKey();
      case AIServiceType.local:
        return true;
      case AIServiceType.composite:
        return true; // Composite always works with fallback
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

  void _loadCurrentSettings() async {
    try {
      // Load current API key and base URL from secure storage
      String? apiKey;
      String? baseUrl;
      
      switch (widget.serviceType) {
        case AIServiceType.openai:
          apiKey = await APIKeyManager.getOpenAIApiKey();
          baseUrl = await APIKeyManager.getOpenAIBaseUrl();
          break;
        case AIServiceType.claude:
          apiKey = await APIKeyManager.getClaudeApiKey();
          baseUrl = await APIKeyManager.getClaudeBaseUrl();
          break;
        case AIServiceType.local:
          // No API key needed for local processing
          break;
        case AIServiceType.composite:
          // Composite service doesn't have its own API key settings
          break;
      }
      
      if (mounted) {
        setState(() {
          _apiKeyController.text = apiKey ?? '';
          _baseUrlController.text = baseUrl ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to load current settings: ${e.toString()}');
      }
    }
  }

  Future<String?> _getCurrentApiKey() async {
    switch (widget.serviceType) {
      case AIServiceType.openai:
        return await APIKeyManager.getOpenAIApiKey();
      case AIServiceType.claude:
        return await APIKeyManager.getClaudeApiKey();
      case AIServiceType.local:
        return null;
      case AIServiceType.composite:
        return null;
    }
  }

  Future<void> _clearApiKey() async {
    try {
      switch (widget.serviceType) {
        case AIServiceType.openai:
          await APIKeyManager.setOpenAIApiKey('');
          await APIKeyManager.setOpenAIBaseUrl(null);
          break;
        case AIServiceType.claude:
          await APIKeyManager.setClaudeApiKey('');
          await APIKeyManager.setClaudeBaseUrl(null);
          break;
        case AIServiceType.local:
          break;
        case AIServiceType.composite:
          break;
      }
      
      if (mounted) {
        setState(() {
          _apiKeyController.clear();
          _baseUrlController.clear();
        });
        _showSnackBar('API key cleared successfully!', isError: false);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to clear API key: ${e.toString()}');
      }
    }
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
            FutureBuilder<String?>(
              future: _getCurrentApiKey(),
              builder: (context, snapshot) {
                final currentApiKey = snapshot.data;
                final hasSavedKey = currentApiKey != null && currentApiKey.isNotEmpty;
                
                return TextField(
                  controller: _apiKeyController,
                  obscureText: _obscureApiKey,
                  decoration: InputDecoration(
                    labelText: 'API Key',
                    hintText: hasSavedKey 
                      ? 'Current: ${APIKeyManager.getMaskedApiKey(currentApiKey)}'
                      : 'Enter your ${widget.serviceType.displayName} API key',
                    border: const OutlineInputBorder(),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasSavedKey) 
                          IconButton(
                            icon: Icon(PhosphorIcons.x()),
                            onPressed: () => _clearApiKey(),
                            tooltip: 'Clear saved API key',
                          ),
                        IconButton(
                          icon: Icon(_obscureApiKey ? PhosphorIcons.eye() : PhosphorIcons.eyeSlash()),
                          onPressed: () {
                            setState(() {
                              _obscureApiKey = !_obscureApiKey;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
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
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    PhosphorIcons.info(),
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
      case AIServiceType.composite:
        return '';
    }
  }

  Future<void> _testConnection() async {
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isEmpty) {
      _showSnackBar('Please enter an API key');
      return;
    }
    
    // Validate API key format first
    if (!APIKeyManager.isValidApiKeyFormat(apiKey, widget.serviceType)) {
      _showSnackBar('Invalid API key format for ${widget.serviceType.displayName}');
      return;
    }

    setState(() {
      _isTestingConnection = true;
    });

    try {
      // Test the API connection with a simple validation request
      // For now, we'll validate the API key format and simulate a test
      bool isValidFormat = false;
      switch (widget.serviceType) {
        case AIServiceType.openai:
          isValidFormat = _apiKeyController.text.startsWith('sk-') && 
                         _apiKeyController.text.length > 20;
          break;
        case AIServiceType.claude:
          isValidFormat = _apiKeyController.text.startsWith('sk-ant-') && 
                         _apiKeyController.text.length > 30;
          break;
        case AIServiceType.local:
          isValidFormat = true; // Local service doesn't need API validation
          break;
        case AIServiceType.composite:
          isValidFormat = true; // Composite service doesn't need API validation
          break;
      }
      
      if (!isValidFormat) {
        throw Exception('Invalid API key format for ${widget.serviceType.name}');
      }
      
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      if (mounted) {
        _showSnackBar('Connection test completed! (Note: Actual API validation pending)', isError: false);
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

  void _saveSettings() async {
    final apiKey = _apiKeyController.text.trim();
    final baseUrl = _baseUrlController.text.trim();
    
    if (apiKey.isEmpty) {
      _showSnackBar('Please enter an API key');
      return;
    }
    
    // Validate API key format
    if (!APIKeyManager.isValidApiKeyFormat(apiKey, widget.serviceType)) {
      _showSnackBar('Invalid API key format for ${widget.serviceType.displayName}');
      return;
    }

    try {
      // Save settings to secure storage
      switch (widget.serviceType) {
        case AIServiceType.openai:
          await APIKeyManager.setOpenAIApiKey(apiKey);
          if (baseUrl.isNotEmpty) {
            await APIKeyManager.setOpenAIBaseUrl(baseUrl);
          }
          break;
        case AIServiceType.claude:
          await APIKeyManager.setClaudeApiKey(apiKey);
          if (baseUrl.isNotEmpty) {
            await APIKeyManager.setClaudeBaseUrl(baseUrl);
          }
          break;
        case AIServiceType.local:
          // No settings to save for local processing
          break;
        case AIServiceType.composite:
          // No settings to save for composite processing
          break;
      }
      
      if (mounted) {
        Navigator.of(context).pop();
        _showSnackBar('Settings saved securely!', isError: false);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to save settings: ${e.toString()}');
      }
    }
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


