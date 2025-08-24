import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

/// Helper utilities for golden tests
class GoldenTestHelper {
  /// Load fonts required for golden tests
  static Future<void> loadAppFonts() async {
    await loadAppFonts();
  }

  /// Configure golden test environment
  static void configureGoldenTests() {
    // Configure golden toolkit for consistent rendering
    GoldenToolkit.configure(
      GoldenToolkitConfiguration(
        enableRealShadows: true,
        skipGoldenAssertion: () => false,
      ),
    );
  }

  /// Standard device configurations for responsive testing
  static const List<Device> testDevices = [
    Device.phone,
    Device.iphone11,
    Device.tabletPortrait,
    Device.tabletLandscape,
  ];

  /// Standard surface sizes for different test scenarios
  static const Map<String, Size> standardSizes = {
    'mobile': Size(320, 568),
    'mobileLarge': Size(414, 896),
    'tablet': Size(768, 1024),
    'desktop': Size(1200, 800),
    'card': Size(400, 200),
    'dialog': Size(400, 600),
    'fullScreen': Size(400, 800),
  };

  /// Create a test description based on theme and component
  static String createTestName(String component, String themeId, [String? variant]) {
    final parts = [component, themeId.toLowerCase()];
    if (variant != null) {
      parts.add(variant);
    }
    return parts.join('_');
  }

  /// Pump widget with standard delays for animations
  static Future<void> pumpWidgetWithSettling(
    WidgetTester tester,
    Widget widget, {
    Duration? duration,
  }) async {
    await tester.pumpWidget(widget);
    
    // Allow time for animations to complete
    await tester.pumpAndSettle(duration ?? const Duration(milliseconds: 100));
    
    // Additional pump for any lingering animations
    await tester.pump(const Duration(milliseconds: 16));
  }

  /// Standard wrapper for consistent test setup
  static Widget createTestWrapper({
    required Widget child,
    required ThemeData theme,
    bool useScaffold = true,
    Color? backgroundColor,
  }) {
    Widget wrappedChild = child;
    
    if (useScaffold) {
      wrappedChild = Scaffold(
        backgroundColor: backgroundColor ?? theme.colorScheme.surface,
        body: child,
      );
    }

    return MaterialApp(
      theme: theme,
      home: wrappedChild,
      debugShowCheckedModeBanner: false,
    );
  }

  /// Generate responsive test configurations
  static List<Map<String, dynamic>> generateResponsiveConfigs() {
    return [
      {
        'name': 'mobile',
        'size': standardSizes['mobile']!,
        'description': 'Mobile portrait layout',
      },
      {
        'name': 'mobile_large',
        'size': standardSizes['mobileLarge']!,
        'description': 'Large mobile layout',
      },
      {
        'name': 'tablet',
        'size': standardSizes['tablet']!,
        'description': 'Tablet layout',
      },
      {
        'name': 'desktop',
        'size': standardSizes['desktop']!,
        'description': 'Desktop layout',
      },
    ];
  }

  /// Wait for images to load in golden tests
  static Future<void> waitForImages(WidgetTester tester) async {
    // Allow time for image loading
    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 100));
    });
    
    await tester.pumpAndSettle();
  }

  /// Verify golden file matches with better error messages
  static Future<void> verifyGolden(
    WidgetTester tester,
    String goldenPath, {
    String? reason,
  }) async {
    try {
      await screenMatchesGolden(tester, goldenPath);
    } catch (e) {
      final message = reason != null
          ? 'Golden test failed for $goldenPath: $reason\nError: $e'
          : 'Golden test failed for $goldenPath: $e';
      
      throw TestFailure(message);
    }
  }

  /// Create consistent test variants for accessibility
  static List<Map<String, dynamic>> getAccessibilityVariants() {
    return [
      {
        'name': 'normal',
        'textScaler': const TextScaler.linear(1.0),
        'description': 'Normal text size',
      },
      {
        'name': 'large_text',
        'textScaler': const TextScaler.linear(1.3),
        'description': 'Large text accessibility',
      },
      {
        'name': 'extra_large_text',
        'textScaler': const TextScaler.linear(1.5),
        'description': 'Extra large text accessibility',
      },
    ];
  }

  /// Generate theme combinations for comprehensive testing
  static List<Map<String, String>> getThemeTestCombinations() {
    return [
      {'theme': 'dracula_ide_dark', 'variant': 'dark'},
      {'theme': 'dracula_ide', 'variant': 'light'},
      {'theme': 'matrix_dark', 'variant': 'dark'},
      {'theme': 'matrix', 'variant': 'light'},
      {'theme': 'vegeta_blue_dark', 'variant': 'dark'},
      {'theme': 'vegeta_blue', 'variant': 'light'},
    ];
  }

  /// Mock system UI overlay style for consistent rendering
  static void mockSystemUIOverlay() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'SystemChrome.setSystemUIOverlayStyle') {
        return null;
      }
      return null;
    });
  }

  /// Reset system UI overlay mocks
  static void resetSystemUIMocks() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  }
}