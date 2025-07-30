import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:task_tracker_app/domain/entities/task_enums.dart';
import 'package:task_tracker_app/services/ai/ai_task_parser.dart';
import 'package:task_tracker_app/services/ai/composite_ai_task_parser.dart';
import 'package:task_tracker_app/services/ai/openai_task_parser.dart';
import 'package:task_tracker_app/services/ai/claude_task_parser.dart';
import 'package:task_tracker_app/services/ai/local_task_parser.dart';

import 'composite_ai_task_parser_test.mocks.dart';

@GenerateMocks([OpenAITaskParser, ClaudeTaskParser, LocalTaskParser])
void main() {
  late MockOpenAITaskParser mockOpenAI;
  late MockClaudeTaskParser mockClaude;
  late MockLocalTaskParser mockLocal;
  late CompositeAITaskParser parser;

  setUp(() {
    mockOpenAI = MockOpenAITaskParser();
    mockClaude = MockClaudeTaskParser();
    mockLocal = MockLocalTaskParser();
  });

  group('CompositeAITaskParser', () {
    group('with AI enabled', () {
      setUp(() {
        parser = CompositeAITaskParser(
          openAIParser: mockOpenAI,
          claudeParser: mockClaude,
          localParser: mockLocal,
          preferredService: AIServiceType.openai,
          enableAI: true,
        );
      });

      test('should use OpenAI when available and preferred', () async {
        when(mockOpenAI.isAvailable).thenReturn(true);
        when(mockOpenAI.serviceName).thenReturn('OpenAI GPT-4o');
        when(mockOpenAI.parseTaskFromText(any)).thenAnswer((_) async => 
          const ParsedTaskData(title: 'OpenAI Task', confidence: 0.9));

        expect(parser.isAvailable, isTrue);
        expect(parser.serviceName, equals('OpenAI GPT-4o'));

        final result = await parser.parseTaskFromText('test task');
        expect(result.title, equals('OpenAI Task'));
        expect(result.confidence, equals(0.9));

        verify(mockOpenAI.parseTaskFromText('test task')).called(1);
        verifyNever(mockClaude.parseTaskFromText(any));
        verifyNever(mockLocal.parseTaskFromText(any));
      });

      test('should fallback to local when OpenAI fails', () async {
        when(mockOpenAI.isAvailable).thenReturn(true);
        when(mockOpenAI.parseTaskFromText(any)).thenThrow(
          const AIParsingException('API error'));
        when(mockLocal.parseTaskFromText(any)).thenAnswer((_) async => 
          const ParsedTaskData(title: 'Local Task', confidence: 0.7));

        final result = await parser.parseTaskFromText('test task');
        expect(result.title, equals('Local Task'));
        expect(result.metadata['ai_fallback'], isTrue);
        expect(result.metadata['ai_error'], contains('API error'));

        verify(mockOpenAI.parseTaskFromText('test task')).called(1);
        verify(mockLocal.parseTaskFromText('test task')).called(1);
      });

      test('should use Claude when preferred', () async {
        parser = CompositeAITaskParser(
          openAIParser: mockOpenAI,
          claudeParser: mockClaude,
          localParser: mockLocal,
          preferredService: AIServiceType.claude,
          enableAI: true,
        );

        when(mockClaude.isAvailable).thenReturn(true);
        when(mockClaude.serviceName).thenReturn('Claude 3');
        when(mockClaude.parseTaskFromText(any)).thenAnswer((_) async => 
          const ParsedTaskData(title: 'Claude Task', confidence: 0.8));

        expect(parser.serviceName, equals('Claude 3'));

        final result = await parser.parseTaskFromText('test task');
        expect(result.title, equals('Claude Task'));

        verify(mockClaude.parseTaskFromText('test task')).called(1);
        verifyNever(mockOpenAI.parseTaskFromText(any));
      });

      test('should combine AI and local tags', () async {
        when(mockOpenAI.isAvailable).thenReturn(true);
        when(mockOpenAI.suggestTags(any)).thenAnswer((_) async => ['ai-tag1', 'ai-tag2']);
        when(mockLocal.suggestTags(any)).thenAnswer((_) async => ['local-tag1', 'local-tag2']);

        final tags = await parser.suggestTags('test task');
        expect(tags, hasLength(4));
        expect(tags, contains('ai-tag1'));
        expect(tags, contains('local-tag1'));

        verify(mockOpenAI.suggestTags('test task')).called(1);
        verify(mockLocal.suggestTags('test task')).called(1);
      });

      test('should limit combined tags to 8', () async {
        when(mockOpenAI.isAvailable).thenReturn(true);
        when(mockOpenAI.suggestTags(any)).thenAnswer((_) async => 
          ['tag1', 'tag2', 'tag3', 'tag4', 'tag5']);
        when(mockLocal.suggestTags(any)).thenAnswer((_) async => 
          ['tag6', 'tag7', 'tag8', 'tag9', 'tag10']);

        final tags = await parser.suggestTags('test task');
        expect(tags.length, lessThanOrEqualTo(8));
      });

      test('should prefer AI date extraction over local', () async {
        final aiDate = DateTime.now().add(const Duration(days: 1));
        when(mockOpenAI.isAvailable).thenReturn(true);
        when(mockOpenAI.extractDueDate(any)).thenAnswer((_) async => aiDate);
        when(mockLocal.extractDueDate(any)).thenAnswer((_) async => 
          DateTime.now().add(const Duration(days: 2)));

        final date = await parser.extractDueDate('tomorrow');
        expect(date, equals(aiDate));

        verify(mockOpenAI.extractDueDate('tomorrow')).called(1);
        verifyNever(mockLocal.extractDueDate(any));
      });

      test('should fallback to local date when AI returns null', () async {
        final localDate = DateTime.now().add(const Duration(days: 1));
        when(mockOpenAI.isAvailable).thenReturn(true);
        when(mockOpenAI.extractDueDate(any)).thenAnswer((_) async => null);
        when(mockLocal.extractDueDate(any)).thenAnswer((_) async => localDate);

        final date = await parser.extractDueDate('tomorrow');
        expect(date, equals(localDate));

        verify(mockOpenAI.extractDueDate('tomorrow')).called(1);
        verify(mockLocal.extractDueDate('tomorrow')).called(1);
      });
    });

    group('with AI disabled', () {
      setUp(() {
        parser = CompositeAITaskParser(
          openAIParser: mockOpenAI,
          claudeParser: mockClaude,
          localParser: mockLocal,
          preferredService: AIServiceType.openai,
          enableAI: false,
        );
      });

      test('should only use local parser', () async {
        when(mockLocal.serviceName).thenReturn('Local Parser');
        when(mockLocal.parseTaskFromText(any)).thenAnswer((_) async => 
          const ParsedTaskData(title: 'Local Task', confidence: 0.7));

        expect(parser.serviceName, equals('Local Parser'));

        final result = await parser.parseTaskFromText('test task');
        expect(result.title, equals('Local Task'));

        verify(mockLocal.parseTaskFromText('test task')).called(1);
        verifyNever(mockOpenAI.parseTaskFromText(any));
        verifyNever(mockClaude.parseTaskFromText(any));
      });

      test('should only use local tags', () async {
        when(mockLocal.suggestTags(any)).thenAnswer((_) async => ['local-tag']);

        final tags = await parser.suggestTags('test task');
        expect(tags, equals(['local-tag']));

        verify(mockLocal.suggestTags('test task')).called(1);
        verifyNever(mockOpenAI.suggestTags(any));
      });
    });

    group('service management', () {
      test('should switch services', () {
        parser = CompositeAITaskParser(
          openAIParser: mockOpenAI,
          claudeParser: mockClaude,
          localParser: mockLocal,
          preferredService: AIServiceType.openai,
          enableAI: true,
        );

        final claudeParser = parser.withService(AIServiceType.claude);
        // Test by checking service name when Claude is available
        when(mockClaude.isAvailable).thenReturn(true);
        when(mockClaude.serviceName).thenReturn('Claude 3');
        expect(claudeParser.serviceName, equals('Claude 3'));
      });

      test('should toggle AI enabled', () {
        parser = CompositeAITaskParser(
          openAIParser: mockOpenAI,
          claudeParser: mockClaude,
          localParser: mockLocal,
          preferredService: AIServiceType.openai,
          enableAI: true,
        );

        final disabledParser = parser.withAIEnabled(false);
        when(mockLocal.serviceName).thenReturn('Local Parser');
        expect(disabledParser.serviceName, equals('Local Parser'));
      });

      test('should list available services', () {
        when(mockOpenAI.isAvailable).thenReturn(true);
        when(mockClaude.isAvailable).thenReturn(false);

        parser = CompositeAITaskParser(
          openAIParser: mockOpenAI,
          claudeParser: mockClaude,
          localParser: mockLocal,
          preferredService: AIServiceType.openai,
          enableAI: true,
        );

        final services = parser.getAvailableServices();
        expect(services, contains(AIServiceType.local));
        expect(services, contains(AIServiceType.openai));
        expect(services, isNot(contains(AIServiceType.claude)));
      });
    });

    group('AIServiceType', () {
      test('should have correct display names', () {
        expect(AIServiceType.openai.displayName, equals('OpenAI GPT-4o'));
        expect(AIServiceType.claude.displayName, equals('Claude 3'));
        expect(AIServiceType.local.displayName, equals('Local Processing'));
      });

      test('should have descriptions', () {
        expect(AIServiceType.openai.description, contains('OpenAI'));
        expect(AIServiceType.claude.description, contains('Claude'));
        expect(AIServiceType.local.description, contains('local'));
      });
    });
  });
}