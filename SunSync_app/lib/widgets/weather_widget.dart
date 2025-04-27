// widgets/weather_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';

class WeatherWidget extends StatelessWidget {
  const WeatherWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        return SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              // 动态背景
              _buildDynamicBackground(weatherProvider.condition),

              // 天气动画层
              _buildWeatherAnimation(weatherProvider.condition),

              // 天气信息内容
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 顶部信息
                      Text(
                        'MY LOCATION',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        weatherProvider.location,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 中间温度
                      Center(
                        child: Column(
                          children: [
                            Text(
                              '${weatherProvider.temperature.round()}°',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 96,
                                fontWeight: FontWeight.w200,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              weatherProvider.condition,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildTempIndicator(
                                  'H',
                                  weatherProvider.highTemp.round(),
                                  Colors.white,
                                ),
                                const SizedBox(width: 24),
                                _buildTempIndicator(
                                  'L',
                                  weatherProvider.lowTemp.round(),
                                  Colors.white.withOpacity(0.8),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 构建动态背景
  Widget _buildDynamicBackground(String condition) {
    LinearGradient gradient;

    if (condition.toLowerCase().contains('clear') ||
        condition.toLowerCase().contains('sunny')) {
      gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF4FC3F7),
          const Color(0xFF0288D1),
          const Color(0xFF01579B),
        ],
      );
    } else if (condition.toLowerCase().contains('cloud')) {
      gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF90A4AE),
          const Color(0xFF607D8B),
          const Color(0xFF455A64),
        ],
      );
    } else if (condition.toLowerCase().contains('rain') ||
        condition.toLowerCase().contains('drizzle')) {
      gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF455A64),
          const Color(0xFF37474F),
          const Color(0xFF263238),
        ],
      );
    } else if (condition.toLowerCase().contains('snow')) {
      gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFE1F5FE),
          const Color(0xFF81D4FA),
          const Color(0xFF4FC3F7),
        ],
      );
    } else {
      gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF42A5F5),
          const Color(0xFF2196F3),
          const Color(0xFF1976D2),
        ],
      );
    }

    return Container(decoration: BoxDecoration(gradient: gradient));
  }

  // 构建天气动画层
  Widget _buildWeatherAnimation(String condition) {
    if (condition.toLowerCase().contains('cloud')) {
      return const CloudAnimation();
    } else if (condition.toLowerCase().contains('rain') ||
        condition.toLowerCase().contains('drizzle')) {
      return const RainAnimation();
    } else if (condition.toLowerCase().contains('snow')) {
      return const SnowAnimation();
    } else if (condition.toLowerCase().contains('clear') ||
        condition.toLowerCase().contains('sunny')) {
      return const SunAnimation();
    }
    return const SizedBox.shrink();
  }

  // 构建温度指示器
  Widget _buildTempIndicator(String label, int temp, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$temp°',
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// 动画组件保持不变...
class CloudAnimation extends StatefulWidget {
  const CloudAnimation({Key? key}) : super(key: key);

  @override
  State<CloudAnimation> createState() => _CloudAnimationState();
}

class _CloudAnimationState extends State<CloudAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: 50,
              left: MediaQuery.of(context).size.width * _animation.value,
              child: Opacity(
                opacity: 0.3,
                child: Icon(Icons.cloud, size: 120, color: Colors.white),
              ),
            ),
            Positioned(
              top: 120,
              left:
                  MediaQuery.of(context).size.width * (_animation.value - 0.5),
              child: Opacity(
                opacity: 0.2,
                child: Icon(Icons.cloud, size: 80, color: Colors.white),
              ),
            ),
            Positioned(
              top: 200,
              left:
                  MediaQuery.of(context).size.width * (_animation.value - 0.3),
              child: Opacity(
                opacity: 0.25,
                child: Icon(Icons.cloud, size: 140, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

// 其他动画组件保持不变，只是尺寸调整更大...
class RainAnimation extends StatefulWidget {
  const RainAnimation({Key? key}) : super(key: key);

  @override
  State<RainAnimation> createState() => _RainAnimationState();
}

class _RainAnimationState extends State<RainAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: List.generate(30, (index) {
            final random = index * 0.1;
            return Positioned(
              top:
                  (_controller.value + random) *
                      MediaQuery.of(context).size.height -
                  50,
              left: (index * 30).toDouble(),
              child: Transform.rotate(
                angle: 0.2,
                child: Container(
                  width: 2,
                  height: 15,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// 其他动画组件（SnowAnimation, SunAnimation）保持相似结构，只是尺寸调整...
class SnowAnimation extends StatefulWidget {
  const SnowAnimation({Key? key}) : super(key: key);

  @override
  State<SnowAnimation> createState() => _SnowAnimationState();
}

class _SnowAnimationState extends State<SnowAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: List.generate(40, (index) {
            final random = index * 0.05;
            return Positioned(
              top:
                  (_controller.value + random) *
                      MediaQuery.of(context).size.height -
                  50,
              left: (index * 25).toDouble(),
              child: Opacity(
                opacity: 0.6,
                child: Icon(Icons.ac_unit, size: 16, color: Colors.white),
              ),
            );
          }),
        );
      },
    );
  }
}

class SunAnimation extends StatefulWidget {
  const SunAnimation({Key? key}) : super(key: key);

  @override
  State<SunAnimation> createState() => _SunAnimationState();
}

class _SunAnimationState extends State<SunAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          top: 60,
          right: 60,
          child: Transform.scale(
            scale: _animation.value,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.0),
                  ],
                ),
              ),
              child: const Icon(Icons.wb_sunny, size: 60, color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}
