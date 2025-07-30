import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';

part 'tag_dao.g.dart';

/// Simple Tag model for database operations
class Tag {
  final String id;
  final String name;
  final String? color;
  final DateTime createdAt;

  const Tag({
    required this.id,
    required this.name,
    this.color,
    required this.createdAt,
  });

  Tag copyWith({
    String? id,
    String? name,
    String? color,
    DateTime? createdAt,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Tag &&
        other.id == id &&
        other.name == name &&
        other.color == color &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ color.hashCode ^ createdAt.hashCode;
  }

  @override
  String toString() {
    return 'Tag(id: $id, name: $name, color: $color, createdAt: $createdAt)';
  }
}

/// Data Access Object for Tag operations
/// 
/// Provides CRUD operations and queries for tags in the database.
@DriftAccessor(tables: [Tags, TaskTags])
class TagDao extends DatabaseAccessor<AppDatabase> with _$TagDaoMixin {
  TagDao(super.db);

  /// Gets all tags from the database
  Future<List<Tag>> getAllTags() async {
    final tagRows = await select(tags).get();
    return tagRows.map(_tagRowToModel).toList().cast<Tag>();
  }

  /// Gets a tag by its ID
  Future<Tag?> getTagById(String id) async {
    final tagRow = await (select(tags)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (tagRow == null) return null;

    return _tagRowToModel(tagRow);
  }

  /// Gets a tag by its name
  Future<Tag?> getTagByName(String name) async {
    final tagRow = await (select(tags)..where((t) => t.name.equals(name))).getSingleOrNull();
    if (tagRow == null) return null;

    return _tagRowToModel(tagRow);
  }

  /// Creates a new tag in the database
  Future<void> createTag(Tag tag) async {
    await into(tags).insert(_tagModelToRow(tag));
  }

  /// Updates an existing tag in the database
  Future<void> updateTag(Tag tag) async {
    await (update(tags)..where((t) => t.id.equals(tag.id)))
        .write(_tagModelToRow(tag));
  }

  /// Deletes a tag from the database
  /// Note: This will also remove all task-tag relationships for this tag
  Future<void> deleteTag(String id) async {
    await (delete(tags)..where((t) => t.id.equals(id))).go();
    // Task-tag relationships will be deleted automatically due to CASCADE
  }

  /// Gets tags used by a specific task
  Future<List<Tag>> getTagsForTask(String taskId) async {
    final query = select(tags).join([
      innerJoin(taskTags, taskTags.tagId.equalsExp(tags.id))
    ])..where(taskTags.taskId.equals(taskId));

    final results = await query.get();
    return results.map((row) => _tagRowToModel(row.readTable(tags))).toList();
  }

  /// Gets tags with usage counts (how many tasks use each tag)
  Future<List<TagWithUsageCount>> getTagsWithUsageCounts() async {
    final query = select(tags).join([
      leftOuterJoin(taskTags, taskTags.tagId.equalsExp(tags.id))
    ]);

    final results = await query.get();
    final tagMap = <String, TagWithUsageCount>{};

    for (final row in results) {
      final tag = row.readTable(tags);
      final taskTag = row.readTableOrNull(taskTags);

      if (!tagMap.containsKey(tag.id)) {
        tagMap[tag.id] = TagWithUsageCount(
          tag: _tagRowToModel(tag),
          usageCount: taskTag != null ? 1 : 0,
        );
      } else if (taskTag != null) {
        final existing = tagMap[tag.id]!;
        tagMap[tag.id] = TagWithUsageCount(
          tag: existing.tag,
          usageCount: existing.usageCount + 1,
        );
      }
    }

    return tagMap.values.toList();
  }

  /// Gets the most frequently used tags
  Future<List<TagWithUsageCount>> getMostUsedTags({int limit = 10}) async {
    final tagsWithCounts = await getTagsWithUsageCounts();
    tagsWithCounts.sort((a, b) => b.usageCount.compareTo(a.usageCount));
    return tagsWithCounts.take(limit).toList();
  }

  /// Searches tags by name
  Future<List<Tag>> searchTags(String query) async {
    final tagRows = await (select(tags)
      ..where((t) => t.name.contains(query))
    ).get();
    
    return tagRows.map(_tagRowToModel).toList().cast<Tag>();
  }

  /// Gets unused tags (tags not associated with any tasks)
  Future<List<Tag>> getUnusedTags() async {
    final query = select(tags).join([
      leftOuterJoin(taskTags, taskTags.tagId.equalsExp(tags.id))
    ])..where(taskTags.tagId.isNull());

    final results = await query.get();
    return results.map((row) => _tagRowToModel(row.readTable(tags))).toList();
  }

  /// Adds a tag to a task
  Future<void> addTagToTask(String taskId, String tagId) async {
    await into(taskTags).insert(TaskTagsCompanion.insert(
      taskId: taskId,
      tagId: tagId,
    ), mode: InsertMode.insertOrIgnore);
  }

  /// Removes a tag from a task
  Future<void> removeTagFromTask(String taskId, String tagId) async {
    await (delete(taskTags)
      ..where((tt) => tt.taskId.equals(taskId) & tt.tagId.equals(tagId))
    ).go();
  }

  /// Watches all tags (returns a stream)
  Stream<List<Tag>> watchAllTags() {
    return select(tags).watch().map((tagRows) {
      return tagRows.map(_tagRowToModel).toList();
    });
  }

  /// Watches tags for a specific task (returns a stream)
  Stream<List<Tag>> watchTagsForTask(String taskId) {
    final query = select(tags).join([
      innerJoin(taskTags, taskTags.tagId.equalsExp(tags.id))
    ])..where(taskTags.taskId.equals(taskId));

    return query.watch().map((results) {
      return results.map((row) => _tagRowToModel(row.readTable(tags))).toList();
    });
  }

  /// Converts a tag database row to a Tag model
  Tag _tagRowToModel(dynamic tagRow) {
    return Tag(
      id: tagRow.id,
      name: tagRow.name,
      color: tagRow.color,
      createdAt: tagRow.createdAt,
    );
  }

  /// Converts a Tag model to a database row
  TagsCompanion _tagModelToRow(Tag tag) {
    return TagsCompanion.insert(
      id: tag.id,
      name: tag.name,
      color: Value(tag.color),
      createdAt: tag.createdAt,
    );
  }
}

/// Helper class for tags with usage counts
class TagWithUsageCount {
  final Tag tag;
  final int usageCount;

  const TagWithUsageCount({
    required this.tag,
    required this.usageCount,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TagWithUsageCount &&
        other.tag == tag &&
        other.usageCount == usageCount;
  }

  @override
  int get hashCode => tag.hashCode ^ usageCount.hashCode;

  @override
  String toString() {
    return 'TagWithUsageCount(tag: $tag, usageCount: $usageCount)';
  }
}