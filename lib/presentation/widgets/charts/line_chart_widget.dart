import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'dart:math' as math;

import '../../../core/theme/typography_constants.dart';
import '../standardized_text.dart';
import 'base_chart_widget.dart';

/// Interactive line chart widget with animations and touch handling
class LineChartWidget extends BaseChartWidget {
  final List<TimeSeriesDataPoint> data;
  final ChartInteractionCallback? onPointTap;
  final bool showGrid;
  final bool showLabels;
  final bool enableAnimation;
  final Duration animationDuration;
  final Color? lineColor;
  final double lineWidth;
  final bool fillArea;
  final String? yAxisLabel;
  final String? xAxisLabel;

  const LineChartWidget({
    super.key,
    required super.title,
    super.subtitle,
    required super.icon,
    super.accentColor,
    super.onTap,
    super.trailing,
    super.padding,
    super.isLoading = false,
    super.error,
    required this.data,
    this.onPointTap,
    this.showGrid = true,
    this.showLabels = true,
    this.enableAnimation = true,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.lineColor,
    this.lineWidth = 2.0,
    this.fillArea = false,
    this.yAxisLabel,
    this.xAxisLabel,
  });

  @override
  Widget buildChart(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmptyState(context);
    }

    return SizedBox(
      height: 250,
      child: CustomPaint(
        painter: _LineChartPainter(
          data: data,
          theme: Theme.of(context),
          accentColor: lineColor ?? accentColor ?? Theme.of(context).colorScheme.primary,
          showGrid: showGrid,
          showLabels: showLabels,
          lineWidth: lineWidth,
          fillArea: fillArea,
        ),
        child: GestureDetector(
          onTapDown: (details) => _handleTap(context, details),
          child: Container(),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.chartLine(),
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              'No data available',
              style: StandardizedTextStyle.titleSmall.toTextStyle(context).copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              'Chart will appear when data is available',
              style: StandardizedTextStyle.bodySmall.toTextStyle(context).copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, TapDownDetails details) {
    if (onPointTap == null || data.isEmpty) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = details.localPosition;
    
    // Find the closest data point
    final chartWidth = renderBox.size.width - 80; // Account for padding
    final pointSpacing = chartWidth / (data.length - 1);
    final tappedIndex = (localPosition.dx - 40) / pointSpacing;
    
    final closestIndex = tappedIndex.round().clamp(0, data.length - 1);
    onPointTap!(data[closestIndex]);
  }
}

class _LineChartPainter extends CustomPainter {
  final List<TimeSeriesDataPoint> data;
  final ThemeData theme;
  final Color accentColor;
  final bool showGrid;
  final bool showLabels;
  final double lineWidth;
  final bool fillArea;

  _LineChartPainter({
    required this.data,
    required this.theme,
    required this.accentColor,
    required this.showGrid,
    required this.showLabels,
    required this.lineWidth,
    required this.fillArea,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = accentColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = theme.colorScheme.outline.withValues(alpha: 0.2)
      ..strokeWidth = 0.5;

    final textStyle = TextStyle(
      color: theme.colorScheme.onSurfaceVariant,
      fontSize: TypographyConstants.labelSmall,
    );

    // Calculate chart area
    const padding = 40.0;
    final chartRect = Rect.fromLTWH(
      padding,
      padding / 2,
      size.width - padding * 2,
      size.height - padding * 1.5,
    );

    // Find min/max values
    final values = data.map((p) => p.value).toList();
    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final valueRange = maxValue - minValue;
    
    // Adjust range if all values are the same
    final adjustedMinValue = valueRange == 0 ? minValue - 1 : minValue;
    final adjustedMaxValue = valueRange == 0 ? maxValue + 1 : maxValue;
    final adjustedRange = adjustedMaxValue - adjustedMinValue;

    // Draw grid lines
    if (showGrid) {
      _drawGrid(canvas, chartRect, gridPaint, adjustedMinValue, adjustedMaxValue);
    }

    // Calculate points
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = chartRect.left + (i / (data.length - 1)) * chartRect.width;
      final normalizedValue = (data[i].value - adjustedMinValue) / adjustedRange;
      final y = chartRect.bottom - normalizedValue * chartRect.height;
      points.add(Offset(x, y));
    }

    // Draw filled area
    if (fillArea && points.length > 1) {
      final fillPath = Path();
      fillPath.moveTo(points.first.dx, chartRect.bottom);
      for (final point in points) {
        fillPath.lineTo(point.dx, point.dy);
      }
      fillPath.lineTo(points.last.dx, chartRect.bottom);
      fillPath.close();
      canvas.drawPath(fillPath, fillPaint);
    }

    // Draw line
    if (points.length > 1) {
      final path = Path();
      path.moveTo(points.first.dx, points.first.dy);
      
      for (int i = 1; i < points.length; i++) {
        // Use smooth curves instead of straight lines
        final current = points[i];
        final previous = points[i - 1];
        
        if (i == 1) {
          path.lineTo(current.dx, current.dy);
        } else {
          final cp1x = previous.dx + (current.dx - previous.dx) * 0.5;
          final cp1y = previous.dy;
          final cp2x = current.dx - (current.dx - previous.dx) * 0.5;
          final cp2y = current.dy;
          
          path.cubicTo(cp1x, cp1y, cp2x, cp2y, current.dx, current.dy);
        }
      }
      
      canvas.drawPath(path, paint);
    }

    // Draw data points
    for (final point in points) {
      canvas.drawCircle(
        point,
        4,
        Paint()
          ..color = accentColor
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        point,
        4,
        Paint()
          ..color = theme.colorScheme.surface
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // Draw labels
    if (showLabels) {
      _drawLabels(canvas, chartRect, textStyle, adjustedMinValue, adjustedMaxValue);
    }
  }

  void _drawGrid(Canvas canvas, Rect chartRect, Paint gridPaint, double minValue, double maxValue) {
    const gridLines = 5;
    
    // Horizontal grid lines
    for (int i = 0; i <= gridLines; i++) {
      final y = chartRect.bottom - (i / gridLines) * chartRect.height;
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        gridPaint,
      );
    }

    // Vertical grid lines
    if (data.length > 1) {
      final verticalLines = math.min(6, data.length);
      for (int i = 0; i <= verticalLines; i++) {
        final x = chartRect.left + (i / verticalLines) * chartRect.width;
        canvas.drawLine(
          Offset(x, chartRect.top),
          Offset(x, chartRect.bottom),
          gridPaint,
        );
      }
    }
  }

  void _drawLabels(Canvas canvas, Rect chartRect, TextStyle textStyle, double minValue, double maxValue) {
    const labelCount = 5;
    
    // Y-axis labels (values)
    for (int i = 0; i <= labelCount; i++) {
      final value = minValue + (maxValue - minValue) * (i / labelCount);
      final y = chartRect.bottom - (i / labelCount) * chartRect.height;
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: _formatValue(value),
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(chartRect.left - textPainter.width - 8, y - textPainter.height / 2),
      );
    }

    // X-axis labels (dates) - show only a few to avoid crowding
    final labelIndices = _calculateLabelIndices(data.length);
    for (final i in labelIndices) {
      final x = chartRect.left + (i / (data.length - 1)) * chartRect.width;
      final date = data[i].date;
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: _formatDate(date),
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, chartRect.bottom + 8),
      );
    }
  }

  List<int> _calculateLabelIndices(int dataLength) {
    if (dataLength <= 6) {
      return List.generate(dataLength, (i) => i);
    }
    
    const maxLabels = 4;
    final indices = <int>[];
    final step = (dataLength - 1) / (maxLabels - 1);
    
    for (int i = 0; i < maxLabels; i++) {
      indices.add((i * step).round().clamp(0, dataLength - 1));
    }
    
    return indices;
  }

  String _formatValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else if (value == value.roundToDouble()) {
      return value.round().toString();
    } else {
      return value.toStringAsFixed(1);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  @override
  bool shouldRepaint(_LineChartPainter oldDelegate) {
    return data != oldDelegate.data ||
           accentColor != oldDelegate.accentColor ||
           showGrid != oldDelegate.showGrid ||
           showLabels != oldDelegate.showLabels ||
           lineWidth != oldDelegate.lineWidth ||
           fillArea != oldDelegate.fillArea;
  }
}