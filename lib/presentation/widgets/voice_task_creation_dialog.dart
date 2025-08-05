import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/entities/task_audio_metadata.dart';
import '../../domain/models/enums.dart';
import '../../services/audio/audio_recording_service.dart';
import '../../services/speech/speech_service_impl.dart';
import '../../services/ai/natural_language_parser.dart';
import '../providers/task_provider.dart';
import 'voice_recording_widget.dart';

/// Dialog for creating tasks with three different input methods
class VoiceTaskCreationDialog extends ConsumerStatefulWidget {
  const VoiceTaskCreationDialog({super.key});

  @override
  ConsumerState<VoiceTaskCreationDialog> createState() => _VoiceTaskCreationDialogState();
}

class _VoiceTaskCreationDialogState extends ConsumerState<VoiceTaskCreationDialog> {
  TaskCreationMode _mode = TaskCreationMode.selection;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;
  List<String> _tags = [];
  bool _isPinned = false;
  
  // Voice recording state
  bool _isRecording = false;
  bool _isTranscribing = false;
  String? _recordedAudioPath;
  String? _transcribedText;
  String? _errorMessage;
  
  // Services
  final AudioRecordingService _audioService = AudioRecordingService();
  final SpeechServiceImpl _speechService = SpeechServiceImpl();
  
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _audioService.initialize();
    await _speechService.initialize();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _audioService.dispose();
    _speechService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text(_getTitle()),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: _mode == TaskCreationMode.selection 
            ? null 
            : [
                if (_mode != TaskCreationMode.selection)
                  TextButton(
                    onPressed: _canSave() ? _saveTask : null,
                    child: const Text('Save'),
                  ),
              ],
        ),
        body: _buildBody(),
      ),
    );
  }

  String _getTitle() {
    switch (_mode) {
      case TaskCreationMode.selection:
        return 'Create Task';
      case TaskCreationMode.text:
        return 'Text Task';
      case TaskCreationMode.voice:
        return 'Voice Task';
      case TaskCreationMode.speechToText:
        return 'Speech-to-Text Task';
    }
  }

  Widget _buildBody() {
    switch (_mode) {
      case TaskCreationMode.selection:
        return _buildModeSelection();
      case TaskCreationMode.text:
        return _buildTextForm();
      case TaskCreationMode.voice:
        return _buildVoiceRecording();
      case TaskCreationMode.speechToText:
        return _buildSpeechToText();
    }
  }

  Widget _buildModeSelection() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'How would you like to create your task?',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Text Task Option
          _ModeOptionCard(
            icon: Icons.edit,
            title: 'Text Task',
            description: 'Type your task manually',
            onTap: () => setState(() => _mode = TaskCreationMode.text),
          ),
          
          const SizedBox(height: 16),
          
          // Voice Task Option
          _ModeOptionCard(
            icon: Icons.mic,
            title: 'Voice Recording',
            description: 'Record audio and save as voice task',
            onTap: () => setState(() => _mode = TaskCreationMode.voice),
          ),
          
          const SizedBox(height: 16),
          
          // Speech-to-Text Option
          _ModeOptionCard(
            icon: Icons.keyboard_voice,
            title: 'Speech-to-Text',
            description: 'Speak and convert to text automatically',
            onTap: () => setState(() => _mode = TaskCreationMode.speechToText),
          ),
        ],
      ),
    );
  }

  Widget _buildTextForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Task Title',
                      hintText: 'Enter task title...',
                      prefixIcon: Icon(Icons.title),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      hintText: 'Enter task description...',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  _buildTaskOptions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceRecording() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (_errorMessage != null) ...[
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                VoiceRecordingWidget(
                  isRecording: _isRecording,
                  isProcessing: false,
                  onStartRecording: _startVoiceRecording,
                  onStopRecording: _stopVoiceRecording,
                  onCancelRecording: _cancelVoiceRecording,
                ),
                
                if (_recordedAudioPath != null) ...[
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.audiotrack),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Voice recording saved',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildTaskOptions(),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeechToText() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (_errorMessage != null) ...[
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          Expanded(
            child: Column(
              children: [
                VoiceRecordingWidget(
                  isRecording: _isRecording,
                  isProcessing: _isTranscribing,
                  transcriptionText: _transcribedText,
                  onStartRecording: _startSpeechToText,
                  onStopRecording: _stopSpeechToText,
                  onCancelRecording: _cancelSpeechToText,
                ),
                
                if (_transcribedText != null) ...[
                  const SizedBox(height: 24),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'AI-Parsed Task Details:',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Original: "$_transcribedText"',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (_dueDate != null)
                                    Text('📅 Due: ${_formatDate(_dueDate!)}', 
                                      style: Theme.of(context).textTheme.bodySmall),
                                  if (_priority != TaskPriority.medium)
                                    Text('⚡ Priority: ${_priority.displayName}', 
                                      style: Theme.of(context).textTheme.bodySmall),
                                  if (_tags.isNotEmpty)
                                    Text('🏷️ Tags: ${_tags.join(', ')}', 
                                      style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Edit task title:',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: TextField(
                                controller: _titleController,
                                decoration: const InputDecoration(
                                  hintText: 'Edit your task title...',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: null,
                                expands: true,
                                textAlignVertical: TextAlignVertical.top,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildTaskOptions(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskOptions() {
    return Column(
      children: [
        // Priority selector
        DropdownButtonFormField<TaskPriority>(
          value: _priority,
          decoration: const InputDecoration(
            labelText: 'Priority',
            prefixIcon: Icon(Icons.flag),
          ),
          items: TaskPriority.values.map((priority) {
            return DropdownMenuItem(
              value: priority,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: priority.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(priority.displayName),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _priority = value;
              });
            }
          },
        ),
        const SizedBox(height: 16),
        
        // Due date picker
        ListTile(
          leading: const Icon(Icons.calendar_today),
          title: Text(_dueDate == null 
            ? 'Set Due Date (Optional)' 
            : 'Due: ${_formatDate(_dueDate!)}'),
          trailing: _dueDate != null 
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _dueDate = null;
                  });
                },
              )
            : const Icon(Icons.arrow_forward_ios),
          onTap: _selectDueDate,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  bool _canSave() {
    switch (_mode) {
      case TaskCreationMode.text:
        return _titleController.text.trim().isNotEmpty;
      case TaskCreationMode.voice:
        return _recordedAudioPath != null;
      case TaskCreationMode.speechToText:
        return _titleController.text.trim().isNotEmpty;
      case TaskCreationMode.selection:
        return false;
    }
  }

  Future<void> _startVoiceRecording() async {
    try {
      setState(() {
        _errorMessage = null;
        _isRecording = true;
      });

      final audioPath = await _audioService.startRecording(
        onMaxDurationReached: () {
          setState(() {
            _isRecording = false;
          });
        },
      );

      if (audioPath == null) {
        throw Exception('Failed to start recording');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isRecording = false;
      });
    }
  }

  Future<void> _stopVoiceRecording() async {
    try {
      final audioPath = await _audioService.stopRecording();
      setState(() {
        _isRecording = false;
        _recordedAudioPath = audioPath;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isRecording = false;
      });
    }
  }

  Future<void> _cancelVoiceRecording() async {
    await _audioService.cancelRecording();
    setState(() {
      _isRecording = false;
      _recordedAudioPath = null;
    });
  }

  Future<void> _startSpeechToText() async {
    try {
      setState(() {
        _errorMessage = null;
        _isRecording = true;
        _transcribedText = null;
      });

      await _speechService.startListening(
        onResult: (text) {
          setState(() {
            _transcribedText = text;
            // Use natural language parser to extract task details
            final parseResult = NaturalLanguageParser.parseTaskTextSync(text);
            _titleController.text = parseResult.extractedTitle;
            _priority = parseResult.priority;
            _dueDate = parseResult.dueDate;
            _tags = parseResult.tags;
          });
        },
        onError: (error) {
          setState(() {
            _errorMessage = error;
            _isRecording = false;
            _isTranscribing = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isRecording = false;
        _isTranscribing = false;
      });
    }
  }

  Future<void> _stopSpeechToText() async {
    await _speechService.stopListening();
    setState(() {
      _isRecording = false;
      _isTranscribing = false;
    });
  }

  Future<void> _cancelSpeechToText() async {
    await _speechService.cancel();
    setState(() {
      _isRecording = false;
      _isTranscribing = false;
      _transcribedText = null;
      _titleController.clear();
    });
  }

  Future<void> _selectDueDate() async {
    if (!mounted) return;
    
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dueDate ?? DateTime.now()),
      );

      if (mounted) {
        if (time != null) {
          setState(() {
            _dueDate = DateTime(
              date.year,
              date.month,
              date.day,
              time.hour,
              time.minute,
            );
          });
        } else {
          setState(() {
            _dueDate = DateTime(
              date.year,
              date.month,
              date.day,
              23,
              59,
            );
          });
        }
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _saveTask() async {
    if (!_canSave()) return;

    try {
      final taskOperations = ref.read(taskOperationsProvider);
      TaskModel newTask;

      switch (_mode) {
        case TaskCreationMode.text:
          newTask = TaskModel.create(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
            priority: _priority,
            dueDate: _dueDate,
            tags: _tags,
            isPinned: _isPinned,
            metadata: {'task_type': TaskType.text.name},
          );
          break;

        case TaskCreationMode.voice:
          newTask = TaskModel.create(
            title: 'Voice Recording ${DateTime.now().toString().substring(0, 16)}',
            priority: _priority,
            dueDate: _dueDate,
            tags: _tags,
            isPinned: _isPinned,
          );
          
          if (_recordedAudioPath != null) {
            newTask = TaskAudioMetadata.withAudio(
              newTask,
              audioFilePath: _recordedAudioPath!,
              recordedAt: DateTime.now(),
              taskType: TaskType.voice,
            );
          }
          break;

        case TaskCreationMode.speechToText:
          newTask = TaskModel.create(
            title: _titleController.text.trim(),
            priority: _priority,
            dueDate: _dueDate,
            tags: _tags,
            isPinned: _isPinned,
            metadata: {'task_type': TaskType.transcribed.name},
          );
          break;

        case TaskCreationMode.selection:
          return; // Should not happen
      }

      await taskOperations.createTask(newTask);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating task: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

class _ModeOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ModeOptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}

enum TaskCreationMode {
  selection,
  text,
  voice,
  speechToText,
}