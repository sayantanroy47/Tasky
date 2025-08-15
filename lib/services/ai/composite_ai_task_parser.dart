import '../../domain/entities/task_enums.dart';
import '../../domain/models/ai_service_type.dart';
import 'ai_task_parser.dart';
import 'openai_task_parser.dart';
import 'claude_task_parser.dart';
import 'local_task_parser.dart';

/// Composite AI task parser that can switch between different AI services
/// and fall back to local parsing when needed
class CompositeAITaskParser implements AITaskParser {
  final OpenAITaskParser? _openAIParser;
  final ClaudeTaskParser? _claudeParser;
  final LocalTaskParser _localParser;
  final AIServiceType _preferredService;
  final bool _enableAI;

  CompositeAITaskParser({
    OpenAITaskParser? openAIParser,
    ClaudeTaskParser? claudeParser,
    LocalTaskParser? localParser,
    AIServiceType preferredService = AIServiceType.openai,
    bool enableAI = true,
  })  : _openAIParser = openAIParser,
        _claudeParser = claudeParser,
        _localParser = localParser ?? LocalTaskParser(),
        _preferredService = preferredService,
        _enableAI = enableAI;  @override
  bool get isAvailable => _enableAI ? _getPreferredParser()?.isAvailable ?? true : true;  @override
  String get serviceName {
    if (!_enableAI) return _localParser.serviceName;
    return _getPreferredParser()?.serviceName ?? _localParser.serviceName;
  }  @override
  Future<ParsedTaskData> parseTaskFromText(String text) async {
    if (!_enableAI) {
      return _localParser.parseTaskFromText(text);
    }

    final parser = _getPreferredParser();
    if (parser != null && parser.isAvailable) {
      try {
        return await parser.parseTaskFromText(text);
      } catch (e) {
        // Fall back to local parser on AI failure
        final localResult = await _localParser.parseTaskFromText(text);
        return localResult.copyWith(
          metadata: {
            ...localResult.metadata,
            'ai_fallback': true,
            'ai_error': e.toString(),
          },
        );
      }
    }

    // Use local parser as final fallback
    return _localParser.parseTaskFromText(text);
  }  @override
  Future<List<String>> suggestTags(String taskText) async {
    if (!_enableAI) {
      return _localParser.suggestTags(taskText);
    }

    final parser = _getPreferredParser();
    if (parser != null && parser.isAvailable) {
      try {
        final aiTags = await parser.suggestTags(taskText);
        final localTags = await _localParser.suggestTags(taskText);
        
        // Combine and deduplicate tags
        final combinedTags = <String>{...aiTags, ...localTags}.toList();
        return combinedTags.take(8).toList(); // Limit to 8 tags
      } catch (e) {
        // Fall back to local tags
        return _localParser.suggestTags(taskText);
      }
    }

    return _localParser.suggestTags(taskText);
  }  @override
  Future<DateTime?> extractDueDate(String text) async {
    if (!_enableAI) {
      return _localParser.extractDueDate(text);
    }

    final parser = _getPreferredParser();
    if (parser != null && parser.isAvailable) {
      try {
        final aiDate = await parser.extractDueDate(text);
        if (aiDate != null) return aiDate;
      } catch (e) {
        // Continue to local fallback
      }
    }

    // Always try local parser as fallback
    return _localParser.extractDueDate(text);
  }  @override
  Future<TaskPriority> determinePriority(String text) async {
    if (!_enableAI) {
      return _localParser.determinePriority(text);
    }

    final parser = _getPreferredParser();
    if (parser != null && parser.isAvailable) {
      try {
        return await parser.determinePriority(text);
      } catch (e) {
        // Fall back to local priority determination
        return _localParser.determinePriority(text);
      }
    }

    return _localParser.determinePriority(text);
  }  @override
  Future<List<String>> extractSubtasks(String text) async {
    if (!_enableAI) {
      return _localParser.extractSubtasks(text);
    }

    final parser = _getPreferredParser();
    if (parser != null && parser.isAvailable) {
      try {
        final aiSubtasks = await parser.extractSubtasks(text);
        final localSubtasks = await _localParser.extractSubtasks(text);
        
        // Combine and deduplicate subtasks
        final combinedSubtasks = <String>{...aiSubtasks, ...localSubtasks}.toList();
        return combinedSubtasks.take(10).toList(); // Limit to 10 subtasks
      } catch (e) {
        // Fall back to local subtasks
        return _localParser.extractSubtasks(text);
      }
    }

    return _localParser.extractSubtasks(text);
  }

  /// Gets the preferred AI parser based on configuration
  AITaskParser? _getPreferredParser() {
    switch (_preferredService) {
      case AIServiceType.openai:
        return _openAIParser;
      case AIServiceType.claude:
        return _claudeParser;
      case AIServiceType.local:
        return _localParser;
    }
  }

  /// Switches to a different AI service
  CompositeAITaskParser withService(AIServiceType service) {
    return CompositeAITaskParser(
      openAIParser: _openAIParser,
      claudeParser: _claudeParser,
      localParser: _localParser,
      preferredService: service,
      enableAI: _enableAI,
    );
  }

  /// Enables or disables AI processing
  CompositeAITaskParser withAIEnabled(bool enabled) {
    return CompositeAITaskParser(
      openAIParser: _openAIParser,
      claudeParser: _claudeParser,
      localParser: _localParser,
      preferredService: _preferredService,
      enableAI: enabled,
    );
  }

  /// Gets available AI services
  List<AIServiceType> getAvailableServices() {
    final services = <AIServiceType>[AIServiceType.local];
    
    if (_openAIParser?.isAvailable == true) {
      services.add(AIServiceType.openai);
    }
    
    if (_claudeParser?.isAvailable == true) {
      services.add(AIServiceType.claude);
    }
    
    return services;
  }

  /// Disposes all parsers
  void dispose() {
    _openAIParser?.dispose();
    _claudeParser?.dispose();
  }
}

/// Enum for different AI service types
// AIServiceType enum moved to domain/models/ai_service_type.dart
