import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:task_tracker_app/services/database/database.dart';
import 'package:task_tracker_app/data/repositories/tag_repository_impl.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/repositories/tag_repository.dart';

void main() {
  group('TagRepositoryImpl', () {
    late AppDatabase database;
    late TagRepository repository;

    setUp(() async {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      repository = TagRepositoryImpl(database);
    });

    tearDown(() async {
      await database.close();
    });

    group('Basic CRUD Operations', () {
      test('should create and retrieve a tag', () async {
        final tag = Tag(
          id: 'tag-1',
          name: 'urgent',
          color: '#FF0000',
          createdAt: DateTime.now(),
        );

        await repository.createTag(tag);
        final retrievedTag = await repository.getTagById(tag.id);

        expect(retrievedTag, isNotNull);
        expect(retrievedTag!.id, tag.id);
        expect(retrievedTag.name, tag.name);
        expect(retrievedTag.color, tag.color);
      });

      test('should get tag by name', () async {
        final tag = Tag(
          id: 'tag-1',
          name: 'work',
          createdAt: DateTime.now(),
        );

        await repository.createTag(tag);
        final retrievedTag = await repository.getTagByName('work');

        expect(retrievedTag, isNotNull);
        expect(retrievedTag!.name, 'work');
      });

      test('should update a tag', () async {
        final tag = Tag(
          id: 'tag-1',
          name: 'original',
          createdAt: DateTime.now(),
        );

        await repository.createTag(tag);

        final updatedTag = tag.copyWith(
          name: 'updated',
          color: '#00FF00',
        );
        await repository.updateTag(updatedTag);

        final retrievedTag = await repository.getTagById(tag.id);
        expect(retrievedTag!.name, 'updated');
        expect(retrievedTag.color, '#00FF00');
      });

      test('should delete a tag', () async {
        final tag = Tag(
          id: 'tag-1',
          name: 'to-delete',
          createdAt: DateTime.now(),
        );

        await repository.createTag(tag);
        await repository.deleteTag(tag.id);

        final retrievedTag = await repository.getTagById(tag.id);
        expect(retrievedTag, isNull);
      });

      test('should get all tags', () async {
        final tag1 = Tag(id: 'tag-1', name: 'work', createdAt: DateTime.now());
        final tag2 = Tag(id: 'tag-2', name: 'personal', createdAt: DateTime.now());

        await repository.createTag(tag1);
        await repository.createTag(tag2);

        final allTags = await repository.getAllTags();

        expect(allTags.length, 2);
        expect(allTags.any((t) => t.name == 'work'), true);
        expect(allTags.any((t) => t.name == 'personal'), true);
      });
    });

    group('Task-Tag Relationships', () {
      test('should add and remove tags from tasks', () async {
        final tag = Tag(id: 'tag-1', name: 'work', createdAt: DateTime.now());
        final task = TaskModel.create(title: 'Test Task');

        await repository.createTag(tag);
        await database.taskDao.createTask(task);

        await repository.addTagToTask(task.id, tag.id);
        var tagsForTask = await repository.getTagsForTask(task.id);
        expect(tagsForTask.length, 1);
        expect(tagsForTask.first.name, 'work');

        await repository.removeTagFromTask(task.id, tag.id);
        tagsForTask = await repository.getTagsForTask(task.id);
        expect(tagsForTask.length, 0);
      });

      test('should get tags for a specific task', () async {
        final tag1 = Tag(id: 'tag-1', name: 'work', createdAt: DateTime.now());
        final tag2 = Tag(id: 'tag-2', name: 'urgent', createdAt: DateTime.now());
        final task = TaskModel.create(title: 'Test Task');

        await repository.createTag(tag1);
        await repository.createTag(tag2);
        await database.taskDao.createTask(task);

        await repository.addTagToTask(task.id, tag1.id);
        await repository.addTagToTask(task.id, tag2.id);

        final tagsForTask = await repository.getTagsForTask(task.id);
        expect(tagsForTask.length, 2);
        expect(tagsForTask.any((t) => t.name == 'work'), true);
        expect(tagsForTask.any((t) => t.name == 'urgent'), true);
      });
    });

    group('Tag Usage Statistics', () {
      test('should get tags with usage counts', () async {
        final tag1 = Tag(id: 'tag-1', name: 'work', createdAt: DateTime.now());
        final tag2 = Tag(id: 'tag-2', name: 'personal', createdAt: DateTime.now());
        final task1 = TaskModel.create(title: 'Task 1');
        final task2 = TaskModel.create(title: 'Task 2');

        await repository.createTag(tag1);
        await repository.createTag(tag2);
        await database.taskDao.createTask(task1);
        await database.taskDao.createTask(task2);

        // Add 'work' tag to both tasks, 'personal' tag to one task
        await repository.addTagToTask(task1.id, tag1.id);
        await repository.addTagToTask(task2.id, tag1.id);
        await repository.addTagToTask(task1.id, tag2.id);

        final tagsWithUsage = await repository.getTagsWithUsage();
        final workTag = tagsWithUsage.firstWhere((t) => t.tag.name == 'work');
        final personalTag = tagsWithUsage.firstWhere((t) => t.tag.name == 'personal');

        expect(workTag.usageCount, 2);
        expect(personalTag.usageCount, 1);
      });

      test('should get most used tags', () async {
        final tag1 = Tag(id: 'tag-1', name: 'popular', createdAt: DateTime.now());
        final tag2 = Tag(id: 'tag-2', name: 'rare', createdAt: DateTime.now());
        final task1 = TaskModel.create(title: 'Task 1');
        final task2 = TaskModel.create(title: 'Task 2');
        final task3 = TaskModel.create(title: 'Task 3');

        await repository.createTag(tag1);
        await repository.createTag(tag2);
        await database.taskDao.createTask(task1);
        await database.taskDao.createTask(task2);
        await database.taskDao.createTask(task3);

        // Make 'popular' tag more popular
        await repository.addTagToTask(task1.id, tag1.id);
        await repository.addTagToTask(task2.id, tag1.id);
        await repository.addTagToTask(task3.id, tag1.id);
        await repository.addTagToTask(task1.id, tag2.id);

        final mostUsedTags = await repository.getMostUsedTags(limit: 2);
        expect(mostUsedTags.length, 2);
        expect(mostUsedTags.first.tag.name, 'popular');
        expect(mostUsedTags.first.usageCount, 3);
        expect(mostUsedTags.last.tag.name, 'rare');
        expect(mostUsedTags.last.usageCount, 1);
      });

      test('should get unused tags', () async {
        final usedTag = Tag(id: 'tag-1', name: 'used', createdAt: DateTime.now());
        final unusedTag = Tag(id: 'tag-2', name: 'unused', createdAt: DateTime.now());
        final task = TaskModel.create(title: 'Test Task');

        await repository.createTag(usedTag);
        await repository.createTag(unusedTag);
        await database.taskDao.createTask(task);

        await repository.addTagToTask(task.id, usedTag.id);

        final unusedTags = await repository.getUnusedTags();
        expect(unusedTags.length, 1);
        expect(unusedTags.first.name, 'unused');
      });
    });

    group('Search and Filter Operations', () {
      test('should search tags', () async {
        final tag1 = Tag(id: 'tag-1', name: 'work-related', createdAt: DateTime.now());
        final tag2 = Tag(id: 'tag-2', name: 'personal', createdAt: DateTime.now());
        final tag3 = Tag(id: 'tag-3', name: 'homework', createdAt: DateTime.now());

        await repository.createTag(tag1);
        await repository.createTag(tag2);
        await repository.createTag(tag3);

        final workTags = await repository.searchTags('work');

        expect(workTags.length, 2); // 'work-related' and 'homework'
        expect(workTags.any((t) => t.name == 'work-related'), true);
        expect(workTags.any((t) => t.name == 'homework'), true);
      });

      test('should filter tags with TagFilter', () async {
        final tag1 = Tag(id: 'tag-1', name: 'popular', color: '#FF0000', createdAt: DateTime.now());
        final tag2 = Tag(id: 'tag-2', name: 'rare', createdAt: DateTime.now());
        final task1 = TaskModel.create(title: 'Task 1');
        final task2 = TaskModel.create(title: 'Task 2');

        await repository.createTag(tag1);
        await repository.createTag(tag2);
        await database.taskDao.createTask(task1);
        await database.taskDao.createTask(task2);

        // Make tag1 more popular
        await repository.addTagToTask(task1.id, tag1.id);
        await repository.addTagToTask(task2.id, tag1.id);
        await repository.addTagToTask(task1.id, tag2.id);

        // Filter by minimum usage count
        final filter1 = TagFilter(minUsageCount: 2);
        final popularTags = await repository.getTagsWithFilter(filter1);
        expect(popularTags.length, 1);
        expect(popularTags.first.name, 'popular');

        // Filter by color presence
        final filter2 = TagFilter(hasColor: true);
        final coloredTags = await repository.getTagsWithFilter(filter2);
        expect(coloredTags.length, 1);
        expect(coloredTags.first.name, 'popular');

        // Search filter
        final filter3 = TagFilter(searchQuery: 'pop');
        final searchResults = await repository.getTagsWithFilter(filter3);
        expect(searchResults.length, 1);
        expect(searchResults.first.name, 'popular');
      });

      test('should sort tags with TagFilter', () async {
        final tagB = Tag(id: 'tag-1', name: 'B Tag', createdAt: DateTime.now());
        final tagA = Tag(id: 'tag-2', name: 'A Tag', createdAt: DateTime.now());

        await repository.createTag(tagB);
        await repository.createTag(tagA);

        // Sort by name ascending
        final filter = TagFilter(
          sortBy: TagSortBy.name,
          sortAscending: true,
        );
        final sortedTags = await repository.getTagsWithFilter(filter);

        expect(sortedTags.first.name, 'A Tag');
        expect(sortedTags.last.name, 'B Tag');
      });

      test('should sort by usage count', () async {
        final tag1 = Tag(id: 'tag-1', name: 'Popular', createdAt: DateTime.now());
        final tag2 = Tag(id: 'tag-2', name: 'Rare', createdAt: DateTime.now());
        final task1 = TaskModel.create(title: 'Task 1');
        final task2 = TaskModel.create(title: 'Task 2');

        await repository.createTag(tag1);
        await repository.createTag(tag2);
        await database.taskDao.createTask(task1);
        await database.taskDao.createTask(task2);

        // Make tag1 more popular
        await repository.addTagToTask(task1.id, tag1.id);
        await repository.addTagToTask(task2.id, tag1.id);
        await repository.addTagToTask(task1.id, tag2.id);

        // Sort by usage count descending
        final filter = TagFilter(
          sortBy: TagSortBy.usageCount,
          sortAscending: false,
        );
        final sortedTags = await repository.getTagsWithFilter(filter);

        expect(sortedTags.first.name, 'Popular');
        expect(sortedTags.last.name, 'Rare');
      });
    });

    group('Stream Operations', () {
      test('should watch all tags', () async {
        final tag = Tag(id: 'tag-1', name: 'Watched Tag', createdAt: DateTime.now());
        
        // Start watching
        final stream = repository.watchAllTags();
        final future = stream.first;

        // Create tag
        await repository.createTag(tag);

        // Verify stream emits the tag
        final tags = await future;
        expect(tags.any((t) => t.name == 'Watched Tag'), true);
      });

      test('should watch tags for a specific task', () async {
        final tag = Tag(id: 'tag-1', name: 'Task Tag', createdAt: DateTime.now());
        final task = TaskModel.create(title: 'Test Task');
        
        await repository.createTag(tag);
        await database.taskDao.createTask(task);
        
        // Start watching tags for task
        final stream = repository.watchTagsForTask(task.id);
        
        // Add tag to task
        await repository.addTagToTask(task.id, tag.id);

        // Get the first emission
        final tags = await stream.first;
        
        // Verify stream emits the tag
        expect(tags.length, 1);
        expect(tags.first.name, 'Task Tag');
      });

      test('should watch tag by id', () async {
        final tag = Tag(id: 'tag-1', name: 'Specific Tag', createdAt: DateTime.now());
        await repository.createTag(tag);
        
        // Start watching specific tag
        final stream = repository.watchTagById(tag.id);
        final watchedTag = await stream.first;

        expect(watchedTag, isNotNull);
        expect(watchedTag!.name, 'Specific Tag');
      });

      test('should return null when watching non-existent tag', () async {
        final stream = repository.watchTagById('non-existent-id');
        final watchedTag = await stream.first;

        expect(watchedTag, isNull);
      });
    });

    group('Edge Cases', () {
      test('should handle duplicate tag names gracefully', () async {
        final tag1 = Tag(id: 'tag-1', name: 'duplicate', createdAt: DateTime.now());
        final tag2 = Tag(id: 'tag-2', name: 'duplicate', createdAt: DateTime.now());

        await repository.createTag(tag1);
        
        // This should fail due to unique constraint on name
        expect(() => repository.createTag(tag2), throwsA(isA<Exception>()));
      });

      test('should handle empty search queries', () async {
        final tag = Tag(id: 'tag-1', name: 'test', createdAt: DateTime.now());
        await repository.createTag(tag);

        final results = await repository.searchTags('');
        expect(results.length, 1); // Should return all tags
      });

      test('should handle non-existent tag operations', () async {
        final retrievedTag = await repository.getTagById('non-existent');
        expect(retrievedTag, isNull);

        final tagByName = await repository.getTagByName('non-existent');
        expect(tagByName, isNull);
      });
    });
  });
}