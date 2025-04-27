// providers/light_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../services/mqtt_service.dart';
import '../services/firebase_service.dart';
import '../models/light_history_model.dart';

class LightProvider with ChangeNotifier {
  final MqttService _mqttService = MqttService();
  final FirebaseService _firebaseService = FirebaseService();
  StreamSubscription? _mqttSubscription;
  StreamSubscription? _lightHistorySubscription;
  Timer? _uploadTimer;

  String _lightCondition = 'Measuring...';
  String _suggestion = '';
  int _lightLevel = 0;
  int _highestLightToday = 0;
  List<LightHistoryModel> _todayLightHistory = [];
  DateTime? _lastUploadTime;

  // 每5分钟上传一次数据
  static const Duration uploadInterval = Duration(minutes: 5);

  String get lightCondition => _lightCondition;
  String get suggestion => _suggestion;
  int get lightLevel => _lightLevel;
  int get highestLightToday => _highestLightToday;
  List<LightHistoryModel> get todayLightHistory => _todayLightHistory;

  LightProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _connectToMqtt();
    _startHistoryListener();
    _startUploadTimer();
  }

  void _startHistoryListener() {
    _lightHistorySubscription?.cancel();
    _lightHistorySubscription = _firebaseService.getTodayLightHistory().listen(
      (history) {
        _todayLightHistory = history;
        notifyListeners();
      },
      onError: (error) {
        print('Error fetching light history: $error');
      },
    );
  }

  void _startUploadTimer() {
    _uploadTimer?.cancel();
    _uploadTimer = Timer.periodic(uploadInterval, (timer) {
      _uploadLightData();
    });
  }

  Future<void> _uploadLightData() async {
    // 只在白天上传数据
    final now = DateTime.now();

    // 检查是否应该上传（仅在白天且距离上次上传足够间隔）
    if (_shouldUploadData(now)) {
      try {
        final lightHistory = LightHistoryModel(
          id: now.millisecondsSinceEpoch.toString(),
          timestamp: now,
          lightLevel: _lightLevel,
          userId: _firebaseService.currentUserId ?? '',
          date: DateTime(now.year, now.month, now.day),
        );

        await _firebaseService.addLightHistory(lightHistory);
        _lastUploadTime = now;
        print('Light data uploaded: $_lightLevel at $now');

        // 立即通知监听器更新数据
        notifyListeners();
      } catch (e) {
        print('Error uploading light data: $e');
      }
    } else {
      print('Skip upload - Current time: $now, Last upload: $_lastUploadTime');
    }
  }

  bool _shouldUploadData(DateTime now) {
    // 修改为全天上传（用于测试）
    // 实际使用时可以改回只在白天上传

    // 检查上次上传时间
    if (_lastUploadTime == null) {
      return true;
    }

    return now.difference(_lastUploadTime!) >= uploadInterval;
  }

  Future<void> _connectToMqtt() async {
    try {
      await _mqttService.connect();
      _mqttSubscription = _mqttService.getMessagesStream().listen((messages) {
        if (messages[MqttService.topicLight] != null) {
          int value = int.tryParse(messages[MqttService.topicLight]!) ?? 0;
          _updateLightLevel(value);
        }
        if (messages[MqttService.topicSuggest] != null) {
          _updateSuggestion(messages[MqttService.topicSuggest]!);
        }
        if (messages[MqttService.topicHighestLight] != null) {
          int value =
              int.tryParse(messages[MqttService.topicHighestLight]!) ?? 0;
          _updateHighestLight(value);
        }
        notifyListeners();
      });
    } catch (e) {
      print('Error connecting to MQTT: $e');
      _setError('Connection failed');
    }
  }

  void _updateLightLevel(int value) {
    _lightLevel = value;
    if (value < 30) {
      _lightCondition = 'Low Light';
    } else if (value < 70) {
      _lightCondition = 'Good Light';
    } else {
      _lightCondition = 'Bright Light';
    }
  }

  void _updateSuggestion(String suggestion) {
    _suggestion = suggestion;
  }

  void _updateHighestLight(int value) {
    _highestLightToday = value;
  }

  void _setError(String message) {
    _lightCondition = message;
    _suggestion = 'Unable to get data';
    notifyListeners();
  }

  @override
  void dispose() {
    _mqttSubscription?.cancel();
    _lightHistorySubscription?.cancel();
    _uploadTimer?.cancel();
    _mqttService.disconnect();
    super.dispose();
  }
}
