import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'dart:math' as math;

import '../../../core/theme/typography_constants.dart';
import '../standardized_text.dart';
import 'base_chart_widget.dart';

/// Interactive pie/donut chart widget with animations and touch handling
class PieChartWidget extends BaseChartWidget {
  final List<ChartDataPoint> data;
  final ChartInteractionCallback? onSliceTap;
  final bool showLabels;
  final bool showPercentages;
  final bool enableAnimation;
  final Duration animationDuration;
  final bool isDonut;
  final double donutWidth;
  final Widget? centerWidget;
  final double startAngle;

  const PieChartWidget({
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
    this.onSliceTap,
    this.showLabels = true,
    this.showPercentages = true,
    this.enableAnimation = true,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.isDonut = false,
    this.donutWidth = 40.0,
    this.centerWidget,
    this.startAngle = -math.pi / 2, // Start at top
  });

  @override
  Widget buildChart(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmptyState(context);
    }

    return SizedBox(
      height: 300,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                CustomPaint(
                  painter: _PieChartPainter(
                    data: data,
                    theme: Theme.of(context),
                    accentColor: accentColor ?? Theme.of(context).colorScheme.primary,
                    isDonut: isDonut,
                    donutWidth: donutWidth,
                    startAngle: startAngle,
                  ),
                  child: GestureDetector(
                    onTapDown: (details) => _handleTap(context, details),
                    child: Container(),
                  ),
                ),
                if (isDonut && centerWidget != null)
                  Center(child: centerWidget!),
              ],
            ),
          ),
          if (showLabels) ...[
            const SizedBox(height: TypographyConstants.spacingMedium),
            _buildLegend(context),
          ],
        ],
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
              PhosphorIcons.chartPie(),
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

  Widget _buildLegend(BuildContext context) {
    final theme = Theme.of(context);
    final totalValue = data.fold<double>(0, (sum, point) => sum + point.value);
    final colors = _generateColors(theme);

    return Wrap(
      spacing: TypographyConstants.spacingSmall,
      runSpacing: TypographyConstants.spacingSmall / 2,
      children: data.asMap().entries.map((entry) {
        final index = entry.key;
        final dataPoint = entry.value;
        final color = dataPoint.color ?? colors[index % colors.length];
        final percentage = totalValue > 0 ? (dataPoint.value / totalValue) * 100 : 0;

        return InkWell(
          onTap: () => onSliceTap?.call(dataPoint),
          borderRadius: BorderRadius.circular(TypographyConstants.radiusXSmall),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: TypographyConstants.spacingSmall,
              vertical: 4,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  dataPoint.label,
                  style: StandardizedTextStyle.bodySmall.toTextStyle(context).copyWith(
                    fontSize: TypographyConstants.bodySmall,
                  ),
                ),
                if (showPercentages) ...[
                  const SizedBox(width: 4),
                  Text(
                    '(${percentage.toStringAsFixed(1)}%)',
                    style: StandardizedTextStyle.bodySmall.toTextStyle(context).copyWith(
                      fontSize: TypographyConstants.labelSmall,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _handleTap(BuildContext context, TapDownDetails details) {
    if (onSliceTap == null || data.isEmpty) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final center = Offset(size.width / 2, size.height / 2);
    final tapPosition = details.localPosition;
    
    // Calculate angle from tap position
    final dx = tapPosition.dx - center.dx;
    final dy = tapPosition.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    
    // Check if tap is within the chart circle
    final chartRadius = math.min(size.width, size.height) / 2 - 20;
    final innerRadius = isDonut ? (chartRadius - donutWidth).toDouble() : 0.0;
    
    if (distance < innerRadius || distance > chartRadius) return;
    
    // Calculate angle
    var angle = math.atan2(dy, dx);
    angle = angle - startAngle;
    if (angle < 0) angle += 2 * math.pi;
    
    // Find which slice was tapped
    final totalValue = data.fold<double>(0, (sum, point) => sum + point.value);
    var currentAngle = 0.0;
    
    for (int i = 0; i < data.length; i++) {
      final sliceAngle = totalValue > 0 ? (data[i].value / totalValue) * 2 * math.pi : 0;
      
      if (angle >= currentAngle && angle < currentAngle + sliceAngle) {
        onSliceTap!(data[i]);
        break;
      }
      
      currentAngle += sliceAngle;
    }
  }

  List<Color> _generateColors(ThemeData theme) {
    final baseColor = accentColor ?? theme.colorScheme.primary;
    final colors = <Color>[];
    
    // Generate a palette based on the accent color
    final hsl = HSLColor.fromColor(baseColor);
    
    for (int i = 0; i < math.max(8, data.length); i++) {
      final hue = (hsl.hue + i * 45) % 360;
      final saturation = math.max(0.4, hsl.saturation - i * 0.1);
      final lightness = hsl.lightness + (i.isEven ? 0.1 : -0.1) * (i / 10);
      
      colors.add(HSLColor.fromAHSL(1.0, hue, saturation, lightness.clamp(0.2, 0.8)).toColor());
    }
    
    return colors;
  }
}

class _PieChartPainter extends CustomPainter {
  final List<ChartDataPoint> data;
  final ThemeData theme;
  final Color accentColor;
  final bool isDonut;
  final double donutWidth;
  final double startAngle;

  _PieChartPainter({
    required this.data,
    required this.theme,
    required this.accentColor,
    required this.isDonut,
    required this.donutWidth,
    required this.startAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;
    final innerRadius = isDonut ? (radius - donutWidth).toDouble() : 0.0;
    
    final totalValue = data.fold<double>(0, (sum, point) => sum + point.value);
    if (totalValue == 0) return;

    final colors = _generateColors();
    var currentAngle = startAngle;

    // Draw each slice
    for (int i = 0; i < data.length; i++) {
      final dataPoint = data[i];
      final sliceAngle = (dataPoint.value / totalValue) * 2 * math.pi;
      final color = dataPoint.color ?? colors[i % colors.length];

      // Create gradient paint
      final gradient = RadialGradient(
        colors: [
          color,
          color.withValues(alpha: 0.8),
        ],
        stops: const [0.6, 1.0],
      );

      final paint = Paint()
        ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.fill;

      final strokePaint = Paint()
        ..color = theme.colorScheme.surface
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      // Draw the slice
      if (isDonut) {
        // Draw donut slice
        final path = Path();
        final outerArcStart = Offset(
          center.dx + radius * math.cos(currentAngle),
          center.dy + radius * math.sin(currentAngle),
        );
        final outerArcEnd = Offset(
          center.dx + radius * math.cos(currentAngle + sliceAngle),
          center.dy + radius * math.sin(currentAngle + sliceAngle),
        );
        final innerArcStart = Offset(
          center.dx + innerRadius * math.cos(currentAngle),
          center.dy + innerRadius * math.sin(currentAngle),
        );
        final innerArcEnd = Offset(
          center.dx + innerRadius * math.cos(currentAngle + sliceAngle),
          center.dy + innerRadius * math.sin(currentAngle + sliceAngle),
        );

        path.moveTo(outerArcStart.dx, outerArcStart.dy);
        path.arcTo(
          Rect.fromCircle(center: center, radius: radius),
          currentAngle,
          sliceAngle,
          false,
        );
        path.lineTo(innerArcEnd.dx, innerArcEnd.dy);
        path.arcTo(
          Rect.fromCircle(center: center, radius: innerRadius),
          currentAngle + sliceAngle,
          -sliceAngle,
          false,
        );
        path.close();

        canvas.drawPath(path, paint);
        canvas.drawPath(path, strokePaint);
      } else {
        // Draw pie slice
        final path = Path();
        path.moveTo(center.dx, center.dy);
        path.arcTo(
          Rect.fromCircle(center: center, radius: radius),
          currentAngle,
          sliceAngle,
          false,
        );
        path.close();

        canvas.drawPath(path, paint);
        canvas.drawPath(path, strokePaint);
      }

      currentAngle += sliceAngle;
    }

    // Add subtle shadow effect
    if (isDonut) {
      final shadowPaint = Paint()
        ..color = theme.colorScheme.shadow.withValues(alpha: 0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      
      canvas.drawCircle(center, radius, shadowPaint);
    }
  }

  List<Color> _generateColors() {
    final colors = <Color>[];
    final hsl = HSLColor.fromColor(accentColor);
    
    for (int i = 0; i < data.length; i++) {
      final hue = (hsl.hue + i * 45) % 360;
      final saturation = math.max(0.4, hsl.saturation - i * 0.05);
      final lightness = hsl.lightness + (i.isEven ? 0.1 : -0.1) * (i / 8);
      
      colors.add(HSLColor.fromAHSL(1.0, hue, saturation, lightness.clamp(0.3, 0.7)).toColor());
    }
    
    return colors;
  }

  @override
  bool shouldRepaint(_PieChartPainter oldDelegate) {
    return data != oldDelegate.data ||
           accentColor != oldDelegate.accentColor ||
           isDonut != oldDelegate.isDonut ||
           donutWidth != oldDelegate.donutWidth ||
           startAngle != oldDelegate.startAngle;
  }
}