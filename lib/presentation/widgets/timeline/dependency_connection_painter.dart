import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../domain/entities/task_model.dart';
import '../../../domain/entities/timeline_dependency.dart';
import '../../../domain/entities/timeline_settings.dart';

/// Custom painter for drawing dependency connections between tasks
/// 
/// Features:
/// - Bezier curve connections between dependent tasks
/// - Color coding based on dependency type and criticality
/// - Arrow indicators showing dependency direction
/// - Critical path highlighting
/// - Lag time visualization
/// - Interactive hover detection
class DependencyConnectionPainter extends CustomPainter {
  /// List of dependencies to visualize
  final List<TimelineDependency> dependencies;
  
  /// List of all tasks for position calculation
  final List<TaskModel> tasks;
  
  /// Timeline display settings
  final TimelineSettings settings;
  
  /// Timeline start date for position calculation
  final DateTime startDate;
  
  /// Current theme for colors
  final ThemeData theme;
  
  /// Height of each task row
  final double taskRowHeight;
  
  /// Whether to highlight critical path
  final bool highlightCriticalPath;
  
  /// Currently hovered dependency (for highlighting)
  final TimelineDependency? hoveredDependency;

  DependencyConnectionPainter({
    required this.dependencies,
    required this.tasks,
    required this.settings,
    required this.startDate,
    required this.theme,
    required this.taskRowHeight,
    this.highlightCriticalPath = false,
    this.hoveredDependency,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dependencies.isEmpty || tasks.isEmpty) return;
    
    // Create task position map for efficient lookup
    final taskPositions = _createTaskPositionMap();
    
    // Draw dependency connections
    for (final dependency in dependencies) {
      _drawDependencyConnection(
        canvas,
        size,
        dependency,
        taskPositions,
      );
    }
  }

  Map<String, TaskPosition> _createTaskPositionMap() {
    final positions = <String, TaskPosition>{};
    
    for (int i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      final taskStart = _getTaskStartDate(task);
      final taskEnd = _getTaskEndDate(task);
      
      if (taskStart != null && taskEnd != null) {
        positions[task.id] = TaskPosition(
          task: task,
          index: i,
          startX: _dateToPixel(taskStart),
          endX: _dateToPixel(taskEnd),
          centerY: (i * taskRowHeight) + (taskRowHeight / 2),
        );
      }
    }
    
    return positions;
  }

  void _drawDependencyConnection(
    Canvas canvas,
    Size size,
    TimelineDependency dependency,
    Map<String, TaskPosition> taskPositions,
  ) {
    final fromTask = taskPositions[dependency.prerequisiteTaskId];
    final toTask = taskPositions[dependency.dependentTaskId];
    
    if (fromTask == null || toTask == null) return;
    
    final connectionPoints = _calculateConnectionPoints(
      dependency,
      fromTask,
      toTask,
    );
    
    if (connectionPoints == null) return;
    
    final paint = _createConnectionPaint(dependency);
    final path = _createConnectionPath(connectionPoints);
    
    // Draw connection line
    canvas.drawPath(path, paint);
    
    // Draw arrow at the end
    _drawArrowHead(
      canvas,
      connectionPoints.endPoint,
      connectionPoints.endDirection,
      paint,
    );
    
    // Draw lag time indicator if present
    if (dependency.lagTimeHours != 0) {
      _drawLagTimeIndicator(
        canvas,
        connectionPoints,
        dependency,
        paint,
      );
    }
    
    // Draw dependency type label if hovered
    if (hoveredDependency == dependency) {
      _drawDependencyLabel(
        canvas,
        connectionPoints,
        dependency,
      );
    }
  }

  ConnectionPoints? _calculateConnectionPoints(
    TimelineDependency dependency,
    TaskPosition fromTask,
    TaskPosition toTask,
  ) {
    Offset startPoint;
    Offset endPoint;
    
    // Calculate connection points based on dependency type
    switch (dependency.type) {
      case DependencyType.finishToStart:
        startPoint = Offset(fromTask.endX, fromTask.centerY);
        endPoint = Offset(toTask.startX, toTask.centerY);
        break;
        
      case DependencyType.startToStart:
        startPoint = Offset(fromTask.startX, fromTask.centerY);
        endPoint = Offset(toTask.startX, toTask.centerY);
        break;
        
      case DependencyType.finishToFinish:
        startPoint = Offset(fromTask.endX, fromTask.centerY);
        endPoint = Offset(toTask.endX, toTask.centerY);
        break;
        
      case DependencyType.startToFinish:
        startPoint = Offset(fromTask.startX, fromTask.centerY);
        endPoint = Offset(toTask.endX, toTask.centerY);
        break;
    }
    
    // Adjust for lag time
    if (dependency.lagTimeHours != 0) {
      final lagOffset = _hoursToPixels(dependency.lagTimeHours);
      endPoint = Offset(endPoint.dx + lagOffset, endPoint.dy);
    }
    
    // Calculate control points for bezier curve
    final controlPoint1 = _calculateControlPoint(startPoint, endPoint, true);
    final controlPoint2 = _calculateControlPoint(startPoint, endPoint, false);
    
    // Calculate direction for arrow
    final direction = (endPoint - controlPoint2).direction;
    
    return ConnectionPoints(
      startPoint: startPoint,
      endPoint: endPoint,
      controlPoint1: controlPoint1,
      controlPoint2: controlPoint2,
      startDirection: (controlPoint1 - startPoint).direction,
      endDirection: direction,
    );
  }

  Offset _calculateControlPoint(Offset start, Offset end, bool isFirst) {
    final midX = (start.dx + end.dx) / 2;
    final horizontalDistance = (end.dx - start.dx).abs();
    final verticalDistance = (end.dy - start.dy).abs();
    
    // Create more natural curves
    final controlDistance = math.min(horizontalDistance * 0.5, 100.0);
    
    if (isFirst) {
      // First control point extends horizontally from start
      return Offset(start.dx + controlDistance, start.dy);
    } else {
      // Second control point extends horizontally to end
      return Offset(end.dx - controlDistance, end.dy);
    }
  }

  Paint _createConnectionPaint(TimelineDependency dependency) {
    Color connectionColor;
    double strokeWidth;
    
    // Determine color based on dependency properties
    if (hoveredDependency == dependency) {
      connectionColor = theme.colorScheme.primary;
      strokeWidth = 3.0;
    } else if (highlightCriticalPath && _isOnCriticalPath(dependency)) {
      connectionColor = theme.colorScheme.error;
      strokeWidth = 2.5;
    } else if (dependency.isCritical) {
      connectionColor = theme.colorScheme.tertiary;
      strokeWidth = 2.0;
    } else {
      connectionColor = theme.colorScheme.outline.withValues(alpha: 0.6);
      strokeWidth = 1.5;
    }
    
    return Paint()
      ..color = connectionColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
  }

  Path _createConnectionPath(ConnectionPoints points) {
    final path = Path();
    
    path.moveTo(points.startPoint.dx, points.startPoint.dy);
    
    // Create smooth bezier curve
    path.cubicTo(
      points.controlPoint1.dx, points.controlPoint1.dy,
      points.controlPoint2.dx, points.controlPoint2.dy,
      points.endPoint.dx, points.endPoint.dy,
    );
    
    return path;
  }

  void _drawArrowHead(
    Canvas canvas,
    Offset point,
    double direction,
    Paint paint,
  ) {
    const arrowSize = 8.0;
    const arrowAngle = math.pi / 6; // 30 degrees
    
    final arrowPath = Path();
    
    // Calculate arrow points
    final arrowPoint1 = Offset(
      point.dx + arrowSize * math.cos(direction + arrowAngle + math.pi),
      point.dy + arrowSize * math.sin(direction + arrowAngle + math.pi),
    );
    
    final arrowPoint2 = Offset(
      point.dx + arrowSize * math.cos(direction - arrowAngle + math.pi),
      point.dy + arrowSize * math.sin(direction - arrowAngle + math.pi),
    );
    
    // Draw filled arrow head
    arrowPath.moveTo(point.dx, point.dy);
    arrowPath.lineTo(arrowPoint1.dx, arrowPoint1.dy);
    arrowPath.lineTo(arrowPoint2.dx, arrowPoint2.dy);
    arrowPath.close();
    
    canvas.drawPath(
      arrowPath,
      Paint()
        ..color = paint.color
        ..style = PaintingStyle.fill,
    );
  }

  void _drawLagTimeIndicator(
    Canvas canvas,
    ConnectionPoints points,
    TimelineDependency dependency,
    Paint paint,
  ) {
    // Draw lag time as a dashed line extension
    final lagPixels = _hoursToPixels(dependency.lagTimeHours.abs());
    
    if (lagPixels < 10) return; // Too small to show
    
    final lagStart = Offset(
      points.endPoint.dx - lagPixels,
      points.endPoint.dy,
    );
    
    _drawDashedLine(
      canvas,
      lagStart,
      Offset(points.endPoint.dx, points.endPoint.dy),
      paint.color.withValues(alpha: 0.5),
      dashWidth: 3,
      dashSpace: 3,
    );
    
    // Draw lag time label
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${dependency.lagTimeHours}h',
        style: TextStyle(
          color: paint.color,
          fontSize: 11.0, // Fixed accessibility violation (was 10px, using 11.0 directly as this is a CustomPainter)
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    
    final labelOffset = Offset(
      lagStart.dx + (lagPixels - textPainter.width) / 2,
      lagStart.dy - textPainter.height - 4,
    );
    
    // Draw label background
    final labelRect = Rect.fromLTWH(
      labelOffset.dx - 2,
      labelOffset.dy - 1,
      textPainter.width + 4,
      textPainter.height + 2,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(labelRect, const Radius.circular(2)),
      Paint()
        ..color = theme.colorScheme.surface.withValues(alpha: 0.9)
        ..style = PaintingStyle.fill,
    );
    
    // Draw label text
    textPainter.paint(canvas, labelOffset);
  }

  void _drawDependencyLabel(
    Canvas canvas,
    ConnectionPoints points,
    TimelineDependency dependency,
  ) {
    final midPoint = Offset(
      (points.startPoint.dx + points.endPoint.dx) / 2,
      (points.startPoint.dy + points.endPoint.dy) / 2,
    );
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: dependency.type.abbreviation,
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    
    final labelOffset = Offset(
      midPoint.dx - textPainter.width / 2,
      midPoint.dy - textPainter.height / 2,
    );
    
    // Draw label background
    final labelRect = Rect.fromLTWH(
      labelOffset.dx - 4,
      labelOffset.dy - 2,
      textPainter.width + 8,
      textPainter.height + 4,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(labelRect, const Radius.circular(4)),
      Paint()
        ..color = theme.colorScheme.primaryContainer.withValues(alpha: 0.9)
        ..style = PaintingStyle.fill,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(labelRect, const Radius.circular(4)),
      Paint()
        ..color = theme.colorScheme.primary.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    
    // Draw label text
    textPainter.paint(canvas, labelOffset);
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Color color,
    {double dashWidth = 2,
    double dashSpace = 2}
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    final distance = (end - start).distance;
    final dashCount = (distance / (dashWidth + dashSpace)).floor();
    
    for (int i = 0; i < dashCount; i++) {
      final startRatio = i * (dashWidth + dashSpace) / distance;
      final endRatio = (i * (dashWidth + dashSpace) + dashWidth) / distance;
      
      final dashStart = Offset.lerp(start, end, startRatio)!;
      final dashEnd = Offset.lerp(start, end, endRatio)!;
      
      canvas.drawLine(dashStart, dashEnd, paint);
    }
  }

  // Utility methods
  double _dateToPixel(DateTime date) {
    final diff = date.difference(startDate);
    return (diff.inMilliseconds / settings.timeUnit.inMilliseconds) * 
           settings.pixelsPerTimeUnit;
  }

  double _hoursToPixels(int hours) {
    final duration = Duration(hours: hours);
    return (duration.inMilliseconds / settings.timeUnit.inMilliseconds) * 
           settings.pixelsPerTimeUnit;
  }

  DateTime? _getTaskStartDate(TaskModel task) {
    return task.createdAt;
  }

  DateTime? _getTaskEndDate(TaskModel task) {
    return task.dueDate ?? 
           task.createdAt.add(Duration(hours: settings.defaultTaskDurationHours));
  }

  bool _isOnCriticalPath(TimelineDependency dependency) {
    // TODO: Implement critical path analysis
    // This would require calculating the critical path through the task network
    return false;
  }

  @override
  bool shouldRepaint(DependencyConnectionPainter oldDelegate) {
    return dependencies != oldDelegate.dependencies ||
           tasks != oldDelegate.tasks ||
           settings != oldDelegate.settings ||
           startDate != oldDelegate.startDate ||
           theme != oldDelegate.theme ||
           taskRowHeight != oldDelegate.taskRowHeight ||
           highlightCriticalPath != oldDelegate.highlightCriticalPath ||
           hoveredDependency != oldDelegate.hoveredDependency;
  }
}

/// Represents the position of a task in the timeline
class TaskPosition {
  final TaskModel task;
  final int index;
  final double startX;
  final double endX;
  final double centerY;

  TaskPosition({
    required this.task,
    required this.index,
    required this.startX,
    required this.endX,
    required this.centerY,
  });
}

/// Represents the connection points for drawing dependency lines
class ConnectionPoints {
  final Offset startPoint;
  final Offset endPoint;
  final Offset controlPoint1;
  final Offset controlPoint2;
  final double startDirection;
  final double endDirection;

  ConnectionPoints({
    required this.startPoint,
    required this.endPoint,
    required this.controlPoint1,
    required this.controlPoint2,
    required this.startDirection,
    required this.endDirection,
  });
}