import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracker_app/domain/entities/project_category.dart';

void main() {
  group('ProjectCategory Entity', () {
    late DateTime testDate;
    late ProjectCategory systemCategory;
    late ProjectCategory userCategory;

    setUp(() {
      testDate = DateTime(2024, 1, 15, 10, 30);
      
      systemCategory = ProjectCategory.createSystem(
        id: 'sys_work',
        name: 'Work',
        iconName: 'briefcase',
        color: '#1976D2',
        sortOrder: 0,
        metadata: const {'domain': 'work'},
      );

      userCategory = ProjectCategory.createUser(
        name: 'Custom Category',
        iconName: 'star',
        color: '#6200EE',
        metadata: const {'custom': true},
      );
    });

    group('Factory Constructors', () {
      test('createSystem creates valid system category', () {
        final category = ProjectCategory.createSystem(
          id: 'test_id',
          name: 'Test Category',
          iconName: 'test-icon',
          color: '#FF0000',
        );

        expect(category.id, equals('test_id'));
        expect(category.name, equals('Test Category'));
        expect(category.iconName, equals('test-icon'));
        expect(category.color, equals('#FF0000'));
        expect(category.isSystemDefined, isTrue);
        expect(category.isActive, isTrue);
        expect(category.sortOrder, equals(0));
        expect(category.updatedAt, isNull); // System categories don't have update timestamps
      });

      test('createUser creates valid user category', () {
        expect(userCategory.id, isNotEmpty);
        expect(userCategory.name, equals('Custom Category'));
        expect(userCategory.iconName, equals('star'));
        expect(userCategory.color, equals('#6200EE'));
        expect(userCategory.isSystemDefined, isFalse);
        expect(userCategory.isActive, isTrue);
        expect(userCategory.createdAt, isNotNull);
        expect(userCategory.updatedAt, isNotNull);
      });
    });

    group('Properties and Getters', () {
      test('hasParent returns correct value', () {
        expect(systemCategory.hasParent, isFalse);
        
        // Create a user category that can be modified
        final childCategory = userCategory.copyWith(parentId: 'parent_id');
        expect(childCategory.hasParent, isTrue);
      });

      test('isUserDefined returns opposite of isSystemDefined', () {
        expect(systemCategory.isUserDefined, isFalse);
        expect(userCategory.isUserDefined, isTrue);
      });

      test('isVisible returns same as isActive', () {
        expect(systemCategory.isVisible, isTrue);
        
        final inactiveCategory = systemCategory.deactivate();
        expect(inactiveCategory.isVisible, isFalse);
      });

      test('displayName formats name correctly', () {
        final category = ProjectCategory.createUser(
          name: 'test name',
          iconName: 'icon',
          color: '#000000',
        );
        expect(category.displayName, equals('Test name'));

        final emptyCategory = ProjectCategory.createUser(
          name: '',
          iconName: 'icon',
          color: '#000000',
        );
        expect(emptyCategory.displayName, equals('Unnamed Category'));
      });
    });

    group('Validation', () {
      test('isValid returns true for valid categories', () {
        expect(systemCategory.isValid(), isTrue);
        expect(userCategory.isValid(), isTrue);
      });

      test('isValid returns false for invalid categories', () {
        // Empty ID
        final invalidId = ProjectCategory(
          id: '',
          name: 'Test',
          iconName: 'icon',
          color: '#000000',
          isSystemDefined: false,
          createdAt: testDate,
        );
        expect(invalidId.isValid(), isFalse);

        // Empty name
        final invalidName = ProjectCategory(
          id: 'test_id',
          name: '',
          iconName: 'icon',
          color: '#000000',
          isSystemDefined: false,
          createdAt: testDate,
        );
        expect(invalidName.isValid(), isFalse);

        // Empty icon name
        final invalidIcon = ProjectCategory(
          id: 'test_id',
          name: 'Test',
          iconName: '',
          color: '#000000',
          isSystemDefined: false,
          createdAt: testDate,
        );
        expect(invalidIcon.isValid(), isFalse);

        // Invalid color format
        final invalidColor = ProjectCategory(
          id: 'test_id',
          name: 'Test',
          iconName: 'icon',
          color: 'invalid',
          isSystemDefined: false,
          createdAt: testDate,
        );
        expect(invalidColor.isValid(), isFalse);

        // Self-referencing parent
        final selfRef = ProjectCategory(
          id: 'test_id',
          name: 'Test',
          iconName: 'icon',
          color: '#000000',
          parentId: 'test_id',
          isSystemDefined: false,
          createdAt: testDate,
        );
        expect(selfRef.isValid(), isFalse);

        // Negative sort order
        final negativeSortOrder = ProjectCategory(
          id: 'test_id',
          name: 'Test',
          iconName: 'icon',
          color: '#000000',
          sortOrder: -1,
          isSystemDefined: false,
          createdAt: testDate,
        );
        expect(negativeSortOrder.isValid(), isFalse);
      });
    });

    group('Modification Methods', () {
      test('update modifies user categories', () {
        final updated = userCategory.update(
          name: 'Updated Name',
          iconName: 'new-icon',
          color: '#FF0000',
        );

        expect(updated.name, equals('Updated Name'));
        expect(updated.iconName, equals('new-icon'));
        expect(updated.color, equals('#FF0000'));
        expect(updated.updatedAt, isNotNull);
        expect(updated.updatedAt, isNot(equals(userCategory.updatedAt)));
      });

      test('copyWith prevents modification of system categories', () {
        final updated = systemCategory.copyWith(
          name: 'New Name',
          iconName: 'new-icon',
        );

        // Should not change system category properties
        expect(updated.name, equals(systemCategory.name));
        expect(updated.iconName, equals(systemCategory.iconName));
        expect(updated.isSystemDefined, isTrue);
      });

      test('activate and deactivate work correctly', () {
        final deactivated = userCategory.deactivate();
        expect(deactivated.isActive, isFalse);
        expect(deactivated.updatedAt, isNotNull);

        final reactivated = deactivated.activate();
        expect(reactivated.isActive, isTrue);
      });

      test('system categories activation changes updatedAt to null', () {
        final deactivated = systemCategory.deactivate();
        expect(deactivated.isActive, isFalse);
        expect(deactivated.updatedAt, isNull);

        final reactivated = deactivated.activate();
        expect(reactivated.isActive, isTrue);
        expect(reactivated.updatedAt, isNull);
      });
    });

    group('Metadata Management', () {
      test('hasMetadata returns correct value', () {
        expect(systemCategory.hasMetadata, isTrue);
        
        final noMetadata = ProjectCategory.createUser(
          name: 'Test',
          iconName: 'icon',
          color: '#000000',
        );
        expect(noMetadata.hasMetadata, isFalse);
      });

      test('getMetadata retrieves values correctly', () {
        expect(systemCategory.getMetadata<String>('domain'), equals('work'));
        expect(systemCategory.getMetadata<String>('nonexistent'), isNull);
        expect(systemCategory.getMetadata<String>('nonexistent', 'default'), equals('default'));
      });

      test('setMetadata adds metadata to user categories', () {
        final withMetadata = userCategory.setMetadata('newKey', 'newValue');
        expect(withMetadata.getMetadata<String>('newKey'), equals('newValue'));
      });

      test('setMetadata does not modify system categories', () {
        final attempted = systemCategory.setMetadata('newKey', 'newValue');
        expect(attempted, equals(systemCategory));
        expect(attempted.getMetadata<String>('newKey'), isNull);
      });

      test('removeMetadata works for user categories', () {
        final withoutMetadata = userCategory.removeMetadata('custom');
        expect(withoutMetadata.getMetadata<bool>('custom'), isNull);
      });

      test('removeMetadata does not modify system categories', () {
        final attempted = systemCategory.removeMetadata('domain');
        expect(attempted, equals(systemCategory));
        expect(attempted.getMetadata<String>('domain'), equals('work'));
      });
    });

    group('JSON Serialization', () {
      test('toJson creates valid JSON', () {
        final json = systemCategory.toJson();
        
        expect(json['id'], equals(systemCategory.id));
        expect(json['name'], equals(systemCategory.name));
        expect(json['iconName'], equals(systemCategory.iconName));
        expect(json['color'], equals(systemCategory.color));
        expect(json['isSystemDefined'], equals(systemCategory.isSystemDefined));
        expect(json['isActive'], equals(systemCategory.isActive));
        expect(json['sortOrder'], equals(systemCategory.sortOrder));
        expect(json['metadata'], isA<Map<String, dynamic>>());
      });

      test('fromJson recreates category correctly', () {
        final json = systemCategory.toJson();
        final recreated = ProjectCategory.fromJson(json);

        expect(recreated.id, equals(systemCategory.id));
        expect(recreated.name, equals(systemCategory.name));
        expect(recreated.iconName, equals(systemCategory.iconName));
        expect(recreated.color, equals(systemCategory.color));
        expect(recreated.isSystemDefined, equals(systemCategory.isSystemDefined));
        expect(recreated.metadata, equals(systemCategory.metadata));
      });

      test('JSON roundtrip preserves all data', () {
        final json = userCategory.toJson();
        final recreated = ProjectCategory.fromJson(json);
        final jsonAgain = recreated.toJson();

        expect(jsonAgain, equals(json));
      });
    });

    group('Equality and Hashing', () {
      test('categories with same properties are equal', () {
        final category1 = ProjectCategory.createSystem(
          id: 'test',
          name: 'Test',
          iconName: 'icon',
          color: '#000000',
        );

        final category2 = ProjectCategory.createSystem(
          id: 'test',
          name: 'Test',
          iconName: 'icon',
          color: '#000000',
        );

        expect(category1, equals(category2));
        expect(category1.hashCode, equals(category2.hashCode));
      });

      test('categories with different properties are not equal', () {
        final category1 = ProjectCategory.createSystem(
          id: 'test1',
          name: 'Test',
          iconName: 'icon',
          color: '#000000',
        );

        final category2 = ProjectCategory.createSystem(
          id: 'test2',
          name: 'Test',
          iconName: 'icon',
          color: '#000000',
        );

        expect(category1, isNot(equals(category2)));
      });
    });

    group('String Representation', () {
      test('toString contains key information', () {
        final str = systemCategory.toString();
        expect(str, contains(systemCategory.id));
        expect(str, contains(systemCategory.name));
        expect(str, contains(systemCategory.iconName));
        expect(str, contains('isSystemDefined: true'));
        expect(str, contains('isActive: true'));
      });
    });

    group('Edge Cases', () {
      test('handles null parent correctly', () {
        final category = ProjectCategory(
          id: 'test',
          name: 'Test',
          iconName: 'icon',
          color: '#000000',
          parentId: null,
          isSystemDefined: false,
          createdAt: testDate,
        );

        expect(category.hasParent, isFalse);
        expect(category.isValid(), isTrue);
      });

      test('handles empty metadata correctly', () {
        final category = ProjectCategory(
          id: 'test',
          name: 'Test',
          iconName: 'icon',
          color: '#000000',
          isSystemDefined: false,
          createdAt: testDate,
          metadata: const {},
        );

        expect(category.hasMetadata, isFalse);
        expect(category.getMetadata<String>('any'), isNull);
      });

      test('handles extreme sort orders', () {
        final category = ProjectCategory(
          id: 'test',
          name: 'Test',
          iconName: 'icon',
          color: '#000000',
          isSystemDefined: false,
          sortOrder: 999999,
          createdAt: testDate,
        );

        expect(category.isValid(), isTrue);
        expect(category.sortOrder, equals(999999));
      });

      test('handles long category names', () {
        final longName = 'A' * 100;
        final category = ProjectCategory(
          id: 'test',
          name: longName,
          iconName: 'icon',
          color: '#000000',
          isSystemDefined: false,
          createdAt: testDate,
        );

        // The current validation doesn't check length, so it should be valid
        // This test verifies behavior rather than enforcing a specific validation rule
        expect(category.isValid(), isTrue);
        expect(category.name.length, equals(100));
      });
    });
  });
}