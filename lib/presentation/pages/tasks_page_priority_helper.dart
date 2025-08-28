import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/enums.dart';
import '../../core/providers/enhanced_theme_provider.dart';

/// Get theme-aware priority color that uses stellar gold for high priority
Color getPriorityColor(TaskPriority priority, BuildContext context) {
  // We need a WidgetRef to access providers, so let's provide a fallback approach
  return priority.color; // This now uses the updated enum colors with stellar gold fallback
}