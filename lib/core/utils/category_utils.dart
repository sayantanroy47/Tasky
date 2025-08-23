import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Utility class for category-related icons and colors
/// Provides consistent category styling across all task cards and components
class CategoryUtils {
  
  /// Get category-based icon for task cards
  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return PhosphorIcons.briefcase();
      case 'personal':
        return PhosphorIcons.user();
      case 'shopping':
        return PhosphorIcons.shoppingCart();
      case 'health':
        return PhosphorIcons.heartbeat();
      case 'fitness':
        return PhosphorIcons.barbell();
      case 'finance':
        return PhosphorIcons.wallet();
      case 'education':
        return PhosphorIcons.graduationCap();
      case 'travel':
        return PhosphorIcons.airplane();
      case 'home':
        return PhosphorIcons.house();
      case 'family':
        return PhosphorIcons.users();
      case 'entertainment':
        return PhosphorIcons.filmStrip();
      case 'food':
        return PhosphorIcons.forkKnife();
      case 'technology':
        return PhosphorIcons.laptop();
      case 'creative':
        return PhosphorIcons.paintBrush();
      case 'project':
        return PhosphorIcons.folder();
      case 'meeting':
        return PhosphorIcons.door();
      case 'call':
        return PhosphorIcons.phone();
      case 'email':
        return PhosphorIcons.envelope();
      case 'urgent':
        return PhosphorIcons.warningCircle();
      case 'important':
        return PhosphorIcons.star();
      default:
        return PhosphorIcons.tag();
    }
  }

  /// Get category-based color for task cards
  static Color getCategoryColor(String category, {ThemeData? theme}) {
    switch (category.toLowerCase()) {
      case 'work':
        return const Color(0xFF1976D2); // Blue
      case 'personal':
        return const Color(0xFF388E3C); // Green
      case 'shopping':
        return const Color(0xFFFF9800); // Orange
      case 'health':
        return const Color(0xFFE91E63); // Pink
      case 'fitness':
        return const Color(0xFF8BC34A); // Light Green
      case 'finance':
        return const Color(0xFF4CAF50); // Green
      case 'education':
        return const Color(0xFF3F51B5); // Indigo
      case 'travel':
        return const Color(0xFF00BCD4); // Cyan
      case 'home':
        return const Color(0xFF795548); // Brown
      case 'family':
        return const Color(0xFFFF5722); // Deep Orange
      case 'entertainment':
        return const Color(0xFF9C27B0); // Purple
      case 'food':
        return const Color(0xFFFF9800); // Orange
      case 'technology':
        return Colors.blueGrey;
      case 'creative':
        return Colors.deepPurple;
      case 'project':
        return const Color(0xFF607D8B); // Blue Grey
      case 'meeting':
        return const Color(0xFF673AB7); // Deep Purple
      case 'call':
        return const Color(0xFF2196F3); // Blue
      case 'email':
        return const Color(0xFF009688); // Teal
      case 'urgent':
        return const Color(0xFFF44336); // Red
      case 'important':
        return const Color(0xFFFFEB3B); // Yellow
      default:
        return theme?.colorScheme.primary ?? const Color(0xFF6200EE); // Default theme color
    }
  }

  /// Create a category icon container widget
  static Widget buildCategoryIconContainer({
    required String category,
    required double size,
    ThemeData? theme,
    double iconSizeRatio = 0.5, // Icon size relative to container
    double borderRadius = 6,
  }) {
    final color = getCategoryColor(category, theme: theme);
    final iconSize = size * iconSizeRatio;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Icon(
        getCategoryIcon(category),
        size: iconSize,
        color: color,
      ),
    );
  }

  /// Get all available categories with their icons and colors
  static List<Map<String, dynamic>> getAllCategories({ThemeData? theme}) {
    const categories = [
      'work', 'personal', 'shopping', 'health', 'fitness', 'finance',
      'education', 'travel', 'home', 'family', 'entertainment', 'food',
      'technology', 'creative', 'project', 'meeting', 'call', 'email',
      'urgent', 'important'
    ];
    
    return categories.map((category) => {
      'name': category,
      'icon': getCategoryIcon(category),
      'color': getCategoryColor(category, theme: theme),
    }).toList();
  }

  /// Check if a category has a custom icon (not the default)
  static bool hasCustomIcon(String category) {
    return category.toLowerCase() != 'default' && 
           getCategoryIcon(category) != PhosphorIcons.tag();
  }

  /// Get display name for category
  static String getCategoryDisplayName(String category) {
    return category.isEmpty 
        ? 'General'
        : category[0].toUpperCase() + category.substring(1).toLowerCase();
  }
}