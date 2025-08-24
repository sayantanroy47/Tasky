import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:task_tracker_app/core/utils/category_utils.dart';
import 'package:task_tracker_app/domain/entities/project_category.dart';

void main() {
  group('CategoryUtils', () {
    late ProjectCategory testCategory;

    setUp(() {
      testCategory = ProjectCategory.createSystem(
        id: 'sys_work',
        name: 'Work',
        iconName: 'briefcase',
        color: '#1976D2',
        metadata: const {'domain': 'work'},
      );
    });

    group('Legacy Category Support', () {
      test('getCategoryIcon returns correct icons for legacy categories', () {
        expect(CategoryUtils.getCategoryIcon('work'), equals(PhosphorIcons.briefcase()));
        expect(CategoryUtils.getCategoryIcon('personal'), equals(PhosphorIcons.user()));
        expect(CategoryUtils.getCategoryIcon('shopping'), equals(PhosphorIcons.shoppingCart()));
        expect(CategoryUtils.getCategoryIcon('health'), equals(PhosphorIcons.heartbeat()));
        expect(CategoryUtils.getCategoryIcon('finance'), equals(PhosphorIcons.wallet()));
        expect(CategoryUtils.getCategoryIcon('unknown'), equals(PhosphorIcons.tag()));
      });

      test('getCategoryIcon is case insensitive', () {
        expect(CategoryUtils.getCategoryIcon('WORK'), equals(PhosphorIcons.briefcase()));
        expect(CategoryUtils.getCategoryIcon('Work'), equals(PhosphorIcons.briefcase()));
        expect(CategoryUtils.getCategoryIcon('WoRk'), equals(PhosphorIcons.briefcase()));
      });

      test('getCategoryColor returns correct colors for legacy categories', () {
        final workColor = CategoryUtils.getCategoryColor('work');
        expect(workColor.value, equals(const Color(0xFF1976D2).value));

        final personalColor = CategoryUtils.getCategoryColor('personal');
        expect(personalColor.value, equals(const Color(0xFF388E3C).value));

        final unknownColor = CategoryUtils.getCategoryColor('unknown');
        expect(unknownColor.value, equals(const Color(0xFF6200EE).value));
      });

      test('getCategoryDisplayName formats names correctly', () {
        expect(CategoryUtils.getCategoryDisplayName('work'), equals('Work'));
        expect(CategoryUtils.getCategoryDisplayName('PERSONAL'), equals('Personal'));
        expect(CategoryUtils.getCategoryDisplayName(''), equals('General'));
        expect(CategoryUtils.getCategoryDisplayName('multiple-words'), equals('Multiple-words'));
      });

      test('getAllCategories returns complete list', () {
        final categories = CategoryUtils.getAllCategories();
        expect(categories, isNotEmpty);
        expect(categories.length, equals(20)); // All legacy categories

        // Check structure
        for (final category in categories) {
          expect(category['name'], isA<String>());
          expect(category['icon'], isA<IconData>());
          expect(category['color'], isA<Color>());
        }

        // Check specific entries
        final workCategory = categories.firstWhere((c) => c['name'] == 'work');
        expect(workCategory['icon'], equals(PhosphorIcons.briefcase()));
      });

      test('hasCustomIcon correctly identifies custom vs default icons', () {
        expect(CategoryUtils.hasCustomIcon('work'), isTrue);
        expect(CategoryUtils.hasCustomIcon('personal'), isTrue);
        expect(CategoryUtils.hasCustomIcon('unknown'), isFalse);
        expect(CategoryUtils.hasCustomIcon('default'), isFalse);
      });
    });

    group('ProjectCategory Entity Support', () {
      test('getCategoryIconFromEntity returns correct icon', () {
        final icon = CategoryUtils.getCategoryIconFromEntity(testCategory);
        expect(icon, equals(PhosphorIcons.briefcase()));
      });

      test('getCategoryIconFromEntity handles invalid icon names', () {
        final categoryWithInvalidIcon = testCategory.copyWith(iconName: 'nonexistent-icon');
        final icon = CategoryUtils.getCategoryIconFromEntity(categoryWithInvalidIcon);
        expect(icon, equals(PhosphorIcons.tag())); // Default fallback
      });

      test('getCategoryColorFromEntity parses hex colors correctly', () {
        final color = CategoryUtils.getCategoryColorFromEntity(testCategory);
        expect(color.value, equals(const Color(0xFF1976D2).value));
      });

      test('getCategoryColorFromEntity handles invalid color format', () {
        final categoryWithInvalidColor = testCategory.copyWith(color: 'invalid-color');
        final color = CategoryUtils.getCategoryColorFromEntity(categoryWithInvalidColor);
        expect(color.value, equals(const Color(0xFF6200EE).value)); // Default color
      });

      test('getCategoryColorFromEntity uses theme fallback', () {
        const primaryColor = Color(0xFFFF5722);
        final themeData = ThemeData(colorScheme: const ColorScheme.light(primary: primaryColor));
        
        final categoryWithInvalidColor = testCategory.copyWith(color: 'invalid');
        final color = CategoryUtils.getCategoryColorFromEntity(categoryWithInvalidColor, theme: themeData);
        expect(color.value, equals(primaryColor.value));
      });

      test('buildCategoryIconContainerFromEntity creates valid widget', () {
        final widget = CategoryUtils.buildCategoryIconContainerFromEntity(
          category: testCategory,
          size: 48.0,
        );

        expect(widget, isA<Container>());
        
        final container = widget as Container;
        expect(container.constraints?.minWidth, equals(48.0));
        expect(container.constraints?.minHeight, equals(48.0));
        expect(container.child, isA<Icon>());
      });
    });

    group('Icon Management', () {
      test('getIconByName returns correct icons', () {
        expect(CategoryUtils.getIconByName('briefcase'), equals(PhosphorIcons.briefcase()));
        expect(CategoryUtils.getIconByName('user'), equals(PhosphorIcons.user()));
        expect(CategoryUtils.getIconByName('heart'), equals(PhosphorIcons.heart()));
        expect(CategoryUtils.getIconByName('nonexistent'), equals(PhosphorIcons.tag()));
      });

      test('getAllIconsByDomain returns organized icons', () {
        final iconsByDomain = CategoryUtils.getAllIconsByDomain();
        expect(iconsByDomain, isNotEmpty);
        expect(iconsByDomain.keys, contains('work'));
        expect(iconsByDomain.keys, contains('personal'));
        expect(iconsByDomain.keys, contains('creative'));
        
        expect(iconsByDomain['work'], isNotEmpty);
        expect(iconsByDomain['work']!['briefcase'], equals(PhosphorIcons.briefcase()));
      });

      test('getPopularIcons returns popular icon set', () {
        final popularIcons = CategoryUtils.getPopularIcons();
        expect(popularIcons, isNotEmpty);
        expect(popularIcons.length, lessThanOrEqualTo(15)); // Should be reasonable number
        expect(popularIcons.keys, contains('briefcase'));
        expect(popularIcons.keys, contains('user'));
        expect(popularIcons.keys, contains('heart'));
      });

      test('getDomainDisplayNames returns formatted names', () {
        final displayNames = CategoryUtils.getDomainDisplayNames();
        expect(displayNames, isNotEmpty);
        expect(displayNames['work'], equals('Work & Business'));
        expect(displayNames['personal'], equals('Personal & Lifestyle'));
        expect(displayNames['creative'], equals('Creative & Arts'));
      });

      test('searchIcons finds matching icons', () {
        final workIcons = CategoryUtils.searchIcons('work');
        expect(workIcons, contains('briefcase'));

        final heartIcons = CategoryUtils.searchIcons('heart');
        expect(heartIcons, contains('heart'));
        expect(heartIcons, contains('heartbeat'));

        final emptyResults = CategoryUtils.searchIcons('nonexistenticon');
        expect(emptyResults, isEmpty);

        final allIcons = CategoryUtils.searchIcons('');
        expect(allIcons, isNotEmpty);
      });

      test('isValidIconName validates icon names', () {
        expect(CategoryUtils.isValidIconName('briefcase'), isTrue);
        expect(CategoryUtils.isValidIconName('user'), isTrue);
        expect(CategoryUtils.isValidIconName('nonexistent-icon'), isFalse);
        expect(CategoryUtils.isValidIconName(''), isFalse);
      });

      test('getIconDomain returns correct domains', () {
        expect(CategoryUtils.getIconDomain('briefcase'), equals('work'));
        expect(CategoryUtils.getIconDomain('user'), equals('personal'));
        expect(CategoryUtils.getIconDomain('paint-brush'), equals('creative'));
        expect(CategoryUtils.getIconDomain('nonexistent'), isNull);
      });

      test('getIconsForDomain returns domain-specific icons', () {
        final workIcons = CategoryUtils.getIconsForDomain('work');
        expect(workIcons, contains('briefcase'));
        expect(workIcons, contains('presentation'));
        expect(workIcons, isNot(contains('user'))); // Personal icon

        final personalIcons = CategoryUtils.getIconsForDomain('personal');
        expect(personalIcons, contains('user'));
        expect(personalIcons, contains('heart'));
        expect(personalIcons, isNot(contains('briefcase'))); // Work icon

        final invalidDomainIcons = CategoryUtils.getIconsForDomain('nonexistent');
        expect(invalidDomainIcons, isEmpty);
      });

      test('getIconStatistics returns valid stats', () {
        final stats = CategoryUtils.getIconStatistics();
        expect(stats, isNotEmpty);
        expect(stats['total_icons'], isA<int>());
        expect(stats['total_domains'], isA<int>());
        expect(stats['total_icons'], greaterThan(100)); // Should have many icons
        expect(stats['total_domains'], greaterThan(10)); // Should have multiple domains
      });
    });

    group('Icon Recommendations', () {
      test('getRecommendedIcons suggests work-related icons', () {
        final recommendations = CategoryUtils.getRecommendedIcons('work office business');
        expect(recommendations, contains('briefcase'));
        expect(recommendations, contains('building-office'));
        expect(recommendations.length, lessThanOrEqualTo(6));
      });

      test('getRecommendedIcons suggests personal icons', () {
        final recommendations = CategoryUtils.getRecommendedIcons('personal family home');
        expect(recommendations, contains('user'));
        expect(recommendations, contains('family'));
        expect(recommendations, contains('house'));
      });

      test('getRecommendedIcons suggests health icons', () {
        final recommendations = CategoryUtils.getRecommendedIcons('health medical fitness');
        expect(recommendations, contains('heartbeat'));
        expect(recommendations, contains('dumbbell'));
      });

      test('getRecommendedIcons suggests creative icons', () {
        final recommendations = CategoryUtils.getRecommendedIcons('creative art design paint');
        expect(recommendations, contains('paint-brush'));
        expect(recommendations, contains('palette'));
      });

      test('getRecommendedIcons suggests technology icons', () {
        final recommendations = CategoryUtils.getRecommendedIcons('tech computer code software');
        expect(recommendations, contains('laptop'));
        expect(recommendations, contains('code'));
      });

      test('getRecommendedIcons handles empty input', () {
        final recommendations = CategoryUtils.getRecommendedIcons('');
        expect(recommendations, isNotEmpty); // Should still return some suggestions
        expect(recommendations.length, lessThanOrEqualTo(6));
      });

      test('getRecommendedIcons handles unknown keywords', () {
        final recommendations = CategoryUtils.getRecommendedIcons('xyz unknown category');
        expect(recommendations, isNotEmpty); // Should fall back to popular icons
        expect(recommendations.length, lessThanOrEqualTo(6));
      });
    });

    group('Migration Support', () {
      test('legacyCategoryToEntity converts known legacy categories', () {
        final workEntity = CategoryUtils.legacyCategoryToEntity('work');
        expect(workEntity, isNotNull);
        expect(workEntity!.name, equals('Work'));
        expect(workEntity.iconName, equals('briefcase'));
        expect(workEntity.color, equals('#1976D2'));
        expect(workEntity.isSystemDefined, isTrue);
        expect(workEntity.getMetadata<bool>('isLegacy'), isTrue);
        expect(workEntity.getMetadata<String>('originalName'), equals('work'));

        final personalEntity = CategoryUtils.legacyCategoryToEntity('personal');
        expect(personalEntity, isNotNull);
        expect(personalEntity!.name, equals('Personal'));
        expect(personalEntity.iconName, equals('user'));
        expect(personalEntity.color, equals('#388E3C'));
      });

      test('legacyCategoryToEntity handles empty input', () {
        final result = CategoryUtils.legacyCategoryToEntity('');
        expect(result, isNull);
      });

      test('legacyCategoryToEntity handles unknown categories', () {
        final unknownEntity = CategoryUtils.legacyCategoryToEntity('unknown');
        expect(unknownEntity, isNotNull);
        expect(unknownEntity!.iconName, equals('tag')); // Default icon
        expect(unknownEntity.color, equals('#6200EE')); // Default color
      });

      test('isLegacyCategory identifies legacy categories correctly', () {
        expect(CategoryUtils.isLegacyCategory('work'), isTrue);
        expect(CategoryUtils.isLegacyCategory('personal'), isTrue);
        expect(CategoryUtils.isLegacyCategory('HEALTH'), isTrue); // Case insensitive
        expect(CategoryUtils.isLegacyCategory('unknown'), isFalse);
        expect(CategoryUtils.isLegacyCategory('custom'), isFalse);
        expect(CategoryUtils.isLegacyCategory(''), isFalse);
      });

      test('getAllLegacyCategories returns complete list', () {
        final legacyCategories = CategoryUtils.getAllLegacyCategories();
        expect(legacyCategories, isNotEmpty);
        expect(legacyCategories.length, equals(20));
        expect(legacyCategories, contains('work'));
        expect(legacyCategories, contains('personal'));
        expect(legacyCategories, contains('health'));
        expect(legacyCategories, contains('finance'));
        expect(legacyCategories, contains('urgent'));
        expect(legacyCategories, contains('important'));
      });
    });

    group('Widget Building', () {
      testWidgets('buildCategoryIconContainer creates proper container', (tester) async {
        const testSize = 48.0;
        const testCategory = 'work';
        
        final widget = CategoryUtils.buildCategoryIconContainer(
          category: testCategory,
          size: testSize,
        );

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(body: widget),
        ));

        expect(find.byType(Container), findsOneWidget);
        expect(find.byType(Icon), findsOneWidget);

        final container = tester.widget<Container>(find.byType(Container));
        expect(container.constraints?.minWidth, equals(testSize));
        expect(container.constraints?.minHeight, equals(testSize));

        final icon = tester.widget<Icon>(find.byType(Icon));
        expect(icon.icon, equals(PhosphorIcons.briefcase()));
        expect(icon.size, equals(testSize * 0.5)); // Default icon size ratio
      });

      testWidgets('buildCategoryIconContainer respects custom parameters', (tester) async {
        const testSize = 64.0;
        const iconSizeRatio = 0.75;
        const borderRadius = 12.0;
        
        final widget = CategoryUtils.buildCategoryIconContainer(
          category: 'personal',
          size: testSize,
          iconSizeRatio: iconSizeRatio,
          borderRadius: borderRadius,
        );

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(body: widget),
        ));

        final icon = tester.widget<Icon>(find.byType(Icon));
        expect(icon.size, equals(testSize * iconSizeRatio));
        expect(icon.icon, equals(PhosphorIcons.user()));
      });

      testWidgets('buildCategoryIconContainerFromEntity works with ProjectCategory', (tester) async {
        const testSize = 56.0;
        
        final widget = CategoryUtils.buildCategoryIconContainerFromEntity(
          category: testCategory,
          size: testSize,
        );

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(body: widget),
        ));

        expect(find.byType(Container), findsOneWidget);
        expect(find.byType(Icon), findsOneWidget);

        final icon = tester.widget<Icon>(find.byType(Icon));
        expect(icon.icon, equals(PhosphorIcons.briefcase()));
      });
    });

    group('Edge Cases and Error Handling', () {
      test('handles null and empty inputs gracefully', () {
        expect(CategoryUtils.getCategoryIcon(''), equals(PhosphorIcons.tag()));
        expect(CategoryUtils.getCategoryDisplayName(''), equals('General'));
        expect(CategoryUtils.searchIcons(''), isNotEmpty);
        expect(CategoryUtils.getRecommendedIcons(''), isNotEmpty);
      });

      test('handles special characters in category names', () {
        expect(CategoryUtils.getCategoryDisplayName('work-project'), equals('Work-project'));
        expect(CategoryUtils.getCategoryDisplayName('work_project'), equals('Work_project'));
        expect(CategoryUtils.getCategoryDisplayName('work.project'), equals('Work.project'));
      });

      test('handles very long category names', () {
        final longName = 'A' * 200;
        expect(CategoryUtils.getCategoryDisplayName(longName), startsWith('A'));
        expect(CategoryUtils.getCategoryDisplayName(longName).length, equals(200));
      });

      test('handles Unicode characters in category names', () {
        expect(CategoryUtils.getCategoryDisplayName('项目'), equals('项目'));
        expect(CategoryUtils.getCategoryDisplayName('работа'), equals('Работа'));
        expect(CategoryUtils.getCategoryDisplayName('プロジェクト'), equals('プロジェクト'));
      });
    });
  });
}