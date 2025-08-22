import 'dart:math' as math;
import '../../domain/entities/task_model.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/models/enums.dart';

/// Enhanced search service providing comprehensive search across all task and project attributes
/// 
/// Features:
/// - Full-text search across all task fields
/// - Advanced filtering and sorting
/// - Search result ranking and relevance scoring
/// - Search suggestions and auto-complete
/// - Search history and analytics
/// - Fuzzy matching and typo tolerance
class EnhancedSearchService {
  final TaskRepository _taskRepository;
  final ProjectRepository? _projectRepository;
  
  // Search configuration
  static const int maxSearchResults = 100;
  static const double relevanceThreshold = 0.1;
  static const List<String> stopWords = [
    'a', 'an', 'and', 'are', 'as', 'at', 'be', 'by', 'for',
    'from', 'has', 'he', 'in', 'is', 'it', 'its', 'of', 'on',
    'that', 'the', 'to', 'was', 'were', 'will', 'with', 'the'
  ];
  
  const EnhancedSearchService(this._taskRepository, [this._projectRepository]);
  
  /// Performs comprehensive search across tasks
  Future<SearchResult> searchTasks(
    String query, {
    SearchOptions options = const SearchOptions(),
  }) async {
    if (query.trim().isEmpty) {
      return SearchResult.empty(query);
    }
    
    final startTime = DateTime.now();
    final allTasks = await _taskRepository.getAllTasks();
    
    // Apply basic filters first to reduce search space
    final filteredTasks = _applyBasicFilters(allTasks, options);
    
    // Perform full-text search and scoring
    final searchResults = <ScoredTaskResult>[];
    final processedQuery = _preprocessQuery(query);
    
    for (final task in filteredTasks) {
      final score = _calculateTaskRelevanceScore(task, processedQuery, options);
      if (score >= relevanceThreshold) {
        searchResults.add(ScoredTaskResult(
          task: task,
          score: score,
          matchedFields: _getMatchedFields(task, processedQuery),
          highlights: _generateHighlights(task, processedQuery),
        ));
      }
    }
    
    // Sort by relevance score
    searchResults.sort((a, b) => b.score.compareTo(a.score));
    
    // Apply result limit
    final limitedResults = searchResults.take(maxSearchResults).toList();
    
    final duration = DateTime.now().difference(startTime);
    
    return SearchResult(
      query: query,
      results: limitedResults,
      totalFound: searchResults.length,
      searchDuration: duration,
      suggestions: await _generateSearchSuggestions(query, allTasks),
    );
  }
  
  /// Searches across both tasks and projects
  Future<UnifiedSearchResult> searchAll(
    String query, {
    SearchOptions options = const SearchOptions(),
  }) async {
    final taskSearchFuture = searchTasks(query, options: options);
    final projectSearchFuture = _projectRepository != null 
        ? searchProjects(query, options: options)
        : Future.value(ProjectSearchResult.empty(query));
    
    final results = await Future.wait([taskSearchFuture, projectSearchFuture]);
    final taskResults = results[0] as SearchResult;
    final projectResults = results[1] as ProjectSearchResult;
    
    return UnifiedSearchResult(
      query: query,
      taskResults: taskResults,
      projectResults: projectResults,
    );
  }
  
  /// Searches projects
  Future<ProjectSearchResult> searchProjects(
    String query, {
    SearchOptions options = const SearchOptions(),
  }) async {
    if (_projectRepository == null || query.trim().isEmpty) {
      return ProjectSearchResult.empty(query);
    }
    
    final startTime = DateTime.now();
    final allProjects = await _projectRepository.getAllProjects();
    final processedQuery = _preprocessQuery(query);
    
    final searchResults = <ScoredProjectResult>[];
    
    for (final project in allProjects) {
      final score = _calculateProjectRelevanceScore(project, processedQuery);
      if (score >= relevanceThreshold) {
        searchResults.add(ScoredProjectResult(
          project: project,
          score: score,
          matchedFields: _getProjectMatchedFields(project, processedQuery),
        ));
      }
    }
    
    searchResults.sort((a, b) => b.score.compareTo(a.score));
    final duration = DateTime.now().difference(startTime);
    
    return ProjectSearchResult(
      query: query,
      results: searchResults,
      searchDuration: duration,
    );
  }
  
  /// Generates search suggestions based on query and available data
  Future<List<SearchSuggestion>> _generateSearchSuggestions(
    String query,
    List<TaskModel> allTasks,
  ) async {
    final suggestions = <SearchSuggestion>[];
    final queryLower = query.toLowerCase();
    
    // Tag suggestions
    final allTags = <String>{};
    for (final task in allTasks) {
      allTags.addAll(task.tags.map((tag) => tag.toLowerCase()));
    }
    
    for (final tag in allTags) {
      if (tag.contains(queryLower) && tag != queryLower) {
        suggestions.add(SearchSuggestion(
          text: 'tag:$tag',
          type: SearchSuggestionType.tag,
          description: 'Search tasks with tag "$tag"',
        ));
      }
    }
    
    // Title suggestions (common task title patterns)
    final titleWords = <String>{};
    for (final task in allTasks) {
      titleWords.addAll(_extractWords(task.title));
    }
    
    for (final word in titleWords) {
      if (word.length > 3 && word.contains(queryLower) && word != queryLower) {
        suggestions.add(SearchSuggestion(
          text: word,
          type: SearchSuggestionType.title,
          description: 'Search for "$word" in task titles',
        ));
      }
    }
    
    // Status suggestions
    if ('completed'.contains(queryLower)) {
      suggestions.add(const SearchSuggestion(
        text: 'status:completed',
        type: SearchSuggestionType.filter,
        description: 'Show completed tasks',
      ));
    }
    
    if ('pending'.contains(queryLower) || 'active'.contains(queryLower)) {
      suggestions.add(const SearchSuggestion(
        text: 'status:pending',
        type: SearchSuggestionType.filter,
        description: 'Show pending tasks',
      ));
    }
    
    // Priority suggestions
    if ('urgent'.contains(queryLower) || 'high'.contains(queryLower)) {
      suggestions.add(const SearchSuggestion(
        text: 'priority:high',
        type: SearchSuggestionType.filter,
        description: 'Show high priority tasks',
      ));
    }
    
    // Date suggestions
    if ('today'.contains(queryLower)) {
      suggestions.add(const SearchSuggestion(
        text: 'due:today',
        type: SearchSuggestionType.filter,
        description: 'Show tasks due today',
      ));
    }
    
    if ('overdue'.contains(queryLower)) {
      suggestions.add(const SearchSuggestion(
        text: 'overdue:true',
        type: SearchSuggestionType.filter,
        description: 'Show overdue tasks',
      ));
    }
    
    // Sort by relevance and limit
    suggestions.sort((a, b) => a.text.length.compareTo(b.text.length));
    return suggestions.take(10).toList();
  }
  
  /// Applies basic filters to reduce search space
  List<TaskModel> _applyBasicFilters(List<TaskModel> tasks, SearchOptions options) {
    var filtered = tasks;
    
    if (options.status != null) {
      filtered = filtered.where((task) => task.status == options.status).toList();
    }
    
    if (options.priority != null) {
      filtered = filtered.where((task) => task.priority == options.priority).toList();
    }
    
    if (options.projectId != null) {
      filtered = filtered.where((task) => task.projectId == options.projectId).toList();
    }
    
    if (options.tags != null && options.tags!.isNotEmpty) {
      filtered = filtered.where((task) => 
        options.tags!.any((tag) => task.tags.contains(tag))
      ).toList();
    }
    
    if (options.dueDateFrom != null) {
      filtered = filtered.where((task) => 
        task.dueDate != null && task.dueDate!.isAfter(options.dueDateFrom!)
      ).toList();
    }
    
    if (options.dueDateTo != null) {
      filtered = filtered.where((task) => 
        task.dueDate != null && task.dueDate!.isBefore(options.dueDateTo!)
      ).toList();
    }
    
    if (options.isOverdue == true) {
      filtered = filtered.where((task) => task.isOverdue).toList();
    }
    
    return filtered;
  }
  
  /// Calculates relevance score for a task
  double _calculateTaskRelevanceScore(
    TaskModel task,
    ProcessedQuery processedQuery,
    SearchOptions options,
  ) {
    double score = 0.0;
    
    // Title matching (highest weight)
    score += _calculateFieldScore(task.title, processedQuery) * 3.0;
    
    // Description matching
    if (task.description != null) {
      score += _calculateFieldScore(task.description!, processedQuery) * 2.0;
    }
    
    // Tags matching
    for (final tag in task.tags) {
      score += _calculateFieldScore(tag, processedQuery) * 1.5;
    }
    
    // Subtask matching
    for (final subtask in task.subTasks) {
      score += _calculateFieldScore(subtask.title, processedQuery) * 1.0;
    }
    
    // Location matching
    if (task.locationTrigger != null) {
      score += _calculateFieldScore(task.locationTrigger!, processedQuery) * 0.5;
    }
    
    // Metadata matching
    for (final value in task.metadata.values) {
      if (value is String) {
        score += _calculateFieldScore(value, processedQuery) * 0.3;
      }
    }
    
    // Boost recent tasks slightly
    final daysSinceCreated = DateTime.now().difference(task.createdAt).inDays;
    if (daysSinceCreated < 7) {
      score *= 1.1;
    }
    
    // Boost active tasks
    if (!task.isCompleted) {
      score *= 1.2;
    }
    
    // Boost high priority tasks
    if (task.priority.isHighPriority) {
      score *= 1.1;
    }
    
    return score;
  }
  
  /// Calculates relevance score for a project
  double _calculateProjectRelevanceScore(
    Project project,
    ProcessedQuery processedQuery,
  ) {
    double score = 0.0;
    
    // Name matching (highest weight)
    score += _calculateFieldScore(project.name, processedQuery) * 3.0;
    
    // Description matching
    if (project.description != null) {
      score += _calculateFieldScore(project.description!, processedQuery) * 2.0;
    }
    
    return score;
  }
  
  /// Calculates score for a specific field
  double _calculateFieldScore(String fieldValue, ProcessedQuery query) {
    if (fieldValue.isEmpty) return 0.0;
    
    final fieldLower = fieldValue.toLowerCase();
    double score = 0.0;
    
    for (final term in query.terms) {
      // Exact phrase match
      if (fieldLower.contains(query.originalQuery.toLowerCase())) {
        score += 10.0;
      }
      
      // Exact term match
      if (fieldLower.contains(term)) {
        score += 5.0;
      }
      
      // Word boundary match
      final words = _extractWords(fieldLower);
      for (final word in words) {
        if (word == term) {
          score += 3.0;
        } else if (word.startsWith(term)) {
          score += 2.0;
        } else if (word.contains(term)) {
          score += 1.0;
        }
      }
      
      // Fuzzy matching for longer terms
      if (term.length >= 4) {
        for (final word in words) {
          final similarity = _calculateSimilarity(word, term);
          if (similarity > 0.7) {
            score += similarity;
          }
        }
      }
    }
    
    return score;
  }
  
  /// Preprocesses search query
  ProcessedQuery _preprocessQuery(String query) {
    final cleaned = query.trim().toLowerCase();
    final words = cleaned.split(RegExp(r'\s+'));
    final terms = words.where((word) => 
      word.isNotEmpty && !stopWords.contains(word)
    ).toList();
    
    return ProcessedQuery(
      originalQuery: query,
      cleanedQuery: cleaned,
      terms: terms,
    );
  }
  
  /// Extracts words from text
  List<String> _extractWords(String text) {
    return text.toLowerCase()
        .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
  }
  
  /// Calculates similarity between two strings using Levenshtein distance
  double _calculateSimilarity(String a, String b) {
    if (a == b) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;
    
    final maxLength = math.max(a.length, b.length);
    final distance = _levenshteinDistance(a, b);
    
    return 1.0 - (distance / maxLength);
  }
  
  /// Calculates Levenshtein distance between two strings
  int _levenshteinDistance(String a, String b) {
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    
    final matrix = List.generate(a.length + 1, 
        (i) => List.filled(b.length + 1, 0));
    
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
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce(math.min);
      }
    }
    
    return matrix[a.length][b.length];
  }
  
  /// Gets matched fields for a task
  Set<String> _getMatchedFields(TaskModel task, ProcessedQuery query) {
    final matchedFields = <String>{};
    
    if (_hasMatch(task.title, query)) matchedFields.add('title');
    if (task.description != null && _hasMatch(task.description!, query)) {
      matchedFields.add('description');
    }
    
    for (final tag in task.tags) {
      if (_hasMatch(tag, query)) {
        matchedFields.add('tags');
        break;
      }
    }
    
    for (final subtask in task.subTasks) {
      if (_hasMatch(subtask.title, query)) {
        matchedFields.add('subtasks');
        break;
      }
    }
    
    return matchedFields;
  }
  
  /// Gets matched fields for a project
  Set<String> _getProjectMatchedFields(Project project, ProcessedQuery query) {
    final matchedFields = <String>{};
    
    if (_hasMatch(project.name, query)) matchedFields.add('name');
    if (project.description != null && _hasMatch(project.description!, query)) {
      matchedFields.add('description');
    }
    
    return matchedFields;
  }
  
  /// Checks if text has a match with query
  bool _hasMatch(String text, ProcessedQuery query) {
    final textLower = text.toLowerCase();
    return query.terms.any((term) => textLower.contains(term));
  }
  
  /// Generates highlights for search results
  Map<String, String> _generateHighlights(TaskModel task, ProcessedQuery query) {
    final highlights = <String, String>{};
    
    highlights['title'] = _highlightText(task.title, query);
    
    if (task.description != null) {
      highlights['description'] = _highlightText(task.description!, query);
    }
    
    return highlights;
  }
  
  /// Highlights matching terms in text
  String _highlightText(String text, ProcessedQuery query) {
    String highlighted = text;
    
    for (final term in query.terms) {
      final regex = RegExp(term, caseSensitive: false);
      highlighted = highlighted.replaceAllMapped(regex, (match) => 
          '<mark>${match.group(0)}</mark>');
    }
    
    return highlighted;
  }
}

/// Search options for filtering and configuring search
class SearchOptions {
  final TaskStatus? status;
  final TaskPriority? priority;
  final String? projectId;
  final List<String>? tags;
  final DateTime? dueDateFrom;
  final DateTime? dueDateTo;
  final bool? isOverdue;
  final TaskSortBy sortBy;
  final bool sortAscending;
  
  const SearchOptions({
    this.status,
    this.priority,
    this.projectId,
    this.tags,
    this.dueDateFrom,
    this.dueDateTo,
    this.isOverdue,
    this.sortBy = TaskSortBy.createdAt,
    this.sortAscending = false,
  });
}

/// Processed search query
class ProcessedQuery {
  final String originalQuery;
  final String cleanedQuery;
  final List<String> terms;
  
  const ProcessedQuery({
    required this.originalQuery,
    required this.cleanedQuery,
    required this.terms,
  });
}

/// Search result for tasks
class SearchResult {
  final String query;
  final List<ScoredTaskResult> results;
  final int totalFound;
  final Duration searchDuration;
  final List<SearchSuggestion> suggestions;
  
  const SearchResult({
    required this.query,
    required this.results,
    required this.totalFound,
    required this.searchDuration,
    required this.suggestions,
  });
  
  factory SearchResult.empty(String query) => SearchResult(
    query: query,
    results: [],
    totalFound: 0,
    searchDuration: Duration.zero,
    suggestions: [],
  );
  
  bool get isEmpty => results.isEmpty;
  bool get hasResults => results.isNotEmpty;
}

/// Scored task search result
class ScoredTaskResult {
  final TaskModel task;
  final double score;
  final Set<String> matchedFields;
  final Map<String, String> highlights;
  
  const ScoredTaskResult({
    required this.task,
    required this.score,
    required this.matchedFields,
    required this.highlights,
  });
}

/// Search result for projects
class ProjectSearchResult {
  final String query;
  final List<ScoredProjectResult> results;
  final Duration searchDuration;
  
  const ProjectSearchResult({
    required this.query,
    required this.results,
    required this.searchDuration,
  });
  
  factory ProjectSearchResult.empty(String query) => ProjectSearchResult(
    query: query,
    results: [],
    searchDuration: Duration.zero,
  );
  
  bool get isEmpty => results.isEmpty;
  bool get hasResults => results.isNotEmpty;
}

/// Scored project search result
class ScoredProjectResult {
  final Project project;
  final double score;
  final Set<String> matchedFields;
  
  const ScoredProjectResult({
    required this.project,
    required this.score,
    required this.matchedFields,
  });
}

/// Unified search result containing both tasks and projects
class UnifiedSearchResult {
  final String query;
  final SearchResult taskResults;
  final ProjectSearchResult projectResults;
  
  const UnifiedSearchResult({
    required this.query,
    required this.taskResults,
    required this.projectResults,
  });
  
  bool get isEmpty => taskResults.isEmpty && projectResults.isEmpty;
  bool get hasResults => taskResults.hasResults || projectResults.hasResults;
  int get totalResults => taskResults.totalFound + projectResults.results.length;
}

/// Search suggestion
class SearchSuggestion {
  final String text;
  final SearchSuggestionType type;
  final String description;
  
  const SearchSuggestion({
    required this.text,
    required this.type,
    required this.description,
  });
}

/// Types of search suggestions
enum SearchSuggestionType {
  tag,
  title,
  filter,
  project,
}