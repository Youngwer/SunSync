// screens/light_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/light_provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/simple_light_chart.dart';

class LightScreen extends StatefulWidget {
  const LightScreen({Key? key}) : super(key: key);

  @override
  State<LightScreen> createState() => _LightScreenState();
}

class _LightScreenState extends State<LightScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // 初始化动画控制器
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    // 确保天气数据已加载
    Future.microtask(() {
      Provider.of<WeatherProvider>(
        context,
        listen: false,
      ).fetchWeatherForCurrentLocation();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<LightProvider>(
        builder: (context, lightProvider, child) {
          // 基于光照条件选择渐变色
          List<Color> gradientColors;

          if (lightProvider.lightCondition.toLowerCase().contains('low')) {
            gradientColors = [Colors.indigo[300]!, Colors.deepPurple[900]!];
          } else if (lightProvider.lightCondition.toLowerCase().contains(
            'bright',
          )) {
            gradientColors = [Colors.amber[400]!, Colors.orange[900]!];
          } else {
            gradientColors = [Colors.cyan[400]!, Colors.blue[900]!];
          }

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  gradientColors[0].withOpacity(0.1),
                  Colors.white,
                  gradientColors[1].withOpacity(0.05),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Indoor Light Condition 部分
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildIndoorLightSection(
                          context,
                          gradientColors,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Light History 部分
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildLightHistorySection(context),
                      ),
                      const SizedBox(height: 20),
                      // Light Recommendations
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildRecommendationsSection(
                          context,
                          lightProvider,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIndoorLightSection(
    BuildContext context,
    List<Color> gradientColors,
  ) {
    return Consumer<LightProvider>(
      builder: (context, lightProvider, child) {
        IconData iconData;

        if (lightProvider.lightCondition.toLowerCase().contains('low')) {
          iconData = Icons.dark_mode_outlined;
        } else if (lightProvider.lightCondition.toLowerCase().contains(
          'bright',
        )) {
          iconData = Icons.wb_sunny_outlined;
        } else {
          iconData = Icons.light_mode_outlined;
        }

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                gradientColors[0].withOpacity(0.8),
                gradientColors[1].withOpacity(0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: gradientColors[0].withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题和时间行
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'INDOOR LIGHT',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lightProvider.lightCondition,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('HH:mm').format(DateTime.now()),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // 水平布局：环形进度和信息
                Row(
                  children: [
                    // 环形进度指示器
                    Container(
                      width: 120,
                      height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 外圈背景
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              value: 1,
                              strokeWidth: 8,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withOpacity(0.1),
                              ),
                            ),
                          ),
                          // 进度条
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              value: lightProvider.lightLevel / 100,
                              strokeWidth: 8,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          // 中心内容
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(iconData, color: Colors.white, size: 24),
                              const SizedBox(height: 4),
                              Text(
                                '${lightProvider.lightLevel}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    // 右侧信息栏
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 建议卡片
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.tips_and_updates_outlined,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    lightProvider.suggestion,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          // 今日最高光照值
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.trending_up_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Today\'s Peak',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      '${lightProvider.highestLightToday}%',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLightHistorySection(BuildContext context) {
    return Consumer2<LightProvider, WeatherProvider>(
      builder: (context, lightProvider, weatherProvider, child) {
        final allData = lightProvider.todayLightHistory;

        // 过滤出日落之前的数据
        final filteredData =
            allData.where((item) {
              return weatherProvider.sunset == null ||
                  item.timestamp.isBefore(weatherProvider.sunset!) ||
                  item.timestamp.isAtSameMomentAs(weatherProvider.sunset!);
            }).toList();

        return SimpleLightChart(
          data: filteredData,
          sunrise: weatherProvider.sunrise,
          sunset: weatherProvider.sunset,
        );
      },
    );
  }

  Widget _buildRecommendationsSection(
    BuildContext context,
    LightProvider lightProvider,
  ) {
    // 根据当前光照条件提供个性化建议
    List<Map<String, dynamic>> recommendations = [];

    if (lightProvider.lightLevel < 30) {
      recommendations = [
        {
          'icon': Icons.lightbulb_outline,
          'title': 'Turn on more lights',
          'description': 'Supplement with artificial lighting',
          'color': Colors.amber,
        },
        {
          'icon': Icons.curtains_closed_outlined,
          'title': 'Open curtains',
          'description': 'Let natural light in',
          'color': Colors.orange,
        },
      ];
    } else if (lightProvider.lightLevel > 90) {
      recommendations = [
        {
          'icon': Icons.curtains_outlined,
          'title': 'Use blinds',
          'description': 'Reduce glare and eye strain',
          'color': Colors.blue,
        },
        {
          'icon': Icons.filter_drama_outlined,
          'title': 'Adjust monitor',
          'description': 'Reduce screen brightness',
          'color': Colors.indigo,
        },
      ];
    } else {
      recommendations = [
        {
          'icon': Icons.computer_outlined,
          'title': 'Perfect for work',
          'description': 'Optimal lighting conditions',
          'color': Colors.green,
        },
        {
          'icon': Icons.menu_book_outlined,
          'title': 'Good for reading',
          'description': 'Comfortable light level',
          'color': Colors.teal,
        },
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            'Recommendations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recommendations.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final rec = recommendations[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: rec['color'].withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: rec['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(rec['icon'], color: rec['color'], size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rec['title'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rec['description'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
