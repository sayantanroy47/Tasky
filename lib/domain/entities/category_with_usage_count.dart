import 'package:equatable/equatable.dart';
import 'project_category.dart';

/// Data class that pairs a ProjectCategory with its usage count
/// 
/// This is used for analytics and statistics to show how frequently
/// each category is used across projects.
class CategoryWithUsageCount extends Equatable {
  /// The project category
  final ProjectCategory category;
  
  /// Number of projects using this category
  final int usageCount;
  
  const CategoryWithUsageCount({
    required this.category,
    required this.usageCount,
  });

  @override
  List<Object?> get props => [category, usageCount];

  @override
  String toString() {
    return 'CategoryWithUsageCount(category: ${category.name}, usageCount: $usageCount)';
  }
}