import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../domain/entities/project.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../../services/analytics/analytics_service.dart';
import 'data_export_models.dart';
import 'excel_export_service.dart';

/// Enterprise reporting service for creating professional reports and dashboards
class EnterpriseReportingService {
  final ExcelExportService _excelService;
  final AnalyticsService? _analyticsService;
  
  EnterpriseReportingService({
    ExcelExportService? excelService,
    AnalyticsService? analyticsService,
  }) : _excelService = excelService ?? ExcelExportService(),
       _analyticsService = analyticsService;
  
  /// Generate executive summary report
  Future<ExportResult> generateExecutiveSummaryReport({
    required List<TaskModel> tasks,
    required List<Project> projects,
    required String filePath,
    ExportOptions? options,
  }) async {
    try {
      final reportData = await _generateExecutiveSummaryData(tasks, projects);
      
      if (filePath.endsWith('.pdf')) {
        return await _createExecutiveSummaryPDF(reportData, filePath);
      } else if (filePath.endsWith('.xlsx')) {
        return await _excelService.createExecutiveDashboard(
          tasks: tasks,
          projects: projects,
          filePath: filePath,
          options: options,
        );
      } else {
        return await _createExecutiveSummaryJSON(reportData, filePath);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Executive summary report error: $e');
      }
      return ExportResult(
        success: false,
        message: 'Executive summary report failed: ${e.toString()}',
        filePath: null,
        fileSize: 0,
      );
    }
  }
  
  /// Generate detailed project performance report
  Future<ExportResult> generateProjectPerformanceReport({
    required List<Project> projects,
    required List<TaskModel> tasks,
    required String filePath,
    ExportOptions? options,
  }) async {
    try {
      final reportData = await _generateProjectPerformanceData(projects, tasks);
      
      if (filePath.endsWith('.pdf')) {
        return await _createProjectPerformancePDF(reportData, filePath);
      } else if (filePath.endsWith('.xlsx')) {
        return await _excelService.exportProjectsToExcel(
          projects: projects,
          allTasks: tasks,
          filePath: filePath,
          options: options,
        );
      } else {
        return await _createProjectPerformanceJSON(reportData, filePath);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Project performance report error: $e');
      }
      return ExportResult(
        success: false,
        message: 'Project performance report failed: ${e.toString()}',
        filePath: null,
        fileSize: 0,
      );
    }
  }
  
  /// Generate team productivity report
  Future<ExportResult> generateTeamProductivityReport({
    required List<TaskModel> tasks,
    required List<Project> projects,
    required String filePath,
    DateTime? startDate,
    DateTime? endDate,
    ExportOptions? options,
  }) async {
    try {
      final reportData = await _generateTeamProductivityData(
        tasks,
        projects,
        startDate,
        endDate,
      );
      
      if (filePath.endsWith('.pdf')) {
        return await _createTeamProductivityPDF(reportData, filePath);
      } else {
        return await _createTeamProductivityJSON(reportData, filePath);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Team productivity report error: $e');
      }
      return ExportResult(
        success: false,
        message: 'Team productivity report failed: ${e.toString()}',
        filePath: null,
        fileSize: 0,
      );
    }
  }
  
  /// Generate risk analysis report
  Future<ExportResult> generateRiskAnalysisReport({
    required List<TaskModel> tasks,
    required List<Project> projects,
    required String filePath,
    ExportOptions? options,
  }) async {
    try {
      final reportData = await _generateRiskAnalysisData(tasks, projects);
      
      if (filePath.endsWith('.pdf')) {
        return await _createRiskAnalysisPDF(reportData, filePath);
      } else {
        return await _createRiskAnalysisJSON(reportData, filePath);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Risk analysis report error: $e');
      }
      return ExportResult(
        success: false,
        message: 'Risk analysis report failed: ${e.toString()}',
        filePath: null,
        fileSize: 0,
      );
    }
  }
  
  /// Generate custom report based on template
  Future<ExportResult> generateCustomReport({
    required ReportTemplate template,
    required List<TaskModel> tasks,
    required List<Project> projects,
    required String filePath,
    Map<String, dynamic> parameters = const {},
    ExportOptions? options,
  }) async {
    try {
      final reportData = await _generateCustomReportData(
        template,
        tasks,
        projects,
        parameters,
      );
      
      if (filePath.endsWith('.pdf')) {
        return await _createCustomReportPDF(template, reportData, filePath);
      } else {
        return await _createCustomReportJSON(template, reportData, filePath);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Custom report error: $e');
      }
      return ExportResult(
        success: false,
        message: 'Custom report failed: ${e.toString()}',
        filePath: null,
        fileSize: 0,
      );
    }
  }
  
  /// Generate time tracking report
  Future<ExportResult> generateTimeTrackingReport({
    required List<TaskModel> tasks,
    required String filePath,
    DateTime? startDate,
    DateTime? endDate,
    ExportOptions? options,
  }) async {
    try {
      final reportData = await _generateTimeTrackingData(tasks, startDate, endDate);
      
      if (filePath.endsWith('.pdf')) {
        return await _createTimeTrackingPDF(reportData, filePath);
      } else {
        return await _createTimeTrackingJSON(reportData, filePath);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Time tracking report error: $e');
      }
      return ExportResult(
        success: false,
        message: 'Time tracking report failed: ${e.toString()}',
        filePath: null,
        fileSize: 0,
      );
    }
  }
  
  // Data generation methods
  
  Future<Map<String, dynamic>> _generateExecutiveSummaryData(
    List<TaskModel> tasks,
    List<Project> projects,
  ) async {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    
    // Overall statistics
    final totalTasks = tasks.length;
    final completedTasks = tasks.where((t) => t.status == TaskStatus.completed).length;
    final inProgressTasks = tasks.where((t) => t.status == TaskStatus.inProgress).length;
    final overdueTasks = tasks.where((t) => 
      t.dueDate != null && 
      t.dueDate!.isBefore(now) && 
      t.status != TaskStatus.completed
    ).length;
    
    final activeProjects = projects.where((p) => !p.isArchived).length;
    final completedProjects = projects.where((p) => 
      p.taskIds.isNotEmpty && 
      p.taskIds.every((taskId) => 
        tasks.any((t) => t.id == taskId && t.status == TaskStatus.completed)
      )
    ).length;
    
    // Trends (last 30 days)
    final recentTasks = tasks.where((t) => t.createdAt.isAfter(thirtyDaysAgo)).length;
    final recentCompletions = tasks.where((t) => 
      t.completedAt != null && 
      t.completedAt!.isAfter(thirtyDaysAgo)
    ).length;
    
    // Performance metrics
    final completionRate = totalTasks > 0 ? (completedTasks / totalTasks * 100) : 0.0;
    final onTimeCompletionRate = _calculateOnTimeCompletionRate(tasks);
    final averageTaskDuration = _calculateAverageTaskDuration(tasks);
    
    // Top performing projects
    final projectPerformance = projects.map((project) {
      final projectTasks = tasks.where((t) => t.projectId == project.id).toList();
      final projectCompletionRate = projectTasks.isNotEmpty 
          ? (projectTasks.where((t) => t.status == TaskStatus.completed).length / projectTasks.length * 100)
          : 0.0;
      
      return {
        'project': project,
        'taskCount': projectTasks.length,
        'completionRate': projectCompletionRate,
        'overdueCount': projectTasks.where((t) => 
          t.dueDate != null && 
          t.dueDate!.isBefore(now) && 
          t.status != TaskStatus.completed
        ).length,
      };
    }).toList();
    
    projectPerformance.sort((a, b) => (b['completionRate'] as double).compareTo(a['completionRate'] as double));
    
    return {
      'generatedAt': now.toIso8601String(),
      'reportType': 'executive_summary',
      'period': {
        'from': thirtyDaysAgo.toIso8601String(),
        'to': now.toIso8601String(),
      },
      'overview': {
        'totalTasks': totalTasks,
        'completedTasks': completedTasks,
        'inProgressTasks': inProgressTasks,
        'overdueTasks': overdueTasks,
        'completionRate': completionRate.round(),
        'activeProjects': activeProjects,
        'completedProjects': completedProjects,
      },
      'trends': {
        'newTasksThisMonth': recentTasks,
        'completionsThisMonth': recentCompletions,
        'avgTaskDurationDays': averageTaskDuration.round(),
        'onTimeCompletionRate': onTimeCompletionRate.round(),
      },
      'topProjects': projectPerformance.take(5).toList(),
      'alerts': _generateAlerts(tasks, projects),
      'recommendations': _generateRecommendations(tasks, projects),
    };
  }
  
  Future<Map<String, dynamic>> _generateProjectPerformanceData(
    List<Project> projects,
    List<TaskModel> tasks,
  ) async {
    return {
      'generatedAt': DateTime.now().toIso8601String(),
      'reportType': 'project_performance',
      'projects': projects.map((project) {
        final projectTasks = tasks.where((t) => t.projectId == project.id).toList();
        return {
          'project': project.toJson(),
          'metrics': _calculateProjectMetrics(project, projectTasks),
          'timeline': _generateProjectTimeline(project, projectTasks),
          'riskFactors': _identifyProjectRisks(project, projectTasks),
        };
      }).toList(),
      'summary': _generateProjectSummary(projects, tasks),
    };
  }
  
  Future<Map<String, dynamic>> _generateTeamProductivityData(
    List<TaskModel> tasks,
    List<Project> projects,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final end = endDate ?? DateTime.now();
    
    final periodTasks = tasks.where((t) => 
      t.createdAt.isAfter(start) && t.createdAt.isBefore(end)
    ).toList();
    
    return {
      'generatedAt': DateTime.now().toIso8601String(),
      'reportType': 'team_productivity',
      'period': {
        'from': start.toIso8601String(),
        'to': end.toIso8601String(),
      },
      'metrics': {
        'totalTasks': periodTasks.length,
        'completedTasks': periodTasks.where((t) => t.status == TaskStatus.completed).length,
        'averageCompletionTime': _calculateAverageCompletionTime(periodTasks),
        'throughput': _calculateThroughput(periodTasks),
        'velocity': _calculateVelocity(periodTasks),
      },
      'trends': _generateProductivityTrends(periodTasks),
      'bottlenecks': _identifyBottlenecks(periodTasks, projects),
    };
  }
  
  Future<Map<String, dynamic>> _generateRiskAnalysisData(
    List<TaskModel> tasks,
    List<Project> projects,
  ) async {
    return {
      'generatedAt': DateTime.now().toIso8601String(),
      'reportType': 'risk_analysis',
      'risks': [
        ..._identifyTaskRisks(tasks),
        ..._identifyProjectRisks(projects, tasks),
        ..._identifyResourceRisks(tasks, projects),
      ],
      'riskMatrix': _generateRiskMatrix(tasks, projects),
      'mitigationStrategies': _generateMitigationStrategies(tasks, projects),
    };
  }
  
  Future<Map<String, dynamic>> _generateCustomReportData(
    ReportTemplate template,
    List<TaskModel> tasks,
    List<Project> projects,
    Map<String, dynamic> parameters,
  ) async {
    final data = <String, dynamic>{
      'generatedAt': DateTime.now().toIso8601String(),
      'reportType': 'custom',
      'template': template.toJson(),
      'parameters': parameters,
    };
    
    // Process each section based on template
    for (final section in template.sections) {
      switch (section) {
        case 'tasks':
          data['tasks'] = tasks.map((t) => t.toJson()).toList();
          break;
        case 'projects':
          data['projects'] = projects.map((p) => p.toJson()).toList();
          break;
        case 'analytics':
          data['analytics'] = await _generateAnalyticsSection(tasks, projects);
          break;
        case 'timeline':
          data['timeline'] = _generateTimelineSection(tasks, projects);
          break;
      }
    }
    
    return data;
  }
  
  Future<Map<String, dynamic>> _generateTimeTrackingData(
    List<TaskModel> tasks,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final end = endDate ?? DateTime.now();
    
    final periodTasks = tasks.where((t) => 
      t.createdAt.isAfter(start) && t.createdAt.isBefore(end)
    ).toList();
    
    return {
      'generatedAt': DateTime.now().toIso8601String(),
      'reportType': 'time_tracking',
      'period': {
        'from': start.toIso8601String(),
        'to': end.toIso8601String(),
      },
      'summary': {
        'totalEstimatedHours': periodTasks.fold<int>(0, (sum, t) => sum + (t.estimatedDuration ?? 0)),
        'totalActualHours': periodTasks.fold<int>(0, (sum, t) => sum + (t.actualDuration ?? 0)),
        'accuracyRate': _calculateEstimationAccuracy(periodTasks),
      },
      'taskBreakdown': periodTasks.map((task) => {
        'id': task.id,
        'title': task.title,
        'estimatedHours': task.estimatedDuration,
        'actualHours': task.actualDuration,
        'variance': (task.actualDuration ?? 0) - (task.estimatedDuration ?? 0),
        'project': task.projectId,
      }).toList(),
      'insights': _generateTimeTrackingInsights(periodTasks),
    };
  }
  
  // PDF creation methods
  
  Future<ExportResult> _createExecutiveSummaryPDF(
    Map<String, dynamic> data,
    String filePath,
  ) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Executive Summary Report',
                  style: pw.TextStyle(font: fontBold, fontSize: 24, color: PdfColors.blue800),
                ),
                pw.Text(
                  'Generated: ${DateTime.now().toString().split('.')[0]}',
                  style: pw.TextStyle(font: font, fontSize: 12),
                ),
              ],
            ),
          ),
          
          pw.SizedBox(height: 20),
          
          // Overview section
          _buildOverviewSection(data['overview'], font, fontBold),
          
          pw.SizedBox(height: 20),
          
          // Trends section
          _buildTrendsSection(data['trends'], font, fontBold),
          
          pw.SizedBox(height: 20),
          
          // Top projects section
          _buildTopProjectsSection(data['topProjects'], font, fontBold),
          
          pw.SizedBox(height: 20),
          
          // Alerts and recommendations
          _buildAlertsSection(data['alerts'], font, fontBold),
          _buildRecommendationsSection(data['recommendations'], font, fontBold),
        ],
      ),
    );
    
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    
    return ExportResult(
      success: true,
      message: 'Executive summary PDF created successfully',
      filePath: filePath,
      fileSize: await file.length(),
      exportedAt: DateTime.now(),
    );
  }
  
  // Helper PDF building methods
  
  pw.Widget _buildOverviewSection(
    Map<String, dynamic> overview,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Overview', style: pw.TextStyle(font: fontBold, fontSize: 18)),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: PdfColors.blue50,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Total Tasks: ${overview['totalTasks']}', style: pw.TextStyle(font: font)),
                    pw.Text('Completed: ${overview['completedTasks']}', style: pw.TextStyle(font: font)),
                    pw.Text('In Progress: ${overview['inProgressTasks']}', style: pw.TextStyle(font: font)),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Active Projects: ${overview['activeProjects']}', style: pw.TextStyle(font: font)),
                    pw.Text('Completion Rate: ${overview['completionRate']}%', style: pw.TextStyle(font: font)),
                    pw.Text('Overdue Tasks: ${overview['overdueTasks']}', style: pw.TextStyle(font: font)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  pw.Widget _buildTrendsSection(
    Map<String, dynamic> trends,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Trends (Last 30 Days)', style: pw.TextStyle(font: fontBold, fontSize: 18)),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: PdfColors.green50,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            children: [
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text('New Tasks: ${trends['newTasksThisMonth']}', style: pw.TextStyle(font: font)),
                  ),
                  pw.Expanded(
                    child: pw.Text('Completions: ${trends['completionsThisMonth']}', style: pw.TextStyle(font: font)),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text('Avg Duration: ${trends['avgTaskDurationDays']} days', style: pw.TextStyle(font: font)),
                  ),
                  pw.Expanded(
                    child: pw.Text('On-time Rate: ${trends['onTimeCompletionRate']}%', style: pw.TextStyle(font: font)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  pw.Widget _buildTopProjectsSection(
    List<dynamic> topProjects,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Top Performing Projects', style: pw.TextStyle(font: fontBold, fontSize: 18)),
        pw.SizedBox(height: 10),
        ...topProjects.take(3).map((projectData) => pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 8),
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Row(
            children: [
              pw.Expanded(
                flex: 3,
                child: pw.Text(
                  (projectData['project'] as Project).name,
                  style: pw.TextStyle(font: fontBold),
                ),
              ),
              pw.Expanded(
                child: pw.Text(
                  'Tasks: ${projectData['taskCount']}',
                  style: pw.TextStyle(font: font, fontSize: 10),
                ),
              ),
              pw.Expanded(
                child: pw.Text(
                  'Rate: ${(projectData['completionRate'] as double).round()}%',
                  style: pw.TextStyle(font: font, fontSize: 10),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
  
  pw.Widget _buildAlertsSection(
    List<dynamic> alerts,
    pw.Font font,
    pw.Font fontBold,
  ) {
    if (alerts.isEmpty) return pw.SizedBox();
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Alerts', style: pw.TextStyle(font: fontBold, fontSize: 18, color: PdfColors.red)),
        pw.SizedBox(height: 10),
        ...alerts.take(5).map((alert) => pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 4),
          child: pw.Row(
            children: [
              pw.Container(
                width: 8,
                height: 8,
                decoration: const pw.BoxDecoration(
                  color: PdfColors.red,
                  shape: pw.BoxShape.circle,
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: pw.Text(alert.toString(), style: pw.TextStyle(font: font, fontSize: 10)),
              ),
            ],
          ),
        )),
      ],
    );
  }
  
  pw.Widget _buildRecommendationsSection(
    List<dynamic> recommendations,
    pw.Font font,
    pw.Font fontBold,
  ) {
    if (recommendations.isEmpty) return pw.SizedBox();
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Recommendations', style: pw.TextStyle(font: fontBold, fontSize: 18, color: PdfColors.green)),
        pw.SizedBox(height: 10),
        ...recommendations.take(5).map((rec) => pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 4),
          child: pw.Row(
            children: [
              pw.Container(
                width: 8,
                height: 8,
                decoration: const pw.BoxDecoration(
                  color: PdfColors.green,
                  shape: pw.BoxShape.circle,
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: pw.Text(rec.toString(), style: pw.TextStyle(font: font, fontSize: 10)),
              ),
            ],
          ),
        )),
      ],
    );
  }
  
  // JSON creation methods
  
  Future<ExportResult> _createExecutiveSummaryJSON(
    Map<String, dynamic> data,
    String filePath,
  ) async {
    final file = File(filePath);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(data),
    );
    
    return ExportResult(
      success: true,
      message: 'Executive summary JSON created successfully',
      filePath: filePath,
      fileSize: await file.length(),
      exportedAt: DateTime.now(),
    );
  }
  
  // Helper calculation methods
  
  double _calculateOnTimeCompletionRate(List<TaskModel> tasks) {
    final completedTasks = tasks.where((t) => 
      t.status == TaskStatus.completed && 
      t.dueDate != null && 
      t.completedAt != null
    ).toList();
    
    if (completedTasks.isEmpty) return 0.0;
    
    final onTimeTasks = completedTasks.where((t) => 
      t.completedAt!.isBefore(t.dueDate!) || 
      t.completedAt!.isAtSameMomentAs(t.dueDate!)
    ).length;
    
    return onTimeTasks / completedTasks.length * 100;
  }
  
  double _calculateAverageTaskDuration(List<TaskModel> tasks) {
    final completedTasks = tasks.where((t) => 
      t.status == TaskStatus.completed && t.completedAt != null
    ).toList();
    
    if (completedTasks.isEmpty) return 0.0;
    
    final totalDays = completedTasks.fold<int>(0, (sum, task) => 
      sum + task.completedAt!.difference(task.createdAt).inDays
    );
    
    return totalDays / completedTasks.length;
  }
  
  List<String> _generateAlerts(List<TaskModel> tasks, List<Project> projects) {
    final alerts = <String>[];
    final now = DateTime.now();
    
    // Overdue tasks alert
    final overdueTasks = tasks.where((t) => 
      t.dueDate != null && 
      t.dueDate!.isBefore(now) && 
      t.status != TaskStatus.completed
    ).length;
    
    if (overdueTasks > 0) {
      alerts.add('$overdueTasks tasks are overdue and require immediate attention');
    }
    
    // High-priority tasks alert
    final urgentTasks = tasks.where((t) => 
      t.priority == TaskPriority.urgent && 
      t.status != TaskStatus.completed
    ).length;
    
    if (urgentTasks > 0) {
      alerts.add('$urgentTasks urgent tasks are still pending');
    }
    
    // Stalled projects alert
    final stalledProjects = projects.where((p) {
      final projectTasks = tasks.where((t) => t.projectId == p.id).toList();
      final recentActivity = projectTasks.any((t) => 
        t.updatedAt != null && 
        t.updatedAt!.isAfter(now.subtract(const Duration(days: 7)))
      );
      return !p.isArchived && !recentActivity && projectTasks.isNotEmpty;
    }).length;
    
    if (stalledProjects > 0) {
      alerts.add('$stalledProjects projects show no activity in the last 7 days');
    }
    
    return alerts;
  }
  
  List<String> _generateRecommendations(List<TaskModel> tasks, List<Project> projects) {
    final recommendations = <String>[];
    
    // Task completion recommendations
    final completionRate = tasks.isNotEmpty 
        ? tasks.where((t) => t.status == TaskStatus.completed).length / tasks.length * 100
        : 0.0;
    
    if (completionRate < 70) {
      recommendations.add('Focus on completing existing tasks to improve overall project velocity');
    }
    
    // Project organization recommendations
    final unassignedTasks = tasks.where((t) => t.projectId == null).length;
    if (unassignedTasks > 0) {
      recommendations.add('Organize $unassignedTasks unassigned tasks into appropriate projects');
    }
    
    // Time management recommendations
    final onTimeRate = _calculateOnTimeCompletionRate(tasks);
    if (onTimeRate < 80) {
      recommendations.add('Improve time estimation and deadline management for better on-time delivery');
    }
    
    return recommendations;
  }
  
  // Placeholder methods for additional functionality
  Map<String, dynamic> _calculateProjectMetrics(Project project, List<TaskModel> tasks) => {};
  Map<String, dynamic> _generateProjectTimeline(Project project, List<TaskModel> tasks) => {};
  List<Map<String, dynamic>> _identifyProjectRisks(Project project, List<TaskModel> tasks) => [];
  Map<String, dynamic> _generateProjectSummary(List<Project> projects, List<TaskModel> tasks) => {};
  double _calculateAverageCompletionTime(List<TaskModel> tasks) => 0.0;
  double _calculateThroughput(List<TaskModel> tasks) => 0.0;
  double _calculateVelocity(List<TaskModel> tasks) => 0.0;
  Map<String, dynamic> _generateProductivityTrends(List<TaskModel> tasks) => {};
  List<Map<String, dynamic>> _identifyBottlenecks(List<TaskModel> tasks, List<Project> projects) => [];
  List<Map<String, dynamic>> _identifyTaskRisks(List<TaskModel> tasks) => [];
  List<Map<String, dynamic>> _identifyProjectRisks(List<Project> projects, List<TaskModel> tasks) => [];
  List<Map<String, dynamic>> _identifyResourceRisks(List<TaskModel> tasks, List<Project> projects) => [];
  Map<String, dynamic> _generateRiskMatrix(List<TaskModel> tasks, List<Project> projects) => {};
  List<Map<String, dynamic>> _generateMitigationStrategies(List<TaskModel> tasks, List<Project> projects) => [];
  Future<Map<String, dynamic>> _generateAnalyticsSection(List<TaskModel> tasks, List<Project> projects) async => {};
  Map<String, dynamic> _generateTimelineSection(List<TaskModel> tasks, List<Project> projects) => {};
  double _calculateEstimationAccuracy(List<TaskModel> tasks) => 0.0;
  List<Map<String, dynamic>> _generateTimeTrackingInsights(List<TaskModel> tasks) => [];
  
  // Additional PDF creation method placeholders
  Future<ExportResult> _createProjectPerformancePDF(Map<String, dynamic> data, String filePath) async => 
    const ExportResult(success: false, message: 'Not implemented', filePath: null, fileSize: 0);
  Future<ExportResult> _createTeamProductivityPDF(Map<String, dynamic> data, String filePath) async => 
    const ExportResult(success: false, message: 'Not implemented', filePath: null, fileSize: 0);
  Future<ExportResult> _createRiskAnalysisPDF(Map<String, dynamic> data, String filePath) async => 
    const ExportResult(success: false, message: 'Not implemented', filePath: null, fileSize: 0);
  Future<ExportResult> _createCustomReportPDF(ReportTemplate template, Map<String, dynamic> data, String filePath) async => 
    const ExportResult(success: false, message: 'Not implemented', filePath: null, fileSize: 0);
  Future<ExportResult> _createTimeTrackingPDF(Map<String, dynamic> data, String filePath) async => 
    const ExportResult(success: false, message: 'Not implemented', filePath: null, fileSize: 0);
  
  // Additional JSON creation method placeholders
  Future<ExportResult> _createProjectPerformanceJSON(Map<String, dynamic> data, String filePath) async => 
    await _createExecutiveSummaryJSON(data, filePath);
  Future<ExportResult> _createTeamProductivityJSON(Map<String, dynamic> data, String filePath) async => 
    await _createExecutiveSummaryJSON(data, filePath);
  Future<ExportResult> _createRiskAnalysisJSON(Map<String, dynamic> data, String filePath) async => 
    await _createExecutiveSummaryJSON(data, filePath);
  Future<ExportResult> _createCustomReportJSON(ReportTemplate template, Map<String, dynamic> data, String filePath) async => 
    await _createExecutiveSummaryJSON(data, filePath);
  Future<ExportResult> _createTimeTrackingJSON(Map<String, dynamic> data, String filePath) async => 
    await _createExecutiveSummaryJSON(data, filePath);
}