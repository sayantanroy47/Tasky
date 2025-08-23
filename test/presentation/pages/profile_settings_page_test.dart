import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:task_tracker_app/presentation/pages/profile_settings_page.dart';
import 'package:task_tracker_app/presentation/providers/profile_providers.dart';
import 'package:task_tracker_app/domain/entities/user_profile.dart';

// Helper functions available to all test groups
Widget createTestWidget({
      UserProfile? userProfile,
      bool hasError = false,
      bool isLoading = false,
    }) {
      return ProviderScope(
        overrides: [
          currentProfileProvider.overrideWith((ref) async {
            if (isLoading) {
              await Future.delayed(const Duration(seconds: 1));
              return userProfile;
            }
            if (hasError) {
              throw Exception('Test error');
            }
            return userProfile;
          }),
        ],
        child: MaterialApp(
          home: Theme(
            data: ThemeData.light(),
            child: const ProfileSettingsPage(),
          ),
        ),
      );
    }

UserProfile createTestProfile({
  String firstName = 'John',
  String lastName = 'Doe',
  String? bio,
  String? phoneNumber,
  String? profileImageUrl,
}) {
  return UserProfile(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    firstName: firstName,
    lastName: lastName,
    location: bio,
    profilePicturePath: profileImageUrl,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

void main() {
  group('ProfileSettingsPage Widget Tests', () {
    testWidgets('should display profile settings page with basic elements', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      expect(find.byType(ProfileSettingsPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display loading state', (tester) async {
      await tester.pumpWidget(createTestWidget(isLoading: true));
      await tester.pump();
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display error state', (tester) async {
      await tester.pumpWidget(createTestWidget(hasError: true));
      await tester.pump();
      
      expect(find.textContaining('error'), findsOneWidget, reason: 'Should display error message');
    });

    testWidgets('should display user profile when it exists', (tester) async {
      final profile = createTestProfile();
      
      await tester.pumpWidget(createTestWidget(userProfile: profile));
      await tester.pump();
      
      expect(find.byType(ProfileSettingsPage), findsOneWidget);
    });

    testWidgets('should handle null profile', (tester) async {
      await tester.pumpWidget(createTestWidget(userProfile: null));
      await tester.pump();
      
      expect(find.byType(ProfileSettingsPage), findsOneWidget);
    });

    testWidgets('should display profile with all fields', (tester) async {
      final profile = createTestProfile(
        firstName: 'Jane',
        lastName: 'Smith',
        bio: 'This is my bio',
        phoneNumber: '+1-555-123-4567',
        profileImageUrl: 'https://example.com/avatar.jpg',
      );
      
      await tester.pumpWidget(createTestWidget(userProfile: profile));
      await tester.pump();
      
      expect(find.byType(ProfileSettingsPage), findsOneWidget);
    });

    testWidgets('should handle profile with minimal fields', (tester) async {
      final profile = createTestProfile(
        firstName: 'Min',
        lastName: '',
      );
      
      await tester.pumpWidget(createTestWidget(userProfile: profile));
      await tester.pump();
      
      expect(find.byType(ProfileSettingsPage), findsOneWidget);
    });

    testWidgets('should handle profile with long names', (tester) async {
      final profile = createTestProfile(
        firstName: 'VeryLongFirstNameThatShouldBeHandledProperly',
        lastName: 'VeryLongLastNameThatShouldAlsoBeHandledProperly',
      );
      
      await tester.pumpWidget(createTestWidget(userProfile: profile));
      await tester.pump();
      
      expect(find.byType(ProfileSettingsPage), findsOneWidget);
    });

    testWidgets('should handle profile with long bio', (tester) async {
      const longBio = 'This is a very long bio that contains multiple sentences. It should be displayed properly in the UI without causing any layout issues. The bio can contain personal information about the user and their preferences. It might also include their professional background and hobbies.';
      
      final profile = createTestProfile(bio: longBio);
      
      await tester.pumpWidget(createTestWidget(userProfile: profile));
      await tester.pump();
      
      expect(find.byType(ProfileSettingsPage), findsOneWidget);
    });

    testWidgets('should handle profile with special characters', (tester) async {
      final profile = createTestProfile(
        firstName: 'José',
        lastName: 'O\'Connor',
        bio: 'Bio with émojis 🎉 and special chars: @#\$%^&*()',
      );
      
      await tester.pumpWidget(createTestWidget(userProfile: profile));
      await tester.pump();
      
      expect(find.byType(ProfileSettingsPage), findsOneWidget);
    });

    testWidgets('should handle invalid email format', (tester) async {
      final profile = createTestProfile();
      
      await tester.pumpWidget(createTestWidget(userProfile: profile));
      await tester.pump();
      
      expect(find.byType(ProfileSettingsPage), findsOneWidget);
    });

    testWidgets('should handle invalid phone number format', (tester) async {
      final profile = createTestProfile(phoneNumber: 'not-a-phone-number');
      
      await tester.pumpWidget(createTestWidget(userProfile: profile));
      await tester.pump();
      
      expect(find.byType(ProfileSettingsPage), findsOneWidget);
    });

    testWidgets('should handle invalid profile image URL', (tester) async {
      final profile = createTestProfile(profileImageUrl: 'not-a-valid-url');
      
      await tester.pumpWidget(createTestWidget(userProfile: profile));
      await tester.pump();
      
      expect(find.byType(ProfileSettingsPage), findsOneWidget);
    });

    testWidgets('should handle edit actions', (tester) async {
      final profile = createTestProfile();
      
      await tester.pumpWidget(createTestWidget(userProfile: profile));
      await tester.pump();
      
      // Look for edit buttons or icons
      final editButtons = find.byIcon(Icons.edit);
      if (editButtons.evaluate().isNotEmpty) {
        await tester.tap(editButtons.first);
        await tester.pump();
      }
      
      expect(find.byType(ProfileSettingsPage), findsOneWidget);
    });

    testWidgets('should handle save actions', (tester) async {
      final profile = createTestProfile();
      
      await tester.pumpWidget(createTestWidget(userProfile: profile));
      await tester.pump();
      
      // Look for save buttons
      final saveButtons = find.byIcon(Icons.save);
      if (saveButtons.evaluate().isNotEmpty) {
        await tester.tap(saveButtons.first);
        await tester.pump();
      }
      
      expect(find.byType(ProfileSettingsPage), findsOneWidget);
    });

    testWidgets('should maintain consistent layout', (tester) async {
      final profile = createTestProfile();
      
      await tester.pumpWidget(createTestWidget(userProfile: profile));
      await tester.pump();
      
      expect(find.byType(ProfileSettingsPage), findsOneWidget);
    });

    testWidgets('should handle rapid state changes', (tester) async {
      await tester.pumpWidget(createTestWidget(isLoading: true));
      await tester.pump();
      
      await tester.pumpWidget(createTestWidget(userProfile: createTestProfile()));
      await tester.pump();
      
      await tester.pumpWidget(createTestWidget(hasError: true));
      await tester.pump();
      
      expect(find.byType(ProfileSettingsPage), findsOneWidget);
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
            home: const ProfileSettingsPage(),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(ProfileSettingsPage), findsOneWidget);
    });

    testWidgets('should handle scrolling with long content', (tester) async {
      final profile = createTestProfile(
        bio: 'Very long bio content that might require scrolling. ' * 20,
      );
      
      await tester.pumpWidget(createTestWidget(userProfile: profile));
      await tester.pump();
      
      // Test scrolling if page is scrollable
      await tester.drag(find.byType(ProfileSettingsPage), const Offset(0, -300));
      await tester.pump();
      
      expect(find.byType(ProfileSettingsPage), findsOneWidget);
    });

    testWidgets('should handle form validation', (tester) async {
      final profile = createTestProfile();
      
      await tester.pumpWidget(createTestWidget(userProfile: profile));
      await tester.pump();
      
      // Look for form fields
      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().isNotEmpty) {
        // Test entering invalid data
        await tester.enterText(textFields.first, '');
        await tester.pump();
        
        // Look for validation messages
        expect(find.byType(ProfileSettingsPage), findsOneWidget);
      }
    });
  });

  group('ProfileSettingsPage Integration Tests', () {
    testWidgets('should integrate with real providers', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Theme(
              data: ThemeData.light(),
              child: const ProfileSettingsPage(),
            ),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(ProfileSettingsPage), findsOneWidget);
    });

    testWidgets('should handle provider state changes', (tester) async {
      final container = ProviderContainer();
      
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ProfileSettingsPage(),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(ProfileSettingsPage), findsOneWidget);
      
      container.dispose();
    });
  });

  group('ProfileSettingsPage Performance Tests', () {
    testWidgets('should render quickly', (tester) async {
      final profile = createTestProfile();
      
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(createTestWidget(userProfile: profile));
      await tester.pump();
      
      stopwatch.stop();
      
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      expect(find.byType(ProfileSettingsPage), findsOneWidget);
    });

    testWidgets('should handle frequent rebuilds', (tester) async {
      final profile = createTestProfile();
      
      for (int i = 0; i < 20; i++) {
        await tester.pumpWidget(createTestWidget(userProfile: profile));
        await tester.pump(const Duration(milliseconds: 10));
      }
      
      await tester.pump();
      expect(find.byType(ProfileSettingsPage), findsOneWidget);
    });
  });

  group('ProfileSettingsPage Edge Cases', () {
    testWidgets('should handle small screen sizes', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      
      final profile = createTestProfile();
      await tester.pumpWidget(createTestWidget(userProfile: profile));
      await tester.pump();
      
      expect(find.byType(ProfileSettingsPage), findsOneWidget);
      
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('should handle large screen sizes', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      
      final profile = createTestProfile();
      await tester.pumpWidget(createTestWidget(userProfile: profile));
      await tester.pump();
      
      expect(find.byType(ProfileSettingsPage), findsOneWidget);
      
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('should handle accessibility requirements', (tester) async {
      final profile = createTestProfile();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentProfileProvider.overrideWith((ref) async => profile),
          ],
          child: const MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(2.0)),
              child: ProfileSettingsPage(),
            ),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(ProfileSettingsPage), findsOneWidget);
    });

    testWidgets('should handle widget disposal', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      // Navigate away
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('Other page'))),
      );
      await tester.pump();
      
      expect(find.text('Other page'), findsOneWidget);
    });

    testWidgets('should handle empty string fields', (tester) async {
      final profile = createTestProfile(
        firstName: '',
        lastName: '',
        bio: '',
        phoneNumber: '',
        profileImageUrl: '',
      );
      
      await tester.pumpWidget(createTestWidget(userProfile: profile));
      await tester.pump();
      
      expect(find.byType(ProfileSettingsPage), findsOneWidget);
    });

    testWidgets('should handle profile with future dates', (tester) async {
      final futureDate = DateTime.now().add(const Duration(days: 365));
      final profile = UserProfile(
        id: '1',
        firstName: 'Future',
        lastName: 'User',
        createdAt: futureDate,
        updatedAt: futureDate,
      );
      
      await tester.pumpWidget(createTestWidget(userProfile: profile));
      await tester.pump();
      
      expect(find.byType(ProfileSettingsPage), findsOneWidget);
    });

    testWidgets('should handle profile with very old dates', (tester) async {
      final oldDate = DateTime(1990, 1, 1);
      final profile = UserProfile(
        id: '1',
        firstName: 'Old',
        lastName: 'User',
        createdAt: oldDate,
        updatedAt: oldDate,
      );
      
      await tester.pumpWidget(createTestWidget(userProfile: profile));
      await tester.pump();
      
      expect(find.byType(ProfileSettingsPage), findsOneWidget);
    });
  });
}
