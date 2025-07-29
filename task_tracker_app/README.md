# Task Tracker App

A voice-driven task management application built with Flutter 3.22+ that provides comprehensive task management capabilities with AI-powered task parsing and offline-first architecture.

## Features

- 🎤 Voice-driven task creation and management
- 🤖 AI-powered natural language task parsing
- 📱 Cross-platform support (Android & iOS)
- 🌙 Material 3 design with light/dark theme support
- 💾 Offline-first architecture with optional cloud sync
- 🔔 Smart notifications and reminders
- 📊 Analytics and productivity insights
- 🔒 Privacy-focused with local data processing

## Tech Stack

- **Framework**: Flutter 3.22+
- **Language**: Dart 3.3+
- **State Management**: Riverpod 3
- **UI Framework**: Material 3
- **Database**: SQLite/Drift (local storage)
- **Speech Recognition**: Whisper.cpp (local) / OpenAI Whisper API (fallback)
- **AI Integration**: OpenAI GPT-4o / Claude 3 API

## Project Structure

```
lib/
├── core/                 # Core utilities and configurations
│   ├── constants/       # App constants and routes
│   ├── errors/          # Error handling and exceptions
│   ├── theme/           # Material 3 theme configuration
│   └── utils/           # Utility functions
├── data/                # Data layer
│   ├── datasources/     # Local and remote data sources
│   ├── models/          # Data models
│   └── repositories/    # Repository implementations
├── domain/              # Business logic layer
│   ├── entities/        # Domain entities
│   ├── repositories/    # Repository interfaces
│   └── usecases/        # Business use cases
├── presentation/        # UI layer
│   ├── pages/           # App screens
│   ├── providers/       # Riverpod providers
│   └── widgets/         # Reusable UI components
└── services/            # External services
    ├── ai/              # AI integration services
    ├── database/        # Database services
    ├── notification/    # Notification services
    ├── speech/          # Speech recognition services
    └── sync/            # Cloud synchronization services
```

## Getting Started

### Prerequisites

- Flutter 3.22+ SDK
- Dart 3.3+
- Android Studio / VS Code
- Android SDK (for Android development)
- Xcode (for iOS development, macOS only)

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd task_tracker_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Development

- **Analyze code**: `flutter analyze`
- **Run tests**: `flutter test`
- **Build APK**: `flutter build apk`
- **Build iOS**: `flutter build ios`

## Architecture

The app follows a clean architecture pattern with clear separation of concerns:

- **Presentation Layer**: Flutter widgets and UI components
- **Business Logic Layer**: Riverpod providers and use cases
- **Data Layer**: Local database and external API integrations
- **Service Layer**: Platform-specific implementations

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and ensure code quality
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Development Status

This project is currently in active development. The basic foundation has been set up with:

- ✅ Flutter project structure
- ✅ Material 3 theme configuration
- ✅ Basic navigation and routing setup
- ✅ Clean architecture foundation
- ✅ Testing framework setup
- ✅ Code quality and linting configuration

Next steps involve implementing core features like task management, voice recognition, and AI integration.