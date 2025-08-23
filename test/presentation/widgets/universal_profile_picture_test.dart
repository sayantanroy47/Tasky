import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:task_tracker_app/presentation/widgets/universal_profile_picture.dart';
import 'package:task_tracker_app/presentation/providers/profile_providers.dart';
import 'package:task_tracker_app/domain/entities/user_profile.dart';

Widget createTestWidget({required Widget child}) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: child,
      ),
    ),
  );
}

UserProfile createTestProfile({
  String firstName = 'John',
  String? lastName = 'Doe',
  String? profilePicturePath,
}) {
  return UserProfile(
    id: 'test-id',
    firstName: firstName,
    lastName: lastName,
    location: 'Test Location',
    profilePicturePath: profilePicturePath,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

void main() {
  group('UniversalProfilePicture Widget Tests', () {
    testWidgets('should display profile picture with user data', (tester) async {
      final profile = createTestProfile();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentProfileProvider.overrideWith((ref) async => profile),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: UniversalProfilePicture(size: 50),
            ),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(UniversalProfilePicture), findsOneWidget);
      expect(find.text('JD'), findsOneWidget); // Initials
    });

    testWidgets('should display single initial for single name', (tester) async {
      final profile = createTestProfile(firstName: 'Madonna', lastName: null);
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentProfileProvider.overrideWith((ref) async => profile),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: UniversalProfilePicture(size: 50),
            ),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(UniversalProfilePicture), findsOneWidget);
      expect(find.text('M'), findsOneWidget);
    });

    testWidgets('should handle loading state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentProfileProvider.overrideWith((ref) => Future.delayed(
              const Duration(seconds: 1),
              () => createTestProfile(),
            )),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: UniversalProfilePicture(size: 50),
            ),
          ),
        ),
      );
      await tester.pump(); // Don't wait for settle to catch loading state
      
      expect(find.byType(UniversalProfilePicture), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should handle error state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentProfileProvider.overrideWith((ref) => 
              Future.error('Profile load error')),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: UniversalProfilePicture(size: 50),
            ),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(UniversalProfilePicture), findsOneWidget);
      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('should handle different sizes', (tester) async {
      final profile = createTestProfile();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentProfileProvider.overrideWith((ref) async => profile),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  UniversalProfilePicture(size: 30),
                  UniversalProfilePicture(size: 100),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(UniversalProfilePicture), findsNWidgets(2));
    });

    testWidgets('should handle tap events', (tester) async {
      bool customTapCalled = false;
      final profile = createTestProfile();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentProfileProvider.overrideWith((ref) async => profile),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: UniversalProfilePicture(
                size: 50,
                customOnTap: () => customTapCalled = true,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      
      await tester.tap(find.byType(UniversalProfilePicture));
      await tester.pump();
      
      expect(customTapCalled, isTrue);
    });

    testWidgets('should handle border configuration', (tester) async {
      final profile = createTestProfile();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentProfileProvider.overrideWith((ref) async => profile),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  UniversalProfilePicture(size: 50, showBorder: true),
                  UniversalProfilePicture(size: 50, showBorder: false),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(UniversalProfilePicture), findsNWidgets(2));
    });

    testWidgets('should work with different themes', (tester) async {
      final profile = createTestProfile();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentProfileProvider.overrideWith((ref) async => profile),
          ],
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: const Scaffold(
              body: UniversalProfilePicture(size: 50),
            ),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(UniversalProfilePicture), findsOneWidget);
      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('should handle profile with custom image', (tester) async {
      final profile = createTestProfile(
        profilePicturePath: '/test/path/image.jpg',
      );
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentProfileProvider.overrideWith((ref) async => profile),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: UniversalProfilePicture(size: 50),
            ),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(UniversalProfilePicture), findsOneWidget);
    });

    testWidgets('should be accessible', (tester) async {
      final profile = createTestProfile();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentProfileProvider.overrideWith((ref) async => profile),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: UniversalProfilePicture(size: 50),
            ),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(UniversalProfilePicture), findsOneWidget);
      
      final semantics = tester.getSemantics(find.byType(UniversalProfilePicture));
      expect(semantics, isNotNull);
    });

    testWidgets('should handle empty profile data', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentProfileProvider.overrideWith((ref) async => null),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: UniversalProfilePicture(size: 50),
            ),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(UniversalProfilePicture), findsOneWidget);
      expect(find.text('U'), findsOneWidget); // Default initial
    });
  });

  group('UniversalProfilePictureSmall Widget Tests', () {
    testWidgets('should display small profile picture', (tester) async {
      final profile = createTestProfile();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentProfileProvider.overrideWith((ref) async => profile),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: UniversalProfilePictureSmall(),
            ),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(UniversalProfilePictureSmall), findsOneWidget);
      expect(find.text('JD'), findsOneWidget);
    });
  });

  group('UniversalProfilePictureLarge Widget Tests', () {
    testWidgets('should display large profile picture', (tester) async {
      final profile = createTestProfile();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentProfileProvider.overrideWith((ref) async => profile),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: UniversalProfilePictureLarge(),
            ),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(UniversalProfilePictureLarge), findsOneWidget);
      expect(find.text('JD'), findsOneWidget);
    });
  });
}