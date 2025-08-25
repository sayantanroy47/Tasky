import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'dart:math' as math;

import '../../../core/theme/typography_constants.dart';
import '../standardized_text.dart';
import 'base_chart_widget.dart';

/// Interactive bar chart widget with animations and touch handling
class BarChartWidget extends BaseChartWidget {
  final List<ChartDataPoint> data;
  final ChartInteractionCallback? onBarTap;
  final bool showGrid;
  final bool showLabels;
  final bool enableAnimation;
  final Duration animationDuration;
  final bool horizontal;
  final double barSpacing;
  final String? yAxisLabel;
  final String? xAxisLabel;

  const BarChartWidget({
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
    this.onBarTap,
    this.showGrid = true,
    this.showLabels = true,
    this.enableAnimation = true,
    this.animationDuration = const Duration(milliseconds: 1200),
    this.horizontal = false,
    this.barSpacing = 0.1,
    this.yAxisLabel,
    this.xAxisLabel,
  });

  @override
  Widget buildChart(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmptyState(context);
    }

    return SizedBox(
      height: horizontal ? math.min(300, data.length * 40.0 + 80) : 250,
      child: CustomPaint(
        painter: _BarChartPainter(
          data: data,
          theme: Theme.of(context),
          accentColor: accentColor ?? Theme.of(context).colorScheme.primary,
          showGrid: showGrid,
          showLabels: showLabels,
          horizontal: horizontal,
          barSpacing: barSpacing,
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
              PhosphorIcons.chartBar(),
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
    if (onBarTap == null || data.isEmpty) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = details.localPosition;
    
    const padding = 40.0;
    
    if (horizontal) {
      // Horizontal bars - find by Y position
      final chartHeight = renderBox.size.height - padding * 1.5;
      final barHeight = chartHeight / data.length;
      final tappedIndex = ((localPosition.dy - padding / 2) / barHeight).floor();
      
      if (tappedIndex >= 0 && tappedIndex < data.length) {
        onBarTap!(data[tappedIndex]);
      }
    } else {
      // Vertical bars - find by X position
      final chartWidth = renderBox.size.width - padding * 2;
      final barWidth = chartWidth / data.length;
      final tappedIndex = ((localPosition.dx - padding) / barWidth).floor();
      
      if (tappedIndex >= 0 && tappedIndex < data.length) {
        onBarTap!(data[tappedIndex]);
      }
    }
  }
}

class _BarChartPainter extends CustomPainter {
  final List<ChartDataPoint> data;
  final ThemeData theme;
  final Color accentColor;
  final bool showGrid;
  final bool showLabels;
  final bool horizontal;
  final double barSpacing;

  _BarChartPainter({
    required this.data,
    required this.theme,
    required this.accentColor,
    required this.showGrid,
    required this.showLabels,
    required this.horizontal,
    required this.barSpacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

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

    // Find max value for scaling
    final maxValue = data.map((p) => p.value).reduce(math.max);
    final adjustedMaxValue = maxValue == 0 ? 1.0 : maxValue.toDouble();

    // Draw grid
    if (showGrid) {
      _drawGrid(canvas, chartRect, gridPaint, adjustedMaxValue);
    }

    // Draw bars
    if (horizontal) {
      _drawHorizontalBars(canvas, chartRect, adjustedMaxValue);
    } else {
      _drawVerticalBars(canvas, chartRect, adjustedMaxValue);
    }

    // Draw labels
    if (showLabels) {
      _drawLabels(canvas, chartRect, textStyle, adjustedMaxValue);
    }
  }

  void _drawGrid(Canvas canvas, Rect chartRect, Paint gridPaint, double maxValue) {
    const gridLines = 5;
    
    if (horizontal) {
      // Vertical grid lines for horizontal bars
      for (int i = 0; i <= gridLines; i++) {
        final x = chartRect.left + (i / gridLines) * chartRect.width;
        canvas.drawLine(
          Offset(x, chartRect.top),
          Offset(x, chartRect.bottom),
          gridPaint,
        );
      }
    } else {
      // Horizontal grid lines for vertical bars
      for (int i = 0; i <= gridLines; i++) {
        final y = chartRect.bottom - (i / gridLines) * chartRect.height;
        canvas.drawLine(
          Offset(chartRect.left, y),
          Offset(chartRect.right, y),
          gridPaint,
        );
      }
    }
  }

  void _drawVerticalBars(Canvas canvas, Rect chartRect, double maxValue) {
    final barWidth = (chartRect.width / data.length) * (1 - barSpacing);
    final spacing = chartRect.width / data.length;
    
    for (int i = 0; i < data.length; i++) {
      final dataPoint = data[i];
      final normalizedHeight = (dataPoint.value / maxValue) * chartRect.height;
      
      final barRect = Rect.fromLTWH(
        chartRect.left + i * spacing + (spacing - barWidth) / 2,
        chartRect.bottom - normalizedHeight,
        barWidth,
        normalizedHeight,
      );

      final barColor = dataPoint.color ?? accentColor;
      
      // Draw bar with gradient
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          barColor,
          barColor.withValues(alpha: 0.7),
        ],
      );

      final barPaint = Paint()
        ..shader = gradient.createShader(barRect)
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = barColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      // Draw bar with rounded corners
      const borderRadius = BorderRadius.vertical(
        top: Radius.circular(TypographyConstants.radiusXSmall),
      );
      final rrect = RRect.fromRectAndCorners(
        barRect,
        topLeft: borderRadius.topLeft,
        topRight: borderRadius.topRight,
      );

      canvas.drawRRect(rrect, barPaint);
      canvas.drawRRect(rrect, borderPaint);

      // Draw value on top of bar
      if (normalizedHeight > 20) { // Only show if bar is tall enough
        final valueText = _formatValue(dataPoint.value);
        final textPainter = TextPainter(
          text: TextSpan(
            text: valueText,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: TypographyConstants.labelSmall,
              fontWeight: TypographyConstants.medium,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        
        textPainter.layout();
        final textY = barRect.top - textPainter.height - 4;
        if (textY > chartRect.top) { // Make sure text fits in chart area
          textPainter.paint(
            canvas,
            Offset(barRect.center.dx - textPainter.width / 2, textY),
          );
        }
      }
    }
  }

  void _drawHorizontalBars(Canvas canvas, Rect chartRect, double maxValue) {
    final barHeight = (chartRect.height / data.length) * (1 - barSpacing);
    final spacing = chartRect.height / data.length;
    
    for (int i = 0; i < data.length; i++) {
      final dataPoint = data[i];
      final normalizedWidth = (dataPoint.value / maxValue) * chartRect.width;
      
      final barRect = Rect.fromLTWH(
        chartRect.left,
        chartRect.top + i * spacing + (spacing - barHeight) / 2,
        normalizedWidth,
        barHeight,
      );

      final barColor = dataPoint.color ?? accentColor;
      
      // Draw bar with gradient
      final gradient = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          barColor,
          barColor.withValues(alpha: 0.7),
        ],
      );

      final barPaint = Paint()
        ..shader = gradient.createShader(barRect)
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = barColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      // Draw bar with rounded corners
      const borderRadius = BorderRadius.horizontal(
        right: Radius.circular(TypographyConstants.radiusXSmall),
      );
      final rrect = RRect.fromRectAndCorners(
        barRect,
        topRight: borderRadius.topRight,
        bottomRight: borderRadius.bottomRight,
      );

      canvas.drawRRect(rrect, barPaint);
      canvas.drawRRect(rrect, borderPaint);

      // Draw value at end of bar
      if (normalizedWidth > 40) { // Only show if bar is wide enough
        final valueText = _formatValue(dataPoint.value);
        final textPainter = TextPainter(
          text: TextSpan(
            text: valueText,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: TypographyConstants.labelSmall,
              fontWeight: TypographyConstants.medium,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        
        textPainter.layout();
        final textX = barRect.right + 4;
        if (textX + textPainter.width < chartRect.right) { // Make sure text fits
          textPainter.paint(
            canvas,
            Offset(textX, barRect.center.dy - textPainter.height / 2),
          );
        }
      }
    }
  }

  void _drawLabels(Canvas canvas, Rect chartRect, TextStyle textStyle, double maxValue) {
    if (horizontal) {
      _drawHorizontalLabels(canvas, chartRect, textStyle, maxValue);
    } else {
      _drawVerticalLabels(canvas, chartRect, textStyle, maxValue);
    }
  }

  void _drawVerticalLabels(Canvas canvas, Rect chartRect, TextStyle textStyle, double maxValue) {
    const labelCount = 5;
    
    // Y-axis labels (values)
    for (int i = 0; i <= labelCount; i++) {
      final value = (maxValue / labelCount) * i;
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

    // X-axis labels (categories)
    final spacing = chartRect.width / data.length;
    for (int i = 0; i < data.length; i++) {
      final x = chartRect.left + i * spacing + spacing / 2;
      final label = data[i].label;
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: _truncateLabel(label, 8),
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

  void _drawHorizontalLabels(Canvas canvas, Rect chartRect, TextStyle textStyle, double maxValue) {
    const labelCount = 4;
    
    // X-axis labels (values)
    for (int i = 0; i <= labelCount; i++) {
      final value = (maxValue / labelCount) * i;
      final x = chartRect.left + (i / labelCount) * chartRect.width;
      
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
        Offset(x - textPainter.width / 2, chartRect.bottom + 8),
      );
    }

    // Y-axis labels (categories)
    final spacing = chartRect.height / data.length;
    for (int i = 0; i < data.length; i++) {
      final y = chartRect.top + i * spacing + spacing / 2;
      final label = data[i].label;
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: _truncateLabel(label, 12),
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

  String _truncateLabel(String label, int maxLength) {
    if (label.length <= maxLength) return label;
    return '${label.substring(0, maxLength - 3)}...';
  }

  @override
  bool shouldRepaint(_BarChartPainter oldDelegate) {
    return data != oldDelegate.data ||
           accentColor != oldDelegate.accentColor ||
           showGrid != oldDelegate.showGrid ||
           showLabels != oldDelegate.showLabels ||
           horizontal != oldDelegate.horizontal ||
           barSpacing != oldDelegate.barSpacing;
  }
}