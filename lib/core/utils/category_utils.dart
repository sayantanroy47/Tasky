import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/phosphor_icons.dart';
import '../../domain/entities/project_category.dart';

/// Enhanced utility class for category-related icons and colors
/// 
/// Provides consistent category styling across all task cards and components.
/// Supports both legacy string categories and new ProjectCategory entities
/// for backward compatibility during migration.
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

  // ============================================================================
  // NEW PROJECTCATEGORY ENTITY SUPPORT - Enhanced category management
  // ============================================================================

  /// Gets icon from ProjectCategory entity using Phosphor icon registry
  static IconData getCategoryIconFromEntity(ProjectCategory category) {
    return PhosphorIconConstants.getIconByName(
      category.iconName, 
      defaultIcon: PhosphorIcons.tag(),
    );
  }

  /// Gets color from ProjectCategory entity with theme fallback
  static Color getCategoryColorFromEntity(ProjectCategory category, {ThemeData? theme}) {
    try {
      // Parse hex color from category
      final hexColor = category.color;
      if (hexColor.startsWith('#') && hexColor.length == 7) {
        return Color(int.parse(hexColor.substring(1), radix: 16) + 0xFF000000);
      }
    } catch (e) {
      // Fall back to theme color if parsing fails
    }
    return theme?.colorScheme.primary ?? const Color(0xFF6200EE);
  }

  /// Creates a category icon container for ProjectCategory entity
  static Widget buildCategoryIconContainerFromEntity({
    required ProjectCategory category,
    required double size,
    ThemeData? theme,
    double iconSizeRatio = 0.5,
    double borderRadius = 6,
  }) {
    final color = getCategoryColorFromEntity(category, theme: theme);
    final icon = getCategoryIconFromEntity(category);
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
        icon,
        size: iconSize,
        color: color,
      ),
    );
  }

  /// Gets icon by icon name (for dynamic icon loading)
  static IconData getIconByName(String iconName) {
    return PhosphorIconConstants.getIconByName(iconName);
  }

  /// Gets all available icons organized by domain for category selection
  static Map<String, Map<String, IconData>> getAllIconsByDomain() {
    return PhosphorIconConstants.iconsByDomain;
  }

  /// Gets popular icons for quick category creation
  static Map<String, IconData> getPopularIcons() {
    return PhosphorIconConstants.popularIcons;
  }

  /// Gets domain display names for UI
  static Map<String, String> getDomainDisplayNames() {
    return PhosphorIconConstants.domainDisplayNames;
  }

  /// Searches available icons by name
  static List<String> searchIcons(String query) {
    return PhosphorIconConstants.searchIconNames(query);
  }

  /// Gets recommended icons based on category name
  static List<String> getRecommendedIcons(String categoryName) {
    final lowercaseName = categoryName.toLowerCase();
    final recommendations = <String>[];

    // Business/Work keywords
    if (RegExp(r'work|business|office|meeting|project|task').hasMatch(lowercaseName)) {
      recommendations.addAll(['briefcase', 'presentation', 'building-office', 'folder', 'clipboard']);
    }
    
    // Personal keywords
    if (RegExp(r'personal|self|me|individual|family|home').hasMatch(lowercaseName)) {
      recommendations.addAll(['user', 'heart', 'house', 'family', 'star']);
    }
    
    // Health keywords
    if (RegExp(r'health|medical|doctor|fitness|exercise|gym').hasMatch(lowercaseName)) {
      recommendations.addAll(['heartbeat', 'activity', 'dumbbell', 'bicycle']);
    }
    
    // Creative keywords
    if (RegExp(r'creative|art|design|paint|music|photo|draw').hasMatch(lowercaseName)) {
      recommendations.addAll(['paint-brush', 'palette', 'camera', 'music-note', 'pen']);
    }
    
    // Technology keywords
    if (RegExp(r'tech|computer|code|digital|software|app').hasMatch(lowercaseName)) {
      recommendations.addAll(['laptop', 'code', 'gear', 'database', 'cpu']);
    }
    
    // Travel keywords
    if (RegExp(r'travel|trip|vacation|flight|car|journey').hasMatch(lowercaseName)) {
      recommendations.addAll(['airplane', 'car', 'suitcase', 'map-pin', 'compass']);
    }
    
    // Finance keywords
    if (RegExp(r'money|finance|bank|budget|investment|expense').hasMatch(lowercaseName)) {
      recommendations.addAll(['wallet', 'bank', 'coins', 'credit-card', 'trending-up']);
    }
    
    // Food keywords
    if (RegExp(r'food|cook|recipe|restaurant|meal|kitchen').hasMatch(lowercaseName)) {
      recommendations.addAll(['fork-knife', 'chef-hat', 'apple', 'cooking-pot']);
    }
    
    // Shopping keywords
    if (RegExp(r'shop|buy|purchase|store|retail').hasMatch(lowercaseName)) {
      recommendations.addAll(['shopping-cart', 'shopping-bag', 'storefront', 'tag']);
    }
    
    // Entertainment keywords
    if (RegExp(r'fun|game|entertainment|hobby|leisure').hasMatch(lowercaseName)) {
      recommendations.addAll(['game-controller', 'film-strip', 'music-note', 'television']);
    }

    // Remove duplicates and return top 6
    return recommendations.toSet().take(6).toList();
  }

  /// Validates that an icon name exists in the Phosphor registry
  static bool isValidIconName(String iconName) {
    return PhosphorIconConstants.hasIcon(iconName);
  }

  /// Gets the domain for a specific icon
  static String? getIconDomain(String iconName) {
    return PhosphorIconConstants.getDomainForIcon(iconName);
  }

  /// Gets all icon names for a specific domain
  static List<String> getIconsForDomain(String domain) {
    return PhosphorIconConstants.getIconNamesForDomain(domain);
  }

  /// Gets icon statistics for analytics
  static Map<String, int> getIconStatistics() {
    return PhosphorIconConstants.getIconStatistics();
  }

  // ============================================================================
  // MIGRATION HELPERS - Support both legacy and new category systems
  // ============================================================================

  /// Converts legacy category string to ProjectCategory entity (for migration)
  static ProjectCategory? legacyCategoryToEntity(String categoryString) {
    if (categoryString.isEmpty) return null;

    final iconName = _getLegacyIconName(categoryString);
    final color = _getLegacyColorHex(categoryString);

    return ProjectCategory.createSystem(
      id: 'legacy_${categoryString.toLowerCase()}',
      name: getCategoryDisplayName(categoryString),
      iconName: iconName,
      color: color,
      metadata: {'isLegacy': true, 'originalName': categoryString},
    );
  }

  /// Gets legacy icon name for backward compatibility
  static String _getLegacyIconName(String category) {
    switch (category.toLowerCase()) {
      case 'work': return 'briefcase';
      case 'personal': return 'user';
      case 'shopping': return 'shopping-cart';
      case 'health': return 'heartbeat';
      case 'fitness': return 'dumbbell';
      case 'finance': return 'wallet';
      case 'education': return 'graduation-cap';
      case 'travel': return 'airplane';
      case 'home': return 'house';
      case 'family': return 'family';
      case 'entertainment': return 'game-controller';
      case 'food': return 'fork-knife';
      case 'technology': return 'laptop';
      case 'creative': return 'paint-brush';
      case 'project': return 'folder';
      case 'meeting': return 'presentation';
      case 'call': return 'phone';
      case 'email': return 'envelope';
      case 'urgent': return 'warning';
      case 'important': return 'star';
      default: return 'tag';
    }
  }

  /// Gets legacy color as hex for backward compatibility
  static String _getLegacyColorHex(String category) {
    switch (category.toLowerCase()) {
      case 'work': return '#1976D2';
      case 'personal': return '#388E3C';
      case 'shopping': return '#FF9800';
      case 'health': return '#E91E63';
      case 'fitness': return '#8BC34A';
      case 'finance': return '#4CAF50';
      case 'education': return '#3F51B5';
      case 'travel': return '#00BCD4';
      case 'home': return '#795548';
      case 'family': return '#FF5722';
      case 'entertainment': return '#9C27B0';
      case 'food': return '#FF9800';
      case 'technology': return '#607D8B';
      case 'creative': return '#9C27B0';
      case 'project': return '#607D8B';
      case 'meeting': return '#673AB7';
      case 'call': return '#2196F3';
      case 'email': return '#009688';
      case 'urgent': return '#F44336';
      case 'important': return '#FFEB3B';
      default: return '#6200EE';
    }
  }

  /// Checks if a category string is a legacy category
  static bool isLegacyCategory(String category) {
    const legacyCategories = [
      'work', 'personal', 'shopping', 'health', 'fitness', 'finance',
      'education', 'travel', 'home', 'family', 'entertainment', 'food',
      'technology', 'creative', 'project', 'meeting', 'call', 'email',
      'urgent', 'important'
    ];
    return legacyCategories.contains(category.toLowerCase());
  }

  /// Gets all legacy category names for migration purposes
  static List<String> getAllLegacyCategories() {
    const categories = [
      'work', 'personal', 'shopping', 'health', 'fitness', 'finance',
      'education', 'travel', 'home', 'family', 'entertainment', 'food',
      'technology', 'creative', 'project', 'meeting', 'call', 'email',
      'urgent', 'important'
    ];
    return categories;
  }
}