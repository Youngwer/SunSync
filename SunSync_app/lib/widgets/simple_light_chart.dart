// widgets/simple_light_chart.dart

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
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

class _SimpleLightChartState extends State<SimpleLightChart>
    with SingleTickerProviderStateMixin {
  String? _tooltipText;
  Offset? _tooltipPosition;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 340,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 背景装饰
          Positioned(
            right: -50,
            top: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.blue.withOpacity(0.05),
                    Colors.blue.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.cyan.withOpacity(0.05),
                    Colors.cyan.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          // 主内容
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LIGHT HISTORY',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[800],
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Today\'s light levels from sunrise to sunset',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue[100]!, width: 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Live',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[800],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
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
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return CustomPaint(
                        size: Size(double.infinity, 240),
                        painter: SimpleLightChartPainter(
                          data: widget.data,
                          sunrise: widget.sunrise,
                          sunset: widget.sunset,
                          animationValue: _animation.value,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          // Tooltip
          if (_tooltipText != null && _tooltipPosition != null)
            Positioned(
              left: _tooltipPosition!.dx - 70,
              top: _tooltipPosition!.dy - 60,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[700]!, Colors.blue[900]!],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      _tooltipText!.split('\n')[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _tooltipText!.split('\n')[1],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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
    final chartPosition = localPosition.translate(-60, 0);

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
      // 过滤日出前的数据点
      if (widget.sunrise != null && item.timestamp.isBefore(widget.sunrise!)) {
        continue;
      }

      final minutesFromStart = item.timestamp.difference(startTime).inMinutes;
      final x = (size.width - 80) * minutesFromStart / timeRange;
      final y =
          (size.height - 100) - (size.height - 100) * item.lightLevel / 100;

      final distance = (Offset(x, y) - chartPosition).distance;
      if (distance < minDistance && distance < 30) {
        minDistance = distance;
        closestPoint = item;
        closestOffset = Offset(x + 60, y + 80);
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
  final double animationValue;

  SimpleLightChartPainter({
    required this.data,
    this.sunrise,
    this.sunset,
    this.animationValue = 1.0,
  });

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

    final gradientPaint =
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
          ..color = Colors.grey[200]!
          ..strokeWidth = 1.0;

    final dashPaint =
        Paint()
          ..color = Colors.grey[300]!
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke;

    // 留出边距
    final leftMargin = 60.0;
    final bottomMargin = 50.0;
    final topMargin = 20.0;
    final rightMargin = 30.0;
    final chartWidth = size.width - leftMargin - rightMargin;
    final chartHeight = size.height - bottomMargin - topMargin;

    // 绘制背景网格
    for (int i = 0; i <= 100; i += 20) {
      final y = topMargin + chartHeight - (chartHeight * i / 100);

      // 绘制虚线网格
      _drawDashedLine(
        canvas,
        Offset(leftMargin, y),
        Offset(size.width - rightMargin, y),
        dashPaint,
        dashWidth: 5,
        dashSpace: 5,
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
      canvas.drawParagraph(paragraph, Offset(leftMargin - 45, y - 6));
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

      // 过滤并收集日出后的数据点
      final filteredData =
          data.where((item) {
            return sunrise == null || !item.timestamp.isBefore(sunrise!);
          }).toList();

      // 如果过滤后没有数据，直接返回
      if (filteredData.isEmpty) return;

      // 收集所有数据点
      for (var item in filteredData) {
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

        // 限制路径长度根据动画值
        final pointCount = (points.length * animationValue).ceil();
        for (int i = 0; i < pointCount - 1; i++) {
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

        if (pointCount > 0) {
          fillPath.lineTo(points[pointCount - 1].dx, topMargin + chartHeight);
          fillPath.close();

          // 绘制填充区域
          canvas.drawPath(fillPath, gradientPaint);

          // 绘制曲线
          canvas.drawPath(path, paint);

          // 绘制数据点
          for (int i = 0; i < pointCount; i++) {
            final point = points[i];

            // 数据点发光效果
            canvas.drawCircle(
              point,
              6,
              Paint()..color = Colors.blue.withOpacity(0.2),
            );

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
      }

      // 绘制时间标签
      // 绘制日出时间 - 特殊样式
      _drawTimeLabel(
        canvas,
        DateFormat('HH:mm').format(startTime),
        leftMargin,
        size.height - bottomMargin + 25,
        isSpecial: true,
        icon: Icons.wb_sunny,
      );

      // 绘制选定的时间点
      final List<int> selectedHours = [8, 10, 12, 14, 16, 18];
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
            // 绘制垂直虚线
            _drawDashedLine(
              canvas,
              Offset(x, topMargin),
              Offset(x, topMargin + chartHeight),
              dashPaint,
            );

            // 绘制时间标签
            _drawTimeLabel(
              canvas,
              '${hour}:00',
              x,
              size.height - bottomMargin + 25,
            );
          }
        }
      }

      // 绘制日落时间 - 特殊样式
      _drawTimeLabel(
        canvas,
        DateFormat('HH:mm').format(endTime),
        size.width - rightMargin,
        size.height - bottomMargin + 25,
        isSpecial: true,
        icon: Icons.nights_stay,
      );
    }
  }

  void _drawTimeLabel(
    Canvas canvas,
    String text,
    double x,
    double y, {
    bool isSpecial = false,
    IconData? icon,
  }) {
    final textStyle = ui.TextStyle(
      color: isSpecial ? Colors.blue[700] : Colors.grey[600],
      fontWeight: isSpecial ? ui.FontWeight.w600 : ui.FontWeight.w500,
    );

    final paragraphBuilder =
        ui.ParagraphBuilder(
            ui.ParagraphStyle(textAlign: ui.TextAlign.center, fontSize: 13),
          )
          ..pushStyle(textStyle)
          ..addText(text);
    final paragraph = paragraphBuilder.build();
    paragraph.layout(ui.ParagraphConstraints(width: 70));

    if (isSpecial) {
      // 绘制特殊标记背景
      final bgPaint =
          Paint()
            ..color = Colors.blue[50]!
            ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, y + 6), width: 60, height: 24),
          Radius.circular(12),
        ),
        bgPaint,
      );

      // 绘制图标
      if (icon != null) {
        final iconPainter = TextPainter(
          text: TextSpan(
            text: String.fromCharCode(icon.codePoint),
            style: TextStyle(
              fontSize: 16,
              fontFamily: icon.fontFamily,
              color: Colors.blue[700],
            ),
          ),
          textDirection: ui.TextDirection.ltr,
        );
        iconPainter.layout();
        iconPainter.paint(canvas, Offset(x - 8, y - 18));
      }
    }

    canvas.drawParagraph(paragraph, Offset(x - 35, y));
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint, {
    double dashWidth = 3,
    double dashSpace = 3,
  }) {
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
        oldDelegate.sunset != sunset ||
        oldDelegate.animationValue != animationValue;
  }
}
