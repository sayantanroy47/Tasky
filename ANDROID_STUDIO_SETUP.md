# 🤖 Android Studio Configuration Guide

## Prerequisites

### Required Software
- **Android Studio**: Latest version (Hedgehog or newer)
- **Flutter SDK**: 3.22.0 or higher
- **Dart SDK**: Included with Flutter
- **Java JDK**: 17 (configured in project)

### Android Studio Plugins
1. **Flutter Plugin** (includes Dart)
2. **Kotlin Plugin** (usually pre-installed)

## 📱 Project Setup in Android Studio

### 1. Open Project
```bash
# Option 1: Open existing project
File → Open → Select D:\Github\Tasky folder

# Option 2: Import from VCS
File → New → Project from Version Control
```

### 2. Flutter SDK Configuration
```bash
File → Settings → Languages & Frameworks → Flutter
- Set Flutter SDK path (e.g., C:\src\flutter)
- Verify Dart SDK is auto-detected
```

### 3. Android SDK Setup
```bash
File → Settings → Appearance & Behavior → System Settings → Android SDK
- API Level 24 (minimum) ✅
- API Level 35 (target) ✅
- Android SDK Build-Tools
- Android SDK Platform-Tools
```

## 🔧 Build Configuration

### Gradle Configuration
The project is pre-configured with:
- **Kotlin DSL** (build.gradle.kts)
- **Java 17** compatibility
- **Minimum SDK**: 24 (Android 7.0)
- **Target SDK**: 35 (Android 14)
- **NDK Version**: 27.0.12077973

### Key Configuration Files
```
android/
├── app/
│   ├── build.gradle.kts      # App-level build config
│   └── src/main/
│       ├── AndroidManifest.xml
│       └── kotlin/com/tasktracker/task_tracker_app/
├── build.gradle.kts          # Project-level build config
├── gradle.properties         # Gradle properties
└── settings.gradle.kts       # Gradle settings
```

## 🚀 Running the App

### Debug Mode
```bash
# Terminal in Android Studio
flutter run

# Or use Run Configuration:
Run → Run 'main.dart'
```

### Release Mode
```bash
flutter run --release
```

### Build APK
```bash
flutter build apk --release
```

## 📋 Run Configurations

### Create Run Configuration
1. **Run → Edit Configurations**
2. **Add New → Flutter**
3. Configure:
   - **Name**: Task Tracker Debug
   - **Dart entrypoint**: lib/main.dart
   - **Build flavor**: debug
   - **Additional arguments**: --hot

### Debug Configuration
- **Hot Reload**: ✅ Enabled by default
- **Hot Restart**: ✅ Available
- **Debug Console**: ✅ Shows Flutter logs

## 🛠️ Development Setup

### Enable Developer Options
```bash
# In Android Studio Terminal
flutter doctor -v    # Check Flutter installation
flutter devices      # List available devices
```

### Android Device/Emulator
1. **Physical Device**:
   - Enable Developer Options
   - Enable USB Debugging
   - Connect via USB

2. **Emulator**:
   - AVD Manager → Create Virtual Device
   - Recommended: Pixel 6 API 35

### iOS Setup (if needed)
```bash
# macOS only
flutter doctor --android-licenses  # Accept Android licenses
```

## 🎯 Project Structure in Android Studio

### Key Directories
```
Tasky/
├── lib/                     # Flutter source code
│   ├── main.dart           # App entry point
│   ├── core/               # Core utilities & themes
│   ├── data/               # Data layer (repositories, models)
│   ├── domain/             # Business logic (entities, use cases)
│   ├── presentation/       # UI layer (pages, widgets, providers)
│   └── services/           # External services
├── android/                # Android-specific code
├── test/                   # Unit & widget tests
├── integration_test/       # Integration tests
└── assets/                 # Images, fonts, etc.
```

## 🔍 Debugging & Testing

### Debug Tools
- **Flutter Inspector**: View widget tree
- **Network Inspector**: Monitor HTTP requests
- **Timeline**: Performance profiling
- **Memory**: Memory usage analysis

### Running Tests
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Specific test file
flutter test test/domain/entities/task_model_test.dart
```

### Hot Reload Tips
- **r**: Hot reload
- **R**: Hot restart
- **q**: Quit
- **h**: Help

## 📦 Dependency Management

### Adding Dependencies
```yaml
# In pubspec.yaml
dependencies:
  new_package: ^1.0.0

# Then run:
flutter pub get
```

### Code Generation
```bash
# Generate code for json_serializable, drift, etc.
flutter packages pub run build_runner build

# Watch for changes
flutter packages pub run build_runner watch
```

## 🎨 UI Development

### Material Design 3
- **Theme**: Pre-configured in `lib/core/theme/`
- **Colors**: Custom color scheme
- **Typography**: Material 3 text styles
- **Components**: Modern Material widgets

### Widget Development
- **Stateless/Stateful**: Traditional Flutter widgets
- **ConsumerWidget**: Riverpod state management
- **Hot Reload**: Real-time UI updates

## 🐛 Troubleshooting

### Common Issues

#### 1. SDK Path Issues
```bash
flutter config --android-sdk /path/to/android/sdk
flutter doctor --android-licenses
```

#### 2. Gradle Sync Issues
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

#### 3. Plugin Issues
```bash
flutter clean
flutter pub get
flutter pub deps
```

#### 4. Hot Reload Not Working
- Save the file (Ctrl+S)
- Ensure no syntax errors
- Try hot restart (R)

### Performance Optimization
```bash
# Profile mode
flutter run --profile

# Release mode
flutter run --release

# Analyze bundle size
flutter build apk --analyze-size
```

## 📱 Device Testing

### Multiple Devices
```yaml
# Test on different screen sizes
- Phone: Pixel 6 (411x891 dp)
- Tablet: Pixel Tablet (1280x800 dp)
- Foldable: Pixel Fold (673x841 dp)
```

### Platform Testing
- **Android 7.0** (API 24) - Minimum
- **Android 14** (API 35) - Target
- **Different OEMs**: Samsung, OnePlus, etc.

## 🔐 Release Configuration

### Signing Configuration
```bash
# Generate keystore
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Configure in android/key.properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-keystore>
```

### Build Release APK
```bash
flutter build apk --release --target-platform android-arm64
```

## 📋 Development Checklist

### Before Building
- [ ] All tests passing (`flutter test`)
- [ ] No linting errors (`flutter analyze`)
- [ ] Dependencies updated (`flutter pub deps`)
- [ ] Code generation complete (`build_runner`)

### Release Checklist
- [ ] Version updated in `pubspec.yaml`
- [ ] Signing configuration set
- [ ] ProGuard/R8 tested
- [ ] All permissions documented
- [ ] Privacy policy updated

## 🎯 Next Steps

1. **Open project in Android Studio**
2. **Configure Flutter SDK path**
3. **Run `flutter doctor`** to verify setup
4. **Connect device/start emulator**
5. **Run the app** with `flutter run`
6. **Explore the codebase** starting with `lib/main.dart`

## 📞 Support

### Useful Commands
- `flutter doctor`: Check setup
- `flutter devices`: List devices
- `flutter clean`: Clean build cache
- `flutter pub get`: Install dependencies
- `flutter analyze`: Static analysis
- `flutter test`: Run tests

### Documentation
- [Flutter Documentation](https://flutter.dev/docs)
- [Android Studio Guide](https://developer.android.com/studio/intro)
- [Dart Language](https://dart.dev/guides)

**Happy coding! 🚀**