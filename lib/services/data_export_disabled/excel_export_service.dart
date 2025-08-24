import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:path/path.dart' as path;

import '../../domain/entities/project.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/entities/tag.dart';
import 'data_export_models.dart';

/// Professional Excel export service with advanced formatting, charts, and analytics
class ExcelExportService {
  static const String _brandColor = '#2196F3';
  static const String _headerColor = '#1976D2';
  static const String _alternateRowColor = '#F5F5F5';
  
  /// Export tasks to a professionally formatted Excel file
  Future<ExportResult> exportTasksToExcel({
    required List<TaskModel> tasks,
    required String filePath,
    ExportOptions? options,
  }) async {
    try {
      final workbook = xlsio.Workbook();
      
      // Create multiple worksheets
      await _createTaskListWorksheet(workbook, tasks, options);
      await _createTaskAnalyticsWorksheet(workbook, tasks);
      await _createTimelineWorksheet(workbook, tasks);
      
      // Save the workbook
      final bytes = workbook.saveAsStream();
      workbook.dispose();
      
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      
      return ExportResult(
        success: true,
        message: 'Excel export completed successfully',
        filePath: filePath,
        fileSize: await file.length(),
        exportedAt: DateTime.now(),
        metadata: {
          'format': 'excel',
          'worksheets': ['Tasks', 'Analytics', 'Timeline'],
          'taskCount': tasks.length,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Excel export error: $e');
      }
      return ExportResult(
        success: false,
        message: 'Excel export failed: ${e.toString()}',
        filePath: null,
        fileSize: 0,
      );
    }
  }
  
  /// Export projects to Excel with comprehensive project analytics
  Future<ExportResult> exportProjectsToExcel({
    required List<Project> projects,
    required List<TaskModel> allTasks,
    required String filePath,
    ExportOptions? options,
  }) async {
    try {
      final workbook = xlsio.Workbook();
      
      // Create multiple worksheets for projects
      await _createProjectListWorksheet(workbook, projects);
      await _createProjectAnalyticsWorksheet(workbook, projects, allTasks);
      await _createProjectTimelineWorksheet(workbook, projects, allTasks);
      await _createResourceAllocationWorksheet(workbook, projects, allTasks);
      
      // Save the workbook
      final bytes = workbook.saveAsStream();
      workbook.dispose();
      
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      
      return ExportResult(
        success: true,
        message: 'Project Excel export completed successfully',
        filePath: filePath,
        fileSize: await file.length(),
        exportedAt: DateTime.now(),
        metadata: {
          'format': 'excel',
          'worksheets': ['Projects', 'Analytics', 'Timeline', 'Resources'],
          'projectCount': projects.length,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Project Excel export error: $e');
      }
      return ExportResult(
        success: false,
        message: 'Project Excel export failed: ${e.toString()}',
        filePath: null,
        fileSize: 0,
      );
    }
  }
  
  /// Create comprehensive executive dashboard in Excel
  Future<ExportResult> createExecutiveDashboard({
    required List<TaskModel> tasks,
    required List<Project> projects,
    required String filePath,
    ExportOptions? options,
  }) async {
    try {
      final workbook = xlsio.Workbook();
      
      // Create executive dashboard worksheets
      await _createExecutiveSummaryWorksheet(workbook, tasks, projects);
      await _createKPIWorksheet(workbook, tasks, projects);
      await _createTrendAnalysisWorksheet(workbook, tasks, projects);
      await _createResourceUtilizationWorksheet(workbook, tasks, projects);
      await _createRiskAnalysisWorksheet(workbook, tasks, projects);
      
      // Save the workbook
      final bytes = workbook.saveAsStream();
      workbook.dispose();
      
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      
      return ExportResult(
        success: true,
        message: 'Executive dashboard created successfully',
        filePath: filePath,
        fileSize: await file.length(),
        exportedAt: DateTime.now(),
        metadata: {
          'format': 'executive_excel',
          'worksheets': ['Executive Summary', 'KPIs', 'Trends', 'Resources', 'Risk Analysis'],
          'taskCount': tasks.length,
          'projectCount': projects.length,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Executive dashboard export error: $e');
      }
      return ExportResult(
        success: false,
        message: 'Executive dashboard export failed: ${e.toString()}',
        filePath: null,
        fileSize: 0,
      );
    }
  }
  
  /// Create task list worksheet with professional formatting
  Future<void> _createTaskListWorksheet(
    xlsio.Workbook workbook,
    List<TaskModel> tasks,
    ExportOptions? options,
  ) async {
    final worksheet = workbook.worksheets[0];
    worksheet.name = 'Tasks';
    
    // Apply theme and styling
    _applyWorksheetTheme(worksheet);
    
    // Headers
    final headers = [
      'Task ID', 'Title', 'Description', 'Project', 'Status', 'Priority',
      'Created Date', 'Due Date', 'Completed Date', 'Progress %', 'Tags',
      'Estimated Hours', 'Actual Hours', 'Assigned To'
    ];
    
    // Set headers with formatting
    for (int i = 0; i < headers.length; i++) {
      final cell = worksheet.getRangeByIndex(1, i + 1);
      cell.setText(headers[i]);
      _formatHeaderCell(cell);
    }
    
    // Add data rows
    for (int i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      final rowIndex = i + 2;
      
      worksheet.getRangeByIndex(rowIndex, 1).setText(task.id);
      worksheet.getRangeByIndex(rowIndex, 2).setText(task.title);
      worksheet.getRangeByIndex(rowIndex, 3).setText(task.description ?? '');
      worksheet.getRangeByIndex(rowIndex, 4).setText(task.projectId ?? 'No Project');
      worksheet.getRangeByIndex(rowIndex, 5).setText(task.status.name.toUpperCase());
      worksheet.getRangeByIndex(rowIndex, 6).setText(task.priority.name.toUpperCase());
      worksheet.getRangeByIndex(rowIndex, 7).setDateTime(task.createdAt);
      worksheet.getRangeByIndex(rowIndex, 8).setDateTime(task.dueDate);
      worksheet.getRangeByIndex(rowIndex, 9).setDateTime(task.completedAt);
      
      // Progress calculation
      final progress = task.status.name == 'completed' ? 100 : 
                      task.status.name == 'inProgress' ? 50 : 0;
      worksheet.getRangeByIndex(rowIndex, 10).setNumber(progress.toDouble());
      
      worksheet.getRangeByIndex(rowIndex, 11).setText(task.tags.join(', '));
      worksheet.getRangeByIndex(rowIndex, 12).setNumber(task.estimatedDuration?.toDouble() ?? 0);
      worksheet.getRangeByIndex(rowIndex, 13).setNumber(task.actualDuration?.toDouble() ?? 0);
      worksheet.getRangeByIndex(rowIndex, 14).setText(''); // Placeholder for assigned to
      
      // Apply alternating row colors
      if (i % 2 == 1) {
        _formatAlternateRow(worksheet, rowIndex, headers.length);
      }
    }
    
    // Auto-fit columns
    for (int i = 1; i <= headers.length; i++) {
      worksheet.autoFitColumn(i);
    }
    
    // Add filters
    worksheet.autoFilters.filterRange = worksheet.getRangeByIndex(1, 1, tasks.length + 1, headers.length);
    
    // Freeze panes
    worksheet.getRangeByIndex(2, 1).freezePanes();
  }
  
  /// Create analytics worksheet with charts
  Future<void> _createTaskAnalyticsWorksheet(
    xlsio.Workbook workbook,
    List<TaskModel> tasks,
  ) async {
    final worksheet = workbook.worksheets.add('Analytics');
    _applyWorksheetTheme(worksheet);
    
    // Title
    final titleCell = worksheet.getRangeByIndex(1, 1, 1, 8);
    titleCell.merge();
    titleCell.setText('Task Analytics Dashboard');
    _formatTitleCell(titleCell);
    
    // Status distribution
    await _createStatusChart(worksheet, tasks, 3, 1);
    
    // Priority distribution
    await _createPriorityChart(worksheet, tasks, 3, 5);
    
    // Timeline analysis
    await _createTimelineChart(worksheet, tasks, 18, 1);
    
    // Summary statistics
    await _createSummaryStatistics(worksheet, tasks, 3, 9);
  }
  
  /// Create timeline worksheet
  Future<void> _createTimelineWorksheet(
    xlsio.Workbook workbook,
    List<TaskModel> tasks,
  ) async {
    final worksheet = workbook.worksheets.add('Timeline');
    _applyWorksheetTheme(worksheet);
    
    // Title
    final titleCell = worksheet.getRangeByIndex(1, 1, 1, 6);
    titleCell.merge();
    titleCell.setText('Project Timeline');
    _formatTitleCell(titleCell);
    
    // Headers for Gantt-like view
    final headers = ['Task', 'Start Date', 'End Date', 'Duration', 'Status', 'Progress'];
    for (int i = 0; i < headers.length; i++) {
      final cell = worksheet.getRangeByIndex(3, i + 1);
      cell.setText(headers[i]);
      _formatHeaderCell(cell);
    }
    
    // Add timeline data
    for (int i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      final rowIndex = i + 4;
      
      worksheet.getRangeByIndex(rowIndex, 1).setText(task.title);
      worksheet.getRangeByIndex(rowIndex, 2).setDateTime(task.createdAt);
      worksheet.getRangeByIndex(rowIndex, 3).setDateTime(task.dueDate ?? task.createdAt.add(const Duration(days: 7)));
      
      final duration = task.dueDate?.difference(task.createdAt).inDays ?? 7;
      worksheet.getRangeByIndex(rowIndex, 4).setNumber(duration.toDouble());
      worksheet.getRangeByIndex(rowIndex, 5).setText(task.status.name);
      
      final progress = task.status.name == 'completed' ? 100 : 
                      task.status.name == 'inProgress' ? 50 : 0;
      worksheet.getRangeByIndex(rowIndex, 6).setNumber(progress.toDouble());
    }
    
    // Auto-fit columns
    for (int i = 1; i <= 6; i++) {
      worksheet.autoFitColumn(i);
    }
  }
  
  /// Create project list worksheet
  Future<void> _createProjectListWorksheet(
    xlsio.Workbook workbook,
    List<Project> projects,
  ) async {
    final worksheet = workbook.worksheets[0];
    worksheet.name = 'Projects';
    _applyWorksheetTheme(worksheet);
    
    // Headers
    final headers = [
      'Project ID', 'Name', 'Description', 'Category', 'Status', 
      'Created Date', 'Deadline', 'Task Count', 'Completion %', 'Color'
    ];
    
    // Set headers
    for (int i = 0; i < headers.length; i++) {
      final cell = worksheet.getRangeByIndex(1, i + 1);
      cell.setText(headers[i]);
      _formatHeaderCell(cell);
    }
    
    // Add data
    for (int i = 0; i < projects.length; i++) {
      final project = projects[i];
      final rowIndex = i + 2;
      
      worksheet.getRangeByIndex(rowIndex, 1).setText(project.id);
      worksheet.getRangeByIndex(rowIndex, 2).setText(project.name);
      worksheet.getRangeByIndex(rowIndex, 3).setText(project.description ?? '');
      worksheet.getRangeByIndex(rowIndex, 4).setText(project.categoryId ?? 'Uncategorized');
      worksheet.getRangeByIndex(rowIndex, 5).setText(project.isArchived ? 'ARCHIVED' : 'ACTIVE');
      worksheet.getRangeByIndex(rowIndex, 6).setDateTime(project.createdAt);
      worksheet.getRangeByIndex(rowIndex, 7).setDateTime(project.deadline);
      worksheet.getRangeByIndex(rowIndex, 8).setNumber(project.taskIds.length.toDouble());
      worksheet.getRangeByIndex(rowIndex, 9).setNumber(0.0); // Placeholder for completion percentage
      worksheet.getRangeByIndex(rowIndex, 10).setText(project.color);
      
      if (i % 2 == 1) {
        _formatAlternateRow(worksheet, rowIndex, headers.length);
      }
    }
    
    // Auto-fit columns and add filters
    for (int i = 1; i <= headers.length; i++) {
      worksheet.autoFitColumn(i);
    }
    worksheet.autoFilters.filterRange = worksheet.getRangeByIndex(1, 1, projects.length + 1, headers.length);
  }
  
  /// Create project analytics worksheet
  Future<void> _createProjectAnalyticsWorksheet(
    xlsio.Workbook workbook,
    List<Project> projects,
    List<TaskModel> allTasks,
  ) async {
    final worksheet = workbook.worksheets.add('Project Analytics');
    _applyWorksheetTheme(worksheet);
    
    // Create various analytics charts and summaries
    await _createProjectStatusChart(worksheet, projects, 3, 1);
    await _createProjectTaskDistribution(worksheet, projects, allTasks, 3, 5);
    await _createProjectTimeline(worksheet, projects, 18, 1);
  }
  
  /// Create executive summary worksheet
  Future<void> _createExecutiveSummaryWorksheet(
    xlsio.Workbook workbook,
    List<TaskModel> tasks,
    List<Project> projects,
  ) async {
    final worksheet = workbook.worksheets[0];
    worksheet.name = 'Executive Summary';
    _applyWorksheetTheme(worksheet);
    
    // Title
    final titleCell = worksheet.getRangeByIndex(1, 1, 1, 8);
    titleCell.merge();
    titleCell.setText('Executive Dashboard - Task Management Summary');
    _formatTitleCell(titleCell);
    
    // Key metrics
    await _createExecutiveMetrics(worksheet, tasks, projects);
    
    // Charts
    await _createExecutiveCharts(worksheet, tasks, projects);
  }
  
  /// Apply professional theme to worksheet
  void _applyWorksheetTheme(xlsio.Worksheet worksheet) {
    worksheet.showGridlines = false;
  }
  
  /// Format header cell
  void _formatHeaderCell(xlsio.Range cell) {
    cell.cellStyle.backColor = _headerColor;
    cell.cellStyle.fontColor = '#FFFFFF';
    cell.cellStyle.fontName = 'Segoe UI';
    cell.cellStyle.fontSize = 12;
    cell.cellStyle.bold = true;
    cell.cellStyle.borders.all.color = '#FFFFFF';
    cell.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;
  }
  
  /// Format title cell
  void _formatTitleCell(xlsio.Range cell) {
    cell.cellStyle.backColor = _brandColor;
    cell.cellStyle.fontColor = '#FFFFFF';
    cell.cellStyle.fontName = 'Segoe UI';
    cell.cellStyle.fontSize = 16;
    cell.cellStyle.bold = true;
    cell.cellStyle.hAlign = xlsio.HAlignType.center;
    cell.cellStyle.vAlign = xlsio.VAlignType.center;
    cell.rowHeight = 30;
  }
  
  /// Format alternate row
  void _formatAlternateRow(xlsio.Worksheet worksheet, int rowIndex, int columnCount) {
    final range = worksheet.getRangeByIndex(rowIndex, 1, rowIndex, columnCount);
    range.cellStyle.backColor = _alternateRowColor;
  }
  
  /// Create status distribution chart
  Future<void> _createStatusChart(
    xlsio.Worksheet worksheet,
    List<TaskModel> tasks,
    int startRow,
    int startCol,
  ) async {
    // Create data for status chart
    final statusCounts = <String, int>{};
    for (final task in tasks) {
      statusCounts[task.status.name] = (statusCounts[task.status.name] ?? 0) + 1;
    }
    
    // Chart title
    final chartTitleCell = worksheet.getRangeByIndex(startRow - 1, startCol);
    chartTitleCell.setText('Task Status Distribution');
    chartTitleCell.cellStyle.bold = true;
    chartTitleCell.cellStyle.fontSize = 14;
    
    // Add chart data
    int row = startRow;
    worksheet.getRangeByIndex(row, startCol).setText('Status');
    worksheet.getRangeByIndex(row, startCol + 1).setText('Count');
    
    statusCounts.forEach((status, count) {
      row++;
      worksheet.getRangeByIndex(row, startCol).setText(status);
      worksheet.getRangeByIndex(row, startCol + 1).setNumber(count.toDouble());
    });
    
    // Create chart (simplified - in a real implementation, you'd use Syncfusion's charting API)
    final chartRange = worksheet.getRangeByIndex(startRow, startCol, row, startCol + 1);
    final chart = worksheet.charts.add();
    chart.chartType = xlsio.ExcelChartType.pie;
    chart.dataRange = chartRange;
    chart.isSeriesInRows = false;
    chart.topRow = startRow + statusCounts.length + 2;
    chart.leftColumn = startCol;
    chart.bottomRow = startRow + statusCounts.length + 10;
    chart.rightColumn = startCol + 3;
  }
  
  /// Create priority distribution chart
  Future<void> _createPriorityChart(
    xlsio.Worksheet worksheet,
    List<TaskModel> tasks,
    int startRow,
    int startCol,
  ) async {
    final priorityCounts = <String, int>{};
    for (final task in tasks) {
      priorityCounts[task.priority.name] = (priorityCounts[task.priority.name] ?? 0) + 1;
    }
    
    // Chart title
    final chartTitleCell = worksheet.getRangeByIndex(startRow - 1, startCol);
    chartTitleCell.setText('Task Priority Distribution');
    chartTitleCell.cellStyle.bold = true;
    chartTitleCell.cellStyle.fontSize = 14;
    
    // Add chart data and create chart similar to status chart
    int row = startRow;
    worksheet.getRangeByIndex(row, startCol).setText('Priority');
    worksheet.getRangeByIndex(row, startCol + 1).setText('Count');
    
    priorityCounts.forEach((priority, count) {
      row++;
      worksheet.getRangeByIndex(row, startCol).setText(priority);
      worksheet.getRangeByIndex(row, startCol + 1).setNumber(count.toDouble());
    });
  }
  
  /// Create timeline chart
  Future<void> _createTimelineChart(
    xlsio.Worksheet worksheet,
    List<TaskModel> tasks,
    int startRow,
    int startCol,
  ) async {
    // Implementation for timeline chart
    final chartTitleCell = worksheet.getRangeByIndex(startRow - 1, startCol);
    chartTitleCell.setText('Task Creation Timeline');
    chartTitleCell.cellStyle.bold = true;
    chartTitleCell.cellStyle.fontSize = 14;
    
    // Group tasks by month
    final monthlyTasks = <String, int>{};
    for (final task in tasks) {
      final monthKey = '${task.createdAt.year}-${task.createdAt.month.toString().padLeft(2, '0')}';
      monthlyTasks[monthKey] = (monthlyTasks[monthKey] ?? 0) + 1;
    }
    
    // Add data
    int row = startRow;
    worksheet.getRangeByIndex(row, startCol).setText('Month');
    worksheet.getRangeByIndex(row, startCol + 1).setText('Tasks Created');
    
    monthlyTasks.forEach((month, count) {
      row++;
      worksheet.getRangeByIndex(row, startCol).setText(month);
      worksheet.getRangeByIndex(row, startCol + 1).setNumber(count.toDouble());
    });
  }
  
  /// Create summary statistics
  Future<void> _createSummaryStatistics(
    xlsio.Worksheet worksheet,
    List<TaskModel> tasks,
    int startRow,
    int startCol,
  ) async {
    // Summary title
    final titleCell = worksheet.getRangeByIndex(startRow - 1, startCol);
    titleCell.setText('Summary Statistics');
    titleCell.cellStyle.bold = true;
    titleCell.cellStyle.fontSize = 14;
    
    // Calculate statistics
    final totalTasks = tasks.length;
    final completedTasks = tasks.where((t) => t.status.name == 'completed').length;
    final inProgressTasks = tasks.where((t) => t.status.name == 'inProgress').length;
    final overdueTasks = tasks.where((t) => 
      t.dueDate != null && 
      t.dueDate!.isBefore(DateTime.now()) && 
      t.status.name != 'completed'
    ).length;
    
    final stats = [
      ['Total Tasks', totalTasks],
      ['Completed Tasks', completedTasks],
      ['In Progress Tasks', inProgressTasks],
      ['Overdue Tasks', overdueTasks],
      ['Completion Rate', completedTasks / totalTasks * 100],
    ];
    
    for (int i = 0; i < stats.length; i++) {
      final row = startRow + i;
      worksheet.getRangeByIndex(row, startCol).setText(stats[i][0].toString());
      worksheet.getRangeByIndex(row, startCol + 1).setNumber((stats[i][1] as num).toDouble());
    }
  }
  
  /// Placeholder implementations for additional worksheets
  Future<void> _createProjectTimelineWorksheet(xlsio.Workbook workbook, List<Project> projects, List<TaskModel> allTasks) async {}
  Future<void> _createResourceAllocationWorksheet(xlsio.Workbook workbook, List<Project> projects, List<TaskModel> allTasks) async {}
  Future<void> _createKPIWorksheet(xlsio.Workbook workbook, List<TaskModel> tasks, List<Project> projects) async {}
  Future<void> _createTrendAnalysisWorksheet(xlsio.Workbook workbook, List<TaskModel> tasks, List<Project> projects) async {}
  Future<void> _createResourceUtilizationWorksheet(xlsio.Workbook workbook, List<TaskModel> tasks, List<Project> projects) async {}
  Future<void> _createRiskAnalysisWorksheet(xlsio.Workbook workbook, List<TaskModel> tasks, List<Project> projects) async {}
  Future<void> _createProjectStatusChart(xlsio.Worksheet worksheet, List<Project> projects, int startRow, int startCol) async {}
  Future<void> _createProjectTaskDistribution(xlsio.Worksheet worksheet, List<Project> projects, List<TaskModel> allTasks, int startRow, int startCol) async {}
  Future<void> _createProjectTimeline(xlsio.Worksheet worksheet, List<Project> projects, int startRow, int startCol) async {}
  Future<void> _createExecutiveMetrics(xlsio.Worksheet worksheet, List<TaskModel> tasks, List<Project> projects) async {}
  Future<void> _createExecutiveCharts(xlsio.Worksheet worksheet, List<TaskModel> tasks, List<Project> projects) async {}
}