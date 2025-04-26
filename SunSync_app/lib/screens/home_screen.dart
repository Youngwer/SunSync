import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../providers/light_provider.dart';

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

                  // 室内光照部分
                  _buildIndoorLightSection(context),
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

  // 室内光照部分的UI (更新以显示MQTT数据)
  Widget _buildIndoorLightSection(BuildContext context) {
    return Consumer<LightProvider>(
      builder: (context, lightProvider, child) {
        final isLoading = lightProvider.isLoading;
        final error = lightProvider.error;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.lightBlue[100],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Indoor Light',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (lightProvider.time.isNotEmpty)
                    Text(
                      lightProvider.time,
                      style: TextStyle(color: Colors.blue[800], fontSize: 14),
                    ),
                ],
              ),
              const SizedBox(height: 15),

              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (error != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      'Could not connect to light sensor',
                      style: TextStyle(color: Colors.red[300]),
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    // 当前光照强度
                    Row(
                      children: [
                        Icon(
                          Icons.wb_sunny,
                          color: Colors.amber[700],
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Current: ${lightProvider.currentLight}%',
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // 光照强度指示条
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value:
                            int.tryParse(
                              lightProvider.currentLight,
                            )?.toDouble() ??
                            0 / 100,
                        minHeight: 10,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getLightColor(
                            int.tryParse(lightProvider.currentLight) ?? 0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 今日最高光照
                    Row(
                      children: [
                        Icon(
                          Icons.trending_up,
                          color: Colors.green[700],
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Today\'s peak: ${lightProvider.highestLight}%',
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // 建议
                    if (lightProvider.suggestion.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lightbulb,
                              color: Colors.amber[800],
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                lightProvider.suggestion,
                                style: TextStyle(
                                  color: Colors.blue[900],
                                  fontSize: 14,
                                ),
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

  // 根据光照强度获取颜色
  Color _getLightColor(int lightLevel) {
    if (lightLevel < 30) {
      return Colors.blue[300]!; // 弱光
    } else if (lightLevel < 70) {
      return Colors.amber[400]!; // 中等光照
    } else {
      return Colors.orange[600]!; // 强光
    }
  }
}
