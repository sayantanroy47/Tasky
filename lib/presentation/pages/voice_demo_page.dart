import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/speech_providers.dart';
import '../widgets/glassmorphism_container.dart';
import '../../core/theme/typography_constants.dart';
import '../widgets/voice_recording_widget.dart';
import '../widgets/standardized_app_bar.dart';
import '../widgets/theme_background_widget.dart';
import '../../services/speech/transcription_service.dart';
import '../../services/speech/transcription_validator.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Demo page to showcase voice recording functionality
class VoiceDemoPage extends ConsumerStatefulWidget {
  const VoiceDemoPage({super.key});
  @override
  ConsumerState<VoiceDemoPage> createState() => _VoiceDemoPageState();
}

class _VoiceDemoPageState extends ConsumerState<VoiceDemoPage> {
  TranscriptionResult? _lastTranscriptionResult;
  TranscriptionValidationResult? _lastValidationResult;
  bool _isTranscribing = false;
  @override
  void initState() {
    super.initState();
    // Initialize speech recognition when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(speechRecognitionProvider.notifier).initialize();
    });
  }
  @override
  Widget build(BuildContext context) {
    final speechState = ref.watch(speechRecognitionProvider);
    final speechNotifier = ref.read(speechRecognitionProvider.notifier);

    return ThemeBackgroundWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: const StandardizedAppBar(
          title: 'Voice Recording Demo',
        ),
        body: Padding(
          padding: const EdgeInsets.only(
            top: kToolbarHeight + 8,
            left: 16.0,
            right: 16.0,
            bottom: 16.0,
          ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status information
            GlassmorphismContainer(
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Speech Recognition Status',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8.0),
                    _buildStatusRow('Available', speechState.isAvailable),
                    _buildStatusRow('Has Permission', speechState.hasPermission),
                    _buildStatusRow('Is Recording', speechState.isRecording),
                    _buildStatusRow('Is Processing', speechState.isProcessing),
                    if (speechState.selectedLocale != null) ...[
                      const SizedBox(height: 8.0),
                      Text('Selected Locale: ${speechState.selectedLocale}'),
                    ],
                  ],
                ),
            ),
            
            const SizedBox(height: 16.0),
            
            // Voice recording widget
            VoiceRecordingWidget(
              isRecording: speechState.isRecording,
              isProcessing: speechState.isProcessing,
              transcriptionText: speechState.transcriptionText,
              soundLevel: speechState.soundLevel,
              errorMessage: speechState.errorMessage,
              onStartRecording: () async {
                await speechNotifier.startListening();
              },
              onStopRecording: () async {
                await speechNotifier.stopListening();
              },
              onCancelRecording: () async {
                await speechNotifier.cancelListening();
              },
              onTranscriptionResult: (text) {
                // Handle transcription result
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Transcription: $text'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              onError: (error) {
                // Handle error
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $error'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 16.0),
            
            // Available locales
            if (speechState.availableLocales.isNotEmpty) ...[
              GlassmorphismContainer(
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Locales',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8.0),
                      DropdownButton<String>(
                        value: speechState.selectedLocale,
                        isExpanded: true,
                        items: speechState.availableLocales.map((locale) {
                          return DropdownMenuItem<String>(
                            value: locale,
                            child: Text(locale),
                          );
                        }).toList(),
                        onChanged: (locale) {
                          if (locale != null) {
                            speechNotifier.setSelectedLocale(locale);
                          }
                        },
                      ),
                    ],
                  ),
                ),
            ],
            
            SizedBox(height: 16.0),
            
            // Transcription testing section
            GlassmorphismContainer(
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transcription Testing',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Test the new transcription service with mock audio data',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12.0),
                    
                    // Test transcription button
                    ElevatedButton.icon(
                      onPressed: _isTranscribing ? null : _testTranscription,
                      icon: _isTranscribing 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(PhosphorIcons.microphone()),
                      label: Text(_isTranscribing ? 'Transcribing...' : 'Test Transcription'),
                    ),
                    
                    const SizedBox(height: 12.0),
                    
                    // Transcription results
                    if (_lastTranscriptionResult != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Transcription Result:',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              _lastTranscriptionResult!.text.isEmpty 
                                  ? '(No text transcribed)' 
                                  : _lastTranscriptionResult!.text,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              children: [
                                Icon(
                                  _lastTranscriptionResult!.isSuccess 
                                      ? PhosphorIcons.checkCircle() 
                                      : PhosphorIcons.warningCircle(),
                                  size: 16,
                                  color: _lastTranscriptionResult!.isSuccess 
                                      ? Colors.green 
                                      : Colors.red,
                                ),
                                const SizedBox(width: 4.0),
                                Text(
                                  'Confidence: ${(_lastTranscriptionResult!.confidence * 100).toStringAsFixed(1)}%',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const Spacer(),
                                Text(
                                  'Time: ${_lastTranscriptionResult!.processingTime.inMilliseconds}ms',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            if (_lastTranscriptionResult!.error != null) ...[
                              const SizedBox(height: 4.0),
                              Text(
                                'Error: ${_lastTranscriptionResult!.error!.message}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    
                    // Validation results
                    if (_lastValidationResult != null) ...[
                      SizedBox(height: 8.0),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: _lastValidationResult!.isValid 
                              ? Colors.green.withValues(alpha:  0.1)
                              : Colors.orange.withValues(alpha:  0.1),
                          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                          border: Border.all(
                            color: _lastValidationResult!.isValid 
                                ? Colors.green 
                                : Colors.orange,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _lastValidationResult!.isValid 
                                      ? PhosphorIcons.checkCircle() 
                                      : PhosphorIcons.warning(),
                                  size: 16,
                                  color: _lastValidationResult!.isValid 
                                      ? Colors.green 
                                      : Colors.orange,
                                ),
                                const SizedBox(width: 4.0),
                                Text(
                                  'Validation: ${_lastValidationResult!.isValid ? 'Valid' : 'Invalid'}',
                                  style: Theme.of(context).textTheme.labelMedium,
                                ),
                                const Spacer(),
                                Text(
                                  'Adjusted Confidence: ${(_lastValidationResult!.confidence * 100).toStringAsFixed(1)}%',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            if (_lastValidationResult!.issues.isNotEmpty) ...[
                              const SizedBox(height: 8.0),
                              Text(
                                'Issues: ${_lastValidationResult!.issuesSummary}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 4.0),
                              ...(_lastValidationResult!.issues.take(3).map((issue) => 
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                                  child: Text(
                                    '• ${issue.severity.name}: ${issue.message}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              )),
                              if (_lastValidationResult!.issues.length > 3) ...[
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                                  child: Text(
                                    '• ... and ${_lastValidationResult!.issues.length - 3} more',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
            ),
            
            const Spacer(),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: speechState.hasError
                      ? () => speechNotifier.clearError()
                      : null,
                  child: const Text('Clear Error'),
                ),
                ElevatedButton(
                  onPressed: speechState.transcriptionText?.isNotEmpty == true
                      ? () => speechNotifier.clearTranscription()
                      : null,
                  child: const Text('Clear Text'),
                ),
                ElevatedButton(
                  onPressed: () => speechNotifier.initialize(),
                  child: const Text('Reinitialize'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    );
  }

  Future<void> _testTranscription() async {
    setState(() {
      _isTranscribing = true;
      _lastTranscriptionResult = null;
      _lastValidationResult = null;
    });

    try {
      final speechService = ref.read(speechRecognitionProvider.notifier).speechService;
      
      if (speechService == null) {
        throw Exception('Speech service not initialized');
      }

      // Create mock audio data for testing
      final mockAudioData = List.generate(1000, (index) => index % 256);
      
      // Test transcription
      final result = await speechService.transcribeAudioData(mockAudioData);
      
      // Validate the result
      final validation = TranscriptionValidator.validateResult(result);
      
      setState(() {
        _lastTranscriptionResult = result;
        _lastValidationResult = validation;
      });
      
      // Show result in snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.isSuccess 
                  ? 'Transcription completed: ${result.text}' 
                  : 'Transcription failed: ${result.error?.message ?? 'Unknown error'}',
            ),
            backgroundColor: result.isSuccess 
                ? Colors.green 
                : Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Handle error
      setState(() {
        _lastTranscriptionResult = TranscriptionResult.failure(
          error: TranscriptionError(
            message: e.toString(),
            type: TranscriptionErrorType.processingError,
          ),
        );
        _lastValidationResult = TranscriptionValidator.validateResult(_lastTranscriptionResult!);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transcription test failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTranscribing = false;
        });
      }
    }
  }

  Widget _buildStatusRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(
            value ? PhosphorIcons.checkCircle() : PhosphorIcons.xCircle(),
            color: value ? Colors.green : Colors.red,
            size: 16.0,
          ),
          const SizedBox(width: 8.0),
          Text('$label: ${value ? 'Yes' : 'No'}'),
        ],
      ),
    );
  }
}


