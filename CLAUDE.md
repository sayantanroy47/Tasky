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
- `build_runner` used for code generation: `flutter packages pub run build_runner build`

### Testing
- Single test file: `flutter test test/path/to/test_file.dart`
- Test coverage: Tests are organized by layer (unit, widget, integration)

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
flutter packages pub run build_runner build --delete-conflicting-outputs
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

## Development Notes

### State Management
All state is managed through Riverpod providers. Business logic is kept in use cases and services, not in UI components.

### Database Schema
Uses Drift for type-safe database operations. Schema changes require code regeneration.

### AI Services
Supports multiple AI providers with fallback mechanisms. API keys should be configured in environment or settings.

### Performance Monitoring
Built-in performance monitoring service tracks app startup times and user interactions.