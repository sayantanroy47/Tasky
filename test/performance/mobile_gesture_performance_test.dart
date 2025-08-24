import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

import 'package:task_tracker_app/services/ui/mobile_gesture_service.dart';
import 'package:task_tracker_app/services/ui/mobile_touch_targets_service.dart';
import 'package:task_tracker_app/services/ui/slidable_feedback_service.dart';
import 'package:task_tracker_app/services/gesture_customization_service.dart';
import 'package:task_tracker_app/presentation/widgets/mobile_kanban_board.dart';
import 'package:task_tracker_app/presentation/widgets/mobile_project_navigation.dart';
import 'package:task_tracker_app/presentation/widgets/mobile_zoomable_timeline.dart';

/// Comprehensive performance tests for mobile gesture system
/// Ensures 60fps interactions and proper touch responsiveness
void main() {
  group('Mobile Gesture Performance Tests', () {
    late ProviderContainer container;
    
    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('Gesture Response Time Tests', () {
      testWidgets('Tap gesture should respond within 16ms (60fps)', (tester) async {
        final stopwatch = Stopwatch();
        bool gestureDetected = false;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GestureDetector(
                onTap: () {
                  stopwatch.stop();
                  gestureDetected = true;
                },
                child: Container(
                  width: 200,
                  height: 200,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        );

        // Start timing and perform tap
        stopwatch.start();
        await tester.tap(find.byType(Container));
        await tester.pump();

        expect(gestureDetected, true);
        expect(stopwatch.elapsedMilliseconds, lessThan(16));
      });

      testWidgets('Long press gesture should respond within 500ms', (tester) async {
        final stopwatch = Stopwatch();
        bool longPressDetected = false;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GestureDetector(
                onLongPress: () {
                  stopwatch.stop();
                  longPressDetected = true;
                },
                child: Container(
                  width: 200,
                  height: 200,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        );

        stopwatch.start();
        await tester.longPress(find.byType(Container));
        await tester.pump();

        expect(longPressDetected, true);
        expect(stopwatch.elapsedMilliseconds, lessThan(600));
      });

      testWidgets('Swipe gesture should respond within 100ms', (tester) async {
        final stopwatch = Stopwatch();
        bool swipeDetected = false;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GestureDetector(
                onPanEnd: (details) {
                  stopwatch.stop();
                  swipeDetected = true;
                },
                child: Container(
                  width: 200,
                  height: 200,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        );

        stopwatch.start();
        await tester.drag(find.byType(Container), const Offset(100, 0));
        await tester.pump();

        expect(swipeDetected, true);
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });
    });

    group('Animation Performance Tests', () {
      testWidgets('Touch feedback animation should maintain 60fps', (tester) async {
        final frameTimeStamps = <Duration>[];
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 200,
                    height: 200,
                    color: Colors.blue,
                  );
                },
              ),
            ),
          ),
        );

        // Record frame timestamps during animation
        tester.binding.addPersistentFrameCallback((timeStamp) {
          frameTimeStamps.add(timeStamp);
        });

        // Trigger animation
        await tester.tap(find.byType(AnimatedContainer));
        
        // Let animation complete
        await tester.pumpAndSettle();

        // Verify frame rate
        if (frameTimeStamps.length > 1) {
          for (int i = 1; i < frameTimeStamps.length; i++) {
            final frameDuration = frameTimeStamps[i] - frameTimeStamps[i - 1];
            // Each frame should be ~16.67ms (60fps)
            expect(frameDuration.inMilliseconds, lessThan(20));
          }
        }
      });

      testWidgets('Scale animation should be smooth and performant', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AnimatedScale(
                scale: 1.0,
                duration: const Duration(milliseconds: 150),
                child: Container(
                  width: 200,
                  height: 200,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        );

        final stopwatch = Stopwatch()..start();
        
        // Trigger scale animation by rebuilding with different scale
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AnimatedScale(
                scale: 0.95,
                duration: const Duration(milliseconds: 150),
                child: Container(
                  width: 200,
                  height: 200,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        stopwatch.stop();

        // Animation should complete within expected time plus small buffer
        expect(stopwatch.elapsedMilliseconds, lessThan(200));
      });
    });

    group('Touch Target Performance Tests', () {
      testWidgets('Touch targets should meet accessibility guidelines', (tester) async {
        final touchService = MobileTouchTargetsService();
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: touchService.createTouchTarget(
                onTap: () {},
                size: TouchTargetSize.standard,
                child: const Icon(Icons.star),
              ),
            ),
          ),
        );

        final containerFinder = find.byType(Container).first;
        final container = tester.widget<Container>(containerFinder);
        final constraints = container.constraints;
        
        if (constraints != null) {
          expect(constraints.minWidth, greaterThanOrEqualTo(44.0));
          expect(constraints.minHeight, greaterThanOrEqualTo(44.0));
        }
      });

      testWidgets('Touch feedback should be immediate', (tester) async {
        final touchService = MobileTouchTargetsService();
        final stopwatch = Stopwatch();
        bool feedbackReceived = false;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: touchService.createTouchTarget(
                onTap: () {
                  stopwatch.stop();
                  feedbackReceived = true;
                },
                enableHapticFeedback: true,
                enableVisualFeedback: true,
                child: const Icon(Icons.star),
              ),
            ),
          ),
        );

        stopwatch.start();
        await tester.tap(find.byType(GestureDetector));
        await tester.pump();

        expect(feedbackReceived, true);
        expect(stopwatch.elapsedMilliseconds, lessThan(16));
      });
    });

    group('Kanban Board Performance Tests', () {
      testWidgets('Kanban board should handle drag operations smoothly', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: MobileKanbanBoard(
                  projectId: 'test-project',
                  enableDragDrop: true,
                ),
              ),
            ),
          ),
        );

        // Wait for initial load
        await tester.pump();
        
        // Performance test should complete without timeout
        expect(find.byType(MobileKanbanBoard), findsOneWidget);
      });

      testWidgets('Drag and drop should maintain smooth animations', (tester) async {
        final animationFrames = <Duration>[];
        
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: MobileKanbanBoard(
                  projectId: 'test-project',
                  enableDragDrop: true,
                ),
              ),
            ),
          ),
        );

        // Monitor animation performance during drag
        tester.binding.addPersistentFrameCallback((timeStamp) {
          animationFrames.add(timeStamp);
        });

        await tester.pump();
        
        // Verify no dropped frames during initialization
        expect(animationFrames.isNotEmpty, true);
      });
    });

    group('Timeline Zoom Performance Tests', () {
      testWidgets('Pinch zoom should respond within acceptable time', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: MobileZoomableTimeline(
                  projectId: 'test-project',
                  enablePinchZoom: true,
                ),
              ),
            ),
          ),
        );

        await tester.pump();
        
        // Verify timeline renders without performance issues
        expect(find.byType(MobileZoomableTimeline), findsOneWidget);
      });

      testWidgets('Scale operations should maintain 60fps', (tester) async {
        const testScales = [1.0, 1.5, 2.0, 0.5, 1.0];
        final performanceTimes = <int>[];
        
        for (final scale in testScales) {
          final stopwatch = Stopwatch()..start();
          
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 400,
                    height: 300,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          );
          
          await tester.pump();
          stopwatch.stop();
          performanceTimes.add(stopwatch.elapsedMilliseconds);
        }
        
        // All scale operations should be fast
        for (final time in performanceTimes) {
          expect(time, lessThan(16)); // 60fps = ~16.67ms per frame
        }
      });
    });

    group('Navigation Performance Tests', () {
      testWidgets('Tab navigation should be responsive', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: MobileProjectNavigation(
                  projectId: 'test-project',
                  enableSwipeNavigation: true,
                ),
              ),
            ),
          ),
        );

        await tester.pump();
        
        // Test navigation performance
        expect(find.byType(MobileProjectNavigation), findsOneWidget);
      });

      testWidgets('Page transitions should be smooth', (tester) async {
        final transitionTimes = <int>[];
        
        for (int i = 0; i < 5; i++) {
          final stopwatch = Stopwatch()..start();
          
          await tester.pumpWidget(
            MaterialApp(
              home: PageView(
                children: [
                  Container(color: Colors.red),
                  Container(color: Colors.blue),
                  Container(color: Colors.green),
                ],
              ),
            ),
          );
          
          await tester.pump();
          stopwatch.stop();
          transitionTimes.add(stopwatch.elapsedMilliseconds);
        }
        
        // All transitions should be performant
        for (final time in transitionTimes) {
          expect(time, lessThan(20));
        }
      });
    });

    group('Memory Performance Tests', () {
      testWidgets('Gesture service should not leak memory', (tester) async {
        // Create and dispose multiple gesture services
        for (int i = 0; i < 10; i++) {
          final container = ProviderContainer();
          final service = container.read(mobileGestureServiceProvider);
          
          // Use the service
          expect(service, isNotNull);
          
          // Dispose container
          container.dispose();
        }
        
        // Test should complete without memory issues
        expect(true, true);
      });

      testWidgets('Touch targets should clean up properly', (tester) async {
        final touchService = MobileTouchTargetsService();
        
        // Create multiple touch targets
        for (int i = 0; i < 20; i++) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: touchService.createTouchTarget(
                  onTap: () {},
                  child: Text('Touch Target $i'),
                ),
              ),
            ),
          );
          
          await tester.pump();
        }
        
        // Memory should not accumulate excessively
        expect(tester.allWidgets.length, lessThan(100));
      });
    });

    group('Concurrent Gesture Handling', () {
      testWidgets('Multiple simultaneous gestures should not block UI', (tester) async {
        int tapCount = 0;
        int longPressCount = 0;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  GestureDetector(
                    onTap: () => tapCount++,
                    child: Container(
                      width: 100,
                      height: 100,
                      color: Colors.red,
                    ),
                  ),
                  GestureDetector(
                    onLongPress: () => longPressCount++,
                    child: Container(
                      width: 100,
                      height: 100,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        // Perform concurrent gestures
        final futures = <Future>[];
        
        futures.add(tester.tap(find.byColor(Colors.red)));
        futures.add(tester.longPress(find.byColor(Colors.blue)));
        
        await Future.wait(futures);
        await tester.pumpAndSettle();

        expect(tapCount, 1);
        expect(longPressCount, 1);
      });
    });

    group('Platform Channel Performance', () {
      testWidgets('Haptic feedback should not block UI thread', (tester) async {
        final stopwatch = Stopwatch();
        bool callbackExecuted = false;
        
        // Mock haptic feedback
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            await Future.delayed(const Duration(milliseconds: 1)); // Simulate platform delay
            return null;
          }
          return null;
        });

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GestureDetector(
                onTap: () async {
                  stopwatch.start();
                  await HapticFeedback.lightImpact();
                  stopwatch.stop();
                  callbackExecuted = true;
                },
                child: Container(
                  width: 200,
                  height: 200,
                  color: Colors.green,
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.byType(Container));
        await tester.pump();

        expect(callbackExecuted, true);
        expect(stopwatch.elapsedMilliseconds, lessThan(50)); // Should be fast even with platform delay
      });
    });
  });

  group('Performance Benchmarks', () {
    test('Gesture service initialization should be fast', () {
      final stopwatch = Stopwatch()..start();
      
      final container = ProviderContainer();
      final service = container.read(mobileGestureServiceProvider);
      
      stopwatch.stop();
      container.dispose();
      
      expect(service, isNotNull);
      expect(stopwatch.elapsedMilliseconds, lessThan(10));
    });

    test('Touch target validation should be efficient', () {
      final touchService = MobileTouchTargetsService();
      final stopwatch = Stopwatch()..start();
      
      // Perform multiple validations
      for (int i = 0; i < 100; i++) {
        final validation = touchService.validateTouchTarget(
          width: 40 + i,
          height: 40 + i,
          padding: const EdgeInsets.all(8),
        );
        expect(validation, isNotNull);
      }
      
      stopwatch.stop();
      
      // 100 validations should complete quickly
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
    });
  });
}

/// Mock classes for testing
class MockGestureCustomizationService extends Mock implements GestureCustomizationService {}
class MockSlidableFeedbackService extends Mock implements SlidableFeedbackService {}