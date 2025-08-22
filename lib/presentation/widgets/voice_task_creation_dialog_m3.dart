import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'glassmorphism_container.dart';
import '../../core/theme/material3/motion_system.dart';
import '../../services/audio/audio_recording_service.dart';
import 'dart:async';

/// Voice Task Creation Dialog with transcription - M3 Design
class VoiceTaskCreationDialogM3 extends ConsumerStatefulWidget {
  const VoiceTaskCreationDialogM3({super.key});
  
  @override
  ConsumerState<VoiceTaskCreationDialogM3> createState() => _VoiceTaskCreationDialogM3State();
}

class _VoiceTaskCreationDialogM3State extends ConsumerState<VoiceTaskCreationDialogM3>
    with TickerProviderStateMixin {
  
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  
  bool _isListening = false;
  bool _isProcessing = false;
  bool _hasRecording = false;
  String _statusMessage = 'Tap to start voice recognition';
  String _transcribedText = '';
  String? _audioFilePath;
  Duration _recordingDuration = Duration.zero;
  
  // Dual stream services
  late SpeechToText _speechToText;
  late AudioRecordingService _audioRecorder;
  bool _speechEnabled = false;
  bool _audioEnabled = false;
  
  // Service states for fallback handling
  bool _speechRecognitionActive = false;
  bool _audioRecordingActive = false;
  
  
  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: ExpressiveMotionSystem.durationMedium3,
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: ExpressiveMotionSystem.durationMedium2,
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: ExpressiveMotionSystem.emphasizedDecelerate,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: ExpressiveMotionSystem.emphasizedDecelerate,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _initializeServices();
    _fadeController.forward();
    _scaleController.forward();
  }
  
  Future<void> _initializeServices() async {
    debugPrint('🎤 Initializing dual stream services...');
    
    // Initialize speech recognition
    try {
      _speechToText = SpeechToText();
      _speechEnabled = await _speechToText.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
        debugLogging: true,
      );
      debugPrint('🎤 Speech recognition enabled: $_speechEnabled');
    } catch (e) {
      debugPrint('🎤 Speech recognition initialization failed: $e');
      _speechEnabled = false;
    }
    
    // Initialize audio recording
    try {
      _audioRecorder = AudioRecordingService();
      _audioEnabled = await _audioRecorder.initialize();
      debugPrint('🎵 Audio recording enabled: $_audioEnabled');
    } catch (e) {
      debugPrint('🎵 Audio recording initialization failed: $e');
      _audioEnabled = false;
    }
    
    if (mounted) {
      setState(() {
        if (!_speechEnabled && !_audioEnabled) {
          _statusMessage = 'Voice services not available';
        } else if (!_speechEnabled) {
          _statusMessage = 'Only audio recording available (no transcription)';
        } else if (!_audioEnabled) {
          _statusMessage = 'Only speech recognition available (no audio file)';
        } else {
          _statusMessage = 'Tap to start dual stream recording';
        }
      });
    }
  }
  
  void _onSpeechStatus(String status) {
    if (mounted) {
      setState(() {
        _isListening = status == 'listening';
        if (status == 'listening') {
          _statusMessage = 'Listening... Speak now';
          _pulseController.repeat(reverse: true);
        } else if (status == 'notListening') {
          if (_hasRecording) {
            _statusMessage = 'Tap create task or record again';
          } else {
            _statusMessage = 'Tap to start voice recognition';
          }
          _pulseController.stop();
          _pulseController.reset();
        } else if (status == 'done') {
          _statusMessage = _hasRecording ? 'Processing complete!' : 'No speech detected';
        }
      });
    }
  }
  
  void _onSpeechError(dynamic error) {
    if (mounted) {
      setState(() {
        _isListening = false;
        _statusMessage = 'Error: ${error.toString()}';
        _pulseController.stop();
        _pulseController.reset();
      });
    }
  }
  
  Future<void> _startListening() async {
    if (!_speechEnabled && !_audioEnabled) return;
    
    try {
      debugPrint('🎯 Starting dual stream recording...');
      
      // Clear previous data
      setState(() {
        _transcribedText = '';
        _hasRecording = false;
        _isListening = true;
        _audioFilePath = null;
        _recordingDuration = Duration.zero;
        _speechRecognitionActive = false;
        _audioRecordingActive = false;
        _statusMessage = 'Starting dual stream recording...';
      });
      
      // STEP 1: Start audio recording first (if available)
      if (_audioEnabled) {
        debugPrint('🎵 Step 1: Starting audio recording...');
        try {
          _audioFilePath = await _audioRecorder.startRecording(
            onDurationUpdate: (duration) {
              if (mounted) {
                setState(() {
                  _recordingDuration = duration;
                });
              }
            },
            onMaxDurationReached: () {
              debugPrint('🎵 Max recording duration reached, stopping...');
              _stopListening();
            },
          );
          
          _audioRecordingActive = true;
          debugPrint('🎵 Audio recording started: $_audioFilePath');
          
          if (mounted) {
            setState(() {
              _statusMessage = 'Audio recording started, preparing speech recognition...';
            });
          }
        } catch (e) {
          debugPrint('🎵 Audio recording failed: $e');
          // Continue with speech-only fallback
        }
      }
      
      // STEP 2: Wait 150ms to avoid microphone resource conflicts
      await Future.delayed(const Duration(milliseconds: 150));
      
      // STEP 3: Start speech recognition (if available)
      if (_speechEnabled) {
        debugPrint('🎤 Step 2: Starting speech recognition...');
        try {
          await _speechToText.listen(
            onResult: _onSpeechResult,
            listenFor: const Duration(seconds: 60),
            pauseFor: const Duration(seconds: 10),
            listenOptions: SpeechListenOptions(
              partialResults: true,
              cancelOnError: true,
              listenMode: ListenMode.confirmation,
            ),
            onSoundLevelChange: (level) {
              // Use sound level from speech recognition for visual feedback
              // since FlutterSound doesn't provide real-time amplitude
            },
          );
          
          _speechRecognitionActive = true;
          debugPrint('🎤 Speech recognition started');
          
          if (mounted) {
            setState(() {
              _statusMessage = 'Recording audio and speech - speak now!';
            });
          }
        } catch (e) {
          debugPrint('🎤 Speech recognition failed: $e');
          // Continue with audio-only fallback
          if (mounted) {
            setState(() {
              _statusMessage = _audioRecordingActive 
                ? 'Audio recording only - speak now!' 
                : 'Failed to start recording services';
            });
          }
        }
      } else {
        // Audio-only mode
        if (mounted) {
          setState(() {
            _statusMessage = 'Audio recording only - speak now!';
          });
        }
      }
      
      // If neither service started, show error
      if (!_audioRecordingActive && !_speechRecognitionActive) {
        if (mounted) {
          setState(() {
            _isListening = false;
            _statusMessage = 'Failed to start recording services';
          });
        }
      }
      
    } catch (e) {
      debugPrint('🎯 Dual stream start failed: $e');
      setState(() {
        _isListening = false;
        _statusMessage = 'Failed to start recording: $e';
      });
    }
  }
  
  void _onSpeechResult(result) {
    if (mounted) {
      setState(() {
        _transcribedText = result.recognizedWords;
        _hasRecording = _transcribedText.isNotEmpty;
        
        // Update status message based on result
        if (result.finalResult) {
          _statusMessage = _hasRecording ? 'Transcription complete! Continue or re-record' : 'No speech detected. Try again';
        } else {
          _statusMessage = 'Listening... (${_transcribedText.length} chars)';
        }
      });
    }
  }
  
  Future<void> _stopListening() async {
    if (!_isListening) return;
    
    debugPrint('🎯 Stopping dual stream recording...');
    
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Processing recording...';
    });
    
    // Stop both services
    String? finalAudioPath;
    bool hasTranscription = false;
    
    try {
      // Stop speech recognition
      if (_speechRecognitionActive && _speechEnabled) {
        debugPrint('🎤 Stopping speech recognition...');
        await _speechToText.stop();
        _speechRecognitionActive = false;
        hasTranscription = _transcribedText.isNotEmpty;
        debugPrint('🎤 Speech recognition stopped. Has transcription: $hasTranscription');
      }
      
      // Stop audio recording
      if (_audioRecordingActive && _audioEnabled) {
        debugPrint('🎵 Stopping audio recording...');
        finalAudioPath = await _audioRecorder.stopRecording();
        _audioRecordingActive = false;
        debugPrint('🎵 Audio recording stopped. File: $finalAudioPath');
      }
      
      // Update final state
      setState(() {
        _isListening = false;
        _isProcessing = false;
        _audioFilePath = finalAudioPath;
        _hasRecording = hasTranscription || (finalAudioPath != null);
        
        // Update status message based on what we captured
        if (hasTranscription && finalAudioPath != null) {
          _statusMessage = 'Dual stream recording complete! Both audio and transcription captured.';
        } else if (hasTranscription) {
          _statusMessage = 'Speech transcription complete! (No audio file captured)';
        } else if (finalAudioPath != null) {
          _statusMessage = 'Audio recording complete! (No transcription captured)';
        } else {
          _statusMessage = 'Recording complete but no data captured. Try again.';
        }
        
        _pulseController.stop();
        _pulseController.reset();
      });
      
      debugPrint('🎯 Dual stream recording complete:');
      debugPrint('  - Audio file: $finalAudioPath');
      debugPrint('  - Transcription: ${_transcribedText.isNotEmpty ? _transcribedText.substring(0, _transcribedText.length > 50 ? 50 : _transcribedText.length) : 'None'}');
      debugPrint('  - Duration: $_recordingDuration');
      
    } catch (e) {
      debugPrint('🎯 Error stopping recording: $e');
      setState(() {
        _isListening = false;
        _isProcessing = false;
        _statusMessage = 'Error stopping recording: $e';
        _pulseController.stop();
        _pulseController.reset();
      });
    }
  }
  
  void _continueToEdit() {
    // Allow continuation if we have either transcription OR audio file
    if (_transcribedText.isEmpty && _audioFilePath == null) return;
    
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Preparing task...';
    });
    
    try {
      debugPrint('🎯 Dual stream: Continuing to edit with:');
      debugPrint('  - Transcription: ${_transcribedText.isNotEmpty ? _transcribedText.substring(0, _transcribedText.length > 100 ? 100 : _transcribedText.length) : 'None'}');
      debugPrint('  - Audio file: $_audioFilePath');
      debugPrint('  - Duration: $_recordingDuration');
      
      // Return dual stream data to be used in enhanced task creation dialog
      final returnData = {
        'transcribedText': _transcribedText.isNotEmpty ? _transcribedText : '',
        'creationMode': 'voiceToText',
        'audioFilePath': _audioFilePath,
        'audioData': _audioFilePath != null ? {
          'filePath': _audioFilePath,
          'format': 'aac', // AudioRecordingService uses AAC format
          'recordingTimestamp': DateTime.now().toIso8601String(),
          'transcription': _transcribedText,
          'duration': _recordingDuration.inSeconds,
          'hasDualStream': true, // Flag to indicate this came from dual stream
          'hasAudioFile': _audioFilePath != null,
          'hasTranscription': _transcribedText.isNotEmpty,
        } : {
          'transcription': _transcribedText,
          'recordingTimestamp': DateTime.now().toIso8601String(),
          'duration': _recordingDuration.inSeconds,
          'hasDualStream': false,
          'hasAudioFile': false,
          'hasTranscription': _transcribedText.isNotEmpty,
        },
      };
      
      debugPrint('🎯 Dual stream: Returning data: $returnData');
      
      if (mounted) {
        Navigator.of(context).pop(returnData);
      }
    } catch (e) {
      debugPrint('🎯 Dual stream: Error in _continueToEdit: $e');
      if (mounted) {
        setState(() {
          _statusMessage = 'Error preparing data: $e';
          _isProcessing = false;
        });
      }
    }
  }
  
  void _clearRecording() {
    setState(() {
      _transcribedText = '';
      _hasRecording = false;
      _audioFilePath = null;
      _recordingDuration = Duration.zero;
      _speechRecognitionActive = false;
      _audioRecordingActive = false;
      _statusMessage = _speechEnabled || _audioEnabled 
        ? 'Tap to start dual stream recording' 
        : 'Voice services not available';
    });
  }
  
  @override
  void dispose() {
    // Clean up controllers
    _fadeController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    
    // Clean up services
    _speechToText.stop();
    
    if (_audioEnabled) {
      _audioRecorder.dispose();
    }
    
    super.dispose();
  }
  
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Voice Task Creation'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_hasRecording && !_isProcessing)
            TextButton(
              onPressed: _isProcessing ? null : _continueToEdit,
              child: _isProcessing 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Continue'),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface.withOpacity(0.95),
              colorScheme.surfaceContainerHighest.withOpacity(0.95),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                
                const SizedBox(height: 32),
                
                // Voice visualization area
                Expanded(
                  flex: 2,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: GlassmorphismContainer(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Voice visualization
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _isListening ? _pulseAnimation.value : 1.0,
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _isListening 
                                        ? colorScheme.primary.withOpacity(0.3)
                                        : colorScheme.surfaceContainerHighest.withOpacity(0.3),
                                      border: Border.all(
                                        color: _isListening 
                                          ? colorScheme.primary
                                          : colorScheme.outline,
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      _isListening ? Icons.mic : Icons.mic_none,
                                      size: 48,
                                      color: _isListening 
                                        ? colorScheme.primary
                                        : colorScheme.onSurface,
                                    ),
                                  ),
                                );
                              },
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Status message
                            Text(
                              _statusMessage,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            // Recording duration (when recording)
                            if (_isListening && _recordingDuration > Duration.zero) ...[ 
                              const SizedBox(height: 8),
                              Text(
                                _formatDuration(_recordingDuration),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Transcribed text area
                if (_transcribedText.isNotEmpty)
                  Expanded(
                    child: GlassmorphismContainer(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.text_fields,
                                  color: colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Transcribed Text',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Text(
                                  _transcribedText,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                
                const SizedBox(height: 24),
                
                
                // Action buttons
                if (_hasRecording && !_isProcessing) ...[
                  // Show Next and Clear buttons after transcription is complete
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _clearRecording,
                          icon: const Icon(PhosphorIcons.x()),
                          label: const Text('Clear'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _continueToEdit,
                          icon: const Icon(PhosphorIcons.arrowRight()),
                          label: const Text('Next'),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Show recording controls when no transcription yet
                  Row(
                    children: [
                      Expanded(
                        child: _isProcessing
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : FilledButton.icon(
                              onPressed: _isListening ? _stopListening : _startListening,
                              icon: Icon(_isListening ? Icons.stop : Icons.mic),
                              label: Text(_isListening ? 'Stop' : 'Start Recording'),
                            ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
