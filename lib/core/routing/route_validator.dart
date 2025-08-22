import 'package:flutter/material.dart';
import '../errors/app_exceptions.dart';

/// Route parameter validation result
class RouteValidationResult {
  final bool isValid;
  final String? errorMessage;
  final Map<String, dynamic>? validatedParams;

  const RouteValidationResult({
    required this.isValid,
    this.errorMessage,
    this.validatedParams,
  });

  factory RouteValidationResult.success(Map<String, dynamic> params) {
    return RouteValidationResult(
      isValid: true,
      validatedParams: params,
    );
  }

  factory RouteValidationResult.failure(String message) {
    return RouteValidationResult(
      isValid: false,
      errorMessage: message,
    );
  }
}

/// Route parameter validator
class RouteValidator {
  /// Validate task ID parameter
  static RouteValidationResult validateTaskId(Object? argument) {
    if (argument == null) {
      return RouteValidationResult.failure('Task ID is required');
    }

    if (argument is! String) {
      return RouteValidationResult.failure('Task ID must be a string');
    }

    final taskId = argument;
    if (taskId.isEmpty) {
      return RouteValidationResult.failure('Task ID cannot be empty');
    }

    // Validate UUID format (relaxed validation for debugging)
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'
    );
    
    // Temporarily relax validation to allow more ID formats for debugging
    if (taskId.length < 5) { // Only reject very short IDs
      return RouteValidationResult.failure('Task ID too short');
    }
    
    // Log the actual taskId for debugging
    debugPrint('🔍 RouteValidator: Validating taskId: $taskId');
    debugPrint('🔍 RouteValidator: Matches UUID: ${uuidRegex.hasMatch(taskId)}');
    debugPrint('🔍 RouteValidator: Starts with temp_: ${taskId.startsWith('temp_')}');

    return RouteValidationResult.success({'taskId': taskId});
  }

  /// Validate project ID parameter
  static RouteValidationResult validateProjectId(Object? argument) {
    if (argument == null) {
      return RouteValidationResult.failure('Project ID is required');
    }

    if (argument is! String) {
      return RouteValidationResult.failure('Project ID must be a string');
    }

    final projectId = argument;
    if (projectId.isEmpty) {
      return RouteValidationResult.failure('Project ID cannot be empty');
    }

    // Validate UUID format (basic validation)
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'
    );
    
    if (!uuidRegex.hasMatch(projectId) && !projectId.startsWith('temp_')) {
      return RouteValidationResult.failure('Invalid project ID format');
    }

    return RouteValidationResult.success({'projectId': projectId});
  }

  /// Validate navigation index parameter
  static RouteValidationResult validateNavigationIndex(Object? argument) {
    if (argument == null) {
      return RouteValidationResult.success({'index': 0}); // Default to home
    }

    int index;
    if (argument is int) {
      index = argument;
    } else if (argument is String) {
      try {
        index = int.parse(argument);
      } catch (e) {
        return RouteValidationResult.failure('Navigation index must be a valid integer');
      }
    } else {
      return RouteValidationResult.failure('Navigation index must be an integer or string');
    }

    if (index < 0 || index > 3) { // Assuming 4 navigation items (0-3)
      return RouteValidationResult.failure('Navigation index must be between 0 and 3');
    }

    return RouteValidationResult.success({'index': index});
  }

  /// Validate export format parameter
  static RouteValidationResult validateExportFormat(Object? argument) {
    if (argument == null) {
      return RouteValidationResult.success({'format': 'json'}); // Default format
    }

    if (argument is! String) {
      return RouteValidationResult.failure('Export format must be a string');
    }

    final format = argument.toString().toLowerCase();
    const validFormats = ['json', 'csv', 'xlsx', 'pdf'];
    
    if (!validFormats.contains(format)) {
      return RouteValidationResult.failure(
        'Invalid export format. Valid formats: ${validFormats.join(', ')}'
      );
    }

    return RouteValidationResult.success({'format': format});
  }

  /// Validate date range parameters
  static RouteValidationResult validateDateRange(Object? argument) {
    if (argument == null) {
      return RouteValidationResult.success({
        'startDate': DateTime.now().subtract(const Duration(days: 30)),
        'endDate': DateTime.now(),
      });
    }

    if (argument is! Map<String, dynamic>) {
      return RouteValidationResult.failure('Date range must be a map with startDate and endDate');
    }

    final params = argument;
    
    try {
      final startDate = params['startDate'] != null 
          ? DateTime.parse(params['startDate'].toString())
          : DateTime.now().subtract(const Duration(days: 30));
          
      final endDate = params['endDate'] != null 
          ? DateTime.parse(params['endDate'].toString())
          : DateTime.now();

      if (startDate.isAfter(endDate)) {
        return RouteValidationResult.failure('Start date cannot be after end date');
      }

      final daysDifference = endDate.difference(startDate).inDays;
      if (daysDifference > 365) {
        return RouteValidationResult.failure('Date range cannot exceed 365 days');
      }

      return RouteValidationResult.success({
        'startDate': startDate,
        'endDate': endDate,
      });
    } catch (e) {
      return RouteValidationResult.failure('Invalid date format. Use ISO 8601 format (YYYY-MM-DD)');
    }
  }

  /// Validate search query parameters
  static RouteValidationResult validateSearchQuery(Object? argument) {
    if (argument == null) {
      return RouteValidationResult.success({'query': ''}); // Empty search
    }

    if (argument is! Map<String, dynamic>) {
      // If it's a simple string, treat it as query
      if (argument is String) {
        final query = argument.trim();
        if (query.length > 100) {
          return RouteValidationResult.failure('Search query cannot exceed 100 characters');
        }
        return RouteValidationResult.success({'query': query});
      }
      return RouteValidationResult.failure('Search parameters must be a map or string');
    }

    final params = argument;
    final query = (params['query'] ?? '').toString().trim();
    final category = params['category']?.toString();
    final priority = params['priority']?.toString();

    if (query.length > 100) {
      return RouteValidationResult.failure('Search query cannot exceed 100 characters');
    }

    // Validate category if provided
    if (category != null && category.isNotEmpty) {
      const validCategories = ['work', 'personal', 'shopping', 'health', 'education', 'other'];
      if (!validCategories.contains(category.toLowerCase())) {
        return RouteValidationResult.failure(
          'Invalid category. Valid categories: ${validCategories.join(', ')}'
        );
      }
    }

    // Validate priority if provided
    if (priority != null && priority.isNotEmpty) {
      const validPriorities = ['low', 'medium', 'high', 'urgent'];
      if (!validPriorities.contains(priority.toLowerCase())) {
        return RouteValidationResult.failure(
          'Invalid priority. Valid priorities: ${validPriorities.join(', ')}'
        );
      }
    }

    return RouteValidationResult.success({
      'query': query,
      'category': category?.toLowerCase(),
      'priority': priority?.toLowerCase(),
    });
  }

  /// Validate theme parameters
  static RouteValidationResult validateThemeParams(Object? argument) {
    if (argument == null) {
      return RouteValidationResult.success({'themeId': null});
    }

    if (argument is! Map<String, dynamic>) {
      // If it's a simple string, treat it as themeId
      if (argument is String) {
        return _validateThemeId(argument);
      }
      return RouteValidationResult.failure('Theme parameters must be a map or string');
    }

    final params = argument;
    final themeId = params['themeId']?.toString();
    final preview = params['preview'] == true;

    if (themeId != null) {
      final themeValidation = _validateThemeId(themeId);
      if (!themeValidation.isValid) {
        return themeValidation;
      }
    }

    return RouteValidationResult.success({
      'themeId': themeId,
      'preview': preview,
    });
  }

  /// Validate theme ID format
  static RouteValidationResult _validateThemeId(String themeId) {
    if (themeId.isEmpty) {
      return RouteValidationResult.failure('Theme ID cannot be empty');
    }

    // Basic format validation for theme IDs
    final validThemePattern = RegExp(r'^[a-z][a-z0-9_]*[a-z0-9]$');
    if (!validThemePattern.hasMatch(themeId) && themeId != 'default') {
      return RouteValidationResult.failure(
        'Invalid theme ID format. Theme IDs must contain only lowercase letters, numbers, and underscores'
      );
    }

    return RouteValidationResult.success({'themeId': themeId});
  }

  /// Validate pagination parameters
  static RouteValidationResult validatePaginationParams(Object? argument) {
    if (argument == null) {
      return RouteValidationResult.success({
        'page': 1,
        'limit': 20,
      });
    }

    if (argument is! Map<String, dynamic>) {
      return RouteValidationResult.failure('Pagination parameters must be a map');
    }

    final params = argument;
    
    int page = 1;
    int limit = 20;

    // Validate page
    if (params['page'] != null) {
      try {
        page = int.parse(params['page'].toString());
        if (page < 1) {
          return RouteValidationResult.failure('Page number must be greater than 0');
        }
        if (page > 1000) {
          return RouteValidationResult.failure('Page number cannot exceed 1000');
        }
      } catch (e) {
        return RouteValidationResult.failure('Page must be a valid integer');
      }
    }

    // Validate limit
    if (params['limit'] != null) {
      try {
        limit = int.parse(params['limit'].toString());
        if (limit < 1) {
          return RouteValidationResult.failure('Limit must be greater than 0');
        }
        if (limit > 100) {
          return RouteValidationResult.failure('Limit cannot exceed 100');
        }
      } catch (e) {
        return RouteValidationResult.failure('Limit must be a valid integer');
      }
    }

    return RouteValidationResult.success({
      'page': page,
      'limit': limit,
      'offset': (page - 1) * limit,
    });
  }

  /// Validate generic ID parameter
  static RouteValidationResult validateId(Object? argument, String paramName) {
    if (argument == null) {
      return RouteValidationResult.failure('$paramName is required');
    }

    if (argument is! String) {
      return RouteValidationResult.failure('$paramName must be a string');
    }

    final id = argument;
    if (id.isEmpty) {
      return RouteValidationResult.failure('$paramName cannot be empty');
    }

    return RouteValidationResult.success({paramName: id});
  }

  /// Validate multiple parameters at once
  static RouteValidationResult validateMultiple(
    Map<String, dynamic> validators,
    Map<String, dynamic>? arguments,
  ) {
    final results = <String, dynamic>{};

    for (final entry in validators.entries) {
      final paramName = entry.key;
      final validator = entry.value as RouteValidationResult Function(Object?);
      
      final argument = arguments?[paramName];
      final result = validator(argument);
      
      if (!result.isValid) {
        return RouteValidationResult.failure('$paramName: ${result.errorMessage}');
      }
      
      if (result.validatedParams != null) {
        results.addAll(result.validatedParams!);
      }
    }

    return RouteValidationResult.success(results);
  }
}

/// Extension for easy route validation in router
extension RouteSettingsValidation on RouteSettings {
  /// Validate arguments with a validator function
  RouteValidationResult validate(RouteValidationResult Function(Object?) validator) {
    return validator(arguments);
  }

  /// Get validated arguments or throw exception
  T getValidatedArguments<T>(RouteValidationResult Function(Object?) validator) {
    final result = validate(validator);
    if (!result.isValid) {
      throw ValidationException(
        result.errorMessage ?? 'Route validation failed',
        code: 'ROUTE_VALIDATION_ERROR',
      );
    }
    return result.validatedParams as T;
  }
}