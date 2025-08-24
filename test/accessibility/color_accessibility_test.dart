import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:task_tracker_app/core/accessibility/color_contrast_validator.dart';

void main() {
  group('Color Accessibility Tests', () {
    group('WCAG Contrast Ratio Tests', () {
      test('should calculate contrast ratios correctly', () {
        // Test black on white (maximum contrast)
        final blackWhiteRatio = ColorContrastValidator.calculateContrastRatio(
          Colors.black,
          Colors.white,
        );
        expect(blackWhiteRatio, closeTo(21.0, 0.1));

        // Test white on black (same as black on white)
        final whiteBlackRatio = ColorContrastValidator.calculateContrastRatio(
          Colors.white,
          Colors.black,
        );
        expect(whiteBlackRatio, closeTo(21.0, 0.1));

        // Test same colors (minimum contrast)
        final sameColorRatio = ColorContrastValidator.calculateContrastRatio(
          Colors.blue,
          Colors.blue,
        );
        expect(sameColorRatio, closeTo(1.0, 0.1));
      });

      test('should validate WCAG AA compliance for normal text', () {
        // High contrast - should pass AA
        expect(
          ColorContrastValidator.meetsWCAGAA(Colors.black, Colors.white),
          isTrue,
        );

        // Good contrast - should pass AA
        expect(
          ColorContrastValidator.meetsWCAGAA(
            const Color(0xFF333333),
            Colors.white,
          ),
          isTrue,
        );

        // Low contrast - should fail AA
        expect(
          ColorContrastValidator.meetsWCAGAA(
            const Color(0xFF888888),
            Colors.white,
          ),
          isFalse,
        );

        // Very low contrast - should definitely fail
        expect(
          ColorContrastValidator.meetsWCAGAA(
            const Color(0xFFCCCCCC),
            Colors.white,
          ),
          isFalse,
        );
      });

      test('should validate WCAG AA compliance for large text', () {
        // Medium contrast that fails normal but passes large text
        const mediumGray = Color(0xFF777777);
        const white = Colors.white;

        // Should fail for normal text
        expect(
          ColorContrastValidator.meetsWCAGAA(mediumGray, white, isLargeText: false),
          isFalse,
        );

        // Should pass for large text (lower requirement)
        expect(
          ColorContrastValidator.meetsWCAGAA(mediumGray, white, isLargeText: true),
          isTrue,
        );
      });

      test('should validate WCAG AAA compliance', () {
        // Black on white should pass AAA
        expect(
          ColorContrastValidator.meetsWCAGAAA(Colors.black, Colors.white),
          isTrue,
        );

        // Dark gray that passes AA but might not pass AAA
        const darkGray = Color(0xFF333333);
        final aaPasses = ColorContrastValidator.meetsWCAGAA(darkGray, Colors.white);
        final aaaPasses = ColorContrastValidator.meetsWCAGAAA(darkGray, Colors.white);

        expect(aaPasses, isTrue);
        // AAA has higher standards
        if (!aaaPasses) {
          // Dark gray passes AA but not AAA - this is expected
        }
      });
    });

    group('Color Scheme Validation', () {
      test('should validate Material 3 light theme compliance', () {
        final lightColorScheme = ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        );

        final report = ColorContrastValidator.generateReport(lightColorScheme);

        // Light theme accessibility report validation

        // Light themes should generally have good contrast
        expect(report.criticalIssues, equals(0));
        expect(report.isAccessible, isTrue);
      });

      test('should validate Material 3 dark theme compliance', () {
        final darkColorScheme = ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        );

        final report = ColorContrastValidator.generateReport(darkColorScheme);

        // Dark theme accessibility report validation

        // Dark themes should also have good contrast
        expect(report.criticalIssues, equals(0));
        expect(report.isAccessible, isTrue);
      });

      test('should validate custom high contrast theme', () {
        const highContrastScheme = ColorScheme(
          brightness: Brightness.light,
          primary: Colors.black,
          onPrimary: Colors.white,
          secondary: Color(0xFF000080), // Navy blue
          onSecondary: Colors.white,
          error: Color(0xFF800000), // Dark red
          onError: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
          surfaceContainerHighest: Color(0xFFF5F5F5),
          onSurfaceVariant: Colors.black,
          outline: Color(0xFF666666),
          outlineVariant: Color(0xFFCCCCCC),
          shadow: Colors.black,
          scrim: Colors.black,
          inverseSurface: Colors.black,
          onInverseSurface: Colors.white,
          inversePrimary: Colors.white,
          primaryContainer: Color(0xFFE3F2FD),
          onPrimaryContainer: Colors.black,
          secondaryContainer: Color(0xFFE8EAF6),
          onSecondaryContainer: Colors.black,
          tertiary: Color(0xFF2E7D32), // Dark green
          onTertiary: Colors.white,
          tertiaryContainer: Color(0xFFE8F5E8),
          onTertiaryContainer: Colors.black,
          errorContainer: Color(0xFFFFEBEE),
          onErrorContainer: Color(0xFF800000),
          surfaceTint: Colors.blue,
        );

        final report = ColorContrastValidator.generateReport(highContrastScheme);

        // High contrast theme accessibility report validation

        // High contrast theme should have excellent accessibility
        expect(report.criticalIssues, equals(0));
        expect(report.highIssues, lessThanOrEqualTo(1)); // Should be very few issues
        expect(report.overallGrade, isIn([AccessibilityGrade.a, AccessibilityGrade.b]));
      });

      test('should identify problematic color combinations', () {
        // Create a deliberately poor color scheme
        const poorColorScheme = ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFFFFD700), // Gold
          onPrimary: Color(0xFFFFFFFF), // White on gold (poor contrast)
          secondary: Color(0xFF90EE90), // Light green
          onSecondary: Color(0xFFFFFFFF), // White on light green (poor contrast)
          error: Color(0xFFFF69B4), // Hot pink
          onError: Color(0xFFFFFFFF), // White on hot pink (poor contrast)
          surface: Colors.white,
          onSurface: Color(0xFFD3D3D3), // Light gray on white (poor contrast)
          surfaceContainerHighest: Color(0xFFF5F5F5),
          onSurfaceVariant: Color(0xFFD3D3D3),
          outline: Color(0xFFE0E0E0),
          outlineVariant: Color(0xFFF0F0F0),
          shadow: Colors.black,
          scrim: Colors.black,
          inverseSurface: Colors.black,
          onInverseSurface: Colors.white,
          inversePrimary: Colors.white,
          primaryContainer: Color(0xFFE3F2FD),
          onPrimaryContainer: Colors.black,
          secondaryContainer: Color(0xFFE8EAF6),
          onSecondaryContainer: Colors.black,
          tertiary: Colors.green,
          onTertiary: Colors.white,
          tertiaryContainer: Color(0xFFE8F5E8),
          onTertiaryContainer: Colors.black,
          errorContainer: Color(0xFFFFEBEE),
          onErrorContainer: Colors.red,
          surfaceTint: Colors.blue,
        );

        final report = ColorContrastValidator.generateReport(poorColorScheme);

        // Poor contrast theme accessibility report validation

        // Should detect multiple issues
        expect(report.totalIssues, greaterThan(0));
        expect(report.isAccessible, isFalse);
        expect(report.overallGrade, isIn([AccessibilityGrade.c, AccessibilityGrade.d, AccessibilityGrade.f]));

        // Validate specific issues exist
        expect(report.issues, isNotEmpty);
      });
    });

    group('Color Adjustment Tests', () {
      test('should adjust colors to meet contrast requirements', () {
        const backgroundColor = Colors.white;
        const originalColor = Color(0xFFCCCCCC); // Light gray (poor contrast on white)

        // Verify original color fails contrast test
        expect(
          ColorContrastValidator.meetsWCAGAA(originalColor, backgroundColor),
          isFalse,
        );

        // Adjust color to meet requirements
        final adjustedColor = ColorContrastValidator.adjustForContrast(
          originalColor,
          backgroundColor,
          minRatio: 4.5,
          preferLighter: false, // Should go darker
        );

        // Verify adjusted color meets requirements
        expect(
          ColorContrastValidator.meetsWCAGAA(adjustedColor, backgroundColor),
          isTrue,
        );

        final ratio = ColorContrastValidator.calculateContrastRatio(adjustedColor, backgroundColor);
        expect(ratio, greaterThanOrEqualTo(4.5));

        // Verify color adjustment improved contrast
        expect(adjustedColor, isNot(equals(originalColor)));
      });

      test('should get accessible text colors', () {
        // Test on light background
        const lightBackground = Color(0xFFF5F5F5);
        final darkTextOnLight = ColorContrastValidator.getAccessibleTextColor(lightBackground);
        
        expect(
          ColorContrastValidator.meetsWCAGAA(darkTextOnLight, lightBackground),
          isTrue,
        );

        // Test on dark background
        const darkBackground = Color(0xFF333333);
        final lightTextOnDark = ColorContrastValidator.getAccessibleTextColor(darkBackground);
        
        expect(
          ColorContrastValidator.meetsWCAGAA(lightTextOnDark, darkBackground),
          isTrue,
        );

        // Test on medium background (should pick the one with better contrast)
        const mediumBackground = Color(0xFF808080);
        final textOnMedium = ColorContrastValidator.getAccessibleTextColor(mediumBackground);
        
        final contrastRatio = ColorContrastValidator.calculateContrastRatio(textOnMedium, mediumBackground);
        expect(contrastRatio, greaterThanOrEqualTo(4.5));
      });

      test('should create accessible color scheme', () {
        final accessibleScheme = ColorContrastValidator.createAccessibleColorScheme(
          primary: Colors.blue,
          background: Colors.white,
          brightness: Brightness.light,
        );

        final report = ColorContrastValidator.generateReport(accessibleScheme);

        // Generated accessible scheme report validation

        // Generated scheme should have minimal issues
        expect(report.criticalIssues, equals(0));
        expect(report.overallGrade, isIn([AccessibilityGrade.a, AccessibilityGrade.b]));
      });
    });

    group('Complex Scenarios', () {
      test('should handle edge case colors', () {
        // Test pure colors
        const pureRed = Color(0xFFFF0000);
        const pureBlue = Color(0xFF0000FF);
        const pureGreen = Color(0xFF00FF00);

        final redWhiteRatio = ColorContrastValidator.calculateContrastRatio(pureRed, Colors.white);
        final blueWhiteRatio = ColorContrastValidator.calculateContrastRatio(pureBlue, Colors.white);
        final greenWhiteRatio = ColorContrastValidator.calculateContrastRatio(pureGreen, Colors.white);

        // Pure color contrast ratios should be measurable

        // All should have measurable ratios
        expect(redWhiteRatio, greaterThan(1.0));
        expect(blueWhiteRatio, greaterThan(1.0));
        expect(greenWhiteRatio, greaterThan(1.0));
      });

      test('should handle transparency considerations', () {
        // Note: Flutter Color doesn't directly handle alpha in contrast calculations
        // This tests the base color calculations
        const semiTransparent = Color(0x80FF0000); // 50% red
        const opaque = Color(0xFFFF0000); // 100% red

        // The contrast ratio should be the same (alpha not considered in current implementation)
        final transparentRatio = ColorContrastValidator.calculateContrastRatio(semiTransparent, Colors.white);
        final opaqueRatio = ColorContrastValidator.calculateContrastRatio(opaque, Colors.white);

        // Transparency considerations in contrast calculations

        // Current implementation ignores alpha
        expect(transparentRatio, equals(opaqueRatio));
      });

      test('should validate compliance levels', () {
        final testColors = [
          (Colors.black, Colors.white, 'Black on white'),
          (const Color(0xFF666666), Colors.white, 'Medium gray on white'),
          (const Color(0xFF999999), Colors.white, 'Light gray on white'),
          (const Color(0xFFCCCCCC), Colors.white, 'Very light gray on white'),
        ];

        for (final (foreground, background, _) in testColors) {
          final level = ColorContrastValidator.getComplianceLevel(foreground, background);
          final ratio = ColorContrastValidator.calculateContrastRatio(foreground, background);
          
          // Validate compliance levels make sense
          
          // Verify compliance levels make sense
          switch (level) {
            case WCAGComplianceLevel.aaa:
              expect(ratio, greaterThanOrEqualTo(7.0));
              break;
            case WCAGComplianceLevel.aa:
              expect(ratio, greaterThanOrEqualTo(4.5));
              expect(ratio, lessThan(7.0));
              break;
            case WCAGComplianceLevel.fail:
              expect(ratio, lessThan(4.5));
              break;
          }
        }
      });
    });
  });
}