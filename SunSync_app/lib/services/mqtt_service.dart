import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:flutter/material.dart';

class MqttService {
  // MQTT客户端
  MqttServerClient? _client;

  // MQTT服务器信息
  final String _host = 'mqtt.cetools.org';
  final int _port = 1884;
  final String _username = 'student';
  final String _password = 'ce2021-mqtt-forget-whale';
  final String _clientIdentifier =
      'flutter_client_${DateTime.now().millisecondsSinceEpoch}';

  // MQTT主题
  final String _topicLight = 'student/SunSync/realtime/light';
  final String _topicSuggestion = 'student/SunSync/realtime/suggestion';
  final String _topicTime = 'student/SunSync/realtime/time';
  final String _topicHighestLight = 'student/SunSync/highest_light';

  // 数据流控制器
  final _lightController = StreamController<String>.broadcast();
  final _suggestionController = StreamController<String>.broadcast();
  final _timeController = StreamController<String>.broadcast();
  final _highestLightController = StreamController<String>.broadcast();

  // 数据流
  Stream<String> get lightStream => _lightController.stream;
  Stream<String> get suggestionStream => _suggestionController.stream;
  Stream<String> get timeStream => _timeController.stream;
  Stream<String> get highestLightStream => _highestLightController.stream;

  // 当前数据值
  String _currentLight = '0';
  String _currentSuggestion = '';
  String _currentTime = '';
  String _currentHighestLight = '0';

  // 获取当前值的getter方法
  String get currentLight => _currentLight;
  String get currentSuggestion => _currentSuggestion;
  String get currentTime => _currentTime;
  String get currentHighestLight => _currentHighestLight;

  // 初始化并连接到MQTT服务器
  Future<void> initialize() async {
    _client = MqttServerClient(_host, _clientIdentifier);
    _client!.port = _port;
    _client!.logging(on: false);
    _client!.keepAlivePeriod = 60;
    _client!.onDisconnected = _onDisconnected;
    _client!.onConnected = _onConnected;

    final connMess = MqttConnectMessage()
        .withClientIdentifier(_clientIdentifier)
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    print('MQTT客户端连接...');
    _client!.connectionMessage = connMess;

    try {
      await _client!.connect(_username, _password);
    } catch (e) {
      print('MQTT连接异常: $e');
      _client!.disconnect();
      return;
    }

    if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
      print('MQTT客户端已连接');
      _subscribeToTopics();
    } else {
      print('MQTT连接失败: ${_client!.connectionStatus!.state}');
      _client!.disconnect();
    }
  }

  // 订阅主题
  void _subscribeToTopics() {
    // 订阅光照强度
    _client!.subscribe(_topicLight, MqttQos.atLeastOnce);

    // 订阅建议
    _client!.subscribe(_topicSuggestion, MqttQos.atLeastOnce);

    // 订阅时间
    _client!.subscribe(_topicTime, MqttQos.atLeastOnce);

    // 订阅最高光照
    _client!.subscribe(_topicHighestLight, MqttQos.atLeastOnce);

    // 监听消息
    _client!.updates!.listen(_onMessage);
  }

  // 消息处理
  void _onMessage(List<MqttReceivedMessage<MqttMessage>> c) {
    final recMess = c[0].payload as MqttPublishMessage;
    final topic = c[0].topic;
    final payload = MqttPublishPayload.bytesToStringAsString(
      recMess.payload.message,
    );

    //print('收到消息: 主题=$topic, 内容=$payload');

    // 根据主题处理不同的消息
    if (topic == _topicLight) {
      _currentLight = payload;
      _lightController.add(payload);
    } else if (topic == _topicSuggestion) {
      _currentSuggestion = payload;
      _suggestionController.add(payload);
    } else if (topic == _topicTime) {
      _currentTime = payload;
      _timeController.add(payload);
    } else if (topic == _topicHighestLight) {
      _currentHighestLight = payload;
      _highestLightController.add(payload);
    }
  }

  // 连接成功回调
  void _onConnected() {
    print('MQTT客户端连接成功');
  }

  // 断开连接回调
  void _onDisconnected() {
    print('MQTT客户端断开连接');
  }

  // 关闭连接和流
  void dispose() {
    _lightController.close();
    _suggestionController.close();
    _timeController.close();
    _highestLightController.close();
    _client?.disconnect();
  }
}
