import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  // 日出日落部分的UI (保持不变)
  Widget _buildSunriseSunsetSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.orange[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sunrise & Sunset',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'This section will display sunrise and sunset times.',
            style: TextStyle(color: Colors.orange, fontSize: 14),
          ),
          SizedBox(height: 100), // 占位，后面会替换成实际内容
        ],
      ),
    );
  }

  // 新增：活动推荐部分
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
