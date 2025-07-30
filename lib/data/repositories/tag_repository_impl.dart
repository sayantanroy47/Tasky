import '../../domain/repositories/tag_repository.dart' as repo;
import '../../services/database/database.dart';
import '../../services/database/daos/tag_dao.dart' as dao;

/// Concrete implementation of TagRepository using local database
/// 
/// This implementation uses the Drift/SQLite database through the TagDao
/// to provide all tag-related operations.
class TagRepositoryImpl implements repo.TagRepository {
  final AppDatabase _database;

  const TagRepositoryImpl(this._database);

  @override
  Future<List<repo.Tag>> getAllTags() async {
    final daoTags = await _database.tagDao.getAllTags();
    return daoTags.map(_daoTagToRepositoryTag).toList();
  }

  @override
  Future<repo.Tag?> getTagById(String id) async {
    final daoTag = await _database.tagDao.getTagById(id);
    return daoTag != null ? _daoTagToRepositoryTag(daoTag) : null;
  }

  @override
  Future<repo.Tag?> getTagByName(String name) async {
    final daoTag = await _database.tagDao.getTagByName(name);
    return daoTag != null ? _daoTagToRepositoryTag(daoTag) : null;
  }

  @override
  Future<void> createTag(repo.Tag tag) async {
    final daoTag = _repositoryTagToDaoTag(tag);
    await _database.tagDao.createTag(daoTag);
  }

  @override
  Future<void> updateTag(repo.Tag tag) async {
    final daoTag = _repositoryTagToDaoTag(tag);
    await _database.tagDao.updateTag(daoTag);
  }

  @override
  Future<void> deleteTag(String id) async {
    await _database.tagDao.deleteTag(id);
  }

  @override
  Future<List<repo.Tag>> getTagsForTask(String taskId) async {
    final daoTags = await _database.tagDao.getTagsForTask(taskId);
    return daoTags.map(_daoTagToRepositoryTag).toList();
  }

  @override
  Future<List<repo.TagWithUsage>> getTagsWithUsage() async {
    final daoTagsWithUsage = await _database.tagDao.getTagsWithUsageCounts();
    return daoTagsWithUsage.map((daoTagWithUsage) {
      return repo.TagWithUsage(
        tag: _daoTagToRepositoryTag(daoTagWithUsage.tag),
        usageCount: daoTagWithUsage.usageCount,
      );
    }).toList();
  }

  @override
  Future<List<repo.TagWithUsage>> getMostUsedTags({int limit = 10}) async {
    final daoTagsWithUsage = await _database.tagDao.getMostUsedTags(limit: limit);
    return daoTagsWithUsage.map((daoTagWithUsage) {
      return repo.TagWithUsage(
        tag: _daoTagToRepositoryTag(daoTagWithUsage.tag),
        usageCount: daoTagWithUsage.usageCount,
      );
    }).toList();
  }

  @override
  Future<List<repo.Tag>> getUnusedTags() async {
    final daoTags = await _database.tagDao.getUnusedTags();
    return daoTags.map(_daoTagToRepositoryTag).toList();
  }

  @override
  Future<List<repo.Tag>> searchTags(String query) async {
    final daoTags = await _database.tagDao.searchTags(query);
    return daoTags.map(_daoTagToRepositoryTag).toList();
  }

  @override
  Future<List<repo.Tag>> getTagsWithFilter(repo.TagFilter filter) async {
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
        case repo.TagSortBy.name:
          comparison = a.tag.name.toLowerCase().compareTo(b.tag.name.toLowerCase());
          break;
        case repo.TagSortBy.createdAt:
          comparison = a.tag.createdAt.compareTo(b.tag.createdAt);
          break;
        case repo.TagSortBy.usageCount:
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
  Stream<List<repo.Tag>> watchAllTags() {
    return _database.tagDao.watchAllTags().map((daoTags) {
      return daoTags.map(_daoTagToRepositoryTag).toList();
    });
  }

  @override
  Stream<List<repo.Tag>> watchTagsForTask(String taskId) {
    return _database.tagDao.watchTagsForTask(taskId).map((daoTags) {
      return daoTags.map(_daoTagToRepositoryTag).toList();
    });
  }

  @override
  Stream<repo.Tag?> watchTagById(String id) {
    return watchAllTags().map((tags) {
      try {
        return tags.firstWhere((tag) => tag.id == id);
      } catch (e) {
        return null;
      }
    });
  }

  /// Converts a DAO Tag to a Repository Tag
  repo.Tag _daoTagToRepositoryTag(dao.Tag daoTag) {
    return repo.Tag(
      id: daoTag.id,
      name: daoTag.name,
      color: daoTag.color,
      createdAt: daoTag.createdAt,
    );
  }

  /// Converts a Repository Tag to a DAO Tag
  dao.Tag _repositoryTagToDaoTag(repo.Tag repositoryTag) {
    return dao.Tag(
      id: repositoryTag.id,
      name: repositoryTag.name,
      color: repositoryTag.color,
      createdAt: repositoryTag.createdAt,
    );
  }
}