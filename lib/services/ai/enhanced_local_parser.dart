import '../../domain/entities/task_enums.dart';
import 'ai_task_parser.dart';

/// Enhanced local NLP parser - NO API costs, surprisingly effective
class EnhancedLocalParser implements AITaskParser {
  
  // Comprehensive keyword databases
  static final _urgentKeywords = [
    'urgent', 'asap', 'immediately', 'critical', 'emergency', 'rush', 'deadline',
    'due today', 'overdue', 'late', 'must do', 'priority', 'important'
  ];
  
  static final _highPriorityKeywords = [
    'important', 'high priority', 'must', 'need to', 'should', 'boss',
    'client', 'meeting', 'presentation', 'interview', 'appointment'
  ];
  
  static final _lowPriorityKeywords = [
    'maybe', 'eventually', 'someday', 'when possible', 'if time', 'optional',
    'nice to have', 'consider', 'think about'
  ];
  
  // Date pattern matching
  static final _relativeDates = <String, DateTime Function()>{
    'today': () => DateTime.now(),
    'tomorrow': () => DateTime.now().add(const Duration(days: 1)),
    'next week': () => DateTime.now().add(const Duration(days: 7)),
    'this week': () => _getEndOfWeek(),
    'next month': () => DateTime.now().add(const Duration(days: 30)),
    'monday': () => _getNextWeekday(DateTime.monday),
    'tuesday': () => _getNextWeekday(DateTime.tuesday),
    'wednesday': () => _getNextWeekday(DateTime.wednesday),
    'thursday': () => _getNextWeekday(DateTime.thursday),
    'friday': () => _getNextWeekday(DateTime.friday),
    'saturday': () => _getNextWeekday(DateTime.saturday),
    'sunday': () => _getNextWeekday(DateTime.sunday),
  };
  
  // Time patterns
  static final _timePatterns = <RegExp, String Function(Match)>{
    RegExp(r'(\d{1,2}):(\d{2})\s*(am|pm)', caseSensitive: false): (match) => 
        '${match.group(1)}:${match.group(2)} ${match.group(3)?.toUpperCase()}',
    RegExp(r'(\d{1,2})\s*(am|pm)', caseSensitive: false): (match) => 
        '${match.group(1)}:00 ${match.group(2)?.toUpperCase()}',
    RegExp(r'noon', caseSensitive: false): (match) => '12:00 PM',
    RegExp(r'midnight', caseSensitive: false): (match) => '12:00 AM',
  };
  
  // Tag categories
  static final _tagPatterns = <String, List<String>>{
    'work': ['work', 'office', 'job', 'meeting', 'client', 'project', 'boss', 'colleague'],
    'personal': ['personal', 'home', 'family', 'friend', 'self'],
    'shopping': ['buy', 'purchase', 'store', 'shop', 'grocery', 'groceries'],
    'health': ['doctor', 'appointment', 'medicine', 'gym', 'exercise', 'health'],
    'finance': ['bank', 'money', 'budget', 'bill', 'payment', 'tax'],
    'travel': ['trip', 'vacation', 'flight', 'hotel', 'travel', 'visit'],
    'education': ['study', 'learn', 'course', 'school', 'university', 'homework'],
    'maintenance': ['fix', 'repair', 'clean', 'maintain', 'service'],
  };

  @override
  bool get isAvailable => true;

  @override
  String get serviceName => 'Enhanced Local Parser';

  @override
  Future<ParsedTaskData> parseTaskFromText(String text) async {
    final cleanText = text.trim().toLowerCase();
    
    return ParsedTaskData(
      title: _extractTitle(text),
      description: _extractDescription(text),
      dueDate: await _extractDueDate(cleanText),
      priority: _determinePriority(cleanText),
      suggestedTags: _suggestTags(cleanText),
      subtasks: _extractSubtasks(text),
      confidence: _calculateConfidence(text),
      metadata: {
        'source': 'enhanced_local_parser',
        'word_count': text.split(' ').length,
        'processing_time': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  @override
  Future<List<String>> suggestTags(String taskText) async {
    return _generateSmartTags(taskText.toLowerCase());
  }

  @override
  Future<DateTime?> extractDueDate(String text) async {
    return _extractDueDate(text.toLowerCase());
  }

  @override
  Future<TaskPriority> determinePriority(String text) async {
    return _analyzePriorityContext(text.toLowerCase());
  }

  @override
  Future<List<String>> extractSubtasks(String text) async {
    return _extractActionItems(text);
  }

  // Private implementation methods

  String _extractTitle(String text) {
    // Remove common prefixes
    String title = text.trim();
    final prefixes = ['todo:', 'task:', 'reminder:', 'note:', 'do:'];
    
    for (final prefix in prefixes) {
      if (title.toLowerCase().startsWith(prefix)) {
        title = title.substring(prefix.length).trim();
        break;
      }
    }
    
    // Take first sentence or first 50 characters
    final sentences = title.split(RegExp(r'[.!?]\s+'));
    if (sentences.isNotEmpty && sentences.first.trim().isNotEmpty) {
      final firstSentence = sentences.first.trim();
      return firstSentence.length > 100 ? '${firstSentence.substring(0, 100)}...' : firstSentence;
    }
    
    return title.length > 100 ? '${title.substring(0, 100)}...' : title;
  }

  String? _extractDescription(String text) {
    final sentences = text.split(RegExp(r'[.!?]\s+'));
    if (sentences.length > 1) {
      // Join remaining sentences as description
      return sentences.skip(1).join('. ').trim();
    }
    return null;
  }

  Future<DateTime?> _extractDueDate(String text) async {
    // Check relative dates first
    for (final entry in _relativeDates.entries) {
      if (text.contains(entry.key)) {
        final baseDate = entry.value();
        
        // Check for time modifiers
        for (final timeEntry in _timePatterns.entries) {
          final match = timeEntry.key.firstMatch(text);
          if (match != null) {
            final timeStr = timeEntry.value(match);
            return _combineDateAndTime(baseDate, timeStr);
          }
        }
        
        return baseDate;
      }
    }
    
    // Check for "in X days/weeks/months" patterns
    final inXPattern = RegExp(r'in (\d+) (day|week|month)s?');
    final match = inXPattern.firstMatch(text);
    if (match != null) {
      final amount = int.parse(match.group(1)!);
      final unit = match.group(2)!;
      
      switch (unit) {
        case 'day':
          return DateTime.now().add(Duration(days: amount));
        case 'week':
          return DateTime.now().add(Duration(days: amount * 7));
        case 'month':
          return DateTime.now().add(Duration(days: amount * 30));
      }
    }
    
    // Check for specific date patterns (MM/DD, DD/MM, etc.)
    final datePatterns = [
      RegExp(r'(\d{1,2})/(\d{1,2})(?:/(\d{2,4}))?'), // MM/DD or MM/DD/YYYY
      RegExp(r'(\d{1,2})-(\d{1,2})(?:-(\d{2,4}))?'), // MM-DD or MM-DD-YYYY
    ];
    
    for (final pattern in datePatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final month = int.tryParse(match.group(1)!) ?? 1;
        final day = int.tryParse(match.group(2)!) ?? 1;
        final year = match.group(3) != null 
            ? int.tryParse(match.group(3)!) ?? DateTime.now().year
            : DateTime.now().year;
        
        try {
          return DateTime(year, month, day);
        } catch (e) {
          // Invalid date, continue
        }
      }
    }
    
    return null;
  }

  TaskPriority _analyzePriorityContext(String text) {
    // Check for urgent indicators
    if (_urgentKeywords.any((keyword) => text.contains(keyword))) {
      return TaskPriority.urgent;
    }
    
    // Check for high priority indicators
    if (_highPriorityKeywords.any((keyword) => text.contains(keyword))) {
      return TaskPriority.high;
    }
    
    // Check for low priority indicators
    if (_lowPriorityKeywords.any((keyword) => text.contains(keyword))) {
      return TaskPriority.low;
    }
    
    // Context-based priority analysis
    if (text.contains('tomorrow') || text.contains('today')) {
      return TaskPriority.high;
    }
    
    if (text.contains('someday') || text.contains('eventually')) {
      return TaskPriority.low;
    }
    
    return TaskPriority.medium;
  }

  List<String> _generateSmartTags(String text) {
    final tags = <String>[];
    
    // Pattern-based tag generation
    for (final entry in _tagPatterns.entries) {
      if (entry.value.any((keyword) => text.contains(keyword))) {
        tags.add(entry.key);
      }
    }
    
    // Extract @mentions as tags
    final mentionPattern = RegExp(r'@(\w+)');
    final mentions = mentionPattern.allMatches(text);
    for (final match in mentions) {
      tags.add(match.group(1)!);
    }
    
    // Extract #hashtags as tags
    final hashtagPattern = RegExp(r'#(\w+)');
    final hashtags = hashtagPattern.allMatches(text);
    for (final match in hashtags) {
      tags.add(match.group(1)!);
    }
    
    // Smart category detection
    if (text.contains(RegExp(r'(call|phone|contact)'))) tags.add('communication');
    if (text.contains(RegExp(r'(email|send|reply)'))) tags.add('email');
    if (text.contains(RegExp(r'(meeting|conference|zoom)'))) tags.add('meeting');
    if (text.contains(RegExp(r'(report|document|write)'))) tags.add('documentation');
    
    return tags.toSet().toList(); // Remove duplicates
  }

  List<String> _extractActionItems(String text) {
    final subtasks = <String>[];
    
    // Look for numbered lists
    final numberedPattern = RegExp(r'^\s*\d+\.\s*(.+)', multiLine: true);
    final numberedMatches = numberedPattern.allMatches(text);
    for (final match in numberedMatches) {
      subtasks.add(match.group(1)!.trim());
    }
    
    // Look for bulleted lists
    final bulletPattern = RegExp(r'^\s*[-*•]\s*(.+)', multiLine: true);
    final bulletMatches = bulletPattern.allMatches(text);
    for (final match in bulletMatches) {
      subtasks.add(match.group(1)!.trim());
    }
    
    // Look for sequential action words
    final actionWords = ['first', 'then', 'next', 'after', 'finally', 'also'];
    final sentences = text.split(RegExp(r'[.!?]\s+'));
    
    for (final sentence in sentences) {
      if (actionWords.any((word) => sentence.toLowerCase().contains(word))) {
        final cleanSentence = sentence.trim();
        if (cleanSentence.isNotEmpty && !subtasks.contains(cleanSentence)) {
          subtasks.add(cleanSentence);
        }
      }
    }
    
    return subtasks;
  }

  double _calculateConfidence(String text) {
    double confidence = 0.5; // Base confidence
    
    // Increase confidence based on structure
    if (text.contains(RegExp(r'\d+\.\s'))) confidence += 0.2; // Numbered list
    if (text.contains(RegExp(r'[-*•]\s'))) confidence += 0.1; // Bullet points
    if (_relativeDates.keys.any((date) => text.toLowerCase().contains(date))) confidence += 0.2;
    if (_urgentKeywords.any((keyword) => text.toLowerCase().contains(keyword))) confidence += 0.1;
    
    return confidence.clamp(0.0, 1.0);
  }

  // Utility methods
  static DateTime _getNextWeekday(int weekday) {
    final now = DateTime.now();
    final daysUntilWeekday = (weekday - now.weekday) % 7;
    return now.add(Duration(days: daysUntilWeekday == 0 ? 7 : daysUntilWeekday));
  }

  static DateTime _getEndOfWeek() {
    final now = DateTime.now();
    final daysUntilSunday = 7 - now.weekday;
    return now.add(Duration(days: daysUntilSunday));
  }

  TaskPriority _determinePriority(String text) {
    return _analyzePriorityContext(text);
  }

  List<String> _suggestTags(String text) {
    return _generateSmartTags(text);
  }

  List<String> _extractSubtasks(String text) {
    final subtasks = <String>[];
    
    // Extract numbered lists
    final numberedPattern = RegExp(r'(\d+)\.\s*(.+)');
    final numberedMatches = numberedPattern.allMatches(text);
    for (final match in numberedMatches) {
      subtasks.add(match.group(2)!.trim());
    }
    
    // Extract bullet points
    final bulletPattern = RegExp(r'[-*•]\s*(.+)');
    final bulletMatches = bulletPattern.allMatches(text);
    for (final match in bulletMatches) {
      subtasks.add(match.group(1)!.trim());
    }
    
    return subtasks;
  }

  DateTime _combineDateAndTime(DateTime date, String timeStr) {
    // Parse time string and combine with date
    final timePattern = RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM)');
    final match = timePattern.firstMatch(timeStr);
    
    if (match != null) {
      int hour = int.parse(match.group(1)!);
      final minute = int.parse(match.group(2)!);
      final period = match.group(3)!;
      
      if (period == 'PM' && hour != 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;
      
      return DateTime(date.year, date.month, date.day, hour, minute);
    }
    
    return date;
  }
}