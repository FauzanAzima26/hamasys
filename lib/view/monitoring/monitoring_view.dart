import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hamasys/services/mqtt_service.dart';
import 'package:mqtt_client/mqtt_client.dart';

class MonitoringView extends StatefulWidget {
  const MonitoringView({super.key});

  @override
  State<MonitoringView> createState() => _MonitoringViewState();
}

class _MonitoringViewState extends State<MonitoringView>
    with SingleTickerProviderStateMixin {
  bool alatHidup = false;
  bool ledCamHidup = false;

  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;

  final List<Map<String, dynamic>> _logMessages = [];
  late MqttService _mqttService;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _colorAnimation = ColorTween(
      begin: Colors.red.shade400,
      end: Colors.green.shade600,
    ).animate(_animationController);

    // MQTT Service
    _mqttService = MqttService();
    _mqttService.onMessageReceived = (data) {
      setState(() {
        String time = DateTime.fromMillisecondsSinceEpoch(
          (data['timestamp'] * 1000).toInt(),
        ).toString();
        List objects = data['objects'];
        _logMessages.insert(0, {
          'pir': objects.contains('person') || objects.contains('bird')
              ? '1'
              : '0',
          'jarak': '-', 
          'time': time,
          'mqtt': objects.join(', '),
        });
      });
    };
    _mqttService.connect();
  }

  void toggleAlat() {
    setState(() {
      alatHidup = !alatHidup;
      alatHidup
          ? _animationController.forward()
          : _animationController.reverse();
    });

    final payload = {'command': alatHidup ? 'ON' : 'OFF'};
    _mqttService.client.publishMessage(
      'esp32cam/command',
      MqttQos.atMostOnce,
      MqttClientPayloadBuilder().addUTF8String(jsonEncode(payload)).payload!,
    );

    if (kDebugMode) {
      print('✅ Command sent: ${payload['command']}');
    }
  }

  void toggleLedCam() {
    setState(() => ledCamHidup = !ledCamHidup);

    final payload = {'led': ledCamHidup ? 'ON' : 'OFF'};
    _mqttService.client.publishMessage(
      'esp32cam/led',
      MqttQos.atMostOnce,
      MqttClientPayloadBuilder().addUTF8String(jsonEncode(payload)).payload!,
    );

    if (kDebugMode) {
      print('✅ LED Cam command sent: ${payload['led']}');
    }
  }

  void bunyikanSuara() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Suara pengusir hama diaktifkan!')),
    );
  }

  Widget _buildLogItem(Map<String, dynamic> log) {
    bool terdeteksi = log['pir'] == '1';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: ListTile(
        leading: Icon(
          terdeteksi ? Icons.warning_amber_rounded : Icons.check_circle,
          color: terdeteksi ? Colors.red : Colors.green,
          size: 28,
        ),
        title: Text(
          terdeteksi ? "Hama Terdeteksi!" : "Tidak Ada Hama",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: terdeteksi ? Colors.red : Colors.green,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Objek: ${log['mqtt'] ?? '-'}"),
            Text("Jarak: ${log['jarak']} cm"),
            Text(
              "Waktu: ${log['time']}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _mqttService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring Alat & Log Hama'),
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 77, 212, 84),
        centerTitle: true,
        elevation: 3,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Tombol On/Off Alat
            AnimatedBuilder(
              animation: _colorAnimation,
              builder: (context, child) {
                return GestureDetector(
                  onTap: toggleAlat,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          _colorAnimation.value!.withOpacity(0.9),
                          _colorAnimation.value!,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.7),
                          offset: const Offset(-6, -6),
                          blurRadius: 8,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(6, 6),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.power_settings_new,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Tombol LED Cam
            ElevatedButton.icon(
              onPressed: toggleLedCam,
              icon: Icon(
                ledCamHidup ? Icons.lightbulb : Icons.lightbulb_outline,
                color: Colors.white,
              ),
              label: Text(
                ledCamHidup ? 'Matikan LED Cam' : 'Nyalakan LED Cam',
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    ledCamHidup ? Colors.green.shade600 : Colors.red.shade400,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              ),
            ),
            const SizedBox(height: 12),

            // Tombol Bunyikan Suara
            ElevatedButton.icon(
              onPressed: alatHidup ? bunyikanSuara : null,
              icon: const Icon(Icons.volume_up),
              label: const Text('Bunyikan Suara', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromARGB(255, 77, 212, 84),
                disabledBackgroundColor: Colors.grey.shade400,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              ),
            ),
            const SizedBox(height: 20),

            // Log MQTT
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Log Monitoring Hama Real-Time",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: _logMessages.isEmpty
                  ? const Center(
                      child: Text(
                        'Menunggu data hama...',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _logMessages.length,
                      itemBuilder: (context, index) =>
                          _buildLogItem(_logMessages[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
