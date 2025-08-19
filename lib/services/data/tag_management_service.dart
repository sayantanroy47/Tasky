import '../../domain/entities/tag.dart';
import '../../domain/repositories/task_repository.dart';


/// Result of tag validation
class TagValidationResult {
  final bool isValid;
  final String? message;
  final TagValidationLevel level;
  
  const TagValidationResult._(this.isValid, this.message, this.level);
  
  factory TagValidationResult.valid() => const TagValidationResult._(true, null, TagValidationLevel.valid);
  factory TagValidationResult.warning(String message) => TagValidationResult._(true, message, TagValidationLevel.warning);
  factory TagValidationResult.invalid(String message) => TagValidationResult._(false, message, TagValidationLevel.invalid);
}

enum TagValidationLevel { valid, warning, invalid }

/// Result of tag list validation
class TagListValidationResult {
  final bool isValid;
  final String? message;
  final List<TagValidationResult> individualResults;
  
  const TagListValidationResult._(this.isValid, this.message, this.individualResults);
  
  factory TagListValidationResult.valid(List<TagValidationResult> results) => TagListValidationResult._(true, null, results);
  factory TagListValidationResult.invalid(String message, [List<TagValidationResult>? results]) => TagListValidationResult._(false, message, results ?? []);
}

/// Tag usage statistics
class TagUsageStatistics {
  final Tag tag;
  final int totalUsage;
  final int recentUsage;
  final DateTime lastUsed;
  final double score;
  
  const TagUsageStatistics({
    required this.tag,
    required this.totalUsage,
    required this.recentUsage,
    required this.lastUsed,
    required this.score,
  });
}

/// Tag suggestion with reason
class TagSuggestion {
  final Tag tag;
  final int usage;
  final TagSuggestionReason reason;
  final double score;
  
  const TagSuggestion({
    required this.tag,
    required this.usage,
    required this.reason,
    required this.score,
  });
}

enum TagSuggestionReason { frequent, recent, similar, contextual }

/// Result of tag cleanup operation
class TagCleanupResult {
  final List<String> removedTags;
  final Map<String, String> mergedTags;
  final Map<String, String> renamedTags;
  final List<String> messages;
  
  const TagCleanupResult({
    required this.removedTags,
    required this.mergedTags,
    required this.renamedTags,
    required this.messages,
  });
}

/// Comprehensive tag management service with validation and operations
class TagManagementService {
  final TaskRepository _taskRepository;
  
  // Configuration constants
  static const int maxTagLength = 30;
  static const int maxTagsPerTask = 15;
  static const String tagPattern = r'^[a-zA-Z0-9\-_\s]+$';
  static const List<String> reservedTags = [
    'system', 'internal', 'temp', 'deleted', 'archived'
  ];
  
  TagManagementService(this._taskRepository);
  
  /// Validates a single tag
  TagValidationResult validateTag(String tag) {
    final trimmedTag = tag.trim();
    
    if (trimmedTag.isEmpty) {
      return TagValidationResult.invalid('Tag cannot be empty');
    }
    
    if (trimmedTag.length > maxTagLength) {
      return TagValidationResult.invalid('Tag exceeds maximum length of $maxTagLength characters');
    }
    
    if (!RegExp(tagPattern, caseSensitive: false).hasMatch(trimmedTag)) {
      return TagValidationResult.invalid('Tag contains invalid characters. Only letters, numbers, hyphens, underscores, and spaces are allowed');
    }
    
    if (reservedTags.contains(trimmedTag.toLowerCase())) {
      return TagValidationResult.invalid('Tag name is reserved and cannot be used');
    }
    
    return TagValidationResult.valid();
  }
  
  /// Normalizes a tag by trimming and standardizing format
  String normalizeTag(String tag) {
    return tag.trim()
      .replaceAll(RegExp(r'\s+'), ' ')
      .toLowerCase();
  }
  
  /// Gets all unique tags across all tasks with usage statistics
  Future<List<TagUsageStatistics>> getAllTagsWithUsage() async {
    final allTasks = await _taskRepository.getAllTasks();
    final tagCounts = <String, TagUsageStatistics>{};
    
    for (final task in allTasks) {
      for (final tagName in task.tags) {
        final normalizedTag = normalizeTag(tagName);
        final tag = Tag(id: normalizedTag, name: normalizedTag, color: '0xFF2196F3', createdAt: DateTime.now());
        
        if (tagCounts.containsKey(normalizedTag)) {
          final existing = tagCounts[normalizedTag]!;
          tagCounts[normalizedTag] = TagUsageStatistics(
            tag: tag,
            totalUsage: existing.totalUsage + 1,
            recentUsage: existing.recentUsage + 1,
            lastUsed: task.createdAt.isAfter(existing.lastUsed) ? task.createdAt : existing.lastUsed,
            score: existing.score + 1,
          );
        } else {
          tagCounts[normalizedTag] = TagUsageStatistics(
            tag: tag,
            totalUsage: 1,
            recentUsage: 1,
            lastUsed: task.createdAt,
            score: 1,
          );
        }
      }
    }
    
    return tagCounts.values.toList()..sort((a, b) => b.totalUsage.compareTo(a.totalUsage));
  }
  
  /// Cleans up tags by removing unused ones and normalizing inconsistencies
  Future<TagCleanupResult> cleanupTags({
    bool removeUnused = false,
    bool normalizeCase = true,
    bool removeEmptyTags = true,
  }) async {
    final allTasks = await _taskRepository.getAllTasks();
    final removedTags = <String>[];
    final mergedTags = <String, String>{};
    final renamedTags = <String, String>{};
    final messages = <String>[];
    
    for (final task in allTasks) {
      try {
        bool taskModified = false;
        final cleanedTags = <String>[];
        
        for (final tag in task.tags) {
          final trimmedTag = tag.trim();
          
          if (removeEmptyTags && trimmedTag.isEmpty) {
            taskModified = true;
            removedTags.add(tag);
            continue;
          }
          
          String processedTag = trimmedTag;
          if (normalizeCase) {
            final normalized = normalizeTag(trimmedTag);
            if (normalized != trimmedTag) {
              processedTag = normalized;
              taskModified = true;
              renamedTags[trimmedTag] = normalized;
            }
          }
          
          cleanedTags.add(processedTag);
        }
        
        final uniqueTags = cleanedTags.toSet().toList();
        if (uniqueTags.length != cleanedTags.length) {
          taskModified = true;
          final duplicateCount = cleanedTags.length - uniqueTags.length;
          mergedTags['duplicates_${task.id}'] = '$duplicateCount duplicates merged';
        }
        
        if (taskModified) {
          final updatedTask = task.copyWith(tags: uniqueTags);
          await _taskRepository.updateTask(updatedTask);
        }
      } catch (e) {
        messages.add('Error processing task ${task.id}: $e');
      }
    }
    
    return TagCleanupResult(
      removedTags: removedTags,
      mergedTags: mergedTags,
      renamedTags: renamedTags,
      messages: messages,
    );
  }
}