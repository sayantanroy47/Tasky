import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart';

import '../../domain/entities/project.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import 'data_export_models.dart';

/// Microsoft Project export service for professional project management integration
class MicrosoftProjectExportService {
  
  /// Export project data to Microsoft Project XML format (.xml)
  Future<ExportResult> exportToMicrosoftProjectXML({
    required List<Project> projects,
    required List<TaskModel> tasks,
    required String filePath,
    ExportOptions? options,
  }) async {
    try {
      final xmlDocument = _createMicrosoftProjectXML(projects, tasks, options);
      
      final file = File(filePath);
      await file.writeAsString(xmlDocument.toXmlString(pretty: true, indent: '  '));
      
      return ExportResult(
        success: true,
        message: 'Microsoft Project XML export completed successfully',
        filePath: filePath,
        fileSize: await file.length(),
        exportedAt: DateTime.now(),
        metadata: {
          'format': 'mspx',
          'projectCount': projects.length,
          'taskCount': tasks.length,
          'version': 'Microsoft Project 2019',
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Microsoft Project XML export error: $e');
      }
      return ExportResult(
        success: false,
        message: 'Microsoft Project XML export failed: ${e.toString()}',
        filePath: null,
        fileSize: 0,
      );
    }
  }
  
  /// Export project data to Microsoft Project compatible JSON format
  Future<ExportResult> exportToMicrosoftProjectJSON({
    required List<Project> projects,
    required List<TaskModel> tasks,
    required String filePath,
    ExportOptions? options,
  }) async {
    try {
      final projectData = _createMicrosoftProjectJSON(projects, tasks, options);
      
      final file = File(filePath);
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(projectData),
      );
      
      return ExportResult(
        success: true,
        message: 'Microsoft Project JSON export completed successfully',
        filePath: filePath,
        fileSize: await file.length(),
        exportedAt: DateTime.now(),
        metadata: {
          'format': 'mspj',
          'projectCount': projects.length,
          'taskCount': tasks.length,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Microsoft Project JSON export error: $e');
      }
      return ExportResult(
        success: false,
        message: 'Microsoft Project JSON export failed: ${e.toString()}',
        filePath: null,
        fileSize: 0,
      );
    }
  }
  
  /// Create Gantt chart compatible export
  Future<ExportResult> exportToGanttChart({
    required List<Project> projects,
    required List<TaskModel> tasks,
    required String filePath,
    ExportOptions? options,
  }) async {
    try {
      final ganttData = _createGanttChartData(projects, tasks, options);
      
      final file = File(filePath);
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(ganttData),
      );
      
      return ExportResult(
        success: true,
        message: 'Gantt chart export completed successfully',
        filePath: filePath,
        fileSize: await file.length(),
        exportedAt: DateTime.now(),
        metadata: {
          'format': 'gantt_json',
          'projectCount': projects.length,
          'taskCount': tasks.length,
          'supportsTimeline': true,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Gantt chart export error: $e');
      }
      return ExportResult(
        success: false,
        message: 'Gantt chart export failed: ${e.toString()}',
        filePath: null,
        fileSize: 0,
      );
    }
  }
  
  /// Create Microsoft Project XML document
  XmlDocument _createMicrosoftProjectXML(
    List<Project> projects,
    List<TaskModel> tasks,
    ExportOptions? options,
  ) {
    final builder = XmlBuilder();
    
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('Project', nest: () {
      builder.attribute('xmlns', 'http://schemas.microsoft.com/project');
      
      // Project properties
      builder.element('Name', nest: () {
        builder.text(projects.isNotEmpty ? projects.first.name : 'Tasky Export');
      });
      
      builder.element('Title', nest: () {
        builder.text('Exported from Tasky Task Management');
      });
      
      builder.element('CreationDate', nest: () {
        builder.text(DateTime.now().toIso8601String());
      });
      
      builder.element('LastSaved', nest: () {
        builder.text(DateTime.now().toIso8601String());
      });
      
      builder.element('ScheduleFromStart', nest: () {
        builder.text('1');
      });
      
      builder.element('StartDate', nest: () {
        final earliestDate = _getEarliestDate(tasks);
        builder.text(earliestDate.toIso8601String());
      });
      
      builder.element('FinishDate', nest: () {
        final latestDate = _getLatestDate(tasks);
        builder.text(latestDate.toIso8601String());
      });
      
      // Calendar information
      _addCalendarInfo(builder);
      
      // Tasks
      builder.element('Tasks', nest: () {
        _addTasksToXML(builder, tasks, projects);
      });
      
      // Resources (placeholder)
      builder.element('Resources', nest: () {
        _addResourcesToXML(builder, tasks);
      });
      
      // Assignments
      builder.element('Assignments', nest: () {
        _addAssignmentsToXML(builder, tasks);
      });
    });
    
    return builder.buildDocument();
  }
  
  /// Create Microsoft Project compatible JSON structure
  Map<String, dynamic> _createMicrosoftProjectJSON(
    List<Project> projects,
    List<TaskModel> tasks,
    ExportOptions? options,
  ) {
    return {
      'formatVersion': '1.0',
      'application': 'Tasky Task Management',
      'exportDate': DateTime.now().toIso8601String(),
      'project': {
        'name': projects.isNotEmpty ? projects.first.name : 'Tasky Export',
        'description': 'Exported from Tasky Task Management System',
        'startDate': _getEarliestDate(tasks).toIso8601String(),
        'endDate': _getLatestDate(tasks).toIso8601String(),
        'status': 'active',
        'priority': 'medium',
        'manager': 'Tasky User',
      },
      'tasks': tasks.map((task) => _convertTaskToMSProjectFormat(task)).toList(),
      'resources': _createResourcesList(tasks),
      'assignments': _createAssignmentsList(tasks),
      'dependencies': _createDependenciesList(tasks),
      'milestones': _createMilestonesList(projects, tasks),
      'metadata': {
        'projectCount': projects.length,
        'taskCount': tasks.length,
        'exportOptions': options?.customOptions ?? {},
      },
    };
  }
  
  /// Create Gantt chart compatible data structure
  Map<String, dynamic> _createGanttChartData(
    List<Project> projects,
    List<TaskModel> tasks,
    ExportOptions? options,
  ) {
    return {
      'gantt': {
        'project': {
          'id': projects.isNotEmpty ? projects.first.id : 'default',
          'name': projects.isNotEmpty ? projects.first.name : 'Tasky Export',
          'start': _getEarliestDate(tasks).toIso8601String(),
          'end': _getLatestDate(tasks).toIso8601String(),
        },
        'tasks': tasks.map((task) => _convertTaskToGanttFormat(task)).toList(),
        'links': _createGanttLinks(tasks),
        'resources': tasks.fold<Set<String>>({}, (resources, task) {
          resources.add(task.projectId ?? 'unassigned');
          return resources;
        }).map((resource) => {
          'id': resource,
          'name': resource == 'unassigned' ? 'Unassigned' : resource,
          'type': 'work',
        }).toList(),
        'settings': {
          'readonly': false,
          'duration_unit': 'day',
          'task_height': 30,
          'row_height': 35,
          'grid_width': 400,
          'date_format': '%Y-%m-%d',
        },
      },
    };
  }
  
  /// Add calendar information to XML
  void _addCalendarInfo(XmlBuilder builder) {
    builder.element('Calendars', nest: () {
      builder.element('Calendar', nest: () {
        builder.element('UID', nest: () => builder.text('1'));
        builder.element('Name', nest: () => builder.text('Standard'));
        builder.element('IsBaseCalendar', nest: () => builder.text('1'));
        builder.element('IsBaselineCalendar', nest: () => builder.text('0'));
        
        // Working days
        for (int i = 1; i <= 7; i++) {
          builder.element('WeekDay', nest: () {
            builder.element('DayType', nest: () => builder.text(i.toString()));
            builder.element('DayWorking', nest: () => builder.text(i <= 5 ? '1' : '0'));
            
            if (i <= 5) {
              builder.element('WorkingTimes', nest: () {
                builder.element('WorkingTime', nest: () {
                  builder.element('FromTime', nest: () => builder.text('09:00:00'));
                  builder.element('ToTime', nest: () => builder.text('17:00:00'));
                });
              });
            }
          });
        }
      });
    });
  }
  
  /// Add tasks to XML
  void _addTasksToXML(
    XmlBuilder builder,
    List<TaskModel> tasks,
    List<Project> projects,
  ) {
    for (int i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      builder.element('Task', nest: () {
        builder.element('UID', nest: () => builder.text((i + 1).toString()));
        builder.element('ID', nest: () => builder.text((i + 1).toString()));
        builder.element('Name', nest: () => builder.text(task.title));
        builder.element('Notes', nest: () => builder.text(task.description ?? ''));
        
        builder.element('Start', nest: () => builder.text(task.createdAt.toIso8601String()));
        builder.element('Finish', nest: () {
          final finish = task.dueDate ?? task.createdAt.add(const Duration(days: 1));
          builder.text(finish.toIso8601String());
        });
        
        builder.element('Duration', nest: () {
          final duration = task.dueDate?.difference(task.createdAt).inDays ?? 1;
          builder.text('PT${duration * 8}H0M0S'); // Convert to hours assuming 8-hour workdays
        });
        
        builder.element('Priority', nest: () {
          final priority = _convertPriorityToMSProject(task.priority);
          builder.text(priority.toString());
        });
        
        builder.element('PercentComplete', nest: () {
          final percent = _getTaskCompletionPercent(task);
          builder.text(percent.toString());
        });
        
        builder.element('IsEffortDriven', nest: () => builder.text('0'));
        builder.element('IsMilestone', nest: () => builder.text('0'));
        builder.element('IsPublished', nest: () => builder.text('1'));
        
        if (task.tags.isNotEmpty) {
          builder.element('Text1', nest: () => builder.text(task.tags.join(', ')));
        }
      });
    }
  }
  
  /// Add resources to XML
  void _addResourcesToXML(XmlBuilder builder, List<TaskModel> tasks) {
    final resources = <String>{};
    for (final task in tasks) {
      if (task.projectId != null) {
        resources.add(task.projectId!);
      }
    }
    
    int uid = 1;
    for (final resource in resources) {
      builder.element('Resource', nest: () {
        builder.element('UID', nest: () => builder.text(uid.toString()));
        builder.element('ID', nest: () => builder.text(uid.toString()));
        builder.element('Name', nest: () => builder.text(resource));
        builder.element('Type', nest: () => builder.text('1')); // Work resource
        builder.element('IsGeneric', nest: () => builder.text('0'));
        builder.element('IsInactive', nest: () => builder.text('0'));
        builder.element('IsEnterprise', nest: () => builder.text('0'));
        uid++;
      });
    }
  }
  
  /// Add assignments to XML
  void _addAssignmentsToXML(XmlBuilder builder, List<TaskModel> tasks) {
    int uid = 1;
    for (int i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      if (task.projectId != null) {
        builder.element('Assignment', nest: () {
          builder.element('UID', nest: () => builder.text(uid.toString()));
          builder.element('TaskUID', nest: () => builder.text((i + 1).toString()));
          builder.element('ResourceUID', nest: () => builder.text('1')); // Simplified
          builder.element('Units', nest: () => builder.text('1.0'));
          uid++;
        });
      }
    }
  }
  
  /// Convert task to Microsoft Project format
  Map<String, dynamic> _convertTaskToMSProjectFormat(TaskModel task) {
    return {
      'id': task.id,
      'name': task.title,
      'notes': task.description,
      'start': task.createdAt.toIso8601String(),
      'finish': (task.dueDate ?? task.createdAt.add(const Duration(days: 1))).toIso8601String(),
      'duration': task.dueDate?.difference(task.createdAt).inDays ?? 1,
      'priority': _convertPriorityToMSProject(task.priority),
      'percentComplete': _getTaskCompletionPercent(task),
      'status': task.status.name,
      'tags': task.tags,
      'projectId': task.projectId,
      'estimatedHours': task.estimatedDuration,
      'actualHours': task.actualDuration,
      'isPinned': task.isPinned,
    };
  }
  
  /// Convert task to Gantt format
  Map<String, dynamic> _convertTaskToGanttFormat(TaskModel task) {
    return {
      'id': task.id,
      'text': task.title,
      'start_date': _formatDateForGantt(task.createdAt),
      'end_date': _formatDateForGantt(task.dueDate ?? task.createdAt.add(const Duration(days: 1))),
      'duration': task.dueDate?.difference(task.createdAt).inDays ?? 1,
      'progress': _getTaskCompletionPercent(task) / 100.0,
      'priority': task.priority.index + 1,
      'status': task.status.name,
      'description': task.description ?? '',
      'tags': task.tags.join(', '),
      'project': task.projectId ?? 'unassigned',
    };
  }
  
  /// Create resources list
  List<Map<String, dynamic>> _createResourcesList(List<TaskModel> tasks) {
    final resources = <String, Map<String, dynamic>>{};
    
    for (final task in tasks) {
      final projectId = task.projectId ?? 'unassigned';
      if (!resources.containsKey(projectId)) {
        resources[projectId] = {
          'id': projectId,
          'name': projectId == 'unassigned' ? 'Unassigned' : projectId,
          'type': 'project',
          'email': '',
          'role': 'contributor',
          'capacity': 8, // hours per day
        };
      }
    }
    
    return resources.values.toList();
  }
  
  /// Create assignments list
  List<Map<String, dynamic>> _createAssignmentsList(List<TaskModel> tasks) {
    return tasks.map((task) => {
      'taskId': task.id,
      'resourceId': task.projectId ?? 'unassigned',
      'allocation': 100, // percentage
      'role': 'assignee',
    }).toList();
  }
  
  /// Create dependencies list (placeholder)
  List<Map<String, dynamic>> _createDependenciesList(List<TaskModel> tasks) {
    // In a real implementation, this would analyze task dependencies
    return [];
  }
  
  /// Create milestones list
  List<Map<String, dynamic>> _createMilestonesList(
    List<Project> projects,
    List<TaskModel> tasks,
  ) {
    final milestones = <Map<String, dynamic>>[];
    
    // Create project deadline milestones
    for (final project in projects) {
      if (project.deadline != null) {
        milestones.add({
          'id': '${project.id}_deadline',
          'name': '${project.name} Deadline',
          'date': project.deadline!.toIso8601String(),
          'description': 'Project completion deadline',
          'projectId': project.id,
        });
      }
    }
    
    return milestones;
  }
  
  /// Create Gantt links (dependencies)
  List<Map<String, dynamic>> _createGanttLinks(List<TaskModel> tasks) {
    // Placeholder for task dependencies
    return [];
  }
  
  /// Get earliest task date
  DateTime _getEarliestDate(List<TaskModel> tasks) {
    if (tasks.isEmpty) return DateTime.now();
    return tasks.map((t) => t.createdAt).reduce((a, b) => a.isBefore(b) ? a : b);
  }
  
  /// Get latest task date
  DateTime _getLatestDate(List<TaskModel> tasks) {
    if (tasks.isEmpty) return DateTime.now().add(const Duration(days: 30));
    final latestDue = tasks
        .where((t) => t.dueDate != null)
        .map((t) => t.dueDate!)
        .fold<DateTime?>(null, (latest, date) => 
            latest == null || date.isAfter(latest) ? date : latest);
    return latestDue ?? DateTime.now().add(const Duration(days: 30));
  }
  
  /// Convert priority to Microsoft Project priority scale (0-1000)
  int _convertPriorityToMSProject(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 200;
      case TaskPriority.medium:
        return 500;
      case TaskPriority.high:
        return 800;
      case TaskPriority.urgent:
        return 1000;
    }
  }
  
  /// Get task completion percentage
  int _getTaskCompletionPercent(TaskModel task) {
    switch (task.status) {
      case TaskStatus.completed:
        return 100;
      case TaskStatus.inProgress:
        return 50;
      case TaskStatus.pending:
        return 0;
      case TaskStatus.cancelled:
        return 0;
    }
  }
  
  /// Format date for Gantt chart
  String _formatDateForGantt(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }
}