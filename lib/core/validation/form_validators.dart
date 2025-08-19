/// Result of field validation
class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? warningMessage;
  final String? successMessage;
  final Map<String, dynamic> metadata;

  const ValidationResult({
    this.isValid = true,
    this.errorMessage,
    this.warningMessage,
    this.successMessage,
    this.metadata = const {},
  });

  ValidationResult.success({String? message, Map<String, dynamic>? metadata})
      : this(
          isValid: true,
          successMessage: message,
          metadata: metadata ?? {},
        );

  ValidationResult.error(String message, {Map<String, dynamic>? metadata})
      : this(
          isValid: false,
          errorMessage: message,
          metadata: metadata ?? {},
        );

  ValidationResult.warning(String message, {Map<String, dynamic>? metadata})
      : this(
          isValid: true,
          warningMessage: message,
          metadata: metadata ?? {},
        );

  bool get hasError => !isValid;
  bool get hasWarning => warningMessage != null;
  bool get hasSuccess => successMessage != null;
  bool get hasMessage => errorMessage != null || warningMessage != null || successMessage != null;

  String? get displayMessage => errorMessage ?? warningMessage ?? successMessage;
}

/// Base validator interface
abstract class FieldValidator {
  ValidationResult validate(String? value, Map<String, dynamic> context);
  String get fieldName;
}

/// Comprehensive form validators
class FormValidators {
  
  // MARK: - Basic Validators
  
  /// Required field validator
  static ValidationResult required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return ValidationResult.error('${fieldName ?? 'This field'} is required');
    }
    return ValidationResult.success();
  }

  /// Minimum length validator
  static ValidationResult minLength(String? value, int minLength, {String? fieldName}) {
    if (value == null || value.length < minLength) {
      return ValidationResult.error(
        '${fieldName ?? 'This field'} must be at least $minLength characters long'
      );
    }
    return ValidationResult.success();
  }

  /// Maximum length validator
  static ValidationResult maxLength(String? value, int maxLength, {String? fieldName}) {
    if (value != null && value.length > maxLength) {
      return ValidationResult.error(
        '${fieldName ?? 'This field'} cannot exceed $maxLength characters'
      );
    }
    return ValidationResult.success();
  }

  /// Length range validator
  static ValidationResult lengthRange(
    String? value, 
    int minLength, 
    int maxLength, 
    {String? fieldName}
  ) {
    if (value == null || value.isEmpty) {
      return ValidationResult.success(); // Let required validator handle this
    }
    if (value.length < minLength) {
      return ValidationResult.error(
        '${fieldName ?? 'This field'} must be at least $minLength characters'
      );
    }
    if (value.length > maxLength) {
      return ValidationResult.error(
        '${fieldName ?? 'This field'} cannot exceed $maxLength characters'
      );
    }
    return ValidationResult.success();
  }

  // MARK: - Pattern Validators

  /// Email validator
  static ValidationResult email(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return ValidationResult.success(); // Let required validator handle this
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      caseSensitive: false,
    );

    if (!emailRegex.hasMatch(value)) {
      return ValidationResult.error('Please enter a valid email address');
    }

    // Warning for common typos
    final commonTypos = ['gmail.co', 'yahoo.co', 'outlook.co', 'hotmail.co'];
    if (commonTypos.any((typo) => value.toLowerCase().contains(typo))) {
      return ValidationResult.warning('Did you mean to add "m" at the end? (e.g., gmail.com)');
    }

    return ValidationResult.success();
  }

  /// Phone number validator
  static ValidationResult phoneNumber(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return ValidationResult.success();
    }

    // Remove all non-digit characters for validation
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.length < 10) {
      return ValidationResult.error('Phone number must be at least 10 digits');
    }

    if (digitsOnly.length > 15) {
      return ValidationResult.error('Phone number cannot exceed 15 digits');
    }

    // Basic format validation (allows various formats)
    final phoneRegex = RegExp(r'^[\+]?[1-9][\d\s\-\(\)\.]{8,20}$');
    if (!phoneRegex.hasMatch(value)) {
      return ValidationResult.error('Please enter a valid phone number');
    }

    return ValidationResult.success();
  }

  /// URL validator
  static ValidationResult url(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return ValidationResult.success();
    }

    try {
      final uri = Uri.parse(value);
      if (!uri.hasScheme || (!uri.scheme.startsWith('http') && !uri.scheme.startsWith('https'))) {
        return ValidationResult.error('Please enter a valid URL (must start with http:// or https://)');
      }
      if (!uri.hasAuthority) {
        return ValidationResult.error('Please enter a complete URL');
      }
      return ValidationResult.success();
    } catch (e) {
      return ValidationResult.error('Please enter a valid URL');
    }
  }

  // MARK: - Numeric Validators

  /// Integer validator
  static ValidationResult integer(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return ValidationResult.success();
    }

    if (int.tryParse(value) == null) {
      return ValidationResult.error('${fieldName ?? 'This field'} must be a whole number');
    }

    return ValidationResult.success();
  }

  /// Decimal validator
  static ValidationResult decimal(String? value, {String? fieldName, int? decimalPlaces}) {
    if (value == null || value.isEmpty) {
      return ValidationResult.success();
    }

    if (double.tryParse(value) == null) {
      return ValidationResult.error('${fieldName ?? 'This field'} must be a valid number');
    }

    if (decimalPlaces != null) {
      final parts = value.split('.');
      if (parts.length > 1 && parts[1].length > decimalPlaces) {
        return ValidationResult.error(
          '${fieldName ?? 'This field'} cannot have more than $decimalPlaces decimal places'
        );
      }
    }

    return ValidationResult.success();
  }

  /// Number range validator
  static ValidationResult numberRange(
    String? value, 
    double min, 
    double max, 
    {String? fieldName}
  ) {
    if (value == null || value.isEmpty) {
      return ValidationResult.success();
    }

    final number = double.tryParse(value);
    if (number == null) {
      return ValidationResult.error('${fieldName ?? 'This field'} must be a valid number');
    }

    if (number < min) {
      return ValidationResult.error('${fieldName ?? 'Value'} must be at least $min');
    }

    if (number > max) {
      return ValidationResult.error('${fieldName ?? 'Value'} cannot exceed $max');
    }

    return ValidationResult.success();
  }

  /// Positive number validator
  static ValidationResult positiveNumber(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return ValidationResult.success();
    }

    final number = double.tryParse(value);
    if (number == null) {
      return ValidationResult.error('${fieldName ?? 'This field'} must be a valid number');
    }

    if (number <= 0) {
      return ValidationResult.error('${fieldName ?? 'Value'} must be greater than zero');
    }

    return ValidationResult.success();
  }

  // MARK: - Date & Time Validators

  /// Date validator
  static ValidationResult date(String? value, {String? fieldName, String? format}) {
    if (value == null || value.isEmpty) {
      return ValidationResult.success();
    }

    try {
      DateTime.parse(value);
      return ValidationResult.success();
    } catch (e) {
      return ValidationResult.error(
        'Please enter a valid date${format != null ? ' in $format format' : ''}'
      );
    }
  }

  /// Future date validator
  static ValidationResult futureDate(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return ValidationResult.success();
    }

    try {
      final date = DateTime.parse(value);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final inputDate = DateTime(date.year, date.month, date.day);

      if (inputDate.isBefore(today)) {
        return ValidationResult.error('${fieldName ?? 'Date'} must be today or in the future');
      }
      return ValidationResult.success();
    } catch (e) {
      return ValidationResult.error('Please enter a valid date');
    }
  }

  /// Past date validator
  static ValidationResult pastDate(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return ValidationResult.success();
    }

    try {
      final date = DateTime.parse(value);
      final now = DateTime.now();
      
      if (date.isAfter(now)) {
        return ValidationResult.error('${fieldName ?? 'Date'} must be in the past');
      }
      return ValidationResult.success();
    } catch (e) {
      return ValidationResult.error('Please enter a valid date');
    }
  }

  /// Date range validator
  static ValidationResult dateRange(
    String? value, 
    DateTime startDate, 
    DateTime endDate, 
    {String? fieldName}
  ) {
    if (value == null || value.isEmpty) {
      return ValidationResult.success();
    }

    try {
      final date = DateTime.parse(value);
      
      if (date.isBefore(startDate)) {
        return ValidationResult.error(
          '${fieldName ?? 'Date'} must be after ${_formatDate(startDate)}'
        );
      }

      if (date.isAfter(endDate)) {
        return ValidationResult.error(
          '${fieldName ?? 'Date'} must be before ${_formatDate(endDate)}'
        );
      }

      return ValidationResult.success();
    } catch (e) {
      return ValidationResult.error('Please enter a valid date');
    }
  }

  // MARK: - Password Validators

  /// Strong password validator
  static ValidationResult strongPassword(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return ValidationResult.success();
    }

    final errors = <String>[];
    
    if (value.length < 8) {
      errors.add('at least 8 characters');
    }
    
    if (!value.contains(RegExp(r'[A-Z]'))) {
      errors.add('one uppercase letter');
    }
    
    if (!value.contains(RegExp(r'[a-z]'))) {
      errors.add('one lowercase letter');
    }
    
    if (!value.contains(RegExp(r'[0-9]'))) {
      errors.add('one number');
    }
    
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      errors.add('one special character');
    }

    if (errors.isNotEmpty) {
      return ValidationResult.error(
        'Password must contain ${errors.join(', ')}'
      );
    }

    return ValidationResult.success();
  }

  /// Password confirmation validator
  static ValidationResult confirmPassword(
    String? value, 
    String? originalPassword, 
    {String? fieldName}
  ) {
    if (value == null || value.isEmpty) {
      return ValidationResult.success();
    }

    if (value != originalPassword) {
      return ValidationResult.error('Passwords do not match');
    }

    return ValidationResult.success();
  }

  // MARK: - Task-specific Validators

  /// Task title validator
  static ValidationResult taskTitle(String? value, {String? fieldName}) {
    final requiredResult = required(value, fieldName: 'Task title');
    if (!requiredResult.isValid) return requiredResult;

    final lengthResult = lengthRange(value, 1, 100, fieldName: 'Task title');
    if (!lengthResult.isValid) return lengthResult;

    // Check for common words that might indicate unclear tasks
    final value_ = value!.toLowerCase();
    final vagueWords = ['something', 'stuff', 'things', 'todo', 'task'];
    if (vagueWords.any((word) => value_.contains(word))) {
      return ValidationResult.warning(
        'Consider being more specific about what needs to be done'
      );
    }

    return ValidationResult.success();
  }

  /// Task description validator
  static ValidationResult taskDescription(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return ValidationResult.success();
    }

    if (value.length > 1000) {
      return ValidationResult.error('Description cannot exceed 1000 characters');
    }

    return ValidationResult.success();
  }

  /// Project name validator
  static ValidationResult projectName(String? value, {String? fieldName}) {
    final requiredResult = required(value, fieldName: 'Project name');
    if (!requiredResult.isValid) return requiredResult;

    final lengthResult = lengthRange(value, 1, 50, fieldName: 'Project name');
    if (!lengthResult.isValid) return lengthResult;

    // Check for special characters that might cause issues
    final invalidChars = RegExp(r'[<>:"/\\|?*]');
    if (invalidChars.hasMatch(value!)) {
      return ValidationResult.error(
        'Project name cannot contain special characters: < > : " / \\ | ? *'
      );
    }

    return ValidationResult.success();
  }

  /// Tag name validator
  static ValidationResult tagName(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return ValidationResult.success();
    }

    if (value.length > 20) {
      return ValidationResult.error('Tag name cannot exceed 20 characters');
    }

    if (value.contains(' ')) {
      return ValidationResult.error('Tag names cannot contain spaces');
    }

    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(value)) {
      return ValidationResult.error(
        'Tag names can only contain letters, numbers, hyphens, and underscores'
      );
    }

    return ValidationResult.success();
  }

  // MARK: - Custom Validators

  /// Custom regex validator
  static ValidationResult customPattern(
    String? value, 
    RegExp pattern, 
    String errorMessage,
    {String? fieldName}
  ) {
    if (value == null || value.isEmpty) {
      return ValidationResult.success();
    }

    if (!pattern.hasMatch(value)) {
      return ValidationResult.error(errorMessage);
    }

    return ValidationResult.success();
  }

  /// Custom function validator
  static ValidationResult custom(
    String? value,
    bool Function(String?) validator,
    String errorMessage,
    {String? fieldName}
  ) {
    if (!validator(value)) {
      return ValidationResult.error(errorMessage);
    }

    return ValidationResult.success();
  }

  /// Async custom validator
  static Future<ValidationResult> customAsync(
    String? value,
    Future<bool> Function(String?) validator,
    String errorMessage,
    {String? fieldName}
  ) async {
    if (!(await validator(value))) {
      return ValidationResult.error(errorMessage);
    }

    return ValidationResult.success();
  }

  // MARK: - Helper Methods

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Composite validator that runs multiple validators
class CompositeValidator extends FieldValidator {
  final List<FieldValidator> validators;
  final String _fieldName;
  final bool stopOnFirstError;

  CompositeValidator({
    required this.validators,
    required String fieldName,
    this.stopOnFirstError = true,
  }) : _fieldName = fieldName;

  @override
  String get fieldName => _fieldName;

  @override
  ValidationResult validate(String? value, Map<String, dynamic> context) {
    final results = <ValidationResult>[];
    
    for (final validator in validators) {
      final result = validator.validate(value, context);
      results.add(result);
      
      if (stopOnFirstError && !result.isValid) {
        return result;
      }
    }

    // Find first error
    final firstError = results.firstWhere(
      (r) => !r.isValid,
      orElse: () => ValidationResult.success(),
    );

    if (!firstError.isValid) {
      return firstError;
    }

    // Find first warning
    final firstWarning = results.firstWhere(
      (r) => r.hasWarning,
      orElse: () => ValidationResult.success(),
    );

    return firstWarning;
  }
}

/// Simple validator wrapper for function-based validation
class SimpleValidator extends FieldValidator {
  final ValidationResult Function(String?, Map<String, dynamic>) _validator;
  final String _fieldName;

  SimpleValidator(this._validator, this._fieldName);

  @override
  String get fieldName => _fieldName;

  @override
  ValidationResult validate(String? value, Map<String, dynamic> context) {
    return _validator(value, context);
  }
}

/// Validator builder for easy validator creation
class ValidatorBuilder {
  final List<FieldValidator> _validators = [];
  final String _fieldName;

  ValidatorBuilder(this._fieldName);

  ValidatorBuilder required() {
    _validators.add(SimpleValidator(
      (value, context) => FormValidators.required(value, fieldName: _fieldName),
      _fieldName,
    ));
    return this;
  }

  ValidatorBuilder minLength(int length) {
    _validators.add(SimpleValidator(
      (value, context) => FormValidators.minLength(value, length, fieldName: _fieldName),
      _fieldName,
    ));
    return this;
  }

  ValidatorBuilder maxLength(int length) {
    _validators.add(SimpleValidator(
      (value, context) => FormValidators.maxLength(value, length, fieldName: _fieldName),
      _fieldName,
    ));
    return this;
  }

  ValidatorBuilder email() {
    _validators.add(SimpleValidator(
      (value, context) => FormValidators.email(value, fieldName: _fieldName),
      _fieldName,
    ));
    return this;
  }

  ValidatorBuilder phoneNumber() {
    _validators.add(SimpleValidator(
      (value, context) => FormValidators.phoneNumber(value, fieldName: _fieldName),
      _fieldName,
    ));
    return this;
  }

  ValidatorBuilder url() {
    _validators.add(SimpleValidator(
      (value, context) => FormValidators.url(value, fieldName: _fieldName),
      _fieldName,
    ));
    return this;
  }

  ValidatorBuilder strongPassword() {
    _validators.add(SimpleValidator(
      (value, context) => FormValidators.strongPassword(value, fieldName: _fieldName),
      _fieldName,
    ));
    return this;
  }

  ValidatorBuilder custom(ValidationResult Function(String?) validator) {
    _validators.add(SimpleValidator(
      (value, context) => validator(value),
      _fieldName,
    ));
    return this;
  }

  FieldValidator build({bool stopOnFirstError = true}) {
    return CompositeValidator(
      validators: _validators,
      fieldName: _fieldName,
      stopOnFirstError: stopOnFirstError,
    );
  }
}