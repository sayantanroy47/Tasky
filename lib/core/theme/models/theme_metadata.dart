import 'package:flutter/material.dart';

/// Metadata information for a theme
class ThemeMetadata {
  final String id;
  final String name;
  final String description;
  final String author;
  final String version;
  final List<String> tags;
  final String category;
  final IconData previewIcon;
  final Color primaryPreviewColor;
  final Color secondaryPreviewColor;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isPremium;
  final double popularityScore;

  const ThemeMetadata({
    required this.id,
    required this.name,
    required this.description,
    this.author = 'Tasky Team',
    this.version = '1.0.0',
    this.tags = const [],
    this.category = 'general',
    this.previewIcon = Icons.palette,
    required this.primaryPreviewColor,
    required this.secondaryPreviewColor,
    required this.createdAt,
    this.updatedAt,
    this.isPremium = false,
    this.popularityScore = 0.0,
  });

  ThemeMetadata copyWith({
    String? id,
    String? name,
    String? description,
    String? author,
    String? version,
    List<String>? tags,
    String? category,
    IconData? previewIcon,
    Color? primaryPreviewColor,
    Color? secondaryPreviewColor,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPremium,
    double? popularityScore,
  }) {
    return ThemeMetadata(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      author: author ?? this.author,
      version: version ?? this.version,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      previewIcon: previewIcon ?? this.previewIcon,
      primaryPreviewColor: primaryPreviewColor ?? this.primaryPreviewColor,
      secondaryPreviewColor: secondaryPreviewColor ?? this.secondaryPreviewColor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPremium: isPremium ?? this.isPremium,
      popularityScore: popularityScore ?? this.popularityScore,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeMetadata && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ThemeMetadata(id: $id, name: $name, category: $category)';
  }
}

/// Theme categories for organization
enum ThemeCategory {
  general('General', Icons.palette, 'Standard themes'),
  gaming('Gaming', Icons.gamepad, 'Themes inspired by games and anime'),
  professional('Professional', Icons.business, 'Clean themes for work'),
  developer('Developer', Icons.code, 'Themes for developers and coding'),
  dark('Dark', Icons.dark_mode, 'Dark mode themes'),
  light('Light', Icons.light_mode, 'Light mode themes'),
  colorful('Colorful', Icons.color_lens, 'Vibrant and colorful themes'),
  minimal('Minimal', Icons.minimize, 'Clean and minimal themes');

  const ThemeCategory(this.displayName, this.icon, this.description);

  final String displayName;
  final IconData icon;
  final String description;

  static ThemeCategory fromString(String category) {
    return ThemeCategory.values.firstWhere(
      (c) => c.name == category,
      orElse: () => ThemeCategory.general,
    );
  }
}