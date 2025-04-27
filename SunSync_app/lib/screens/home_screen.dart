// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/weather_widget.dart';
import '../widgets/sunrise_sunset_widget.dart';
import '../widgets/activity_suggestion_widget.dart';

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
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 全屏天气背景
          const WeatherWidget(),

          // 内容层
          RefreshIndicator(
            onRefresh: () async {
              await Provider.of<WeatherProvider>(
                context,
                listen: false,
              ).fetchWeatherForCurrentLocation();
            },
            color: Colors.white,
            backgroundColor: Colors.transparent,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // 空白区域，为天气信息留出空间
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.38,
                  ),
                ),

                // 内容区域
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(color: Colors.transparent),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          // 日出日落部分
                          SunriseSunsetWidget(),

                          SizedBox(height: 24),

                          // 活动推荐部分
                          ActivitySuggestionWidget(),

                          SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
