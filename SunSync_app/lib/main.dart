// main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart'; // 这个文件会由 flutterfire configure 命令生成
import 'screens/home_screen.dart';
import 'screens/light_screen.dart';
import 'screens/reminder_screen.dart';
import 'providers/weather_provider.dart';
import 'providers/light_provider.dart';
import 'providers/reminder_provider.dart';
import 'services/simple_notification_manager.dart';

void main() async {
  // 初始化Flutter绑定
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => WeatherProvider()),
        ChangeNotifierProvider(create: (context) => LightProvider()),
        ChangeNotifierProvider(create: (context) => ReminderProvider()),
      ],
      child: MaterialApp(
        title: 'SunSync',
        theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
        home: const MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _controller;

  // 创建三个页面数组
  static final List<Widget> _pages = [
    const HomeScreen(),
    const LightScreen(),
    const ReminderScreen(),
  ];

  // 导航项配置
  final List<Map<String, dynamic>> _navItems = [
    {
      'icon': Icons.home_rounded,
      'activeIcon': Icons.home_rounded,
      'label': 'Home',
      'color': Colors.blue,
    },
    {
      'icon': Icons.lightbulb_outline_rounded,
      'activeIcon': Icons.lightbulb_rounded,
      'label': 'Light',
      'color': Colors.amber,
    },
    {
      'icon': Icons.alarm_rounded,
      'activeIcon': Icons.alarm_on_rounded,
      'label': 'Reminder',
      'color': Colors.purple,
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    // 初始化通知管理器
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SimpleNotificationManager().init(context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_navItems.length, (index) {
                  return GestureDetector(
                    onTap: () => _onItemTapped(index),
                    child: _buildNavItem(index),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final isSelected = _selectedIndex == index;
    final item = _navItems[index];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color:
            isSelected ? item['color'].withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(25),
      ),
      child: AnimatedScale(
        scale: isSelected ? 1.0 : 0.9,
        duration: const Duration(milliseconds: 200),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: isSelected ? 1.0 : 0.0),
              duration: const Duration(milliseconds: 200),
              builder: (context, value, child) {
                return Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient:
                        isSelected
                            ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                item['color'],
                                item['color'].withOpacity(0.7),
                              ],
                            )
                            : null,
                    boxShadow:
                        isSelected
                            ? [
                              BoxShadow(
                                color: item['color'].withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                            : null,
                  ),
                  child: Icon(
                    isSelected ? item['activeIcon'] : item['icon'],
                    color: isSelected ? Colors.white : Colors.grey[600],
                    size: 22,
                  ),
                );
              },
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected ? item['color'] : Colors.grey[600],
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              child: Text(item['label']),
            ),
          ],
        ),
      ),
    );
  }
}
