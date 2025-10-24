import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  final String broker = 'test.mosquitto.org';
  final int port = 1883;
  final String topic = 'esp32cam/detection';

  late MqttServerClient client;
  Function(Map<String, dynamic>)? onMessageReceived;

  Future<void> connect() async {
    client = MqttServerClient(broker, '');
    client.port = port;
    client.logging(on: false);
    client.keepAlivePeriod = 20;
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('flutter_client_${DateTime.now().millisecondsSinceEpoch}')
        .startClean();
    client.connectionMessage = connMessage;

    try {
      await client.connect();
    } catch (e) {
      client.disconnect();
      print('❌ MQTT connection failed: $e');
      return;
    }

    client.subscribe(topic, MqttQos.atMostOnce);

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMessage = c![0].payload as MqttPublishMessage;
      final payload =
          MqttPublishPayload.bytesToStringAsString(recMessage.payload.message);
      final data = jsonDecode(payload) as Map<String, dynamic>;
      if (onMessageReceived != null) onMessageReceived!(data);
    });
  }

  void onDisconnected() {
    print('MQTT disconnected');
  }

  void onConnected() {
    print('MQTT connected');
  }

  void disconnect() {
    client.disconnect();
  }
}
