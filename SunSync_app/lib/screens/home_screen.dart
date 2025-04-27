// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../providers/weather_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // 初始化时获取天气数据
    Future.microtask(() {
      Provider.of<WeatherProvider>(
        context,
        listen: false,
      ).fetchWeatherForCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Provider.of<WeatherProvider>(
              context,
              listen: false,
            ).fetchWeatherForCurrentLocation();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 天气部分
                  _buildWeatherSection(context),

                  const SizedBox(height: 20),

                  // 日出日落部分
                  _buildSunriseSunsetSection(),

                  const SizedBox(height: 20),

                  // 活动推荐部分
                  _buildActivityRecommendation(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 天气部分的UI (保持原样)
  Widget _buildWeatherSection(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MY LOCATION',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                weatherProvider.location,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Center(
                child: Text(
                  '${weatherProvider.temperature.round()}°',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 80,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              Center(
                child: Text(
                  weatherProvider.condition,
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'H:${weatherProvider.highTemp.round()}° L:${weatherProvider.lowTemp.round()}°',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 日出日落部分的UI
  Widget _buildSunriseSunsetSection() {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        if (weatherProvider.sunrise == null || weatherProvider.sunset == null) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            ),
          );
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.orange[100],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sunrise & Sunset',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // 太阳轨迹可视化
              SizedBox(
                height: 150,
                child: CustomPaint(
                  size: const Size(double.infinity, 150),
                  painter: SunPathPainter(
                    progress: weatherProvider.getSunProgress(),
                    isDaytime: weatherProvider.isDaytime(),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 日出日落时间
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sunrise',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        DateFormat('HH:mm').format(weatherProvider.sunrise!),
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Sunset',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        DateFormat('HH:mm').format(weatherProvider.sunset!),
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 活动推荐部分 (保持原样)
  Widget _buildActivityRecommendation(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        final condition = weatherProvider.condition.toLowerCase();
        final recommendation = _getActivityRecommendation(condition);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Activity Suggestion',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Icon(
                    recommendation['icon'] as IconData,
                    color: Colors.green[700],
                    size: 32,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recommendation['title'] as String,
                          style: TextStyle(
                            color: Colors.green[800],
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          recommendation['description'] as String,
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 根据天气情况获取活动推荐
  Map<String, dynamic> _getActivityRecommendation(String condition) {
    if (condition.contains('rain') ||
        condition.contains('snow') ||
        condition.contains('thunderstorm') ||
        condition.contains('drizzle') ||
        condition.contains('hail')) {
      // 恶劣天气 - 室内活动
      return {
        'icon': Icons.self_improvement,
        'title': 'Indoor Activities',
        'description':
            'Perfect time for yoga, meditation, or indoor exercises. Stay cozy and focus on your wellbeing.',
      };
    } else if (condition.contains('clear') || condition.contains('sunny')) {
      // 晴天 - 户外活动
      return {
        'icon': Icons.directions_run,
        'title': 'Outdoor Activities',
        'description':
            'Great weather for running, cycling, or walking in the park. Enjoy the sunshine!',
      };
    } else if (condition.contains('cloud')) {
      // 多云 - 轻度户外活动
      return {
        'icon': Icons.directions_walk,
        'title': 'Light Outdoor Activities',
        'description':
            'Nice weather for a walk or light jogging. The cloud cover provides comfortable conditions.',
      };
    } else {
      // 其他天气情况
      return {
        'icon': Icons.fitness_center,
        'title': 'Flexible Activities',
        'description':
            'Choose activities based on your preference. Both indoor and outdoor options are suitable.',
      };
    }
  }
}

// 自定义太阳轨迹画板
class SunPathPainter extends CustomPainter {
  final double progress;
  final bool isDaytime;

  SunPathPainter({required this.progress, required this.isDaytime});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

    // 绘制地平线
    paint.color = Colors.orange[300]!;
    canvas.drawLine(
      Offset(0, size.height * 0.7),
      Offset(size.width, size.height * 0.7),
      paint,
    );

    // 绘制太阳轨迹
    paint.style = PaintingStyle.stroke;
    paint.color = Colors.orange;

    final path = Path();
    path.moveTo(0, size.height * 0.7);

    // 绘制一个弧形路径表示太阳轨迹
    path.quadraticBezierTo(size.width / 2, 0, size.width, size.height * 0.7);

    canvas.drawPath(path, paint);

    // 根据进度绘制太阳位置
    if (isDaytime) {
      // 计算太阳位置
      final sunX = size.width * progress;

      // 使用二次贝塞尔曲线计算 Y 坐标
      final t = progress;
      final sunY =
          2 * (1 - t) * t * 0 +
          (1 - t) * (1 - t) * size.height * 0.7 +
          t * t * size.height * 0.7;

      // 绘制太阳
      paint.style = PaintingStyle.fill;
      paint.color = Colors.orange;
      canvas.drawCircle(Offset(sunX, sunY), 10, paint);

      // 绘制太阳光晕
      paint.color = Colors.orange.withOpacity(0.3);
      canvas.drawCircle(Offset(sunX, sunY), 15, paint);
    } else {
      // 夜晚显示月亮
      final centerX = size.width / 2;
      final centerY = size.height / 3;

      // 绘制月亮
      paint.style = PaintingStyle.fill;
      paint.color = Colors.grey[300]!;
      canvas.drawCircle(Offset(centerX, centerY), 10, paint);

      // 绘制星星
      paint.color = Colors.yellow[700]!;
      final random = math.Random(42); // 固定种子以保持星星位置一致
      for (int i = 0; i < 10; i++) {
        final starX = random.nextDouble() * size.width;
        final starY = random.nextDouble() * size.height * 0.5;
        canvas.drawCircle(Offset(starX, starY), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(SunPathPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isDaytime != isDaytime;
  }
}
