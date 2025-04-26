import 'package:flutter/material.dart';
import '../services/mqtt_service.dart';

class LightProvider extends ChangeNotifier {
  final MqttService _mqttService = MqttService();

  // 光照数据
  String _currentLight = '0';
  String _highestLight = '0';
  String _suggestion = '';
  String _time = '';

  // 连接状态
  bool _isConnected = false;
  bool _isLoading = false;
  String? _error;

  // Getters
  String get currentLight => _currentLight;
  String get highestLight => _highestLight;
  String get suggestion => _suggestion;
  String get time => _time;
  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 构造函数
  LightProvider() {
    // 初始化连接到MQTT服务器
    _connectToMqtt();
  }

  // 连接到MQTT服务器
  Future<void> _connectToMqtt() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _mqttService.initialize();

      // 在连接成功后立即获取当前值
      _currentLight = _mqttService.currentLight;
      _highestLight = _mqttService.currentHighestLight; // 获取当前最高值
      _suggestion = _mqttService.currentSuggestion;
      _time = _mqttService.currentTime;

      // 订阅数据流更新
      _mqttService.lightStream.listen((light) {
        _currentLight = light;
        notifyListeners();
      });

      _mqttService.suggestionStream.listen((suggestion) {
        _suggestion = suggestion;
        notifyListeners();
      });

      _mqttService.timeStream.listen((time) {
        _time = time;
        notifyListeners();
      });

      _mqttService.highestLightStream.listen((highestLight) {
        _highestLight = highestLight;
        notifyListeners();
      });

      _isConnected = true;
      notifyListeners(); // 确保在获取初始值后通知更新
    } catch (e) {
      _error = e.toString();
      print('连接MQTT错误: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 重新连接到MQTT服务器
  Future<void> reconnect() async {
    await _connectToMqtt();
  }

  // 关闭MQTT连接
  void dispose() {
    _mqttService.dispose();
    super.dispose();
  }
}
