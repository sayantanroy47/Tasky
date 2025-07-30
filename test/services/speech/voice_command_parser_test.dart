import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracker_app/services/speech/voice_command_parser.dart';
import 'package:task_tracker_app/services/speech/voice_command_models.dart';
import 'package:task_tracker_app/domain/entities/task_enums.dart';

void main() {
  group('VoiceCommandParser', () {
    late VoiceCommandParser parser;

    setUp(() {
      parser = const VoiceCommandParser();
    });

    group('Create Task Commands', () {
      test('should parse basic create task command', () async {
        final command = await parser.parseCommand('create task buy groceries');
        
        expect(command.type, VoiceCommandType.createTask);
        expect(command.taskTitle, 'buy groceries');
        expect(command.isExecutable, true);
      });

      test('should parse create task with priority', () async {
        final command = await parser.parseCommand('create high priority task finish report');
        
        expect(command.type, VoiceCommandType.createTask);
        expect(command.taskTitle, 'finish report');
        expect(command.priority, TaskPriority.high);
      });

      test('should parse create task with due date', () async {
        final command = await parser.parseCommand('create task call mom tomorrow');
        
        expect(command.type, VoiceCommandType.createTask);
        expect(command.taskTitle, 'call mom');
        expect(command.dueDate, isNotNull);
        expect(command.dueDate!.day, DateTime.now().add(const Duration(days: 1)).day);
      });

      test('should parse create task with time', () async {
        final command = await parser.parseCommand('create task meeting at 3pm');
        
        expect(command.type, VoiceCommandType.createTask);
        expect(command.taskTitle, 'meeting');
        expect(command.dueDate, isNotNull);
        expect(command.dueDate!.hour, 15); // 3 PM in 24-hour format
      });

      test('should parse alternative create task phrases', () async {
        final phrases = [
          'add task review documents',
          'new task prepare presentation',
          'remind me to water plants',
          'i need to buy milk',
        ];

        for (final phrase in phrases) {
          final command = await parser.parseCommand(phrase);
          expect(command.type, VoiceCommandType.createTask);
          expect(command.isExecutable, true);
        }
      });
    });

    group('Complete Task Commands', () {
      test('should parse complete task command', () async {
        final command = await parser.parseCommand('complete task buy groceries');
        
        expect(command.type, VoiceCommandType.completeTask);
        expect(command.taskTitle, 'buy groceries');
        expect(command.status, TaskStatus.completed);
      });

      test('should parse alternative complete task phrases', () async {
        final phrases = [
          'mark buy groceries as complete',
          'mark buy groceries as done',
          'finish task buy groceries',
          'done with buy groceries',
        ];

        for (final phrase in phrases) {
          final command = await parser.parseCommand(phrase);
          expect(command.type, VoiceCommandType.completeTask);
          expect(command.taskTitle, 'buy groceries');
        }
      });
    });

    group('Delete Task Commands', () {
      test('should parse delete task command', () async {
        final command = await parser.parseCommand('delete task old meeting');
        
        expect(command.type, VoiceCommandType.deleteTask);
        expect(command.taskTitle, 'old meeting');
      });

      test('should parse alternative delete task phrases', () async {
        final phrases = [
          'remove task old meeting',
          'cancel task old meeting',
          'get rid of old meeting',
        ];

        for (final phrase in phrases) {
          final command = await parser.parseCommand(phrase);
          expect(command.type, VoiceCommandType.deleteTask);
          expect(command.taskTitle, 'old meeting');
        }
      });
    });

    group('Reschedule Task Commands', () {
      test('should parse reschedule task command', () async {
        final command = await parser.parseCommand('reschedule meeting to tomorrow');
        
        expect(command.type, VoiceCommandType.rescheduleTask);
        expect(command.taskTitle, 'meeting');
        expect(command.dueDate, isNotNull);
      });

      test('should parse alternative reschedule phrases', () async {
        final phrases = [
          'move meeting to tomorrow',
          'change meeting due date to tomorrow',
          'postpone meeting to tomorrow',
        ];

        for (final phrase in phrases) {
          final command = await parser.parseCommand(phrase);
          expect(command.type, VoiceCommandType.rescheduleTask);
          expect(command.taskTitle, 'meeting');
        }
      });
    });

    group('Set Priority Commands', () {
      test('should parse set priority command', () async {
        final command = await parser.parseCommand('set meeting priority to high');
        
        expect(command.type, VoiceCommandType.setPriority);
        expect(command.taskTitle, 'meeting');
        expect(command.priority, TaskPriority.high);
      });

      test('should parse alternative priority phrases', () async {
        final command = await parser.parseCommand('make meeting urgent priority');
        
        expect(command.type, VoiceCommandType.setPriority);
        expect(command.taskTitle, 'meeting');
        expect(command.priority, TaskPriority.urgent);
      });
    });

    group('Search Commands', () {
      test('should parse search command', () async {
        final command = await parser.parseCommand('search for grocery tasks');
        
        expect(command.type, VoiceCommandType.searchTasks);
        expect(command.searchQuery, 'grocery tasks');
      });

      test('should parse alternative search phrases', () async {
        final phrases = [
          'find tasks grocery',
          'show me grocery',
          'look for grocery',
        ];

        for (final phrase in phrases) {
          final command = await parser.parseCommand(phrase);
          expect(command.type, VoiceCommandType.searchTasks);
          expect(command.searchQuery, isNotEmpty);
        }
      });
    });

    group('List Tasks Commands', () {
      test('should parse list tasks command', () async {
        final phrases = [
          'list tasks',
          'show tasks',
          'what are my tasks',
          'show my tasks',
          'what do i need to do',
        ];

        for (final phrase in phrases) {
          final command = await parser.parseCommand(phrase);
          expect(command.type, VoiceCommandType.listTasks);
        }
      });
    });

    group('Add Tag Commands', () {
      test('should parse add tag command', () async {
        final command = await parser.parseCommand('add tag work to meeting task');
        
        expect(command.type, VoiceCommandType.addTag);
        expect(command.tags, contains('work'));
        expect(command.taskTitle, 'meeting task');
      });
    });

    group('Mark In Progress Commands', () {
      test('should parse mark in progress command', () async {
        final command = await parser.parseCommand('start working on report');
        
        expect(command.type, VoiceCommandType.markInProgress);
        expect(command.taskTitle, 'report');
        expect(command.status, TaskStatus.inProgress);
      });
    });

    group('Add Subtask Commands', () {
      test('should parse add subtask command', () async {
        final command = await parser.parseCommand('add subtask review draft to report task');
        
        expect(command.type, VoiceCommandType.addSubtask);
        expect(command.subtaskTitle, 'review draft');
        expect(command.taskTitle, 'report task');
      });
    });

    group('Unknown Commands', () {
      test('should return unknown for unrecognized commands', () async {
        final command = await parser.parseCommand('xyz abc random text');
        
        expect(command.type, VoiceCommandType.unknown);
        expect(command.isExecutable, false);
      });

      test('should return unknown for empty input', () async {
        final command = await parser.parseCommand('');
        
        expect(command.type, VoiceCommandType.unknown);
        expect(command.isExecutable, false);
      });
    });

    group('Command Inference', () {
      test('should infer task creation from action words', () async {
        final command = await parser.parseCommand('buy milk and bread');
        
        expect(command.type, VoiceCommandType.createTask);
        expect(command.taskTitle, 'buy milk and bread');
      });

      test('should infer search from question words', () async {
        final command = await parser.parseCommand('what tasks do I have');
        
        expect(command.type, VoiceCommandType.searchTasks);
        expect(command.searchQuery, 'what tasks do I have');
      });
    });

    group('Date and Time Parsing', () {
      test('should parse relative dates correctly', () async {
        final testCases = {
          'today': 0,
          'tomorrow': 1,
          'day after tomorrow': 2,
          'next week': 7,
        };

        for (final entry in testCases.entries) {
          final command = await parser.parseCommand('create task test ${entry.key}');
          expect(command.dueDate, isNotNull, reason: 'Due date should not be null for "${entry.key}"');
          
          // Normalize dates to midnight for comparison
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final expectedDate = today.add(Duration(days: entry.value));
          final actualDate = command.dueDate!;
          final actualDateNormalized = DateTime(actualDate.year, actualDate.month, actualDate.day);
          
          expect(actualDateNormalized, expectedDate, 
                 reason: 'Expected ${entry.key} to be $expectedDate, but got $actualDateNormalized');
        }
      });

      test('should parse time correctly', () async {
        final testCases = {
          'at 9am': 9,
          'at 2pm': 14,
          'by 5:30pm': 17,
        };

        for (final entry in testCases.entries) {
          final command = await parser.parseCommand('create task meeting ${entry.key}');
          expect(command.dueDate, isNotNull);
          expect(command.dueDate!.hour, entry.value);
        }
      });
    });

    group('Priority Parsing', () {
      test('should parse priority keywords correctly', () async {
        final testCases = {
          'low': TaskPriority.low,
          'medium': TaskPriority.medium,
          'high': TaskPriority.high,
          'urgent': TaskPriority.urgent,
          'important': TaskPriority.high,
          'critical': TaskPriority.urgent,
        };

        for (final entry in testCases.entries) {
          final command = await parser.parseCommand('create ${entry.key} priority task test');
          expect(command.priority, entry.value);
        }
      });
    });

    group('Confidence Calculation', () {
      test('should assign high confidence to clear commands', () async {
        final command = await parser.parseCommand('create task buy groceries tomorrow');
        expect(command.confidence, CommandConfidence.high);
      });

      test('should assign low confidence to unclear commands', () async {
        final command = await parser.parseCommand('maybe do something');
        expect(command.confidence, CommandConfidence.low);
      });
    });
  });
}