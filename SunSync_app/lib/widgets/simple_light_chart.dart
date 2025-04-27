// widgets/simple_light_chart.dart

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import '../models/light_history_model.dart';

class SimpleLightChart extends StatefulWidget {
  final List<LightHistoryModel> data;
  final DateTime? sunrise;
  final DateTime? sunset;

  const SimpleLightChart({
    Key? key,
    required this.data,
    this.sunrise,
    this.sunset,
  }) : super(key: key);

  @override
  State<SimpleLightChart> createState() => _SimpleLightChartState();
}

class _SimpleLightChartState extends State<SimpleLightChart> {
  String? _tooltipText;
  Offset? _tooltipPosition;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[50]!, Colors.lightBlue[50]!],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Light History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Today\'s indoor light levels from sunrise to sunset',
                      style: TextStyle(fontSize: 14, color: Colors.blue[600]),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTapDown: (details) => _handleTap(details.localPosition),
                  onLongPressStart:
                      (details) => _handleTap(details.localPosition),
                  onPanUpdate: (details) => _handleTap(details.localPosition),
                  onPanEnd: (_) => _clearTooltip(),
                  onTapUp: (_) => _clearTooltip(),
                  onLongPressEnd: (_) => _clearTooltip(),
                  child: CustomPaint(
                    size: Size(double.infinity, 200),
                    painter: SimpleLightChartPainter(
                      data: widget.data,
                      sunrise: widget.sunrise,
                      sunset: widget.sunset,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Tooltip
          if (_tooltipText != null && _tooltipPosition != null)
            Positioned(
              left: _tooltipPosition!.dx - 60,
              top: _tooltipPosition!.dy - 50,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[700]!, Colors.blue[900]!],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  _tooltipText!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handleTap(Offset localPosition) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    // 减去边距
    final chartPosition = localPosition.translate(-50, 0);

    if (widget.data.isEmpty) return;

    final startTime = widget.sunrise ?? widget.data.first.timestamp;
    final endTime = widget.sunset ?? widget.data.last.timestamp;
    final timeRange = endTime.difference(startTime).inMinutes;

    if (timeRange <= 0) return;

    // 查找最近的数据点
    LightHistoryModel? closestPoint;
    double minDistance = double.infinity;
    Offset? closestOffset;

    for (var item in widget.data) {
      final minutesFromStart = item.timestamp.difference(startTime).inMinutes;
      final x = (size.width - 66) * minutesFromStart / timeRange;
      final y = (size.height - 80) - (size.height - 80) * item.lightLevel / 100;

      final distance = (Offset(x, y) - chartPosition).distance;
      if (distance < minDistance && distance < 30) {
        minDistance = distance;
        closestPoint = item;
        closestOffset = Offset(x + 50, y + 80);
      }
    }

    if (closestPoint != null && closestOffset != null) {
      setState(() {
        _tooltipText =
            '${DateFormat('HH:mm').format(closestPoint!.timestamp)}\n${closestPoint.lightLevel}%';
        _tooltipPosition = closestOffset;
      });
    } else {
      _clearTooltip();
    }
  }

  void _clearTooltip() {
    setState(() {
      _tooltipText = null;
      _tooltipPosition = null;
    });
  }
}

class SimpleLightChartPainter extends CustomPainter {
  final List<LightHistoryModel> data;
  final DateTime? sunrise;
  final DateTime? sunset;

  SimpleLightChartPainter({required this.data, this.sunrise, this.sunset});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint =
        Paint()
          ..color = Colors.blue
          ..strokeWidth = 3.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    final fillPaint =
        Paint()
          ..style = PaintingStyle.fill
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.withOpacity(0.3),
              Colors.blue.withOpacity(0.0),
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final gridPaint =
        Paint()
          ..color = Colors.grey[300]!.withOpacity(0.5)
          ..strokeWidth = 1.0;

    // 留出边距
    final leftMargin = 55.0;
    final bottomMargin = 40.0;
    final topMargin = 15.0;
    final rightMargin = 25.0;
    final chartWidth = size.width - leftMargin - rightMargin;
    final chartHeight = size.height - bottomMargin - topMargin;

    // 绘制网格线
    for (int i = 0; i <= 100; i += 20) {
      final y = topMargin + chartHeight - (chartHeight * i / 100);
      canvas.drawLine(
        Offset(leftMargin, y),
        Offset(size.width - rightMargin, y),
        gridPaint,
      );

      // 绘制Y轴标签
      final paragraphBuilder =
          ui.ParagraphBuilder(
              ui.ParagraphStyle(
                textAlign: ui.TextAlign.right,
                fontSize: 12,
                fontWeight: ui.FontWeight.w500,
              ),
            )
            ..pushStyle(ui.TextStyle(color: Colors.grey[600]))
            ..addText('$i%');
      final paragraph = paragraphBuilder.build();
      paragraph.layout(ui.ParagraphConstraints(width: 40));
      canvas.drawParagraph(paragraph, Offset(leftMargin - 40, y - 6));
    }

    // 计算时间范围
    final startTime = sunrise ?? data.first.timestamp;
    final endTime = sunset ?? data.last.timestamp;
    final timeRange = endTime.difference(startTime).inMinutes;

    if (timeRange > 0) {
      // 创建平滑曲线路径
      final path = Path();
      final fillPath = Path();
      final points = <Offset>[];

      // 收集所有数据点
      for (var item in data) {
        final minutesFromStart = item.timestamp.difference(startTime).inMinutes;
        final x = leftMargin + (chartWidth * minutesFromStart / timeRange);
        final y =
            topMargin + chartHeight - (chartHeight * item.lightLevel / 100);
        points.add(Offset(x, y));
      }

      // 创建平滑的贝塞尔曲线
      if (points.isNotEmpty) {
        path.moveTo(points[0].dx, points[0].dy);
        fillPath.moveTo(points[0].dx, topMargin + chartHeight);
        fillPath.lineTo(points[0].dx, points[0].dy);

        for (int i = 0; i < points.length - 1; i++) {
          final p0 = i > 0 ? points[i - 1] : points[i];
          final p1 = points[i];
          final p2 = points[i + 1];
          final p3 = i < points.length - 2 ? points[i + 2] : p2;

          final cp1x = p1.dx + (p2.dx - p0.dx) / 6;
          final cp1y = p1.dy + (p2.dy - p0.dy) / 6;
          final cp2x = p2.dx - (p3.dx - p1.dx) / 6;
          final cp2y = p2.dy - (p3.dy - p1.dy) / 6;

          path.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
          fillPath.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
        }

        fillPath.lineTo(points.last.dx, topMargin + chartHeight);
        fillPath.close();

        // 绘制填充区域
        canvas.drawPath(fillPath, fillPaint);

        // 绘制曲线
        canvas.drawPath(path, paint);

        // 绘制数据点
        for (var point in points) {
          // 外圈
          canvas.drawCircle(
            point,
            4,
            Paint()
              ..color = Colors.white
              ..style = PaintingStyle.fill,
          );
          // 内圈
          canvas.drawCircle(
            point,
            3,
            Paint()
              ..color = Colors.blue
              ..style = PaintingStyle.fill,
          );
        }
      }

      // 绘制时间标签
      final List<int> selectedHours = [8, 10, 12, 14, 16, 18];

      // 绘制日出时间 - 特殊样式
      _drawTimeLabel(
        canvas,
        DateFormat('HH:mm').format(startTime),
        leftMargin,
        size.height - bottomMargin + 20,
        isSpecial: true,
      );

      // 添加日出标记
      final sunriseIcon = Icons.wb_sunny;
      final sunriseIconPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(sunriseIcon.codePoint),
          style: TextStyle(
            fontSize: 14,
            fontFamily: sunriseIcon.fontFamily,
            color: Colors.amber[700],
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      sunriseIconPainter.layout();
      sunriseIconPainter.paint(
        canvas,
        Offset(leftMargin - 7, size.height - bottomMargin - 10),
      );

      // 绘制选定的时间点
      for (int hour in selectedHours) {
        final DateTime time = DateTime(
          startTime.year,
          startTime.month,
          startTime.day,
          hour,
          0,
        );

        if (time.isAfter(startTime) && time.isBefore(endTime)) {
          final minutesFromStart = time.difference(startTime).inMinutes;
          final x = leftMargin + (chartWidth * minutesFromStart / timeRange);

          // 只有当时间点不会与日落时间太接近时才绘制
          final minutesToEnd = endTime.difference(time).inMinutes;
          if (minutesToEnd > 60) {
            // 只有当距离日落超过1小时才显示
            // 绘制垂直虚线
            _drawDashedLine(
              canvas,
              Offset(x, topMargin),
              Offset(x, topMargin + chartHeight),
              gridPaint,
            );

            // 绘制时间标签
            _drawTimeLabel(
              canvas,
              '${hour}:00',
              x,
              size.height - bottomMargin + 20,
            );
          }
        }
      }

      // 绘制日落时间 - 特殊样式
      _drawTimeLabel(
        canvas,
        DateFormat('HH:mm').format(endTime),
        size.width - rightMargin,
        size.height - bottomMargin + 20,
        isSpecial: true,
      );

      // 添加日落标记
      final sunsetIcon = Icons.nights_stay;
      final sunsetIconPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(sunsetIcon.codePoint),
          style: TextStyle(
            fontSize: 14,
            fontFamily: sunsetIcon.fontFamily,
            color: Colors.amber[700],
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      sunsetIconPainter.layout();
      sunsetIconPainter.paint(
        canvas,
        Offset(size.width - rightMargin - 7, size.height - bottomMargin - 10),
      );
    }
  }

  void _drawTimeLabel(
    Canvas canvas,
    String text,
    double x,
    double y, {
    bool isSpecial = false,
  }) {
    final textStyle = ui.TextStyle(
      color: isSpecial ? Colors.amber[700] : Colors.grey[600],
      fontWeight: isSpecial ? ui.FontWeight.w600 : ui.FontWeight.w500,
    );

    final paragraphBuilder =
        ui.ParagraphBuilder(
            ui.ParagraphStyle(textAlign: ui.TextAlign.center, fontSize: 13),
          )
          ..pushStyle(textStyle)
          ..addText(text);
    final paragraph = paragraphBuilder.build();
    paragraph.layout(ui.ParagraphConstraints(width: 60));

    if (isSpecial) {
      // 绘制特殊标记背景
      final bgPaint =
          Paint()
            ..color = Colors.amber[50]!
            ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, y + 6), width: 55, height: 22),
          Radius.circular(11),
        ),
        bgPaint,
      );
    }

    canvas.drawParagraph(paragraph, Offset(x - 30, y));
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    final dashWidth = 3;
    final dashSpace = 3;
    double distance = (end - start).distance;
    double currentDistance = 0;

    while (currentDistance < distance) {
      final dashStart = start + (end - start) * (currentDistance / distance);
      final dashEnd =
          start + (end - start) * ((currentDistance + dashWidth) / distance);
      canvas.drawLine(dashStart, dashEnd, paint);
      currentDistance += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(SimpleLightChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.sunrise != sunrise ||
        oldDelegate.sunset != sunset;
  }
}
