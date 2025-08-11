/// AI Service Type enumeration
/// Shared across all AI-related services to avoid conflicts
enum AIServiceType {
  openai,
  claude,
  local;
  
  String get displayName {
    switch (this) {
      case AIServiceType.openai:
        return 'OpenAI';
      case AIServiceType.claude:
        return 'Claude';
      case AIServiceType.local:
        return 'Local';
    }
  }
  
  String get description {
    switch (this) {
      case AIServiceType.openai:
        return 'OpenAI GPT models for task parsing';
      case AIServiceType.claude:
        return 'Anthropic Claude models for task parsing';
      case AIServiceType.local:
        return 'Local AI processing (offline)';
    }
  }
}