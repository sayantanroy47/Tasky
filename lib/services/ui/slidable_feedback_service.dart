import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import 'package:just_audio/just_audio.dart';

import 'slidable_action_service.dart';

/// Comprehensive feedback service for slidable actions
/// Provides haptic, audio, visual feedback with accessibility support
class SlidableFeedbackService {
  static AudioPlayer? _audioPlayer;
  static bool _audioEnabled = true;
  static bool _hapticsEnabled = true;
  static bool _visualFeedbackEnabled = true;

  /// Initialize the feedback service
  static Future<void> initialize() async {
    try {
      _audioPlayer = AudioPlayer();
    } catch (e) {
      debugPrint('SlidableFeedbackService: Audio initialization failed - $e');
      _audioEnabled = false;
    }
  }

  /// Dispose resources
  static Future<void> dispose() async {
    await _audioPlayer?.dispose();
    _audioPlayer = null;
  }

  /// Provides comprehensive feedback for slidable actions
  static Future<void> provideFeedback(
    SlidableActionType actionType, {
    bool includeHaptic = true,
    bool includeAudio = true,
    bool includeVisual = true,
  }) async {
    if (includeHaptic && _hapticsEnabled) {
      await _provideHapticFeedback(actionType);
    }

    if (includeAudio && _audioEnabled) {
      await _provideAudioFeedback(actionType);
    }

    if (includeVisual && _visualFeedbackEnabled) {
      _provideVisualFeedback(actionType);
    }
  }

  /// Provides haptic feedback based on action type
  static Future<void> _provideHapticFeedback(SlidableActionType actionType) async {
    switch (actionType) {
      case SlidableActionType.complete:
        await HapticFeedback.mediumImpact();
        // Double tap for completion satisfaction
        await Future.delayed(const Duration(milliseconds: 50));
        await HapticFeedback.lightImpact();
        break;
      
      case SlidableActionType.edit:
        await HapticFeedback.lightImpact();
        break;
      
      case SlidableActionType.destructive:
        await HapticFeedback.heavyImpact();
        // Warning pattern: heavy -> pause -> medium
        await Future.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.mediumImpact();
        break;
      
      case SlidableActionType.archive:
        await HapticFeedback.mediumImpact();
        break;
      
      case SlidableActionType.neutral:
        await HapticFeedback.selectionClick();
        break;
      
      case SlidableActionType.error:
        // Strong feedback for errors
        await HapticFeedback.vibrate();
        break;
    }
  }

  /// Provides audio feedback based on action type
  static Future<void> _provideAudioFeedback(SlidableActionType actionType) async {
    if (_audioPlayer == null) return;

    try {
      switch (actionType) {
        case SlidableActionType.complete:
          await _playSystemSound('complete');
          break;
        
        case SlidableActionType.edit:
          await _playSystemSound('edit');
          break;
        
        case SlidableActionType.destructive:
          await _playSystemSound('destructive');
          break;
        
        case SlidableActionType.archive:
          await _playSystemSound('archive');
          break;
        
        case SlidableActionType.neutral:
          await _playSystemSound('neutral');
          break;
        
        case SlidableActionType.error:
          await _playSystemSound('error');
          break;
      }
    } catch (e) {
      debugPrint('SlidableFeedbackService: Audio playback failed - $e');
    }
  }

  /// Provides visual feedback through system methods
  static void _provideVisualFeedback(SlidableActionType actionType) {
    // Visual feedback would typically be handled by the UI components
    // This could trigger custom animations or state changes
    debugPrint('SlidableFeedbackService: Visual feedback for $actionType');
  }

  /// Plays system sounds for different actions
  static Future<void> _playSystemSound(String soundType) async {
    // For now, use system sounds. In future, custom sounds could be added
    switch (soundType) {
      case 'complete':
        SystemSound.play(SystemSoundType.click);
        break;
      case 'destructive':
        SystemSound.play(SystemSoundType.alert);
        break;
      default:
        SystemSound.play(SystemSoundType.click);
        break;
    }
  }

  /// Creates a vibration pattern for complex actions
  static Future<void> createCustomVibrationPattern(List<int> pattern) async {
    for (int i = 0; i < pattern.length; i++) {
      if (i % 2 == 0) {
        // Even indices are vibration durations
        await HapticFeedback.mediumImpact();
      }
      await Future.delayed(Duration(milliseconds: pattern[i]));
    }
  }

  /// Provides accessibility feedback for screen readers using proper Semantics API
  static Future<void> provideAccessibilityFeedback(
    SlidableActionType actionType,
    String actionLabel,
  ) async {
    String announcementText;
    const TextDirection textDirection = TextDirection.ltr;
    
    switch (actionType) {
      case SlidableActionType.complete:
        announcementText = 'Task marked as complete';
        break;
      case SlidableActionType.edit:
        announcementText = 'Opening $actionLabel for editing';
        break;
      case SlidableActionType.destructive:
        announcementText = 'Warning: $actionLabel action performed';
        break;
      case SlidableActionType.archive:
        announcementText = '$actionLabel archived';
        break;
      case SlidableActionType.neutral:
        announcementText = 'Performed $actionLabel';
        break;
      
      case SlidableActionType.error:
        announcementText = 'Error: Unable to perform $actionLabel';
        break;
    }

    try {
      // Use proper Semantics API for accessibility announcements
      await SemanticsService.announce(announcementText, textDirection);
    } catch (e) {
      // Fallback to debug print if SemanticsService fails
      debugPrint('Accessibility announcement: $announcementText (Error: $e)');
    }
  }

  /// Provides contextual help for gestures using proper accessibility APIs
  static Future<void> announceGestureHint(String hint) async {
    try {
      // Use proper Semantics API for gesture hints
      await SemanticsService.announce('Hint: $hint', TextDirection.ltr);
    } catch (e) {
      // Fallback to debug print if SemanticsService fails
      debugPrint('Gesture hint: $hint (Error: $e)');
    }
  }

  /// Creates a success celebration feedback
  static Future<void> celebrateSuccess() async {
    if (!_hapticsEnabled) return;

    // Success celebration pattern
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.lightImpact();
  }

  /// Creates an error/warning feedback
  static Future<void> signalError() async {
    if (!_hapticsEnabled) return;

    // Error pattern: heavy -> pause -> heavy
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 200));
    await HapticFeedback.heavyImpact();
  }

  /// Settings management
  static void setHapticsEnabled(bool enabled) {
    _hapticsEnabled = enabled;
  }

  static void setAudioEnabled(bool enabled) {
    _audioEnabled = enabled;
  }

  static void setVisualFeedbackEnabled(bool enabled) {
    _visualFeedbackEnabled = enabled;
  }

  static bool get hapticsEnabled => _hapticsEnabled;
  static bool get audioEnabled => _audioEnabled;
  static bool get visualFeedbackEnabled => _visualFeedbackEnabled;

  /// Provides feedback for slide gesture start
  static Future<void> onSlideStart(SlidableActionType actionType) async {
    if (_hapticsEnabled) {
      await HapticFeedback.selectionClick();
    }
  }

  /// Provides feedback for slide gesture progress
  static Future<void> onSlideProgress(double progress, SlidableActionType actionType) async {
    // Progressive haptic feedback based on slide distance
    if (_hapticsEnabled && progress > 0.5) {
      await HapticFeedback.selectionClick();
    }
  }

  /// Provides feedback for slide gesture completion
  static Future<void> onSlideComplete(SlidableActionType actionType, String actionLabel) async {
    await provideFeedback(actionType);
  }

  /// Provides feedback for slide gesture cancellation
  static Future<void> onSlideCancel() async {
    if (_hapticsEnabled) {
      await HapticFeedback.lightImpact();
    }
  }

  /// Creates contextual tutorials with feedback
  static Future<void> playTutorialFeedback(String tutorialStep) async {
    switch (tutorialStep) {
      case 'slide_hint':
        await HapticFeedback.selectionClick();
        break;
      case 'action_preview':
        await HapticFeedback.lightImpact();
        break;
      case 'tutorial_complete':
        await celebrateSuccess();
        break;
    }
  }
}