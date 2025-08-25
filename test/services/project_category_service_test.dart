import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:task_tracker_app/domain/entities/project_category.dart';
import 'package:task_tracker_app/domain/entities/category_with_usage_count.dart';
import 'package:task_tracker_app/domain/repositories/project_category_repository.dart';
import 'package:task_tracker_app/services/project_category_service.dart';

// Generate mocks
@GenerateMocks([ProjectCategoryRepository])
import 'project_category_service_test.mocks.dart';

void main() {
  group('ProjectCategoryService', () {
    late MockProjectCategoryRepository mockRepository;
    late ProjectCategoryService service;

    setUp(() {
      mockRepository = MockProjectCategoryRepository();
      service = ProjectCategoryService(mockRepository);
    });

    group('System Categories', () {
      test('systemCategories contains expected categories', () {
        final systemCategories = ProjectCategoryService.systemCategories;

        expect(systemCategories, isNotEmpty);
        expect(systemCategories.length, greaterThan(15)); // Should have at least 15 categories

        // Check for key system categories
        final categoryNames = systemCategories.map((c) => c.name.toLowerCase()).toList();
        expect(categoryNames, contains('work'));
        expect(categoryNames, contains('personal'));
        expect(categoryNames, contains('health'));
        expect(categoryNames, contains('finance'));
        expect(categoryNames, contains('education'));

        // Verify all are system defined
        expect(systemCategories.every((c) => c.isSystemDefined), isTrue);
        expect(systemCategories.every((c) => c.isActive), isTrue);
        expect(systemCategories.every((c) => c.isValid()), isTrue);
      });

      test('systemCategories have unique IDs', () {
        final systemCategories = ProjectCategoryService.systemCategories;
        final ids = systemCategories.map((c) => c.id).toList();
        final uniqueIds = ids.toSet();

        expect(ids.length, equals(uniqueIds.length));
      });

      test('systemCategories have valid colors', () {
        final systemCategories = ProjectCategoryService.systemCategories;
        final colorRegex = RegExp(r'^#[0-9A-Fa-f]{6}$');

        for (final category in systemCategories) {
          expect(colorRegex.hasMatch(category.color), isTrue, 
                 reason: 'Category ${category.name} has invalid color: ${category.color}');
        }
      });
    });

    group('seedSystemCategoriesIfNeeded', () {
      test('seeds categories when none exist', () async {
        when(mockRepository.getSystemCategories())
            .thenAnswer((_) async => []);
        when(mockRepository.createCategory(any))
            .thenAnswer((_) async {});

        await service.seedSystemCategoriesIfNeeded();

        verify(mockRepository.getSystemCategories()).called(1);
        verify(mockRepository.createCategory(any))
            .called(ProjectCategoryService.systemCategories.length);
      });

      test('does not seed when categories already exist', () async {
        final existingCategories = [
          ProjectCategory.createSystem(
            id: 'sys_work',
            name: 'Work',
            iconName: 'briefcase',
            color: '#1976D2',
          ),
        ];

        when(mockRepository.getSystemCategories())
            .thenAnswer((_) async => existingCategories);

        await service.seedSystemCategoriesIfNeeded();

        verify(mockRepository.getSystemCategories()).called(1);
        verifyNever(mockRepository.createCategory(any));
      });

      test('adds new system categories when some exist', () async {
        final existingCategories = [
          ProjectCategory.createSystem(
            id: 'sys_work',
            name: 'Work',
            iconName: 'briefcase',
            color: '#1976D2',
          ),
        ];

        when(mockRepository.getSystemCategories())
            .thenAnswer((_) async => existingCategories);
        when(mockRepository.createCategory(any))
            .thenAnswer((_) async {});

        await service.seedSystemCategoriesIfNeeded();

        verify(mockRepository.getSystemCategories()).called(1);
        // Should create all categories except the existing one
        verify(mockRepository.createCategory(any))
            .called(ProjectCategoryService.systemCategories.length - 1);
      });
    });

    group('Category Management', () {
      test('getActiveCategories returns categories from repository', () async {
        final mockCategories = [
          ProjectCategory.createSystem(
            id: 'sys_work',
            name: 'Work',
            iconName: 'briefcase',
            color: '#1976D2',
          ),
        ];

        when(mockRepository.getActiveCategories())
            .thenAnswer((_) async => mockCategories);

        final result = await service.getActiveCategories();

        expect(result, equals(mockCategories));
        verify(mockRepository.getActiveCategories()).called(1);
      });

      test('getCategoriesByDomain organizes categories correctly', () async {
        final mockCategories = [
          ProjectCategory.createSystem(
            id: 'sys_work',
            name: 'Work',
            iconName: 'briefcase',
            color: '#1976D2',
            metadata: const {'domain': 'work'},
          ),
          ProjectCategory.createSystem(
            id: 'sys_personal',
            name: 'Personal',
            iconName: 'user',
            color: '#388E3C',
            metadata: const {'domain': 'personal'},
          ),
          ProjectCategory.createSystem(
            id: 'sys_work2',
            name: 'Project',
            iconName: 'folder',
            color: '#607D8B',
            metadata: const {'domain': 'work'},
          ),
        ];

        when(mockRepository.getActiveCategories())
            .thenAnswer((_) async => mockCategories);

        final result = await service.getCategoriesByDomain();

        expect(result.keys, contains('work'));
        expect(result.keys, contains('personal'));
        expect(result['work']?.length, equals(2));
        expect(result['personal']?.length, equals(1));
      });

      test('getRootCategories returns root categories from repository', () async {
        final mockCategories = [
          ProjectCategory.createSystem(
            id: 'sys_work',
            name: 'Work',
            iconName: 'briefcase',
            color: '#1976D2',
          ),
        ];

        when(mockRepository.getRootCategories())
            .thenAnswer((_) async => mockCategories);

        final result = await service.getRootCategories();

        expect(result, equals(mockCategories));
        verify(mockRepository.getRootCategories()).called(1);
      });
    });

    group('User Category Creation', () {
      test('createUserCategory creates valid category', () async {
        when(mockRepository.isCategoryNameUnique('Custom Category'))
            .thenAnswer((_) async => true);
        when(mockRepository.getUserCategories())
            .thenAnswer((_) async => []);
        when(mockRepository.createCategory(any))
            .thenAnswer((_) async {});

        final result = await service.createUserCategory(
          name: 'Custom Category',
          iconName: 'star',
          color: '#6200EE',
        );

        expect(result.name, equals('Custom Category'));
        expect(result.iconName, equals('star'));
        expect(result.color, equals('#6200EE'));
        expect(result.isUserDefined, isTrue);
        expect(result.sortOrder, equals(1000)); // First user category

        verify(mockRepository.isCategoryNameUnique('Custom Category')).called(1);
        verify(mockRepository.getUserCategories()).called(1);
        verify(mockRepository.createCategory(any)).called(1);
      });

      test('createUserCategory validates inputs', () async {
        // Test invalid name
        expect(
          () => service.createUserCategory(
            name: '',
            iconName: 'star',
            color: '#6200EE',
          ),
          throwsA(isA<ArgumentError>()),
        );

        // Test invalid icon name (non-existent)
        expect(
          () => service.createUserCategory(
            name: 'Valid Name',
            iconName: 'nonexistent-icon',
            color: '#6200EE',
          ),
          throwsA(isA<ArgumentError>()),
        );

        // Test invalid color
        expect(
          () => service.createUserCategory(
            name: 'Valid Name',
            iconName: 'star',
            color: 'invalid-color',
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('createUserCategory checks name uniqueness', () async {
        when(mockRepository.isCategoryNameUnique('Existing Category'))
            .thenAnswer((_) async => false);

        expect(
          () => service.createUserCategory(
            name: 'Existing Category',
            iconName: 'star',
            color: '#6200EE',
          ),
          throwsA(isA<ArgumentError>()),
        );

        verify(mockRepository.isCategoryNameUnique('Existing Category')).called(1);
        verifyNever(mockRepository.createCategory(any));
      });

      test('createUserCategory assigns correct sort order', () async {
        final existingUserCategories = [
          ProjectCategory.createUser(
            name: 'Category 1',
            iconName: 'star',
            color: '#000000',
            sortOrder: 1000,
          ),
          ProjectCategory.createUser(
            name: 'Category 2',
            iconName: 'heart',
            color: '#000000',
            sortOrder: 1005,
          ),
        ];

        when(mockRepository.isCategoryNameUnique('New Category'))
            .thenAnswer((_) async => true);
        when(mockRepository.getUserCategories())
            .thenAnswer((_) async => existingUserCategories);
        when(mockRepository.createCategory(any))
            .thenAnswer((_) async {});

        final result = await service.createUserCategory(
          name: 'New Category',
          iconName: 'star',
          color: '#6200EE',
        );

        expect(result.sortOrder, equals(1006)); // Next after highest
      });
    });

    group('Category Updates', () {
      test('updateUserCategory updates valid category', () async {
        final existingCategory = ProjectCategory.createUser(
          name: 'Original Name',
          iconName: 'star',
          color: '#000000',
        );

        when(mockRepository.getCategoryById(existingCategory.id))
            .thenAnswer((_) async => existingCategory);
        when(mockRepository.isCategoryNameUnique('Updated Name', excludeId: existingCategory.id))
            .thenAnswer((_) async => true);
        when(mockRepository.updateCategory(any))
            .thenAnswer((_) async {});

        await service.updateUserCategory(
          existingCategory.id,
          name: 'Updated Name',
          iconName: 'heart',
          color: '#FF0000',
        );

        verify(mockRepository.getCategoryById(existingCategory.id)).called(1);
        verify(mockRepository.isCategoryNameUnique('Updated Name', excludeId: existingCategory.id)).called(1);
        verify(mockRepository.updateCategory(any)).called(1);
      });

      test('updateUserCategory prevents system category modification', () async {
        final systemCategory = ProjectCategory.createSystem(
          id: 'sys_work',
          name: 'Work',
          iconName: 'briefcase',
          color: '#1976D2',
        );

        when(mockRepository.getCategoryById(systemCategory.id))
            .thenAnswer((_) async => systemCategory);

        expect(
          () => service.updateUserCategory(
            systemCategory.id,
            name: 'Modified Name',
          ),
          throwsA(isA<ArgumentError>()),
        );

        verify(mockRepository.getCategoryById(systemCategory.id)).called(1);
        verifyNever(mockRepository.updateCategory(any));
      });
    });

    group('Category Deletion', () {
      test('deleteUserCategory deletes valid user category', () async {
        final userCategory = ProjectCategory.createUser(
          name: 'User Category',
          iconName: 'star',
          color: '#000000',
        );

        when(mockRepository.getCategoryById(userCategory.id))
            .thenAnswer((_) async => userCategory);
        when(mockRepository.getChildCategories(userCategory.id))
            .thenAnswer((_) async => []);
        when(mockRepository.deleteCategory(userCategory.id))
            .thenAnswer((_) async {});

        await service.deleteUserCategory(userCategory.id);

        verify(mockRepository.getCategoryById(userCategory.id)).called(1);
        verify(mockRepository.getChildCategories(userCategory.id)).called(1);
        verify(mockRepository.deleteCategory(userCategory.id)).called(1);
      });

      test('deleteUserCategory prevents system category deletion', () async {
        final systemCategory = ProjectCategory.createSystem(
          id: 'sys_work',
          name: 'Work',
          iconName: 'briefcase',
          color: '#1976D2',
        );

        when(mockRepository.getCategoryById(systemCategory.id))
            .thenAnswer((_) async => systemCategory);

        expect(
          () => service.deleteUserCategory(systemCategory.id),
          throwsA(isA<ArgumentError>()),
        );

        verify(mockRepository.getCategoryById(systemCategory.id)).called(1);
        verifyNever(mockRepository.deleteCategory(any));
      });

      test('deleteUserCategory prevents deletion of category with children', () async {
        final parentCategory = ProjectCategory.createUser(
          name: 'Parent Category',
          iconName: 'star',
          color: '#000000',
        );

        final childCategory = ProjectCategory.createUser(
          name: 'Child Category',
          iconName: 'heart',
          color: '#000000',
          parentId: parentCategory.id,
        );

        when(mockRepository.getCategoryById(parentCategory.id))
            .thenAnswer((_) async => parentCategory);
        when(mockRepository.getChildCategories(parentCategory.id))
            .thenAnswer((_) async => [childCategory]);

        expect(
          () => service.deleteUserCategory(parentCategory.id),
          throwsA(isA<ArgumentError>()),
        );

        verify(mockRepository.getCategoryById(parentCategory.id)).called(1);
        verify(mockRepository.getChildCategories(parentCategory.id)).called(1);
        verifyNever(mockRepository.deleteCategory(any));
      });
    });

    group('Search and Discovery', () {
      test('searchCategories delegates to repository', () async {
        final mockResults = [
          ProjectCategory.createUser(
            name: 'Work Category',
            iconName: 'briefcase',
            color: '#000000',
          ),
        ];

        when(mockRepository.searchCategories('work'))
            .thenAnswer((_) async => mockResults);

        final result = await service.searchCategories('work');

        expect(result, equals(mockResults));
        verify(mockRepository.searchCategories('work')).called(1);
      });

      test('searchCategories returns all active categories for empty query', () async {
        final mockCategories = [
          ProjectCategory.createUser(
            name: 'Category 1',
            iconName: 'star',
            color: '#000000',
          ),
        ];

        when(mockRepository.getActiveCategories())
            .thenAnswer((_) async => mockCategories);

        final result = await service.searchCategories('');

        expect(result, equals(mockCategories));
        verify(mockRepository.getActiveCategories()).called(1);
      });

      test('getPopularCategories returns sorted categories by usage', () async {
        final mockCategoriesWithUsage = [
          CategoryWithUsageCount(
            category: ProjectCategory.createUser(
              name: 'Popular',
              iconName: 'star',
              color: '#000000',
            ),
            usageCount: 10,
          ),
          CategoryWithUsageCount(
            category: ProjectCategory.createUser(
              name: 'Less Popular',
              iconName: 'heart',
              color: '#000000',
            ),
            usageCount: 5,
          ),
        ];

        when(service.getCategoriesWithUsage())
            .thenAnswer((_) async => mockCategoriesWithUsage);

        final result = await service.getPopularCategories(limit: 1);

        expect(result.length, equals(1));
        expect(result.first.name, equals('Popular'));
      });
    });

    group('Icon Recommendations', () {
      test('getRecommendedIcons returns relevant suggestions', () {
        final workRecommendations = service.getRecommendedIcons('work project');
        expect(workRecommendations, contains('briefcase'));
        expect(workRecommendations, contains('folder'));
        
        final personalRecommendations = service.getRecommendedIcons('personal family');
        expect(personalRecommendations, contains('user'));
        expect(personalRecommendations, contains('family'));
        
        final healthRecommendations = service.getRecommendedIcons('health fitness');
        expect(healthRecommendations, contains('heartbeat'));
        expect(healthRecommendations, contains('dumbbell'));
      });

      test('getRecommendedIcons limits results', () {
        final recommendations = service.getRecommendedIcons('test category', limit: 3);
        expect(recommendations.length, lessThanOrEqualTo(6)); // Default limit is 6
      });
    });

    group('Statistics', () {
      test('getCategoryStatistics returns comprehensive stats', () async {
        final allCategories = [
          ProjectCategory.createSystem(id: 'sys1', name: 'System1', iconName: 'icon1', color: '#000000'),
          ProjectCategory.createUser(name: 'User1', iconName: 'icon2', color: '#000000'),
        ];
        final activeCategories = allCategories;
        final systemCategories = [allCategories.first];
        final userCategories = [allCategories.last];
        final categoriesWithUsage = [
          CategoryWithUsageCount(category: allCategories.first, usageCount: 5),
        ];

        when(mockRepository.getAllCategories()).thenAnswer((_) async => allCategories);
        when(mockRepository.getActiveCategories()).thenAnswer((_) async => activeCategories);
        when(mockRepository.getSystemCategories()).thenAnswer((_) async => systemCategories);
        when(mockRepository.getUserCategories()).thenAnswer((_) async => userCategories);
        when(service.getCategoriesWithUsage()).thenAnswer((_) async => categoriesWithUsage);

        final stats = await service.getCategoryStatistics();

        expect(stats['total_categories'], equals(2));
        expect(stats['active_categories'], equals(2));
        expect(stats['system_categories'], equals(1));
        expect(stats['user_categories'], equals(1));
        expect(stats['categories_with_projects'], equals(1));
        expect(stats['total_projects_with_categories'], equals(5));
        expect(stats['domains'], isA<Map<String, int>>());
      });
    });

    group('Error Handling', () {
      test('handles repository errors gracefully', () async {
        when(mockRepository.getActiveCategories())
            .thenThrow(Exception('Database error'));

        expect(
          () => service.getActiveCategories(),
          throwsA(isA<Exception>()),
        );
      });

      test('validates category creation parameters', () async {
        // Test with whitespace-only name
        expect(
          () => service.createUserCategory(
            name: '   ',
            iconName: 'star',
            color: '#6200EE',
          ),
          throwsA(isA<ArgumentError>()),
        );

        // Test with too long name
        final longName = 'A' * 100;
        expect(
          () => service.createUserCategory(
            name: longName,
            iconName: 'star',
            color: '#6200EE',
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });
}