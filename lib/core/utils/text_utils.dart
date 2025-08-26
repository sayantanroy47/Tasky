/// Utilities for text formatting and manipulation
class TextUtils {
  /// Private constructor to prevent instantiation
  TextUtils._();

  /// Capitalizes the first letter of each word in the string
  /// Example: "hello world" -> "Hello World"
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    
    return text
        .split(' ')
        .map((word) => word.isEmpty ? word : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  /// Capitalizes only the first letter of the string
  /// Example: "hello world" -> "Hello world"
  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Auto-capitalizes text based on content type and length
  /// For titles and names, capitalizes each word
  /// Preserves existing capitalization if it seems intentional (mixed case)
  static String autoCapitalize(String text) {
    if (text.isEmpty) return text;
    
    // If the text has mixed case already, preserve it
    final hasUpperCase = text.contains(RegExp(r'[A-Z]'));
    final hasLowerCase = text.contains(RegExp(r'[a-z]'));
    
    if (hasUpperCase && hasLowerCase) {
      // Mixed case detected, preserve existing capitalization
      return text;
    }
    
    // If all lowercase or all uppercase, apply title case
    if (text == text.toLowerCase() || text == text.toUpperCase()) {
      return capitalizeWords(text);
    }
    
    return text;
  }
}