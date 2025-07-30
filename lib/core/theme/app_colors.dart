import 'package:flutter/material.dart';

/// Color definitions for the Task Tracker App
/// Provides Material 3 color system with accessibility support
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  /// Primary seed color for Material 3 color scheme generation
  static const Color primarySeed = Color(0xFF6750A4);

  /// High contrast colors for accessibility (Light theme)
  static const Color highContrastPrimary = Color(0xFF000000);
  static const Color highContrastOnPrimary = Color(0xFFFFFFFF);
  static const Color highContrastSurface = Color(0xFFFFFFFF);
  static const Color highContrastOnSurface = Color(0xFF000000);

  /// High contrast colors for accessibility (Dark theme)
  static const Color highContrastPrimaryDark = Color(0xFFFFFFFF);
  static const Color highContrastOnPrimaryDark = Color(0xFF000000);
  static const Color highContrastSurfaceDark = Color(0xFF000000);
  static const Color highContrastOnSurfaceDark = Color(0xFFFFFFFF);

  /// Task priority colors
  static const Color priorityLow = Color(0xFF4CAF50);
  static const Color priorityMedium = Color(0xFFFF9800);
  static const Color priorityHigh = Color(0xFFFF5722);
  static const Color priorityUrgent = Color(0xFFD32F2F);

  /// Task status colors
  static const Color statusPending = Color(0xFF757575);
  static const Color statusInProgress = Color(0xFF2196F3);
  static const Color statusCompleted = Color(0xFF4CAF50);
  static const Color statusCancelled = Color(0xFF9E9E9E);

  /// Semantic colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF2196F3);

  /// Voice recording colors
  static const Color voiceRecording = Color(0xFFE91E63);
  static const Color voiceProcessing = Color(0xFF9C27B0);
  static const Color voiceSuccess = Color(0xFF4CAF50);
  static const Color voiceError = Color(0xFFD32F2F);

  /// Tag colors for task categorization
  static const List<Color> tagColors = [
    Color(0xFFE3F2FD), // Light Blue
    Color(0xFFE8F5E8), // Light Green
    Color(0xFFFFF3E0), // Light Orange
    Color(0xFFFCE4EC), // Light Pink
    Color(0xFFF3E5F5), // Light Purple
    Color(0xFFE0F2F1), // Light Teal
    Color(0xFFFFF8E1), // Light Yellow
    Color(0xFFEFEBE9), // Light Brown
    Color(0xFFE8EAF6), // Light Indigo
    Color(0xFFE1F5FE), // Light Cyan
  ];

  /// Get priority color based on priority level
  static Color getPriorityColor(int priority) {
    switch (priority) {
      case 0:
        return priorityLow;
      case 1:
        return priorityMedium;
      case 2:
        return priorityHigh;
      case 3:
        return priorityUrgent;
      default:
        return priorityMedium;
    }
  }

  /// Get status color based on status
  static Color getStatusColor(int status) {
    switch (status) {
      case 0:
        return statusPending;
      case 1:
        return statusInProgress;
      case 2:
        return statusCompleted;
      case 3:
        return statusCancelled;
      default:
        return statusPending;
    }
  }

  /// Get tag color by index
  static Color getTagColor(int index) {
    return tagColors[index % tagColors.length];
  }
}