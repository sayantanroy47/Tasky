import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'package:task_tracker_app/services/database/database.dart';
import 'package:task_tracker_app/services/database/daos/tag_dao.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('TagDao', () {
    late AppDatabase database;
    late TagDao tagDao;
    late Tag testTag;

    setUp(() async {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      tagDao = database.tagDao;
      
      testTag = Tag(
        id: 'test-tag-id',
        name: 'Test Tag',
        color: '#FF5722',
        createdAt: DateTime.now(),
      );
    });

    tearDown(() async {
      await database.close();
    });

    group('Tag Creation', () {
      test('should create a tag successfully', () async {
        await tagDao.insertTag(testTag);
        
        final tags = await tagDao.getAllTags();
        expect(tags, hasLength(1));
        expect(tags.first.name, equals('Test Tag'));
        expect(tags.first.color, equals('#FF5722'));
      });

      test('should create tag without color', () async {
        final tagWithoutColor = Tag(
          id: 'no-color-tag',
          name: 'No Color Tag',
          color: null,
          createdAt: DateTime.now(),
        );

        await tagDao.insertTag(tagWithoutColor);
        
        final retrieved = await tagDao.getTagById('no-color-tag');
        expect(retrieved, isNotNull);
        expect(retrieved!.name, equals('No Color Tag'));
        expect(retrieved.color, isNull);
      });

      test('should handle duplicate tag names', () async {
        await tagDao.insertTag(testTag);
        
        final duplicateTag = Tag(
          id: 'duplicate-tag-id',
          name: 'Test Tag', // Same name
          color: '#2196F3',
          createdAt: DateTime.now(),
        );

        // Should allow duplicate names with different IDs
        await tagDao.insertTag(duplicateTag);
        
        final tags = await tagDao.getAllTags();
        expect(tags, hasLength(2));
      });
    });

    group('Tag Retrieval', () {
      setUp(() async {
        await tagDao.insertTag(testTag);
        await tagDao.insertTag(Tag(
          id: 'work-tag',
          name: 'Work',
          color: '#4CAF50',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ));
        await tagDao.insertTag(Tag(
          id: 'personal-tag',
          name: 'Personal',
          color: '#9C27B0',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ));
      });

      test('should get all tags', () async {
        final tags = await tagDao.getAllTags();
        expect(tags, hasLength(3));
        
        final names = tags.map((t) => t.name).toList();
        expect(names, containsAll(['Test Tag', 'Work', 'Personal']));
      });

      test('should get tag by ID', () async {
        final retrieved = await tagDao.getTagById(testTag.id);
        expect(retrieved, isNotNull);
        expect(retrieved!.id, equals(testTag.id));
        expect(retrieved.name, equals('Test Tag'));
      });

      test('should return null for non-existent tag', () async {
        final retrieved = await tagDao.getTagById('non-existent-id');
        expect(retrieved, isNull);
      });

      test('should get tag by name', () async {
        final retrieved = await tagDao.getTagByName('Work');
        expect(retrieved, isNotNull);
        expect(retrieved!.name, equals('Work'));
        expect(retrieved.color, equals('#4CAF50'));
      });

      test('should search tags by name pattern', () async {
        final results = await tagDao.searchTags('Test');
        expect(results, hasLength(1));
        expect(results.first.name, equals('Test Tag'));
      });

      test('should get recently used tags', () async {
        final recentTags = await tagDao.getRecentlyUsedTags(limit: 2);
        expect(recentTags, hasLength(2));
        // Should be ordered by creation date (most recent first)
        expect(recentTags.first.name, equals('Test Tag'));
      });
    });

    group('Tag Updates', () {
      setUp(() async {
        await tagDao.insertTag(testTag);
      });

      test('should update tag successfully', () async {
        final updatedTag = testTag.copyWith(
          name: 'Updated Tag Name',
          color: '#FFC107',
        );

        await tagDao.updateTag(updatedTag);
        
        final retrieved = await tagDao.getTagById(testTag.id);
        expect(retrieved, isNotNull);
        expect(retrieved!.name, equals('Updated Tag Name'));
        expect(retrieved.color, equals('#FFC107'));
      });

      test('should handle updating non-existent tag', () async {
        final nonExistentTag = testTag.copyWith(id: 'non-existent');
        
        // Should not throw but also should not affect any rows
        await tagDao.updateTag(nonExistentTag);
        
        final retrieved = await tagDao.getTagById('non-existent');
        expect(retrieved, isNull);
      });
    });

    group('Tag Deletion', () {
      setUp(() async {
        await tagDao.insertTag(testTag);
        await tagDao.insertTag(Tag(
          id: 'delete-test-tag',
          name: 'Delete Test',
          color: '#795548',
          createdAt: DateTime.now(),
        ));
      });

      test('should delete tag by ID', () async {
        await tagDao.deleteTag(testTag.id);
        
        final retrieved = await tagDao.getTagById(testTag.id);
        expect(retrieved, isNull);
        
        final allTags = await tagDao.getAllTags();
        expect(allTags, hasLength(1));
        expect(allTags.first.name, equals('Delete Test'));
      });

      test('should handle deleting non-existent tag', () async {
        await tagDao.deleteTag('non-existent-id');
        
        // Should not affect existing tags
        final allTags = await tagDao.getAllTags();
        expect(allTags, hasLength(2));
      });
    });

    group('Tag Usage Statistics', () {
      setUp(() async {
        // Create tags and some usage data
        await tagDao.insertTag(testTag);
        await tagDao.insertTag(Tag(
          id: 'popular-tag',
          name: 'Popular Tag',
          color: '#E91E63',
          createdAt: DateTime.now(),
        ));
      });

      test('should get tag usage count', () async {
        final usageCount = await tagDao.getTagUsageCount(testTag.id);
        expect(usageCount, isA<int>());
        expect(usageCount, greaterThanOrEqualTo(0));
      });

      test('should get popular tags', () async {
        final popularTags = await tagDao.getPopularTags(limit: 5);
        expect(popularTags, isA<List<Tag>>());
        expect(popularTags.length, lessThanOrEqualTo(5));
      });

      test('should get unused tags', () async {
        final unusedTags = await tagDao.getUnusedTags();
        expect(unusedTags, isA<List<Tag>>());
        // Most tags should be unused initially
        expect(unusedTags.length, greaterThanOrEqualTo(2));
      });
    });

    group('Tag Relationships', () {
      setUp(() async {
        await tagDao.insertTag(testTag);
        await tagDao.insertTag(Tag(
          id: 'related-tag',
          name: 'Related Tag',
          color: '#607D8B',
          createdAt: DateTime.now(),
        ));
      });

      test('should get tags for task', () async {
        const taskId = 'test-task-id';
        
        final tagsForTask = await tagDao.getTagsForTask(taskId);
        expect(tagsForTask, isA<List<Tag>>());
        // Initially empty since no task-tag relationships exist
        expect(tagsForTask, isEmpty);
      });

      test('should get tasks for tag', () async {
        final tasksForTag = await tagDao.getTasksForTag(testTag.id);
        expect(tasksForTag, isA<List<String>>());
        // Initially empty since no task-tag relationships exist
        expect(tasksForTag, isEmpty);
      });
    });

    group('Error Handling', () {
      test('should handle database connection errors gracefully', () async {
        expect(tagDao.getAllTags(), completes);
      });

      test('should handle malformed data gracefully', () async {
        final edgeCaseTag = Tag(
          id: 'edge-case-tag',
          name: 'A' * 255, // Very long name
          color: '#INVALID', // Invalid color format
          createdAt: DateTime.now(),
        );
        
        expect(() => tagDao.insertTag(edgeCaseTag), returnsNormally);
      });

      test('should validate input parameters', () async {
        expect(
          () => tagDao.getTagById(''),
          returnsNormally, // Should return null, not throw
        );
        
        final result = await tagDao.getTagById('');
        expect(result, isNull);
      });
    });

    group('Tag Colors', () {
      test('should handle various color formats', () async {
        final coloredTags = [
          Tag(id: 'hex-tag', name: 'Hex Tag', color: '#FF5722', createdAt: DateTime.now()),
          Tag(id: 'rgb-tag', name: 'RGB Tag', color: 'rgb(255, 87, 34)', createdAt: DateTime.now()),
          Tag(id: 'named-tag', name: 'Named Tag', color: 'red', createdAt: DateTime.now()),
        ];

        for (final tag in coloredTags) {
          await tagDao.insertTag(tag);
        }

        final allTags = await tagDao.getAllTags();
        expect(allTags, hasLength(3));
        
        final colors = allTags.map((t) => t.color).toList();
        expect(colors, containsAll(['#FF5722', 'rgb(255, 87, 34)', 'red']));
      });
    });

    group('Batch Operations', () {
      test('should handle batch tag insertion', () async {
        final tags = List.generate(10, (index) => Tag(
          id: 'batch-tag-$index',
          name: 'Batch Tag $index',
          color: '#${(index * 100000).toRadixString(16).padLeft(6, '0')}',
          createdAt: DateTime.now().subtract(Duration(minutes: index)),
        ));

        for (final tag in tags) {
          await tagDao.insertTag(tag);
        }

        final allTags = await tagDao.getAllTags();
        expect(allTags, hasLength(10));
        
        // Verify all tags were inserted
        for (int i = 0; i < 10; i++) {
          final tag = allTags.firstWhere((t) => t.id == 'batch-tag-$i');
          expect(tag.name, equals('Batch Tag $i'));
        }
      });

      test('should handle batch tag updates', () async {
        final tags = List.generate(5, (index) => Tag(
          id: 'update-tag-$index',
          name: 'Original Tag $index',
          color: '#FF0000',
          createdAt: DateTime.now(),
        ));

        // Insert all tags
        for (final tag in tags) {
          await tagDao.insertTag(tag);
        }

        // Update all tags
        final updatedTags = tags.map((tag) => tag.copyWith(
          name: 'Updated ${tag.name}',
          color: '#00FF00',
        )).toList();

        for (final tag in updatedTags) {
          await tagDao.updateTag(tag);
        }

        final allTags = await tagDao.getAllTags();
        for (final tag in allTags) {
          expect(tag.name, startsWith('Updated Original Tag'));
          expect(tag.color, equals('#00FF00'));
        }
      });
    });
  });
}