// services/mqtt_service.dart

import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  late MqttServerClient client;
  final StreamController<Map<String, String>> _messageStreamController =
      StreamController<Map<String, String>>.broadcast();
  final Map<String, String> _latestMessages = {};

  // MQTT连接配置
  static const String broker = 'mqtt.cetools.org';
  static const int port = 1884;
  static const String username = 'student';
  static const String password = 'ce2021-mqtt-forget-whale';
  static const String clientId = 'flutter_light_monitor';

  // 订阅的主题
  static const String topicLight = 'student/SunSync/realtime/light';
  static const String topicSuggest = 'student/SunSync/realtime/suggestion';
  static const String topicHighestLight = 'student/SunSync/highest_light';

  Stream<Map<String, String>> getMessagesStream() {
    return _messageStreamController.stream;
  }

  Future<void> connect() async {
    client = MqttServerClient(broker, clientId);
    client.port = port;
    client.logging(on: false);
    client.keepAlivePeriod = 60;
    client.onDisconnected = _onDisconnected;
    client.onConnected = _onConnected;
    client.onSubscribed = _onSubscribed;

    final connMessage = MqttConnectMessage()
        .authenticateAs(username, password)
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    client.connectionMessage = connMessage;

    try {
      await client.connect();

      if (client.connectionStatus!.state == MqttConnectionState.connected) {
        print('MQTT client connected');

        // 订阅主题
        client.subscribe(topicLight, MqttQos.atLeastOnce);
        client.subscribe(topicSuggest, MqttQos.atLeastOnce);
        client.subscribe(topicHighestLight, MqttQos.atLeastOnce);

        // 监听消息
        client.updates!.listen(_onMessage);
      } else {
        print('MQTT client connection failed');
        client.disconnect();
      }
    } catch (e) {
      print('MQTT client exception: $e');
      client.disconnect();
      rethrow;
    }
  }

  void _onConnected() {
    print('MQTT client connected');
  }

  void _onDisconnected() {
    print('MQTT client disconnected');
  }

  void _onSubscribed(String topic) {
    print('MQTT client subscribed to topic: $topic');
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage>> event) {
    final MqttPublishMessage recMess = event[0].payload as MqttPublishMessage;
    final String topic = event[0].topic;
    final String message = MqttPublishPayload.bytesToStringAsString(
      recMess.payload.message,
    );

    _latestMessages[topic] = message;
    _messageStreamController.add(Map.from(_latestMessages));
  }

  void disconnect() {
    client.disconnect();
    _messageStreamController.close();
  }
}
