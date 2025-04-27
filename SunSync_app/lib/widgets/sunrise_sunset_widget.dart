// widgets/sunrise_sunset_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'dart:ui'; // 添加这个导入以使用ImageFilter
import '../providers/weather_provider.dart';

class SunriseSunsetWidget extends StatelessWidget {
  const SunriseSunsetWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        if (weatherProvider.sunrise == null || weatherProvider.sunset == null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.0,
                  ),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sunrise & Sunset',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 太阳轨迹可视化
                  SizedBox(
                    height: 200,
                    child: CustomPaint(
                      size: const Size(double.infinity, 200),
                      painter: SunPathPainter(
                        progress: weatherProvider.getSunProgress(),
                        isDaytime: weatherProvider.isDaytime(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 日出日落时间
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.wb_sunny_outlined,
                                color: Colors.orange,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Sunrise',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            DateFormat(
                              'HH:mm',
                            ).format(weatherProvider.sunrise!),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.nights_stay_outlined,
                                color: Colors.orange,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Sunset',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            DateFormat('HH:mm').format(weatherProvider.sunset!),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// 自定义太阳轨迹画板 - 更大的半圆
class SunPathPainter extends CustomPainter {
  final double progress;
  final bool isDaytime;

  SunPathPainter({required this.progress, required this.isDaytime});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0;

    // 绘制地平线
    paint.color = Colors.white.withOpacity(0.5);
    canvas.drawLine(
      Offset(0, size.height * 0.8),
      Offset(size.width, size.height * 0.8),
      paint,
    );

    // 绘制太阳轨迹 - 更大的弧形
    paint.style = PaintingStyle.stroke;
    paint.color = Colors.orange.withOpacity(0.7);
    paint.strokeWidth = 2.0;

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height * 0.8;
    final radius = size.width * 0.4;

    path.moveTo(centerX - radius, centerY);

    // 绘制更大的半圆
    path.arcTo(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
      math.pi,
      math.pi,
      false,
    );

    canvas.drawPath(path, paint);

    // 绘制虚线指示当前时间
    paint.strokeWidth = 1.0;
    paint.color = Colors.white.withOpacity(0.3);
    final dashHeight = 5.0;
    final dashSpace = 5.0;
    var startY = 0.0;

    while (startY < centerY) {
      canvas.drawLine(
        Offset(centerX, startY),
        Offset(centerX, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }

    // 根据进度绘制太阳位置
    if (isDaytime) {
      // 计算太阳位置 - 修复计算逻辑
      final angle = math.pi * progress; // 从左到右的角度
      final sunX = centerX - radius * math.cos(angle);
      final sunY = centerY - radius * math.sin(angle);

      // 绘制太阳光晕
      paint.style = PaintingStyle.fill;
      paint.color = Colors.orange.withOpacity(0.2);
      canvas.drawCircle(Offset(sunX, sunY), 24, paint);

      // 绘制太阳
      paint.color = Colors.orange;
      canvas.drawCircle(Offset(sunX, sunY), 16, paint);

      // 绘制太阳内部
      paint.color = Colors.yellow;
      canvas.drawCircle(Offset(sunX, sunY), 12, paint);
    } else {
      // 夜晚显示月亮和星星
      final moonX = centerX;
      final moonY = size.height * 0.3;

      // 绘制月亮光晕
      paint.style = PaintingStyle.fill;
      paint.color = Colors.white.withOpacity(0.1);
      canvas.drawCircle(Offset(moonX, moonY), 20, paint);

      // 绘制月亮
      paint.color = Colors.white.withOpacity(0.8);
      canvas.drawCircle(Offset(moonX, moonY), 14, paint);

      // 绘制星星
      final random = math.Random(42); // 固定种子以保持星星位置一致
      for (int i = 0; i < 20; i++) {
        final starX = random.nextDouble() * size.width;
        final starY = random.nextDouble() * size.height * 0.6;
        final starSize = random.nextDouble() * 2 + 1;

        paint.color = Colors.white.withOpacity(random.nextDouble() * 0.5 + 0.3);
        canvas.drawCircle(Offset(starX, starY), starSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(SunPathPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isDaytime != isDaytime;
  }
}
