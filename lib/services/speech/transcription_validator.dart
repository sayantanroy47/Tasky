import 'transcription_service.dart';

/// Service for validating transcription accuracy and quality
class TranscriptionValidator {
  static const double _minConfidenceThreshold = 0.6;
  static const int _minTextLength = 3;
  static const int _maxTextLength = 1000;
  
  // Language patterns for improved validation
  static final _englishWords = <String>{
    'a', 'an', 'and', 'are', 'as', 'at', 'be', 'by', 'for', 'from',
    'has', 'he', 'in', 'is', 'it', 'its', 'of', 'on', 'that', 'the',
    'to', 'was', 'were', 'will', 'with', 'would', 'i', 'you', 'my',
    'me', 'we', 'they', 'this', 'can', 'do', 'have', 'should', 'could',
  };
  
  // Common task-related keywords for context validation
  static final _taskKeywords = <String>{
    'task', 'todo', 'remind', 'reminder', 'meeting', 'call', 'email',
    'buy', 'purchase', 'appointment', 'deadline', 'project', 'work',
    'home', 'family', 'urgent', 'important', 'today', 'tomorrow',
    'week', 'month', 'schedule', 'plan', 'complete', 'finish',
  };
  
  /// Validate transcription result quality
  static TranscriptionValidationResult validateResult(TranscriptionResult result) {
    final issues = <ValidationIssue>[];
    
    // Check if transcription was successful
    if (!result.isSuccess) {
      issues.add(ValidationIssue(
        type: ValidationIssueType.transcriptionFailed,
        message: 'Transcription failed: ${result.error?.message ?? 'Unknown error'}',
        severity: ValidationSeverity.critical,
      ));
      
      return TranscriptionValidationResult(
        isValid: false,
        confidence: 0.0,
        issues: issues,
        originalResult: result,
      );
    }
    
    // Check confidence level
    if (result.confidence < _minConfidenceThreshold) {
      issues.add(ValidationIssue(
        type: ValidationIssueType.lowConfidence,
        message: 'Low confidence score: ${result.confidence.toStringAsFixed(2)}',
        severity: ValidationSeverity.warning,
      ));
    }
    
    // Check text length
    final textLength = result.text.trim().length;
    if (textLength < _minTextLength) {
      issues.add(ValidationIssue(
        type: ValidationIssueType.textTooShort,
        message: 'Transcribed text is too short: $textLength characters',
        severity: ValidationSeverity.warning,
      ));
    } else if (textLength > _maxTextLength) {
      issues.add(ValidationIssue(
        type: ValidationIssueType.textTooLong,
        message: 'Transcribed text is too long: $textLength characters',
        severity: ValidationSeverity.warning,
      ));
    }
    
    // Check for empty or whitespace-only text
    if (result.text.trim().isEmpty) {
      issues.add(const ValidationIssue(
        type: ValidationIssueType.emptyText,
        message: 'Transcribed text is empty or contains only whitespace',
        severity: ValidationSeverity.critical,
      ));
    }
    
    // Check for suspicious patterns
    _checkSuspiciousPatterns(result.text, issues);
    
    // Check language coherence
    _checkLanguageCoherence(result.text, issues);
    
    // Check task-relevance
    _checkTaskRelevance(result.text, issues);
    
    // Check processing time (flag unusually long processing times)
    if (result.processingTime.inSeconds > 30) {
      issues.add(ValidationIssue(
        type: ValidationIssueType.slowProcessing,
        message: 'Processing took ${result.processingTime.inSeconds} seconds',
        severity: ValidationSeverity.info,
      ));
    }
    
    // Determine overall validity
    final hasCriticalIssues = issues.any((issue) => 
        issue.severity == ValidationSeverity.critical);
    
    final adjustedConfidence = _calculateAdjustedConfidence(result, issues);
    
    return TranscriptionValidationResult(
      isValid: !hasCriticalIssues && adjustedConfidence >= _minConfidenceThreshold,
      confidence: adjustedConfidence,
      issues: issues,
      originalResult: result,
    );
  }
  
  /// Compare multiple transcription results and select the best one
  static TranscriptionResult selectBestResult(List<TranscriptionResult> results) {
    if (results.isEmpty) {
      throw ArgumentError('Cannot select best result from empty list');
    }
    
    if (results.length == 1) {
      return results.first;
    }
    
    // Validate all results
    final validatedResults = results.map((result) => 
        MapEntry(result, validateResult(result))).toList();
    
    // Sort by validation score (combination of validity and confidence)
    validatedResults.sort((a, b) {
      final scoreA = _calculateValidationScore(a.value);
      final scoreB = _calculateValidationScore(b.value);
      return scoreB.compareTo(scoreA);
    });
    
    return validatedResults.first.key;
  }
  
  /// Check for suspicious patterns in transcribed text
  static void _checkSuspiciousPatterns(String text, List<ValidationIssue> issues) {
    final lowerText = text.toLowerCase();
    
    // Check for repeated characters or words
    if (_hasExcessiveRepetition(text)) {
      issues.add(const ValidationIssue(
        type: ValidationIssueType.suspiciousPattern,
        message: 'Text contains excessive repetition',
        severity: ValidationSeverity.warning,
      ));
    }
    
    // Check for common transcription errors
    final commonErrors = [
      'uh uh uh',
      'um um um',
      'er er er',
      'ah ah ah',
    ];
    
    for (final error in commonErrors) {
      if (lowerText.contains(error)) {
        issues.add(ValidationIssue(
          type: ValidationIssueType.suspiciousPattern,
          message: 'Text contains common transcription error pattern: $error',
          severity: ValidationSeverity.warning,
        ));
        break;
      }
    }
    
    // Check for non-linguistic content
    if (_containsNonLinguisticContent(text)) {
      issues.add(const ValidationIssue(
        type: ValidationIssueType.suspiciousPattern,
        message: 'Text appears to contain non-linguistic content',
        severity: ValidationSeverity.warning,
      ));
    }
  }
  
  /// Check if text has excessive repetition
  static bool _hasExcessiveRepetition(String text) {
    final words = text.toLowerCase().split(RegExp(r'\s+'));
    if (words.length < 4) return false;
    
    // Check for repeated words
    for (int i = 0; i < words.length - 2; i++) {
      if (words[i] == words[i + 1] && words[i] == words[i + 2]) {
        return true;
      }
    }
    
    // Check for repeated characters
    final charPattern = RegExp(r'(.)\1{4,}');
    return charPattern.hasMatch(text);
  }
  
  /// Check if text contains non-linguistic content
  static bool _containsNonLinguisticContent(String text) {
    // Check for excessive special characters
    final normalChars = RegExp(r'[a-zA-Z0-9\s\.,!?;:\-()]');
    final specialCharCount = text.replaceAll(normalChars, '').length;
    final totalLength = text.length;
    
    if (totalLength > 0 && specialCharCount / totalLength > 0.3) {
      return true;
    }
    
    // Check for patterns that suggest audio artifacts
    final artifactPatterns = [
      RegExp(r'\[.*?\]'), // Bracketed content
      RegExp(r'\(.*?\)'), // Parenthetical content that might be artifacts
      RegExp(r'[*]{2,}'), // Multiple asterisks
      RegExp(r'[#]{2,}'), // Multiple hash symbols
    ];
    
    for (final pattern in artifactPatterns) {
      if (pattern.hasMatch(text)) {
        return true;
      }
    }
    
    return false;
  }
  
  /// Check language coherence and word recognition accuracy
  static void _checkLanguageCoherence(String text, List<ValidationIssue> issues) {
    final words = text.toLowerCase().split(RegExp(r'\s+'));
    if (words.length < 3) return; // Skip for very short text
    
    // Count recognizable English words
    int recognizedWords = 0;
    for (final word in words) {
      final cleanWord = word.replaceAll(RegExp(r'[^\w]'), '');
      if (_englishWords.contains(cleanWord) || cleanWord.length >= 4) {
        recognizedWords++;
      }
    }
    
    final recognitionRate = recognizedWords / words.length;
    
    if (recognitionRate < 0.3) {
      issues.add(ValidationIssue(
        type: ValidationIssueType.lowLanguageCoherence,
        message: 'Low language recognition rate: ${(recognitionRate * 100).toStringAsFixed(1)}%',
        severity: ValidationSeverity.warning,
      ));
    }
    
    // Check for grammatical patterns
    if (!_hasBasicGrammarPatterns(text)) {
      issues.add(const ValidationIssue(
        type: ValidationIssueType.grammarIssues,
        message: 'Text lacks basic grammatical structure',
        severity: ValidationSeverity.warning,
      ));
    }
  }
  
  /// Check if text is relevant for task creation
  static void _checkTaskRelevance(String text, List<ValidationIssue> issues) {
    final lowerText = text.toLowerCase();
    final words = lowerText.split(RegExp(r'\s+'));
    
    // Check for task-relevant keywords
    bool hasTaskKeywords = false;
    for (final keyword in _taskKeywords) {
      if (lowerText.contains(keyword)) {
        hasTaskKeywords = true;
        break;
      }
    }
    
    // Check for action verbs
    final actionVerbs = {
      'do', 'make', 'create', 'call', 'email', 'buy', 'get', 'go', 'visit',
      'complete', 'finish', 'start', 'schedule', 'plan', 'organize', 'prepare',
      'review', 'check', 'update', 'send', 'write', 'read', 'meet', 'discuss',
    };
    
    bool hasActionVerbs = false;
    for (final word in words) {
      if (actionVerbs.contains(word)) {
        hasActionVerbs = true;
        break;
      }
    }
    
    if (!hasTaskKeywords && !hasActionVerbs && words.length > 5) {
      issues.add(const ValidationIssue(
        type: ValidationIssueType.lowTaskRelevance,
        message: 'Text may not be relevant for task creation',
        severity: ValidationSeverity.info,
      ));
    }
  }
  
  /// Check for basic grammar patterns
  static bool _hasBasicGrammarPatterns(String text) {
    final lowerText = text.toLowerCase();
    
    // Check for basic sentence structure indicators
    final grammarIndicators = [
      RegExp(r'\b(i|you|we|they|he|she|it)\s+\w+'), // Subject-verb patterns
      RegExp(r'\b(the|a|an)\s+\w+'), // Article-noun patterns
      RegExp(r'\b\w+ing\b'), // Present participle
      RegExp(r'\b\w+ed\b'), // Past tense
      RegExp(r'\b(is|are|was|were|will|would|can|should|could)\b'), // Auxiliary verbs
    ];
    
    int patternMatches = 0;
    for (final pattern in grammarIndicators) {
      if (pattern.hasMatch(lowerText)) {
        patternMatches++;
      }
    }
    
    return patternMatches >= 2 || text.split(RegExp(r'\s+')).length < 6;
  }
  
  /// Perform cross-validation between multiple transcription attempts
  static TranscriptionValidationResult crossValidateResults(
    List<TranscriptionResult> results,
  ) {
    if (results.isEmpty) {
      throw ArgumentError('Cannot cross-validate empty results list');
    }
    
    if (results.length == 1) {
      return validateResult(results.first);
    }
    
    // Find common elements between transcriptions
    final texts = results.map((r) => r.text.toLowerCase()).toList();
    final commonWords = _findCommonWords(texts);
    final averageConfidence = results.map((r) => r.confidence).reduce((a, b) => a + b) / results.length;
    
    // Select the result with highest confidence that contains most common words
    TranscriptionResult bestResult = results.first;
    double bestScore = 0.0;
    
    for (final result in results) {
      final commonWordsInResult = _countCommonWords(result.text.toLowerCase(), commonWords);
      final score = result.confidence * 0.7 + (commonWordsInResult / commonWords.length) * 0.3;
      
      if (score > bestScore) {
        bestScore = score;
        bestResult = result;
      }
    }
    
    // Validate the best result and add cross-validation metadata
    final validation = validateResult(bestResult);
    
    // Add cross-validation insights
    final crossValidationIssues = <ValidationIssue>[];
    
    if (commonWords.length < 3 && results.length > 2) {
      crossValidationIssues.add(const ValidationIssue(
        type: ValidationIssueType.lowConsistency,
        message: 'Low consistency between multiple transcription attempts',
        severity: ValidationSeverity.warning,
      ));
    }
    
    return TranscriptionValidationResult(
      isValid: validation.isValid,
      confidence: (validation.confidence + averageConfidence) / 2,
      issues: [...validation.issues, ...crossValidationIssues],
      originalResult: bestResult,
    );
  }
  
  /// Find words that appear in multiple transcriptions
  static Set<String> _findCommonWords(List<String> texts) {
    if (texts.isEmpty) return <String>{};
    
    final wordCounts = <String, int>{};
    
    for (final text in texts) {
      final words = text.split(RegExp(r'\s+'));
      final uniqueWords = words.toSet();
      
      for (final word in uniqueWords) {
        wordCounts[word] = (wordCounts[word] ?? 0) + 1;
      }
    }
    
    // Return words that appear in at least half of the transcriptions
    final threshold = (texts.length / 2).ceil();
    return wordCounts.entries
        .where((entry) => entry.value >= threshold)
        .map((entry) => entry.key)
        .toSet();
  }
  
  /// Count how many common words appear in a text
  static int _countCommonWords(String text, Set<String> commonWords) {
    final words = text.split(RegExp(r'\s+'));
    return words.where((word) => commonWords.contains(word)).length;
  }
  
  /// Calculate adjusted confidence based on validation issues
  static double _calculateAdjustedConfidence(
    TranscriptionResult result, 
    List<ValidationIssue> issues,
  ) {
    double confidence = result.confidence;
    
    // Reduce confidence based on issues
    for (final issue in issues) {
      switch (issue.severity) {
        case ValidationSeverity.critical:
          confidence *= 0.1; // Severely reduce confidence
          break;
        case ValidationSeverity.warning:
          confidence *= 0.8; // Moderately reduce confidence
          break;
        case ValidationSeverity.info:
          confidence *= 0.95; // Slightly reduce confidence
          break;
      }
    }
    
    return confidence.clamp(0.0, 1.0);
  }
  
  /// Calculate overall validation score
  static double _calculateValidationScore(TranscriptionValidationResult validation) {
    double score = validation.confidence;
    
    // Bonus for valid results
    if (validation.isValid) {
      score *= 1.2;
    }
    
    // Penalty for issues
    final criticalIssues = validation.issues.where((i) => 
        i.severity == ValidationSeverity.critical).length;
    final warningIssues = validation.issues.where((i) => 
        i.severity == ValidationSeverity.warning).length;
    
    score -= (criticalIssues * 0.5) + (warningIssues * 0.1);
    
    return score.clamp(0.0, 1.0);
  }
}

/// Result of transcription validation
class TranscriptionValidationResult {
  final bool isValid;
  final double confidence;
  final List<ValidationIssue> issues;
  final TranscriptionResult originalResult;

  const TranscriptionValidationResult({
    required this.isValid,
    required this.confidence,
    required this.issues,
    required this.originalResult,
  });

  /// Get issues by severity
  List<ValidationIssue> getIssuesBySeverity(ValidationSeverity severity) {
    return issues.where((issue) => issue.severity == severity).toList();
  }

  /// Check if validation has any critical issues
  bool get hasCriticalIssues => 
      issues.any((issue) => issue.severity == ValidationSeverity.critical);

  /// Get a summary of validation issues
  String get issuesSummary {
    if (issues.isEmpty) return 'No issues found';
    
    final criticalCount = getIssuesBySeverity(ValidationSeverity.critical).length;
    final warningCount = getIssuesBySeverity(ValidationSeverity.warning).length;
    final infoCount = getIssuesBySeverity(ValidationSeverity.info).length;
    
    final parts = <String>[];
    if (criticalCount > 0) parts.add('$criticalCount critical');
    if (warningCount > 0) parts.add('$warningCount warning');
    if (infoCount > 0) parts.add('$infoCount info');
    
    return parts.join(', ');
  }  @override
  String toString() {
    return 'TranscriptionValidationResult(valid: $isValid, confidence: ${confidence.toStringAsFixed(2)}, issues: ${issues.length})';
  }
}

/// Individual validation issue
class ValidationIssue {
  final ValidationIssueType type;
  final String message;
  final ValidationSeverity severity;

  const ValidationIssue({
    required this.type,
    required this.message,
    required this.severity,
  });  @override
  String toString() {
    return 'ValidationIssue(${severity.name}: $message)';
  }
}

/// Types of validation issues
enum ValidationIssueType {
  transcriptionFailed,
  lowConfidence,
  textTooShort,
  textTooLong,
  emptyText,
  suspiciousPattern,
  slowProcessing,
  lowLanguageCoherence,
  grammarIssues,
  lowTaskRelevance,
  lowConsistency,
}

/// Severity levels for validation issues
enum ValidationSeverity {
  info,
  warning,
  critical,
}
