import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracker_app/core/theme/app_theme.dart';
import 'package:task_tracker_app/core/theme/app_colors.dart';

void main() {
  group('AppTheme Tests', () {
    test('should create light theme with Material 3', () {
      final theme = AppTheme.lightTheme;
      
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.brightness, Brightness.light);
    });

    test('should create dark theme with Material 3', () {
      final theme = AppTheme.darkTheme;
      
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.brightness, Brightness.dark);
    });

    test('should create high contrast light theme', () {
      final theme = AppTheme.highContrastLightTheme;
      
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, AppColors.highContrastPrimary);
    });

    test('should create high contrast dark theme', () {
      final theme = AppTheme.highContrastDarkTheme;
      
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, AppColors.highContrastPrimaryDark);
    });

    test('should have consistent card theme across all themes', () {
      final themes = [
        AppTheme.lightTheme,
        AppTheme.darkTheme,
        AppTheme.highContrastLightTheme,
        AppTheme.highContrastDarkTheme,
      ];

      for (final theme in themes) {
        expect(theme.cardTheme.shape, isA<RoundedRectangleBorder>());
        expect(theme.cardTheme.elevation, isNotNull);
      }
    });

    test('should have proper app bar theme configuration', () {
      final theme = AppTheme.lightTheme;
      
      expect(theme.appBarTheme.centerTitle, isTrue);
      expect(theme.appBarTheme.elevation, 0);
      expect(theme.appBarTheme.scrolledUnderElevation, 1);
    });

    test('should have proper input decoration theme', () {
      final theme = AppTheme.lightTheme;
      
      expect(theme.inputDecorationTheme.filled, isTrue);
      expect(theme.inputDecorationTheme.border, isA<OutlineInputBorder>());
      expect(theme.inputDecorationTheme.enabledBorder, isA<OutlineInputBorder>());
      expect(theme.inputDecorationTheme.focusedBorder, isA<OutlineInputBorder>());
    });
  });

  group('AppColors Tests', () {
    test('should return correct priority colors', () {
      expect(AppColors.getPriorityColor(0), AppColors.priorityLow);
      expect(AppColors.getPriorityColor(1), AppColors.priorityMedium);
      expect(AppColors.getPriorityColor(2), AppColors.priorityHigh);
      expect(AppColors.getPriorityColor(3), AppColors.priorityUrgent);
      expect(AppColors.getPriorityColor(999), AppColors.priorityMedium); // Default
    });

    test('should return correct status colors', () {
      expect(AppColors.getStatusColor(0), AppColors.statusPending);
      expect(AppColors.getStatusColor(1), AppColors.statusInProgress);
      expect(AppColors.getStatusColor(2), AppColors.statusCompleted);
      expect(AppColors.getStatusColor(3), AppColors.statusCancelled);
      expect(AppColors.getStatusColor(999), AppColors.statusPending); // Default
    });

    test('should return tag colors cyclically', () {
      expect(AppColors.getTagColor(0), AppColors.tagColors[0]);
      expect(AppColors.getTagColor(5), AppColors.tagColors[5]);
      expect(AppColors.getTagColor(10), AppColors.tagColors[0]); // Cycles back
      expect(AppColors.getTagColor(15), AppColors.tagColors[5]); // Cycles back
    });

    test('should have defined tag colors list', () {
      expect(AppColors.tagColors.length, greaterThan(0));
      expect(AppColors.tagColors.length, 10); // Expected number of tag colors
    });
  });
}