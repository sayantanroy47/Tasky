import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/tag.dart';
import '../../domain/repositories/tag_repository.dart';
import '../../core/providers/core_providers.dart';

/// Provider for all tags
final allTagsProvider = FutureProvider<List<Tag>>((ref) async {
  final repository = ref.read(tagRepositoryProvider);
  return await repository.getAllTags();
});

/// Provider for a specific tag by ID
final tagByIdProvider = FutureProvider.family<Tag?, String>((ref, tagId) async {
  final repository = ref.read(tagRepositoryProvider);
  return await repository.getTagById(tagId);
});

/// Provider for tags by their IDs (used by task cards)
final tagsByIdsProvider = FutureProvider.family<List<Tag>, List<String>>((ref, tagIds) async {
  if (tagIds.isEmpty) return [];
  
  final repository = ref.read(tagRepositoryProvider);
  final List<Tag> tags = [];
  
  for (final tagId in tagIds) {
    final tag = await repository.getTagById(tagId);
    if (tag != null) {
      tags.add(tag);
    }
  }
  
  return tags;
});

/// State notifier for tag operations
class TagOperationsNotifier extends StateNotifier<AsyncValue<void>> {
  TagOperationsNotifier(this.ref) : super(const AsyncValue.data(null));
  
  final Ref ref;
  
  TagRepository get _repository => ref.read(tagRepositoryProvider);
  
  /// Create a new tag
  Future<Tag> createTag({
    required String name,
    String? color,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final tag = Tag.create(name: name, color: color);
      await _repository.createTag(tag);
      
      // Invalidate the tags list to refresh UI
      ref.invalidate(allTagsProvider);
      
      state = const AsyncValue.data(null);
      return tag;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
  
  /// Update an existing tag
  Future<void> updateTag(Tag tag) async {
    state = const AsyncValue.loading();
    
    try {
      await _repository.updateTag(tag);
      
      // Invalidate relevant providers
      ref.invalidate(allTagsProvider);
      ref.invalidate(tagByIdProvider(tag.id));
      
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
  
  /// Delete a tag
  Future<void> deleteTag(String tagId) async {
    state = const AsyncValue.loading();
    
    try {
      await _repository.deleteTag(tagId);
      
      // Invalidate relevant providers
      ref.invalidate(allTagsProvider);
      ref.invalidate(tagByIdProvider(tagId));
      
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
  
  /// Search tags by name
  Future<List<Tag>> searchTags(String query) async {
    final repository = ref.read(tagRepositoryProvider);
    return await repository.searchTags(query);
  }
}

/// Provider for tag operations
final tagOperationsProvider = StateNotifierProvider<TagOperationsNotifier, AsyncValue<void>>((ref) {
  return TagOperationsNotifier(ref);
});

/// Provider for predefined colors that users can choose from
final predefinedTagColorsProvider = Provider<List<String>>((ref) {
  return [
    '#FF5722', // Deep Orange
    '#E91E63', // Pink
    '#9C27B0', // Purple
    '#673AB7', // Deep Purple
    '#3F51B5', // Indigo
    '#2196F3', // Blue
    '#03A9F4', // Light Blue
    '#00BCD4', // Cyan
    '#009688', // Teal
    '#4CAF50', // Green
    '#8BC34A', // Light Green
    '#CDDC39', // Lime
    '#FFEB3B', // Yellow
    '#FFC107', // Amber
    '#FF9800', // Orange
    '#795548', // Brown
    '#607D8B', // Blue Grey
    '#F44336', // Red
  ];
});

/// Provider for popular/frequently used tags
final popularTagsProvider = FutureProvider<List<Tag>>((ref) async {
  // For now, return all tags sorted by creation date
  // In the future, this could be based on usage frequency
  final allTags = await ref.watch(allTagsProvider.future);
  return allTags.take(8).toList(); // Show top 8 popular tags
});

/// State provider for selected tags during task creation/editing
final selectedTagsProvider = StateProvider<List<Tag>>((ref) => []);

/// State provider for tag search query
final tagSearchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for filtered tags based on search query
final filteredTagsProvider = Provider<AsyncValue<List<Tag>>>((ref) {
  final searchQuery = ref.watch(tagSearchQueryProvider);
  final allTagsAsync = ref.watch(allTagsProvider);
  
  return allTagsAsync.when(
    data: (tags) {
      if (searchQuery.isEmpty) {
        return AsyncValue.data(tags);
      }
      
      final filtered = tags.where((Tag tag) => 
        tag.name.toLowerCase().contains(searchQuery.toLowerCase())
      ).toList();
      
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Provider for tag statistics
final tagStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  // TODO: Implement actual usage statistics from tasks
  // For now, return empty stats
  return <String, int>{};
});