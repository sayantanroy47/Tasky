import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'voice_command_models.dart';

/// Service for managing custom voice commands and user preferences
class VoiceCommandCustomization {
  static const String _customCommandsFileName = 'custom_voice_commands.json';
  static const String _commandAliasesFileName = 'voice_command_aliases.json';
  static const String _voiceSettingsFileName = 'voice_command_settings.json';

  File? _customCommandsFile;
  File? _aliasesFile;
  File? _settingsFile;

  Map<String, CustomVoiceCommand> _customCommands = {};
  Map<String, String> _commandAliases = {};
  VoiceCommandConfig _config = const VoiceCommandConfig();

  /// Gets the current voice command configuration
  VoiceCommandConfig get config => _config;

  /// Gets all custom commands
  Map<String, CustomVoiceCommand> get customCommands => Map.unmodifiable(_customCommands);

  /// Gets all command aliases
  Map<String, String> get commandAliases => Map.unmodifiable(_commandAliases);

  /// Initializes the customization service
  Future<void> initialize() async {
    await _initializeFiles();
    await _loadCustomCommands();
    await _loadCommandAliases();
    await _loadSettings();
  }

  /// Adds a new custom voice command
  Future<void> addCustomCommand(CustomVoiceCommand command) async {
    _customCommands[command.id] = command;
    await _saveCustomCommands();
  }

  /// Removes a custom voice command
  Future<void> removeCustomCommand(String commandId) async {
    _customCommands.remove(commandId);
    await _saveCustomCommands();
  }

  /// Updates an existing custom voice command
  Future<void> updateCustomCommand(CustomVoiceCommand command) async {
    if (_customCommands.containsKey(command.id)) {
      _customCommands[command.id] = command;
      await _saveCustomCommands();
    }
  }

  /// Adds a command alias (alternative phrase for existing commands)
  Future<void> addCommandAlias(String alias, String originalCommand) async {
    _commandAliases[alias.toLowerCase()] = originalCommand.toLowerCase();
    await _saveCommandAliases();
  }

  /// Removes a command alias
  Future<void> removeCommandAlias(String alias) async {
    _commandAliases.remove(alias.toLowerCase());
    await _saveCommandAliases();
  }

  /// Updates the voice command configuration
  Future<void> updateConfig(VoiceCommandConfig newConfig) async {
    _config = newConfig;
    await _saveSettings();
  }

  /// Gets suggestions for improving command recognition
  List<String> getCommandSuggestions(String transcription) {
    final suggestions = <String>[];
    final lowerTranscription = transcription.toLowerCase();

    // Check for similar custom commands
    for (final command in _customCommands.values) {
      for (final pattern in command.patterns) {
        if (_calculateSimilarity(lowerTranscription, pattern.toLowerCase()) > 0.7) {
          suggestions.add('Did you mean: "$pattern"?');
        }
      }
    }

    // Check for similar aliases
    for (final alias in _commandAliases.keys) {
      if (_calculateSimilarity(lowerTranscription, alias) > 0.7) {
        suggestions.add('Did you mean: "$alias"?');
      }
    }

    // Add common command suggestions based on keywords
    if (lowerTranscription.contains('create') || lowerTranscription.contains('add')) {
      suggestions.add('Try: "Create task [task name]"');
    }
    if (lowerTranscription.contains('complete') || lowerTranscription.contains('done')) {
      suggestions.add('Try: "Complete task [task name]"');
    }
    if (lowerTranscription.contains('delete') || lowerTranscription.contains('remove')) {
      suggestions.add('Try: "Delete task [task name]"');
    }

    return suggestions.take(3).toList(); // Limit to 3 suggestions
  }

  /// Exports custom commands and settings to a JSON string
  String exportCustomizations() {
    final data = {
      'customCommands': _customCommands.map((key, value) => MapEntry(key, value.toJson())),
      'commandAliases': _commandAliases,
      'config': _configToJson(_config),
      'exportedAt': DateTime.now().toIso8601String(),
      'version': '1.0',
    };

    return jsonEncode(data);
  }

  /// Imports custom commands and settings from a JSON string
  Future<void> importCustomizations(String jsonData) async {
    try {
      final data = jsonDecode(jsonData) as Map<String, dynamic>;

      // Import custom commands
      if (data.containsKey('customCommands')) {
        final commandsData = data['customCommands'] as Map<String, dynamic>;
        _customCommands = commandsData.map(
          (key, value) => MapEntry(key, CustomVoiceCommand.fromJson(value)),
        );
      }

      // Import command aliases
      if (data.containsKey('commandAliases')) {
        _commandAliases = Map<String, String>.from(data['commandAliases']);
      }

      // Import configuration
      if (data.containsKey('config')) {
        _config = _configFromJson(data['config']);
      }

      // Save imported data
      await _saveCustomCommands();
      await _saveCommandAliases();
      await _saveSettings();
    } catch (e) {
      throw Exception('Failed to import customizations: $e');
    }
  }

  /// Resets all customizations to defaults
  Future<void> resetToDefaults() async {
    _customCommands.clear();
    _commandAliases.clear();
    _config = const VoiceCommandConfig();

    await _saveCustomCommands();
    await _saveCommandAliases();
    await _saveSettings();
  }

  /// Gets usage statistics for voice commands
  Map<String, int> getCommandUsageStats() {
    // In a real implementation, this would track command usage
    // For now, return empty stats
    return {};
  }

  /// Validates a custom command pattern
  bool validateCommandPattern(String pattern) {
    if (pattern.trim().isEmpty) return false;
    if (pattern.length < 3) return false;
    if (pattern.length > 100) return false;

    // Check for valid regex if it contains regex patterns
    if (pattern.contains('(') || pattern.contains('[')) {
      try {
        RegExp(pattern);
      } catch (e) {
        return false;
      }
    }

    return true;
  }

  // Private methods

  Future<void> _initializeFiles() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final voiceCommandsDir = Directory('${documentsDir.path}/voice_commands');
    
    if (!await voiceCommandsDir.exists()) {
      await voiceCommandsDir.create(recursive: true);
    }

    _customCommandsFile = File('${voiceCommandsDir.path}/$_customCommandsFileName');
    _aliasesFile = File('${voiceCommandsDir.path}/$_commandAliasesFileName');
    _settingsFile = File('${voiceCommandsDir.path}/$_voiceSettingsFileName');
  }

  Future<void> _loadCustomCommands() async {
    if (_customCommandsFile == null || !await _customCommandsFile!.exists()) {
      return;
    }

    try {
      final content = await _customCommandsFile!.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      
      _customCommands = data.map(
        (key, value) => MapEntry(key, CustomVoiceCommand.fromJson(value)),
      );
    } catch (e) {
      // If loading fails, start with empty commands
      _customCommands = {};
    }
  }

  Future<void> _saveCustomCommands() async {
    if (_customCommandsFile == null) return;

    final data = _customCommands.map((key, value) => MapEntry(key, value.toJson()));
    await _customCommandsFile!.writeAsString(jsonEncode(data));
  }

  Future<void> _loadCommandAliases() async {
    if (_aliasesFile == null || !await _aliasesFile!.exists()) {
      return;
    }

    try {
      final content = await _aliasesFile!.readAsString();
      _commandAliases = Map<String, String>.from(jsonDecode(content));
    } catch (e) {
      // If loading fails, start with empty aliases
      _commandAliases = {};
    }
  }

  Future<void> _saveCommandAliases() async {
    if (_aliasesFile == null) return;

    await _aliasesFile!.writeAsString(jsonEncode(_commandAliases));
  }

  Future<void> _loadSettings() async {
    if (_settingsFile == null || !await _settingsFile!.exists()) {
      return;
    }

    try {
      final content = await _settingsFile!.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      _config = _configFromJson(data);
    } catch (e) {
      // If loading fails, use default config
      _config = const VoiceCommandConfig();
    }
  }

  Future<void> _saveSettings() async {
    if (_settingsFile == null) return;

    final data = _configToJson(_config);
    await _settingsFile!.writeAsString(jsonEncode(data));
  }

  Map<String, dynamic> _configToJson(VoiceCommandConfig config) {
    return {
      'confidenceThreshold': config.confidenceThreshold,
      'enableFuzzyMatching': config.enableFuzzyMatching,
      'enableContextualParsing': config.enableContextualParsing,
      'customCommands': config.customCommands,
      'commandAliases': config.commandAliases,
      'enableMultiLanguage': config.enableMultiLanguage,
      'primaryLanguage': config.primaryLanguage,
      'commandTimeout': config.commandTimeout.inMilliseconds,
    };
  }

  VoiceCommandConfig _configFromJson(Map<String, dynamic> json) {
    return VoiceCommandConfig(
      confidenceThreshold: json['confidenceThreshold']?.toDouble() ?? 0.7,
      enableFuzzyMatching: json['enableFuzzyMatching'] ?? true,
      enableContextualParsing: json['enableContextualParsing'] ?? true,
      customCommands: List<String>.from(json['customCommands'] ?? []),
      commandAliases: Map<String, String>.from(json['commandAliases'] ?? {}),
      enableMultiLanguage: json['enableMultiLanguage'] ?? false,
      primaryLanguage: json['primaryLanguage'] ?? 'en',
      commandTimeout: Duration(milliseconds: json['commandTimeout'] ?? 30000),
    );
  }

  double _calculateSimilarity(String a, String b) {
    if (a == b) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;

    final longer = a.length > b.length ? a : b;
    final shorter = a.length > b.length ? b : a;

    if (longer.isEmpty) return 1.0;

    final editDistance = _levenshteinDistance(longer, shorter);
    return (longer.length - editDistance) / longer.length;
  }

  int _levenshteinDistance(String a, String b) {
    final matrix = List.generate(
      a.length + 1,
      (i) => List.generate(b.length + 1, (j) => 0),
    );

    for (int i = 0; i <= a.length; i++) {
      matrix[i][0] = i;
    }

    for (int j = 0; j <= b.length; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= a.length; i++) {
      for (int j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1, // deletion
          matrix[i][j - 1] + 1, // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[a.length][b.length];
  }
}

/// Represents a custom voice command created by the user
class CustomVoiceCommand {
  final String id;
  final String name;
  final String description;
  final List<String> patterns;
  final VoiceCommandType targetCommandType;
  final Map<String, dynamic> parameters;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CustomVoiceCommand({
    required this.id,
    required this.name,
    required this.description,
    required this.patterns,
    required this.targetCommandType,
    this.parameters = const {},
    this.isEnabled = true,
    required this.createdAt,
    this.updatedAt,
  });

  /// Creates a custom voice command from JSON
  factory CustomVoiceCommand.fromJson(Map<String, dynamic> json) {
    return CustomVoiceCommand(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      patterns: List<String>.from(json['patterns']),
      targetCommandType: VoiceCommandType.values.firstWhere(
        (type) => type.name == json['targetCommandType'],
        orElse: () => VoiceCommandType.unknown,
      ),
      parameters: Map<String, dynamic>.from(json['parameters'] ?? {}),
      isEnabled: json['isEnabled'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  /// Converts this custom command to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'patterns': patterns,
      'targetCommandType': targetCommandType.name,
      'parameters': parameters,
      'isEnabled': isEnabled,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  /// Creates a copy of this command with updated fields
  CustomVoiceCommand copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? patterns,
    VoiceCommandType? targetCommandType,
    Map<String, dynamic>? parameters,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomVoiceCommand(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      patterns: patterns ?? this.patterns,
      targetCommandType: targetCommandType ?? this.targetCommandType,
      parameters: parameters ?? this.parameters,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
