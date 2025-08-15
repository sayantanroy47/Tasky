import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../domain/entities/task_enums.dart';
import 'ai_task_parser.dart';

/// Claude 3 implementation of AI task parsing
class ClaudeTaskParser implements AITaskParser {
  final String _apiKey;
  final String _baseUrl;
  final String _model;
  final http.Client _httpClient;

  ClaudeTaskParser({
    required String apiKey,
    String baseUrl = 'https://api.anthropic.com/v1',
    String model = 'claude-3-sonnet-20240229',
    http.Client? httpClient,
  })  : _apiKey = apiKey,
        _baseUrl = baseUrl,
        _model = model,
        _httpClient = httpClient ?? http.Client();  @override
  bool get isAvailable => _apiKey.isNotEmpty;  @override
  String get serviceName => 'Claude 3';  @override
  Future<ParsedTaskData> parseTaskFromText(String text) async {
    if (!isAvailable) {
      throw const AIParsingException('Claude API key not configured');
    }

    try {
      final prompt = _buildTaskParsingPrompt(text);
      final response = await _makeAPICall(prompt);
      return _parseTaskResponse(response, text);
    } catch (e) {
      throw AIParsingException(
        'Failed to parse task with Claude: ${e.toString()}',
        originalError: e,
      );
    }
  }  @override
  Future<List<String>> suggestTags(String taskText) async {
    if (!isAvailable) return [];

    try {
      final prompt = _buildTagSuggestionPrompt(taskText);
      final response = await _makeAPICall(prompt);
      return _parseTagsResponse(response);
    } catch (e) {
      // Fail silently for tag suggestions
      return [];
    }
  }  @override
  Future<DateTime?> extractDueDate(String text) async {
    if (!isAvailable) return null;

    try {
      final prompt = _buildDateExtractionPrompt(text);
      final response = await _makeAPICall(prompt);
      return _parseDateResponse(response);
    } catch (e) {
      // Fail silently for date extraction
      return null;
    }
  }  @override
  Future<TaskPriority> determinePriority(String text) async {
    if (!isAvailable) return TaskPriority.medium;

    try {
      final prompt = _buildPriorityPrompt(text);
      final response = await _makeAPICall(prompt);
      return _parsePriorityResponse(response);
    } catch (e) {
      // Fail silently and return default priority
      return TaskPriority.medium;
    }
  }  @override
  Future<List<String>> extractSubtasks(String text) async {
    if (!isAvailable) return [];

    try {
      final prompt = _buildSubtaskExtractionPrompt(text);
      final response = await _makeAPICall(prompt);
      return _parseSubtasksResponse(response);
    } catch (e) {
      // Fail silently for subtask extraction
      return [];
    }
  }

  /// Makes an API call to Claude
  Future<String> _makeAPICall(String prompt) async {
    try {
      final uri = Uri.parse('$_baseUrl/messages');
      
      final body = jsonEncode({
        'model': _model,
        'max_tokens': 500,
        'messages': [
          {
            'role': 'user',
            'content': prompt,
          },
        ],
      });

      final response = await _httpClient.post(
        uri,
        headers: {
          'x-api-key': _apiKey,
          'Content-Type': 'application/json',
          'anthropic-version': '2023-06-01',
        },
        body: body,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw const AIParsingException(
          'Claude API request timed out after 30 seconds',
          code: 'TIMEOUT',
        ),
      );

      if (response.statusCode != 200) {
        String errorMessage = 'Claude API request failed with status ${response.statusCode}';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['error']?['message'] != null) {
            errorMessage += ': ${errorData['error']['message']}';
          }
        } catch (_) {
          // Ignore JSON parsing errors for error response
        }
        
        throw AIParsingException(
          errorMessage,
          code: response.statusCode.toString(),
        );
      }

      if (response.body.isEmpty) {
        throw const AIParsingException('Empty response from Claude API');
      }

      late final Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        throw AIParsingException(
          'Invalid JSON response from Claude API: $e',
          code: 'INVALID_JSON',
        );
      }
      
      final content = responseData['content']?[0]?['text'];
      
      if (content == null || content.toString().trim().isEmpty) {
        throw const AIParsingException('Invalid or empty response content from Claude API');
      }

      return content.toString();
    } on AIParsingException {
      // Re-throw AIParsingException as-is
      rethrow;
    } catch (e) {
      // Catch all other exceptions (network errors, etc.)
      throw AIParsingException(
        'Network or system error during Claude API call: ${e.toString()}',
        originalError: e,
        code: 'NETWORK_ERROR',
      );
    }
  }

  /// Builds the prompt for comprehensive task parsing
  String _buildTaskParsingPrompt(String text) {
    return '''
Parse the following text into a structured task. Extract:
1. Title (required, concise)
2. Description (optional, detailed)
3. Due date (ISO 8601 format if found, null otherwise)
4. Priority (low, medium, high, urgent)
5. Suggested tags (relevant keywords)
6. Subtasks (if any steps are mentioned)

Text: "$text"

Respond with valid JSON in this exact format:
{
  "title": "string",
  "description": "string or null",
  "dueDate": "ISO 8601 string or null",
  "priority": "low|medium|high|urgent",
  "suggestedTags": ["tag1", "tag2"],
  "subtasks": ["subtask1", "subtask2"],
  "confidence": 0.0-1.0
}
''';
  }

  /// Builds the prompt for tag suggestions
  String _buildTagSuggestionPrompt(String taskText) {
    return '''
Suggest relevant tags for this task. Consider:
- Task category (work, personal, shopping, etc.)
- Context (meeting, deadline, project, etc.)
- Keywords from the text

Task: "$taskText"

Respond with JSON: {"tags": ["tag1", "tag2", "tag3"]}
''';
  }

  /// Builds the prompt for date extraction
  String _buildDateExtractionPrompt(String text) {
    return '''
Extract the due date from this text. Consider:
- Relative dates (tomorrow, next week, in 3 days)
- Absolute dates (March 15, 2024-03-15)
- Time expressions (by 5pm, end of day)

Text: "$text"
Current date: ${DateTime.now().toIso8601String()}

Respond with JSON: {"dueDate": "ISO 8601 string or null"}
''';
  }

  /// Builds the prompt for priority determination
  String _buildPriorityPrompt(String text) {
    return '''
Determine the priority level from this text. Look for:
- Urgency indicators (urgent, ASAP, immediately)
- Importance markers (important, critical, high priority)
- Deadline pressure (due today, overdue)
- Default to medium if unclear

Text: "$text"

Respond with JSON: {"priority": "low|medium|high|urgent"}
''';
  }

  /// Builds the prompt for subtask extraction
  String _buildSubtaskExtractionPrompt(String text) {
    return '''
Extract subtasks or steps from this text. Look for:
- Numbered or bulleted lists
- Sequential actions (first, then, next)
- Multiple verbs indicating separate actions

Text: "$text"

Respond with JSON: {"subtasks": ["step1", "step2"]}
''';
  }

  /// Parses the comprehensive task response
  ParsedTaskData _parseTaskResponse(String response, String originalText) {
    try {
      final data = jsonDecode(response);
      
      return ParsedTaskData(
        title: data['title']?.toString() ?? _extractTitleFallback(originalText),
        description: data['description']?.toString(),
        dueDate: data['dueDate'] != null ? DateTime.tryParse(data['dueDate']) : null,
        priority: _parsePriorityString(data['priority']?.toString()),
        suggestedTags: (data['suggestedTags'] as List?)?.cast<String>() ?? [],
        subtasks: (data['subtasks'] as List?)?.cast<String>() ?? [],
        confidence: (data['confidence'] as num?)?.toDouble() ?? 0.5,
        metadata: {'source': 'claude', 'model': _model},
      );
    } catch (e) {
      // Fallback to basic parsing
      return ParsedTaskData(
        title: _extractTitleFallback(originalText),
        confidence: 0.1,
        metadata: {'source': 'fallback', 'error': e.toString()},
      );
    }
  }

  /// Parses tags response
  List<String> _parseTagsResponse(String response) {
    try {
      final data = jsonDecode(response);
      return (data['tags'] as List?)?.cast<String>() ?? [];
    } catch (e) {
      return [];
    }
  }

  /// Parses date response
  DateTime? _parseDateResponse(String response) {
    try {
      final data = jsonDecode(response);
      final dateStr = data['dueDate']?.toString();
      return dateStr != null ? DateTime.tryParse(dateStr) : null;
    } catch (e) {
      return null;
    }
  }

  /// Parses priority response
  TaskPriority _parsePriorityResponse(String response) {
    try {
      final data = jsonDecode(response);
      return _parsePriorityString(data['priority']?.toString());
    } catch (e) {
      return TaskPriority.medium;
    }
  }

  /// Parses subtasks response
  List<String> _parseSubtasksResponse(String response) {
    try {
      final data = jsonDecode(response);
      return (data['subtasks'] as List?)?.cast<String>() ?? [];
    } catch (e) {
      return [];
    }
  }

  /// Converts priority string to enum
  TaskPriority _parsePriorityString(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'low':
        return TaskPriority.low;
      case 'high':
        return TaskPriority.high;
      case 'urgent':
        return TaskPriority.urgent;
      default:
        return TaskPriority.medium;
    }
  }

  /// Fallback title extraction
  String _extractTitleFallback(String text) {
    // Take first sentence or first 50 characters
    final sentences = text.split(RegExp(r'[.!?]'));
    if (sentences.isNotEmpty && sentences.first.trim().isNotEmpty) {
      return sentences.first.trim();
    }
    
    return text.length > 50 ? '${text.substring(0, 50)}...' : text;
  }

  /// Disposes resources
  void dispose() {
    _httpClient.close();
  }
}
