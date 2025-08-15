import '../../domain/models/enums.dart';
import 'enhanced_local_parser.dart';

/// Natural language parsing service for extracting task details from text
/// 
/// This service analyzes user input to extract:
/// - Due dates from natural language expressions
/// - Priority levels from keywords
/// - Tags from contextual keywords
/// - Task categories
class NaturalLanguageParser {
  static final EnhancedLocalParser _parser = EnhancedLocalParser();
  
  /// Parses a text input and extracts task information
  static Future<TaskParseResult> parseTaskText(String input) async {
    // Use the enhanced local parser
    final parsedData = await _parser.parseTaskFromText(input);
    
    return TaskParseResult(
      originalText: input,
      extractedTitle: parsedData.title,
      dueDate: parsedData.dueDate,
      priority: parsedData.priority,
      tags: parsedData.suggestedTags,
      category: _extractCategory(input.toLowerCase()),
    );
  }
  
  /// Legacy synchronous method for backward compatibility
  static TaskParseResult parseTaskTextSync(String input) {
    final cleanInput = input.toLowerCase().trim();
    
    return TaskParseResult(
      originalText: input,
      extractedTitle: _extractTitle(cleanInput, input),
      dueDate: _extractDueDate(cleanInput),
      priority: _extractPriority(cleanInput),
      tags: _extractTags(cleanInput),
      category: _extractCategory(cleanInput),
    );
  }
  
  /// Extracts the main task title by removing date/priority keywords
  static String _extractTitle(String cleanInput, String originalInput) {
    String title = originalInput;
    
    // Remove common date expressions
    final datePatterns = [
      r'\b(today|tomorrow|yesterday)\b',
      r'\b(next|this)\s+(week|month|year|monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b',
      r'\b(in\s+\d+\s+(days?|weeks?|months?|years?))\b',
      r'\b(on\s+(monday|tuesday|wednesday|thursday|friday|saturday|sunday))\b',
      r'\b(at\s+\d{1,2}(:\d{2})?\s*(am|pm)?)\b',
      r'\b\d{1,2}[/\-]\d{1,2}([/\-]\d{2,4})?\b',
    ];
    
    for (final pattern in datePatterns) {
      title = title.replaceAll(RegExp(pattern, caseSensitive: false), '').trim();
    }
    
    // Remove priority keywords
    final priorityPatterns = [
      r'\b(urgent|emergency|asap)\b',
      r'\b(high\s+priority|important)\b',
      r'\b(low\s+priority|when\s+i\s+have\s+time)\b',
      r'\b(medium\s+priority|normal)\b',
    ];
    
    for (final pattern in priorityPatterns) {
      title = title.replaceAll(RegExp(pattern, caseSensitive: false), '').trim();
    }
    
    // Clean up extra whitespace
    title = title.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    return title.isNotEmpty ? title : originalInput;
  }
  
  /// Extracts due date from natural language expressions
  static DateTime? _extractDueDate(String input) {
    final now = DateTime.now();
    
    // Today
    if (RegExp(r'\btoday\b').hasMatch(input)) {
      return DateTime(now.year, now.month, now.day, 23, 59);
    }
    
    // Tomorrow
    if (RegExp(r'\btomorrow\b').hasMatch(input)) {
      final tomorrow = now.add(const Duration(days: 1));
      return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 23, 59);
    }
    
    // Yesterday (for overdue tasks)
    if (RegExp(r'\byesterday\b').hasMatch(input)) {
      final yesterday = now.subtract(const Duration(days: 1));
      return DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59);
    }
    
    // Next week
    if (RegExp(r'\bnext\s+week\b').hasMatch(input)) {
      final nextWeek = now.add(const Duration(days: 7));
      return DateTime(nextWeek.year, nextWeek.month, nextWeek.day, 23, 59);
    }
    
    // This week (Friday)
    if (RegExp(r'\bthis\s+week\b').hasMatch(input)) {
      final daysUntilFriday = (5 - now.weekday) % 7;
      final thisWeekEnd = now.add(Duration(days: daysUntilFriday == 0 ? 7 : daysUntilFriday));
      return DateTime(thisWeekEnd.year, thisWeekEnd.month, thisWeekEnd.day, 23, 59);
    }
    
    // Next month
    if (RegExp(r'\bnext\s+month\b').hasMatch(input)) {
      final nextMonth = DateTime(now.year, now.month + 1, now.day);
      return DateTime(nextMonth.year, nextMonth.month, nextMonth.day, 23, 59);
    }
    
    // Specific days of the week
    final weekdays = {
      'monday': 1, 'tuesday': 2, 'wednesday': 3, 'thursday': 4,
      'friday': 5, 'saturday': 6, 'sunday': 7
    };
    
    for (final entry in weekdays.entries) {
      if (RegExp('\\b(next\\s+)?${entry.key}\\b').hasMatch(input)) {
        final targetWeekday = entry.value;
        final daysUntilTarget = (targetWeekday - now.weekday) % 7;
        final targetDate = now.add(Duration(days: daysUntilTarget == 0 ? 7 : daysUntilTarget));
        return DateTime(targetDate.year, targetDate.month, targetDate.day, 23, 59);
      }
    }
    
    // "In X days/weeks/months"
    final inXPattern = RegExp(r'\bin\s+(\d+)\s+(days?|weeks?|months?)\b');
    final inXMatch = inXPattern.firstMatch(input);
    if (inXMatch != null) {
      final amount = int.tryParse(inXMatch.group(1) ?? '');
      final unit = inXMatch.group(2);
      
      if (amount != null) {
        Duration duration;
        switch (unit) {
          case 'day':
          case 'days':
            duration = Duration(days: amount);
            break;
          case 'week':
          case 'weeks':
            duration = Duration(days: amount * 7);
            break;
          case 'month':
          case 'months':
            // Approximate month as 30 days
            duration = Duration(days: amount * 30);
            break;
          default:
            return null;
        }
        
        final targetDate = now.add(duration);
        return DateTime(targetDate.year, targetDate.month, targetDate.day, 23, 59);
      }
    }
    
    // Date patterns like "12/25" or "12-25-2024"
    final datePattern = RegExp(r'\b(\d{1,2})[/\-](\d{1,2})(?:[/\-](\d{2,4}))?\b');
    final dateMatch = datePattern.firstMatch(input);
    if (dateMatch != null) {
      final month = int.tryParse(dateMatch.group(1) ?? '');
      final day = int.tryParse(dateMatch.group(2) ?? '');
      final yearStr = dateMatch.group(3);
      int year = now.year;
      
      if (yearStr != null) {
        final parsedYear = int.tryParse(yearStr);
        if (parsedYear != null) {
          year = parsedYear < 100 ? 2000 + parsedYear : parsedYear;
        }
      }
      
      if (month != null && day != null && month >= 1 && month <= 12 && day >= 1 && day <= 31) {
        try {
          return DateTime(year, month, day, 23, 59);
        } catch (e) {
          // Invalid date
          return null;
        }
      }
    }
    
    return null;
  }
  
  /// Extracts priority level from keywords
  static TaskPriority _extractPriority(String input) {
    // Urgent/Emergency
    if (RegExp(r'\b(urgent|emergency|asap|critical|immediately)\b').hasMatch(input)) {
      return TaskPriority.urgent;
    }
    
    // High priority
    if (RegExp(r'\b(high\s+priority|important|crucial|vital)\b').hasMatch(input)) {
      return TaskPriority.high;
    }
    
    // Low priority
    if (RegExp(r'\b(low\s+priority|when\s+i\s+have\s+time|sometime|eventually)\b').hasMatch(input)) {
      return TaskPriority.low;
    }
    
    // Medium priority (default or explicit)
    if (RegExp(r'\b(medium\s+priority|normal|regular)\b').hasMatch(input)) {
      return TaskPriority.medium;
    }
    
    // Default to medium if no priority indicators found
    return TaskPriority.medium;
  }
  
  /// Extracts relevant tags from the input
  static List<String> _extractTags(String input) {
    final tags = <String>[];
    
    // Work-related keywords
    if (RegExp(r'\b(meeting|call|email|presentation|report|project|client|boss|colleague)\b').hasMatch(input)) {
      tags.add('work');
    }
    
    // Personal keywords
    if (RegExp(r'\b(family|personal|home|doctor|appointment|birthday|anniversary)\b').hasMatch(input)) {
      tags.add('personal');
    }
    
    // Health keywords
    if (RegExp(r'\b(doctor|dentist|hospital|medicine|workout|exercise|gym|health)\b').hasMatch(input)) {
      tags.add('health');
    }
    
    // Shopping keywords
    if (RegExp(r'\b(buy|purchase|shop|store|grocery|groceries|supermarket|mall)\b').hasMatch(input)) {
      tags.add('shopping');
    }
    
    // Travel keywords
    if (RegExp(r'\b(travel|flight|hotel|vacation|trip|booking|airport)\b').hasMatch(input)) {
      tags.add('travel');
    }
    
    // Finance keywords
    if (RegExp(r'\b(bank|payment|bill|budget|money|finance|tax|insurance)\b').hasMatch(input)) {
      tags.add('finance');
    }
    
    // Car/Transport keywords
    if (RegExp(r'\b(car|drive|gas|maintenance|repair|parking|transport)\b').hasMatch(input)) {
      tags.add('transport');
    }
    
    return tags;
  }
  
  /// Extracts task category
  static String? _extractCategory(String input) {
    // Work category
    if (RegExp(r'\b(meeting|call|email|presentation|report|project|client|work)\b').hasMatch(input)) {
      return 'Work';
    }
    
    // Personal category  
    if (RegExp(r'\b(family|personal|home|chores|cleaning)\b').hasMatch(input)) {
      return 'Personal';
    }
    
    // Health category
    if (RegExp(r'\b(doctor|dentist|hospital|medicine|workout|exercise|gym|health)\b').hasMatch(input)) {
      return 'Health';
    }
    
    // Shopping category
    if (RegExp(r'\b(buy|purchase|shop|store|grocery|groceries|shopping)\b').hasMatch(input)) {
      return 'Shopping';
    }
    
    return null;
  }
}

/// Result of parsing task text
class TaskParseResult {
  final String originalText;
  final String extractedTitle;
  final DateTime? dueDate;
  final TaskPriority priority;
  final List<String> tags;
  final String? category;
  
  const TaskParseResult({
    required this.originalText,
    required this.extractedTitle,
    this.dueDate,
    required this.priority,
    required this.tags,
    this.category,
  });
  
  @override
  String toString() {
    return 'TaskParseResult(title: $extractedTitle, dueDate: $dueDate, priority: $priority, tags: $tags, category: $category)';
  }
}