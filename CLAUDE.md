# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Essential Commands

### Build & Run
- `flutter pub get` - Install dependencies
- `flutter run` - Run the app in debug mode
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app

### Code Quality
- `flutter analyze` - Run static analysis with strict linting rules
- `flutter test` - Run all unit and widget tests
- `dart run build_runner build --delete-conflicting-outputs` - Generate code for models, DAOs, and providers

### Testing
- Single test file: `flutter test test/path/to/test_file.dart`
- Test with coverage: `flutter test --coverage`
- Generate coverage report: `genhtml coverage/lcov.info -o coverage/html`
- Update golden tests: `flutter test --update-goldens`
- Performance tests: `flutter test test/performance/`
- Integration tests: `flutter test test/integration/`

## Architecture Overview

This is a Flutter task management app following Clean Architecture with these key layers:

### Core Architecture
- **Clean Architecture**: Separation between presentation, domain, and data layers
- **State Management**: Riverpod 3 for dependency injection and state management
- **Database**: SQLite with Drift ORM for local storage
- **Code Generation**: Heavy use of code generation (.g.dart files) for models, DAOs, and providers

### Key Directories
- `lib/core/` - App-wide utilities, theme, constants, and routing
- `lib/domain/` - Business entities, repository interfaces, and use cases
- `lib/data/` - Repository implementations, data models, and local data sources
- `lib/presentation/` - UI pages, widgets, and Riverpod providers
- `lib/services/` - External integrations (AI, speech, notifications, sync)

### Important Services
- **AI Integration**: Multiple AI providers (OpenAI, Claude) for task parsing
- **Speech Services**: Voice-to-text with local/remote fallback
- **Offline-First**: Local SQLite database with optional cloud sync
- **Location Services**: Geofencing and location-based tasks
- **Notifications**: Local notifications with scheduling

### Code Generation
Many files use code generation. When modifying models or DAOs, run:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Key Patterns
- Repository pattern for data access
- Provider pattern for dependency injection
- Clean separation between UI and business logic
- Extensive use of sealed classes and enums for type safety
- Material 3 design system with comprehensive theming

### Testing Strategy
- Unit tests for business logic and services
- Widget tests for UI components
- Integration tests for complete user flows
- Mock generation using Mockito for dependencies
- Performance testing with benchmarks (<50ms for AI parsing, <100ms for complex operations)
- Golden tests for UI consistency across themes

## Development Notes

### State Management
All state is managed through Riverpod providers. Business logic is kept in use cases and services, not in UI components.

### Database Schema
Uses Drift for type-safe database operations. Schema changes require code regeneration.

### AI Services
Supports multiple AI providers with fallback mechanisms. API keys should be configured in environment or settings.

### Performance Monitoring
Built-in performance monitoring service tracks app startup times and user interactions.

## Code Quality Standards

### Linting Configuration
- Strict mode enabled (no implicit casts/dynamic)
- Single quotes preferred
- Const constructors enforced
- Relative imports required
- Generated files excluded from analysis (.g.dart, .freezed.dart, .mocks.dart)

### Known Architectural Issues
**God Classes Requiring Refactoring:**
- `HomePage` (1993 lines) - Split into controller + widgets
- `RealDataExportService` (1665 lines) - Split by export format
- `AnalyticsService` (1437 lines) - Split by calculation domain
- `TaskDetailPage` (1307 lines) - Extract component widgets

### Maintenance Tasks
**Regular Cleanup Needed:**
- Backup files: `find lib/ -name "*.backup" -delete` (127 files currently)
- Unused imports: Run Flutter analyze and clean systematically
- Generated files: Re-run build_runner after model changes

### Test Coverage Requirements
- 85%+ line coverage maintained
- All new features require comprehensive test coverage
- Performance tests for operations >10ms
- Golden tests for UI changes across all themes
- Integration tests for critical user flows

## Performance Benchmarks
- AI parsing: <50ms for simple text, <500ms for complex
- Task operations: <100ms for 1000 operations
- UI rendering: <100ms for complex widgets
- Memory: No leaks under stress testing (100K operations)

## Development Workflow
1. Always run `flutter analyze` before commits
2. Generate code after model changes: `dart run build_runner build --delete-conflicting-outputs`
3. Run relevant tests: `flutter test test/domain/` for domain changes
4. Update golden tests if UI modified: `flutter test --update-goldens`
5. Clean backup files periodically to maintain clean working directory