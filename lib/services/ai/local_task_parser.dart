import '../../domain/entities/task_enums.dart';
import 'ai_task_parser.dart';

/// Local implementation of task parsing using keyword matching and regex
/// This serves as a fallback when AI services are disabled or unavailable
class LocalTaskParser implements AITaskParser {  @override
  bool get isAvailable => true;  @override
  String get serviceName => 'Local Parser';  @override
  Future<ParsedTaskData> parseTaskFromText(String text) async {
    final title = _extractTitle(text);
    final description = _extractDescription(text, title);
    final dueDate = await extractDueDate(text);
    final priority = await determinePriority(text);
    final tags = await suggestTags(text);
    final subtasks = await extractSubtasks(text);

    return ParsedTaskData(
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      suggestedTags: tags,
      subtasks: subtasks,
      confidence: 0.7,
      metadata: {'source': 'local', 'method': 'keyword_matching'},
    );
  }  @override
  Future<List<String>> suggestTags(String taskText) async {
    final tags = <String>[];
    final lowerText = taskText.toLowerCase();

    if (_containsAny(lowerText, ['meeting', 'call', 'conference', 'presentation'])) {
      tags.add('meeting');
    }
    if (_containsAny(lowerText, ['email', 'reply', 'respond', 'message'])) {
      tags.add('communication');
    }
    if (_containsAny(lowerText, ['project', 'deadline', 'deliverable'])) {
      tags.add('work');
    }
    if (_containsAny(lowerText, ['report', 'document', 'write', 'draft'])) {
      tags.add('documentation');
    }
    if (_containsAny(lowerText, ['buy', 'purchase', 'shop', 'store', 'grocery'])) {
      tags.add('shopping');
    }
    if (_containsAny(lowerText, ['doctor', 'appointment', 'dentist', 'medical'])) {
      tags.add('health');
    }
    if (_containsAny(lowerText, ['exercise', 'gym', 'workout', 'run', 'walk'])) {
      tags.add('fitness');
    }
    if (_containsAny(lowerText, ['home', 'house', 'clean', 'repair', 'fix'])) {
      tags.add('home');
    }
    if (_containsAny(lowerText, ['urgent', 'asap', 'immediately', 'critical'])) {
      tags.add('urgent');
    }
    if (_containsAny(lowerText, ['important', 'priority', 'high'])) {
      tags.add('important');
    }
    if (_containsAny(lowerText, ['daily', 'everyday', 'routine'])) {
      tags.add('routine');
    }
    if (_containsAny(lowerText, ['weekly', 'every week'])) {
      tags.add('weekly');
    }

    return tags.take(5).toList();
  }  @override
  Future<DateTime?> extractDueDate(String text) async {
    final lowerText = text.toLowerCase();
    final now = DateTime.now();

    if (_containsAny(lowerText, ['today', 'this day'])) {
      return DateTime(now.year, now.month, now.day, 23, 59);
    }

    if (_containsAny(lowerText, ['tomorrow', 'next day'])) {
      final tomorrow = now.add(const Duration(days: 1));
      return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 23, 59);
    }

    if (_containsAny(lowerText, ['this week', 'end of week'])) {
      final daysUntilFriday = 5 - now.weekday;
      final friday = now.add(Duration(days: daysUntilFriday));
      return DateTime(friday.year, friday.month, friday.day, 17, 0);
    }

    if (_containsAny(lowerText, ['next week', 'following week'])) {
      final nextWeek = now.add(const Duration(days: 7));
      return DateTime(nextWeek.year, nextWeek.month, nextWeek.day, 17, 0);
    }

    if (_containsAny(lowerText, ['this month', 'end of month'])) {
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
      return DateTime(lastDayOfMonth.year, lastDayOfMonth.month, lastDayOfMonth.day, 23, 59);
    }

    final weekdays = {
      'monday': 1, 'tuesday': 2, 'wednesday': 3, 'thursday': 4,
      'friday': 5, 'saturday': 6, 'sunday': 7,
    };

    for (final entry in weekdays.entries) {
      if (lowerText.contains(entry.key)) {
        final targetWeekday = entry.value;
        final daysUntilTarget = (targetWeekday - now.weekday + 7) % 7;
        final targetDate = now.add(Duration(days: daysUntilTarget == 0 ? 7 : daysUntilTarget));
        return DateTime(targetDate.year, targetDate.month, targetDate.day, 17, 0);
      }
    }

    final daysMatch = RegExp(r'in (\d+) days?').firstMatch(lowerText);
    if (daysMatch != null) {
      final days = int.tryParse(daysMatch.group(1) ?? '');
      if (days != null) {
        final targetDate = now.add(Duration(days: days));
        return DateTime(targetDate.year, targetDate.month, targetDate.day, 23, 59);
      }
    }

    final weeksMatch = RegExp(r'in (\d+) weeks?').firstMatch(lowerText);
    if (weeksMatch != null) {
      final weeks = int.tryParse(weeksMatch.group(1) ?? '');
      if (weeks != null) {
        final targetDate = now.add(Duration(days: weeks * 7));
        return DateTime(targetDate.year, targetDate.month, targetDate.day, 23, 59);
      }
    }

    final datePatterns = [
      RegExp(r'(\d{1,2})/(\d{1,2})/(\d{4})'),
      RegExp(r'(\d{1,2})-(\d{1,2})-(\d{4})'),
      RegExp(r'(\d{4})-(\d{1,2})-(\d{1,2})'),
    ];

    for (final pattern in datePatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        try {
          int year, month, day;
          if (pattern == datePatterns[2]) {
            year = int.parse(match.group(1)!);
            month = int.parse(match.group(2)!);
            day = int.parse(match.group(3)!);
          } else {
            month = int.parse(match.group(1)!);
            day = int.parse(match.group(2)!);
            year = int.parse(match.group(3)!);
          }
          return DateTime(year, month, day, 23, 59);
        } catch (e) {
          continue;
        }
      }
    }

    return null;
  }  @override
  Future<TaskPriority> determinePriority(String text) async {
    final lowerText = text.toLowerCase();

    if (_containsAny(lowerText, [
      'low priority', 'when possible', 'eventually', 'someday',
      'nice to have', 'optional', 'if time permits'
    ])) {
      return TaskPriority.low;
    }

    if (_containsAny(lowerText, [
      'urgent', 'asap', 'immediately', 'critical', 'emergency',
      'right now', 'right away', 'can\'t wait'
    ])) {
      return TaskPriority.urgent;
    }

    if (_containsAny(lowerText, [
      'important', 'high priority', 'crucial',
      'must do', 'need to', 'deadline', 'due today'
    ])) {
      return TaskPriority.high;
    }

    return TaskPriority.medium;
  }  @override
  Future<List<String>> extractSubtasks(String text) async {
    final subtasks = <String>[];

    // Simple approach: split by numbers and extract
    final parts = text.split(RegExp(r'\s+\d+\.\s+'));
    if (parts.length > 1) {
      for (int i = 1; i < parts.length; i++) {
        final part = parts[i].trim();
        if (part.isNotEmpty) {
          // Take only the first sentence/phrase
          final firstPart = part.split(RegExp(r'[.!?]')).first.trim();
          if (firstPart.isNotEmpty) {
            subtasks.add(firstPart);
          }
        }
      }
    }

    // Try bullet points
    final bulletMatches = RegExp(r'[-*•]\s*([^\n-*•]+)').allMatches(text);
    for (final match in bulletMatches) {
      final subtask = match.group(1)?.trim();
      if (subtask != null && subtask.isNotEmpty) {
        subtasks.add(subtask);
      }
    }

    // Sequential indicators
    if (text.toLowerCase().contains('first')) {
      final firstMatch = RegExp(r'first[,:]?\s*(.+?)(?=\s*(?:then|next|finally|$))', caseSensitive: false).firstMatch(text);
      if (firstMatch != null) {
        final subtask = firstMatch.group(1)?.trim();
        if (subtask != null && subtask.isNotEmpty) {
          subtasks.add(subtask);
        }
      }
    }

    return subtasks.toSet().take(10).toList();
  }

  String _extractTitle(String text) {
    final cleanText = text
        .replaceFirst(RegExp(r'^(todo|task|reminder|note):\s*', caseSensitive: false), '')
        .trim();

    final sentences = cleanText.split(RegExp(r'[.!?]'));
    final firstSentence = sentences.first.trim();
    
    if (firstSentence.isNotEmpty) {
      return firstSentence.length > 100 
          ? '${firstSentence.substring(0, 100)}...'
          : firstSentence;
    }

    return text.length > 50 ? '${text.substring(0, 50)}...' : text;
  }

  String? _extractDescription(String text, String title) {
    final cleanTitle = title.replaceAll('...', '');
    
    if (text.length <= cleanTitle.length + 10) {
      return null;
    }

    final titleIndex = text.indexOf(cleanTitle);
    if (titleIndex != -1) {
      final afterTitle = text.substring(titleIndex + cleanTitle.length).trim();
      if (afterTitle.startsWith('.') || afterTitle.startsWith('!') || afterTitle.startsWith('?')) {
        final remaining = afterTitle.substring(1).trim();
        return remaining.isNotEmpty ? remaining : null;
      }
      return afterTitle.isNotEmpty ? afterTitle : null;
    }

    return null;
  }

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }
}
