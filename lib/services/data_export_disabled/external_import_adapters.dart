import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import '../../domain/entities/project.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/entities/tag.dart';
import '../../domain/models/enums.dart';
import 'data_export_models.dart';

/// Import adapter for external project management platforms
class ExternalImportAdapters {
  final http.Client _httpClient;
  
  ExternalImportAdapters({http.Client? httpClient}) 
      : _httpClient = httpClient ?? http.Client();
  
  /// Import data from Trello boards
  Future<ImportResultData> importFromTrello({
    required String boardId,
    required String apiKey,
    required String token,
    ImportOptions? options,
  }) async {
    try {
      final config = ExternalPlatformConfig(
        source: ImportSource.trello,
        apiKey: apiKey,
        baseUrl: 'https://api.trello.com/1',
        headers: {'Authorization': 'OAuth oauth_consumer_key="$apiKey", oauth_token="$token"'},
        requiresAuthentication: true,
      );
      
      // Fetch board data
      final boardData = await _fetchTrelloBoard(boardId, config);
      final lists = await _fetchTrelloLists(boardId, config);
      final cards = await _fetchTrelloCards(boardId, config);
      
      // Convert to internal format
      final projects = [_convertTrelloBoardToProject(boardData, lists)];
      final tasks = cards.map((card) => _convertTrelloCardToTask(card, lists)).toList();
      
      return ImportResultData(
        success: true,
        message: 'Successfully imported ${tasks.length} tasks from Trello',
        importedCount: tasks.length,
        skippedCount: 0,
        errors: [],
        importedAt: DateTime.now(),
        metadata: {
          'source': 'trello',
          'boardId': boardId,
          'boardName': boardData['name'],
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Trello import error: $e');
      }
      return ImportResultData(
        success: false,
        message: 'Trello import failed: ${e.toString()}',
        importedCount: 0,
        skippedCount: 0,
        errors: [e.toString()],
      );
    }
  }
  
  /// Import data from Asana projects
  Future<ImportResultData> importFromAsana({
    required String projectId,
    required String personalAccessToken,
    ImportOptions? options,
  }) async {
    try {
      final config = ExternalPlatformConfig(
        source: ImportSource.asana,
        apiKey: personalAccessToken,
        baseUrl: 'https://app.asana.com/api/1.0',
        headers: {'Authorization': 'Bearer $personalAccessToken'},
        requiresAuthentication: true,
      );
      
      // Fetch project data
      final projectData = await _fetchAsanaProject(projectId, config);
      final tasks = await _fetchAsanaTasks(projectId, config);
      
      // Convert to internal format
      final project = _convertAsanaProjectToProject(projectData);
      final convertedTasks = tasks.map((task) => _convertAsanaTaskToTask(task, projectId)).toList();
      
      return ImportResultData(
        success: true,
        message: 'Successfully imported ${convertedTasks.length} tasks from Asana',
        importedCount: convertedTasks.length,
        skippedCount: 0,
        errors: [],
        importedAt: DateTime.now(),
        metadata: {
          'source': 'asana',
          'projectId': projectId,
          'projectName': projectData['name'],
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Asana import error: $e');
      }
      return ImportResultData(
        success: false,
        message: 'Asana import failed: ${e.toString()}',
        importedCount: 0,
        skippedCount: 0,
        errors: [e.toString()],
      );
    }
  }
  
  /// Import data from Microsoft Project XML files
  Future<ImportResultData> importFromMicrosoftProject({
    required String filePath,
    ImportOptions? options,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return const ImportResultData(
          success: false,
          message: 'Microsoft Project file not found',
          importedCount: 0,
          skippedCount: 0,
          errors: ['File does not exist'],
        );
      }
      
      final xmlContent = await file.readAsString();
      final document = XmlDocument.parse(xmlContent);
      
      // Extract project information
      final projectElement = document.findElements('Project').first;
      final project = _convertMSProjectToProject(projectElement);
      
      // Extract tasks
      final taskElements = projectElement.findElements('Tasks').first.findElements('Task');
      final tasks = taskElements.map((element) => _convertMSProjectTaskToTask(element, project.id)).toList();
      
      return ImportResultData(
        success: true,
        message: 'Successfully imported ${tasks.length} tasks from Microsoft Project',
        importedCount: tasks.length,
        skippedCount: 0,
        errors: [],
        importedAt: DateTime.now(),
        metadata: {
          'source': 'microsoftProject',
          'fileName': path.basename(filePath),
          'projectName': project.name,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Microsoft Project import error: $e');
      }
      return ImportResultData(
        success: false,
        message: 'Microsoft Project import failed: ${e.toString()}',
        importedCount: 0,
        skippedCount: 0,
        errors: [e.toString()],
      );
    }
  }
  
  /// Import data from Notion databases
  Future<ImportResultData> importFromNotion({
    required String databaseId,
    required String integrationToken,
    ImportOptions? options,
  }) async {
    try {
      final config = ExternalPlatformConfig(
        source: ImportSource.notion,
        apiKey: integrationToken,
        baseUrl: 'https://api.notion.com/v1',
        headers: {
          'Authorization': 'Bearer $integrationToken',
          'Notion-Version': '2022-06-28',
          'Content-Type': 'application/json',
        },
        requiresAuthentication: true,
      );
      
      // Fetch database pages
      final pages = await _fetchNotionDatabasePages(databaseId, config);
      
      // Convert to tasks
      final tasks = pages.map((page) => _convertNotionPageToTask(page)).toList();
      
      return ImportResultData(
        success: true,
        message: 'Successfully imported ${tasks.length} tasks from Notion',
        importedCount: tasks.length,
        skippedCount: 0,
        errors: [],
        importedAt: DateTime.now(),
        metadata: {
          'source': 'notion',
          'databaseId': databaseId,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Notion import error: $e');
      }
      return ImportResultData(
        success: false,
        message: 'Notion import failed: ${e.toString()}',
        importedCount: 0,
        skippedCount: 0,
        errors: [e.toString()],
      );
    }
  }
  
  /// Import data from Todoist projects
  Future<ImportResultData> importFromTodoist({
    required String projectId,
    required String apiToken,
    ImportOptions? options,
  }) async {
    try {
      final config = ExternalPlatformConfig(
        source: ImportSource.todoist,
        apiKey: apiToken,
        baseUrl: 'https://api.todoist.com/rest/v2',
        headers: {'Authorization': 'Bearer $apiToken'},
        requiresAuthentication: true,
      );
      
      // Fetch project and tasks
      final projectData = await _fetchTodoistProject(projectId, config);
      final tasks = await _fetchTodoistTasks(projectId, config);
      
      // Convert to internal format
      final project = _convertTodoistProjectToProject(projectData);
      final convertedTasks = tasks.map((task) => _convertTodoistTaskToTask(task, projectId)).toList();
      
      return ImportResultData(
        success: true,
        message: 'Successfully imported ${convertedTasks.length} tasks from Todoist',
        importedCount: convertedTasks.length,
        skippedCount: 0,
        errors: [],
        importedAt: DateTime.now(),
        metadata: {
          'source': 'todoist',
          'projectId': projectId,
          'projectName': projectData['name'],
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Todoist import error: $e');
      }
      return ImportResultData(
        success: false,
        message: 'Todoist import failed: ${e.toString()}',
        importedCount: 0,
        skippedCount: 0,
        errors: [e.toString()],
      );
    }
  }
  
  /// Import data from JIRA projects
  Future<ImportResultData> importFromJira({
    required String baseUrl,
    required String projectKey,
    required String email,
    required String apiToken,
    ImportOptions? options,
  }) async {
    try {
      final config = ExternalPlatformConfig(
        source: ImportSource.jira,
        apiKey: apiToken,
        baseUrl: baseUrl,
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$email:$apiToken'))}',
          'Accept': 'application/json',
        },
        requiresAuthentication: true,
      );
      
      // Fetch project and issues
      final projectData = await _fetchJiraProject(projectKey, config);
      final issues = await _fetchJiraIssues(projectKey, config);
      
      // Convert to internal format
      final project = _convertJiraProjectToProject(projectData);
      final convertedTasks = issues.map((issue) => _convertJiraIssueToTask(issue, project.id)).toList();
      
      return ImportResultData(
        success: true,
        message: 'Successfully imported ${convertedTasks.length} tasks from JIRA',
        importedCount: convertedTasks.length,
        skippedCount: 0,
        errors: [],
        importedAt: DateTime.now(),
        metadata: {
          'source': 'jira',
          'projectKey': projectKey,
          'projectName': projectData['name'],
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('JIRA import error: $e');
      }
      return ImportResultData(
        success: false,
        message: 'JIRA import failed: ${e.toString()}',
        importedCount: 0,
        skippedCount: 0,
        errors: [e.toString()],
      );
    }
  }
  
  // Trello API methods
  Future<Map<String, dynamic>> _fetchTrelloBoard(String boardId, ExternalPlatformConfig config) async {
    final url = Uri.parse('${config.baseUrl}/boards/$boardId?key=${config.apiKey}&token=${config.headers['Authorization']?.split('oauth_token="')[1].split('"')[0]}');
    final response = await _httpClient.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to fetch Trello board: ${response.statusCode}');
  }
  
  Future<List<Map<String, dynamic>>> _fetchTrelloLists(String boardId, ExternalPlatformConfig config) async {
    final url = Uri.parse('${config.baseUrl}/boards/$boardId/lists?key=${config.apiKey}&token=${config.headers['Authorization']?.split('oauth_token="')[1].split('"')[0]}');
    final response = await _httpClient.get(url);
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception('Failed to fetch Trello lists: ${response.statusCode}');
  }
  
  Future<List<Map<String, dynamic>>> _fetchTrelloCards(String boardId, ExternalPlatformConfig config) async {
    final url = Uri.parse('${config.baseUrl}/boards/$boardId/cards?key=${config.apiKey}&token=${config.headers['Authorization']?.split('oauth_token="')[1].split('"')[0]}');
    final response = await _httpClient.get(url);
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception('Failed to fetch Trello cards: ${response.statusCode}');
  }
  
  // Asana API methods
  Future<Map<String, dynamic>> _fetchAsanaProject(String projectId, ExternalPlatformConfig config) async {
    final url = Uri.parse('${config.baseUrl}/projects/$projectId');
    final response = await _httpClient.get(url, headers: config.headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    throw Exception('Failed to fetch Asana project: ${response.statusCode}');
  }
  
  Future<List<Map<String, dynamic>>> _fetchAsanaTasks(String projectId, ExternalPlatformConfig config) async {
    final url = Uri.parse('${config.baseUrl}/tasks?project=$projectId');
    final response = await _httpClient.get(url, headers: config.headers);
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body)['data']);
    }
    throw Exception('Failed to fetch Asana tasks: ${response.statusCode}');
  }
  
  // Notion API methods
  Future<List<Map<String, dynamic>>> _fetchNotionDatabasePages(String databaseId, ExternalPlatformConfig config) async {
    final url = Uri.parse('${config.baseUrl}/databases/$databaseId/query');
    final response = await _httpClient.post(url, headers: config.headers, body: jsonEncode({}));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body)['results']);
    }
    throw Exception('Failed to fetch Notion database pages: ${response.statusCode}');
  }
  
  // Todoist API methods
  Future<Map<String, dynamic>> _fetchTodoistProject(String projectId, ExternalPlatformConfig config) async {
    final url = Uri.parse('${config.baseUrl}/projects/$projectId');
    final response = await _httpClient.get(url, headers: config.headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to fetch Todoist project: ${response.statusCode}');
  }
  
  Future<List<Map<String, dynamic>>> _fetchTodoistTasks(String projectId, ExternalPlatformConfig config) async {
    final url = Uri.parse('${config.baseUrl}/tasks?project_id=$projectId');
    final response = await _httpClient.get(url, headers: config.headers);
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception('Failed to fetch Todoist tasks: ${response.statusCode}');
  }
  
  // JIRA API methods
  Future<Map<String, dynamic>> _fetchJiraProject(String projectKey, ExternalPlatformConfig config) async {
    final url = Uri.parse('${config.baseUrl}/rest/api/2/project/$projectKey');
    final response = await _httpClient.get(url, headers: config.headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to fetch JIRA project: ${response.statusCode}');
  }
  
  Future<List<Map<String, dynamic>>> _fetchJiraIssues(String projectKey, ExternalPlatformConfig config) async {
    final url = Uri.parse('${config.baseUrl}/rest/api/2/search?jql=project=$projectKey');
    final response = await _httpClient.get(url, headers: config.headers);
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body)['issues']);
    }
    throw Exception('Failed to fetch JIRA issues: ${response.statusCode}');
  }
  
  // Conversion methods
  Project _convertTrelloBoardToProject(Map<String, dynamic> boardData, List<Map<String, dynamic>> lists) {
    return Project(
      id: boardData['id'],
      name: boardData['name'],
      description: boardData['desc'],
      color: '#2196F3', // Default color
      createdAt: DateTime.now(),
      taskIds: const [],
    );
  }
  
  TaskModel _convertTrelloCardToTask(Map<String, dynamic> cardData, List<Map<String, dynamic>> lists) {
    final listName = lists.firstWhere((list) => list['id'] == cardData['idList'])['name'];
    final status = _mapTrelloListToStatus(listName);
    
    return TaskModel(
      id: cardData['id'],
      title: cardData['name'],
      description: cardData['desc'],
      status: status,
      priority: TaskPriority.medium, // Default priority
      createdAt: DateTime.parse(cardData['dateLastActivity']),
      dueDate: cardData['due'] != null ? DateTime.parse(cardData['due']) : null,
      tags: List<String>.from(cardData['labels']?.map((label) => label['name']) ?? []),
      isPinned: false,
    );
  }
  
  Project _convertAsanaProjectToProject(Map<String, dynamic> projectData) {
    return Project(
      id: projectData['gid'],
      name: projectData['name'],
      description: projectData['notes'],
      color: projectData['color'] ?? '#2196F3',
      createdAt: DateTime.parse(projectData['created_at']),
      taskIds: const [],
    );
  }
  
  TaskModel _convertAsanaTaskToTask(Map<String, dynamic> taskData, String projectId) {
    return TaskModel(
      id: taskData['gid'],
      title: taskData['name'],
      description: taskData['notes'],
      status: taskData['completed'] ? TaskStatus.completed : TaskStatus.pending,
      priority: TaskPriority.medium, // Default priority
      createdAt: DateTime.parse(taskData['created_at']),
      dueDate: taskData['due_at'] != null ? DateTime.parse(taskData['due_at']) : null,
      projectId: projectId,
      tags: const [],
      isPinned: false,
    );
  }
  
  Project _convertMSProjectToProject(XmlElement projectElement) {
    final name = projectElement.findElements('Name').first.innerText;
    final creationDate = projectElement.findElements('CreationDate').first.innerText;
    
    return Project(
      id: 'ms_project_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: 'Imported from Microsoft Project',
      color: '#2196F3',
      createdAt: DateTime.parse(creationDate),
      taskIds: const [],
    );
  }
  
  TaskModel _convertMSProjectTaskToTask(XmlElement taskElement, String projectId) {
    final uid = taskElement.findElements('UID').first.innerText;
    final name = taskElement.findElements('Name').first.innerText;
    final notes = taskElement.findElements('Notes').firstOrNull?.innerText ?? '';
    final start = taskElement.findElements('Start').first.innerText;
    final finish = taskElement.findElements('Finish').first.innerText;
    final percentComplete = int.parse(taskElement.findElements('PercentComplete').first.innerText);
    
    return TaskModel(
      id: 'ms_task_$uid',
      title: name,
      description: notes,
      status: percentComplete == 100 ? TaskStatus.completed : 
              percentComplete > 0 ? TaskStatus.inProgress : TaskStatus.pending,
      priority: TaskPriority.medium,
      createdAt: DateTime.parse(start),
      dueDate: DateTime.parse(finish),
      projectId: projectId,
      tags: const [],
      isPinned: false,
    );
  }
  
  TaskModel _convertNotionPageToTask(Map<String, dynamic> pageData) {
    final properties = pageData['properties'];
    final title = properties['Name']?['title']?[0]?['plain_text'] ?? 'Untitled';
    final status = properties['Status']?['select']?['name'] ?? 'To Do';
    
    return TaskModel(
      id: pageData['id'],
      title: title,
      description: '',
      status: _mapNotionStatusToStatus(status),
      priority: TaskPriority.medium,
      createdAt: DateTime.parse(pageData['created_time']),
      tags: const [],
      isPinned: false,
    );
  }
  
  Project _convertTodoistProjectToProject(Map<String, dynamic> projectData) {
    return Project(
      id: projectData['id'].toString(),
      name: projectData['name'],
      description: projectData['comment_count']?.toString() ?? '',
      color: projectData['color'] ?? '#2196F3',
      createdAt: DateTime.now(), // Todoist doesn't provide creation date in API
      taskIds: const [],
    );
  }
  
  TaskModel _convertTodoistTaskToTask(Map<String, dynamic> taskData, String projectId) {
    return TaskModel(
      id: taskData['id'].toString(),
      title: taskData['content'],
      description: taskData['description'] ?? '',
      status: taskData['is_completed'] ? TaskStatus.completed : TaskStatus.pending,
      priority: _mapTodoistPriorityToPriority(taskData['priority']),
      createdAt: DateTime.parse(taskData['created_at']),
      dueDate: taskData['due']?['date'] != null ? DateTime.parse(taskData['due']['date']) : null,
      projectId: projectId,
      tags: List<String>.from(taskData['labels'] ?? []),
      isPinned: false,
    );
  }
  
  Project _convertJiraProjectToProject(Map<String, dynamic> projectData) {
    return Project(
      id: projectData['key'],
      name: projectData['name'],
      description: projectData['description'] ?? '',
      color: '#2196F3',
      createdAt: DateTime.now(),
      taskIds: const [],
    );
  }
  
  TaskModel _convertJiraIssueToTask(Map<String, dynamic> issueData, String projectId) {
    final fields = issueData['fields'];
    
    return TaskModel(
      id: issueData['key'],
      title: fields['summary'],
      description: fields['description'] ?? '',
      status: _mapJiraStatusToStatus(fields['status']['name']),
      priority: _mapJiraPriorityToPriority(fields['priority']?['name']),
      createdAt: DateTime.parse(fields['created']),
      dueDate: fields['duedate'] != null ? DateTime.parse(fields['duedate']) : null,
      projectId: projectId,
      tags: List<String>.from(fields['labels'] ?? []),
      isPinned: false,
    );
  }
  
  // Helper mapping methods
  TaskStatus _mapTrelloListToStatus(String listName) {
    final lowerName = listName.toLowerCase();
    if (lowerName.contains('done') || lowerName.contains('complete')) {
      return TaskStatus.completed;
    } else if (lowerName.contains('doing') || lowerName.contains('progress')) {
      return TaskStatus.inProgress;
    }
    return TaskStatus.pending;
  }
  
  TaskStatus _mapNotionStatusToStatus(String status) {
    switch (status.toLowerCase()) {
      case 'done':
      case 'completed':
        return TaskStatus.completed;
      case 'in progress':
      case 'doing':
        return TaskStatus.inProgress;
      case 'cancelled':
        return TaskStatus.cancelled;
      default:
        return TaskStatus.pending;
    }
  }
  
  TaskPriority _mapTodoistPriorityToPriority(int priority) {
    switch (priority) {
      case 4:
        return TaskPriority.urgent;
      case 3:
        return TaskPriority.high;
      case 2:
        return TaskPriority.medium;
      case 1:
      default:
        return TaskPriority.low;
    }
  }
  
  TaskStatus _mapJiraStatusToStatus(String status) {
    switch (status.toLowerCase()) {
      case 'done':
      case 'closed':
      case 'resolved':
        return TaskStatus.completed;
      case 'in progress':
        return TaskStatus.inProgress;
      case 'cancelled':
        return TaskStatus.cancelled;
      default:
        return TaskStatus.pending;
    }
  }
  
  TaskPriority _mapJiraPriorityToPriority(String? priority) {
    if (priority == null) return TaskPriority.medium;
    
    switch (priority.toLowerCase()) {
      case 'highest':
      case 'critical':
        return TaskPriority.urgent;
      case 'high':
        return TaskPriority.high;
      case 'medium':
        return TaskPriority.medium;
      case 'low':
      case 'lowest':
        return TaskPriority.low;
      default:
        return TaskPriority.medium;
    }
  }
  
  void dispose() {
    _httpClient.close();
  }
}