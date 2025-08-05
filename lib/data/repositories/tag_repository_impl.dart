import '../../domain/repositories/tag_repository.dart';
import '../../domain/entities/tag.dart' as entity;
import '../../services/database/database.dart';
import '../../services/database/daos/tag_dao.dart' as dao;

/// Concrete implementation of TagRepository using local database
/// 
/// This implementation uses the Drift/SQLite database through the TagDao
/// to provide all tag-related operations.
class TagRepositoryImpl implements TagRepository {
  final AppDatabase _database;

  const TagRepositoryImpl(this._database);
  @override
  Future<List<entity.Tag>> getAllTags() async {
    final daoTags = await _database.tagDao.getAllTags();
    return daoTags.map(_daoTagToRepositoryTag).toList();
  }
  @override
  Future<entity.Tag?> getTagById(String id) async {
    final daoTag = await _database.tagDao.getTagById(id);
    return daoTag != null ? _daoTagToRepositoryTag(daoTag) : null;
  }
  @override
  Future<entity.Tag?> getTagByName(String name) async {
    final daoTag = await _database.tagDao.getTagByName(name);
    return daoTag != null ? _daoTagToRepositoryTag(daoTag) : null;
  }
  @override
  Future<void> createTag(entity.Tag tag) async {
    final daoTag = _repositoryTagToDaoTag(tag);
    await _database.tagDao.createTag(daoTag);
  }
  @override
  Future<void> updateTag(entity.Tag tag) async {
    final daoTag = _repositoryTagToDaoTag(tag);
    await _database.tagDao.updateTag(daoTag);
  }
  @override
  Future<void> deleteTag(String id) async {
    await _database.tagDao.deleteTag(id);
  }
  @override
  Future<List<entity.Tag>> getTagsForTask(String taskId) async {
    final daoTags = await _database.tagDao.getTagsForTask(taskId);
    return daoTags.map(_daoTagToRepositoryTag).toList();
  }
  @override
  Future<List<TagWithUsage>> getTagsWithUsage() async {
    final daoTagsWithUsage = await _database.tagDao.getTagsWithUsageCounts();
    return daoTagsWithUsage.map((daoTagWithUsage) {
      return TagWithUsage(
        tag: _daoTagToRepositoryTag(daoTagWithUsage.tag),
        usageCount: daoTagWithUsage.usageCount,
      );
    }).toList();
  }
  @override
  Future<List<TagWithUsage>> getMostUsedTags({int limit = 10}) async {
    final daoTagsWithUsage = await _database.tagDao.getMostUsedTags(limit: limit);
    return daoTagsWithUsage.map((daoTagWithUsage) {
      return TagWithUsage(
        tag: _daoTagToRepositoryTag(daoTagWithUsage.tag),
        usageCount: daoTagWithUsage.usageCount,
      );
    }).toList();
  }
  @override
  Future<List<entity.Tag>> getUnusedTags() async {
    final daoTags = await _database.tagDao.getUnusedTags();
    return daoTags.map(_daoTagToRepositoryTag).toList();
  }
  @override
  Future<List<entity.Tag>> searchTags(String query) async {
    final daoTags = await _database.tagDao.searchTags(query);
    return daoTags.map(_daoTagToRepositoryTag).toList();
  }
  @override
  Future<List<entity.Tag>> getTagsWithFilter(TagFilter filter) async {
    // Start with all tags
    var tagsWithUsage = await getTagsWithUsage();

    // Apply filters
    if (filter.minUsageCount != null) {
      tagsWithUsage = tagsWithUsage.where((tagWithUsage) {
        return tagWithUsage.usageCount >= filter.minUsageCount!;
      }).toList();
    }

    if (filter.maxUsageCount != null) {
      tagsWithUsage = tagsWithUsage.where((tagWithUsage) {
        return tagWithUsage.usageCount <= filter.maxUsageCount!;
      }).toList();
    }

    if (filter.hasColor == true) {
      tagsWithUsage = tagsWithUsage.where((tagWithUsage) {
        return tagWithUsage.tag.color != null && tagWithUsage.tag.color!.isNotEmpty;
      }).toList();
    } else if (filter.hasColor == false) {
      tagsWithUsage = tagsWithUsage.where((tagWithUsage) {
        return tagWithUsage.tag.color == null || tagWithUsage.tag.color!.isEmpty;
      }).toList();
    }

    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      final query = filter.searchQuery!.toLowerCase();
      tagsWithUsage = tagsWithUsage.where((tagWithUsage) {
        return tagWithUsage.tag.name.toLowerCase().contains(query);
      }).toList();
    }

    // Apply sorting
    tagsWithUsage.sort((a, b) {
      int comparison = 0;
      
      switch (filter.sortBy) {
        case TagSortBy.name:
          comparison = a.tag.name.toLowerCase().compareTo(b.tag.name.toLowerCase());
          break;
        case TagSortBy.createdAt:
          comparison = a.tag.createdAt.compareTo(b.tag.createdAt);
          break;
        case TagSortBy.usageCount:
          comparison = a.usageCount.compareTo(b.usageCount);
          break;
      }

      return filter.sortAscending ? comparison : -comparison;
    });

    return tagsWithUsage.map((tagWithUsage) => tagWithUsage.tag).toList();
  }
  @override
  Future<void> addTagToTask(String taskId, String tagId) async {
    await _database.tagDao.addTagToTask(taskId, tagId);
  }
  @override
  Future<void> removeTagFromTask(String taskId, String tagId) async {
    await _database.tagDao.removeTagFromTask(taskId, tagId);
  }
  @override
  Stream<List<entity.Tag>> watchAllTags() {
    return _database.tagDao.watchAllTags().map((daoTags) {
      return daoTags.map(_daoTagToRepositoryTag).toList();
    });
  }
  @override
  Stream<List<entity.Tag>> watchTagsForTask(String taskId) {
    return _database.tagDao.watchTagsForTask(taskId).map((daoTags) {
      return daoTags.map(_daoTagToRepositoryTag).toList();
    });
  }
  @override
  Stream<entity.Tag?> watchTagById(String id) {
    return watchAllTags().map((tags) {
      try {
        return tags.firstWhere((tag) => tag.id == id);
      } catch (e) {
        return null;
      }
    });
  }

  /// Converts a DAO Tag to a Repository Tag
  entity.Tag _daoTagToRepositoryTag(dao.Tag daoTag) {
    return entity.Tag(
      id: daoTag.id,
      name: daoTag.name,
      color: daoTag.color,
      createdAt: daoTag.createdAt,
    );
  }

  /// Converts a Repository Tag to a DAO Tag
  dao.Tag _repositoryTagToDaoTag(entity.Tag repositoryTag) {
    return dao.Tag(
      id: repositoryTag.id,
      name: repositoryTag.name,
      color: repositoryTag.color,
      createdAt: repositoryTag.createdAt,
    );
  }
}
