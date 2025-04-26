import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_screen.dart';
import 'screens/light_screen.dart';
import 'screens/reminder_screen.dart';
import 'providers/weather_provider.dart';
import 'providers/light_provider.dart';

Future<void> main() async {
  // 初始化Flutter绑定
  WidgetsFlutterBinding.ensureInitialized();
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

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // 创建三个页面数组
  static final List<Widget> _pages = [
    const HomeScreen(),
    const LightScreen(),
    const ReminderScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
            label: 'Light',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.alarm), label: 'Reminder'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
