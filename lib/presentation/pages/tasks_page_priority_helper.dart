import 'package:flutter/material.dart';
import '../../domain/models/enums.dart';

/// Get theme-aware priority color that uses stellar gold for high priority
Color getPriorityColor(TaskPriority priority, BuildContext context) {
  // We need a WidgetRef to access providers, so let's provide a fallback approach
  return priority.color; // This now uses the updated enum colors with stellar gold fallback
}