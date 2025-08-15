import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MonitoringView extends StatefulWidget {
  const MonitoringView({super.key});

  @override
  State<MonitoringView> createState() => _MonitoringViewState();
}

class _MonitoringViewState extends State<MonitoringView>
    with SingleTickerProviderStateMixin {
  bool alatHidup = false;

  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;

  // Bagian untuk data ThingSpeak
  final List<Map<String, dynamic>> _logMessages = [];
  late Timer _timer;
  static const String channelId = "3034607";
  static const String readApiKey = "83E30R03Y3UOFJK1";
  static const String writeApiKey = "F37QJQ0FRO2UQ1QM";

  String get readUrl =>
      "https://api.thingspeak.com/channels/$channelId/feeds.json?api_key=$readApiKey&results=5";

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

    // Ambil data tiap 5 detik
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      fetchThingSpeakData();
    });
    fetchThingSpeakData();
  }

  void toggleAlat(bool value) {
    setState(() {
      alatHidup = value;
      if (alatHidup) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void bunyikanSuara() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Suara pengusir hama diaktifkan!')),
    );
  }

  Future<void> fetchThingSpeakData() async {
    try {
      final response = await http.get(Uri.parse(readUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final feeds = (data['feeds'] ?? []) as List;

        setState(() {
          _logMessages.clear();
          for (var feed in feeds.reversed) {
            String pir1 = feed['field1'] ?? '0';
            String jarak = feed['field5'] ?? '0';
            String waktu = feed['created_at'] ?? '';

            _logMessages.add({'pir': pir1, 'jarak': jarak, 'time': waktu});
          }
        });
      } else {
        debugPrint("Gagal ambil data: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> resetThingSpeakData() async {
    const String updateUrl = "https://api.thingspeak.com/update";

    try {
      final response = await http.get(
        Uri.parse('$updateUrl?api_key=$writeApiKey&field1=0&field5=0'),
      );

      if (response.statusCode == 200) {
        if (response.body == '0') {
          debugPrint("❌ Gagal reset data: Channel tidak update");
        } else {
          debugPrint("✅ Data berhasil direset. Entry ID: ${response.body}");
          fetchThingSpeakData();
        }
      } else {
        debugPrint("❌ Gagal reset data: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("⚠ Error saat reset data: $e");
    }
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Konfirmasi Reset"),
          content: const Text(
            "Apakah Anda yakin ingin mereset data?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(ctx);
                resetThingSpeakData();
              },
              child: const Text("Reset"),
            ),
          ],
        );
      },
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
    _timer.cancel();
    _animationController.dispose();
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
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: "Reset Data",
            onPressed: _showResetConfirmation,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Bagian Monitoring
          AnimatedBuilder(
            animation: _colorAnimation,
            builder: (context, child) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _colorAnimation.value?.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Alat ${alatHidup ? "Hidup" : "Mati"}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: alatHidup ? Colors.green : Colors.red.shade700,
                    ),
                  ),
                  Switch(
                    value: alatHidup,
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.red.shade700,
                    onChanged: toggleAlat,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: alatHidup ? bunyikanSuara : null,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, 
              backgroundColor: const Color.fromARGB(255, 77, 212, 84),
              padding: const EdgeInsets.symmetric(vertical: 16),
              disabledBackgroundColor: Colors.grey.shade400,
            ),
            child: const Text(
              'Bunyikan Suara',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          const Divider(height: 32, thickness: 2),

          // Bagian Log Hama
          const Text(
            "Log Monitoring Hama Real-Time",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _logMessages.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Menunggu data hama...',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                )
              : Column(
                  children:
                      _logMessages.map((log) => _buildLogItem(log)).toList(),
                ),
        ],
      ),
    );
  }
}
