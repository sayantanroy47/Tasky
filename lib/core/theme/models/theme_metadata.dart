import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
  final Color? tertiaryPreviewColor;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isPremium;
  final double popularityScore;

  ThemeMetadata({
    required this.id,
    required this.name,
    required this.description,
    this.author = 'Tasky Team',
    this.version = '1.0.0',
    this.tags = const [],
    this.category = 'general',
    IconData? previewIcon,
    required this.primaryPreviewColor,
    required this.secondaryPreviewColor,
    this.tertiaryPreviewColor,
    required this.createdAt,
    this.updatedAt,
    this.isPremium = false,
    this.popularityScore = 0.0,
  }) : previewIcon = previewIcon ?? PhosphorIcons.palette();

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
    Color? tertiaryPreviewColor,
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
      tertiaryPreviewColor: tertiaryPreviewColor ?? this.tertiaryPreviewColor,
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
  general('General', 'Standard themes'),
  gaming('Gaming', 'Themes inspired by games and anime'),
  professional('Professional', 'Clean themes for work'),
  developer('Developer', 'Themes for developers and coding'),
  dark('Dark', 'Dark mode themes'),
  light('Light', 'Light mode themes'),
  colorful('Colorful', 'Vibrant and colorful themes'),
  minimal('Minimal', 'Clean and minimal themes');

  const ThemeCategory(this.displayName, this.description);

  final String displayName;
  final String description;
  
  IconData get icon {
    switch (this) {
      case ThemeCategory.general:
        return PhosphorIcons.palette();
      case ThemeCategory.gaming:
        return PhosphorIcons.gameController();
      case ThemeCategory.professional:
        return PhosphorIcons.buildings();
      case ThemeCategory.developer:
        return PhosphorIcons.code();
      case ThemeCategory.dark:
        return PhosphorIcons.moon();
      case ThemeCategory.light:
        return PhosphorIcons.sun();
      case ThemeCategory.colorful:
        return PhosphorIcons.palette();
      case ThemeCategory.minimal:
        return PhosphorIcons.minus();
    }
  }

  static ThemeCategory fromString(String category) {
    return ThemeCategory.values.firstWhere(
      (c) => c.name == category,
      orElse: () => ThemeCategory.general,
    );
  }
}

