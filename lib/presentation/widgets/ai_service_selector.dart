import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/typography_constants.dart';
import '../../core/accessibility/touch_target_validator.dart';

import '../../services/ai/ai_task_parsing_service.dart';
import '../../services/security/api_key_manager.dart';
import '../../domain/models/ai_service_type.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'standardized_text.dart';
import 'standardized_spacing.dart';

/// Widget for selecting AI service provider
class AIServiceSelector extends ConsumerWidget {
  const AIServiceSelector({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(aiParsingConfigProvider);
    final configNotifier = ref.read(aiParsingConfigProvider.notifier);

    return Card(
      child: Padding(
        padding: StandardizedSpacing.padding(SpacingSize.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  PhosphorIcons.cloud(),
                  color: Theme.of(context).colorScheme.primary,
                ),
                StandardizedGaps.horizontal(SpacingSize.xs),
                const StandardizedText(
                  'AI Service Provider',
                  style: StandardizedTextStyle.titleLarge,
                ),
              ],
            ),
            StandardizedGaps.vertical(SpacingSize.xs),
            const StandardizedText(
              'Choose which AI service to use for task parsing',
              style: StandardizedTextStyle.bodyMedium,
            ),
            StandardizedGaps.vertical(SpacingSize.md),
            
            // Local Processing Option
            ListTile(
              title: const StandardizedText('Local Processing', style: StandardizedTextStyle.titleMedium),
              subtitle: const StandardizedText('Privacy-focused, works offline', style: StandardizedTextStyle.bodyMedium),
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
              title: const StandardizedText('OpenAI GPT-4o', style: StandardizedTextStyle.titleMedium),
              subtitle: const StandardizedText('Advanced AI parsing, requires API key', style: StandardizedTextStyle.bodyMedium),
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
              title: const StandardizedText('Claude 3', style: StandardizedTextStyle.titleMedium),
              subtitle: const StandardizedText('Anthropic\'s AI model, requires API key', style: StandardizedTextStyle.bodyMedium),
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
            
            StandardizedGaps.vertical(SpacingSize.md),
            
            // API Key Configuration
            if (config.serviceType != AIServiceType.local) ...[
              const Divider(),
              StandardizedGaps.vertical(SpacingSize.md),
              Row(
                children: [
                  Icon(
                    PhosphorIcons.key(),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  StandardizedGaps.horizontal(SpacingSize.xs),
                  const StandardizedText(
                    'API Configuration',
                    style: StandardizedTextStyle.titleMedium,
                  ),
                ],
              ),
              StandardizedGaps.vertical(SpacingSize.md),
              FutureBuilder<bool>(
                future: _hasApiKey(config.serviceType),
                builder: (context, snapshot) {
                  final hasKey = snapshot.data ?? false;
                  return ListTile(
                    leading: Icon(
                      hasKey ? PhosphorIcons.checkCircle() : PhosphorIcons.gear(),
                      color: hasKey ? Colors.green : null,
                    ),
                    title: StandardizedText('Configure ${config.serviceType.displayName} API', style: StandardizedTextStyle.titleMedium),
                    subtitle: StandardizedText(hasKey ? 'API key configured' : 'Set up API key and preferences', style: StandardizedTextStyle.bodyMedium),
                    trailing: Icon(PhosphorIcons.caretRight()),
                    onTap: () => _showAPIConfigDialog(context, config.serviceType),
                  );
                },
              ),
            ],
            
            // Service Status
            StandardizedGaps.vertical(SpacingSize.md),
            FutureBuilder<bool>(
              future: _hasApiKey(config.serviceType),
              builder: (context, snapshot) {
                final hasKey = snapshot.data ?? false;
                return Container(
                  padding: StandardizedSpacing.padding(SpacingSize.sm),
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
                      StandardizedGaps.horizontal(SpacingSize.xs),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StandardizedText(
                              _getStatusTitle(config.serviceType, hasKey),
                              style: StandardizedTextStyle.bodyMedium,
                            ),
                            StandardizedText(
                              _getStatusDescription(config.serviceType, hasKey),
                              style: StandardizedTextStyle.bodySmall,
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
      title: StandardizedText('Configure ${widget.serviceType.displayName}', style: StandardizedTextStyle.headlineSmall),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StandardizedText(
              'Enter your API credentials to enable ${widget.serviceType.displayName} parsing.',
              style: StandardizedTextStyle.bodyMedium,
            ),
            StandardizedGaps.vertical(SpacingSize.md),
            
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
            StandardizedGaps.vertical(SpacingSize.md),
            
            // Base URL Field (Advanced)
            ExpansionTile(
              title: const StandardizedText('Advanced Settings', style: StandardizedTextStyle.titleMedium),
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
            
            StandardizedGaps.vertical(SpacingSize.md),
            
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
                  StandardizedGaps.horizontal(SpacingSize.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const StandardizedText(
                          'Privacy Notice',
                          style: StandardizedTextStyle.bodyMedium,
                        ),
                        StandardizedGaps.vertical(SpacingSize.xs),
                        StandardizedText(
                          'Your task text will be sent to ${widget.serviceType.displayName} for processing. Data is not stored after processing.',
                          style: StandardizedTextStyle.bodySmall,
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
          child: const StandardizedText('Cancel', style: StandardizedTextStyle.buttonText),
        ),
        TextButton(
          onPressed: _isTestingConnection ? null : _testConnection,
          child: _isTestingConnection
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const StandardizedText('Test', style: StandardizedTextStyle.buttonText),
        ),
        FilledButton(
          onPressed: _saveSettings,
          child: const StandardizedText('Save', style: StandardizedTextStyle.buttonText),
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
        content: StandardizedText(message, style: StandardizedTextStyle.bodyMedium),
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


