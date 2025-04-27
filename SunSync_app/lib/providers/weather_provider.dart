// providers/weather_provider.dart
import 'package:flutter/material.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();

  // 默认值
  String _location = 'Loading...';
  double _temperature = 0.0;
  String _condition = '';
  double _highTemp = 0.0;
  double _lowTemp = 0.0;
  bool _isLoading = false;
  String? _error;
  DateTime? _sunrise;
  DateTime? _sunset;

  // Getters
  String get location => _location;
  double get temperature => _temperature;
  String get condition => _condition;
  double get highTemp => _highTemp;
  double get lowTemp => _lowTemp;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get sunrise => _sunrise;
  DateTime? get sunset => _sunset;

  // 通过城市名称获取天气数据
  Future<void> fetchWeatherByCity(String city) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final weatherData = await _weatherService.getWeatherByCity(city);
      _updateWeatherData(weatherData);
    } catch (e) {
      _error = e.toString();
      print('Error fetching weather: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 获取当前位置的天气
  Future<void> fetchWeatherForCurrentLocation() async {
    // 由于我们还没有集成位置服务，暂时使用伦敦作为默认值
    await fetchWeatherByCity('London');
  }

  // 从API响应中更新天气数据
  void _updateWeatherData(Map<String, dynamic> data) {
    final main = data['main'];
    final weather = data['weather'][0];

    _location = data['name'];
    _temperature = (main['temp'] as num).toDouble();
    _condition = weather['main'];
    _highTemp = (main['temp_max'] as num).toDouble();
    _lowTemp = (main['temp_min'] as num).toDouble();

    // 解析日出日落时间
    if (data['sunrise'] != null) {
      _sunrise = DateTime.parse(data['sunrise']);
    }
    if (data['sunset'] != null) {
      _sunset = DateTime.parse(data['sunset']);
    }
  }

  // 计算当前太阳位置进度 (0.0 到 1.0)
  double getSunProgress() {
    if (_sunrise == null || _sunset == null) return 0.0;

    final now = DateTime.now();

    // 如果当前时间在日出之前或日落之后，返回0
    if (now.isBefore(_sunrise!) || now.isAfter(_sunset!)) {
      return 0.0;
    }

    // 计算日出到日落的总分钟数
    final totalMinutes = _sunset!.difference(_sunrise!).inMinutes;

    // 计算当前时间距离日出的分钟数
    final elapsedMinutes = now.difference(_sunrise!).inMinutes;

    // 返回进度 (0.0 到 1.0)
    return elapsedMinutes / totalMinutes;
  }

  // 判断当前是否是白天
  bool isDaytime() {
    if (_sunrise == null || _sunset == null) return true;

    final now = DateTime.now();
    return now.isAfter(_sunrise!) && now.isBefore(_sunset!);
  }
}
